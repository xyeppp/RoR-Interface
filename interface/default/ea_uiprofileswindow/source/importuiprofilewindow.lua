
----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_UiProfileImport = {}
EA_Window_UiProfileImport.titleText = L""
EA_Window_UiProfileImport.instructionsText = L""
EA_Window_UiProfileImport.okayButtonText = L""
EA_Window_UiProfileImport.excludeActiveProfile = false
EA_Window_UiProfileImport.okayButtonCallback = L""
EA_Window_UiProfileImport.cancelButtonCallback = L""

EA_Window_UiProfileImport.selectedProfileDataIndex = nil


local WINDOWNAME = "EA_Window_UiProfileImport"

function EA_Window_UiProfileImport.Begin( titleText, instructionsText, okayButtonText, excludeActiveProfile, okayButtonCallback, cancelButtonCallback )

    if( DoesWindowExist( WINDOWNAME ) )
    then
        return
    end
    
    -- Set the Params    
    EA_Window_UiProfileImport.titleText             = titleText
    EA_Window_UiProfileImport.instructionsText      = instructionsText
    EA_Window_UiProfileImport.okayButtonText        = okayButtonText
    EA_Window_UiProfileImport.excludeActiveProfile  = excludeActiveProfile
    EA_Window_UiProfileImport.okayButtonCallback    = okayButtonCallback
    EA_Window_UiProfileImport.cancelButtonCallback  = cancelButtonCallback

    -- Create the Window & Show it.
    CreateWindow( WINDOWNAME, true )
    
    EA_Window_ManageUiProfiles.UpdateProfileButtons()

end

function EA_Window_UiProfileImport.End()

    if( not DoesWindowExist( WINDOWNAME ) )
    then
        return
    end
    
    EA_Window_UiProfileImport.selectedProfileDataIndex = nil

    -- Destroy the Window
    DestroyWindow( WINDOWNAME )
    
    EA_Window_ManageUiProfiles.UpdateProfileButtons()
end

function EA_Window_UiProfileImport.Exists()
    return  DoesWindowExist( WINDOWNAME )
end


----------------------------------------------------------------
--  Variables
----------------------------------------------------------------

EA_Window_UiProfileImport.profilesListData = {}
EA_Window_UiProfileImport.profilesDisplayOrder = {}

-- Sorting Rules
EA_Window_UiProfileImport.SORT_ORDER_UP	            = 1
EA_Window_UiProfileImport.SORT_ORDER_DOWN	        = 2


EA_Window_UiProfileImport.PROFILE_SORTBY_NAME           = 1
EA_Window_UiProfileImport.PROFILE_SORTBY_CHARACTER      = 2
EA_Window_UiProfileImport.PROFILE_SORTBY_SERVER         = 3
EA_Window_UiProfileImport.PROFILE_SORTBY_LAST_MODIFIED  = 4

local function NewSortData( param_label, param_title, param_desc )
    return { windowName=param_label, title=param_title, desc=param_desc }
end

EA_Window_UiProfileImport.sortData = {}
EA_Window_UiProfileImport.sortData[1] = NewSortData( WINDOWNAME.."SortButton1", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.UI_PROFILE_PROFILE_NAME ) , L"" )
EA_Window_UiProfileImport.sortData[2] = NewSortData( WINDOWNAME.."SortButton2", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.UI_PROFILE_CHARACTER_NAME ) , L"" )
EA_Window_UiProfileImport.sortData[3] = NewSortData( WINDOWNAME.."SortButton3", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.UI_PROFILE_SERVER_NAME ) , L"" )
EA_Window_UiProfileImport.sortData[4] = NewSortData( WINDOWNAME.."SortButton4", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.UI_PROFILE_LAST_UPDATED_TITLE ) , L"" )

EA_Window_UiProfileImport.curSortType = EA_Window_UiProfileImport.PROFILE_SORTBY_NAME
EA_Window_UiProfileImport.curSortOrder = EA_Window_UiProfileImport.SORT_ORDER_UP	


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
    
    local sortType  = EA_Window_UiProfileImport.curSortType
    local order     = EA_Window_UiProfileImport.curSortOrder 
    
    --DEBUG(L"Sorting.. Type="..sortType..L" Order="..order )
    
    local profile1 = EA_Window_UiProfileImport.profilesListData[ index1 ]
    local profile2 = EA_Window_UiProfileImport.profilesListData[ index2 ]
    
     -- Sort By Name
    if( sortType == EA_Window_UiProfileImport.PROFILE_SORTBY_NAME ) 
    then            
        return StringUtils.SortByString( profile1.name, profile2.name, order ) 
    end    
    
    -- Sort By Server
    if( sortType == EA_Window_UiProfileImport.PROFILE_SORTBY_SERVER ) 
    then
    
        if( profile1.server == profile2.server  ) 
        then            
            -- If the servers at the same, then sort by character                
            return StringUtils.SortByString( profile1.character, profile2.character, EA_Window_UiProfileImport.SORT_ORDER_UP )  
        else            
            return StringUtils.SortByString( profile1.server, profile2.server, order )	
        end   
      
    end
    
    -- Sort By Character
    if( sortType == EA_Window_UiProfileImport.PROFILE_SORTBY_CHARACTER ) 
    then            
        return StringUtils.SortByString( profile1.character, profile2.character, order ) 
    end
    
    -- Sort By Last Modified
    if( sortType == EA_Window_UiProfileImport.PROFILE_SORTBY_LAST_MODIFIED )
    then
        local dateCompare = CompareDate( profile1.lastUpdated, profile2.lastUpdated )
        if( dateCompare == 0 )
        then
            return StringUtils.SortByString( profile1.character, profile2.character, EA_Window_UiProfileImport.SORT_ORDER_UP ) 
            
        elseif( order == EA_Window_UiProfileImport.SORT_ORDER_UP )
        then
            return (dateCompare == -1)
        else
            return (dateCompare == 1)
        end
    end
end

local function SortProfilesList()

    local sortType  = EA_Window_UiProfileImport.curSortType
    local order     = EA_Window_UiProfileImport.curSortOrder 

    --DEBUG(L" Sorting Mods: type="..sortType..L" order="..order )
    table.sort( EA_Window_UiProfileImport.profilesListDisplayOrder, CompareProfiles )
end

local function UpdateProfilesList()
    
    ListBoxSetDisplayOrder( WINDOWNAME.."ProfilesList", EA_Window_UiProfileImport.profilesListDisplayOrder )
end


local function UpdateProfilesData()

    local activeProfile = EA_Window_ManageUiProfiles.GetActiveProfileData()
    EA_Window_UiProfileImport.profilesListData = CharacterSettingsGetAllUiProfiles()
    EA_Window_UiProfileImport.profilesListDisplayOrder = {}   
   
    -- Build a list of all the profiles
    for index, profileData in ipairs( EA_Window_UiProfileImport.profilesListData ) 
    do      

        local isActiveProfile = ( activeProfile.name == profileData.name )
                              and ( activeProfile.character == profileData.character )
                              and ( activeProfile.server == profileData.server )
           
         -- All all profiles other than the destination profile to the import list                   
        if( (not isActiveProfile) or (not EA_Window_UiProfileImport.excludeActiveProfile) )
        then
    
            -- Create a w-string version of the Last Updated Date
            profileData.lastUpdatedText = 
                GetStringFormatFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.UI_PROFILE_LAST_UPDATED_FORMAT_M_D_Y_H_M,
                {  wstring.format( L"%d", profileData.lastUpdated.month ),
                   wstring.format( L"%02d", profileData.lastUpdated.day ),
                   wstring.format( L"%04d", profileData.lastUpdated.year ),
                   wstring.format( L"%d", profileData.lastUpdated.hour ),
                   wstring.format( L"%02d", profileData.lastUpdated.minute ),
                })
                
            table.insert(EA_Window_UiProfileImport.profilesListDisplayOrder, index )
        end
    end   
    
    
    SortProfilesList()
    UpdateProfilesList()
    
    return (EA_Window_UiProfileImport.profilesListData[1] ~= nil )
    
end


----------------------------------------------------------------
-- EA_Window_UiProfileImport Functions
----------------------------------------------------------------

function EA_Window_UiProfileImport.Initialize()

    -- Text
    LabelSetText( "EA_Window_UiProfileImportTitleBarText", EA_Window_UiProfileImport.titleText )           
    LabelSetText( "EA_Window_UiProfileImportInstructions", EA_Window_UiProfileImport.instructionsText ) 
   
    -- Sort Buttons
    for _, data in ipairs( EA_Window_UiProfileImport.sortData )
    do      
        ButtonSetText( data.windowName, data.title )   
        ButtonSetStayDownFlag( data.windowName, true )       
    end
    EA_Window_UiProfileImport.UpdateProfileSortButtons()

    -- Profiles List
    UpdateProfilesData()

    -- Buttons     
    ButtonSetText( "EA_Window_UiProfileImportOkayButton", EA_Window_UiProfileImport.okayButtonText )   
    ButtonSetText( "EA_Window_UiProfileImportCancelButton", GetString( StringTables.Default.LABEL_CANCEL ) )   
    
end


-----------------------------------------------------------------------------------------
-- Sorting Functions
-----------------------------------------------------------------------------------------

function EA_Window_UiProfileImport.UpdateProfileSortButtons()

    local type = EA_Window_UiProfileImport.curSortType
    local order = EA_Window_UiProfileImport.curSortOrder
    
    for index, data in ipairs( EA_Window_UiProfileImport.sortData ) 
    do      
        ButtonSetPressedFlag( data.windowName, index == EA_Window_UiProfileImport.curSortType )       
    end
    
    -- Update the Arrow
    WindowSetShowing( "EA_Window_UiProfileImportSortUpArrow", order == EA_Window_UiProfileImport.SORT_ORDER_UP )
    WindowSetShowing( "EA_Window_UiProfileImportSortDownArrow", order == EA_Window_UiProfileImport.SORT_ORDER_DOWN )
            
    local window = EA_Window_UiProfileImport.sortData[type].windowName

    if( order == EA_Window_UiProfileImport.SORT_ORDER_UP ) then		
        WindowClearAnchors( "EA_Window_UiProfileImportSortUpArrow" )
        WindowAddAnchor("EA_Window_UiProfileImportSortUpArrow", "right", window, "right", -8, 0 )
        
    else
        WindowClearAnchors( "EA_Window_UiProfileImportSortDownArrow" )
        WindowAddAnchor("EA_Window_UiProfileImportSortDownArrow", "right", window, "right", -8, 0 )
        
    end
end

function EA_Window_UiProfileImport.OnClickProfilesListSortButton()

    local type = WindowGetId( SystemData.ActiveWindow.name )
    
    -- If we are already using this sort type, toggle the order.
    if( type == EA_Window_UiProfileImport.curSortType ) 
    then
        if( EA_Window_UiProfileImport.curSortOrder == EA_Window_UiProfileImport.SORT_ORDER_UP ) then
            EA_Window_UiProfileImport.curSortOrder = EA_Window_UiProfileImport.SORT_ORDER_DOWN
        else
            EA_Window_UiProfileImport.curSortOrder = EA_Window_UiProfileImport.SORT_ORDER_UP
        end
        
    -- Otherwise change the type and use the up order.	
    else
        EA_Window_UiProfileImport.curSortType = type
        EA_Window_UiProfileImport.curSortOrder = EA_Window_UiProfileImport.SORT_ORDER_UP
    end

    SortProfilesList()
    UpdateProfilesList()
    
    EA_Window_UiProfileImport.UpdateProfileSortButtons()
    
end

function EA_Window_UiProfileImport.OnMouseOverProfilesListSortButton()

end


function EA_Window_UiProfileImport.UpdateProfileRows()

    if( EA_Window_UiProfileImportProfilesList.PopulatorIndices == nil )
    then
        return
    end

			
    for rowIndex, dataIndex in ipairs(EA_Window_UiProfileImportProfilesList.PopulatorIndices) 
    do    
        -- Update the Background Row color
        local windowName = "EA_Window_UiProfileImportProfilesListRow"..rowIndex.."Background"
        local isSelected = (dataIndex == EA_Window_UiProfileImport.selectedProfileDataIndex)        
        
        DefaultColor.SetListRowTint( windowName, rowIndex, isSelected )
    end
    
    -- Disable the Okay Button when nothing is selected
    ButtonSetDisabledFlag( WINDOWNAME.."OkayButton", EA_Window_UiProfileImport.selectedProfileDataIndex == nil )
end


function EA_Window_UiProfileImport.OnClickUiProfileRow()

    local rowIndex = WindowGetId( SystemData.ActiveWindow.name )
    
    local dataIndex = EA_Window_UiProfileImportProfilesList.PopulatorIndices[rowIndex]
    
    EA_Window_UiProfileImport.SetSelectedProfile( dataIndex )
end


function EA_Window_UiProfileImport.SetSelectedProfile( dataIndex )
    EA_Window_UiProfileImport.selectedProfileDataIndex = dataIndex
        
    EA_Window_UiProfileImport.UpdateProfileRows()
end


function EA_Window_UiProfileImport.GetSelectedProfileData()

    if( EA_Window_UiProfileImport.selectedProfileDataIndex == nil )
    then
        return nil
    end
    
    return EA_Window_UiProfileImport.profilesListData[ EA_Window_UiProfileImport.selectedProfileDataIndex ]
    
end 


function EA_Window_UiProfileImport.OnOkayButton()

    if( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) )
    then
        return
    end
    
    -- Trigger the Callback
    EA_Window_UiProfileImport.okayButtonCallback( EA_Window_UiProfileImport.GetSelectedProfileData() )
    
    EA_Window_UiProfileImport.End()
end


function EA_Window_UiProfileImport.OnCancelButton()

    -- Cancel Button Callback
    if( EA_Window_UiProfileImport.cancelButtonCallback )
    then
        EA_Window_UiProfileImport.cancelButtonCallback()
    end
    
    EA_Window_UiProfileImport.End()
end

