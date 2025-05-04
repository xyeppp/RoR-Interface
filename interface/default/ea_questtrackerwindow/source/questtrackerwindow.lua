----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_QuestTracker    = {}
EA_Window_QuestTrackerNub = {}

EA_Window_QuestTracker.conditionWidth = 0
EA_Window_QuestTracker.questDataWidth = 0

EA_Window_QuestTracker.minWidth = 0

EA_Window_QuestTracker.MAX_TRACKED_QUESTS = 10
EA_Window_QuestTracker.EMPTY_SIZE = { x=330, y=200 }
EA_Window_QuestTracker.BUFFER_FRAME = { x=10, y=10 }

EA_Window_QuestTracker.QUEST_NAME_OFFSET        = 35
EA_Window_QuestTracker.MIN_CONDITION_HEIGHT     = 16

EA_Window_QuestTracker.TIMER_WIDTH = 85
EA_Window_QuestTracker.CLOCK_WIDTH  = 20
EA_Window_QuestTracker.CLOCK_HEIGHT = 20
EA_Window_QuestTracker.COUNTER_WIDTH = 115
EA_Window_QuestTracker.QUEST_TITLE_OFFSET = 4
EA_Window_QuestTracker.QUEST_SPACING = 10
EA_Window_QuestTracker.NEVER_FADE  = -1

EA_Window_QuestTracker.currentData = {}


----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

----------------------------------------------------------------
-- Saved Variables
----------------------------------------------------------------
EA_Window_QuestTracker.Settings = {}

EA_Window_QuestTracker.Settings.isShowing = true
EA_Window_QuestTracker.Settings.fadeTime  = (30 * 60) -- seconds until quest fade out
EA_Window_QuestTracker.Settings.fadeData  = {}

EA_Window_QuestTracker.Settings.fadeAlpha = 0.7


----------------------------------------------------------------
-- Nub Toggling Functions
----------------------------------------------------------------
function EA_Window_QuestTrackerNub.Initialize()
    ButtonSetStayDownFlag("EA_Window_QuestTrackerNubButtonOpen",   true)
    ButtonSetStayDownFlag("EA_Window_QuestTrackerNubButtonClosed", true)
end

function EA_Window_QuestTrackerNub.ToggleWindow()
    EA_Window_QuestTracker.ToggleShowing()
    EA_Window_QuestTrackerNub.Refresh()
end

function EA_Window_QuestTrackerNub.Refresh()
    local isOpen = WindowGetShowing("EA_Window_QuestTracker")
    
    ButtonSetPressedFlag("EA_Window_QuestTrackerNubButtonOpen",   isOpen)
    ButtonSetPressedFlag("EA_Window_QuestTrackerNubButtonClosed", isOpen)
end

----------------------------------------------------------------
-- EA_Window_QuestTracker Functions
----------------------------------------------------------------

-- OnInitialize Handler
function EA_Window_QuestTracker.Initialize()

    LayoutEditor.RegisterWindow( "EA_Window_QuestTracker",
                                 GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_QUEST_TRACKER_WINDOW_NAME ),
                                 GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_QUEST_TRACKER_WINDOW_DESC ),
                                 false, false,
                                 true, nil,
                                 { "topleft", "topright", } )

    LayoutEditor.RegisterWindow( "EA_Window_QuestTrackerNub",
                                 GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_QUEST_TRACKER_NUB_WINDOW_NAME ),
                                 GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_QUEST_TRACKER_NUB_WINDOW_DESC ),
                                 false, false,
                                 true, nil )
                                
    WindowRegisterEventHandler( "EA_Window_QuestTracker", SystemData.Events.QUEST_LIST_UPDATED, "EA_Window_QuestTracker.OnQuestListUpdated")
    WindowRegisterEventHandler( "EA_Window_QuestTracker", SystemData.Events.QUEST_INFO_UPDATED, "EA_Window_QuestTracker.OnQuestUpdated")   
    
    EA_Window_QuestTracker.OnQuestListUpdated()
    
    if ( EA_Window_QuestTracker.Settings.isShowing )
    then
        LayoutEditor.Show( "EA_Window_QuestTracker" )
    else
        LayoutEditor.Hide( "EA_Window_QuestTracker" )
    end
    EA_Window_QuestTrackerNub.Refresh()
end

function EA_Window_QuestTracker.InitializeLayout()
    EA_Window_QuestTracker.UpdateWindowSize()
end

-- OnUpdate Handler
function EA_Window_QuestTracker.Update( timePassed )

    -- Update the timers
    for index, data in ipairs( EA_Window_QuestTracker.currentData )
    do
        if( data.hasTimer )
        then
        -- Timers are decremented by Data Utils
            local questData = DataUtils.GetQuestData( data.questId )
            local time = TimeUtils.FormatClock( questData.timeLeft )    
            LabelSetText( "EA_Window_QuestTrackerData"..index.."TimerValue", time )
        end
        
        if (EA_Window_QuestTracker.Settings.fadeData[data.questId])
        then
            if (EA_Window_QuestTracker.Settings.fadeData[data.questId].timer)
            then
                EA_Window_QuestTracker.Settings.fadeData[data.questId].timer = EA_Window_QuestTracker.Settings.fadeData[data.questId].timer + timePassed
            else
                EA_Window_QuestTracker.Settings.fadeData[data.questId] = { timer = timePassed }
            end
        else
            EA_Window_QuestTracker.Settings.fadeData[data.questId] = { timer = timePassed }
        end
    end 

    EA_Window_QuestTracker.UpdateFade()
end

-- OnShutdown Handler
function EA_Window_QuestTracker.Shutdown()

end

function EA_Window_QuestTracker.HasQuests()
    return EA_Window_QuestTracker.currentData[1] ~= nil
end

function EA_Window_QuestTracker.GetMaxQuests()
    return EA_Window_QuestTracker.MAX_TRACKED_QUESTS 
end

function EA_Window_QuestTracker.IsTrackerFull()
    return EA_Window_QuestTracker.currentData[EA_Window_QuestTracker.MAX_TRACKED_QUESTS] ~= nil   
end


function EA_Window_QuestTracker.ToggleShowing()
    if ( EA_Window_QuestTracker.Settings.isShowing )
    then
        LayoutEditor.Hide( "EA_Window_QuestTracker" )
        EA_Window_QuestTracker.Settings.isShowing = false
    else
        LayoutEditor.Show( "EA_Window_QuestTracker" )
        EA_Window_QuestTracker.Settings.isShowing = true
    end
    EA_Window_QuestTrackerNub.Refresh()
end

function EA_Window_QuestTracker.UpdateFade()

    for index, data in ipairs( EA_Window_QuestTracker.currentData )
    do
        if( EA_Window_QuestTracker.Settings.fadeData[data.questId] )
        then
            if (EA_Window_QuestTracker.Settings.fadeData[data.questId].override) or
               (EA_Window_QuestTracker.Settings.fadeTime == EA_Window_QuestTracker.NEVER_FADE)
            then
                WindowSetAlpha("EA_Window_QuestTrackerData"..index,     1.0)
                WindowSetFontAlpha("EA_Window_QuestTrackerData"..index, 1.0)
            elseif (EA_Window_QuestTracker.Settings.fadeData[data.questId].timer >= EA_Window_QuestTracker.Settings.fadeTime)
            then
                WindowSetAlpha("EA_Window_QuestTrackerData"..index,     EA_Window_QuestTracker.Settings.fadeAlpha)
                WindowSetFontAlpha("EA_Window_QuestTrackerData"..index, EA_Window_QuestTracker.Settings.fadeAlpha)
            end
        else
            -- What?  Start a new timer.
            EA_Window_QuestTracker.Settings.fadeData[data.questId] = { timer = 0 }
        end
    end 
    
end

-- Updates the entire list
function EA_Window_QuestTracker.OnQuestListUpdated()  
    
    -- DEBUG(L" ** EA_Window_QuestTracker.OnQuestListUpdated() ")

    -- Clear the data
    local index = 1
    local oldFadeData = {}

    -- Cache off the old tracker data to carry over the fadetimer values
    for index, value in pairs(EA_Window_QuestTracker.Settings.fadeData)
    do
        oldFadeData[index] = value
    end
    
    EA_Window_QuestTracker.currentData = {}
    EA_Window_QuestTracker.Settings.fadeData    = {}

    -- Build the list of currently tracked quests
    local tempQuests = DataUtils.GetQuests()
    for quest, questData in ipairs( tempQuests )
    do
        -- DEBUG(L" Quest #"..quest..L" = "..questData.name..L" maxTimer = "..questData.maxTimer ) 		
        if( questData.name ~= L"" and questData.tracking == true )
        then
            local id = questData.id
            local hasTimer = questData.maxTimer ~= 0
            local showDetails = true
            
            EA_Window_QuestTracker.currentData[index] = QuestUtils.NewTrackerData( id, hasTimer, showDetails )

            -- Carry over any fade timeout value that was attached to the quest.
            if (oldFadeData[id])
            then
                EA_Window_QuestTracker.Settings.fadeData[id] = { timer=oldFadeData[id].timer }
            else
                EA_Window_QuestTracker.Settings.fadeData[id] = { timer = 0 }
            end
            
            -- DEBUG(L" Quest Tracker #"..index..L" = "..questData.name )
            index = index + 1			
        end				
    end

    EA_Window_QuestTracker.conditionWidth = 0
    EA_Window_QuestTracker.questDataWidth = 0

    -- Update the display
    for quest = 1, EA_Window_QuestTracker.MAX_TRACKED_QUESTS
    do
        if( EA_Window_QuestTracker.currentData[quest] ~= nil )
        then       
            EA_Window_QuestTracker.UpdateTracker( quest )
        end             
        WindowSetShowing( "EA_Window_QuestTrackerData"..quest,  EA_Window_QuestTracker.currentData[quest]~= nil )               
    end     
        
    -- I have a bug somewhere in here that's causing the window not to be sized correctly the first time through
    EA_Window_QuestTracker.UpdateWindowSize()
    EA_Window_QuestTrackerNub.Refresh()
end

function EA_Window_QuestTracker.UpdateWindowSize()

    -- DEBUG(L"EA_Window_QuestTracker.UpdateWindowSize()")
    if( EA_Window_QuestTracker.currentData[1] == nil )
    then    
        -- Set the Empty size so the window container still appears for the layout editor.
        WindowSetDimensions( "EA_Window_QuestTracker", EA_Window_QuestTracker.EMPTY_SIZE.x, EA_Window_QuestTracker.EMPTY_SIZE.y)
        return
    end
          
    local height = 0
    local totalWidth = 0
    
    if( EA_Window_QuestTracker.questDataWidth - EA_Window_QuestTracker.conditionWidth ~= EA_Window_QuestTracker.QUEST_NAME_OFFSET )
    then
        EA_Window_QuestTracker.conditionWidth = EA_Window_QuestTracker.questDataWidth - EA_Window_QuestTracker.QUEST_NAME_OFFSET 
    end
    
    -- DEBUG(L" UPDATE Quest Data Width = "..EA_Window_QuestTracker.questDataWidth )
    -- DEBUG(L" UPDATE Quest Condition Width = "..EA_Window_QuestTracker.conditionWidth )
    

    -- Adjust all windows 
    for quest = 1, EA_Window_QuestTracker.MAX_TRACKED_QUESTS
    do
        local windowName = "EA_Window_QuestTrackerData"..quest
        -- Only update the window when it actually contains data
        if( WindowGetShowing(windowName) == true )
        then
 
            -- Resize the Quest Name - This is needed for the right corner anchors to work     
            -- on the conditions.
            local _, y = WindowGetDimensions( windowName.."Name" )
            
            WindowSetDimensions( windowName.."Name", EA_Window_QuestTracker.questDataWidth - EA_Window_QuestTracker.QUEST_NAME_OFFSET, y )

            local _, iconY = WindowGetDimensions( windowName.."TypeIcon" )
            
            -- DEBUG(L"  y = "..y..L", iconY = "..iconY)
            -- Start the height at the larger of the icon height and the name height 
            if (y < iconY)
            then
                y = iconY
            end
            
            -- Resize the Quest Data        
            local x, y = WindowGetDimensions( windowName )
            WindowSetDimensions( windowName, EA_Window_QuestTracker.questDataWidth, y )
            
            height = height + y
            if( quest > 1 )
            then
                height = height + EA_Window_QuestTracker.QUEST_SPACING
            end
        end
    
    end

    -- Size the tracker and container window.
    WindowSetDimensions( "EA_Window_QuestTracker",
                         EA_Window_QuestTracker.questDataWidth + EA_Window_QuestTracker.BUFFER_FRAME.x,
                         height + EA_Window_QuestTracker.BUFFER_FRAME.y)
    -- DEBUG(L" Width = "..(EA_Window_QuestTracker.questDataWidth+EA_Window_QuestTracker.BUFFER_FRAME.x)..L", Height = "..(height+EA_Window_QuestTracker.BUFFER_FRAME.y) )
    
end

function EA_Window_QuestTracker.OnQuestUpdated()  
    
    local questId = GameData.Player.Quests.updatedQuest
    -- DEBUG(L" EA_Window_QuestTracker.OnQuestUpdated - QuestId = "..questId )

    -- Find the index in the display
    for index, data in ipairs( EA_Window_QuestTracker.currentData )
    do
        if( data.questId == questId )
        then
            -- Reset the fade out when a condition steps.
            EA_Window_QuestTracker.ResetFade( index, data )
            EA_Window_QuestTracker.UpdateTracker( index )
            EA_Window_QuestTracker.UpdateWindowSize()
            return
        end
   end
   
end

function EA_Window_QuestTracker.UpdateTracker( quest )

    -- DEBUG(L" EA_Window_QuestTracker.UpdateTracker - quest = "..quest )
    
    if (EA_Window_QuestTracker.currentData[quest] == nil)
    then
        return
    end
        
    local questData = DataUtils.GetQuestData( EA_Window_QuestTracker.currentData[quest].questId )
    local window = "EA_Window_QuestTrackerData"..quest
    
    if( questData == nil )
    then
        WindowSetShowing( window, false )
        return
    end

    local questDataWidth  = 0
    local questDataHeight = 0
    local conditionWidth  = 0
    
    local showDetails = true

    -- Name
    ButtonSetText(window.."Name", questData.name )
    local questNameWidth, questNameHeight = WindowGetDimensions( window.."Name" )
    local _, iconY = WindowGetDimensions( window.."TypeIcon" )
    -- Start the height at the larger of the icon height and the name height 
    if (questNameHeight < iconY)
    then
        questNameHeight = iconY
    end
    -- DEBUG( L"Quest "..questData.name..L" Name dimensions: x="..questNameWidth..L", y="..questNameHeight )

    questDataHeight = questDataHeight + questNameHeight
    

    if( isComplete )
    then
        ButtonSetTextColor(window.."Name", Button.ButtonState.NORMAL, GameDefs.CompleteQuestTitleColor.r, GameDefs.CompleteQuestTitleColor.g, GameDefs.CompleteQuestTitleColor.b )
    else
        ButtonSetTextColor(window.."Name", Button.ButtonState.NORMAL, GameDefs.IncompleteQuestTitleColor.r, GameDefs.IncompleteQuestTitleColor.g, GameDefs.IncompleteQuestTitleColor.b)
    end
    
    -- Timer    
    if( questData.maxTimer ~= 0 )
    then                
        local time = TimeUtils.FormatClock( questData.timeLeft )
        LabelSetText( window.."TimerValue", time )        
        WindowSetShowing( window.."TimerValue", true )
        
        questDataWidth = questDataWidth + EA_Window_QuestTracker.TIMER_WIDTH
        WindowSetShowing( window.."ClockImage", true )
        WindowSetDimensions( window.."ClockImage", EA_Window_QuestTracker.CLOCK_WIDTH, EA_Window_QuestTracker.CLOCK_HEIGHT )
        
        local x, y = LabelGetTextDimensions( window.."TimerValue" )
        questDataHeight = questDataHeight + y
    else            
        LabelSetText( window.."TimerValue", L"" )      
        WindowSetShowing( window.."TimerValue", false )  
        WindowSetShowing( window.."ClockImage", false )
        WindowSetDimensions( window.."ClockImage", 0, 0 )
    end
    
    local typeIconWindowName = window.."TypeIcon"
    WindowSetShowing( typeIconWindowName, true )
    
    -- Set the quest tracker icon
    QuestUtils.SetCompletionIcon(questData, typeIconWindowName)
   
    -- Conditions
    for condition, conditionData in ipairs(questData.conditions)
    do
        local nameLabel     = window.."Condition"..condition
        
        local conditionName = conditionData.name
        local curCounter    = conditionData.curCounter
        local maxCounter    = conditionData.maxCounter
        
        LabelSetText( nameLabel, conditionName )
        
        local x, y = LabelGetTextDimensions(nameLabel)
        
        if( maxCounter > 0 )
        then
            LabelSetText( nameLabel, L""..conditionName..L" - "..curCounter..L"/"..maxCounter )
        else
            LabelSetText( nameLabel, conditionName )
        end

        if( curCounter == maxCounter )
        then
            LabelSetTextColor(nameLabel, GameDefs.CompleteCounterColor.r, GameDefs.CompleteCounterColor.g, GameDefs.CompleteCounterColor.b )
        else
            LabelSetTextColor(nameLabel, GameDefs.IncompleteCounterColor.r, GameDefs.IncompleteCounterColor.g, GameDefs.IncompleteCounterColor.b)
        end         

        if( conditionWidth < x )
        then              
            conditionWidth = x
        end                 
        
        -- Only show the conditions if we are viewing details
        if( showDetails == true )
        then
            questDataHeight = questDataHeight + y
            WindowSetShowing(window.."Condition"..condition, true)
        else
            WindowSetShowing(window.."Condition"..condition, false)
        end
    end
    for emptyConditions = #questData.conditions + 1, QuestUtils.MAX_CONDITIONS
    do
        WindowSetShowing(window.."Condition"..emptyConditions, false)
    end
    
    
    if( questNameWidth > conditionWidth )
    then
        questDataWidth = questNameWidth + EA_Window_QuestTracker.QUEST_NAME_OFFSET
    else
        questDataWidth = conditionWidth + EA_Window_QuestTracker.QUEST_NAME_OFFSET
    end
    
    -- DEBUG(L" { width="..questDataWidth..L", height = "..questDataHeight )


    -- Track the largest questDataWidth
    if( EA_Window_QuestTracker.questDataWidth < questDataWidth  )
    then
        EA_Window_QuestTracker.questDataWidth = questDataWidth  
    end
    
    WindowSetDimensions( window, EA_Window_QuestTracker.questDataWidth, questDataHeight )
    
    -- DEBUG(L" Condition Width = "..EA_Window_QuestTracker.conditionWidth )
    -- DEBUG(L" Quest Data Width = "..questDataWidth )
  
end

function EA_Window_QuestTracker.ShowConditions()

    local quest = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
        
    if( EA_Window_QuestTracker.currentData[quest] ~= nil )
    then
        EA_Window_QuestTracker.currentData[quest].showDetails = true      
        EA_Window_QuestTracker.UpdateTracker( quest )
        EA_Window_QuestTracker.UpdateWindowSize()
    end 

end

function EA_Window_QuestTracker.HideConditions()
   
    local quest = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
        
    if( EA_Window_QuestTracker.currentData[quest] ~= nil )
    then
        EA_Window_QuestTracker.currentData[quest].showDetails = false     
        EA_Window_QuestTracker.UpdateTracker( quest )
        EA_Window_QuestTracker.UpdateWindowSize()
    end 
end

function EA_Window_QuestTracker.ResetFade( index, data )
    EA_Window_QuestTracker.Settings.fadeData[data.questId].timer = 0
    WindowSetAlpha("EA_Window_QuestTrackerData"..index, 1.0)
    WindowSetFontAlpha("EA_Window_QuestTrackerData"..index, 1.0)
end

function EA_Window_QuestTracker.OnMouseOverQuest()
    local index = WindowGetId( SystemData.ActiveWindow.name )
    -- DEBUG(L"EA_Window_QuestTracker.OnMouseOverQuest() - "..index)
    EA_Window_QuestTracker.MouseOverQuest( index )
end

function EA_Window_QuestTracker.OnMouseOverEndQuest()
    EA_Window_QuestTracker.MouseOverEndQuest( )
end

function EA_Window_QuestTracker.OnMouseOverQuestName()
    local index = WindowGetId( WindowGetParent(SystemData.ActiveWindow.name) )
    EA_Window_QuestTracker.MouseOverQuest( index )
end

function EA_Window_QuestTracker.OnMouseOverEndQuestName()
    EA_Window_QuestTracker.MouseOverEndQuest( )
end

function EA_Window_QuestTracker.MouseOverQuest(	index )

    local questId = EA_Window_QuestTracker.currentData[index].questId
    local questData = DataUtils.GetQuestData( questId )   
    
    EA_Window_QuestTracker.Settings.fadeData[questId].override = true

    -- DEBUG( L"EA_Window_QuestTracker.MouseOverQuest " .. StringToWString( SystemData.ActiveWindow.name ) .. L" - " .. questData.id )	
    
    local row = 1
    local column = 1

    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, nil )	

    -- Quest Name
    local text = questData.name	
    Tooltips.SetTooltipText( row, column, text )
    Tooltips.SetTooltipColorDef( row, column, Tooltips.COLOR_HEADING )	
    
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
    
    local anchor = { Point="topleft", RelativeTo="EA_Window_QuestTrackerData"..index, RelativePoint="topright", XOffset=-4, YOffset=0 }
    Tooltips.AnchorTooltip( anchor )
end

function EA_Window_QuestTracker.MouseOverEndQuest()
    for _, data in pairs(EA_Window_QuestTracker.Settings.fadeData)
    do
        data.override = false
    end
end

function EA_Window_QuestTracker.OnLButtonUpQuestName( flags, x, y )

    local id = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
    local questId = EA_Window_QuestTracker.currentData[id].questId

    -- Cancel any fade out 
    EA_Window_QuestTracker.ResetFade( id, EA_Window_QuestTracker.currentData[id])

    -- Create an Quest Link on Shift-Left Click
    if( flags == SystemData.ButtonFlags.SHIFT )
    then    
    
        local questData = DataUtils.GetQuestData( questId )      
        EA_ChatWindow.InsertQuestLink( questData )   
      
    -- Otherwise Open/Close the Tome      
    else
        -- DEBUG( L"Opening Tome to Quest: "..questId )
        
        -- If we are clicking the same quest button, hide the Tome
        if( WindowGetShowing( "TomeWindow" ) == false  )
        then	   	    
            MenuBarWindow.ToggleTomeWindow()	
        elseif( TomeWindow.IsShowingQuest( questId ) == true )
        then
            MenuBarWindow.ToggleTomeWindow()	
            return  
        end
        TomeWindow.OpenToQuest( questId )
        
    end


end

function EA_Window_QuestTracker.OnMouseOverQuestType()
    local id = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
    local questId = EA_Window_QuestTracker.currentData[id].questId  
    local questData = DataUtils.GetQuestData( questId )    
    QuestUtils.CreateQuestTypeTooltip( questData, SystemData.MouseOverWindow.name )    
end


----------------------------------------------------------------
-- Context Menu Window
----------------------------------------------------------------
function EA_Window_QuestTracker.CreateContextMenu()
    EA_Window_ContextMenu.CreateContextMenu( "EA_Window_QuestTracker" ) 

    EA_Window_ContextMenu.AddMenuItem( GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_SET_QUEST_FADE_AMOUNT ), EA_Window_QuestTracker.OnWindowOptionsSetAlpha,         false, true )
    EA_Window_ContextMenu.AddMenuItem( GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_SET_FADE_TIME_NOW ),     EA_Window_QuestTracker.OnWindowOptionsSetFadeTimeNow,   false, true )
    
    local timeOptions = { 30, 60, 300, 600, 1800 }
    for _, timeValue in ipairs(timeOptions)
    do
        local label    = GetStringFormatFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_SET_FADE_TIME_X, { L""..timeValue } )
        local callback = EA_Window_QuestTracker["OnWindowOptionsSetFadeTime"..timeValue]
        
        EA_Window_ContextMenu.AddMenuItem( label, callback, false, true )
    end
    
    EA_Window_ContextMenu.AddMenuItem( GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_SET_FADE_TIME_NEVER ),   EA_Window_QuestTracker.OnWindowOptionsSetFadeTimeNever, false, true )

    EA_Window_ContextMenu.Finalize()
end

function EA_Window_QuestTracker.OnWindowOptionsSetAlpha()
    -- Open the Alpha Slider    
    local alpha = EA_Window_QuestTracker.Settings.fadeAlpha  
    SliderBarSetCurrentPosition("EA_Window_SetQuestTrackerOpacitySlider", alpha )    
    
    -- Anchor the OpacityWindow in the middle of the active window.
    WindowClearAnchors( "EA_Window_SetQuestTrackerOpacity" )
    WindowAddAnchor( "EA_Window_SetQuestTrackerOpacity", "top", "EA_Window_QuestTracker", "top", 0 , 0 )

    WindowSetShowing( "EA_Window_SetQuestTrackerOpacity", true )
end

function EA_Window_QuestTracker.OnSlideWindowOptionsAlpha( slidePos )
    EA_Window_QuestTracker.Settings.fadeAlpha = slidePos
end

function EA_Window_QuestTracker.CloseSetOpacityWindow()
    WindowSetShowing( "EA_Window_SetQuestTrackerOpacity", false )
end

function EA_Window_QuestTracker.OnWindowOptionsSetFadeTimeNow()
    EA_Window_QuestTracker.Settings.fadeTime = 0
end

function EA_Window_QuestTracker.OnWindowOptionsSetFadeTime30()
    EA_Window_QuestTracker.Settings.fadeTime = 30
end

function EA_Window_QuestTracker.OnWindowOptionsSetFadeTime60()
    EA_Window_QuestTracker.Settings.fadeTime = 60
end

function EA_Window_QuestTracker.OnWindowOptionsSetFadeTime300()
    EA_Window_QuestTracker.Settings.fadeTime = 300
end

function EA_Window_QuestTracker.OnWindowOptionsSetFadeTime600()
    EA_Window_QuestTracker.Settings.fadeTime = 600
end

function EA_Window_QuestTracker.OnWindowOptionsSetFadeTime1800()
    EA_Window_QuestTracker.Settings.fadeTime = 1800
end

function EA_Window_QuestTracker.OnWindowOptionsSetFadeTimeNever()
    EA_Window_QuestTracker.Settings.fadeTime = EA_Window_QuestTracker.NEVER_FADE
end
