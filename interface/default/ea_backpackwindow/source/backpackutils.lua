----------------------------------------------------------------
-- Backpack Utils
--
-- This file contains Util Functions that are shared across the 
-- the backpack views.
----------------------------------------------------------------

EA_Window_Backpack.CRAFTING_TYPE_APOTHECARY = 1
EA_Window_Backpack.CRAFTING_TYPE_TALISMAN_MAKING = 2
EA_Window_Backpack.CRAFTING_TYPE_CULTIVATING = 3

-------------------------------------------------------------------------
-- General Util Functions
-------------------------------------------------------------------------

function EA_Window_Backpack.ReportFullBackpack()
    local errorText = GetStringFromTable( "BackpackStrings",  StringTables.Backpack.ERROR_PLAYER_INVENTORY_FULL )
    EA_ChatWindow.Print(errorText, SystemData.ChatLogFilters.SAY)
end

function EA_Window_Backpack.ReportInventorySlotOccupied()
    local errorText = GetStringFromTable( "BackpackStrings",  StringTables.Backpack.ERROR_PLAYER_INVENTORY_SLOT_OCCUPIED )
    EA_ChatWindow.Print(errorText, SystemData.ChatLogFilters.SAY)
end

function EA_Window_Backpack.ValidItem( itemData )
    return ( itemData ~= nil and ( (itemData.uniqueID ~= 0) or (itemData.type == GameData.ItemTypes.QUEST ) ) )
end

-------------------------------------------------------------------------
-- Util Functions for supporting multiple backpack inventories
-------------------------------------------------------------------------

function EA_Window_Backpack.GetItemsFromBackpack( backpackType )
    if( backpackType == EA_Window_Backpack.TYPE_QUEST )
    then
        return DataUtils.GetQuestItems()
    elseif( backpackType == EA_Window_Backpack.TYPE_INVENTORY )
    then
        return DataUtils.GetItems()
    elseif( backpackType == EA_Window_Backpack.TYPE_CURRENCY )
    then
        return DataUtils.GetCurrencyItems()
    elseif( backpackType == EA_Window_Backpack.TYPE_CRAFTING )
    then
        return DataUtils.GetCraftingItems()
    end    
    ERROR(L"Trying to get items from invalid backpack type")
end

function EA_Window_Backpack.GetCursorForBackpack( backpackType )
    if( backpackType == EA_Window_Backpack.TYPE_QUEST )
    then
        return Cursor.SOURCE_QUEST_ITEM
    elseif( backpackType == EA_Window_Backpack.TYPE_INVENTORY )
    then
        return Cursor.SOURCE_INVENTORY
    elseif( backpackType == EA_Window_Backpack.TYPE_CURRENCY )
    then
        return Cursor.SOURCE_CURRENCY_ITEM
    elseif( backpackType == EA_Window_Backpack.TYPE_CRAFTING )
    then
        return Cursor.SOURCE_CRAFTING_ITEM
    end    
    ERROR(L"Trying to get a cursor from invalid backpack type")
end

function EA_Window_Backpack.GetCurrentBackpackType()
    return EA_Window_Backpack.currentMode
end

----------------------------------
-- Item Refinement Functions
--

function EA_Window_Backpack.IsRefinable( itemData )

    return ( itemData ~= nil and itemData.isRefinable )
end

-- This function already assumes the item is refinable
function EA_Window_Backpack.GetRefinementInstruction( itemData )
    
    -- It turns out that we now have more refinable APOTHECARY items other than plants that can be reaped.
    --   In the near future we hope to have a refinement type field so that the strings can be more specific again.
    --[[
    if DataUtils.IsTradeSkillItem( itemData, GameData.TradeSkills.APOTHECARY ) then
        return GetStringFromTable( "BackpackStrings", StringTables.Backpack.PLANT_REAPING_HELP_TEXT )
    else
        return GetStringFromTable( "BackpackStrings", StringTables.Backpack.DEFAULT_REFINING_HELP_TEXT )
    end    
	--]]
    
    return GetStringFromTable( "BackpackStrings", StringTables.Backpack.DEFAULT_REFINING_HELP_TEXT )
end


-- This function already assumes the item is refinable
function EA_Window_Backpack.GetRefinementConfirmationText( itemData )
    
    -- It turns out that we now have more refinable APOTHECARY items other than plants that can be reaped.
    --   In the near future we hope to have a refinement type field so that the strings can be more specific again.
    --[[
    if DataUtils.IsTradeSkillItem( itemData, GameData.TradeSkills.APOTHECARY ) and itemData.name ~= nil then
        return GetFormatStringFromTable( "BackpackStrings", StringTables.Backpack.PLANT_REAPING_CONFIRMATION_TEXT, { itemData.name } )
    else
        return GetStringFromTable( "BackpackStrings", StringTables.Backpack.DEFAULT_REFINING_CONFIRMATION_TEXT )
    end    
	--]]
    
    if( itemData.type == GameData.ItemTypes.CURRENCY ) 
    then
        return GetStringFromTable( "BackpackStrings", StringTables.Backpack.CURRENCY_REFINING_CONFIRMATION_TEXT )
    end    
    return GetStringFromTable( "BackpackStrings", StringTables.Backpack.DEFAULT_REFINING_CONFIRMATION_TEXT )
end



function EA_Window_Backpack.ConfirmThenRefine( slot, backpackType )

    local inventory = EA_Window_Backpack.GetItemsFromBackpack( backpackType )
    local itemData = inventory[slot]
    
    local warningType
    if( itemData.type == GameData.ItemTypes.CURRENCY )
    then
        warningType = SystemData.Settings.DlgWarning.WARN_REFINEMENT_CURRENCY
    else
        warningType = SystemData.Settings.DlgWarning.WARN_REFINEMENT
    end
    
    local warnBeforeRefine = SystemData.Settings.ShowWarning[warningType]

    if warnBeforeRefine then
        EA_Window_Backpack.ShowRefineConfirm( slot, backpackType )
    else
        EA_Window_Backpack.refineItemSlot = slot
        EA_Window_Backpack.refineBackpack = backpackType
        EA_Window_Backpack.RefineItem()
    end
end

function EA_Window_Backpack.ShowRefineConfirm( slot, backpackType )

    EA_Window_Backpack.refineItemSlot = slot
    EA_Window_Backpack.refineBackpack = backpackType
    local inventory = EA_Window_Backpack.GetItemsFromBackpack( EA_Window_Backpack.currentMode )
    local itemData = inventory[slot]
    
    local warningFunction
    if( itemData.type == GameData.ItemTypes.CURRENCY )
    then
        warningFunction = EA_Window_Backpack.ToggleWarnBeforeRefiningCurrency
    else
        warningFunction = EA_Window_Backpack.ToggleWarnBeforeRefiningCrafting
    end
        
    DialogManager.MakeTwoButtonDialog( EA_Window_Backpack.GetRefinementConfirmationText( itemData ), 
                                       GetString (StringTables.Default.LABEL_YES), EA_Window_Backpack.RefineItem, 
                                       GetString (StringTables.Default.LABEL_NO), nil,
                                       nil, nil, false, warningFunction ) 
end

function EA_Window_Backpack.RefineItem()

    if( EA_Window_Backpack.refineItemSlot and EA_Window_Backpack.refineBackpack )
    then
        local location = EA_Window_Backpack.GetCursorForBackpack( EA_Window_Backpack.refineBackpack )
        SendUseItem( location, EA_Window_Backpack.refineItemSlot, 0, 0, 0)
        EA_Window_Backpack.refineItemSlot = nil
        EA_Window_Backpack.refineBackpack = nil
    end
end

function EA_Window_Backpack.ToggleWarnBeforeRefining( warningType )

    local curVal = SystemData.Settings.ShowWarning[warningType]
    SystemData.Settings.ShowWarning[warningType] = not curVal
    
    if WindowGetShowing( "SettingsWindowTabbed") == true then
        SettingsWindowTabGeneral.UpdateDialogWarnings( warningType )
    end
    
    BroadcastEvent( SystemData.Events.USER_SETTINGS_CHANGED )
end

function EA_Window_Backpack.ToggleWarnBeforeRefiningCurrency()
    EA_Window_Backpack.ToggleWarnBeforeRefining( SystemData.Settings.DlgWarning.WARN_REFINEMENT_CURRENCY )
end

function EA_Window_Backpack.ToggleWarnBeforeRefiningCrafting()
    EA_Window_Backpack.ToggleWarnBeforeRefining( SystemData.Settings.DlgWarning.WARN_REFINEMENT )
end

-------------------------------------------------------------------------
-- Button Handlers
-------------------------------------------------------------------------


function EA_Window_Backpack.MouseOverEquipmentSlot( slot, mouseOverWindowName )
    local inventory = EA_Window_Backpack.GetItemsFromBackpack( EA_Window_Backpack.currentMode )
    EA_Window_Backpack.DisplayItemTooltip( inventory[slot], mouseOverWindowName )
end
      
function EA_Window_Backpack.DisplayItemTooltip( itemData, mouseOverWindowName )
                
    if not EA_Window_Backpack.ValidItem( itemData ) then         
        --Tooltips.ClearTooltip()   
    else 
        -- If a store is open, and right clicking would sell, let the player know by putting extra text in the in the tooltip...
        --
        -- If the item is enhanceable, and the player is NOT at a store (stop selling before enhancing)
        -- then show how to begin the enhancement process.
        local actionText            = nil
        local textColor             = nil
        local atStore               = EA_Window_InteractionStore.InteractingWithStore() or EA_Window_InteractionLibrarianStore.InteractingWithLibrarianStore()
        local atRepairMan           = EA_Window_InteractionStore.InteractingWithRepairMan() or EA_Window_InteractionLibrarianStore.InteractingWithRepairMan()
        local isBattleMap           = (itemData.uniqueID == EA_Window_Backpack.BATTLE_MAP_ID)
        local isSalvagable          = SalvagingWindow.IsSalvagableItem( itemData )
        local inSalvageMode         = SalvagingWindow.CurrentlyInSalvageMode()
               
        if (mouseOverWindowName == EA_Window_Backpack.OVERFLOW_ITEM_ICON)
        then
            actionText      = GetStringFromTable( "BackpackStrings",  StringTables.Backpack.OVERFLOW_HELP_TEXT )
            textColor       = Tooltips.COLOR_ACTION
            
        elseif (inSalvageMode and isSalvagable)
        then
            actionText, textColor = SalvagingWindow.GetSalvagingDifficultyForItem( itemData )
            
        elseif (atRepairMan and itemData.broken)
        then
            actionText      = GetString (StringTables.Default.LABEL_CLICK_TO_REPAIR)
            textColor       = Tooltips.COLOR_WARNING
            
        elseif ( atStore and not atRepairMan )
        then
            actionText      = GetString (StringTables.Default.LABEL_RIGHT_CLICK_SELLS_ITEM)
            textColor       = Tooltips.COLOR_WARNING
        elseif( not atStore and not atRepairMan )
        then            
            local isTradeSkillItem      = DataUtils.IsTradeSkillItem( itemData, nil ) or itemData.type == GameData.ItemTypes.CRAFTING
            local isCurrencyItem        = ( itemData.type == GameData.ItemTypes.CURRENCY )
            local canAddCraftingItem    = EA_Window_Backpack.CanAddCraftingItem( itemData )
            local canAddEquipUpgradeItem = EquipmentUpgradeWindow and EquipmentUpgradeWindow.CanInsertItem( itemData )
            local isTeleportItem        = ( itemData.type == GameData.ItemTypes.TELEPORT )
            local isTeleportGroupItem   = ( itemData.type == GameData.ItemTypes.TELEPORT_GROUP )
            local isEnhanceable         = (itemData.numEnhancementSlots ~= 0) and not itemData.broken
                        
            if( EA_Window_Backpack.IsRefinable( itemData ) )
            then
                actionText      = EA_Window_Backpack.GetRefinementInstruction( itemData )
                textColor       = Tooltips.COLOR_ACTION
                
            elseif( isBattleMap )
            then
                actionText      = GetString (StringTables.Default.LABEL_BIND_LOCATION)
                actionText      = actionText..GetStringFromTable("BindLocations", GameData.Player.bindLocation)
                textColor       = Tooltips.COLOR_ACTION
            elseif( isTeleportItem )
            then
                actionText      = GetString( StringTables.Default.TOOLTIP_SUMMONING_STONE )
                textColor       = Tooltips.COLOR_ACTION
            elseif( isTeleportGroupItem )
            then
                actionText      = GetString( StringTables.Default.TOOLTIP_GROUP_SUMMONING_STONE )
                textColor       = Tooltips.COLOR_ACTION
            end
            
            -- The rest of the messages can exist at the same time as the previous ones
            if( canAddCraftingItem or canAddEquipUpgradeItem or isEnhanceable or isTradeSkillItem or isCurrencyItem )
            then
                if( actionText )
                then
                    actionText = actionText..L"<br>"
                else
                    actionText = L""
                end
                
                if ( canAddCraftingItem )
                then
                    actionText = actionText..GetString( StringTables.Default.LABEL_RIGHT_CLICK_ADDS_ITEM )
                elseif( canAddEquipUpgradeItem )
                then
                    actionText = actionText..GetString( StringTables.Default.LABEL_RIGHT_CLICK_ADDS_ITEM_TO_EQUIP_UPGRADE )
                elseif ( isEnhanceable )
                then
                    actionText = actionText..GetString( StringTables.Default.LABEL_RIGHT_CLICK_ENHANCES_ITEM )
                else
                    if( EA_Window_Backpack.currentMode == EA_Window_Backpack.TYPE_INVENTORY )
                    then
                        if( isTradeSkillItem )
                        then
                            actionText = actionText..GetString( StringTables.Default.LABEL_RIGHT_CLICK_MOVES_TO_CRAFTING )
                        else
                            actionText = actionText..GetString( StringTables.Default.LABEL_RIGHT_CLICK_MOVES_TO_CURRENCY )
                        end
                    else
                        actionText = actionText..GetString( StringTables.Default.LABEL_RIGHT_CLICK_MOVES_TO_MAIN )
                    end
                end
                
                textColor  = Tooltips.COLOR_ACTION
            end
        end            
        local anchorWindow = SystemData.ActiveWindow.name
        Tooltips.CreateItemTooltip( itemData, 
                                    mouseOverWindowName,
                                    Tooltips.ANCHOR_WINDOW_RIGHT, 
                                    Tooltips.ENABLE_COMPARISON, 
                                    actionText, textColor, false )

        if atStore and ( atRepairMan == itemData.broken ) then
            Tooltips.ShowSellPrice (itemData)
        end
        
        if Cursor.UseItemTargeting then 
            UseItemTargeting.HandleMouseOverItem( itemData )
        end
    end
    
end



-- TODO: this should really be abstracted out, e.g. by notifying the Cursor table and
--    letting it take the appropriate action
function EA_Window_Backpack.MouseOverEquipmentSlotEnd()

    if GameData.InteractStoreData.LibrarianType == GameData.InteractStoreData.STORE_TYPE_DEFAULT
    then
        EA_Window_InteractionStore.OnMouseOverRepairableItemEnd()
    else
        EA_Window_InteractionLibrarianStore.OnMouseOverRepairableItemEnd()
    end
    UseItemTargeting.HandleMouseOverItemEnd()
end



-- OnLButtonDown Handler
function EA_Window_Backpack.EquipmentLButtonDown( slot, flags )
    local isInRepairMode    = EA_Window_InteractionStore.repairModeOn or EA_Window_InteractionLibrarianStore.repairModeOn
    
    local inventory = EA_Window_Backpack.GetItemsFromBackpack( EA_Window_Backpack.currentMode )
    local itemData = inventory[slot]

    local cursorType = EA_Window_Backpack.GetCursorForBackpack( EA_Window_Backpack.currentMode )
    
    -- short circuit this function if we're dropping an item from the merchant window (handled in LButtonUp handler)
    if EA_Window_InteractionStore.CursorIsCarryingMerchantItem() or EA_Window_InteractionLibrarianStore.CursorIsCarryingMerchantItem()
    then
        return
    end
    
    
    if (EA_Window_Backpack.IsSlotLocked(slot, EA_Window_Backpack.currentMode ) or isInRepairMode) then
        if( itemData and itemData.uniqueID ~= 0 and EA_Window_Backpack.softLocksEnabled ) then
            Cursor.PickUp( cursorType, slot, itemData.uniqueID, itemData.iconNum, true )
        end
        return
    end
    
    if Cursor.UseItemTargeting then
        --Attempt to use the target item on the selected slot
        UseItemTargeting.HandleUseItemOnTarget( cursorType, slot )
    elseif Cursor.IconOnCursor() then
        local slotMovingToIsLocked, _   = EA_Window_Backpack.IsSlotLocked( slot, EA_Window_Backpack.currentMode )
        local slotMovingFromIsLocked, _ = EA_Window_Backpack.IsSlotLocked( Cursor.Data.SourceSlot, EA_Window_Backpack.currentMode )
        
        -- don't bother sending a move item if we're dropping on the original slot. just clear the cursor
        if( Cursor.Data.Source == cursorType and Cursor.Data.SourceSlot == slot )
        then 
            Cursor.Clear()

		-- If dropping an item into the backpack from the Guild Vault, call the Guild Vault command to move the item
		elseif Cursor.Data.Source >= Cursor.SOURCE_GUILD_VAULT1 and Cursor.Data.Source <= Cursor.SOURCE_GUILD_VAULT5 then
		
			if( EA_Window_Backpack.currentlyInListView )
            then
				GuildVaultWindow.MoveItemFromGuildVaultToBackpack( Cursor.Data.Source - Cursor.SOURCE_GUILD_VAULT1 + 1, GameData.Inventory.FIRST_AVAILABLE_INVENTORY_SLOT, flags, EA_Window_Backpack.currentMode )
			else
				GuildVaultWindow.MoveItemFromGuildVaultToBackpack( Cursor.Data.Source - Cursor.SOURCE_GUILD_VAULT1 + 1, slot, flags, EA_Window_Backpack.currentMode )
			end
			GuildVaultWindow.dropPending = true

        -- if dropping item into list view then just auto place item
        elseif( EA_Window_Backpack.currentlyInListView )
        then
            RequestMoveItem( Cursor.Data.Source, Cursor.Data.SourceSlot, Cursor.SOURCE_INVENTORY, GameData.Inventory.FIRST_AVAILABLE_INVENTORY_SLOT, Cursor.Data.StackAmount )
            EA_Window_Backpack.dropPending = true
              
        -- Attempt to drop the object if the slots are not locked via the soft lock option 
        elseif( not slotMovingToIsLocked and not slotMovingFromIsLocked ) then        
            
            EA_Window_Backpack.ManuallyMoveItem( Cursor.Data.Source, Cursor.Data.SourceSlot, cursorType, slot, Cursor.Data.StackAmount )            
            EA_Window_Backpack.dropPending = true
        end
        
    elseif GetDesiredInteractAction() == SystemData.InteractActions.SALVAGE then
        -- Try to start salvaging
        SalvagingWindow.Salvage( slot )
    else
        if( itemData and itemData.uniqueID ~= 0 ) 
        then
        
            -- Create an Item Link on Shift-Left Click
            if( flags == SystemData.ButtonFlags.SHIFT)
            then
                EA_ChatWindow.InsertItemLink( itemData )
 
            -- Otherwise Just Pick up the item
            else
                Cursor.PickUp( cursorType, slot, itemData.uniqueID, itemData.iconNum, true)
            end
        end
        EA_Window_Backpack.dropPending = false
    end
        
end

-- OnLButtonUp Handler
function EA_Window_Backpack.EquipmentLButtonUp( slot )
    
    if Cursor.IconOnCursor() and EA_Window_Backpack.dropPending == false
    then
        --** These two lines should not need to be here, but something is disabling the backpack tab
        --** when moving an item into a backpack after clicking on a different backpack tab
        local tabName = EA_Window_Backpack.views[EA_Window_Backpack.currentMode].tabName
        ButtonSetPressedFlag( tabName, true )
        ButtonSetStayDownFlag( tabName, true )
        ---** 
        
        local cursorType = EA_Window_Backpack.GetCursorForBackpack( EA_Window_Backpack.currentMode )
        local slotMovingToIsLocked = EA_Window_Backpack.IsSlotLocked( slot, EA_Window_Backpack.currentMode )
        local slotMovingFromIsLocked = ( ( Cursor.Data.Source == cursorType ) and 
                                         EA_Window_Backpack.IsSlotLocked( Cursor.Data.SourceSlot, EA_Window_Backpack.currentMode ) )
        local sameSlot = ((Cursor.Data.Source == cursorType) and (Cursor.Data.SourceSlot == slot))

        if Cursor.Data.Source == Cursor.SOURCE_MERCHANT then
            if GameData.InteractStoreData.LibrarianType == GameData.InteractStoreData.STORE_TYPE_DEFAULT
            then
                EA_Window_InteractionStore.ConfirmThenBuyItem( Cursor.Data.SourceSlot, Cursor.Data.StackAmount )
            else
                EA_Window_InteractionLibrarianStore.ConfirmThenBuyItem( Cursor.Data.SourceSlot, Cursor.Data.StackAmount )
            end
            
		-- If dropping an item into the backpack from the Guild Vault, call the Guild Vault command to move the item
		elseif Cursor.Data.Source >= Cursor.SOURCE_GUILD_VAULT1 and Cursor.Data.Source <= Cursor.SOURCE_GUILD_VAULT5 then
		
		if( EA_Window_Backpack.currentlyInListView )
        then
			GuildVaultWindow.MoveItemFromGuildVaultToBackpack( Cursor.Data.Source - Cursor.SOURCE_GUILD_VAULT1 + 1, GameData.Inventory.FIRST_AVAILABLE_INVENTORY_SLOT, flags, EA_Window_Backpack.TYPE_INVENTORY )
		else
            GuildVaultWindow.MoveItemFromGuildVaultToBackpack( Cursor.Data.Source - Cursor.SOURCE_GUILD_VAULT1 + 1, slot, flags, EA_Window_Backpack.currentMode )
		end
			
        -- if dropping item into list view then just auto place item
        elseif( EA_Window_Backpack.currentlyInListView and not slotMovingFromIsLocked and not sameSlot )
        then
            RequestMoveItem( Cursor.Data.Source, Cursor.Data.SourceSlot, Cursor.SOURCE_INVENTORY, CharacterWindow.FIRST_AVAILABLE_INVENTORY_SLOT, Cursor.Data.StackAmount )
            
        elseif( not slotMovingFromIsLocked and not slotMovingToIsLocked and not sameSlot ) then
           
            -- Attempt to drop the object
            EA_Window_Backpack.ManuallyMoveItem( Cursor.Data.Source, Cursor.Data.SourceSlot, cursorType, slot, Cursor.Data.StackAmount )
        end
    end
end


function EA_Window_Backpack.IsCorrectCraftingWindowOpen( itemData )

    local isApothecaryWindowOpen =  WindowGetShowing("ApothecaryWindow") 
    local isTalismanMakingWindowOpen =  WindowGetShowing("TalismanMakingWindow") 
    local isCultivatingWindowOpen =  WindowGetShowing("CultivationWindow")
    
    local isApothecaryItem = DataUtils.IsTradeSkillItem( itemData, GameData.TradeSkills.APOTHECARY )
    local isTalismanMakingItem = DataUtils.IsTradeSkillItem( itemData, GameData.TradeSkills.TALISMAN )
    local isCultivatingItem = DataUtils.IsTradeSkillItem( itemData, GameData.TradeSkills.CULTIVATION )
    
    if isApothecaryWindowOpen and isApothecaryItem
    then
		return true, EA_Window_Backpack.CRAFTING_TYPE_APOTHECARY
		
    elseif isTalismanMakingWindowOpen and isTalismanMakingItem
    then
		return true, EA_Window_Backpack.CRAFTING_TYPE_TALISMAN_MAKING
		
    elseif isCultivatingWindowOpen and isCultivatingItem
    then
		return true, EA_Window_Backpack.CRAFTING_TYPE_CULTIVATING
		
	else
		return false, nil
	end
end

function EA_Window_Backpack.AutoAddCraftingItemIfPossible( slot )
    local inventory = EA_Window_Backpack.GetItemsFromBackpack( EA_Window_Backpack.currentMode )
    local itemData = inventory[slot]
	local windowIsOpen, callbackFunction = EA_Window_Backpack.GetCraftingWindowStatusAndAutoAddFunction( itemData )
	if( windowIsOpen and callbackFunction and itemData )
    then
		callbackFunction( slot, itemData, EA_Window_Backpack.currentMode )
        return true
	end
    return false
end

function EA_Window_Backpack.CanAddCraftingItem( itemData )
    local isOpen, craftingType = EA_Window_Backpack.IsCorrectCraftingWindowOpen( itemData )
    if( isOpen == false )
    then
        return false
        
    elseif ( craftingType == EA_Window_Backpack.CRAFTING_TYPE_APOTHECARY )
    then
		return ApothecaryWindow.WouldBePossibleToAdd( itemData )
        
    elseif ( craftingType == EA_Window_Backpack.CRAFTING_TYPE_TALISMAN_MAKING )
    then
		return TalismanMakingWindow.WouldBePossibleToAdd( itemData )
		
    elseif ( craftingType == EA_Window_Backpack.CRAFTING_TYPE_CULTIVATING )
    then
		return CultivationWindow.WouldBePossibleToAdd( itemData )
		
	else
		return false
	end
end

function EA_Window_Backpack.GetCraftingWindowStatusAndAutoAddFunction( itemData )
    local isOpen, craftingType = EA_Window_Backpack.IsCorrectCraftingWindowOpen( itemData )
   
    if ( craftingType == EA_Window_Backpack.CRAFTING_TYPE_APOTHECARY )
    then
		return isOpen, ApothecaryWindow.AutoAddItem
        
    elseif ( craftingType == EA_Window_Backpack.CRAFTING_TYPE_TALISMAN_MAKING )
    then
		return isOpen, TalismanMakingWindow.AutoAddItem
		
    elseif ( craftingType == EA_Window_Backpack.CRAFTING_TYPE_CULTIVATING )
    then
		return isOpen, CultivationWindow.AutoAddItem
		
	else
		return isOpen, nil
	end
    
end



-- OnRButtonUp Handler
function EA_Window_Backpack.EquipmentRButtonUp( slot, flags )

    local inventory = EA_Window_Backpack.GetItemsFromBackpack( EA_Window_Backpack.currentMode )
    local itemData = inventory[slot]
    -- If there's no item in this slot, do nothing
    if itemData == nil or itemData.id == nil or itemData.id == 0 then 
        return
    end
    
    local cursorType = EA_Window_Backpack.GetCursorForBackpack( EA_Window_Backpack.currentMode )
    
    local isEnhanceable       = (itemData.numEnhancementSlots > 0)
    local shiftPressed        = (flags == SystemData.ButtonFlags.SHIFT)
    local controlPressed      = (flags == SystemData.ButtonFlags.CONTROL)
    local atStore             = (EA_Window_InteractionStore and EA_Window_InteractionStore.InteractingWithStore ()) or
                                (EA_Window_InteractionLibrarianStore and EA_Window_InteractionLibrarianStore.InteractingWithLibrarianStore ())
    local atRepairMan         = EA_Window_InteractionStore.InteractingWithRepairMan() or EA_Window_InteractionLibrarianStore.InteractingWithRepairMan()
    local isTrading           = EA_Window_Trade.TradeOpen()
    local isMailing           = WindowGetShowing("MailWindow") and WindowGetShowing("MailWindowTabSend")
    local isBankOpen          = BankWindow.IsShowing()
    local isGuildVaultOpen    = GuildVaultWindow.IsVaultOpen()

    local isTradeSkillItem    = DataUtils.IsTradeSkillItem( itemData, nil ) or itemData.type == GameData.ItemTypes.CRAFTING
    local isCurrencyItem      = ( itemData.type == GameData.ItemTypes.CURRENCY )
    
    -- Things you can do when using backpack items while not at a store:
    -- 1. Equip the item (if equippable)
    -- 2. Enhance the item, (if enhanceable)
    -- 3. Use the item (left up to the server to determine if it's usable.)
    -- 4. Trade the item (if trade window open)
    -- 5. Mail the item (if the Send Tab of the Mail Window is open)
    -- 6. Put the item in the Guild Vault
    -- 7. Put the item in the crafting window.
    
    -- Block all interactions if the Slot is considered locked
    local slotIsLocked, lockingWindow = EA_Window_Backpack.IsSlotLocked( slot, EA_Window_Backpack.currentMode )
    if slotIsLocked then
        if lockingWindow.windowName == "EA_Window_Trade" then
            EA_Window_Trade.ClearInventoryItem( slot, EA_Window_Backpack.currentMode )

        -- Allow right click to slot stacked crafting items even when they are locked
        elseif ( itemData.stackCount > 1 )
        then
            EA_Window_Backpack.AutoAddCraftingItemIfPossible( slot )
        end
        return
    end
    
    -- If Shift is Pressed on a stacked item, Show the stack count window
    if( shiftPressed and itemData.stackCount > 1 ) then
        ItemStackingWindow.Show( cursorType, slot )
        return
    end
    
    
    if (not atStore and not atRepairMan) then
    
        if isTrading then
            EA_Window_Trade.AddInventoryItem( slot, EA_Window_Backpack.currentMode )
            
        elseif EA_Window_Backpack.AutoAddCraftingItemIfPossible( slot )
        then
            -- The item should be added now, in case all criteria were fulfilled
            
        elseif EquipmentUpgradeWindow and EquipmentUpgradeWindow.AddItem( EA_Window_Backpack.currentMode, slot )
        then
            -- The item should be added now, in case all criteria were fulfilled
            
        elseif isBankOpen then
            RequestMoveItem( cursorType, slot, Cursor.SOURCE_BANK, GameData.Inventory.FIRST_AVAILABLE_BANK_SLOT, itemData.stackCount )
        
        elseif isGuildVaultOpen then
            GuildVaultWindow.OnRButtonUpBackpack(slot)
        
        elseif isMailing then
            MailWindowTabSend.AttachItem( slot )    -- There is no 'Mailbox' slot.. The item stays in the backpack until the message is sent.
        
        elseif (isEnhanceable and shiftPressed) then
            BeginItemEnhancement (slot)
        
        elseif (itemData.equipSlot > 0) or (itemData.type == GameData.ItemTypes.TROPHY) then
            CharacterWindow.AutoEquipItem( slot )
        
        elseif EA_Window_Backpack.IsRefinable( itemData ) then
            if( controlPressed )
            then
                EA_Window_Backpack.ConfirmThenRefine( slot, EA_Window_Backpack.currentMode )  
            elseif( isTradeSkillItem or isCurrencyItem )
            then
                TransferBetweenBackpacks( slot, EA_Window_Backpack.currentMode )
            end
            -- right clicking refinable items without holding control should avoid calling SendUseItem
        
        elseif ( isTradeSkillItem or isCurrencyItem )
        then
            TransferBetweenBackpacks( slot, EA_Window_Backpack.currentMode )
        else
            -- try to use the item
            
            -- isHandled returns true if this item requires clicking on another item to be used (e.g. dyes)
            local isHandled = UseItemTargeting.HandleUseItemChangeTargetCursor( cursorType, slot )   
            if not isHandled then
                if not ItemUtils.ShowUseOptions(itemData, GameData.ItemLocs.INVENTORY, slot)
                then
                    SendUseItem( GameData.ItemLocs.INVENTORY, slot, 0, 0, 0 )
                end
                
            end
        end
        return
    end        

    -- Only try selling the item if it has a sellPrice...
    if ( atRepairMan and itemData.broken and itemData.repairPrice > 0 and itemData.repairedName ~= nil and itemData.repairedName ~= L"") then
        -- try to repair item
        if GameData.InteractStoreData.LibrarianType == GameData.InteractStoreData.STORE_TYPE_DEFAULT
        then
            EA_Window_InteractionStore.ConfirmThenRepairItem( slot )  
        else
            EA_Window_InteractionLibrarianStore.ConfirmThenRepairItem( slot )  
        end
        
    elseif atStore and itemData.sellPrice > 0 and not itemData.flags[GameData.Item.EITEMFLAG_NO_SELL] and (not EA_Window_InteractionStore.repairModeOn or not EA_Window_InteractionLibrarianStore.repairModeOn) then
        -- If the player is interacting with a store, try to sell the item.
        if GameData.InteractStoreData.LibrarianType == GameData.InteractStoreData.STORE_TYPE_DEFAULT
        then
            EA_Window_InteractionStore.ConfirmThenSellItem( slot, itemData.stackCount )
        else
            EA_Window_InteractionLibrarianStore.ConfirmThenSellItem( slot, itemData.stackCount )
        end
             
    end
    
end



function EA_Window_Backpack.MouseOverOverflowSlot()
    
    EA_Window_Backpack.DisplayItemTooltip( EA_Window_Backpack.overflowItem, EA_Window_Backpack.OVERFLOW_ITEM_ICON  )
end

function EA_Window_Backpack.OverflowLButtonDown( slot, flags )

    local itemData = EA_Window_Backpack.overflowItem
    if not EA_Window_Backpack.ValidItem( itemData ) then
        return
    end
    
    if Cursor.IconOnCursor() then
        Cursor.Clear()
    else
        Cursor.PickUp( Cursor.SOURCE_INVENTORY_OVERFLOW, 1, itemData.uniqueID, itemData.iconNum, true)
    end
    
end

-- NOTE: we do not allow using items from the overflow slot directly
--
-- TODO: it would be great if this had ability to sell directly to merchant and autoplace to various windows,
--  but a lot of those functions just take a slot number and assume that the item is the main inventory
--
-- So for now, the only choice is to move the item into inventory
--
function EA_Window_Backpack.OverflowRButtonUp()
    
    local itemData = EA_Window_Backpack.overflowItem
    if not EA_Window_Backpack.ValidItem( itemData ) then
        return
    end
    
    RequestMoveItem( Cursor.SOURCE_INVENTORY_OVERFLOW, 1, Cursor.SOURCE_INVENTORY, GameData.Inventory.FIRST_AVAILABLE_INVENTORY_SLOT, itemData.stackCount)
end



------------------------------
--- Item Locking Functions ---
------------------------------

-- this doesn't make any sanity checks, so don't give it values you're not sure about
function EA_Window_Backpack.RequestLockForSlot(slotNum, backpackType, windowName, highLightColor)

    local isLocked, lockingWindow = EA_Window_Backpack.IsSlotLocked(slotNum, backpackType)
    
    if( not isLocked )
    then
        if( not EA_Window_Backpack.lockedSlot[backpackType] )
        then
            EA_Window_Backpack.lockedSlot[backpackType] = {}
        end
        EA_Window_Backpack.lockedSlot[backpackType][slotNum] = { windowName=windowName, highLightColor=highLightColor }
        lockingWindow = EA_Window_Backpack.lockedSlot[backpackType][slotNum]
        
        -- Update the Slot
        EA_Window_Backpack.OnBackpackSlotUpdated( backpackType, {slotNum} )
        return true
    end
    
    return (lockingWindow.windowName == windowName)
end

function EA_Window_Backpack.IsSlotLocked(slotNum, backpackType)
    local isLocked = false
    local lockingWindow = nil
    if( EA_Window_Backpack.lockedSlot[backpackType] and  EA_Window_Backpack.lockedSlot[backpackType][slotNum] )
    then
        isLocked = true
        lockingWindow = EA_Window_Backpack.lockedSlot[backpackType][slotNum]
    end
    return isLocked, lockingWindow
end

function EA_Window_Backpack.ReleaseLockForSlot(slotNum, backpackType, windowName)
    
    if( type(slotNum) == "number" and 
        EA_Window_Backpack.lockedSlot[backpackType]~= nil and 
        EA_Window_Backpack.lockedSlot[backpackType][slotNum] ~= nil and 
        EA_Window_Backpack.lockedSlot[backpackType][slotNum].windowName == windowName ) then
        
        EA_Window_Backpack.lockedSlot[backpackType][slotNum] = nil
        
         -- Update the Slot      
        EA_Window_Backpack.OnBackpackSlotUpdated( backpackType, {slotNum} )
        return true
    end

    return false
end

-- When soft locks are enabled items can still be picked up from the back pack,
-- other than that everything else is the same about them
function EA_Window_Backpack.EnableSoftLocks( bEnable )
    EA_Window_Backpack.softLocksEnabled = bEnable
end

function EA_Window_Backpack.ReleaseAllLocksForWindow(windowName)

    for backpackType = 1, EA_Window_Backpack.NUM_BACKPACK_TYPES
    do
        if( EA_Window_Backpack.lockedSlot[backpackType] )
        then
            local updatedSlots = {}
            for slotNum, lockingWindow in pairs(EA_Window_Backpack.lockedSlot[backpackType])
            do
                if lockingWindow.windowName == windowName
                then
                    EA_Window_Backpack.lockedSlot[backpackType][slotNum] = nil
                    table.insert( updatedSlots, slotNum )
                end
            end
            -- Update the Slots      
            EA_Window_Backpack.OnBackpackSlotUpdated( backpackType, updatedSlots )
        end
    end

end

function EA_Window_Backpack.ReleaseAllSlotLocks()

    for backpackType = 1, EA_Window_Backpack.NUM_BACKPACK_TYPES
    do
        if( EA_Window_Backpack.lockedSlot[backpackType] )
        then
            local updatedSlots = {}
            for slotNum, lockingWindow in pairs(EA_Window_Backpack.lockedSlot[backpackType])
            do
                if lockingWindow.windowName == windowName then
                    table.insert( updatedSlots, slotNum )
                end
            end
            -- Update the Slots      
            EA_Window_Backpack.OnBackpackSlotUpdated( backpackType, updatedSlots )
        end
    end
    EA_Window_Backpack.lockedSlot = {}
    

end

--- END Item Locking Functions 
----------------------------------


