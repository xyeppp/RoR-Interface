
----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_UiProfileRename = {}

local WINDOWNAME = "EA_Window_UiProfileRename"
local m_selectedProfileName = L""

function EA_Window_UiProfileRename.Begin()

    if( DoesWindowExist( WINDOWNAME ) )
    then
        return
    end

    -- Create the Window & Show it.
    CreateWindow( WINDOWNAME, true )

    EA_Window_ManageUiProfiles.UpdateProfileButtons()
    
end

function EA_Window_UiProfileRename.End()

    if( not DoesWindowExist( WINDOWNAME ) )
    then
        return
    end
    
    m_selectedProfileName = L""

    -- Destroy the Window
    DestroyWindow( WINDOWNAME )
    
    EA_Window_ManageUiProfiles.UpdateProfileButtons()
end

function EA_Window_UiProfileRename.Exists()
    return  DoesWindowExist( WINDOWNAME )
end

----------------------------------------------------------------
-- EA_Window_UiProfileRename Functions
----------------------------------------------------------------

function EA_Window_UiProfileRename.Initialize()

    m_selectedProfileName = EA_Window_ManageUiProfiles.GetSelectedProfileData().name

    LabelSetText( WINDOWNAME.."TitleBarText", GetStringFormatFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.RENAME_UI_PROFILE_TITLE, { m_selectedProfileName } ))   
    LabelSetText( WINDOWNAME.."Instructions", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.RENAME_UI_PROFILE_INSTRUCTIONS ))   
    
    ButtonSetText( WINDOWNAME.."OkayButton", GetString( StringTables.Default.LABEL_OKAY ) )   
    ButtonSetText( WINDOWNAME.."CancelButton", GetString( StringTables.Default.LABEL_CANCEL ) )   
    
    TextEditBoxSetText( WINDOWNAME.."EditBox", m_selectedProfileName )    
    TextEditBoxSelectAll( WINDOWNAME.."EditBox" )
    
    EA_Window_UiProfileRename.OnEditBoxTextChanged()
end

function EA_Window_UiProfileRename.OnEditBoxTextChanged()
    
    -- Disable the 'Okay' Button until a valid profile name is entered
    
    local profileName = EA_Window_UiProfileRenameEditBox.Text
    
    local disabled = profileName == L"" or EA_Window_ManageUiProfiles.IsProfileNameInUse( profileName ) 
   
    ButtonSetDisabledFlag( WINDOWNAME.."OkayButton", disabled )

end

function EA_Window_UiProfileRename.OnOkayButton()

    -- Do nothing if the button is disabled
    if( ButtonGetDisabledFlag( WINDOWNAME.."OkayButton" ) )
    then
        return
    end   

    local profileName = EA_Window_UiProfileRenameEditBox.Text
    
    -- Rename the Profile
    CharacterSettingsRenameUiProfile( m_selectedProfileName, profileName )

    EA_Window_UiProfileRename.End()
end

function EA_Window_UiProfileRename.OnCancelButton()
    EA_Window_UiProfileRename.End()
end
