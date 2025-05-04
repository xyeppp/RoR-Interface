
----------------------------------
--- List View 

-- TODO: rename to listDisplayData once it's working
--		Make sure to change XML at same time
EA_Window_Backpack.displayData = {}

EA_Window_Backpack.MAX_VISIBLE_ROWS = 6


---------------------
-- Filtering Data  --

EA_Window_Backpack.ARMOR_FILTER                  = 1;
EA_Window_Backpack.WEAPON_FILTER                 = 2;
EA_Window_Backpack.CRAFTING_FILTER               = 3;
EA_Window_Backpack.MISC_FILTER                   = 4;
EA_Window_Backpack.NUM_STORE_CATEGORY_FILTERS    = 4;

-- These are to help with looking up a name for a filter type...
EA_Window_Backpack.filterNames = {};
EA_Window_Backpack.filterNames[EA_Window_Backpack.ARMOR_FILTER]       = GetString (StringTables.Default.LABEL_ARMOR_ITEMS);
EA_Window_Backpack.filterNames[EA_Window_Backpack.WEAPON_FILTER]      = GetString (StringTables.Default.LABEL_WEAPON_ITEMS);
EA_Window_Backpack.filterNames[EA_Window_Backpack.CRAFTING_FILTER]    = GetString (StringTables.Default.LABEL_CRAFTING_ITEMS);
EA_Window_Backpack.filterNames[EA_Window_Backpack.MISC_FILTER]        = GetString (StringTables.Default.LABEL_MISC_ITEMS);
    

-----------------------
-- Sorting Data  --


EA_Window_Backpack.sortColumnNum = 0				-- column number to sort by
EA_Window_Backpack.sortColumnName = ""				-- column name currently sorting by
EA_Window_Backpack.shouldSortIncresing = true		-- DEFAULT_SORTING
EA_Window_Backpack.displayOrder = {}				-- used for switching between up and
EA_Window_Backpack.reverseDisplayOrder = {}			--   down sort directions


-- Header Strings
EA_Window_Backpack.rarityHeader		= GetStringFromTable( "BackpackStrings", StringTables.Backpack.LIST_VIEW_RARITY_HEADER )
EA_Window_Backpack.itemNameHeader   = GetStringFromTable( "BackpackStrings", StringTables.Backpack.LIST_VIEW_NAME_HEADER )
EA_Window_Backpack.typeHeader       = GetStringFromTable( "BackpackStrings", StringTables.Backpack.LIST_VIEW_TYPE_HEADER )
EA_Window_Backpack.rankHeader       = GetStringFromTable( "BackpackStrings", StringTables.Backpack.LIST_VIEW_RANK_HEADER )

-- Header comparator functions

local function originalOrderComparator( a, b )	return( a.slotNum < b.slotNum )  end 
local function rarityComparator( a, b )			return( a.rarity > b.rarity )  end
local function nameComparator( a, b )			return( WStringsCompare( a.name, b.name ) == -1 )  end
local function typeComparator( a, b )			return( WStringsCompare( a.typeText, b.typeText ) == -1 )  end 
local function rankComparator( a, b )			return( a.level > b.level )  end

EA_Window_Backpack.sortHeaderData =
{
	[0] = { sortFunc=originalOrderComparator, },
    { column = "Rarity",        text=EA_Window_Backpack.rarityHeader,		sortFunc=rarityComparator,     },
    { column = "Name",          text=EA_Window_Backpack.itemNameHeader,     sortFunc=nameComparator,     },
    { column = "Type",          text=EA_Window_Backpack.typeHeader,         sortFunc=typeComparator,     },
    { column = "Rank",          text=EA_Window_Backpack.rankHeader,         sortFunc=rankComparator,    },
}

--------------------------
-- General List View Functions 



function EA_Window_Backpack.InitializeListView()
	     
    -- Basic Filters
    LabelSetText("EA_Window_BackpackListViewFilterArmorLabel", GetString (StringTables.Default.LABEL_ARMOR_ITEMS))
    LabelSetText("EA_Window_BackpackListViewFilterWeaponsLabel", GetString (StringTables.Default.LABEL_WEAPON_ITEMS))
    LabelSetText("EA_Window_BackpackListViewFilterMiscLabel", GetString (StringTables.Default.LABEL_MISC_ITEMS))
    LabelSetText("EA_Window_BackpackListViewFilterByUsableLabel", GetStringFromTable( "BackpackStrings",  StringTables.Backpack.LIST_VIEW_FILTER_USABLE ) )
	
     -- Sorting Buttons
    for i, data in ipairs( EA_Window_Backpack.sortHeaderData ) do
        local buttonName = "EA_Window_BackpackListViewHeader"..data.column
	    ButtonSetText( buttonName, data.text )
        WindowSetShowing( buttonName.."DownArrow", false )
        WindowSetShowing( buttonName.."UpArrow", false )
    end
    	
	 EA_Window_Backpack.ResetListViewFilters()

	DataUtils.SetListRowAlternatingTints( "EA_Window_BackpackListViewList", EA_Window_Backpack.MAX_VISIBLE_ROWS )

end


function EA_Window_Backpack.SetListViewItem( slotNum, itemData )

	if not EA_Window_Backpack.ValidItem( itemData ) then
		EA_Window_Backpack.listViewData[slotNum] = nil
		return
	end
	
	local listViewItem = {}
	
	-- since sorting changes the order things are in the table, we save their original slotNum
    listViewItem.slotNum = slotNum
    listViewItem.iconNum = itemData.iconNum
    listViewItem.rarity = itemData.rarity
    listViewItem.name = GetStringFormatFromTable("BackpackStrings", StringTables.Backpack.LIST_VIEW_ITEM_NAME_WITH_COUNT, {itemData.name, L""..itemData.stackCount})
    listViewItem.typeText = DataUtils.getItemTypeText( itemData )
    listViewItem.level = itemData.level
    
    if(itemData.type == GameData.ItemTypes.TREASURE_CHEST) then
        listViewItem.lockedText = GetString(StringTables.Default.TEXT_LOCKED)
    else
        listViewItem.lockedText = L""
    end
    
    if(itemData.level > 1) 
    then
        listViewItem.rank = GetStringFormatFromTable("BackpackStrings", StringTables.Backpack.LIST_VIEW_MIN_RANK, {L""..itemData.level})
    else
        listViewItem.rank = L""
    end


	-- TODO: add trade skill level or maybe renown requirement
    
    EA_Window_Backpack.listViewData[slotNum] = listViewItem
end

function EA_Window_Backpack.CreateListViewData( backpackType )

	local itemsTable = EA_Window_Backpack.GetItemsFromBackpack( backpackType )
	
	EA_Window_Backpack.listViewData = {}
	
    for slotNum, itemData in pairs( itemsTable ) do
		if slotNum > EA_Window_Backpack.numberOfSlots[backpackType] then
			-- had to comment out because currently we regenerate this list every time we switch to list view
			--   and then every time inventory changes once in list view 
			--ERROR(L"createListDisplayData was given item with out of range slot number="..slotNum..L". Ignoring it." )
			continue
		end
	
		EA_Window_Backpack.SetListViewItem( slotNum, itemData )
    end

	EA_Window_Backpack.CreateListDisplayData()
end



function EA_Window_Backpack.CreateListDisplayData()
	
	EA_Window_Backpack.displayData = {}
	
    for slotNum, itemData in pairs( EA_Window_Backpack.listViewData ) do
		table.insert( EA_Window_Backpack.displayData, itemData )
	end
end

function EA_Window_Backpack.UpdateCurrentList( backpackType )
    
    -- TODO: OPTIMIZE: we shouldn't have to recreate the whole list every time a new item comes in.
	EA_Window_Backpack.CreateListViewData( backpackType )
    
	EA_Window_Backpack.ShowCurrentList( )
    
end

function EA_Window_Backpack.ShowCurrentList( )
    
    local currentBackpackType = EA_Window_Backpack.GetCurrentBackpackType()
    -- sort all data before filtering
    EA_Window_Backpack.Sort()
       
    local filteredDataIndices = EA_Window_Backpack.CreateFilteredList( currentBackpackType )
    EA_Window_Backpack.InitDataForSorting( filteredDataIndices )
    EA_Window_Backpack.DisplaySortedData()
    
end



function EA_Window_Backpack.DisplaySortedData()
    if EA_Window_Backpack.shouldSortIncresing then
        ListBoxSetDisplayOrder( "EA_Window_BackpackListViewList", EA_Window_Backpack.displayOrder )
    else
        ListBoxSetDisplayOrder( "EA_Window_BackpackListViewList", EA_Window_Backpack.reverseDisplayOrder )
    end 
end


function EA_Window_Backpack.ColorLabelIfMeetsRequirements( labelName, isLabelShown, meetsReqs )

	local color
	if isLabelShown then
		if meetsReqs then
			color = EA_Window_Backpack.COLOR_MEETS_REQUIREMENTS
		else
			color = EA_Window_Backpack.COLOR_FAILS_REQUIREMENTS
		end	
		LabelSetTextColor( labelName, color.r, color.g, color.b )		
	end		
end


function EA_Window_Backpack.PopulateListDisplayData()
	
    local backpackType = EA_Window_Backpack.GetCurrentBackpackType()
    local inventory = EA_Window_Backpack.GetItemsFromBackpack( backpackType )
    local slotNum, itemData
    local labelName, isLabelShown, reqFlags, meetsReq
    local color
            
    for row, rowIndex in ipairs( EA_Window_BackpackListViewList.PopulatorIndices ) do
        
        slotNum = EA_Window_Backpack.displayData[rowIndex].slotNum
		itemData = inventory[slotNum]
		reqFlags = DataUtils.PlayerMeetsReqs( itemData )
	
	
		-- TODO: once we have cooldown timers working in list view, i think they 
		--		need to clear and be re-checked every time we populate
	
	
		-- display name in color of rarity
		color = DataUtils.GetItemRarityColor( itemData )
		LabelSetTextColor( EA_Window_Backpack.windowName.."ListViewListRow"..row.."ItemName", color.r, color.g, color.b )
	
	    -- display locked text in appropriate color if item is a treasure chest
		isLabelShown = EA_Window_Backpack.displayData[rowIndex].lockedText ~= L""
		if(isLabelShown) then
		    labelName = EA_Window_Backpack.windowName.."ListViewListRow"..row.."ItemLocked"
            color = DataUtils.GetItemTierColor(itemData)
            LabelSetTextColor( labelName, color.r, color.g, color.b )
        end
	
		-- display itemtype in red if player doesn't meet skill requirement
		labelName = EA_Window_Backpack.windowName.."ListViewListRow"..row.."ItemType"
		isLabelShown = EA_Window_Backpack.displayData[rowIndex].typeText ~= L""
		meetsReq = reqFlags.skills 
		EA_Window_Backpack.ColorLabelIfMeetsRequirements( labelName, isLabelShown, meetsReq )
		
		
		-- display rank requirements in red if player doesn't meet requirement
		labelName = EA_Window_Backpack.windowName.."ListViewListRow"..row.."ItemRank"
		isLabelShown = itemData.level ~= nil and itemData.level > 1		-- NOTE: we may want to use trade skill checks and renown checks in this same label later	
		meetsReq = reqFlags.level	-- and reqFlags.tradeSkillLevel and reqFlags.renown
		EA_Window_Backpack.ColorLabelIfMeetsRequirements( labelName, isLabelShown, meetsReq )
		
    end
end



--------------------------
-- Filtering Functions 


function EA_Window_Backpack.ResetListViewFilters()
    
    ButtonSetPressedFlag( "EA_Window_BackpackListViewFilterArmorButton", true )
    ButtonSetPressedFlag( "EA_Window_BackpackListViewFilterWeaponsButton", true )
    ButtonSetPressedFlag( "EA_Window_BackpackListViewFilterMiscButton", true )
  
    ButtonSetPressedFlag( "EA_Window_BackpackListViewFilterByUsableButton", false )
end


function EA_Window_Backpack.ToggleListViewFilter()
    
    if ButtonGetDisabledFlag( SystemData.ActiveWindow.name.."Button" ) then
		return
	end
	
	--[[
    if Cursor.IconOnCursor() then
        Cursor.Clear()
    end
    --]]
    
    EA_LabelCheckButton.Toggle()
    
    EA_Window_Backpack.ShowCurrentList()
end


function EA_Window_Backpack.CreateFilteredList( backpackType )

    local shouldShowOnlyUsable = ButtonGetPressedFlag( "EA_Window_BackpackListViewFilterByUsableButton" )

    local shouldShowArmor = ButtonGetPressedFlag( "EA_Window_BackpackListViewFilterArmorButton" )
    local shouldShowWeapon = ButtonGetPressedFlag( "EA_Window_BackpackListViewFilterWeaponsButton" )
    local shouldShowMisc = ButtonGetPressedFlag( "EA_Window_BackpackListViewFilterMiscButton" )
    
    local displayOrder = {}
    local itemData
    local inventory = EA_Window_Backpack.GetItemsFromBackpack( backpackType )
       
    for index, displayItem in ipairs(EA_Window_Backpack.displayData) do
            
		itemData = inventory[displayItem.slotNum]
        if shouldShowOnlyUsable and not DataUtils.PlayerCanUseItem( itemData ) then
           continue
        end
        
        local show = true
        
        -- ASSUMPTION: I'm assuming all filters are mutually exclusive item category and 
        --             therefore we only have to check until one item category matches
        --
        if DataUtils.ItemIsArmor( itemData ) then
            show = shouldShowArmor
            
        elseif DataUtils.ItemIsWeapon( itemData ) then
            show = shouldShowWeapon
            
        else
            show = shouldShowMisc
        end
        
        if show then
            table.insert( displayOrder, index )
        end
        
    end

    return displayOrder
end



----------------------------------------------------------------
-- Sorting Functions
----------------------------------------------------------------


-- keep the forward and backward order lists for clicking on sort headers
function EA_Window_Backpack.InitDataForSorting( filteredIndices )
    
    EA_Window_Backpack.displayOrder = filteredIndices
    
    EA_Window_Backpack.reverseDisplayOrder = {}
    for i = #filteredIndices, 1, -1 do  
        table.insert( EA_Window_Backpack.reverseDisplayOrder, filteredIndices[i] )
    end
  
end


-- clears the column header sort arrow if set
function EA_Window_Backpack.ClearSortButton()
    
    if EA_Window_Backpack.sortColumnName ~= "" then
        WindowSetShowing(EA_Window_Backpack.sortColumnName.."DownArrow", false )
        WindowSetShowing(EA_Window_Backpack.sortColumnName.."UpArrow", false )
        
        EA_Window_Backpack.sortColumnName = "" 
        EA_Window_Backpack.sortColumnNum = 0
        EA_Window_Backpack.shouldSortIncresing = true
    end
    
end

     
-- Update the sort buttons
-- They have 3 states to switch between if you keep pressng the same button: 
--		increasing, decreasing, and off
-- 
function EA_Window_Backpack.ChangeSorting()
    
    if EA_Window_Backpack.sortColumnName == SystemData.ActiveWindow.name  then
		if EA_Window_Backpack.shouldSortIncresing then
			EA_Window_Backpack.shouldSortIncresing = (not EA_Window_Backpack.shouldSortIncresing)
		else
			EA_Window_Backpack.ClearSortButton()
		end
        
    else
        EA_Window_Backpack.ClearSortButton()
        EA_Window_Backpack.sortColumnName = SystemData.ActiveWindow.name
        EA_Window_Backpack.sortColumnNum = WindowGetId( SystemData.ActiveWindow.name )
    end

	if EA_Window_Backpack.sortColumnNum > 0 then
		WindowSetShowing(EA_Window_Backpack.sortColumnName.."DownArrow", EA_Window_Backpack.shouldSortIncresing )
		WindowSetShowing(EA_Window_Backpack.sortColumnName.."UpArrow", (not EA_Window_Backpack.shouldSortIncresing) )
	end
	
    EA_Window_Backpack.ShowCurrentList()
end


function EA_Window_Backpack.RefreshAllSortButtons()

    for i, data in ipairs( EA_Window_Backpack.sortHeaderData ) do
        local buttonName = "EA_Window_BackpackListViewHeader"..data.column
        WindowSetShowing( buttonName.."DownArrow", false )
        WindowSetShowing( buttonName.."UpArrow", false )
    end
	
	if EA_Window_Backpack.sortColumnNum > 0 then
		WindowSetShowing(EA_Window_Backpack.sortColumnName.."DownArrow", EA_Window_Backpack.shouldSortIncresing )
		WindowSetShowing(EA_Window_Backpack.sortColumnName.."UpArrow", (not EA_Window_Backpack.shouldSortIncresing) )
	end
end
   
-- returns true if a sort column is set and false if not
function EA_Window_Backpack.Sort()

    if EA_Window_Backpack.sortColumnNum >= 0 then
        local comparator = EA_Window_Backpack.sortHeaderData[EA_Window_Backpack.sortColumnNum].sortFunc
        table.sort( EA_Window_Backpack.displayData, comparator )
    end

end


     


function EA_Window_Backpack.GetSlotNumForActiveListRow()

	local rowIdx = WindowGetId( SystemData.ActiveWindow.name ) 

    local dataIdx = ListBoxGetDataIndex (EA_Window_Backpack.windowName.."ListViewList", rowIdx)
    return EA_Window_Backpack.displayData[dataIdx].slotNum
end



-------------------------------------------------------------------------
-- Button Handlers
-------------------------------------------------------------------------

function EA_Window_Backpack.ListViewInventoryMouseOver()

	local slotNum = EA_Window_Backpack.GetSlotNumForActiveListRow()
    EA_Window_Backpack.MouseOverEquipmentSlot( slotNum, SystemData.ActiveWindow.name )
end 

function EA_Window_Backpack.ListViewInventoryLButtonDown( flags )

	local slotNum = EA_Window_Backpack.GetSlotNumForActiveListRow()
    EA_Window_Backpack.EquipmentLButtonDown( slotNum, flags )
end 

function EA_Window_Backpack.ListViewInventoryLButtonUp()

	local slotNum = EA_Window_Backpack.GetSlotNumForActiveListRow()
    EA_Window_Backpack.EquipmentLButtonUp( slotNum )
end 

function EA_Window_Backpack.ListViewInventoryRButtonUp( flags )

	local slotNum = EA_Window_Backpack.GetSlotNumForActiveListRow()
    EA_Window_Backpack.EquipmentRButtonUp( slotNum, flags )
end 

