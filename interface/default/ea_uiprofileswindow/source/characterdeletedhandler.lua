-- EA_UiProfilesCharacterDeleteHandler:
--
-- This file handles the UI protion of the Character Deletion Process. 
--
-- When a character is deleted, this code prompts the user to export
-- any shared profiles that they may have had on that character that
-- are currently in use and gives them the option of deleting all UI 
-- settings files that are curertnly stored for that character.

----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------
EA_UiProfilesCharacterDeleteHandler = {}

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------
local m_profilesToExport = {}
local m_characterName = L""
local m_readyForNextDialog = false

----------------------------------------------------------------
-- EA_UiProfilesCharacterDeleteHandler Functions
----------------------------------------------------------------

function EA_UiProfilesCharacterDeleteHandler.Initialize()
    
    RegisterEventHandler( SystemData.Events.CHARACTER_SETTINGS_ON_CHARACTER_DELETED, "EA_UiProfilesCharacterDeleteHandler.OnCharacterDeleted" )  
    RegisterEventHandler( SystemData.Events.UPDATE_PROCESSED, "EA_UiProfilesCharacterDeleteHandler.OnUpdateProcessed" )  
    
end

function EA_UiProfilesCharacterDeleteHandler.OnCharacterDeleted( serverName, characterName )  

    -- Cover the Screeen
    CreateWindow( "EA_Window_UiProfilePopupScreen", true )      
   
    m_characterName = characterName
    local characterSettings = CharacterSettingsGetData()
       
    -- Examine the Profiles data
    for _, profileData in ipairs( characterSettings.uiProfiles )
    do
        if( profileData.isShared )
        then
    
            -- If other characters are using this profile, we will need to export it.
            local othersUsing = CharacterSettingsGetOtherCharactersUsingProfile( profileData.name )
            if( othersUsing and othersUsing[1] )
            then
                table.insert( m_profilesToExport, { data=profileData, exportChars=othersUsing } )
            end            
            
            -- Turn Off Sharing. If the user elects not to delete the UI file, this will prevent the orphaned
            -- profiles from appearing in the List.
            CharacterSettingsSetUiProfileShared( profileData.name, false )    
            
        end   
    end    
    
    if( #m_profilesToExport > 0 )
    then
    
        -- Create a prompt explaining the export
        
        local text = GetStringFormatFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.DELETE_CHARACTER_SHARED_PROFILES_TEXT, 
                                               {m_characterName, towstring(#m_profilesToExport) } )
        
        EA_Window_UiProfilePopupDialog.Begin( GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.DELETE_CHARACTER_SHARED_PROFILES_TITLE ),
                                              text,
                                              GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.DELETE_CHARACTER_SHARED_PROFILES_PROMPT_CONTINUE ), 
                                              EA_UiProfilesCharacterDeleteHandler.ExportNextProfile, 
                                              nil,
                                              nil )
                                              
        EA_Window_UiProfilePopupDialog.Center()
        
    else
    
        -- Otherwise just show the delete prompt as deleting this data will not affect other characters.  
        EA_UiProfilesCharacterDeleteHandler.CreateDeleteAllDataPrompt()
    
    end  
end

function EA_UiProfilesCharacterDeleteHandler.ExportNextProfile()
  
    -- This is a Recursive Function that calls it self via the Export Dialog 'Okay' callback. 
    -- This function will continue until the user sucessfully exports all Shared Profiles.
  
   local profile = m_profilesToExport[1]       
   if( profile == nil )
   then      
         -- If no profiles are left, prompt for deletion  
        EA_UiProfilesCharacterDeleteHandler.CreateDeleteAllDataPrompt()
        return
    end  
    
    table.remove( m_profilesToExport, 1 )
                    
    local title = GetStringFormatFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.EXPORT_UI_PROFILE_TITLE, { profile.data.name } )   
    local text  = GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.DELETE_CHARACTER_SHARED_PROFILE_EXPORT_TEXT )   
       
    -- Spawn the Export Dialog     
    EA_Window_UiProfileExport.Begin( profile.data.name, 
                                     profile.exportChars, 
                                     title,
                                     text, 
                                     false, 
                                     EA_UiProfilesCharacterDeleteHandler.OnExportComplete, 
                                     nil )

end

function EA_UiProfilesCharacterDeleteHandler.OnExportComplete()
    m_readyForNextDialog = true;
end

function EA_UiProfilesCharacterDeleteHandler.OnUpdateProcessed()

    -- HACK.. since the Begin/End functions create and destroy the window,
    -- delay showing subsequent dialogs by one frame to allow delayed proccessing 
    -- to finish before spawning the next dialog.
    if( m_readyForNextDialog == true )
    then
        m_readyForNextDialog = false
        EA_UiProfilesCharacterDeleteHandler.ExportNextProfile()
    end

end

function EA_UiProfilesCharacterDeleteHandler.CreateDeleteAllDataPrompt()

    EA_Window_UiProfilePopupDialog.Begin( GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.DELETE_CHARACTER_DELETE_ALL_DATA_TITLE ),
                                          GetStringFormatFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.DELETE_CHARACTER_DELETE_ALL_DATA_INSTRUCTIONS, {m_characterName}  ), 
                                          GetString( StringTables.Default.LABEL_YES ), 
                                          EA_UiProfilesCharacterDeleteHandler.OnDeleteUIDataYes, 
                                          GetString( StringTables.Default.LABEL_NO ),
                                          EA_UiProfilesCharacterDeleteHandler.OnDeleteUIDataNo )
                                          
                                          
    EA_Window_UiProfilePopupDialog.Center()
end

function EA_UiProfilesCharacterDeleteHandler.OnDeleteUIDataYes()

    -- End handling and delete the data.
    CharacterSettingsHandleDeletedCharacter( true )
    
    DestroyWindow( "EA_Window_UiProfilePopupScreen" )
end

function EA_UiProfilesCharacterDeleteHandler.OnDeleteUIDataNo()

    -- End handling and don't delete the data.
    CharacterSettingsHandleDeletedCharacter( false )
    
    DestroyWindow( "EA_Window_UiProfilePopupScreen" )
end

        
