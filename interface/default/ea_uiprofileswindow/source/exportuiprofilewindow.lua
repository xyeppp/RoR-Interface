
----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_UiProfileExport = {}

local WINDOWNAME = "EA_Window_UiProfileExport"

local m = {}

local function InitLocalVars()
    m = 
    {        
        titleText           = L"",
        instructionsText    = L"",
        
        allowCancel = true,
        okayButtonCallback = nil,
        cancelButtonCallback = nil,
             
        selectedProfileName = L"",        
        exportCharacters    = nil,

        selectedCharacter = nil,

        hasSelectedCharacter = false,
        hasValidProfileName = false,

        allProfiles = {},
    }
end

InitLocalVars()


function EA_Window_UiProfileExport.Begin( profileName, 
                                          exportCharacters, 
                                          titleText,
                                          instructionsText,                                          
                                          allowCancel, 
                                          okayButtonCallback, 
                                          cancelButtonCallback )

    if( DoesWindowExist( WINDOWNAME ) )
    then
        return
    end
    
    m.selectedProfileName               = profileName
    m.exportCharacters                  = exportCharacters
    m.titleText                         = titleText
    m.instructionsText                  = instructionsText
    m.allowCancel                       = allowCancel
    m.okayButtonCallback                = okayButtonCallback
    m.cancelButtonCallback              = cancelButtonCallback

    -- Create the Window & Show it.
    CreateWindow( WINDOWNAME, true )

end

function EA_Window_UiProfileExport.End()

    if( not DoesWindowExist( WINDOWNAME ) )
    then
        return
    end

    -- Destroy the Window
    DestroyWindow( WINDOWNAME )
    
    InitLocalVars()
    
end

function EA_Window_UiProfileExport.Exists()
    return  DoesWindowExist( WINDOWNAME )
end


----------------------------------------------------------------
-- EA_Window_UiProfileExport Functions
----------------------------------------------------------------

local function SortCharacters( charData1, charData2 )
    
    if( charData2 == nil )
    then
        return false
    end
    
    if( charData1.characterName == charData2.characterName )
    then
        StringUtils.SortByString( charData1.serverName, charData2.serverName, StringUtils.SORT_ORDER_UP ) 
    end 
    
    
    return  StringUtils.SortByString( charData1.characterName, charData2.characterName, StringUtils.SORT_ORDER_UP ) 

end

local function IsProfileNameInUseForSelectedCharacter( profileName )

    if( m.allProfiles == nil )
    then
        return false
    end
    
    if( m.selectedCharacter == nil )
    then
        return false
    end
        
    -- Convert the names to all lowercase for the comparison.
    local name = wstring.lower( profileName )
    
    for index, data in ipairs( m.allProfiles )
    do
        -- Only examine profiles for the selected character.
        if( (data.character == m.selectedCharacter.characterName) and (data.server == m.selectedCharacter.serverName) )
        then    
            if( wstring.lower( data.name ) == name )
            then
                return true
            end
        end
    end
    
    return false

end

function EA_Window_UiProfileExport.Initialize()

    LabelSetText( WINDOWNAME.."TitleBarText", m.titleText )  
    LabelSetText( WINDOWNAME.."Instructions", m.instructionsText )   
    
    LabelSetText( WINDOWNAME.."ComboBoxPrompt", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.EXPORT_UI_PROFILE_COMBO_BOX_PROMPT ) )   
    LabelSetText( WINDOWNAME.."EditBoxPrompt", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.EXPORT_UI_PROFILE_EDIT_BOX_PROMPT ) )   
        
    --Buttons
    ButtonSetText( WINDOWNAME.."OkayButton", GetString( StringTables.Default.LABEL_OKAY ) ) 
      
    -- If there is no 'Cancel' Callback, update the display to show only one button
    if( m.cancelButtonCallback )
    then
        ButtonSetText( WINDOWNAME.."CancelButton", GetString( StringTables.Default.LABEL_CANCEL ) ) 
    else       
    
        -- Hide the 'Cancel' Buttons
        WindowSetShowing( WINDOWNAME.."CancelButton", false )        
        WindowSetShowing( WINDOWNAME.."Close", false )
        
        -- Center the 'Okay' Button
        WindowClearAnchors( WINDOWNAME.."OkayButton" )
        WindowAddAnchor( WINDOWNAME.."OkayButton", "bottom", WINDOWNAME, "bottom", 0, -10 )
        
    end
        
    -- Sort the Characters & Fill the Combo Box
    SortCharacters( m.exportCharacters )
    for _, charData in ipairs( m.exportCharacters )
    do
        local text = GetStringFormatFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.EXPORT_UI_PROFILE_NEW_OWNER_COMBO_ITEM,
                                                { charData.characterName, charData.serverName }   )

        ComboBoxAddMenuItem( WINDOWNAME.."ComboBox", text )
    end
    
    -- EditBox SetProfile 
    TextEditBoxSetText( WINDOWNAME.."EditBox", m.selectedProfileName )
        
    m.allProfiles = CharacterSettingsGetAllUiProfiles()
    
    ButtonSetDisabledFlag( WINDOWNAME.."CancelButton", not m.allowCancel )
    
    -- Force an Update of both the Combo & Edit Box check
    EA_Window_UiProfileExport.OnComboBoxSelChanged( -1 ) 
end

function EA_Window_UiProfileExport.OnComboBoxSelChanged( curSel )

    m.selectedCharacter = m.exportCharacters[ curSel ]
    
    m.hasSelectedCharacter = (m.selectedCharacter ~= nil)

    -- Update the Name Conflict Text
    if( m.hasSelectedCharacter )
    then
        local text = GetStringFormatFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.EXPORT_UI_PROFILE_NAME_CONFLICT,
                                              { m.selectedCharacter.characterName }   )
        LabelSetText( WINDOWNAME.."NameConflictText", text )
    end


    -- Trigger the text callback to check the profile name.    
    EA_Window_UiProfileExport.OnEditBoxTextChanged()
end


function EA_Window_UiProfileExport.OnEditBoxTextChanged()
        
    local profileName = EA_Window_UiProfileExportEditBox.Text
    
    m.hasValidProfileName = (profileName ~= L"") and (IsProfileNameInUseForSelectedCharacter( profileName ) == false )
    
    WindowSetShowing( WINDOWNAME.."NameConflictText", m.hasSelectedCharacter and not m.hasValidProfileName )
    
    EA_Window_UiProfileExport.UpdateOkayButton()
end

function EA_Window_UiProfileExport.UpdateOkayButton()

    local disabled = ( m.hasSelectedCharacter == false ) or (m.hasValidProfileName == false )
   
    ButtonSetDisabledFlag( WINDOWNAME.."OkayButton", disabled )
end

function EA_Window_UiProfileExport.OnOkayButton()

    -- Do nothing if the button is disabled
    if( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) )
    then
        return
    end   
    
    -- Force the 'Okay' button to pressed.
    ButtonSetPressedFlag( WINDOWNAME.."OkayButton", true )
    
    -- Export the Profile
    
    local exportCharacter   = m.selectedCharacter.characterName
    local exportServer      = m.selectedCharacter.serverName
    local exportProfile     = EA_Window_UiProfileExportEditBox.Text
    
    CharacterSettingsExportUiProfile( m.selectedProfileName, exportServer, exportCharacter, exportProfile )
        
    -- Okay Button Callback
    if( m.okayButtonCallback )
    then
        m.okayButtonCallback()
    end    
    
    EA_Window_UiProfileExport.End()

end

function EA_Window_UiProfileExport.OnCancelButton()

    -- Do nothing if the button is disabled
    if( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) )
    then
        return
    end 
    
    -- Cancel Button Callback
    if( m.cancelButtonCallback )
    then
        m.cancelButtonCallback()
    end

    EA_Window_UiProfileExport.End()
end
