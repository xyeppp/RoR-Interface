----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

QuestUtils = {}


QuestUtils.OFFERED_QUEST_ICON  = { texture="map_markers01", x=512, y=53, width=32, height=32 }
QuestUtils.OFFERED_REPEATABLE_QUEST_ICON = { texture="map_markers01", x=636, y=265, width=32, height=32 }
QuestUtils.PENDING_QUEST_ICON  = { texture="map_markers01", x=704, y=195, width=32, height=32 }
QuestUtils.COMPLETE_QUEST_ICON = { texture="map_markers01", x=512, y=149, width=32, height=32 }
QuestUtils.ACTIVE_QUEST_ICON  = { texture="map_markers01", x=544, y=53, width=32, height=32 }


QuestUtils.NUM_QUEST_TYPE_ICONS = 6
QuestUtils.MAX_CONDITIONS = 10

----------------------------------------------------------------
-- Global Functions
----------------------------------------------------------------

function QuestUtils.NewTrackerData( qstId, timer, details )
    return { questId=qstId, hasTimer=timer, showDetails=details, updated=false, completed=false } 
end

function QuestUtils.SetCompletionIcon( questData, dynamicImageWindowName )
    
    -- While a quest may have multiple types, the design only calls for displaying one.
    local isComplete = QuestUtils.IsQuestComplete( questData )
    if (isComplete)
    then
        DynamicImageSetTextureSlice(dynamicImageWindowName, "QuestCompleted-Gold")
    else
        local slice = QuestUtils.GetSliceForType(questData.questTypes)
        DynamicImageSetTextureSlice(dynamicImageWindowName, slice)
    end

end

-- These magic number correspond to entries in MapIcons.xml
function QuestUtils.GetSliceForType( questTypes )
    local slice = "QuestActive"

    if questTypes ~= nil
    then
    
        if (questTypes[GameData.QuestTypes.EPIC])
        then
            slice = "QuestEpic"
        elseif (questTypes[GameData.QuestTypes.TOME])
        then
            slice = "QuestTome"
        elseif (questTypes[GameData.QuestTypes.PLAYER_KILL])
        then
            slice = "QuestRVRkill"
        elseif (questTypes[GameData.QuestTypes.GROUP] and questTypes[GameData.QuestTypes.RVR])
        then
            slice = "QuestRVRGroup"
        elseif (questTypes[GameData.QuestTypes.GROUP])
        then
            slice = "QuestGroup"
        elseif (questTypes[GameData.QuestTypes.TRAVEL])
        then
            slice = "QuestMovement"
        elseif (questTypes[GameData.QuestTypes.RVR])
        then
            slice = "QuestRVR"
        end
        
    end
    
    return slice
end

function QuestUtils.GetQuestTypeStringFromTypes( questTypes )

    if questTypes ~= nil
    then
        
        if (questTypes[GameData.QuestTypes.EPIC])
        then
            return GetString( StringTables.Default.LABEL_EPIC_QUEST )
            
        elseif (questTypes[GameData.QuestTypes.TOME])
        then
            return GetString( StringTables.Default.LABEL_TOME_QUEST )
            
        elseif (questTypes[GameData.QuestTypes.PLAYER_KILL])
        then
            return GetString( StringTables.Default.LABEL_KILL_PLAYER_QUEST )
            
        elseif (questTypes[GameData.QuestTypes.GROUP] and questTypes[GameData.QuestTypes.RVR])
        then
            return GetString( StringTables.Default.LABEL_RVR_QUEST )
            
        elseif (questTypes[GameData.QuestTypes.GROUP])
        then
            return GetString( StringTables.Default.LABEL_GROUP_QUEST )
            
        elseif (questTypes[GameData.QuestTypes.TRAVEL])
        then
            return GetString( StringTables.Default.LABEL_TRAVEL_QUEST )
            
        elseif (questTypes[GameData.QuestTypes.RVR])
        then
            return GetString( StringTables.Default.LABEL_RVR_QUEST )
        end
        
    end
    
    return L""
end


function QuestUtils.SetQuestTypeIcon( iconID, dynamicImageWindowName )
    if( iconID == nil or iconID == -1 or dynamicImageWindowName == nil or dynamicImageWindowName == "" )
    then
        return
    end
    
    local color = DefaultColor.WHITE
    if( iconID == GameData.QuestTypes.GROUP )
    then
        color = DefaultColor.BLUE
    elseif( iconID == GameData.QuestTypes.TRAVEL )
    then
        color = DefaultColor.GREEN
    elseif( iconID == GameData.QuestTypes.PLAYER_KILL )
    then
        color = DefaultColor.RED
    elseif( iconID == GameData.QuestTypes.RVR )
    then
        color = DefaultColor.YELLOW
    elseif( iconID == GameData.QuestTypes.TOME )
    then
        color = DefaultColor.BROWN
    elseif( iconID == GameData.QuestTypes.EPIC )
    then
        color = DefaultColor.PURPLE
    end
    DefaultColor.SetWindowTint( dynamicImageWindowName, color )
end

function QuestUtils.GetQuestTypeString( iconID )
    if( iconID == nil or iconID == -1 )
    then
        return L""
    end

    if( iconID == GameData.QuestTypes.GROUP )
    then
        return GetString( StringTables.Default.LABEL_GROUP_QUEST )
    elseif( iconID == GameData.QuestTypes.TRAVEL )
    then
        return GetString( StringTables.Default.LABEL_TRAVEL_QUEST )
    elseif( iconID == GameData.QuestTypes.PLAYER_KILL )
    then
        return GetString( StringTables.Default.LABEL_KILL_PLAYER_QUEST )
    elseif( iconID == GameData.QuestTypes.RVR )
    then
        return GetString( StringTables.Default.LABEL_RVR_QUEST )
    elseif( iconID == GameData.QuestTypes.TOME )
    then
        return GetString( StringTables.Default.LABEL_TOME_QUEST )
    elseif( iconID == GameData.QuestTypes.EPIC )
    then
        return GetString( StringTables.Default.LABEL_EPIC_QUEST )
    else
        return L""
    end
end

function QuestUtils.IsQuestComplete( questData )
    if (questData == nil)
    then
        return false
    end
    
    if (questData.complete)
    then
        return true
    end
    
    local conditionsComplete = true
    
    for conditionIndex, condition in ipairs(questData.conditions)
    do
        if (condition.maxCounter == 0)
        then
            conditionsComplete = false
            break
        elseif (condition.maxCounter > 0) and (condition.curCounter < condition.maxCounter)
        then
            conditionsComplete = false
            break
        end
    end
    
    return conditionsComplete
end

function QuestUtils.SetQuestTypeIcons( questData, iconImageBase )

    if (not DoesWindowExist(iconImageBase.."1"))
    then
        return
    end
    
    local iconIndex = 1    
    
    -- Set the Icon for each quest type
    if( questData and questData.questTypes )
    then
        for questType, enabled in ipairs( questData.questTypes )
        do
            if( enabled )
            then
                -- DEBUG(L" ["..index..L"] = "..questType )
                QuestUtils.SetQuestTypeIcon( questType, iconImageBase..iconIndex )
                WindowSetShowing( iconImageBase..iconIndex, true )
                iconIndex = iconIndex + 1
             end
        end
    end
    
    -- DEBUG(L" Num Icons = "..iconIndex-1 )
    
    
    -- Hide all the extra icon slots
    while( iconIndex <= QuestUtils.NUM_QUEST_TYPE_ICONS )
    do        
        WindowSetShowing( iconImageBase..iconIndex, false )
        iconIndex = iconIndex + 1
    end
end

function QuestUtils.CreateQuestTypeTooltip( questData, windowName )

    Tooltips.CreateTextOnlyTooltip ( windowName, nil )
    Tooltips.SetTooltipText( 1, 1, GetString( StringTables.Default.LABEL_QUEST_TYPE ) )
    Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
    
    
    -- Set the string for each quest type
    local lineNumber = 2
    for questType, enabled in ipairs( questData.questTypes )
    do
        if enabled
        then
            local typeName = QuestUtils.GetQuestTypeString( questType )    
            
            Tooltips.SetTooltipText( lineNumber + 1, 1, typeName )
            Tooltips.SetTooltipColorDef( lineNumber + 1, 1, Tooltips.COLOR_BODY )
            
            lineNumber = lineNumber + 1
        end
    end
    
    Tooltips.AnchorTooltip( Tooltips.VARIABLE_ANCHOR )
    Tooltips.Finalize()
end



-- Quest Tracker Functions

function QuestUtils.SetQuestTrackerData( window, questData, showDetails  )

    --DEBUG(L" QuestUtils.UpdateTrackerWindow - quest = "..quest )
        
    local questDataWidth  = 0
    local questDataHeight = titleOffset
    local conditionWidth  = 0
    
    if( questData == nil ) then
        WindowSetShowing( window, false )
        WindowSetDimensions( window, 0, 0 )
        return
    end
    
    WindowSetShowing( window, true )       
    
    local questDataHeight = 10

    -- Show the appropriate +/- button
    if( DoesWindowExist( window.."PlusButton" ) )
    then
        if( showDetails == true ) then
            WindowSetShowing(window.."PlusButton", false )
            WindowSetShowing(window.."MinusButton", true )
        else
            WindowSetShowing(window.."PlusButton", true )
            WindowSetShowing(window.."MinusButton", false )
        end
    end

    -- Name
    ButtonSetText(window.."Name", questData.name )
    local x, y = WindowGetDimensions( window.."Name" )
    questDataHeight = questDataHeight + y

    -- Timer    
    if( questData.maxTimer ~= 0 ) then                
        
        local time = TimeUtils.FormatClock( questData.timeLeft )
        LabelSetText( window.."TimerValue", time )        
        WindowSetShowing( window.."TimerValue", true )
        
        WindowSetShowing( window.."ClockImage", true )
        
        -- Only show the timer name if the quest is expanded
        if( showDetails == true ) then 
            LabelSetText( window.."TimerName", L"" )
            local x, y = LabelGetTextDimensions( window.."TimerName" )
            questDataHeight = questDataHeight + y
        else
            LabelSetText( window.."TimerName", L"" )
        end               
    
    else            
        LabelSetText( window.."TimerValue", L"" )      
        LabelSetText( window.."TimerName", L"" )
        WindowSetShowing( window.."TimerValue", false )  
        WindowSetShowing( window.."ClockImage", false )
    end
    
    -- Icons
    QuestUtils.SetQuestTypeIcons( questData, window.."BulletImage" )
   
    -- Conditions
    for condition, conditionData in ipairs(questData.conditions)
    do
    
        local conditionName = conditionData.name
        local curCounter    = conditionData.curCounter
        local maxCounter    = conditionData.maxCounter
        
        local nameLabel    = window.."Condition"..condition.."Name"
        local counterLabel = window.."Condition"..condition.."Counter"
                    
                    
        -- Only show the conditions if we are vieiwing details
        local conditionHeight = 0
        if (conditionName ~= L"" )
        then            
            
            LabelSetText( nameLabel, conditionName )            
            if( maxCounter > 0 )
            then
                LabelSetText( counterLabel, L""..curCounter..L"/"..maxCounter )
            else
                LabelSetText( counterLabel, L"" )
            end
            
            local x, y = WindowGetDimensions( nameLabel )
            conditionHeight = y      
               
        else
            LabelSetText( nameLabel, L"" )
            LabelSetText( counterLabel, L"" )
        end
        
        
        if( conditionName ~= L"" and showDetails  ) then
            WindowSetShowing(window.."Condition"..condition, true )
            
            local x, y = WindowGetDimensions( window.."Condition"..condition )
            WindowSetDimensions( window.."Condition"..condition, x, conditionHeight )
            
            questDataHeight = questDataHeight + conditionHeight + 2
        else
            WindowSetShowing(window.."Condition"..condition, false )
        end
        
    end
    
    
    local x, y = WindowGetDimensions( window )    
    WindowSetDimensions( window, x, questDataHeight )            
            
end

function QuestUtils.MouseOverQuestTracker(	trackerName, questId )

    local questData = DataUtils.GetQuestData( questId )   

    --DEBUG( L"QuestTrackerWindow.MouseOverQuest " .. StringToWString( SystemData.ActiveWindow.name ) .. L" - " .. questData.id )	
    
    local row = 1
    local column = 1

    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, nil )	

    -- Quest Name
    local text = questData.name	
    Tooltips.SetTooltipText( row, column, text )
    Tooltips.SetTooltipColorDef( row, column, Tooltips.COLOR_HEADING )	

    --[[
    -- Complete Text
    column = column + 1	
    if( questData.complete == true ) then
        text = GetString( StringTables.Default.LABEL_COMPLETE )			
        Tooltips.SetTooltipColor( row, column, CompleteCounterColor.r, CompleteCounterColor.g, CompleteCounterColor.b)
        Tooltips.SetTooltipText( row, column, text )
    end
    
    --]]
    
    row = row + 1
    column = 1

    -- Quest Text
    local text = questData.journalDesc
    Tooltips.SetTooltipText( row, column, text )
    row = row + 1
    column = 1

    -- Open Tome Text
    Tooltips.SetTooltipActionText( GetString( StringTables.Default.TEXT_OPEN_TO_QUEST_ENTRY ) )

    Tooltips.Finalize()
    
    local anchor = { Point="topleft", RelativeTo=trackerName, RelativePoint="topright", XOffset=-4, YOffset=0 }
    Tooltips.AnchorTooltip( anchor )
end

function QuestUtils.OpenTomeForQuest( questId )

    --DEBUG( L"Opening Tome to Quest: "..questId )
    
    -- If we are clicking the same quest button, hide the Tome
    if( WindowGetShowing( "TomeWindow" ) == false  ) then	   	    
        MenuBarWindow.ToggleTomeWindow()	
    elseif( TomeWindow.IsShowingQuest( questId ) == true ) then
        MenuBarWindow.ToggleTomeWindow()	
        return  
    end
    TomeWindow.OpenToQuest( questId )
end


function QuestUtils.ToggleTrackQuest( questId )
    if( questId == nil )
    then        
        ERROR(L"Invalid params to QuestUtils.ToggleTrackQuest( questId ): questId is nil")
        return
    end

    local questData = DataUtils.GetQuestData( questId )
    if( questData == nil )
    then        
        ERROR(L"Error in QuestUtils.ToggleTrackQuest( questId ): questId "..questId..L" not found" )
        return
    end

    -- TODO: Fix this so it does not depend on the QuestTracker
    if( EA_Window_QuestTracker.IsTrackerFull() and questData.tracking == false )
    then        
        ButtonSetPressedFlag(SystemData.ActiveWindow.name, false )
        local text = GetStringFormat( StringTables.Default.TEXT_MAX_QUESTS_TRACKS, { QuestTrackerWindow.GetMaxQuests() } )
        AlertTextWindow.AddLine( SystemData.AlertText.Types.STATUS_ERRORS, text )
        return
    end

    SetTrackQuest( questData.id, not questData.tracking )
end


function QuestUtils.ToggleTrackQuestMapPin( questId )

    if( questId == nil )
    then
        ERROR(L"Invalid params to QuestUtils.ToggleTrackQuestMapPin( questId ): questId is nil")
        return
    end

    local questData = DataUtils.GetQuestData( questId )
    if( questData == nil )
    then        
        ERROR(L"Error in QuestUtils.ToggleTrackQuestMapPin( questId ): questId "..questId..L" not found" )
        return
    end
    
    SetTrackQuestPin( questData.id, not questData.trackingPin  )
    
end
