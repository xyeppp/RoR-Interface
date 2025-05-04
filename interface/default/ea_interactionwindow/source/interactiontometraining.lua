----------------------------------------------------------------
-- Local variables
----------------------------------------------------------------
EA_Window_InteractionTomeTraining =
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
        availabilityFilter = false,
    }
}

EA_Window_InteractionTomeTraining.sortButtonData[1] = { label = StringTables.Training.LABEL_SORT_TACTIC, direction = EA_Window_InteractionTomeTraining.SORT_ASCENDING, active = false, }

----------------------------------------------------------------
-- Standard Window Functions
----------------------------------------------------------------
function EA_Window_InteractionTomeTraining.Initialize()

    EA_Window_InteractionTomeTraining.InitializeLabels()
    EA_Window_InteractionTomeTraining.SetListRowTints()
    EA_Window_InteractionTomeTraining.SetListRowNameTints()

    -- register event handlers
    WindowRegisterEventHandler("EA_Window_InteractionTomeTraining", SystemData.Events.PLAYER_CAREER_CATEGORY_UPDATED,  "EA_Window_InteractionTomeTraining.Refresh")
    WindowRegisterEventHandler("EA_Window_InteractionTomeTraining", SystemData.Events.PLAYER_ABILITIES_LIST_UPDATED,   "EA_Window_InteractionTomeTraining.Refresh" )
    WindowRegisterEventHandler("EA_Window_InteractionTomeTraining", SystemData.Events.PLAYER_SINGLE_ABILITY_UPDATED,   "EA_Window_InteractionTomeTraining.Refresh" )
    
    EA_Window_InteractionTomeTraining.selectedAdvances = {}
    EA_Window_InteractionTomeTraining.selectedCosts    = 0
    
    -- No Abilities Text
    LabelSetText( "EA_Window_InteractionTomeTrainingNoAbiltitiesText", GetString( StringTables.Default.TEXT_TRAINER_NO_ABILITITES ) )
end

function EA_Window_InteractionTomeTraining.Shutdown()
end

function EA_Window_InteractionTomeTraining.OnHidden()
    EA_Window_InteractionTomeTraining.selectedAdvances = {}
    WindowUtils.RemoveFromOpenList("EA_Window_InteractionTomeTraining")
end

function EA_Window_InteractionTomeTraining.OnShown()
    WindowUtils.OnShown(EA_Window_InteractionTomeTraining.Hide, WindowUtils.Cascade.MODE_AUTOMATIC)
end

function EA_Window_InteractionTomeTraining.ToggleContextMenu()
end

function EA_Window_InteractionTomeTraining.Show()
    WindowSetShowing( "EA_Window_InteractionTomeTraining", true )
    EA_Window_InteractionTomeTraining.LoadAdvances()
    EA_Window_InteractionTomeTraining.RefreshList()
    EA_Window_InteractionTomeTraining.selectedAdvances = {}
end

function EA_Window_InteractionTomeTraining.Hide()
    WindowSetShowing( "EA_Window_InteractionTomeTraining", false )
end

function EA_Window_InteractionTomeTraining.Refresh()
    EA_Window_InteractionTomeTraining.LoadAdvances()
    EA_Window_InteractionTomeTraining.RefreshList()
end

function EA_Window_InteractionTomeTraining.InitializeAvailabilityFilter()
    EA_LabelCheckButton.Initialize( EA_Window_InteractionTomeTraining.Settings.availabilityFilter )
end

function EA_Window_InteractionTomeTraining.ToggleAvailabilityFilter()
    EA_LabelCheckButton.Toggle()
    EA_Window_InteractionTomeTraining.Settings.availabilityFilter = EA_LabelCheckButton.IsChecked()
    
    EA_Window_InteractionTomeTraining.RefreshList()
end

function EA_Window_InteractionTomeTraining.InitializeLabels()
    LabelSetText("EA_Window_InteractionTomeTrainingTitleBarText", GetStringFromTable( "InteractionStoreStrings", StringTables.InteractionStore.STORE_TITLE ) )
    LabelSetText("EA_Window_InteractionTomeTrainingHint",         GetStringFromTable("TrainingStrings", StringTables.Training.HINT_SELECT_TO_PURCHASE_TACTIC) )

    ButtonSetText( "EA_Window_InteractionTomeTrainingSortButton1", GetStringFromTable("TrainingStrings", EA_Window_InteractionTomeTraining.sortButtonData[1].label ))

    LabelSetText( "EA_Window_InteractionTomeTrainingAvailabilityFilterLabel",   GetStringFromTable("TrainingStrings", StringTables.Training.LABEL_UNAVAILABLE_TACTICS_FILTER_BUTTON) )
    
    ButtonSetText( "EA_Window_InteractionTomeTrainingPurchaseButton",     GetStringFromTable("TrainingStrings", StringTables.Training.LABEL_PURCHASE_TRAINING ) )
    ButtonSetText( "EA_Window_InteractionTomeTrainingCancelButton",       GetStringFromTable("TrainingStrings", StringTables.Training.LABEL_CANCEL_TRAINING ) )

end

----------------------------------------------------------------
-- List Population
----------------------------------------------------------------
function EA_Window_InteractionTomeTraining.LoadAdvances()
    EA_Window_InteractionTomeTraining.advanceData = GameData.Player.GetAdvanceData()
end

function EA_Window_InteractionTomeTraining.RefreshList()

    -- DEBUG(L"EA_Window_InteractionTomeTraining.RefreshList()")

    -- set up the display ordering and filter settings
    local displayOrder = {}
    EA_Window_InteractionTomeTraining.SetSortFunction()
    
    if (EA_Window_InteractionTomeTraining.advanceData == nil)
    then
        -- this can occur during the initial load, in which case ignore it
        return
    end
    
    if (WindowGetShowing("EA_Window_InteractionTomeTraining") == false)
    then
        -- Why bother if nothing's being displayed anyway?
        return
    end
    
    table.sort(EA_Window_InteractionTomeTraining.advanceData, EA_Window_InteractionTomeTraining.FlexibleSort)
    
    for index, data in pairs(EA_Window_InteractionTomeTraining.advanceData)
    do
        local advanceData = EA_Window_InteractionTomeTraining.advanceData[index]
        
        local showEntry = InteractionUtils.IsTomeAdvance(advanceData) and
                          InteractionUtils.IsAbility(advanceData) and
                          EA_Window_InteractionTomeTraining.AvailabilityIfSetFilter(advanceData) and
                          not InteractionUtils.HasAbilityFilter(advanceData) and
                          not InteractionUtils.HasPurchasedPackageToMaximum(advanceData)
        
        -- normal packages list
        if (showEntry)
        then
            table.insert(displayOrder, index)
        end
        
    end

    ListBoxSetDisplayOrder("EA_Window_InteractionTomeTrainingList", displayOrder)
       
    -- If there are no items in the list, show the 'none avail' text.
    WindowSetShowing( "EA_Window_InteractionTomeTrainingNoAbiltitiesText",  #displayOrder == 0 )    
    
end

function EA_Window_InteractionTomeTraining.Populate()
    if (nil == EA_Window_InteractionTomeTraining.advanceData)
    then
        -- DEBUG(L"  no advance data found!")
    end
    
    -- Post-process any conditional formatting
    for row, data in ipairs(EA_Window_InteractionTomeTrainingList.PopulatorIndices)
    do
        local advanceData = EA_Window_InteractionTomeTraining.advanceData[data]

        local rowFrame    = "EA_Window_InteractionTomeTrainingListRow"..row

        EA_Window_InteractionTomeTraining.PopulateName(rowFrame, advanceData)
        EA_Window_InteractionTomeTraining.PopulateIcon(rowFrame, advanceData)

        -- Process the type information
        EA_Window_InteractionTomeTraining.PopulateType(rowFrame, advanceData)

        EA_Window_InteractionTomeTraining.ShowIconType(row, advanceData)

        local dependencyText = EA_Window_InteractionTomeTraining.GetDependencyText(advanceData)
        if nil ~= dependencyText
        then
            LabelSetText(rowFrame.."Req", dependencyText)
        else
            LabelSetText(rowFrame.."Req", L"")
        end
    end

    EA_Window_InteractionTomeTraining.SetListRowTints()
    EA_Window_InteractionTomeTraining.SetListRowNameTints()
    EA_Window_InteractionTomeTraining.UpdateListButtonStates()
end

function EA_Window_InteractionTomeTraining.PopulateName(rowFrame, advanceData)
    local labelFrame = rowFrame.."Name"
    
    if (advanceData.abilityInfo == nil)
    then
        LabelSetText(labelFrame, advanceData.advanceName)
    else
        LabelSetText(labelFrame, advanceData.abilityInfo.name)
    end
end

function EA_Window_InteractionTomeTraining.PopulateIcon(rowFrame, advanceData)
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
        
function EA_Window_InteractionTomeTraining.PopulateType(rowFrame, advanceData)

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

function EA_Window_InteractionTomeTraining.SetListRowTints()
    for row = 1, EA_Window_InteractionTomeTrainingList.numVisibleRows
    do
        -- Show the background for every other button   
        local color = GameDefs.RowColorInvalid

        local advanceData = nil

        if ( EA_Window_InteractionTomeTraining.advanceData ~= nil )
        then
            advanceData = EA_Window_InteractionTomeTraining.advanceData[ ListBoxGetDataIndex("EA_Window_InteractionTomeTrainingList", row) ]
        end

        local row_mod = math.mod(row, 2)
        local color = DataUtils.GetAlternatingRowColor( row_mod )
        local targetRowWindow = "EA_Window_InteractionTomeTrainingListRow"..row
        
        if (advanceData ~= nil)
        then
            WindowSetTintColor(targetRowWindow.."RowBackground", color.r, color.g, color.b )
            WindowSetAlpha(targetRowWindow.."RowBackground", color.a)
        end
    end
end

function EA_Window_InteractionTomeTraining.SetListRowNameTints()
    for row = 1, EA_Window_InteractionTomeTrainingList.numVisibleRows
    do
        -- Show the background for every other button   
        local color = GameDefs.RowColorInvalid
        
        local advanceData = nil
        
        if ( EA_Window_InteractionTomeTraining.advanceData ~= nil )
        then
            advanceData = EA_Window_InteractionTomeTraining.advanceData[ ListBoxGetDataIndex("EA_Window_InteractionTomeTrainingList", row) ]
        end

        if (advanceData ~= nil)
        then
        
            local targetRowWindow = "EA_Window_InteractionTomeTrainingListRow"..row

            if (InteractionUtils.AvailabilityFilter(advanceData, EA_Window_InteractionTomeTraining.advanceData)) and
                ( EA_Window_InteractionTomeTraining.HasTomeUnlock(advanceData))
            then
                local textColor = DefaultColor.YELLOW
                LabelSetTextColor(targetRowWindow.."Name", textColor.r, textColor.g, textColor.b)
                
                local iconTint  = DefaultColor.RowColors.AVAILABLE
                local dataIndex = ListBoxGetDataIndex("EA_Window_InteractionTomeTrainingList", row)
                if (EA_Window_InteractionTomeTraining.selectedAdvances[dataIndex] == true)
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

function EA_Window_InteractionTomeTraining.UpdateListButtonStates()
    -- sort button arrows
    for index, data in pairs(EA_Window_InteractionTomeTraining.sortButtonData)
    do
        local buttonName = "EA_Window_InteractionTomeTrainingSortButton"..index
        
        if (data.active == true)
        then
            WindowSetShowing(buttonName.."DownArrow", (data.direction == EA_Window_InteractionTomeTraining.SORT_ASCENDING) )
            WindowSetShowing(buttonName.."UpArrow",   (data.direction == EA_Window_InteractionTomeTraining.SORT_DESCENDING))
        else
            WindowSetShowing(buttonName.."DownArrow", false)
            WindowSetShowing(buttonName.."UpArrow",   false)
        end
    end
    
    -- selection marquee
    if (EA_Window_InteractionTomeTrainingList.PopulatorIndices ~= nil)
    then
        for row, dataIndex in ipairs(EA_Window_InteractionTomeTrainingList.PopulatorIndices)
        do
            local rowWindow = "EA_Window_InteractionTomeTrainingListRow"..row
            -- Highlight the selected row, unhighlight the rest
            -- DEBUG(L"  processing row "..row..L" = data entry #"..data)
            local rowIsSelected = EA_Window_InteractionTomeTraining.selectedAdvances[dataIndex]
            
            if (rowIsSelected)
            then
                ButtonSetPressedFlag(rowWindow,  true)
                ButtonSetStayDownFlag(rowWindow, true)
            else
                ButtonSetPressedFlag(rowWindow,  false)
                ButtonSetStayDownFlag(rowWindow, false)
            end
            
            -- Disable windows that cannot be purchased.
            local advanceIsAvailable = InteractionUtils.AvailabilityFilter( EA_Window_InteractionTomeTraining.advanceData[dataIndex], EA_Window_InteractionTomeTraining.advanceData ) and
                            EA_Window_InteractionTomeTraining.HasTomeUnlock(EA_Window_InteractionTomeTraining.advanceData[dataIndex])
            ButtonSetDisabledFlag(rowWindow, not advanceIsAvailable )
        end
    end

    -- If the selected advance is not available or not applicable, don't enable the purchase button
    local enablePurchaseButton = EA_Window_InteractionTomeTraining.SimulatePurchase()
    ButtonSetDisabledFlag("EA_Window_InteractionTomeTrainingPurchaseButton", not enablePurchaseButton)

end

function EA_Window_InteractionTomeTraining.ShowIconType(row, advanceData)

    -- show circleimages for morale, square for anything else
    local isMoralePackage = (advanceData ~= nil) and
                            (advanceData.abilityInfo ~= nil) and
                            (advanceData.abilityInfo.moraleLevel > 0)

    WindowSetShowing("EA_Window_InteractionTomeTrainingListRow"..row.."Circle", isMoralePackage == true )
    WindowSetShowing("EA_Window_InteractionTomeTrainingListRow"..row.."Square", isMoralePackage == false)
    
    -- Disable frames for tactics
    local isTacticPackage = (advanceData ~= nil) and
                            (advanceData.abilityInfo ~= nil) and
                            (advanceData.abilityInfo.numTacticSlots > 0)
    WindowSetShowing("EA_Window_InteractionTomeTrainingListRow"..row.."SquareFrame", isTacticPackage == false)

end

----------------------------------------------------------------
-- Advance purchase
----------------------------------------------------------------
function EA_Window_InteractionTomeTraining.PurchaseAdvance()
    if (ButtonGetDisabledFlag("EA_Window_InteractionTomeTrainingPurchaseButton") == false)
    then
        for dataIndex, isSelected in pairs(EA_Window_InteractionTomeTraining.selectedAdvances)
        do
            if (isSelected)
            then
                local packageID    = EA_Window_InteractionTomeTraining.advanceData[dataIndex].packageId
                local tier         = EA_Window_InteractionTomeTraining.advanceData[dataIndex].tier
                local category     = EA_Window_InteractionTomeTraining.advanceData[dataIndex].category
                BuyCareerPackage( tier, category, packageID )
            end
        end

        -- (assume the purchase worked?)
        PlayInteractSound("trainer_accept")
    end
end

function EA_Window_InteractionTomeTraining.SelectAdvance()
    -- Record the list item that was selected / deselect other buttons
    local selectedRow = WindowGetId(SystemData.MouseOverWindow.name)
    
    local selectedDataIndex = ListBoxGetDataIndex("EA_Window_InteractionTomeTrainingList", selectedRow)
    local advanceData = EA_Window_InteractionTomeTraining.advanceData[selectedDataIndex]
    
    if (InteractionUtils.AvailabilityFilter( advanceData, EA_Window_InteractionTomeTraining.advanceData )) and
        (EA_Window_InteractionTomeTraining.HasTomeUnlock(advanceData))
    then
        if (EA_Window_InteractionTomeTraining.selectedAdvances[selectedDataIndex])
        then
            EA_Window_InteractionTomeTraining.selectedAdvances[selectedDataIndex] = false
            EA_Window_InteractionTomeTraining.selectedCosts = EA_Window_InteractionTomeTraining.selectedCosts - advanceData.cashCost
        else
            EA_Window_InteractionTomeTraining.selectedAdvances[selectedDataIndex] = true
            EA_Window_InteractionTomeTraining.selectedCosts = EA_Window_InteractionTomeTraining.selectedCosts + advanceData.cashCost
        end
        
        -- DEBUG(L"EA_Window_InteractionTomeTraining.SelectAdvance() selecting entry "..selectedDataIndex)
        EA_Window_InteractionTomeTraining.UpdateListButtonStates()
        EA_Window_InteractionTomeTraining.SetListRowNameTints()
    end
    
    -- else do nothing, we can't purchase this item
end

function EA_Window_InteractionTomeTraining.MouseOverAdvance()
    local advanceIndex = WindowGetId(SystemData.MouseOverWindow.name)

    if (advanceIndex ~= 0)
    then
        local dataIndex = ListBoxGetDataIndex("EA_Window_InteractionTomeTrainingList", advanceIndex)
        
        if (EA_Window_InteractionTomeTraining.advanceData == nil)
        then
            return
        elseif (dataIndex ~= 0)
        then
            local advanceData = EA_Window_InteractionTomeTraining.advanceData[dataIndex]
            local abilityData = advanceData.abilityInfo

            if (abilityData ~= nil)
            then            
                -- Move package limit to ability level
                abilityData["minimumRank"] = EA_Window_InteractionTomeTraining.advanceData[dataIndex].minimumRank

                -- DUMP_TABLE(abilityData)
                local dependencyText = EA_Window_InteractionTomeTraining.GetDependencyText(advanceData)

                Tooltips.CreateAbilityTooltip( abilityData, SystemData.ActiveWindow.name, EA_Window_InteractionTomeTraining.ANCHOR_CURSOR, dependencyText )
            else
                -- This isn't an ability so look up the relevent package tooltip.
                Tooltips.CreateTextOnlyTooltip(SystemData.ActiveWindow.name)

                Tooltips.SetTooltipText( 1, 1, advanceData.advanceName )
                Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
                Tooltips.SetTooltipText( 2, 1, GetStringFromTable( "PackageDescriptions", advanceData.advanceID ) )
                Tooltips.Finalize()

                Tooltips.AnchorTooltip( EA_Window_InteractionTomeTraining.ANCHOR_CURSOR )
            end
        else

        end
    end

end

-- This function simulates what we think the server will do if we were to hit the 'buy all these packages' button
--   at the present.
function EA_Window_InteractionTomeTraining.SimulatePurchase()

    local isAnySelected = false
    local totalCost     = 0
    
    for dataIndex, isSelected in pairs(EA_Window_InteractionTomeTraining.selectedAdvances)
    do
        isAnySelected = isAnySelected or isSelected
        
        local advanceData = EA_Window_InteractionTomeTraining.advanceData[dataIndex]
        totalCost = totalCost + advanceData.cashCost
    end
    
    local sufficientCash = totalCost <= Player.GetMoney()

    return isAnySelected and sufficientCash
end

----------------------------------------------------------------
-- Sorting
----------------------------------------------------------------
function EA_Window_InteractionTomeTraining.ChangeSorting()
    -- Update the sort buttons
    local buttonIndex = WindowGetId( SystemData.ActiveWindow.name )
    
    for index, data in pairs(EA_Window_InteractionTomeTraining.sortButtonData)
    do
        if (index == buttonIndex)
        then
            if (data.active == true)
            then
                data.direction = not data.direction
            else
                data.active = true
                EA_Window_InteractionTomeTraining.currentSort = index
            end
        else
            data.active = false
        end
    end
    
    EA_Window_InteractionTomeTraining.selectedAdvances = {}
    EA_Window_InteractionTomeTraining.RefreshList()
    EA_Window_InteractionTomeTraining.UpdateListButtonStates()
end

function EA_Window_InteractionTomeTraining.OnMouseOverSortButton()
end

function EA_Window_InteractionTomeTraining.SetSortFunction()
    for index, data in pairs(EA_Window_InteractionTomeTraining.sortButtonData)
    do
        if (data.active == true)
        then
            EA_Window_InteractionTomeTraining.currentSort = index
        end
    end
end

function EA_Window_InteractionTomeTraining.FlexibleSort(a, b)

    for index, data in pairs(EA_Window_InteractionTomeTraining.sortButtonData)
    do
        if (index == EA_Window_InteractionTomeTraining.currentSort)
        then
            if (data.active == true)
            then
                if (index == 1)
                then
                    return EA_Window_InteractionTomeTraining.TypeSort(a, b)
                elseif (index == 2)
                then
                    return EA_Window_InteractionTomeTraining.RankSort(a, b)
                elseif (index == 3)
                then
                    return EA_Window_InteractionTomeTraining.PathSort(a, b)
                end
                
                break
            end
        end
    end
    
    return false

end

function EA_Window_InteractionTomeTraining.TypeSort(a, b)
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
    elseif (EA_Window_InteractionTomeTraining.sortButtonData[1].direction == EA_Window_InteractionTomeTraining.SORT_ASCENDING)
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

function EA_Window_InteractionTomeTraining.RankSort(a, b)
    if (a == nil)
    then
        return false
    end
    
    if (b == nil)
    then
        return true
    end
    
    if (EA_Window_InteractionTomeTraining.sortButtonData[2].direction == EA_Window_InteractionTomeTraining.SORT_ASCENDING)
    then
        return a.minimumRank < b.minimumRank
    else
        return a.minimumRank > b.minimumRank
    end
end

function EA_Window_InteractionTomeTraining.PathSort(a, b)
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
    elseif (EA_Window_InteractionTomeTraining.sortButtonData[3].direction == EA_Window_InteractionTomeTraining.SORT_ASCENDING)
    then
        return a.abilityInfo.specialization < b.abilityInfo.specialization
    else
        return a.abilityInfo.specialization > b.abilityInfo.specialization
    end
end

----------------------------------------------------------------
-- Filtering
----------------------------------------------------------------
function EA_Window_InteractionTomeTraining.AvailabilityIfSetFilter(advanceData)

    local targetButton = "EA_Window_InteractionTomeTrainingAvailabilityFilterButton"
    local useFilter    = ( ButtonGetPressedFlag( targetButton ) )

    if (useFilter == false) then
        -- DEBUG(L"  allowing "..advanceData.abilityInfo.name..L" since it is disabled")
        return true
    end

    return InteractionUtils.AvailabilityFilter(advanceData, EA_Window_InteractionTomeTraining.advanceData) and EA_Window_InteractionTomeTraining.HasTomeUnlock(advanceData)
           
end

function EA_Window_InteractionTomeTraining.GetDependencyText(advanceData)
    local dependencyText = nil

    for dependency, amount in pairs(advanceData.dependencies)
    do
        local dependentData = InteractionUtils.GetDependentPackage( advanceData, dependency, EA_Window_InteractionTomeTraining.advanceData )

        dependencyText = GetStringFormatFromTable("TrainingStrings", StringTables.Training.LABEL_REQUIRES_DEPENDENT_PACKAGE, { dependentData.abilityInfo.name, towstring(amount) } )

        -- Only look at the first dependency
        break
    end

    local tacticLineName, progress, rewardData = TomeGetTacticCounter( advanceData.requiredActionCounterID )
    -- if we don't have a dependencyText line and we are short on the number of items we need
    if (dependencyText == nil) and (progress < advanceData.requiredActionCounterCount)
    then
        dependencyText = GetStringFormatFromTable("TrainingStrings", StringTables.Training.LABEL_REQUIRES_DEPENDENT_COUNT_X_Y_Z, { tacticLineName, towstring(progress), towstring(advanceData.requiredActionCounterCount) } )
    end

    return dependencyText
end

function EA_Window_InteractionTomeTraining.HasTomeUnlock(advanceData)
    local tacticLineName, progress, rewardData = TomeGetTacticCounter( advanceData.requiredActionCounterID )
    local tacticData = TomeGetTacticCounterRewardData( advanceData.packageId )

    if tacticData ~= nil
    then
        -- check to see if the tactic is unlocked and if we have enough progress for it to be available
        return tacticData.unlocked and (progress >= advanceData.requiredActionCounterCount)
    -- if the tactic data wasn't found we'll assume it's true so that we don't hide a tactic by mistake
    else
        return true
    end
end