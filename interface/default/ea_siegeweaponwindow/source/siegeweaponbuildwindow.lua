----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

SiegeWeaponBuildWindow = {}


SiegeWeaponBuildWindow.MAX_WEAPON_DEFS = 5
SiegeWeaponBuildWindow.MAX_REQUIRED_ITEMS = 3


SiegeWeaponBuildWindow.weaponsData = nil
SiegeWeaponBuildWindow.weaponListDisplayOrder = {}
SiegeWeaponBuildWindow.numVisibleRows = 3

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

----------------------------------------------------------------
-- SiegeWeaponBuildWindow Functions
----------------------------------------------------------------

function SiegeWeaponBuildWindow.Initialize()       

    -- Setup component text
    LabelSetText( "SiegeWeaponBuildWindowTitleBarText", GetStringFromTable( "SiegeStrings",  StringTables.Siege.LABEL_SIEGE_PAD_WINDOW_TITLE ) )
    LabelSetText( "SiegeWeaponBuildWindowInstructions", GetStringFromTable( "SiegeStrings",  StringTables.Siege.TEXT_BUILD_INSTRUCTIONS ) )    
    ButtonSetText( "SiegeWeaponBuildWindowCancelButton", GetStringFromTable( "Default",  StringTables.Default.LABEL_CANCEL ) )
    ButtonSetText( "SiegeWeaponBuildWindowBuildButton", GetStringFromTable( "SiegeStrings",  StringTables.Siege.LABEL_ACTION_BUILD ) )    
    
    WindowRegisterEventHandler( "SiegeWeaponBuildWindow", SystemData.Events.INTERACT_SHOW_SIEGE_PAD_BUILD_LIST, "SiegeWeaponBuildWindow.UpdateData" )
    
    
    WindowRegisterEventHandler ("SiegeWeaponBuildWindow", SystemData.Events.PLAYER_INVENTORY_SLOT_UPDATED, "SiegeWeaponBuildWindow.OnInventoryUpdated")
    WindowRegisterEventHandler ("SiegeWeaponBuildWindow", SystemData.Events.PLAYER_QUEST_ITEM_SLOT_UPDATED, "SiegeWeaponBuildWindow.OnInventoryUpdated")
    
    
    SiegeWeaponBuildWindow.UpdateData()
end

function SiegeWeaponBuildWindow.Shutdown()

end

function SiegeWeaponBuildWindow.ShowBuildScreen()
    SiegeWeaponBuildWindow.UpdateData()
end

--------------------------------------------------------------------
-- Siege Weapon Definitions Callbacks
--------------------------------------------------------------------

function SiegeWeaponBuildWindow.UpdateData()

    --DEBUG(L"SiegeWeaponBuildWindow.UpdateData()")
    
    SiegeWeaponBuildWindow.weaponsData = GetSiegePadBuildData()    
   
    local showWindow = SiegeWeaponBuildWindow.weaponsData[1] ~= nil
    WindowSetShowing( "SiegeWeaponBuildWindow", showWindow )   
    if( showWindow == false ) then
        return
    end    
   
    SiegeWeaponBuildWindow.weaponListDisplayOrder = {}
       
    -- Sort Alphabetically
    table.sort(SiegeWeaponBuildWindow.weaponsData, DataUtils.AlphabetizeByNames)      
    
    -- Get the Strings for the SiegeWeaponTypes
    for index, data in ipairs( SiegeWeaponBuildWindow.weaponsData ) do        
        table.insert(SiegeWeaponBuildWindow.weaponListDisplayOrder, index )
    end    
    
    -- Update the List
    ListBoxSetDisplayOrder("SiegeWeaponBuildWindowWeaponDefsList", SiegeWeaponBuildWindow.weaponListDisplayOrder)
    SiegeWeaponBuildWindow.UpdateListButtonStates()
    
    -- Select the first item
    SiegeWeaponBuildWindow.SelectWeapon( 1 )
    
    
end

function SiegeWeaponBuildWindow.PopulateWeaponDefs()
    
    -- DEBUG(L"SiegeWeaponBuildWindow.Populate()")
    
    if (nil == SiegeWeaponBuildWindow.weaponsData ) then
        -- DEBUG(L"  no advance data found!")
    end
    
    -- Post-process any conditional formatting
    for row, data in ipairs( SiegeWeaponBuildWindowWeaponDefsList.PopulatorIndices ) do
        local weaponData = SiegeWeaponBuildWindow.weaponsData[data]
        
        local rowName   = "SiegeWeaponBuildWindowWeaponDefsListRow"..row

        -- Set the 'Requires' Label
        LabelSetText( rowName.."Requires", GetStringFromTable( "SiegeStrings",  StringTables.Siege.LABEL_REQUIRES ) )
        
        -- Only show the 'Requires' label when the weapon actually has requirements.
        WindowSetShowing( rowName.."Requires", weaponData.requiredItems[1] ~= nil )
        
        local hasRequiredItems = true
        
        -- Set up the Icons for the Required Items.
        for index = 1, SiegeWeaponBuildWindow.MAX_REQUIRED_ITEMS do            
            local show = weaponData.requiredItems[index] ~= nil
           
            WindowSetShowing( rowName.."Item"..index, show )   
            WindowSetId(  rowName.."Item"..index, index ) -- FORCE the id back to the value we want, the ListBox is overwriting it on creation.
            
            if( show ) then
                local iconWindow = rowName.."Item"..index.."Icon"
            
                local texture, x, y = GetIconData( weaponData.requiredItems[index].iconNum )
                DynamicImageSetTexture( iconWindow, texture, x, y )
                
                -- TODO: Color the Icons based on if the player has the item
                local hasItem = (DataUtils.FindItem( weaponData.requiredItems[index].uniqueID ) ~= nil)
                if( hasItem ) then
                    WindowSetTintColor( iconWindow, 255, 255, 255 )
                else
                    WindowSetTintColor( iconWindow, 255, 0, 0 )
                end
                
                hasRequiredItems = hasRequiredItems and hasItem
            end     
        end
        
        -- Set the HP
        LabelSetText( rowName.."HitPoints", GetStringFormatFromTable( "SiegeStrings",  StringTables.Siege.LABEL_HIT_POINTS_X, { L""..weaponData.hitPoints} ) )
        
        -- Set the Level
        LabelSetText( rowName.."Level", GetStringFormatFromTable( "SiegeStrings",  StringTables.Siege.LABEL_LEVEL_X, { L""..weaponData.level} ) )
                
    end
    
    SiegeWeaponBuildWindow.SetListRowTints()
end

function SiegeWeaponBuildWindow.OnInventoryUpdated()
    
    -- If the Siege Weapon Build screen is showing when the player's inventory
    -- Is Updated re-populate the list data to update the required items.  
    if( SiegeWeaponBuildWindow.weaponsData ) then
        local hasData = SiegeWeaponBuildWindow.weaponsData[1] ~= nil 
        if( hasData and WindowGetShowing("SiegeWeaponBuildWindow" ) )then
            SiegeWeaponBuildWindow.PopulateWeaponDefs()  
            SiegeWeaponBuildWindow.UpdateListButtonStates()  
        end
    end
end

function SiegeWeaponBuildWindow.CanPlayerBuildWeapon( weaponData )
    
    if( weaponData == nil ) then
        return false
    end
    
    local canBuild = true
    
    -- Check each of the required items.
    for index, itemData in ipairs( weaponData.requiredItems ) do    
        local hasItem = (DataUtils.FindItem( itemData.uniqueID ) ~= nil)
        canBuild = canBuild and hasItem
    end

    return canBuild
end

function SiegeWeaponBuildWindow.SetListRowTints()
    for row = 1, SiegeWeaponBuildWindow.numVisibleRows do
    
        -- Show the background for every other button   
        local color = GameDefs.RowColorInvalid
        
        local weaponData = nil
        
        if ( SiegeWeaponBuildWindow.weaponsData ~= nil ) then
            weaponData = SiegeWeaponBuildWindow.weaponsData[row]
        end

        local row_mod = math.mod(row, 2)
        local color = DataUtils.GetAlternatingRowColor( row_mod )
        local rowName   = "SiegeWeaponBuildWindowWeaponDefsListRow"..row
        
        if (weaponData ~= nil) then
            WindowSetTintColor(rowName.."RowBackground", color.r, color.g, color.b )
            WindowSetAlpha(rowName.."RowBackground", color.a)
        end
    end
end

--------------------------------------------------------------------
-- Mouse Over Functions
--------------------------------------------------------------------


function SiegeWeaponBuildWindow.OnMouseOverRequiredItem()

    local itemIndex = WindowGetId( SystemData.ActiveWindow.name )
    
    local selectedRow = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name) )
    local dataIndex =  ListBoxGetDataIndex("SiegeWeaponBuildWindowWeaponDefsList", selectedRow)
    
    local weaponData = SiegeWeaponBuildWindow.weaponsData[dataIndex]    
    
    if( weaponData.requiredItems[itemIndex] ) then
        Tooltips.CreateItemTooltip( weaponData.requiredItems[itemIndex], SystemData.ActiveWindow.name,  false )    
    else
        local text = GetStringFromTable( "SiegeStrings",  StringTables.Siege.TEXT_NO_ITEM_REQUIRED )
        Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, text )
    end
    
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT )
end

function SiegeWeaponBuildWindow.OnClickRequiredItem()
    local selectedRow = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name) )
    SiegeWeaponBuildWindow.OnClickRow( selectedRow )
end

function SiegeWeaponBuildWindow.OnMouseOverFireAbility()
    
    local selectedRow = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name) )
    local dataIndex =  ListBoxGetDataIndex("SiegeWeaponBuildWindowWeaponDefsList", selectedRow)
    
    local weaponData = SiegeWeaponBuildWindow.weaponsData[dataIndex]
    
    if( weaponData.fireAbility.id ~= 0 ) then
        Tooltips.CreateAbilityTooltip( weaponData.fireAbility, SystemData.ActiveWindow.name )    
    else
        local text = GetStringFromTable( "SiegeStrings",  StringTables.Siege.TEXT_FIRE_ABILITY_NOT_SET )
        Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, text )
    end
    
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT )
end

function SiegeWeaponBuildWindow.OnClickFireAbility()
    local selectedRow = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name) )
    SiegeWeaponBuildWindow.OnClickRow( selectedRow )
end

--------------------------------------------------------------------
-- Selection Functions
--------------------------------------------------------------------

function SiegeWeaponBuildWindow.UpdateListButtonStates()
    -- DEBUG(L"SiegeWeaponBuildWindow.UpdateListButtonStates()")
    
    if (SiegeWeaponBuildWindowWeaponDefsList.PopulatorIndices ~= nil)
    then
        for row, data in ipairs(SiegeWeaponBuildWindowWeaponDefsList.PopulatorIndices)
        do
            local rowWindow = "SiegeWeaponBuildWindowWeaponDefsListRow"..row
            -- Highlight the selected row, unhighlight the rest
            -- DEBUG(L"  processing row "..row..L" = data entry #"..data)
            ButtonSetPressedFlag(rowWindow, (data == SiegeWeaponBuildWindow.selectedWeapon))
            ButtonSetStayDownFlag(rowWindow, (data == SiegeWeaponBuildWindow.selectedWeapon))
            
        end
    end

    -- If the selected advance is not available or not applicable, don't enable the purchase button
    local selectedWeaponData = SiegeWeaponBuildWindow.weaponsData[SiegeWeaponBuildWindow.selectedWeapon]
    local enableBuildButton = (SiegeWeaponBuildWindow.selectedWeapon ~= 0) and SiegeWeaponBuildWindow.CanPlayerBuildWeapon( selectedWeaponData )
    ButtonSetDisabledFlag("SiegeWeaponBuildWindowBuildButton", not enableBuildButton)   
    
end


function SiegeWeaponBuildWindow.OnSelectWeapon()
    -- Record the list item that was selected / deselect other buttons
    local selectedRow = WindowGetId(SystemData.ActiveWindow.name)    
    SiegeWeaponBuildWindow.OnClickRow( selectedRow )
end

function SiegeWeaponBuildWindow.OnClickRow( rowId )
    -- Record the list item that was selected / deselect other buttons
    SiegeWeaponBuildWindow.SelectWeapon( ListBoxGetDataIndex("SiegeWeaponBuildWindowWeaponDefsList", rowId) )
end


function SiegeWeaponBuildWindow.SelectWeapon( weaponIndex )

    SiegeWeaponBuildWindow.selectedWeapon = weaponIndex

    --DEBUG(L"SiegeWeaponBuildWindow.SelectWeapon() selecting entry "..SiegeWeaponBuildWindow.selectedWeapon)
    
    SiegeWeaponBuildWindow.UpdateListButtonStates()
end

--------------------------------------------------------------------
-- Button Callbacks
--------------------------------------------------------------------


function SiegeWeaponBuildWindow.BuildWeapon()
    
    if( ButtonGetDisabledFlag(  SystemData.ActiveWindow.name ) == true ) then
        return
    end
    
    local weaponId = SiegeWeaponBuildWindow.weaponsData[SiegeWeaponBuildWindow.selectedWeapon].id
    local weaponName = SiegeWeaponBuildWindow.weaponsData[SiegeWeaponBuildWindow.selectedWeapon].name
    
    --DEBUG( L"Building SiegeWeapon: "..weaponId..L" ("..weaponName..L")" )
    BuildSiegeWeapon( weaponId )
    SiegeWeaponBuildWindow.Hide()
end

function SiegeWeaponBuildWindow.Clear()
end

function SiegeWeaponBuildWindow.Show()
    WindowSetShowing( "SiegeWeaponBuildWindow", true )
end

function SiegeWeaponBuildWindow.Hide()
    WindowSetShowing( "SiegeWeaponBuildWindow", false )
end

function SiegeWeaponBuildWindow.ToggleShowing()
    if ( SiegeWeaponBuildWindow.IsShowing() == true ) then
        SiegeWeaponBuildWindow.Hide()
    else
        SiegeWeaponBuildWindow.Show()
    end
end

function SiegeWeaponBuildWindow.IsShowing()
    return WindowGetShowing( "SiegeWeaponBuildWindow" )
end


function SiegeWeaponBuildWindow.OnShown()
    WindowUtils.OnShown()
    SiegeWeaponBuildWindow.Clear()
end

function SiegeWeaponBuildWindow.OnHidden()
    WindowUtils.OnHidden()
    SiegeWeaponBuildWindow.Clear()
end