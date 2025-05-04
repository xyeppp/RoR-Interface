
----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_UiProfileIntroDialog = {}

local WINDOWNAME = "EA_Window_UiProfileIntroDialog"

function EA_Window_UiProfileIntroDialog.Begin()

    if( DoesWindowExist( WINDOWNAME ) )
    then
        return
    end       
        
    -- Only show the intro dialog for existing characters that are running the default UI.
    -- This means they have not loaded any settings data
    if( GameData.Player.level <= 1 )
    then
        return
    end
    
    -- Only show the intro dialog when there is more than just our current UI profile.
    local availProfiles = CharacterSettingsGetAllUiProfiles()
    if( availProfiles[2] == nil )
    then
        return
    end      

    -- Create the Window & Show it.
    CreateWindow( WINDOWNAME, true )     
end

function EA_Window_UiProfileIntroDialog.End()

    if( not DoesWindowExist( WINDOWNAME ) )
    then
        return
    end    
        
    -- Clear the 'New Character' flag to prevent the dialog from reappearing.
    CharacterSettingsClearRunningDefaultUiFlag()   

    -- Destroy the Window
    DestroyWindow( WINDOWNAME )
end

function EA_Window_UiProfileIntroDialog.Exists()
    return  DoesWindowExist( WINDOWNAME )
end

----------------------------------------------------------------
-- EA_Window_UiProfileIntroDialog Functions
----------------------------------------------------------------

function EA_Window_UiProfileIntroDialog.Initialize()

    -- Text
    LabelSetText( WINDOWNAME.."TitleBarText", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.MANAGE_UI_PROFILES_INTRO_TITLE) )           
    LabelSetText( WINDOWNAME.."Instructions", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.MANAGE_UI_PROFILES_INTRO_INSTRUCTIONS ) ) 
    LabelSetText( WINDOWNAME.."Instructions2", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.MANAGE_UI_PROFILES_INTRO_GEAR_TEXT ) ) 
    
    -- Buttons
    ButtonSetText( WINDOWNAME.."OkayButton", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.MANAGE_UI_PROFILES_INTRO_IMPORT_BUTTON ) )   
    ButtonSetText( WINDOWNAME.."CancelButton", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.MANAGE_UI_PROFILES_INTRO_CLOSE_BUTTON ) )
    
end


function EA_Window_UiProfileIntroDialog.OnOkayButton()
    
    -- Spawn the Import Dialog    
    EA_Window_UiProfileImport.Begin( GetStringFormatFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.IMPORT_UI_PROFILE_TITLE, { EA_Window_ManageUiProfiles.characterSettings.activeUiProfile } ),       
                                     GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.IMPORT_UI_PROFILE_INSTRUCTIONS ), 
                                     GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.IMPORT_UI_PROFILE_IMPORT_BUTTON ),
                                     true,
                                     EA_Window_ManageUiProfiles.OnNewCharacterImportPromptDoImport, 
                                     nil )
    
    EA_Window_UiProfileIntroDialog.End()
end

function EA_Window_UiProfileIntroDialog.OnCancelButton()
    
    EA_Window_UiProfileIntroDialog.End()
end
