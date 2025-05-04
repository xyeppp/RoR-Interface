    
----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

UiModWindow = {}

UiModWindow.Settings = 
{
    showAdvancedWarning = true,
    showMainUiInModsList = false,
    
}

UiModWindow.isInErrorMode = false

UiModWindow.modsListData = {}
UiModWindow.modsSets = {}
UiModWindow.modsListDataDisplayOrder = {}

UiModWindow.selectedModName = nil

UiModWindow.selectedCategory = 2

UiModWindow.modOptionsChanged = false

---------------------------------------------------------------------
-- Mod Categories

UiModWindow.ALL_CATEGORIES = -1

local function NewCategoryData( in_id )
    return { id=in_id, 
             name=GetStringFromTable("UiModuleCategories", in_id ) 
           }
end

UiModWindow.ModCategoriesData =
{
    -- Manually create a category for the 'All' Option
    [ 1] = { id=UiModWindow.ALL_CATEGORIES, name=GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.MOD_DETAILS_CATEGORY_COMBO_ALL ) },
    
    -- Then Add Each Category
    [ 2] = NewCategoryData( SystemData.UiModuleCategory.ACTION_BARS ),
    [ 3] = NewCategoryData( SystemData.UiModuleCategory.ITEMS_INVENTORY ),
    [ 4] = NewCategoryData( SystemData.UiModuleCategory.BUFFS_DEBUFFS ),
    [ 5] = NewCategoryData( SystemData.UiModuleCategory.COMBAT ),
    [ 6] = NewCategoryData( SystemData.UiModuleCategory.RVR ),
    [ 7] = NewCategoryData( SystemData.UiModuleCategory.GROUPING ),
    [ 8] = NewCategoryData( SystemData.UiModuleCategory.CAREER_SPECIFIC ),
    [ 9] = NewCategoryData( SystemData.UiModuleCategory.MAIL ),
    [10] = NewCategoryData( SystemData.UiModuleCategory.AUCTION ),
    [11] = NewCategoryData( SystemData.UiModuleCategory.CHAT ),
    [12] = NewCategoryData( SystemData.UiModuleCategory.COMBAT ),
    [13] = NewCategoryData( SystemData.UiModuleCategory.QUESTS ),
    [14] = NewCategoryData( SystemData.UiModuleCategory.MAP ),
    [15] = NewCategoryData( SystemData.UiModuleCategory.CRAFTING ),
    [16] = NewCategoryData( SystemData.UiModuleCategory.SYSTEM ),
    [17] = NewCategoryData( SystemData.UiModuleCategory.DEVELOPMENT ),
    [18] = NewCategoryData( SystemData.UiModuleCategory.OTHER ),
}
 
---------------------------------------------------------------------    
-- Mod Types Data
    
local function NewModTypeData( in_nameStringId, in_tooltipStringId )
    return { name=GetStringFromTable( "CustomizeUiStrings",  in_nameStringId ), -- Cache the Name since it is used in the list box.
             tooltipStringId=in_tooltipStringId 
           }
end 
    
UiModWindow.ModTypesData =
{ 
    [SystemData.UiModuleType.PREGAME]                 = NewModTypeData( StringTables.CustomizeUi.MOD_DETAILS_TYPE_PREGAME_NAME,                 StringTables.CustomizeUi.MOD_DETAILS_TYPE_TEXT_PREGAME_TOOLTIP ),
    [SystemData.UiModuleType.DEFAULT_INGAME]          = NewModTypeData( StringTables.CustomizeUi.MOD_DETAILS_TYPE_DEFAULT_INGAME_NAME,          StringTables.CustomizeUi.MOD_DETAILS_TYPE_DEFAULT_INGAME_TOOLTIP ),
    [SystemData.UiModuleType.CUSTOM_INGAME]           = NewModTypeData( StringTables.CustomizeUi.MOD_DETAILS_TYPE_CUSTOM_INGAME_NAME,           StringTables.CustomizeUi.MOD_DETAILS_TYPE_CUSTOM_INGAME_TOOLTIP ),
    [SystemData.UiModuleType.MYTHIC_APPROVED_ADDON]   = NewModTypeData( StringTables.CustomizeUi.MOD_DETAILS_TYPE_MYTHIC_APPROVED_NAME,         StringTables.CustomizeUi.MOD_DETAILS_TYPE_MYTHIC_APPROVED_TOOLTIP ),
    [SystemData.UiModuleType.USER_ADDON]              = NewModTypeData( StringTables.CustomizeUi.MOD_DETAILS_TYPE_USER_ADDON_NAME,              StringTables.CustomizeUi.MOD_DETAILS_TYPE_USER_ADDON_TOOLTIP ),
}

---------------------------------------------------------------------
-- Mod Load Status Data

local function NewModLoadStatusData( in_nameStringId, in_tooltipStringId, in_color )
    return { name=GetStringFromTable( "CustomizeUiStrings",  in_nameStringId ), -- Cache the Name since it is used in the list box.
             tooltipStringId=in_tooltipStringId,
             color=in_color,
           }
end 

UiModWindow.ModLoadStatusData =
{ 
    [SystemData.UiModuleLoadStatus.NOT_LOADED]                      = NewModLoadStatusData( StringTables.CustomizeUi.MOD_DETAILS_STATUS_NOT_LOADED_NAME,                  StringTables.CustomizeUi.MOD_DETAILS_STATUS_NOT_LOADED_TOOLTIP,                   DefaultColor.LIGHT_GRAY ),
    [SystemData.UiModuleLoadStatus.REPLACED]                        = NewModLoadStatusData( StringTables.CustomizeUi.MOD_DETAILS_STATUS_REPLACED_NAME,                    StringTables.CustomizeUi.MOD_DETAILS_STATUS_REPLACED_TOOLTIP,                     DefaultColor.TEAL ),
    [SystemData.UiModuleLoadStatus.LOADING_DEPENDENCIES]            = NewModLoadStatusData( StringTables.CustomizeUi.MOD_DETAILS_STATUS_LOADING_DEPENDENCIES_NAME,        StringTables.CustomizeUi.MOD_DETAILS_STATUS_LOADING_DEPENDENCIES_TOOLTIP,         DefaultColor.WHITE  ),
    [SystemData.UiModuleLoadStatus.FAILED_MISSING_DEPENDENCY]       = NewModLoadStatusData( StringTables.CustomizeUi.MOD_DETAILS_STATUS_FAILED_NAME,                      StringTables.CustomizeUi.MOD_DETAILS_STATUS_FAILED_TOOLTIP,                       DefaultColor.RED ),
    [SystemData.UiModuleLoadStatus.FAILED_DEPENDENCY_NOT_ENABLED]   = NewModLoadStatusData( StringTables.CustomizeUi.MOD_DETAILS_STATUS_FAILED_NAME,                      StringTables.CustomizeUi.MOD_DETAILS_STATUS_FAILED_TOOLTIP,                       DefaultColor.RED ),
    [SystemData.UiModuleLoadStatus.FAILED_DEPENDENCY_FAILED]        = NewModLoadStatusData( StringTables.CustomizeUi.MOD_DETAILS_STATUS_FAILED_NAME,                      StringTables.CustomizeUi.MOD_DETAILS_STATUS_FAILED_TOOLTIP,                       DefaultColor.RED ),
    [SystemData.UiModuleLoadStatus.FAILED_CIRCULAR_DEPENDENCY]      = NewModLoadStatusData( StringTables.CustomizeUi.MOD_DETAILS_STATUS_FAILED_NAME,                      StringTables.CustomizeUi.MOD_DETAILS_STATUS_FAILED_TOOLTIP,                       DefaultColor.RED ),
    [SystemData.UiModuleLoadStatus.SUCEEDED_NO_ERRORS]              = NewModLoadStatusData( StringTables.CustomizeUi.MOD_DETAILS_STATUS_SUCEEDED_NO_ERRORS_NAME,          StringTables.CustomizeUi.MOD_DETAILS_STATUS_SUCEEDED_NO_ERRORS_TOOLTIP,           DefaultColor.GREEN ),
    [SystemData.UiModuleLoadStatus.SUCEEDED_WITH_ERRORS]            = NewModLoadStatusData( StringTables.CustomizeUi.MOD_DETAILS_STATUS_SUCEEDED_WITH_ERRORS_NAME,        StringTables.CustomizeUi.MOD_DETAILS_STATUS_SUCEEDED_WITH_ERRORS_TOOLTIP,         DefaultColor.YELLOW ),
}




---------------------------------------------------------------------
-- Sorting Rules
UiModWindow.SORT_ORDER_UP	   = 1
UiModWindow.SORT_ORDER_DOWN	   = 2

UiModWindow.MOD_SORTBY_NAME    = 1
UiModWindow.MOD_SORTBY_TYPE    = 2
UiModWindow.MOD_SORTBY_STATUS = 3
UiModWindow.MOD_SORTBY_ENABLED = 4

function NewModSortData( param_label, param_title, param_desc )
    return { windowName=param_label, title=param_title, desc=param_desc }
end

UiModWindow.sortData = {}
UiModWindow.sortData[1] = NewModSortData( "UiModWindowSortButton1", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.UI_MODS_SORTBY_NAME ) )
UiModWindow.sortData[2] = NewModSortData( "UiModWindowSortButton2", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.UI_MODS_SORTBY_TYPE ) )
UiModWindow.sortData[3] = NewModSortData( "UiModWindowSortButton3", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.UI_MODS_SORTBY_STATUS ) )
UiModWindow.sortData[4] = NewModSortData( "UiModWindowSortButton4", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.UI_MODS_SORTBY_ENABLED ) )

UiModWindow.curSortType = UiModWindow.MOD_SORTBY_NAME
UiModWindow.curSortOrder = UiModWindow.SORT_ORDER_UP	


-- This function is used to compare mods for table.sort() on
-- the mod list display order.
local function CompareMods( index1, index2 )

    if( index2 == nil ) then
        return false
    end
    
    local sortType  = UiModWindow.curSortType
    local order     = UiModWindow.curSortOrder 
    
    --DEBUG(L"Sorting.. Type="..sortType..L" Order="..order )
    
    local mod1 = UiModWindow.modsListData[ index1 ]
    local mod2 = UiModWindow.modsListData[ index2 ]
    
    -- Sort By Name
    if( sortType == UiModWindow.MOD_SORTBY_NAME ) 
    then
        return StringUtils.SortByString( mod1.wideStrName, mod2.wideStrName, order ) 
    end

    -- Sort By Type
    if( sortType == UiModWindow.MOD_SORTBY_TYPE ) 
    then
        if( mod1.moduleType == mod2.moduleType  ) 
        then        
            return StringUtils.SortByString( mod1.wideStrName, mod2.wideStrName, UiModWindow.SORT_ORDER_UP )  
        else            
            if( order == UiModWindow.SORT_ORDER_UP ) 
            then	
                return ( mod1.moduleType < mod2.moduleType )
            else
                return ( mod1.moduleType > mod2.moduleType )
            end		
        end
    end
    
    -- Sort By Status
    if( sortType == UiModWindow.MOD_SORTBY_STATUS ) 
    then
        if( mod1.loadStatus == mod2.loadStatus  ) 
        then        
            return StringUtils.SortByString( mod1.wideStrName, mod2.wideStrName, UiModWindow.SORT_ORDER_UP )  
        else            
            if( order == UiModWindow.SORT_ORDER_UP ) 
            then	
                return ( mod1.loadStatus < mod2.loadStatus )
            else
                return ( mod1.loadStatus > mod2.loadStatus )
            end		
        end
    end
    
    -- Sort By Enabled
    if( sortType == UiModWindow.MOD_SORTBY_ENABLED ) 
    then
        if( mod1.isEnabled == mod2.isEnabled  ) 
        then        
            return StringUtils.SortByString( mod1.wideStrName, mod2.wideStrName, UiModWindow.SORT_ORDER_UP )  
        else            
            if( order == UiModWindow.SORT_ORDER_UP ) 
            then	
                return ( mod2.isEnabled )
            else
                return ( mod1.isEnabled )
            end		
        end
    end
end

local function SortModsList()

    local sortType  = UiModWindow.curSortType
    local order     = UiModWindow.curSortOrder 

    --DEBUG(L" Sorting Mods: type="..sortType..L" order="..order )
    table.sort( UiModWindow.modsListDataDisplayOrder, CompareMods )
end

local function UpdateModsList()       
    ListBoxSetDisplayOrder("UiModWindowModsList", UiModWindow.modsListDataDisplayOrder )
end


local function UpdateModData()

    UiModWindow.modCategories = {}
    UiModWindow.modsListData = ModulesGetData()
    
    -- Build a list of all the mod sets
    local setNames = {}
    for modIndex, modData in ipairs( UiModWindow.modsListData ) 
    do
        -- Add a reference to the data index
        modData.modIndex = modIndex
                
        local found = false

        -- Add a reference to each category
        for _, category in ipairs( modData.categories )
        do
            if( UiModWindow.modCategories[ category ] == nil )
            then
                UiModWindow.modCategories[ category ] = {}
            end   
            
            table.insert( UiModWindow.modCategories[ category ], modData )
        end
                
        --DEBUG(L"Mod ["..modIndex..L"] = "..modData.wideStrName )
    end      
    
end

local function GetModByName( name ) 

    if( UiModWindow.modsListData == nil ) then
        return nil
    end
    
    for index, data in ipairs( UiModWindow.modsListData ) do
        if( data.name == name ) then
            return data
        end    
    end
    
end


local function ShouldShowType( modData )
    return     (modData.moduleType == SystemData.UiModuleType.MYTHIC_APPROVED_ADDON) 
            or (modData.moduleType == SystemData.UiModuleType.USER_ADDON)
            or (UiModWindow.Settings.showMainUiInModsList == true )
            
end

local function ShouldShowCategory( modData )
    
    if( UiModWindow.selectedCategory == UiModWindow.ALL_CATEGORIES )
    then
        return true
    end
    
    for _, categoryId in ipairs( modData.categories )
    do
        if( UiModWindow.selectedCategory == categoryId )
        then
            return true
        end
    end
    
    return false
end
    

----------------------------------------------------------------
-- UiModWindow Functions
----------------------------------------------------------------

-- OnInitialize Handler()
function UiModWindow.Initialize()

    LabelSetText( "UiModWindowTitleBarText", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.UI_MODS_WINDOW_TITLE ) )   
   
    -- List Sort Buttons
    for _, sortData in ipairs( UiModWindow.sortData )
    do
        ButtonSetText( sortData.windowName, sortData.title )        
    end
    
    -- No Mods Text
    LabelSetText("UiModWindowNoModsText", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.TEXT_NO_MODS_FOUND ) ) 
    
    -- Managment Buttons
    ButtonSetText( "UiModWindowReEnableAllAutoDisabledButton", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.UI_MODS_REENABLE_ALL_BUTTON ) )     
    ButtonSetText( "UiModWindowEnableAllButton", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.UI_MODS_ENABLE_ALL_BUTTON ) ) 
    ButtonSetText( "UiModWindowDisableAllButton", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.UI_MODS_DISABLE_ALL_BUTTON ) )   
              
    -- Buttons
    ButtonSetText( "UiModWindowAdvancedButton", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_ADVANCED_SETTINGS_BUTTON ) )  
    ButtonSetText( "UiModWindowOkayButton", GetPregameString( StringTables.Pregame.LABEL_OKAY ) )   
    ButtonSetText( "UiModWindowCancelButton", GetPregameString( StringTables.Pregame.LABEL_CANCEL ) )   
    
    -- Details    
    UiModWindow.InitModDetails( "UiModWindowModDetails" )
      
    UiModWindow.UpdateInstructions()
    
    WindowRegisterEventHandler( "EA_Window_ManageUiProfiles", SystemData.Events.ALL_MODULES_INITIALIZED, "UiModWindow.RefreshData" )
    
end

function UiModWindow.OnShown()
    WindowUtils.OnShown()
    UiModWindow.RefreshData()
end
    
function UiModWindow.RefreshData()
    
    UpdateModData()
    
    UiModWindow.UpdateCategoryComboBox()
    
    UiModWindow.ShowModCategory( UiModWindow.ALL_CATEGORIES )    
    UiModWindow.UpdateModSortButtons()
end

function UiModWindow.OnHidden()
    WindowUtils.OnHidden()
    UiModWindow.modOptionsChanged = false
end

function UiModWindow.UpdateInstructions()

    -- If the AddOns directory is a relative path, this call will pre-pend the game's exe path
    local addOnsDir = FileUtils.GetFullPathWideString( SystemData.Directories.AddOnsInterface )
 
    local text = GetStringFormatFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.TEXT_ADD_ONS_BASIC_INSTRUCTIONS, { addOnsDir } )

    -- Instructions
    LabelSetText( "UiModWindowInstructions", text )    
 
end

function UiModWindow.UpdateCategoryComboBox()
    
    ComboBoxClearMenuItems( "UiModWindowCategoryComboBox" )
    
    for menuIndex, categoryData in ipairs( UiModWindow.ModCategoriesData )
    do
        local numMods = 0
        if( categoryData.id == UiModWindow.ALL_CATEGORIES )
        then
            -- Count all the mods we'll display
            for _, modData in ipairs( UiModWindow.modsListData )
            do
                if( ShouldShowType( modData ) )
                then
                    numMods = numMods + 1
                end
            end
            
        elseif( UiModWindow.modCategories[ categoryData.id ] )
        then
            numMods = #UiModWindow.modCategories[ categoryData.id ]
        end
        
        local menuItemText = GetStringFormatFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.UI_MODS_LISTITEM_CATEGORY_NAME_AND_COUNT,
                                                             {categoryData.name, L""..numMods } )
        
        ComboBoxAddMenuItem( "UiModWindowCategoryComboBox", menuItemText )
             
        
        -- If there are no mods in this category, change the 'normal' color of the menu item button to the disabled color.
        -- (We do this instead of disabling the button so the highlight will still appear when mousing over the category)      
        local buttonName = "UiModWindowCategoryComboBoxMenuButton"..menuIndex
        if( numMods == 0 )
        then
            ButtonSetTextColor(buttonName, Button.ButtonState.NORMAL, DefaultColor.MEDIUM_GRAY.r, DefaultColor.MEDIUM_GRAY.g, DefaultColor.MEDIUM_GRAY.b)         
        else
            ButtonSetTextColor(buttonName, Button.ButtonState.NORMAL, DefaultColor.WHITE.r, DefaultColor.WHITE.g, DefaultColor.WHITE.b)
        end
    end
    
    -- Select the current Category
    ComboBoxSetSelectedMenuItem( "UiModWindowCategoryComboBox", 1 )
    UiModWindow.ShowModCategory( UiModWindow.ALL_CATEGORIES )  
end

function UiModWindow.OnCategoryComboSelChanged( curSelIndex )

    local categoryData = UiModWindow.ModCategoriesData[ curSelIndex ]
    if( categoryData == nil )
    then
        return
    end
    
    UiModWindow.ShowModCategory( categoryData.id )  
end

function UiModWindow.ShowModCategory( categoryId )    
   
    
    UiModWindow.selectedCategory = categoryId   
     
    -- Update the List      
    UiModWindow.modsListDataDisplayOrder = {}
    for index, modData in ipairs( UiModWindow.modsListData ) 
    do                
         if( ShouldShowType( modData ) and ShouldShowCategory( modData )  )
         then           
            table.insert( UiModWindow.modsListDataDisplayOrder, index )
         end
    end
        
    SortModsList()    
    UpdateModsList() 
     
    -- Display the 'No Mods' Text if no mods have been found.
    WindowSetShowing( "UiModWindowNoModsText", UiModWindow.modsListDataDisplayOrder[1] == nil )
    
    UiModWindow.UpdateModSortButtons()
    UiModWindow.UpdateEnableDisableAllButtons()
    
    -- Update the Details
    UiModWindow.ShowModDetails( UiModWindow.modsListData[ UiModWindow.modsListDataDisplayOrder[1] ] )
end

function UiModWindow.OnClickModListSortButton()

    local type = WindowGetId( SystemData.ActiveWindow.name )
    
    -- If we are already using this sort type, toggle the order.
    if( type == UiModWindow.curSortType ) then
        if( UiModWindow.curSortOrder == UiModWindow.SORT_ORDER_UP ) then
            UiModWindow.curSortOrder = UiModWindow.SORT_ORDER_DOWN
        else
            UiModWindow.curSortOrder = UiModWindow.SORT_ORDER_UP
        end
        
    -- Otherwise change the type and use the up order.	
    else
        UiModWindow.curSortType = type
        UiModWindow.curSortOrder = UiModWindow.SORT_ORDER_UP
    end

    SortModsList()
    UpdateModsList()
    
    UiModWindow.UpdateModSortButtons()
end


function UiModWindow.OnMouseOverModListSortButton()

end

-- Displays the clicked sort button as pressed down and positions an arrow above it
function UiModWindow.UpdateModSortButtons()

    local type = UiModWindow.curSortType
    local order = UiModWindow.curSortOrder
    
    -- Update the Arrow
    WindowSetShowing( "UiModWindowSortUpArrow", (order == UiModWindow.SORT_ORDER_UP) )
    WindowSetShowing( "UiModWindowSortDownArrow", (order == UiModWindow.SORT_ORDER_DOWN) )
            
    local window = UiModWindow.sortData[type].windowName

    if( order == UiModWindow.SORT_ORDER_UP ) then		
        WindowClearAnchors( "UiModWindowSortUpArrow" )
        WindowAddAnchor("UiModWindowSortUpArrow", "right", window, "right", -8, 0 )
        
    else
        WindowClearAnchors( "UiModWindowSortDownArrow" )
        WindowAddAnchor("UiModWindowSortDownArrow", "right", window, "right", -8, 0 )
        
    end

end

function UiModWindow.MarkAsChanged()
    UiModWindow.modOptionsChanged = true
end

function UiModWindow.OnOkayButton()

    if( not UiModWindow.modOptionsChanged )
    then
    
        WindowSetShowing( "UiModWindow", false )
        return
    end    
    
    UiModWindow.CreateReloadDialogMods()
end

function UiModWindow.CreateReloadDialogMods()

    -- Otherwise pop up a dialog.
    DialogManager.MakeTwoButtonDialog(  GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.TEXT_UI_MOD_SETTINGS_CHANGED_DIALOG ), 
                                            GetString( StringTables.Default.LABEL_YES ), UiModWindow.SaveAndReloadMods, 
                                            GetString( StringTables.Default.LABEL_NO ),  nil )
    
end

function UiModWindow.SaveAndReloadMods()

    WindowSetShowing( "UiModWindow", false )
    
    for index, modData in ipairs( UiModWindow.modsListData ) do    
        ModuleSetEnabled( modData.name, modData.isEnabled  )
    end    

    BroadcastEvent( SystemData.Events.RELOAD_INTERFACE )
   
end

function UiModWindow.OnCancelButton()
    
    -- Close the window         
    WindowSetShowing( "UiModWindow", false )
end


function UiModWindow.UpdateModRows()

    if (UiModWindowModsList.PopulatorIndices ~= nil) 
    then				
        for rowIndex, dataIndex in ipairs (UiModWindowModsList.PopulatorIndices) 
        do
        
            local modData = UiModWindow.modsListData[ dataIndex ]
            UiModWindow.UpdateModRowByIndex( rowIndex, modData )				
        end
    end    

end

function UiModWindow.UpdateModRowByIndex( rowIndex, modData )

    --DUMP_TABLE( modData )
    
    local rowName = "UiModWindowModsListRow"..rowIndex         	  
	         	  
    -- Set the Background Color 
    local isSelected = modData.name and (UiModWindow.selectedModName == modData.name )
    DefaultColor.SetListRowTint( rowName.."Background", rowIndex, isSelected )
        
    -- Mod Type
    local typeText = UiModWindow.ModTypesData[ modData.moduleType ].name
    LabelSetText( rowName.."Type", typeText )
    
    -- Mod Status
    local loadStatusData = UiModWindow.ModLoadStatusData[ modData.loadStatus ]
    LabelSetText( rowName.."Status", loadStatusData.name )
    DefaultColor.SetLabelColor( rowName.."Status", loadStatusData.color )
       
    -- Enabled 
    ButtonSetCheckButtonFlag( rowName.."Enabled", true )			
    ButtonSetPressedFlag( rowName.."Enabled", modData.isEnabled )	
                   
end

function UiModWindow.OnMouseOverModType()

    local rowIndex  = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
    local dataIndex = ListBoxGetDataIndex( "UiModWindowModsList", rowIndex )    
    local modData   = UiModWindow.modsListData[ dataIndex ]
    
    local typeData  = UiModWindow.ModTypesData[ modData.moduleType ]     
    local tooltipText = GetStringFromTable( "CustomizeUiStrings", typeData.tooltipStringId )
    
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )    
    Tooltips.SetTooltipText( 1, 1, typeData.name )
    Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
    Tooltips.SetTooltipText( 2, 1, tooltipText )
    Tooltips.Finalize()
    
    Tooltips.AnchorTooltip(Tooltips.ANCHOR_TOP);
    
end

function UiModWindow.OnMouseOverStatus()
    
    local rowIndex  = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
    local dataIndex = ListBoxGetDataIndex( "UiModWindowModsList", rowIndex )    
    local modData   = UiModWindow.modsListData[ dataIndex ]
    
    local statusData  = UiModWindow.ModLoadStatusData[ modData.loadStatus ]     
    local tooltipText = GetStringFromTable( "CustomizeUiStrings", statusData.tooltipStringId )
    
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )    
    Tooltips.SetTooltipText( 1, 1, statusData.name )
    Tooltips.SetTooltipColorDef( 1, 1, statusData.color )
    Tooltips.SetTooltipText( 2, 1, tooltipText )
    Tooltips.Finalize()
    
    Tooltips.AnchorTooltip(Tooltips.ANCHOR_TOP);

    
end

function UiModWindow.OnToggleModEnabled()

    local rowIndex  = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
    local dataIndex = ListBoxGetDataIndex( "UiModWindowModsList", rowIndex )    
    local modData   = UiModWindow.modsListData[ dataIndex ]
    
    modData.isEnabled = ButtonGetPressedFlag( SystemData.ActiveWindow.name )
    
    UiModWindow.MarkAsChanged()    
    UiModWindow.UpdateEnableDisableAllButtons()
end


function UiModWindow.UpdateEnableDisableAllButtons()
    
    local numEnabled = 0
    local numDisabled = 0
    local numAutoDisabled = 0
    
    for _, dataIndex in ipairs( UiModWindow.modsListDataDisplayOrder ) 
    do    
        local modData = UiModWindow.modsListData[ dataIndex ]   
        if( modData.isEnabled )
        then
            numEnabled = numEnabled + 1
        else
            numDisabled = numDisabled + 1
           
            if( modData.isAutoDisabledOnGameVersionMismatch )
            then
                numAutoDisabled = numAutoDisabled + 1
            end
        end 
          	
    end    
    
    ButtonSetDisabledFlag( "UiModWindowEnableAllButton", numDisabled == 0 )
    ButtonSetDisabledFlag( "UiModWindowDisableAllButton", numEnabled == 0 )
    ButtonSetDisabledFlag( "UiModWindowReEnableAllAutoDisabledButton", numAutoDisabled == 0 )

end

function UiModWindow.OnReEnableAutoDisabled()

    if( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) )
    then
        return
    end

    for _, dataIndex in ipairs( UiModWindow.modsListDataDisplayOrder ) 
    do    
        local modData = UiModWindow.modsListData[ dataIndex ]
        if( modData.isEnabled ~= nil )
        then      
            if( modData.isAutoDisabledOnGameVersionMismatch )
            then          
                modData.isEnabled = true
            end
        end    	
    end   

    UiModWindow.MarkAsChanged()
    UiModWindow.UpdateEnableDisableAllButtons()
    
    UpdateModsList()
end


function UiModWindow.OnEnableAllButton()

    if( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) )
    then
        return
    end

    for _, dataIndex in ipairs( UiModWindow.modsListDataDisplayOrder ) 
    do    
        local modData = UiModWindow.modsListData[ dataIndex ]
        if( modData.isEnabled ~= nil )
        then        
            modData.isEnabled = true
        end    	
    end   

    UiModWindow.MarkAsChanged()
    UiModWindow.UpdateEnableDisableAllButtons()
    
    UpdateModsList()
end

function UiModWindow.OnDisableAllButton()

    if( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) )
    then
        return
    end

    for _, dataIndex in ipairs( UiModWindow.modsListDataDisplayOrder ) 
    do    
        local modData = UiModWindow.modsListData[ dataIndex ]
        if( modData.isEnabled ~= nil )
        then        
            modData.isEnabled = false
        end    	
    end 
    
    UiModWindow.MarkAsChanged()  
    UiModWindow.UpdateEnableDisableAllButtons()
    
    UpdateModsList()
end

function UiModWindow.OnClickModRow()    
    local rowIndex = WindowGetId( SystemData.ActiveWindow.name )
    
    local dataIndex = UiModWindowModsList.PopulatorIndices[rowIndex]
    local modData = UiModWindow.modsListData[ dataIndex ]    
    
    -- Update the details data
    UiModWindow.ShowModDetails( modData )   
end

function UiModWindow.ShowModDetails( modData )

    -- Hide the window no mods are selected   
    WindowSetShowing( "UiModWindowModDetails", modData ~= nil )   
    if( modData )
    then   
        UiModWindow.selectedModName = modData.name
                
        local windowName = "UiModWindowModDetails"
        UiModWindow.UpdateModDetailsData( windowName, modData )
    else
        UiModWindow.selectedModName = nil
    end  

    UiModWindow.UpdateModRows()      
end

function UiModWindow.InitModDetails( windowName )

    -- Heading Background
    DefaultColor.SetWindowTint( windowName.."ScrollChildNameBackground",  DefaultColor.GetRowColor(1) )	
    
    -- Labels
    LabelSetText( windowName.."ScrollChildAuthorLabel", GetPregameString( StringTables.Pregame.TEXT_MOD_AUTHOR ) )
    LabelSetText( windowName.."ScrollChildVersionLabel", GetPregameString( StringTables.Pregame.TEXT_MOD_VERSION ) )
    LabelSetText( windowName.."ScrollChildGameVersionLabel", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.TEXT_MOD_GAME_VERSION ) )
    LabelSetText( windowName.."ScrollChildDescriptionLabel",GetPregameString( StringTables.Pregame.TEXT_MOD_DESCRIPTION ) )    
    LabelSetText( windowName.."ScrollChildCategoriesLabel", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.MOD_DETAILS_CATEGORIES_LABEL ) )
    LabelSetText( windowName.."ScrollChildCareersLabel", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.MOD_DETAILS_CAREERS_LABEL ) )
    
    LabelSetText( windowName.."ScrollChildCareersText", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.MOD_DETAILS_NONE_SPECIFIED_TEXT ) )

end

function UiModWindow.UpdateModDetailsData( windowName, modData )
        
    if( modData == nil ) 
    then     
        return
    end
    
    -- Set Each of the fields
    
    -- Name
    LabelSetText( windowName.."ScrollChildName", modData.wideStrName )    


    -- Status
    local statusText = UiModWindow.GetStatusMessageForMod( modData )
    if( statusText )
    then
        -- Set the Text
        LabelSetText( windowName.."ScrollChildStatusText", statusText )
    
        -- Colre the Text
        local loadStatusData = UiModWindow.ModLoadStatusData[ modData.loadStatus ]
        DefaultColor.SetLabelColor( windowName.."ScrollChildStatusText", loadStatusData.color )               
        
        -- Size & Show the Box
        local STATUS_SPACING = 10
        local _, textHeight = WindowGetDimensions( windowName.."ScrollChildStatusText" )        
        WindowSetDimensions( windowName.."ScrollChildStatus", 0, textHeight + STATUS_SPACING*2)
        WindowSetShowing( windowName.."ScrollChildStatus", true)
    else
        -- Hide the 'Staus' box if we don't have any text to display
        WindowSetDimensions( windowName.."ScrollChildStatus", 0, 0)
        WindowSetShowing( windowName.."ScrollChildStatus", false)
    end



    -- Author (This field is optional)    
    local author = L""
    if( modData.author )
    then
        author = StringToWString( modData.author.name )
    end
    LabelSetText( windowName.."ScrollChildAuthorText", author  )
    

    -- Mod Version
    local version = StringToWString( modData.version )    
    LabelSetText( windowName.."ScrollChildVersionText", version  ) 
    

    -- Game Version (This field is optional)
    local gameVersion = L""
        
    if( modData.versionsettings.gameVersion )
    then     
        gameVersion = StringToWString( modData.versionsettings.gameVersion )
    end
    
    if( gameVersion == L"" )
    then
        gameVersion = GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.VERSION_MISMATCH_GAME_VERSION_NOT_SPECIFIED )
    end       
    LabelSetText( windowName.."ScrollChildGameVersionText", gameVersion  )         


    -- Categories   
    local categoriesText = L""

    -- Add a reference to each category
    for _, categoryId in ipairs( modData.categories )
    do
        local categoryName = GetStringFromTable("UiModuleCategories", categoryId)
        if( categoriesText == L"" )
        then
            categoriesText = categoryName
        else
            categoriesText = StringUtils.AppendItemToList( categoriesText, categoryName )
        end
    end
                
    if( categoriesText == L"" )
    then
        categoriesText = GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.MOD_DETAILS_NONE_SPECIFIED_TEXT )
    end     
    
    LabelSetText( windowName.."ScrollChildCategoriesText", categoriesText  )            
    
    -- Recomended Careers
    local careers = {}
    for index, careerLineId in ipairs( modData.careers)
    do                
        table.insert( careers, careerLineId )           
    end
    
    local numCareers =  #careers
    
    local rows = 1
    local cols = #careers
        
    local MAX_COLS = 12
    while( cols > MAX_COLS )
    do    
        rows = rows + 1
        cols = cols - math.min( cols-MAX_COLS, MAX_COLS )
    end
        
	ActionButtonGroupSetNumButtons( windowName.."ScrollChildCareers", rows, cols )	
	
    local totalButtons = rows * cols
	for index = 1, totalButtons
	do
	    local careerLineId  = careers[index] 
	    if( careerLineId )
	    then
	
	        local iconNum = Icons.GetCareerIconIDFromCareerLine(careerLineId)
	        ActionButtonGroupSetIcon( windowName.."ScrollChildCareers", index, iconNum )
	        ActionButtonGroupSetId( windowName.."ScrollChildCareers", index, careerLineId )
	    end
	    
	    ActionButtonGroupSetShowing( windowName.."ScrollChildCareers", index, careerLineId ~= nil )
	end
	
	WindowSetShowing( windowName.."ScrollChildCareersText", numCareers == 0 )
	
	
	-- Description	
    local desc = StringToWString( modData.description.text )
    LabelSetText( windowName.."ScrollChildDescriptionText",  desc  )    
       
       
    -- Update the Scroll Rect
    ScrollWindowSetOffset( windowName, 0 )
    ScrollWindowUpdateScrollRect( windowName )
end


function UiModWindow.GetStatusMessageForMod( modData )
    
    if( modData == nil )
    then
        return nil
    end
    
    ---------------------------------------------
    -- NOT_LOADED   
       
    -- No message needed when not loaded
    if( modData.loadStatus == SystemData.UiModuleLoadStatus.NOT_LOADED )
    then
        return nil
    end
    
    ---------------------------------------------
    -- SUCEEDED_NO_ERRORS
    
    -- No message needed when loaded sucessfully w/o errors
    if( modData.loadStatus == SystemData.UiModuleLoadStatus.SUCEEDED_NO_ERRORS )
    then
        return nil
    end
    
    ---------------------------------------------
    -- SUCEEDED_WITH_ERRORS
    
    --  Just return an 'errors occured' message if the load suceeded.
    if( modData.loadStatus == SystemData.UiModuleLoadStatus.SUCEEDED_WITH_ERRORS )
    then
        return GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.MOD_DETAILS_STATUS_SUCEEDED_WITH_ERRORS_TEXT )
    end
    
    ---------------------------------------------
    -- REPLACED
    
    -- If the mod has been replaced, return a string containing the name of the mod that has replaced this
    if( modData.loadStatus == SystemData.UiModuleLoadStatus.REPLACED )
    then       
        return GetStringFormatFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.MOD_DETAILS_STATUS_REPLACED_TEXT, 
                                                              { StringToWString( modData.replacedByModuleName ) } )
    end
             
    ---------------------------------------------
    -- FAILED_CIRCULAR_DEPENDENCY
           
    -- If the mod failed due to a circular dependency, just return the message.
    if( modData.loadStatus == SystemData.UiModuleLoadStatus.FAILED_CIRCULAR_DEPENDENCY )
    then
        return GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.MOD_DETAILS_STATUS_FAILED_CIRCULAR_DEPENDENCY )    
    end
       
       
         
    -- Util Function shared by all the Dependency Errors to build an approriate string.
    local function GetDependencyErrorString( modData, errorFunction, stringId )
    
        local numDependencies = 0
        local dependenciesText = L""
    
        -- Build a list of dependencies that pass the error function
        for _, dependency in ipairs( modData.dependencies )
        do            
            local depModData = GetModByName( dependency.name )
            if( errorFunction( dependency, depModData ) )
            then                
                if( numDependencies == 0 )
                then
                    dependenciesText = StringToWString(dependency.name) 
                else
                    dependenciesText = StringUtils.AppendItemToList( dependenciesText, StringToWString(dependency.name)  )
                end
                        
                numDependencies = numDependencies + 1
            end        
        end   
        
        return GetStringFormatFromTable( "CustomizeUiStrings", stringId, 
                                                              { L""..numDependencies,
                                                              dependenciesText } )        
    
    end
    
    ---------------------------------------------
    -- FAILED_MISSING_DEPENDENCY
    
    -- If the mod is missing a dependency missing, list it.
    if( modData.loadStatus == SystemData.UiModuleLoadStatus.FAILED_MISSING_DEPENDENCY )
    then
    
        local function HasError( dependencyDef, dependencyModData )
            return (dependencyDef.optional == false) and (dependencyModData == nil) 
        end
    
        return  GetDependencyErrorString( modData, HasError, StringTables.CustomizeUi.MOD_DETAILS_STATUS_FAILED_MISSING_DEPENDENCY_TEXT )    
        
    end
    
    ---------------------------------------------
    -- FAILED_DEPENDENCY_NOT_ENABLED
    
    -- If the mod has a dependency that is not enabled, list it.
    if( modData.loadStatus == SystemData.UiModuleLoadStatus.FAILED_DEPENDENCY_NOT_ENABLED )
    then
        
        local function HasError( dependencyDef, dependencyModData )
        
            if( dependencyModData == nil )
            then
                return false
            end
            
            return (dependencyModData.isEnabled == false)
        end
    
        return  GetDependencyErrorString( modData, HasError, StringTables.CustomizeUi.MOD_DETAILS_STATUS_FAILED_MISSING_DEPENDENCY_TEXT )           
  
        
    end    
        
    ---------------------------------------------
    -- FAILED_DEPENDENCY_FAILED
    
    -- If the mod has a dependency that failed to load, list it.
    if( modData.loadStatus == SystemData.UiModuleLoadStatus.FAILED_DEPENDENCY_FAILED )
    then
            
        local function HasError( dependencyDef, dependencyModData )
        
            if( dependencyModData == nil )
            then
                return false
            end
            
            return    (dependencyModData.loadStatus == SystemData.UiModuleLoadStatus.FAILED_MISSING_DEPENDENCY)
                   or (dependencyModData.loadStatus == SystemData.UiModuleLoadStatus.FAILED_DEPENDENCY_NOT_ENABLED)
                   or (dependencyModData.loadStatus == SystemData.UiModuleLoadStatus.FAILED_DEPENDENCY_FAILED)
        end
    
        return  GetDependencyErrorString( modData, HasError, StringTables.CustomizeUi.MOD_DETAILS_STATUS_FAILED_DEPENDENCY_FAILED_TEXT )           
        
    end
    
   
   -- Anything else, not handled.
   return nil 

end