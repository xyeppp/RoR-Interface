----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_CityTracker = {}

EA_Window_CityTracker.EMPTY_SIZE = { x=600, y=200 } -- Used to provide a size guide for the layout editor.

EA_Window_CityTracker.NUM_OBJECTIVES = 2
EA_Window_CityTracker.NUM_QUESTS = 2
EA_Window_CityTracker.NUM_CONDITION_COUNTERS = 5

EA_Window_CityTracker.WIDTH = 600
EA_Window_CityTracker.CONDITION_NAME_WIDTH = 530
EA_Window_CityTracker.CAPTURE_BAR_HEIGHT   = 50

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

local CompleteCounterColor      = DefaultColor.TEAL
local IncompleteCounterColor    = DefaultColor.WHITE
local CompleteQuestTitleColor   = CompleteCounterColor 
local IncompleteQuestTitleColor = IncompleteCounterColor

----------------------------------------------------------------
-- Local functions
----------------------------------------------------------------
local function CheckObjectiveOutOfRange(index)
    if ( ( index < 1 ) or ( index > EA_Window_CityTracker.NUM_OBJECTIVES ) )
    then
        --ERROR(L"Active objective #"..index..L" updated, the City Tracker only supports "..EA_Window_CityTracker.NUM_OBJECTIVES..L" objectives with "..EA_Window_CityTracker.NUM_QUESTS..L" quests")
        return true
    end
    return false
end

----------------------------------------------------------------
-- EA_Window_CityTracker Functions
----------------------------------------------------------------
-- OnInitialize Handler
function EA_Window_CityTracker.Initialize()

    LayoutEditor.RegisterWindow( "EA_Window_CityTracker",
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_CITY_TRACKER_WINDOW_NAME ),
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_CITY_TRACKER_WINDOW_DESC ),
                                false, false,
                                true, nil,
                                { "topleft", "top", "topright" } )
                                

    WindowRegisterEventHandler( "EA_Window_CityTracker", SystemData.Events.PUBLIC_QUEST_ADDED,   "EA_Window_CityTracker.OnQuestAdded")
    WindowRegisterEventHandler( "EA_Window_CityTracker", SystemData.Events.PUBLIC_QUEST_UPDATED, "EA_Window_CityTracker.OnQuestUpdated")
    WindowRegisterEventHandler( "EA_Window_CityTracker", SystemData.Events.PUBLIC_QUEST_REMOVED, "EA_Window_CityTracker.OnQuestRemoved")
    WindowRegisterEventHandler( "EA_Window_CityTracker", SystemData.Events.PUBLIC_QUEST_CONDITION_UPDATED, "EA_Window_CityTracker.OnQuestConditionUpdated")
    WindowRegisterEventHandler( "EA_Window_CityTracker", SystemData.Events.PUBLIC_QUEST_COMPLETED, "EA_Window_CityTracker.OnQuestCompleted")
    WindowRegisterEventHandler( "EA_Window_CityTracker", SystemData.Events.PUBLIC_QUEST_FAILED, "EA_Window_CityTracker.OnQuestFailed")
    WindowRegisterEventHandler( "EA_Window_CityTracker", SystemData.Events.PUBLIC_QUEST_RESETTING, "EA_Window_CityTracker.OnQuestResetting")
    WindowRegisterEventHandler( "EA_Window_CityTracker", SystemData.Events.PUBLIC_QUEST_OPTOUT, "EA_Window_CityTracker.OnQuestOptOut")
    WindowRegisterEventHandler( "EA_Window_CityTracker", SystemData.Events.PUBLIC_QUEST_FORCEDOUT, "EA_Window_CityTracker.OnQuestForcedOut")
    
    WindowRegisterEventHandler( "EA_Window_CityTracker", SystemData.Events.CITY_SCENARIO_BEGIN,          "EA_Window_CityTracker.UpdateStatus")
    WindowRegisterEventHandler( "EA_Window_CityTracker", SystemData.Events.CITY_SCENARIO_UPDATE_STATUS,  "EA_Window_CityTracker.UpdateStatus")
    WindowRegisterEventHandler( "EA_Window_CityTracker", SystemData.Events.CITY_SCENARIO_END,            "EA_Window_CityTracker.UpdateStatus")

    WindowRegisterEventHandler( "EA_Window_CityTracker", SystemData.Events.LOADING_END,                  "EA_Window_CityTracker.UpdateStatus" )
    WindowRegisterEventHandler( "EA_Window_CityTracker", SystemData.Events.INTERFACE_RELOADED,           "EA_Window_CityTracker.UpdateStatus" )
    WindowRegisterEventHandler( "EA_Window_CityTracker", SystemData.Events.PLAYER_ZONE_CHANGED,          "EA_Window_CityTracker.UpdateStatus" )
    
    LabelSetText( "EA_Window_CityTrackerOverviewStatus", GetStringFromTable("RvRCityStrings", StringTables.RvRCity.CITY_TRACKER_HEADING ) )
    
    -- Initialize the Opt Out Options Context Menu
    TrackerUtils.CreateOptOutContextMenuItems( "EA_Window_CityTracker" )  
    
    EA_Window_CityTracker.UpdateFullList()    
    EA_Window_CityTracker.UpdateStatus()
end

function EA_Window_CityTracker.InitializeLayout()
    EA_Window_CityTracker.UpdateMainWindowSize()
end

-- OnUpdate Handler
function EA_Window_CityTracker.Update( timePassed )
    -- Update the timers
    EA_Window_CityTracker.UpdateQuestTimer()
end

-- OnShutdown Handler
function EA_Window_CityTracker.Shutdown()

end

----------------------------------------------------------------
-- Opt Out Options
----------------------------------------------------------------

function EA_Window_CityTracker.OnLButtonUpOptOut()
    if( SystemData.ActiveWindow.name == nil or SystemData.ActiveWindow.name == "" ) then
        return
    end
    
    if(ButtonSetDisabledFlag(SystemData.ActiveWindow.name) == true)
    then
        return
    end
    
    -- Get the index number of the parent button so that we tag the
    -- context menu items with the appropriate objective id
    local index = WindowGetId( SystemData.ActiveWindow.name )

    if (CheckObjectiveOutOfRange(index))
    then
        return
    end    
            
    EA_Window_ContextMenu.CreateContextMenu( SystemData.ActiveWindow.name ) 
    
    -- None
    ButtonSetPressedFlag("EA_Window_CityTrackerOptOutNoneCheckBox", TrackerUtils.ShouldOptOutOptionBeChecked(index, TrackerUtils.OPT_OUT_OPTION_NONE))
    EA_Window_ContextMenu.AddUserDefinedMenuItem("EA_Window_CityTrackerOptOutNone")
    
    -- All (Loot and Gold Bags)
    ButtonSetPressedFlag("EA_Window_CityTrackerOptOutAllCheckBox", TrackerUtils.ShouldOptOutOptionBeChecked(index, TrackerUtils.OPT_OUT_OPTION_ALL))
    EA_Window_ContextMenu.AddUserDefinedMenuItem("EA_Window_CityTrackerOptOutAll")
    
    -- Gold Bags Only
    ButtonSetPressedFlag("EA_Window_CityTrackerOptOutGoldCheckBox", TrackerUtils.ShouldOptOutOptionBeChecked(index, TrackerUtils.OPT_OUT_OPTION_GOLD))
    EA_Window_ContextMenu.AddUserDefinedMenuItem("EA_Window_CityTrackerOptOutGold")
    
    EA_Window_ContextMenu.Finalize()
    
    WindowSetId("EA_Window_CityTrackerOptOutNone", index)
    WindowSetId("EA_Window_CityTrackerOptOutAll", index)
    WindowSetId("EA_Window_CityTrackerOptOutGold", index)
end

function EA_Window_CityTracker.ToggleOptOutOptionNone()    

    local index = WindowGetId( SystemData.ActiveWindow.name )
    if (CheckObjectiveOutOfRange(index))
    then
        return
    end    
    
    TrackerUtils.SetOptOutOption( SystemData.ActiveWindow.name, index, TrackerUtils.OPT_OUT_OPTION_NONE )    
end

function EA_Window_CityTracker.ToggleOptOutOptionAll()     

    local index = WindowGetId( SystemData.ActiveWindow.name )
    if (CheckObjectiveOutOfRange(index))
    then
        return
    end    
    
    TrackerUtils.SetOptOutOption( SystemData.ActiveWindow.name, index, TrackerUtils.OPT_OUT_OPTION_ALL )    
end

function EA_Window_CityTracker.ToggleOptOutOptionGold()   

    local index = WindowGetId( SystemData.ActiveWindow.name )
    if (CheckObjectiveOutOfRange(index))
    then
        return
    end    
      
    TrackerUtils.SetOptOutOption( SystemData.ActiveWindow.name, index, TrackerUtils.OPT_OUT_OPTION_GOLD )    
end

function EA_Window_CityTracker.OnQuestOptOut(index, optOut)
   
    if (CheckObjectiveOutOfRange(index))
    then
        return
    end

    DataUtils.activeObjectivesData[index].optedOutForLoot = optOut
end

function EA_Window_CityTracker.OnQuestForcedOut(index, forcedOut)

    if (CheckObjectiveOutOfRange(index))
    then
        return
    end
    
    ButtonSetDisabledFlag( "EA_Window_CityTrackerObjective"..index.."OptOutButton", forcedOut )

    DataUtils.activeObjectivesData[index].forcedOutForLoot = forcedOut
end

----------------------------------------------------------------
-- Quests
----------------------------------------------------------------
function EA_Window_CityTracker.OnQuestAdded()
    DataUtils.activeObjectivesData = GetActiveObjectivesData()
    local index = GameData.ActiveObjectives.updatedObjectiveIndex
    
    if (CheckObjectiveOutOfRange(index))
    then
        return
    end
    
    -- Update the Window to Include the new objective       
    EA_Window_CityTracker.UpdateTracker( index )
    EA_Window_CityTracker.UpdateQuestVisibility()
    
    -- Sound
    Sound.Play( Sound.PUBLIC_QUEST_ADDED )
    
end

function EA_Window_CityTracker.OnQuestResetting()
    DataUtils.activeObjectivesData = GetActiveObjectivesData()
end

function EA_Window_CityTracker.OnQuestUpdated()
    DataUtils.activeObjectivesData = GetActiveObjectivesData()

    local index = GameData.ActiveObjectives.updatedObjectiveIndex
    
    if (CheckObjectiveOutOfRange(index))
    then
        return
    end

    -- Update the Window to Include the new objective       
    EA_Window_CityTracker.UpdateTracker( index )
    EA_Window_CityTracker.UpdateMainWindowSize()
end


function EA_Window_CityTracker.OnQuestRemoved()
    DataUtils.activeObjectivesData = GetActiveObjectivesData()
    
    local index = GameData.ActiveObjectives.updatedObjectiveIndex
    
    if (CheckObjectiveOutOfRange(index))
    then
        return
    end
    
    -- Update the windows
    for objective = index, EA_Window_CityTracker.NUM_OBJECTIVES
    do
        EA_Window_CityTracker.UpdateTracker( objective )
    end
    
    EA_Window_CityTracker.UpdateQuestVisibility()
    
end

function EA_Window_CityTracker.OnQuestCompleted()
    DataUtils.activeObjectivesData = GetActiveObjectivesData()
    -- Sound
    Sound.Play( Sound.PUBLIC_QUEST_COMPLETED )
end

function EA_Window_CityTracker.OnQuestFailed()
    DataUtils.activeObjectivesData = GetActiveObjectivesData()
    -- Sound
    Sound.Play( Sound.PUBLIC_QUEST_FAILED )
end

function EA_Window_CityTracker.OnQuestConditionUpdated()

    -- DEBUG(L" **EA_Window_CityTracker.OnQuestConditionUpdated" )
    DataUtils.activeObjectivesData = GetActiveObjectivesData()
    
    local objective  = GameData.ActiveObjectives.updatedObjectiveIndex
    local questIndex = GameData.ActiveObjectives.updatedQuestIndex
    local condition  = GameData.ActiveObjectives.updatedQuestConditionIndex
    
    if (CheckObjectiveOutOfRange(objective))
    then
        return
    end

    local questData = DataUtils.activeObjectivesData[objective].Quest[questIndex]
    
    -- Update only the Condtion Counters
    local questWindowString = "EA_Window_CityTrackerObjective"..objective.."Quest"..questIndex
    
    for index, data in pairs(questData.conditions)
    do
        local conditionName = data.name
        local curCounter    = data.curCounter
        local maxCounter    = data.maxCounter
                    
        local counterLabel = questWindowString.."DataCondition"..index.."Counter"
        local counterName  = questWindowString.."DataCondition"..index.."Name"
        local typeImage    = questWindowString.."DataCondition"..index.."Type"

        -- Only show the conditions if conditionName is not empty
        if( conditionName ~= L"" )
        then
                      
            if( maxCounter > 0 )
            then
                LabelSetText( counterLabel, L""..curCounter..L"/"..maxCounter )

                if( curCounter == maxCounter)
                then
                    LabelSetTextColor(counterLabel, CompleteCounterColor.r, CompleteCounterColor.g, CompleteCounterColor.b )
                    LabelSetTextColor(counterName,  CompleteCounterColor.r, CompleteCounterColor.g, CompleteCounterColor.b )
                else
                    LabelSetTextColor(counterLabel, IncompleteCounterColor.r, IncompleteCounterColor.g, IncompleteCounterColor.b)
                    LabelSetTextColor(counterName,  IncompleteCounterColor.r, IncompleteCounterColor.g, IncompleteCounterColor.b)
                end         
                
                WindowSetShowing( counterLabel, true )
                WindowSetShowing( typeImage, true )
                    
            else
                WindowSetShowing( counterLabel, false )
                WindowSetShowing( typeImage, false )
            end
                
        end   
    end
    
end

function EA_Window_CityTracker.UpdateQuestTimer()
    for objectiveIndex = 1, EA_Window_CityTracker.NUM_OBJECTIVES
    do
        for questIndex = 1, EA_Window_CityTracker.NUM_QUESTS
        do
            local questWindowString = "EA_Window_CityTrackerObjective"..objectiveIndex.."Quest"..questIndex
            local objectiveData = DataUtils.activeObjectivesData[objectiveIndex]
            
            local questData = nil
            if (objectiveData ~= nil)
            then
                questData = objectiveData.Quest[questIndex]
            end
            
            if ((questData ~= nil) and (questData.timerState ~= GameData.PQTimerState.NONE))
            then
                local timeLeft = DataUtils.GetPQTimerRemaining( questData.timerState, questData.timerValue )
                local text = TimeUtils.FormatTimeCondensedTruncate( timeLeft )
                LabelSetText( questWindowString.."TimerValue", text )
                WindowSetShowing( questWindowString.."ClockImage", true )
            else            
                LabelSetText( questWindowString.."TimerValue", L"" )      
                WindowSetShowing( questWindowString.."ClockImage", false )
            end
       end
    end
end

-- This is only called on initialization to populate the window without any state changing animations
function EA_Window_CityTracker.UpdateFullList()

    DataUtils.activeObjectivesData = GetActiveObjectivesData()
    
    for objectiveIndex = 1, EA_Window_CityTracker.NUM_OBJECTIVES
    do
        local isObjectiveValid = false
        local objectiveWindowString = "EA_Window_CityTrackerObjective"..objectiveIndex
        local objectiveData = DataUtils.activeObjectivesData[objectiveIndex]
        
        if ( objectiveData ~= nil )
        then
            for questIndex = 1, EA_Window_CityTracker.NUM_QUESTS
            do
                local questData = objectiveData.Quest[questIndex]
                local isQuestValid = (questData ~= nil) and (questData.name ~= nil) and (questData.name ~= L"")
    
                WindowSetShowing( objectiveWindowString.."Quest"..questIndex, isQuestValid )
                isObjectiveValid = isObjectiveValid or isQuestValid
            end
        end
        
        if ( isObjectiveValid )
        then
            WindowSetShowing( objectiveWindowString, true )
            EA_Window_CityTracker.UpdateTracker( objectiveIndex )
        else
            WindowSetShowing( objectiveWindowString, false )
        end
    end
    
    EA_Window_CityTracker.UpdateMainWindowSize()
end

function EA_Window_CityTracker.UpdateQuestVisibility()    
    local numActiveObjectives = #DataUtils.activeObjectivesData
    if ( ( numActiveObjectives == 0) or 
         ( (PQData.currentState ~= PQData.STATE_CLEAR) and
         ( GameData.PQData.id == DataUtils.activeObjectivesData[GameData.ActiveObjectives.updatedObjectiveIndex].id )) )
    then
        WindowSetShowing("EA_Window_CityTrackerObjective1", false)
        WindowSetShowing("EA_Window_CityTrackerObjective2", false)
    else
        if (numActiveObjectives > 2)
        then
            --ERROR(L""..numActiveObjectives..L" objectives detected, City Tracker will only display the first two.")
        end
        
        WindowSetShowing("EA_Window_CityTrackerObjective1", true)

        if (numActiveObjectives > 1)
        then
            WindowSetShowing("EA_Window_CityTrackerObjective2", true)
        end
    end
    
    EA_Window_CityTracker.UpdateMainWindowSize()
end

function EA_Window_CityTracker.UpdateMainWindowSize()

    local height = 0
    local overviewHeight = 0
    
    if WindowGetShowing("EA_Window_CityTracker")
    then
        if WindowGetShowing("EA_Window_CityTrackerOverview")
        then
        
            local _, headingY = LabelGetTextDimensions("EA_Window_CityTrackerOverviewStatus")
            overviewHeight = overviewHeight + headingY + 10 -- 10 is the anchor offset from the top of the window to status

            local _, descriptionY = LabelGetTextDimensions("EA_Window_CityTrackerOverviewDescription")
            overviewHeight = overviewHeight + descriptionY + 10 -- 10 is the anchor offset from the status to the description

            -- Add a bit more empty space at the bottom of the sub window            
            overviewHeight = overviewHeight + 10
            
            WindowSetDimensions("EA_Window_CityTrackerOverview", EA_Window_CityTracker.WIDTH, overviewHeight)
        end
    
        height = height + 5 -- anchor offset between Overview and Main
                
        for objective = 1, EA_Window_CityTracker.NUM_OBJECTIVES
        do
            local objectiveWindowName = "EA_Window_CityTrackerObjective"..objective
            local objectiveWindowHeight = 0
            
            if WindowGetShowing(objectiveWindowName)
            then
                -- add the anchor offset between objectives
                if( objective > 1 )
                then
                    height = height + 5 -- anchor offset between Objective(N) and Objective(N+1)
                end
                
                -- Quests    
                for questIndex = 1, EA_Window_CityTracker.NUM_QUESTS
                do
                    -- Only update the window when it actually contains data
                    local questWindowHeight = 0
                    local questWindowName = objectiveWindowName.."Quest"..questIndex
                    if( WindowGetShowing( questWindowName ) == true )
                    then
                        local _, questLabelY   = LabelGetTextDimensions( questWindowName.."Label" )
                        local conditionsHeight = EA_Window_CityTracker.UpdateConditionsSize( questWindowName.."Data" )
                        
                        questWindowHeight = questLabelY + conditionsHeight + 1 -- 1 is the anchor offset between the quest label and quest conditions
                                                                               -- on a EA_Window_CityTrackerQuestCluster

                        WindowSetDimensions( questWindowName.."Data", EA_Window_CityTracker.WIDTH, conditionsHeight  )
                        WindowSetDimensions( questWindowName,         EA_Window_CityTracker.WIDTH, questWindowHeight ) 
                    else
                        WindowSetDimensions( questWindowName.."Data", EA_Window_CityTracker.WIDTH, 0 ) 
                        WindowSetDimensions( questWindowName,         EA_Window_CityTracker.WIDTH, 0 ) 
                    end
                    
                    objectiveWindowHeight = objectiveWindowHeight + questWindowHeight
                end
                
                -- Opt out window (only for objective 1 in cities)
                if (objective == 1)
                then
                    local _, optOutY = WindowGetDimensions( objectiveWindowName.."OptOutButton"  )
                    objectiveWindowHeight = objectiveWindowHeight + optOutY + 8 -- 8 is the anchor offset between the quests and the opt out window
                end
            end
            
            WindowSetDimensions( objectiveWindowName, EA_Window_CityTracker.WIDTH, objectiveWindowHeight )
            height = height + objectiveWindowHeight
        end
    end
    
    height = height + overviewHeight
    WindowSetDimensions( "EA_Window_CityTracker", EA_Window_CityTracker.WIDTH, height )
    
end

function EA_Window_CityTracker.UpdateConditionsSize( dataWindow )
    -- Resize on Conditions
    local conditionHeight = 0
    for condition = 1, EA_Window_CityTracker.NUM_CONDITION_COUNTERS
    do
        local windowName = dataWindow.."Condition"..condition
        local nameWindowName = windowName.."Name"
        if( WindowGetShowing(windowName) == true )
        then
            local _, conditionTextHeight = LabelGetTextDimensions( nameWindowName )
            WindowSetDimensions( nameWindowName, EA_Window_CityTracker.CONDITION_NAME_WIDTH, conditionTextHeight ) 
            WindowSetDimensions( windowName,     EA_Window_CityTracker.WIDTH,                conditionTextHeight ) 
            conditionHeight = conditionHeight + conditionTextHeight
        else
            WindowSetDimensions( nameWindowName, EA_Window_CityTracker.CONDITION_NAME_WIDTH, 0 ) 
            WindowSetDimensions( windowName,     EA_Window_CityTracker.WIDTH,                0 ) 
        end
    end
    
    return conditionHeight
end

-- Updates the Quest & Condition Data for an Objective
function EA_Window_CityTracker.UpdateTracker( objective )
    
    if (CheckObjectiveOutOfRange(objective))
    then
        return
    end
    
    local objectiveData = DataUtils.activeObjectivesData[objective]
    local objectiveWindowString = "EA_Window_CityTrackerObjective"..objective
    
    -- If this index isn't used or it is a battlefield objective, hide the objective tracker
    local showObjective = objectiveData ~= nil and not objectiveData.isBattlefieldObjective
    WindowSetShowing( objectiveWindowString, showObjective )
    if ( not showObjective )
    then
        return
    end
    
    -- set opt out flag (only for main city objective in cities)
    if ( objectiveData.isCityBoss )
    then
        ButtonSetDisabledFlag( objectiveWindowString.."OptOutButton", objectiveData.forcedOutForLoot )
        WindowSetShowing( objectiveWindowString.."OptOutButton", true )
    else
        WindowSetShowing( objectiveWindowString.."OptOutButton", false )
    end
    
    -- Quests
    for questIndex = 1, EA_Window_CityTracker.NUM_QUESTS
    do
        local questData = objectiveData.Quest[questIndex]
        local questWindowString = objectiveWindowString.."Quest"..questIndex
        
        if ( questData ~= nil )
        then
            WindowSetShowing( questWindowString, true )
        
            -- Name (ignore the objective's name in favor of the quests' name)
            local name = DataUtils.activeObjectivesData[objective].Quest[questIndex].name
        
            LabelSetText(questWindowString.."Label", name )

            -- Conditions
            for index, data in ipairs(questData.conditions)
            do
                local conditionName = data.name
                local curCounter    = data.curCounter
                local maxCounter    = data.maxCounter
                -- In cities, you can see the conditions for both your realm and the opposite realm. Consider a condition to be a failure condition if it
                -- is available to the opposite realm. This differs from the logic the other trackers use to determine if a condition is a failure condition.
                local isFailureCondition = questData.availableRealm ~= GameData.Player.realm
            
                local nameLabel    = questWindowString.."DataCondition"..index.."Name"
                local counterLabel = questWindowString.."DataCondition"..index.."Counter"
                local typeImage    = questWindowString.."DataCondition"..index.."Type"

                -- Only show the conditions if conditionName is not empty
                if( conditionName ~= L"" )
                then
                            
                    if( maxCounter > 0 )
                    then
                        LabelSetText( nameLabel, conditionName..L" - " )
                        LabelSetText( counterLabel, L""..curCounter..L"/"..maxCounter )

                        if( curCounter == maxCounter)
                        then
                            LabelSetTextColor(counterLabel, CompleteCounterColor.r, CompleteCounterColor.g, CompleteCounterColor.b )
                            LabelSetTextColor(nameLabel,    CompleteCounterColor.r, CompleteCounterColor.g, CompleteCounterColor.b )
                        else
                            LabelSetTextColor(counterLabel, IncompleteCounterColor.r, IncompleteCounterColor.g, IncompleteCounterColor.b)
                            LabelSetTextColor(nameLabel,    IncompleteCounterColor.r, IncompleteCounterColor.g, IncompleteCounterColor.b)
                        end
                        
                        WindowSetShowing( counterLabel, true )
                        WindowSetShowing( typeImage, true )
                    else
                        LabelSetText( nameLabel, conditionName )
                        WindowSetShowing( counterLabel, false )
                        WindowSetShowing( typeImage, false )
                    end

                    WindowSetShowing(questWindowString.."DataCondition"..index, true)
                else
                    WindowSetShowing(questWindowString.."DataCondition"..index, false)
                end
            
                if (isFailureCondition)
                then
                    DynamicImageSetTextureSlice(typeImage, "PQ-Failure-Condition")
                else
                    DynamicImageSetTextureSlice(typeImage, "PQ-Success-Condition")
                end
            end
        
            for index = #questData.conditions + 1, EA_Window_CityTracker.NUM_CONDITION_COUNTERS
            do
                local nameLabel    = questWindowString.."DataCondition"..index.."Name"
                local counterLabel = questWindowString.."DataCondition"..index.."Counter"

                WindowSetShowing(questWindowString.."DataCondition"..index, false)
            end
        else
            WindowSetShowing(questWindowString, false)
        end
        
    end
end

function EA_Window_CityTracker.UpdateStatus()

    if ( GameData.Player.isInSiege )
    then
        LayoutEditor.Show( "EA_Window_CityTracker" )
        local descriptionText = L""
        if ( GameData.CityScenarioData.playerIsDefending )
        then
            descriptionText = GetStringFormatFromTable("RvRCityStrings", StringTables.RvRCity.CITY_TRACKER_DESCRIPTION_DEFEND, { GetZoneName(GameData.Player.zone) } )
        else
            descriptionText = GetStringFormatFromTable("RvRCityStrings", StringTables.RvRCity.CITY_TRACKER_DESCRIPTION_ATTACK, { GetZoneName(GameData.Player.zone) } )
        end
        LabelSetText( "EA_Window_CityTrackerOverviewDescription", descriptionText )
    
        -- Resize the window to fit
        EA_Window_CityTracker.UpdateMainWindowSize()
    else
        LayoutEditor.Hide( "EA_Window_CityTracker" )
    end
end

function EA_Window_CityTracker.MouseOverQuest()

    local objective  = WindowGetId(WindowGetParent(SystemData.ActiveWindow.name))
    local questIndex = WindowGetId( SystemData.ActiveWindow.name )

    if (DataUtils.activeObjectivesData[objective] == nil)
    then
        return
    elseif ( DataUtils.activeObjectivesData[objective].Quest[questIndex] == nil )
    then
        return
    end
    
    local objectiveData = DataUtils.activeObjectivesData[objective]
    local questData     = objectiveData.Quest[questIndex]

    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )    
    local row = 1
    local column = 1

    -- Name
    local text = questData.name
    Tooltips.SetTooltipFont( row, column, "font_default_sub_heading", WindowUtils.FONT_DEFAULT_SUB_HEADING_LINESPACING  )
    Tooltips.SetTooltipText( row, column, text )
    Tooltips.SetTooltipColor( row, column, 255, 204, 102 )
    
    -- Complete Label
    column = column + 1 
    if( questData.complete == true )
    then
        text = GetString( StringTables.Default.LABEL_COMPLETE )         
        Tooltips.SetTooltipColor( row, column, CompleteCounterColor.r, CompleteCounterColor.g, CompleteCounterColor.b)
        Tooltips.SetTooltipText( row, column, text )
    end
    row = row + 1
    column = 1
    
    -- Objective Label
    text = GetString( StringTables.Default.LABEL_PUBLIC_QUEST ) 
    -- Difficulty
    local difficultyText = TrackerUtils.GetDifficultyText( objectiveData.difficulty )
    text = text..L" ("..difficultyText..L")"
    Tooltips.SetTooltipText( row, column, text )
    Tooltips.SetTooltipColor( row, column, 100, 100, 100)
    
    row = row + 1
    
    -- Text
    local text = questData.desc
    Tooltips.SetTooltipText( row, column, text )
    row = row + 1
    column = 1
    
    -- Difficulty help
    text = TrackerUtils.GetDifficultyHelpText( objectiveData.difficulty )
    local color = TrackerUtils.GetDifficultyColor( objectiveData.difficulty )
    Tooltips.SetTooltipText( row, column, text )
    Tooltips.SetTooltipColor( row, column, color.r, color.g, color.b )

    Tooltips.Finalize()
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT )   
end
