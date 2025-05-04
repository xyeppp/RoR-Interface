QuickStartWindow = {}

QuickStartWindow.iQueueTime = 0
QuickStartWindow.iQueuePos = 0
QuickStartWindow.iQueueSize = 0
QuickStartWindow.iLastUpdate = 0

QuickStartWindow.iMaxQueueTime = 65535 -- the max server time (0xFFFF) is sent down when the server doesn't know what time to send so we won't display a time at that time

function QuickStartWindow.OnShown()
    Sound.Play( GameData.Sound.PREGAME_PLAY_CHARACTER_ORDER ) -- Play the order sound cause we always goto the order background scene when going to character select from Quick Start
end

function QuickStartWindow.Initialize()

    WindowRegisterEventHandler( "QuickStartWindow", SystemData.Events.CHARACTER_QUEUE_UPDATED, "QuickStartWindow.OnQueueUpdated")
    WindowRegisterEventHandler( "QuickStartWindow", SystemData.Events.CHARACTER_SELECT_NUM_PAID_NAME_CHANGES_UPDATED, "QuickStartWindow.TogglePNCButton" )

    ButtonSetText( "QuickStartWindowCinematicButton",  GetPregameString( StringTables.Pregame.LABEL_BUTTON_PRELOGIN_CINEMATIC  )  )
    ButtonSetText( "QuickStartWindowCreditsButton",    GetPregameString( StringTables.Pregame.LABEL_BUTTON_PRELOGIN_CREDITS    )  )
    ButtonSetText( "QuickStartWindowSettingsButton",   GetPregameString( StringTables.Pregame.LABEL_BUTTON_PRELOGIN_SETTINGS   )  )
    ButtonSetText( "QuickStartWindowQuitButton",       GetPregameString( StringTables.Pregame.LABEL_QUIT                       )  )
    ButtonSetText("QuickStartWindowPlay",              GetPregameString( StringTables.Pregame.LABEL_PLAY                       )  )
    ButtonSetText("QuickStartWindowCharactersButton",  GetPregameString( StringTables.Pregame.LABEL_BUTTON_PRELOGIN_CHARACTERS )  )
    ButtonSetText("QuickStartWindowServersButton",     GetPregameString( StringTables.Pregame.LABEL_BUTTON_PRELOGIN_SERVERS    )  )
    ButtonSetText( "QuickStartWindowUpgradeTrial",     GetPregameString( StringTables.Pregame.LABEL_UPGRADE                    )  )
    ButtonSetText("QuickStartWindowPNCButton",         GetPregameString( StringTables.Pregame.LABEL_PNC_BUTTON                 )  )

    local trialPlayer, _ = GetAccountData()
    WindowSetShowing("QuickStartWindowUpgradeTrial", trialPlayer)

    local nameLabel, rank, careerLabel, locationLabel = PregameGetQuickStartLabels( )
    LabelSetText("QuickStartWindowNameLabel", nameLabel)
	local rankAndCareerLineText = GetPregameStringFormat( StringTables.Pregame.TEXT_QUICK_START_LINE_TWO, { rank, careerLabel} )
    LabelSetText("QuickStartWindowRankLabel", rankAndCareerLineText)
    LabelSetText("QuickStartWindowLocationLabel", locationLabel)

    WindowSetShowing("QuickStartQueueStatusWindow", false)

    -- update the server name label if the LobbyBackground window exists
    if (DoesWindowExist("LobbyBackground")) then
        LobbyBackground.UpdateServerName()
    end

    -- if the transfer flag hasn't been used yet
    if not SystemData.Server.TransferFlagUsed
    then
        -- set the use flag
        SystemData.Server.TransferFlagUsed = true
        
        -- if the transfer flag is on
        if (SystemData.Server.TransferFlag == 1)
        then
        
            local serverStatus = EA_Window_TransferPopup.OPEN_SERVER
            
            local serverList = GetServerList()
            for _, serverData in ipairs( serverList )
            do
                if ( SystemData.Server.ID == serverData.id )
                then
                    if ( serverData.legacy )
                    then
                        serverStatus = EA_Window_TransferPopup.LEGACY_SERVER
                    end
                    break
                end
            end
            
            EA_Window_TransferPopup.Show( serverStatus )
        end
    end    
    
    QuickStartWindow.UpgradeTrialAccountInfoText()
    
    QuickStartWindow.TogglePNCButton()
    
end

function QuickStartWindow.LButtonUp( flags, mouseX, mouseY )
    BroadcastEvent( SystemData.Events.MOUSE_UP_ON_CHAR_SELECT_NIF )
end

function QuickStartWindow.LButtonDown( flags, mouseX, mouseY )
    BroadcastEvent( SystemData.Events.MOUSE_DOWN_ON_CHAR_SELECT_NIF )
end

function QuickStartWindow.QuitGame()
    BroadcastEvent( SystemData.Events.QUIT )
end

function QuickStartWindow.ToggleSettings()
    local showing = WindowGetShowing("SettingsWindowTabbed")
    WindowSetShowing("SettingsWindowTabbed", not showing)
end

-- OnLButtonUp Handler for the 'Play' Button
function QuickStartWindow.Play( flags, mouseX, mouseY )

	-- The character should NOT be playable if it belongs to a trial account and rank > GameData.TrialAccount.MaxLevel.
	-- Popup a warning message dialog box to alert user
    if( SystemData.Territory.TAIWAN )
    then
        local trialPlayer, _ = GetAccountData()
        if ( trialPlayer )
        then
            local _, rank = PregameGetQuickStartLabels( )
            if( rank > GameData.TrialAccount.MaxLevel )
            then
                DialogManager.MakeTwoButtonDialog( GetString(StringTables.Default.TEXT_UPGRADE_ACCOUNT_FOR_HIGH_LEVEL_CHARACTER),
                                                   GetString(StringTables.Default.LABEL_YES), QuickStartWindow.OnPressUpgradeButton,
                                                   GetString(StringTables.Default.LABEL_NO), QuickStartWindow.GoToCharacters,
                                                   nil, nil, nil, nil, DialogManager.TYPE_MODAL )
                return
            end
        end
    end

    BroadcastEvent( SystemData.Events.PLAY)

end

-- OnLButtonUp Handler for the 'Servers' Button
function QuickStartWindow.GoToServers( flags, mouseX, mouseY )

    BroadcastEvent( SystemData.Events.PREGAME_LAUNCH_SERVER_SELECT )

end

-- OnLButtonUp Handler for the 'Characters' Button
function QuickStartWindow.GoToCharacters( flags, mouseX, mouseY )
    
    BroadcastEvent( SystemData.Events.PREGAME_GO_TO_CHARACTER_SELECT)

end

function QuickStartWindow.OnQueueUpdated( waitSeconds, queuePos, queueSize )

    WindowSetShowing("QuickStartQueueStatusWindow", true)

    QuickStartWindow.iQueueTime = waitSeconds
    QuickStartWindow.iQueuePos = queuePos
    QuickStartWindow.iQueueSize = queueSize
    QuickStartWindow.iLastUpdate = 0

    QuickStartWindow.UpdateQueueStatus()
end

function QuickStartWindow.UpdateQueueStatus()

    local text = GetPregameStringFormat( StringTables.Pregame.TEXT_REALM_FULL_QUEUE, { QuickStartWindow.iQueuePos, QuickStartWindow.iQueueSize, QuickStartWindow.GetTimeRemainingString() } )
    
    LabelSetText("QuickStartQueueStatusWindowText", text)
    
    if( QuickStartWindow.iQueueTime == 0 )
    then
        QuickStartWindow.ResetPlayButton() 
    else
        -- Disable the play button until the player selects annother character
        ButtonSetDisabledFlag("QuickStartWindowPlay", false )
    end

end

function QuickStartWindow.ResetPlayButton()

    ButtonSetPressedFlag("QuickStartWindowPlay", false )
    ButtonSetDisabledFlag("QuickStartWindowPlay", false )

end

function QuickStartWindow.GetTimeRemainingString()
    if QuickStartWindow.iQueueTime < 60
    then
        return GetPregameString( StringTables.Pregame.LABEL_SMALL_TIMER  )
    elseif QuickStartWindow.iQueueTime == QuickStartWindow.iMaxQueueTime
    then
        return L""
    end

    return TimeUtils.FormatTime(QuickStartWindow.iQueueTime)
end

function QuickStartWindow.UpgradeTrial()
    EA_TrialAlertWindow.OnUpgradeWithOutClose()
end

function QuickStartWindow.OnPressUpgradeButton()
    -- display a modal confirmation dialog 
    DialogManager.MakeTwoButtonDialog(GetString(StringTables.Default.LABEL_EXIT_CONFIRMATION),
        GetString(StringTables.Default.LABEL_YES), EA_TrialAlertWindow.OpenUpgradePage, 
        GetString(StringTables.Default.LABEL_NO), QuickStartWindow.GoToCharacters,
        nil, nil, false, nil, DialogManager.TYPE_MODAL)
end

function QuickStartWindow.UpgradeTrialAccountInfoText()
    if( not SystemData.Territory.TAIWAN )
    then
        -- hide free trial account info
        WindowSetShowing("QuickStartWindowTrialAccountInfo", false)
        return
    end

    local trialPlayer, _ = GetAccountData()
    if ( trialPlayer )
    then
        local _, rank = PregameGetQuickStartLabels( )
        -- show free trial account info
        LabelSetText( "QuickStartWindowTrialAccountInfoHeader", GetString( StringTables.Default.TEXT_FREE_TRIAL_ACCOUNT_HEADER ) )
        if( rank > GameData.TrialAccount.MaxLevel )
        then
            -- this was a paid account before
            LabelSetText( "QuickStartWindowTrialAccountInfoText", GetString( StringTables.Default.TEXT_QUICK_START_WINDOW_PAID_ACCOUNT ) )
        else
            -- this was a new trial account
            LabelSetText( "QuickStartWindowTrialAccountInfoText", GetString( StringTables.Default.TEXT_QUICK_START_WINDOW_TRIAL_ACCOUNT ) )
        end
        WindowSetShowing("QuickStartWindowTrialAccountInfo", true)
    else
        WindowSetShowing("QuickStartWindowTrialAccountInfo", false)
    end
end

function QuickStartWindow.TogglePNCButton()

    if(GameData.Account.CharacterCreation.NumPaidNameChangesAvailable > 0)
    then
        WindowSetShowing("QuickStartWindowPNCButton", true)
    else
        WindowSetShowing("QuickStartWindowPNCButton", false)
        WindowSetShowing("PNCWindow", false)
    end

end

function QuickStartWindow.ShowPNCWindow()

    if(GameData.Account.CharacterCreation.NumPaidNameChangesAvailable > 0)
    then
        PNCWindow.Show()
    end

end
