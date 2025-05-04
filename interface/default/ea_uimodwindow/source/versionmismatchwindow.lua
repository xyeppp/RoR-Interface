    
----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

UiModVersionMismatchWindow = {}

UiModVersionMismatchWindow.modsList = {}
UiModVersionMismatchWindow.modsListDisplayOrder = {}

UiModVersionMismatchWindow.selectedModName = nil

UiModVersionMismatchWindow.modOptionsChanged = false


-- Sorting Rules
UiModVersionMismatchWindow.SORT_ORDER_UP	   = 1
UiModVersionMismatchWindow.SORT_ORDER_DOWN	   = 2

UiModVersionMismatchWindow.MOD_SORTBY_NAME    = 1
UiModVersionMismatchWindow.MOD_SORTBY_GAME_VERSION = 2

function NewModSortData( param_label, param_title, param_desc )
    return { windowName=param_label, title=param_title, desc=param_desc }
end

UiModVersionMismatchWindow.sortData = {}
UiModVersionMismatchWindow.sortData[1] = NewModSortData( "UiModVersionMismatchWindowSortButton1", GetPregameString( StringTables.Pregame.LABEL_MOD_NAME ), L"" )
UiModVersionMismatchWindow.sortData[2] = NewModSortData( "UiModVersionMismatchWindowSortButton2", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.VERSION_MISMATCH_TITLE ) , L"" )

UiModVersionMismatchWindow.curSortType = UiModVersionMismatchWindow.MOD_SORTBY_NAME
UiModVersionMismatchWindow.curSortOrder = UiModVersionMismatchWindow.SORT_ORDER_UP	


-- This function is used to compare mods for table.sort() on
-- the mod list display order.
local function CompareMods( index1, index2 )

    if( index2 == nil ) 
    then
        return false
    end
    
    local sortType  = UiModVersionMismatchWindow.curSortType
    local order     = UiModVersionMismatchWindow.curSortOrder 
    
    --DEBUG(L"Sorting.. Type="..sortType..L" Order="..order )
    
    local mod1 = UiModVersionMismatchWindow.modsList[ index1 ]
    local mod2 = UiModVersionMismatchWindow.modsList[ index2 ]
    
    -- Sort By Name
    if( sortType == UiModVersionMismatchWindow.MOD_SORTBY_NAME ) 
    then
        return StringUtils.SortByString( mod1.wideStrName, mod2.wideStrName, order ) 
    end
    
    -- Sort By Game Version
    if( sortType == UiModVersionMismatchWindow.MOD_SORTBY_GAME_VERSION ) 
    then            
        if( mod1.wideStrGameVersion == mod2.wideStrGameVersion  ) then        
            return StringUtils.SortByString( mod1.wideStrName, mod2.wideStrName, UiModVersionMismatchWindow.SORT_ORDER_UP )  
        else            
            StringUtils.SortByString( mod1.wideStrGameVersion, mod2.wideStrGameVersion, order )	
        end
    end
end

local function SortModsList()

    local sortType  = UiModVersionMismatchWindow.curSortType
    local order     = UiModVersionMismatchWindow.curSortOrder 

    --DEBUG(L" Sorting Mods: type="..sortType..L" order="..order )
    table.sort( UiModVersionMismatchWindow.modsListDisplayOrder, CompareMods )
end

local function UpdateModsList()
    
    ListBoxSetDisplayOrder("UiModVersionMismatchWindowModsList", UiModVersionMismatchWindow.modsListDisplayOrder )
end


local function UpdateModData()

    local mods = ModulesGetData()
    
    UiModVersionMismatchWindow.modsList = {}
    UiModVersionMismatchWindow.modsListDisplayOrder = {}
   
    local modIndex = 1
   
    -- Build a list of all the mod mods that have been automatically disabled.    
    for _, modData in ipairs( mods ) do
        
       if( modData.isAutoDisabledOnGameVersionMismatch )
       then
       
            -- Create a w-string version of the mod name for display
            modData.wideStrName = StringToWString( modData.name )
           
            modData.wideStrGameVersion = L""
            if( modData.versionsettings.gameVersion )
            then     
                modData.wideStrGameVersion = StringToWString( modData.versionsettings.gameVersion )
            end
        
            if( modData.wideStrGameVersion == L"" )
            then
                modData.wideStrGameVersion =GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.VERSION_MISMATCH_GAME_VERSION_NOT_SPECIFIED )
            end
       
            table.insert(UiModVersionMismatchWindow.modsList, modData)         
            table.insert(UiModVersionMismatchWindow.modsListDisplayOrder, modIndex)    
            modIndex = modIndex + 1     
                
            --DEBUG(L"Mod ["..modIndex..L"] = "..modData.wideStrName..L" v. "..modData.version )
       end
        
    end   
    
    
    SortModsList()
    UpdateModsList()
    
    return (UiModVersionMismatchWindow.modsList[1] ~= nil )
    
end

local function GetModByName( name ) 

    if( UiModVersionMismatchWindow.modsList == nil ) then
        return nil
    end
    
    for index, data in ipairs( UiModVersionMismatchWindow.modsList ) do
        if( data.name == name ) then
            return data
        end    
    end
    
end


----------------------------------------------------------------
-- UiModVersionMismatchWindow Functions
----------------------------------------------------------------

-- OnInitialize Handler()
function UiModVersionMismatchWindow.Initialize()

    LabelSetText( "UiModVersionMismatchWindowTitleBarText", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.VERSION_MISMATCH_TITLE ) )  
   
    -- List Sort Buttons
    ButtonSetText( "UiModVersionMismatchWindowSortButton1", GetPregameString( StringTables.Pregame.LABEL_MOD_NAME ) )
    ButtonSetText( "UiModVersionMismatchWindowSortButton2", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.VERSION_MISMATCH_SORTBY_GAMEVERSION ) )
    UiModVersionMismatchWindow.UpdateModSortButtons()
    
    -- Buttons
    ButtonSetText( "UiModVersionMismatchWindowCancelButton", GetPregameString( StringTables.Pregame.LABEL_CANCEL ) )   
    ButtonSetText( "UiModVersionMismatchWindowReEnableButton", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.VERSION_MISMATCH_REENABLE ) )   
    WindowUtils.AddWindowStateButton( "UiModVersionMismatchWindowReEnableButton", "UiModWindow" )
      
    UiModVersionMismatchWindow.UpdateInstructions()  
    
    local showWindow = UpdateModData()
    WindowSetShowing("UiModVersionMismatchWindow", showWindow) 
end

function UiModVersionMismatchWindow.OnShown()
    WindowUtils.OnShown()
    UpdateModData()
end

function UiModVersionMismatchWindow.OnHidden()
    WindowUtils.OnHidden()
    UiModVersionMismatchWindow.modOptionsChanged = false
end

function UiModVersionMismatchWindow.UpdateInstructions()

    -- Instructions    
    local text = GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.VERSION_MISMATCH_TEXT_DESC )
    LabelSetText( "UiModVersionMismatchWindowInstructions", text )     
 
    -- Current Version
    local versionText = GetStringFormatFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.VERSION_MISMATCH_TEXT_CUR_VERSION, { SystemData.ClientVersion } )     
    LabelSetText( "UiModVersionMismatchWindowCurrentVersionText", versionText )    
 
end

function UiModVersionMismatchWindow.OnClickModRow()

end

function UiModVersionMismatchWindow.OnClickModListSortButton()
    local type = WindowGetId( SystemData.ActiveWindow.name )
    
    -- If we are already using this sort type, toggle the order.
    if( type == UiModVersionMismatchWindow.curSortType ) 
    then
        if( UiModVersionMismatchWindow.curSortOrder == UiModVersionMismatchWindow.SORT_ORDER_UP ) then
            UiModVersionMismatchWindow.curSortOrder = UiModVersionMismatchWindow.SORT_ORDER_DOWN
        else
            UiModVersionMismatchWindow.curSortOrder = UiModVersionMismatchWindow.SORT_ORDER_UP
        end
        
    -- Otherwise change the type and use the up order.	
    else
        UiModVersionMismatchWindow.curSortType = type
        UiModVersionMismatchWindow.curSortOrder = UiModVersionMismatchWindow.SORT_ORDER_UP
    end

    SortModsList()
    UpdateModsList()
    
    UiModVersionMismatchWindow.UpdateModSortButtons()
end


function UiModVersionMismatchWindow.OnMouseOverModListSortButton()

end

-- Displays the clicked sort button as pressed down and positions an arrow above it
function UiModVersionMismatchWindow.UpdateModSortButtons()

    local type = UiModVersionMismatchWindow.curSortType
    local order = UiModVersionMismatchWindow.curSortOrder
    
    for index, data in ipairs( UiModVersionMismatchWindow.sortData ) do      
        ButtonSetPressedFlag( data.windowName, index == UiModVersionMismatchWindow.curSortType )       
    end
    
    -- Update the Arrow
    WindowSetShowing( "UiModVersionMismatchWindowSortUpArrow", order == UiModVersionMismatchWindow.SORT_ORDER_UP )
    WindowSetShowing( "UiModVersionMismatchWindowSortDownArrow", order == UiModVersionMismatchWindow.SORT_ORDER_DOWN )
            
    local window = UiModVersionMismatchWindow.sortData[type].windowName

    if( order == UiModVersionMismatchWindow.SORT_ORDER_UP ) then		
        WindowClearAnchors( "UiModVersionMismatchWindowSortUpArrow" )
        WindowAddAnchor("UiModVersionMismatchWindowSortUpArrow", "right", window, "right", -8, 0 )
        
    else
        WindowClearAnchors( "UiModVersionMismatchWindowSortDownArrow" )
        WindowAddAnchor("UiModVersionMismatchWindowSortDownArrow", "right", window, "right", -8, 0 )
        
    end

end

function UiModVersionMismatchWindow.OnCancelButton()
    
    -- Close the window         
    WindowSetShowing( "UiModVersionMismatchWindow", false )
end


function UiModVersionMismatchWindow.UpdateModRows()

    if (UiModVersionMismatchWindowModsList.PopulatorIndices ~= nil) then				
        for rowIndex, dataIndex in ipairs (UiModVersionMismatchWindowModsList.PopulatorIndices) do
        
            local modData = UiModVersionMismatchWindow.modsList[ dataIndex ]
            UiModVersionMismatchWindow.UpdateModRowByIndex( rowIndex, modData )				
        end
    end    

end

function UiModVersionMismatchWindow.UpdateModRowByIndex( rowIndex, modData )
    local row_mod = math.mod (rowIndex, 2)
    local color = PregameDataUtils.GetAlternatingRowColor( row_mod )			
    local labelName = "UiModVersionMismatchWindowModsListRow"..rowIndex.."Name"

    WindowSetTintColor("UiModVersionMismatchWindowModsListRow"..rowIndex.."Background", color.r, color.g, color.b)				

    local color = DefaultColor.GetRowColor( rowIndex )		        
    DefaultColor.SetWindowTint( "UiModVersionMismatchWindowModsListRow"..rowIndex.."Background",  color )		         	  
            
    -- Set the Text color based on selection
    color = { r=255, g=255, b=255 }
    if( UiModVersionMismatchWindow.selectedModName == modData.name ) 
    then
        color = { r=255, g=204, b=102 }
    end
    LabelSetTextColor( "UiModVersionMismatchWindowModsListRow"..rowIndex.."Name", color.r, color.g, color.b)
end

function UiModVersionMismatchWindow.OnReEnableButton()
    WindowUtils.ToggleShowing("UiModWindow" )
end