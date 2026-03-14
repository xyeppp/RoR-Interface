----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

AuctionWindowSellControls = {}
AuctionWindowSellControls.itemInventorySlot = { slot = 0, backpack = 0 }
AuctionWindowSellControls.itemJustPickedUp = false

local WINDOW_NAME = "AuctionWindow"
local SELL_CONTROLS_NAME = WINDOW_NAME.."SellControls"

local DEFAULT_BUY_OUT_PRICE_MULTIPLIER = 2.0

function AuctionWindowSellControls.Initialize()
    -- Any of these events can change whether or not we are able to post Guild or Alliance only auctions
    WindowRegisterEventHandler( "AuctionWindow", SystemData.Events.GUILD_REFRESH,       "AuctionWindowSellControls.UpdateRestrictionTypes" )
    WindowRegisterEventHandler( "AuctionWindow", SystemData.Events.GUILD_INFO_UPDATED,  "AuctionWindowSellControls.UpdateRestrictionTypes" )
	WindowRegisterEventHandler( "AuctionWindow", SystemData.Events.GUILD_EXP_UPDATED,   "AuctionWindowSellControls.UpdateRestrictionTypes" )
    WindowRegisterEventHandler( "AuctionWindow", SystemData.Events.ALLIANCE_UPDATED,    "AuctionWindowSellControls.UpdateRestrictionTypes" )
    
    ButtonSetText( SELL_CONTROLS_NAME.."CreateButton", GetStringFromTable( "AuctionHouseStrings",  StringTables.AuctionHouse.CREATE_AUCTION_CREATE_BUTTON ) )
    ButtonSetText( SELL_CONTROLS_NAME.."ClearButton", GetStringFromTable( "AuctionHouseStrings",  StringTables.AuctionHouse.CREATE_AUCTION_CLEAR_BUTTON ) )
    LabelSetText( SELL_CONTROLS_NAME.."BuyOutPriceHeader", GetStringFromTable( "AuctionHouseStrings",  StringTables.AuctionHouse.CREATE_AUCTION_BUY_OUT_PRICE_LABEL ) )
    LabelSetText( SELL_CONTROLS_NAME.."DepositHeader", GetStringFromTable( "AuctionHouseStrings",  StringTables.AuctionHouse.CREATE_AUCTION_DEPOSIT_LABEL ) )
    LabelSetText( SELL_CONTROLS_NAME.."VendorPriceHeader", GetStringFromTable( "AuctionHouseStrings",  StringTables.AuctionHouse.CREATE_AUCTION_VENDOR_PRICE_LABEL ) )

    AuctionWindowSellControls.UpdateRestrictionTypes()
end

function AuctionWindowSellControls.ItemSlotLButtonDown()
    AuctionWindowSellControls.PickupItemIfPossible()
end

function AuctionWindowSellControls.ItemSlotLButtonUp()
    AuctionWindowSellControls.DropItemIfPossible()
end

function AuctionWindowSellControls.ItemSlotRButtonUp()
    AuctionWindowSellControls.Clear()
end

function AuctionWindowSellControls.ItemSlotMouseOver()
    local iconWindowName = SystemData.ActiveWindow.name
    
    if( AuctionWindowSellControls.itemInventorySlot.slot > 0 )
    then 
        local itemData = EA_BackpackUtilsMediator.GetItemsFromBackpack( AuctionWindowSellControls.itemInventorySlot.backpack )[AuctionWindowSellControls.itemInventorySlot.slot]
        if( itemData and itemData.id and itemData.id > 0 )
        then
            Tooltips.CreateItemTooltip (itemData, iconWindowName, Tooltips.ANCHOR_WINDOW_RIGHT)
        end
    end
end 

function AuctionWindowSellControls.PickupItemIfPossible()
    AuctionWindowSellControls.itemJustPickedUp = false
    
    if( AuctionWindowSellControls.itemInventorySlot.slot > 0 )
    then
        if( not Cursor.IconOnCursor() )
        then
            local backpackType = EA_BackpackUtilsMediator.GetCurrentBackpackType()
            local itemData = EA_BackpackUtilsMediator.GetItemsFromBackpack( AuctionWindowSellControls.itemInventorySlot.backpack )[AuctionWindowSellControls.itemInventorySlot.slot]
            if( itemData ~= nil  
                and EA_BackpackUtilsMediator.ReleaseLockForSlot(AuctionWindowSellControls.itemInventorySlot.slot,
                    AuctionWindowSellControls.itemInventorySlot.backpack, WINDOW_NAME)
               )
            then
                local cursor = EA_BackpackUtilsMediator.GetCursorForBackpack( AuctionWindowSellControls.itemInventorySlot.backpack )
                Cursor.PickUp( cursor, AuctionWindowSellControls.itemInventorySlot.slot, itemData.uniqueID, itemData.iconNum, true )
                AuctionWindowSellControls.Clear()
                AuctionWindowSellControls.itemJustPickedUp = true
            end
        end
    end

    return AuctionWindowSellControls.itemJustPickedUp
end

function AuctionWindowSellControls.Clear()
    DynamicImageSetTexture( SELL_CONTROLS_NAME.."ItemImageIcon", "", 0, 0 )
    LabelSetText( SELL_CONTROLS_NAME.."ItemName", L"" )
    ButtonSetText( SELL_CONTROLS_NAME.."ItemImage", L"" )
    
    MoneyFrame.FormatMoney( SELL_CONTROLS_NAME.."BuyOutPrice", 0, MoneyFrame.SHOW_EMPTY_WINDOWS )
    MoneyFrame.FormatMoney( SELL_CONTROLS_NAME.."DepositPrice", 0, MoneyFrame.HIDE_EMPTY_WINDOWS )
    MoneyFrame.FormatMoney( SELL_CONTROLS_NAME.."VendorPrice", 0, MoneyFrame.HIDE_EMPTY_WINDOWS )
    
    AuctionWindowSellControls.UpdateCreateButton()
	
	if ( AuctionWindowSellControls.itemInventorySlot.slot > 0 )
    then
	    EA_BackpackUtilsMediator.ReleaseLockForSlot(AuctionWindowSellControls.itemInventorySlot.slot,
	                                                AuctionWindowSellControls.itemInventorySlot.backpack,
	                                                WINDOW_NAME )
	    AuctionWindowSellControls.itemInventorySlot = { slot = 0, backpack = 0 }
	end
end

function AuctionWindowSellControls.UpdateCreateButton()
    local itemName = LabelGetText( SELL_CONTROLS_NAME.."ItemName", itemData.name )
    ButtonSetDisabledFlag( SELL_CONTROLS_NAME.."CreateButton", itemName == L"" )
end

function AuctionWindowSellControls.UpdateRestrictionTypes()
    local comboBoxName = SELL_CONTROLS_NAME.."RestrictionComboBox"
    ComboBoxClearMenuItems( comboBoxName )
	ComboBoxAddMenuItem( comboBoxName, GetStringFromTable( "AuctionHouseStrings", StringTables.AuctionHouse.CONTEXT_MENU_ADDITIONAL_FILTERS_UNRESTRICTED ) )
	
	if AuctionWindow.PlayerCanSearchGuildAuctions()
	then
		ComboBoxAddMenuItem( comboBoxName, GetStringFromTable( "AuctionHouseStrings", StringTables.AuctionHouse.CONTEXT_MENU_ADDITIONAL_FILTERS_GUILD ) )
	end
	
	if AuctionWindow.PlayerCanSearchAllianceAuctions()
	then
		ComboBoxAddMenuItem( comboBoxName, GetStringFromTable( "AuctionHouseStrings", StringTables.AuctionHouse.CONTEXT_MENU_ADDITIONAL_FILTERS_ALLIANCE ) )
	end
	
    ComboBoxSetSelectedMenuItem( comboBoxName, GameData.Auction.RESTRICTION_NONE)
end

function AuctionWindowSellControls.UpdatePrices( itemData )
    local basePrice = itemData.sellPrice * itemData.stackCount
    local depositPrice = math.floor( basePrice * GameData.Auction.DEPOSIT_MULTIPLIER )    
    
    if depositPrice < 1
    then
		depositPrice = 1
    end

    local buyOutPrice = math.floor( basePrice * DEFAULT_BUY_OUT_PRICE_MULTIPLIER )
    MoneyFrame.FormatMoney( SELL_CONTROLS_NAME.."BuyOutPrice", buyOutPrice, MoneyFrame.SHOW_EMPTY_WINDOWS )
    MoneyFrame.FormatMoney( SELL_CONTROLS_NAME.."DepositPrice", depositPrice, MoneyFrame.HIDE_EMPTY_WINDOWS )
    MoneyFrame.FormatMoney( SELL_CONTROLS_NAME.."VendorPrice", basePrice, MoneyFrame.HIDE_EMPTY_WINDOWS )
end

function AuctionWindowSellControls.UpdateForItem( itemData )

    local texture, x, y = GetIconData( itemData.iconNum )
    DynamicImageSetTexture( SELL_CONTROLS_NAME.."ItemImageIcon", texture, x, y )
    LabelSetText( SELL_CONTROLS_NAME.."ItemName", itemData.name )
    
    -- Stack Count            
    if( itemData.stackCount > 1 ) then
        ButtonSetText( SELL_CONTROLS_NAME.."ItemImage", L""..itemData.stackCount )
    else
        ButtonSetText( SELL_CONTROLS_NAME.."ItemImage", L"" )
    end
    
    AuctionWindowSellControls.UpdatePrices( itemData )
    
    AuctionWindowSellControls.UpdateCreateButton()
end

function AuctionWindowSellControls.DropItemIfPossible()
    
    if Cursor.IconOnCursor() and not AuctionWindowSellControls.itemJustPickedUp
    then
        local isTrial, _ = GetAccountData()
        
        if( isTrial )
        then
            EA_TrialAlertWindow.Show(SystemData.TrialAlert.ALERT_AUCTION)
            return
        end
    
        local backpackType = EA_BackpackUtilsMediator.GetCurrentBackpackType()
        local currentCursor = EA_BackpackUtilsMediator.GetCursorForBackpack( backpackType )
        if Cursor.Data and Cursor.Data.Source == currentCursor
        then
            local inventorySlot = Cursor.Data.SourceSlot
            local itemData = EA_BackpackUtilsMediator.GetItemsFromBackpack( backpackType )[inventorySlot]
            
            -- acquiring lock on inventory slot number
            if( itemData
                and EA_BackpackUtilsMediator.RequestLockForSlot( inventorySlot, backpackType, WINDOW_NAME ) )
            then
                
                Cursor.Clear ()
                
                -- Check to see if there was an item already in slot that we need to pick up
                if AuctionWindowSellControls.itemInventorySlot.slot > 0
                then
                    AuctionWindowSellControls.PickupItemIfPossible()
                end

                AuctionWindowSellControls.UpdateForItem( itemData )
                
                AuctionWindowSellControls.itemInventorySlot = { slot = inventorySlot, backpack = backpackType }
            end
        end
    end 
    
    AuctionWindowSellControls.itemJustPickedUp = false
end

function AuctionWindowSellControls.Create()  
    if( ButtonGetDisabledFlag( SELL_CONTROLS_NAME.."CreateButton") == true 
        or AuctionWindowSellControls.itemInventorySlot.slot == 0 )
    then
        Sound.Play( Sound.ACTION_FAILED )
        return
    end
    
    local depositPrice = MoneyFrame.ConvertCurrencyToBrass( SELL_CONTROLS_NAME.."DepositPrice" )
    if( Player.GetMoney() < depositPrice )
    then
        local okayText = GetString (StringTables.Default.LABEL_OKAY)
        DialogManager.MakeOneButtonDialog( GetStringFromTable( "AuctionHouseStrings",  StringTables.AuctionHouse.LABEL_ERROR_INSUFFICIENT_FUNDS ), okayText)  
        return
    end
        
    local buyOutPrice = MoneyFrame.ConvertCurrencyToBrass( SELL_CONTROLS_NAME.."BuyOutPrice" )
    if( buyOutPrice < 1 )
    then
        local okayText = GetString (StringTables.Default.LABEL_OKAY)
        DialogManager.MakeOneButtonDialog( GetStringFromTable( "AuctionHouseStrings",  StringTables.AuctionHouse.LABEL_ERROR_NO_PRICE ), okayText)  
        return
    end
    
    local restrictionChoice = ComboBoxGetSelectedMenuItem( SELL_CONTROLS_NAME.."RestrictionComboBox" )
    
    CreateAuction( AuctionWindowSellControls.itemInventorySlot.slot, AuctionWindowSellControls.itemInventorySlot.backpack, buyOutPrice, restrictionChoice ) 

    Sound.Play( Sound.AUCTION_HOUSE_CREATE_AUCTION )

    AuctionWindowSellControls.Clear()
    
    -- Refresh display to include newly sold item
    AuctionWindowListDataManager.SendPlayersAuctionSearch()
end
