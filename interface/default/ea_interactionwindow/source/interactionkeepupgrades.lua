EA_Window_InteractionKeepUpgrades =
{
}

EA_Window_InteractionKeepUpgrades.WINDOW_BASE_HEIGHT = 295
EA_Window_InteractionKeepUpgrades.HEIGHT_PER_ROW = 50

EA_Window_InteractionKeepUpgrades.COLUMN_LEFT = 1
EA_Window_InteractionKeepUpgrades.COLUMN_RIGHT = 2

EA_Window_InteractionKeepUpgrades.upgradeColumns =
{
    EA_Window_InteractionKeepUpgrades.COLUMN_LEFT,
    EA_Window_InteractionKeepUpgrades.COLUMN_RIGHT
}

EA_Window_InteractionKeepUpgrades.MAX_ROWS = 12
EA_Window_InteractionKeepUpgrades.MAX_COLS = #EA_Window_InteractionKeepUpgrades.upgradeColumns

EA_Window_InteractionKeepUpgrades.listData = {}

EA_Window_InteractionKeepUpgrades.currentUpgradeData = {}
EA_Window_InteractionKeepUpgrades.currentKeepID = 0
EA_Window_InteractionKeepUpgrades.currentGuildRank = 0
EA_Window_InteractionKeepUpgrades.currentPoints = 0 -- Total point values of all matured upgrades
EA_Window_InteractionKeepUpgrades.currentUpkeep = 0 -- Total upkeep of all matured upgrades
EA_Window_InteractionKeepUpgrades.totalUpkeep = 0   -- Total upkeep of all upgrades, both matured and planned
EA_Window_InteractionKeepUpgrades.numModifiedUpgrades = 0   -- How many upgrades have we changed from initial state
EA_Window_InteractionKeepUpgrades.isReadOnly = false

EA_Window_InteractionKeepUpgrades.activeUpgrades = {}


----------------------------------------------------------------
-- EA_Window_InteractionKeepUpgrades Functions
----------------------------------------------------------------

-- OnInitialize: Set localized strings and register event handlers
function EA_Window_InteractionKeepUpgrades.OnInitialize()

    LabelSetText( "EA_Window_InteractionKeepUpgradesTitleBarText", GetString( StringTables.Default.LABEL_UPGRADE_KEEP ) )
    LabelSetText( "EA_Window_InteractionKeepUpgradesCurrentUpkeepLabel", GetString( StringTables.Default.LABEL_CURRENT_UPKEEP_COST ) )
    LabelSetText( "EA_Window_InteractionKeepUpgradesTotalUpkeepLabel", GetString( StringTables.Default.LABEL_TOTAL_UPKEEP_COST ) )
    LabelSetText( "EA_Window_InteractionKeepUpgradesGuildFundsLabel", GetString( StringTables.Default.LABEL_APPROXIMATE_GUILD_FUNDS ) )
    LabelSetText( "EA_Window_InteractionKeepUpgradesHeader1Upgrade", GetString( StringTables.Default.LABEL_KEEP_UPGRADE_COLUMN_UPGRADE ) )
    LabelSetText( "EA_Window_InteractionKeepUpgradesHeader1Rank", GetString( StringTables.Default.LABEL_KEEP_UPGRADE_COLUMN_RANK ) )
    LabelSetText( "EA_Window_InteractionKeepUpgradesHeader1Cost", GetString( StringTables.Default.LABEL_KEEP_UPGRADE_COLUMN_COST ) )
    LabelSetText( "EA_Window_InteractionKeepUpgradesHeader1Time", GetString( StringTables.Default.LABEL_KEEP_UPGRADE_COLUMN_TIME ) )
    LabelSetText( "EA_Window_InteractionKeepUpgradesHeader2Upgrade", GetString( StringTables.Default.LABEL_KEEP_UPGRADE_COLUMN_UPGRADE ) )
    LabelSetText( "EA_Window_InteractionKeepUpgradesHeader2Rank", GetString( StringTables.Default.LABEL_KEEP_UPGRADE_COLUMN_RANK ) )
    LabelSetText( "EA_Window_InteractionKeepUpgradesHeader2Cost", GetString( StringTables.Default.LABEL_KEEP_UPGRADE_COLUMN_COST ) )
    LabelSetText( "EA_Window_InteractionKeepUpgradesHeader2Time", GetString( StringTables.Default.LABEL_KEEP_UPGRADE_COLUMN_TIME ) )
    ButtonSetText( "EA_Window_InteractionKeepUpgradesSaveButton", GetString( StringTables.Default.LABEL_SAVE ) )
    ButtonSetText( "EA_Window_InteractionKeepUpgradesResetButton", GetString( StringTables.Default.LABEL_RESET ) )
    ButtonSetText( "EA_Window_InteractionKeepUpgradesCancelButton", GetString( StringTables.Default.LABEL_CANCEL ) )
    
    WindowRegisterEventHandler( "EA_Window_InteractionKeepUpgrades", SystemData.Events.INTERACT_DONE,                "EA_Window_InteractionKeepUpgrades.Hide" )
    WindowRegisterEventHandler( "EA_Window_InteractionKeepUpgrades", SystemData.Events.INTERACT_KEEP_UPGRADE_OPEN,   "EA_Window_InteractionKeepUpgrades.Show" )
    WindowRegisterEventHandler( "EA_Window_InteractionKeepUpgrades", SystemData.Events.INTERACT_KEEP_UPGRADE_UPDATE, "EA_Window_InteractionKeepUpgrades.UpdatedInfo" )
    WindowRegisterEventHandler( "EA_Window_InteractionKeepUpgrades", SystemData.Events.GUILD_EXP_UPDATED,            "EA_Window_InteractionKeepUpgrades.OnGuildXPUpdated" )
    WindowRegisterEventHandler( "EA_Window_InteractionKeepUpgrades", SystemData.Events.GUILD_KEEP_UPDATED,           "EA_Window_InteractionKeepUpgrades.OnGuildKeepUpdated" )
    WindowRegisterEventHandler( "EA_Window_InteractionKeepUpgrades", SystemData.Events.GUILD_VAULT_COIN_UPDATED,     "EA_Window_InteractionKeepUpgrades.UpdatedGuildVault" )
    
end

-- GetKeepRank: Returns the rank of a keep based on how many points it has
function EA_Window_InteractionKeepUpgrades.GetKeepRank(points)
    local keepRank = math.floor(points / GameData.KeepUpgrades.POINTS_PER_LEVEL)
    return math.min(keepRank, GameData.KeepUpgrades.MAX_LEVEL)
end

-- GetChangeFromLevelToLevel: Returns the change in valueArray from going from oldLevel to newLevel
function EA_Window_InteractionKeepUpgrades.GetChangeFromLevelToLevel(valueArray, oldLevel, newLevel)
    local totalValue = 0
    if (oldLevel > 0) then
        totalValue = totalValue - valueArray[oldLevel]
    end
    if (newLevel > 0) then
        totalValue = totalValue + valueArray[newLevel]
    end
    return totalValue
end

-- GetSumFromLevelToLevel: Returns the sum of the values in valueArray between lowLevel and highLevel
function EA_Window_InteractionKeepUpgrades.GetSumFromLevelToLevel(valueArray, lowLevel, highLevel)
    local totalValue = 0
    for level = lowLevel, highLevel
    do
        totalValue = totalValue + valueArray[level]
    end
    return totalValue
end

-- IsUpgradeInActiveList: Checks if an upgrade is currently in the list of upgrades that are counting down their time values
function EA_Window_InteractionKeepUpgrades.IsUpgradeInActiveList(upgradeId)
    for _, activeUpgradeId in ipairs(EA_Window_InteractionKeepUpgrades.activeUpgrades)
    do
        if (upgradeId == activeUpgradeId) then
            return true
        end
    end
    
    return false
end

-- AddUpgradeToActiveList: Adds the upgrade with specified id to the active list, meaning that its time value will count down.
function EA_Window_InteractionKeepUpgrades.AddUpgradeToActiveList(upgradeId)
    if (EA_Window_InteractionKeepUpgrades.IsUpgradeInActiveList(upgradeId) == false) then
        table.insert(EA_Window_InteractionKeepUpgrades.activeUpgrades, upgradeId)
    end
end

-- RemoveUpgradeFromActiveList: Removes the upgrade with specified id from the active list, if it is in it
function EA_Window_InteractionKeepUpgrades.RemoveUpgradeFromActiveList(upgradeId)
    for arrayIndex, activeUpgradeId in ipairs(EA_Window_InteractionKeepUpgrades.activeUpgrades)
    do
        if (upgradeId == activeUpgradeId) then
            table.remove(EA_Window_InteractionKeepUpgrades.activeUpgrades, arrayIndex)
            break
        end
    end
end

-- GetRealCurrentLevel: The server increments the current level as soon as an upgrade is purchased. However, the client doesn't increment it until it matures. Use the status to translate between the two.
function EA_Window_InteractionKeepUpgrades.GetClientCurrentLevel(serverCurrentLevel, targetLevel, status)
    if ((status == GameData.KeepUpgradeStatus.PURCHASED) or (status == GameData.KeepUpgradeStatus.PURCHASED_NOT_FUNDED)) then
        -- If targetLevel < serverCurrentLevel, then we are downgrading and the server current level is the same as the client current level
        if (targetLevel < serverCurrentLevel) then
            return serverCurrentLevel
        end
        
        -- Otherwise, we upgraded but it hasn't matured yet, so subtract 1 from the server current level
        return serverCurrentLevel-1
    end
    
    -- Upgrade either hasn't been purchased yet or already matured, so the server current level is the same as the client current level
    return serverCurrentLevel
end

-- AssignToFirstAvailableLocation: Finds the first available row, col in the map displayLocationAvailable and assigns the keep upgrade to that location
function EA_Window_InteractionKeepUpgrades.AssignToFirstAvailableLocation(keepUpgrade, displayLocationAvailable)
    for rowNum = 1, EA_Window_InteractionKeepUpgrades.MAX_ROWS
    do
        for colNum = 1, EA_Window_InteractionKeepUpgrades.MAX_COLS
        do
            if (displayLocationAvailable[rowNum][colNum]) then
                keepUpgrade.row = rowNum
                keepUpgrade.col = colNum
                displayLocationAvailable[rowNum][colNum] = false
                return
            end
        end
    end
end

-- SetCellShowing: Shows or hides the fields for a specific row and column
function EA_Window_InteractionKeepUpgrades.SetCellShowing(rowNum, colNum, showing)
    local rowFrame = "EA_Window_InteractionKeepUpgradesListBoxRow"..rowNum
    
    WindowSetShowing(rowFrame.."Upgrade"..colNum, showing)
    WindowSetShowing(rowFrame.."Money"..colNum, showing)
    WindowSetShowing(rowFrame.."Clock"..colNum, showing)
    WindowSetShowing(rowFrame.."Time"..colNum, showing)
    WindowSetShowing(rowFrame.."Rank"..colNum, showing)
    WindowSetShowing(rowFrame.."RankUp"..colNum, showing)
    WindowSetShowing(rowFrame.."RankDown"..colNum, showing)
end

-- MeetsDependencies: Returns true if an upgrade meets at least one of its dependencies, or has no dependencies, or if the player already has it; false otherwise
function EA_Window_InteractionKeepUpgrades.MeetsDependencies(keepUpgrade)
    local hasAnyDependencies = false
    local meetsAnyDependencies = false
    
    for _, dependencyUpgradeId in ipairs(keepUpgrade.dependsOn)
    do
        local dependencyKeepUpgrade = EA_Window_InteractionKeepUpgrades.currentUpgradeData[dependencyUpgradeId]
        if (dependencyKeepUpgrade ~= nil) then
            hasAnyDependencies = true
            if (dependencyKeepUpgrade.currentLevel > 0) then
                meetsAnyDependencies = true
                break
            end
        end
    end
    
    return (meetsAnyDependencies or not hasAnyDependencies or (keepUpgrade.currentLevel > 0))
end

-- GetUpgradeTotalTimeInMinutes: Figures out the value to display in the time column based on the current target level and the current time left on an existing upgrade
function EA_Window_InteractionKeepUpgrades.GetUpgradeTotalTimeInMinutes(keepUpgrade)
    local totalTime = 0
    if (keepUpgrade.targetLevel > keepUpgrade.currentLevel) then
        -- We're currently upgrading
        if (keepUpgrade.localTargetLevel < keepUpgrade.currentLevel) then
            -- Player actually wants to downgrade. Ignore upgrade time, just use the planned downgrade time
            totalTime = EA_Window_InteractionKeepUpgrades.GetSumFromLevelToLevel(keepUpgrade.timeToMature, keepUpgrade.localTargetLevel+1, keepUpgrade.currentLevel)
        elseif (keepUpgrade.localTargetLevel == keepUpgrade.currentLevel) then
            -- Player wants to cancel the upgrade
            totalTime = 0
        elseif (keepUpgrade.localTargetLevel == keepUpgrade.currentLevel+1) then
            -- Player is just upgrading one level
            totalTime = keepUpgrade.time
        elseif (keepUpgrade.localTargetLevel > keepUpgrade.currentLevel+1) then
            -- Player is upgrading more than one level
            totalTime = keepUpgrade.time + EA_Window_InteractionKeepUpgrades.GetSumFromLevelToLevel(keepUpgrade.timeToMature, keepUpgrade.currentLevel+2, keepUpgrade.localTargetLevel)
        end
    elseif (keepUpgrade.targetLevel < keepUpgrade.currentLevel) then
        -- We're currently downgrading
        if (keepUpgrade.localTargetLevel > keepUpgrade.currentLevel) then
            -- Player actually wants to upgrade. Ignore downgrade time, just use the planned upgrade time
            totalTime = EA_Window_InteractionKeepUpgrades.GetSumFromLevelToLevel(keepUpgrade.timeToMature, keepUpgrade.currentLevel+1, keepUpgrade.localTargetLevel)
        elseif (keepUpgrade.localTargetLevel == keepUpgrade.currentLevel) then
            -- Player wants to cancel the downgrade
            totalTime = 0
        elseif (keepUpgrade.localTargetLevel == keepUpgrade.currentLevel-1) then
            -- Player is just downgrading one level
            totalTime = keepUpgrade.time
        elseif (keepUpgrade.localTargetLevel < keepUpgrade.currentLevel-1) then
            -- Player is downgrading more than one level
            totalTime = keepUpgrade.time + EA_Window_InteractionKeepUpgrades.GetSumFromLevelToLevel(keepUpgrade.timeToMature, keepUpgrade.localTargetLevel+1, keepUpgrade.currentLevel-1)
        end
    elseif (keepUpgrade.targetLevel == keepUpgrade.currentLevel) then
        -- We're not currently upgrading or downgrading, so only take into account the time of any planned actions
        if (keepUpgrade.localTargetLevel > keepUpgrade.currentLevel) then
            totalTime = EA_Window_InteractionKeepUpgrades.GetSumFromLevelToLevel(keepUpgrade.timeToMature, keepUpgrade.currentLevel+1, keepUpgrade.localTargetLevel)
        elseif (keepUpgrade.localTargetLevel < keepUpgrade.currentLevel) then
            totalTime = EA_Window_InteractionKeepUpgrades.GetSumFromLevelToLevel(keepUpgrade.timeToMature, keepUpgrade.localTargetLevel+1, keepUpgrade.currentLevel)
        elseif (keepUpgrade.localTargetLevel == keepUpgrade.currentLevel) then
            totalTime = 0
        end
    end
    
    return math.ceil(totalTime / 60)
end

-- UpdateUpgradeValues: Sets the listbox values (except for upgrade name) for a specific keep upgrade
function EA_Window_InteractionKeepUpgrades.UpdateUpgradeValues(keepUpgrade)
    local rowNum = keepUpgrade.row
    local colNum = keepUpgrade.col
    local rowFrame = "EA_Window_InteractionKeepUpgradesListBoxRow"..rowNum
    
    if (EA_Window_InteractionKeepUpgrades.isReadOnly) then
        ButtonSetDisabledFlag(rowFrame.."RankUp"..colNum, true)
        ButtonSetDisabledFlag(rowFrame.."RankDown"..colNum, true)
        DefaultColor.LabelSetTextColor(rowFrame.."Upgrade"..colNum, DefaultColor.MEDIUM_GRAY)
    else
        if (EA_Window_InteractionKeepUpgrades.MeetsDependencies(keepUpgrade)) then
            if (keepUpgrade.localTargetLevel >= keepUpgrade.totalLevel) then
                ButtonSetDisabledFlag(rowFrame.."RankUp"..colNum, true)
                DefaultColor.LabelSetTextColor(rowFrame.."Upgrade"..colNum, DefaultColor.WHITE)
            else
                if (GameData.Guild.m_GuildRank < keepUpgrade.rankRequired[keepUpgrade.localTargetLevel + 1]) then
                    ButtonSetDisabledFlag(rowFrame.."RankUp"..colNum, true)
                    DefaultColor.LabelSetTextColor(rowFrame.."Upgrade"..colNum, DefaultColor.MEDIUM_GRAY)
                else
                    ButtonSetDisabledFlag(rowFrame.."RankUp"..colNum, false)
                    DefaultColor.LabelSetTextColor(rowFrame.."Upgrade"..colNum, DefaultColor.WHITE)
                end
            end
        else
            ButtonSetDisabledFlag(rowFrame.."RankUp"..colNum, true)
            DefaultColor.LabelSetTextColor(rowFrame.."Upgrade"..colNum, DefaultColor.MEDIUM_GRAY)
        end
    
        if (keepUpgrade.localTargetLevel == 0) then
            ButtonSetDisabledFlag(rowFrame.."RankDown"..colNum, true)
        else
            ButtonSetDisabledFlag(rowFrame.."RankDown"..colNum, false)
        end
    end
    
    LabelSetText(rowFrame.."Rank"..colNum, GetStringFormat( StringTables.Default.TEXT_KEEP_UPGRADE_TARGET_LEVEL, { keepUpgrade.localTargetLevel } ))
    
    local totalCost = 0
    if (keepUpgrade.localTargetLevel > 0) then
        totalCost = keepUpgrade.cost[keepUpgrade.localTargetLevel]
    end
    MoneyFrame.FormatMoney(rowFrame.."Money"..colNum, totalCost, MoneyFrame.HIDE_EMPTY_WINDOWS_ABOVE_VALUE)
    
    local totalTimeInMinutes = EA_Window_InteractionKeepUpgrades.GetUpgradeTotalTimeInMinutes(keepUpgrade)
    if (totalTimeInMinutes > 0) then
        keepUpgrade.lastTimeInMinutes = totalTimeInMinutes
        LabelSetText(rowFrame.."Time"..colNum, GetStringFormat( StringTables.Default.TEXT_KEEP_UPGRADE_TIME_IN_MINUTES, { totalTimeInMinutes } ))
        WindowSetShowing(rowFrame.."Clock"..colNum, true)
        WindowSetShowing(rowFrame.."Time"..colNum, true)
    else
        keepUpgrade.lastTimeInMinutes = 0
        WindowSetShowing(rowFrame.."Clock"..colNum, false)
        WindowSetShowing(rowFrame.."Time"..colNum, false)
    end
end

-- UpdateDependencies: Handles a possible change to an upgrade's current level that might affect upgrades that depend on it
function EA_Window_InteractionKeepUpgrades.UpdateDependencies(keepUpgrade)
    for _, possibleDependencyKeepUpgrade in pairs(EA_Window_InteractionKeepUpgrades.currentUpgradeData)
    do
        if (keepUpgrade.id ~= possibleDependencyKeepUpgrade.id) then
            for _, dependencyUpgradeId in ipairs(possibleDependencyKeepUpgrade.dependsOn)
            do
                if (keepUpgrade.id == dependencyUpgradeId) then
                    -- Make sure localTargetLevel is still valid
                    if ((keepUpgrade.currentLevel == 0) and (possibleDependencyKeepUpgrade.localTargetLevel > possibleDependencyKeepUpgrade.targetLevel)) then
                        EA_Window_InteractionKeepUpgrades.UpdateSaveResetButtonStates(possibleDependencyKeepUpgrade, possibleDependencyKeepUpgrade.targetLevel, possibleDependencyKeepUpgrade.targetLevel)
                        EA_Window_InteractionKeepUpgrades.UpdateTotalUpkeep(possibleDependencyKeepUpgrade, possibleDependencyKeepUpgrade.localTargetLevel, possibleDependencyKeepUpgrade.targetLevel)
                        possibleDependencyKeepUpgrade.localTargetLevel = possibleDependencyKeepUpgrade.targetLevel
                    end
                    -- Update the dependency's displayed values
                    EA_Window_InteractionKeepUpgrades.UpdateUpgradeValues(possibleDependencyKeepUpgrade)
                    break
                end
            end
        end
    end
end

-- Show: Initializes the window for a specific set of keep upgrades
function EA_Window_InteractionKeepUpgrades.Show(upgradeData, keepID, upkeepCost)
    EA_Window_InteractionKeepUpgrades.currentUpgradeData = {}
    EA_Window_InteractionKeepUpgrades.activeUpgrades = {}
    EA_Window_InteractionKeepUpgrades.isReadOnly = not GuildWindowTabAdmin.GetGuildCommandPermissionForPlayer( SystemData.GuildPermissons.KEEPUPGRADE_EDIT )
    EA_Window_InteractionKeepUpgrades.currentKeepID = keepID
    EA_Window_InteractionKeepUpgrades.currentGuildRank = GameData.Guild.m_GuildRank
    
    local displayLocationAvailable = {}
    local numRowsUsed = 0
    -- Initialize all display locations as available
    for rowNum = 1, EA_Window_InteractionKeepUpgrades.MAX_ROWS
    do
        displayLocationAvailable[rowNum] = {}
        for colNum = 1, EA_Window_InteractionKeepUpgrades.MAX_COLS
        do
            displayLocationAvailable[rowNum][colNum] = true
        end
    end
    
    local currentPoints = 0
    local currentUpkeep = upkeepCost
    local totalUpkeep = upkeepCost
    -- First pass through upgrades
    for _, keepUpgrade in ipairs(upgradeData)
    do
        -- Translate the current level the server gave us to a current level we understand
        keepUpgrade.currentLevel = EA_Window_InteractionKeepUpgrades.GetClientCurrentLevel(keepUpgrade.currentLevel, keepUpgrade.targetLevel, keepUpgrade.status)
        
        if (keepUpgrade.currentLevel > 0) then
            currentPoints = currentPoints + keepUpgrade.points[keepUpgrade.currentLevel]
            currentUpkeep = currentUpkeep + keepUpgrade.cost[keepUpgrade.currentLevel]
        end
        
        if (keepUpgrade.targetLevel > 0) then
            totalUpkeep = totalUpkeep + keepUpgrade.cost[keepUpgrade.targetLevel]
        end
        
        if (keepUpgrade.time > 0) then
            EA_Window_InteractionKeepUpgrades.AddUpgradeToActiveList(keepUpgrade.id)
        end
        
        keepUpgrade.localTargetLevel = keepUpgrade.targetLevel
        
        -- If the upgrade has a definite location, mark its position as no longer available
        if ((keepUpgrade.row > 0) and (keepUpgrade.col > 0)) then
            displayLocationAvailable[keepUpgrade.row][keepUpgrade.col] = false
            if (keepUpgrade.row > numRowsUsed) then
                numRowsUsed = keepUpgrade.row
            end
        end
            
        EA_Window_InteractionKeepUpgrades.currentUpgradeData[keepUpgrade.id] = keepUpgrade
    end
    
    -- Assign any upgrades without a specific row/col to the first available slot
    for _, keepUpgrade in pairs(EA_Window_InteractionKeepUpgrades.currentUpgradeData)
    do
        if ((keepUpgrade.row == 0) or (keepUpgrade.col == 0)) then
            EA_Window_InteractionKeepUpgrades.AssignToFirstAvailableLocation(keepUpgrade, displayLocationAvailable)
            if (keepUpgrade.row > numRowsUsed) then
                numRowsUsed = keepUpgrade.row
            end
        end
    end
    
    EA_Window_InteractionKeepUpgrades.currentPoints = currentPoints
    EA_Window_InteractionKeepUpgrades.currentUpkeep = currentUpkeep
    EA_Window_InteractionKeepUpgrades.totalUpkeep = totalUpkeep
    
    EA_Window_InteractionKeepUpgrades.numModifiedUpgrades = 0
    ButtonSetDisabledFlag( "EA_Window_InteractionKeepUpgradesSaveButton", true )
    ButtonSetDisabledFlag( "EA_Window_InteractionKeepUpgradesResetButton", true )
    
    LabelSetText( "EA_Window_InteractionKeepUpgradesKeepName", GetKeepName(keepID) )
    local keepRank = EA_Window_InteractionKeepUpgrades.GetKeepRank(currentPoints)
    LabelSetText( "EA_Window_InteractionKeepUpgradesRankText", GetStringFormat(StringTables.Default.TEXT_KEEP_UPGRADE_CURRENT_RANK, { keepRank } ))
    MoneyFrame.FormatMoney ("EA_Window_InteractionKeepUpgradesCurrentUpkeepMoney", currentUpkeep, MoneyFrame.HIDE_EMPTY_WINDOWS_ABOVE_VALUE)
    MoneyFrame.FormatMoney ("EA_Window_InteractionKeepUpgradesTotalUpkeepMoney", totalUpkeep, MoneyFrame.HIDE_EMPTY_WINDOWS_ABOVE_VALUE)
    
    EA_Window_InteractionKeepUpgrades.listData = {}
    -- Initialize rows to blank
    local displayOrder = {}
    for rowNum = 1, numRowsUsed
    do
        EA_Window_InteractionKeepUpgrades.listData[rowNum] = {}
        for colNum = 1, EA_Window_InteractionKeepUpgrades.MAX_COLS
        do
            EA_Window_InteractionKeepUpgrades.listData[rowNum]["upgrade"..colNum] = L""
        end
        table.insert(displayOrder, rowNum)
    end
        
    -- Set upgrade names
    for _, keepUpgrade in pairs(EA_Window_InteractionKeepUpgrades.currentUpgradeData)
    do
        EA_Window_InteractionKeepUpgrades.listData[keepUpgrade.row]["upgrade"..keepUpgrade.col] = GetKeepUpgradeName(keepUpgrade.id)
    end
        
    -- Initialize listbox
    ListBoxSetVisibleRowCount( "EA_Window_InteractionKeepUpgradesListBox", numRowsUsed )
    ListBoxSetDisplayOrder( "EA_Window_InteractionKeepUpgradesListBox", displayOrder )
        
    -- Set whether or not each cell is visible based on whether it has an upgrade in it
    for rowNum = 1, numRowsUsed
    do
        for colNum = 1, EA_Window_InteractionKeepUpgrades.MAX_COLS
        do
            EA_Window_InteractionKeepUpgrades.SetCellShowing(rowNum, colNum, not displayLocationAvailable[rowNum][colNum])
        end
    end
        
    -- For each upgrade, set its cell to show its current data
    for _, keepUpgrade in pairs(EA_Window_InteractionKeepUpgrades.currentUpgradeData)
    do
        EA_Window_InteractionKeepUpgrades.UpdateUpgradeValues(keepUpgrade)
            
        local rowFrame = "EA_Window_InteractionKeepUpgradesListBoxRow"..keepUpgrade.row
        WindowSetId(rowFrame.."Upgrade"..keepUpgrade.col, keepUpgrade.id)
        WindowSetId(rowFrame.."RankUp"..keepUpgrade.col, keepUpgrade.id)
        WindowSetId(rowFrame.."RankDown"..keepUpgrade.col, keepUpgrade.id)
    end
    
    -- Set window sizes
    local listBoxHeight = EA_Window_InteractionKeepUpgrades.HEIGHT_PER_ROW * numRowsUsed
    local windowHeight = EA_Window_InteractionKeepUpgrades.WINDOW_BASE_HEIGHT + listBoxHeight
    local listBoxWidth, _ = WindowGetDimensions( "EA_Window_InteractionKeepUpgradesListBox" )
    local windowWidth, _ = WindowGetDimensions( "EA_Window_InteractionKeepUpgrades" )
    WindowSetDimensions( "EA_Window_InteractionKeepUpgrades", windowWidth, windowHeight )
    WindowSetDimensions( "EA_Window_InteractionKeepUpgradesListBox", listBoxWidth, listBoxHeight )
    
    WindowSetShowing( "EA_Window_InteractionKeepUpgrades", true )
end

-- Hide: Causes the window to be hidden
function EA_Window_InteractionKeepUpgrades.Hide()
    WindowSetShowing( "EA_Window_InteractionKeepUpgrades", false )
    EA_Window_InteractionKeepUpgrades.activeUpgrades = {}
end

-- OnShown: Called when the window has just been shown
function EA_Window_InteractionKeepUpgrades.OnShown()
    WindowUtils.OnShown( EA_Window_InteractionKeepUpgrades.Hide, WindowUtils.Cascade.MODE_AUTOMATIC )
end

-- OnHidden: Called when the window has just been hidden
function EA_Window_InteractionKeepUpgrades.OnHidden()
    WindowUtils.OnHidden()
end

-- SetRowBackgroundColor: Automatically sets the listbox's background color for a specific row
function EA_Window_InteractionKeepUpgrades.SetRowBackgroundColor(rowNum)
    local rowFrame = "EA_Window_InteractionKeepUpgradesListBoxRow"..rowNum
    local row_mod = math.mod(rowNum, 2)
    local color = DataUtils.GetAlternatingRowColor( row_mod )
    
    WindowSetTintColor( rowFrame.."Background1", color.r, color.g, color.b )
    WindowSetAlpha( rowFrame.."Background1", color.a )
    WindowSetTintColor( rowFrame.."Background2", color.r, color.g, color.b )
    WindowSetAlpha( rowFrame.."Background2", color.a )
end

-- PopulateList: Internal listbox function called to initialize the listbox
function EA_Window_InteractionKeepUpgrades.PopulateList()
    if (EA_Window_InteractionKeepUpgradesListBox.PopulatorIndices ~= nil) then				
        for rowIndex, dataIndex in ipairs (EA_Window_InteractionKeepUpgradesListBox.PopulatorIndices)
        do
            EA_Window_InteractionKeepUpgrades.SetRowBackgroundColor(rowIndex)
        end
    end
end

-- UpdateCurrentPoints: Updates the current points and keep rank based on a change of an upgrade from oldLevel to newLevel
function EA_Window_InteractionKeepUpgrades.UpdateCurrentPoints(keepUpgrade, oldLevel, newLevel)
    EA_Window_InteractionKeepUpgrades.currentPoints = EA_Window_InteractionKeepUpgrades.currentPoints + EA_Window_InteractionKeepUpgrades.GetChangeFromLevelToLevel(keepUpgrade.points, oldLevel, newLevel)
    local keepRank = EA_Window_InteractionKeepUpgrades.GetKeepRank(EA_Window_InteractionKeepUpgrades.currentPoints)
    LabelSetText( "EA_Window_InteractionKeepUpgradesRankText", GetStringFormat(StringTables.Default.TEXT_KEEP_UPGRADE_CURRENT_RANK, { keepRank } ))
end

-- UpdateCurrentUpkeep: Updates the current upkeep based on a change of an upgrade from oldLevel to newLevel
function EA_Window_InteractionKeepUpgrades.UpdateCurrentUpkeep(keepUpgrade, oldLevel, newLevel)
    EA_Window_InteractionKeepUpgrades.currentUpkeep = EA_Window_InteractionKeepUpgrades.currentUpkeep + EA_Window_InteractionKeepUpgrades.GetChangeFromLevelToLevel(keepUpgrade.cost, oldLevel, newLevel)
    MoneyFrame.FormatMoney ("EA_Window_InteractionKeepUpgradesCurrentUpkeepMoney", EA_Window_InteractionKeepUpgrades.currentUpkeep, MoneyFrame.HIDE_EMPTY_WINDOWS_ABOVE_VALUE)
end

-- UpdateTotalUpkeep: Updates the total upkeep based on a change of an upgrade from oldLevel to newLevel
function EA_Window_InteractionKeepUpgrades.UpdateTotalUpkeep(keepUpgrade, oldLevel, newLevel)
    EA_Window_InteractionKeepUpgrades.totalUpkeep = EA_Window_InteractionKeepUpgrades.totalUpkeep + EA_Window_InteractionKeepUpgrades.GetChangeFromLevelToLevel(keepUpgrade.cost, oldLevel, newLevel)
    MoneyFrame.FormatMoney ("EA_Window_InteractionKeepUpgradesTotalUpkeepMoney", EA_Window_InteractionKeepUpgrades.totalUpkeep, MoneyFrame.HIDE_EMPTY_WINDOWS_ABOVE_VALUE)
end

-- UpdateSaveResetButtonStates: Updates numModifiedUpgrades when an upgrade's targetLevel and/or localTargetLevel has changed, and grays Save/Reset buttons appropriately
function EA_Window_InteractionKeepUpgrades.UpdateSaveResetButtonStates(keepUpgrade, newTargetLevel, newLocalTargetLevel)
    if ((newLocalTargetLevel ~= newTargetLevel) and (keepUpgrade.localTargetLevel == keepUpgrade.targetLevel)) then
        -- The upgrade was non-modified and has become modified
        EA_Window_InteractionKeepUpgrades.numModifiedUpgrades = EA_Window_InteractionKeepUpgrades.numModifiedUpgrades + 1
        if (EA_Window_InteractionKeepUpgrades.numModifiedUpgrades > 0) then
            ButtonSetDisabledFlag( "EA_Window_InteractionKeepUpgradesSaveButton", false )
            ButtonSetDisabledFlag( "EA_Window_InteractionKeepUpgradesResetButton", false )
        end
    elseif ((newLocalTargetLevel == newTargetLevel) and (keepUpgrade.localTargetLevel ~= keepUpgrade.targetLevel)) then
        -- The upgrade was modified and has become non-modified
        EA_Window_InteractionKeepUpgrades.numModifiedUpgrades = EA_Window_InteractionKeepUpgrades.numModifiedUpgrades - 1
        if (EA_Window_InteractionKeepUpgrades.numModifiedUpgrades == 0) then
            ButtonSetDisabledFlag( "EA_Window_InteractionKeepUpgradesSaveButton", true )
            ButtonSetDisabledFlag( "EA_Window_InteractionKeepUpgradesResetButton", true )
        end
    end
    -- In the other two cases (upgrade was modified and is still modified) and (upgrade was not modified and is still not modified), we don't need to do anything
end

-- OnRankUp: Called when the rank up button is pressed for a specific upgrade
function EA_Window_InteractionKeepUpgrades.OnRankUp()
    if (not EA_Window_InteractionKeepUpgrades.isReadOnly) then
        local upgradeId = WindowGetId( SystemData.ActiveWindow.name )

        local keepUpgrade = EA_Window_InteractionKeepUpgrades.currentUpgradeData[upgradeId]
        if ((keepUpgrade.localTargetLevel < keepUpgrade.totalLevel) and EA_Window_InteractionKeepUpgrades.MeetsDependencies(keepUpgrade)) then
            local newLocalTargetLevel = keepUpgrade.localTargetLevel + 1
            if (GameData.Guild.m_GuildRank >= keepUpgrade.rankRequired[newLocalTargetLevel]) then
                EA_Window_InteractionKeepUpgrades.UpdateSaveResetButtonStates(keepUpgrade, keepUpgrade.targetLevel, newLocalTargetLevel)
                keepUpgrade.localTargetLevel = newLocalTargetLevel
                EA_Window_InteractionKeepUpgrades.UpdateUpgradeValues(keepUpgrade)
                EA_Window_InteractionKeepUpgrades.UpdateTotalUpkeep(keepUpgrade, newLocalTargetLevel-1, newLocalTargetLevel)
            end
        end
    end
end

-- OnRankDown: Called when the rank down button is pressed for a specific upgrade
function EA_Window_InteractionKeepUpgrades.OnRankDown()
    if (not EA_Window_InteractionKeepUpgrades.isReadOnly) then
        local upgradeId = WindowGetId( SystemData.ActiveWindow.name )
    
        local keepUpgrade = EA_Window_InteractionKeepUpgrades.currentUpgradeData[upgradeId]
        if (keepUpgrade.localTargetLevel > 0) then
            local newLocalTargetLevel = keepUpgrade.localTargetLevel - 1
            EA_Window_InteractionKeepUpgrades.UpdateSaveResetButtonStates(keepUpgrade, keepUpgrade.targetLevel, newLocalTargetLevel)
            keepUpgrade.localTargetLevel = newLocalTargetLevel
            EA_Window_InteractionKeepUpgrades.UpdateUpgradeValues(keepUpgrade)
            EA_Window_InteractionKeepUpgrades.UpdateTotalUpkeep(keepUpgrade, newLocalTargetLevel+1, newLocalTargetLevel)
        end
    end
end

-- OnReset: Called when the reset button is pressed
function EA_Window_InteractionKeepUpgrades.OnReset()
    for _, keepUpgrade in pairs(EA_Window_InteractionKeepUpgrades.currentUpgradeData)
    do
        if (keepUpgrade.localTargetLevel ~= keepUpgrade.targetLevel) then
            EA_Window_InteractionKeepUpgrades.UpdateTotalUpkeep(keepUpgrade, keepUpgrade.localTargetLevel, keepUpgrade.targetLevel)
            keepUpgrade.localTargetLevel = keepUpgrade.targetLevel
            EA_Window_InteractionKeepUpgrades.UpdateUpgradeValues(keepUpgrade)
        end
    end
    
    EA_Window_InteractionKeepUpgrades.numModifiedUpgrades = 0
    ButtonSetDisabledFlag( "EA_Window_InteractionKeepUpgradesSaveButton", true )
    ButtonSetDisabledFlag( "EA_Window_InteractionKeepUpgradesResetButton", true )
end

-- OnUpdate: Used to count down timers for active upgrades
function EA_Window_InteractionKeepUpgrades.OnUpdate( timePassed )
    local indicesToRemove = {}
    for _, upgradeId in ipairs(EA_Window_InteractionKeepUpgrades.activeUpgrades)
    do
        local keepUpgrade = EA_Window_InteractionKeepUpgrades.currentUpgradeData[upgradeId]
        local newTime = keepUpgrade.time - timePassed
        
        if (newTime <= 0) then
            if (keepUpgrade.currentLevel < keepUpgrade.targetLevel) then
                -- The upgrade just leveled up
                keepUpgrade.currentLevel = keepUpgrade.currentLevel + 1
                EA_Window_InteractionKeepUpgrades.UpdateCurrentPoints(keepUpgrade, keepUpgrade.currentLevel-1, keepUpgrade.currentLevel)
                EA_Window_InteractionKeepUpgrades.UpdateCurrentUpkeep(keepUpgrade, keepUpgrade.currentLevel-1, keepUpgrade.currentLevel)
            elseif (keepUpgrade.currentLevel > keepUpgrade.targetLevel) then
                -- The upgrade just leveled down
                keepUpgrade.currentLevel = keepUpgrade.currentLevel - 1
                EA_Window_InteractionKeepUpgrades.UpdateCurrentPoints(keepUpgrade, keepUpgrade.currentLevel+1, keepUpgrade.currentLevel)
                EA_Window_InteractionKeepUpgrades.UpdateCurrentUpkeep(keepUpgrade, keepUpgrade.currentLevel+1, keepUpgrade.currentLevel)
            end
            
            if (keepUpgrade.targetLevel == keepUpgrade.currentLevel) then
                -- Reached our target, remove from active list
                table.insert(indicesToRemove, keepUpgrade.id)
                keepUpgrade.time = 0
            else
                -- Haven't reached the target. Set time remaining to new value.
                if (keepUpgrade.currentLevel < keepUpgrade.targetLevel) then
                    keepUpgrade.time = keepUpgrade.timeToMature[keepUpgrade.currentLevel+1] + newTime
                else
                    keepUpgrade.time = keepUpgrade.timeToMature[keepUpgrade.currentLevel] + newTime
                end
            end
            
            -- Update the row (to update the time)
            EA_Window_InteractionKeepUpgrades.UpdateUpgradeValues(keepUpgrade)
            -- Update dependency rows (which could have been locked or unlocked by this upgrade changing level)
            EA_Window_InteractionKeepUpgrades.UpdateDependencies(keepUpgrade)
        else
            keepUpgrade.time = newTime
            local totalTimeInMinutes = EA_Window_InteractionKeepUpgrades.GetUpgradeTotalTimeInMinutes(keepUpgrade)
            if (totalTimeInMinutes ~= keepUpgrade.lastTimeInMinutes) then
                EA_Window_InteractionKeepUpgrades.UpdateUpgradeValues(keepUpgrade)
            end
        end
    end
    
    for _, upgradeId in ipairs(indicesToRemove)
    do
        EA_Window_InteractionKeepUpgrades.RemoveUpgradeFromActiveList(upgradeId)
    end
end

-- ShowNotEnoughMoneyDialog: Show a dialog alerting the user they can't afford to purchase a certain upgrade
function EA_Window_InteractionKeepUpgrades.ShowNotEnoughMoneyDialog(upgradeId)
    local upgradeName = GetKeepUpgradeName(upgradeId)
    local displayString = GetStringFormat(StringTables.Default.TEXT_KEEP_UPGRADE_NOT_ENOUGH_MONEY, { upgradeName })
    DialogManager.MakeOneButtonDialog( displayString, GetString( StringTables.Default.LABEL_OKAY ), nil )
end

-- OnGuildXPUpdated: Check if the guild has leveled up, and if so, unlock any upgrades as appropriate
function EA_Window_InteractionKeepUpgrades.OnGuildXPUpdated()
    if (WindowGetShowing( "EA_Window_InteractionKeepUpgrades" )) then
        if (GameData.Guild.m_GuildRank > EA_Window_InteractionKeepUpgrades.currentGuildRank) then
            for _, keepUpgrade in pairs(EA_Window_InteractionKeepUpgrades.currentUpgradeData)
            do
                if (keepUpgrade.localTargetLevel < keepUpgrade.totalLevel) then
                    local rankRequired = keepUpgrade.rankRequired[keepUpgrade.localTargetLevel + 1]
                    if ((EA_Window_InteractionKeepUpgrades.currentGuildRank < rankRequired) and (GameData.Guild.m_GuildRank >= rankRequired)) then
                        EA_Window_InteractionKeepUpgrades.UpdateUpgradeValues(keepUpgrade)
                    end
                end
            end
            
            EA_Window_InteractionKeepUpgrades.currentGuildRank = GameData.Guild.m_GuildRank
        end
    end
end

-- OnGuildKeepUpdated: Check if the guild keep has been lost, in which case we'd need to close the window
function EA_Window_InteractionKeepUpgrades.OnGuildKeepUpdated()
    if (WindowGetShowing( "EA_Window_InteractionKeepUpgrades" )) then
        if (GameData.Guild.KeepId ~= EA_Window_InteractionKeepUpgrades.currentKeepID) then
            EA_Window_InteractionKeepUpgrades.Hide()
        
            local keepName = GetKeepName(EA_Window_InteractionKeepUpgrades.currentKeepID)
            local displayString = GetStringFormat(StringTables.Default.TEXT_KEEP_UPGRADE_KEEP_LOST, { keepName })
            DialogManager.MakeOneButtonDialog( displayString, GetString( StringTables.Default.LABEL_OKAY ), nil )
        end
    end
end

-- UpdatedInfo: Sent by the server when new information has arrived for certain upgrade packages
function EA_Window_InteractionKeepUpgrades.UpdatedInfo(upgradeData, keepID)
    if (WindowGetShowing( "EA_Window_InteractionKeepUpgrades" )) then
        for _, newUpgradeData in ipairs(upgradeData)
        do
            for _, keepUpgrade in pairs(EA_Window_InteractionKeepUpgrades.currentUpgradeData)
            do
                if (newUpgradeData.id == keepUpgrade.id) then
                    -- See if this is a failed purchase update
                    if (newUpgradeData.status == GameData.KeepUpgradeStatus.NOT_ENOUGH_MONEY_TO_PURCHASE) then
                        EA_Window_InteractionKeepUpgrades.UpdateSaveResetButtonStates(keepUpgrade, keepUpgrade.currentLevel, keepUpgrade.currentLevel)
                        EA_Window_InteractionKeepUpgrades.UpdateTotalUpkeep(keepUpgrade, keepUpgrade.localTargetLevel, keepUpgrade.currentLevel)
                        
                        keepUpgrade.targetLevel = keepUpgrade.currentLevel
                        keepUpgrade.localTargetLevel = keepUpgrade.currentLevel
                        EA_Window_InteractionKeepUpgrades.RemoveUpgradeFromActiveList(keepUpgrade.id)
                        
                        EA_Window_InteractionKeepUpgrades.ShowNotEnoughMoneyDialog(keepUpgrade.id)
                    else
                        -- Translate the current level the server gave us to a current level we understand
                        newUpgradeData.currentLevel = EA_Window_InteractionKeepUpgrades.GetClientCurrentLevel(newUpgradeData.currentLevel, newUpgradeData.targetLevel, newUpgradeData.status)
                    
                        -- Figure out what's changed, and adjust our internal values appropriately
                        if (newUpgradeData.currentLevel ~= keepUpgrade.currentLevel) then
                            EA_Window_InteractionKeepUpgrades.UpdateCurrentPoints(keepUpgrade, keepUpgrade.currentLevel, newUpgradeData.currentLevel)
                            EA_Window_InteractionKeepUpgrades.UpdateCurrentUpkeep(keepUpgrade, keepUpgrade.currentLevel, newUpgradeData.currentLevel)
                            keepUpgrade.currentLevel = newUpgradeData.currentLevel
                            -- Update dependency rows (which could have been locked or unlocked by this upgrade changing level)
                            EA_Window_InteractionKeepUpgrades.UpdateDependencies(keepUpgrade)
                        end
                
                        if (newUpgradeData.targetLevel ~= keepUpgrade.targetLevel) then
                            EA_Window_InteractionKeepUpgrades.UpdateSaveResetButtonStates(keepUpgrade, newUpgradeData.targetLevel, keepUpgrade.localTargetLevel)
                            keepUpgrade.targetLevel = newUpgradeData.targetLevel
                        end
                
                        if (newUpgradeData.time > 0) then
                            keepUpgrade.time = newUpgradeData.time
                            -- Add to active list (safe to call even if it's already in it)
                            EA_Window_InteractionKeepUpgrades.AddUpgradeToActiveList(keepUpgrade.id)
                        else
                            keepUpgrade.time = 0
                            -- Call remove just in case it happens to be in the active list.
                            EA_Window_InteractionKeepUpgrades.RemoveUpgradeFromActiveList(keepUpgrade.id)
                        end
                    end
                    
                    EA_Window_InteractionKeepUpgrades.UpdateUpgradeValues(keepUpgrade)
                    break
                end
            end
        end
    end
end

-- OnSave: Called when the save button is pressed
function EA_Window_InteractionKeepUpgrades.OnSave()
    for _, keepUpgrade in pairs(EA_Window_InteractionKeepUpgrades.currentUpgradeData)
    do
        if (keepUpgrade.localTargetLevel ~= keepUpgrade.targetLevel) then
            if (keepUpgrade.localTargetLevel > keepUpgrade.currentLevel) then
            
                -- User wants to upgrade
                
                if (keepUpgrade.targetLevel < keepUpgrade.currentLevel) then
                    -- User is currently downgrading. We need to cancel the downgrade first.
                    CancelKeepUpgrade(keepUpgrade.id)
                end
                
                if (keepUpgrade.targetLevel <= keepUpgrade.currentLevel) then
                    -- We're starting a new upgrade or just canceled a downgrade, so we need to initialize the time
                    keepUpgrade.time = keepUpgrade.timeToMature[keepUpgrade.currentLevel+1]
                end
                
                EA_Window_InteractionKeepUpgrades.AddUpgradeToActiveList(keepUpgrade.id)
                PurchaseKeepUpgrade(keepUpgrade.id, keepUpgrade.localTargetLevel)
                
            elseif (keepUpgrade.localTargetLevel < keepUpgrade.currentLevel) then
            
                -- User wants to downgrade
                
                if (keepUpgrade.targetLevel > keepUpgrade.currentLevel) then
                    -- User is currently upgrading. We need to cancel the upgrade first.
                    CancelKeepUpgrade(keepUpgrade.id)
                end
                
                if (keepUpgrade.targetLevel >= keepUpgrade.currentLevel) then
                    -- We're starting a new downgrade or just canceled an upgrade, so we need to initialize the time
                    keepUpgrade.time = keepUpgrade.timeToMature[keepUpgrade.currentLevel]
                end
                
                EA_Window_InteractionKeepUpgrades.AddUpgradeToActiveList(keepUpgrade.id)
                PurchaseKeepUpgrade(keepUpgrade.id, keepUpgrade.localTargetLevel)
                
            elseif (keepUpgrade.localTargetLevel == keepUpgrade.currentLevel) then
            
                -- User wants to cancel the in-progress upgrade or downgrade
                CancelKeepUpgrade(keepUpgrade.id)
                keepUpgrade.time = 0
                EA_Window_InteractionKeepUpgrades.RemoveUpgradeFromActiveList(keepUpgrade.id)
                
            end
            
            keepUpgrade.targetLevel = keepUpgrade.localTargetLevel
        end
    end
    
    EA_Window_InteractionKeepUpgrades.numModifiedUpgrades = 0
    ButtonSetDisabledFlag( "EA_Window_InteractionKeepUpgradesSaveButton", true )
    ButtonSetDisabledFlag( "EA_Window_InteractionKeepUpgradesResetButton", true )
end

-- OnRankMouseOver: Called when the mouse is moved over the Keep Rank
function EA_Window_InteractionKeepUpgrades.OnRankMouseOver()
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, GetString(StringTables.Default.TOOLTIP_KEEP_RANK_TITLE) )
    Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
    Tooltips.SetTooltipText( 2, 1, GetString(StringTables.Default.TOOLTIP_KEEP_RANK_DETAILS) )
    Tooltips.SetTooltipColorDef( 2, 1, Tooltips.COLOR_BODY )
    Tooltips.Finalize()
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT )
end

-- OnUpgradeMouseOver: Called when the mouse is moved over a keep upgrade's name
function EA_Window_InteractionKeepUpgrades.OnUpgradeMouseOver()
    local upgradeId = WindowGetId(SystemData.ActiveWindow.name)
    
    local keepUpgrade = EA_Window_InteractionKeepUpgrades.currentUpgradeData[upgradeId]
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, GetKeepUpgradeName(keepUpgrade.id) )
    Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
    Tooltips.SetTooltipText( 2, 1, GetKeepUpgradeDesc(keepUpgrade.id) )
    Tooltips.SetTooltipColorDef( 2, 1, Tooltips.COLOR_BODY )
    if (keepUpgrade.totalLevel >= 1) then
        Tooltips.SetTooltipText( 3, 1, L"" )
        Tooltips.SetTooltipColorDef( 3, 1, Tooltips.COLOR_BODY )
        for upgradeLevel = 1, keepUpgrade.totalLevel
        do
            local costValue = MoneyFrame.FormatMoneyString(keepUpgrade.cost[upgradeLevel], true)
            local timeValue = keepUpgrade.timeToMature[upgradeLevel] / 60
            local guildRankValue = keepUpgrade.rankRequired[upgradeLevel]
            
            local tooltipText = L""
            if (guildRankValue > 0) then
                tooltipText = GetStringFormat(StringTables.Default.TOOLTIP_KEEP_UPGRADE_DETAILS_WITH_GUILD_RANK, { upgradeLevel, costValue, timeValue, guildRankValue } )
            else
                tooltipText = GetStringFormat(StringTables.Default.TOOLTIP_KEEP_UPGRADE_DETAILS, { upgradeLevel, costValue, timeValue } )
            end
            
            Tooltips.SetTooltipText( 3 + upgradeLevel, 1, tooltipText )
            Tooltips.SetTooltipColorDef( 3 + upgradeLevel, 1, Tooltips.COLOR_BODY )
        end
    end
    Tooltips.Finalize()
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT )
end

-- UpdatedGuildVault: Called when updated guild vault info comes from the server
function EA_Window_InteractionKeepUpgrades.UpdatedGuildVault(amount)
    if (WindowGetShowing( "EA_Window_InteractionKeepUpgrades" )) then
        MoneyFrame.FormatMoney ("EA_Window_InteractionKeepUpgradesGuildFundsMoney", amount, MoneyFrame.HIDE_EMPTY_WINDOWS_ABOVE_VALUE)
    end
end
