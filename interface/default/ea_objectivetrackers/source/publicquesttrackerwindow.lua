----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_PublicQuestTracker = {}

EA_Window_PublicQuestTracker.EMPTY_SIZE = { x=600, y=200 } -- Used to provide a size guide for the layout editor.

EA_Window_PublicQuestTracker.NUM_OBJECTIVES = 2
EA_Window_PublicQuestTracker.NUM_QUESTS = 3
EA_Window_PublicQuestTracker.NUM_CONDITION_COUNTERS = 5

EA_Window_PublicQuestTracker.WIDTH = 600
EA_Window_PublicQuestTracker.CONDITION_NAME_WIDTH = 530

OptOutVal = nil

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
    if ( ( index < 1 ) or ( index > EA_Window_PublicQuestTracker.NUM_OBJECTIVES ) )
    then
        --ERROR(L"Active objective #"..index..L" updated, the Public Quest Tracker only supports "..EA_Window_PublicQuestTracker.NUM_OBJECTIVES..L" objectives with "..EA_Window_PublicQuestTracker.NUM_QUESTS..L" quests")
        return true
    end
    return false
end

----------------------------------------------------------------
-- EA_Window_PublicQuestTracker Functions
----------------------------------------------------------------
-- OnInitialize Handler
function EA_Window_PublicQuestTracker.Initialize()

    LayoutEditor.RegisterWindow( "EA_Window_PublicQuestTracker",
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_PUBLIC_QUEST_TRACKER_WINDOW_NAME ),
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_PUBLIC_QUEST_TRACKER_WINDOW_DESC ),
                                false, false,
                                true, nil,
                                { "topleft", "top", "topright" } )
                                

    WindowRegisterEventHandler( "EA_Window_PublicQuestTracker", SystemData.Events.PUBLIC_QUEST_ADDED,   "EA_Window_PublicQuestTracker.OnQuestAdded")
    WindowRegisterEventHandler( "EA_Window_PublicQuestTracker", SystemData.Events.PUBLIC_QUEST_UPDATED, "EA_Window_PublicQuestTracker.OnQuestUpdated")
    WindowRegisterEventHandler( "EA_Window_PublicQuestTracker", SystemData.Events.PUBLIC_QUEST_REMOVED, "EA_Window_PublicQuestTracker.OnQuestRemoved")
    WindowRegisterEventHandler( "EA_Window_PublicQuestTracker", SystemData.Events.PUBLIC_QUEST_CONDITION_UPDATED, "EA_Window_PublicQuestTracker.OnQuestConditionUpdated")
    WindowRegisterEventHandler( "EA_Window_PublicQuestTracker", SystemData.Events.PUBLIC_QUEST_COMPLETED, "EA_Window_PublicQuestTracker.OnQuestCompleted")
    WindowRegisterEventHandler( "EA_Window_PublicQuestTracker", SystemData.Events.PUBLIC_QUEST_FAILED, "EA_Window_PublicQuestTracker.OnQuestFailed")
    WindowRegisterEventHandler( "EA_Window_PublicQuestTracker", SystemData.Events.PUBLIC_QUEST_RESETTING, "EA_Window_PublicQuestTracker.OnQuestResetting")
    WindowRegisterEventHandler( "EA_Window_PublicQuestTracker", SystemData.Events.PUBLIC_QUEST_OPTOUT, "EA_Window_PublicQuestTracker.OnQuestOptOut")
    WindowRegisterEventHandler( "EA_Window_PublicQuestTracker", SystemData.Events.PUBLIC_QUEST_FORCEDOUT, "EA_Window_PublicQuestTracker.OnQuestForcedOut")
            
    WindowRegisterEventHandler( "EA_Window_PublicQuestTracker", SystemData.Events.PLAYER_ZONE_CHANGED,          "EA_Window_PublicQuestTracker.OnZoneChange")

    WindowRegisterEventHandler( "EA_Window_PublicQuestTracker", SystemData.Events.PLAYER_AREA_CHANGED,          "EA_Window_PublicQuestTracker.OnAreaChange" )
    WindowRegisterEventHandler( "EA_Window_PublicQuestTracker", SystemData.Events.PLAYER_INFLUENCE_UPDATED,     "EA_Window_PublicQuestTracker.OnPlayerInfluenceUpdated" )
    WindowRegisterEventHandler( "EA_Window_PublicQuestTracker", SystemData.Events.LOADING_END,                  "EA_Window_PublicQuestTracker.UpdateInfluenceBar" )
    WindowRegisterEventHandler( "EA_Window_PublicQuestTracker", SystemData.Events.INTERFACE_RELOADED,           "EA_Window_PublicQuestTracker.Refresh" )
    WindowRegisterEventHandler( "EA_Window_PublicQuestTracker", SystemData.Events.PLAYER_INFLUENCE_RANK_UPDATED,"EA_Window_PublicQuestTracker.OnRankUp" )
    
    WindowRegisterEventHandler( "EA_Window_PublicQuestTracker", SystemData.Events.PLAYER_LEARNED_ABOUT_UI_ELEMENT, "EA_Window_PublicQuestTracker.UpdateTutorial" )
    WindowRegisterEventHandler( "EA_Window_PublicQuestTracker", SystemData.Events.PLAYER_CAREER_RANK_UPDATED,      "EA_Window_PublicQuestTracker.UpdateTutorial" )
    
    -- Initialize the Opt Out Options Context Menu
    TrackerUtils.CreateOptOutContextMenuItems( "EA_Window_PublicQuestTracker" )  
    
    EA_Window_PublicQuestTracker.UpdateFullList()
    EA_Window_PublicQuestTracker.UpdateInfluenceBar()
    EA_Window_PublicQuestTracker.UpdateLocation()
    EA_Window_PublicQuestTracker.UpdateTutorial()
    
    StatusBarSetMaximumValue("EA_Window_PublicQuestTrackerInfluenceBarFill", 100 ) -- Maximum of 100%

end

function EA_Window_PublicQuestTracker.InitializeLayout()
    EA_Window_PublicQuestTracker.UpdateMainWindowSize()
end

-- OnUpdate Handler
function EA_Window_PublicQuestTracker.Update( timePassed )
    -- Update the timers
    EA_Window_PublicQuestTracker.UpdateQuestTimer()
end

-- OnShutdown Handler
function EA_Window_PublicQuestTracker.Shutdown()

end

function EA_Window_PublicQuestTracker.Refresh()
    EA_Window_PublicQuestTracker.UpdateInfluenceBar()
end

function EA_Window_PublicQuestTracker.OnRankUp()
    Sound.Play(Sound.INFLUENCE_RANK_UP)
end

----------------------------------------------------------------
-- Opt Out Options
----------------------------------------------------------------

function EA_Window_PublicQuestTracker.OnLButtonUpOptOut()
    if( SystemData.ActiveWindow.name == nil or SystemData.ActiveWindow.name == "" ) then
        return
    end
    
    if(ButtonGetDisabledFlag(SystemData.ActiveWindow.name) == true)
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
    
    
    
    if (OptOutVal == nil) then 
      -- None
      ButtonSetPressedFlag("EA_Window_PublicQuestTrackerOptOutNoneCheckBox", TrackerUtils.ShouldOptOutOptionBeChecked(index, TrackerUtils.OPT_OUT_OPTION_NONE))
      -- All (Loot and Gold Bags)
      ButtonSetPressedFlag("EA_Window_PublicQuestTrackerOptOutAllCheckBox", TrackerUtils.ShouldOptOutOptionBeChecked(index, TrackerUtils.OPT_OUT_OPTION_ALL))
      -- Gold Bags Only
      ButtonSetPressedFlag("EA_Window_PublicQuestTrackerOptOutGoldCheckBox", TrackerUtils.ShouldOptOutOptionBeChecked(index, TrackerUtils.OPT_OUT_OPTION_GOLD))
    else 
      d("button click Opt out "..OptOutVal)
      local Arr = {false, false, false}
      Arr[OptOutVal+1] = true
      ButtonSetPressedFlag("EA_Window_PublicQuestTrackerOptOutNoneCheckBox", Arr[1])
      ButtonSetPressedFlag("EA_Window_PublicQuestTrackerOptOutAllCheckBox", Arr[2])
      ButtonSetPressedFlag("EA_Window_PublicQuestTrackerOptOutGoldCheckBox", Arr[3])
    end
    
    EA_Window_ContextMenu.AddUserDefinedMenuItem("EA_Window_PublicQuestTrackerOptOutNone")
    EA_Window_ContextMenu.AddUserDefinedMenuItem("EA_Window_PublicQuestTrackerOptOutAll")    
    EA_Window_ContextMenu.AddUserDefinedMenuItem("EA_Window_PublicQuestTrackerOptOutGold")
    
    EA_Window_ContextMenu.Finalize()
    
    WindowSetId("EA_Window_PublicQuestTrackerOptOutNone", index)
    WindowSetId("EA_Window_PublicQuestTrackerOptOutAll", index)
    WindowSetId("EA_Window_PublicQuestTrackerOptOutGold", index)
end

function EA_Window_PublicQuestTracker.ToggleOptOutOptionNone()    

    local index = WindowGetId( SystemData.ActiveWindow.name )
    if (CheckObjectiveOutOfRange(index))
    then
        return
    end    
    OptOutVal = 0
    TrackerUtils.SetOptOutOption( SystemData.ActiveWindow.name, index, TrackerUtils.OPT_OUT_OPTION_NONE )    
end

function EA_Window_PublicQuestTracker.ToggleOptOutOptionAll()     

    local index = WindowGetId( SystemData.ActiveWindow.name )
    if (CheckObjectiveOutOfRange(index))
    then
        return
    end    
    OptOutVal = 1
    TrackerUtils.SetOptOutOption( SystemData.ActiveWindow.name, index, TrackerUtils.OPT_OUT_OPTION_ALL )    
end

function EA_Window_PublicQuestTracker.ToggleOptOutOptionGold()   

    local index = WindowGetId( SystemData.ActiveWindow.name )
    if (CheckObjectiveOutOfRange(index))
    then
        return
    end    
    OptOutVal = 2  
    TrackerUtils.SetOptOutOption( SystemData.ActiveWindow.name, index, TrackerUtils.OPT_OUT_OPTION_GOLD )    
end

function EA_Window_PublicQuestTracker.OnQuestOptOut(index, optOut)
   
    if (CheckObjectiveOutOfRange(index))
    then
        return
    end

    DataUtils.activeObjectivesData[index].optedOutForLoot = optOut
end

function EA_Window_PublicQuestTracker.OnQuestForcedOut(index, forcedOut)

    if (CheckObjectiveOutOfRange(index))
    then
        return
    end
    
    ButtonSetDisabledFlag( "EA_Window_PublicQuestTrackerObjective"..index.."OptOutButton", forcedOut )

    DataUtils.activeObjectivesData[index].forcedOutForLoot = forcedOut
end


----------------------------------------------------------------
-- Pairing and Chapter text
----------------------------------------------------------------
function EA_Window_PublicQuestTracker.UpdateLocation()
    local raceLocation = StringUtils.GetFriendlyRaceForCurrentPairing( zonePairing, true )
    LabelSetText("EA_Window_PublicQuestTrackerLocationPairingLabel", raceLocation)
    
    local influenceID = EA_Window_PublicQuestTracker.GetLocalAreaInfluenceID()
    if ((influenceID ~= nil) and (influenceID > 0))
    then
        local chapterName = GetChapterShortName( influenceID )
        LabelSetText("EA_Window_PublicQuestTrackerLocationChapterLabel", chapterName)
    else
        LabelSetText("EA_Window_PublicQuestTrackerLocationChapterLabel", L"")
    end
end

----------------------------------------------------------------
-- Quests
----------------------------------------------------------------
function EA_Window_PublicQuestTracker.OnQuestAdded() 
    DataUtils.activeObjectivesData = GetActiveObjectivesData()
    local index = GameData.ActiveObjectives.updatedObjectiveIndex    
    
    --DEBUG(L"EA_Window_PublicQuestTracker.OnQuestAdded: index="..index )

    if (CheckObjectiveOutOfRange(index))
    then
        return
    end
    
    -- Update the Window to Include the new objective       
    EA_Window_PublicQuestTracker.UpdateTracker( index )      
    EA_Window_PublicQuestTracker.UpdateQuestVisibility()     
    
    -- Sound
    Sound.Play( Sound.PUBLIC_QUEST_ADDED )
    
end

function EA_Window_PublicQuestTracker.OnQuestResetting()
    DataUtils.activeObjectivesData = GetActiveObjectivesData()
    --DEBUG(L"EA_Window_PublicQuestTracker.OnQuestResetting" )

    local index = GameData.ActiveObjectives.updatedObjectiveIndex

    if (CheckObjectiveOutOfRange(index))
    then
        return
    end
    OptOutVal = nil
    Sound.Play( Sound.PUBLIC_QUEST_CYCLING )
    
end

function EA_Window_PublicQuestTracker.OnQuestUpdated() 
    DataUtils.activeObjectivesData = GetActiveObjectivesData()
--    DEBUG(L"EA_Window_PublicQuestTracker.OnQuestUpdated" )

    local index = GameData.ActiveObjectives.updatedObjectiveIndex

    if (CheckObjectiveOutOfRange(index))
    then
        return
    end
    
    -- Update the Window to Include the new objective       
    EA_Window_PublicQuestTracker.UpdateTracker( index )
    EA_Window_PublicQuestTracker.UpdateMainWindowSize()
end


function EA_Window_PublicQuestTracker.OnQuestRemoved()
    DataUtils.activeObjectivesData = GetActiveObjectivesData()
    
    local index = GameData.ActiveObjectives.updatedObjectiveIndex
    --DEBUG(L"EA_Window_PublicQuestTracker.OnQuestRemoved() index = "..index)

    if (CheckObjectiveOutOfRange(index))
    then
        return
    end
    
    -- Update the windows
    for objective = index, EA_Window_PublicQuestTracker.NUM_OBJECTIVES
    do
        EA_Window_PublicQuestTracker.UpdateTracker( objective )
    end
    
    EA_Window_PublicQuestTracker.UpdateQuestVisibility()
    
end

function EA_Window_PublicQuestTracker.OnQuestCompleted()
    --DEBUG(L"EA_Window_PublicQuestTracker.OnQuestCompleted()")
    DataUtils.activeObjectivesData = GetActiveObjectivesData()
    -- Sound
    Sound.Play( Sound.PUBLIC_QUEST_COMPLETED )
end

function EA_Window_PublicQuestTracker.OnQuestFailed()
    --DEBUG(L" **EA_Window_PublicQuestTracker.OnQuestFailed" )
    DataUtils.activeObjectivesData = GetActiveObjectivesData()
    -- Sound
    Sound.Play( Sound.PUBLIC_QUEST_FAILED )
end

function EA_Window_PublicQuestTracker.OnQuestConditionUpdated()

    --DEBUG(L" **EA_Window_PublicQuestTracker.OnQuestConditionUpdated" )
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
    local questWindowString = "EA_Window_PublicQuestTrackerObjective"..objective.."Quest"..questIndex
    
    for index, data in pairs(questData.conditions)
    do
    
        local conditionName = data.name
        local curCounter    = data.curCounter
        local maxCounter    = data.maxCounter
                
        local counterLabel = questWindowString.."DataCondition"..index.."Counter"
        local counterName  = questWindowString.."DataCondition"..index.."Name"

        -- Only show the conditions if conditionName is not empty
        if( conditionName ~= L"" )
        then
        -- DEBUG(L"Made it through 06 - conditions")
                  
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
                
                --DEBUG(L"    Condition #"..condition..L": "..curCounter..L" of "..maxCounter..L" counters.")
            else
                LabelSetText( counterLabel, L"" )
            end
            
        end   
    end
    
end

function EA_Window_PublicQuestTracker.UpdateQuestTimer()
    for objectiveIndex = 1, EA_Window_PublicQuestTracker.NUM_OBJECTIVES
    do
        for questIndex = 1, EA_Window_PublicQuestTracker.NUM_QUESTS
        do
            local questWindowString = "EA_Window_PublicQuestTrackerObjective"..objectiveIndex.."Quest"..questIndex
            local objectiveData = DataUtils.activeObjectivesData[objectiveIndex]
            
            local questData = nil
            if (objectiveData ~= nil)
            then
                questData = objectiveData.Quest[questIndex]
            end
            
            if ((questData ~= nil) and (questData.timerState ~= GameData.PQTimerState.NONE))
            then
                local timeLeft = DataUtils.GetPQTimerRemaining( questData.timerState, questData.timerValue )
                local text = TimeUtils.FormatClock( timeLeft )
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
function EA_Window_PublicQuestTracker.UpdateFullList()

--    DEBUG(L"EA_Window_PublicQuestTracker.UpdateFullList()")
    DataUtils.activeObjectivesData = GetActiveObjectivesData()
    local objectiveCount = 0
    
    for objective = 1, EA_Window_PublicQuestTracker.NUM_OBJECTIVES
    do
        local isObjectiveValid = false
        local objectiveWindowString = "EA_Window_PublicQuestTrackerObjective"..objective

        for questIndex = 1, EA_Window_PublicQuestTracker.NUM_QUESTS
        do
            local isQuestValid = false

            if ( DataUtils.activeObjectivesData ~= nil )
            then
                if ( DataUtils.activeObjectivesData[objective] ~= nil )
                then
                    if( DataUtils.activeObjectivesData[objective].Quest[questIndex] ~= nil )
                    then
                        isQuestValid = DataUtils.activeObjectivesData[objective].Quest[questIndex].name ~= L"" and
                                       DataUtils.activeObjectivesData[objective].Quest[questIndex].name ~= nil
                    end
                end
            end
    
            WindowSetShowing( objectiveWindowString.."Quest"..questIndex, isQuestValid )
            
            isObjectiveValid = isObjectiveValid or isQuestValid
        end
        
        if( isObjectiveValid )
        then
            WindowSetShowing( objectiveWindowString, true )
            EA_Window_PublicQuestTracker.UpdateTracker( objective )
            objectiveCount = objectiveCount + 1
        else
            WindowSetShowing( objectiveWindowString, false )
        end     

    end     

    if (objectiveCount > 0)
    then
        LayoutEditor.Show( "EA_Window_PublicQuestTracker" )
    else
        LayoutEditor.Hide( "EA_Window_PublicQuestTracker" )
    end
        
    -- I have a bug somewhere in here that's causing the window not to be sized correctly the first time through
    EA_Window_PublicQuestTracker.UpdateMainWindowSize()
end

function EA_Window_PublicQuestTracker.UpdateQuestVisibility()
    local PQFlag
    if (DataUtils.activeObjectivesData[GameData.ActiveObjectives.updatedObjectiveIndex]==nil) then 
      PQFlag = false
    else 
      PQFlag = DataUtils.activeObjectivesData[GameData.ActiveObjectives.updatedObjectiveIndex].isPublicQuest
    end
    if ( #DataUtils.activeObjectivesData == 0) or 
         ( (PQData.currentState ~= PQData.STATE_CLEAR) and
         ( GameData.PQData.id == DataUtils.activeObjectivesData[GameData.ActiveObjectives.updatedObjectiveIndex].id )) or
         (not PQFlag) or
         GameData.Player.isInSiege
    then
        WindowSetShowing("EA_Window_PublicQuestTrackerObjective1", false)
        WindowSetShowing("EA_Window_PublicQuestTrackerObjective2", false)
    else
        if (#DataUtils.activeObjectivesData > 2)
        then
            --ERROR(L""..#DataUtils.activeObjectivesData..L" objectives detected, Public Quest Tracker will only display the first two.")
        end
        
        WindowSetShowing("EA_Window_PublicQuestTrackerObjective1", true)

        if (#DataUtils.activeObjectivesData > 1)
        then
            WindowSetShowing("EA_Window_PublicQuestTrackerObjective2", true)
        end
    end
    
    EA_Window_PublicQuestTracker.UpdateMainWindowSize()
end

function EA_Window_PublicQuestTracker.UpdateMainWindowSize()

    local height = 0
    local mainHeight = 0
    
    if WindowGetShowing("EA_Window_PublicQuestTracker")
    then
    
        -- Influence Bar.
        local _, influenceY = WindowGetDimensions( "EA_Window_PublicQuestTrackerInfluenceBar" )
        height = height + influenceY
        
        -- Location Bar.
        local _, locationY = WindowGetDimensions( "EA_Window_PublicQuestTrackerLocation" )
        height = height + locationY + 25 -- 25 is the anchor offset between the location bar and objective1 window
        
        -- Main Windows.
        for objective = 1, EA_Window_PublicQuestTracker.NUM_OBJECTIVES
        do
            local objectiveWindowName = "EA_Window_PublicQuestTrackerObjective"..objective
            local objectiveWindowHeight = 0

            if WindowGetShowing(objectiveWindowName)
            then

                -- add the anchor offset between objectives
                if( objective > 1 )
                then
                    height = height + 5 -- anchor offset between Objective(N) and Objective(N+1)
                end
                
                -- Quests    
                for questIndex = 1, EA_Window_PublicQuestTracker.NUM_QUESTS
                do
                    -- Only update the window when it actually contains data
                    local questWindowHeight = 0
                    local questWindowName = objectiveWindowName.."Quest"..questIndex
                    if( WindowGetShowing( questWindowName ) == true )
                    then
                        local _, questLabelY   = LabelGetTextDimensions( questWindowName.."Label" )
                        local conditionsHeight = EA_Window_PublicQuestTracker.UpdateConditionsSize( questWindowName.."Data" )
                        
                        questWindowHeight = questLabelY + conditionsHeight + 1 -- 1 is the anchor offset between the quest label and quest conditions
                                                                               -- on a EA_Window_PublicQuestTrackerQuestCluster

                        WindowSetDimensions( questWindowName.."Data", EA_Window_PublicQuestTracker.WIDTH, conditionsHeight  )
                        WindowSetDimensions( questWindowName,         EA_Window_PublicQuestTracker.WIDTH, questWindowHeight ) 
                    else
                        WindowSetDimensions( questWindowName.."Data", EA_Window_PublicQuestTracker.WIDTH, 0 ) 
                        WindowSetDimensions( questWindowName,         EA_Window_PublicQuestTracker.WIDTH, 0 ) 
                    end
                    
                    objectiveWindowHeight = objectiveWindowHeight + questWindowHeight
                end
                
                -- Opt out window
                local _, optOutY = WindowGetDimensions( objectiveWindowName.."OptOutButton"  )
                objectiveWindowHeight = objectiveWindowHeight + optOutY + 8 -- 8 is the anchor offset between the quests and the opt out window
            end

            WindowSetDimensions( objectiveWindowName, EA_Window_PublicQuestTracker.WIDTH, objectiveWindowHeight )
            mainHeight = mainHeight + objectiveWindowHeight
        end

    end
    
    height = height + mainHeight
    WindowSetDimensions( "EA_Window_PublicQuestTracker", EA_Window_PublicQuestTracker.WIDTH, height )
    
end

function EA_Window_PublicQuestTracker.UpdateConditionsSize( dataWindow )
    -- Resize on Conditions
    local conditionHeight = 0
    for condition = 1, EA_Window_PublicQuestTracker.NUM_CONDITION_COUNTERS
    do
        local windowName = dataWindow.."Condition"..condition
        local nameWindowName = windowName.."Name"
        if( WindowGetShowing(windowName) == true )
        then
            local _, conditionTextHeight = LabelGetTextDimensions( nameWindowName )
            WindowSetDimensions( nameWindowName, EA_Window_PublicQuestTracker.CONDITION_NAME_WIDTH, conditionTextHeight ) 
            WindowSetDimensions( windowName,     EA_Window_PublicQuestTracker.WIDTH,                conditionTextHeight ) 
            conditionHeight = conditionHeight + conditionTextHeight
        else
            WindowSetDimensions( nameWindowName, EA_Window_PublicQuestTracker.CONDITION_NAME_WIDTH, 0 ) 
            WindowSetDimensions( windowName,     EA_Window_PublicQuestTracker.WIDTH,                0 ) 
        end
    end
    
    return conditionHeight
end

-- Updates the Quest & Condition Data for an Objective
function EA_Window_PublicQuestTracker.UpdateTracker( objective )     
   
    -- DEBUG(L"EA_Window_PublicQuestTracker.UpdateTracker("..objective..L"): #"..GameData.ActiveObjectives[objective].id..L" '"..GameData.ActiveObjectives[objective].name..L"' control = "..GameData.ActiveObjectives[objective].curControlPoints )
    if (CheckObjectiveOutOfRange(objective))
    then
        return
    end
    
    local objectiveData = DataUtils.activeObjectivesData[objective]
    local objectiveWindowString = "EA_Window_PublicQuestTrackerObjective"..objective

    -- If this index isn't used or it is a battlefield objective, hide the objective tracker
    WindowSetShowing( objectiveWindowString, objectiveData ~= nil and not objectiveData.isBattlefieldObjective )
    
    -- nothing else to do
    if ( objectiveData == nil ) or
       ( objectiveData.isBattlefieldObjective )
    then
        return
    end    
    
    -- Set opt out flag; if the player is forced out, disable the opt out button
    ButtonSetDisabledFlag( objectiveWindowString.."OptOutButton", objectiveData.forcedOutForLoot )
    
    -- Name and Difficulty
    local difficultyColor = TrackerUtils.GetDifficultyColor( objectiveData.difficulty )
    LabelSetTextColor( objectiveWindowString.."Quest1Label", difficultyColor.r, difficultyColor.g, difficultyColor.b )
    
    -- Quests
    for questIndex = 1, EA_Window_PublicQuestTracker.NUM_QUESTS
    do
        -- DEBUG(L"Made it through 02")
        local questData = objectiveData.Quest[questIndex]
        local questWindowString = objectiveWindowString.."Quest"..questIndex
        
        if ( questData ~= nil )
        then
            -- DEBUG(L"Made it through 03")    
            
            WindowSetShowing( questWindowString, true )
            --DEBUG(L"  Quest #"..questIndex..L" '"..GameData.ActiveObjectives[objective].Quest[questIndex].name..L"'")
            
            -- Execute special layout for quests past the first one if the realm is the same as the
            --   previous quest's realm.
            -- TODO: Fix this so that the server can send the list of quests with various realms' quests interleaved
            local realmIsSameAsPrevious = false
            if( questIndex > 1 )
            then 
                realmIsSameAsPrevious = (questData.availableRealm == 0) or
                                        (questData.availableRealm == 
                                        DataUtils.activeObjectivesData[objective].Quest[questIndex - 1].availableRealm)
            end
            
            local useOrForName = realmIsSameAsPrevious

            -- Name
            local name = L""
            if (useOrForName)
            then
                name = GetString(StringTables.Default.LABEL_ALTERNATE_QUEST_CHOICE_PREFIX )
            elseif (questData.availableRealm ~= GameData.Player.realm)
            then
                if (questData.availableRealm == GameData.Realm.ORDER)
                then
                    name = GetString(StringTables.Default.LABEL_ORDER)
                elseif (questData.availableRealm == GameData.Realm.DESTRUCTION)
                then
                    name = GetString(StringTables.Default.LABEL_DESTRUCTION)
                else
                    name = DataUtils.activeObjectivesData[objective].name
                end
                name = name..L" - "..DataUtils.activeObjectivesData[objective].Quest[questIndex].name
            else
                name = DataUtils.activeObjectivesData[objective].name
                name = name..L" - "..DataUtils.activeObjectivesData[objective].Quest[questIndex].name
                
                local difficultyText = TrackerUtils.GetDifficultyText( objectiveData.difficulty )
                name = name..L" ("..difficultyText..L")"
            end
            -- DEBUG(L"Made it through 04")
            LabelSetText(questWindowString.."Label", name )
            --DEBUG(L"  Quest #"..questIndex..L" '"..name..L"' with dimensions: x="..x..L", y="..y )

            EA_Window_PublicQuestTracker.UpdateQuestTimer()          
          
            -- Conditions
            for index, data in ipairs(questData.conditions)
            do
                local conditionName = data.name
                local curCounter    = data.curCounter
                local maxCounter    = data.maxCounter
                local isFailureCondition = data.failureCondition
                
                local nameLabel    = questWindowString.."DataCondition"..index.."Name"
                local counterLabel = questWindowString.."DataCondition"..index.."Counter"
                local typeImage    = questWindowString.."DataCondition"..index.."Type"

                -- Only show the conditions if conditionName is not empty
                if( conditionName ~= L"" )
                then
                -- DEBUG(L"Made it through 06 - conditions")
                    
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
                        
                        --DEBUG(L"    Condition #"..condition..L": "..curCounter..L" of "..maxCounter..L" counters.")
                    else
                        LabelSetText( nameLabel, conditionName )            
                        LabelSetText( counterLabel, L"" )
                    end
                             
                    WindowSetShowing(questWindowString.."DataCondition"..index, true )
                else
                    LabelSetText( nameLabel, L"" )
                    LabelSetText( counterLabel, L"" )
                    WindowSetShowing(questWindowString.."DataCondition"..index, false)
                end
                
                if (isFailureCondition)
                then
                    DynamicImageSetTextureSlice(typeImage, "PQ-Failure-Condition")
                else
                    DynamicImageSetTextureSlice(typeImage, "PQ-Success-Condition")
                end
                
            end
            
            for index = #questData.conditions + 1, EA_Window_PublicQuestTracker.NUM_CONDITION_COUNTERS
            do
                local nameLabel    = questWindowString.."DataCondition"..index.."Name"
                local counterLabel = questWindowString.."DataCondition"..index.."Counter"

                LabelSetText( nameLabel, L"" )
                LabelSetText( counterLabel, L"" )
                WindowSetShowing(questWindowString.."DataCondition"..index, false)
            end
                       
        else
            WindowSetShowing(questWindowString, false)
        end
        
    end        
    -- DEBUG(L"Made it through 07 - exiting")

end


function EA_Window_PublicQuestTracker.MouseOverQuest()

    local objective  = WindowGetId(WindowGetParent(SystemData.ActiveWindow.name))
    local questIndex = WindowGetId(SystemData.ActiveWindow.name)
    -- DEBUG(L"EA_Window_PublicQuestTracker.MouseOverQuest - ActiveObjective Index = "..objective..L", quest index = "..questIndex )

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

----------------------------------------------------------------
-- Influence Bar
----------------------------------------------------------------

function EA_Window_PublicQuestTracker.OnAreaChange()
    EA_Window_PublicQuestTracker.UpdateInfluenceBar()
    EA_Window_PublicQuestTracker.UpdateLocation()
end

function EA_Window_PublicQuestTracker.OnZoneChange()
    EA_Window_PublicQuestTracker.UpdateFullList()
    EA_Window_PublicQuestTracker.UpdateInfluenceBar()
    EA_Window_PublicQuestTracker.UpdateLocation()
end

function EA_Window_PublicQuestTracker.OnPlayerInfluenceUpdated()
    EA_Window_PublicQuestTracker.UpdateInfluenceBar()
end

function EA_Window_PublicQuestTracker.UpdateInfluenceBar()
    local infID, hasPQButNoInfluence = EA_Window_PublicQuestTracker.GetLocalAreaInfluenceID()
    local showBar = DataUtils.UpdateInfluenceBar( "EA_Window_PublicQuestTrackerInfluenceBarFill", infID )
    local inPeacefulCity = (GameDefs.PeacefulCityZoneIDs[ GameData.Player.zone ] ~= nil)
    
    -- Hide the location and the influence if we are not in an area that has influence. Also hide it in peaceful cities. Always hide location bar in contested cities, but allow influence bar to show there.
    WindowSetShowing( "EA_Window_PublicQuestTrackerLocation", not hasPQButNoInfluence and not inPeacefulCity and not GameData.Player.isInSiege )
    WindowSetShowing( "EA_Window_PublicQuestTrackerInfluenceBar", not hasPQButNoInfluence and not inPeacefulCity )
    
    -- Show or hide the entire window depending on whether we're in an influence area or a PQ area without influence or a peaceful city
    if ( showBar or hasPQButNoInfluence or inPeacefulCity )
    then
        LayoutEditor.Show( "EA_Window_PublicQuestTracker" )
    else
        LayoutEditor.Hide( "EA_Window_PublicQuestTracker" )
    end
    EA_Window_PublicQuestTracker.UpdateMainWindowSize()
end

function EA_Window_PublicQuestTracker.OnMouseOverInfluenceBar()

    local influenceData = DataUtils.GetInfluenceData( EA_Window_PublicQuestTracker.GetLocalAreaInfluenceID())
    if( influenceData ~= nil )
    then
        -- Fix for rogue entries
        if( influenceData.zoneNum == 0 and influenceData.zoneAreaNum == 0 )
        then
            return
        end
        
        local line1 = GetString( StringTables.Default.LABEL_AREA_INFLUENCE )
        
        local line2 = L""
        if (GameData.Player.isInSiege) then
            -- Figure out the local player's capital city (not necessarily the city they are currently in)
            local cityName = GetCityNameForRealm(GameData.Player.realm)
            line2 = GetStringFormat( StringTables.Default.TEXT_PQ_TRACKER_INFLUENCE_CITY_BAR, { influenceData.npcName, cityName } )
        elseif (influenceData.isRvRInfluence) then
            local zoneName = GetZoneName( influenceData.zoneNum )
            line2 = GetStringFormat( StringTables.Default.TEXT_PQ_TRACKER_INFLUENCE_RVR_BAR, { influenceData.npcName, zoneName } )
        else
            local zoneName = GetZoneName( influenceData.zoneNum )
            local areaName = GetZoneAreaName(  influenceData.zoneNum, influenceData.zoneAreaNum )
            line2 = GetStringFormat( StringTables.Default.TEXT_PQ_TRACKER_INFLUENCE_BAR, { influenceData.npcName, areaName, zoneName } )
        end
        
        local actionText = GetString( StringTables.Default.TEXT_CLICK_VIEW_REWARDS )    
        
        Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
        Tooltips.SetTooltipText( 1, 1, line1)
        Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
        Tooltips.SetTooltipText( 2, 1, line2)
        
        Tooltips.SetTooltipActionText( actionText)
        
        Tooltips.Finalize()
        Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT )   
    end
end

function EA_Window_PublicQuestTracker.OnClickInfluenceBar()
    
    local influenceData = DataUtils.GetInfluenceData( EA_Window_PublicQuestTracker.GetLocalAreaInfluenceID() )

    if( influenceData ~= nil ) then
        -- Fix for rogue entries
        if( influenceData.zoneNum == 0 and influenceData.zoneAreaNum == 0 )
        then
            return
        end
    
        -- Open the tome to the link
        TomeWindow.OpenTomeToEntry( influenceData.tomeSection, influenceData.tomeEntry )
    end
    
end

function EA_Window_PublicQuestTracker.GetLocalAreaInfluenceID()

    local areaData = GetAreaData()
    
    if( areaData == nil )
    then
        -- DEBUG(L"[EA_Window_PublicQuestTracker.GetLocalAreaInfluenceID] AreaData returned nil")
        return nil, false
    end
    
    local hasPQButNoInfluence = false
    for key, value in ipairs( areaData )
    do
        -- These should match the data that was retrived from war_interface::LuaGetAreaData
        if (value.influenceID ~= 0)
        then
            -- Return whatever value.hasPQButNoInfluence is
            return value.influenceID, value.hasPQButNoInfluence
        elseif( value.hasPQButNoInfluence )
        then
            -- If any of the areas we are in have a PQ but no influence we want this to be true
            hasPQButNoInfluence = true
        end
    end
    
    return nil, hasPQButNoInfluence
end

function EA_Window_PublicQuestTracker.UpdateTutorial()
    -- Show/hide the container window for the bar. The bar itself is hidden/shown in UpdateInfluenceBar() based on whether we're in an area with influence
    EA_AdvancedWindowManager.UpdateWindowShowing( "EA_Window_PublicQuestTrackerInfluence", EA_AdvancedWindowManager.WINDOW_TYPE_INFLUENCE_BAR )
end
