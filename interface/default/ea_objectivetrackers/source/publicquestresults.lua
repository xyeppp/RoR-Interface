----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_PublicQuestResults = {}
EA_Window_PublicQuestResults.USE_GENERIC_PQLOOT_TEXT = true
EA_Window_PublicQuestResults.MAX_HEIGHT   = 250
EA_Window_PublicQuestResults.LINE_HEIGHT  = 15
EA_Window_PublicQuestResults.MAX_TIME_TO_SHOW = 15 * 60


----------------------------------------------------------------
-- Window Functions
----------------------------------------------------------------

function EA_Window_PublicQuestResults.Initialize()

    PQData.AddWindow( EA_Window_PublicQuestResults )

    if PQData.currentState == PQData.STATE_CLEAR
    then
        EA_Window_PublicQuestResults.Hide()
    end
    
    WindowRegisterEventHandler( "EA_Window_PublicQuestResults", SystemData.Events.OBJECTIVE_AREA_EXIT, "EA_Window_PublicQuestResults.OnObjectiveLeave" )
    WindowRegisterEventHandler( "EA_Window_PublicQuestResults", SystemData.Events.PUBLIC_QUEST_RESETTING, "EA_Window_PublicQuestResults.CheckForReentry" )
    WindowRegisterEventHandler( "EA_Window_PublicQuestResults", SystemData.Events.PLAYER_ZONE_CHANGED, "EA_Window_PublicQuestResults.OnZoneChange" )
    
    EA_Window_PublicQuestResults.queueReanchor = false
end


-- OnUpdate Handler
function EA_Window_PublicQuestResults.Update( timePassed )
    if  (EA_Window_PublicQuestResults.clockTimeLeft ~= nil) and 
        (EA_Window_PublicQuestResults.clockTimeLeft > 0)
    then
        EA_Window_PublicQuestResults.clockTimeLeft = EA_Window_PublicQuestResults.clockTimeLeft - timePassed
        
        if( EA_Window_PublicQuestResults.timeUntilHide ~= nil )
        then
            EA_Window_PublicQuestResults.timeUntilHide = EA_Window_PublicQuestResults.timeUntilHide - timePassed
            if( EA_Window_PublicQuestResults.timeUntilHide < 0 )
            then
                EA_Window_PublicQuestResults.timeUntilHide = nil
                EA_Window_PublicQuestResults.Hide()
            end
        end
        
        if EA_Window_PublicQuestResults.clockTimeLeft < 0
        then
            EA_Window_PublicQuestResults.clockTimeLeft = 0
        end
        
        local timeText = TimeUtils.FormatClock( EA_Window_PublicQuestResults.clockTimeLeft )
        
        if (PQData.isCityPQ)
        then
            LabelSetText( "EA_Window_PublicQuestResultsDataTimerLabel", GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_STATE_FINISHED ) )
            LabelSetText( "EA_Window_PublicQuestResultsDataTimerText", L"" )
            WindowSetShowing( "EA_Window_PublicQuestResultsDataTimerImage", false )
        else
            LabelSetText( "EA_Window_PublicQuestResultsDataTimerText", timeText )
        end
    end
    

    if (EA_Window_PublicQuestResults.queueReanchor)
    then
        EA_Window_PublicQuestResults.Reanchor()
    end
end

function EA_Window_PublicQuestResults.Shutdown()

end

function EA_Window_PublicQuestResults.Refresh()
    if (PQData.currentState ~= PQData.STATE_CLEAR)
    then
        EA_Window_PublicQuestResults.Show()
        EA_Window_PublicQuestResults.RefreshButtons()
    else
        EA_Window_PublicQuestResults.Hide()
    end
    
end

function EA_Window_PublicQuestResults.RefreshButtons()
    if (PQData == nil) or (PQData.playerData == nil) or (PQData.playerData.sackType == nil)
    then
        WindowSetShowing("EA_Window_PublicQuestResultsButtonPending", true)
        WindowSetShowing("EA_Window_PublicQuestResultsButtonWin",     false)
        WindowSetShowing("EA_Window_PublicQuestResultsButtonLose",    false)
    elseif (PQData.playerData.sackType == GameData.PQData.PQ_SACK_NONE)
    then
        WindowSetShowing("EA_Window_PublicQuestResultsButtonPending", false)
        WindowSetShowing("EA_Window_PublicQuestResultsButtonWin",     false)
        WindowSetShowing("EA_Window_PublicQuestResultsButtonLose",    true)
    else
        WindowSetShowing("EA_Window_PublicQuestResultsButtonPending", false)
        WindowSetShowing("EA_Window_PublicQuestResultsButtonWin",     true)
        WindowSetShowing("EA_Window_PublicQuestResultsButtonLose",    false)
    end
end

function EA_Window_PublicQuestResults.HideButtons()
    WindowSetShowing("EA_Window_PublicQuestResultsButtonPending", false)
    WindowSetShowing("EA_Window_PublicQuestResultsButtonWin",     false)
    WindowSetShowing("EA_Window_PublicQuestResultsButtonLose",    false)
end


function EA_Window_PublicQuestResults.OnObjectiveLeave(objectiveID)
    if (objectiveID == GameData.PQData.id)
    then
        EA_Window_PublicQuestResults.Hide()
    end
end


function EA_Window_PublicQuestResults.CheckForReentry()
    if   (PQData.currentState ~= PQData.STATE_CLEAR)
    then
        EA_Window_PublicQuestResults.queueReanchor = true
        EA_Window_PublicQuestResults.Show()
    end
end


function EA_Window_PublicQuestResults.OnZoneChange()
    -- When zoning, the server may inform us of a new PQ for the new zone before the new zone finishes loading. Therefore only
    -- hide the current PQ if it is for a different zone than the new zone. Ignore zone values of 0 which are temporary loading values.
    if ( ( GameData.Player.zone ~= 0 ) and ( GameData.Player.zone ~= GameData.PQData.zone ) )
    then
        EA_Window_PublicQuestResults.Hide()
    end
end

function EA_Window_PublicQuestResults.Clear()

    local windowName = "EA_Window_PublicQuestResults"
    LabelSetText( windowName.."ActionText", L""  )

    LabelSetText( windowName.."DataPQName",     L"" )
    LabelSetText( windowName.."DataTimerLabel", L"" )
    LabelSetText( windowName.."DataTimerText",  L"" )

 end

function EA_Window_PublicQuestResults.OnClicked()
	PQLootWindow.ToggleVisibility()
end

function EA_Window_PublicQuestResults.Show()
    -- DEBUG(L"EA_Window_PublicQuestResults.Show()")
    WindowSetShowing( "EA_Window_PublicQuestResults", true )
    
    EA_Window_PublicQuestResults.Resize()
    EA_Window_PublicQuestResults.Reanchor()
    
    EA_Window_PublicQuestTracker.UpdateQuestVisibility()
    EA_Window_CityTracker.UpdateQuestVisibility()
end

function EA_Window_PublicQuestResults.Hide()
    -- DEBUG(L"EA_Window_PublicQuestResults.Hide()")
    WindowSetShowing( "EA_Window_PublicQuestResults", false )
    
    EA_Window_PublicQuestTracker.UpdateQuestVisibility()
    EA_Window_CityTracker.UpdateQuestVisibility()
end

-- TODO: dynamically resize to be the size of the children
function EA_Window_PublicQuestResults.Resize()

    local width, height = WindowGetDimensions( "EA_Window_PublicQuestTracker" )
    if( width < EA_Window_PublicQuestTracker.WIDTH )
    then
        width = EA_Window_PublicQuestTracker.WIDTH 
    end     
    
    -- set width first since it could change child heights
    WindowSetDimensions( "EA_Window_PublicQuestResults", width, EA_Window_PublicQuestResults.MAX_HEIGHT )   
    
    if WindowGetShowing( "EA_Window_PublicQuestResults" ) == false
    then
        height = EA_Window_PublicQuestTracker.EMPTY_SIZE.y
    else
        -- start with height = larger of TimeLabel or TimeText
        local _, y = LabelGetTextDimensions( "EA_Window_PublicQuestResultsDataTimerLabel")
        height = y
        
        _, y = LabelGetTextDimensions( "EA_Window_PublicQuestResultsDataTimerText")
        if y > height
        then
            height = y 
        end 
    
        _, y = LabelGetTextDimensions( "EA_Window_PublicQuestResultsDataPQName")
        height = height + y + 5

        _, y = LabelGetTextDimensions( "EA_Window_PublicQuestResultsActionText")
        height = height + y + EA_Window_PublicQuestResults.LINE_HEIGHT + 40

        _, y = WindowGetDimensions( "EA_Window_PublicQuestResultsButtonPending")
        height = height + y + EA_Window_PublicQuestResults.LINE_HEIGHT
    end     
    
    WindowSetDimensions( "EA_Window_PublicQuestResults", width, height)
        
end

function EA_Window_PublicQuestResults.Reanchor()
    
    -- Locate the tracker window which is showing
    local anchorToWindow = ""
    if (WindowGetShowing("EA_Window_PublicQuestTracker") and not GameData.Player.isInSiege)
    then
        anchorToWindow = "EA_Window_PublicQuestTracker"
    elseif (WindowGetShowing("EA_Window_KeepObjectiveTracker") and not GameData.Player.isInSiege)
    then
        anchorToWindow = "EA_Window_KeepObjectiveTracker"
    elseif (WindowGetShowing("EA_Window_CityTracker") and GameData.Player.isInSiege)
    then
        anchorToWindow = "EA_Window_CityTracker"
    end

    if (anchorToWindow ~= "")
    then
        WindowClearAnchors("EA_Window_PublicQuestResults")
        WindowAddAnchor("EA_Window_PublicQuestResults", "bottomright", anchorToWindow, "topright", 0, 0)
        EA_Window_PublicQuestResults.queueReanchor = false
    else
        -- No windows to attach to are left...wait until one returns.
        EA_Window_PublicQuestResults.queueReanchor = true
    end
end

function EA_Window_PublicQuestResults.ShowDefaultFields()
    local windowName = "EA_Window_PublicQuestResultsData"
    LabelSetText( windowName.."PQName", PQData.PQName )
    
    if (PQData.isCityPQ == true)
    then
        LabelSetText( windowName.."TimerLabel", GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_STATE_FINISHED ) )
        LabelSetText( windowName.."TimerText", L"" )
        WindowSetShowing( windowName.."TimerImage", false ) -- turned off in a City PQ (i.e. no reset time)
    else
        -- In cities, PQs transition rather than reset, so use a different string
        if (GameData.Player.isInSiege)
        then
            LabelSetText( windowName.."TimerLabel", GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_TIMER_TRANSITIONING ) )
        else
            LabelSetText( windowName.."TimerLabel", GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_TIMER_RESETTING ) )
        end
        
        EA_Window_PublicQuestResults.clockTimeLeft = PQData.timeUntilPQReset
        local timeText = TimeUtils.FormatClock( EA_Window_PublicQuestResults.clockTimeLeft )
        LabelSetText( windowName.."TimerText", timeText )
        WindowSetShowing( windowName.."TimerImage", true )
    end
end

function EA_Window_PublicQuestResults.ShowTopContributors()
    EA_Window_PublicQuestResults.Show()
    EA_Window_PublicQuestResults.ShowDefaultFields()
        
    local windowName = "EA_Window_PublicQuestResults"

    LabelSetText( windowName.."DataPQName",    PQData.PQName )
    LabelSetText( windowName.."DataTimerLabel", GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_TIMER_ROLLING ) )
    
	EA_Window_PublicQuestResults.clockTimeLeft = PQData.GetFakedTimerTime()
	local timeText = TimeUtils.FormatClock( EA_Window_PublicQuestResults.clockTimeLeft )
	LabelSetText( windowName.."DataTimerText", timeText )

    local resultsText
    if ( not PQData.metMinContribution )
    then
        if ( PQData.forcedOut )
        then
            resultsText = GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_NOT_ENOUGH_CONTRIBUTION_FORCED_OUT )
        elseif ( PQData.optedOut )
        then
            resultsText = GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_NOT_ENOUGH_CONTRIBUTION_OPTED_OUT )
        else
            resultsText = GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_NOT_ENOUGH_CONTRIBUTION )
        end
    else
        resultsText = GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_RESULTS_ROLLING )
    end

    LabelSetText(windowName.."ActionText", resultsText )
    
    EA_Window_PublicQuestResults.RefreshButtons()
    EA_Window_PublicQuestResults.Resize()
end


function EA_Window_PublicQuestResults.ShowRolls()

    local windowName = "EA_Window_PublicQuestResults"
    
    EA_Window_PublicQuestResults.Show()
    EA_Window_PublicQuestResults.ShowDefaultFields()

    LabelSetText( windowName.."DataTimerLabel", GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_TIMER_ROLLING ) )
    
    local resultsText
    if ( not PQData.metMinContribution )
    then
        if ( PQData.forcedOut )
        then
            resultsText = GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_NOT_ENOUGH_CONTRIBUTION_FORCED_OUT )
        elseif ( PQData.optedOut )
        then
            resultsText = GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_NOT_ENOUGH_CONTRIBUTION_OPTED_OUT )
        else
            resultsText = GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_NOT_ENOUGH_CONTRIBUTION )
        end
    else
        if ( PQData.forcedOut )
        then
            resultsText = GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_FORCED_OUT )..L"."
        elseif ( PQData.optedOut )
        then
            resultsText = GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_OPTED_OUT )..L"."
        else
            resultsText = GetStringFormatFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_CONTRIBUTION1, {towstring( PQData.playerData.place )} ) 
    
            if (PQData.playerData.grade ~= nil) and (PQData.playerData.grade ~= PQLootWindow.NO_MEDAL_GRADE)
            then
                local medalName = PQLootWindow.medalName[PQData.playerData.grade]
                local bonus = PQData.playerData.contribution
                resultsText = resultsText..L" "..GetStringFormatFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_CONTRIBUTION2, { medalName, bonus } ) 
            end        
        end
    end

    LabelSetText(windowName.."ActionText", resultsText )
    
	EA_Window_PublicQuestResults.clockTimeLeft = PQData.GetFakedTimerTime()
	local timeText = TimeUtils.FormatClock( EA_Window_PublicQuestResults.clockTimeLeft )
	LabelSetText( windowName.."DataTimerText", timeText )

    EA_Window_PublicQuestResults.RefreshButtons()
    EA_Window_PublicQuestResults.Resize()
end


function EA_Window_PublicQuestResults.ShowTransitionScreen()
    local windowName = "EA_Window_PublicQuestResults"
    
    EA_Window_PublicQuestResults.Show()
    EA_Window_PublicQuestResults.ShowDefaultFields()

    LabelSetText( windowName.."DataTimerLabel", GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_TIMER_ROLLING ) )

    LabelSetText( windowName.."ActionText", GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_TRANSITION ) )

	EA_Window_PublicQuestResults.clockTimeLeft = PQData.GetFakedTimerTime()
	local timeText = TimeUtils.FormatClock( EA_Window_PublicQuestResults.clockTimeLeft )
	LabelSetText( windowName.."DataTimerText", timeText )

    EA_Window_PublicQuestResults.RefreshButtons()
    EA_Window_PublicQuestResults.Resize()
end


function EA_Window_PublicQuestResults.ShowFinalResults()
    
    local windowName = "EA_Window_PublicQuestResults"
    
    EA_Window_PublicQuestResults.Show()
    EA_Window_PublicQuestResults.ShowDefaultFields()
    
    local resultsText
    if ( not PQData.metMinContribution )
    then
        if ( PQData.isResetting )
        then
            resultsText = L""
        else
            if ( PQData.forcedOut )
            then
                resultsText = GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_NOT_ENOUGH_CONTRIBUTION_FORCED_OUT )
            elseif ( PQData.optedOut )
            then
                resultsText = GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_NOT_ENOUGH_CONTRIBUTION_OPTED_OUT )
            else
                resultsText = GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_NOT_ENOUGH_CONTRIBUTION )
            end
        end
    else
        
        if ( PQData.forcedOut )
        then
            resultsText = GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_FORCED_OUT)
            
            -- TODO: Add in information about the Forced Out prize into the appropriate message so we can display it here
            --if( PQData.playerData.looserPrize ~= L"")
            --then
                --resultsText = resultsText..GetStringFormatFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_PLACED6, {PQData.playerData.looserPrize} )
            --else
                resultsText = resultsText..L"."
            --end
        elseif ( PQData.optedOut )
        then
            resultsText = GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_OPTED_OUT)
            
            if( PQData.playerData.looserPrize ~= L"")
            then
                resultsText = resultsText..GetStringFormatFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_PLACED6, {PQData.playerData.looserPrize} )
            else
                resultsText = resultsText..L"."
            end
                
        else
            resultsText = GetStringFormatFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_PLACED1, { towstring(PQData.playerData.place) } )
        
            if( PQData.playerData.sackType ~= PQLootWindow.REWARDS_UNKNOWN_INDEX and
               PQData.playerData.sackType ~= PQLootWindow.REWARDS_NO_REWARD_INDEX )
            then
                    
                if (EA_Window_PublicQuestResults.USE_GENERIC_PQLOOT_TEXT == true)
                then
                    -- TODO: ideally the ActionText should change to LABEL_PQLOOT_SCOREBOARD_PLACED5 "You have claimed your PQ loot!" after it has been claimed
                    --   Since we currently don't know when it's been looted, we're using a generic message
                    --
                    local sackName = PQLootWindow.sackName[PQData.playerData.sackType]
                    resultsText = resultsText..L" "..GetStringFormatFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_PLACED2, {sackName} )
                else
                    resultsText = resultsText..L" "..GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_PLACED4 )	
                end
                
            else
                if( PQData.playerData.looserPrize == L"")
                then
                    resultsText = resultsText..L" "..GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_PLACED3 )
                else
                    resultsText = resultsText..GetStringFormatFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_PLACED6, {PQData.playerData.looserPrize} )
                end
            end
            
        end
        
    end

    LabelSetText(windowName.."ActionText", resultsText )
    WindowSetShowing(windowName.."ActionText", resultsText ~= L"")
    WindowSetShowing(windowName.."ActionTextBackground", resultsText ~= L"")
    
    EA_Window_PublicQuestResults.clockTimeLeft = PQData.timeUntilPQReset
    if PQData.timeUntilPQReset < 1 or PQData.timeUntilPQReset > EA_Window_PublicQuestResults.MAX_TIME_TO_SHOW
    then
        EA_Window_PublicQuestResults.timeUntilHide = EA_Window_PublicQuestResults.MAX_TIME_TO_SHOW
    else
        EA_Window_PublicQuestResults.timeUntilHide = PQData.timeUntilPQReset
    end
    

    if (resultsText ~= L"")
    then
        EA_Window_PublicQuestResults.RefreshButtons()
    else
        EA_Window_PublicQuestResults.HideButtons()
    end
    EA_Window_PublicQuestResults.Resize()
    
    -- TODO: should have a bag icon that appears if user has unclaimed loot
end

function EA_Window_PublicQuestResults.OnMouseOverResults()
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.TOOLTIP_PQ_RESULTS ) )
    Tooltips.AnchorTooltip( {Point="bottomright", RelativeTo="EA_Window_PublicQuestResults", RelativePoint="topleft", XOffset=0, YOffset=0 } )
end

