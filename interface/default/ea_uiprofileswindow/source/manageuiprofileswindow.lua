
----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_ManageUiProfiles = 
{
    profilesListData = {},
    profilesDisplayOrder = {},
    
    characterSettings = nil,
    
    selectedProfileDataIndex = nil,
    
    switchToProfileName = L"",
}


-- Sorting Rules
EA_Window_ManageUiProfiles.SORT_ORDER_UP	         = 1
EA_Window_ManageUiProfiles.SORT_ORDER_DOWN	         = 2

EA_Window_ManageUiProfiles.PROFILE_SORTBY_NAME            = 1
EA_Window_ManageUiProfiles.PROFILE_SORTBY_LAST_MODIFIED   = 2
EA_Window_ManageUiProfiles.PROFILE_SORTBY_SHARING         = 3

local function NewSortData( param_label, param_title, param_desc )
    return { windowName=param_label, title=param_title, desc=param_desc }
end

EA_Window_ManageUiProfiles.sortData = {}
EA_Window_ManageUiProfiles.sortData[1] = NewSortData( "EA_Window_ManageUiProfilesSortButton1", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.UI_PROFILE_PROFILE_NAME ) , L"" )
EA_Window_ManageUiProfiles.sortData[2] = NewSortData( "EA_Window_ManageUiProfilesSortButton2", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.UI_PROFILE_LAST_UPDATED_TITLE ) , L"" )
EA_Window_ManageUiProfiles.sortData[3] = NewSortData( "EA_Window_ManageUiProfilesSortButton3", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.UI_PROFILE_SHARING_TITLE ) , L"" )

EA_Window_ManageUiProfiles.curSortType = EA_Window_ManageUiProfiles.PROFILE_SORTBY_NAME
EA_Window_ManageUiProfiles.curSortOrder = EA_Window_ManageUiProfiles.SORT_ORDER_UP	


local function CompareDate( date1, date2 )

    local keys = { "year", "month", "day", "hour", "minute" }
    
    for _, key in ipairs( keys )
    do
    
        if( date1[key] < date2[key] )
        then
            return -1
        elseif( date1[key] > date2[key] )
        then
            return 1
        end

    end

    return 0
end


-- This function is used to compare mods for table.sort() on
-- the profiles list display order.
local function CompareProfiles( index1, index2 )

    if( index2 == nil ) 
    then
        return false
    end
    
    local sortType  = EA_Window_ManageUiProfiles.curSortType
    local order     = EA_Window_ManageUiProfiles.curSortOrder 
    
    
    --DEBUG(L"Sorting.. Type="..sortType..L" Order="..order )
    
    local profile1 = EA_Window_ManageUiProfiles.profilesListData[ index1 ]
    local profile2 = EA_Window_ManageUiProfiles.profilesListData[ index2 ]
    
    -- Sort By Name
    if( sortType == EA_Window_ManageUiProfiles.PROFILE_SORTBY_NAME ) 
    then            
        return StringUtils.SortByString( profile1.name, profile2.name, order ) 
    end
    
    -- Sort By Last Modified
    if( sortType == EA_Window_ManageUiProfiles.PROFILE_SORTBY_LAST_MODIFIED )
    then
        local dateCompare = CompareDate( profile1.lastUpdated, profile2.lastUpdated )
        if( dateCompare == 0 )
        then
            return StringUtils.SortByString( profile1.name, profile2.name, EA_Window_ManageUiProfiles.SORT_ORDER_UP ) 
            
        elseif( order == EA_Window_ManageUiProfiles.SORT_ORDER_UP )
        then
            return (dateCompare == -1)
        else
            return (dateCompare == 1)
        end
    end
    
    if( sortType == EA_Window_ManageUiProfiles.PROFILE_SORTBY_SHARING )
    then
        
        -- Convert the Sharing information to a number value for sorting
        
        -- 1: You own it, shared.
        -- 2: You own it, not shared.
        -- 3: You dont own it (therefore is shared by someone else).
       
       
        local function GetSharingNumValue( profileData )
            
            if( not profileData.isOwnedByActiveCharacter )
            then
               return 3 
            end
            
            if( profileData.isShared )
            then
                return 1
            end
            
            return 2
        end 
                   
        
        local val1 = GetSharingNumValue( profile1 )
        local val2 = GetSharingNumValue( profile2 )
    
        if( val1 == val2 )
        then
            return StringUtils.SortByString( profile1.name, profile2.name, order )     
        else
            if( order == EA_Window_ManageUiProfiles.SORT_ORDER_UP )
            then
                return (val1 < val2)
            else
                return (val1 > val2)
            end   
        
        end
           
    end
    
end

local function SortProfilesList()

    local sortType  = EA_Window_ManageUiProfiles.curSortType
    local order     = EA_Window_ManageUiProfiles.curSortOrder 

    --DEBUG(L" Sorting Mods: type="..sortType..L" order="..order )
    table.sort( EA_Window_ManageUiProfiles.profilesListDisplayOrder, CompareProfiles )
end

local function UpdateProfilesList()
    
    ListBoxSetDisplayOrder("EA_Window_ManageUiProfilesProfilesList", EA_Window_ManageUiProfiles.profilesListDisplayOrder )
end


local function UpdateProfilesData()

    EA_Window_ManageUiProfiles.profilesListData = EA_Window_ManageUiProfiles.characterSettings.uiProfiles
    EA_Window_ManageUiProfiles.profilesListDisplayOrder = {}   
   
    -- Build a list of all the profiles
    for index, profileData in ipairs( EA_Window_ManageUiProfiles.profilesListData ) 
    do      
        -- Create a w-string version of the Last Updated Date
        profileData.lastUpdatedText = 
            GetStringFormatFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.UI_PROFILE_LAST_UPDATED_FORMAT_M_D_Y_H_M,
            {  wstring.format( L"%d", profileData.lastUpdated.month ),
               wstring.format( L"%02d", profileData.lastUpdated.day ),
               wstring.format( L"%04d", profileData.lastUpdated.year ),
               wstring.format( L"%d", profileData.lastUpdated.hour ),
               wstring.format( L"%02d", profileData.lastUpdated.minute ),
            })
            
        table.insert(EA_Window_ManageUiProfiles.profilesListDisplayOrder, index )
        
    end   
    
    
    SortProfilesList()
    UpdateProfilesList()
    
    return (EA_Window_ManageUiProfiles.profilesListData[1] ~= nil )
    
end


----------------------------------------------------------------
-- EA_Window_ManageUiProfiles Functions
----------------------------------------------------------------

-- OnInitialize Handler()
function EA_Window_ManageUiProfiles.Initialize()

    LabelSetText( "EA_Window_ManageUiProfilesTitleBarText", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.MANAGE_UI_PROFILES_TITLE ) )  

    LabelSetText( "EA_Window_ManageUiProfilesInstructions", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.MANAGE_UI_PROFILES_INTRUCTIONS ) )   

    -- Sort Buttons
    for _, data in ipairs( EA_Window_ManageUiProfiles.sortData )
    do      
        ButtonSetText( data.windowName, data.title )   
        ButtonSetStayDownFlag( data.windowName, true )       
    end
    EA_Window_ManageUiProfiles.UpdateProfileSortButtons()

    -- Profile Buttons
    ButtonSetText( "EA_Window_ManageUiProfilesSwitchButton", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.MANAGE_UI_PROFILES_SWITCH_BUTTON ) ) 
    ButtonSetText( "EA_Window_ManageUiProfilesRenameButton", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.MANAGE_UI_PROFILES_RENAME_BUTTON ) ) 
    ButtonSetText( "EA_Window_ManageUiProfilesNewButton",    GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.MANAGE_UI_PROFILES_NEW_BUTTON ) )        
    ButtonSetText( "EA_Window_ManageUiProfilesDeleteButton", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.MANAGE_UI_PROFILES_DELETE_BUTTON ) )      
    
    WindowRegisterEventHandler( "EA_Window_ManageUiProfiles", SystemData.Events.CHARACTER_SETTINGS_UPDATED, "EA_Window_ManageUiProfiles.UpdateCharacterSettings" )
    
    EA_Window_ManageUiProfiles.UpdateCharacterSettings()
end

function EA_Window_ManageUiProfiles.OnShown()
    WindowUtils.OnShown()
 
    EA_Window_ManageUiProfiles.UpdateCharacterSettings()    
    EA_Window_ManageUiProfiles.UpdateProfileButtons()
end

function EA_Window_ManageUiProfiles.Hide()
    WindowSetShowing("EA_Window_ManageUiProfiles", false )
end

function EA_Window_ManageUiProfiles.OnHidden()
    WindowUtils.OnHidden()
    
    -- Ensure the Sub Windows are Removed
    EA_Window_UiProfileCreate.End()
    EA_Window_UiProfileDelete.End()
    EA_Window_UiProfileImport.End()
    EA_Window_UiProfileRename.End()
end

------------------------------------------------------------------------------------------------
-- Character Data Functions
------------------------------------------------------------------------------------------------

function EA_Window_ManageUiProfiles.UpdateCharacterSettings()

    EA_Window_ManageUiProfiles.characterSettings = CharacterSettingsGetData()
     
    local profileData = EA_Window_ManageUiProfiles.GetActiveProfileData()
    if( profileData == nil )
    then
        return
    end
     
        
    -- Profile Name
    local text = GetStringFormatFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.MANAGE_UI_PROFILES_ACTIVE_PROFILE_TEXT, 
                                           { profileData.name } )   
                                           
    LabelSetText( "EA_Window_ManageUiProfilesActiveProfile", text )
             
       
    -- Sharing Info
    if( profileData.isOwnedByActiveCharacter )
    then    
        WindowSetShowing( "EA_Window_ManageUiProfilesActiveProfileSharingInfo", false )
    else
        WindowSetShowing( "EA_Window_ManageUiProfilesActiveProfileSharingInfo", true )
        LabelSetText( "EA_Window_ManageUiProfilesActiveProfileSharingInfo", GetStringFormatFromTable( "CustomizeUiStrings", 
                                                                                                       StringTables.CustomizeUi.MANAGE_UI_PROFILES_ACTIVE_PROFILE_SHARED_TEXT, 
                                                                                                       { profileData.character, profileData.server } ) )
                                                                                                     
    end     
        
    UpdateProfilesData()        
    
    -- If this Character is running the default UI, Show the Intro Dialog
    if( EA_Window_ManageUiProfiles.characterSettings.isRunningDefaultUi )
    then       
        EA_Window_UiProfileIntroDialog.Begin()
    end
    
end

function EA_Window_ManageUiProfiles.OnNewCharacterImportPromptDoImport( profileData )

    -- Import to the active profile    
    CharacterSettingsImportUiProfile( EA_Window_ManageUiProfiles.characterSettings.activeUiProfile, profileData.path )  
end


function EA_Window_ManageUiProfiles.IsProfileNameInUse( profileName )

    -- Convert the names to all lowercase for the comparison.
    local name = wstring.lower( profileName )
    
    for index, data in ipairs( EA_Window_ManageUiProfiles.characterSettings.uiProfiles )
    do
        if( wstring.lower( data.name ) == name )
        then
            return true
        end
       
    end
    
    return false
end


function EA_Window_ManageUiProfiles.GetProfileData( profileName )

    for index, data in ipairs( EA_Window_ManageUiProfiles.characterSettings.uiProfiles )
    do
        if( data.name == profileName )
        then
            return data
        end
       
    end

    return nil
end


function EA_Window_ManageUiProfiles.GetActiveProfileData()
    return EA_Window_ManageUiProfiles.GetProfileData( EA_Window_ManageUiProfiles.characterSettings.activeUiProfile )
end


------------------------------------------------------------------------------------------------
-- Sorting Functions

function EA_Window_ManageUiProfiles.UpdateProfileSortButtons()

    local type = EA_Window_ManageUiProfiles.curSortType
    local order = EA_Window_ManageUiProfiles.curSortOrder
    
    for index, data in ipairs( EA_Window_ManageUiProfiles.sortData ) 
    do      
        ButtonSetPressedFlag( data.windowName, index == EA_Window_ManageUiProfiles.curSortType )       
    end
    
    -- Update the Arrow
    WindowSetShowing( "EA_Window_ManageUiProfilesSortUpArrow", order == EA_Window_ManageUiProfiles.SORT_ORDER_UP )
    WindowSetShowing( "EA_Window_ManageUiProfilesSortDownArrow", order == EA_Window_ManageUiProfiles.SORT_ORDER_DOWN )
            
    local window = EA_Window_ManageUiProfiles.sortData[type].windowName

    if( order == EA_Window_ManageUiProfiles.SORT_ORDER_UP ) then		
        WindowClearAnchors( "EA_Window_ManageUiProfilesSortUpArrow" )
        WindowAddAnchor("EA_Window_ManageUiProfilesSortUpArrow", "right", window, "right", -8, 0 )
        
    else
        WindowClearAnchors( "EA_Window_ManageUiProfilesSortDownArrow" )
        WindowAddAnchor("EA_Window_ManageUiProfilesSortDownArrow", "right", window, "right", -8, 0 )
        
    end
end

function EA_Window_ManageUiProfiles.OnClickProfilesListSortButton()

    local type = WindowGetId( SystemData.ActiveWindow.name )
    
    -- If we are already using this sort type, toggle the order.
    if( type == EA_Window_ManageUiProfiles.curSortType ) 
    then
        if( EA_Window_ManageUiProfiles.curSortOrder == EA_Window_ManageUiProfiles.SORT_ORDER_UP ) then
            EA_Window_ManageUiProfiles.curSortOrder = EA_Window_ManageUiProfiles.SORT_ORDER_DOWN
        else
            EA_Window_ManageUiProfiles.curSortOrder = EA_Window_ManageUiProfiles.SORT_ORDER_UP
        end
        
    -- Otherwise change the type and use the up order.	
    else
        EA_Window_ManageUiProfiles.curSortType = type
        EA_Window_ManageUiProfiles.curSortOrder = EA_Window_ManageUiProfiles.SORT_ORDER_UP
    end

    SortProfilesList()
    UpdateProfilesList()
    
    EA_Window_ManageUiProfiles.UpdateProfileSortButtons()
    
end

function EA_Window_ManageUiProfiles.OnMouseOverProfilesListSortButton()

end


function EA_Window_ManageUiProfiles.UpdateProfileRows()

    if( EA_Window_ManageUiProfilesProfilesList.PopulatorIndices == nil )
    then
        return
    end

			
    for rowIndex, dataIndex in ipairs (EA_Window_ManageUiProfilesProfilesList.PopulatorIndices) 
    do    
        -- Update the Background Row color
        local rowName = "EA_Window_ManageUiProfilesProfilesListRow"..rowIndex
        local isSelected = (dataIndex == EA_Window_ManageUiProfiles.selectedProfileDataIndex)        
        
        DefaultColor.SetListRowTint( rowName.."Background", rowIndex, isSelected )
        
        
        local profileData = EA_Window_ManageUiProfiles.profilesListData[ dataIndex ]
        
        
        
        
        
        -- Show the 'Shared'         
        if( profileData.isOwnedByActiveCharacter )
        then 
        
            -- Show the 'Share' toggle           
        
            WindowSetShowing( rowName.."ShareButton", true )
            ButtonSetStayDownFlag( rowName.."ShareButton", true )
            ButtonSetPressedFlag( rowName.."ShareButton", profileData.isShared )
                     
            -- Hide the Text
             WindowSetShowing( rowName.."SharedBy", false )  
               
        else
            
            -- Hide the 'Share' toggle            
            WindowSetShowing( rowName.."ShareButton", false )
        
        
            -- Set the text            
            WindowSetShowing( rowName.."SharedBy", true )
            LabelSetText( rowName.."SharedBy", GetStringFormatFromTable( "CustomizeUiStrings", 
                                                                         StringTables.CustomizeUi.MANAGE_UI_PROFILES_SHARE_TEXT, 
                                                                         { profileData.character, profileData.server } ) )
        
        end 
        
        
    end
    

end

function EA_Window_ManageUiProfiles.UpdateProfileButtons()

    local isAProfileSelected            = EA_Window_ManageUiProfiles.selectedProfileDataIndex ~= nil
    local isActiveProfileSelected       = false
    local isPopupActive                 = EA_Window_UiProfilePopupDialog.Exists()
    local isPlayerOwnedProfileSelected  = false        
    
    if( isAProfileSelected )
    then
        local profileData = EA_Window_ManageUiProfiles.profilesListData[ EA_Window_ManageUiProfiles.selectedProfileDataIndex ]        
        isActiveProfileSelected = (profileData.name == EA_Window_ManageUiProfiles.characterSettings.activeUiProfile) 
        isPlayerOwnedProfileSelected = profileData.isOwnedByActiveCharacter
    end
    
    -- Update Each Profile manipulation button according to the current states
    
    -- Switch
    local switchEnabled = (isAProfileSelected) and (not isActiveProfileSelected) and (EA_Window_ManageUiProfiles.switchToProfileName == L"") and (not isPopupActive)    
    ButtonSetDisabledFlag( "EA_Window_ManageUiProfilesSwitchButton", not switchEnabled ) 
                
    -- Rename
    local renameEnabled = (isAProfileSelected) and (not EA_Window_UiProfileRename.Exists()) and (not isPopupActive) and (isPlayerOwnedProfileSelected)
    ButtonSetDisabledFlag( "EA_Window_ManageUiProfilesRenameButton", not renameEnabled )       
    
    -- New
    local newEnabled = (not EA_Window_UiProfileCreate.Exists()) and (not isPopupActive)
    ButtonSetDisabledFlag( "EA_Window_ManageUiProfilesNewButton", not newEnabled )                                  
    
    -- Delete
    local deleteEnabled = (isAProfileSelected) and (not isActiveProfileSelected) and (not EA_Window_UiProfileDelete.Exists()) and (not isPopupActive) and (isPlayerOwnedProfileSelected)
    ButtonSetDisabledFlag( "EA_Window_ManageUiProfilesDeleteButton",  not deleteEnabled ) 
    
end

function EA_Window_ManageUiProfiles.OnClickUiProfileRow()

    local rowIndex = WindowGetId( SystemData.ActiveWindow.name )
    
    local dataIndex = EA_Window_ManageUiProfilesProfilesList.PopulatorIndices[rowIndex]
    
    EA_Window_ManageUiProfiles.SetSelectedProfile( dataIndex )
end


function EA_Window_ManageUiProfiles.SetSelectedProfile( dataIndex )
    EA_Window_ManageUiProfiles.selectedProfileDataIndex = dataIndex
        
    EA_Window_ManageUiProfiles.UpdateProfileRows()
    EA_Window_ManageUiProfiles.UpdateProfileButtons()
end

function EA_Window_ManageUiProfiles.SelectProfileByName( profileName )
    EA_Window_ManageUiProfiles.selectedProfileDataIndex = dataIndex
        
    EA_Window_ManageUiProfiles.UpdateProfileRows()
    EA_Window_ManageUiProfiles.UpdateProfileButtons()
end

function EA_Window_ManageUiProfiles.GetSelectedProfileData()

    if( EA_Window_ManageUiProfiles.selectedProfileDataIndex == nil )
    then
        return nil
    end
    
    return EA_Window_ManageUiProfiles.profilesListData[ EA_Window_ManageUiProfiles.selectedProfileDataIndex ]
    
end 


function EA_Window_ManageUiProfiles.OnCloseButton()
    
    -- Close the window         
    WindowSetShowing( "EA_Window_ManageUiProfiles", false )
end


function EA_Window_ManageUiProfiles.OnSwitchButton()

    if( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) )
    then
        return
    end
    
    local profileData = EA_Window_ManageUiProfiles.GetSelectedProfileData()
    if( profileData.isOwnedByActiveCharacter )
    then    
        EA_Window_ManageUiProfiles.switchToProfileName = EA_Window_ManageUiProfiles.GetSelectedProfileData().name
    else
        EA_Window_ManageUiProfiles.switchToProfileName = EA_Window_ManageUiProfiles.GetSelectedProfileData().path
    end

    -- Create A Reload Prompt.
    EA_Window_UiProfilePopupDialog.Begin( GetStringFormatFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.SWITCH_UI_PROFILE_TITLE, { EA_Window_ManageUiProfiles.switchToProfileName } ),    
                                          GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.SWITCH_UI_PROFILE_INSTRUCTIONS ), 
                                          GetString( StringTables.Default.LABEL_YES ), 
                                          EA_Window_ManageUiProfiles.OnSwitchReloadPromptOkay, 
                                          GetString( StringTables.Default.LABEL_NO ),
                                          EA_Window_ManageUiProfiles.OnSwitchReloadPromptCancel )
    
end

function EA_Window_ManageUiProfiles.OnSwitchReloadPromptOkay()

    local name = EA_Window_ManageUiProfiles.switchToProfileName 
    EA_Window_ManageUiProfiles.switchToProfileName = L""
    CharacterSettingsSetActiveUiProfile(name)
    
end

function EA_Window_ManageUiProfiles.OnSwitchReloadPromptCancel()

    EA_Window_ManageUiProfiles.switchToProfileName = L""
end

function EA_Window_ManageUiProfiles.OnRenameButton()

    if( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) )
    then
        return
    end
    
    -- Open the Rename Window.
    EA_Window_UiProfileRename.Begin()
end

function EA_Window_ManageUiProfiles.OnNewButton()
    
    if( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) )
    then
        return
    end

    -- Open the Create Window.
    EA_Window_UiProfileCreate.Begin()
end

function EA_Window_ManageUiProfiles.OnDeleteButton()

    if( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) )
    then
        return
    end

    -- Open the Create Window.
    local profileData = EA_Window_ManageUiProfiles.GetSelectedProfileData()
    EA_Window_UiProfileDelete.Begin( profileData.name )
end


function EA_Window_ManageUiProfiles.OnToggleShareButton()
    
    local rowIndex      = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )    
    local dataIndex     = EA_Window_ManageUiProfilesProfilesList.PopulatorIndices[rowIndex]        
    local profileData   = EA_Window_ManageUiProfiles.profilesListData[ dataIndex ]
    
    profileData.isShared = not profileData.isShared    
        
    CharacterSettingsSetUiProfileShared( profileData.name, profileData.isShared )    
    ButtonSetPressedFlag( SystemData.ActiveWindow.name, profileData.isShared )

end

function EA_Window_ManageUiProfiles.OnMouseOverToggleShareButton()

    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, GetStringFromTable( "CustomizeUiStrings",  StringTables.CustomizeUi.MANAGE_UI_PROFILES_SHARE_BUTTON_TOOLTIP ) )
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_TOP)
end


function EA_Window_ManageUiProfiles.OnMouseOverSharedText()

    local rowIndex      = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )    
    local dataIndex     = EA_Window_ManageUiProfilesProfilesList.PopulatorIndices[rowIndex]        
    local profileData   = EA_Window_ManageUiProfiles.profilesListData[ dataIndex ]

    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, GetStringFormatFromTable( "CustomizeUiStrings",  
                                                                                      StringTables.CustomizeUi.MANAGE_UI_PROFILES_SHARE_TEXT_TOOLTIP, 
                                                                                      { profileData.character, profileData.server } ) )
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_TOP)
end