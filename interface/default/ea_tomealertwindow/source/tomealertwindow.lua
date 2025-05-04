----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

TomeAlertWindow = {}

TomeAlertWindow.alertQueue = {}

TomeAlertWindow.WIDTH_PAD   = 75
TomeAlertWindow.HEIGHT_PAD  = 40

TomeAlertWindow.DISPLAY_TIME = 5
TomeAlertWindow.FADE_TIME    = 1.5

TomeAlertWindow.displayTimer = 0
TomeAlertWindow.fadeTimer    = 0

TomeAlertWindow.timerPaused   = false

local function NewAlertData( paramSection, paramEntry, paramSubEntry, paramName, paramText, paramXp )
    return { section = paramSection, entry = paramEntry, subEntry = paramSubEntry, name = paramName, text = paramText, xp = paramXp }
end


----------------------------------------------------------------
-- TomeAlertWindow Functions
----------------------------------------------------------------

-- OnInitialize Handler
function TomeAlertWindow.Initialize()

    WindowRegisterEventHandler( "TomeAlertWindow", SystemData.Events.TOME_ALERT_ADDED, "TomeAlertWindow.OnTomeAlertAdded")
    WindowRegisterEventHandler( "TomeAlertWindow", SystemData.Events.LOADING_END, "TomeAlertWindow.OnLoadEnd" )
    
    WindowSetAlpha( "TomeAlertWindowBackground", 0.75 )
        
    LabelSetText( "TomeAlertWindowSectionName", L"" )
    
    
    -- Set the Unlock Name & Text
    LabelSetText( "TomeAlertWindowText", L"" )
    
end

-- OnUpdate Handler
function TomeAlertWindow.Update( timePassed )
    
    
    -- Only Update the Timers when they are not paused and not currently loading.
    if( TomeAlertWindow.timerPaused == false and SystemData.LoadingData.isLoading == false ) then 
    
        -- Update the Display Timer, when it reaches 0 start the fade timer.
        if( TomeAlertWindow.displayTimer > 0 ) then
            TomeAlertWindow.displayTimer = TomeAlertWindow.displayTimer - timePassed
            if( TomeAlertWindow.displayTimer <= 0 ) then
                TomeAlertWindow.displayTimer = 0
                WindowStartAlphaAnimation( "TomeAlertWindow", Window.AnimationType.EASE_OUT, 1.0, 0.0, 
                    TomeAlertWindow.FADE_TIME, false, 0, 0 )
                
                TomeAlertWindow.fadeTimer = TomeAlertWindow.FADE_TIME
            end
        end
        
        -- Update the Fade Timer, when it reaches 0 either display the next alert or hide the window.
        if( TomeAlertWindow.fadeTimer > 0 ) then
            TomeAlertWindow.fadeTimer = TomeAlertWindow.fadeTimer - timePassed
            if( TomeAlertWindow.fadeTimer <= 0 ) then
                TomeAlertWindow.fadeTimer = 0
                TomeAlertWindow.ClearAlert()
            end
        end
    
    end -- if( TomeAlertWindow.timerPaused == false )  
    
end

-- OnShutdown Handler
function TomeAlertWindow.Shutdown()
    WindowSetShowing( "TomeAlertWindow", false )
end

-- Tome Alerts
function TomeAlertWindow.OnTomeAlertAdded()     

    local tomeAlerts = DataUtils.GetTomeAlerts()
    
    -- If we're hiding advanced windows from the player,
    -- don't show the alert unless it is for the Map.
    if( ( not EA_AdvancedWindowManager.ShouldShow( EA_AdvancedWindowManager.WINDOW_TYPE_TOK_ALERTS ) )
        and ( tomeAlerts[1].section ~= GameData.Tome.SECTION_ZONE_MAPS )
       )
    then
        return
    end
    
    
    -- Otherwise create a alert..
    local alert =  NewAlertData( tomeAlerts[1].section, 
                                 tomeAlerts[1].entry, 
                                 tomeAlerts[1].subEntry,
                                 tomeAlerts[1].name,
                                 tomeAlerts[1].desc,
                                 tomeAlerts[1].xp ) 
                                              
    -- Don't queue the alert for invalid sections or if the suppression flag is set
    if( tomeAlerts[1].section ~= 0 and tomeAlerts[1].suppressPopup == false )
    then
        TomeAlertWindow.QueueAlert( alert )
    end     
                                              
   -- If this was a map alert, automatically remove the alert from the new entires list.
    if( tomeAlerts[1].section == GameData.Tome.SECTION_ZONE_MAPS ) then
        RemoveTomeAlert( tomeAlerts[1].id )
        return
    end   

end

function TomeAlertWindow.QueueAlert( alertData ) 

    -- Store all alerts in a queue to show one at a time.
    table.insert( TomeAlertWindow.alertQueue, alertData )
       
    -- Show the alert now if the window is not currently in use and we are not loading
    if( TomeAlertWindow.displayTimer == 0 and TomeAlertWindow.fadeTimer == 0  and SystemData.LoadingData.isLoading == false) then
        TomeAlertWindow.ShowAlert()
    end
end

function TomeAlertWindow.ClearAlert()       
        
    -- Unpause the Timers
    TomeAlertWindow.timerPaused = false
    
    -- Stop the Timers
    TomeAlertWindow.displayTimer = 0
    TomeAlertWindow.fadeTimer    = 0
    
    -- Remove the first alert from the table.
    table.remove( TomeAlertWindow.alertQueue, 1 )

    -- If we have annother alert waiting in the queue, show it now.
    if( TomeAlertWindow.alertQueue[1] ) then
        TomeAlertWindow.ShowAlert()
        return
    end
    
    -- Otherwise Hide the window.
    WindowStopAlphaAnimation( "TomeAlertWindow" )
    WindowSetShowing( "TomeAlertWindow", false )
end

function TomeAlertWindow.ShowAlert()

    local alertData = TomeAlertWindow.alertQueue[1] 
    if( alertData == nil ) then
        return
    end
    
    local xpText = GetStringFormat( StringTables.Default.LABEL_X_XP, { alertData.xp } )
    local color = DefaultColor.COLOR_EXPERIENCE_GAIN
    LabelSetText( "TomeAlertWindowXPLabel", wstring.upper( xpText ) )
    LabelSetTextColor( "TomeAlertWindowXPLabel", color.r, color.g, color.b )
    WindowSetShowing( "TomeAlertWindowXPLabel", alertData.xp ~= 0 )

    -- Set the Icon and Section Name
    local icon          = DataUtils.GetTomeSectionIcon( alertData.section, true )
    local sectionName   = DataUtils.GetTomeSectionName( alertData.section )
    sectionName = GetStringFormat( StringTables.Default.LABEL_X_UNLOCK, { sectionName } )
    
    if( icon ~= nil )
    then
        DynamicImageSetTextureSlice( "TomeAlertWindowSectionIcon", icon )
    end
    WindowSetShowing( "TomeAlertWindowSectionIcon", icon ~= nil )
    if( alertData.useName )
    then
        LabelSetText( "TomeAlertWindowSectionName", wstring.upper( alertData.name ) )
    else
        LabelSetText( "TomeAlertWindowSectionName", wstring.upper( sectionName ) )
    end
    local nameWidth, nameHeight = WindowGetDimensions( "TomeAlertWindowSectionName" )
    
    local text = L""
    -- Set the Unlock Text, Default to "New Tome Entry: Blah" if no desc is included
    if( alertData.text ~= L"" ) then
        text = alertData.text
    else
        text = alertData.name
    end        

    LabelSetText( "TomeAlertWindowText", text )
    local textWidth, textHeight = LabelGetTextDimensions( "TomeAlertWindowText" )

    local width = math.max( nameWidth, textWidth ) + TomeAlertWindow.WIDTH_PAD
    local height = nameHeight + textHeight + TomeAlertWindow.HEIGHT_PAD
    WindowSetDimensions( "TomeAlertWindow", width, height )
    
    if( WindowGetShowing( "TomeAlertWindow" ) == false ) then
        WindowSetShowing( "TomeAlertWindow", true )
    end

    WindowStartAlphaAnimation( "TomeAlertWindow", Window.AnimationType.SINGLE_NO_RESET, 0.0, 1.0, 
                    TomeAlertWindow.FADE_TIME, false, 0, 0 )
    
    TomeAlertWindow.displayTimer = TomeAlertWindow.DISPLAY_TIME
    
    
    -- Play the TomeUnlock sound
    Sound.Play( Sound.PUBLIC_TOME_UNLOCKED )
     
end

function TomeAlertWindow.OnMouseOver()

    -- Pause the Display and Fade timers when the mouse is over the alert window.
    TomeAlertWindow.timerPaused = true
    
    -- If the window has been faded out some, fade it back in.
    if( TomeAlertWindow.fadeTimer > 0 ) then
        local fadeTime = TomeAlertWindow.FADE_TIME * ( (TomeAlertWindow.FADE_TIME -  TomeAlertWindow.fadeTimer ) / TomeAlertWindow.FADE_TIME )
        local startAlpha = WindowGetAlpha( "TomeAlertWindow" )
        WindowStartAlphaAnimation( "TomeAlertWindow", Window.AnimationType.SINGLE_NO_RESET, startAlpha, 1.0, 
                    fadeTime, false, 0, 0 )
    end
        
        
    -- Create a tooltip
    local text = GetString( StringTables.Default.TEXT_CLICK_TO_VIEW_ENTRY )
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, text )
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT)
end


function TomeAlertWindow.OnMouseOverEnd()

    -- Unpause the Timers
    TomeAlertWindow.timerPaused = false
    
    if( TomeAlertWindow.alertQueue[1]  ) then
        -- Set the Display Timer to 1/3 of it's duration.    
        TomeAlertWindow.displayTimer = TomeAlertWindow.DISPLAY_TIME / 3
        TomeAlertWindow.fadeTimer = 0
    end
    
end

function TomeAlertWindow.OnClickAlert()

    -- Open the tome to the entry    
    local alertData = TomeAlertWindow.alertQueue[1]      
    TomeWindow.OpenTomeToEntry( alertData.section, alertData.entry, alertData.subEntry )    
    
    -- Remove the alert.
    TomeAlertWindow.ClearAlert()
end

function TomeAlertWindow.OnLoadEnd()
    WindowSetShowing( "TomeAlertWindow", false )
    
    -- If we have an alert waiting in the queue, show it now.
    if( TomeAlertWindow.alertQueue[1] ) then
        TomeAlertWindow.ShowAlert()
        return
    end
end