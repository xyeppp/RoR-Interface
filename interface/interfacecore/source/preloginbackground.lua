PreloginBackground = {}

function PreloginBackground.Initialize()
    
    ButtonSetText( "PreloginBackgroundCinematicButton",  GetPregameString( StringTables.Pregame.LABEL_BUTTON_PRELOGIN_CINEMATIC  )  )
    ButtonSetText( "PreloginBackgroundCreditsButton",    GetPregameString( StringTables.Pregame.LABEL_BUTTON_PRELOGIN_CREDITS    )  )
    ButtonSetText( "PreloginBackgroundSettingsButton",   GetPregameString( StringTables.Pregame.LABEL_BUTTON_PRELOGIN_SETTINGS   )  )
    ButtonSetText( "PreloginBackgroundQuitButton",       GetPregameString( StringTables.Pregame.LABEL_QUIT                       )  )
    
    ButtonSetText( "PreloginBackgroundUpgradeButton",       GetPregameString( StringTables.Pregame.LABEL_UPGRADE                    )  )

    -- get the player data, this indicates if the player is a trial player and/or a buddied trial player
    local trialPlayer, buddiedPlayer = GetAccountData()
    -- show the upgrade button if this is a trial player
    WindowSetShowing("PreloginBackgroundUpgradeButton", trialPlayer)
       
end

function PreloginBackground.QuitGame()
    BroadcastEvent( SystemData.Events.QUIT )
end

function PreloginBackground.ToggleSettings()
    local showing = WindowGetShowing("SettingsWindowTabbed")
    WindowSetShowing("SettingsWindowTabbed", not showing)
end

function PreloginBackground.UpgradeAccount()
    EA_TrialAlertWindow.OnUpgradeWithOutClose()
end

