----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_TransferPopup = {}

EA_Window_TransferPopup.OPEN_SERVER = 0
EA_Window_TransferPopup.LEGACY_SERVER = 1
EA_Window_TransferPopup.RETIRED_SERVER = 2

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

----------------------------------------------------------------
-- EA_Window_TransferPopup Functions
----------------------------------------------------------------

function EA_Window_TransferPopup.Initialize()       

    LabelSetText( "EA_Window_TransferPopupTitleBarText", GetPregameString( StringTables.Pregame.LABEL_SERVER_SELECT_LOW_POPULATION_TITLE))
    LabelSetText( "EA_Window_TransferPopupLabel", GetPregameString( StringTables.Pregame.LABEL_SERVER_SELECT_LOW_POPULATION_POPUP))
	LabelSetText( "EA_Window_TransferPopupLabelWarning", GetPregameString( StringTables.Pregame.LABEL_WARNING_OPEN_DEFAULT_BROWSER))
    ButtonSetText("EA_Window_TransferPopupOkButton", GetPregameString( StringTables.Pregame.LABEL_OKAY ))
	ButtonSetText("EA_Window_TransferPopupAccountPageButton", GetPregameString( StringTables.Pregame.BUTTON_OPEN_ACCOUNT_PAGE ))
end

function EA_Window_TransferPopup.Show( serverStatus )
    if ( SystemData.Territory.KOREA and ( serverStatus == EA_Window_TransferPopup.OPEN_SERVER ) )
    then
        -- Korea does NOT want to show the "Low Population Server" popup message to their clients
        return
    end
    
    if ( DoesWindowExist( "EA_Window_Transfer" ) )
    then
        WindowSetShowing("EA_Window_Transfer", true)
    else
        CreateWindow( "EA_Window_Transfer", true )
    end
    
    EA_Window_TransferPopup.UpdateServerText( serverStatus )
end

function EA_Window_TransferPopup.Ok()
    WindowSetShowing("EA_Window_Transfer", false)
end

function EA_Window_TransferPopup.UpdateServerText( serverStatus )
    if( serverStatus == EA_Window_TransferPopup.LEGACY_SERVER )
    then
        LabelSetText( "EA_Window_TransferPopupLabel", GetPregameString( StringTables.Pregame.LABEL_SERVER_SELECT_LEGACY_SERVER_POPUP))
    elseif( serverStatus == EA_Window_TransferPopup.RETIRED_SERVER )
    then
        LabelSetText( "EA_Window_TransferPopupLabel", GetPregameString( StringTables.Pregame.LABEL_SERVER_SELECT_RETIRED_SERVER_POPUP))
    else
        LabelSetText( "EA_Window_TransferPopupLabel", GetPregameString( StringTables.Pregame.LABEL_SERVER_SELECT_LOW_POPULATION_POPUP))
    end
end

function EA_Window_TransferPopup.OpenAccountPage()
    OpenURL( GameData.URLs.URL_ACCOUNT_MANAGEMENT )
end
