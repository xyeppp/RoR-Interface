----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_RuleSetPopup = {}

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------
local MODE_OPENRVR = 1
local MODE_ROLEPLAY = 2
local currentMode = MODE_OPENRVR
local currentServer = nil

----------------------------------------------------------------
-- Local Functions
----------------------------------------------------------------
local function SetupWindowForCurrentMode()
    if ( currentMode == MODE_OPENRVR )
    then
        LabelSetText( "EA_Window_RuleSetPopupTitleBarText", GetPregameString( StringTables.Pregame.LABEL_OPEN_RVR_ADDENDUM_TITLE ) )
        LabelSetText( "EA_Window_RuleSetPopupScrollWindowScrollChildLabel", GetPregameString( StringTables.Pregame.LABEL_OPEN_RVR_ADDENDUM ) )
    else
        LabelSetText( "EA_Window_RuleSetPopupTitleBarText", GetPregameString( StringTables.Pregame.LABEL_ROLE_PLAYING_ADDENDUM_TITLE ) )
        local bodyText = GetPregameString( StringTables.Pregame.LABEL_RP_ADDENDUM1 )..GetPregameString( StringTables.Pregame.LABEL_RP_ADDENDUM2 )
        LabelSetText( "EA_Window_RuleSetPopupScrollWindowScrollChildLabel", bodyText )
    end
    
    ScrollWindowUpdateScrollRect( "EA_Window_RuleSetPopupScrollWindow" )
    ScrollWindowSetOffset( "EA_Window_RuleSetPopupScrollWindow", 0 )
end

----------------------------------------------------------------
-- EA_Window_RuleSetPopup Functions
----------------------------------------------------------------

function EA_Window_RuleSetPopup.Initialize()
    ButtonSetText( "EA_Window_RuleSetPopupAcceptButton", GetPregameString( StringTables.Pregame.LABEL_PRESELECT_ACCEPT ) )
    ButtonSetText( "EA_Window_RuleSetPopupDeclineButton", GetPregameString( StringTables.Pregame.LABEL_PRESELECT_DECLINE ) )
end

function EA_Window_RuleSetPopup.Show( serverData )
    if ( DoesWindowExist( "EA_Window_RuleSet" ) )
    then
        WindowSetShowing( "EA_Window_RuleSet", true )
    else
        CreateWindow( "EA_Window_RuleSet", true )
    end
    
    currentServer = serverData
    if ( currentServer.rulesetOpenRvR )
    then
        currentMode = MODE_OPENRVR
    elseif ( currentServer.rulesetRolePlaying )
    then
        currentMode = MODE_ROLEPLAY
    end
    SetupWindowForCurrentMode()
end

function EA_Window_RuleSetPopup.Accept()
    if ( ( currentMode == MODE_OPENRVR ) and currentServer.rulesetRolePlaying )
    then
        currentMode = MODE_ROLEPLAY
        SetupWindowForCurrentMode()
    else
        ServerSelectWindow.SelectServerAddendumAccepted()
        WindowSetShowing( "EA_Window_RuleSet", false )
    end
end

function EA_Window_RuleSetPopup.Decline()
    WindowSetShowing( "EA_Window_RuleSet", false )
end
