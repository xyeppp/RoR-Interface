    
--------------------------------------------------------------------
-- Advanced Settings

function UiModWindow.InitAdvancedWindow()
        
    LabelSetText( "UiModAdvancedWindowTitleBarText", GetPregameString( StringTables.Pregame.LABEL_ADVANCED_MOD_SETTINGS ) )
    
    LabelSetText( "UiModAdvancedWindowInstructions", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.TEXT_UI_ADVANCED_SETTINGS_WARNING ) )   
    
    -- EA Default / Custom Toggle 
    LabelSetText( "UiModAdvancedWindowUseEADefaultToggleLabel", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.TEXT_LOAD_EA_DEFAULT_UI ) )
    ButtonSetStayDownFlag( "UiModAdvancedWindowUseEADefaultToggleButton", true )   

    LabelSetText( "UiModAdvancedWindowUseCustomUIToggleLabel", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.TEXT_REPLACE_EA_DEFAULT ) )
    ButtonSetStayDownFlag( "UiModAdvancedWindowUseCustomUIToggleButton", true )   
    
    --- Toggle 
    LabelSetText( "UiModAdvancedWindowShowInAddOnsListCheckLabel", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.TEXT_SHOW_MAIN_UI_IN_MODS_LIST ) )
    ButtonSetStayDownFlag( "UiModAdvancedWindowShowInAddOnsListCheckButton", true )  

    -- Add Ons Directory
    LabelSetText( "UiModAdvancedWindowCustomUITitle", GetPregameString( StringTables.Pregame.LABEL_MAIN_INTERFACE  ) )
    
    LabelSetText( "UiModAdvancedWindowAddOnsTitle", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_ADD_ONS_DIRECTORY ) )   

    ButtonSetText( "UiModAdvancedWindowDebugWindowButton", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_DEBUG_LOG_BUTTON ) )   
    ButtonSetText( "UiModAdvancedWindowOkayButton", GetPregameString( StringTables.Pregame.LABEL_OKAY ) )   
    ButtonSetText( "UiModAdvancedWindowCancelButton", GetPregameString( StringTables.Pregame.LABEL_CANCEL ) )   

end

function UiModWindow.UpdateAdvancedSettings()
    
    -- EA Default / Custom Path Toggle
    ButtonSetPressedFlag( "UiModAdvancedWindowUseEADefaultToggleButton", not SystemData.Settings.UseCustomUI )
    ButtonSetPressedFlag( "UiModAdvancedWindowUseCustomUIToggleButton", SystemData.Settings.UseCustomUI )
           
    TextEditBoxSetText( "UiModAdvancedWindowCustomUiDirectory", SystemData.Directories.CustomInterface )
        
    ButtonSetPressedFlag( "UiModAdvancedWindowShowInAddOnsListCheckButton", UiModWindow.Settings.showMainUiInModsList )

    -- Add Ons
    TextEditBoxSetText( "UiModAdvancedWindowAddOnsDirectory", SystemData.Directories.AddOnsInterface )         
end

function UiModWindow.SelectMainUiLoadOption()
    
    if( SystemData.ActiveWindow.name == "UiModAdvancedWindowUseEADefaultToggle" )
    then  
        UiModWindow.SetLoadCustomUI( false )      
    else    
        UiModWindow.SetLoadCustomUI( true )
    end

end

function UiModWindow.SetLoadCustomUI( value )
    ButtonSetPressedFlag( "UiModAdvancedWindowUseEADefaultToggleButton", not value )
    ButtonSetPressedFlag( "UiModAdvancedWindowUseCustomUIToggleButton", value )  
end


function UiModWindow.OnAdvancedButton()
    local showing = WindowGetShowing("UiModAdvancedWindow")
    WindowSetShowing("UiModAdvancedWindow", not showing )
end

function UiModWindow.OnAdvancedShown()
    WindowUtils.OnShown()
    UiModWindow.UpdateAdvancedSettings()
end

function UiModWindow.OnAdvancedHidden()
    WindowUtils.OnHidden()
end


function UiModWindow.ToggleShowMainUiInModsList()
    UiModWindow.Settings.showMainUiInModsList = not UiModWindow.Settings.showMainUiInModsList
    ButtonSetPressedFlag( "UiModAdvancedWindowShowInAddOnsListCheckButton", UiModWindow.Settings.showMainUiInModsList )
    UiModWindow.RefreshData()  
end

function UiModWindow.OnDebugWindowButton()
    local showing = WindowGetShowing("DebugWindow")
    WindowSetShowing("DebugWindow", not showing )
end

function UiModWindow.OnAdvancedOkayButton()

    local optionsChanged = false
    
    local useCustom = ButtonGetPressedFlag( "UiModAdvancedWindowUseCustomUIToggleButton" )
    if( useCustom ~= SystemData.Settings.UseCustomUI )
    then
       optionsChanged = true
    end
    
    -- Custom Ui Directory
    local oldText  = SystemData.Directories.CustomInterface
    local newText  = UiModAdvancedWindowCustomUiDirectory.Text
    if( oldText ~= newText )
    then
        optionsChanged = true
    end 
    
    -- Add Ons Directory
    local oldText  = SystemData.Directories.AddOnsInterface
    local newText  = UiModAdvancedWindowAddOnsDirectory.Text
    if( oldText ~= newText )
    then
        UiModWindow.UpdateInstructions()
        optionsChanged = true
    end 
    
    if( (optionsChanged == false) and (UiModWindow.isInErrorMode == false) )
    then        
        WindowSetShowing( "UiModAdvancedWindow", false )
        return
    end
    
    UiModWindow.CreateReloadDialogAdvanced()
end

function UiModWindow.OnAdvancedCancelButton()

    WindowSetShowing("UiModAdvancedWindow", false )
    
    if( UiModWindow.isInErrorMode )
    then
        UiModWindow.ShowCustomUIErrorMessage()
    end
end


function UiModWindow.CreateReloadDialogAdvanced()

    -- Otherwise pop up a dialog.
    DialogManager.MakeTwoButtonDialog(  GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.TEXT_UI_MOD_SETTINGS_CHANGED_DIALOG ), 
                                            GetString( StringTables.Default.LABEL_YES ), UiModWindow.SaveAndReloadAdvanced, 
                                            GetString( StringTables.Default.LABEL_NO ),  UiModWindow.CancelAdvancedDialog )
    
end

function UiModWindow.SaveAndReloadAdvanced()

    -- Close the window     
    WindowSetShowing( "UiModAdvancedWindow", false )

    SystemData.Settings.UseCustomUI = ButtonGetPressedFlag( "UiModAdvancedWindowUseCustomUIToggleButton" )

    SystemData.Directories.CustomInterface = UiModAdvancedWindowCustomUiDirectory.Text
    SystemData.Directories.AddOnsInterface = UiModAdvancedWindowAddOnsDirectory.Text
          

    BroadcastEvent( SystemData.Events.USER_SETTINGS_CHANGED )
    BroadcastEvent( SystemData.Events.RELOAD_INTERFACE )
   
end

function UiModWindow.CancelAdvancedDialog()
    if( UiModWindow.isInErrorMode and WindowGetShowing("UiModAdvancedWindow") == false )
    then
        UiModWindow.ShowCustomUIErrorMessage()
    end
end

function UiModWindow.ShowCustomUIErrorMessage()

    UiModWindow.isInErrorMode = true

    local dir  = SystemData.Directories.CustomInterface
    local text = GetStringFormatFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.TEXT_CUSTOM_UI_DIRECTORY_ERROR, { dir }  )

    -- Otherwise pop up a dialog.
    DialogManager.MakeTwoButtonDialog(  text,
                                        GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_REVERT ), UiModWindow.RevertToEADefaultData, 
                                        GetString( StringTables.Default.LABEL_CANCEL ),  UiModWindow.ShowAdvancedDialog )
    
end

function UiModWindow.RevertToEADefaultData()
    UiModWindow.UpdateAdvancedSettings()  
    UiModWindow.SetLoadCustomUI( false )
    UiModWindow.CreateReloadDialogAdvanced()
end

function UiModWindow.ShowAdvancedDialog()
    WindowSetShowing("UiModAdvancedWindow", true )
end
