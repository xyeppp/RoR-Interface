----------------------------------------------------------------
-- Local Functions (placed here to avoid dependency issues)
----------------------------------------------------------------

----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_InteractionLastName = {}

function EA_Window_InteractionLastName.Initialize()
    -- Set the text of all the buttons/labels
    LabelSetText( "EA_Window_InteractionLastNameKeyInputLabel", GetString( StringTables.Default.TEXT_LASTNAME_ENTRY ) )
    LabelSetText( "EA_Window_InteractionLastNameTitleBarText", GetString( StringTables.Default.LABEL_LASTNAME_REGISTRAR ) )
    LabelSetText( "EA_Window_InteractionLastNameCostLabel", GetString( StringTables.Default.LABEL_LASTNAME_COST ) )
    ButtonSetText( "EA_Window_InteractionLastNameAccept", GetString( StringTables.Default.LABEL_ACCEPT ) )
    ButtonSetText( "EA_Window_InteractionLastNameCancel", GetString( StringTables.Default.LABEL_CANCEL ) )
    
    WindowRegisterEventHandler( "EA_Window_InteractionLastName", SystemData.Events.INTERACT_LAST_NAME_MERCHANT, "EA_Window_InteractionLastName.Interact" )
end

function EA_Window_InteractionLastName.OnShown()
    WindowUtils.OnShown(EA_Window_InteractionHealer.Hide, WindowUtils.Cascade.MODE_AUTOMATIC)
end

function EA_Window_InteractionLastName.OnHidden()
    WindowUtils.OnHidden()
end

function EA_Window_InteractionLastName.Hide()
    WindowSetShowing( "EA_Window_InteractionLastName", false )
end

function EA_Window_InteractionLastName.Show()
    WindowSetShowing( "EA_Window_InteractionLastName", true )
end

function EA_Window_InteractionLastName.Interact( cost )
    -- Set the money and the edit box to any current last name
    MoneyFrame.FormatMoney( "EA_Window_InteractionLastNameCost", cost, MoneyFrame.SHOW_EMPTY_WINDOWS )
    EA_Window_InteractionLastName.Show()
end

function EA_Window_InteractionLastName.OnAcceptButton()
    GameData.LastNameMerchant.requestedLastName = TextEditBoxGetText( "EA_Window_InteractionLastNameTextInput" )
    BroadcastEvent( SystemData.Events.INTERACT_LAST_NAME_MERCHANT_BUY )
end

function EA_Window_InteractionLastName.OnCancelButton()
    EA_Window_InteractionLastName.Hide()
end
