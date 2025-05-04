----------------------------------------------------------------
-- Local variables
----------------------------------------------------------------
EA_Window_InteractionRenownTraining =
{
    advanceData      = {},
    selectedAdvances = {},
    selectedCosts    = 0,
    
    SORT_ASCENDING   = true,
    SORT_DESCENDING  = false,
    currentSort      = 2,
    sortButtonData   = {},
    pointsSpent      = 0,
    
    ANCHOR_CURSOR    = { Point = "topleft", RelativeTo = "CursorWindow", RelativePoint = "bottomleft", XOffset = 30, YOffset = -20 },
    
                  
    Settings = 
    {
        availabilityFilter = true,
    }
}

EA_Window_InteractionRenownTraining.sortButtonData[1] = { label = StringTables.Training.LABEL_SORT_ABILITY_NAME, direction = EA_Window_InteractionRenownTraining.SORT_ASCENDING, active = true, }

----------------------------------------------------------------
-- Standard Window Functions
----------------------------------------------------------------
function EA_Window_InteractionRenownTraining.Initialize()

    EA_Window_InteractionRenownTraining.InitializeLabels()
    EA_Window_InteractionRenownTraining.SetListRowTints()
    EA_Window_InteractionRenownTraining.SetListRowNameTints()

    -- register event handlers
    WindowRegisterEventHandler("EA_Window_InteractionRenownTraining", SystemData.Events.PLAYER_CAREER_CATEGORY_UPDATED,  "EA_Window_InteractionRenownTraining.FullRefresh")
    WindowRegisterEventHandler("EA_Window_InteractionRenownTraining", SystemData.Events.PLAYER_ABILITIES_LIST_UPDATED,   "EA_Window_InteractionRenownTraining.Refresh" )
    WindowRegisterEventHandler("EA_Window_InteractionRenownTraining", SystemData.Events.PLAYER_SINGLE_ABILITY_UPDATED,   "EA_Window_InteractionRenownTraining.Refresh" )
    WindowRegisterEventHandler("EA_Window_InteractionRenownTraining", SystemData.Events.PLAYER_MONEY_UPDATED,            "EA_Window_InteractionRenownTraining.UpdatePlayerResources" )    
    
    EA_Window_InteractionRenownTraining.selectedAdvances = {}
    EA_Window_InteractionRenownTraining.selectedCosts    = 0
    
    -- No Abilities Text
    LabelSetText( "EA_Window_InteractionRenownTrainingNoAbiltitiesText", GetString( StringTables.Default.TEXT_TRAINER_NO_ABILITITES ) )
end

function EA_Window_InteractionRenownTraining.Shutdown()
end

function EA_Window_InteractionRenownTraining.OnHidden()
    EA_Window_InteractionRenownTraining.selectedAdvances = {}
    WindowUtils.RemoveFromOpenList("EA_Window_InteractionRenownTraining")
end

function EA_Window_InteractionRenownTraining.OnShown()
    WindowUtils.OnShown(EA_Window_InteractionRenownTraining.Hide, WindowUtils.Cascade.MODE_AUTOMATIC)
end

function EA_Window_InteractionRenownTraining.ToggleContextMenu()
end

function EA_Window_InteractionRenownTraining.Show()
    WindowSetShowing( "EA_Window_InteractionRenownTraining", true )
    EA_Window_InteractionRenownTraining.LoadAdvances()
    EA_Window_InteractionRenownTraining.UpdatePlayerResources()
    EA_Window_InteractionRenownTraining.RefreshList()
    EA_Window_InteractionRenownTraining.selectedAdvances = {}
end

function EA_Window_InteractionRenownTraining.Hide()
    WindowSetShowing( "EA_Window_InteractionRenownTraining", false )
end

function EA_Window_InteractionRenownTraining.Refresh()
    EA_Window_InteractionRenownTraining.LoadAdvances()
    EA_Window_InteractionRenownTraining.UpdatePlayerResources()
    EA_Window_InteractionRenownTraining.RefreshList()
end

function EA_Window_InteractionRenownTraining.InitializeAvailabilityFilter()
    EA_LabelCheckButton.Initialize( EA_Window_InteractionRenownTraining.Settings.availabilityFilter )
end

function EA_Window_InteractionRenownTraining.ToggleAvailabilityFilter()
    EA_LabelCheckButton.Toggle()
    EA_Window_InteractionRenownTraining.Settings.availabilityFilter = EA_LabelCheckButton.IsChecked()
    
    EA_Window_InteractionRenownTraining.RefreshList()
end

function EA_Window_InteractionRenownTraining.InitializeLabels()

    EA_Window_InteractionRenownTraining.UpdatePlayerResources()
    
    LabelSetText("EA_Window_InteractionRenownTrainingTitleBarText", GetStringFromTable( "TrainingStrings", StringTables.Training.LABEL_RENOWN_TRAINING_TITLE ) )
    LabelSetText("EA_Window_InteractionRenownTrainingHint",         GetStringFromTable("TrainingStrings", StringTables.Training.HINT_SELECT_TO_PURCHASE_RENOWN) )
    ButtonSetText( "EA_Window_InteractionRenownTrainingSortButton1", GetStringFromTable("TrainingStrings", EA_Window_InteractionRenownTraining.sortButtonData[1].label ))
    LabelSetText( "EA_Window_InteractionRenownTrainingAvailabilityFilterLabel",   GetStringFromTable("TrainingStrings", StringTables.Training.LABEL_UNAVAILABLE_RENOWN_FILTER_BUTTON) )
    ButtonSetText( "EA_Window_InteractionRenownTrainingRespecializeButton", GetString( StringTables.Default.LABEL_PURCHASE_RESPECIALIZATION ) )
    ButtonSetText( "EA_Window_InteractionRenownTrainingPurchaseButton",     GetStringFromTable("TrainingStrings", StringTables.Training.LABEL_PURCHASE_TRAINING ) )
    ButtonSetText( "EA_Window_InteractionRenownTrainingCancelButton",       GetStringFromTable("TrainingStrings", StringTables.Training.LABEL_CANCEL_TRAINING ) )

end

----------------------------------------------------------------
-- Respecialize
----------------------------------------------------------------
function EA_Window_InteractionRenownTraining.Respecialize()
    local respecCost = GameData.Player.GetRenownRefundCost()
    local pointsSpent = EA_Window_InteractionRenownTraining.GetPointsAlreadyPurchased()
    
    if (pointsSpent == 0)
    then
        -- There are no points to refund. In this case this button acts as a simple Reset.
        EA_Window_InteractionRenownTraining.FullRefresh()
    elseif (respecCost > GameData.Player.money)
    then
        DialogManager.MakeOneButtonDialog( GetStringFormatFromTable("TrainingStrings", StringTables.Training.TEXT_RESPEC_NOT_ENOUGH_MONEY, { MoneyFrame.FormatMoneyString (respecCost) }),
                                           GetString( StringTables.Default.LABEL_OKAY ), nil )
    else
        DialogManager.MakeTwoButtonDialog( GetStringFormatFromTable("TrainingStrings", StringTables.Training.TEXT_RESPEC_CONFIRMATION, { MoneyFrame.FormatMoneyString (respecCost) }), 
                                           GetString(StringTables.Default.LABEL_YES), RefundRenownPoints, 
                                           GetString(StringTables.Default.LABEL_NO) )
    end
end

----------------------------------------------------------------
-- Money/resource/display initialization and updates
----------------------------------------------------------------
function EA_Window_InteractionRenownTraining.UpdatePlayerResources()
    local pointsRemaining = EA_Window_InteractionRenownTraining.GetPointsAvailable()
    local pointsSpent     = EA_Window_InteractionRenownTraining.GetPointsSpent()    
    local pointText       = GetStringFormatFromTable("TrainingStrings", StringTables.Training.LABEL_RENOWN_PURSE, { L""..pointsRemaining, L""..pointsSpent } )
    
    LabelSetText("EA_Window_InteractionRenownTrainingPurseLabel", pointText)  
    
    EA_Window_InteractionRenownTraining.RefreshList()  
end

function EA_Window_InteractionRenownTraining.FullRefresh()
    -- Clear the selected advances and then refresh
    EA_Window_InteractionRenownTraining.selectedAdvances = {}
    EA_Window_InteractionRenownTraining.pointsSpent      = 0
    EA_Window_InteractionRenownTraining.Refresh()
end

----------------------------------------------------------------
-- Utiltiy Functions
----------------------------------------------------------------
function EA_Window_InteractionRenownTraining.GetPointsAvailable()
    local pointsTotal     = GameData.Player.GetAdvancePointsAvailable()[GameData.CareerCategory.RENOWN_STATS_A]
    local pointsSpent     = EA_Window_InteractionRenownTraining.pointsSpent
    local pointsRemaining = pointsTotal - pointsSpent
    
    return pointsRemaining
end

function EA_Window_InteractionRenownTraining.GetPointsAlreadyPurchased()
    -- loop through and take the highest of any of category 9-15, since only the most recently updated will
    --   contain an accurate number
    local purchasedPoints   = GameData.Player.GetAdvancePointsSpent()
    local purchasedPointsMaximum = 0
    for category = GameData.CareerCategory.RENOWN_STATS_A, GameData.CareerCategory.RENOWN_REALM
    do
        purchasedPointsMaximum = math.max(purchasedPointsMaximum, purchasedPoints[category])
    end
    return purchasedPointsMaximum
end

function EA_Window_InteractionRenownTraining.GetPointsSpent()
    local purchasedPoints   = EA_Window_InteractionRenownTraining.GetPointsAlreadyPurchased()
    local speculativePoints = EA_Window_InteractionRenownTraining.pointsSpent
    local spentTotal        = purchasedPoints + speculativePoints
    
    return spentTotal
end

----------------------------------------------------------------
-- List Population
----------------------------------------------------------------
function EA_Window_InteractionRenownTraining.LoadAdvances()
    EA_Window_InteractionRenownTraining.advanceData = GameData.Player.GetAdvanceData()
end

function EA_Window_InteractionRenownTraining.RefreshList()

    --DEBUG(L"EA_Window_InteractionRenownTraining.RefreshList()")

    -- set up the display ordering and filter settings
    local displayOrder = {}
    EA_Window_InteractionRenownTraining.SetSortFunction()
    
    if (EA_Window_InteractionRenownTraining.advanceData == nil)
    then
        -- this can occur during the initial load, in which case ignore it
        return
    end
    
    if (WindowGetShowing("EA_Window_InteractionRenownTraining") == false)
    then
        -- Why bother if nothing's being displayed anyway?
        return
    end
    
    table.sort(EA_Window_InteractionRenownTraining.advanceData, EA_Window_InteractionRenownTraining.FlexibleSort)
    
    for index, data in pairs(EA_Window_InteractionRenownTraining.advanceData)
    do        
        local showEntry = InteractionUtils.IsRenownAdvance(data) and
                          EA_Window_InteractionRenownTraining.AvailabilityIfSetFilter(data) and
                          not InteractionUtils.HasAbilityFilter(data) and
                          not InteractionUtils.HasPurchasedPackageToMaximum(data)
                                  
        -- normal packages list
        if (showEntry)
        then
            table.insert(displayOrder, index)
        end
        
    end

    ListBoxSetDisplayOrder("EA_Window_InteractionRenownTrainingList", displayOrder)
       
    -- If there are no items in the list, show the 'none avail' text.
    WindowSetShowing( "EA_Window_InteractionRenownTrainingNoAbiltitiesText",  #displayOrder == 0 )    
    
end

function EA_Window_InteractionRenownTraining.Populate()
    if (nil == EA_Window_InteractionRenownTraining.advanceData)
    then
        DEBUG(L"  no advance data found!")
    end
    
    -- Post-process any conditional formatting
    for row, data in ipairs(EA_Window_InteractionRenownTrainingList.PopulatorIndices)
    do
        local advanceData = EA_Window_InteractionRenownTraining.advanceData[data]

        local rowFrame    = "EA_Window_InteractionRenownTrainingListRow"..row

        EA_Window_InteractionRenownTraining.PopulateName(rowFrame, advanceData)
        EA_Window_InteractionRenownTraining.PopulateIcon(rowFrame, advanceData)
        
        -- Process the visible money frames
        EA_Window_InteractionRenownTraining.PopulateCost(rowFrame, advanceData)

        -- Process the type information
        EA_Window_InteractionRenownTraining.PopulateType(rowFrame, advanceData)

        EA_Window_InteractionRenownTraining.ShowIconType(row, advanceData)

        local dependencyText = EA_Window_InteractionRenownTraining.GetDependencyText(advanceData)
        if nil ~= dependencyText
        then
            LabelSetText(rowFrame.."Req", dependencyText)
        else
            LabelSetText(rowFrame.."Req", L"")
        end
    end

    EA_Window_InteractionRenownTraining.SetListRowTints()
    EA_Window_InteractionRenownTraining.SetListRowNameTints()
    EA_Window_InteractionRenownTraining.UpdateListButtonStates()
end

function EA_Window_InteractionRenownTraining.PopulateName(rowFrame, advanceData)
    local labelFrame = rowFrame.."Name"
    
    if (advanceData.abilityInfo == nil)
    then
        LabelSetText(labelFrame, advanceData.advanceName)
    else
        LabelSetText(labelFrame, advanceData.abilityInfo.name)
    end
end

function EA_Window_InteractionRenownTraining.PopulateIcon(rowFrame, advanceData)
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

function EA_Window_InteractionRenownTraining.PopulateCost(rowFrame, advanceData)

    local moneyLabel = rowFrame.."PointCost"
    
    local priceString = GetStringFormatFromTable("TrainingStrings", StringTables.Training.TEXT_RENOWN_POINT_COST, { L""..advanceData.pointCost } )
    
    LabelSetText(moneyLabel, priceString)

end
        
function EA_Window_InteractionRenownTraining.PopulateType(rowFrame, advanceData)

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

function EA_Window_InteractionRenownTraining.SetListRowTints()
    for row = 1, EA_Window_InteractionRenownTrainingList.numVisibleRows
    do
        -- Show the background for every other button   
        local color = GameDefs.RowColorInvalid

        local advanceData = nil

        if ( EA_Window_InteractionRenownTraining.advanceData ~= nil )
        then
            advanceData = EA_Window_InteractionRenownTraining.advanceData[ ListBoxGetDataIndex("EA_Window_InteractionRenownTrainingList", row) ]
        end

        local row_mod = math.mod(row, 2)
        local color = DataUtils.GetAlternatingRowColor( row_mod )
        local targetRowWindow = "EA_Window_InteractionRenownTrainingListRow"..row
        
        if (advanceData ~= nil)
        then
            WindowSetTintColor(targetRowWindow.."RowBackground", color.r, color.g, color.b )
            WindowSetAlpha(targetRowWindow.."RowBackground", color.a)
        end
    end
end

function EA_Window_InteractionRenownTraining.SetListRowNameTints()
    for row = 1, EA_Window_InteractionRenownTrainingList.numVisibleRows
    do
        -- Show the background for every other button   
        local color = GameDefs.RowColorInvalid
        
        local advanceData = nil
        
        if ( EA_Window_InteractionRenownTraining.advanceData ~= nil )
        then
            advanceData = EA_Window_InteractionRenownTraining.advanceData[ ListBoxGetDataIndex("EA_Window_InteractionRenownTrainingList", row) ]
        end

        if (advanceData ~= nil)
        then
        
            local targetRowWindow = "EA_Window_InteractionRenownTrainingListRow"..row

            if (InteractionUtils.AvailabilityFilter(advanceData, EA_Window_InteractionRenownTraining.advanceData))
            then
                local textColor = DefaultColor.YELLOW
                LabelSetTextColor(targetRowWindow.."Name", textColor.r, textColor.g, textColor.b)
                
                local iconTint  = DefaultColor.RowColors.AVAILABLE
                local dataIndex = ListBoxGetDataIndex("EA_Window_InteractionRenownTrainingList", row)
                if (EA_Window_InteractionRenownTraining.selectedAdvances[dataIndex] == true)
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

function EA_Window_InteractionRenownTraining.UpdateListButtonStates()
    -- sort button arrows
    for index, data in pairs(EA_Window_InteractionRenownTraining.sortButtonData)
    do
        local buttonName = "EA_Window_InteractionRenownTrainingSortButton"..index
        
        if (data.active == true)
        then
            WindowSetShowing(buttonName.."DownArrow", (data.direction == EA_Window_InteractionRenownTraining.SORT_ASCENDING) )
            WindowSetShowing(buttonName.."UpArrow",   (data.direction == EA_Window_InteractionRenownTraining.SORT_DESCENDING))
        else
            WindowSetShowing(buttonName.."DownArrow", false)
            WindowSetShowing(buttonName.."UpArrow",   false)
        end
    end
    
    -- selection marquee
    if (EA_Window_InteractionRenownTrainingList.PopulatorIndices ~= nil)
    then
        for row, dataIndex in ipairs(EA_Window_InteractionRenownTrainingList.PopulatorIndices)
        do
            local rowWindow = "EA_Window_InteractionRenownTrainingListRow"..row
            -- Highlight the selected row, unhighlight the rest
            -- DEBUG(L"  processing row "..row..L" = data entry #"..data)
            local rowIsSelected = EA_Window_InteractionRenownTraining.selectedAdvances[dataIndex]
            
            if (rowIsSelected)
            then
                ButtonSetPressedFlag(rowWindow,  true)
                ButtonSetStayDownFlag(rowWindow, true)
            else
                ButtonSetPressedFlag(rowWindow,  false)
                ButtonSetStayDownFlag(rowWindow, false)
            end
            
            -- Disable windows that cannot be purchased.
            local advanceIsAvailable = InteractionUtils.AvailabilityFilter( EA_Window_InteractionRenownTraining.advanceData[dataIndex], EA_Window_InteractionRenownTraining.advanceData )
            ButtonSetDisabledFlag(rowWindow, not advanceIsAvailable )
        end
    end

    -- If the selected advance is not available or not applicable, don't enable the purchase button
    local enablePurchaseButton = EA_Window_InteractionRenownTraining.SimulatePurchase()
    ButtonSetDisabledFlag("EA_Window_InteractionRenownTrainingPurchaseButton", not enablePurchaseButton)

end

function EA_Window_InteractionRenownTraining.ShowIconType(row, advanceData)

    -- show circleimages for morale, square for anything else
    local isMoralePackage = (advanceData ~= nil) and
                            (advanceData.abilityInfo ~= nil) and
                            (advanceData.abilityInfo.moraleLevel > 0)

    WindowSetShowing("EA_Window_InteractionRenownTrainingListRow"..row.."Circle", isMoralePackage == true )
    WindowSetShowing("EA_Window_InteractionRenownTrainingListRow"..row.."Square", isMoralePackage == false)
    
    -- Disable frames for tactics
    local isTacticPackage = (advanceData ~= nil) and
                            (advanceData.abilityInfo ~= nil) and
                            (advanceData.abilityInfo.numTacticSlots > 0)
    WindowSetShowing("EA_Window_InteractionRenownTrainingListRow"..row.."SquareFrame", isTacticPackage == false)

end

----------------------------------------------------------------
-- Advance purchase
----------------------------------------------------------------
function EA_Window_InteractionRenownTraining.PurchaseAdvance()

    if (ButtonGetDisabledFlag("EA_Window_InteractionRenownTrainingPurchaseButton") == false)
    then
        for dataIndex, isSelected in pairs(EA_Window_InteractionRenownTraining.selectedAdvances)
        do
            if (isSelected)
            then
                local packageID    = EA_Window_InteractionRenownTraining.advanceData[dataIndex].packageId
                local tier         = EA_Window_InteractionRenownTraining.advanceData[dataIndex].tier
                local category     = EA_Window_InteractionRenownTraining.advanceData[dataIndex].category
                BuyCareerPackage( tier, category, packageID )
            end
        end
        
        -- (assume the purchase worked?)
        EA_Window_InteractionRenownTraining.selectedAdvances = {}

        PlayInteractSound("trainer_accept")
    end    
    
end

function EA_Window_InteractionRenownTraining.SelectAdvance()
    -- Record the list item that was selected / deselect other buttons
    local selectedRow = WindowGetId(SystemData.MouseOverWindow.name)
    
    local selectedDataIndex = ListBoxGetDataIndex("EA_Window_InteractionRenownTrainingList", selectedRow)
    local advanceData = EA_Window_InteractionRenownTraining.advanceData[selectedDataIndex]
    
    if (InteractionUtils.AvailabilityFilter( advanceData, EA_Window_InteractionRenownTraining.advanceData ))
    then
        if (EA_Window_InteractionRenownTraining.selectedAdvances[selectedDataIndex])
        then
            EA_Window_InteractionRenownTraining.selectedAdvances[selectedDataIndex] = false
            EA_Window_InteractionRenownTraining.selectedCosts = EA_Window_InteractionRenownTraining.selectedCosts - advanceData.cashCost
        else
            EA_Window_InteractionRenownTraining.selectedAdvances[selectedDataIndex] = true
            EA_Window_InteractionRenownTraining.selectedCosts = EA_Window_InteractionRenownTraining.selectedCosts + advanceData.cashCost
        end
        
        -- DEBUG(L"EA_Window_InteractionRenownTraining.SelectAdvance() selecting entry "..selectedDataIndex)
        EA_Window_InteractionRenownTraining.UpdateListButtonStates()
        EA_Window_InteractionRenownTraining.SetListRowNameTints()
    end
    
    -- else do nothing, we can't purchase this item
end

function EA_Window_InteractionRenownTraining.MouseOverAdvance()    
    local advanceIndex = WindowGetId(SystemData.MouseOverWindow.name)
    
    if (advanceIndex ~= 0)
    then
        local dataIndex = ListBoxGetDataIndex("EA_Window_InteractionRenownTrainingList", advanceIndex)
                
        if (EA_Window_InteractionRenownTraining.advanceData == nil)
        then
            return
        elseif (dataIndex ~= 0)
        then
            local advanceData = EA_Window_InteractionRenownTraining.advanceData[dataIndex]
            local abilityData = advanceData.abilityInfo
            
            local priceString = GetStringFormatFromTable("TrainingStrings", StringTables.Training.TEXT_RENOWN_POINT_COST, { L""..advanceData.pointCost } )

            if (abilityData ~= nil)
            then            
                -- Move package limit to ability level
                abilityData["minimumRank"] = EA_Window_InteractionRenownTraining.advanceData[dataIndex].minimumRank

                -- DUMP_TABLE(abilityData)
                local dependencyText = EA_Window_InteractionRenownTraining.GetDependencyText(advanceData)

                Tooltips.CreateAbilityTooltip( abilityData, SystemData.ActiveWindow.name, EA_Window_InteractionRenownTraining.ANCHOR_CURSOR, dependencyText )
            else
                -- This isn't an ability so look up the relevent package tooltip.
                Tooltips.CreateTextOnlyTooltip(SystemData.ActiveWindow.name)
                
                Tooltips.SetTooltipText( 1, 1, advanceData.advanceName )
                Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
                Tooltips.SetTooltipText( 2, 1, GetStringFromTable( "PackageDescriptions", advanceData.advanceID ) )
                Tooltips.SetTooltipText( 3, 1, priceString )
                Tooltips.Finalize()

                Tooltips.AnchorTooltip( EA_Window_InteractionRenownTraining.ANCHOR_CURSOR ) 
            end
        else

        end
    end

end

-- This function simulates what we think the server will do if we were to hit the 'buy all these packages' button
--   at the present.
function EA_Window_InteractionRenownTraining.SimulatePurchase()

    local isAnySelected = false
    local totalCost     = 0
    
    for dataIndex, isSelected in pairs(EA_Window_InteractionRenownTraining.selectedAdvances)
    do
        isAnySelected = isAnySelected or isSelected
        
        local advanceData = EA_Window_InteractionRenownTraining.advanceData[dataIndex]
        totalCost = totalCost + advanceData.cashCost
    end
    
    local sufficientCash = totalCost <= Player.GetMoney()

    return isAnySelected and sufficientCash
end

----------------------------------------------------------------
-- Sorting
----------------------------------------------------------------
function EA_Window_InteractionRenownTraining.ChangeSorting()
    -- Update the sort buttons
    local buttonIndex = WindowGetId( SystemData.ActiveWindow.name )
    
    for index, data in pairs(EA_Window_InteractionRenownTraining.sortButtonData)
    do
        if (index == buttonIndex)
        then
            if (data.active == true)
            then
                data.direction = not data.direction
            else
                data.active = true
                EA_Window_InteractionRenownTraining.currentSort = index
            end
        else
            data.active = false
        end
    end
    
    EA_Window_InteractionRenownTraining.selectedAdvances = {}
    EA_Window_InteractionRenownTraining.RefreshList()
    EA_Window_InteractionRenownTraining.UpdateListButtonStates()
end

function EA_Window_InteractionRenownTraining.OnMouseOverSortButton()
end

function EA_Window_InteractionRenownTraining.SetSortFunction()
    for index, data in pairs(EA_Window_InteractionRenownTraining.sortButtonData)
    do
        if (data.active == true)
        then
            EA_Window_InteractionRenownTraining.currentSort = index
        end
    end
end

function EA_Window_InteractionRenownTraining.FlexibleSort(a, b)

    for index, data in pairs(EA_Window_InteractionRenownTraining.sortButtonData)
    do
        if (index == EA_Window_InteractionRenownTraining.currentSort)
        then
            if (data.active == true)
            then
                if (index == 1)
                then
                    return EA_Window_InteractionRenownTraining.NameSort(a, b)
                end
                
                break
            end
        end
    end
    
    return false

end

function EA_Window_InteractionRenownTraining.NameSort(a, b)
    if (a == nil)
    then
        return false
    end
    
    if (b == nil)
    then
        return true
    end
    
    local nameA = a.advanceName
    if(a.abilityInfo ~= nil)
    then
        nameA = a.abilityInfo.name
    end
    
    local nameB = b.advanceName
    if(b.abilityInfo ~= nil)
    then
        nameB = b.abilityInfo.name
    end
    
    return ( WStringsCompare(nameA, nameB) < 0 )
        
end

----------------------------------------------------------------
-- Filtering
----------------------------------------------------------------
function EA_Window_InteractionRenownTraining.AvailabilityIfSetFilter(advanceData)

    local targetButton = "EA_Window_InteractionRenownTrainingAvailabilityFilterButton"
    local useFilter    = ( ButtonGetPressedFlag( targetButton ) )

    if (useFilter == false) then
        -- DEBUG(L"  allowing "..advanceData.abilityInfo.name..L" since it is disabled")
        return true
    end

    return InteractionUtils.AvailabilityFilter(advanceData, EA_Window_InteractionRenownTraining.advanceData)
           
end

function EA_Window_InteractionRenownTraining.GetDependencyText(advanceData)
    local dependencyText = nil

    for dependency, amount in pairs(advanceData.dependencies)
    do
        local dependentData = InteractionUtils.GetDependentPackage( advanceData, dependency, EA_Window_InteractionRenownTraining.advanceData )

        local displayName = dependentData.advanceName
        if(dependentData.abilityInfo ~= nil)
        then
            displayName = dependentData.abilityInfo.name
        end
        
        dependencyText = GetStringFormatFromTable("TrainingStrings", StringTables.Training.LABEL_REQUIRES_DEPENDENT_PACKAGE, { displayName, towstring(amount) } )

        -- Only look at the first dependency
        break
    end

    return dependencyText
end