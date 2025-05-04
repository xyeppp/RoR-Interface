----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

PNCWindow = {}

PNCWindow.RMTPNC_RESULT_SUCCESS             = 1
PNCWindow.RMTPNC_RESULT_PROCESSING_ERROR    = 2
PNCWindow.RMTPNC_RESULT_SVC_NOT_AVAILABLE   = 3
PNCWindow.RMTPNC_RESULT_NONE_AVAILABLE      = 4
PNCWindow.RMTPNC_RESULT_NAME_NOT_AVAILABLE  = 5

PNCWindow.ConfirmationShowing               = false

----------------------------------------------------------------
-- Local  Variables
----------------------------------------------------------------

----------------------------------------------------------------
-- PNCWindow Functions
----------------------------------------------------------------

-- OnInitialize Handler
function PNCWindow.Initialize()

    WindowRegisterEventHandler( "PNCWindow", SystemData.Events.CHARACTER_SELECT_PAID_NAME_CHANGE_RESPONSE, "PNCWindow.ShowMessages")

    LabelSetText("PNCWindowCharacterNameHeader", GetPregameString( StringTables.Pregame.TEXT_PNC_HEADER ) )
    LabelSetText("PNCWindowCharacterNameDetails", GetPregameString( StringTables.Pregame.TEXT_PNC_DETAILS ) )
    LabelSetText("PNCWindowCharacterNameLabel", GetPregameString( StringTables.Pregame.LABEL_PNC_NAME ) )
    ButtonSetText("PNCWindowOKButton",  GetPregameString( StringTables.Pregame.LABEL_SUBMIT ) )
    ButtonSetText("PNCWindowCancelButton",  GetPregameString( StringTables.Pregame.LABEL_CANCEL ) )
    
    WindowSetShowing("PNCWindowCharacterNameMessages", false)
    
    CreateWindow( "PNCWindowMockModal", false )
        
end

function PNCWindow.Show()
    WindowSetShowing( "PNCWindowMockModal", true )
    WindowSetShowing( "PNCWindow", true )
    WindowAssignFocus( "PNCWindowCharacterName", true )  
end

function PNCWindow.Hide()
    WindowSetShowing( "PNCWindowMockModal", false )
    WindowSetShowing( "PNCWindow", false )
end

function PNCWindow.ShowMessages(messageType)

    local showMessage = false
    local messageString = ""
    
    if(messageType == PNCWindow.RMTPNC_RESULT_PROCESSING_ERROR)
    then
        showMessage = true
        messageString = GetPregameString( StringTables.Pregame.TEXT_PNC_ERROR_PROCESSING )
    elseif(messageType == PNCWindow.RMTPNC_RESULT_SVC_NOT_AVAILABLE)
    then
        showMessage = true
        messageString = GetPregameString( StringTables.Pregame.TEXT_PNC_ERROR_SVC_NOT_AVAILABLE )
    elseif(messageType == PNCWindow.RMTPNC_RESULT_NONE_AVAILABLE)
    then
        showMessage = true
        messageString = GetPregameString( StringTables.Pregame.TEXT_PNC_ERROR_NONE_AVAILABLE )
    elseif(messageType == PNCWindow.RMTPNC_RESULT_NAME_NOT_AVAILABLE)
    then
        -- Bad name, go ahead and remove the invalid one from the text box as a courtesy to the player
        showMessage = true
        messageString = GetPregameString( StringTables.Pregame.TEXT_PNC_ERROR_NAME_NOT_AVAILABLE )
        TextEditBoxSetText("PNCWindowCharacterName", "")
    elseif(messageType == PNCWindow.RMTPNC_RESULT_SUCCESS)
    then        
        -- Close the window! We're done here.
        TextEditBoxSetText("PNCWindowCharacterName", "")
        PNCWindow.Hide()    
        BroadcastEvent( SystemData.Events.PREGAME_GO_TO_CHARACTER_SELECT)
    end
    
    LabelSetText("PNCWindowCharacterNameMessages", messageString)

    if(showMessage == true)
    then
        WindowSetShowing("PNCWindowCharacterNameMessages", true)
    end
    
end

-- OnLButtonUp Handler for the 'Submit' Button
function PNCWindow.SetCharacterName()
        
    -- Exit early if the name is empty
    if( PNCWindowCharacterName.Text == "" )
    then
        return;
    end
    
    local confirmationText = GetStringFormatFromTable( "Pregame", StringTables.Pregame.TEXT_PNC_CONFIRMATION, { PNCWindowCharacterName.Text } )
    
    DialogManager.MakeTwoButtonDialog( confirmationText, 
                                       GetString(StringTables.Default.LABEL_YES), PNCWindow.SendCharacterNameRequest, 
                                       GetString(StringTables.Default.LABEL_NO), PNCWindow.CancelCharacterNameRequest )
                                       
    PNCWindow.ToggleButtons(true)    

end

-- Send the request for the new name to the server
function PNCWindow.SendCharacterNameRequest()

    -- Exit early if the name is empty
    if( PNCWindowCharacterName.Text == "" )
    then
        return;
    end
    
    WindowSetShowing("PNCWindowCharacterNameMessages", false)
    RMTPaidNameChange(PNCWindowCharacterName.Text)
    
    PNCWindow.ToggleButtons(false)
    
end

-- Cancel the confirmation dialog
function PNCWindow.CancelCharacterNameRequest()
      
    PNCWindow.ToggleButtons(false)

end

function PNCWindow.ToggleButtons(confirmationShowing)

    if(confirmationShowing == true)
    then
        WindowSetShowing("PNCWindow", false)
        --WindowSetShowing("PNCWindowOKButton", false)
        --WindowSetShowing("PNCWindowCancelButton", false)
    else
        WindowSetShowing("PNCWindow", true)
        --WindowSetShowing("PNCWindowOKButton", true)
        --WindowSetShowing("PNCWindowCancelButton", true)
    end

end

-- OnLButtonUp Handler for the 'Cancel' Button
function PNCWindow.Cancel()

    -- Cancel the option to set a display name. This will log the player
    -- off the server.
    WindowSetShowing("PNCWindowCharacterNameMessages", false)
    PNCWindow.Hide()

end
