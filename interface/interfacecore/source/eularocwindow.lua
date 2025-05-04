----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_EULAROCPopup = {}

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------
local MODE_EULA = 1
local MODE_ROC = 2
local currentMode = MODE_EULA

----------------------------------------------------------------
-- Local Functions
----------------------------------------------------------------
local function SetupWindowForCurrentMode( isFirstMode )
    -- Initially disable the accept button and uncheck the checkbox
    ButtonSetDisabledFlag( "EA_Window_EULAROCPopupAcceptButton", true )
    ButtonSetPressedFlag( "EA_Window_EULAROCPopupAgreeCheckbox", false )
    
    local stringTableFileName
    if ( currentMode == MODE_EULA )
    then
        LabelSetText( "EA_Window_EULAROCPopupTitleBarText", GetPregameString( StringTables.Pregame.LABEL_EULA_TITLE ) )
        LabelSetText( "EA_Window_EULAROCPopupAgreeCheckboxLabel", GetPregameString( StringTables.Pregame.LABEL_EULA_CHECKBOX ) )
        stringTableFileName = PregameGetEULAFileName()
    elseif ( currentMode == MODE_ROC )
    then
        LabelSetText( "EA_Window_EULAROCPopupTitleBarText", GetPregameString( StringTables.Pregame.LABEL_ROC_TITLE ) )
        LabelSetText( "EA_Window_EULAROCPopupAgreeCheckboxLabel", GetPregameString( StringTables.Pregame.LABEL_ROC_CHECKBOX ) )
        stringTableFileName = PregameGetROCFileName()
    end

    if ( stringTableFileName )
    then
        LoadStringTable("EULAROC", "data/strings/<LANG>/pregame", stringTableFileName, "cache/<LANG>", "StringTables.EULAROC" )
        local numEntries = #StringTables.EULAROC+1    -- Add 1 to account for the '0th' entry.
        
        if ( isFirstMode )
        then
            TextLogCreate( "EULAROCLog", numEntries )
            TextLogAddFilterType("EULAROCLog", 1, L"")
            LogDisplayAddLog( "EA_Window_EULAROCPopupLogDisplay", "EULAROCLog", true )
        else
            TextLogClear( "EULAROCLog" )
            TextLogSetEntryLimit( "EULAROCLog", numEntries )
        end
        
        for index = 0, #StringTables.EULAROC
        do
            TextLogAddEntry( "EULAROCLog", 1, GetStringFromTable( "EULAROC", index ) )
        end

        LogDisplayScrollToTop( "EA_Window_EULAROCPopupLogDisplay" )
    
        UnloadStringTable( "EULAROC" )
    end
end

----------------------------------------------------------------
-- EA_Window_EULAROCPopup Functions
----------------------------------------------------------------

function EA_Window_EULAROCPopup.Initialize()
    ButtonSetText( "EA_Window_EULAROCPopupAcceptButton", GetPregameString( StringTables.Pregame.LABEL_PRESELECT_ACCEPT ) )
    ButtonSetText( "EA_Window_EULAROCPopupDeclineButton", GetPregameString( StringTables.Pregame.LABEL_PRESELECT_DECLINE ) )
    ButtonSetCheckButtonFlag( "EA_Window_EULAROCPopupAgreeCheckbox", true )
    
    LogDisplaySetShowTimestamp( "EA_Window_EULAROCPopupLogDisplay", false )
    LogDisplaySetShowLogName( "EA_Window_EULAROCPopupLogDisplay", false )
    TextLogDisplayShowScrollbar( "EA_Window_EULAROCPopupLogDisplay", true )
end

function EA_Window_EULAROCPopup.Shutdown()
    TextLogDestroy("EULAROCLog")
end

function EA_Window_EULAROCPopup.Show()
    local shouldShow = false
    if ( PregameHasEULAChanged() or SystemData.Territory.KOREA )
    then
        shouldShow = true
        currentMode = MODE_EULA
    elseif ( PregameHasROCChanged() )
    then
        shouldShow = true
        currentMode = MODE_ROC
    end
    
    if ( shouldShow )
    then
        if ( DoesWindowExist( "EA_Window_EULAROC" ) )
        then
            WindowSetShowing( "EA_Window_EULAROC", true )
        else
            CreateWindow( "EA_Window_EULAROC", true )
        end
        SetupWindowForCurrentMode( true )
    else
        SettingsWindowTabbed.DoLoginPerformanceWarning()    -- This is otherwise called once both EULA and ROC are accepted
    end
end

function EA_Window_EULAROCPopup.Accept()
    -- don't do anything if the checkbox hasn't been checked
    if ( ButtonGetDisabledFlag( "EA_Window_EULAROCPopupAcceptButton" ) )
    then
        return
    end

    if ( currentMode == MODE_EULA )
    then
        -- let the C side know that we have accepted the EULA
        BroadcastEvent( SystemData.Events.PREGAME_EULA_ACCEPTED )
        
        if ( PregameHasROCChanged() )
        then
            currentMode = MODE_ROC
            SetupWindowForCurrentMode( false )
        else
            WindowSetShowing( "EA_Window_EULAROC", false )
            SettingsWindowTabbed.DoLoginPerformanceWarning()
        end
    elseif ( currentMode == MODE_ROC )
    then
        -- let the C side know that we have accepted the ROC
        BroadcastEvent( SystemData.Events.PREGAME_ROC_ACCEPTED )
        
        WindowSetShowing( "EA_Window_EULAROC", false )
        SettingsWindowTabbed.DoLoginPerformanceWarning()
    end
end

function EA_Window_EULAROCPopup.Decline()
    WindowSetShowing( "EA_Window_EULAROC", false )
    -- if you don't accept then we will quit the game
    BroadcastEvent( SystemData.Events.QUIT )
end

function EA_Window_EULAROCPopup.ToggleAgreeCheckbox()
    -- don't do anything if the checkbox hasn't been enabled
    if ( ButtonGetDisabledFlag( "EA_Window_EULAROCPopupAgreeCheckbox" ) )
    then
        return
    end

    local toggleIsPressed = ButtonGetPressedFlag( "EA_Window_EULAROCPopupAgreeCheckbox" )
    ButtonSetDisabledFlag( "EA_Window_EULAROCPopupAcceptButton", not toggleIsPressed )
end

function EA_Window_EULAROCPopup.ToggleAgreeCheckboxFromLabel()
    -- don't do anything if the checkbox hasn't been enabled
    if ( ButtonGetDisabledFlag( "EA_Window_EULAROCPopupAgreeCheckbox" ) )
    then
        return
    end

    local toggleIsPressed = ButtonGetPressedFlag( "EA_Window_EULAROCPopupAgreeCheckbox" )
    ButtonSetPressedFlag( "EA_Window_EULAROCPopupAgreeCheckbox", not toggleIsPressed )
    EA_Window_EULAROCPopup.ToggleAgreeCheckbox()
end

function EA_Window_EULAROCPopup.MouseOverCheckboxLabel()
    -- don't do anything if the checkbox hasn't been enabled
    if ( ButtonGetDisabledFlag( "EA_Window_EULAROCPopupAgreeCheckbox" ) )
    then
        return
    end

    DefaultColor.LabelSetTextColor( "EA_Window_EULAROCPopupAgreeCheckboxLabel", DefaultColor.YELLOW )
end

function EA_Window_EULAROCPopup.MouseOverEndCheckboxLabel()
    -- don't do anything if the checkbox hasn't been enabled
    if ( ButtonGetDisabledFlag( "EA_Window_EULAROCPopupAgreeCheckbox" ) )
    then
        return
    end

    DefaultColor.LabelSetTextColor( "EA_Window_EULAROCPopupAgreeCheckboxLabel", DefaultColor.WHITE )
end
