
----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_UiProfileCreate = {}

local WINDOWNAME = "EA_Window_UiProfileCreate"

function EA_Window_UiProfileCreate.Begin()

    if( DoesWindowExist( WINDOWNAME ) )
    then
        return
    end

    -- Create the Window & Show it.
    CreateWindow( WINDOWNAME, true )

    EA_Window_ManageUiProfiles.UpdateProfileButtons()
    
end

function EA_Window_UiProfileCreate.End()

    if( not DoesWindowExist( WINDOWNAME ) )
    then
        return
    end

    -- Destroy the Window
    DestroyWindow( WINDOWNAME )
    
    EA_Window_ManageUiProfiles.UpdateProfileButtons()
end

function EA_Window_UiProfileCreate.Exists()
    return  DoesWindowExist( WINDOWNAME )
end

----------------------------------------------------------------
-- EA_Window_UiProfileCreate Functions
----------------------------------------------------------------

local CREATE_FROM_DEFAULT   = 1
local CREATE_FROM_TEMPLATE  = 2
local NUM_CREATE_OPTIONS    = 2

local m_createMode = CREATE_FROM_DEFAULT

local m_template = {}

function EA_Window_UiProfileCreate.Initialize()

    m_createMode = CREATE_FROM_DEFAULT
    m_template = {}
    

    LabelSetText( WINDOWNAME.."TitleBarText", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.CREATE_UI_PROFILE_TITLE ))   
    LabelSetText( WINDOWNAME.."Instructions", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.CREATE_UI_PROFILE_INSTRUCTIONS ))   
    
    ButtonSetText( WINDOWNAME.."OkayButton", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.CREATE_UI_PROFILE_CREATE_BUTTON ) )
    ButtonSetText( WINDOWNAME.."CancelButton", GetString( StringTables.Default.LABEL_CANCEL ) )   
   
    -- Create Options      	
    LabelSetText( WINDOWNAME.."CreateFromInstructions", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.CREATE_UI_PROFILE_CREATE_FROM_INSTRUCTIONS ))   
    LabelSetText( WINDOWNAME.."CreateFromDefaultLabel", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.CREATE_UI_PROFILE_CREATE_FROM_DEFAULT ) )   
    LabelSetText( WINDOWNAME.."CreateFromTemplateLabel", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.CREATE_UI_PROFILE_CREATE_FROM_TEMPLATE ) )          
    
    ButtonSetStayDownFlag( WINDOWNAME.."CreateFromDefaultButton", true )
    ButtonSetStayDownFlag( WINDOWNAME.."CreateFromTemplateButton", true )    
    
    ButtonSetText( WINDOWNAME.."SelectTemplateButton", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.CREATE_UI_PROFILE_CREATE_SELECT_TEMPLATE_BUTTON ) )  
    
    EA_Window_UiProfileCreate.OnEditBoxTextChanged()
    EA_Window_UiProfileCreate.UpdateCreateOptionButtons()
    EA_Window_UiProfileCreate.UpdateTemplateText()
end

function EA_Window_UiProfileCreate.OnEditBoxTextChanged()
    EA_Window_UiProfileCreate.UpdateOkayButton()
end

function EA_Window_UiProfileCreate.UpdateOkayButton()
    
    -- Disable the 'Okay' Button until a valid profile name is entered
    
    local profileName = EA_Window_UiProfileCreateEditBox.Text
    
    local disabled = profileName == L"" or EA_Window_ManageUiProfiles.IsProfileNameInUse( profileName ) 
    
    -- If the user wants to create from a template, they must also select a valid template
    if( (m_createMode == CREATE_FROM_TEMPLATE) and (m_template.name == nil) )
    then 
        disabled = true
    end
   
    ButtonSetDisabledFlag( WINDOWNAME.."OkayButton", disabled )

end

function EA_Window_UiProfileCreate.UpdateCreateOptionButtons()

    ButtonSetPressedFlag( WINDOWNAME.."CreateFromDefaultButton", m_createMode == CREATE_FROM_DEFAULT )
    ButtonSetPressedFlag( WINDOWNAME.."CreateFromTemplateButton", m_createMode == CREATE_FROM_TEMPLATE )

    -- Only Enable the 'Select Template' button when in template mode.
    ButtonSetDisabledFlag( WINDOWNAME.."SelectTemplateButton", m_createMode ~= CREATE_FROM_TEMPLATE )
   
end

function EA_Window_UiProfileCreate.UpdateTemplateText()

    local text = GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.CREATE_UI_PROFILE_SELECTED_TEMPLATE_NONE_TEXT )
    local color = DefaultColor.LIGHT_GRAY
    if( m_template.name ~= nil ) 
    then
        text = GetStringFormatFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.CREATE_UI_PROFILE_SELECTED_TEMPLATE_TEXT, 
                                        { m_template.name, m_template.character, m_template.server } ) 
                                        
        color = DefaultColor.LIGHT_BLUE
    end        

    LabelSetText( WINDOWNAME.."SelectedTemplateText", text )
    DefaultColor.SetLabelColor( WINDOWNAME.."SelectedTemplateText", color )
end


function EA_Window_UiProfileCreate.OnClickCreateFromButton()
    local modeId = WindowGetId( SystemData.ActiveWindow.name )
    EA_Window_UiProfileCreate.SelectCreateMode( modeId )
end
   
function EA_Window_UiProfileCreate.SelectCreateMode( modeId )
    m_createMode = modeId 
   
    EA_Window_UiProfileCreate.UpdateCreateOptionButtons()    
    EA_Window_UiProfileCreate.UpdateOkayButton()
end


function EA_Window_UiProfileCreate.OnSelectTemplateButton()

    -- Do nothing if the button is disabled
    if( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) )
    then
        return
    end   

    -- Spawn the Import Dialog    
    EA_Window_UiProfileImport.Begin( GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.CREATE_UI_PROFILE_TEMPLATE_SELECT_TITLE ), 
                                    GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.CREATE_UI_PROFILE_TEMPLATE_SELECT_TEXT ), 
                                    GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.CREATE_UI_PROFILE_TEMPLATE_SELECT_OKAY_BUTTON ),
                                    false,
                                    EA_Window_UiProfileCreate.OnSelectTemplateOkay, 
                                    nil )

end

function EA_Window_UiProfileCreate.OnSelectTemplateOkay( profileData )
    m_template = profileData
    EA_Window_UiProfileCreate.UpdateTemplateText()
    EA_Window_UiProfileCreate.UpdateOkayButton()
end

function EA_Window_UiProfileCreate.OnOkayButton()

    -- Do nothing if the button is disabled
    if( ButtonGetDisabledFlag( WINDOWNAME.."OkayButton" ) )
    then
        return
    end   

    local profileName = EA_Window_UiProfileCreateEditBox.Text
    
    -- Create the New Profile
    CharacterSettingsCreateUiProfile( profileName )
    
    -- Import if a template is specified. 
    if( m_template.name ~= nil )
    then        
        CharacterSettingsImportUiProfile( profileName, m_template.path )
    end

    EA_Window_UiProfileCreate.End()
    
end

function EA_Window_UiProfileCreate.OnCancelButton()
    EA_Window_UiProfileCreate.End()
end
