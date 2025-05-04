----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------
GuildVaultWindow = {}

GuildVaultWindow.vaultDataTable = {}

GuildVaultWindow.SelectedVault = 1
GuildVaultWindow.PurchasableVault = nil         -- If the guild has not yet purchased their extra vault, this is the index of the vault they can purchase
GuildVaultWindow.MoneyOnlyMode = false          -- This becomes true if the player does not have access to view any vaults, and can only deposit money

GuildVaultWindow.SLOTS_PER_ROW      = 10    -- There are always 10 slots per row. New slots are unlocked in increments of 10 slots.
GuildVaultWindow.MAX_ROWS           = 6
GuildVaultWindow.MAX_VAULTS         = 5

GuildVaultWindow.VaultSource =
{
    [1] = Cursor.SOURCE_GUILD_VAULT1,
    [2] = Cursor.SOURCE_GUILD_VAULT2,
    [3] = Cursor.SOURCE_GUILD_VAULT3,
    [4] = Cursor.SOURCE_GUILD_VAULT4,
    [5] = Cursor.SOURCE_GUILD_VAULT5,
}

-- This table contains 5 tables, one for each Guild Vault.
-- Each one of those tables contains an index representing a locked slot. The contents of that index is the memberID that locked the slot.
GuildVaultWindow.vaultDataLockTable = {}
GuildVaultWindow.vaultDataLockTable[1] = {}
GuildVaultWindow.vaultDataLockTable[2] = {}
GuildVaultWindow.vaultDataLockTable[3] = {}
GuildVaultWindow.vaultDataLockTable[4] = {}
GuildVaultWindow.vaultDataLockTable[5] = {}

GuildVaultWindow.UNLOCKS =
{
    -- What guild rank does each vault automatically unlock at?
    -- Note: The index into this array is not necessarily the guild vault number - it is
    -- number of the Nth unpurchased vault. If the player has not yet purchased
    -- an extra vault, it matches up with the vault numbers. If the player has purchased
    -- their extra vault, you must subtract 1 from the vault number before indexing into this array.
    [1] = 3,
    [2] = 11,
    [3] = 23,
    [4] = 33,
    -- The 5th guild vault can only be purchased and never automatically unlocks.
}

GuildVaultWindow.VaultPermission =
{
    [1] =
    {
        view = SystemData.GuildPermissons.VAULT1_VIEW,
        give = SystemData.GuildPermissons.VAULT1_ADD_ITEM,
        take = SystemData.GuildPermissons.VAULT1_TAKE_ITEM,
    },
    
    [2] =
    {
        view = SystemData.GuildPermissons.VAULT2_VIEW,
        give = SystemData.GuildPermissons.VAULT2_ADD_ITEM,
        take = SystemData.GuildPermissons.VAULT2_TAKE_ITEM,
    },
    
    [3] =
    {
        view = SystemData.GuildPermissons.VAULT3_VIEW,
        give = SystemData.GuildPermissons.VAULT3_ADD_ITEM,
        take = SystemData.GuildPermissons.VAULT3_TAKE_ITEM,
    },
    
    [4] =
    {
        view = SystemData.GuildPermissons.VAULT4_VIEW,
        give = SystemData.GuildPermissons.VAULT4_ADD_ITEM,
        take = SystemData.GuildPermissons.VAULT4_TAKE_ITEM,
    },
    
    [5] =
    {
        view = SystemData.GuildPermissons.VAULT5_VIEW,
        give = SystemData.GuildPermissons.VAULT5_ADD_ITEM,
        take = SystemData.GuildPermissons.VAULT5_TAKE_ITEM,
    },
}

local function ResetTabText( vaultIndex )
    local buttonText = GetStringFormatFromTable( "GuildStrings", StringTables.Guild.LABEL_GUILD_VAULT_TAB_VAULT, { towstring(vaultIndex) } ) 
    ButtonSetText("GuildVaultWindowTabsVault"..vaultIndex, buttonText)
    WindowSetShowing("GuildVaultWindowTabsVault"..vaultIndex.."Lock", false)
end

----------------------------------------------------------------
-- GuildVaultWindow Functions
----------------------------------------------------------------
function GuildVaultWindow.Initialize()
	
	GuildVaultWindow.InitializeEditBoxes()

	WindowRegisterEventHandler( "GuildVaultWindow", SystemData.Events.INTERACT_DONE, "GuildVaultWindow.Hide")

	WindowRegisterEventHandler( "GuildVaultWindow", SystemData.Events.GUILD_INFO_UPDATED, "GuildVaultWindow.UpdateThingsWithPermissions")
	WindowRegisterEventHandler( "GuildVaultWindow", SystemData.Events.GUILD_MEMBER_UPDATED, "GuildVaultWindow.UpdateThingsWithPermissions")
	WindowRegisterEventHandler( "GuildVaultWindow", SystemData.Events.GUILD_PERMISSIONS_UPDATED, "GuildVaultWindow.UpdateThingsWithPermissions")

	WindowRegisterEventHandler( "GuildVaultWindow", SystemData.Events.INTERACT_GUILD_VAULT_OPEN, "GuildVaultWindow.OnGuildVaultOpened")
	WindowRegisterEventHandler( "GuildVaultWindow", SystemData.Events.INTERACT_GUILD_VAULT_CLOSED, "GuildVaultWindow.OnGuildVaultClosed")

	WindowRegisterEventHandler( "GuildVaultWindow", SystemData.Events.GUILD_VAULT_COIN_UPDATED, "GuildVaultWindow.UpdateMoneyInVault")
	WindowRegisterEventHandler( "GuildVaultWindow", SystemData.Events.GUILD_VAULT_ITEMS_UPDATED, "GuildVaultWindow.UpdateItemsInVault")
    WindowRegisterEventHandler( "GuildVaultWindow", SystemData.Events.GUILD_VAULT_CAPACITY_UPDATED, "GuildVaultWindow.UpdateCapacity")

	WindowRegisterEventHandler( "GuildVaultWindow", SystemData.Events.GUILD_VAULT_SLOT_LOCKED, "GuildVaultWindow.SlotLocked")
	WindowRegisterEventHandler( "GuildVaultWindow", SystemData.Events.GUILD_VAULT_SLOT_UNLOCKED, "GuildVaultWindow.SlotUnlocked")


	-- Header text
	LabelSetText("GuildVaultWindowTitleBarText", GetGuildString(StringTables.Guild.LABEL_GUILD_VAULT))

	for vaultIndex = 1, GuildVaultWindow.MAX_VAULTS
    do
        ResetTabText( vaultIndex )
    end

	ButtonSetText("GuildVaultWindowDepositButton", GetGuildString(StringTables.Guild.BUTTON_GUILD_VAULT_DEPOSIT))
	ButtonSetText("GuildVaultWindowWithdrawButton", GetGuildString(StringTables.Guild.BUTTON_GUILD_VAULT_WITHDRAW))
end

function GuildVaultWindow.InitializeEditBoxes()
	WindowSetTintColor("GuildVaultWindowMoneyEditBoxGoldBackground",	0, 0, 0 )
	WindowSetTintColor("GuildVaultWindowMoneyEditBoxSilverBackground",	0, 0, 0 )
	WindowSetTintColor("GuildVaultWindowMoneyEditBoxBrassBackground",	0, 0, 0 )
end

function GuildVaultWindow.OnClose()	-- Registered Event Trigger	(User closed the window)
	SendGuildVaultCommand(SystemData.GuildVaultCommands.CLOSE, 0, 0, 0, 0, false)
	GuildVaultWindow.Hide()
end

function GuildVaultWindow.OnShown()
    EA_BackpackUtilsMediator.ShowBackpack()
end

function GuildVaultWindow.OnHidden()
    WindowUtils.OnHidden()
end

function GuildVaultWindow.Hide()
    WindowSetShowing( "GuildVaultWindow", false );	
end

function GuildVaultWindow.OnGuildVaultOpened(vaultDataTable)
	WindowSetShowing( "GuildVaultWindow", true )
    
    for vaultIndex = 1, GuildVaultWindow.MAX_VAULTS
    do
        GuildVaultWindow.vaultDataLockTable[vaultIndex] = {}    
    end

	GuildVaultWindow.vaultDataTable = DataUtils.CopyTable(vaultDataTable)

	GuildVaultWindow.SetMoneyInVault(GuildVaultWindow.vaultDataTable.MoneyInVault)
	GuildVaultWindow.UpdateThingsWithPermissions()
	GuildVaultWindow.SelectTab(GuildVaultWindow.SelectedVault)
end

function GuildVaultWindow.OnGuildVaultClosed()
	GuildVaultWindow.vaultDataTable = {}
	GuildVaultWindow.Hide()
end

-----------------------------------------------------------
-- Tab Controls
-----------------------------------------------------------
function GuildVaultWindow.OnMouseOverTab()
    local vaultIndex = WindowGetId (SystemData.ActiveWindow.name)
    local tooltipText = L""
    
    if ( ( GuildVaultWindow.vaultDataTable[vaultIndex] ~= nil ) and ( GuildVaultWindow.vaultDataTable[vaultIndex].NumberOfSlots > 0 ) )
    then
        tooltipText = GetStringFormatFromTable( "GuildStrings", StringTables.Guild.TOOLTIP_GUILD_VAULT_ENABLED, { towstring(vaultIndex) } )
    else
        -- If both NumberOfSlots = 0 and NextExpansionCost = 0, that is a server code for no permission to view the vault
        if ( ( GuildVaultWindow.vaultDataTable[vaultIndex] ~= nil ) and ( GuildVaultWindow.vaultDataTable[vaultIndex].NextExpansionCost == 0 ) )
        then
            tooltipText = GetGuildString( StringTables.Guild.TOOLTIP_GUILD_VAULT_DISABLED )
        else
            if ( GuildVaultWindow.PurchasableVault == vaultIndex )
            then
                local expansionCostText = MoneyFrame.FormatMoneyString( GuildVaultWindow.vaultDataTable[vaultIndex].NextExpansionCost )
                if ( vaultIndex == GuildVaultWindow.MAX_VAULTS )
                then
                    -- This is the last vault. Therefore there is no level at which it automatically unlocks.
                    tooltipText = GetStringFormatFromTable( "GuildStrings", StringTables.Guild.TOOLTIP_GUILD_VAULT_PURCHASABLE, { expansionCostText } )
                else
                    -- This is not the last vault, so there is a level at which it automatically unlocks.
                    local unlockLevel = GuildVaultWindow.UNLOCKS[vaultIndex]
                    tooltipText = GetStringFormatFromTable( "GuildStrings", StringTables.Guild.TOOLTIP_GUILD_VAULT_LOCKED_PURCHASABLE, { towstring(unlockLevel), expansionCostText } )
                end
            else
                -- We should never reach this point. If the guild does not have this vault yet and it is not purchasable, it should not be visible.
                assert( false )
            end
        end
    end

    Tooltips.CreateTextOnlyTooltip (SystemData.ActiveWindow.name, nil)
    Tooltips.SetTooltipText (1, 1, tooltipText )
    Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)	
    Tooltips.Finalize ()
    
    local anchor = { Point="top", RelativeTo=SystemData.MouseOverWindow.name, RelativePoint="bottom", XOffset=0, YOffset=-5 }
    Tooltips.AnchorTooltip (anchor)
    Tooltips.SetTooltipAlpha (1)
end

function GuildVaultWindow.SelectTab(tabID)
	if ( ButtonGetDisabledFlag("GuildVaultWindowTabsVault"..tabID) )
    then
		return
	end
    
    ButtonSetPressedFlag( "GuildVaultWindowTabsVault"..GuildVaultWindow.SelectedVault, false )
    ButtonSetPressedFlag( "GuildVaultWindowTabsVault"..tabID, true )
    
    GuildVaultWindow.SelectedVault = tabID
	GuildVaultWindow.UpdateVaultSlots(GuildVaultWindow.SelectedVault)
end

local buyingGuildVault = false

function GuildVaultWindow.OnLButtonUpTab()
    local vaultIndex = WindowGetId( SystemData.ActiveWindow.name )
    if ( GuildVaultWindow.PurchasableVault == vaultIndex )
    then
        if( buyingGuildVault )
        then
            return
        end
        
        local function doneBuyingGuildVault()
            buyingGuildVault = false
        end
        
        local nextExpansionCost = GuildVaultWindow.vaultDataTable[vaultIndex].NextExpansionCost
    
        if ( GameData.Player.money < nextExpansionCost )
        then
            DialogManager.MakeOneButtonDialog( GetStringFromTable( "GuildStrings", StringTables.Guild.TEXT_GUILD_VAULT_PURCHASE_VAULT_NO_MONEY ),
                                               GetString( StringTables.Default.LABEL_OKAY ),
                                               doneBuyingGuildVault )
        else
            local expansionCostText = MoneyFrame.FormatMoneyString( nextExpansionCost )
            local dialogText = GetStringFormatFromTable( "GuildStrings", StringTables.Guild.TEXT_GUILD_VAULT_PURCHASE_VAULT_CONFIRMATION, { expansionCostText } )
        
            local function buyNewVault()
                doneBuyingGuildVault()
                if ( GameData.Player.money < nextExpansionCost )
                then
                    DialogManager.MakeOneButtonDialog( GetStringFromTable( "GuildStrings", StringTables.Guild.TEXT_GUILD_VAULT_PURCHASE_VAULT_NO_MONEY ), GetString( StringTables.Default.LABEL_OKAY ) )
                else
                    SendGuildVaultCommand( SystemData.GuildVaultCommands.PURCHASE_EXPANSION, vaultIndex, nextExpansionCost, 0, 0, false)
                end
            end
        
            DialogManager.MakeTwoButtonDialog( dialogText, 
									           GetString(StringTables.Default.LABEL_YES),
									           buyNewVault,
									           GetString(StringTables.Default.LABEL_NO),
									           doneBuyingGuildVault )
        end
        
        buyingGuildVault = true
    else
	    GuildVaultWindow.SelectTab( vaultIndex )
    end
end

-----------------------------------------------------------
-- Money Functions
-----------------------------------------------------------

function GuildVaultWindow.SetMoneyInVault(amount)
	MoneyFrame.FormatMoney ("GuildVaultWindowMoneyInVault", amount, MoneyFrame.SHOW_EMPTY_WINDOWS)
end

-----------------------------------------------------------
-- Permission Function
-----------------------------------------------------------
function GuildVaultWindow.UpdateThingsWithPermissions()

    if ( not GuildVaultWindow.IsVaultOpen() )
    then
        return
    end
    
	local statusNumber = GuildWindowTabAdmin.GetMemberTitleNumberByMemberName(GameData.Player.name)

	-- Show or hide the Deposit and Withdraw buttons based on permissions. 
	local bShowDepositButton = GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.VAULT_DEPOSIT, statusNumber)
	local bShowWithdrawButton = GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.VAULT_WITHDRAW, statusNumber)
	WindowSetShowing("GuildVaultWindowDepositButton", bShowDepositButton)
	WindowSetShowing("GuildVaultWindowWithdrawButton", bShowWithdrawButton)

	WindowSetShowing("GuildVaultWindowMoney", bShowDepositButton or bShowWithdrawButton)
	
	-- Process each guild vault tab
	local firstViewableVault = nil
    local lastVisibleVault = nil
	for vaultIndex = 1, GuildVaultWindow.MAX_VAULTS
	do
        -- Determine the following: does the guild have this vault, does the player have access to it, is it the next purchasable vault?
        local doesGuildHaveVault
        local doesPlayerHaveAccess
        local isNextPurchasable
        
        local tabWindow = "GuildVaultWindowTabsVault"..vaultIndex
        local vaultTable = GuildVaultWindow.vaultDataTable[vaultIndex]
        if ( vaultTable ~= nil )
        then
            if ( ( vaultTable.NumberOfSlots == 0 ) and ( vaultTable.NextExpansionCost == 0 ) )
            then
                -- This is a special code from the server to indicate the guild has this vault but the player does not have access.
                doesGuildHaveVault = true
                doesPlayerHaveAccess = false
                isNextPurchasable = false
            elseif ( vaultTable.NumberOfSlots == 0 )
            then
                doesGuildHaveVault = false
                doesPlayerHaveAccess = true -- This value is irrelevant in this case
                isNextPurchasable = ( vaultTable.NextExpansionCost > 0 )
            else
                doesGuildHaveVault = true
                doesPlayerHaveAccess = true
                isNextPurchasable = false
            end
        else
            doesGuildHaveVault = false
            doesPlayerHaveAccess = true -- This value is irrelevant in this case
            isNextPurchasable = false   -- If this could be purchased, the server would have sent info about this vault, because we would need NextExpansionCost
        end
        
        if ( ( GuildVaultWindow.PurchasableVault == vaultIndex ) and not isNextPurchasable )
        then
            -- Vault was purchasable but no longer is.
            ResetTabText( vaultIndex )
            GuildVaultWindow.PurchasableVault = nil
        elseif ( ( GuildVaultWindow.PurchasableVault ~= vaultIndex ) and isNextPurchasable )
        then
            -- Vault was not purchasable but now is.
            if ( GuildVaultWindow.PurchasableVault ~= nil )
            then
                ResetTabText( GuildVaultWindow.PurchasableVault )
            end
            ButtonSetText( tabWindow, GetGuildString( StringTables.Guild.TEXT_GUILD_VAULT_PURCHASE_VAULT ) )
            WindowSetShowing( tabWindow.."Lock", true )
            GuildVaultWindow.PurchasableVault = vaultIndex
        end
        
        local isTabVisible = doesGuildHaveVault or isNextPurchasable
        local isVaultViewable = doesGuildHaveVault and doesPlayerHaveAccess
        local isVaultAccessDenied = doesGuildHaveVault and not isNextPurchasable and not doesPlayerHaveAccess
        
        WindowSetShowing( tabWindow, isTabVisible )
        ButtonSetDisabledFlag( tabWindow, isVaultAccessDenied )
        
        if ( isTabVisible )
        then
            lastVisibleVault = vaultIndex
        end
        
        if ( ( firstViewableVault == nil ) and isVaultViewable )
        then
            firstViewableVault = vaultIndex
        end
	end
    
    assert( lastVisibleVault ~= nil )   -- There should always be at least one VISIBLE vault tab, even if the player does not have access to it
    -- Reanchor the tab separator as the number of tabs may have changed
    WindowClearAnchors( "GuildVaultWindowTabsSeparatorRight" )
    WindowAddAnchor( "GuildVaultWindowTabsSeparatorRight", "bottomright", "GuildVaultWindowTabsVault"..lastVisibleVault, "topleft", 0, -6 )
    WindowAddAnchor( "GuildVaultWindowTabsSeparatorRight", "bottomright", "GuildVaultWindowTabs", "bottomright", 0, -6 )

    if ( GuildVaultWindow.MoneyOnlyMode )
    then
        -- If the user previously did not have access to view any tabs, but now does, automatically show the first tab they have access to
        if ( firstViewableVault ~= nil )
        then
            GuildVaultWindow.MoneyOnlyMode = false
            WindowSetShowing( "GuildVaultWindowSlots", true )
            GuildVaultWindow.SelectTab( firstViewableVault )
        end
    else
        -- If the user is looking at a Vault Tab for which permission is no longer granted, then switch to the first tab they do have access to.
        -- Note: If the user has access to none of the vaults, and no access to deposit/withddraw, the server will close the vault window.
        local selectedVaultWindow = "GuildVaultWindowTabsVault"..GuildVaultWindow.SelectedVault
        if ( ButtonGetDisabledFlag( selectedVaultWindow ) or not WindowGetShowing( selectedVaultWindow ) )
        then
            if ( firstViewableVault ~= nil )
            then
                GuildVaultWindow.SelectTab( firstViewableVault )
            else
                -- If we get here and the selected vault tab is disabled, we don't have permission to view
                -- any vault, but we can deposit money. Hide the vault buttons to prevent confusion.
                ButtonSetPressedFlag(selectedVaultWindow, false )
                GuildVaultWindow.MoneyOnlyMode = true
                WindowSetShowing( "GuildVaultWindowSlots", false )
            end
        end
    end

end

function GuildVaultWindow.OnMouseOverVaultSlot(slot, flags)
	local itemData = GuildVaultWindow.GetItemDataFromVaultSlot(GuildVaultWindow.SelectedVault, slot)

	if ( ( itemData ~= nil ) and ( itemData.id ~= nil ) and ( itemData.id > 0 ) )
    then
		Tooltips.CreateItemTooltip (itemData, SystemData.ActiveWindow.name.."Button"..slot, Tooltips.ANCHOR_WINDOW_BOTTOM)
    end
end

-----------------------------------------------------------
-- Command Functions
-----------------------------------------------------------

function GuildVaultWindow.OnLButtonUpDepositButton()
	local money = tonumber(GuildVaultWindowMoneyEditBoxGold.Text) * 10000 + 
					tonumber(GuildVaultWindowMoneyEditBoxSilver.Text) * 100 + 
					tonumber(GuildVaultWindowMoneyEditBoxBrass.Text)
	SendGuildVaultCommand(SystemData.GuildVaultCommands.GIVE_COIN, money, 0, 0, 0, false)
end

function GuildVaultWindow.OnLButtonUpWithdrawButton()
	local money = tonumber(GuildVaultWindowMoneyEditBoxGold.Text) * 10000 + 
					tonumber(GuildVaultWindowMoneyEditBoxSilver.Text) * 100 + 
					tonumber(GuildVaultWindowMoneyEditBoxBrass.Text)
	SendGuildVaultCommand(SystemData.GuildVaultCommands.TAKE_COIN, money, 0, 0, 0, false)
end

function GuildVaultWindow.IsVaultOpen()
	return ( WindowGetShowing( "GuildVaultWindow" ) )
end

-----------------------------------------------------------
-- Button & Item Handlers 
-----------------------------------------------------------

function GuildVaultWindow.SetItemInSlot(vaultID, slot, itemData)
    local vaultData = GuildVaultWindow.vaultDataTable[vaultID]
	
    if ( ( itemData == nil) or ( itemData.id == nil ) or ( itemData.id == 0) )
    then
        if ( vaultData )
        then
            vaultData.itemsAttached[slot] = nil
        end

        -- Only update the icon if the update is for an item in the same vault we're currently looking at. 
        if ( vaultID == GuildVaultWindow.SelectedVault )
        then
            ActionButtonGroupSetIcon( "GuildVaultWindowSlots", slot, 0 )
            ActionButtonGroupSetText( "GuildVaultWindowSlots", slot, L"" )
        end

        return
    end

    -- Item
    vaultData.itemsAttached[slot] = DataUtils.CopyTable(itemData)

    -- Only update the icon if the update is for an item in the same vault we're currently looking at. 
    if ( vaultID == GuildVaultWindow.SelectedVault )
    then
        local stackCountText = L""
        if ( itemData.stackCount > 1 )
        then
            stackCountText = towstring(itemData.stackCount)
        end
        
        ActionButtonGroupSetIcon( "GuildVaultWindowSlots", slot, itemData.iconNum )
        ActionButtonGroupSetText( "GuildVaultWindowSlots", slot, stackCountText )
    end
end

function GuildVaultWindow.GetItemDataFromVaultSlot(vaultID, slotNumber)
    if ( ( GuildVaultWindow.vaultDataTable[vaultID] ~= nil ) and 
         ( GuildVaultWindow.vaultDataTable[vaultID].itemsAttached ~= nil ) and
         ( GuildVaultWindow.vaultDataTable[vaultID].itemsAttached[slotNumber] ~= nil ) )
    then
        return GuildVaultWindow.vaultDataTable[vaultID].itemsAttached[slotNumber]
    end

    return nil
end

function GuildVaultWindow.IsSlotLocked(source, sourceSlot)
    for slotNumber, slot in pairs( GuildVaultWindow.vaultDataLockTable[source] )
    do
        if ( slot == sourceSlot )
        then
            return true
        end
    end
    return false
end

function GuildVaultWindow.UpdateVaultSlots(vaultID)
	-- This function refreshes all the slots for the passed in Vault Number.
    if ( ( GuildVaultWindow.vaultDataTable[vaultID] == nil ) or ( GuildVaultWindow.vaultDataTable[vaultID].NumberOfSlots == 0 ) )
    then
        return
    end
    
    local numRows = math.ceil( GuildVaultWindow.vaultDataTable[vaultID].NumberOfSlots / GuildVaultWindow.SLOTS_PER_ROW )
    local numRows = math.min( numRows, GuildVaultWindow.MAX_ROWS )
    ActionButtonGroupSetNumButtons( "GuildVaultWindowSlots", numRows, GuildVaultWindow.SLOTS_PER_ROW )

    local itemData
    for i=1, GuildVaultWindow.vaultDataTable[vaultID].NumberOfSlots
    do
        if ( GuildVaultWindow.vaultDataTable[vaultID].itemsAttached ~= nil )
        then
            itemData = GuildVaultWindow.vaultDataTable[vaultID].itemsAttached[i]
        else
            itemData = nil
        end

        -- Update the slot's icon
        GuildVaultWindow.SetItemInSlot(vaultID, i, itemData)

        -- Update the slot's tint
        if ( GuildVaultWindow.IsSlotLocked(vaultID, i) )
        then
            ActionButtonGroupSetTintColor("GuildVaultWindowSlots", i, 128, 128, 128)
        else
            ActionButtonGroupSetTintColor("GuildVaultWindowSlots", i, 255, 255, 255)
        end

    end
    
    if ( GuildVaultWindow.vaultDataTable[vaultID].NextExpansionCost > 0 )
    then
        WindowSetShowing( "GuildVaultWindowBuyNewRow", true )
        
        local expansionCostText = MoneyFrame.FormatMoneyString( GuildVaultWindow.vaultDataTable[vaultID].NextExpansionCost, true )
        ButtonSetText( "GuildVaultWindowBuyNewRowButton", GetStringFormatFromTable( "GuildStrings", StringTables.Guild.TEXT_GUILD_VAULT_PURCHASE_ROW, { expansionCostText } ) )
    else
        WindowSetShowing( "GuildVaultWindowBuyNewRow", false )
    end
end

function GuildVaultWindow.OnLButtonDownVaultSlot(buttonIndex, flags)

    -- We can do one of three things... 
    --  1) If there's no item in the slot and the cursor doesn't have an item on it, do nothing.
    --	2) If the cursor already has an item attached, and the slot is empty, then place it.
    --	3) If the cursor doesn't have an item attached, pick up the item in the slot.

    -- 1) If there's no item in the slot and the cursor doesn't have an item on it, do nothing.
    if ( ( Cursor.IconOnCursor() == false ) and ( GuildVaultWindow.GetItemDataFromVaultSlot(GuildVaultWindow.SelectedVault, buttonIndex) == nil ) )
    then
		return
	end

    --	2) If the cursor already has an item attached, drop it.
    if ( Cursor.IconOnCursor() )
    then

        -- Verify user has permission to place an item in this guild vault.
        local statusNumber = GuildWindowTabAdmin.GetMemberTitleNumberByMemberName(GameData.Player.name)
        local bGiveVault = GuildWindowTabAdmin.GetGuildCommandPermission(GuildVaultWindow.VaultPermission[GuildVaultWindow.SelectedVault].give, statusNumber)
        if ( bGiveVault == false )
        then
            local errorText = GetStringFormatFromTable( "GuildStrings", StringTables.Guild.ERROR_GUILD_VAULT_NO_GIVE_PERMISSION, { towstring(GuildVaultWindow.SelectedVault) } )
            EA_ChatWindow.Print(errorText, SystemData.ChatLogFilters.SAY) 
            return
        end

        -- If we're dropping the Item onto the same slot we picked it up from, just clear the cursor
        if( Cursor.Data.Source >= Cursor.SOURCE_GUILD_VAULT1 and		-- Verify that the source slot
            Cursor.Data.Source <= Cursor.SOURCE_GUILD_VAULT5 and		--		is a vault slot
            Cursor.Data.Source == GuildVaultWindow.SelectedVault and	-- Verify the source and dest vaults are the same
            Cursor.Data.SourceSlot == buttonIndex )						-- Verify the source slot is the same as the selected slot
        then
            SendGuildVaultCommand(SystemData.GuildVaultCommands.SLOT_UNLOCK, GuildVaultWindow.SelectedVault, buttonIndex, 0, 0, false)
            Cursor.Clear()
        else
            local itemData = GuildVaultWindow.GetItemDataFromVaultSlot(GuildVaultWindow.SelectedVault, buttonIndex)

            -- If the slot is clear, drop the item into it.
            if ( itemData == nil )
            then
                -- If the source is the backpack, the server is expecting a sourceID of 0, otherwise it expects the source to be the vault#.
                local backpackType = EA_BackpackUtilsMediator.GetCurrentBackpackType()
                local currentCursor = EA_BackpackUtilsMediator.GetCursorForBackpack( backpackType )
                if ( Cursor.Data.Source == currentCursor )
                then
                    local backpackType = EA_BackpackUtilsMediator.GetCurrentBackpackType() + GuildVaultWindow.MAX_VAULTS
                    SendGuildVaultCommand(SystemData.GuildVaultCommands.MOVE_ITEM, backpackType, Cursor.Data.SourceSlot, GuildVaultWindow.SelectedVault, buttonIndex, false)
                else
                    SendGuildVaultCommand(SystemData.GuildVaultCommands.MOVE_ITEM, Cursor.Data.Source - Cursor.SOURCE_GUILD_VAULT1 +1, Cursor.Data.SourceSlot, GuildVaultWindow.SelectedVault, buttonIndex, false)
                end
                Cursor.Clear()
                return
            end
        end
        return
    end

    --	3) If the cursor doesn't have an item attached, and the slot isn't locked, pick up the item in the slot.
    if (GuildVaultWindow.IsSlotLocked(GuildVaultWindow.SelectedVault, buttonIndex) == false) then
        -- Verify user has permission to place an item in this guild vault.
        local statusNumber = GuildWindowTabAdmin.GetMemberTitleNumberByMemberName(GameData.Player.name)
        local bTakeVault = GuildWindowTabAdmin.GetGuildCommandPermission(GuildVaultWindow.VaultPermission[GuildVaultWindow.SelectedVault].take, statusNumber)
        if ( bTakeVault == false )
        then
            local errorText = GetStringFormatFromTable( "GuildStrings", StringTables.Guild.ERROR_GUILD_VAULT_NO_TAKE_PERMISSION, { towstring(GuildVaultWindow.SelectedVault) } )
            EA_ChatWindow.Print(errorText, SystemData.ChatLogFilters.SAY) 
            return
        end

        local itemData = GuildVaultWindow.GetItemDataFromVaultSlot(GuildVaultWindow.SelectedVault, buttonIndex)
        if ( itemData ~= nil )
        then

            -- NOTE: We're ignoring stackable items for now. (Splitting up a stacked item from within the Vault is not server supported yet.
            -- If the Shift key is pressed while cilcking on a stacked item, then only pick up some of the stack
            --if ( (flags == SystemData.ButtonFlags.SHIFT) and itemData.stackCount > 1 ) then
            --    ItemStackingWindow.Show(GuildVaultWindow.VaultSource[GuildVaultWindow.SelectedVault], buttonIndex)
            --else
                SendGuildVaultCommand(SystemData.GuildVaultCommands.SLOT_LOCK, GuildVaultWindow.SelectedVault, buttonIndex, 0, 0, false)
                Cursor.PickUp( GuildVaultWindow.VaultSource[GuildVaultWindow.SelectedVault], buttonIndex, itemData.uniqueID, itemData.iconNum, true)
            --end

            --GuildVaultWindow.dropPending = false
            return
        end
    end
end

function GuildVaultWindow.OnLButtonUpVaultSlot(buttonIndex, flags)
    -- In order to support Drag & Drop, we should only respond to this event if all the following cases are true
    -- 1) There is already an item on the cursor
    -- 2) The sourceslot is not the same as the butotnIndex (otherwise, we'll always be pickuping up item in LbuttonDown, but then dropping it here)

    if ( ( Cursor.IconOnCursor() ) and ( Cursor.Data.SourceSlot ~= buttonIndex ) )
    then
        GuildVaultWindow.OnLButtonDownVaultSlot(buttonIndex, flags)
    end
end

-- If the user R-clicks to clear the cursor outside the guild vault, Cursor.OnRButtonDownProcessed() handles the cursor clear, 
-- but if the source is the Guild Vault, it also calls this function.
function GuildVaultWindow.ClearUnlock(source, sourceSlot)
    SendGuildVaultCommand(SystemData.GuildVaultCommands.SLOT_UNLOCK, source-Cursor.SOURCE_GUILD_VAULT1+1, sourceSlot, 0, 0, false)
end

function GuildVaultWindow.OnRButtonUpVaultSlot(buttonIndex)
    -- If the user already has something on the cursor, do nothing.
    if ( Cursor.IconOnCursor() )
    then
        return
    end

    local statusNumber = GuildWindowTabAdmin.GetMemberTitleNumberByMemberName(GameData.Player.name)
    local bTakeVault = GuildWindowTabAdmin.GetGuildCommandPermission(GuildVaultWindow.VaultPermission[GuildVaultWindow.SelectedVault].take, statusNumber)
    if ( bTakeVault == false )
    then
        local errorText = GetStringFormatFromTable( "GuildStrings", StringTables.Guild.ERROR_GUILD_VAULT_NO_TAKE_PERMISSION, { towstring(GuildVaultWindow.SelectedVault) } )
        EA_ChatWindow.Print(errorText, SystemData.ChatLogFilters.SAY) 
        return
    end

    local itemData = GuildVaultWindow.GetItemDataFromVaultSlot(GuildVaultWindow.SelectedVault, buttonIndex)

    if ( ( itemData ~= nil ) and ( itemData.id ~= nil ) and ( itemData.id >0 ) )
    then
        -- Move the item from the Selected Vault to the player's backpack. 
        -- Note that the 4th param is 0, which tells the server that the dest is the player's backpack.
        SendGuildVaultCommand(SystemData.GuildVaultCommands.MOVE_ITEM, GuildVaultWindow.SelectedVault, buttonIndex, 0, GameData.Inventory.FIRST_AVAILABLE_INVENTORY_SLOT, true)
    end
end

-- This function handles the Guild Vault command to move an Item from the Guild Vault to the player's Backpack.
-- It's called from EA_Window_Backpack.EquipmentLButtonDown in BackpackUtils.lua. 
function GuildVaultWindow.MoveItemFromGuildVaultToBackpack(vaultNumber, backpackSlot, flags, backpackType)
    -- Special: Server expects a source ID of 0 for the backpack.
    local backpack = backpackType + GuildVaultWindow.MAX_VAULTS
    SendGuildVaultCommand(SystemData.GuildVaultCommands.MOVE_ITEM, vaultNumber, Cursor.Data.SourceSlot, backpack, backpackSlot, false)
    Cursor.Clear()
end

function GuildVaultWindow.OnRButtonUpBackpack(buttonIndex)
    -- Move the item from the player's backpack to the selected Guild Vault.
    -- Note that the 2nd param is 0, which tells the server that the source location is the player's backpack.
    -- Don't worry about offsetting the backpack slot#, that'll happen on the C side.
    -- Ensure the user has write permission to this vault
    local statusNumber = GuildWindowTabAdmin.GetMemberTitleNumberByMemberName(GameData.Player.name)
    local bGiveVault = GuildWindowTabAdmin.GetGuildCommandPermission(GuildVaultWindow.VaultPermission[GuildVaultWindow.SelectedVault].give, statusNumber)

    if ( bGiveVault )
    then
        local backpackType = EA_BackpackUtilsMediator.GetCurrentBackpackType() + GuildVaultWindow.MAX_VAULTS
        SendGuildVaultCommand(SystemData.GuildVaultCommands.MOVE_ITEM, backpackType, buttonIndex, GuildVaultWindow.SelectedVault, GameData.Inventory.FIRST_AVAILABLE_GUILD_VAULT_SLOT, true)
    else
        local errorText = GetStringFormatFromTable( "GuildStrings", StringTables.Guild.ERROR_GUILD_VAULT_NO_GIVE_PERMISSION, { towstring(GuildVaultWindow.SelectedVault) } )
        EA_ChatWindow.Print(errorText, SystemData.ChatLogFilters.SAY) 
    end
end

function GuildVaultWindow.UpdateMoneyInVault(amount)
    GuildVaultWindow.vaultDataTable.MoneyInVault = amount
    GuildVaultWindow.SetMoneyInVault(amount)
end

-- LUA Script param includes a table of vaults and items that have been changed. This is NOT a new list of all items in all vaults!
function GuildVaultWindow.UpdateItemsInVault(vaultData)
-- The Parameter structure looks like this:
-- vaultData									This table contains all the vaults that have changed.
--		vaultData[vault#]						This table contains contains all the changes to this vault.
--			vaultData[vault#].itemsUpdated		This table contains all the items that have changed for this vault. The Index is the slot#.
--				vaultData.itemsUpdated[slot#]	This table contains the itemData.
    for vaultIndex, data in pairs(vaultData)
    do
        for slotIndex, itemData in pairs (data.itemsUpdated)
        do
            GuildVaultWindow.SetItemInSlot(vaultIndex, slotIndex, itemData)
        end
    end
end

function GuildVaultWindow.UpdateCapacity(vaultID, numberOfSlots, nextExpansionCost)
    if ( GuildVaultWindow.vaultDataTable[vaultID] == nil)
    then
        -- Set up a new guild vault if necessary
        GuildVaultWindow.vaultDataTable[vaultID] = {}
        GuildVaultWindow.vaultDataTable[vaultID].itemsAttached = {}
	end
    
    GuildVaultWindow.vaultDataTable[vaultID].NumberOfSlots = numberOfSlots
    GuildVaultWindow.vaultDataTable[vaultID].NextExpansionCost = nextExpansionCost
    
    GuildVaultWindow.UpdateThingsWithPermissions()
    if ( vaultID == GuildVaultWindow.SelectedVault )
    then
	    GuildVaultWindow.UpdateVaultSlots( GuildVaultWindow.SelectedVault )
    end
end

function GuildVaultWindow.OnMouseOverDepositButton()
    Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name, nil)
    Tooltips.SetTooltipText (1, 1, GetGuildString(StringTables.Guild.TOOLTIP_GUILD_VAULT_DEPOSIT_BUTTON) )
    Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)
    Tooltips.Finalize ()
    
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_BOTTOM )
end

function GuildVaultWindow.OnMouseOverWithdrawButton()
    Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name, nil)
    Tooltips.SetTooltipText (1, 1, GetGuildString(StringTables.Guild.TOOLTIP_GUILD_VAULT_WITHDRAW_BUTTON) )
    Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)	
    Tooltips.Finalize ()
    
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_BOTTOM )
end

function GuildVaultWindow.SlotLocked(memberID, source, sourceSlot)
    local itemData = GuildVaultWindow.GetItemDataFromVaultSlot(source, sourceSlot)
    local vaultLockedList = GuildVaultWindow.vaultDataLockTable[source]
    -- Use the slotID as an index to the memberID. This tells us 2 things: That the slot is locked, and who locked it.
    table.insert(GuildVaultWindow.vaultDataLockTable[source], sourceSlot)

    -- If the user didn't lock the slot but has the item on their cursor, clear their cursor.
    local localMemberID = GuildWindowTabRoster.GetMemberID()
    if ( ( memberID ~= localMemberID ) and ( Cursor.Data ~= nil ) and ( Cursor.Data.SourceSlot == source ) and ( Cursor.Data.SourceSlot == sourceSlot ) )
    then
        Cursor.Clear()
    end

    -- Grey out the slot that's been locked and if the memberID matches you, pickup the item.
    -- its possibel to pick up an item in V2 and then quickly click V1, thereby greying out the V2 slot in V1. So verify the source.
    if ( GuildVaultWindow.SelectedVault == source )
    then 
        ActionButtonGroupSetTintColor("GuildVaultWindowSlots", sourceSlot, 128, 128, 128)
    end
end

function GuildVaultWindow.SlotUnlocked(memberID, source, sourceSlot)
    -- Add the slotId to our list of locked slots for the source vault
    if ( GuildVaultWindow.vaultDataLockTable[source] ~= nil )
    then
        table.remove(GuildVaultWindow.vaultDataLockTable[source], sourceSlot)
    end

    local itemData = GuildVaultWindow.GetItemDataFromVaultSlot(source, sourceSlot)

    -- If the slot was owned by the current user, clear their cursor.
    for index, memberData in ipairs(GuildWindowTabRoster.memberListData)
    do
        if ( ( memberData.memberID == memberID ) and ( itemData ~= nil ) and ( itemData.id ~= nil ) and ( itemData.id > 0 ) )
        then
            Cursor.Clear()
            break
        end
    end

    -- Ungrey the locked slot if we're looking at the vault whose's slot is getting unlocked.
    if ( source == GuildVaultWindow.SelectedVault )
    then
        ActionButtonGroupSetTintColor("GuildVaultWindowSlots", sourceSlot, 255, 255, 255)
    end
end

local buyingGuildVaultSlots = false

function GuildVaultWindow.OnBuyNewRow()
    if ( buyingGuildVaultSlots
         or ( GuildVaultWindow.vaultDataTable[GuildVaultWindow.SelectedVault] == nil )
         or ( GuildVaultWindow.vaultDataTable[GuildVaultWindow.SelectedVault].NumberOfSlots == 0 )
         or ( GuildVaultWindow.vaultDataTable[GuildVaultWindow.SelectedVault].NextExpansionCost == 0 ) )
    then
        return
    end
    
    local function doneBuyingGuildVaultSlots()
        buyingGuildVaultSlots = false
    end
    
    local nextExpansionCost = GuildVaultWindow.vaultDataTable[GuildVaultWindow.SelectedVault].NextExpansionCost
    
    if ( GameData.Player.money < nextExpansionCost )
    then
        DialogManager.MakeOneButtonDialog( GetStringFromTable( "GuildStrings", StringTables.Guild.TEXT_GUILD_VAULT_PURCHASE_ROW_NO_MONEY ),
                                           GetString( StringTables.Default.LABEL_OKAY ),
                                           doneBuyingGuildVaultSlots )
    else
        local expansionCostText = MoneyFrame.FormatMoneyString( nextExpansionCost )
        local dialogText = GetStringFormatFromTable( "GuildStrings", StringTables.Guild.TEXT_GUILD_VAULT_PURCHASE_ROW_CONFIRMATION, { expansionCostText } )
        
        local function buyNewRow()
            doneBuyingGuildVaultSlots()
            if ( GameData.Player.money < nextExpansionCost )
            then
                DialogManager.MakeOneButtonDialog( GetStringFromTable( "GuildStrings", StringTables.Guild.TEXT_GUILD_VAULT_PURCHASE_ROW_NO_MONEY ), GetString( StringTables.Default.LABEL_OKAY ) )
            else
                SendGuildVaultCommand( SystemData.GuildVaultCommands.PURCHASE_EXPANSION, GuildVaultWindow.SelectedVault, nextExpansionCost, 0, 0, false)
            end
        end
        
        DialogManager.MakeTwoButtonDialog( dialogText, 
									       GetString(StringTables.Default.LABEL_YES),
									       buyNewRow,
									       GetString(StringTables.Default.LABEL_NO),
									       doneBuyingGuildVaultSlots )
    end
    
    buyingGuildVaultSlots = true
end