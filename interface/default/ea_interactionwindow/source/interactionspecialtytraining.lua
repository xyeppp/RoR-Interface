----------------------------------------------------------------
-- Local variables
----------------------------------------------------------------
EA_Window_InteractionSpecialtyTraining =
{

    TAB_SPECIALIZATION_1  = 1,
    TAB_SPECIALIZATION_2  = 2,
    TAB_SPECIALIZATION_3  = 3,
    NUM_TABS              = 3,

    currentTab            = 0,
    
    MAXIMUM_LINKED_ABILITIES = 9,

    Tabs = {},

    
    advanceData                 = nil,
    linkedAdvances              = {},
    pathAdvances                = {},
    
    initialSpecializationLevels  = { 0, 0, 0 },
    selectedSpecializationLevels = { 0, 0, 0 },
    selectedAdvances            = { {}, {}, {} },
    
    pathFrames       = {},
    abilityFrames    = {}
}

EA_Window_InteractionSpecialtyTraining.Tabs[ EA_Window_InteractionSpecialtyTraining.TAB_SPECIALIZATION_1 ]   = { name="EA_Window_InteractionSpecialtyTrainingTabsSpecialization1Tab", label=StringTables.Default.LABEL_SPECIALIZATION_TITLE, tooltip=StringTables.Default.TEXT_CAREER_SPECIALIZATION_ADVANCE_DESC, }
EA_Window_InteractionSpecialtyTraining.Tabs[ EA_Window_InteractionSpecialtyTraining.TAB_SPECIALIZATION_2 ]   = { name="EA_Window_InteractionSpecialtyTrainingTabsSpecialization2Tab", label=StringTables.Default.LABEL_SPECIALIZATION_TITLE, tooltip=StringTables.Default.TEXT_CAREER_SPECIALIZATION_ADVANCE_DESC, }
EA_Window_InteractionSpecialtyTraining.Tabs[ EA_Window_InteractionSpecialtyTraining.TAB_SPECIALIZATION_3 ]   = { name="EA_Window_InteractionSpecialtyTrainingTabsSpecialization3Tab", label=StringTables.Default.LABEL_SPECIALIZATION_TITLE, tooltip=StringTables.Default.TEXT_CAREER_SPECIALIZATION_ADVANCE_DESC, }


local careerImageNameLookUp = 
{
    [1] =   "EA_Mastery_Ironbreaker1_d1.dds",
    [2] =   "EA_Mastery_Ironbreaker2_d1.dds",
    [3] =   "EA_Mastery_Ironbreaker3_d1.dds",
    [4] =   "EA_Mastery_Slayer1_d1.dds",
    [5] =   "EA_Mastery_Slayer2_d1.dds",
    [6] =   "EA_Mastery_Slayer3_d1.dds",
    [7] =   "EA_Mastery_RunePriest1_d1.dds",
    [8] =   "EA_Mastery_RunePriest2_d1.dds",
    [9] =   "EA_Mastery_RunePriest3_d1.dds",
    [10] =  "EA_Mastery_Engineer1_d1.dds",
    [11] =  "EA_Mastery_Engineer2_d1.dds",
    [12] =  "EA_Mastery_Engineer3_d1.dds",
    [13] =  "EA_Mastery_BlackOrc1_d1.dds",
    [14] =  "EA_Mastery_BlackOrc2_d1.dds",
    [15] =  "EA_Mastery_BlackOrc3_d1.dds",
    [16] =  "EA_Mastery_Choppa1_d1.dds",
    [17] =  "EA_Mastery_Choppa2_d1.dds",
    [18] =  "EA_Mastery_Choppa3_d1.dds",
    [19] =  "EA_Mastery_Shaman1_d1.dds",
    [20] =  "EA_Mastery_Shaman2_d1.dds",
    [21] =  "EA_Mastery_Shaman3_d1.dds",
    [22] =  "EA_Mastery_SquigHerder1_d1.dds",
    [23] =  "EA_Mastery_SquigHerder2_d1.dds",
    [24] =  "EA_Mastery_SquigHerder3_d1.dds",
    [25] =  "EA_Mastery_WitchHunter1_d1.dds",
    [26] =  "EA_Mastery_WitchHunter2_d1.dds",
    [27] =  "EA_Mastery_WitchHunter3_d1.dds",
    [28] =  "EA_Mastery_Knight1_d1.dds",
    [29] =  "EA_Mastery_Knight2_d1.dds",
    [30] =  "EA_Mastery_Knight3_d1.dds",
    [31] =  "EA_Mastery_BrightWiz1_d1.dds",
    [32] =  "EA_Mastery_BrightWiz2_d1.dds",
    [33] =  "EA_Mastery_BrightWiz3_d1.dds",
    [34] =  "EA_Mastery_WarriorPriest1_d1.dds",
    [35] =  "EA_Mastery_WarriorPriest2_d1.dds",
    [36] =  "EA_Mastery_WarriorPriest3_d1.dds",
    [37] =  "EA_Mastery_Chosen1_d1.dds",
    [38] =  "EA_Mastery_Chosen2_d1.dds",
    [39] =  "EA_Mastery_Chosen3_d1.dds",
    [40] =  "EA_Mastery_Marauder1_d1.dds",
    [41] =  "EA_Mastery_Marauder2_d1.dds",
    [42] =  "EA_Mastery_Marauder3_d1.dds",
    [43] =  "EA_Mastery_Zealot1_d1.dds",
    [44] =  "EA_Mastery_Zealot2_d1.dds",
    [45] =  "EA_Mastery_Zealot3_d1.dds",
    [46] =  "EA_Mastery_Magus1_d1.dds",
    [47] =  "EA_Mastery_Magus2_d1.dds",
    [48] =  "EA_Mastery_Magus3_d1.dds",
    [49] =  "EA_Mastery_Swordmaster1_d1.dds",
    [50] =  "EA_Mastery_Swordmaster2_d1.dds",
    [51] =  "EA_Mastery_Swordmaster3_d1.dds",
    [52] =  "EA_Mastery_ShadowWarrior1_d1.dds",
    [53] =  "EA_Mastery_ShadowWarrior2_d1.dds",
    [54] =  "EA_Mastery_ShadowWarrior3_d1.dds",
    [55] =  "EA_Mastery_WhiteLion1_d1.dds",
    [56] =  "EA_Mastery_WhiteLion2_d1.dds",
    [57] =  "EA_Mastery_WhiteLion3_d1.dds",
    [58] =  "EA_Mastery_Archmage1_d1.dds",
    [59] =  "EA_Mastery_Archmage2_d1.dds",
    [60] =  "EA_Mastery_Archmage3_d1.dds",
    [61] =  "EA_Mastery_BlackGuard1_d1.dds",
    [62] =  "EA_Mastery_BlackGuard2_d1.dds",
    [63] =  "EA_Mastery_BlackGuard3_d1.dds",
    [64] =  "EA_Mastery_WitchElf1_d1.dds",
    [65] =  "EA_Mastery_WitchElf2_d1.dds",
    [66] =  "EA_Mastery_WitchElf3_d1.dds",
    [67] =  "EA_Mastery_Disciple1_d1.dds",
    [68] =  "EA_Mastery_Disciple2_d1.dds",
    [69] =  "EA_Mastery_Disciple3_d1.dds",
    [70] =  "EA_Mastery_Sorceress1_d1.dds",
    [71] =  "EA_Mastery_Sorceress2_d1.dds",
    [72] =  "EA_Mastery_Sorceress3_d1.dds"
}

local pathName = "EA_InteractionWindow/Textures/"

local function DumpSelection()

    DEBUG(L"SELECTED ABILITIES: " )
    for index = 1, EA_Window_InteractionSpecialtyTraining.NUM_TABS 
    do
        local text = L"    ["..index..L"] = "
        for id, data in pairs( EA_Window_InteractionSpecialtyTraining.selectedAdvances[index] )
        do
            text = text..id..L", "
        end
        DEBUG( text )
    end  
      
end

----------------------------------------------------------------
-- Standard Window Functions
----------------------------------------------------------------
function EA_Window_InteractionSpecialtyTraining.Initialize()

    -- register event handlers
    WindowRegisterEventHandler("EA_Window_InteractionSpecialtyTraining", SystemData.Events.PLAYER_CAREER_CATEGORY_UPDATED,  "EA_Window_InteractionSpecialtyTraining.Refresh")
    WindowRegisterEventHandler("EA_Window_InteractionSpecialtyTraining", SystemData.Events.PLAYER_MONEY_UPDATED,            "EA_Window_InteractionSpecialtyTraining.UpdatePlayerResources" )
    WindowRegisterEventHandler("EA_Window_InteractionSpecialtyTraining", SystemData.Events.PLAYER_ABILITIES_LIST_UPDATED,   "EA_Window_InteractionSpecialtyTraining.Refresh" )
    WindowRegisterEventHandler("EA_Window_InteractionSpecialtyTraining", SystemData.Events.PLAYER_SINGLE_ABILITY_UPDATED,   "EA_Window_InteractionSpecialtyTraining.Refresh" )
    WindowRegisterEventHandler("EA_Window_InteractionSpecialtyTraining", SystemData.Events.PLAYER_CAREER_LINE_UPDATED,      "EA_Window_InteractionSpecialtyTraining.OnCareerLineUpdated" )

    EA_Window_InteractionSpecialtyTraining.currentTab       = 0
    
    EA_Window_InteractionSpecialtyTraining.InitializeFrames()
    EA_Window_InteractionSpecialtyTraining.InitializeLabels()
    EA_Window_InteractionSpecialtyTraining.LoadAdvances()
    
end

function EA_Window_InteractionSpecialtyTraining.Shutdown()
    for index, frame in pairs(EA_Window_InteractionSpecialtyTraining.pathFrames)
    do
        frame:Destroy()
    end

    for index, frame in pairs(EA_Window_InteractionSpecialtyTraining.abilityFrames)
    do
        frame:Destroy()
    end
    EA_Window_InteractionSpecialtyTraining.abilityFrames = {}
end

function EA_Window_InteractionSpecialtyTraining.OnShown()
    WindowUtils.OnShown(EA_Window_InteractionSpecialtyTraining.Hide, WindowUtils.Cascade.MODE_AUTOMATIC)
end

function EA_Window_InteractionSpecialtyTraining.OnHidden()
    WindowUtils.RemoveFromOpenList("EA_Window_InteractionSpecialtyTraining")
    
    for index, frame in pairs(EA_Window_InteractionSpecialtyTraining.abilityFrames)
    do
        frame:Destroy()
    end
    EA_Window_InteractionSpecialtyTraining.abilityFrames = {}
    
    EA_Window_InteractionSpecialtyTraining.ClearSelection()    
end

function EA_Window_InteractionSpecialtyTraining.ToggleContextMenu()
end

function EA_Window_InteractionSpecialtyTraining.Show()
    WindowSetShowing( "EA_Window_InteractionSpecialtyTraining", true )
    
    EA_Window_InteractionSpecialtyTraining.currentTab = 0
    
    EA_Window_InteractionSpecialtyTraining.Refresh()
    EA_Window_InteractionSpecialtyTraining.ShowTab(1)
    
end

function EA_Window_InteractionSpecialtyTraining.Hide()
    WindowSetShowing( "EA_Window_InteractionSpecialtyTraining", false )
end

function EA_Window_InteractionSpecialtyTraining.ClearSelection()

    -- Clear the selections
    EA_Window_InteractionSpecialtyTraining.selectedSpecializationLevels = { 0, 0, 0 }
    EA_Window_InteractionSpecialtyTraining.selectedAdvances             = { {}, {}, {} }

end

function EA_Window_InteractionSpecialtyTraining.OnCareerLineUpdated()
    SetCareerMasteryImages( pathName..careerImageNameLookUp[GameData.Player.SPECIALIZATION_PATH_1],
                            pathName..careerImageNameLookUp[GameData.Player.SPECIALIZATION_PATH_2],
                            pathName..careerImageNameLookUp[GameData.Player.SPECIALIZATION_PATH_3] )
end

function EA_Window_InteractionSpecialtyTraining.Refresh()

    if (WindowGetShowing( "EA_Window_InteractionSpecialtyTraining" ) == false)
    then
        return
    end

    EA_Window_InteractionSpecialtyTraining.LoadAdvances()    
    EA_Window_InteractionSpecialtyTraining.RefreshPathTabs()    
    EA_Window_InteractionSpecialtyTraining.RefreshDisplayPane()
    
    -- Only update the Tab-Specific data when a tab is selected
    if( EA_Window_InteractionSpecialtyTraining.currentTab ~= 0 ) 
    then
        local oldTab = EA_Window_InteractionSpecialtyTraining.currentTab
        EA_Window_InteractionSpecialtyTraining.currentTab = 0
        EA_Window_InteractionSpecialtyTraining.ShowTab(oldTab)
        EA_Window_InteractionSpecialtyTraining.RefreshInteractivePane()
    end
   
   EA_Window_InteractionSpecialtyTraining.ClearSelection()
end

function EA_Window_InteractionSpecialtyTraining.RefreshInteractivePane()
    EA_Window_InteractionSpecialtyTraining.RefreshPathLevel()
    EA_Window_InteractionSpecialtyTraining.RefreshPathAbilities()
    EA_Window_InteractionSpecialtyTraining.SetPurchaseButtonStates()
end

function EA_Window_InteractionSpecialtyTraining.RefreshDisplayPane()
    EA_Window_InteractionSpecialtyTraining.UpdatePlayerResources()
end

function EA_Window_InteractionSpecialtyTraining.RefreshPathTabs()
    ButtonSetText("EA_Window_InteractionSpecialtyTrainingTabsSpecialization1Tab", GetStringFormat(StringTables.Default.LABEL_SPECIALIZATION_TITLE, { GetSpecializationPathName(GameData.Player.SPECIALIZATION_PATH_1) } ) )
    ButtonSetText("EA_Window_InteractionSpecialtyTrainingTabsSpecialization2Tab", GetStringFormat(StringTables.Default.LABEL_SPECIALIZATION_TITLE, { GetSpecializationPathName(GameData.Player.SPECIALIZATION_PATH_2) } ) )
    ButtonSetText("EA_Window_InteractionSpecialtyTrainingTabsSpecialization3Tab", GetStringFormat(StringTables.Default.LABEL_SPECIALIZATION_TITLE, { GetSpecializationPathName(GameData.Player.SPECIALIZATION_PATH_3) } ) )
end

function EA_Window_InteractionSpecialtyTraining.LoadAdvances()
    EA_Window_InteractionSpecialtyTraining.advanceData = GameData.Player.GetAdvanceData()
    
    -- Populate the current and initial advance levels
    for index, advanceData in pairs(EA_Window_InteractionSpecialtyTraining.advanceData)
    do
        if (advanceData.category == GameData.CareerCategory.SPECIALIZATION)
        then

            -- DEBUG(L"Spec "..advanceData.packageId..L" level "..advanceData.timesPurchased..L" found.")
            EA_Window_InteractionSpecialtyTraining.initialSpecializationLevels[advanceData.packageId] = advanceData.timesPurchased
        end
    end
    
    EA_Window_InteractionSpecialtyTraining.selectedSpecializationLevels = { 0, 0, 0 }
end

----------------------------------------------------------------
-- Money/resource/display initialization and updates
----------------------------------------------------------------
function EA_Window_InteractionSpecialtyTraining.UpdatePlayerResources()
    local pointsTotal     = GameData.Player.GetAdvancePointsAvailable()[GameData.CareerCategory.SPECIALIZATION]
    local pointsSpent     = EA_Window_InteractionSpecialtyTraining.GetSelectedAdvanceCount() + EA_Window_InteractionSpecialtyTraining.GetSelectedSpecLevelCount()
    local pointsRemaining = pointsTotal - pointsSpent
    local pointText       = GetStringFormatFromTable("TrainingStrings", StringTables.Training.LABEL_SPECIALIZATION_POINTS_LEFT, { L""..pointsRemaining } )

    LabelSetText("EA_Window_InteractionSpecialtyTrainingDisplayPaneMasteryPointPurse", pointText)
end

function EA_Window_InteractionSpecialtyTraining.InitializeLabels()

    LabelSetText("EA_Window_InteractionSpecialtyTrainingTitleBarText", GetString( StringTables.Default.TITLE_TRAINING ) )

    -- Path Tabs
    ButtonSetStayDownFlag("EA_Window_InteractionSpecialtyTrainingTabsSpecialization1Tab", true )
    ButtonSetStayDownFlag("EA_Window_InteractionSpecialtyTrainingTabsSpecialization2Tab", true )
    ButtonSetStayDownFlag("EA_Window_InteractionSpecialtyTrainingTabsSpecialization3Tab", true )

    -- Display pane text
    LabelSetText("EA_Window_InteractionSpecialtyTrainingDisplayPaneMasteryPointText",  GetStringFromTable("TrainingStrings", StringTables.Training.TEXT_MASTERY_POINT_USE ) )
    LabelSetText("EA_Window_InteractionSpecialtyTrainingDisplayPaneLinkedAbilityText", GetStringFromTable("TrainingStrings", StringTables.Training.TEXT_LINKED_ABILITY_EXPLANATION ) )

    -- Increment / decrement buttons
    ButtonSetText("EA_Window_InteractionSpecialtyTrainingInteractivePanePathIncrement", L"+" )
    ButtonSetText("EA_Window_InteractionSpecialtyTrainingInteractivePanePathDecrement", L"-" )

    -- Footer buttons
    ButtonSetText( "EA_Window_InteractionSpecialtyTrainingRespecializeButton", GetString( StringTables.Default.LABEL_PURCHASE_RESPECIALIZATION ) )
    ButtonSetText( "EA_Window_InteractionSpecialtyTrainingPurchaseButton",     GetStringFromTable("TrainingStrings", StringTables.Training.LABEL_PURCHASE_TRAINING ) )
    ButtonSetText( "EA_Window_InteractionSpecialtyTrainingCancelButton",       GetStringFromTable("TrainingStrings", StringTables.Training.LABEL_CANCEL_TRAINING ) )

    for index, frame in pairs(EA_Window_InteractionSpecialtyTraining.pathFrames)
    do
        frame:SetText(L""..index)
    end

end

function EA_Window_InteractionSpecialtyTraining.InitializeFrames()

    for frameNumber = 1, 15
    do
        EA_Window_InteractionSpecialtyTraining.pathFrames[frameNumber] = EA_Window_InteractionSpecialtyTrainingLevel:CreateFrameForExistingWindow("EA_Window_InteractionSpecialtyTrainingInteractivePaneSpecializationStep"..frameNumber)
    end

end

----------------------------------------------------------------
-- Tab Selection and Manipulation
----------------------------------------------------------------
function EA_Window_InteractionSpecialtyTraining.SelectTab()
    local tab = WindowGetId(SystemData.ActiveWindow.name)
    
    EA_Window_InteractionSpecialtyTraining.ShowTab( tab )
end

function EA_Window_InteractionSpecialtyTraining.OnMouseOverTab()
end

function EA_Window_InteractionSpecialtyTraining.ShowTab( pathIndex )
    if (pathIndex == EA_Window_InteractionSpecialtyTraining.currentTab)
    then
        -- DEBUG(L"  same as currently registered tab, doing nothing.")
        return
    end
    
    EA_Window_InteractionSpecialtyTraining.currentTab = pathIndex
    
    EA_Window_InteractionSpecialtyTraining.PopulateAdvanceTables()
    
    -- Set the path desription
    local specializationDescription = L""
    if (pathIndex == 1)
    then
        specializationDescription = GetSpecializationPathDescription( GameData.Player.SPECIALIZATION_PATH_1 )
        
    elseif (pathIndex == 2)
    then
        specializationDescription = GetSpecializationPathDescription( GameData.Player.SPECIALIZATION_PATH_2 )
    elseif (pathIndex == 3)
    then
        specializationDescription = GetSpecializationPathDescription( GameData.Player.SPECIALIZATION_PATH_3 )
    end
    LabelSetText("EA_Window_InteractionSpecialtyTrainingDisplayPanePathDescriptionText", specializationDescription)

    -- Set the mastery path background
    DynamicImageSetTexture( "EA_Window_InteractionSpecialtyTrainingPicture", "career_mastery_image"..pathIndex, 0, 0 )
    
    -- Unset the pressed flags of buttons that aren't this TabIndex
    for index, tab in ipairs(EA_Window_InteractionSpecialtyTraining.Tabs)
    do
        if (index ~= EA_Window_InteractionSpecialtyTraining.currentTab)
        then
            ButtonSetPressedFlag( tab.name, false )
        else
            ButtonSetPressedFlag( tab.name, true )
        end
    end
    
    -- Wipe out the dynamic layout frames
    for _, frame in pairs(EA_Window_InteractionSpecialtyTraining.abilityFrames)
    do
        frame:Destroy()
    end
    EA_Window_InteractionSpecialtyTraining.abilityFrames = {}

    EA_Window_InteractionSpecialtyTraining.PopulateLinkedAbilities()
    EA_Window_InteractionSpecialtyTraining.PopulatePathAbilities()
    EA_Window_InteractionSpecialtyTraining.RefreshInteractivePane()

end

function EA_Window_InteractionSpecialtyTraining.PopulateAdvanceTables()
    -- construct the list of linked advances
    EA_Window_InteractionSpecialtyTraining.linkedAdvances = {}
    EA_Window_InteractionSpecialtyTraining.pathAdvances   = {}
    
    for index, advanceData in pairs(EA_Window_InteractionSpecialtyTraining.advanceData)
    do
        if InteractionUtils.IsAbility(advanceData)
        then
            -- DEBUG(L" Populating linked abilities, checking spec "..advanceData.abilityInfo.specialization)
            if ( (advanceData.abilityInfo.specialization == EA_Window_InteractionSpecialtyTraining.currentTab) and
                 (InteractionUtils.GetDependencyChainLength(advanceData, EA_Window_InteractionSpecialtyTraining.advanceData) == 0) )
            then
                table.insert(EA_Window_InteractionSpecialtyTraining.linkedAdvances, advanceData)
            end
        end

        if (advanceData.category == GameData.CareerCategory.SPECIALIZATION)
        then
            -- Populate the path advances
            if (advanceData.dependencies ~= nil) and
               (advanceData.dependencies[EA_Window_InteractionSpecialtyTraining.currentTab] ~= nil)
            then
                table.insert(EA_Window_InteractionSpecialtyTraining.pathAdvances, advanceData)
            end
            
        end
    end
end

----------------------------------------------------------------
-- Dynamic layout and content
----------------------------------------------------------------
function EA_Window_InteractionSpecialtyTraining.PopulateLinkedAbilities()
    -- DEBUG(L"EA_Window_InteractionSpecialtyTraining.PopulateLinkedAbilities()")
    -- table.sort(EA_Window_InteractionSpecialtyTraining.linkedAdvances)
    
    local relativeIndex = 1
    for _, advanceData in pairs(EA_Window_InteractionSpecialtyTraining.linkedAdvances)
    do
        local linkedWindow = "EA_Window_InteractionSpecialtyTrainingDisplayPaneAbility"..relativeIndex
        local iconWindow   = linkedWindow.."Icon"
        local texture, x, y = GetIconData(advanceData.abilityInfo.iconNum)
        WindowSetShowing(linkedWindow, true)
        DynamicImageSetTexture(iconWindow, texture, x, y)
        
        if (advanceData.timesPurchased == 0)
        then
            local color = DefaultColor.RowColors.UNAVAILABLE
            WindowSetTintColor( iconWindow, color.r, color.g, color.b )
        else
            local color = DefaultColor.RowColors.SELECTED
            WindowSetTintColor( iconWindow, color.r, color.g, color.b )
        end
        
        relativeIndex = relativeIndex + 1
    end
    
    for currentIndex = relativeIndex, EA_Window_InteractionSpecialtyTraining.MAXIMUM_LINKED_ABILITIES
    do
        local emptyWindow = "EA_Window_InteractionSpecialtyTrainingDisplayPaneAbility"..currentIndex
        WindowSetShowing(emptyWindow, false)
    end
end

function EA_Window_InteractionSpecialtyTraining.PopulatePathAbilities()
    -- DEBUG(L"EA_Window_InteractionSpecialtyTraining.PopulatePathAbilities()")

    for index, advanceData in pairs(EA_Window_InteractionSpecialtyTraining.pathAdvances)
    do
        assert(advanceData.dependencies ~= nil)
        local requiredPathLevel = advanceData.dependencies[EA_Window_InteractionSpecialtyTraining.currentTab]
        local newFrame = nil

        if InteractionUtils.IsAction(advanceData)
        then
            newFrame = EA_Window_InteractionSpecialtyActionAbility:Create("EA_Window_InteractionSpecialtyTrainingPathActionAbility"..index,
                                                                          "EA_Window_InteractionSpecialtyTrainingInteractivePane",
                                                                          advanceData)
            -- DEBUG(L"  new frame spawned at level "..requiredPathLevel)
        elseif InteractionUtils.IsMorale(advanceData)
        then
            newFrame = EA_Window_InteractionSpecialtyMoraleAbility:Create("EA_Window_InteractionSpecialtyTrainingPathMoraleAbility"..index,
                                                                          "EA_Window_InteractionSpecialtyTrainingInteractivePane",
                                                                          advanceData)
        elseif InteractionUtils.IsTactic(advanceData)
        then
            newFrame = EA_Window_InteractionSpecialtyTacticAbility:Create("EA_Window_InteractionSpecialtyTrainingPathTacticAbility"..index,
                                                                          "EA_Window_InteractionSpecialtyTrainingInteractivePane",
                                                                          advanceData)
        end
        
        if (newFrame ~= nil)
        then
            table.insert( EA_Window_InteractionSpecialtyTraining.abilityFrames, newFrame)
            
            local anchorPoint = {Point="center", RelativeTo=EA_Window_InteractionSpecialtyTraining.pathFrames[requiredPathLevel]:GetName().."Empty", RelativePoint="center", XOffset=0, YOffset=0}
            newFrame:SetAnchor(anchorPoint)

            newFrame:SetIcon()
            newFrame:Show(true)
            
            -- If the Advance was previously selected, update the state.
            if( EA_Window_InteractionSpecialtyTraining.selectedAdvances[EA_Window_InteractionSpecialtyTraining.currentTab][ advanceData.packageId ] ~= nil )
            then
                newFrame:SetSelected()
            end
        end
    end

end

function EA_Window_InteractionSpecialtyTraining.RefreshPathAbilities()
    -- DEBUG(L"EA_Window_InteractionSpecialtyTraining.RefreshPathAbilities()")

    local pointsAvailable = GameData.Player.GetAdvancePointsAvailable()[GameData.CareerCategory.SPECIALIZATION]

    for _, frame in pairs(EA_Window_InteractionSpecialtyTraining.abilityFrames)
    do
        local advanceData = frame:GetAdvanceData()
        local requiredPathLevel = advanceData.dependencies[EA_Window_InteractionSpecialtyTraining.currentTab]

        local currentPathLevel = EA_Window_InteractionSpecialtyTraining.initialSpecializationLevels[EA_Window_InteractionSpecialtyTraining.currentTab] +  
                                 EA_Window_InteractionSpecialtyTraining.selectedSpecializationLevels[EA_Window_InteractionSpecialtyTraining.currentTab]
                
        -- DEBUG(L"  "..advanceData.advanceName..L" requires "..requiredPathLevel..L" <= ("..EA_Window_InteractionSpecialtyTraining.initialSpecializationLevels[EA_Window_InteractionSpecialtyTraining.currentTab]..L" + "..EA_Window_InteractionSpecialtyTraining.selectedSpecializationLevels[EA_Window_InteractionSpecialtyTraining.currentTab]..L")")
        if ( requiredPathLevel and (requiredPathLevel <= currentPathLevel) )
        then
            local pointsSpent     = EA_Window_InteractionSpecialtyTraining.GetSelectedAdvanceCount() + EA_Window_InteractionSpecialtyTraining.GetSelectedSpecLevelCount()
            
            if (advanceData.timesPurchased > 0)
            then
                frame:SetPurchased()
            elseif (frame:IsSelected() )
            then
                frame:SetSelected()
            elseif ( pointsSpent >= pointsAvailable )
            then
                frame:SetUnavailable()
            else
                frame:SetAvailable()
            end
        else
            frame:SetUnavailable()
        end
    end
            
end

function EA_Window_InteractionSpecialtyTraining.RefreshPathLevel()

    -- Update the pathometer
    for index, frame in pairs(EA_Window_InteractionSpecialtyTraining.pathFrames)
    do
        local currentPathLevel = EA_Window_InteractionSpecialtyTraining.initialSpecializationLevels[EA_Window_InteractionSpecialtyTraining.currentTab] +  
                                 EA_Window_InteractionSpecialtyTraining.selectedSpecializationLevels[EA_Window_InteractionSpecialtyTraining.currentTab]
                        
        if (index <= currentPathLevel)
        then
            frame:SetFull()
        else
            frame:SetEmpty()
        end
    end
end

function EA_Window_InteractionSpecialtyTraining.SetPurchaseButtonStates()
    local isDecrementLevelValid =  EA_Window_InteractionSpecialtyTraining.selectedSpecializationLevels[EA_Window_InteractionSpecialtyTraining.currentTab] > 0 

    ButtonSetDisabledFlag( "EA_Window_InteractionSpecialtyTrainingInteractivePanePathDecrement", not isDecrementLevelValid )
    
    local pointsSpent = EA_Window_InteractionSpecialtyTraining.GetSelectedAdvanceCount() + EA_Window_InteractionSpecialtyTraining.GetSelectedSpecLevelCount()

    local pathPackageData = nil
    for _, data in ipairs(EA_Window_InteractionSpecialtyTraining.advanceData)
    do
        -- if this is the package(s) we are looking for
        if ( (GameData.CareerCategory.SPECIALIZATION == data.category) and
             (1 == data.tier) and
             (EA_Window_InteractionSpecialtyTraining.currentTab == data.packageId) )
        then
            pathPackageData = data
            break
        end
    end

    local atSpecializationLimit = ( (EA_Window_InteractionSpecialtyTraining.initialSpecializationLevels[EA_Window_InteractionSpecialtyTraining.currentTab] +
                                     EA_Window_InteractionSpecialtyTraining.selectedSpecializationLevels[EA_Window_InteractionSpecialtyTraining.currentTab])
                                     >= pathPackageData.maximumPurchaseCount )
    
    local isIncrementLevelValid = pathPackageData and
                                  (pointsSpent < GameData.Player.GetAdvancePointsAvailable()[GameData.CareerCategory.SPECIALIZATION]) and
                                  not atSpecializationLimit
                                  
    ButtonSetDisabledFlag( "EA_Window_InteractionSpecialtyTrainingInteractivePanePathIncrement", not isIncrementLevelValid )
    
    local isTrainValid = (pointsSpent > 0)
    ButtonSetDisabledFlag( "EA_Window_InteractionSpecialtyTrainingPurchaseButton", not isTrainValid )
end

----------------------------------------------------------------
-- Event Handlers
----------------------------------------------------------------
function EA_Window_InteractionSpecialtyTraining.MouseOverLinkedAbility()

    local advanceIndex = WindowGetId(SystemData.MouseOverWindow.name)

    if (advanceIndex ~= 0)
    then
        local advanceData = EA_Window_InteractionSpecialtyTraining.linkedAdvances[advanceIndex]
        local abilityData = advanceData.abilityInfo

        if (abilityData ~= nil)
        then            
            -- Move package limit to ability level
            abilityData["minimumRank"] = advanceData.minimumRank
            
            -- DUMP_TABLE(abilityData)
            Tooltips.CreateAbilityTooltip( abilityData, SystemData.ActiveWindow.name )
        else
            -- This isn't an ability so look up the relevent package tooltip.
            Tooltips.CreateTextOnlyTooltip(SystemData.ActiveWindow.name)

            Tooltips.SetTooltipText( 1, 1, advanceData.advanceName )
            Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
            Tooltips.SetTooltipText( 2, 1, GetStringFromTable( "PackageDescriptions", advanceData.advanceID ) )
            Tooltips.Finalize()

            -- Tooltips.AnchorTooltip( EA_Window_InteractionTraining.PACKAGE_TOOLTIP_ANCHOR )
        end
    end

end

function EA_Window_InteractionSpecialtyTraining.MouseOverSpecializationAbility()
    local advanceData = FrameManager:GetMouseOverWindow():GetAdvanceData()
    local abilityData = advanceData.abilityInfo

    if (abilityData ~= nil)
    then            
        -- Move package limit to ability level
        abilityData["minimumRank"] = advanceData.minimumRank
        Tooltips.CreateAbilityTooltip( abilityData, SystemData.ActiveWindow.name )
    end
end

function EA_Window_InteractionSpecialtyTraining.SelectSpecializationAbility()
    
    if ( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) )
    then
        return
    end

    local selectedFrame = FrameManager:GetMouseOverWindow()

    local pointsTotal     = GameData.Player.GetAdvancePointsAvailable()[GameData.CareerCategory.SPECIALIZATION]
    local pointsSpent     = EA_Window_InteractionSpecialtyTraining.GetSelectedAdvanceCount() + EA_Window_InteractionSpecialtyTraining.GetSelectedSpecLevelCount()
    local pointsRemaining = pointsTotal - pointsSpent

    if (selectedFrame:IsSelected())
    then
        selectedFrame:SetAvailable()
    elseif (pointsRemaining > 0)
    then
        selectedFrame:SetSelected()
    end
    
    EA_Window_InteractionSpecialtyTraining.RefreshDisplayPane()
    EA_Window_InteractionSpecialtyTraining.RefreshInteractivePane()
end

function EA_Window_InteractionSpecialtyTraining.IncrementSpecialization()
    if (ButtonGetDisabledFlag("EA_Window_InteractionSpecialtyTrainingInteractivePanePathIncrement") == false)
    then
        EA_Window_InteractionSpecialtyTraining.selectedSpecializationLevels[EA_Window_InteractionSpecialtyTraining.currentTab]  
            = EA_Window_InteractionSpecialtyTraining.selectedSpecializationLevels[EA_Window_InteractionSpecialtyTraining.currentTab]  + 1
        
        EA_Window_InteractionSpecialtyTraining.RefreshInteractivePane()
        EA_Window_InteractionSpecialtyTraining.RefreshDisplayPane()
    end
end

function EA_Window_InteractionSpecialtyTraining.DecrementSpecialization()
    if (ButtonGetDisabledFlag("EA_Window_InteractionSpecialtyTrainingInteractivePanePathDecrement") == false)
    then
    
        EA_Window_InteractionSpecialtyTraining.selectedSpecializationLevels[EA_Window_InteractionSpecialtyTraining.currentTab]  
                    = EA_Window_InteractionSpecialtyTraining.selectedSpecializationLevels[EA_Window_InteractionSpecialtyTraining.currentTab]  - 1
        
        EA_Window_InteractionSpecialtyTraining.RefreshInteractivePane()
        EA_Window_InteractionSpecialtyTraining.RefreshDisplayPane()
    end
end

function EA_Window_InteractionSpecialtyTraining.PurchaseAdvances()
    if (ButtonGetDisabledFlag( "EA_Window_InteractionSpecialtyTrainingPurchaseButton" ))
    then
        return -- early return
    end
    
    -- Purchase for all tabs
    for tab = 1, EA_Window_InteractionSpecialtyTraining.NUM_TABS
    do
        -- Buy all path levels
        local levelsToPurchase = EA_Window_InteractionSpecialtyTraining.selectedSpecializationLevels[tab]
        local levelPurchaseCount = 0
        
        while (levelPurchaseCount < levelsToPurchase)
        do
            -- TODO: make tier not hardcoded
            BuyCareerPackage( 1, GameData.CareerCategory.SPECIALIZATION, tab )
            levelPurchaseCount = levelPurchaseCount + 1
        end
        
        -- Then buy all selected specialist abilities
        for packageId, advanceData in pairs(EA_Window_InteractionSpecialtyTraining.selectedAdvances[tab] )
        do            
           BuyCareerPackage( advanceData.tier, advanceData.category, packageId )
        end
        
    end
    
    -- Disable button until next update, so the player can't double click accidentally 
    ButtonSetDisabledFlag( "EA_Window_InteractionSpecialtyTrainingPurchaseButton", true )
end

function EA_Window_InteractionSpecialtyTraining.Respecialize()
    local respecCost = GameData.Player.GetSpecialtyRefundCost()
    local pointsSpent = GameData.Player.GetAdvancePointsSpent()[GameData.CareerCategory.SPECIALIZATION]
    
    if (pointsSpent == 0)
    then
        -- There are no points to refund. In this case this button acts as a simple Reset.
        EA_Window_InteractionSpecialtyTraining.ClearSelection()
        EA_Window_InteractionSpecialtyTraining.Refresh()
    elseif (respecCost > GameData.Player.money)
    then
        DialogManager.MakeOneButtonDialog( GetStringFormatFromTable("TrainingStrings", StringTables.Training.TEXT_RESPEC_NOT_ENOUGH_MONEY, { MoneyFrame.FormatMoneyString (respecCost) }),
                                           GetString( StringTables.Default.LABEL_OKAY ), nil )
    else
        DialogManager.MakeTwoButtonDialog( GetStringFormatFromTable("TrainingStrings", StringTables.Training.TEXT_RESPEC_CONFIRMATION, { MoneyFrame.FormatMoneyString (respecCost) }), 
                                           GetString(StringTables.Default.LABEL_YES), RefundSpecialtyPoints, 
                                           GetString(StringTables.Default.LABEL_NO) )
    end
end

----------------------------------------------------------------
-- Utility Functions
----------------------------------------------------------------
function EA_Window_InteractionSpecialtyTraining.GetSelectedAdvanceCount()
    local selectedAdvanceCount = 0
    

    -- Account for the selections aross all tabs
    for _, selectedAdvances in pairs( EA_Window_InteractionSpecialtyTraining.selectedAdvances ) 
    do
        for _, _ in pairs( selectedAdvances )
        do
            selectedAdvanceCount = selectedAdvanceCount + 1
        end
    end      
    
    return selectedAdvanceCount
end


function EA_Window_InteractionSpecialtyTraining.GetSelectedSpecLevelCount()

    local specLevelCount = 0    

    for _, numLevels in pairs(EA_Window_InteractionSpecialtyTraining.selectedSpecializationLevels)
    do
        specLevelCount = specLevelCount + numLevels
    end
    
    return specLevelCount

end


----------------------------------------------------------------
-- Specialization Mastery Path Level Frame
----------------------------------------------------------------
EA_Window_InteractionSpecialtyTrainingLevel = Frame:Subclass("EA_Templates_SpecializationStep")

function EA_Window_InteractionSpecialtyTrainingLevel:Create(windowName, parentWindow)
    -- Create should do nothing, this frame class only attaches to existing frames
    return nil
end

function EA_Window_InteractionSpecialtyTrainingLevel:Update(elapsedTime)
    
end

function EA_Window_InteractionSpecialtyTrainingLevel:SetFull()
    WindowSetShowing( self:GetName().."Full", true )
    
    local fullColor = DefaultColor.OWNED_SPECIALIZATION_LEVEL_TEXT
    self:SetTextColor(fullColor.r, fullColor.g, fullColor.b)
end

function EA_Window_InteractionSpecialtyTrainingLevel:SetEmpty()
    WindowSetShowing( self:GetName().."Full", false )
    
    local emptyColor = DefaultColor.WHITE
    self:SetTextColor(emptyColor.r, emptyColor.g, emptyColor.b)
end

function EA_Window_InteractionSpecialtyTrainingLevel:SetText(labelText)
    LabelSetText( self:GetName().."LevelText", labelText)
end

function EA_Window_InteractionSpecialtyTrainingLevel:SetTextColor(r, g, b)
    LabelSetTextColor(self:GetName().."LevelText", r, g, b)
end

----------------------------------------------------------------
-- Specialization Mastery Path Action Ability Frame
----------------------------------------------------------------
EA_Window_InteractionSpecialtyActionAbility = Frame:Subclass("EA_Templates_SpecializationActionAbility")

function EA_Window_InteractionSpecialtyActionAbility:Create(windowName, parentName, advanceData)
    local abilityFrame = self:CreateFromTemplate(windowName, parentName)

    if (abilityFrame ~= nil)
    then
        abilityFrame.m_AdvanceData = advanceData
        abilityFrame.m_IsSelected  = false
    end
    
    return abilityFrame
end

function EA_Window_InteractionSpecialtyActionAbility:SetIcon()
    local texture, x, y = GetIconData(self.m_AdvanceData.abilityInfo.iconNum)
    DynamicImageSetTexture(self:GetName().."Icon", texture, x, y)
end

function EA_Window_InteractionSpecialtyActionAbility:SetPurchased()
    ButtonSetDisabledFlag( self:GetName(), true )
    ButtonSetCheckButtonFlag( self:GetName(), false )
    ButtonSetStayDownFlag( self:GetName(), true )
    ButtonSetPressedFlag(  self:GetName(), true )

    local color = DefaultColor.RowColors.SELECTED
    WindowSetTintColor( self:GetName().."Icon", color.r, color.g, color.b )
    WindowSetShowing( self:GetName().."BackgroundRule", false)

    self.m_IsSelected = false
    EA_Window_InteractionSpecialtyTraining.selectedAdvances[EA_Window_InteractionSpecialtyTraining.currentTab][self.m_AdvanceData.packageId] = nil
end

function EA_Window_InteractionSpecialtyActionAbility:SetAvailable()
    ButtonSetDisabledFlag( self:GetName(), false )
    ButtonSetCheckButtonFlag( self:GetName(), true )
    ButtonSetStayDownFlag( self:GetName(), false )
    ButtonSetPressedFlag( self:GetName(), false )

    local color = DefaultColor.RowColors.AVAILABLE
    WindowSetTintColor( self:GetName().."Icon", color.r, color.g, color.b )
    WindowSetShowing( self:GetName().."BackgroundRule", true)
    DynamicImageSetTextureSlice( self:GetName().."BackgroundRule", "white-bar" )

    self.m_IsSelected = false
    EA_Window_InteractionSpecialtyTraining.selectedAdvances[EA_Window_InteractionSpecialtyTraining.currentTab][self.m_AdvanceData.packageId] = nil
end

function EA_Window_InteractionSpecialtyActionAbility:SetSelected()
    ButtonSetDisabledFlag( self:GetName(), false )
    ButtonSetCheckButtonFlag( self:GetName(), true )
    ButtonSetStayDownFlag( self:GetName(), false )
    ButtonSetPressedFlag( self:GetName(), true )

    local color = DefaultColor.RowColors.SELECTED
    WindowSetTintColor( self:GetName().."Icon", color.r, color.g, color.b )
    WindowSetShowing( self:GetName().."BackgroundRule", false)

    self.m_IsSelected = true
    EA_Window_InteractionSpecialtyTraining.selectedAdvances[EA_Window_InteractionSpecialtyTraining.currentTab][self.m_AdvanceData.packageId] = self.m_AdvanceData
end

function EA_Window_InteractionSpecialtyActionAbility:SetUnavailable()
    ButtonSetDisabledFlag( self:GetName(), true )
    ButtonSetPressedFlag( self:GetName(), false )
    
    local color = DefaultColor.RowColors.UNAVAILABLE
    WindowSetTintColor( self:GetName().."Icon", color.r, color.g, color.b )
    WindowSetShowing( self:GetName().."BackgroundRule", true)
    DynamicImageSetTextureSlice( self:GetName().."BackgroundRule", "grey-bar" )

    self.m_IsSelected = false
    EA_Window_InteractionSpecialtyTraining.selectedAdvances[EA_Window_InteractionSpecialtyTraining.currentTab][self.m_AdvanceData.packageId] = nil
end

function EA_Window_InteractionSpecialtyActionAbility:GetAdvanceData()
    return self.m_AdvanceData
end

function EA_Window_InteractionSpecialtyActionAbility:IsSelected()
    return self.m_IsSelected
end

----------------------------------------------------------------
-- Specialization Mastery Path Morale Ability Frame
----------------------------------------------------------------
EA_Window_InteractionSpecialtyMoraleAbility = Frame:Subclass("EA_Templates_SpecializationMoraleAbility")

function EA_Window_InteractionSpecialtyMoraleAbility:Create(windowName, parentName, advanceData)
    local abilityFrame = self:CreateFromTemplate(windowName, parentName)

    if (abilityFrame ~= nil)
    then
        abilityFrame.m_AdvanceData = advanceData
        abilityFrame.m_IsSelected  = false
    end
    
    return abilityFrame
end

function EA_Window_InteractionSpecialtyMoraleAbility:SetIcon()
    local texture, x, y = GetIconData(self.m_AdvanceData.abilityInfo.iconNum)
    CircleImageSetTexture(self:GetName().."Icon", texture, 32, 32)
end

function EA_Window_InteractionSpecialtyMoraleAbility:SetPurchased()
    ButtonSetDisabledFlag( self:GetName(), true )
    ButtonSetCheckButtonFlag( self:GetName(), false )
    ButtonSetStayDownFlag( self:GetName(), true )
    ButtonSetPressedFlag(  self:GetName(), true )
    
    local color = DefaultColor.RowColors.SELECTED
    WindowSetTintColor( self:GetName().."Icon", color.r, color.g, color.b )
    WindowSetShowing( self:GetName().."BackgroundRule", false)

    self.m_IsSelected = false
    EA_Window_InteractionSpecialtyTraining.selectedAdvances[EA_Window_InteractionSpecialtyTraining.currentTab][self.m_AdvanceData.packageId] = nil
end

function EA_Window_InteractionSpecialtyMoraleAbility:SetSelected()
    ButtonSetDisabledFlag( self:GetName(), false )
    ButtonSetCheckButtonFlag( self:GetName(), true )
    ButtonSetStayDownFlag( self:GetName(), false )
    ButtonSetPressedFlag( self:GetName(), true )

    local color = DefaultColor.RowColors.SELECTED
    WindowSetTintColor( self:GetName().."Icon", color.r, color.g, color.b )
    WindowSetShowing( self:GetName().."BackgroundRule", false)

    self.m_IsSelected = true    
    EA_Window_InteractionSpecialtyTraining.selectedAdvances[EA_Window_InteractionSpecialtyTraining.currentTab][self.m_AdvanceData.packageId] = self.m_AdvanceData
end

function EA_Window_InteractionSpecialtyMoraleAbility:SetAvailable()
    ButtonSetDisabledFlag( self:GetName(), false )
    ButtonSetCheckButtonFlag( self:GetName(), true )
    ButtonSetStayDownFlag( self:GetName(), false )
    ButtonSetPressedFlag( self:GetName(), false )

    local color = DefaultColor.RowColors.AVAILABLE
    WindowSetTintColor( self:GetName().."Icon", color.r, color.g, color.b )
    WindowSetShowing( self:GetName().."BackgroundRule", true)
    DynamicImageSetTextureSlice( self:GetName().."BackgroundRule", "white-bar" )

    self.m_IsSelected = false    
    EA_Window_InteractionSpecialtyTraining.selectedAdvances[EA_Window_InteractionSpecialtyTraining.currentTab][self.m_AdvanceData.packageId] = nil
end

function EA_Window_InteractionSpecialtyMoraleAbility:SetUnavailable()
    ButtonSetDisabledFlag( self:GetName(), true )
    ButtonSetPressedFlag( self:GetName(), false )

    local color = DefaultColor.RowColors.UNAVAILABLE
    WindowSetTintColor( self:GetName().."Icon", color.r, color.g, color.b )
    WindowSetShowing( self:GetName().."BackgroundRule", true)
    DynamicImageSetTextureSlice( self:GetName().."BackgroundRule", "grey-bar" )
    
    self.m_IsSelected = false
    EA_Window_InteractionSpecialtyTraining.selectedAdvances[EA_Window_InteractionSpecialtyTraining.currentTab][self.m_AdvanceData.packageId] = nil
end

function EA_Window_InteractionSpecialtyMoraleAbility:GetAdvanceData()
    return self.m_AdvanceData
end

function EA_Window_InteractionSpecialtyMoraleAbility:IsSelected()
    return self.m_IsSelected
end

----------------------------------------------------------------
-- Specialization Mastery Path Tactic Ability Frame
----------------------------------------------------------------
EA_Window_InteractionSpecialtyTacticAbility = Frame:Subclass("EA_Templates_SpecializationTacticAbility")

function EA_Window_InteractionSpecialtyTacticAbility:Create(windowName, parentName, advanceData)
    local abilityFrame = self:CreateFromTemplate(windowName, parentName)

    if (abilityFrame ~= nil)
    then
        abilityFrame.m_AdvanceData = advanceData
        abilityFrame.m_IsSelected  = false
    end
    
    return abilityFrame
end

function EA_Window_InteractionSpecialtyTacticAbility:SetPurchased()
    ButtonSetDisabledFlag( self:GetName(), true )
    ButtonSetCheckButtonFlag( self:GetName(), false )
    ButtonSetStayDownFlag( self:GetName(), true )
    ButtonSetPressedFlag(  self:GetName(), true )

    local color = DefaultColor.RowColors.SELECTED
    WindowSetTintColor( self:GetName().."Icon", color.r, color.g, color.b )
    WindowSetShowing( self:GetName().."BackgroundRule", false)
    
    self.m_IsSelected = false
    EA_Window_InteractionSpecialtyTraining.selectedAdvances[EA_Window_InteractionSpecialtyTraining.currentTab][self.m_AdvanceData.packageId] = nil
end

function EA_Window_InteractionSpecialtyTacticAbility:SetAvailable()
    ButtonSetDisabledFlag( self:GetName(), false )
    ButtonSetCheckButtonFlag( self:GetName(), true )
    ButtonSetStayDownFlag( self:GetName(), false )
    ButtonSetPressedFlag( self:GetName(), false )

    local color = DefaultColor.RowColors.AVAILABLE
    WindowSetTintColor( self:GetName().."Icon", color.r, color.g, color.b )
    WindowSetShowing( self:GetName().."BackgroundRule", true)
    DynamicImageSetTextureSlice( self:GetName().."BackgroundRule", "white-bar" )

    self.m_IsSelected = false
    EA_Window_InteractionSpecialtyTraining.selectedAdvances[EA_Window_InteractionSpecialtyTraining.currentTab][self.m_AdvanceData.packageId] = nil
end

function EA_Window_InteractionSpecialtyTacticAbility:SetSelected()
    ButtonSetDisabledFlag( self:GetName(), false )
    ButtonSetCheckButtonFlag( self:GetName(), true )
    ButtonSetStayDownFlag( self:GetName(), false )
    ButtonSetPressedFlag( self:GetName(), true )

    local color = DefaultColor.RowColors.SELECTED
    WindowSetTintColor( self:GetName().."Icon", color.r, color.g, color.b )
    WindowSetShowing( self:GetName().."BackgroundRule", false)
    
    self.m_IsSelected = true
    EA_Window_InteractionSpecialtyTraining.selectedAdvances[EA_Window_InteractionSpecialtyTraining.currentTab][self.m_AdvanceData.packageId] = self.m_AdvanceData
  end

function EA_Window_InteractionSpecialtyTacticAbility:SetUnavailable()
    ButtonSetDisabledFlag( self:GetName(), true )
    ButtonSetPressedFlag( self:GetName(), false )
    
    local color = DefaultColor.RowColors.UNAVAILABLE
    WindowSetTintColor( self:GetName().."Icon", color.r, color.g, color.b )
    WindowSetShowing( self:GetName().."BackgroundRule", true)
    DynamicImageSetTextureSlice( self:GetName().."BackgroundRule", "grey-bar" )
    
    self.m_IsSelected = false
    EA_Window_InteractionSpecialtyTraining.selectedAdvances[EA_Window_InteractionSpecialtyTraining.currentTab][self.m_AdvanceData.packageId] = nil
end

function EA_Window_InteractionSpecialtyTacticAbility:SetIcon()
    local texture, x, y = GetIconData(self.m_AdvanceData.abilityInfo.iconNum)
    DynamicImageSetTexture(self:GetName().."Icon", texture, x, y)
end

function EA_Window_InteractionSpecialtyTacticAbility:GetAdvanceData()
    return self.m_AdvanceData
end

function EA_Window_InteractionSpecialtyTacticAbility:IsSelected()
    return self.m_IsSelected
end
