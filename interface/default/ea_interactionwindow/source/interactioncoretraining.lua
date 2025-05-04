----------------------------------------------------------------
-- Local variables
----------------------------------------------------------------
EA_Window_InteractionCoreTraining =
{
    advanceData      = {},
    selectedAdvances = {},
    selectedCosts    = 0,
    
    SORT_ASCENDING   = true,
    SORT_DESCENDING  = false,
    currentSort      = 2,
    sortButtonData   = {},
    
    ANCHOR_CURSOR    = { Point = "topleft", RelativeTo = "CursorWindow", RelativePoint = "bottomleft", XOffset = 30, YOffset = -20 },


    Settings = 
    {
        availabilityFilter = true,
    }
}

EA_Window_InteractionCoreTraining.sortButtonData[1] = { label = StringTables.Training.LABEL_SORT_ABILITY, direction = EA_Window_InteractionCoreTraining.SORT_ASCENDING, active = false, }
EA_Window_InteractionCoreTraining.sortButtonData[2] = { label = StringTables.Training.LABEL_SORT_RANK,    direction = EA_Window_InteractionCoreTraining.SORT_ASCENDING, active = true,  }
EA_Window_InteractionCoreTraining.sortButtonData[3] = { label = StringTables.Training.LABEL_SORT_PATH,    direction = EA_Window_InteractionCoreTraining.SORT_ASCENDING, active = false, }


----------------------------------------------------------------
-- Standard Window Functions
----------------------------------------------------------------
function EA_Window_InteractionCoreTraining.Initialize()

    EA_Window_InteractionCoreTraining.InitializeLabels()
    EA_Window_InteractionCoreTraining.UpdatePlayerResources(GameData.Player.money)
    EA_Window_InteractionCoreTraining.SetListRowTints()
    EA_Window_InteractionCoreTraining.SetListRowNameTints()

    -- register event handlers
    WindowRegisterEventHandler("EA_Window_InteractionCoreTraining", SystemData.Events.PLAYER_CAREER_CATEGORY_UPDATED,  "EA_Window_InteractionCoreTraining.Refresh")
    WindowRegisterEventHandler("EA_Window_InteractionCoreTraining", SystemData.Events.PLAYER_MONEY_UPDATED,            "EA_Window_InteractionCoreTraining.UpdatePlayerResources" )
    WindowRegisterEventHandler("EA_Window_InteractionCoreTraining", SystemData.Events.PLAYER_ABILITIES_LIST_UPDATED,   "EA_Window_InteractionCoreTraining.Refresh" )
    WindowRegisterEventHandler("EA_Window_InteractionCoreTraining", SystemData.Events.PLAYER_SINGLE_ABILITY_UPDATED,   "EA_Window_InteractionCoreTraining.Refresh" )
    
    EA_Window_InteractionCoreTraining.selectedAdvances = {}
    EA_Window_InteractionCoreTraining.selectedCosts    = 0
    
    -- No Abilities Text
    LabelSetText( "EA_Window_InteractionCoreTrainingNoAbiltitiesText", GetString( StringTables.Default.TEXT_TRAINER_NO_ABILITITES ) )

end

function EA_Window_InteractionCoreTraining.Shutdown()
end

function EA_Window_InteractionCoreTraining.OnHidden()
    EA_Window_InteractionCoreTraining.selectedAdvances = {}
    WindowUtils.RemoveFromOpenList("EA_Window_InteractionCoreTraining")
end

function EA_Window_InteractionCoreTraining.OnShown()
    WindowUtils.OnShown(EA_Window_InteractionCoreTraining.Hide, WindowUtils.Cascade.MODE_AUTOMATIC)
end

function EA_Window_InteractionCoreTraining.ToggleContextMenu()
end

function EA_Window_InteractionCoreTraining.Show()
    WindowSetShowing( "EA_Window_InteractionCoreTraining", true )
    EA_Window_InteractionCoreTraining.LoadAdvances()
    EA_Window_InteractionCoreTraining.RefreshList()
    EA_Window_InteractionCoreTraining.selectedAdvances = {}
end

function EA_Window_InteractionCoreTraining.Hide()
    WindowSetShowing( "EA_Window_InteractionCoreTraining", false )
end

function EA_Window_InteractionCoreTraining.Refresh()
    EA_Window_InteractionCoreTraining.LoadAdvances()
    EA_Window_InteractionCoreTraining.RefreshList()
end

function EA_Window_InteractionCoreTraining.InitializeAvailabilityFilter()
    EA_LabelCheckButton.Initialize( EA_Window_InteractionCoreTraining.Settings.availabilityFilter )
end

function EA_Window_InteractionCoreTraining.ToggleAvailabilityFilter()
    EA_LabelCheckButton.Toggle()
    EA_Window_InteractionCoreTraining.Settings.availabilityFilter = EA_LabelCheckButton.IsChecked()

    EA_Window_InteractionCoreTraining.RefreshList()
end

----------------------------------------------------------------
-- Money/resource/display initialization and updates
----------------------------------------------------------------
function EA_Window_InteractionCoreTraining.UpdatePlayerResources(currentMoney)
    MoneyFrame.FormatMoney( "EA_Window_InteractionCoreTrainingPurse", currentMoney, MoneyFrame.SHOW_EMPTY_WINDOWS)
end

function EA_Window_InteractionCoreTraining.InitializeLabels()
    LabelSetText("EA_Window_InteractionCoreTrainingTitleBarText", GetString( StringTables.Default.TITLE_TRAINING ) )
    LabelSetText("EA_Window_InteractionCoreTrainingHint",         GetStringFromTable("TrainingStrings", StringTables.Training.HINT_SELECT_TO_PURCHASE) )
    LabelSetText("EA_Window_InteractionCoreTrainingPurseLabel",   GetStringFromTable("TrainingStrings", StringTables.Training.LABEL_PLAYER_PURSE_PREFIX) )

    ButtonSetText( "EA_Window_InteractionCoreTrainingSortButton1", GetStringFromTable("TrainingStrings", EA_Window_InteractionCoreTraining.sortButtonData[1].label ))
    ButtonSetText( "EA_Window_InteractionCoreTrainingSortButton2", GetStringFromTable("TrainingStrings", EA_Window_InteractionCoreTraining.sortButtonData[2].label ))
    ButtonSetText( "EA_Window_InteractionCoreTrainingSortButton3", GetStringFromTable("TrainingStrings", EA_Window_InteractionCoreTraining.sortButtonData[3].label ))

    LabelSetText( "EA_Window_InteractionCoreTrainingAvailabilityFilterLabel",   GetStringFromTable("TrainingStrings", StringTables.Training.LABEL_UNAVAILABLE_FILTER_BUTTON) )
    
    ButtonSetText( "EA_Window_InteractionCoreTrainingPurchaseButton",     GetStringFromTable("TrainingStrings", StringTables.Training.LABEL_PURCHASE_TRAINING ) )
    ButtonSetText( "EA_Window_InteractionCoreTrainingCancelButton",       GetStringFromTable("TrainingStrings", StringTables.Training.LABEL_CANCEL_TRAINING ) )

end

----------------------------------------------------------------
-- List Population
----------------------------------------------------------------
function EA_Window_InteractionCoreTraining.LoadAdvances()
    EA_Window_InteractionCoreTraining.advanceData = GameData.Player.GetAdvanceData()
end

function EA_Window_InteractionCoreTraining.RefreshList()

    -- DEBUG(L"EA_Window_InteractionCoreTraining.RefreshList()")

    -- set up the display ordering and filter settings
    local displayOrder = {}
    EA_Window_InteractionCoreTraining.SetSortFunction()
    
    if (EA_Window_InteractionCoreTraining.advanceData == nil)
    then
        -- this can occur during the initial load, in which case ignore it
        return
    end
    
    if (WindowGetShowing("EA_Window_InteractionCoreTraining") == false)
    then
        -- Why bother if nothing's being displayed anyway?
        return
    end
    
    table.sort(EA_Window_InteractionCoreTraining.advanceData, EA_Window_InteractionCoreTraining.FlexibleSort)
    
    for index, data in pairs(EA_Window_InteractionCoreTraining.advanceData)
    do
        local advanceData = EA_Window_InteractionCoreTraining.advanceData[index]
        
        local showEntry = InteractionUtils.CoreFilter(advanceData) and
                          InteractionUtils.IsAbility(advanceData) and
                          EA_Window_InteractionCoreTraining.AvailabilityIfSetFilter(advanceData) and
                          not InteractionUtils.HasAbilityFilter(advanceData) and
                          not InteractionUtils.HasPurchasedPackageToMaximum(advanceData)
        
        -- normal packages list
        if (showEntry)
        then
            table.insert(displayOrder, index)
        end
        
    end

    ListBoxSetDisplayOrder("EA_Window_InteractionCoreTrainingList", displayOrder)
    
    -- If there are no items in the list, show the 'none avail' text.
    WindowSetShowing( "EA_Window_InteractionCoreTrainingNoAbiltitiesText",  #displayOrder == 0 )    

    
end

function EA_Window_InteractionCoreTraining.Populate()
    if (nil == EA_Window_InteractionCoreTraining.advanceData)
    then
        -- DEBUG(L"  no advance data found!")
    end
    
    -- Post-process any conditional formatting
    for row, data in ipairs(EA_Window_InteractionCoreTrainingList.PopulatorIndices)
    do
        local advanceData = EA_Window_InteractionCoreTraining.advanceData[data]
        
        local rowFrame   = "EA_Window_InteractionCoreTrainingListRow"..row

        EA_Window_InteractionCoreTraining.PopulateName(rowFrame, advanceData)
        EA_Window_InteractionCoreTraining.PopulateIcon(rowFrame, advanceData)
        
        -- Process the visible money frames
        EA_Window_InteractionCoreTraining.PopulateCost(rowFrame, advanceData)
        
        -- Process the requirements string.
        EA_Window_InteractionCoreTraining.PopulateRank(rowFrame, advanceData)
        
        -- Process the type information
        EA_Window_InteractionCoreTraining.PopulateType(rowFrame, advanceData)
        
        EA_Window_InteractionCoreTraining.PopulatePath(rowFrame, advanceData)
        
        EA_Window_InteractionCoreTraining.ShowIconType(row, advanceData)
    end
    
    EA_Window_InteractionCoreTraining.SetListRowTints()
    EA_Window_InteractionCoreTraining.SetListRowNameTints()
    EA_Window_InteractionCoreTraining.UpdateListButtonStates()
end

function EA_Window_InteractionCoreTraining.PopulateName(rowFrame, advanceData)
    local labelFrame = rowFrame.."Name"
    
    if (advanceData.abilityInfo == nil)
    then
        LabelSetText( labelFrame, GetStringFormatFromTable("TrainingStrings", StringTables.Training.LABEL_CORE_TRAINING_ABILITY_NAME_FORMAT, {advanceData.advanceName}) )
    else
        LabelSetText( labelFrame, GetStringFormatFromTable("TrainingStrings", StringTables.Training.LABEL_CORE_TRAINING_ABILITY_NAME_FORMAT, {advanceData.abilityInfo.name}) )
    end
end

function EA_Window_InteractionCoreTraining.PopulateIcon(rowFrame, advanceData)
    local circleFrame = rowFrame.."Circle"
    local squareFrame = rowFrame.."Square"
    
    if (advanceData.abilityInfo == nil)
    then
        -- nothing yet
        local texture, x, y = GetIconData(advanceData.advanceIcon)
        
        CircleImageSetTexture(circleFrame,  texture, 32, 32)
        DynamicImageSetTexture(squareFrame, texture, x, y)
    else
        local texture, x, y = GetIconData(advanceData.abilityInfo.iconNum)

        CircleImageSetTexture(circleFrame,  texture, 32, 32)
        DynamicImageSetTexture(squareFrame, texture, x, y)
    end   
    
end
        
function EA_Window_InteractionCoreTraining.PopulateCost(rowFrame, advanceData)

    local moneyFrame = rowFrame.."CurrencyCost"
    MoneyFrame.FormatMoney(moneyFrame, advanceData.cashCost, MoneyFrame.HIDE_EMPTY_WINDOWS)

end
        
function EA_Window_InteractionCoreTraining.PopulateRank(rowFrame, advanceData)
    LabelSetText( rowFrame.."Rank", L""..advanceData.minimumRank)
end
        
function EA_Window_InteractionCoreTraining.PopulateType(rowFrame, advanceData)

    local typeText = GetStringFromTable("TrainingStrings", StringTables.Training.LABEL_ACTION_TYPE)
    if (InteractionUtils.IsTactic(advanceData))
    then
        typeText = GetStringFromTable("TrainingStrings", StringTables.Training.LABEL_TACTIC_TYPE)
    elseif (InteractionUtils.IsMorale(advanceData))
    then
        typeText = GetStringFromTable("TrainingStrings", StringTables.Training.LABEL_MORALE_TYPE)
    elseif (InteractionUtils.AdvanceIsPassive(advanceData))
    then
        typeText = GetStringFromTable("TrainingStrings", StringTables.Training.LABEL_PASSIVE_TYPE)
    end
    
    LabelSetText(rowFrame.."Type", typeText)
    
end

function EA_Window_InteractionCoreTraining.PopulatePath(rowFrame, advanceData)

    local pathText = L""

    if (advanceData.abilityInfo ~= nil)
    then
        if (advanceData.abilityInfo.specialization == 1)
        then
            pathText = GetStringFormat(StringTables.Default.LABEL_SPECIALIZATION_TITLE, { GetSpecializationPathName(GameData.Player.SPECIALIZATION_PATH_1) } )
        elseif (advanceData.abilityInfo.specialization == 2)
        then
            pathText = GetStringFormat(StringTables.Default.LABEL_SPECIALIZATION_TITLE, { GetSpecializationPathName(GameData.Player.SPECIALIZATION_PATH_2) } )
        elseif (advanceData.abilityInfo.specialization == 3)
        then
            pathText = GetStringFormat(StringTables.Default.LABEL_SPECIALIZATION_TITLE, { GetSpecializationPathName(GameData.Player.SPECIALIZATION_PATH_3) } )
        end
    end

    LabelSetText(rowFrame.."Path", pathText)

end

        
function EA_Window_InteractionCoreTraining.SetListRowTints()
    for row = 1, EA_Window_InteractionCoreTrainingList.numVisibleRows
    do
        -- Show the background for every other button   
        local color = GameDefs.RowColorInvalid
        
        local advanceData = nil
        
        if ( EA_Window_InteractionCoreTraining.advanceData ~= nil ) then
            advanceData = EA_Window_InteractionCoreTraining.advanceData[ ListBoxGetDataIndex("EA_Window_InteractionCoreTrainingList", row) ]
        end

        local row_mod = math.mod(row, 2)
        local color = DataUtils.GetAlternatingRowColor( row_mod )
        local targetRowWindow = "EA_Window_InteractionCoreTrainingListRow"..row
        
        if (advanceData ~= nil) then
            WindowSetTintColor(targetRowWindow.."RowBackground", color.r, color.g, color.b )
            WindowSetAlpha(targetRowWindow.."RowBackground", color.a)
        end
    end
end

function EA_Window_InteractionCoreTraining.SetListRowNameTints()
    for row = 1, EA_Window_InteractionCoreTrainingList.numVisibleRows
    do
        -- Show the background for every other button   
        local color = GameDefs.RowColorInvalid
        
        local advanceData = nil
        
        if ( EA_Window_InteractionCoreTraining.advanceData ~= nil )
        then
            advanceData = EA_Window_InteractionCoreTraining.advanceData[ ListBoxGetDataIndex("EA_Window_InteractionCoreTrainingList", row) ]
        end

        if (advanceData ~= nil)
        then
        
            local targetRowWindow = "EA_Window_InteractionCoreTrainingListRow"..row

            if (InteractionUtils.AvailabilityFilter(advanceData, EA_Window_InteractionCoreTraining.advanceData))
            then
                local textColor = DefaultColor.YELLOW
                LabelSetTextColor(targetRowWindow.."Name", textColor.r, textColor.g, textColor.b)
                
                local iconTint  = DefaultColor.RowColors.AVAILABLE
                local dataIndex = ListBoxGetDataIndex("EA_Window_InteractionCoreTrainingList", row)
                if (EA_Window_InteractionCoreTraining.selectedAdvances[dataIndex] == true)
                then
                    iconTint  = DefaultColor.RowColors.SELECTED
                end
                
                WindowSetTintColor( targetRowWindow.."Circle", iconTint.r, iconTint.g, iconTint.b )
                WindowSetTintColor( targetRowWindow.."Square", iconTint.r, iconTint.g, iconTint.b )
            else
                local textColor = DefaultColor.RowColors.UNAVAILABLE_TEXT
                LabelSetTextColor(targetRowWindow.."Name", textColor.r, textColor.g, textColor.b)
                LabelSetTextColor(targetRowWindow.."Type", textColor.r, textColor.g, textColor.b)

                local iconTint  = DefaultColor.RowColors.UNAVAILABLE
                WindowSetTintColor( targetRowWindow.."Circle", iconTint.r, iconTint.g, iconTint.b )
                WindowSetTintColor( targetRowWindow.."Square", iconTint.r, iconTint.g, iconTint.b )
            end

        end
    end

end

function EA_Window_InteractionCoreTraining.UpdateListButtonStates()
    -- sort button arrows
    for index, data in pairs(EA_Window_InteractionCoreTraining.sortButtonData)
    do
        local buttonName = "EA_Window_InteractionCoreTrainingSortButton"..index
        
        if (data.active == true)
        then
            WindowSetShowing(buttonName.."DownArrow", (data.direction == EA_Window_InteractionCoreTraining.SORT_ASCENDING) )
            WindowSetShowing(buttonName.."UpArrow",   (data.direction == EA_Window_InteractionCoreTraining.SORT_DESCENDING))
        else
            WindowSetShowing(buttonName.."DownArrow", false)
            WindowSetShowing(buttonName.."UpArrow",   false)
        end
    end
    
    -- selection marquee
    if (EA_Window_InteractionCoreTrainingList.PopulatorIndices ~= nil)
    then
        for row, dataIndex in ipairs(EA_Window_InteractionCoreTrainingList.PopulatorIndices)
        do
            local rowWindow = "EA_Window_InteractionCoreTrainingListRow"..row
            -- Highlight the selected row, unhighlight the rest
            -- DEBUG(L"  processing row "..row..L" = data entry #"..data)
            local rowIsSelected = EA_Window_InteractionCoreTraining.selectedAdvances[dataIndex]
            
            if (rowIsSelected)
            then
                ButtonSetPressedFlag(rowWindow,  true)
                ButtonSetStayDownFlag(rowWindow, true)
            else
                ButtonSetPressedFlag(rowWindow,  false)
                ButtonSetStayDownFlag(rowWindow, false)
            end
            
            -- Disable windows that cannot be purchased.
            ButtonSetDisabledFlag(rowWindow, not InteractionUtils.AvailabilityFilter( EA_Window_InteractionCoreTraining.advanceData[dataIndex], EA_Window_InteractionCoreTraining.advanceData ) )
        end
    end

    -- If the selected advance is not available or not applicable, don't enable the purchase button
    local enablePurchaseButton = EA_Window_InteractionCoreTraining.SimulatePurchase()
    ButtonSetDisabledFlag("EA_Window_InteractionCoreTrainingPurchaseButton", not enablePurchaseButton)

end

function EA_Window_InteractionCoreTraining.ShowIconType(row, advanceData)

    -- show circleimages for morale, square for anything else
    local isMoralePackage = (advanceData ~= nil) and
                            (advanceData.abilityInfo ~= nil) and
                            (advanceData.abilityInfo.moraleLevel > 0)

    WindowSetShowing("EA_Window_InteractionCoreTrainingListRow"..row.."Circle", isMoralePackage == true )
    WindowSetShowing("EA_Window_InteractionCoreTrainingListRow"..row.."Square", isMoralePackage == false)
    
    -- Disable frames for tactics
    local isTacticPackage = (advanceData ~= nil) and
                            (advanceData.abilityInfo ~= nil) and
                            (advanceData.abilityInfo.numTacticSlots > 0)
    WindowSetShowing("EA_Window_InteractionCoreTrainingListRow"..row.."SquareFrame", isTacticPackage == false)

end

----------------------------------------------------------------
-- Advance purchase
----------------------------------------------------------------
function EA_Window_InteractionCoreTraining.PurchaseAdvance()
    if (ButtonGetDisabledFlag("EA_Window_InteractionCoreTrainingPurchaseButton") == false)
    then
        for dataIndex, isSelected in pairs(EA_Window_InteractionCoreTraining.selectedAdvances)
        do
            if (isSelected)
            then
                local packageID    = EA_Window_InteractionCoreTraining.advanceData[dataIndex].packageId
                local tier         = EA_Window_InteractionCoreTraining.advanceData[dataIndex].tier
                local category     = EA_Window_InteractionCoreTraining.advanceData[dataIndex].category
                BuyCareerPackage( tier, category, packageID )
            end
        end

        -- Clear the shopping lists.
        EA_Window_InteractionCoreTraining.selectedAdvances = {}
        EA_Window_InteractionCoreTraining.selectedCosts    = 0

        -- (assume the purchase worked?)
        PlayInteractSound("trainer_accept")
    end
end

function EA_Window_InteractionCoreTraining.SelectAdvance()
    -- Record the list item that was selected / deselect other buttons
    local selectedRow = WindowGetId(SystemData.MouseOverWindow.name)
    
    local selectedDataIndex = ListBoxGetDataIndex("EA_Window_InteractionCoreTrainingList", selectedRow)
    local advanceData = EA_Window_InteractionCoreTraining.advanceData[selectedDataIndex]
    
    if (InteractionUtils.AvailabilityFilter( advanceData, EA_Window_InteractionCoreTraining.advanceData ))
    then
        if (EA_Window_InteractionCoreTraining.selectedAdvances[selectedDataIndex])
        then
            EA_Window_InteractionCoreTraining.selectedAdvances[selectedDataIndex] = false
            EA_Window_InteractionCoreTraining.selectedCosts = EA_Window_InteractionCoreTraining.selectedCosts - advanceData.cashCost
        else
            EA_Window_InteractionCoreTraining.selectedAdvances[selectedDataIndex] = true
            EA_Window_InteractionCoreTraining.selectedCosts = EA_Window_InteractionCoreTraining.selectedCosts + advanceData.cashCost
        end
        
        -- DEBUG(L"EA_Window_InteractionCoreTraining.SelectAdvance() selecting entry "..selectedDataIndex)
        EA_Window_InteractionCoreTraining.UpdateListButtonStates()
        EA_Window_InteractionCoreTraining.SetListRowNameTints()
    end
    
    -- else do nothing, we can't purchase this item
end

function EA_Window_InteractionCoreTraining.MouseOverAdvance()
    local advanceIndex = WindowGetId(SystemData.MouseOverWindow.name)

    if (advanceIndex ~= 0)
    then
        local dataIndex = ListBoxGetDataIndex("EA_Window_InteractionCoreTrainingList", advanceIndex)
        
        if (EA_Window_InteractionCoreTraining.advanceData == nil)
        then
            return
        elseif (dataIndex ~= 0)
        then
            local advanceData = EA_Window_InteractionCoreTraining.advanceData[dataIndex]
            local abilityData = advanceData.abilityInfo

            if (abilityData ~= nil)
            then            
                -- Move package limit to ability level
                abilityData["minimumRank"] = EA_Window_InteractionCoreTraining.advanceData[dataIndex].minimumRank
                
                -- DUMP_TABLE(abilityData)
                Tooltips.CreateAbilityTooltip( abilityData, SystemData.ActiveWindow.name, EA_Window_InteractionCoreTraining.ANCHOR_CURSOR )
            else
                -- This isn't an ability so look up the relevent package tooltip.
                Tooltips.CreateTextOnlyTooltip(SystemData.ActiveWindow.name)

                Tooltips.SetTooltipText( 1, 1, advanceData.advanceName )
                Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
                Tooltips.SetTooltipText( 2, 1, GetStringFromTable( "PackageDescriptions", advanceData.advanceID ) )
                Tooltips.Finalize()

                Tooltips.AnchorTooltip( EA_Window_InteractionCoreTraining.ANCHOR_CURSOR )
            end
        else

        end
    end

end

-- This function simulates what we think the server will do if we were to hit the 'buy all these packages' button
--   at the present.
function EA_Window_InteractionCoreTraining.SimulatePurchase()

    local isAnySelected = false
    local totalCost     = 0
    
    for dataIndex, isSelected in pairs(EA_Window_InteractionCoreTraining.selectedAdvances)
    do
        isAnySelected = isAnySelected or isSelected
        
        local advanceData = EA_Window_InteractionCoreTraining.advanceData[dataIndex]
        totalCost = totalCost + advanceData.cashCost
    end
    
    local sufficientCash = totalCost <= Player.GetMoney()

    return isAnySelected and sufficientCash
end

----------------------------------------------------------------
-- Sorting
----------------------------------------------------------------
function EA_Window_InteractionCoreTraining.ChangeSorting()
    -- Update the sort buttons
    local buttonIndex = WindowGetId( SystemData.ActiveWindow.name )
    
    for index, data in pairs(EA_Window_InteractionCoreTraining.sortButtonData)
    do
        if (index == buttonIndex)
        then
            if (data.active == true)
            then
                data.direction = not data.direction
            else
                data.active = true
                EA_Window_InteractionCoreTraining.currentSort = index
            end
        else
            data.active = false
        end
    end
    
    EA_Window_InteractionCoreTraining.selectedAdvances = {}
    EA_Window_InteractionCoreTraining.RefreshList()
    EA_Window_InteractionCoreTraining.UpdateListButtonStates()
end

function EA_Window_InteractionCoreTraining.OnMouseOverSortButton()
end

function EA_Window_InteractionCoreTraining.SetSortFunction()
    for index, data in pairs(EA_Window_InteractionCoreTraining.sortButtonData)
    do
        if (data.active == true)
        then
            EA_Window_InteractionCoreTraining.currentSort = index
        end
    end
end

function EA_Window_InteractionCoreTraining.FlexibleSort(a, b)

    for index, data in pairs(EA_Window_InteractionCoreTraining.sortButtonData)
    do
        if (index == EA_Window_InteractionCoreTraining.currentSort)
        then
            if (data.active == true)
            then
                if (index == 1)
                then
                    return EA_Window_InteractionCoreTraining.TypeSort(a, b)
                elseif (index == 2)
                then
                    return EA_Window_InteractionCoreTraining.RankSort(a, b)
                elseif (index == 3)
                then
                    return EA_Window_InteractionCoreTraining.PathSort(a, b)
                end
                
                break
            end
        end
    end
    
    return false

end

function EA_Window_InteractionCoreTraining.TypeSort(a, b)
    if (a == nil) or (a.abilityInfo == nil)
    then
        return false
    end
    
    if (b == nil) or (b.abilityInfo == nil)
    then
        return true
    end

    if (InteractionUtils.IsAction(a) and InteractionUtils.IsAction(b)) or
       (InteractionUtils.IsMorale(a) and InteractionUtils.IsMorale(b)) or
       (InteractionUtils.IsTactic(a) and InteractionUtils.IsTactic(b))
    then
        return a.minimumRank < b.minimumRank
    elseif (EA_Window_InteractionCoreTraining.sortButtonData[1].direction == EA_Window_InteractionCoreTraining.SORT_ASCENDING)
    then
        local actionPrecedence = InteractionUtils.IsAction(a) and not InteractionUtils.IsAction(b)
        local moralePrecedence = InteractionUtils.IsMorale(a) and not (InteractionUtils.IsAction(b) or InteractionUtils.IsMorale(b))
        return actionPrecedence or moralePrecedence
    else
        local tacticPrecedence = InteractionUtils.IsTactic(a) and not InteractionUtils.IsTactic(b)
        local moralePrecedence = InteractionUtils.IsMorale(a) and not (InteractionUtils.IsTactic(b) or InteractionUtils.IsMorale(b))
        return tacticPrecedence or moralePrecedence
    end
        
end

function EA_Window_InteractionCoreTraining.RankSort(a, b)
    if (a == nil)
    then
        return false
    end
    
    if (b == nil)
    then
        return true
    end
    
    if (EA_Window_InteractionCoreTraining.sortButtonData[2].direction == EA_Window_InteractionCoreTraining.SORT_ASCENDING)
    then
        return a.minimumRank < b.minimumRank
    else
        return a.minimumRank > b.minimumRank
    end
end

function EA_Window_InteractionCoreTraining.PathSort(a, b)
    if (a == nil) or (a.abilityInfo == nil)
    then
        return false
    end
    
    if (b == nil) or (b.abilityInfo == nil)
    then
        return true
    end
    
    if (a.abilityInfo.specialization == b.abilityInfo.specialization)
    then
        return a.minimumRank < b.minimumRank
    elseif (EA_Window_InteractionCoreTraining.sortButtonData[3].direction == EA_Window_InteractionCoreTraining.SORT_ASCENDING)
    then
        return a.abilityInfo.specialization < b.abilityInfo.specialization
    else
        return a.abilityInfo.specialization > b.abilityInfo.specialization
    end
end

----------------------------------------------------------------
-- Filtering
----------------------------------------------------------------
function EA_Window_InteractionCoreTraining.AvailabilityIfSetFilter(advanceData)

    local targetButton = "EA_Window_InteractionCoreTrainingAvailabilityFilterButton"
    local useFilter    = ( ButtonGetPressedFlag( targetButton ) )

    if (useFilter == false) then
        -- DEBUG(L"  allowing "..advanceData.abilityInfo.name..L" since it is disabled")
        return true
    end

    return InteractionUtils.AvailabilityFilter(advanceData, EA_Window_InteractionCoreTraining.advanceData)
           
end
