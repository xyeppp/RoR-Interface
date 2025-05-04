
----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_Backpack_Filters = 
{
	
	-- NOTE: for now these need to match the index that they are provided in the MAIN_MENU.
	-- TODO: we should create a mapping so that this is not required
	--
	CRAFTING_SUBMENU    = 5,
	MISC_SUBMENU        = 6,
	USABILITY_SUBMENU   = 7,
	RARITY_SUBMENU      = 8,


	-- this value shouldn't matter as long as it doesn't conflict with the ones above
	MAIN_MENU			= 1,	
	
	filterWindowPrefix = EA_Window_Backpack.windowName.."Filter",
}


----------------------------------
--- local Filter Functions 

-- TODO: move these filters to DataUtils so can be used by other Items windows (like Auction House)

-- item types
local function FilterWeapons( itemData )	return( DataUtils.ItemIsWeapon( itemData ) )						end
local function FilterArmor( itemData )		return( DataUtils.ItemIsArmor( itemData ) and itemData.type ~= GameData.ItemTypes.ACCESSORY )							end
local function FilterPotions( itemData )	return( itemData.type == GameData.ItemTypes.POTION )				end
local function FilterSiege( itemData )		return( itemData.type == GameData.ItemTypes.SIEGE )					end
local function FilterCrafting( itemData )	return( DataUtils.IsTradeSkillItem( itemData ) )					end
local function FilterMisc( itemData )	

	return( not FilterWeapons( itemData ) and
			not FilterArmor( itemData ) and
			not FilterCrafting( itemData ) and
			not FilterSiege( itemData ) and
			not FilterPotions( itemData ) )
end

-- crafting subchoices
local function FilterCultivating( itemData )	return( DataUtils.IsTradeSkillItem( itemData, GameData.TradeSkills.CULTIVATION ) )								end
local function FilterApothecary( itemData )		return( DataUtils.IsTradeSkillItem( itemData, GameData.TradeSkills.APOTHECARY ) )	end
local function FilterTalismanMaking( itemData )	return( DataUtils.IsTradeSkillItem( itemData, GameData.TradeSkills.TALISMAN ) )		end
local function FilterSalvaging( itemData )		return( DataUtils.IsTradeSkillItem( itemData, GameData.ItemTypes.EITEM_TYPE_SALVAGING )	)					end

-- misc subchoices
local function FilterAccessory( itemData )	return( itemData.type == GameData.ItemTypes.ACCESSORY )				end
local function FilterDye( itemData )		return( itemData.type == GameData.ItemTypes.DYE )					end
local function FilterTalisman( itemData )	return( itemData.type == GameData.ItemTypes.ENHANCEMENT )			end
local function FilterTrophy( itemData )		return( itemData.type == GameData.ItemTypes.TROPHY)					end

-- rarity
local function FilterRarityUtility( itemData )	return( itemData.rarity == SystemData.ItemRarity.UTILITY )		end
local function FilterRarityCommon( itemData )	return( itemData.rarity == SystemData.ItemRarity.COMMON )		end
local function FilterRarityUncommon( itemData )	return( itemData.rarity == SystemData.ItemRarity.UNCOMMON )		end
local function FilterRarityRare( itemData )		return( itemData.rarity == SystemData.ItemRarity.RARE )			end
local function FilterRarityVeryRare( itemData )	return( itemData.rarity == SystemData.ItemRarity.VERY_RARE )	end
local function FilterRarityMythic( itemData )	return( itemData.rarity == SystemData.ItemRarity.ARTIFACT )		end


-- IsUsable, NeverUsable, and NotYetUsable are basically 3 different categories can be viewed as.
--   the main difference between IsUsable and NotYetUsable is whether the player currently is high enough level,
--   skill, or renown to currently equip/use the item.

local function FilterIsUsable( itemData )	return( DataUtils.PlayerCanUseItem( itemData ) )					end

local function FilterNeverUsable( itemData )

	return( not DataUtils.CareerIsAllowedForItem( GameData.Player.career.line, inItemData ) or 
			not DataUtils.SkillIsEnoughForItem( GameData.Player.Skills, inItemData ) or
			not DataUtils.RaceIsAllowedForItem( GameData.Player.race.id, inItemData ) or
			not DataUtils.RenownIsEnoughForItem( GameData.Player.Renown.curRank, inItemData ) 
		  )
end

local function FilterNotYetUsable( itemData )	
	return( not FilterIsUsable( itemData ) and not FilterNeverUsable( itemData ) )
end



-- the field windowName gets added to each filter table dynamicly
EA_Window_Backpack_Filters.menus = 
{

	[EA_Window_Backpack_Filters.MAIN_MENU] =
	{
		{ text=GetStringFromTable( "BackpackStrings", StringTables.Backpack.FILTERS_MAIN_WEAPONS ),		template="BackpackContextMenuChoice",   filter=FilterWeapons,	filterGroup=EA_Window_Backpack_Filters.MAIN_MENU,		},
		{ text=GetStringFromTable( "BackpackStrings", StringTables.Backpack.FILTERS_MAIN_ARMOR ),		template="BackpackContextMenuChoice",   filter=FilterArmor,	    filterGroup=EA_Window_Backpack_Filters.MAIN_MENU,		},
		{ text=GetStringFromTable( "BackpackStrings", StringTables.Backpack.FILTERS_MAIN_POTIONS ),		template="BackpackContextMenuChoice",   filter=FilterPotions,	filterGroup=EA_Window_Backpack_Filters.MAIN_MENU,		},
		{ text=GetStringFromTable( "BackpackStrings", StringTables.Backpack.FILTERS_MAIN_SIEGE ),		template="BackpackContextMenuChoice",   filter=FilterSiege,		filterGroup=EA_Window_Backpack_Filters.MAIN_MENU,		},
		{ text=GetStringFromTable( "BackpackStrings", StringTables.Backpack.FILTERS_MAIN_CRAFTING ),	template="BackpackContextMenuChoice",   filter=FilterCrafting,	filterGroup=EA_Window_Backpack_Filters.MAIN_MENU,		subMenu=EA_Window_Backpack_Filters.CRAFTING_SUBMENU,	},
		{ text=GetStringFromTable( "BackpackStrings", StringTables.Backpack.FILTERS_MAIN_MISC ),		template="BackpackContextMenuChoice",   filter=FilterMisc,		filterGroup=EA_Window_Backpack_Filters.MAIN_MENU,		subMenu=EA_Window_Backpack_Filters.MISC_SUBMENU,		},
		{ text=GetStringFromTable( "BackpackStrings", StringTables.Backpack.FILTERS_MAIN_USABILITY ),	template="BackpackContextMenuChoice",   filter=nil,				noCheckbox=true,										subMenu=EA_Window_Backpack_Filters.USABILITY_SUBMENU,	},
		{ text=GetStringFromTable( "BackpackStrings", StringTables.Backpack.FILTERS_MAIN_RARITY ),		template="BackpackContextMenuChoice",   filter=nil,				noCheckbox=true,										subMenu=EA_Window_Backpack_Filters.RARITY_SUBMENU,		},
	},
		 
	[EA_Window_Backpack_Filters.CRAFTING_SUBMENU] =
	{
		{ text=GetStringFromTable( "BackpackStrings", StringTables.Backpack.FILTERS_CRAFTING_CULTIVATING ), 		filter=FilterCultivating,			filterGroup=EA_Window_Backpack_Filters.CRAFTING_SUBMENU,		 },
		{ text=GetStringFromTable( "BackpackStrings", StringTables.Backpack.FILTERS_CRAFTING_APOTHECARY ), 			filter=FilterApothecary,			filterGroup=EA_Window_Backpack_Filters.CRAFTING_SUBMENU,		 },
		{ text=GetStringFromTable( "BackpackStrings", StringTables.Backpack.FILTERS_CRAFTING_TALISMAN_MAKING ),		filter=FilterTalismanMaking,		filterGroup=EA_Window_Backpack_Filters.CRAFTING_SUBMENU,		 },
		{ text=GetStringFromTable( "BackpackStrings", StringTables.Backpack.FILTERS_CRAFTING_SALVAGING ), 			filter=FilterSalvaging,				filterGroup=EA_Window_Backpack_Filters.CRAFTING_SUBMENU,		 },
	},
	
		 
	[EA_Window_Backpack_Filters.MISC_SUBMENU] =
	{
		{ text=ItemTypes[ GameData.ItemTypes.ACCESSORY ].name,  	filter=FilterAccessory,		filterGroup=EA_Window_Backpack_Filters.MISC_SUBMENU,		},
		{ text=ItemTypes[ GameData.ItemTypes.DYE ].name,  			filter=FilterDye,			filterGroup=EA_Window_Backpack_Filters.MISC_SUBMENU,		},
		{ text=ItemTypes[ GameData.ItemTypes.ENHANCEMENT ].name,  	filter=FilterTalisman,		filterGroup=EA_Window_Backpack_Filters.MISC_SUBMENU,		},
		{ text=ItemTypes[ GameData.ItemTypes.TROPHY ].name, 		filter=FilterTrophy,		filterGroup=EA_Window_Backpack_Filters.MISC_SUBMENU,		},
	},

	[EA_Window_Backpack_Filters.USABILITY_SUBMENU] =
	{
		{ text=GetStringFromTable( "BackpackStrings", StringTables.Backpack.FILTERS_USABILITY_IS_USABLE ), 			filter=FilterIsUsable,			filterGroup=EA_Window_Backpack_Filters.USABILITY_SUBMENU,		},
		{ text=GetStringFromTable( "BackpackStrings", StringTables.Backpack.FILTERS_USABILITY_FUTURE_USABLE ), 		filter=FilterNotYetUsable,		filterGroup=EA_Window_Backpack_Filters.USABILITY_SUBMENU,		},
		{ text=GetStringFromTable( "BackpackStrings", StringTables.Backpack.FILTERS_USABILITY_NEVER_USABLE ), 		filter=FilterNeverUsable,		filterGroup=EA_Window_Backpack_Filters.USABILITY_SUBMENU,		},
	},
		 
	[EA_Window_Backpack_Filters.RARITY_SUBMENU] =
	{
		{ text=GameDefs.ItemRarity[SystemData.ItemRarity.UTILITY].desc,		filter=FilterRarityUtility,			filterGroup=EA_Window_Backpack_Filters.RARITY_SUBMENU,		},
		{ text=GameDefs.ItemRarity[SystemData.ItemRarity.COMMON].desc,		filter=FilterRarityCommon,			filterGroup=EA_Window_Backpack_Filters.RARITY_SUBMENU,		},
		{ text=GameDefs.ItemRarity[SystemData.ItemRarity.UNCOMMON].desc,	filter=FilterRarityUncommon,		filterGroup=EA_Window_Backpack_Filters.RARITY_SUBMENU,		},
		{ text=GameDefs.ItemRarity[SystemData.ItemRarity.RARE].desc,		filter=FilterRarityRare,			filterGroup=EA_Window_Backpack_Filters.RARITY_SUBMENU,		},
		{ text=GameDefs.ItemRarity[SystemData.ItemRarity.VERY_RARE].desc,	filter=FilterRarityVeryRare,		filterGroup=EA_Window_Backpack_Filters.RARITY_SUBMENU,		},
		{ text=GameDefs.ItemRarity[SystemData.ItemRarity.ARTIFACT].desc, 	filter=FilterRarityMythic,			filterGroup=EA_Window_Backpack_Filters.RARITY_SUBMENU,		},
	},
	
}

EA_Window_Backpack.STRING_TITLE_CONJUNCTION = GetStringFromTable( "BackpackStrings", StringTables.Backpack.FILTERS_SECTION_TITLE_LIST_CONJUNCTOR_SYMBOL )

EA_Window_Backpack.MAX_CHOICES_PER_FILTER_MENU = 100

EA_Window_Backpack.filtersMenuOpened = 0
EA_Window_Backpack.pocketForFiltersMenuOpened = 0



----------------------------------------------------------------
-- EA_Window_Backpack_Filters Functions
----------------------------------------------------------------


-- OnInitialize Handler
function EA_Window_Backpack.InitializeBackpackFilters()

	local filterID
	
	for filterMenuIndex, filterMenuData in pairs(EA_Window_Backpack_Filters.menus) do
	
		for filterIndex, filterData in pairs(filterMenuData) do
		
			EA_Window_Backpack.SetWindowNameForFilter( filterData )
			
			local template = "BackpackContextSubMenuChoice" 
            if( filterData.template ) 
            then 
                template = filterData.template 
            end 
            CreateWindowFromTemplate( filterData.windowName, template, "Root" )
			LabelSetText( filterData.windowName.."Text", filterData.text )
			
			filterID = EA_Window_Backpack.GetIDForFilter( filterMenuIndex, filterIndex )
			WindowSetId( filterData.windowName.."CheckBox", filterID )
			ButtonSetCheckButtonFlag( filterData.windowName.."CheckBox", true )
			WindowSetShowing( filterData.windowName.."CheckBox", (not filterData.noCheckbox) )
			WindowSetShowing( filterData.windowName.."SubMenuButton", (filterData.subMenu ~= nil))
			WindowSetShowing( filterData.windowName, false)
		end
		
	end
end



-- OnShutdown Handler
-- explicitly destroying dynamically created windows
function EA_Window_Backpack.ShutdownBackpackFilters()

	for filterMenuIndex, filterMenuData in pairs(EA_Window_Backpack_Filters.menus) do
	
		for filterIndex, filterData in pairs(filterMenuData) do
		
			DestroyWindow( filterData.windowName)
		end
	end

end


-- dynamically create an XML windowName based on the filter name.
-- ASSUMPTION: all of the filter names need to be different
--
function EA_Window_Backpack.SetWindowNameForFilter( filterData )
	
	local tempName = string.gsub( WStringToString(filterData.text), " ", "_" )
	filterData.windowName = EA_Window_Backpack_Filters.filterWindowPrefix..tempName
end


-- ASSUMPTION: right now this only handles 2 levels of windows
function EA_Window_Backpack.GetWindowNameForFilterMenu( filterMenuIndex )

	local anchorWindow = WindowGetParent( SystemData.MouseOverWindow.name ) 
	local contextMenuID = EA_Window_ContextMenu.CONTEXT_MENU_2
	
	if filterMenuIndex == EA_Window_Backpack_Filters.MAIN_MENU then
		anchorWindow = EA_Window_Backpack.windowName
		contextMenuID = EA_Window_ContextMenu.CONTEXT_MENU_1
	end
	local contextWindow = "EA_Window_ContextMenu"..contextMenuID
	
	return contextWindow, contextMenuID, anchorWindow
end


function EA_Window_Backpack.ShowFilterMenu( filterMenuIndex, pocketNumber )

	EA_Window_Backpack.filtersMenuOpened = filterMenuIndex
    local pocketData = EA_Window_Backpack.pockets[pocketNumber]
    if pocketData == nil or pocketData.filters == nil then
		ERROR(L"EA_Window_Backpack.ShowFilterMenu: pocketData filters not found for pocket number "..pocketNumber)
    end
    
	local contextWindow, contextMenuID, anchorWindow = EA_Window_Backpack.GetWindowNameForFilterMenu( filterMenuIndex )
	
    EA_Window_ContextMenu.CreateContextMenu( anchorWindow, contextMenuID )
    
    local filterID
	for filterIndex, filterData in pairs( EA_Window_Backpack_Filters.menus[filterMenuIndex] ) do 
		
		filterID = EA_Window_Backpack.GetIDForFilter( filterMenuIndex, filterIndex )
		EA_Window_ContextMenu.AddUserDefinedMenuItem(filterData.windowName, contextMenuID)
		ButtonSetPressedFlag( filterData.windowName.."CheckBox", (pocketData.filters[filterID] == true) )
	end
	
    EA_Window_ContextMenu.Finalize(contextMenuID)
end

function EA_Window_Backpack.OnMouseOverFiltersButton()
    -- TODO : Remove the check when we want to handle multiple backpacks
    if( EA_Window_Backpack.currentMode == EA_Window_Backpack.TYPE_INVENTORY )
    then
        local windowName = SystemData.ActiveWindow.name
        Tooltips.CreateTextOnlyTooltip( windowName, GetStringFromTable( "BackpackStrings", StringTables.Backpack.FILTERS_BUTTON_TOOLTIP ) )
        Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_TOP)
    end
end


function EA_Window_Backpack.HideFilterMenus()

	EA_Window_Backpack.pocketForFiltersMenuOpened = 0
	EA_Window_Backpack.filtersMenuOpened = 0
	
	EA_Window_ContextMenu.HideAll()
end


function EA_Window_Backpack.ToggleFiltersMainMenu()
	
    -- TODO : Remove the check when we want to handle multiple backpacks
    if( EA_Window_Backpack.currentMode == EA_Window_Backpack.TYPE_INVENTORY )
    then
        local pocketNumber = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
        local previousPocketNumber = EA_Window_Backpack.pocketForFiltersMenuOpened
        
        local mainMenuWindowName = EA_Window_Backpack.GetWindowNameForFilterMenu( EA_Window_Backpack_Filters.MAIN_MENU )
        if WindowGetShowing(mainMenuWindowName) then
            
            EA_Window_Backpack.HideFilterMenus()
            
        else
            -- clear previousPocketNumber because we are currently using generic windows as the base for the filter menus and so
            --   don't have a way to set an OnHidden() callback to clear EA_Window_Backpack.pocketForFiltersMenuOpened all of the time  
            previousPocketNumber = 0
        end
        
        if pocketNumber ~= previousPocketNumber then
            EA_Window_Backpack.ShowFiltersMainMenu()
        end
	end
end


function EA_Window_Backpack.ToggleFiltersSubMenu()
	
	local filterIndex = WindowGetId( SystemData.MouseOverWindow.name )
	local previousFilterIndex = EA_Window_Backpack.filtersMenuOpened

	if EA_Window_Backpack.filtersMenuOpened <= 0 then
		ERROR( L"In EA_Window_Backpack.ToggleFiltersSubMenu: unexpected value for EA_Window_Backpack.filtersMenuOpened = "..EA_Window_Backpack.filtersMenuOpened )
		return
	end
	
	if (previousFilterIndex > 0 and previousFilterIndex ~= EA_Window_Backpack_Filters.MAIN_MENU and filterIndex ~= previousFilterIndex ) then
		EA_Window_Backpack.HideLastFiltersSubMenu()
	end
	
	if filterIndex ~= previousFilterIndex then
		EA_Window_Backpack.ShowFiltersSubMenu()
	end
	
end

function EA_Window_Backpack.ShowFiltersMainMenu()

	local pocketNumber = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
	EA_Window_Backpack.pocketForFiltersMenuOpened = pocketNumber
	
	EA_Window_Backpack.ShowFilterMenu( EA_Window_Backpack_Filters.MAIN_MENU, pocketNumber )
	
end


function EA_Window_Backpack.ShowFiltersSubMenu()

	local filterIndex = WindowGetId( SystemData.MouseOverWindow.name )
	local filterData = EA_Window_Backpack_Filters.menus[EA_Window_Backpack.filtersMenuOpened][filterIndex]
	
	if filterData.subMenu ~= nil and EA_Window_Backpack.pocketForFiltersMenuOpened > 0 then 
		EA_Window_Backpack.ShowFilterMenu( filterData.subMenu, EA_Window_Backpack.pocketForFiltersMenuOpened )
	end
	
end

function EA_Window_Backpack.HideLastFiltersSubMenu()

	local contextWindow, contextMenuNumber = EA_Window_Backpack.GetWindowNameForFilterMenu( EA_Window_Backpack.filtersMenuOpened )

	EA_Window_ContextMenu.Hide( contextMenuNumber )
	EA_Window_Backpack.filtersMenuOpened = EA_Window_Backpack_Filters.MAIN_MENU
end

function EA_Window_Backpack.ToggleFilterChoice()
	
    local checkBoxName = SystemData.MouseOverWindow.name
	local filterChoice = WindowGetId( checkBoxName )
	local pocketNumber = EA_Window_Backpack.pocketForFiltersMenuOpened 
	local pocketData = EA_Window_Backpack.pockets[pocketNumber]
	
	if pocketData == nil or pocketData.filters == nil then
		ERROR( L"EA_Window_Backpack.ToggleFilterChoice: pocketData.filters could not be accessed.")
		return
	end
	
	if pocketData.filters[filterChoice] then
		pocketData.filters[filterChoice] = nil
	else
		pocketData.filters[filterChoice] = true
	end
	
    if( not EA_Window_Backpack.filters[pocketNumber] )
    then
        EA_Window_Backpack.filters[pocketNumber] = {}
    end
    EA_Window_Backpack.filters[pocketNumber][filterChoice] = pocketData.filters[filterChoice]
    
	EA_Window_Backpack.SetPocketTitleFromFilter( pocketNumber )
end


function EA_Window_Backpack.SetPocketTitleFromFilter( pocketNumber )

	local string
	local filterName
	local pocketData = EA_Window_Backpack.pockets[pocketNumber]
	
	for filterID in pairs( pocketData.filters ) do
    
		filterName = EA_Window_Backpack.GetFilterNameFromID( filterID )
		
		if string == nil then
			string = filterName
		else
			string = string..EA_Window_Backpack.STRING_TITLE_CONJUNCTION..filterName
		end
		
	end
	
	if string == nil then
		string = EA_Window_Backpack.GetPocketDefaultTitle( pocketNumber )
	end

    EA_Window_Backpack.filterPocketNames[pocketNumber] = string
    
	EA_Window_Backpack.SetPocketTitleString( pocketNumber, string )
end



-- only returns true if there is filter(s) set and all match the item
function EA_Window_Backpack.DoesItemMatchPocketFilters( itemData, pocketNumber )

	local pocketData = EA_Window_Backpack.pockets[pocketNumber]
	
	return EA_Window_Backpack.CheckCustomFiltersForMatch( itemData, pocketData.filters )
end



-- ASSUMPTION: this hardcodes the maximum number of cascading filters to be 3 deep. 
--   If more is needed it will be cleaner just to pass in an array
function EA_Window_Backpack.GetIDForFilter( firstIndex, secondIndex, thirdIndex )

	secondIndex = secondIndex or 0
	thirdIndex = thirdIndex or 0
	
	local filterID = (firstIndex * EA_Window_Backpack.MAX_CHOICES_PER_FILTER_MENU) + secondIndex
	filterID = (filterID * EA_Window_Backpack.MAX_CHOICES_PER_FILTER_MENU) + thirdIndex
	
	return filterID
end


function EA_Window_Backpack.GetFilterIndicesFromID( filterID )

	local thirdIndex = filterID % EA_Window_Backpack.MAX_CHOICES_PER_FILTER_MENU
	filterID = math.floor(filterID / EA_Window_Backpack.MAX_CHOICES_PER_FILTER_MENU)
	
	local secondIndex = filterID % EA_Window_Backpack.MAX_CHOICES_PER_FILTER_MENU
	filterID = math.floor(filterID / EA_Window_Backpack.MAX_CHOICES_PER_FILTER_MENU)
	
	local firstIndex = filterID
	
	return firstIndex, secondIndex, thirdIndex
end


function EA_Window_Backpack.GetFilterNameFromID( filterID )

	local firstIndex, secondIndex = EA_Window_Backpack.GetFilterIndicesFromID( filterID )
	local menuEntry = EA_Window_Backpack_Filters.menus[firstIndex][secondIndex]
	return menuEntry.text
end


function EA_Window_Backpack.CheckCustomFiltersForMatch( itemData, tableOfFilters)
	
	local MainMenuIndex, SubMenuIndex
	local anyFilters = false
	local filterFunction, filterData
	local filterGroupsEvaluated = {}
	
	for filterID in pairs( tableOfFilters ) do
	
		MainMenuIndex, SubMenuIndex = EA_Window_Backpack.GetFilterIndicesFromID( filterID )
	
		filterData = EA_Window_Backpack_Filters.menus[MainMenuIndex][SubMenuIndex]
		filterFunction = filterData.filter
		if filterFunction == nil or type(filterFunction) ~= "function" then
			ERROR(L"EA_Window_Backpack.CheckCustomFiltersForMatch filter found with no test function. filterID="..filterID)
			continue	
		end
		
		-- check filter
		-- though can skip check if one of the filters from the same filterGroup already matched
		if not filterGroupsEvaluated[filterData.filterGroup] then
			anyFilters = true
			filterGroupsEvaluated[filterData.filterGroup] = filterFunction( itemData ) 
		end
	end
	
	-- make sure we had at least one filter 
	if not anyFilters then
		return false
	end
	
	-- check each filter group marked to make sure it had at least one filter match
	for group, passed in pairs( filterGroupsEvaluated ) do
		if not passed then
			return false
		end
	end

	return true
end

function EA_Window_Backpack.FindNewPocketForIncomingItem( slot, currentPocket )
    -- TODO : Update this function to work with any backpack, that we want filters on
    local backpackType = EA_Window_Backpack.TYPE_INVENTORY
    local itemData  = EA_Window_Backpack.GetItemsFromBackpack( backpackType )[slot]
    local openSlot
    
	for __, pocketNumber in ipairs(EA_Window_Backpack.pockets.filterOrder)
    do
		if EA_Window_Backpack.DoesItemMatchPocketFilters( itemData, pocketNumber )
        then
			-- if already in the desired pocket, then leave it there
			if pocketNumber == currentPocket
            then
				return 0, 0
			end
			
			openSlot = EA_Window_Backpack.GetFirstOpenSlotInPocket( backpackType, pocketNumber )
			if openSlot > 0
            then
				return openSlot, pocketNumber
			end
		end
		
	end
	
	-- the only way this line should get hit is if the item won't fit in any filtered pockets that it matches,
	--   there's no room in the main items pocket, and another pocket has spaces but doesn't meet the filter.
	
	return 0, 0
end


function EA_Window_Backpack.GetFirstOpenSlotInPocket( backpackType, pocketNumber )
			
	local itemData
	for slot = EA_Window_Backpack.pockets[pocketNumber].firstSlotID, EA_Window_Backpack.pockets[pocketNumber].lastSlotID do
	
        local inventory = EA_Window_Backpack.GetItemsFromBackpack( backpackType )
		itemData = inventory[slot]
		if not EA_Window_Backpack.ValidItem( itemData ) and EA_Window_Backpack.manuallyMovedItems[backpackType][slot] == nil then
			return slot
		end
	end
	
	return 0
end
