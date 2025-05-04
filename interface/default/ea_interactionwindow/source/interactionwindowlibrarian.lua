
----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_InteractionLibrarianStore = 
{
    versionNumber = 0.01,
    librarianStoredata = {},
    
    currentlyDisplayedTabID = 0,
    UNUSABLE_ITEM_COLOR = { r=200, g=0, b=0 },
    
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

 
-- point EA_Window_InteractionLibrarianStore.displayData to librarianStoredata so hopefully 
--   we can optimize by not re-fetching that data from C++ over and over
--
EA_Window_InteractionLibrarianStore.displayData = EA_Window_InteractionLibrarianStore.librarianStoredata

EA_Window_InteractionLibrarianStore.MAX_VISIBLE_ROWS = 5

EA_Window_InteractionLibrarianStore.STORE_TAB_ID = 1
EA_Window_InteractionLibrarianStore.BUY_BACK_TAB_ID = 2

EA_Window_InteractionLibrarianStore.tabs =
{
    [EA_Window_InteractionLibrarianStore.STORE_TAB_ID ]		= "EA_Window_InteractionLibrarianStoreTabsSellTab",
}

-----------------------
-- Sorting Data  --

-- Header Strings
EA_Window_InteractionLibrarianStore.itemNameHeader   = GetStringFromTable( "InteractionStoreStrings", StringTables.InteractionStore.STORE_SORT_BY_HEADER_NAME )
EA_Window_InteractionLibrarianStore.typeHeader       = GetStringFromTable( "InteractionStoreStrings", StringTables.InteractionStore.STORE_SORT_BY_HEADER_TYPE )

-- Header comparator functions

local function originalOrderComparator( a, b )	return ( a.slotNum < b.slotNum )  end
local function nameComparator( a, b )			return( WStringsCompare( a.name, b.name ) == -1 )  end
local function typeComparator( a, b )			return( WStringsCompare( a.typeText, b.typeText ) == -1 )  end 

EA_Window_InteractionLibrarianStore.sortHeaderData =
{
    [0] = { sortFunc=originalOrderComparator, },
    { column = "Name",          text=EA_Window_InteractionLibrarianStore.itemNameHeader,     sortFunc=nameComparator,     },
    { column = "Type",          text=EA_Window_InteractionLibrarianStore.typeHeader,         sortFunc=typeComparator,     },
}


----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

----------------------------------------------------------------
-- EA_Window_InteractionLibrarianStore Functions
----------------------------------------------------------------

-- OnInitialize Handler
function EA_Window_InteractionLibrarianStore.Initialize()
    -- DEBUG(L"EA_Window_InteractionLibrarianStore.Initialize")
   
    local red, green, blue = LabelGetTextColor( "EA_Window_InteractionLibrarianStoreFilterByUsableLabel" )
    EA_Window_InteractionLibrarianStore.ENABLED_FILTER_COLOR = {r=red,g=green,b=blue}
    EA_Window_InteractionLibrarianStore.DISABLED_FILTER_COLOR = {r=128,g=128,b=128}

    WindowRegisterEventHandler( "EA_Window_InteractionLibrarianStore", SystemData.Events.INTERACT_SHOW_LIBRARIAN, "EA_Window_InteractionLibrarianStore.ShowLibrarianStore")
    WindowRegisterEventHandler( "EA_Window_InteractionLibrarianStore", SystemData.Events.INTERACT_UPDATE_LIBRARIAN, "EA_Window_InteractionLibrarianStore.UpdateLibrarianStoreList")
    WindowRegisterEventHandler( "EA_Window_InteractionLibrarianStore", SystemData.Events.PLAYER_MONEY_UPDATED, "EA_Window_InteractionLibrarianStore.UpdateMoneyAvailable" )
    WindowRegisterEventHandler( "EA_Window_InteractionLibrarianStore", SystemData.Events.INTERACT_DONE, "EA_Window_InteractionLibrarianStore.Done")
    
    LabelSetText("EA_Window_InteractionLibrarianStoreTitleBarText", GetStringFromTable( "InteractionStoreStrings", StringTables.InteractionStore.STORE_TITLE ) )

    LabelSetText("EA_Window_InteractionLibrarianStoreMoneyAvailableHeader", GetStringFromTable( "InteractionStoreStrings", StringTables.InteractionStore.STORE_MONEY_LABEL ) )

    -- tab names
    ButtonSetText("EA_Window_InteractionLibrarianStoreTabsSellTab", GetStringFromTable( "InteractionStoreStrings", StringTables.InteractionStore.STORE_REWARDS_TAB_LABEL ) ) 
    ButtonSetPressedFlag( "EA_Window_InteractionLibrarianStoreTabsSellTab", true )
    ButtonSetStayDownFlag( "EA_Window_InteractionLibrarianStoreTabsSellTab", true )
    
    -- LibrarianStore Filters
    LabelSetText("EA_Window_InteractionLibrarianStoreFilterByUsableLabel", GetStringFromTable( "InteractionStoreStrings", StringTables.InteractionStore.STORE_USABLE_ONLY_LABEL ) )

     -- Sorting Buttons
    for i, data in ipairs( EA_Window_InteractionLibrarianStore.sortHeaderData ) do
        local buttonName = "EA_Window_InteractionLibrarianStoreHeader"..data.column
        ButtonSetText( buttonName, data.text )
        WindowSetShowing( buttonName.."DownArrow", false )
        WindowSetShowing( buttonName.."UpArrow", false )
    end
        
     -- Buttons
    ButtonSetText("EA_Window_InteractionLibrarianStoreDone", GetString( StringTables.Default.LABEL_DONE ))
    ButtonSetText("EA_Window_InteractionLibrarianStoreRepairAll", GetStringFromTable( "InteractionStoreStrings", StringTables.InteractionStore.STORE_REPAIR_ALL_BUTTON_LABEL ) )
    ButtonSetText("EA_Window_InteractionLibrarianStoreRepairToggle", GetStringFromTable( "InteractionStoreStrings", StringTables.InteractionStore.STORE_REPAIR_TOGGLE_BUTTON_LABEL ) )
   
    EA_Window_InteractionLibrarianStore.ResetLibrarianStoreFilters()

    DataUtils.SetListRowAlternatingTints( "EA_Window_InteractionLibrarianStoreList", EA_Window_InteractionLibrarianStore.MAX_VISIBLE_ROWS )
end


-- OnShutdown Handler
function EA_Window_InteractionLibrarianStore.Shutdown()
    EA_Window_InteractionLibrarianStore.RepairingOff()

end


function EA_Window_InteractionLibrarianStore.OnRButtonUp()
    EA_Window_ContextMenu.CreateDefaultContextMenu( "EA_Window_InteractionLibrarianStore" )
end

function EA_Window_InteractionLibrarianStore.Hide()
    EA_Window_InteractionLibrarianStore.Done()
end

function EA_Window_InteractionLibrarianStore.OnHidden()
    -- DEBUG(L"EA_Window_InteractionLibrarianStore.OnHidden")

    WindowUnregisterEventHandler( "EA_Window_InteractionLibrarianStore", SystemData.Events.PLAYER_INVENTORY_SLOT_UPDATED )
    
    PlayInteractSound("merchant_goodbye")
    BroadcastEvent( SystemData.Events.INTERACT_DONE )
    
    EA_Window_InteractionLibrarianStore.librarianStoredata = {};
    EA_Window_InteractionLibrarianStore.RepairingOff()
    
    WindowUtils.OnHidden()  
end

-- Play welcome sound and possibly close or move around other windows
function EA_Window_InteractionLibrarianStore.OnShown()
    -- DEBUG(L"EA_Window_InteractionLibrarianStore.OnShown")
    
    EA_Window_InteractionLibrarianStore.SetStoreType()

    WindowUtils.OnShown(EA_Window_InteractionLibrarianStore.Hide, WindowUtils.Cascade.MODE_HIGHLANDER)
    PlayInteractSound("merchant_offer") 
    
    EA_Window_InteractionLibrarianStore.updateButtonsAndTooltips()
    WindowRegisterEventHandler( "EA_Window_InteractionLibrarianStore", SystemData.Events.PLAYER_INVENTORY_SLOT_UPDATED, "EA_Window_InteractionLibrarianStore.updateButtonsAndTooltips")
    
    EA_BackpackUtilsMediator.ShowBackpack()
end

function EA_Window_InteractionLibrarianStore.Done()

    if Cursor.IconOnCursor() then
        Cursor.Clear()
    end
    
    WindowSetShowing( "EA_Window_InteractionLibrarianStore", false )
end



----------------------------------------------------------------
-- Sorting Functions
----------------------------------------------------------------

-- clears the column header sort arrow if set
function EA_Window_InteractionLibrarianStore.ClearSortButton()
--DEBUG(L"EA_Window_InteractionLibrarianStore.ClearSortButton")
    
    if EA_Window_InteractionLibrarianStore.sortColumnName ~= "" then
        WindowSetShowing(EA_Window_InteractionLibrarianStore.sortColumnName.."DownArrow", false )
        WindowSetShowing(EA_Window_InteractionLibrarianStore.sortColumnName.."UpArrow", false )
        
        EA_Window_InteractionLibrarianStore.sortColumnName = "" 
        EA_Window_InteractionLibrarianStore.sortColumnNum = 0
        EA_Window_InteractionLibrarianStore.shouldSortIncresing = true
    end
    
end


-- Update the sort buttons
-- They have 3 states to switch between if you keep pressng the same button: 
--		increasing, decreasing, and off
-- 
function EA_Window_InteractionLibrarianStore.ChangeSorting()
--DEBUG(L"EA_Window_InteractionLibrarianStore.ChangeSorting")
    
    if Cursor.IconOnCursor() then
        Cursor.Clear()
    end
    
    if EA_Window_InteractionLibrarianStore.sortColumnName == SystemData.ActiveWindow.name  then
        if EA_Window_InteractionLibrarianStore.shouldSortIncresing then
            EA_Window_InteractionLibrarianStore.shouldSortIncresing = (not EA_Window_InteractionLibrarianStore.shouldSortIncresing)
        else
            EA_Window_InteractionLibrarianStore.ClearSortButton()
        end
        
    else
        EA_Window_InteractionLibrarianStore.ClearSortButton()
        EA_Window_InteractionLibrarianStore.sortColumnName = SystemData.ActiveWindow.name
        EA_Window_InteractionLibrarianStore.sortColumnNum = WindowGetId( SystemData.ActiveWindow.name )
    end

    if EA_Window_InteractionLibrarianStore.sortColumnNum > 0 then
        WindowSetShowing(EA_Window_InteractionLibrarianStore.sortColumnName.."DownArrow", EA_Window_InteractionLibrarianStore.shouldSortIncresing )
        WindowSetShowing(EA_Window_InteractionLibrarianStore.sortColumnName.."UpArrow", (not EA_Window_InteractionLibrarianStore.shouldSortIncresing) )
    end
    
    -- TODO: this causes the data to be re-retrieved unncessarily
    EA_Window_InteractionLibrarianStore.ShowCurrentList()
end


function EA_Window_InteractionLibrarianStore.RefreshAllSortButtons()
    --DEBUG(L"EA_Window_InteractionLibrarianStore.RefreshAllSortButtons")

    for i, data in ipairs( EA_Window_InteractionLibrarianStore.sortHeaderData ) do
        local buttonName = "EA_Window_InteractionLibrarianStoreHeader"..data.column
        WindowSetShowing( buttonName.."DownArrow", false )
        WindowSetShowing( buttonName.."UpArrow", false )
    end
    
    if EA_Window_InteractionLibrarianStore.sortColumnNum > 0 then
        WindowSetShowing(EA_Window_InteractionLibrarianStore.sortColumnName.."DownArrow", EA_Window_InteractionLibrarianStore.shouldSortIncresing )
        WindowSetShowing(EA_Window_InteractionLibrarianStore.sortColumnName.."UpArrow", (not EA_Window_InteractionLibrarianStore.shouldSortIncresing) )
    end
end
   
-- returns true if a sort column is set and false if not
function EA_Window_InteractionLibrarianStore.Sort()
--DEBUG(L"EA_Window_InteractionLibrarianStore.Sort")

    if EA_Window_InteractionLibrarianStore.sortColumnNum >= 0 then
        local comparator = EA_Window_InteractionLibrarianStore.sortHeaderData[EA_Window_InteractionLibrarianStore.sortColumnNum].sortFunc
        table.sort( EA_Window_InteractionLibrarianStore.displayData, comparator )
    end

end


-- keep the forward and backward order lists for clicking on sort headers
function EA_Window_InteractionLibrarianStore.InitDataForSorting( filteredIndices )

    --DEBUG(L"EA_Window_InteractionLibrarianStore.InitSortingForNewData #filteredIndices = "..#filteredIndices)
    EA_Window_InteractionLibrarianStore.displayOrder = filteredIndices

    EA_Window_InteractionLibrarianStore.reverseDisplayOrder = {}
    for i = #filteredIndices, 1, -1 do  
        table.insert( EA_Window_InteractionLibrarianStore.reverseDisplayOrder, filteredIndices[i] )
    end

end


function EA_Window_InteractionLibrarianStore.DisplaySortedData()
    if EA_Window_InteractionLibrarianStore.shouldSortIncresing then
        ListBoxSetDisplayOrder( "EA_Window_InteractionLibrarianStoreList", EA_Window_InteractionLibrarianStore.displayOrder )
    else
        ListBoxSetDisplayOrder( "EA_Window_InteractionLibrarianStoreList", EA_Window_InteractionLibrarianStore.reverseDisplayOrder )
    end 
end


----------------------------------------------------------------
-- Filtering Functions
----------------------------------------------------------------

function EA_Window_InteractionLibrarianStore.ResetLibrarianStoreFilters()

    ButtonSetPressedFlag( "EA_Window_InteractionLibrarianStoreFilterByUsableButton", true )
end

function EA_Window_InteractionLibrarianStore.ToggleLibrarianStoreFilter()

    if ButtonGetDisabledFlag( SystemData.ActiveWindow.name.."Button" ) then
        return
    end

    if Cursor.IconOnCursor() then
        Cursor.Clear()
    end

    EA_LabelCheckButton.Toggle()
    EA_Window_InteractionLibrarianStore.ShowCurrentList()
end

function EA_Window_InteractionLibrarianStore.CreateFilteredList()

    local shouldShowOnlyUsable = ButtonGetPressedFlag( "EA_Window_InteractionLibrarianStoreFilterByUsableButton" )

    local displayOrder = {}

    --DEBUG(L"   EA_Window_InteractionLibrarianStore.displayData = ")
    for index, itemData in ipairs(EA_Window_InteractionLibrarianStore.displayData)
    do

        --DEBUG(L"      "..index..L" = "..itemData.name)
        if index > GameData.InteractStoreData.LastItemIndex then 
            DEBUG(L"EA_Window_InteractionLibrarianStore.displayData has more entries than it's supposed to")
            continue
        end

        -- we never want to show the item if it cannot be used by the player
        -- alternatively if the player cannot buy it we don't want to show it if
        -- the "purchasable" filter is on
        if not DataUtils.PlayerCanUseItem( itemData ) or
           ( shouldShowOnlyUsable and
             not itemData.canbuy )
        then
            continue
        end

        table.insert( displayOrder, index )

    end

    return displayOrder
end

----------------------------------------------------------------
-- Show LibrarianStore Functions
----------------------------------------------------------------

function EA_Window_InteractionLibrarianStore.ShowLibrarianStore()

    --DEBUG (L"EA_Window_InteractionLibrarianStore.ShowLibrarianStore");
    
    -- TODO: OPTIMIZATION: could use a dirty flag so they we don't repeatedly fetch same data
    -- TODO: OPTIMIZATION:  this is getting called for each of 6 or 8 pages of librarianStore data getting sent by server, when it really only needs to get called by the last one
    EA_Window_InteractionLibrarianStore.librarianStoredata = GetStoreData()
    --EA_Window_InteractionLibrarianStore.displayData = EA_Window_InteractionLibrarianStore.librarianStoredata
    
    WindowSetShowing( "EA_Window_InteractionLibrarianStore", true )
    
    if EA_Window_InteractionLibrarianStore.librarianStoredata.canRepair then
        WindowSetShowing("EA_Window_InteractionLibrarianStoreRepairAll", true)
        WindowSetShowing("EA_Window_InteractionLibrarianStoreRepairToggle", true)
    else
        WindowSetShowing("EA_Window_InteractionLibrarianStoreRepairAll", false)
        WindowSetShowing("EA_Window_InteractionLibrarianStoreRepairToggle", false)
    end

    
    --EA_Window_InteractionLibrarianStore.HideUselessLibrarianStoreFilters()
    EA_Window_InteractionLibrarianStore.UpdateCurrentList()
    
    EA_Window_InteractionLibrarianStore.UpdateMoneyAvailable()
    
end



--[[ 
    Convenience function to see if a player is interacting with a librarianStore.
--]]
function EA_Window_InteractionLibrarianStore.InteractingWithLibrarianStore()

    return WindowGetShowing("EA_Window_InteractionLibrarianStore")
end


function EA_Window_InteractionLibrarianStore.PreProcessLibrarianStoreData( dataTable )

    -- since sorting changes the order things are in the table, we save their original slotNum
    for index, itemData in ipairs(dataTable) do
        itemData.slotNum = index
        itemData.typeText = DataUtils.getItemTypeText( itemData )
    end

end

--[[
    This is a callback for custom list cell population.
--]]
function EA_Window_InteractionLibrarianStore.PopulateLibrarianStoreItemData ()

    for row, data in ipairs (EA_Window_InteractionLibrarianStoreList.PopulatorIndices) do
        --DEBUG (L"Setting row: "..row..L", to GameData.InteractionStoreData["..data..L"].cost="..EA_Window_InteractionLibrarianStore.displayData[data].cost);

        -- skip if the player cannot use the item
        if not (DataUtils.PlayerCanUseItem(EA_Window_InteractionLibrarianStore.displayData[data]))
        then
            continue
        end

        local itemName = EA_Window_InteractionLibrarianStore.displayData[data].name
        itemName = itemName or L" "  -- sanity check, in case somehow the name is not set
        itemName = GetStringFormatFromTable( "InteractionStoreStrings",  StringTables.InteractionStore.STORE_LABEL_ITEM_NAME_WITH_COUNT, {itemName, L""..EA_Window_InteractionLibrarianStore.displayData[data].stackCount} )
        LabelSetText( "EA_Window_InteractionLibrarianStoreListRow"..row.."ItemName", itemName )

        local totalCost = EA_Window_InteractionLibrarianStore.displayData[data].cost * EA_Window_InteractionLibrarianStore.displayData[data].stackCount        
        local moneyFrame = "EA_Window_InteractionLibrarianStoreListRow"..row.."ItemCost";
        local altCurrencyFrame = "EA_Window_InteractionLibrarianStoreListRow"..row.."ItemAltCost";
        local itemDescWinName = "EA_Window_InteractionLibrarianStoreListRow"..row.."ItemDesc";
        local lastAnchor

        WindowSetShowing( moneyFrame, (totalCost > 0) )
        if totalCost > 0 then
            lastAnchor = MoneyFrame.FormatMoney (moneyFrame, totalCost, MoneyFrame.HIDE_EMPTY_WINDOWS);
        end
        
        WindowSetShowing( altCurrencyFrame, (EA_Window_InteractionLibrarianStore.displayData[data].altCurrency ~= nil) )
        if EA_Window_InteractionLibrarianStore.displayData[data].altCurrency ~= nil
        then
        
            -- reset the altCurrencyFrame anchoring 
            WindowClearAnchors (altCurrencyFrame);
            if totalCost > 0 then
                WindowAddAnchor (altCurrencyFrame, "topright", lastAnchor, "topleft", 10, 0);
            else
                local anchorWindow = "EA_Window_InteractionLibrarianStoreListRow"..row.."ItemPic";
                WindowAddAnchor (altCurrencyFrame, "bottomright", anchorWindow, "bottomleft", 5, 3);    
            end
            
            MoneyFrame.FormatAltCurrency (altCurrencyFrame, EA_Window_InteractionLibrarianStore.displayData[data].altCurrency, MoneyFrame.HIDE_EMPTY_WINDOWS);
        end
        
        if (DataUtils.PlayerCanUseItem(EA_Window_InteractionLibrarianStore.displayData[data])) and
            EA_Window_InteractionLibrarianStore.displayData[data].canbuy
        then
            WindowSetTintColor("EA_Window_InteractionLibrarianStoreListRow"..row.."ItemPic", 255, 255, 255);
        else
            local UnusableItemColor = EA_Window_InteractionLibrarianStore.UNUSABLE_ITEM_COLOR
            WindowSetTintColor("EA_Window_InteractionLibrarianStoreListRow"..row.."ItemPic", UnusableItemColor.r, UnusableItemColor.g, UnusableItemColor.b);
        end

        if GameData.InteractStoreData.LibrarianType == GameData.InteractStoreData.STORE_TYPE_LIBRARIAN_TOME_TOKEN
        then
            WindowSetShowing(itemDescWinName, false)
        elseif GameData.InteractStoreData.LibrarianType == GameData.InteractStoreData.STORE_TYPE_LIBRARIAN_TOME_ACCESSORY
        then
            -- I'm setting this label repeatedly here so that it will be easier to replace with the actual description
            LabelSetText(itemDescWinName, GetStringFromTable( "InteractionStoreStrings", StringTables.InteractionStore.STORE_DEFAULT_DESCRIPTION ) )
            WindowSetShowing(itemDescWinName, true)
            WindowSetShowing( moneyFrame, false)
        elseif GameData.InteractStoreData.LibrarianType == GameData.InteractStoreData.STORE_TYPE_LIBRARIAN_TOME_TROPHY
        then
            -- I'm setting this label repeatedly here so that it will be easier to replace with the actual description
            LabelSetText(itemDescWinName, GetStringFromTable( "InteractionStoreStrings", StringTables.InteractionStore.STORE_DEFAULT_DESCRIPTION ) )
            WindowSetShowing(itemDescWinName, true)
            WindowSetShowing( moneyFrame, false)
        end
    end        
end



function EA_Window_InteractionLibrarianStore.ConfirmThenBuyItem( dataIdx, buyCount )
    --DEBUG(L"EA_Window_InteractionLibrarianStore.BuyItem, dataIdx="..dataIdx)

    buyCount = buyCount or 1
    if (dataIdx ~= 0)
    then
    
        -- TODO: we should actually be passing these values as parameters in the buy/sell/repair calls, so that if someone clicks fast enough they aren't receiving the wrong item
        -- TODO: Always buy one item for now...eventually I will make a popup for this...
        GameData.InteractStoreData.NumItems = buyCount
        GameData.InteractStoreData.CurrentItemIndex = EA_Window_InteractionLibrarianStore.displayData[dataIdx].slotNum

        if( EA_Window_InteractionLibrarianStore.displayData[dataIdx].cost  <= Player.GetMoney() )
        then

            local warnOnBuy = SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_BUY];

            if (warnOnBuy)
            then
                local text = GetStringFormatFromTable( "InteractionStoreStrings",  StringTables.InteractionStore.STORE_CLAIM_REWARD_TEXT, {EA_Window_InteractionLibrarianStore.displayData[dataIdx].name} )

                DialogManager.MakeTwoButtonDialog (text, 
                                                GetStringFromTable( "InteractionStoreStrings",  StringTables.InteractionStore.STORE_CLAIM_REWARD ), 
                                                EA_Window_InteractionLibrarianStore.BuyItem, 
                                                GetString (StringTables.Default.LABEL_NO), nil,
                                                nil, nil, not warnOnBuy,
                                                EA_Window_InteractionLibrarianStore.NeverWarnAboutBuying)
            else
                EA_Window_InteractionLibrarianStore.BuyItem() 
            end        
            
        else
            --EA_ChatWindow.Print(GetString(StringTables.Default.TEXT_MERCHANT_LACK_FUNDS_FOR_ITEM))
            EA_Window_InteractionLibrarianStore.BuyItem() 
            Sound.Play( Sound.NEGATIVE_FEEDBACK )
        end
    end
end

function EA_Window_InteractionLibrarianStore.BuyItem() 
--DEBUG(L"EA_Window_InteractionLibrarianStore.BuyItem, CurrentItemIndex="..GameData.InteractStoreData.CurrentItemIndex)

    -- TODO: should really change this from Lua exposed variables and broadcast to a function call with parameters
    -- GameData.InteractStoreData.NumItems and CurrentItemIndex have already been set...
    -- So just broadcast the buy and it should fail if you're not interacting or have moved
    -- away from the merchant...
    BroadcastEvent( SystemData.Events.INTERACT_BUY_ITEM )
end

function EA_Window_InteractionLibrarianStore.NeverWarnAboutBuying()
    local curVal = SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_BUY]
    SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_BUY] = not curVal
    
    EA_Window_InteractionLibrarianStore.UpdateDialogWarnings(SystemData.Settings.DlgWarning.WARN_BUY)
    
    BroadcastEvent( SystemData.Events.USER_SETTINGS_CHANGED )
end

function EA_Window_InteractionLibrarianStore.SellItem( inventorySlot, sellCount )
    --DEBUG(L"EA_Window_InteractionLibrarianStore.SellItem")
    -- NOTE: if sellCount not provided, then sell the entire stack of items in the inventory slot
    --sellCount = sellCount or DataUtils.GetItems()[inventorySlot].stackCount
    sellCount = sellCount or DataUtils.GetItems()[inventorySlot].stackCount
    
    -- TODO: should really change this from Lua exposed variables and broadcast to a function call with parameters
    GameData.InteractStoreData.CurrentItemIndex = inventorySlot
    GameData.InteractStoreData.NumItems = sellCount
    BroadcastEvent( SystemData.Events.INTERACT_SELL_ITEM )
    
    -- NOTE: Same deal as buy item...this needs a sound!
end

function EA_Window_InteractionLibrarianStore.MouseOverLibrarianStoreItem()

    local rowIdx = WindowGetId( WindowGetParent(SystemData.ActiveWindow.name) )

    if (rowIdx ~= 0) then
        local dataIdx = ListBoxGetDataIndex ("EA_Window_InteractionLibrarianStoreList", rowIdx)
        if (EA_Window_InteractionLibrarianStore.displayData == nil) then
            --DEBUG(L"displayData wasn't found")      
        elseif (dataIdx ~= 0) then
            Tooltips.CreateItemTooltip (EA_Window_InteractionLibrarianStore.displayData[dataIdx], 
                                                    SystemData.ActiveWindow.name,
                                                    Tooltips.ANCHOR_WINDOW_RIGHT,
                                                    false);
        end
    end

end


function EA_Window_InteractionLibrarianStore.UpdateLibrarianStoreList()

    -- TODO: OPTIMIZATION: could use a dirty flag so they we don't repeatedly fetch same data
    EA_Window_InteractionLibrarianStore.librarianStoredata = GetStoreData()
    EA_Window_InteractionLibrarianStore.PreProcessLibrarianStoreData( EA_Window_InteractionLibrarianStore.librarianStoredata )

    EA_Window_InteractionLibrarianStore.ShowLibrarianStoreList()
end

function EA_Window_InteractionLibrarianStore.ShowLibrarianStoreList()

    EA_Window_InteractionLibrarianStore.displayData = EA_Window_InteractionLibrarianStore.librarianStoredata

    -- sort all data before filtering
    EA_Window_InteractionLibrarianStore.Sort()

    local filteredDataIndices = EA_Window_InteractionLibrarianStore.CreateFilteredList()

    EA_Window_InteractionLibrarianStore.InitDataForSorting( filteredDataIndices )
    EA_Window_InteractionLibrarianStore.DisplaySortedData()

end



function EA_Window_InteractionLibrarianStore.UpdateMoneyAvailable()
    if WindowGetShowing( "EA_Window_InteractionLibrarianStore" ) then
        MoneyFrame.FormatMoney( "EA_Window_InteractionLibrarianStoreMoneyAvailable", Player.GetMoney(), MoneyFrame.HIDE_EMPTY_WINDOWS)  --MoneyFrame.SHOW_EMPTY_WINDOWS )
        EA_Window_InteractionLibrarianStore.updateButtonsAndTooltips()
    end
end


function EA_Window_InteractionLibrarianStore.UpdateCurrentList()

    EA_Window_InteractionLibrarianStore.UpdateLibrarianStoreList()

end

function EA_Window_InteractionLibrarianStore.ShowCurrentList()

    EA_Window_InteractionLibrarianStore.ShowLibrarianStoreList()

end
--------------------------------------------------------------------
-- Broken Items Repair Man
--------------------------------------------------------------------


--[[ 
    Convenience function to see if a player is interacting with a repair man.
--]]
function EA_Window_InteractionLibrarianStore.InteractingWithRepairMan()

    return ( EA_Window_InteractionLibrarianStore.repairModeOn and WindowGetShowing("EA_Window_InteractionLibrarianStoreRepairToggle") )
end


function EA_Window_InteractionLibrarianStore.ToggleRepairMode()
--DEBUG(L"EA_Window_InteractionLibrarianStore.ToggleRepairMode")

    if Cursor.IconOnCursor() then
        Cursor.Clear()
    end
    
    if ButtonGetDisabledFlag( "EA_Window_InteractionLibrarianStoreRepairToggle") then
        return
    end
    
    if EA_Window_InteractionLibrarianStore.repairModeOn then
        EA_Window_InteractionLibrarianStore.RepairingOff()
    else
        EA_Window_InteractionLibrarianStore.RepairingOn()
    end 
    EA_Window_InteractionLibrarianStore.RepairButtonMouseOver()
end


function EA_Window_InteractionLibrarianStore.RepairButtonMouseOver()
--DEBUG(L"EA_Window_InteractionLibrarianStore.RepairButtonMouseOver")

    local text 
    if ButtonGetDisabledFlag( "EA_Window_InteractionLibrarianStoreRepairToggle") then
        text = EA_Window_InteractionLibrarianLibrarianStore.repairToggleTooltip
    elseif EA_Window_InteractionLibrarianLibrarianStore.repairModeOn == false then
        text = GetStringFromTable( "InteractionStoreStrings",  StringTables.InteractionStore.STORE_REPAIR_MODE_ON_MOUSEOVER )
        
    else
        text = GetStringFromTable( "InteractionStoreStrings",  StringTables.InteractionStore.STORE_REPAIR_MODE_OFF_MOUSEOVER )
    end
    

    Tooltips.CreateTextOnlyTooltip (SystemData.ActiveWindow.name, text )
    Tooltips.AnchorTooltip (Tooltips.ANCHOR_WINDOW_TOP)
end


function EA_Window_InteractionLibrarianStore.RepairAllButtonMouseOver()
--DEBUG(L"EA_Window_InteractionLibrarianStore.RepairAllButtonMouseOver")

    Tooltips.CreateTextOnlyTooltip (SystemData.ActiveWindow.name, EA_Window_InteractionLibrarianStore.repairAllTooltip )
    if not EA_Window_InteractionLibrarianStore.sufficientFundsToRepairAll then
    
        local errorMsg = GetStringFromTable( "InteractionStoreStrings",  StringTables.InteractionStore.STORE_INSUFFICIENT_MONEY_MOUSEOVER )
        Tooltips.SetTooltipText (2, 1, errorMsg)
        Tooltips.SetTooltipColorDef (2, 1, Tooltips.COLOR_FAILS_REQUIREMENTS)
        Tooltips.Finalize ()
    end
    Tooltips.AnchorTooltip (Tooltips.ANCHOR_WINDOW_TOP)
end


function EA_Window_InteractionLibrarianStore.RepairingOn()

    EA_Window_InteractionLibrarianStore.repairModeOn = true
    
    EA_Window_InteractionLibrarianStore.currentRepairCursor = nil
    EA_Window_InteractionLibrarianStore.OnMouseOverRepairableItemEnd()
    
end

function EA_Window_InteractionLibrarianStore.OnMouseOverRepairableItem()

    if( EA_Window_InteractionLibrarianStore.repairModeOn == true and 
        EA_Window_InteractionLibrarianStore.currentRepairCursor ~= SystemData.InteractActions.REPAIR
      ) then
      
        SetDesiredInteractAction( SystemData.InteractActions.REPAIR )
        EA_Window_InteractionLibrarianStore.currentRepairCursor = SystemData.InteractActions.REPAIR
    end
end


function EA_Window_InteractionLibrarianStore.OnMouseOverRepairableItemEnd()

    if( EA_Window_InteractionLibrarianStore.repairModeOn == true and 
        EA_Window_InteractionLibrarianStore.currentRepairCursor ~= SystemData.InteractActions.REPAIR_DISABLED
      ) then
        
        SetDesiredInteractAction( SystemData.InteractActions.REPAIR_DISABLED )
        EA_Window_InteractionLibrarianStore.currentRepairCursor = SystemData.InteractActions.REPAIR_DISABLED
    end
end

function EA_Window_InteractionLibrarianStore.RepairingOff()

    EA_Window_InteractionLibrarianStore.repairModeOn = false
    EA_Window_InteractionLibrarianStore.currentRepairCursor = nil
    if( GetDesiredInteractAction() == SystemData.InteractActions.REPAIR or
        GetDesiredInteractAction() == SystemData.InteractActions.REPAIR_DISABLED ) then
        
        SetDesiredInteractAction( SystemData.InteractActions.NONE )
    end
    
    --ClearCursor()
end



function EA_Window_InteractionLibrarianStore.RepairItem(inventorySlot)
--DEBUG(L"EA_Window_InteractionLibrarianStore.RepairItem, inventorySlot="..inventorySlot)


    -- TODO: should really change this from Lua exposed variables and broadcast to a function call with parameters
    GameData.InteractStoreData.NumItems         = 1
    GameData.InteractStoreData.CurrentItemIndex = inventorySlot
    
    BroadcastEvent (SystemData.Events.INTERACT_REPAIR)
    
    -- NOTE: Same deal as sell item...this needs a sound!
    
end



-- cause repair interaction for all repairable items in backpack
function EA_Window_InteractionLibrarianStore.RepairAll()
--DEBUG(L"EA_Window_InteractionLibrarianStore.RepairAll")

    if Cursor.IconOnCursor() then
        Cursor.Clear()
    end
    
    if ButtonGetDisabledFlag( "EA_Window_InteractionLibrarianStoreRepairAll") then
        return
    end
    
    if EA_Window_InteractionLibrarianStore.repairModeOn then
        EA_Window_InteractionLibrarianStore.RepairingOff()
    end 
    
    EA_Window_InteractionLibrarianStore.pendingRepairSlots = EA_Window_InteractionLibrarianStore.GetRepairableItems()
    
    EA_Window_InteractionLibrarianStore.ShowNextQueuedRepairConfirm()
end



-- returns 2 tables and an int:
--    table of indices into the backpack of broken items repairable by your career
--    table of indices into the backpack of broken items *not* repairable by your career
--    the price of repairing all repairable items
--
function EA_Window_InteractionLibrarianStore.GetRepairableItems()
--DEBUG(L"EA_Window_InteractionLibrarianStore.GetRepairableItems")

    local inventory = DataUtils.GetItems()
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

function EA_Window_InteractionLibrarianStore.toggleSortButtons()
    --DEBUG(L"EA_Window_InteractionLibrarianStore.toggleSortButtons")

    local tempSortColumnNum = EA_Window_InteractionLibrarianStore.sortColumnNum
    local tempSortColumnName = EA_Window_InteractionLibrarianStore.sortColumnName
    local tempShouldSortIncresing = EA_Window_InteractionLibrarianStore.shouldSortIncresing
    
    EA_Window_InteractionLibrarianStore.sortColumnNum = EA_Window_InteractionLibrarianStore.previousSortColumnNum
    EA_Window_InteractionLibrarianStore.sortColumnName = EA_Window_InteractionLibrarianStore.previousSortColumnName
    EA_Window_InteractionLibrarianStore.shouldSortIncresing = EA_Window_InteractionLibrarianStore.previousShouldSortIncresing
    
    EA_Window_InteractionLibrarianStore.previousSortColumnNum = tempSortColumnNum
    EA_Window_InteractionLibrarianStore.previousSortColumnName = tempSortColumnName
    EA_Window_InteractionLibrarianStore.previousShouldSortIncresing = tempShouldSortIncresing   
    
    EA_Window_InteractionLibrarianStore.RefreshAllSortButtons()
end

function EA_Window_InteractionLibrarianStore.updateFilterButtons( isFilterable )
    
    local color
    if isFilterable then 
        color = EA_Window_InteractionLibrarianStore.ENABLED_FILTER_COLOR
    else
        color = EA_Window_InteractionLibrarianStore.DISABLED_FILTER_COLOR
    end
    
    ButtonSetDisabledFlag( "EA_Window_InteractionLibrarianStoreFilterByUsableButton", not isFilterable )
    
    LabelSetTextColor( "EA_Window_InteractionLibrarianStoreFilterByUsableLabel", color.r, color.g, color.b )
    
    --[[
    WindowSetShowing( "EA_Window_InteractionLibrarianStoreFilterByUsable", isFilterable )
    --]]
end

function EA_Window_InteractionLibrarianStore.updateButtonsAndTooltips()
--DEBUG(L"EA_Window_InteractionLibrarianStore.updateButtonsAndTooltips")

    local repairableItems, brokenButNotRepairableItems, totalRepairPrice = EA_Window_InteractionLibrarianStore.GetRepairableItems()
    local numRepairable = #repairableItems 
    local numBrokenButNotRepairable = #brokenButNotRepairableItems 
    local someRepairables = numRepairable > 0
    EA_Window_InteractionLibrarianStore.sufficientFundsToRepairAll = ( Player.GetMoney() >= totalRepairPrice )

    local repairPriceString = L""
    if totalRepairPrice > 0 then
        repairPriceString = MoneyFrame.FormatMoneyString( totalRepairPrice )
    end
    
    if EA_Window_InteractionLibrarianStore.librarianStoredata.canRepair then
        ButtonSetDisabledFlag( "EA_Window_InteractionLibrarianStoreRepairToggle", not someRepairables )
        ButtonSetDisabledFlag( "EA_Window_InteractionLibrarianStoreRepairAll", (not someRepairables or not EA_Window_InteractionLibrarianStore.sufficientFundsToRepairAll) )
    end
    
    if not someRepairables and EA_Window_InteractionLibrarianStore.repairModeOn then
        EA_Window_InteractionLibrarianStore.RepairingOff()
    end
    
    EA_Window_InteractionLibrarianStore.repairToggleTooltip = 
            GetFormatStringFromTable( "InteractionStoreStrings", StringTables.InteractionStore.STORE_REPAIR_MODE_DISABLED_MOUSEOVER, 
                                      { numBrokenButNotRepairable } ) 
                            
    EA_Window_InteractionLibrarianStore.repairAllTooltip = 
                GetFormatStringFromTable( "InteractionStoreStrings", StringTables.InteractionStore.STORE_REPAIR_ALL_BUTTON_MOUSEOVER, 
                                          { numRepairable , numBrokenButNotRepairable, totalRepairPrice, repairPriceString } ) 
    
    
    
    if SystemData.MouseOverWindow.name == "EA_Window_InteractionLibrarianStoreRepairToggle" then
        Tooltips.ClearTooltip()
        EA_Window_InteractionLibrarianStore.RepairButtonMouseOver()
        
    elseif SystemData.MouseOverWindow.name == "EA_Window_InteractionLibrarianStoreRepairAll" then
        Tooltips.ClearTooltip()
        EA_Window_InteractionLibrarianStore.RepairAllButtonMouseOver()
    end
    
end



------------------------
-- Repair Item Confirmations 
------------------------

function EA_Window_InteractionLibrarianStore.toggleWarnBeforeRepairing()

    local curVal = SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_REPAIR]
    SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_REPAIR] = not curVal
    
    EA_Window_InteractionLibrarianStore.UpdateDialogWarnings(SystemData.Settings.DlgWarning.WARN_REPAIR)

    BroadcastEvent (SystemData.Events.USER_SETTINGS_CHANGED)
end

-- TODO: this should be kept in C++ settings file and be able to turn back on through User Settings Window
function EA_Window_InteractionLibrarianStore.shouldWarnBeforeRepairing()

    return SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_REPAIR]
end


function EA_Window_InteractionLibrarianStore.RepairPendingItem()
        
    if #EA_Window_InteractionLibrarianStore.pendingRepairSlots > 0 then
        local pendingRepairSlot = table.remove( EA_Window_InteractionLibrarianStore.pendingRepairSlots, 1 )
        EA_Window_InteractionLibrarianStore.RepairItem( pendingRepairSlot )
        EA_Window_InteractionLibrarianStore.ShowNextQueuedRepairConfirm()
    end
end

function EA_Window_InteractionLibrarianStore.RemoveRepairPendingItem()
        
    if #EA_Window_InteractionLibrarianStore.pendingRepairSlots > 0 then
        table.remove( EA_Window_InteractionLibrarianStore.pendingRepairSlots, 1 )
        EA_Window_InteractionLibrarianStore.ShowNextQueuedRepairConfirm()
    end
end

function EA_Window_InteractionLibrarianStore.ConfirmThenRepairItem( inventorySlot )

    local itemData = DataUtils.GetItems()[inventorySlot]
    if( itemData ~=nil and itemData.repairPrice ~= nil and itemData.repairPrice  > Player.GetMoney() ) then
    
        EA_Window_InteractionLibrarianStore.RepairItem( inventorySlot )
        Sound.Play( Sound.NEGATIVE_FEEDBACK )
        return
    end
    
    local warnOnRepair = EA_Window_InteractionLibrarianStore.shouldWarnBeforeRepairing()
    if (warnOnRepair) then
        
        table.insert( EA_Window_InteractionLibrarianStore.pendingRepairSlots, inventorySlot )
        EA_Window_InteractionLibrarianStore.ShowRepairConfirm(inventorySlot, warnOnRepair )
        
    else
        EA_Window_InteractionLibrarianStore.RepairItem( inventorySlot )
    end
end

-- NOTE: we may want to change this to a 3 button dialog that let's us abort the entire Repair All pending list
function EA_Window_InteractionLibrarianStore.ShowRepairConfirm( inventorySlot, displayNeverWarnCheckBox )

    local itemData = DataUtils.GetItems()[inventorySlot]
    
    -- verify the repairable item is still in that slot
    if itemData == nil or itemData.broken == false or itemData.repairPrice <= 0 then
        EA_Window_InteractionLibrarianStore.RemoveRepairPendingItem()
    end
    
    local neverWarnCallback = nil
    if displayNeverWarnCheckBox then
        neverWarnCallback = EA_Window_InteractionLibrarianStore.toggleWarnBeforeRepairing
    end
    
    local price = MoneyFrame.FormatMoneyString (itemData.repairPrice) 
    local text = GetStringFormat (StringTables.Default.LABEL_CONFIRM_REPAIR_ITEM, { itemData.name, price })
    DialogManager.MakeTwoButtonDialog (text, 
                                        GetString (StringTables.Default.LABEL_YES), EA_Window_InteractionLibrarianStore.RepairPendingItem, 
                                        GetString (StringTables.Default.LABEL_NO), EA_Window_InteractionLibrarianStore.RemoveRepairPendingItem,
                                        nil, nil, false, neverWarnCallback )
    
end

-- for some reason DialogManager.MakeTwoButtonDialog can't queue up more data than it has windows,
--   (even though it will only display each window one at a time), so I'm queueing it here.
--
function EA_Window_InteractionLibrarianStore.ShowNextQueuedRepairConfirm()

    if #EA_Window_InteractionLibrarianStore.pendingRepairSlots > 0 then
        local inventorySlot = EA_Window_InteractionLibrarianStore.pendingRepairSlots[1]
        EA_Window_InteractionLibrarianStore.ShowRepairConfirm( inventorySlot, false )		-- false == can't turn off confirmation
    end

end

----------------------------
-- Sell Item Confirmations 
----------------------------

function EA_Window_InteractionLibrarianStore.toggleWarnBeforeSelling()

    local curVal = SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_SELL]
    SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_SELL] = not curVal
    
    EA_Window_InteractionLibrarianStore.UpdateDialogWarnings(SystemData.Settings.DlgWarning.WARN_SELL)

    BroadcastEvent (SystemData.Events.USER_SETTINGS_CHANGED)
end

function EA_Window_InteractionLibrarianStore.shouldWarnBeforeSelling()

    return SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_SELL]
end


function EA_Window_InteractionLibrarianStore.SellPendingItem()  
    --DEBUG(L"EA_Window_InteractionLibrarianStore.SellPendingItem")
        
    if #EA_Window_InteractionLibrarianStore.pendingSellSlots > 0 then
        local pendingSellSlot = table.remove( EA_Window_InteractionLibrarianStore.pendingSellSlots, 1 )
        local pendingSellCount = table.remove( EA_Window_InteractionLibrarianStore.pendingSellCounts, 1 )
        
        EA_Window_InteractionLibrarianStore.SellItem( pendingSellSlot, pendingSellCount )
        --EA_Window_InteractionLibrarianStore.ShowNextQueuedSellConfirm()
    end
end

function EA_Window_InteractionLibrarianStore.RemoveSellPendingItem()
    --DEBUG(L"EA_Window_InteractionLibrarianStore.RemoveSellPendingItem")
        
    if #EA_Window_InteractionLibrarianStore.pendingSellSlots > 0 then
        table.remove( EA_Window_InteractionLibrarianStore.pendingSellSlots, 1 )
        table.remove( EA_Window_InteractionLibrarianStore.pendingSellCounts, 1 )
        --EA_Window_InteractionLibrarianStore.ShowNextQueuedSellConfirm()
    end
end



function EA_Window_InteractionLibrarianStore.ConfirmThenSellItem( inventorySlot, sellCount )
    --DEBUG(L"EA_Window_InteractionLibrarianStore.ConfirmThenSellItem")

    local warnOnSell = EA_Window_InteractionLibrarianStore.shouldWarnBeforeSelling()

    if (warnOnSell) then
        EA_Window_InteractionLibrarianStore.ShowSellConfirm(inventorySlot, warnOnSell )
        
    else
        EA_Window_InteractionLibrarianStore.SellItem( inventorySlot, sellCount )
    end
end

function EA_Window_InteractionLibrarianStore.ShowSellConfirm( inventorySlot, displayNeverWarnCheckBox, sellCount )

    -- NOTE: if sellCount not provided, then sell the entire stack of items in the inventory slot
    local itemData = DataUtils.GetItems()[inventorySlot]
    sellCount = sellCount or itemData.stackCount
    
    local neverWarnCallback = nil
    if displayNeverWarnCheckBox then
        neverWarnCallback = EA_Window_InteractionLibrarianStore.toggleWarnBeforeSelling
    end
    
    table.insert( EA_Window_InteractionLibrarianStore.pendingSellSlots, inventorySlot )
    table.insert( EA_Window_InteractionLibrarianStore.pendingSellCounts, sellCount )
    
    local text = GetStringFormat (StringTables.Default.LABEL_CONFIRM_SELL_ITEM, { itemData.name } )
    DialogManager.MakeTwoButtonDialog ( text, 
                                        GetString (StringTables.Default.LABEL_YES), EA_Window_InteractionLibrarianStore.SellPendingItem, 
                                        GetString (StringTables.Default.LABEL_NO), EA_Window_InteractionLibrarianStore.RemoveSellPendingItem,
                                        nil, nil, false, neverWarnCallback )
    
end

-- pretty much the same as checking Cursor.IconOnCursor(), but verifies it wasn't an item picked up from the merchant window
function EA_Window_InteractionLibrarianStore.CursorIsCarryingItem()
    if Cursor.IconOnCursor() and  Cursor.Data.Source ~= Cursor.SOURCE_MERCHANT then
        return true
    else
        return false
    end
    
end

-- right now this only will sell things from the backpack window. Any backpack items that are not sellable are checked from the server. 
function EA_Window_InteractionLibrarianStore.IsCarryingSellableItem()
    
    if Cursor.IconOnCursor() and  Cursor.Data.Source == Cursor.SOURCE_INVENTORY then
        return true
    else
        return false
    end
end

function EA_Window_InteractionLibrarianStore.CursorIsCarryingMerchantItem()
    
    if Cursor.IconOnCursor() and  Cursor.Data.Source == Cursor.SOURCE_MERCHANT then
        return true
    else
        return false
    end
end

function EA_Window_InteractionLibrarianStore.SellItemOnCursor()
    if EA_Window_InteractionLibrarianStore.IsCarryingSellableItem() then
        EA_Window_InteractionLibrarianStore.ConfirmThenSellItem( Cursor.Data.SourceSlot, Cursor.Data.StackAmount )
        Cursor.Clear()
    else
        -- TODO: provide some kind of error message
        --local text = GetString (StringTables.Default.)
        --EA_ChatWindow.Print (text, SystemData.ChatLogFilters.SAY)  
    end
end


function EA_Window_InteractionLibrarianStore.OnItemLButtonUp( flags )

    -- this check will ignore icons picked up from the merchant window
    if EA_Window_InteractionLibrarianStore.CursorIsCarryingItem() then
        EA_Window_InteractionLibrarianStore.SellItemOnCursor()
        return
    end
    
end

function EA_Window_InteractionLibrarianStore.OnItemLButtonDown( flags )

    if EA_Window_InteractionLibrarianStore.CursorIsCarryingItem() 
    then
        EA_Window_InteractionLibrarianStore.SellItemOnCursor()
        return
    end
    
    local rowIdx = WindowGetId(SystemData.MouseOverWindow.name)
    if (rowIdx == 0) 
    then
        return
    end
    
    local dataIdx = ListBoxGetDataIndex ("EA_Window_InteractionLibrarianStoreList", rowIdx)
    local itemData = EA_Window_InteractionLibrarianStore.displayData[dataIdx]
    
    -- Create Chat HyperLinks on Shift-Left-Button-Down
    if( flags == SystemData.ButtonFlags.SHIFT )
    then
        EA_ChatWindow.InsertItemLink( itemData )
    else
        Cursor.PickUp( Cursor.SOURCE_MERCHANT, dataIdx, itemData.uniqueID, itemData.iconNum, true, itemData.stackCount )
    end
    
end



function EA_Window_InteractionLibrarianStore.OnItemRButtonUp( flags, x, y )
    --DEBUG(L"EA_Window_InteractionLibrarianStore.BuyItem")

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
    local dataIdx = ListBoxGetDataIndex ("EA_Window_InteractionLibrarianStoreList", rowIdx)
    
    -- On Shift-R-Button Down, Open the Stack Window
    if( flags == SystemData.ButtonFlags.SHIFT )
    then
        local titleBarText = GetStringFromTable( "InteractionStoreStrings", StringTables.InteractionStore.STORE_BUY_STACK_TITLE )
        ItemStackingWindow.Show( Cursor.SOURCE_MERCHANT, dataIdx, titleBarText )
    else
    
        -- Otherwise buy the item     
        local buyCount = EA_Window_InteractionLibrarianStore.displayData[dataIdx].stackCount
        EA_Window_InteractionLibrarianStore.ConfirmThenBuyItem( dataIdx, buyCount )
    end
    
end

function EA_Window_InteractionLibrarianStore.GetItem( dataIdx )
    return EA_Window_InteractionLibrarianStore.displayData[dataIdx]
end

-- Handle dialog warning change 
function EA_Window_InteractionLibrarianStore.UpdateDialogWarnings(whichWarning)
    if WindowGetShowing( "SettingsWindowTabbed") == true 
    then
        SettingsWindowTabGeneral.UpdateDialogWarnings(whichWarning)
    end
end

function EA_Window_InteractionLibrarianStore.SetStoreType()
    --DEBUG(L"GameData.InteractStoreData.LibrarianType = "..GameData.InteractStoreData.LibrarianType)

    if GameData.InteractStoreData.LibrarianType == GameData.InteractStoreData.STORE_TYPE_LIBRARIAN_TOME_TOKEN
    then
        EA_Window_InteractionLibrarianStore.SetStoreTypeTomeToken()
    elseif GameData.InteractStoreData.LibrarianType == GameData.InteractStoreData.STORE_TYPE_LIBRARIAN_TOME_ACCESSORY
    then
        EA_Window_InteractionLibrarianStore.SetStoreTypeTomeAccessory()
    elseif GameData.InteractStoreData.LibrarianType == GameData.InteractStoreData.STORE_TYPE_LIBRARIAN_TOME_TROPHY
    then
        EA_Window_InteractionLibrarianStore.SetStoreTypeTomeTrophy()
    end
end

-- now all the store types are hiding the available money windows
-- but eventually the bestial tokens will be handled like actual money
-- and we can display the number we have available so we'll keep the windows around
function EA_Window_InteractionLibrarianStore.SetStoreTypeTomeToken()
    WindowSetShowing("EA_Window_InteractionLibrarianStoreMoneyAvailableHeader", false)
    WindowSetShowing("EA_Window_InteractionLibrarianStoreMoneyAvailable", false)

    -- Hiding the filter purchasable button and label
    WindowSetShowing("EA_Window_InteractionLibrarianStoreFilterByUsable", false)
end

function EA_Window_InteractionLibrarianStore.SetStoreTypeTomeAccessory()
    WindowSetShowing("EA_Window_InteractionLibrarianStoreMoneyAvailableHeader", false)
    WindowSetShowing("EA_Window_InteractionLibrarianStoreMoneyAvailable", false)

    -- Show the filter purchasable button and label
    WindowSetShowing("EA_Window_InteractionLibrarianStoreFilterByUsable", true)
end

function EA_Window_InteractionLibrarianStore.SetStoreTypeTomeTrophy()
    WindowSetShowing("EA_Window_InteractionLibrarianStoreMoneyAvailableHeader", false)
    WindowSetShowing("EA_Window_InteractionLibrarianStoreMoneyAvailable", false)

    -- Show the filter purchasable button and label
    WindowSetShowing("EA_Window_InteractionLibrarianStoreFilterByUsable", true)
end

function EA_Window_InteractionLibrarianStore.MouseOverAltCost()
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, EA_Window_InteractionLibrarianStore.displayData[WindowGetId( SystemData.ActiveWindow.name )].altCurrency[1].description )
	Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_VARIABLE )
end