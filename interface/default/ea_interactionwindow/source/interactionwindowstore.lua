
----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_InteractionStore = 
{
    versionNumber = 0.01,
    storeCategories = {},
    storedata = {},
    buyBackData = {},
    
    currentlyDisplayedTabID = 0,
    UNUSABLE_ITEM_COLOR = { r=200, g=0, b=0 },

	SORT_FILTER_ATTAINABLE = 1,
	SORT_FILTER_APPLICABLE = 2,
    SORT_FILTER_SHOW_ALL = 3,
    
    allowCategorySwitch = false,
    categoryIdMap = {},
    
    repairModeOn = false,
    currentRepairCursor = nil,
    pendingRepairSlots = {},
    pendingSellSlots = {},
    pendingSellCounts = {},
        
    -- We'll go ahead and cache this, since it's easier to change when we detect inventory changes
    repairToggleTooltip = L"",
    repairAllTooltip = L"",
    sufficientFundsToRepairAll = false,
    

    sortColumnNum = 0,               -- column number to sort by
    sortColumnName = "",              -- column name currently sorting by
    shouldSortIncresing = true,       -- DEFAULT_SORTING
    displayOrder = {},          -- used for switching between up and
    reverseDisplayOrder = {},   --   down sort directions
    
    -- we now save sort column separately for the 2 tabs, so easy way is 
    --   just to remember previous values and switch out when we switch tabs
    previousSortColumnNum = 0,               -- column number to sort by
    previousSortColumnName = "",              -- column name currently sorting by
    previousShouldSortIncresing = true,       -- DEFAULT_SORTING
    --previousDisplayOrder = {},          -- used for switching between up and
    --previousReverseDisplayOrder = {},   --   down sort directions

}
 
 
-----------------------------------------------
-- Data for Different Views/ Items for Sale  --

 
-- point EA_Window_InteractionStore.displayData to storedata or buyBackData so hopefully 
--   we can optimize by not re-fetching that data from C++ over and over
--
EA_Window_InteractionStore.displayData = EA_Window_InteractionStore.storedata

EA_Window_InteractionStore.MAX_VISIBLE_ROWS = 5

EA_Window_InteractionStore.STORE_TAB_ID = 1
EA_Window_InteractionStore.BUY_BACK_TAB_ID = 2

EA_Window_InteractionStore.tabs =
{
    [EA_Window_InteractionStore.STORE_TAB_ID ]		= "EA_Window_InteractionStoreTabsSellTab",
    [EA_Window_InteractionStore.BUY_BACK_TAB_ID ]	= "EA_Window_InteractionStoreTabsBuyBackTab",
}

---------------------
-- Filtering Data  --

EA_Window_InteractionStore.ARMOR_FILTER                  = 1;
EA_Window_InteractionStore.WEAPON_FILTER                 = 2;
EA_Window_InteractionStore.CRAFTING_FILTER               = 3;
EA_Window_InteractionStore.MISC_FILTER                   = 4;
EA_Window_InteractionStore.NUM_STORE_CATEGORY_FILTERS    = 4;

-- These are to help with looking up a name for a filter type...
EA_Window_InteractionStore.filterNames = {};
EA_Window_InteractionStore.filterNames[EA_Window_InteractionStore.ARMOR_FILTER]       = GetString (StringTables.Default.LABEL_ARMOR_ITEMS);
EA_Window_InteractionStore.filterNames[EA_Window_InteractionStore.WEAPON_FILTER]      = GetString (StringTables.Default.LABEL_WEAPON_ITEMS);
EA_Window_InteractionStore.filterNames[EA_Window_InteractionStore.CRAFTING_FILTER]    = GetString (StringTables.Default.LABEL_CRAFTING_ITEMS);
EA_Window_InteractionStore.filterNames[EA_Window_InteractionStore.MISC_FILTER]        = GetString (StringTables.Default.LABEL_MISC_ITEMS);
    

-----------------------
-- Sorting Data  --

-- Header Strings
EA_Window_InteractionStore.itemNameHeader   = GetStringFromTable( "InteractionStoreStrings", StringTables.InteractionStore.STORE_SORT_BY_HEADER_NAME )
EA_Window_InteractionStore.typeHeader       = GetStringFromTable( "InteractionStoreStrings", StringTables.InteractionStore.STORE_SORT_BY_HEADER_TYPE )
EA_Window_InteractionStore.priceHeader      = GetStringFromTable( "InteractionStoreStrings", StringTables.InteractionStore.STORE_SORT_BY_HEADER_PRICE )

-- Header comparator functions

local function originalOrderComparator( a, b )	return ( a.slotNum < b.slotNum )  end
local function nameComparator( a, b )			return( WStringsCompare( a.name, b.name ) == -1 )  end
local function typeComparator( a, b )			return( WStringsCompare( a.typeText, b.typeText ) == -1 )  end 
local function priceComparator( a, b )			return( (a.cost * a.stackCount) < (b.cost * b.stackCount))  end

EA_Window_InteractionStore.sortHeaderData =
{
    [0] = { sortFunc=originalOrderComparator, },
    { column = "Name",          text=EA_Window_InteractionStore.itemNameHeader,     sortFunc=nameComparator,     },
    { column = "Type",          text=EA_Window_InteractionStore.typeHeader,         sortFunc=typeComparator,     },
    { column = "Price",         text=EA_Window_InteractionStore.priceHeader,        sortFunc=priceComparator,    },
}


----------------------------------------------------------------
-- Local Functions
----------------------------------------------------------------

local function GetServerCategoryIDFromLocal( localID )

    local serverID = EA_Window_InteractionStore.categoryIdMap[localID]
    return serverID

end

local function GetLocalCategoryIDFromServer( serverID )
    
    for index, mapServerID in ipairs( EA_Window_InteractionStore.categoryIdMap ) do
        if(mapServerID == serverID)
        then
            return index            
        end
    end
    
    return 0

end

----------------------------------------------------------------
-- EA_Window_InteractionStore Functions
----------------------------------------------------------------

-- OnInitialize Handler
function EA_Window_InteractionStore.Initialize()
    -- DEBUG(L"EA_Window_InteractionStore.Initialize")
        
    local red, green, blue = LabelGetTextColor( "EA_Window_InteractionStoreFilterArmorLabel" )
    EA_Window_InteractionStore.ENABLED_FILTER_COLOR = {r=red,g=green,b=blue}
    EA_Window_InteractionStore.DISABLED_FILTER_COLOR = {r=128,g=128,b=128}

    WindowRegisterEventHandler( "EA_Window_InteractionStore", SystemData.Events.INTERACT_SHOW_STORE, "EA_Window_InteractionStore.ShowStore")
    WindowRegisterEventHandler( "EA_Window_InteractionStore", SystemData.Events.PLAYER_MONEY_UPDATED, "EA_Window_InteractionStore.UpdateMoneyAvailable" )
    WindowRegisterEventHandler( "EA_Window_InteractionStore", SystemData.Events.INTERACT_DONE, "EA_Window_InteractionStore.Done")
    
    LabelSetText("EA_Window_InteractionStoreTitleBarText", GetString( StringTables.Default.LABEL_STORE ) )

    LabelSetText("EA_Window_InteractionStoreMoneyAvailableHeader", GetStringFromTable( "InteractionStoreStrings", StringTables.InteractionStore.STORE_MONEY_LABEL ) )

    -- tab names
    ButtonSetText("EA_Window_InteractionStoreTabsSellTab", GetStringFromTable( "InteractionStoreStrings", StringTables.InteractionStore.STORE_SELL_TAB_LABEL ) ) 
    ButtonSetText("EA_Window_InteractionStoreTabsBuyBackTab", GetStringFromTable( "InteractionStoreStrings", StringTables.InteractionStore.STORE_BUY_BACK_TAB_LABEL ) )
    
    -- Store Filters
    LabelSetText("EA_Window_InteractionStoreFilterArmorLabel", GetString (StringTables.Default.LABEL_ARMOR_ITEMS))
    LabelSetText("EA_Window_InteractionStoreFilterWeaponsLabel", GetString (StringTables.Default.LABEL_WEAPON_ITEMS))
    LabelSetText("EA_Window_InteractionStoreFilterMiscLabel", GetString (StringTables.Default.LABEL_MISC_ITEMS))

    LabelSetText( "EA_Window_InteractionStoreFilterSelectBoxLabel", GetStringFromTable( "InteractionStoreStrings", StringTables.InteractionStore.STORE_FILTER_LABEL ) )
    ComboBoxAddMenuItem( "EA_Window_InteractionStoreFilterSelectBox", GetStringFromTable( "InteractionStoreStrings", StringTables.InteractionStore.STORE_APPLICABLE_LABEL ) )
    ComboBoxAddMenuItem( "EA_Window_InteractionStoreFilterSelectBox", GetStringFromTable( "InteractionStoreStrings", StringTables.InteractionStore.STORE_AVAILABLE_LABEL ) )
    ComboBoxAddMenuItem( "EA_Window_InteractionStoreFilterSelectBox", GetStringFromTable( "InteractionStoreStrings", StringTables.InteractionStore.STORE_SHOW_ALL_LABEL ) )    
    
    LabelSetText("EA_Window_InteractionStoreFilterCategoryBoxLabel", GetStringFromTable( "InteractionStoreStrings", StringTables.InteractionStore.STORE_CATEGORY_LABEL ) ) 

     -- Sorting Buttons
    for i, data in ipairs( EA_Window_InteractionStore.sortHeaderData ) do
        local buttonName = "EA_Window_InteractionStoreHeader"..data.column
        ButtonSetText( buttonName, data.text )
        WindowSetShowing( buttonName.."DownArrow", false )
        WindowSetShowing( buttonName.."UpArrow", false )
    end
        
     -- Buttons
    ButtonSetText("EA_Window_InteractionStoreDone", GetString( StringTables.Default.LABEL_DONE ))
    ButtonSetText("EA_Window_InteractionStoreRepairAll", GetStringFromTable( "InteractionStoreStrings", StringTables.InteractionStore.STORE_REPAIR_ALL_BUTTON_LABEL ) )
    ButtonSetText("EA_Window_InteractionStoreRepairToggle", GetStringFromTable( "InteractionStoreStrings", StringTables.InteractionStore.STORE_REPAIR_TOGGLE_BUTTON_LABEL ) )
   
    EA_Window_InteractionStore.ResetStoreFilters()

    EA_Window_InteractionStore.SetCurrentTab( EA_Window_InteractionStore.STORE_TAB_ID  ) 

    DataUtils.SetListRowAlternatingTints( "EA_Window_InteractionStoreList", EA_Window_InteractionStore.MAX_VISIBLE_ROWS )
end


-- OnShutdown Handler
function EA_Window_InteractionStore.Shutdown()
    EA_Window_InteractionStore.RepairingOff()

end


function EA_Window_InteractionStore.OnRButtonUp()
    EA_Window_ContextMenu.CreateDefaultContextMenu( "EA_Window_InteractionStore" )
end

function EA_Window_InteractionStore.OnHidden()
    -- DEBUG(L"EA_Window_InteractionStore.OnHidden")

    WindowUnregisterEventHandler( "EA_Window_InteractionStore", SystemData.Events.PLAYER_INVENTORY_SLOT_UPDATED )
    
    PlayInteractSound("merchant_goodbye")
    BroadcastEvent( SystemData.Events.INTERACT_DONE )
    
    EA_Window_InteractionStore.storedata = {};
    EA_Window_InteractionStore.buyBackData = {};
    EA_Window_InteractionStore.RepairingOff()
    
    WindowUtils.OnHidden()  
end

-- Play welcome sound and possibly close or move around other windows
function EA_Window_InteractionStore.OnShown()
    -- DEBUG(L"EA_Window_InteractionStore.OnShown")

    WindowUtils.OnShown(EA_Window_InteractionStore.Done, WindowUtils.Cascade.MODE_HIGHLANDER)
    PlayInteractSound("merchant_offer") 
    
    EA_Window_InteractionStore.updateButtonsAndTooltips()
    WindowRegisterEventHandler( "EA_Window_InteractionStore", SystemData.Events.PLAYER_INVENTORY_SLOT_UPDATED, "EA_Window_InteractionStore.updateButtonsAndTooltips")
    
    EA_BackpackUtilsMediator.ShowBackpack()
end

function EA_Window_InteractionStore.Done()

    if Cursor.IconOnCursor() then
        Cursor.Clear()
    end
    
    WindowSetShowing( "EA_Window_InteractionStore", false )
    
    -- The Alt Currency window is "attached" to the store so it should always be hidden when the store window itself is hidden
    EA_Window_InteractionAltCurrency.Hide()
end

----------------------------------------------------------------
-- Sorting Functions
----------------------------------------------------------------

-- clears the column header sort arrow if set
function EA_Window_InteractionStore.ClearSortButton()
--DEBUG(L"EA_Window_InteractionStore.ClearSortButton")
    
    if EA_Window_InteractionStore.sortColumnName ~= "" then
        WindowSetShowing(EA_Window_InteractionStore.sortColumnName.."DownArrow", false )
        WindowSetShowing(EA_Window_InteractionStore.sortColumnName.."UpArrow", false )
        
        EA_Window_InteractionStore.sortColumnName = "" 
        EA_Window_InteractionStore.sortColumnNum = 0
        EA_Window_InteractionStore.shouldSortIncresing = true
    end
    
end


-- Update the sort buttons
-- They have 3 states to switch between if you keep pressng the same button: 
--		increasing, decreasing, and off
-- 
function EA_Window_InteractionStore.ChangeSorting()
--DEBUG(L"EA_Window_InteractionStore.ChangeSorting")
    
    if Cursor.IconOnCursor() then
        Cursor.Clear()
    end
    
    if EA_Window_InteractionStore.sortColumnName == SystemData.ActiveWindow.name  then
        if EA_Window_InteractionStore.shouldSortIncresing then
            EA_Window_InteractionStore.shouldSortIncresing = (not EA_Window_InteractionStore.shouldSortIncresing)
        else
            EA_Window_InteractionStore.ClearSortButton()
        end
        
    else
        EA_Window_InteractionStore.ClearSortButton()
        EA_Window_InteractionStore.sortColumnName = SystemData.ActiveWindow.name
        EA_Window_InteractionStore.sortColumnNum = WindowGetId( SystemData.ActiveWindow.name )
    end

    if EA_Window_InteractionStore.sortColumnNum > 0 then
        WindowSetShowing(EA_Window_InteractionStore.sortColumnName.."DownArrow", EA_Window_InteractionStore.shouldSortIncresing )
        WindowSetShowing(EA_Window_InteractionStore.sortColumnName.."UpArrow", (not EA_Window_InteractionStore.shouldSortIncresing) )
    end
    
    -- TODO: this causes the data to be re-retrieved unncessarily
    EA_Window_InteractionStore.ShowCurrentList()
end


function EA_Window_InteractionStore.RefreshAllSortButtons()
    --DEBUG(L"EA_Window_InteractionStore.RefreshAllSortButtons")

    for i, data in ipairs( EA_Window_InteractionStore.sortHeaderData ) do
        local buttonName = "EA_Window_InteractionStoreHeader"..data.column
        WindowSetShowing( buttonName.."DownArrow", false )
        WindowSetShowing( buttonName.."UpArrow", false )
    end
    
    if EA_Window_InteractionStore.sortColumnNum > 0 then
        WindowSetShowing(EA_Window_InteractionStore.sortColumnName.."DownArrow", EA_Window_InteractionStore.shouldSortIncresing )
        WindowSetShowing(EA_Window_InteractionStore.sortColumnName.."UpArrow", (not EA_Window_InteractionStore.shouldSortIncresing) )
    end
end
   
-- returns true if a sort column is set and false if not
function EA_Window_InteractionStore.Sort()
--DEBUG(L"EA_Window_InteractionStore.Sort")

    if EA_Window_InteractionStore.sortColumnNum >= 0 then
        local comparator = EA_Window_InteractionStore.sortHeaderData[EA_Window_InteractionStore.sortColumnNum].sortFunc
        table.sort( EA_Window_InteractionStore.displayData, comparator )
    end

end


-- keep the forward and backward order lists for clicking on sort headers
function EA_Window_InteractionStore.InitDataForSorting( filteredIndices )
    
    --DEBUG(L"EA_Window_InteractionStore.InitSortingForNewData #filteredIndices = "..#filteredIndices)
    EA_Window_InteractionStore.displayOrder = filteredIndices
    
    EA_Window_InteractionStore.reverseDisplayOrder = {}
    for i = #filteredIndices, 1, -1 do  
        table.insert( EA_Window_InteractionStore.reverseDisplayOrder, filteredIndices[i] )
    end
  
end


function EA_Window_InteractionStore.DisplaySortedData()
    if EA_Window_InteractionStore.shouldSortIncresing then
        ListBoxSetDisplayOrder( "EA_Window_InteractionStoreList", EA_Window_InteractionStore.displayOrder )
    else
        ListBoxSetDisplayOrder( "EA_Window_InteractionStoreList", EA_Window_InteractionStore.reverseDisplayOrder )
    end 
end


----------------------------------------------------------------
-- Filtering Functions
----------------------------------------------------------------


function EA_Window_InteractionStore.ResetStoreFilters()
    
    ButtonSetPressedFlag( "EA_Window_InteractionStoreFilterArmorButton", true )
    ButtonSetPressedFlag( "EA_Window_InteractionStoreFilterWeaponsButton", true )
    ButtonSetPressedFlag( "EA_Window_InteractionStoreFilterMiscButton", true )

    ComboBoxSetSelectedMenuItem( "EA_Window_InteractionStoreFilterSelectBox", EA_Window_InteractionStore.SORT_FILTER_ATTAINABLE )

end


function EA_Window_InteractionStore.ToggleStoreFilter()
    
    if ButtonGetDisabledFlag( SystemData.ActiveWindow.name.."Button" ) then
        return
    end
    
    if Cursor.IconOnCursor() then
        Cursor.Clear()
    end
    
    EA_LabelCheckButton.Toggle()
    EA_Window_InteractionStore.ShowCurrentList()
end


function EA_Window_InteractionStore.CreateFilteredList()

    local itemShowFilter = ComboBoxGetSelectedMenuItem( "EA_Window_InteractionStoreFilterSelectBox" )

    local shouldShowArmor = ButtonGetPressedFlag( "EA_Window_InteractionStoreFilterArmorButton" )
    local shouldShowWeapon = ButtonGetPressedFlag( "EA_Window_InteractionStoreFilterWeaponsButton" )
    local shouldShowMisc = ButtonGetPressedFlag( "EA_Window_InteractionStoreFilterMiscButton" )
    
    local displayOrder = {}
       
    --DEBUG(L"   EA_Window_InteractionStore.displayData = ")
    for index, itemData in ipairs(EA_Window_InteractionStore.displayData)
    do
            
        --DEBUG(L"      "..index..L" = "..itemData.name)
        if index > GameData.InteractStoreData.LastItemIndex then 
            DEBUG(L"EA_Window_InteractionStore.displayData has more entries than it's supposed to")
            continue
        end
       
        if ( itemShowFilter == EA_Window_InteractionStore.SORT_FILTER_APPLICABLE ) and
           ( not DataUtils.PlayerCanUseItem( itemData ) or
             not itemData.canbuy )
        then
            continue
        end

		if ( itemShowFilter == EA_Window_InteractionStore.SORT_FILTER_ATTAINABLE ) and
            ( not DataUtils.PlayerCanEventuallyUseItem( itemData ) )	
		then
		    continue
		end
		
        local show = true
        
        -- ASSUMPTION: I'm assuming all filters are mutually exclusive item category and 
        --             therefore we only have to check until one item category matches
        --
        if DataUtils.ItemIsArmor( itemData )
        then
            show = shouldShowArmor
        elseif DataUtils.ItemIsWeapon( itemData )
        then
            show = shouldShowWeapon
        else
            show = shouldShowMisc
        end
        
        if show
        then
            table.insert( displayOrder, index )
        end
        
    end

    return displayOrder
end


----------------------------------------------------------------
-- Show Store Functions
----------------------------------------------------------------

function EA_Window_InteractionStore.ShowStore()

    --DEBUG (L"EA_Window_InteractionStore.ShowStore");
    
    -- TODO: OPTIMIZATION: we really only need to be fetching canRepair flag, so should just make that it's own function or else do this check elsewhere 
    --      (we could move it to UpdateStore and UpdateBuyback if we send this flag in the GetBuyBackData() too )
    -- TODO: OPTIMIZATION: could use a dirty flag so they we don't repeatedly fetch same data
    -- TODO: OPTIMIZATION:  this is getting called for each of 6 or 8 pages of store data getting sent by server, when it really only needs to get called by the last one
    EA_Window_InteractionStore.storedata = GetStoreData()
    --EA_Window_InteractionStore.displayData = EA_Window_InteractionStore.storedata
    
    WindowSetShowing( "EA_Window_InteractionStore", true )
    
    if EA_Window_InteractionStore.storedata.canRepair then
        WindowSetShowing("EA_Window_InteractionStoreRepairAll", true)
        WindowSetShowing("EA_Window_InteractionStoreRepairToggle", true)
    else
        WindowSetShowing("EA_Window_InteractionStoreRepairAll", false)
        WindowSetShowing("EA_Window_InteractionStoreRepairToggle", false)
    end
	
    EA_Window_InteractionStore.UpdateCurrentList()
    
    EA_Window_InteractionStore.UpdateMoneyAvailable()
        
end



--[[ 
    Convenience function to see if a player is interacting with a store.
--]]
function EA_Window_InteractionStore.InteractingWithStore()

    return WindowGetShowing("EA_Window_InteractionStore")
end
    
function EA_Window_InteractionStore.PreProcessStoreData( dataTable )

    -- since sorting changes the order things are in the table, we save their original slotNum
    for index, itemData in ipairs(dataTable) do
        itemData.slotNum = index
        itemData.typeText = DataUtils.getItemTypeText( itemData )
    end

end

--[[
    This is a callback for custom list cell population.
--]]
function EA_Window_InteractionStore.PopulateStoreItemData ()

    for row, data in ipairs (EA_Window_InteractionStoreList.PopulatorIndices) do
        --DEBUG (L"Setting row: "..row..L", to GameData.InteractionStoreData["..data..L"].cost="..EA_Window_InteractionStore.displayData[data].cost);
        
        local itemName = EA_Window_InteractionStore.displayData[data].name
        itemName = itemName or L" "  -- sanity check, in case somehow the name is not set
        itemName = GetStringFormatFromTable( "InteractionStoreStrings",  StringTables.InteractionStore.STORE_LABEL_ITEM_NAME_WITH_COUNT, {itemName, L""..EA_Window_InteractionStore.displayData[data].stackCount} )
        LabelSetText( "EA_Window_InteractionStoreListRow"..row.."ItemName", itemName )

        local totalCost = EA_Window_InteractionStore.displayData[data].cost * EA_Window_InteractionStore.displayData[data].stackCount        
        local moneyFrame = "EA_Window_InteractionStoreListRow"..row.."ItemCost";
        local altCurrencyFrame = "EA_Window_InteractionStoreListRow"..row.."ItemAltCost";
        local lastAnchor

        WindowSetShowing( moneyFrame, (totalCost > 0) )
        if totalCost > 0 then
            lastAnchor = MoneyFrame.FormatMoney (moneyFrame, totalCost, MoneyFrame.HIDE_EMPTY_WINDOWS);
        end
        
        WindowSetShowing( altCurrencyFrame, (EA_Window_InteractionStore.displayData[data].altCurrency ~= nil) )
        if EA_Window_InteractionStore.displayData[data].altCurrency ~= nil
        then
        
            -- reset the altCurrencyFrame anchoring 
            WindowClearAnchors (altCurrencyFrame);
            if totalCost > 0 then
                WindowAddAnchor (altCurrencyFrame, "topright", lastAnchor, "topleft", 10, 0);
            else
                local anchorWindow = "EA_Window_InteractionStoreListRow"..row.."ItemPic";
                WindowAddAnchor (altCurrencyFrame, "bottomright", anchorWindow, "bottomleft", 5, 3);    
            end
            
            MoneyFrame.FormatAltCurrency (altCurrencyFrame, EA_Window_InteractionStore.displayData[data].altCurrency, MoneyFrame.HIDE_EMPTY_WINDOWS);
        end
        
        if (DataUtils.PlayerCanUseItem(EA_Window_InteractionStore.displayData[data])) and
            EA_Window_InteractionStore.displayData[data].canbuy
        then
            WindowSetTintColor("EA_Window_InteractionStoreListRow"..row.."ItemPic", 255, 255, 255);
        else
            local UnusableItemColor = EA_Window_InteractionStore.UNUSABLE_ITEM_COLOR
            WindowSetTintColor("EA_Window_InteractionStoreListRow"..row.."ItemPic", UnusableItemColor.r, UnusableItemColor.g, UnusableItemColor.b);
        end
    end        
end



function EA_Window_InteractionStore.ConfirmThenBuyItem( dataIdx, buyCount )

    buyCount = buyCount or 1
    if (dataIdx ~= 0)
    then
    
        local itemData = EA_Window_InteractionStore.displayData[dataIdx]
    
        local function doBuyItem()
            EA_Window_InteractionStore.CheckForAltCurrencyThenBuyItem( itemData, buyCount )
        end

        if( itemData.cost  <= Player.GetMoney() )
        then
            
            local warnOnBuy = SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_BUY];
            local canUseNow = DataUtils.PlayerCanUseItem( itemData )
			local canUseLater = DataUtils.PlayerCanEventuallyUseItem( itemData )
			
            if ( (warnOnBuy) and canUseNow )
			then
                local text = GetStringFormat(StringTables.Default.LABEL_CONFIRM_BUY_ITEM, { itemData.name })
                
                DialogManager.MakeTwoButtonDialog (text, 
                                                GetString (StringTables.Default.LABEL_YES), doBuyItem, 
                                                GetString (StringTables.Default.LABEL_NO), nil,
                                                nil, nil, not warnOnBuy,
                                                EA_Window_InteractionStore.NeverWarnAboutBuying)

			elseif ( not canUseNow )
			then
			    local text = L""
			    if ( canUseLater )
				then
				    text = GetStringFormat(StringTables.Default.LABEL_CONFIRM_BUY_USABLE_ITEM, { itemData.name })    
				elseif ( not canUseLater and not canUseNow )
				then
				    text = GetStringFormat(StringTables.Default.LABEL_CONFIRM_BUY_UNUSABLE_ITEM, { itemData.name })
				end
				
				DialogManager.MakeTwoButtonDialog( text, 
                                                GetString (StringTables.Default.LABEL_YES), doBuyItem, 
                                                GetString (StringTables.Default.LABEL_NO), nil)
	   
			else
                doBuyItem() 
            end        
            
        else
            -- Call BuyItem so the server-generated error shows in the chat window
            EA_Window_InteractionStore.BuyItem( itemData, buyCount )
            Sound.Play( Sound.NEGATIVE_FEEDBACK )
        end
    end
end

function EA_Window_InteractionStore.CheckForAltCurrencyThenBuyItem( itemData, buyCount )
    -- If the player is buying an item, and it takes exactly 1 alt currency with a quantity of 1, then show the alt currency window
    local validAltCurrenciesFound = 0
    local lastValidAltCurrencyData = nil
    if ( EA_Window_InteractionStore.displayData ~= EA_Window_InteractionStore.buyBackData )
    then
        if ( itemData.altCurrency ~= nil )
        then
            for _, altCurrencyData in ipairs(itemData.altCurrency)
            do
                if ( ( altCurrencyData.icon ~= 0 ) and ( altCurrencyData.quantity == 1 ) )
                then
                    validAltCurrenciesFound = validAltCurrenciesFound + 1
                    lastValidAltCurrencyData = altCurrencyData
                end
            end
        end
    end
    
    -- Only show the alt currency window if there's EXACTLY one alt currency to use
    if ( validAltCurrenciesFound == 1 )
    then
        local result = EA_Window_InteractionAltCurrency.Show( itemData, buyCount )
        if ( not result )
        then
            -- Call BuyItem so the server-generated error shows in the chat window
            EA_Window_InteractionStore.BuyItem( itemData, buyCount )
        end
    else
        -- Don't need to show alt currency window, go ahead and buy item
        EA_Window_InteractionStore.BuyItem( itemData, buyCount )
    end
end

function EA_Window_InteractionStore.BuyItem( itemData, buyCount )

    -- TODO: should really change this from Lua exposed variables and broadcast to a function call with parameters
    
    GameData.InteractStoreData.NumItems = buyCount
    GameData.InteractStoreData.CurrentItemIndex = itemData.slotNum
        
    if EA_Window_InteractionStore.displayData == EA_Window_InteractionStore.buyBackData then
        BroadcastEvent( SystemData.Events.INTERACT_BUY_BACK_ITEM )
    else
        BroadcastEvent( SystemData.Events.INTERACT_BUY_ITEM )
    end
end

function EA_Window_InteractionStore.NeverWarnAboutBuying()
    local curVal = SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_BUY]
    SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_BUY] = not curVal
    
    EA_Window_InteractionStore.UpdateDialogWarnings(SystemData.Settings.DlgWarning.WARN_BUY)
    
    BroadcastEvent( SystemData.Events.USER_SETTINGS_CHANGED )
end

function EA_Window_InteractionStore.SellItem( inventorySlot, sellCount )
    --DEBUG(L"EA_Window_InteractionStore.SellItem")
    -- NOTE: if sellCount not provided, then sell the entire stack of items in the inventory slot
    local backpackType = EA_BackpackUtilsMediator.GetCurrentBackpackType()
    local inventory = EA_BackpackUtilsMediator.GetItemsFromBackpack( backpackType )
    sellCount = sellCount or inventory[inventorySlot].stackCount
    
    -- TODO: should really change this from Lua exposed variables and broadcast to a function call with parameters
    GameData.InteractStoreData.CurrentItemIndex = inventorySlot
    GameData.InteractStoreData.NumItems = sellCount
    GameData.InteractStoreData.CurrentBackpackIndex = backpackType
    BroadcastEvent( SystemData.Events.INTERACT_SELL_ITEM )
    
    -- NOTE: Same deal as buy item...this needs a sound!
end

function EA_Window_InteractionStore.MouseOverStoreItem()

    local rowIdx = WindowGetId( WindowGetParent(SystemData.ActiveWindow.name) )
    
    if (rowIdx ~= 0) then
        local dataIdx = ListBoxGetDataIndex ("EA_Window_InteractionStoreList", rowIdx)
        if (EA_Window_InteractionStore.displayData == nil) then
            --DEBUG(L"displayData wasn't found")      
        elseif (dataIdx ~= 0) then
            Tooltips.CreateItemTooltip (EA_Window_InteractionStore.displayData[dataIdx], 
                                                    SystemData.ActiveWindow.name,
                                                    Tooltips.ANCHOR_WINDOW_RIGHT,
                                                    false);
        end
    end

end

function EA_Window_InteractionStore.UpdateCategoryList( selectedCategory )
    
    -- Block the handler to the category combo box for the moment since we may trigger it in this function
    EA_Window_InteractionStore.allowCategorySwitch = false
    
    EA_Window_InteractionStore.storeCategories = GetStoreCategories()
    if( next(EA_Window_InteractionStore.storeCategories) ~= nil )
    then        
        -- Clear the combo box before populating it in case it had data from a previous store interaction
        ComboBoxClearMenuItems( "EA_Window_InteractionStoreFilterCategoryBox" )
                
        local localCategoryId = 1;
        for index, catName in pairs( EA_Window_InteractionStore.storeCategories ) do
            EA_Window_InteractionStore.categoryIdMap[localCategoryId] = index
            ComboBoxAddMenuItem( "EA_Window_InteractionStoreFilterCategoryBox", catName )
            localCategoryId = localCategoryId + 1
        end
    
        ComboBoxSetDisabledFlag( "EA_Window_InteractionStoreFilterCategoryBox", false )        
        ComboBoxSetSelectedMenuItem( "EA_Window_InteractionStoreFilterCategoryBox", GetLocalCategoryIDFromServer(selectedCategory) )
    else
        -- We need to disable this combo box and add a single entry to let the player know there are no categories
        ComboBoxSetDisabledFlag( "EA_Window_InteractionStoreFilterCategoryBox", true )
        ComboBoxAddMenuItem( "EA_Window_InteractionStoreFilterCategoryBox", GetStringFromTable( "InteractionStoreStrings", StringTables.InteractionStore.STORE_CATEGORY_NONE ) )
        ComboBoxSetSelectedMenuItem( "EA_Window_InteractionStoreFilterCategoryBox", 1 )
    end
    
    -- Reallow category switching
    EA_Window_InteractionStore.allowCategorySwitch = true
    
end

function EA_Window_InteractionStore.SwitchCategories()

    if(EA_Window_InteractionStore.allowCategorySwitch)
    then
        local comboBoxSelIndex = ComboBoxGetSelectedMenuItem( "EA_Window_InteractionStoreFilterCategoryBox" )
        SwitchStoreCategories( GetServerCategoryIDFromLocal( comboBoxSelIndex ) )
    end
    
end


function EA_Window_InteractionStore.UpdateStoreList()

    -- TODO: OPTIMIZATION: could use a dirty flag so they we don't repeatedly fetch same data
    EA_Window_InteractionStore.storedata = GetStoreData()
    EA_Window_InteractionStore.PreProcessStoreData( EA_Window_InteractionStore.storedata )
    
    -- Update the category list with data that has just arrived    
    if( EA_Window_InteractionStore.storedata ~= nil )
    then
        EA_Window_InteractionStore.UpdateCategoryList(EA_Window_InteractionStore.storedata.selectedCategory)
    end

    EA_Window_InteractionStore.ShowStoreList()
end

function EA_Window_InteractionStore.ShowStoreList()
    
    EA_Window_InteractionStore.displayData = EA_Window_InteractionStore.storedata
    
    -- sort all data before filtering
    EA_Window_InteractionStore.Sort()
    
    local filteredDataIndices = EA_Window_InteractionStore.CreateFilteredList()
    
    EA_Window_InteractionStore.InitDataForSorting( filteredDataIndices )
    EA_Window_InteractionStore.DisplaySortedData()
    
end



function EA_Window_InteractionStore.UpdateBuyBackList()

    -- TODO: OPTIMIZATION: could use a dirty flag so they we don't repeatedly fetch same data
    
    EA_Window_InteractionStore.buyBackData = GetBuyBackData()
    EA_Window_InteractionStore.PreProcessStoreData( EA_Window_InteractionStore.buyBackData )
    
    EA_Window_InteractionStore.ShowBuyBackList()
end  

function EA_Window_InteractionStore.ShowBuyBackList()

    EA_Window_InteractionStore.displayData = EA_Window_InteractionStore.buyBackData
    
    -- I'm not sure if we really want to Sort buy back data either so leave it off fow now
    EA_Window_InteractionStore.Sort()
       
    -- no reason to fiter out buyBack items I don't think so we'll just created a list of all indices
    --local displayOrder = EA_Window_InteractionStore.CreateFilteredList()
    local displayOrder = {}
    for index, itemData in ipairs(EA_Window_InteractionStore.displayData) do
        table.insert( displayOrder, index )
    end
    
    EA_Window_InteractionStore.InitDataForSorting( displayOrder )
    EA_Window_InteractionStore.DisplaySortedData()
end


function EA_Window_InteractionStore.UpdateMoneyAvailable()
    if WindowGetShowing( "EA_Window_InteractionStore" ) then
        MoneyFrame.FormatMoney( "EA_Window_InteractionStoreMoneyAvailable", Player.GetMoney(), MoneyFrame.HIDE_EMPTY_WINDOWS)  --MoneyFrame.SHOW_EMPTY_WINDOWS )
        EA_Window_InteractionStore.updateButtonsAndTooltips()
    end
end


function EA_Window_InteractionStore.OnTabSelected()
--DEBUG(L"EA_Window_InteractionStore.OnTabSelected")

    if Cursor.IconOnCursor() then
        Cursor.Clear()
    end
    
    local tabNum = WindowGetId( SystemData.ActiveWindow.name )
    
    if tabNum ~= EA_Window_InteractionStore.currentlyDisplayedTabID then
        
        if EA_Window_InteractionStore.SetCurrentTab( tabNum ) then
        
            EA_Window_InteractionStore.UpdateCurrentList()
        end
    end
    
end

function EA_Window_InteractionStore.SetCurrentTab( tabNum )
    --DEBUG(L"EA_Window_InteractionStore.SetCurrentTab  tabNum="..tabNum)

    if tabNum < 1 or tabNum > #EA_Window_InteractionStore.tabs then
        return false
    end
    
    for id, tabName in ipairs( EA_Window_InteractionStore.tabs ) do
        ButtonSetPressedFlag( tabName, id == tabNum )
        ButtonSetStayDownFlag( tabName, id == tabNum )
    end
    
    EA_Window_InteractionStore.currentlyDisplayedTabID = tabNum
    
    EA_Window_InteractionStore.updateFilterButtons( tabNum == EA_Window_InteractionStore.STORE_TAB_ID )
    EA_Window_InteractionStore.toggleSortButtons()

    return true
end

function EA_Window_InteractionStore.UpdateCurrentList()

    if EA_Window_InteractionStore.currentlyDisplayedTabID == EA_Window_InteractionStore.STORE_TAB_ID then
        EA_Window_InteractionStore.UpdateStoreList()
        
    elseif EA_Window_InteractionStore.currentlyDisplayedTabID == EA_Window_InteractionStore.BUY_BACK_TAB_ID then
        EA_Window_InteractionStore.UpdateBuyBackList()
    end

end

function EA_Window_InteractionStore.ShowCurrentList()

    if EA_Window_InteractionStore.currentlyDisplayedTabID == EA_Window_InteractionStore.STORE_TAB_ID then
        EA_Window_InteractionStore.ShowStoreList()
        
    elseif EA_Window_InteractionStore.currentlyDisplayedTabID == EA_Window_InteractionStore.BUY_BACK_TAB_ID then
        EA_Window_InteractionStore.ShowBuyBackList()
    end

end
--------------------------------------------------------------------
-- Broken Items Repair Man
--------------------------------------------------------------------


--[[ 
    Convenience function to see if a player is interacting with a repair man.
--]]
function EA_Window_InteractionStore.InteractingWithRepairMan()

    return ( EA_Window_InteractionStore.repairModeOn and WindowGetShowing("EA_Window_InteractionStoreRepairToggle") )
end


function EA_Window_InteractionStore.ToggleRepairMode()
--DEBUG(L"EA_Window_InteractionStore.ToggleRepairMode")

    if Cursor.IconOnCursor() then
        Cursor.Clear()
    end
    
    if ButtonGetDisabledFlag( "EA_Window_InteractionStoreRepairToggle") then
        return
    end
    
    if EA_Window_InteractionStore.repairModeOn then
        EA_Window_InteractionStore.RepairingOff()
    else
        EA_Window_InteractionStore.RepairingOn()
    end 
    EA_Window_InteractionStore.RepairButtonMouseOver()
end


function EA_Window_InteractionStore.RepairButtonMouseOver()
--DEBUG(L"EA_Window_InteractionStore.RepairButtonMouseOver")

    local text 
    if ButtonGetDisabledFlag( "EA_Window_InteractionStoreRepairToggle") then
        text = EA_Window_InteractionStore.repairToggleTooltip
    elseif EA_Window_InteractionStore.repairModeOn == false then
        text = GetStringFromTable( "InteractionStoreStrings",  StringTables.InteractionStore.STORE_REPAIR_MODE_ON_MOUSEOVER )
        
    else
        text = GetStringFromTable( "InteractionStoreStrings",  StringTables.InteractionStore.STORE_REPAIR_MODE_OFF_MOUSEOVER )
    end
    

    Tooltips.CreateTextOnlyTooltip (SystemData.ActiveWindow.name, text )
    Tooltips.AnchorTooltip (Tooltips.ANCHOR_WINDOW_TOP)
end


function EA_Window_InteractionStore.RepairAllButtonMouseOver()
--DEBUG(L"EA_Window_InteractionStore.RepairAllButtonMouseOver")

    Tooltips.CreateTextOnlyTooltip (SystemData.ActiveWindow.name, EA_Window_InteractionStore.repairAllTooltip )
    if not EA_Window_InteractionStore.sufficientFundsToRepairAll then
    
        local errorMsg = GetStringFromTable( "InteractionStoreStrings",  StringTables.InteractionStore.STORE_INSUFFICIENT_MONEY_MOUSEOVER )
        Tooltips.SetTooltipText (2, 1, errorMsg)
        Tooltips.SetTooltipColorDef (2, 1, Tooltips.COLOR_FAILS_REQUIREMENTS)
        Tooltips.Finalize ()
    end
    Tooltips.AnchorTooltip (Tooltips.ANCHOR_WINDOW_TOP)
end


function EA_Window_InteractionStore.RepairingOn()

    EA_Window_InteractionStore.repairModeOn = true
    
    EA_Window_InteractionStore.currentRepairCursor = nil
    EA_Window_InteractionStore.OnMouseOverRepairableItemEnd()
    
end

function EA_Window_InteractionStore.OnMouseOverRepairableItem()

    if( EA_Window_InteractionStore.repairModeOn == true and 
        EA_Window_InteractionStore.currentRepairCursor ~= SystemData.InteractActions.REPAIR
      ) then
      
        SetDesiredInteractAction( SystemData.InteractActions.REPAIR )
        EA_Window_InteractionStore.currentRepairCursor = SystemData.InteractActions.REPAIR
    end
end


function EA_Window_InteractionStore.OnMouseOverRepairableItemEnd()

    if( EA_Window_InteractionStore.repairModeOn == true and 
        EA_Window_InteractionStore.currentRepairCursor ~= SystemData.InteractActions.REPAIR_DISABLED
      ) then
        
        SetDesiredInteractAction( SystemData.InteractActions.REPAIR_DISABLED )
        EA_Window_InteractionStore.currentRepairCursor = SystemData.InteractActions.REPAIR_DISABLED
    end
end

function EA_Window_InteractionStore.RepairingOff()

    EA_Window_InteractionStore.repairModeOn = false
    EA_Window_InteractionStore.currentRepairCursor = nil
    if( GetDesiredInteractAction() == SystemData.InteractActions.REPAIR or
        GetDesiredInteractAction() == SystemData.InteractActions.REPAIR_DISABLED ) then
        
        SetDesiredInteractAction( SystemData.InteractActions.NONE )
    end
    
    --ClearCursor()
end



function EA_Window_InteractionStore.RepairItem(inventorySlot)
--DEBUG(L"EA_Window_InteractionStore.RepairItem, inventorySlot="..inventorySlot)
    local backpackType = EA_BackpackUtilsMediator.GetCurrentBackpackType()

    -- TODO: should really change this from Lua exposed variables and broadcast to a function call with parameters
    GameData.InteractStoreData.NumItems         = 1
    GameData.InteractStoreData.CurrentItemIndex = inventorySlot
    GameData.InteractStoreData.CurrentBackpackIndex = backpackType
    
    BroadcastEvent (SystemData.Events.INTERACT_REPAIR)
    
    -- NOTE: Same deal as sell item...this needs a sound!
    
end



-- cause repair interaction for all repairable items in backpack
function EA_Window_InteractionStore.RepairAll()
--DEBUG(L"EA_Window_InteractionStore.RepairAll")

    if Cursor.IconOnCursor() then
        Cursor.Clear()
    end
    
    if ButtonGetDisabledFlag( "EA_Window_InteractionStoreRepairAll") then
        return
    end
    
    if EA_Window_InteractionStore.repairModeOn then
        EA_Window_InteractionStore.RepairingOff()
    end 
    
    EA_Window_InteractionStore.pendingRepairSlots = EA_Window_InteractionStore.GetRepairableItems()
    
    EA_Window_InteractionStore.ShowNextQueuedRepairConfirm()
end



-- returns 2 tables and an int:
--    table of indices into the backpack of broken items repairable by your career
--    table of indices into the backpack of broken items *not* repairable by your career
--    the price of repairing all repairable items
--
function EA_Window_InteractionStore.GetRepairableItems()
--DEBUG(L"EA_Window_InteractionStore.GetRepairableItems")

    local backpackType = EA_BackpackUtilsMediator.GetCurrentBackpackType()
    local inventory = EA_BackpackUtilsMediator.GetItemsFromBackpack( backpackType )
    if inventory == nil then
        return
    end
    
    repairableItems = {}
    brokenButNotRepairableItems = {}
    totalRepairPrice = 0
    
    for i, itemData in pairs(inventory) do
        if itemData.broken then
            local repairableItemAvailable = (itemData.repairedName ~= nil and itemData.repairedName ~= L"")
            --local repairableItemAvailable = itemData.repairPrice > 0
            if repairableItemAvailable then
                table.insert( repairableItems, i )
                totalRepairPrice = totalRepairPrice + itemData.repairPrice 
            else
                table.insert( brokenButNotRepairableItems, i )
            end
        end
    end
    
    return repairableItems, brokenButNotRepairableItems, totalRepairPrice
end

function EA_Window_InteractionStore.toggleSortButtons()
    --DEBUG(L"EA_Window_InteractionStore.toggleSortButtons")

    local tempSortColumnNum = EA_Window_InteractionStore.sortColumnNum
    local tempSortColumnName = EA_Window_InteractionStore.sortColumnName
    local tempShouldSortIncresing = EA_Window_InteractionStore.shouldSortIncresing
    
    EA_Window_InteractionStore.sortColumnNum = EA_Window_InteractionStore.previousSortColumnNum
    EA_Window_InteractionStore.sortColumnName = EA_Window_InteractionStore.previousSortColumnName
    EA_Window_InteractionStore.shouldSortIncresing = EA_Window_InteractionStore.previousShouldSortIncresing
    
    EA_Window_InteractionStore.previousSortColumnNum = tempSortColumnNum
    EA_Window_InteractionStore.previousSortColumnName = tempSortColumnName
    EA_Window_InteractionStore.previousShouldSortIncresing = tempShouldSortIncresing   
    
    EA_Window_InteractionStore.RefreshAllSortButtons()
end

function EA_Window_InteractionStore.updateFilterButtons( isFilterable )
    
    local color
    if isFilterable then 
        color = EA_Window_InteractionStore.ENABLED_FILTER_COLOR
    else
        color = EA_Window_InteractionStore.DISABLED_FILTER_COLOR
    end
    
    ComboBoxSetDisabledFlag( "EA_Window_InteractionStoreFilterSelectBox", not isFilterable )

    ButtonSetDisabledFlag( "EA_Window_InteractionStoreFilterArmorButton", not isFilterable )
    ButtonSetDisabledFlag( "EA_Window_InteractionStoreFilterWeaponsButton", not isFilterable )
    ButtonSetDisabledFlag( "EA_Window_InteractionStoreFilterMiscButton", not isFilterable )
    
    LabelSetTextColor( "EA_Window_InteractionStoreFilterSelectBoxLabel", color.r, color.g, color.b )
    LabelSetTextColor( "EA_Window_InteractionStoreFilterCategoryBoxLabel", color.r, color.g, color.b )
    LabelSetTextColor( "EA_Window_InteractionStoreFilterArmorLabel", color.r, color.g, color.b )
    LabelSetTextColor( "EA_Window_InteractionStoreFilterWeaponsLabel", color.r, color.g, color.b )
    LabelSetTextColor( "EA_Window_InteractionStoreFilterMiscLabel", color.r, color.g, color.b )
    
    --[[
    WindowSetShowing( "EA_Window_InteractionStoreFilterByUsable", isFilterable )
    WindowSetShowing( "EA_Window_InteractionStoreFilterArmor", isFilterable )
    WindowSetShowing( "EA_Window_InteractionStoreFilterWeapons", isFilterable )
    WindowSetShowing( "EA_Window_InteractionStoreFilterMisc", isFilterable )
    --]]
end

function EA_Window_InteractionStore.updateButtonsAndTooltips()
--DEBUG(L"EA_Window_InteractionStore.updateButtonsAndTooltips")

    local repairableItems, brokenButNotRepairableItems, totalRepairPrice = EA_Window_InteractionStore.GetRepairableItems()
    local numRepairable = #repairableItems 
    local numBrokenButNotRepairable = #brokenButNotRepairableItems 
    local someRepairables = numRepairable > 0
    EA_Window_InteractionStore.sufficientFundsToRepairAll = ( Player.GetMoney() >= totalRepairPrice )

    local repairPriceString = L""
    if totalRepairPrice > 0 then
        repairPriceString = MoneyFrame.FormatMoneyString( totalRepairPrice )
    end
    
    if EA_Window_InteractionStore.storedata.canRepair then
        ButtonSetDisabledFlag( "EA_Window_InteractionStoreRepairToggle", not someRepairables )
        ButtonSetDisabledFlag( "EA_Window_InteractionStoreRepairAll", (not someRepairables or not EA_Window_InteractionStore.sufficientFundsToRepairAll) )
    end
    
    if not someRepairables and EA_Window_InteractionStore.repairModeOn then
        EA_Window_InteractionStore.RepairingOff()
    end
    
    EA_Window_InteractionStore.repairToggleTooltip = 
            GetFormatStringFromTable( "InteractionStoreStrings", StringTables.InteractionStore.STORE_REPAIR_MODE_DISABLED_MOUSEOVER, 
                                      { numBrokenButNotRepairable } ) 
                            
    EA_Window_InteractionStore.repairAllTooltip = 
                GetFormatStringFromTable( "InteractionStoreStrings", StringTables.InteractionStore.STORE_REPAIR_ALL_BUTTON_MOUSEOVER, 
                                          { numRepairable , numBrokenButNotRepairable, totalRepairPrice, repairPriceString } ) 
    
    
    
    if SystemData.MouseOverWindow.name == "EA_Window_InteractionStoreRepairToggle" then
        Tooltips.ClearTooltip()
        EA_Window_InteractionStore.RepairButtonMouseOver()
        
    elseif SystemData.MouseOverWindow.name == "EA_Window_InteractionStoreRepairAll" then
        Tooltips.ClearTooltip()
        EA_Window_InteractionStore.RepairAllButtonMouseOver()
    end
    
end



------------------------
-- Repair Item Confirmations 
------------------------

function EA_Window_InteractionStore.toggleWarnBeforeRepairing()

    local curVal = SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_REPAIR]
    SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_REPAIR] = not curVal
    
    EA_Window_InteractionStore.UpdateDialogWarnings(SystemData.Settings.DlgWarning.WARN_REPAIR)

    BroadcastEvent (SystemData.Events.USER_SETTINGS_CHANGED)
end

-- TODO: this should be kept in C++ settings file and be able to turn back on through User Settings Window
function EA_Window_InteractionStore.shouldWarnBeforeRepairing()

    return SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_REPAIR]
end


function EA_Window_InteractionStore.RepairPendingItem()
        
    if #EA_Window_InteractionStore.pendingRepairSlots > 0 then
        local pendingRepairSlot = table.remove( EA_Window_InteractionStore.pendingRepairSlots, 1 )
        EA_Window_InteractionStore.RepairItem( pendingRepairSlot )
        EA_Window_InteractionStore.ShowNextQueuedRepairConfirm()
    end
end

function EA_Window_InteractionStore.RemoveRepairPendingItem()
        
    if #EA_Window_InteractionStore.pendingRepairSlots > 0 then
        table.remove( EA_Window_InteractionStore.pendingRepairSlots, 1 )
        EA_Window_InteractionStore.ShowNextQueuedRepairConfirm()
    end
end

function EA_Window_InteractionStore.ConfirmThenRepairItem( inventorySlot )

    local backpackType = EA_BackpackUtilsMediator.GetCurrentBackpackType()
    local inventory = EA_BackpackUtilsMediator.GetItemsFromBackpack( backpackType )
    local itemData = inventory[inventorySlot]
    if( itemData ~=nil and itemData.repairPrice ~= nil and itemData.repairPrice  > Player.GetMoney() ) then
    
        EA_Window_InteractionStore.RepairItem( inventorySlot )
        Sound.Play( Sound.NEGATIVE_FEEDBACK )
        return
    end
    
    local warnOnRepair = EA_Window_InteractionStore.shouldWarnBeforeRepairing()
    if (warnOnRepair) then
        
        table.insert( EA_Window_InteractionStore.pendingRepairSlots, inventorySlot )
        EA_Window_InteractionStore.ShowRepairConfirm(inventorySlot, warnOnRepair )
        
    else
        EA_Window_InteractionStore.RepairItem( inventorySlot )
    end
end

-- NOTE: we may want to change this to a 3 button dialog that let's us abort the entire Repair All pending list
function EA_Window_InteractionStore.ShowRepairConfirm( inventorySlot, displayNeverWarnCheckBox )

    local backpackType = EA_BackpackUtilsMediator.GetCurrentBackpackType()
    local inventory = EA_BackpackUtilsMediator.GetItemsFromBackpack( backpackType )
    local itemData = inventory[inventorySlot]
    
    -- verify the repairable item is still in that slot
    if itemData == nil or itemData.broken == false or itemData.repairPrice <= 0 then
        EA_Window_InteractionStore.RemoveRepairPendingItem()
    end
    
    local neverWarnCallback = nil
    if displayNeverWarnCheckBox then
        neverWarnCallback = EA_Window_InteractionStore.toggleWarnBeforeRepairing
    end
    
    local price = MoneyFrame.FormatMoneyString (itemData.repairPrice) 
    local text = GetStringFormat (StringTables.Default.LABEL_CONFIRM_REPAIR_ITEM, { itemData.name, price })
    DialogManager.MakeTwoButtonDialog (text, 
                                        GetString (StringTables.Default.LABEL_YES), EA_Window_InteractionStore.RepairPendingItem, 
                                        GetString (StringTables.Default.LABEL_NO), EA_Window_InteractionStore.RemoveRepairPendingItem,
                                        nil, nil, false, neverWarnCallback )
    
end

-- for some reason DialogManager.MakeTwoButtonDialog can't queue up more data than it has windows,
--   (even though it will only display each window one at a time), so I'm queueing it here.
--
function EA_Window_InteractionStore.ShowNextQueuedRepairConfirm()

    if #EA_Window_InteractionStore.pendingRepairSlots > 0 then
        local inventorySlot = EA_Window_InteractionStore.pendingRepairSlots[1]
        EA_Window_InteractionStore.ShowRepairConfirm( inventorySlot, false )		-- false == can't turn off confirmation
    end

end

----------------------------
-- Sell Item Confirmations 
----------------------------

function EA_Window_InteractionStore.toggleWarnBeforeSelling()

    local curVal = SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_SELL]
    SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_SELL] = not curVal
    
    EA_Window_InteractionStore.UpdateDialogWarnings(SystemData.Settings.DlgWarning.WARN_SELL)

    BroadcastEvent (SystemData.Events.USER_SETTINGS_CHANGED)
end

function EA_Window_InteractionStore.shouldWarnBeforeSelling()

    return SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_SELL]
end


function EA_Window_InteractionStore.SellPendingItem()  
    --DEBUG(L"EA_Window_InteractionStore.SellPendingItem")
        
    if #EA_Window_InteractionStore.pendingSellSlots > 0 then
        local pendingSellSlot = table.remove( EA_Window_InteractionStore.pendingSellSlots, 1 )
        local pendingSellCount = table.remove( EA_Window_InteractionStore.pendingSellCounts, 1 )
        
        EA_Window_InteractionStore.SellItem( pendingSellSlot, pendingSellCount )
        --EA_Window_InteractionStore.ShowNextQueuedSellConfirm()
    end
end

function EA_Window_InteractionStore.RemoveSellPendingItem()
    --DEBUG(L"EA_Window_InteractionStore.RemoveSellPendingItem")
        
    if #EA_Window_InteractionStore.pendingSellSlots > 0 then
        table.remove( EA_Window_InteractionStore.pendingSellSlots, 1 )
        table.remove( EA_Window_InteractionStore.pendingSellCounts, 1 )
        --EA_Window_InteractionStore.ShowNextQueuedSellConfirm()
    end
end



function EA_Window_InteractionStore.ConfirmThenSellItem( inventorySlot, sellCount )
    --DEBUG(L"EA_Window_InteractionStore.ConfirmThenSellItem")

    local warnOnSell = EA_Window_InteractionStore.shouldWarnBeforeSelling()

    if (warnOnSell) then
        EA_Window_InteractionStore.ShowSellConfirm(inventorySlot, warnOnSell )
        
    else
        EA_Window_InteractionStore.SellItem( inventorySlot, sellCount )
    end
end

function EA_Window_InteractionStore.ShowSellConfirm( inventorySlot, displayNeverWarnCheckBox, sellCount )

    -- NOTE: if sellCount not provided, then sell the entire stack of items in the inventory slot
    local backpackType = EA_BackpackUtilsMediator.GetCurrentBackpackType()
    local inventory = EA_BackpackUtilsMediator.GetItemsFromBackpack( backpackType )
    local itemData = inventory[inventorySlot]
    sellCount = sellCount or itemData.stackCount
    
    local neverWarnCallback = nil
    if displayNeverWarnCheckBox then
        neverWarnCallback = EA_Window_InteractionStore.toggleWarnBeforeSelling
    end
    
    table.insert( EA_Window_InteractionStore.pendingSellSlots, inventorySlot )
    table.insert( EA_Window_InteractionStore.pendingSellCounts, sellCount )
    
    local text = GetStringFormat (StringTables.Default.LABEL_CONFIRM_SELL_ITEM, { itemData.name } )
    DialogManager.MakeTwoButtonDialog ( text, 
                                        GetString (StringTables.Default.LABEL_YES), EA_Window_InteractionStore.SellPendingItem, 
                                        GetString (StringTables.Default.LABEL_NO), EA_Window_InteractionStore.RemoveSellPendingItem,
                                        nil, nil, false, neverWarnCallback )
    
end

-- pretty much the same as checking Cursor.IconOnCursor(), but verifies it wasn't an item picked up from the merchant window
function EA_Window_InteractionStore.CursorIsCarryingItem()
    if Cursor.IconOnCursor() and  Cursor.Data.Source ~= Cursor.SOURCE_MERCHANT then
        return true
    else
        return false
    end
    
end

-- right now this only will sell things from the backpack window. Any backpack items that are not sellable are checked from the server. 
function EA_Window_InteractionStore.IsCarryingSellableItem()
    local backpackType = EA_BackpackUtilsMediator.GetCurrentBackpackType()
    local currentCursor = EA_BackpackUtilsMediator.GetCursorForBackpack( backpackType )
    if Cursor.IconOnCursor() and  Cursor.Data.Source == currentCursor then
        return true
    else
        return false
    end
end

function EA_Window_InteractionStore.CursorIsCarryingMerchantItem()
    
    if Cursor.IconOnCursor() and  Cursor.Data.Source == Cursor.SOURCE_MERCHANT then
        return true
    else
        return false
    end
end

function EA_Window_InteractionStore.SellItemOnCursor()
    if EA_Window_InteractionStore.IsCarryingSellableItem() then
        EA_Window_InteractionStore.ConfirmThenSellItem( Cursor.Data.SourceSlot, Cursor.Data.StackAmount )
        Cursor.Clear()
    else
        -- TODO: provide some kind of error message
        --local text = GetString (StringTables.Default.)
        --EA_ChatWindow.Print (text, SystemData.ChatLogFilters.SAY)  
    end
end


function EA_Window_InteractionStore.OnItemLButtonUp( flags )

    -- this check will ignore icons picked up from the merchant window
    if EA_Window_InteractionStore.CursorIsCarryingItem() then
        EA_Window_InteractionStore.SellItemOnCursor()
        return
    end
    
end

function EA_Window_InteractionStore.OnItemLButtonDown( flags )

    if EA_Window_InteractionStore.CursorIsCarryingItem() 
    then
        EA_Window_InteractionStore.SellItemOnCursor()
        return
    end
    
    local rowIdx = WindowGetId(SystemData.MouseOverWindow.name)
    if (rowIdx == 0) 
    then
        return
    end
    
    local dataIdx = ListBoxGetDataIndex ("EA_Window_InteractionStoreList", rowIdx)
    local itemData = EA_Window_InteractionStore.displayData[dataIdx]
    
    -- Create Chat HyperLinks on Shift-Left-Button-Down
    if( flags == SystemData.ButtonFlags.SHIFT )
    then
        EA_ChatWindow.InsertItemLink( itemData )
    else
        Cursor.PickUp( Cursor.SOURCE_MERCHANT, dataIdx, itemData.uniqueID, itemData.iconNum, true, itemData.stackCount )
    end
    
end



function EA_Window_InteractionStore.OnItemRButtonUp( flags, x, y )

    if Cursor.IconOnCursor() 
    then
        Cursor.Clear()
        return
    end
    
    local rowIdx = WindowGetId(SystemData.MouseOverWindow.name)
    
    if (rowIdx == 0) 
    then
        -- Window id was 0, first row always has id = 1
        return
    end      
        
    -- Map the row index to an actual item index (takes the filtering/sorting of the list into account)
    local dataIdx = ListBoxGetDataIndex ("EA_Window_InteractionStoreList", rowIdx)
    
    -- On Shift-R-Button Down, Open the Stack Window
    if( flags == SystemData.ButtonFlags.SHIFT )
    then
        local titleBarText = GetStringFromTable( "InteractionStoreStrings", StringTables.InteractionStore.STORE_BUY_STACK_TITLE )
        ItemStackingWindow.Show( Cursor.SOURCE_MERCHANT, dataIdx, titleBarText )
    else
    
        -- Otherwise buy the item     
        local buyCount = EA_Window_InteractionStore.displayData[dataIdx].stackCount
        EA_Window_InteractionStore.ConfirmThenBuyItem( dataIdx, buyCount )
    end
    
end

function EA_Window_InteractionStore.GetItem( dataIdx )
    return EA_Window_InteractionStore.displayData[dataIdx]
end


-- Handle dialog warning change 
function EA_Window_InteractionStore.UpdateDialogWarnings(whichWarning)
    if WindowGetShowing( "SettingsWindowTabbed") == true 
    then
        SettingsWindowTabGeneral.UpdateDialogWarnings(whichWarning)
    end
end
