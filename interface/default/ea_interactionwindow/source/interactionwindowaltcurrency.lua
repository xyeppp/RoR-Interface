
----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_InteractionAltCurrency = 
{
    displayData = {},
    currentItemData = nil,
    currentItemBuyCount = 0,
    selectedItemIndex = 0,
}

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------
local MAX_VISIBLE_ROWS = 3

-- Takes an entry from the displayData array and gets the full itemData for it
local function GetItemDataFromItemInfo( itemInfo )
    return EA_Window_Backpack.GetItemsFromBackpack( itemInfo.backpackType )[itemInfo.slotNum]
end

local function ShouldPurchaseButtonBeEnabled()
    return ButtonGetPressedFlag( "EA_Window_InteractionAltCurrencyWarningButton" ) and ( EA_Window_InteractionAltCurrency.selectedItemIndex ~= 0 )
end

local function RefreshListBox()
    local numEntries = #EA_Window_InteractionAltCurrency.displayData
    local displayOrder = {}
    for entry = 1, numEntries
    do
        table.insert( displayOrder, entry )
    end
    ListBoxSetDisplayOrder( "EA_Window_InteractionAltCurrencyList", displayOrder )
end

local function GetDisplayInfo( backpackType, slot, itemData )
    return
    {
        backpackType = backpackType,
        slotNum = slot,
        iconNum = itemData.iconNum,
        typeText = DataUtils.getItemTypeText( itemData ),
        name = itemData.name,
        stackCount = itemData.stackCount,
    }
end

----------------------------------------------------------------
-- EA_Window_InteractionAltCurrency Functions
----------------------------------------------------------------

function EA_Window_InteractionAltCurrency.Initialize()
    LabelSetText("EA_Window_InteractionAltCurrencyTitleBarText", GetStringFromTable( "InteractionStoreStrings", StringTables.InteractionStore.ALT_CURRENCY_TITLEBAR ) )
    LabelSetText("EA_Window_InteractionAltCurrencyInfo", GetStringFromTable( "InteractionStoreStrings", StringTables.InteractionStore.ALT_CURRENCY_INFO ) )
    LabelSetText("EA_Window_InteractionAltCurrencyWarningLabel", GetStringFromTable( "InteractionStoreStrings", StringTables.InteractionStore.ALT_CURRENCY_WARNING ) )
    
    ButtonSetText("EA_Window_InteractionAltCurrencyPurchase", GetString( StringTables.Default.LABEL_BUY ))
    ButtonSetText("EA_Window_InteractionAltCurrencyCancel", GetString( StringTables.Default.LABEL_CANCEL ))

    DataUtils.SetListRowAlternatingTints( "EA_Window_InteractionAltCurrencyList", MAX_VISIBLE_ROWS )
end

function EA_Window_InteractionAltCurrency.OnRButtonUp()
    EA_Window_ContextMenu.CreateDefaultContextMenu( "EA_Window_InteractionAltCurrency" )
end

function EA_Window_InteractionAltCurrency.Hide()
    WindowSetShowing( "EA_Window_InteractionAltCurrency", false )
end

function EA_Window_InteractionAltCurrency.OnHidden()
    WindowUnregisterEventHandler( "EA_Window_InteractionAltCurrency", SystemData.Events.PLAYER_INVENTORY_SLOT_UPDATED )
    WindowUnregisterEventHandler( "EA_Window_InteractionAltCurrency", SystemData.Events.PLAYER_CRAFTING_SLOT_UPDATED )
    WindowUnregisterEventHandler( "EA_Window_InteractionAltCurrency", SystemData.Events.PLAYER_CURRENCY_SLOT_UPDATED )
end

function EA_Window_InteractionAltCurrency.OnShown()
    WindowRegisterEventHandler( "EA_Window_InteractionAltCurrency", SystemData.Events.PLAYER_INVENTORY_SLOT_UPDATED, "EA_Window_InteractionAltCurrency.OnInventorySlotUpdated" )
    WindowRegisterEventHandler( "EA_Window_InteractionAltCurrency", SystemData.Events.PLAYER_CRAFTING_SLOT_UPDATED,  "EA_Window_InteractionAltCurrency.OnCraftingSlotUpdated" )
    WindowRegisterEventHandler( "EA_Window_InteractionAltCurrency", SystemData.Events.PLAYER_CURRENCY_SLOT_UPDATED,  "EA_Window_InteractionAltCurrency.OnCurrencySlotUpdated" )
end

-- Returns true if there is at least one valid item and the window has shown. False if there are no valid potential items.
function EA_Window_InteractionAltCurrency.Show( itemData, buyCount )

    local displayData = {}
    
    -- Generate a list of matching items
    local altCurrencyType = itemData.altCurrency[1].type
    for backpackType = 1, EA_Window_Backpack.NUM_BACKPACK_TYPES
    do
        local items = EA_Window_Backpack.GetItemsFromBackpack( backpackType )
        for slot, itemData in ipairs(items)
        do
            if ( DataUtils.IsValidItem( itemData ) and ( itemData.uniqueID == altCurrencyType ) )
            then
                -- We only want to show the alt currency window to show non-stackable items (which have a capacity, AKA max stack count, of 1).
                if ( itemData.capacity == 1 )
                then
                    table.insert( displayData, GetDisplayInfo( backpackType, slot, itemData ) )
                end
            end
        end
    end
    
    if ( #displayData == 0 )
    then
        return false
    end
    
    -- By default, no item is selected
    EA_Window_InteractionAltCurrency.selectedItemIndex = 0
    
    EA_Window_InteractionAltCurrency.displayData = displayData
    RefreshListBox()
    
    -- Save itemData and buyCount variables. We will need this to actually purchase the item when the "Buy" button is clicked.
    EA_Window_InteractionAltCurrency.currentItemData = itemData
    EA_Window_InteractionAltCurrency.currentItemBuyCount = buyCount
    
    -- Default the checkbox to unchecked and update the Purchase button appropriately
    ButtonSetPressedFlag( "EA_Window_InteractionAltCurrencyWarningButton", false )
    ButtonSetDisabledFlag( "EA_Window_InteractionAltCurrencyPurchase", true )
    
    -- Show the window
    WindowSetShowing( "EA_Window_InteractionAltCurrency", true )
    
    -- Normally the cursor is cleared once the purchase is actually complete, but in this case, waiting for that would look strange, so clear the cursor now.
    Cursor.Clear()
    
    return true
    
end

function EA_Window_InteractionAltCurrency.PopulateItemData()
    for row, data in ipairs(EA_Window_InteractionAltCurrencyList.PopulatorIndices)
    do
        local itemInfo = EA_Window_InteractionAltCurrency.displayData[data]
        local itemName = GetStringFormatFromTable( "InteractionStoreStrings", StringTables.InteractionStore.STORE_LABEL_ITEM_NAME_WITH_COUNT, { itemInfo.name, towstring(itemInfo.stackCount) } )
        LabelSetText( "EA_Window_InteractionAltCurrencyListRow"..row.."ItemName", itemName )
        WindowSetShowing( "EA_Window_InteractionAltCurrencyListRow"..row.."SelectionBorder", EA_Window_InteractionAltCurrency.selectedItemIndex == data )
    end
end

function EA_Window_InteractionAltCurrency.MouseOverItem()
    local rowIdx = WindowGetId( SystemData.ActiveWindow.name )
    
    if ( rowIdx ~= 0 )
    then
        local dataIdx = ListBoxGetDataIndex( "EA_Window_InteractionAltCurrencyList", rowIdx )
        if ( dataIdx ~= 0 )
        then
            local itemInfo = EA_Window_InteractionAltCurrency.displayData[dataIdx]
            if ( itemInfo ~= nil )
            then
                local itemData = GetItemDataFromItemInfo( itemInfo )
                if ( itemData ~= nil )
                then
                    Tooltips.CreateItemTooltip( itemData, SystemData.ActiveWindow.name, Tooltips.ANCHOR_WINDOW_RIGHT, false )
                end
            end
        end
    end
end

function EA_Window_InteractionAltCurrency.ToggleWarning()
    EA_LabelCheckButton.Toggle()
    ButtonSetDisabledFlag( "EA_Window_InteractionAltCurrencyPurchase", not ShouldPurchaseButtonBeEnabled() )
end

function EA_Window_InteractionAltCurrency.Purchase()
    if ( not ButtonGetDisabledFlag(SystemData.ActiveWindow.name) )
    then
        GameData.InteractStoreData.NumItems = EA_Window_InteractionAltCurrency.currentItemBuyCount
        GameData.InteractStoreData.CurrentItemIndex = EA_Window_InteractionAltCurrency.currentItemData.slotNum
        
        local itemInfo = EA_Window_InteractionAltCurrency.displayData[EA_Window_InteractionAltCurrency.selectedItemIndex]
        GameData.InteractStoreData.AltCurrencyBackpackIndex = itemInfo.backpackType
        GameData.InteractStoreData.AltCurrencyItemIndex = itemInfo.slotNum
        
        BroadcastEvent( SystemData.Events.INTERACT_BUY_ITEM_WITH_ALT_CURRENCY )
        
        WindowSetShowing( "EA_Window_InteractionAltCurrency", false )
    end
end

function EA_Window_InteractionAltCurrency.OnItemLButtonDown( flags )
    local rowIdx = WindowGetId( SystemData.ActiveWindow.name )
    if ( rowIdx == 0 )
    then
        return
    end
    
    local dataIdx = ListBoxGetDataIndex( "EA_Window_InteractionAltCurrencyList", rowIdx )
    local itemInfo = EA_Window_InteractionAltCurrency.displayData[dataIdx]
    
    -- Create Chat HyperLinks on Shift-Left-Button-Down
    if ( flags == SystemData.ButtonFlags.SHIFT )
    then
        local itemData = GetItemDataFromItemInfo( itemInfo )
        if ( itemData ~= nil )
        then
            EA_ChatWindow.InsertItemLink( itemData )
        end
    else
        if ( EA_Window_InteractionAltCurrency.selectedItemIndex ~= dataIdx )
        then
            EA_Window_InteractionAltCurrency.selectedItemIndex = dataIdx
            
            -- Update the highlight around the selected row
            for row = 1, MAX_VISIBLE_ROWS
            do
                WindowSetShowing( "EA_Window_InteractionAltCurrencyListRow"..row.."SelectionBorder", ( row == rowIdx ) )
            end
            
            -- This may have enabled the Purchase button
            ButtonSetDisabledFlag( "EA_Window_InteractionAltCurrencyPurchase", not ShouldPurchaseButtonBeEnabled() )
        end
    end
end

function EA_Window_InteractionAltCurrency.OnInventorySlotUpdated( updatedSlots )
    EA_Window_InteractionAltCurrency.OnGenericSlotUpdated( EA_Window_Backpack.TYPE_INVENTORY, updatedSlots )
end

function EA_Window_InteractionAltCurrency.OnCraftingSlotUpdated( updatedSlots )
    EA_Window_InteractionAltCurrency.OnGenericSlotUpdated( EA_Window_Backpack.TYPE_CRAFTING, updatedSlots )
end

function EA_Window_InteractionAltCurrency.OnCurrencySlotUpdated( updatedSlots )
    EA_Window_InteractionAltCurrency.OnGenericSlotUpdated( EA_Window_Backpack.TYPE_CURRENCY, updatedSlots )
end

function EA_Window_InteractionAltCurrency.OnGenericSlotUpdated( backpackType, updatedSlots )
    local altCurrencyType = EA_Window_InteractionAltCurrency.currentItemData.altCurrency[1].type
    local items = EA_Window_Backpack.GetItemsFromBackpack( backpackType )
    
    for _, slot in ipairs(updatedSlots)
    do
        local itemData = items[slot]
        
        local didFind = false
        for rowNum, itemInfo in ipairs(EA_Window_InteractionAltCurrency.displayData)
        do
            if ( ( itemInfo.backpackType == backpackType ) and ( itemInfo.slotNum == slot ) )
            then
                -- If this row is selected, deselect it. Because the item has changed, the row may refer to a different item entirely.
                if ( EA_Window_InteractionAltCurrency.selectedItemIndex == rowNum )
                then
                    EA_Window_InteractionAltCurrency.selectedItemIndex = 0
                    ButtonSetDisabledFlag( "EA_Window_InteractionAltCurrencyPurchase", true )
                end
                
                if ( DataUtils.IsValidItem( itemData ) and ( itemData.uniqueID == altCurrencyType ) )
                then
                    -- This slot is still valid but may have changed. Update the slot data.
                    EA_Window_InteractionAltCurrency.displayData[rowNum] = GetDisplayInfo( backpackType, slot, itemData )
                else
                    -- This slot is no longer valid. Remove it from the list.
                    table.remove( EA_Window_InteractionAltCurrency.displayData, rowNum )
                end
                
                RefreshListBox()
                didFind = true
                break
            end
        end
        
        if ( not didFind )
        then
            -- We didn't already have this in the list, thus it's probably new and needs to be added
            if ( DataUtils.IsValidItem( itemData ) and ( itemData.uniqueID == altCurrencyType ) )
            then
                table.insert( EA_Window_InteractionAltCurrency.displayData, GetDisplayInfo( backpackType, slot, itemData ) )
                RefreshListBox()
            end
        end
    end
end