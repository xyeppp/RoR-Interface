----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

-- TODO: Make sure to check for player option to block incoming trades

EA_Window_Trade = {}

-- This table keeps a map of trade items (added to our side of the trade) to their backpack slot
--   NOTE that there may be more items in this array than in EA_Window_Trade.myOfferItemData,
--   which just means that we haven't received confirmation yet on those items.
EA_Window_Trade.PendingTradeItems = {}

EA_Window_Trade.NUM_TRADE_SLOTS  = 9


EA_Window_Trade.MY_OFFER_UPDATED  = 0
EA_Window_Trade.OTHER_OFFER_UPDATED = 1

EA_Window_Trade.TOOLTIP_ANCHOR = { Point = "topright",   RelativeTo = "EA_Window_Trade", RelativePoint = "topleft",   XOffset=5, YOffset=75 }

EA_Window_Trade.myOfferItemData              = {}
EA_Window_Trade.myOfferMoney                 = 0
EA_Window_Trade.otherOfferItemData           = {} 
EA_Window_Trade.otherOfferMoney              = 0

EA_Window_Trade.IAccepted = false
EA_Window_Trade.otherPlayerAccepted = false
EA_Window_Trade.tradeCompleted = false
EA_Window_Trade.OtherPlayerHasMadeInitialOffer = false

EA_Window_Trade.SECURE_TRADE_TIMEOUT		= 0 -- in seconds, this actually gets set every time a trade is initiated
EA_Window_Trade.SECURE_TRADE_TIMER_OFF		= 9999

EA_Window_Trade.secureTimeRemaining = EA_Window_Trade.SECURE_TRADE_TIMER_OFF


----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

local REFRESH_MY_OFFER		= 0
local REFRESH_OTHER_OFFER	= 1
local REFRESH_BOTH			= 2



----------------------------------------------------------------
-- EA_Window_Trade Functions
----------------------------------------------------------------

-- OnInitialize Handler
function EA_Window_Trade.Initialize()    
    
	local windowName = "EA_Window_Trade"
    
    WindowRegisterEventHandler (windowName, SystemData.Events.PLAYER_TRADE_INITIATED, "EA_Window_Trade.TradeInitiated")
    WindowRegisterEventHandler (windowName, SystemData.Events.PLAYER_TRADE_ITEMS_UPDATED, "EA_Window_Trade.UpdateMyTradeOffer")
    WindowRegisterEventHandler (windowName, SystemData.Events.PLAYER_OFFER_ITEMS_UPDATED, "EA_Window_Trade.UpdateOtherTradeOffer")
    WindowRegisterEventHandler (windowName, SystemData.Events.PLAYER_TRADE_ACCEPTED, "EA_Window_Trade.OtherPlayerAccepted")
    WindowRegisterEventHandler (windowName, SystemData.Events.PLAYER_TRADE_CANCELLED, "EA_Window_Trade.Hide")
    
    MoneyFrame.RegisterCallbackForValueChanged( windowName.."UserTradeOfferMoney", EA_Window_Trade.MyMoneyChangedByUser )

    LabelSetText( windowName.."TitleBarText", GetString( StringTables.Default.LABEL_TRADE ) )    
    LabelSetText( windowName.."UserTradeOfferName", GetString( StringTables.Default.LABEL_TRADE_YOUR_OFFER ) )

    ButtonSetText( windowName.."UserAcceptButton", GetString( StringTables.Default.LABEL_ACCEPT ) )
    ButtonSetText( windowName.."CancelButton", GetString( StringTables.Default.LABEL_CANCEL ) )
    
    EA_Window_Trade.DisplayIHaveNotAccepted()
    EA_Window_Trade.DisplayOtherHasAccepted()
    
end

function EA_Window_Trade.TradeOpen()

	return WindowGetShowing( "EA_Window_Trade" ) 
end

function EA_Window_Trade.GetTradeSlotNum( invSlotNum, backpackType )
	
	for slot, pendingSlot in ipairs( EA_Window_Trade.PendingTradeItems )
    do
		if pendingSlot.slot == invSlotNum and pendingSlot.backpack == backpackType
        then
			return slot
		end
	end
	
	return 0
end

-- does client side validation that item is tradable and display error msg to chat window if it isn't
--     return a bool saying whether successful or not
--
function EA_Window_Trade.AddInventoryItem( invSlotNum, backpackType )

    local inventory = EA_BackpackUtilsMediator.GetItemsFromBackpack( backpackType )
	local itemData = inventory[invSlotNum]
	if (itemData == nil) or
	   (itemData.flags[GameData.Item.EITEMFLAG_NO_MOVE] == true) or 
	   (itemData.boundToPlayer == true) 
	   then
		
		local errorText = GetString( StringTables.Default.TEXT_TRADE_ERROR_NON_TRADABLE_ITEM )
		EA_ChatWindow.Print(errorText, SystemData.ChatLogFilters.SAY) 
		return false
	
	elseif #EA_Window_Trade.PendingTradeItems == EA_Window_Trade.NUM_TRADE_SLOTS then
		-- this should be obvious enough why it doesn't add.
		return false
	end

	-- which trade slot we're requesting doesn't matter so just hardcoding 1, 
	--   since server is just putting it in first available slot
	ChangeTrade( 1, invSlotNum, backpackType, EA_Window_Trade.myOfferMoney )
    EA_Window_Trade.InsertPendingTradeItem( invSlotNum , backpackType )

	return true
end

function EA_Window_Trade.InsertPendingTradeItem( invSlotNum , backpackType )
    for slot = 1, EA_Window_Trade.NUM_TRADE_SLOTS
    do
        if( not EA_Window_Trade.PendingTradeItems[slot] )
        then
            EA_Window_Trade.PendingTradeItems[slot] = { slot = invSlotNum, backpack = backpackType }
            EA_BackpackUtilsMediator.RequestLockForSlot( invSlotNum, backpackType, "EA_Window_Trade" )
            return
        end
    end
end

function EA_Window_Trade.RemovePendingTradeItem( invSlotNum , backpackType )
    local itemFound = false
    for slot = 1, EA_Window_Trade.NUM_TRADE_SLOTS
    do
        if( EA_Window_Trade.PendingTradeItems[slot] and
            EA_Window_Trade.PendingTradeItems[slot].slot == invSlotNum and
            EA_Window_Trade.PendingTradeItems[slot].backpack == backpackType )
        then
            EA_Window_Trade.PendingTradeItems[slot] = nil
            EA_BackpackUtilsMediator.ReleaseLockForSlot( invSlotNum, backpackType, "EA_Window_Trade" )
            itemFound = true
        end
        if( itemFound and slot ~= EA_Window_Trade.NUM_TRADE_SLOTS)
        then
            EA_Window_Trade.PendingTradeItems[slot] = EA_Window_Trade.PendingTradeItems[slot + 1]
        end
    end
end
      
function EA_Window_Trade.ClearInventoryItem( invSlotNum, backpackType )

	slot = EA_Window_Trade.GetTradeSlotNum( invSlotNum, backpackType )
	EA_Window_Trade.ClearTradeSlot( slot, invSlotNum, backpackType )
end

-- NOTE: This may be called on a pending item slot which is not in EA_Window_Trade.myOfferItemData yet
function EA_Window_Trade.ClearTradeSlot( slot, invSlotNum, backpackType )
	
	if slot == nil or slot < 1 or slot > EA_Window_Trade.NUM_TRADE_SLOTS then
		ERROR(L"EA_Window_Trade.ClearTradeSlot: Invalid slot")
		return
	end
	
	-- tell server we're removing item from trade
	ChangeTrade( slot, 0, 0, EA_Window_Trade.myOfferMoney )
	
	-- do a temporary clear of the icon
	DynamicImageSetTexture ("EA_Window_TradeUserTradeOfferSlot"..slot.."Icon", "", 0, 0)
	ButtonSetText("EA_Window_TradeUserTradeOfferSlot"..slot, L"" )
	    
    EA_Window_Trade.RemovePendingTradeItem( invSlotNum , backpackType )
end	

-- Clear the Trade Window data
function EA_Window_Trade.ResetData ()

	EA_Window_Trade.myOfferItemData              = {} 
	EA_Window_Trade.myOfferMoney                 = 0
	EA_Window_Trade.otherOfferItemData           = {} 
	EA_Window_Trade.otherOfferMoney              = 0
	EA_Window_Trade.tradeCompleted               = false

	EA_BackpackUtilsMediator.ReleaseAllLocksForWindow( "EA_Window_Trade" )
	EA_Window_Trade.PendingTradeItems = {}
	
	EA_Window_Trade.OtherPlayerHasMadeInitialOffer = false
    EA_Window_Trade.secureTimeRemaining = EA_Window_Trade.SECURE_TRADE_TIMER_OFF
end

-- Retrieves offer data provided from Data Layer
function EA_Window_Trade.RefreshItemData (refreshType)
    if (REFRESH_MY_OFFER == refreshType) then
        EA_Window_Trade.myOfferItemData, EA_Window_Trade.myOfferMoney = GetTradeItemData(EA_Window_Trade.MY_OFFER_UPDATED)
    elseif (REFRESH_OTHER_OFFER == refreshType) then
        EA_Window_Trade.otherOfferItemData, EA_Window_Trade.otherOfferMoney = GetTradeItemData(EA_Window_Trade.OTHER_OFFER_UPDATED)
    elseif (REFRESH_BOTH == refreshType) then
        EA_Window_Trade.myOfferItemData, EA_Window_Trade.myOfferMoney = GetTradeItemData(EA_Window_Trade.MY_OFFER_UPDATED)
        EA_Window_Trade.otherOfferItemData, EA_Window_Trade.otherOfferMoney = GetTradeItemData(EA_Window_Trade.OTHER_OFFER_UPDATED)
    end
end

function EA_Window_Trade.SetTradeSlot(windowName, slot, slotName, slotIcon, stackCount )

    if (slotName ~= L"" ) then
        local texture, x, y = GetIconData (slotIcon)
        DynamicImageSetTexture (windowName.."Slot"..slot.."Icon", texture, x, y)
        
        if( stackCount > 1 ) then
            ButtonSetText(windowName.."Slot"..slot, L""..stackCount )
        else
            ButtonSetText(windowName.."Slot"..slot, L"" )
        end
    else
        DynamicImageSetTexture (windowName.."Slot"..slot.."Icon", "", 0, 0)
        ButtonSetText(windowName.."Slot"..slot, L"" )
    end
end



-- Begin trade 
function EA_Window_Trade.InitiateTradeWithCurrentTarget (targetName)
	
	-- NOTE: ASSUMPTION: this assumes we can only trade with one player at a time
	--  though wouldn't be difficult to change
    if not EA_Window_Trade.TradeOpen() then
		--GameData.Player.TradeTarget.Name = targetName
		InitiateTrade( 1, 0 )
		
	    EA_Window_Trade.RefreshItemData (REFRESH_BOTH)
		EA_Window_Trade.Show()
	end
end


--  Trade started by other player
function EA_Window_Trade.TradeInitiated ()
    
    EA_Window_Trade.DisplayMyOffer()
    EA_Window_Trade.DisplayOtherPlayersOffer()

	EA_Window_Trade.Show ()
end

-- Show Trade Window
function EA_Window_Trade.Show ()

    if not EA_Window_Trade.TradeOpen() then
		LabelSetText( "EA_Window_TradeOtherTradeOfferName", GetStringFormat( StringTables.Default.LABEL_TRADE_OTHERS_OFFER, {GameData.Player.TradeTarget.Name} ) )

        WindowSetShowing ("EA_Window_Trade", true)
    end
end

        
-- Hide the Trade Window
function EA_Window_Trade.Hide()
    if EA_Window_Trade.TradeOpen() then
        WindowSetShowing ("EA_Window_Trade", false)
    end
end

function EA_Window_Trade.OnHidden()
    WindowUtils.OnHidden()
    -- We do this to ensure that the trade is cancelled if they close the window by hitting escape
    if( not EA_Window_Trade.tradeCompleted ) then
        CancelTrade()
    end
    EA_Window_Trade.ResetData ()
end

function EA_Window_Trade.OnShown()
    WindowUtils.OnShown(EA_Window_Trade.Hide, WindowUtils.Cascade.MODE_AUTOMATIC)
end

-- TODO: Rewrite this code, so it always keeps myOfferItemData and PendingTradeItems in sync.
-- The current solution is flawed and will generate some minor glitches.
function EA_Window_Trade.DisplayMyOffer()

    EA_Window_Trade.RefreshItemData (REFRESH_MY_OFFER)

    local windowName = "EA_Window_TradeUserTradeOffer"
    for  slot = 1, EA_Window_Trade.NUM_TRADE_SLOTS  do
        
		local itemData = EA_Window_Trade.myOfferItemData[slot]
        local slotName = itemData.name
        local slotIcon = 0
        local stackCount = 0
        
        if DataUtils.IsValidItem( itemData )
        then
      
            slotIcon = EA_Window_Trade.myOfferItemData[slot].iconNum
            stackCount = EA_Window_Trade.myOfferItemData[slot].stackCount
            
            local pendingSlot = EA_Window_Trade.FindSlotForPendingItem( itemData.uniqueID )
            if( not pendingSlot )
            then
				DEBUG(L"EA_Window_Trade.DisplayMyOffer received trade item: "..slotName..L" not found in EA_Window_Trade.PendingTradeItems so it will not be locked in backpack.")
            end
				
		elseif( EA_Window_Trade.PendingTradeItems[slot] ~= nil )
        then
            local invSlot = EA_Window_Trade.PendingTradeItems[slot].slot
            local backpackType = EA_Window_Trade.PendingTradeItems[slot].backpack
            EA_Window_Trade.RemovePendingTradeItem( invSlot , backpackType )
        end
        
        EA_Window_Trade.SetTradeSlot(windowName, slot, slotName, slotIcon, stackCount)
        
    end
    EA_Window_Trade.UpdateMyMoney()
    
    EA_Window_Trade.DisableAcceptIfNothingToTrade()
end


function EA_Window_Trade.FindSlotForPendingItem( uniqueID )
    for slot = 1, EA_Window_Trade.NUM_TRADE_SLOTS do
    
        if( EA_Window_Trade.PendingTradeItems[slot] )
        then
            local invSlot = EA_Window_Trade.PendingTradeItems[slot].slot
            local backpackType = EA_Window_Trade.PendingTradeItems[slot].backpack
            local inventory = EA_BackpackUtilsMediator.GetItemsFromBackpack( backpackType )
            local invItemData = inventory[ invSlot ]
            if invItemData.uniqueID == uniqueID
            then
                return slot
            end
        end
    end
    
	return nil
end
        
    
function EA_Window_Trade.DisplayOtherPlayersOffer()

    EA_Window_Trade.RefreshItemData (REFRESH_OTHER_OFFER)

    windowName = "EA_Window_TradeOtherTradeOffer"
    for  slot = 1, EA_Window_Trade.NUM_TRADE_SLOTS  do
        
        local slotName = EA_Window_Trade.otherOfferItemData[slot].name
        local slotIcon = 0
        local stackCount = 0
        
        if (slotName ~= L"") then
            slotIcon = EA_Window_Trade.otherOfferItemData[slot].iconNum
            stackCount = EA_Window_Trade.otherOfferItemData[slot].stackCount
        end
        EA_Window_Trade.SetTradeSlot(windowName, slot, slotName, slotIcon, stackCount)
        
    end
    EA_Window_Trade.UpdateOtherPlayersMoney()
    
    EA_Window_Trade.DisableAcceptIfNothingToTrade()
    
    if not EA_Window_Trade.NothingToTrade() then
		EA_Window_Trade.OtherPlayerHasMadeInitialOffer = true
	end
end

-- ASSUMPTION: this assumes we only need to check the first slot to see if any items were offered
--
function EA_Window_Trade.NothingToTrade()

	if EA_Window_Trade.myOfferMoney > 0 or EA_Window_Trade.otherOfferMoney > 0 then
	
		return false
	
	elseif EA_Window_Trade.myOfferItemData ~= nil  and DataUtils.IsValidItem( EA_Window_Trade.myOfferItemData[1] ) then
		
		return false
	
	elseif EA_Window_Trade.otherOfferItemData ~= nil and DataUtils.IsValidItem( EA_Window_Trade.otherOfferItemData[1] ) then

		return false
	end
	
	return true
end

function EA_Window_Trade.UpdateMyMoney()
    MoneyFrame.FormatMoney ("EA_Window_TradeUserTradeOfferMoney", EA_Window_Trade.myOfferMoney, MoneyFrame.SHOW_EMPTY_WINDOWS)
end

function EA_Window_Trade.UpdateOtherPlayersMoney()
    MoneyFrame.FormatMoney ("EA_Window_TradeOtherTradeOfferMoney", EA_Window_Trade.otherOfferMoney, MoneyFrame.SHOW_EMPTY_WINDOWS)
end



function EA_Window_Trade.PickupItemIfPossible()

    local slot = WindowGetId(SystemData.ActiveWindow.name)
    
    if not Cursor.IconOnCursor() and EA_Window_Trade.SlotIsInMyTradeOffer( SystemData.ActiveWindow.name ) then

		local itemData  = EA_Window_Trade.myOfferItemData[slot]
		local invSlotNum = EA_Window_Trade.PendingTradeItems[slot].slot
        local currentBackpackType = EA_BackpackUtilsMediator.GetCurrentBackpackType()
        local cursor = EA_BackpackUtilsMediator.GetCursorForBackpack( currentBackpackType )
        
        if itemData ~= nil and itemData.uniqueID ~= 0 and invSlotNum ~= nil then
            Cursor.PickUp( cursor, invSlotNum, itemData.uniqueID, itemData.iconNum, true )
  		
            local clearedBackpack = EA_Window_Trade.PendingTradeItems[slot].backpack
  			EA_Window_Trade.ClearTradeSlot( slot, invSlotNum, clearedBackpack )
			return true
        end
	end
	
	return false
end


function EA_Window_Trade.DropItemIfPossible()
	
    local slot = WindowGetId(SystemData.ActiveWindow.name)

    if Cursor.IconOnCursor() then

        local currentBackpackType = EA_BackpackUtilsMediator.GetCurrentBackpackType()
        local cursor = EA_BackpackUtilsMediator.GetCursorForBackpack( currentBackpackType )
		if Cursor.Data and Cursor.Data.Source == cursor then
			
			local invSlotNum = Cursor.Data.SourceSlot
			if EA_Window_Trade.AddInventoryItem( invSlotNum, currentBackpackType ) then
				Cursor.Clear ()
			end
        end
        
    end    
end

-- OnLButtonDown Handler
function EA_Window_Trade.ItemSlotLButtonDown()

	EA_Window_Trade.PickupItemIfPossible()
end

-- OnLButtonUp Handler
function EA_Window_Trade.ItemSlotLButtonUp()

    EA_Window_Trade.DropItemIfPossible()
end

-- OnRButtonUp Handler
function EA_Window_Trade.ItemSlotRButtonUp (flags, x, y)

	if EA_Window_Trade.PickupItemIfPossible() then
		Cursor.Clear ()
	end

end


-- SystemData.Events.PLAYER_TRADE_ITEMS_UPDATED Handler
function EA_Window_Trade.UpdateMyTradeOffer()

	EA_Window_Trade.DisplayMyOffer()
	EA_Window_Trade.UnsetAcceptButtons()
end


-- SystemData.Events.PLAYER_OFFER_ITEMS_UPDATED Handler
function EA_Window_Trade.UpdateOtherTradeOffer()
	
	
	EA_Window_Trade.DisplayOtherPlayersOffer()
	EA_Window_Trade.UnsetAcceptButtons()
	
	if EA_Window_Trade.OtherPlayerHasMadeInitialOffer and not EA_Window_Trade.NothingToTrade() then
			
		EA_Window_Trade.SECURE_TRADE_TIMEOUT = GameData.Player.TradeTarget.Timeout

		--set timer before can press Accept button again
		EA_Window_Trade.StartSecureTradeTimer()
	end
end


function EA_Window_Trade.SlotIsInMyTradeOffer( slotName )

	local parentName = WindowGetParent( slotName )
	
	if parentName == "EA_Window_TradeUserTradeOffer" then
		return true
	else
		return false
	end
end

function EA_Window_Trade.SlotIsInOtherPlayerTradeOffer( slotName )

	local parentName = WindowGetParent( slotName )
	
	if parentName == "EA_Window_TradeOtherTradeOffer" then
		return true
	else
		return false
	end
end

-- OnMouseMove Handler
function EA_Window_Trade.ItemSlotMouseOver()
	local windowName = SystemData.ActiveWindow.name
	local slot = WindowGetId(windowName)
	local itemData = nil

	if EA_Window_Trade.SlotIsInMyTradeOffer( windowName ) then
		itemData = EA_Window_Trade.myOfferItemData[slot]
		
	elseif EA_Window_Trade.SlotIsInOtherPlayerTradeOffer( windowName ) then
		itemData = EA_Window_Trade.otherOfferItemData[slot]
		
	else
		ERROR( L"EA_Window_Trade.ItemSlotMouseOver: unknown window name." )
		return
	end
	
	if itemData and itemData.id and itemData.id > 0 then
		Tooltips.CreateItemTooltip (itemData, windowName, Tooltips.ANCHOR_WINDOW_RIGHT)
    end

end 


function EA_Window_Trade.DisableAcceptIfNothingToTrade()
	if EA_Window_Trade.NothingToTrade() then
		ButtonSetDisabledFlag( "EA_Window_TradeUserAcceptButton", true )
	elseif EA_Window_Trade.secureTimeRemaining == EA_Window_Trade.SECURE_TRADE_TIMER_OFF then
		ButtonSetDisabledFlag( "EA_Window_TradeUserAcceptButton", false )
	end
end

-- NOTE: this will disable the user's accept button if no data has been pulled yet
--
function EA_Window_Trade.UnsetAcceptButtons()

	EA_Window_Trade.DisplayIHaveNotAccepted()
	EA_Window_Trade.DisplayOtherHasNotAccepted()
end


function EA_Window_Trade.DisplayIHaveAccepted()
	EA_Window_Trade.IAccepted = true
	DefaultColor.SetLabelColor( "EA_Window_TradeUserTradeOfferName", DefaultColor.TEAL )
	DefaultColor.SetWindowTint("EA_Window_TradeUserTradeOfferFrame", DefaultColor.TEAL )
end


-- NOTE: this will disable the user's accept button if no data has been pulled yet
--
function EA_Window_Trade.DisplayIHaveNotAccepted()
	EA_Window_Trade.IAccepted = false
	DefaultColor.SetLabelColor( "EA_Window_TradeUserTradeOfferName", DefaultColor.CLEAR_WHITE )
    DefaultColor.SetWindowTint("EA_Window_TradeUserTradeOfferFrame", DefaultColor.BLACK )
end

function EA_Window_Trade.DisplayOtherHasAccepted()
	EA_Window_Trade.otherPlayerAccepted = true
	DefaultColor.SetLabelColor( "EA_Window_TradeOtherTradeOfferName", DefaultColor.TEAL )
        DefaultColor.SetWindowTint("EA_Window_TradeOtherTradeOfferFrame", DefaultColor.TEAL )
end

function EA_Window_Trade.DisplayOtherHasNotAccepted()
	EA_Window_Trade.otherPlayerAccepted = false
	DefaultColor.SetLabelColor( "EA_Window_TradeOtherTradeOfferName", DefaultColor.CLEAR_WHITE )
        DefaultColor.SetWindowTint("EA_Window_TradeOtherTradeOfferFrame", DefaultColor.BLACK )
end

function EA_Window_Trade.ToggleAcceptButton()

	-- ignore button presses when disabled
    if ButtonGetDisabledFlag( "EA_Window_TradeUserAcceptButton" ) then
		return
	end	
	
	if EA_Window_Trade.IAccepted == false then
		EA_Window_Trade.AcceptTrade()
	else
		EA_Window_Trade.UnacceptTrade()
	end
end

function EA_Window_Trade.AcceptTrade()

	EA_Window_Trade.DisplayIHaveAccepted()
	AcceptTrade()
	
	if EA_Window_Trade.otherPlayerAccepted == true then
		EA_Window_Trade.TradeComplete()
	end
end


function EA_Window_Trade.UnacceptTrade()
	EA_Window_Trade.DisplayIHaveNotAccepted()
    ChangeTrade( 0, 0, 0, EA_Window_Trade.myOfferMoney )
end

function EA_Window_Trade.OtherPlayerAccepted()

	EA_Window_Trade.DisplayOtherHasAccepted()
	
	if EA_Window_Trade.IAccepted == true then
		EA_Window_Trade.TradeComplete()
	end
end

function EA_Window_Trade.OnUpdate( timePassed )
	if EA_Window_Trade.secureTimeRemaining ~= EA_Window_Trade.SECURE_TRADE_TIMER_OFF then
		EA_Window_Trade.UpdateSecureTradeTimer( timePassed )
	end
end

function EA_Window_Trade.StartSecureTradeTimer()
    ButtonSetDisabledFlag( "EA_Window_TradeUserAcceptButton", true )
    
    EA_Window_Trade.secureTimeRemaining = EA_Window_Trade.SECURE_TRADE_TIMEOUT
end

function EA_Window_Trade.UpdateSecureTradeTimer( timePassed )
	EA_Window_Trade.secureTimeRemaining = EA_Window_Trade.secureTimeRemaining - timePassed
	
	if EA_Window_Trade.secureTimeRemaining <= 0 
	then
		EA_Window_Trade.CompleteSecureTradeTimer()
	end
end

function EA_Window_Trade.CompleteSecureTradeTimer()

    EA_Window_Trade.secureTimeRemaining = EA_Window_Trade.SECURE_TRADE_TIMER_OFF
    ButtonSetDisabledFlag( "EA_Window_TradeUserAcceptButton", false )
end

function EA_Window_Trade.TradeComplete()
    EA_Window_Trade.tradeCompleted = true
	EA_Window_Trade.Hide()
end

-- Cancel the Trade and Hide the window
function EA_Window_Trade.CancelTrade ()

    if EA_Window_Trade.TradeOpen() then
		EA_Window_Trade.Hide()
        CancelTrade()
    end
end
	

function EA_Window_Trade.MyMoneyChangedByUser( money )

	if EA_Window_Trade.myOfferMoney ~= money then
		EA_Window_Trade.myOfferMoney = money
		ChangeTrade( 0, 0, 0, EA_Window_Trade.myOfferMoney )
	end
end


-- OnShutdown Handler
function EA_Window_Trade.Shutdown()

	local windowName = "EA_Window_Trade"
	EA_Window_Trade.CancelTrade() -- will only send msg if trade window is showing

	MoneyFrame.UnregisterCallbackForValueChanged( "EA_Window_TradeUserTradeOfferMoney" )
end
