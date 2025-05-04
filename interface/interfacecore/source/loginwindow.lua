----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

LoginWindow = {}

----------------------------------------------------------------
-- Local  Variables
----------------------------------------------------------------

----------------------------------------------------------------
-- LoginWindow Functions
----------------------------------------------------------------

-- OnInitialize Handler
function LoginWindow.Initialize()
    WindowRegisterEventHandler( "LoginWindow", SystemData.Events.AUTHENTICATION_LOGIN_START, "LoginWindow.Show")

    LabelSetText("LoginWindowUsernameLabel", GetPregameString( StringTables.Pregame.LABEL_USERNAME ) )
    LabelSetText("LoginWindowPasswordLabel", GetPregameString( StringTables.Pregame.LABEL_PASSWORD ) )
    ButtonSetText("LoginWindowLoginButton",  GetPregameString( StringTables.Pregame.LABEL_LOGIN ) )

    TextEditBoxSetText( "LoginWindowUsername", GameData.Account.AccountName )
    TextEditBoxSetText( "LoginWindowPassword", GameData.Account.Password )
    
end

function LoginWindow.Show()
    --DEBUG(L"LoginWindow.Show()")
    -- Show the Login Progress Window
    WindowSetShowing( "LoginWindow", true )
    LoginWindow.isShowing = true
    WindowAssignFocus( "LoginWindowUsername", true )
    TextEditBoxSelectAll( "LoginWindowUsername" )	    
end

function LoginWindow.Hide()
    --DEBUG(L"LoginWindow.Hide()")
    -- Show the Login Progress Window
    WindowSetShowing( "LoginWindow", false )
    LoginWindow.isShowing = false
end

-- OnLButtonUp Handler for the 'Ok' Button
function LoginWindow.Login( flags, mouseX, mouseY )

    -- Set the Login Data
    GameData.Account.AccountName = LoginWindowUsername.Text
    GameData.Account.Password	 = LoginWindowPassword.Text
    
    -- Broadcast the event
    BroadcastEvent( SystemData.Events.LOGIN )

end
