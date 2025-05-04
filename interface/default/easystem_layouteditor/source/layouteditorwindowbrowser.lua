
----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------


LayoutEditor.windowListDisplayOrder = {}
LayoutEditor.windowBrowserDataList = {}

LayoutEditor.selectedWindowBrowserRowName = nil

-- Sorting Rules
LayoutEditor.SORT_ORDER_UP	       = 1
LayoutEditor.SORT_ORDER_DOWN	   = 2

LayoutEditor.WINDOW_SORTBY_NAME    = 1
LayoutEditor.WINDOW_SORTBY_LOCKED  = 2
LayoutEditor.WINDOW_SORTBY_HIDDEN  = 3

function NewModSortData( param_label, param_title, param_desc )
    return { windowName=param_label, title=param_title, desc=param_desc }
end

LayoutEditor.sortData = {}
LayoutEditor.sortData[1] = NewModSortData( "LayoutEditorWindowControlScreenBrowserSortButton1", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_WINDOW_NAME ), L"" )
LayoutEditor.sortData[2] = NewModSortData( "LayoutEditorWindowControlScreenBrowserSortButton2", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_LOCKED ), L"" )
LayoutEditor.sortData[3] = NewModSortData( "LayoutEditorWindowControlScreenBrowserSortButton3", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_HIDDEN ), L"" )

LayoutEditor.curSortType = LayoutEditor.WINDOW_SORTBY_NAME
LayoutEditor.curSortOrder = LayoutEditor.SORT_ORDER_UP	


-- This function is used to compare windows for table.sort() on
-- the window list display order.
local function CompareWindows( index1, index2 )

    if( index2 == nil ) then
        return false
    end
    
    local sortType  = LayoutEditor.curSortType
    local order     = LayoutEditor.curSortOrder 
    
    --DEBUG(L"Sorting.. Type="..sortType..L" Order="..order )
    
    local frame1 = LayoutEditor.windowBrowserDataList[ index1 ]
    local frame2 = LayoutEditor.windowBrowserDataList[ index2 ]
    
    -- Sort By Name
    if( sortType == LayoutEditor.WINDOW_SORTBY_NAME ) then
        return StringUtils.SortByString( frame1:GetDisplayName(), frame2:GetDisplayName(), order ) 
    end
    
    -- Sort By Locked
    if( sortType == LayoutEditor.WINDOW_SORTBY_LOCKED ) then
        if( frame1:IsLocked() == frame2:IsLocked() ) then        
            return StringUtils.SortByString( frame1:GetDisplayName(), frame2:GetDisplayName(), LayoutEditor.SORT_ORDER_UP )  
        else            
            if( order == LayoutEditor.SORT_ORDER_UP ) then	
                return ( frame2:IsLocked() )
            else
                return ( frame1:IsLocked() )
            end		
        end
    end
    
    -- Sort By Hidden
    if( sortType == LayoutEditor.WINDOW_SORTBY_HIDDEN ) then
        if( frame1:IsHidden() == frame2:IsHidden()  ) then       
            
            -- If the the frames do not allow hiding, sort by that seperately
            if( frame1:AllowHiding() == frame2:AllowHiding() )
            then          
                 return StringUtils.SortByString( frame1:GetDisplayName(), frame2:GetDisplayName(), LayoutEditor.SORT_ORDER_UP )  
            else
                if( order == LayoutEditor.SORT_ORDER_UP ) 
                then	
                    return ( frame2:AllowHiding() )
                else
                    return ( frame1:AllowHiding() )
                end	            
            end
        else            
            if( order == LayoutEditor.SORT_ORDER_UP ) 
            then	
                return ( frame2:IsHidden() )
            else
                return ( frame1:IsHidden() )
            end		
        end
    end
end

local function SortWindowsList()

    local sortType  = LayoutEditor.curSortType
    local order     = LayoutEditor.curSortOrder 

    --DEBUG(L" Sorting Mods: type="..sortType..L" order="..order )
    table.sort( LayoutEditor.windowListDisplayOrder, CompareWindows )
end

local function UpdateWindowsList()
    
    ListBoxSetDisplayOrder("LayoutEditorWindowControlScreenBrowserWindowsList", LayoutEditor.windowListDisplayOrder )
end


----------------------------------------------------------------
-- LayoutEditor Window Browser Functions
----------------------------------------------------------------

-- OnInitialize Handler()
function LayoutEditor.InitializeWindowBrowser()

    LabelSetText( "LayoutEditorWindowControlScreenBrowserTitleBarText", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_WINDOW_BROWSER_TITLE ) )
   
   
    -- List Sort Buttons
    ButtonSetText( "LayoutEditorWindowControlScreenBrowserSortButton1", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_WINDOW_NAME ) )
    ButtonSetText( "LayoutEditorWindowControlScreenBrowserSortButton2", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_LOCKED ) )
    ButtonSetText( "LayoutEditorWindowControlScreenBrowserSortButton3", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_HIDDEN ) )    

     
    -- Buttons
    --ButtonSetText("LayoutEditorWindowControlScreenBrowserRestoreDefaultsButton",  GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_RESTORE_DEFAULTS ) )
    --ButtonSetText("LayoutEditorWindowControlScreenBrowserResetButton",  GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_RESET_WINDOWS ) )
    ButtonSetText("LayoutEditorWindowControlScreenBrowserLockAllButton",  GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_LOCK_ALL_WINDOWS ) )
    ButtonSetText("LayoutEditorWindowControlScreenBrowserUnlockAllButton",  GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_UNLOCK_ALL_WINDOWS ) )
  
    
    LayoutEditor.UpdateWindowBroswerList()
    
    WindowSetShowing("LayoutEditorWindowControlScreenBrowser", false )
    
end

function LayoutEditor.ShutdownWindowBrowser()

    -- Clear the window
    LayoutEditor.windowListDisplayOrder = {}
    UpdateWindowsList()
end


function LayoutEditor.UpdateWindowBroswerList()
    -- Populate the Display List
    LayoutEditor.windowBrowserDataList = {}
    LayoutEditor.windowListDisplayOrder = {}
    local index = 1
    for _, data in pairs( LayoutEditor.framesList )
    do
       table.insert( LayoutEditor.windowBrowserDataList, data )
       table.insert( LayoutEditor.windowListDisplayOrder, index )
       
       index = index + 1
    end
    SortWindowsList()
    UpdateWindowsList()
    
    LayoutEditor.UpdateWindowSortButtons()
end


function LayoutEditor.OnClickWindowBrowserListSortButton()
    local type = WindowGetId( SystemData.ActiveWindow.name )
    
    -- If we are already using this sort type, toggle the order.
    if( type == LayoutEditor.curSortType ) then
        if( LayoutEditor.curSortOrder == LayoutEditor.SORT_ORDER_UP ) then
            LayoutEditor.curSortOrder = LayoutEditor.SORT_ORDER_DOWN
        else
            LayoutEditor.curSortOrder = LayoutEditor.SORT_ORDER_UP
        end
        
    -- Otherwise change the type and use the up order.	
    else
        LayoutEditor.curSortType = type
        LayoutEditor.curSortOrder = LayoutEditor.SORT_ORDER_UP
    end

    SortWindowsList()
    UpdateWindowsList()
    
    LayoutEditor.UpdateWindowSortButtons()
end


function LayoutEditor.OnMouseOverWindowBrowserListSortButton()

end

-- Displays the clicked sort button as pressed down and positions an arrow above it
function LayoutEditor.UpdateWindowSortButtons()

    local type = LayoutEditor.curSortType
    local order = LayoutEditor.curSortOrder

    
    for index, data in pairs( LayoutEditor.sortData ) do      
        ButtonSetPressedFlag( data.windowName, index == LayoutEditor.curSortType )       
    end
    
    -- Update the Arrow
    WindowSetShowing( "LayoutEditorWindowControlScreenBrowserSortUpArrow", order == LayoutEditor.SORT_ORDER_UP )
    WindowSetShowing( "LayoutEditorWindowControlScreenBrowserSortDownArrow", order == LayoutEditor.SORT_ORDER_DOWN )
            
    local window = LayoutEditor.sortData[type].windowName

    if( order == LayoutEditor.SORT_ORDER_UP ) then		
        WindowClearAnchors( "LayoutEditorWindowControlScreenBrowserSortUpArrow" )
        WindowAddAnchor("LayoutEditorWindowControlScreenBrowserSortUpArrow", "right", window, "right", -8, 0 )
        
    else
        WindowClearAnchors( "LayoutEditorWindowControlScreenBrowserSortDownArrow" )
        WindowAddAnchor("LayoutEditorWindowControlScreenBrowserSortDownArrow", "right", window, "right", -8, 0 )
        
    end

end


function LayoutEditor.OnOkayButton()

    LayoutEditor.OnApplyButton()

    -- Close the window     
    WindowSetShowing( "LayoutEditorWindowControlScreenBrowser", false )
    
end

function LayoutEditor.OnApplyButton()

    SystemData.Settings.UseCustomUI = ButtonGetPressedFlag( "UiModAdvancedWindowUseCustomUICheckButton" )

    SystemData.Directories.CustomInterface = WStringToString( UiModAdvancedWindowCustomUiDirectory.Text )
    SystemData.Directories.AddOnsInterface = WStringToString( UiModAdvancedWindowAddOnsDirectory.Text )
          

    for index, windowData in pairs( LayoutEditor.windowsList ) do    
        ModuleSetEnabled( windowData.name, windowData.isEnabled  )
    end    
    
   
    BroadcastEvent( SystemData.Events.USER_SETTINGS_CHANGED )
    BroadcastEvent( SystemData.Events.RELOAD_INTERFACE )
    

end


function LayoutEditor.OnCancelButton()

    LayoutEditor.OnResetButton()
    
    -- Close the window         
    WindowSetShowing( "LayoutEditorWindowControlScreenBrowser", false )
end

function LayoutEditor.OnClickModGroupTab()
    local tab = WindowGetId( SystemData.ActiveWindow.name )
    LayoutEditor.ShowModTab( tab )  
end


function LayoutEditor.UpdateWindowBrowserRows()

    if (LayoutEditorWindowControlScreenBrowserWindowsList.PopulatorIndices ~= nil) then				
        for rowIndex, dataIndex in pairs (LayoutEditorWindowControlScreenBrowserWindowsList.PopulatorIndices) do
        
            local frame = LayoutEditor.windowBrowserDataList[ dataIndex ]
            LayoutEditor.UpdateWindowBrowserRowByIndex( rowIndex, frame )				
        end
    end    

end

function LayoutEditor.UpdateWindowBrowserForFrame( frame )

    if (LayoutEditorWindowControlScreenBrowserWindowsList.PopulatorIndices ~= nil) then				
        for rowIndex, dataIndex in pairs (LayoutEditorWindowControlScreenBrowserWindowsList.PopulatorIndices) do
        
            local rowFrame = LayoutEditor.windowBrowserDataList[ dataIndex ]
            if( rowFrame ) 
            then
            
                if( rowFrame:GetSourceWindowName() == frame:GetSourceWindowName() ) 
                then
                    LayoutEditor.UpdateWindowBrowserRowByIndex( rowIndex, frame )	
                    return			
                end
            end
        end
    end   
end

function LayoutEditor.UpdateWindowBrowserRowByIndex( rowIndex, frame )

    local row_window = math.mod(rowIndex, 2)
    local color = PregameDataUtils.GetAlternatingRowColor( row_window )			
    
    local rowName = "LayoutEditorWindowControlScreenBrowserWindowsListRow"..rowIndex    
        
    WindowSetTintColor( rowName.."BackgroundName", color.r, color.g, color.b)		

    LabelSetText( rowName.."Name", frame:GetDisplayName() )
    
    ButtonSetStayDownFlag( rowName.."Locked", true )			
    ButtonSetPressedFlag( rowName.."Locked", frame:IsLocked() )	
    
    ButtonSetStayDownFlag( rowName.."Hidden", true )			
    ButtonSetPressedFlag( rowName.."Hidden", frame:IsHidden() )	
    WindowSetShowing( rowName.."Hidden", frame:AllowHiding() )           
            
            
    -- Set the Text color based on selection
    color = { r=255, g=255, b=255 }
    if( LayoutEditor.selectedWindowBrowserRowName == frame:GetSourceWindowName() ) then
        color = { r=255, g=204, b=102 }
    end
    LabelSetTextColor( rowName.."Name", color.r, color.g, color.b)
end



function LayoutEditor.OnToggleLocked()

    local rowIndex = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
    local dataIndex = ListBoxGetDataIndex( "LayoutEditorWindowControlScreenBrowserWindowsList", rowIndex )
    
    local frame = LayoutEditor.windowBrowserDataList[dataIndex]      
    frame:SetLocked( not frame:IsLocked() )
    
    -- If unlocking the frame, auto-select it
    if( not frame:IsLocked() )
    then
        LayoutEditor.SetActiveFrame( frame )
    end
end

function LayoutEditor.OnToggleHidden()

    local rowIndex  = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
    local dataIndex = ListBoxGetDataIndex( "LayoutEditorWindowControlScreenBrowserWindowsList", rowIndex )
    
    local frame = LayoutEditor.windowBrowserDataList[dataIndex]    
    frame:SetHidden( not frame:IsHidden() )
    
    -- If showing the frame, auto-select it
    if( not frame:IsHidden() )
    then
        LayoutEditor.SetActiveFrame( frame )
    end
end

function LayoutEditor.OnClickWindowBrowserRow() 
    local rowIndex = WindowGetId( SystemData.ActiveWindow.name )
    
    local dataIndex = LayoutEditorWindowControlScreenBrowserWindowsList.PopulatorIndices[rowIndex]
    local windowData = LayoutEditor.windowsList[ dataIndex ]
    

end
