----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

ItemEnhancementWindow = {}
ItemEnhancementWindow.isOpen = false

ItemEnhancementWindow.enhancedItem = nil

ActiveTemporaryEnhacements = {}

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

local g_enhInvSlots                 = { }
local g_readyForCursorUpdate        = false
local g_reanchorEnhSlots            = true
local g_clickedEnhSlotId            = 0
local c_SAVE_ORIGINAL_INV_SLOTS     = true
local c_EXCLUDE_ORIGINAL_INV_SLOTS  = false
local c_DEFAULT_ICON_BUTTON_WIDTH   = 55   -- NOTE: Define here, or extract from a function call?  (Or other file?)
local c_ENH_H_SLOT_SPACING          = 20
local c_ENH_V_SLOT_SPACING          = -40

----------------------------------------------------------------
-- Local Functions
----------------------------------------------------------------

--[[
    Reanchors, and shows/hides the enhancement slot windows to match the
    number of enhancement slots on the item.
--]]
local function ReAnchorSlots (itemData)
    --local curItemWin    = "ItemEnhancementWindowCurrentItem"
	--local curItemWin    = "ItemEnhancementWindowItemName"
	local anchorWindow	= "ItemEnhancementWindowSeperator"
    local curEnhSlot    = "ItemEnhancementWindowSlot"
    local numEnhSlots   = itemData.numEnhancementSlots

    -- Determine the offset of the initial slot based on the number
    -- of total enhancement slots on the item.        
    local itemWidth, itemHeight = WindowGetDimensions (anchorWindow)
    local totalSlotWidth = (numEnhSlots * c_DEFAULT_ICON_BUTTON_WIDTH) + ((numEnhSlots - 1) * c_ENH_H_SLOT_SPACING)
    local centeredAnchor = (itemWidth - totalSlotWidth) / 2

    for i = 1, GameDefs.MAX_ITEM_ENHANCEMENT_SLOTS do
        WindowClearAnchors (curEnhSlot..i)
        WindowSetShowing (curEnhSlot..i, false)
        WindowSetShowing (curEnhSlot..i.."Id", false)
    end

    -- There's always at least one anchor...
	WindowAddAnchor (curEnhSlot.."1", "topleft", anchorWindow, "bottomleft", centeredAnchor, c_ENH_V_SLOT_SPACING)
    WindowSetShowing (curEnhSlot.."1", true)
    WindowSetShowing (curEnhSlot.."1Id", true)

    -- Then anchor the rest of the enhancement slots to this window
    -- Except that these just anchor left to right...
    for i = 2, itemData.numEnhancementSlots do
        WindowAddAnchor (curEnhSlot..i, "right", curEnhSlot..(i - 1), "left", c_ENH_H_SLOT_SPACING, 0)
        WindowSetShowing (curEnhSlot..i, true)
        WindowSetShowing (curEnhSlot..i.."Id", true)
    end

    -- And finally...tell the system that no more re-anchoring is necessary...
    g_reanchorEnhSlots = false
end

--[[
    Takes a snapshot of the enhancement inventory slots of the item being enhanced
    
    The inventory slots refer to which slots in the player's inventory the
    slotted enhancements come from.
    
    If the inventory slot of an enhancement slot's item is 0, that means 
    the enhancement slotted there is fused to the item, and cannot be changed.
    
    This is not confusing at all.
--]]
local function SaveEnhancementInvSlots (itemData)

    if (g_reanchorEnhSlots) then
        ReAnchorSlots (itemData)
    end
    
    local enableFuse = false

    for i = 1, GameDefs.MAX_ITEM_ENHANCEMENT_SLOTS do
        g_enhInvSlots[i] = 0
        
        if ((itemData                          ~= nil) and
            (itemData.enhSlot                  ~= nil) and
            (itemData.enhSlot[i]               ~= nil) and
            (itemData.enhSlot[i].inventorySlot ~= nil))
        then
            g_enhInvSlots[i] = itemData.enhSlot[i].inventorySlot
        end
        
        if (g_enhInvSlots[i] > 0) then enableFuse = true end
    end
    
    -- If the player slotted something that can be removed, enable the fusion!!!!
    ButtonSetDisabledFlag ("ItemEnhancementWindowFuseEnhancements", not enableFuse)
end

--[[
    DESTROY....RAWR!
--]]
local function ClearEnhancementInvSlots ()

    g_reanchorEnhSlots  = true
    g_clickedEnhSlotId  = 0
    
    for i = 1, GameDefs.MAX_ITEM_ENHANCEMENT_SLOTS do
        g_enhInvSlots[i] = 0
        DynamicImageSetTexture ("ItemEnhancementWindowSlot"..i.."Icon", "", 0, 0)
    end
end

--[[
    Displays the enhancement item's current stats in the item readout
    Re-anchor (and show or hide) the item's enhancement slots based on what
    the item currently looks like.
    
    Not doing anything more than just setting the name and the enhancement slots
    for now...no stat info...
--]]
local function UpdateEnhancementDisplay(enhItem)

    -- Set the name of the item the user is currently enhancing at the top of the dialog...
    LabelSetText("ItemEnhancementWindowItemName", enhItem.name)
    
    -- Create the tooltip...
	Tooltips.CreateCustomItemTooltip (enhItem, "ItemEnhancementWindowScrollWindowChildItemInfo")
   
	-- Since this item's data is actually contained within the Item Enhancemnet Window, we want to readjust some stuff
	-- Hide the Title, Icon, Frame, and Name. I don't know why, but this window was setup to not use these 4 elements.
	WindowSetShowing("ItemEnhancementWindowScrollWindowChildItemInfoTitle", false)
	WindowSetShowing("ItemEnhancementWindowScrollWindowChildItemInfoIcon", false)
	WindowSetShowing("ItemEnhancementWindowScrollWindowChildItemInfoFrame", false)
	WindowSetShowing("ItemEnhancementWindowScrollWindowChildItemInfoName", false)

	-- Clear the anchors to the unused elements since we don't want them to mess up the scroll window calculations
	WindowClearAnchors("ItemEnhancementWindowScrollWindowChildItemInfoTitle")
	WindowClearAnchors("ItemEnhancementWindowScrollWindowChildItemInfoIcon")
	WindowClearAnchors("ItemEnhancementWindowScrollWindowChildItemInfoFrame")
	WindowClearAnchors("ItemEnhancementWindowScrollWindowChildItemInfoName")

	-- Reanchor the item slot name to be in the top left corner.
	WindowClearAnchors("ItemEnhancementWindowScrollWindowChildItemInfoSlot")
	WindowAddAnchor("ItemEnhancementWindowScrollWindowChildItemInfoSlot", "topleft", "ItemEnhancementWindowScrollWindowChildItemInfoBackground", "topleft", 0, 5)

    -- Make the enhancement slot window have the icon of the correct enhancement.
    --
    -- TODO: Display it as "locked down" if it's the original enhancement (inv slot == 0)
    --
        
    for i = 1, enhItem.numEnhancementSlots do
        local texture = ""
        local x = 0
        local y = 0
        
        if ((enhItem ~= nil)                    and
            (enhItem.enhSlot ~= nil)            and
            (enhItem.enhSlot[i] ~= nil)         and
            (enhItem.enhSlot[i].iconNum ~= nil) and
            (enhItem.enhSlot[i].iconNum > 0)) 
        then 
            texture, x, y = GetIconData (enhItem.enhSlot[i].iconNum)
        end
        
        local iconWin = "ItemEnhancementWindowSlot"..i.."Icon"
        
        DynamicImageSetTexture (iconWin, texture, x, y)
        
        if ((enhItem ~= nil)                            and
            (enhItem.enhSlot ~= nil)                    and
            (enhItem.enhSlot[i] ~= nil)                 and
            (enhItem.enhSlot[i].inventorySlot ~= nil)   and
            (enhItem.enhSlot[i].inventorySlot == 0)) 
        then 
            WindowSetTintColor (iconWin, 75, 75, 75)
        else
            WindowSetTintColor (iconWin, 255, 255, 255)
        end
    end

    ScrollWindowSetOffset( "ItemEnhancementWindowScrollWindow", 0 )
    ScrollWindowUpdateScrollRect("ItemEnhancementWindowScrollWindow")

    -- This will call the timer check at least once. If there 
    --   are no timers, or they all expire then it will deregister itself
    --Tooltips.SetUpdateCallback( UpdateEnhancementDurations )
        
    -- Finally, signal that the system is ready for a cursor update 
    -- (if one needs to be performed.)
    g_readyForCursorUpdate = true
end


--[[
    Called to refresh the counter if any of the enhancements have a duration.
--]]
function UpdateEnhancementDurations (timePassed)

    local timerChanged = false
    local enhItem = ItemEnhancementWindow.enhancedItem
    for i = 1, enhItem.numEnhancementSlots do
        local enhSlot = enhItem.enhSlot[i]
        if enhSlot ~= nil then
        
            for ixEnhSlotBonus, bonus in ipairs(enhSlot.bonus) do
                if bonus.duration > 0 then
                    bonus.duration = bonus.duration - timePassed
                    if bonus.duration < 0 then
                        bonus.duration = 0
                    end
            
                    -- TODO: only set this if actual number of seconds change
                    --   since we aren't displaying millis
                    timerChanged = true
                end
            end
        end
    end    
    
    if timerChanged then
        UpdateEnhancementDisplay (enhItem)
    else
        Tooltips.SetUpdateCallback( nil )
    end

end

--[[
    Convenience function to determine whether or not the cursor is holding:
        1. An item from the player's inventory of ANY type
        2. An enhancement item from the player's inventory
        
    NOTE: Not moving this into Cursor.lua because its use is fairly specialized at this point.
    
    Returned as two seperate booleans
--]]
local function GetCursorItemType ()
    if (Cursor.IconOnCursor ()) then
        local cursorHasInventoryItem    = (Cursor.Data.Source == Cursor.SOURCE_INVENTORY)
        local cursorHasEnhItem          = false

        if (cursorHasInventoryItem) then
            local inventoryData = DataUtils.GetItems ()
            cursorHasEnhItem = (inventoryData[Cursor.Data.SourceSlot].type == GameData.ItemTypes.ENHANCEMENT)
        end  
        
        return cursorHasInventoryItem, cursorHasEnhItem
    else
        return false, false
    end
end

--[[
    Diffs the actual enhancement item (enhItem) against the slots' snapshot
    to see if the cursor image should drop what it's holding, or pick up a slot.
    
    This should be called in between the enhItem update and the slot snapshot update.
--]]
local function UpdateCursor (enhItem, enhSlotId)
    if (g_readyForCursorUpdate) then
    
        local cursorHoldsInv, cursorHoldsEnh = GetCursorItemType ()
        
        if (cursorHoldsInv) then
            if (cursorHoldsEnh) then 
                for i = 1, enhItem.numEnhancementSlots do
                    -- If the item being enhanced has an enhancement slotted here of the same
                    -- iconNum, then the item you're holding will drop off the cursor, but the intended
                    -- effect won't happen...
                    if ((enhItem.enhSlot            ~= nil) and
                        (enhItem.enhSlot[i]         ~= nil) and
                        (enhItem.enhSlot[i].iconNum ~= nil) and
                        (Cursor.Data.IconId         == enhItem.enhSlot[i].iconNum))
                    then
                        Cursor.Clear ()
                        return
                    end
                end

                -- This means that item getting enhanced was not updated with the item the cursor contains.
                --DEBUG (L"ItemEnhancementWindow: Unable to find enhancement icon that matches cursor data!")
            end
        else
        
            if (g_clickedEnhSlotId < 1) then
                return
            end
                   
            local invSlot = g_enhInvSlots[g_clickedEnhSlotId]
            local invItem = DataUtils.GetItems()[invSlot]
            
            if (invSlot == 0 or invItem == nil or invItem.id == nil or invItem.iconNum == nil) then
                return
            end
            
            Cursor.PickUp (Cursor.SOURCE_INVENTORY, invSlot, invItem.id, invItem.iconNum, true)
            
            -- Force pick up...
            Cursor.OnLButtonDownProcessed ()
            Cursor.PickupTimer = -1
            Cursor.Update (0)
        end
    end
    
    g_readyForCursorUpdate = false
end

--[[
    Echoes some error text to the screen (may also revert backpack
    slot info, if we end up going that way.)
    
    FIXME: Is there a better way to get the error text in red without using
    the COMBAT text type?  Maybe add an error type to Alert Text?
--]]
local function EnhancementPlacementError (stringID)
    AlertTextWindow.AddLine (SystemData.AlertText.Types.COMBAT, GetString (stringID))
end


----------------------------------------------------------------
-- ItemEnhancement Functions
----------------------------------------------------------------

-- OnInitialize Handler
function ItemEnhancementWindow.Initialize()        
            
    WindowRegisterEventHandler ("ItemEnhancementWindow", SystemData.Events.UPDATE_ITEM_ENHANCEMENT, "ItemEnhancementWindow.UpdateEnhancement")
    WindowRegisterEventHandler ("ItemEnhancementWindow", SystemData.Events.END_ITEM_ENHANCEMENT, "ItemEnhancementWindow.EndItemEnhancement")
        
    -- Label/Button Text
    LabelSetText ("ItemEnhancementWindowTitleBarText", GetString (StringTables.Default.LABEL_ENHANCE_ITEM))
    ButtonSetText ("ItemEnhancementWindowFuseEnhancements", GetString (StringTables.Default.LABEL_FUSE_ENHANCEMENTS))
    
    -- Customize the tooltip window with settings that we can't override from the XML definition.
    
    -- FIXME: This really hints at the need to be able to set ANY window attributes from
    -- lua and have those changes propagate to the interface immediately, without need for calling
    -- window updates.  (Even though something like this will rely on a meta-table to make the call transparently.)
    
    -- This is what I would like to specify in the XML: (changed from the original tooltip)
    -- <Label ... font="another font" ... wordwrap="true"... />
    
	local c_TOOLTIP_BASE = "ItemEnhancementWindowScrollWindowChildItemInfo"
    
    WindowSetShowing (c_TOOLTIP_BASE.."Name",       false)
    WindowSetShowing (c_TOOLTIP_BASE.."Icon",       false)
    WindowSetShowing (c_TOOLTIP_BASE.."Frame",      false)
    WindowSetShowing (c_TOOLTIP_BASE.."Background", false)
    
    -- For now, hide ANY item set data, because this is the most likely culprit of
    -- data explosion which will result in tons of dangling text...which everyone hates.
    -- If any time is SCHEDULED to fix this, we can make the window resize, but I 
    -- personally think that's a bad idea.
    WindowSetShowing (c_TOOLTIP_BASE.."Set",    false)
    ItemEnhancementWindow.isOpen = false
    ItemEnhancementWindow.enhancedItem = GetCurrentEnhancementItemData()
end

--[[
    Event Handler: SystemData.Events.UPDATE_ITEM_ENHANCEMENT
    
    Displays the enhancement window, pulls the current item to
    operate on from GameData.Player.CurrentEnhancementItem
    Takes a snapshot of the item being enhanced so it knows
    how to handle addition/removal of enhancement items

    (currently items can only be enhanced from the backpack...
    if we use the server idea of slots we can enhance items
    from the paper doll window as well.)
--]]
function ItemEnhancementWindow.UpdateEnhancement ()

    ItemEnhancementWindow.enhancedItem = GetCurrentEnhancementItemData()
    if (ItemEnhancementWindow.isOpen == false) then
          
        ClearEnhancementInvSlots ()
    
        WindowSetShowing ("ItemEnhancementWindow", true)
               
        ItemEnhancementWindow.isOpen = true        
    end
    
    ItemEnhancementWindow.UpdateItem ()
end

--[[
    Looks at GameData.Player.CurrentEnhanceItem to update the 
    contents of the enhancement window
--]]
function ItemEnhancementWindow.UpdateItem ()

    ItemEnhancementWindow.enhancedItem = GetCurrentEnhancementItemData()
    local enhItem = ItemEnhancementWindow.enhancedItem
    
    UpdateEnhancementDisplay (enhItem)
    UpdateCursor (enhItem)
    SaveEnhancementInvSlots (enhItem)
end

--[[
    Event Handler: SystemData.Events.END_ITEM_ENHANCEMENT
    
    When the server sends this, hide the enhancement window
    The item unlocks should be performed as a result
    of other updates    
--]]
function ItemEnhancementWindow.EndItemEnhancement ()
    if( WindowGetShowing("ItemEnhancementWindow") ) then
        WindowSetShowing ("ItemEnhancementWindow", false)
    end
    ItemEnhancementWindow.isOpen = false
end

function ItemEnhancementWindow.OnHidden()
    WindowUtils.OnHidden()
    EndItemEnhancement()
end


--[[
    Tells the server that you want to stop enhancing this item
    This is NOT the event handler.  This is what gets called in response
    to you pressing the CLOSE button or hitting escape.
--]]
function ItemEnhancementWindow.Hide ()        
    EndItemEnhancement ()
end

--[[
    Fuses the slotted enhancements to the item, melding them with eternity...
    I mean, destroying them in your inventory, but hey, you get a more powerful
    item as a result...so that's a good thing.
    
    This will NOT send the request to the server if the client does not believe
    the item to be enhanceable.  (If nothing has been slotted!)
--]]
function ItemEnhancementWindow.FuseEnhancements ()
    for i = 1, GameDefs.MAX_ITEM_ENHANCEMENT_SLOTS do
        if (g_enhInvSlots[i] > 0) then
            FuseItemEnhancements ()
            return
        end
    end
end

--[[
    NOTE: None of this will lock down (grey-out) inventory items...
    going to test what happens on the server when something is slotted,
    and then attempt to move it in the inventory.
    
    A. If there is some random piece of whatever on the mouse cursor
       (an ability, a random inventory item, gold, etc...)
         1. Echoes an error message about the fact that you must place
            enhancement items here.
         2. Returns        
        
    B. If there is an enhancement on the mouse cursor:
         1. Sends an add enhancement message to the server with the cursor's current inv slot
         (2.) Previous slot will get saved off WHEN the server responds to the request...don't drop anything yet.

    C. If there is nothing on the mouse cursor:    
         If a non-fused enhancement is in the slot:
            1. Picks it up (puts it on the mouse cursor)
            2. Puts the PREVIOUS enhancement back into the slot 
               (Maintained on a per-slot basis, and can be empty)
            3. Sends a remove enhancement to the server
--]]
function ItemEnhancementWindow.SlotLButtonUp (flags, x, y)    
    
    g_clickedEnhSlotId = WindowGetId (SystemData.ActiveWindow.name)
    
    local cursorHoldsInv, cursorHoldsEnh = GetCursorItemType ()
    
    if (cursorHoldsInv) then    
        if (cursorHoldsEnh) then
            local itemEquipSlot = ItemEnhancementWindow.enhancedItem.equipSlot
            local currentBackpack = EA_BackpackUtilsMediator.GetCurrentBackpackType()
            local inventoryData = EA_BackpackUtilsMediator.GetItemsFromBackpack( currentBackpack )
            local enhancementData = inventoryData[Cursor.Data.SourceSlot]
            if DataUtils.SlotIsAllowedForItem(itemEquipSlot, enhancementData) then
                -- Request that the server slot this enhancement here (and calculate bonus, etc...)
                -- When the next item update arrives, it will be used to determine what to do
                -- with the icon on the cursor.
                AddItemEnhancement (g_clickedEnhSlotId, Cursor.Data.SourceSlot)
            else
                EnhancementPlacementError (StringTables.Default.INVALID_LOCATION)
            end
            
        else
            EnhancementPlacementError (StringTables.Default.TEXT_ENHANCEMENT_PLACEMENT_ERROR)
        end
    else
        -- Only request a removal of the enhancement item if it has an inventory slot greater than 0.
        -- (That's what signals it as removable)
        local enhItem = ItemEnhancementWindow.enhancedItem
               
        if (enhItem.enhSlot[g_clickedEnhSlotId].inventorySlot > 0) then
            RemoveItemEnhancement (g_clickedEnhSlotId)
        end        
    end
end

--[[
    Shows a tooltip about the current enhancement in this slot.
    
    Just showing the name for now...
    
    TODO: Create a custom "EnhancementTooltip" and use that one:
    Tooltips.CreateEnhancementTooltip (enhItem.enhSlot[enhSlotId])
    
    Yay!
--]]
function ItemEnhancementWindow.SlotMouseOver (flags, x, y)

    local enhSlotId = WindowGetId (SystemData.ActiveWindow.name)
    
    if (enhSlotId < 1) then
        return
    end
    
    local enhSlotWin    = "ItemEnhancementWindowSlot"..enhSlotId
    local enhItem       = ItemEnhancementWindow.enhancedItem
    local tooltipText   
    
    if ((enhItem == nil)                            or 
        (enhItem.enhSlot == nil)                    or
        (enhItem.enhSlot[enhSlotId] == nil)         or
        (enhItem.enhSlot[enhSlotId].name == nil)    or 
        (enhItem.enhSlot[enhSlotId].name == L"")) 
    then
        tooltipText = GetString (StringTables.Default.LABEL_EMPTY_ENHANCEMENT_SLOT)
    else
        tooltipText = enhItem.enhSlot[enhSlotId].name
    end
    
    Tooltips.CreateTextOnlyTooltip (enhSlotWin, tooltipText)
    Tooltips.AnchorTooltip (Tooltips.ANCHOR_WINDOW_VARIABLE) 
end


--[[
    there's no real restriction on what type item is as long as it's non-nil 
    bonus must be a table containing a field duration.
    
    If this particular bonus already exists, you should use a different method
    to change it. This method will simply add it again.
--]]
function ActiveTemporaryEnhacements.AddEnhancement( item, bonus )

    if item == nil or bonus == nil or bonus.duration == nil then
        return
    end
    
    local bonuses = ActiveTemporaryEnhacements[item] or {}
    table.insert(bonuses, bonus)
    
end

function ActiveTemporaryEnhacements.GetEnhancementDuration( item, bonus )

    if item == nil or bonus == nil or ActiveTemporaryEnhacements[item] == nil then
        return
    end
    
    local bonuses = ActiveTemporaryEnhacements[item]
    
    for k, _bonus in pairs(bonuses) do
        if _bonus == bonus then
            return bonus.duration
        end
    end
end

-- Counts down the timer of each temporary enhancement
function ActiveTemporaryEnhacements.UpdateEnhancementDurations (timePassed)


    for item, bonuses in pairs(ActiveTemporaryEnhacements) do
        
        for k, bonus in pairs(bonuses) do
            bonus.duration = bonus.duration - timePassed
            if bonus.duration < 0 then
                bonuses[k] = nil
            end
        end
        if table.getn(bonuses) == 0 then
            ActiveTemporaryEnhacements[item] = nil
        end
    end
end
