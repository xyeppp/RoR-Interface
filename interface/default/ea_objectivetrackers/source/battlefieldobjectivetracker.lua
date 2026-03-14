----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_BattlefieldObjectiveTracker = {}

EA_Window_BattlefieldObjectiveTracker.EMPTY_SIZE = { x=600, y=200 } -- Used to provide a size guide for the layout editor.

EA_Window_BattlefieldObjectiveTracker.NUM_OBJECTIVES = 1
EA_Window_BattlefieldObjectiveTracker.NUM_QUESTS = 1
EA_Window_BattlefieldObjectiveTracker.NUM_CONDITION_COUNTERS = 5

EA_Window_BattlefieldObjectiveTracker.WIDTH = 600
EA_Window_BattlefieldObjectiveTracker.CONDITION_NAME_WIDTH = 530
EA_Window_BattlefieldObjectiveTracker.ACTION_LABEL_WIDTH = 230
EA_Window_BattlefieldObjectiveTracker.ACTION_LABEL_HEIGHT = 6


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
    if ( ( index < 1 ) or ( index > EA_Window_BattlefieldObjectiveTracker.NUM_OBJECTIVES ) )
    then
        --ERROR(L"Active objective #"..index..L" updated, the BO Tracker only supports "..EA_Window_BattlefieldObjectiveTracker.NUM_OBJECTIVES..L" objectives with "..EA_Window_BattlefieldObjectiveTracker.NUM_QUESTS..L" quests")
        return true
    end
    return false
end

local function CheckQuestOutOfRange(index)
    if ( ( index < 1 ) or ( index > EA_Window_BattlefieldObjectiveTracker.NUM_QUESTS ) )
    then
        --ERROR(L"Active quest #"..index..L" updated, the BO Tracker only supports "..EA_Window_BattlefieldObjectiveTracker.NUM_OBJECTIVES..L" objectives with "..EA_Window_BattlefieldObjectiveTracker.NUM_QUESTS..L" quests")
        return true
    end
    return false
end

----------------------------------------------------------------
-- EA_Window_BattlefieldObjectiveTracker Functions
----------------------------------------------------------------
-- OnInitialize Handler
function EA_Window_BattlefieldObjectiveTracker.Initialize()

    LayoutEditor.RegisterWindow( "EA_Window_BattlefieldObjectiveTracker",
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_RVR_OBJECTIVE_TRACKER_WINDOW_NAME ),
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_RVR_OBJECTIVE_TRACKER_WINDOW_DESC ),
                                false, false,
                                true, nil,
                                { "topleft", "top", "topright" } )
                                

    WindowRegisterEventHandler( "EA_Window_BattlefieldObjectiveTracker", SystemData.Events.PUBLIC_QUEST_ADDED,   "EA_Window_BattlefieldObjectiveTracker.OnQuestAdded")
    WindowRegisterEventHandler( "EA_Window_BattlefieldObjectiveTracker", SystemData.Events.PUBLIC_QUEST_UPDATED, "EA_Window_BattlefieldObjectiveTracker.OnQuestUpdated")
    WindowRegisterEventHandler( "EA_Window_BattlefieldObjectiveTracker", SystemData.Events.PUBLIC_QUEST_REMOVED, "EA_Window_BattlefieldObjectiveTracker.OnQuestRemoved")
    WindowRegisterEventHandler( "EA_Window_BattlefieldObjectiveTracker", SystemData.Events.PUBLIC_QUEST_CONDITION_UPDATED, "EA_Window_BattlefieldObjectiveTracker.OnQuestConditionUpdated")
    WindowRegisterEventHandler( "EA_Window_BattlefieldObjectiveTracker", SystemData.Events.PUBLIC_QUEST_COMPLETED, "EA_Window_BattlefieldObjectiveTracker.OnQuestCompleted")
    WindowRegisterEventHandler( "EA_Window_BattlefieldObjectiveTracker", SystemData.Events.PUBLIC_QUEST_FAILED, "EA_Window_BattlefieldObjectiveTracker.OnQuestFailed")
    WindowRegisterEventHandler( "EA_Window_BattlefieldObjectiveTracker", SystemData.Events.PUBLIC_QUEST_RESETTING, "EA_Window_BattlefieldObjectiveTracker.OnQuestResetting")

    WindowRegisterEventHandler( "EA_Window_BattlefieldObjectiveTracker", SystemData.Events.INTERFACE_RELOADED,           "EA_Window_BattlefieldObjectiveTracker.Refresh" )
    WindowRegisterEventHandler( "EA_Window_BattlefieldObjectiveTracker", SystemData.Events.PLAYER_ZONE_CHANGED,          "EA_Window_BattlefieldObjectiveTracker.Refresh" )    
    WindowRegisterEventHandler( "EA_Window_BattlefieldObjectiveTracker", SystemData.Events.CAMPAIGN_ZONE_UPDATED,        "EA_Window_BattlefieldObjectiveTracker.OnCampaignZoneUpdated")
    WindowRegisterEventHandler( "EA_Window_BattlefieldObjectiveTracker", SystemData.Events.CAMPAIGN_PAIRING_UPDATED,     "EA_Window_BattlefieldObjectiveTracker.OnCampaignPairingUpdated")
    
    LabelSetText("EA_Window_BattlefieldObjectiveTrackerLockedText", GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.TEXT_BATTLEFIELD_LOCKEDZONE) )
    
    EA_Window_BattlefieldObjectiveTracker.UpdateFullList()
end

function EA_Window_BattlefieldObjectiveTracker.InitializeLayout()
    EA_Window_BattlefieldObjectiveTracker.UpdateMainWindowSize()
end

-- OnUpdate Handler
function EA_Window_BattlefieldObjectiveTracker.Update( timePassed )
    -- Update the timers
    EA_Window_BattlefieldObjectiveTracker.UpdateQuestTimer()
end

-- OnShutdown Handler
function EA_Window_BattlefieldObjectiveTracker.Shutdown()
end

function EA_Window_BattlefieldObjectiveTracker.Refresh()
    EA_Window_BattlefieldObjectiveTracker.UpdateTracker()
end


function EA_Window_BattlefieldObjectiveTracker.OnCampaignZoneUpdated( zoneId )
    if( zoneId == GameData.Player.zone )
    then
        EA_Window_BattlefieldObjectiveTracker.UpdateTracker()
    end
end

function EA_Window_BattlefieldObjectiveTracker.OnCampaignPairingUpdated( pairingId )
    EA_Window_BattlefieldObjectiveTracker.UpdateTracker()
end


----------------------------------------------------------------
-- Quests
----------------------------------------------------------------
function EA_Window_BattlefieldObjectiveTracker.OnQuestAdded() 
    DataUtils.activeObjectivesData = GetActiveObjectivesData()
    local index = GameData.ActiveObjectives.updatedObjectiveIndex
    
    -- DEBUG(L"EA_Window_BattlefieldObjectiveTracker.OnQuestAdded: index="..index )

    if (DataUtils.activeObjectivesData[index] and (DataUtils.activeObjectivesData[index].isBattlefieldObjective == false))
    then
        return
    end

    if (CheckObjectiveOutOfRange(index))
    then
        return
    end
    
    -- Update the Window to Include the new objective       
    EA_Window_BattlefieldObjectiveTracker.UpdateTracker( )
    
    -- Sound
    Sound.Play( Sound.PUBLIC_QUEST_ADDED )
    
end

function EA_Window_BattlefieldObjectiveTracker.OnQuestResetting()
    DataUtils.activeObjectivesData = GetActiveObjectivesData()
    -- DEBUG(L"EA_Window_BattlefieldObjectiveTracker.OnQuestResetting" )

    local index = GameData.ActiveObjectives.updatedObjectiveIndex
    
    if (DataUtils.activeObjectivesData[index] and (DataUtils.activeObjectivesData[index].isBattlefieldObjective == false))
    then
        return
    end

    if (CheckObjectiveOutOfRange(index))
    then
        return
    end
    
    local showing = WindowGetShowing( "EA_Window_BattlefieldObjectiveTracker" )
    
    if ( showing == false ) then
    
        -- Sound
        Sound.Play( Sound.PUBLIC_QUEST_CYCLING )

        -- TODO : Show the UI in faded out mode

    end
    
end

function EA_Window_BattlefieldObjectiveTracker.OnQuestUpdated() 
    DataUtils.activeObjectivesData = GetActiveObjectivesData()
    -- DEBUG(L"EA_Window_BattlefieldObjectiveTracker.OnQuestUpdated" )

    local index = GameData.ActiveObjectives.updatedObjectiveIndex
    
    if (DataUtils.activeObjectivesData[index] and (DataUtils.activeObjectivesData[index].isBattlefieldObjective == false))
    then
        return
    end

    if (CheckObjectiveOutOfRange(index))
    then
        return
    end
    
    -- Update the Window to Include the new objective       
    EA_Window_BattlefieldObjectiveTracker.UpdateTracker( )
end


function EA_Window_BattlefieldObjectiveTracker.OnQuestRemoved()
    DataUtils.activeObjectivesData = GetActiveObjectivesData()
    
    local index = GameData.ActiveObjectives.updatedObjectiveIndex
    -- DEBUG(L"EA_Window_BattlefieldObjectiveTracker.OnQuestRemoved() index = "..index)

    if (DataUtils.activeObjectivesData[index] and (DataUtils.activeObjectivesData[index].isBattlefieldObjective == false))
    then
        return
    end

    if (CheckObjectiveOutOfRange(index))
    then
        return
    end
    
    -- Update the windows
    EA_Window_BattlefieldObjectiveTracker.UpdateTracker( )
    
end

function EA_Window_BattlefieldObjectiveTracker.OnQuestCompleted()
    -- DEBUG(L"EA_Window_BattlefieldObjectiveTracker.OnQuestCompleted()")
    DataUtils.activeObjectivesData = GetActiveObjectivesData()
    -- Sound
    Sound.Play( Sound.PUBLIC_QUEST_COMPLETED )
end

function EA_Window_BattlefieldObjectiveTracker.OnQuestFailed()
    -- DEBUG(L" **EA_Window_BattlefieldObjectiveTracker.OnQuestFailed" )
    DataUtils.activeObjectivesData = GetActiveObjectivesData()
    -- Sound
    Sound.Play( Sound.PUBLIC_QUEST_FAILED )
end

function EA_Window_BattlefieldObjectiveTracker.OnQuestConditionUpdated()

    -- DEBUG(L" **EA_Window_BattlefieldObjectiveTracker.OnQuestConditionUpdated" )
    DataUtils.activeObjectivesData = GetActiveObjectivesData()
    local objective = GameData.ActiveObjectives.updatedObjectiveIndex
    local questIndex = GameData.ActiveObjectives.updatedQuestIndex
    local condition = GameData.ActiveObjectives.updatedQuestConditionIndex
    
    if (DataUtils.activeObjectivesData[objective].isBattlefieldObjective == false)
    then
        return
    end

    if (CheckObjectiveOutOfRange(objective) or CheckQuestOutOfRange(questIndex))
    then
        return
    end
    
    local questData = DataUtils.activeObjectivesData[objective].Quest[questIndex]

    -- Update only the Condtion Counters
    local questWindowString = "EA_Window_BattlefieldObjectiveTrackerMainQuest"..questIndex
    
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


function EA_Window_BattlefieldObjectiveTracker.UpdateQuestTimer()
    local timerContainerWindow = "EA_Window_BattlefieldObjectiveTracker"
    
    local objectiveData = DataUtils.activeObjectivesData[1]
            
    local questData = nil
    if (objectiveData ~= nil)
    then
        questData = objectiveData.Quest[1]
    end
            
    if ((questData ~= nil) and (questData.timerState ~= GameData.PQTimerState.NONE))
    then
        local timeLeft = DataUtils.GetPQTimerRemaining( questData.timerState, questData.timerValue )
        local text = TimeUtils.FormatClock( timeLeft )
        LabelSetText( timerContainerWindow.."TimerValue", text )
        WindowSetShowing( timerContainerWindow.."ClockImage", true )
    else            
        LabelSetText( timerContainerWindow.."TimerValue", L"" )      
        WindowSetShowing( timerContainerWindow.."ClockImage", false )
    end
end

-- This is only called on initialization to populate the window without any state changing animations
function EA_Window_BattlefieldObjectiveTracker.UpdateFullList()

    -- DEBUG(L"EA_Window_BattlefieldObjectiveTracker.UpdateFullList()")
    --DataUtils.activeObjectivesData = GetActiveObjectivesData()

    for objective = 1, EA_Window_BattlefieldObjectiveTracker.NUM_OBJECTIVES
    do

        local isObjectiveValid = false

        for questIndex = 1, EA_Window_BattlefieldObjectiveTracker.NUM_QUESTS
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

            local questWindow = "EA_Window_BattlefieldObjectiveTrackerMainQuest"..questIndex
            WindowSetShowing( questWindow, isQuestValid )

            isObjectiveValid = isObjectiveValid or isQuestValid
        end
        
        local useBattlefieldTracker = not GameData.Player.isInScenario

        if( isObjectiveValid and useBattlefieldTracker )
        then
            EA_Window_BattlefieldObjectiveTracker.UpdateTracker( )
        else
            LayoutEditor.Hide( "EA_Window_BattlefieldObjectiveTracker" )
        end     

    end     
        
        
    -- I have a bug somewhere in here that's causing the window not to be sized correctly the first time through
    EA_Window_BattlefieldObjectiveTracker.UpdateMainWindowSize()
end


function EA_Window_BattlefieldObjectiveTracker.UpdateMainWindowSize()

    -- Hm.  Unneeded?
    
end

function EA_Window_BattlefieldObjectiveTracker.UpdateConditionsSize( dataWindow )
    -- Resize on Conditions
    local conditionHeight = 0
    for condition = 1, EA_Window_BattlefieldObjectiveTracker.NUM_CONDITION_COUNTERS
    do
        local windowName = dataWindow.."Condition"..condition
        local nameWindowName = windowName.."Name"
        if( WindowGetShowing(windowName) == true )
        then
            local _, conditionTextHeight = LabelGetTextDimensions( nameWindowName )
            WindowSetDimensions( nameWindowName, EA_Window_BattlefieldObjectiveTracker.CONDITION_NAME_WIDTH, conditionTextHeight ) 
            WindowSetDimensions( windowName,     EA_Window_BattlefieldObjectiveTracker.WIDTH,                conditionTextHeight ) 
            conditionHeight = conditionHeight + conditionTextHeight
        else
            WindowSetDimensions( nameWindowName, EA_Window_BattlefieldObjectiveTracker.CONDITION_NAME_WIDTH, 0 ) 
            WindowSetDimensions( windowName,     EA_Window_BattlefieldObjectiveTracker.WIDTH,                0 ) 
        end
    end
    
    return conditionHeight
end

function EA_Window_BattlefieldObjectiveTracker.UpdateObjectiveDimensions(objective)

    if (CheckObjectiveOutOfRange(objective))
    then
        return
    end


    local windowName = "EA_Window_BattlefieldObjectiveTrackerMain"
    local x, y = WindowGetDimensions( windowName )    
    y = EA_Window_BattlefieldObjectiveTracker.UpdateConditionsSize( windowName.."Quest"..objective.."Data" )
    WindowSetDimensions(windowName, x, y )

end


-- Updates the Quest & Condition Data for an Objective
function EA_Window_BattlefieldObjectiveTracker.UpdateTracker()
    -- DEBUG(L"EA_Window_BattlefieldObjectiveTracker.UpdateTracker()")

    local objective = 1
        
    local objectiveData         = DataUtils.activeObjectivesData[objective]
    local trackerWindow         = "EA_Window_BattlefieldObjectiveTracker"
    local objectiveWindowString = "EA_Window_BattlefieldObjectiveTrackerMain"
    local lockedWindow          = "EA_Window_BattlefieldObjectiveTrackerLocked"

    local useBattlefieldTracker = objectiveData ~= nil and
                                  objectiveData.isBattlefieldObjective and
                                  not objectiveData.isKeep and
                                  not GameData.Player.isInScenario and
                                  not GameData.Player.isInSiege
                                  
    if ( not useBattlefieldTracker )
    then
        LayoutEditor.Hide( trackerWindow )
        return
    end

    LayoutEditor.Show( trackerWindow )

    local objectiveID = objectiveData.id
    
    -- Capture ownership and state
    local iconWindow = trackerWindow.."OwnerIcon"
    local owner = TrackerUtils.GetFlagSliceForOwner(objectiveData.controllingRealm)
    DynamicImageSetTextureSlice(iconWindow, owner)
    
    -- Location name
    local name = DataUtils.activeObjectivesData[objective].name
    LabelSetText(trackerWindow.."Label", name )
    
    -- Check for zone lock.
    local zoneData = GetCampaignZoneData( GameData.Player.zone )
    
    if( (zoneData ~= nil) and (zoneData.isLocked) )
    then
        local pairingData = GetCampaignPairingData( zoneData.pairingId )
        if( pairingData.contestedZone ~= 0  )
        then  
            -- The Battle is in annother zone in this pairing or in the city
            local frontLineZoneName = GetZoneName(pairingData.contestedZone)
            local frontLineText = GetStringFormatFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.TEXT_BATTLEFIELD_FRONTZONE, {frontLineZoneName} )
            LabelSetText( lockedWindow.."Location", frontLineText )
        else
            -- This pairing has been captured but a city is not yet unlocked
            local capturedRealmName = ( GetRealmName(pairingData.controllingRealm) )
                        
            local capturedFortressName = L""
            if( pairingData.controllingRealm == GameData.Realm.DESTRUCTION)
            then
                capturedFortressName = GetZoneName(pairingData.orderFortressZone) 
            elseif( pairingData.controllingRealm == GameData.Realm.ORDER)
            then
                capturedFortressName = GetZoneName(pairingData.destructionFortressZone) 
            end
            
            
            local capturedText = GetStringFormatFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.TEXT_BATTLEFIELD_CAPTURED, { capturedRealmName, capturedFortressName } )
            LabelSetText( lockedWindow.."Location", capturedText )
        end
        
        WindowSetShowing( lockedWindow,          true )
        WindowSetShowing( objectiveWindowString, false )
        return
    else
        WindowSetShowing( lockedWindow,          false )
        WindowSetShowing( objectiveWindowString, true )
    end
    
    
    -- Quests
    for questIndex = 1, EA_Window_BattlefieldObjectiveTracker.NUM_QUESTS
    do
        -- DEBUG(L"Made it through 02")
        local questData = objectiveData.Quest[questIndex]
        local questWindowString = "EA_Window_BattlefieldObjectiveTrackerMainQuest"..questIndex
        if DataUtils.activeObjectivesData ~= nil then
          if (DataUtils.activeObjectivesData[GameData.ActiveObjectives.updatedObjectiveIndex] ~= nil) then
          if ( questData ~= nil and DataUtils.activeObjectivesData[GameData.ActiveObjectives.updatedObjectiveIndex].isBattlefieldObjective )
          then
            -- DEBUG(L"Made it through 03")    
            
            WindowSetShowing( questWindowString, true )
            --DEBUG(L"  Quest #"..questIndex..L" '"..GameData.ActiveObjectives[objective].Quest[questIndex].name..L"'")
            
            -- Quest name            
            local questName = DataUtils.activeObjectivesData[objective].Quest[questIndex].name
            WindowSetDimensions( trackerWindow.."ActionLabel", EA_Window_BattlefieldObjectiveTracker.ACTION_LABEL_WIDTH, EA_Window_BattlefieldObjectiveTracker.ACTION_LABEL_HEIGHT )
            LabelSetText( trackerWindow.."ActionLabel", questName )
            local x, _ = LabelGetTextDimensions( trackerWindow.."ActionLabel" )
            if( x < EA_Window_BattlefieldObjectiveTracker.ACTION_LABEL_WIDTH )
            then
                WindowSetDimensions( trackerWindow.."ActionLabel", x + 15, EA_Window_BattlefieldObjectiveTracker.ACTION_LABEL_HEIGHT )
                LabelSetText( trackerWindow.."ActionLabel", questName )
            end

            EA_Window_BattlefieldObjectiveTracker.UpdateQuestTimer()          
          
            -- Conditions
            for index, data in ipairs(questData.conditions)
            do
                local conditionName = data.name
                local curCounter    = data.curCounter
                local maxCounter    = data.maxCounter
                local isFailureCondition = data.failureCondition
                
                local nameLabel    = questWindowString.."DataCondition"..index.."Name"
                local counterLabel = questWindowString.."DataCondition"..index.."Counter"

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
                
            end
            
            for index = #questData.conditions + 1, EA_Window_BattlefieldObjectiveTracker.NUM_CONDITION_COUNTERS
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
        end
    end        
    -- DEBUG(L"Made it through 07 - exiting")
    EA_Window_BattlefieldObjectiveTracker.UpdateObjectiveDimensions(objective)

end


function EA_Window_BattlefieldObjectiveTracker.MouseOverQuest()

    local objective  = 1
    local questIndex = 1
    -- DEBUG(L"EA_Window_BattlefieldObjectiveTracker.MouseOverQuest - ActiveObjective Index = "..objective..L", quest index = "..questIndex )

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
    text = GetString( StringTables.Default.LABEL_BATTLEFIELD_OBJECTIVE ) 
    Tooltips.SetTooltipText( row, column, text )
    Tooltips.SetTooltipColor( row, column, 100, 100, 100)
    
    row = row + 1
    
    -- Text
    local text = questData.desc
    Tooltips.SetTooltipText( row, column, text )
    row = row + 1
    column = 1
    

    Tooltips.Finalize()
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT )   
end

