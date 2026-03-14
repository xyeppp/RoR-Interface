----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

BankWindow = {}
BankWindow.items = {}

BankWindow.versionNumber = 0.01
BankWindow.dropPending = false
BankWindow.currentTabNumber = 0

local NUM_BANK_SLOTS = 80
local NUM_COLS = 8
local NUM_ROWS = 10
local NUM_TABS = 3
local NUM_SLOTS_PER_TAB = NUM_ROWS * NUM_COLS
local TOTAL_NUMBER_BANK_SLOTS = NUM_SLOTS_PER_TAB * NUM_TABS

local WINDOW_NAME = "BankWindow"
local SLOTS_NAME = WINDOW_NAME.."Slots"
local TAB_NAME = WINDOW_NAME.."TabsVault"
local LOCK_NAME = WINDOW_NAME.."Lock"
local NUM_LOCKS = NUM_ROWS


----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------


----------------------------------------------------------------
-- Local Functions
-- End Local Functions
----------------------------------------------------------------



----------------------------------------------------------------
-- BankWindow Functions

-- OnInitialize Handler
function BankWindow.Initialize()  
    ActionButtonGroupSetNumButtons( SLOTS_NAME, NUM_ROWS, NUM_COLS )
    WindowRegisterEventHandler( WINDOW_NAME, SystemData.Events.INTERACT_OPEN_BANK, "BankWindow.OpenBank")
    WindowRegisterEventHandler( WINDOW_NAME, SystemData.Events.PLAYER_BANK_SLOT_UPDATED, "BankWindow.UpdateBankSlots")
    WindowRegisterEventHandler( WINDOW_NAME, SystemData.Events.INTERACT_DONE, "BankWindow.Hide")
    WindowRegisterEventHandler( WINDOW_NAME, SystemData.Events.PLAYER_NEW_NUMBER_OF_BANK_SLOTS, "BankWindow.OnNewBankSlots")
    
    LabelSetText( WINDOW_NAME.."TitleBarText", GetString( StringTables.Default.LABEL_PLAYER_VAULT_TITLE ) )
    
    for i=1, NUM_TABS
    do
        ButtonSetText(TAB_NAME..i, towstring(i) )
    end

    for i=1, NUM_LOCKS
    do
        ButtonSetText( LOCK_NAME..i.."BuyButton", GetString( StringTables.Default.LABEL_BUY ) )
    end
    
    NUM_BANK_SLOTS = GameData.Player.numBankSlots
	BankWindow.InitializeSlots()
    BankWindow.SwitchTabs( 1 )
end


-- OnShutdown Handler
function BankWindow.Shutdown()
	BankWindow.Hide()
end

function BankWindow.OnRButtonDown()
    EA_Window_ContextMenu.CreateDefaultContextMenu( WINDOW_NAME )
end

-- Show the Bank
function BankWindow.Show()
    BankWindow.SwitchTabs( 1 )
    WindowSetShowing( WINDOW_NAME, true )
end

function BankWindow.OnShown()

    WindowUtils.OnShown(BankWindow.Hide, WindowUtils.Cascade.MODE_AUTOMATIC)
    EA_BackpackUtilsMediator.ShowBackpack()
end


-- Hide the Bank
function BankWindow.Hide()

	WindowSetShowing( WINDOW_NAME, false )
end

function BankWindow.OnHidden()

    WindowUtils.OnHidden()
end


function BankWindow.ToggleShowing()
    WindowUtils.ToggleShowing( WINDOW_NAME )
end


function BankWindow.IsShowing()
    return WindowGetShowing( WINDOW_NAME )
end


-- Show the Bank
function BankWindow.OpenBank()
	local bankItems = DataUtils.GetBankData()		
	BankWindow.UpdateAllBankSlots( bankItems )
	BankWindow.Show()
end


function BankWindow.InitializeSlots()
    
	for slot = 1, NUM_SLOTS_PER_TAB do
		BankWindow.SetBankSlot( slot, nil )
	end
end

function BankWindow.GetButtonIndexForSlotNumber( slotNumber )
    local buttonIndex = math.fmod(slotNumber, NUM_SLOTS_PER_TAB)
    if( buttonIndex == 0 )
    then
        buttonIndex = NUM_SLOTS_PER_TAB
    end
    
	return buttonIndex
end

function BankWindow.GetSlotNumberForButtonIndex( buttonIndex )  
	return NUM_SLOTS_PER_TAB * (BankWindow.currentTabNumber - 1) + buttonIndex
end

function BankWindow.GetSlotWindowForSlotNumber( slot )
    return SLOTS_NAME.."Button"..BankWindow.GetButtonIndexForSlotNumber( slot )
end

local function GetMinVisibleBankSlot()
    return (BankWindow.currentTabNumber-1) * NUM_SLOTS_PER_TAB + 1
end

local function GetMaxVisibleBankSlot()
    return BankWindow.currentTabNumber * NUM_SLOTS_PER_TAB
end

function BankWindow.SetBankSlotsInRange( min, max )
    if( min < max and max - min <= NUM_SLOTS_PER_TAB )
    then
		for slot = min, max
        do
			itemData = BankWindow.items[slot]
			BankWindow.SetBankSlot( slot, itemData ) 
		end
    end
end

function BankWindow.UpdateAllBankSlots( updatedSlots )
    if updatedSlots ~= nil
    then
		BankWindow.items = updatedSlots
        BankWindow.SetBankSlotsInRange( GetMinVisibleBankSlot(), GetMaxVisibleBankSlot() )
    end
end


-- SystemData.Events.PLAYER_BANK_SLOT_UPDATED Handler
function BankWindow.UpdateBankSlots( updatedSlots )

	-- NOTE: since we don't have a working UPDATE_ALL call, wait until we open up
	--       the bank window and fetch all 80 items at one time
    if BankWindow.IsShowing() == false then
        return  
    end 
    
    -- BankWindow.UpdateBankSlot() will grab itemData from C++ one slot at a time
    -- If for any reason we send more than 2 slots at a time, then we're likely 
    -- clearing or setting all 80 slots so just use UpdateAllBankSlots() to 
    -- grab them all and update them all at one time. 
    --
    if #updatedSlots > 2 then
		BankWindow.UpdateAllBankSlots( updatedSlots )
	else
		for _, slot in ipairs( updatedSlots ) do
			BankWindow.UpdateBankSlot( slot )
		end
	end
end

-- SystemData.Events.PLAYER_BANK_SLOT_UPDATED Handler
function BankWindow.UpdateBankSlot( slot )
    
    -- make sure slot number is in proper range
    if slot < 1 or slot > NUM_BANK_SLOTS then
		 DEBUG(L"ERROR in BankWindow.UpdateBankSlot received out of range slot index = "..slot)
        return  
    end 
    
    local itemData  = GetSingleItem( GameData.ItemLocs.BANK, slot, false )
    
    BankWindow.items[slot] = itemData
    if( slot >= GetMinVisibleBankSlot()
        and slot <=  GetMaxVisibleBankSlot() ) --If the bank slot is visible then set it
    then
        BankWindow.SetBankSlot( slot, itemData )
    end

    -- If we are placing the item that is currently on the cursor, clear it
    if( Cursor.IconOnCursor() and itemData and (Cursor.Data.ObjectId == itemData.uniqueID or BankWindow.dropPending == true) ) then 
        Cursor.Clear()
    end
    
    -- If we are mousing over the updated slot, show the tooltip
    local SLOTS_NAME = BankWindow.GetSlotWindowForSlotNumber( slot )
    if( SystemData.MouseOverWindow.name == SLOTS_NAME ) then    
        BankWindow.EquipmentMouseOver( BankWindow.GetButtonIndexForSlotNumber( slot ) )
    end
    
end



function BankWindow.SetBankSlot( slot, itemData )

    local buttonIndex = BankWindow.GetButtonIndexForSlotNumber( slot )

    -- Clear the Slot if no item is set.
    if ( not DataUtils.IsValidItem( itemData ) )
    then
        ActionButtonGroupSetIcon( SLOTS_NAME, buttonIndex, 0 )
        ActionButtonGroupSetText( SLOTS_NAME, buttonIndex, L"" )
        return
    end

    ActionButtonGroupSetIcon( SLOTS_NAME, buttonIndex, itemData.iconNum )
    
    local stackCount = L""
    if itemData.stackCount > 1
    then
        stackCount = towstring(itemData.stackCount)
    end

    ActionButtonGroupSetText( SLOTS_NAME, buttonIndex, stackCount )
end

function BankWindow.GetItem(slot)
    
    if (slot == nil or slot <= 0 or slot > NUM_BANK_SLOTS) then
        return nil
    end
    
    return BankWindow.items[slot]
end

---------------------------------
--- Item Handlers -----
---------------------------------

-- OnLButtonDown Handler
function BankWindow.EquipmentLButtonDown( buttonIndex, flags )

	local slot = BankWindow.GetSlotNumberForButtonIndex( buttonIndex )  
    local itemData = BankWindow.GetItem(slot)

    if Cursor.IconOnCursor() then
        
        -- don't bother sending a move item if we're dropping on the original slot. just clear the cursor
        --   Same for list mode
        if( Cursor.Data.Source == Cursor.SOURCE_BANK and Cursor.Data.SourceSlot == slot ) then 
			
            Cursor.Clear()        
           
        else  
            RequestMoveItem( Cursor.Data.Source, Cursor.Data.SourceSlot, Cursor.SOURCE_BANK, slot, Cursor.Data.StackAmount )            
            BankWindow.dropPending = true
        end
        
    else
        if DataUtils.IsValidItem( itemData ) then
            if flags == SystemData.ButtonFlags.SHIFT  then
                -- This doesn't send the item data for some reason
                --EA_ChatWindow.InsertItemLink( itemData )
            else
                Cursor.PickUp( Cursor.SOURCE_BANK, slot, itemData.uniqueID, itemData.iconNum, true)
            end
        end
        BankWindow.dropPending = false
    end
        
end

-- OnLButtonUp Handler
function BankWindow.EquipmentLButtonUp( buttonIndex )
	local slot = BankWindow.GetSlotNumberForButtonIndex( buttonIndex )  
	
    if Cursor.IconOnCursor() and BankWindow.dropPending == false then
    
        -- Attempt to drop the object
        RequestMoveItem( Cursor.Data.Source, Cursor.Data.SourceSlot, Cursor.SOURCE_BANK, slot, Cursor.Data.StackAmount )
    end
end


-- OnRButtonDown Handler
function BankWindow.EquipmentRButtonDown( buttonIndex, flags )

	local slot = BankWindow.GetSlotNumberForButtonIndex( buttonIndex )  
	local itemData = BankWindow.GetItem( slot )
    
    -- verify that we're clicking on an icon before spamming the server
    if not Cursor.IconOnCursor() and DataUtils.IsValidItem( itemData ) then

		
		if( (flags == SystemData.ButtonFlags.SHIFT) and itemData.stackCount > 1 ) then
			-- If Shift is Pressed, Show the stack count window
			ItemStackingWindow.Show(Cursor.SOURCE_BANK, slot)
		else
			 -- Attempt to put this item back into the inventory
			RequestMoveItem( Cursor.SOURCE_BANK, slot, Cursor.SOURCE_INVENTORY, GameData.Inventory.FIRST_AVAILABLE_INVENTORY_SLOT, itemData.stackCount)
		end

    end
end


function BankWindow.EquipmentMouseOver( buttonIndex )
	local slot = BankWindow.GetSlotNumberForButtonIndex( buttonIndex )  
    local itemData = BankWindow.GetItem( slot ) 
    if not DataUtils.IsValidItem( itemData ) then
        Tooltips.ClearTooltip()
    else 
        Tooltips.CreateAndTintItemTooltip( itemData, 
                                           SystemData.ActiveWindow.name.."Button"..buttonIndex,
                                           Tooltips.ANCHOR_WINDOW_RIGHT, 
                                           Tooltips.ENABLE_COMPARISON )
    end
    
end

function BankWindow.OnNewBankSlots()
    NUM_BANK_SLOTS = GameData.Player.numBankSlots
    BankWindow.ShowLocks( BankWindow.currentTabNumber )
    BankWindow.DisableUnpurchasedBankTabs()
end

function BankWindow.ShowLocks( tabNumber )
    local numberOfRowsLeftUnpurchased = (TOTAL_NUMBER_BANK_SLOTS - NUM_BANK_SLOTS) / NUM_COLS
    local numberOfRowsPurchased = (NUM_ROWS * NUM_TABS) - numberOfRowsLeftUnpurchased
    local startRow = (tabNumber - 1) * NUM_ROWS
    for i=1, NUM_ROWS
    do
        WindowSetShowing( WINDOW_NAME.."Lock"..i, i + startRow > numberOfRowsPurchased )
    end
end

function BankWindow.DisableUnpurchasedBankTabs()
    -- Start out at the second tab and if the previous tab has not been fully purchased disable the current
    for i=2, NUM_TABS
    do
        ButtonSetDisabledFlag( TAB_NAME..i, NUM_BANK_SLOTS < (i-1) * NUM_SLOTS_PER_TAB  )
    end
end

function BankWindow.SwitchTabs( tabNumber )
    if( tabNumber ~= BankWindow.currentTabNumber )
    then
        if( BankWindow.currentTabNumber ~= 0 )
        then
            ButtonSetPressedFlag( TAB_NAME..BankWindow.currentTabNumber, false )
        end

        BankWindow.ShowLocks( tabNumber )

        BankWindow.currentTabNumber = tabNumber

       BankWindow.SetBankSlotsInRange( GetMinVisibleBankSlot(), GetMaxVisibleBankSlot() )
    end

    ButtonSetPressedFlag( TAB_NAME..BankWindow.currentTabNumber, true )
end

function BankWindow.OnLButtonUpTab()
    if( not ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) )
    then
        BankWindow.SwitchTabs( WindowGetId(SystemData.ActiveWindow.name) )
    end
end

function BankWindow.OnMouseOverTab()
end

local purchasingBankSlots = false -- Whether or not we have popped up a dialog to purchase more bank slots

function BankWindow.OnBuyRow()

        if( purchasingBankSlots )
        then
            return
        end
        
        local newSlotsCost = GameData.Player.bankExpansionSlotsCost

        if( newSlotsCost <= 0 and GameData.Player.bankExpansionSlots <= 0 )
        then
            return
        end

        -- Create Confirmation Dialog
        local dialogText = GetStringFormat( StringTables.Default.DIALOG_BUY_BANK_SLOTS, {MoneyFrame.FormatMoneyString (newSlotsCost, false, true) } )
        
        local function donePurchasingBankSlots()
            purchasingBankSlots = false
        end
        
        local function buyExpansionSlots()
            donePurchasingBankSlots()
            
            if( GameData.Player.money < newSlotsCost )
            then
                DialogManager.MakeOneButtonDialog( GetString( StringTables.Default.DIALOG_CANNOT_BUY_BANK_SLOTS), GetString( StringTables.Default.LABEL_OKAY ) )
                return
            end
            BuyBankSlots()
            
        end

        DialogManager.MakeTwoButtonDialog( dialogText, 
									       GetString(StringTables.Default.LABEL_YES),
									       buyExpansionSlots,
									       GetString(StringTables.Default.LABEL_NO),
									       donePurchasingBankSlots )
									       
	    purchasingBankSlots = true
end

BankWindow.TOOLTIP_ANCHOR = {
                                Point="top", 
                                RelativeTo="",
                                RelativePoint="bottom", 
                                XOffset=0, 
                                YOffset=0
                            }

function BankWindow.OnMouseOverBuyRow()
    Tooltips.CreateTextOnlyTooltip( SystemData.MouseOverWindow.name, GetString( StringTables.Default.TOOLTIP_BUY_BANK_SLOTS ) )
    
    -- Anchor it to the Lock and not the button because the button is too large and makes the tooltip appear at the edge of the window.
    BankWindow.TOOLTIP_ANCHOR.RelativeTo = "BankWindowLock"..WindowGetId( WindowGetParent( SystemData.MouseOverWindow.name ) ).."Lock"
    
    Tooltips.AnchorTooltip( BankWindow.TOOLTIP_ANCHOR )
end
