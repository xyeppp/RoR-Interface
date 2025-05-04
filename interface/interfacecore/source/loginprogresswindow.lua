----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

LoginProgressWindow = {}
LoginProgressWindow.displayText = L""


----------------------------------------------------------------
-- LoginWindow Functions
----------------------------------------------------------------

-- OnInitialize Handler()
function LoginProgressWindow.Initialize()
    WindowRegisterEventHandler( "LoginProgressWindow", SystemData.Events.LOGIN_PROGRESS_STARTING,   "LoginProgressWindow.StartLobbyLogin")
    WindowRegisterEventHandler( "LoginProgressWindow", SystemData.Events.LOGIN_PROGRESS_UPDATED,    "LoginProgressWindow.UpdateText")  
    WindowRegisterEventHandler( "LoginProgressWindow", SystemData.Events.AUTHENTICATION_LOGIN_START, "LoginProgressWindow.StartLogin")  
    --WindowRegisterEventHandler( "LoginProgressWindow", SystemData.Events.AUTHENTICATION_RESPONSE,   "LoginProgressWindow.EndLogin")  
    WindowRegisterEventHandler( "LoginProgressWindow", SystemData.Events.PLAYER_DATA_START,         "LoginProgressWindow.StartPlayerData")  
    --WindowRegisterEventHandler( "LoginProgressWindow", SystemData.Events.PLAYER_DATA_RESPONSE,      "LoginProgressWindow.EndPlayerData")  
    WindowRegisterEventHandler( "LoginProgressWindow", SystemData.Events.SERVER_LIST_START,         "LoginProgressWindow.StartServerList")  
    --WindowRegisterEventHandler( "LoginProgressWindow", SystemData.Events.SERVER_LIST_RESPONSE,      "LoginProgressWindow.EndServerList")  
    WindowRegisterEventHandler( "LoginProgressWindow", SystemData.Events.CHARACTER_LIST_START,      "LoginProgressWindow.StartCharacterList")  
    --WindowRegisterEventHandler( "LoginProgressWindow", SystemData.Events.CHARACTER_LIST_RESPONSE,   "LoginProgressWindow.EndCharacterList")  
    WindowRegisterEventHandler( "LoginProgressWindow", SystemData.Events.AUTHENTICATION_ERROR,      "LoginProgressWindow.ShowError")  
    
    ButtonSetText( "LoginProgressWindowQuitButton",    GetPregameString( StringTables.Pregame.LABEL_BUTTON_PRELOGIN_PROGRESS_QUIT    ) )
    ButtonSetText( "LoginProgressWindowRepatchButton", GetPregameString( StringTables.Pregame.LABEL_BUTTON_PRELOGIN_PROGRESS_REPATCH ) )
    WindowSetShowing("LoginProgressWindowQuitButton",    false)
    WindowSetShowing("LoginProgressWindowRepatchButton", false)
end

----------------------------------------------------------------
-- Dispatched event handlers
----------------------------------------------------------------
function LoginProgressWindow.StartLobbyLogin()
    LoginProgressWindow.displayText = GetPregameString( StringTables.Pregame.TEXT_CONNECTING_TO_SERVER_LOBBY )
    LabelSetText( "LoginProgressWindowText", LoginProgressWindow.displayText )
end

function LoginProgressWindow.UpdateText(text)
    WindowSetShowing("LoginProgressWindow", true)
    
    LoginProgressWindow.displayText = LoginProgressWindow.displayText..L"\n"..text
    LabelSetText( "LoginProgressWindowText", LoginProgressWindow.displayText )
end

function LoginProgressWindow.StartLogin()
    WindowSetShowing("LoginProgressWindow", true)

    LoginProgressWindow.displayText = LoginProgressWindow.displayText..L"\n"..GetPregameString( StringTables.Pregame.TEXT_AUTHENTICATING_WITH_SERVER )
    LabelSetText( "LoginProgressWindowText", LoginProgressWindow.displayText )
end

function LoginProgressWindow.StartPlayerData()
    WindowSetShowing("LoginProgressWindow", true)

    -- Restart the login log at this point.
    LoginProgressWindow.displayText = GetPregameString( StringTables.Pregame.TEXT_GETTING_PLAYER_DATA )
    LabelSetText( "LoginProgressWindowText", LoginProgressWindow.displayText )
end

function LoginProgressWindow.StartServerList()
    WindowSetShowing("LoginProgressWindow", true)

    -- Restart the login log at this point.
    LoginProgressWindow.displayText = GetPregameString( StringTables.Pregame.TEXT_GETTING_SERVER_LIST )
    LabelSetText( "LoginProgressWindowText", LoginProgressWindow.displayText )
end

function LoginProgressWindow.StartCharacterList()
    WindowSetShowing("LoginProgressWindow", true)

    LoginProgressWindow.displayText = LoginProgressWindow.displayText..L"\n"..GetPregameString( StringTables.Pregame.TEXT_GETTING_CHARACTER_LIST )
    LabelSetText( "LoginProgressWindowText", LoginProgressWindow.displayText )
end

function LoginProgressWindow.ShowError(errorNumber)
    LabelSetText( "LoginProgressWindowText", GetStringFromTable( "AuthorizationError",  errorNumber ) )
    WindowSetShowing("LoginProgressWindowQuitButton",    true)
    WindowSetShowing("LoginProgressWindowRepatchButton", true)
end

function LoginProgressWindow.HideErrorButtons()
    WindowSetShowing("LoginProgressWindowQuitButton",    false)
    WindowSetShowing("LoginProgressWindowRepatchButton", false)
end

----------------------------------------------------------------
-- Button event handlers
----------------------------------------------------------------

function LoginProgressWindow.Quit()
    BroadcastEvent( SystemData.Events.QUIT )
end

function LoginProgressWindow.Repatch()
    BroadcastEvent( SystemData.Events.QUIT )
end