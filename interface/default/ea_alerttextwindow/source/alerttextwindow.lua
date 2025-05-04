----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

-- The Actual Alert Window
AlertTextWindow = {}

AlertTextWindow.ALERT_WINDOW_TEMPLATE_NAME = "AlertTextWindow"
AlertTextWindow.ALERT_WINDOWS_NAME = "AlertTextWindow"

AlertTextWindow.TypeInfo= {}
AlertTextWindow.TypeInfo[ SystemData.AlertText.Types.DEFAULT ]                      =   { font = "font_alert_outline_large", halfFont = "font_alert_outline_half_large",    color = "White" }   
AlertTextWindow.TypeInfo[ SystemData.AlertText.Types.COMBAT ]                       =   { font = "font_alert_outline_large", halfFont = "font_alert_outline_half_large",    color = "Yellow"   }           
AlertTextWindow.TypeInfo[ SystemData.AlertText.Types.QUEST_NAME ]                   =   { font = "font_alert_outline_tiny", halfFont = "font_alert_outline_half_tiny",      color = "Yellow"}       
AlertTextWindow.TypeInfo[ SystemData.AlertText.Types.QUEST_CONDITION ]              =   { font = "font_alert_outline_large", halfFont = "font_alert_outline_half_large",    color = "White" }       
AlertTextWindow.TypeInfo[ SystemData.AlertText.Types.QUEST_END ]                    =   { font = "font_alert_outline_huge", halfFont = "font_alert_outline_half_huge",      color = "Gold"  }       
AlertTextWindow.TypeInfo[ SystemData.AlertText.Types.OBJECTIVE ]                    =   { font = "font_alert_outline_large", halfFont = "font_alert_outline_half_large",    color = "White" }   
AlertTextWindow.TypeInfo[ SystemData.AlertText.Types.RVR ]                          =   { font = "font_alert_outline_giant", halfFont = "font_alert_outline_half_giant",    color = "White" }   
AlertTextWindow.TypeInfo[ SystemData.AlertText.Types.SCENARIO ]                     =   { font = "font_alert_outline_large", halfFont = "font_alert_outline_half_large",    color = "White" }
AlertTextWindow.TypeInfo[ SystemData.AlertText.Types.MOVEMENT_RVR ]                 =   { font = "font_alert_outline_giant", halfFont = "font_alert_outline_half_giant",    color = "Red"   }
AlertTextWindow.TypeInfo[ SystemData.AlertText.Types.ENTERAREA ]                    =   { font = "font_alert_outline_large", halfFont = "font_alert_outline_half_large",    color = "White" }
AlertTextWindow.TypeInfo[ SystemData.AlertText.Types.STATUS_ERRORS ]                =   { font = "font_alert_outline_large", halfFont = "font_alert_outline_half_large",    color = "Yellow"}
AlertTextWindow.TypeInfo[ SystemData.AlertText.Types.STATUS_ACHIEVEMENTS_GOLD ]     =   { font = "font_alert_outline_medium", halfFont = "font_alert_outline_half_medium", color = "Gold"   }
AlertTextWindow.TypeInfo[ SystemData.AlertText.Types.STATUS_ACHIEVEMENTS_PURPLE ]   =   { font = "font_alert_outline_medium", halfFont = "font_alert_outline_half_medium", color = "Purple" }
AlertTextWindow.TypeInfo[ SystemData.AlertText.Types.STATUS_ACHIEVEMENTS_RANK ]     =   { font = "font_alert_outline_gigantic", halfFont = "font_alert_outline_half_gigantic", color = "Gold"   }
AlertTextWindow.TypeInfo[ SystemData.AlertText.Types.STATUS_ACHIEVEMENTS_RENOUN ]   =   { font = "font_alert_outline_gigantic", halfFont = "font_alert_outline_half_gigantic", color = "Purple" }
AlertTextWindow.TypeInfo[ SystemData.AlertText.Types.PQ_ENTER ]                     =   { font = "font_alert_outline_small", halfFont = "font_alert_outline_half_small",    color = "Yellow"    }
AlertTextWindow.TypeInfo[ SystemData.AlertText.Types.PQ_NAME ]                      =   { font = "font_alert_outline_huge", halfFont = "font_alert_outline_half_huge",      color = "Teal"  }
AlertTextWindow.TypeInfo[ SystemData.AlertText.Types.PQ_DESCRIPTION ]               =   { font = "font_alert_outline_small", halfFont = "font_alert_outline_half_small",    color = "Teal"  }
AlertTextWindow.TypeInfo[ SystemData.AlertText.Types.ENTERZONE ]                    =   { font = "font_alert_outline_huge", halfFont = "font_alert_outline_half_huge",      color = "White" }
AlertTextWindow.TypeInfo[ SystemData.AlertText.Types.ORDER ]                        =   { font = "font_alert_outline_medium", halfFont = "font_alert_outline_half_medium",  color = "Blue"  }   
AlertTextWindow.TypeInfo[ SystemData.AlertText.Types.DESTRUCTION ]                  =   { font = "font_alert_outline_medium", halfFont = "font_alert_outline_half_medium",  color = "Red"   }   
AlertTextWindow.TypeInfo[ SystemData.AlertText.Types.NEUTRAL ]                      =   { font = "font_alert_outline_medium", halfFont = "font_alert_outline_half_medium",  color = "Yellow"}
AlertTextWindow.TypeInfo[ SystemData.AlertText.Types.ABILITY ]                      =   { font = "font_alert_outline_large", halfFont = "font_alert_outline_half_large",    color = "Yellow"}
AlertTextWindow.TypeInfo[ SystemData.AlertText.Types.BO_ENTER ]                     =   { font = "font_alert_outline_small", halfFont = "font_alert_outline_half_small",    color = "Yellow"    }
AlertTextWindow.TypeInfo[ SystemData.AlertText.Types.BO_NAME ]                      =   { font = "font_alert_outline_huge", halfFont = "font_alert_outline_half_huge",  color = "White" }
AlertTextWindow.TypeInfo[ SystemData.AlertText.Types.BO_DESCRIPTION ]               =   { font = "font_alert_outline_small", halfFont = "font_alert_outline_half_small",    color = "Yellow"}
AlertTextWindow.TypeInfo[ SystemData.AlertText.Types.ENTER_CITY ]                   =   { font = "font_alert_outline_huge", halfFont = "font_alert_outline_half_huge",      color = "White" }
AlertTextWindow.TypeInfo[ SystemData.AlertText.Types.CITY_RATING ]                  =   { font = "font_alert_outline_huge", halfFont = "font_alert_outline_half_huge",  color = "White" }
AlertTextWindow.TypeInfo[ SystemData.AlertText.Types.GUILD_RANK ]                   =   { font = "font_alert_outline_gigantic", halfFont = "font_alert_outline_half_gigantic", color = "Olive" }
AlertTextWindow.TypeInfo[ SystemData.AlertText.Types.RRQ_UNPAUSED ]                 =   { font = "font_alert_outline_medium",   halfFont = "font_alert_outline_half_medium",   color = "Yellow"}
AlertTextWindow.TypeInfo[ SystemData.AlertText.Types.LARGE_ORDER ]                  =   { font = "font_alert_outline_gigantic", halfFont = "font_alert_outline_half_gigantic", color = "Blue"  }   
AlertTextWindow.TypeInfo[ SystemData.AlertText.Types.LARGE_DESTRUCTION ]            =   { font = "font_alert_outline_gigantic", halfFont = "font_alert_outline_half_gigantic", color = "Red"   }   
AlertTextWindow.TypeInfo[ SystemData.AlertText.Types.LARGE_NEUTRAL ]                =   { font = "font_alert_outline_gigantic", halfFont = "font_alert_outline_half_gigantic", color = "Yellow"}

AlertTextWindow.MESSAGE_WIDTH = 1024
AlertTextWindow.MESSAGE_HEIGHT_PADDING = 10
AlertTextWindow.MIN_HEIGHT_SHIFT = 275
AlertTextWindow.NUM_LINES = 5

AlertTextWindow.ANIMATION_DATA = nil

AlertTextWindow.FADE_IN_TIME = 0.5
AlertTextWindow.DISPLAY_TIME = 3.5
AlertTextWindow.FADE_OUT_TIME = 1.5
AlertTextWindow.ALERT_LIFE_TIME = AlertTextWindow.DISPLAY_TIME + AlertTextWindow.FADE_OUT_TIME
AlertTextWindow.TIME_BETWEEN_ALERTS = 1.5

--Stores whether or not there has been enough elapse time between each message
AlertTextWindow.totalTimePassed = 0
AlertTextWindow.readyForAlert = true

AlertTextWindow.MessageQueue = nil
AlertTextWindow.AlertQueue = nil
AlertTextWindow.OldestAlert = nil
AlertTextWindow.NewestHeight = 0
AlertTextWindow.enoughSpace = true
AlertTextWindow.loading = false

----------------------------------------------------------------
-- Helper Functions
----------------------------------------------------------------
function AlertTextWindow.NewLineData( txt, clr, typ)
    return { text = txt,  color = clr, type = typ}
end

function AlertTextWindow.NewMessageData( vType, vText )
    return { vecType = vType , vecText = vText }
end

function AlertTextWindow.NewAlertData( windowName )
    if( windowName == nil or windowName == "" )
    then
        return nil
    end
    return { alertWindowName=windowName, displayTime=0.0, animating=false, fading=false, lineData = {} }
end

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

----------------------------------------------------------------
-- Functions Variables
----------------------------------------------------------------

function AlertTextWindow.Initialize()
    RegisterEventHandler( SystemData.Events.SHOW_ALERT_TEXT, "AlertTextWindow.AddAlert" )
    RegisterEventHandler( SystemData.Events.LOADING_BEGIN, "AlertTextWindow.BeginLoading" )
    RegisterEventHandler( SystemData.Events.LOADING_END, "AlertTextWindow.EndLoading" )

    local uiScale = InterfaceCore.GetScale()
    AlertTextWindow.ANIMATION_DATA =
    {
        duration = AlertTextWindow.TIME_BETWEEN_ALERTS - AlertTextWindow.FADE_IN_TIME,
        delay = AlertTextWindow.FADE_IN_TIME,
        startAlpha = 0.0,
        endAlpha = 1.0,
        alphaInDuration  = AlertTextWindow.FADE_IN_TIME,
        alphaOutDuration = AlertTextWindow.FADE_OUT_TIME,
    }

    AlertTextWindow.MessageQueue = Queue:Create()
    AlertTextWindow.AlertQueue = Queue:Create()
end

function AlertTextWindow.Shutdown()
    UnregisterEventHandler( SystemData.Events.SHOW_ALERT_TEXT, "AlertTextWindow.AddAlert" )
    UnregisterEventHandler( SystemData.Events.LOADING_BEGIN, "AlertTextWindow.BeginLoading" )
    UnregisterEventHandler( SystemData.Events.LOADING_END, "AlertTextWindow.EndLoading" )
    
    -- Kill any windows that are still around
    while not AlertTextWindow.AlertQueue:IsEmpty()
    do
        local alertData = AlertTextWindow.AlertQueue:PopFront()
        DestroyWindow( alertData.alertWindowName )
    end
end

function AlertTextWindow.Update( timePassed )
    if( AlertTextWindow.loading or ( DoesWindowExist( "LoadingWindow" ) and WindowGetShowing( "LoadingWindow" ) ) )
    then
        return
    end
    
    -- Sanity check so we don't fly through any messages
    if( timePassed > 0.08 )
    then
        timePassed = 0.08
    end

    -- Update the animations    
    AlertTextWindow.UpdateAlphaAnimations( timePassed )
    AlertTextWindow.UpdatePositionAnimations()
    
    -- Check to see if we need to add a new message
    if( AlertTextWindow.readyForAlert == false ) then
        AlertTextWindow.totalTimePassed = AlertTextWindow.totalTimePassed + timePassed
        
        if( AlertTextWindow.totalTimePassed > AlertTextWindow.TIME_BETWEEN_ALERTS) then
            --DEBUG(L"Ready For Next Alert!")
            AlertTextWindow.readyForAlert = true
        end
    end
    
    if( AlertTextWindow.readyForAlert == true and
        not AlertTextWindow.MessageQueue:IsEmpty() and 
        ( AlertTextWindow.enoughSpace or AlertTextWindow.AlertQueue:IsEmpty() ) )
    then
        AlertTextWindow.ActivateNextMessage()
        
        AlertTextWindow.totalTimePassed = 0
        AlertTextWindow.readyForAlert = false
        AlertTextWindow.enoughSpace = false
        if( AlertTextWindow.OldestAlert )
        then
            AlertTextWindow.OldestAlert.animating = false
        end
    end
end

function AlertTextWindow.UpdateAlphaAnimations( timePassed )
    if( timePassed == nil or timePassed <= 0 )
    then
        return
    end
    
    -- Fade out the text after it passes the display time
    for index = AlertTextWindow.AlertQueue:Begin(), AlertTextWindow.AlertQueue:End()
    do
        local AlertData = AlertTextWindow.AlertQueue[index]
        if( AlertData.displayTime ~= nil )
        then
            AlertData.displayTime = AlertData.displayTime + timePassed

            local windowName = AlertData.alertWindowName
            
            if( AlertData.displayTime < AlertTextWindow.FADE_IN_TIME and not AlertData.fading )
            then
                --DEBUG(L"Start Fade In!")
                --Start the fade in for the new message
                WindowStartAlphaAnimation(  windowName,
                                            Window.AnimationType.SINGLE_NO_RESET,
                                            AlertTextWindow.ANIMATION_DATA.startAlpha,
                                            AlertTextWindow.ANIMATION_DATA.endAlpha,
                                            AlertTextWindow.ANIMATION_DATA.alphaInDuration,
                                            true, 0, 0 )
                AlertData.fading = true
            elseif( AlertData.displayTime > AlertTextWindow.FADE_IN_TIME and 
                    AlertData.displayTime < AlertTextWindow.DISPLAY_TIME and
                    AlertData.fading )
            then
                --DEBUG(L"Stop Fade In!")
                -- Turn animating off once we fade in
                --WindowStopAlphaAnimation( windowName )
                AlertData.fading = false
            elseif( AlertData.displayTime > AlertTextWindow.DISPLAY_TIME and not AlertData.fading)
            then
                --DEBUG(L"Start Fade Out!")
                -- Start fading the text out after AlertTextWindow.DISPLAY_TIME has passed
                WindowStartAlphaAnimation(  windowName,
                                            Window.AnimationType.SINGLE_NO_RESET,
                                            AlertTextWindow.ANIMATION_DATA.endAlpha,
                                            AlertTextWindow.ANIMATION_DATA.startAlpha,
                                            AlertTextWindow.ANIMATION_DATA.alphaOutDuration,
                                            true, 0, 0 )
                AlertData.fading = true
            elseif( AlertData.displayTime > AlertTextWindow.ALERT_LIFE_TIME and AlertData.fading )
            then
                -- Kill the window!
                --DEBUG(L"Killing Window!")
                AlertTextWindow.DestroyAlert( windowName )
            end
        end
    end
end

function AlertTextWindow.UpdatePositionAnimations()
    if( not AlertTextWindow.MessageQueue:IsEmpty() and
        AlertTextWindow.IsThereEnoughSpace() and
        AlertTextWindow.totalTimePassed >= AlertTextWindow.FADE_IN_TIME and
        AlertTextWindow.OldestAlert and
        not AlertTextWindow.OldestAlert.animating )
    then
        -- Animate upwards if there is a new message that needs to be displayed
        --DEBUG(L"Starting Animation")

        local oldestWindowName = AlertTextWindow.OldestAlert.alertWindowName
        
        -- Get where we are
        local x, y = WindowGetOffsetFromParent( oldestWindowName )
        WindowStopPositionAnimation( oldestWindowName )
        
        -- reset the anchor for the oldest window
        -- because animation ignores the anchors
        WindowClearAnchors( oldestWindowName )
        WindowAddAnchor( oldestWindowName, "top", "Root", "top", 0, y )
        
        local uiScale = InterfaceCore.GetScale()
        x = uiScale * x
        y = uiScale * y
              
        local targetY = y - AlertTextWindow.NewestHeight
        WindowStartPositionAnimation(   oldestWindowName,
                                        Window.AnimationType.SINGLE_NO_RESET,
                                        x,
                                        y,
                                        x,
                                        targetY,
                                        AlertTextWindow.ANIMATION_DATA.duration,
                                        true, 0, 0 )
        AlertTextWindow.OldestAlert.animating = true
        AlertTextWindow.enoughSpace = true
    end
end

function AlertTextWindow.DestroyAlert( windowName )
    if( windowName ~= nil and windowName ~= "" and
        AlertTextWindow.OldestAlert and windowName == AlertTextWindow.OldestAlert.alertWindowName )
    then
        --DEBUG( L"Destroying Alert" )
        -- We have to reanchor the next window that is going to be the new top
        AlertTextWindow.AlertQueue:PopFront()
        AlertTextWindow.OldestAlert = AlertTextWindow.AlertQueue:Front()
        
        -- Kill the window
        DestroyWindow( windowName )
    end
end

function AlertTextWindow.IsThereEnoughSpace()
    if( not AlertTextWindow.OldestAlert )
    then
        return true
    end
    
    local x, y = WindowGetOffsetFromParent( AlertTextWindow.OldestAlert.alertWindowName )
    local uiScale = InterfaceCore.GetScale()
    y = uiScale * y  
    local targetY = y - AlertTextWindow.NewestHeight
    
    return targetY >= 0
end

-- Check to see if there already is a message like this in the queue
function AlertTextWindow.IsDupe( alertText )
    -- Iterate over the queue
    for index = AlertTextWindow.MessageQueue:Begin(), AlertTextWindow.MessageQueue:End()
    do
        local dupe = true
        for k, v in ipairs( AlertTextWindow.MessageQueue[ index ].vecText )
        do
            if( v ~= alertText[ k ] )
            then
                dupe = false
                break
            end
        end

        if( dupe )
        then
            --DEBUG(L"Found a dupe, Not Adding it!")
            return true
        end
    end

    return false
end

function AlertTextWindow.AddAlert()
    --dt( SystemData.AlertText.VecType )
    --dt( SystemData.AlertText.VecText )
    if( (AlertTextWindow.loading or DoesWindowExist( "LoadingWindow" ) and WindowGetShowing( "LoadingWindow" ) ) and
        SystemData.AlertText.VecType[1] ~= SystemData.AlertText.Types.ENTERZONE and
        SystemData.AlertText.VecType[1] ~= SystemData.AlertText.Types.ENTERAREA and
        SystemData.AlertText.VecType[1] ~= SystemData.AlertText.Types.ENTER_CITY )
    then
        return
    end

    AlertTextWindow.SetAlertData(SystemData.AlertText.VecType,  SystemData.AlertText.VecText)
end

function AlertTextWindow.SetAlertData(vecType, vecText)
    if ( vecText ~= nil and not AlertTextWindow.IsDupe( vecText ) )
    then
        local messageData = AlertTextWindow.NewMessageData( vecType, vecText )
        --dt( vecType )
        --dt( vecText )
        
        -- Check whether or not we can immediately show the message unless theres a message up already,
        -- need to wait 1.5 sec in the queue
        if( AlertTextWindow.CanImmediatelyShowMessage(vecText, vecType) )
        then
            --DEBUG(L"immediateShow")
            AlertTextWindow.MessageQueue:PushFront( messageData )
        else
            AlertTextWindow.MessageQueue:PushBack( messageData )
        end
    end
end

function AlertTextWindow.CanImmediatelyShowMessage(vecText, vecType)
    --If it is a error message or rvr message immediately show message
    for i, textString in pairs( vecText )
    do
        --DEBUG(L"Alert Label # "..i..L" text: "..textString)
        if( textString ~= nil and textString ~= L"")
        then
            --Need to display these special messages immediately
            if( vecType[i] ~= nil and 
               (vecType[i] == SystemData.AlertText.Types.RVR or vecType[i] == SystemData.AlertText.Types.STATUS_ERRORS) )
            then
                return true
            end
        end
    end

    return false
end

local SingleAlertLineAdder = { alertTypes = {}, alertTexts = {} }

function AlertTextWindow.AddLine (alertType, text)
    SingleAlertLineAdder.alertTypes[1] = alertType
    SingleAlertLineAdder.alertTexts[1] = text
    
    AlertTextWindow.SetAlertData (SingleAlertLineAdder.alertTypes, SingleAlertLineAdder.alertTexts)
end

--Add the alert into the alert messaging window
-- NOTE: Do not call this externally, it bypasses the queueing system.
function AlertTextWindow.AddAlertMessage( vecType, vecText)
    if ( vecText ~= nil ) then
        local windowId = AlertTextWindow.AlertQueue:End() + 1
        local windowName = AlertTextWindow.ALERT_WINDOWS_NAME..windowId
        
        if( not CreateWindowFromTemplate( windowName, AlertTextWindow.ALERT_WINDOW_TEMPLATE_NAME, "AlertTextContainerWindow" ) )
        then
            return
        end
        WindowSetId( windowName, windowId )
        
        local alertData = AlertTextWindow.NewAlertData( windowName )
        AlertTextWindow.AlertQueue:PushBack( alertData )
        AlertTextWindow.OldestAlert = AlertTextWindow.AlertQueue:Front()
        
        -- Add any extra data to the message depending upon type
        AlertTextWindow.AddExtraTypeData( vecType, vecText )
        
        local count =1 
        local totalLabelHeight = 0
        local ySize = 0
        for i, textString in pairs( vecText ) do
            if( textString ~= nil and textString ~= L"") then
                local upperCaseText
                if( vecType[i] == SystemData.AlertText.Types.CITY_RATING )
                then
                    upperCaseText = textString
                else
                    -- Convert everything except <icon> fields to uppercase
                    upperCaseText = wstring.gsub(wstring.upper(textString), L"<ICON", L"<icon")
                end
                ySize = AlertTextWindow.AddLineToWindow( vecType[i], upperCaseText, count, alertData ) 
                totalLabelHeight = totalLabelHeight + ySize
                count = count +1
            end 
        end

        --Set alert message window size after all the labels have been created        
        WindowSetDimensions(windowName, AlertTextWindow.MESSAGE_WIDTH , totalLabelHeight + AlertTextWindow.MESSAGE_HEIGHT_PADDING)
        AlertTextWindow.NewestHeight = totalLabelHeight
        
        AlertTextWindow.AnchorMessageWindow( windowName )
        
        WindowSetAlpha( windowName, AlertTextWindow.ANIMATION_DATA.startAlpha )
        WindowSetFontAlpha( windowName, AlertTextWindow.ANIMATION_DATA.startAlpha )
        WindowSetShowing(windowName, true)
    end
end

--Anchor the previous alert to the top of the lastest alert window
function AlertTextWindow.AnchorMessageWindow( windowName )
    -- We need to reanchor the newest window to the one above it
    local lastWindow = AlertTextWindow.AlertQueue:Back()
    local nextToLastWindow = AlertTextWindow.AlertQueue[ AlertTextWindow.AlertQueue:End() - 1 ]
    
    if( lastWindow and nextToLastWindow )
    then
        WindowClearAnchors( lastWindow.alertWindowName )
        WindowAddAnchor( lastWindow.alertWindowName, "bottom", nextToLastWindow.alertWindowName, "top", 0, 0 )
    else
        WindowClearAnchors( windowName )
        WindowAddAnchor( windowName, "top", "Root", "top", 0, AlertTextWindow.MIN_HEIGHT_SHIFT )
    end
end

function AlertTextWindow.ActivateNextMessage()
    --DEBUG(L"Activateing Next Message")
    local data = AlertTextWindow.MessageQueue:PopFront()
    if(data ~= nil )
    then
        --DEBUG(L"Data Not Nil - Adding Alert Message")
        AlertTextWindow.AddAlertMessage( data.vecType, data.vecText )
    end
end

function AlertTextWindow.AddLineToWindow( type, text, lineNumber, alertData )
    if(AlertTextWindow.TypeInfo[type] == nil )
    then
        ERROR(L"AlertTextWindow.AddLineToWindow(): Unknown alert type.")
        return 0
    end
    
    local color = DefaultColor.AlertTextColors[ AlertTextWindow.TypeInfo[type].color ]
    local font = AlertTextWindow.TypeInfo[ type ].font    
    
    --Need to add more line labels if there is more than 5 lines per alerts
    if( lineNumber <= AlertTextWindow.NUM_LINES ) then
        --Set data for the message window, and update the label text, color and font
        local textData = AlertTextWindow.NewLineData( text, color, type )
        --DEBUG(L"Type is : "..type)
        alertData.lineData[lineNumber] = textData
            
        if( alertData.lineData ~= nil and alertData.lineData[lineNumber] ~= nil ) then   
            local ySize = AlertTextWindow.UpdateLabel( alertData.alertWindowName, lineNumber, text, color, font )   
            return ySize  
        end 
    end
    return 0
end

--Update Label text, font and color
function AlertTextWindow.UpdateLabel( windowName, lineNumber, text, color, font )
    local labelName = windowName.."Line"..lineNumber
    --DEBUG(L"Text is: "..text)
    LabelSetText( labelName, text)
    LabelSetFont( labelName, font, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING)
    LabelSetTextColor( labelName, color.r, color.g, color.b)
    local x, y = LabelGetTextDimensions( labelName )
    return y
end

function AlertTextWindow.PQEnterExtraText( vecType, vecText, index )
    local nextIndex = #vecType + 1
    
    -- HACK: Battlefield Objectives in scenarios are actually represented internally as PQs. Since scenarios do not
    -- have PQs or keeps, just assume that if the player is in a scenario, this is a Battlefield Objective.
    if (GameData.Player.isInScenario)
    then
        table.insert( vecType, nextIndex, SystemData.AlertText.Types.BO_DESCRIPTION )
        table.insert( vecText, nextIndex, wstring.upper( GetString( StringTables.Default.LABEL_BATTLE_FIELD_OBJECTIVE ) ) )
        return
    end

    -- Get the influence ID
    local areaData = GetAreaData()
    local infID = 0
    local hasPQButNoInfluence = false
    if( areaData ~= nil ) then
        for k, v in ipairs( areaData ) do
            -- The first value with an influenceID of non-zero is the current area's influence id
            -- if there is no influence id then this is a battlefield objective or keep
            if( v.influenceID ~= 0 )
            then
                infID = v.influenceID
                -- use whatever value.hasPQButNoInfluence is
                hasPQButNoInfluence = v.hasPQButNoInfluence
                break
            elseif( v.hasPQButNoInfluence )
            then
                -- If any of the areas we are in have a PQ but no influence we want this to be true
                hasPQButNoInfluence = true
            end
        end
    end
    
    -- HACK: Peaceful cities don't have keeps, they only have PQs, and they don't have influence
    -- This prevents "Keep" from being displayed without having to setup an influenceids.csv for
    -- city zones (which has other side effects)
    if (GameData.Player.City.id ~= 0) then
        hasPQButNoInfluence = true
    end
    
    if( infID == 0 and not hasPQButNoInfluence)
    then
        -- we have entered a keep if the influence id is 0
        -- and it is not an influenceless PQ
        -- so change the colors as well as return the keep label
        for index = 1, #vecType
        do
            if( vecType[index] == SystemData.AlertText.Types.PQ_NAME )
            then
                vecType[index] = SystemData.AlertText.Types.BO_NAME
                break
            end
        end
        table.insert( vecType, nextIndex, SystemData.AlertText.Types.BO_DESCRIPTION )
        table.insert( vecText, nextIndex, wstring.upper( GetString( StringTables.Default.LABEL_KEEP ) ) )
        return
    end
    
    local zonePairing = GetZonePairing()


    
    -- No need for race name or chapter for influenceless PQs
    local raceName
    if( not hasPQButNoInfluence )
    then
        raceName = StringUtils.GetFriendlyRaceForCurrentPairing( zonePairing, true )
    end

    -- add the chapter
    local chapterName
    if (infID > 0 and not hasPQButNoInfluence)
    then
        chapterName = GetChapterName( infID )
    end
    
    -- return PQ_DESCRIPTION, race and the chapter #
    local pqDesc
    if( raceName or chapterName )
    then
        pqDesc = wstring.upper( GetStringFormat( StringTables.Default.LABEL_PQ_RACE_CHAPTER_FORMAT, {racename or L"", chaptername or L""} ) )
    else
        pqDesc = wstring.upper( GetString( StringTables.Default.LABEL_PUBLIC_QUEST ) )
    end
    
    if( infID > 0 or hasPQButNoInfluence )
    then
        table.insert( vecType, nextIndex, SystemData.AlertText.Types.PQ_DESCRIPTION )
        table.insert( vecText, nextIndex, pqDesc )
    end
end

function AlertTextWindow.BOEnterExtraText( vecType, vecText, index )
    local nextIndex = #vecType + 1
    table.insert( vecType, nextIndex, SystemData.AlertText.Types.BO_DESCRIPTION )
    table.insert( vecText, nextIndex, wstring.upper( GetString( StringTables.Default.LABEL_BATTLE_FIELD_OBJECTIVE ) ) )
end

function AlertTextWindow.CityEnterExtraText( vecType, vecText, index )
    local nextIndex = index + 1
    -- construct the city rating string
    local cityRating = GetCityRatingForCityId( GameData.Player.City.id )
    local starStr = L""

    for i = 1, cityRating
    do
        starStr = starStr..L"<icon49>"
    end
    
    if( starStr ~= L"" )
    then
        table.insert( vecType, nextIndex, SystemData.AlertText.Types.CITY_RATING )
        table.insert( vecText, nextIndex, starStr )
    end
    
    nextIndex = nextIndex + 1
    if( GameData.Player.isInSiege )
    then
        table.insert( vecType, nextIndex, SystemData.AlertText.Types.NEUTRAL )
        table.insert( vecText, nextIndex, GetString( StringTables.Default.LABEL_CONTESTED ) )
    else
        local type = SystemData.AlertText.Types.ORDER
        if( GameData.Player.realm == GameData.Realm.DESTRUCTION )
        then
            type = SystemData.AlertText.Types.DESTRUCTION
        end
        table.insert( vecType, nextIndex, type )
        table.insert( vecText, nextIndex, wstring.upper( GetString( StringTables.Default.LABEL_SAFE ) ) )
    end
end

AlertTextWindow.ExtraTypeFunctions = 
{
    [SystemData.AlertText.Types.PQ_ENTER] = AlertTextWindow.PQEnterExtraText,
    [SystemData.AlertText.Types.BO_ENTER] = AlertTextWindow.BOEnterExtraText,
    [SystemData.AlertText.Types.ENTER_CITY] = AlertTextWindow.CityEnterExtraText
}

function AlertTextWindow.AddExtraTypeData( vecType, vecText )
    
    for index = 1, #vecType
    do
        local type = vecType[index]
        if( AlertTextWindow.ExtraTypeFunctions[type] )
        then
            AlertTextWindow.ExtraTypeFunctions[type]( vecType, vecText, index )
            break
        end
    end
    
end

function AlertTextWindow.BeginLoading()
    --DEBUG(L"Begin Loading")
    AlertTextWindow.loading = true
end

function AlertTextWindow.EndLoading()
    --DEBUG(L"End Loading")
    AlertTextWindow.loading = false
end
