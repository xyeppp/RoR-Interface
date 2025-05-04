
----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_UiProfileDelete = {}

local WINDOWNAME = "EA_Window_UiProfileDelete"
local m_selectedProfileName = L""

function EA_Window_UiProfileDelete.Begin( profileName )

    if( DoesWindowExist( WINDOWNAME ) )
    then
        return
    end
    
    local profileData = EA_Window_ManageUiProfiles.GetProfileData( profileName )
    if( profileData == nil )
    then
        return
    end   
        
    m_selectedProfileName = profileName    
           
    -- If other characters are using this profile, we first need
    -- to prompt an export
    if( profileData.isShared )
    then
        local sharedWithCharacters = CharacterSettingsGetOtherCharactersUsingProfile(m_selectedProfileName)
        if( # sharedWithCharacters > 0 )
        then
        
            local title = GetStringFormatFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.EXPORT_UI_PROFILE_TITLE, { m_selectedProfileName } )   
            local text  = GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.EXPORT_UI_PROFILE_INSTRUCTIONS )   
               
            -- Spawn the Export Dialog
            EA_Window_UiProfileExport.Begin( m_selectedProfileName, 
                                             sharedWithCharacters, 
                                             title,
                                             text, 
                                             true, 
                                             EA_Window_UiProfileDelete.Show, 
                                             EA_Window_UiProfileDelete.OnCancelButton )

        end    
    end   
    
    -- Create the Window & Show it if the Export Prompt is not up.
    CreateWindow( WINDOWNAME, not EA_Window_UiProfileExport.Exists() )

    EA_Window_ManageUiProfiles.UpdateProfileButtons()
end

function EA_Window_UiProfileDelete.End()

    if( not DoesWindowExist( WINDOWNAME ) )
    then
        return
    end

    -- Destroy the Window
    DestroyWindow( WINDOWNAME )
    
    m_selectedProfileName = L""
    
    EA_Window_ManageUiProfiles.UpdateProfileButtons()
end

function EA_Window_UiProfileDelete.Exists()
    return  DoesWindowExist( WINDOWNAME )
end

function EA_Window_UiProfileDelete.Show()
    WindowSetShowing( WINDOWNAME, true )
end

----------------------------------------------------------------
-- EA_Window_UiProfileDelete Functions
----------------------------------------------------------------

function EA_Window_UiProfileDelete.Initialize()

    LabelSetText( WINDOWNAME.."TitleBarText", GetStringFormatFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.DELETE_UI_PROFILE_TITLE, { m_selectedProfileName }  ))   
    LabelSetText( WINDOWNAME.."Instructions", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.DELETE_UI_PROFILE_INTRUCTIONS ))   
    LabelSetText( WINDOWNAME.."Prompt", GetPregameString( StringTables.Pregame.LABEL_TYPE_Y_E_S ) )   
        
    --Buttons
    ButtonSetText( WINDOWNAME.."OkayButton", GetString( StringTables.Default.LABEL_OKAY ) )   
    ButtonSetText( WINDOWNAME.."CancelButton", GetString( StringTables.Default.LABEL_CANCEL ) )   
    
    EA_Window_UiProfileDelete.OnEditBoxTextChanged()
    
end

function EA_Window_UiProfileDelete.OnEditBoxTextChanged()

    -- Disable the 'Okay' Button until the confirmation text has been typed sucessfully    
    
    local confirmationText =  GetPregameString( StringTables.Pregame.LABEL_CAPITAL_YES )
    local disabled = EA_Window_UiProfileDeleteEditBox.Text ~= confirmationText
   
    ButtonSetDisabledFlag( WINDOWNAME.."OkayButton", disabled )

end

function EA_Window_UiProfileDelete.OnOkayButton()

    -- Do nothing if the button is disabled
    if( ButtonGetDisabledFlag( WINDOWNAME.."OkayButton" ) )
    then
        return
    end   
    
    -- Force the 'Okay' button to pressed.
    ButtonSetPressedFlag( WINDOWNAME.."OkayButton", true )

    -- Clear the selection
    EA_Window_ManageUiProfiles.SetSelectedProfile( nil )
    
    -- Delete the Profile
    CharacterSettingsRemoveUiProfile( m_selectedProfileName )
    
    EA_Window_UiProfileDelete.End()

end

function EA_Window_UiProfileDelete.OnCancelButton()
    EA_Window_UiProfileDelete.End()
end
