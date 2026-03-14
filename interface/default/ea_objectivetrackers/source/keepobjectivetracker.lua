----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_KeepObjectiveTracker = {}

EA_Window_KeepObjectiveTracker.EMPTY_SIZE = { x=600, y=200 } -- Used to provide a size guide for the layout editor.

EA_Window_KeepObjectiveTracker.NUM_OBJECTIVES = 1
EA_Window_KeepObjectiveTracker.NUM_QUESTS = 1
EA_Window_KeepObjectiveTracker.NUM_CONDITION_COUNTERS = 1

EA_Window_KeepObjectiveTracker.WIDTH = 600

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
    if ( ( index < 1 ) or ( index > EA_Window_KeepObjectiveTracker.NUM_OBJECTIVES ) )
    then
        --ERROR(L"Active objective #"..index..L" updated, the Keep Tracker only supports "..EA_Window_KeepObjectiveTracker.NUM_OBJECTIVES..L" objectives with "..EA_Window_KeepObjectiveTracker.NUM_QUESTS..L" quests")
        return true
    end
    return false
end

----------------------------------------------------------------
-- EA_Window_KeepObjectiveTracker Functions
----------------------------------------------------------------
-- OnInitialize Handler
function EA_Window_KeepObjectiveTracker.Initialize()

    LayoutEditor.RegisterWindow( "EA_Window_KeepObjectiveTracker",
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_KEEP_OBJECTIVE_TRACKER_WINDOW_NAME ),
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_KEEP_OBJECTIVE_TRACKER_WINDOW_DESC ),
                                false, false,
                                true, nil,
                                { "topleft", "top", "topright" } )
                                

    WindowRegisterEventHandler( "EA_Window_KeepObjectiveTracker", SystemData.Events.PUBLIC_QUEST_ADDED,   "EA_Window_KeepObjectiveTracker.OnQuestAdded")
    WindowRegisterEventHandler( "EA_Window_KeepObjectiveTracker", SystemData.Events.PUBLIC_QUEST_UPDATED, "EA_Window_KeepObjectiveTracker.OnQuestUpdated")
    WindowRegisterEventHandler( "EA_Window_KeepObjectiveTracker", SystemData.Events.PUBLIC_QUEST_REMOVED, "EA_Window_KeepObjectiveTracker.OnQuestRemoved")
    WindowRegisterEventHandler( "EA_Window_KeepObjectiveTracker", SystemData.Events.PUBLIC_QUEST_COMPLETED, "EA_Window_KeepObjectiveTracker.OnQuestCompleted")
    WindowRegisterEventHandler( "EA_Window_KeepObjectiveTracker", SystemData.Events.PUBLIC_QUEST_FAILED, "EA_Window_KeepObjectiveTracker.OnQuestFailed")
    WindowRegisterEventHandler( "EA_Window_KeepObjectiveTracker", SystemData.Events.PUBLIC_QUEST_RESETTING, "EA_Window_KeepObjectiveTracker.OnQuestResetting")
    WindowRegisterEventHandler( "EA_Window_KeepObjectiveTracker", SystemData.Events.PUBLIC_QUEST_OPTOUT, "EA_Window_KeepObjectiveTracker.OnQuestOptOut")
    WindowRegisterEventHandler( "EA_Window_KeepObjectiveTracker", SystemData.Events.PUBLIC_QUEST_FORCEDOUT, "EA_Window_KeepObjectiveTracker.OnQuestForcedOut")

    WindowRegisterEventHandler( "EA_Window_KeepObjectiveTracker", SystemData.Events.INTERFACE_RELOADED,           "EA_Window_KeepObjectiveTracker.Refresh" )
    WindowRegisterEventHandler( "EA_Window_KeepObjectiveTracker", SystemData.Events.PLAYER_ZONE_CHANGED,          "EA_Window_KeepObjectiveTracker.Refresh" )
    WindowRegisterEventHandler( "EA_Window_KeepObjectiveTracker", SystemData.Events.CAMPAIGN_ZONE_UPDATED,        "EA_Window_KeepObjectiveTracker.OnCampaignZoneUpdated")
    WindowRegisterEventHandler( "EA_Window_KeepObjectiveTracker", SystemData.Events.CAMPAIGN_PAIRING_UPDATED,     "EA_Window_KeepObjectiveTracker.OnCampaignPairingUpdated")
    
    LabelSetText("EA_Window_KeepObjectiveTrackerLockedText", GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.TEXT_BATTLEFIELD_LOCKEDZONE) )
    
    WindowSetShowing("EA_Window_KeepObjectiveTrackerLocked", false)
    
    -- Initialize the Opt Out Options Context Menu
    TrackerUtils.CreateOptOutContextMenuItems( "EA_Window_KeepObjectiveTracker" )  
    
    EA_Window_KeepObjectiveTracker.UpdateFullList()
    
end

-- OnUpdate Handler
function EA_Window_KeepObjectiveTracker.Update( timePassed )
    EA_Window_KeepObjectiveTracker.UpdateTimer()
end

-- OnShutdown Handler
function EA_Window_KeepObjectiveTracker.Shutdown()

end

function EA_Window_KeepObjectiveTracker.Refresh()
    EA_Window_KeepObjectiveTracker.UpdateTracker()
end

function EA_Window_KeepObjectiveTracker.OnCampaignZoneUpdated( zoneId )
    if( zoneId == GameData.Player.zone )
    then
        EA_Window_KeepObjectiveTracker.UpdateTracker()
    end
end

function EA_Window_KeepObjectiveTracker.OnCampaignPairingUpdated( pairingId )
    EA_Window_KeepObjectiveTracker.UpdateTracker()
end

----------------------------------------------------------------
-- Opt Out Options
----------------------------------------------------------------

function EA_Window_KeepObjectiveTracker.OnLButtonUpOptOut()
    if( SystemData.ActiveWindow.name == nil or SystemData.ActiveWindow.name == "" ) then
        return
    end
    
    if(ButtonSetDisabledFlag(SystemData.ActiveWindow.name) == true)
    then
        return
    end
    
    -- The Keep Objective Tracker only knows about 1 objective with 1 quest
    local index = 1

    if (CheckObjectiveOutOfRange(index))
    then
        return
    end    
            
    EA_Window_ContextMenu.CreateContextMenu( SystemData.ActiveWindow.name ) 
    
    -- None
    ButtonSetPressedFlag("EA_Window_KeepObjectiveTrackerOptOutNoneCheckBox", TrackerUtils.ShouldOptOutOptionBeChecked(index, TrackerUtils.OPT_OUT_OPTION_NONE))
    EA_Window_ContextMenu.AddUserDefinedMenuItem("EA_Window_KeepObjectiveTrackerOptOutNone")
    
    -- All (Loot and Gold Bags)
    ButtonSetPressedFlag("EA_Window_KeepObjectiveTrackerOptOutAllCheckBox", TrackerUtils.ShouldOptOutOptionBeChecked(index, TrackerUtils.OPT_OUT_OPTION_ALL))
    EA_Window_ContextMenu.AddUserDefinedMenuItem("EA_Window_KeepObjectiveTrackerOptOutAll")
    
    -- Gold Bags Only
    ButtonSetPressedFlag("EA_Window_KeepObjectiveTrackerOptOutGoldCheckBox", TrackerUtils.ShouldOptOutOptionBeChecked(index, TrackerUtils.OPT_OUT_OPTION_GOLD))
    EA_Window_ContextMenu.AddUserDefinedMenuItem("EA_Window_KeepObjectiveTrackerOptOutGold")
    
    EA_Window_ContextMenu.Finalize()
    
    WindowSetId("EA_Window_KeepObjectiveTrackerOptOutNone", index)
    WindowSetId("EA_Window_KeepObjectiveTrackerOptOutAll", index)
    WindowSetId("EA_Window_KeepObjectiveTrackerOptOutGold", index)
end

function EA_Window_KeepObjectiveTracker.ToggleOptOutOptionNone()    

    local index = WindowGetId( SystemData.ActiveWindow.name )
    if (CheckObjectiveOutOfRange(index))
    then
        return
    end    
    
    TrackerUtils.SetOptOutOption( SystemData.ActiveWindow.name, index, TrackerUtils.OPT_OUT_OPTION_NONE )    
end

function EA_Window_KeepObjectiveTracker.ToggleOptOutOptionAll()     

    local index = WindowGetId( SystemData.ActiveWindow.name )
    if (CheckObjectiveOutOfRange(index))
    then
        return
    end    
    
    TrackerUtils.SetOptOutOption( SystemData.ActiveWindow.name, index, TrackerUtils.OPT_OUT_OPTION_ALL )    
end

function EA_Window_KeepObjectiveTracker.ToggleOptOutOptionGold()   

    local index = WindowGetId( SystemData.ActiveWindow.name )
    if (CheckObjectiveOutOfRange(index))
    then
        return
    end    
      
    TrackerUtils.SetOptOutOption( SystemData.ActiveWindow.name, index, TrackerUtils.OPT_OUT_OPTION_GOLD )    
end

function EA_Window_KeepObjectiveTracker.OnQuestOptOut(index, optOut)
   
    if (CheckObjectiveOutOfRange(index))
    then
        return
    end

    DataUtils.activeObjectivesData[index].optedOutForLoot = optOut
end

function EA_Window_KeepObjectiveTracker.OnQuestForcedOut(index, forcedOut)

    if (CheckObjectiveOutOfRange(index))
    then
        return
    end
    
    ButtonSetDisabledFlag( "EA_Window_KeepObjectiveTrackerOptOutButton", forcedOut )

    DataUtils.activeObjectivesData[index].forcedOutForLoot = forcedOut
end

----------------------------------------------------------------
-- Quests
----------------------------------------------------------------
function EA_Window_KeepObjectiveTracker.OnQuestAdded() 
    DataUtils.activeObjectivesData = GetActiveObjectivesData()
    local index = GameData.ActiveObjectives.updatedObjectiveIndex
    
    -- DEBUG(L"EA_Window_KeepObjectiveTracker.OnQuestAdded: index="..index )
    
    if (not DataUtils.activeObjectivesData[index].isKeep)
    then
        return
    end

    if (CheckObjectiveOutOfRange(index))
    then
        return
    end
    
    -- Update the Window to Include the new objective       
    EA_Window_KeepObjectiveTracker.UpdateTracker( )
    
    -- Sound
    Sound.Play( Sound.PUBLIC_QUEST_ADDED )
    
end

function EA_Window_KeepObjectiveTracker.OnQuestResetting()
    DataUtils.activeObjectivesData = GetActiveObjectivesData()
    -- DEBUG(L"EA_Window_KeepObjectiveTracker.OnQuestResetting" )

    local index = GameData.ActiveObjectives.updatedObjectiveIndex
    
    if (CheckObjectiveOutOfRange(index))
    then
        return
    end
    
    local showing = WindowGetShowing( "EA_Window_KeepObjectiveTracker" )
    
    if ( showing == false )
    then
    
        -- Sound
        Sound.Play( Sound.PUBLIC_QUEST_CYCLING )

    end
    
end

function EA_Window_KeepObjectiveTracker.OnQuestUpdated() 
    DataUtils.activeObjectivesData = GetActiveObjectivesData()
    -- DEBUG(L"EA_Window_KeepObjectiveTracker.OnQuestUpdated" )

    local index = GameData.ActiveObjectives.updatedObjectiveIndex
    
    if (CheckObjectiveOutOfRange(index))
    then
        return
    end
    
    -- Update the Window to Include the new objective       
    EA_Window_KeepObjectiveTracker.UpdateTracker( )
end


function EA_Window_KeepObjectiveTracker.OnQuestRemoved()
    DataUtils.activeObjectivesData = GetActiveObjectivesData()
    
    local index = GameData.ActiveObjectives.updatedObjectiveIndex
    -- DEBUG(L"EA_Window_KeepObjectiveTracker.OnQuestRemoved() index = "..index)

    if (CheckObjectiveOutOfRange(index))
    then
        return
    end
    
    -- Update the windows
    EA_Window_KeepObjectiveTracker.UpdateTracker( )
    
end

function EA_Window_KeepObjectiveTracker.OnQuestCompleted()
    -- DEBUG(L"EA_Window_KeepObjectiveTracker.OnQuestCompleted()")
    DataUtils.activeObjectivesData = GetActiveObjectivesData()
    -- Sound
    Sound.Play( Sound.PUBLIC_QUEST_COMPLETED )
end

function EA_Window_KeepObjectiveTracker.OnQuestFailed()
    -- DEBUG(L" **EA_Window_KeepObjectiveTracker.OnQuestFailed" )
    DataUtils.activeObjectivesData = GetActiveObjectivesData()
    -- Sound
    Sound.Play( Sound.PUBLIC_QUEST_FAILED )
end

-- This is only called on initialization to populate the window without any state changing animations
function EA_Window_KeepObjectiveTracker.UpdateFullList()

    -- DEBUG(L"EA_Window_KeepObjectiveTracker.UpdateFullList()")
    --DataUtils.activeObjectivesData = GetActiveObjectivesData()

    for objective = 1, EA_Window_KeepObjectiveTracker.NUM_OBJECTIVES
    do

        local isObjectiveValid = false

        for questIndex = 1, EA_Window_KeepObjectiveTracker.NUM_QUESTS
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
    
            WindowSetShowing( "EA_Window_KeepObjectiveTrackerDuringActionQuest", isQuestValid )
            
            isObjectiveValid = isObjectiveValid or isQuestValid
        end
        
        if( isObjectiveValid )
        then
            EA_Window_KeepObjectiveTracker.UpdateTracker( )
        else
            LayoutEditor.Hide( "EA_Window_KeepObjectiveTracker" )
        end     

    end     
        
end


-- Updates the Quest & Condition Data for an Objective
function EA_Window_KeepObjectiveTracker.UpdateTracker()
    --DEBUG(L"EA_Window_KeepObjectiveTracker.UpdateTracker()")

    local objective = 1
        
    local objectiveData         = DataUtils.activeObjectivesData[objective]
    local trackerWindow         = "EA_Window_KeepObjectiveTracker"
    local lockedWindow          = "EA_Window_KeepObjectiveTrackerLocked"

    local useKeepTracker = objectiveData ~= nil and
                           objectiveData.isKeep and
                           not GameData.Player.isInScenario
                                  
    if ( not useKeepTracker )
    then
        LayoutEditor.Hide( trackerWindow )
        return
    end

    LayoutEditor.Show( trackerWindow )    

    -- DEBUG(L"  : #"..objectiveData.id..L" '"..objectiveData.name..L"' control = "..GameData.ActiveObjectives[1].curControlPoints )

    -- Set opt out flag; if the player is forced out, disable the opt out button
    ButtonSetDisabledFlag( trackerWindow.."OptOutButton", objectiveData.forcedOutForLoot )
    
    local objectiveID = objectiveData.id
    
    -- Capture ownership and state
    local iconWindow = trackerWindow.."OwnerIcon"
    local owner = TrackerUtils.GetKeepSliceForOwner(objectiveData.controllingRealm)
    DynamicImageSetTextureSlice(iconWindow, owner)
    
    -- Location name
    local name = DataUtils.activeObjectivesData[objective].name
    LabelSetText(trackerWindow.."Label", name )
    
    -- Check for zone lock.
    local zoneData = GetCampaignZoneData( GameData.Player.zone )  
    if(objectiveData.isFortress == true)
    then
        WindowSetShowing( "EA_Window_KeepObjectiveTrackerOptOutButton", true )
        WindowSetShowing( lockedWindow, false )
    else
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
            
            WindowSetShowing( "EA_Window_KeepObjectiveTrackerOptOutButton", false )
            WindowSetShowing( lockedWindow,          true )
            return
        else
            WindowSetShowing( "EA_Window_KeepObjectiveTrackerOptOutButton", true )
            WindowSetShowing( lockedWindow,          false )
        end
    end
    
    
    -- Quests
    for questIndex = 1, EA_Window_KeepObjectiveTracker.NUM_QUESTS
    do
        -- DEBUG(L"Made it through 02")
        local questData = objectiveData.Quest[questIndex]
        local questWindowString = "EA_Window_KeepObjectiveTrackerDuringActionQuest"
        
        local count = 0
        for _ in pairs(DataUtils.activeObjectivesData) do count = count + 1 end
        
        if (DataUtils.activeObjectivesData~=nil) and (count~=0) then 
	  if (DataUtils.activeObjectivesData[GameData.ActiveObjectives.updatedObjectiveIndex] ~= nil) then 
            if ( questData ~= nil and DataUtils.activeObjectivesData[GameData.ActiveObjectives.updatedObjectiveIndex].isKeep )
            then

              local questName = questData.name
              LabelSetText( questWindowString, questName )            
              LabelSetTextColor(questWindowString, CompleteCounterColor.r, CompleteCounterColor.g, CompleteCounterColor.b)
        
            -- DEBUG(L"Made it through 03")    
            
              WindowSetShowing( questWindowString, true )
            --DEBUG(L"  Quest #"..questIndex..L" '"..GameData.ActiveObjectives[objective].Quest[questIndex].name..L"'")
            
            -- Quest name            
              local questName = DataUtils.activeObjectivesData[objective].Quest[questIndex].name

            -- Conditions
              for index, data in ipairs(questData.conditions)
              do
                local conditionName = data.name
                local nameLabel     = questWindowString

                -- Only show the conditions if conditionName is not empty
                if( conditionName ~= L"" )
                then
                    LabelSetText( nameLabel, conditionName )            
                    LabelSetTextColor(nameLabel, IncompleteCounterColor.r, IncompleteCounterColor.g, IncompleteCounterColor.b)
                end
              end
            
            else
              WindowSetShowing(questWindowString, false)
            end
          end
        end
    end        
    -- DEBUG(L"Made it through 07 - exiting")

end

function EA_Window_KeepObjectiveTracker.UpdateTimer()
    local timerContainerWindow = "EA_Window_KeepObjectiveTrackerDuringAction"
    
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

----------------------------------------------------------------
-- Tooltips
----------------------------------------------------------------

function EA_Window_KeepObjectiveTracker.MouseOverQuest()

    local objective  = 1
    local questIndex = 1
    -- DEBUG(L"EA_Window_KeepObjectiveTracker.MouseOverQuest - ActiveObjective Index = "..objective..L", quest index = "..questIndex )

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
    row = row + 1
    
    -- Text
    local text = questData.desc
    Tooltips.SetTooltipText( row, column, text )
    row = row + 1
    column = 1
    

    Tooltips.Finalize()
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT )   
end