EA_Window_CurrentEvents = {}

-- Settings
EA_Window_CurrentEvents.Settings =
{
    showOnLogin = true,
}

local WINDOWNAME = "EA_Window_CurrentEvents"

local NUM_PVE_EVENTS = 1
local NUM_RVR_EVENTS = 3
local MIN_TIER = 1
local MAX_TIER = 4
local HIDE_EVENT_THRESHOLD = 3 -- Event windows equalt to or above this number will be hidden 
local NO_EVENT_SELECTED = 0

local m_eventsData = { }                     
local function ClearEventsData()
    m_eventsData[1] = { PVE = {}, RVR = {} }
    m_eventsData[2] = { PVE = {}, RVR = {} }
    m_eventsData[3] = { PVE = {}, RVR = {} }
    m_eventsData[4] = { PVE = {}, RVR = {} }                
end

local function GetEventDataFromId( idToFind )    
    for _, tierData in ipairs( m_eventsData )
    do
        for _, data in ipairs( tierData.PVE )
        do
            if( data.id == idToFind )
            then
                return data
            end
        end
        
        for _, data in ipairs( tierData.RVR )
        do
            if( data.id == idToFind )
            then
                return data
            end
        end   
    end
    return nil
end

local function GetRandomStringId( stringIds )    
    return stringIds[ math.random( 1, #stringIds ) ]
end

local m_selectedEventData                   = nil
local m_confirmationDialogOpen              = false
local m_jumpCooldownTimerHours              = 0
local m_jumpCooldownTimerMinutes            = 0
local m_playerCurJumpCooldownTimerSeconds   = 0
local m_currentTier                         = 1

local m_isUpdateOnLogin                     = false

local m_selectedEventId                     = NO_EVENT_SELECTED

function EA_Window_CurrentEvents.Initialize()

    WindowRegisterEventHandler( WINDOWNAME, SystemData.Events.CURRENT_EVENTS_LIST_UPDATED, "EA_Window_CurrentEvents.OnEventsUpdated" )
    WindowRegisterEventHandler( WINDOWNAME, SystemData.Events.CURRENT_EVENTS_JUMP_TIMER_UPDATED, "EA_Window_CurrentEvents.OnJumpTimerUpdated" )
    WindowRegisterEventHandler( WINDOWNAME, SystemData.Events.LOADING_BEGIN, "EA_Window_CurrentEvents.OnLoadingBegin" ) 
    WindowRegisterEventHandler( WINDOWNAME, SystemData.Events.LOADING_END, "EA_Window_CurrentEvents.OnLoadingEnd" ) 
    WindowRegisterEventHandler( WINDOWNAME, SystemData.Events.PLAYER_COMBAT_FLAG_UPDATED, "EA_Window_CurrentEvents.HideOnCombat" ) 
    WindowRegisterEventHandler( WINDOWNAME, SystemData.Events.PLAYER_IS_BEING_THROWN, "EA_Window_CurrentEvents.HideOnCombat" ) 
 
    LabelSetText( WINDOWNAME.."BorderTitleText", GetStringFromTable("CurrentEventsStrings", StringTables.CurrentEvents.TITLE ) )
    LabelSetText( WINDOWNAME.."NoEventsText", GetStringFromTable("CurrentEventsStrings", StringTables.CurrentEvents.NO_EVENTS ) )
    
    ButtonSetText( WINDOWNAME.."GoButton", GetStringFromTable("CurrentEventsStrings", StringTables.CurrentEvents.GO_BUTTON ) )
  
    -- Settings
    LabelSetText( WINDOWNAME.."ShowOnLoginName", GetStringFromTable("CurrentEventsStrings", StringTables.CurrentEvents.SHOW_ON_LOGIN_LABEL ) )
    EA_Window_CurrentEvents.SetShowOnLogin( EA_Window_CurrentEvents.Settings.showOnLogin )       
    
    EA_Window_CurrentEvents.OnEventsUpdated( CurrentEventsGetList() )
    EA_Window_CurrentEvents.OnJumpTimerUpdated( CurrentEventsGetTimers() )    
    EA_Window_CurrentEvents.SetCurrentTier( Player.GetTier() )
    
    EA_Window_CurrentEvents.OnLoadingBegin()
end

function EA_Window_CurrentEvents.Update( secondsPassed )
    EA_Window_CurrentEvents.UpdateCooldownTimer( secondsPassed )
end


function EA_Window_CurrentEvents.Hide()
    WindowSetShowing( WINDOWNAME, false )    
end

function EA_Window_CurrentEvents.HideOnCombat()
    if (GameData.Player.inCombat == true or GameData.Player.isBeingThrown == true)
    then
        WindowSetShowing( WINDOWNAME, false )  
    end  
end

function EA_Window_CurrentEvents.Show()
    if (GameData.Player.inCombat == false and GameData.Player.isBeingThrown == false)
    then
        WindowSetShowing( WINDOWNAME, true )  
    end  
end

function EA_Window_CurrentEvents.ToggleShowing()
    if (GameData.Player.inCombat == true or GameData.Player.isBeingThrown == true)
    then
        EA_Window_CurrentEvents.HideOnCombat()
    else    
        WindowUtils.ToggleShowing( WINDOWNAME )
    end
end

function  EA_Window_CurrentEvents.OnShown()
   WindowUtils.OnShown()
   CurrentEventsUpdate()   
end

function EA_Window_CurrentEvents.OnLoadingBegin()    
    m_isUpdateOnLogin = SystemData.LoadingData.initialLoad 
end

function EA_Window_CurrentEvents.OnLoadingEnd()

    -- If the window is showing, force an update on the data
    -- as the player is now fully connected to the world.    
    if( m_isUpdateOnLogin )
    then
       CurrentEventsUpdate()
    end

end

function EA_Window_CurrentEvents.HandleShowOnInitialUpdate( hasEvents )

    if( m_isUpdateOnLogin and hasEvents
        and EA_Window_CurrentEvents.GetShowOnLogin()
        and EA_AdvancedWindowManager.ShouldShow( EA_AdvancedWindowManager.WINDOW_TYPE_CURRENT_EVENTS ) 
       )
    then
        
        -- Show the Window with the Player's the Player's Current Tier
        EA_Window_CurrentEvents.SetCurrentTier( Player.GetTier() )
        EA_Window_CurrentEvents.Show() 
        
    end                 

    m_isUpdateOnLogin = false
end

local function GetTableIndexBasedOnPriority( eventTable, eventData, priorityName, startIndex )
    if( not eventTable[startIndex] or
        CurrentEvents.SubTypes[eventData.subType][priorityName] < CurrentEvents.SubTypes[eventTable[startIndex].subType][priorityName] )
    then
        return startIndex
    end

    return GetTableIndexBasedOnPriority( eventTable, eventData, priorityName, startIndex + 1 )
end

--------------------------------------------------------------------------------------------
-- Data Updates
--------------------------------------------------------------------------------------------

function EA_Window_CurrentEvents.OnEventsUpdated( eventsData )

    ClearEventsData()
    m_selectedEventData = nil
    
    -- Parse the Events Data by Tier & Type
    for _, data in ipairs( eventsData )
    do    
        local subTypeData = CurrentEvents.SubTypes[ data.subType ]
        if( subTypeData ~= nil )
        then
            data.nameStringId = GetRandomStringId( subTypeData.nameStringIds )
            data.descStringId = GetRandomStringId( subTypeData.descStringIds )
        end
        
        if( data.type == SystemData.CurrentEventType.PVE )
        then
            local insertationIndex = GetTableIndexBasedOnPriority( m_eventsData[ data.tier ].PVE, data, "pvePriority", 1 )
            table.insert( m_eventsData[ data.tier ].PVE, insertationIndex, data )
            
        elseif( data.type == SystemData.CurrentEventType.RVR )
        then
            local insertationIndex = GetTableIndexBasedOnPriority( m_eventsData[ data.tier ].RVR, data, "rvrPriority", 1 )
            table.insert( m_eventsData[ data.tier ].RVR, insertationIndex, data )
        end
    
    end

    EA_Window_CurrentEvents.SetCurrentTier( m_currentTier )
    
    
    -- Update the 'No Events'
    local noEvents = ( #eventsData == 0) 
    
    WindowSetShowing( WINDOWNAME.."NoEventsText", noEvents == true )
    WindowSetShowing( WINDOWNAME.."Instructions", noEvents == false )
    WindowSetShowing( WINDOWNAME.."GoButton", noEvents == false )

   
    EA_Window_CurrentEvents.HandleShowOnInitialUpdate( not noEvents )
    
end

function EA_Window_CurrentEvents.SetCurrentTier( tier )

    m_currentTier = tier
    
    -- Update the Tier Label
    local text = GetStringFormatFromTable("CurrentEventsStrings", StringTables.CurrentEvents.TIER_TEXT, 
                            { L""..m_currentTier } )
    LabelSetText( WINDOWNAME.."TierText", text )

    -- Update the Buttons
    WindowSetShowing( WINDOWNAME.."LowerTierButton", m_currentTier ~= MIN_TIER )
    WindowSetShowing( WINDOWNAME.."HigherTierButton", m_currentTier ~= MAX_TIER )

    -- Set the headline with the first RVR event
    EA_Window_CurrentEvents.UpdateEvent( WINDOWNAME.."HeadlineEvent", 
                                         m_eventsData[ m_currentTier ].RVR[ 1 ]  )

    
    -- Update the PVE Events
    -- There is only one PVE event that we show and it always should be shown in event window 1
    EA_Window_CurrentEvents.UpdateEvent( WINDOWNAME.."Event"..1, 
                                         m_eventsData[ m_currentTier ].PVE[ 1 ]  )


    -- Update the RVR Events
    for index = 1, NUM_RVR_EVENTS do
        -- Start with the second event in the RVR event list to populate the event windows
        -- Cause the first one will be in used for the headline
        local windowEventNumber = index + 1
        local eventWindowName = WINDOWNAME.."Event"..windowEventNumber
        EA_Window_CurrentEvents.UpdateEvent( eventWindowName, 
                                             m_eventsData[ m_currentTier ].RVR[ windowEventNumber ]  )

        -- Hide the all event windows if there data is nil and the window is equal to or above the hide threshold
        if( windowEventNumber >= HIDE_EVENT_THRESHOLD )
        then
            WindowSetShowing( eventWindowName, m_eventsData[ m_currentTier ].RVR[ windowEventNumber ] ~= nil )
        end
    end

end

function EA_Window_CurrentEvents.ClearEvent( eventWindowName )

    -- Clear Everything
    WindowSetId( eventWindowName, 0 )
    LabelSetText( eventWindowName.."Title", L"" )
    LabelSetText( eventWindowName.."Text", L"" ) 
    LabelSetText( eventWindowName.."Time", L"" )
    WindowSetShowing( eventWindowName.."Icon", false )
    WindowSetShowing( eventWindowName.."NoEventIcon", true )
    WindowSetShowing( eventWindowName.."ClockImage", false )      
    ButtonSetDisabledFlag( eventWindowName, true )  
    EA_Window_CurrentEvents.UpdateSelectionForWindow( eventWindowName, nil )
end

function EA_Window_CurrentEvents.UpdateEvent( eventWindowName, eventData )
    if( eventData == nil )
    then
        EA_Window_CurrentEvents.ClearEvent( eventWindowName )
        return
    end

    local subTypeData = CurrentEvents.SubTypes[ eventData.subType ]
    if( subTypeData == nil )
    then
        EA_Window_CurrentEvents.ClearEvent( eventWindowName )
        return    
    end
    
    -- Set the Id
    WindowSetId( eventWindowName, eventData.id )
    
    -- Set the Title
    LabelSetText( eventWindowName.."Title", subTypeData.GetName( eventData ) )
 
    -- Set the Text
    LabelSetText( eventWindowName.."Text", subTypeData.GetText( eventData ) )
            
    -- Set the Icon
    WindowSetShowing( eventWindowName.."Icon", true )
    WindowSetShowing( eventWindowName.."NoEventIcon", false )
    DynamicImageSetTextureSlice( eventWindowName.."Icon", CurrentEvents.SubTypes[ eventData.subType ].iconSlice )
    
    -- Set the Time  
    --WindowSetShowing( eventWindowName.."ClockImage", true )        
    --LabelSetText( eventWindowName.."Time", TimeUtils.FormatTimeCondensed(eventData.time) )
    WindowSetShowing( eventWindowName.."ClockImage", false )   -- (For now, just hide the clock )

    -- Enable the Button behavior
    ButtonSetDisabledFlag( eventWindowName, false )
    
    -- Update the Selection
    EA_Window_CurrentEvents.UpdateSelectionForWindow( eventWindowName, eventData )
end


---
-- Tier Navigation

function EA_Window_CurrentEvents.OnClickLowerTierButton()

    if( m_currentTier > MIN_TIER  )
    then
        EA_Window_CurrentEvents.SetCurrentTier( m_currentTier - 1 )
        EA_Window_CurrentEvents.OnMouseOverLowerTierButton()

        -- Set the selected event to zero, so if they click the GO button
        -- it will not take them to an event on a previous tier
        EA_Window_CurrentEvents.SelectEvent( NO_EVENT_SELECTED )
    end   

end

function EA_Window_CurrentEvents.OnMouseOverLowerTierButton()
    EA_Window_CurrentEvents.CreateTierButtonTooltip( m_currentTier - 1 )
end

function EA_Window_CurrentEvents.OnClickHigherTierButton()

    if( m_currentTier < MAX_TIER  )
    then
        EA_Window_CurrentEvents.SetCurrentTier( m_currentTier + 1 )
        EA_Window_CurrentEvents.OnMouseOverHigherTierButton()

        -- Set the selected event to zero, so if they click the GO button
        -- it will not take them to an event on a previous tier
        EA_Window_CurrentEvents.SelectEvent( NO_EVENT_SELECTED )
    end   

end

function EA_Window_CurrentEvents.OnMouseOverHigherTierButton()
    EA_Window_CurrentEvents.CreateTierButtonTooltip( m_currentTier + 1 )
end


function EA_Window_CurrentEvents.CreateTierButtonTooltip( tier )

    local text = GetStringFormatFromTable( "CurrentEventsStrings", 
                                           StringTables.CurrentEvents.TIER_TOOLTIP,
                                           { L""..tier } )
    

    Tooltips.CreateTextOnlyTooltip(SystemData.ActiveWindow.name, text)
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_TOP)
end

--------------------------------------------------------------------------------------------
-- Selection
--------------------------------------------------------------------------------------------

function EA_Window_CurrentEvents.OnClickEvent()

    -- Ignore selections while the dialog is up.
    if( m_confirmationDialogOpen )
    then
        return
    end

    local eventId = WindowGetId( SystemData.ActiveWindow.name )
    
    EA_Window_CurrentEvents.SelectEvent( eventId )
end

function EA_Window_CurrentEvents.SelectEvent( eventId )

    m_selectedEventId = eventId

    EA_Window_CurrentEvents.UpdateSelection()
    EA_Window_CurrentEvents.UpdateGoButton()
end

function EA_Window_CurrentEvents.UpdateSelection()

    -- Set the headline with the first RVR event
    EA_Window_CurrentEvents.UpdateSelectionForWindow( WINDOWNAME.."HeadlineEvent", 
                                         m_eventsData[ m_currentTier ].RVR[ 1 ]  )

    
    -- Update the PVE Events
    -- There is only one PVE event that we show and it always should be shown in event window 1
    EA_Window_CurrentEvents.UpdateSelectionForWindow( WINDOWNAME.."Event"..1, 
                                         m_eventsData[ m_currentTier ].PVE[ 1 ]  )


    -- Update the RVR Events
    for index = 1, NUM_RVR_EVENTS do        
        -- Start with the second event in the RVR event list to populate the event windows
        -- Cause the first one will be in used for the headline
        EA_Window_CurrentEvents.UpdateSelectionForWindow( WINDOWNAME.."Event"..index + 1, 
                                             m_eventsData[ m_currentTier ].RVR[ index + 1 ]  )
    end

end

function EA_Window_CurrentEvents.UpdateSelectionForWindow( eventWindowName, eventData )

    local isSelected = false
    if( eventData ~= nil ) 
    then
        isSelected = eventData.id == m_selectedEventId
    end
    ButtonSetStayDownFlag( eventWindowName,  isSelected )
    ButtonSetPressedFlag( eventWindowName,  isSelected )
end


--------------------------------------------------------------------------------------------
-- Jump Timer Updates
--------------------------------------------------------------------------------------------

function EA_Window_CurrentEvents.OnJumpTimerUpdated( playerCurrentTimerSeconds, jumpCooldownTimerSeconds )

    m_playerCurJumpCooldownTimerSeconds = playerCurrentTimerSeconds
    m_jumpCooldownTimerHours = jumpCooldownTimerSeconds / TimeUtils.SECONDS_PER_HOUR    
    m_jumpCooldownTimerMinutes = jumpCooldownTimerSeconds / TimeUtils.SECONDS_PER_MINUTE
    
    local jumpDisabled = m_playerCurJumpCooldownTimerSeconds ~= 0 
    
    -- Update the Instructions Text
    local instructionsStringId = StringTables.CurrentEvents.INSTRUCTIONS_ENABLED
    if( jumpDisabled )
    then
        instructionsStringId = StringTables.CurrentEvents.INSTRUCTIONS_DISABLED
    end
    LabelSetText( WINDOWNAME.."Instructions", GetStringFormatFromTable("CurrentEventsStrings", instructionsStringId,
                                                                       { L""..m_jumpCooldownTimerMinutes } ) )
                
    -- Show/Hide the Cooldown Display
    WindowSetShowing( WINDOWNAME.."CooldownClockImage", jumpDisabled )
    WindowSetShowing( WINDOWNAME.."CooldownTimer", jumpDisabled )
    
    EA_Window_CurrentEvents.UpdateCooldownTimer( 0 )
    
    EA_Window_CurrentEvents.UpdateGoButton()
end

function EA_Window_CurrentEvents.UpdateCooldownTimer( secondsPassed )

    if( m_playerCurJumpCooldownTimerSeconds > 0  )
    then
        m_playerCurJumpCooldownTimerSeconds = m_playerCurJumpCooldownTimerSeconds - secondsPassed
        if( m_playerCurJumpCooldownTimerSeconds < 0 )
        then
            m_playerCurJumpCooldownTimerSeconds = 0
            -- TODO: Trigger Alert, Play sound?
            
        end        
        
        LabelSetText( WINDOWNAME.."CooldownTimer", TimeUtils.FormatTimeCondensed(m_playerCurJumpCooldownTimerSeconds) )
    end  
end

function EA_Window_CurrentEvents.UpdateGoButton()

    -- Disable the 'Go' Button if the player has not selected an event
    -- or they have not have am active cooldown timer.
    local disabled = (m_selectedEventId == NO_EVENT_SELECTED) or (m_playerCurJumpCooldownTimerSeconds > 0)

    ButtonSetDisabledFlag( WINDOWNAME.."GoButton", disabled )
end


--------------------------------------------------------------------------------------------
-- 'Go' Button and Confirmation Dialog
--------------------------------------------------------------------------------------------

function EA_Window_CurrentEvents.OnGoButton()
        
    if( ButtonGetDisabledFlag( WINDOWNAME.."GoButton" ) )
    then
        return
    end
        
    local eventData = GetEventDataFromId( m_selectedEventId )
    if( eventData == nil )
    then
        return
    end
        
    local subTypeData = CurrentEvents.SubTypes[ eventData.subType ]
    if( subTypeData == nil )
    then
        return
    end
    
    -- Spawn the Confirmation Dialog
    local eventName = subTypeData.GetName( eventData )
    local eventText = subTypeData.GetText( eventData )
    local dialogText = GetStringFormatFromTable("CurrentEventsStrings", StringTables.CurrentEvents.CONFIRM_DIALOG_TEXT, 
                     { eventName, eventText } )
    
    if( DialogManager.MakeTwoButtonDialog( dialogText,
                                       GetStringFromTable("CurrentEventsStrings", 
                                       StringTables.CurrentEvents.CONFIRM_DIALOG_GO_BUTTON), EA_Window_CurrentEvents.OnConfirmationDialogYes, 
                                       GetString(StringTables.Default.LABEL_CANCEL), EA_Window_CurrentEvents.OnConfirmationDialogNo,
                                       nil, nil, false, nil, nil, 
                                       nil, nil)
      )
    then
        m_confirmationDialogOpen = true
    end
    
    EA_Window_CurrentEvents.Hide()   
end

function EA_Window_CurrentEvents.OnConfirmationDialogYes()
    CurrentEventsJumpToEvent( m_selectedEventId )
    m_confirmationDialogOpen = false
end

function EA_Window_CurrentEvents.OnConfirmationDialogNo()
    m_confirmationDialogOpen = false
    EA_Window_CurrentEvents.Show()
end

--------------------------------------------------------------------------------------------
-- Settings
--------------------------------------------------------------------------------------------

function EA_Window_CurrentEvents.SetShowOnLogin( value )
    EA_Window_CurrentEvents.Settings.showOnLogin = value    
    ButtonSetPressedFlag( WINDOWNAME.."ShowOnLoginCheckBox", value )
end

function EA_Window_CurrentEvents.GetShowOnLogin()
    return EA_Window_CurrentEvents.Settings.showOnLogin
end


function EA_Window_CurrentEvents.ToggleShowOnLogin()    
    EA_Window_CurrentEvents.SetShowOnLogin( not EA_Window_CurrentEvents.Settings.showOnLogin )
end
