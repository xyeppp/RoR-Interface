----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------
MailWindowTabSend = {}

MailWindowTabSend.attachments = {}
MailWindowTabSend.MAX_ATTACHMENTS = 16

-- Icon for no attachment
-- <Icon id="00020" texture="Textures/Ge_Accessory.dds" name="										Generic Equip"/>
MailWindowTabSend.EMPTY_ATTACHMENT_ICON = 20

----------------------------------------------------------------
-- Local Functions
----------------------------------------------------------------

-- This function adds all the Gold, Silver, and Brass in the attachement section. It returns false if player has insufficient funds, true otherwise
local function CheckSufficientFunds(g, s, b)
    local attachment = (g * 10000) + (s * 100) + b
    if  attachment + MailWindow.PostageCostTotal > Player.GetMoney()
    then
        return false
    else
        return true
    end 
end

----------------------------------------------------------------
-- Global Functions
----------------------------------------------------------------
function MailWindowTabSend.Initialize()
	ActionButtonGroupSetNumButtons( "MailWindowTabSendAttachmentSlots", MailWindow.ATTACHMENTS_MAX_ROWS, MailWindow.ATTACHMENTS_MAX_COLS )

    LabelSetText("MailWindowTabSendToHeader",		            GetMailString( StringTables.Mail.LABEL_MAIL_HEADER_TO ) )
    LabelSetText("MailWindowTabSendSubjectHeader",	            GetMailString( StringTables.Mail.LABEL_MAIL_HEADER_SUBJECT ) )
    LabelSetText("MailWindowTabSendMessageBodyHeader",          GetMailString( StringTables.Mail.LABEL_MAIL_HEADER_MESSAGE ) )
    LabelSetText("MailWindowTabSendPostageHeader",	            GetMailString( StringTables.Mail.LABEL_MAIL_HEADER_POSTAGE_COST ) )
    LabelSetText("MailWindowTabSendCODCheckBoxButtonHeader",    GetMailString( StringTables.Mail.LABEL_MAIL_CHECKBOX_COD ) )
    LabelSetText("MailWindowTabSendMoneyInBackpackHeader",      GetMailString( StringTables.Mail.LABEL_MAIL_MONEY_IN_BACPACK ) )

    ButtonSetText("MailWindowTabSendCommandSendButton", GetMailString( StringTables.Mail.BUTTON_MAIL_SEND ) )

    ButtonSetStayDownFlag("MailWindowTabSendCODCheckBoxButton", true)
    ButtonSetCheckButtonFlag("MailWindowTabSendCODCheckBoxButton", true)
    MailWindowTabSend.SetCODFlag(false)

	MailWindowTabSend.ClearAttachments()
    MailWindowTabSend.ClearAttachmentMoney()
    MailWindowTabSend.UpdatePostageCost()
end

function MailWindowTabSend.Shutdown()
end

function MailWindowTabSend.UpdatePostageCost()

    local itemCost = 0
	local itemData = nil

	for index, data in pairs(MailWindowTabSend.attachments)
    do
        local inventory = EA_BackpackUtilsMediator.GetItemsFromBackpack( data.backpack )
		itemData = inventory[data.slot]
		if itemData ~= nil and itemData.uniqueID ~= 0 then
			itemCost = itemCost + itemData.sellPrice
		end
	end

    MailWindow.PostageCostTotal = MailWindow.PostageCostBase + math.floor(itemCost * MailWindow.PostageCostItemMultiplier)
    MoneyFrame.FormatMoney ("MailWindowTabSendPostageFrame", MailWindow.PostageCostTotal, MoneyFrame.SHOW_EMPTY_WINDOWS);
end

function MailWindowTabSend.ClearAttachments()
	for attachmentSlotNum=1, MailWindow.ATTACHMENTS_MAX_ROWS*MailWindow.ATTACHMENTS_MAX_COLS do
		MailWindowTabSend.SetItemAttachment(attachmentSlotNum, 0)
	end
	EA_BackpackUtilsMediator.ReleaseAllLocksForWindow("MailWindowTabSend")
end

function MailWindowTabSend.SetItemAttachment(attachmentSlotNum, backpackSlotNum)
	if attachmentSlotNum == nil then
		return
	end
	MailWindow.OnResultsUpdated(0)
    if backpackSlotNum == nil or backpackSlotNum == 0
    then
		ActionButtonGroupSetIcon( "MailWindowTabSendAttachmentSlots", attachmentSlotNum, 0 )
		ActionButtonGroupSetText( "MailWindowTabSendAttachmentSlots", attachmentSlotNum, L"" )
        if( MailWindowTabSend.attachments[attachmentSlotNum] )
        then
            EA_BackpackUtilsMediator.ReleaseLockForSlot(MailWindowTabSend.attachments[attachmentSlotNum].slot, MailWindowTabSend.attachments[attachmentSlotNum].backpack, "MailWindowTabSend")
        end
		MailWindowTabSend.attachments[attachmentSlotNum] = nil
    else
        local currentBackpackType = EA_BackpackUtilsMediator.GetCurrentBackpackType()
        local itemData = EA_BackpackUtilsMediator.GetItemsFromBackpack( currentBackpackType )[backpackSlotNum]

        if	itemData.uniqueID == 0 or (itemData.boundToPlayer == true and not itemData.flags[GameData.Item.EITEMFLAG_ACCOUNT_BOUND])
        then
			if (itemData.boundToPlayer == true and not itemData.flags[GameData.Item.EITEMFLAG_ACCOUNT_BOUND])
			then
				MailWindow.OnResultsUpdated(9)
			end
			ActionButtonGroupSetIcon( "MailWindowTabSendAttachmentSlots", attachmentSlotNum, 0 )
			ActionButtonGroupSetText( "MailWindowTabSendAttachmentSlots", attachmentSlotNum, L"" )
			EA_BackpackUtilsMediator.ReleaseLockForSlot(MailWindowTabSend.attachments[attachmentSlotNum].slot, MailWindowTabSend.attachments[attachmentSlotNum].backpack, "MailWindowTabSend")
			MailWindowTabSend.attachments[attachmentSlotNum] = nil
        else
			if EA_BackpackUtilsMediator.RequestLockForSlot(backpackSlotNum, currentBackpackType, "MailWindowTabSend")
			then
                MailWindowTabSend.attachments[attachmentSlotNum] = { slot = backpackSlotNum, backpack = currentBackpackType }
				Cursor.Clear()
				ActionButtonGroupSetIcon( "MailWindowTabSendAttachmentSlots", attachmentSlotNum, itemData.iconNum )
				if itemData.stackCount > 1
				then
					ActionButtonGroupSetText( "MailWindowTabSendAttachmentSlots", attachmentSlotNum, L""..itemData.stackCount )
				else
					ActionButtonGroupSetText( "MailWindowTabSendAttachmentSlots", attachmentSlotNum, L"" )
				end
			end
        end
    end

    MailWindowTabSend.UpdatePostageCost()
end

function MailWindowTabSend.PopulateFieldsFromOnLButtonUpReplyButton() -- Called from MailWindowTabMessage.OnLButtonUpReplyButton()

    local who = LabelGetText("MailWindowTabMessageFromText")
    local subject = LabelGetText("MailWindowTabMessageSubjectText")
    local body = LabelGetText("MailWindowTabMessageBodyText")

    if who ~= nil
    then
        TextEditBoxSetText( "MailWindowTabSendToEditBox",           who )
    else
        TextEditBoxSetText( "MailWindowTabSendToEditBox",           L"" )
    end
    if subject ~= nil
    then
        TextEditBoxSetText( "MailWindowTabSendSubjectEditBox",      GetMailString(StringTables.Mail.TEXT_MAIL_REPLY_ABBREVIATION)..subject )
    else
        TextEditBoxSetText( "MailWindowTabSendSubjectEditBox",      GetMailString(StringTables.Mail.TEXT_MAIL_REPLY_ABBREVIATION) )
    end
    if body ~= nil
    then
        TextEditBoxSetText( "MailWindowTabSendMessageBodyEditBox",  L"["..body..L"]" )
    else
        TextEditBoxSetText( "MailWindowTabSendMessageBodyEditBox",  L"" )
    end

	WindowAssignFocus("MailWindowTabSendMessageBodyEditBox", true)

    MailWindowTabSend.ClearAttachmentMoney()
	MailWindowTabSend.ClearAttachments()
	MailWindowTabSend.UpdatePostageCost()
    MailWindowTabSend.SetCODFlag(false)
end

function MailWindowTabSend.ClearAttachmentMoney()
    TextEditBoxSetText("MailWindowTabSendEditBoxGold",   L""..0)
    TextEditBoxSetText("MailWindowTabSendEditBoxSilver", L""..0)
    TextEditBoxSetText("MailWindowTabSendEditBoxBrass",  L""..0)
end

function MailWindowTabSend.SetCODFlag(bFlag)
    ButtonSetPressedFlag("MailWindowTabSendCODCheckBoxButton", bFlag)

	if bFlag then
		LabelSetText("MailWindowTabSendAttachmentHeader",  GetMailString( StringTables.Mail.LABEL_MAIL_HEADER_ATTACHMENT_COD ) )
	else
		LabelSetText("MailWindowTabSendAttachmentHeader",  GetMailString( StringTables.Mail.LABEL_MAIL_HEADER_ATTACHMENT ) )
	end
end

function MailWindowTabSend.ClearEntries()
    TextEditBoxSetText("MailWindowTabSendToEditBox",          L"")
    TextEditBoxSetText("MailWindowTabSendSubjectEditBox",     L"")
    TextEditBoxSetText("MailWindowTabSendMessageBodyEditBox", L"")
    MailWindowTabSend.ClearAttachmentMoney()
    MailWindowTabSend.ClearAttachments()
    MailWindowTabSend.UpdatePostageCost()
	MailWindowTabSend.SetCODFlag(false)
end

function MailWindowTabSend.OnPressGoldMinusButton()
    local g = tonumber(TextEditBoxGetText("MailWindowTabSendEditBoxGold"))
    local s = tonumber(TextEditBoxGetText("MailWindowTabSendEditBoxSilver"))
    local b = tonumber(TextEditBoxGetText("MailWindowTabSendEditBoxBrass"))
    
    g = g-1
    if g < 0
    then
        if ButtonGetPressedFlag("MailWindowTabSendCODCheckBoxButton")
        then
            g=99
        else
            g=math.floor(Player.GetMoney() /10000)
        end
    end

    if ButtonGetPressedFlag("MailWindowTabSendCODCheckBoxButton") or CheckSufficientFunds(g, s, b)
    then
        TextEditBoxSetText("MailWindowTabSendEditBoxGold", L""..g)
    end

end

function MailWindowTabSend.OnPressGoldPlusButton()
    local g = tonumber(TextEditBoxGetText("MailWindowTabSendEditBoxGold"))
    local s = tonumber(TextEditBoxGetText("MailWindowTabSendEditBoxSilver"))
    local b = tonumber(TextEditBoxGetText("MailWindowTabSendEditBoxBrass"))

    g=g+1
    if g > math.floor(Player.GetMoney() / 10000)
    then
        if not ButtonGetPressedFlag("MailWindowTabSendCODCheckBoxButton")
        then
            g = 0
        end
    end
    
    if ButtonGetPressedFlag("MailWindowTabSendCODCheckBoxButton") or CheckSufficientFunds(g, s, b)
    then
        TextEditBoxSetText("MailWindowTabSendEditBoxGold", L""..g)
    end

end

function MailWindowTabSend.OnPressSilverMinusButton()
    local g = tonumber(TextEditBoxGetText("MailWindowTabSendEditBoxGold"))
    local s = tonumber(TextEditBoxGetText("MailWindowTabSendEditBoxSilver"))
    local b = tonumber(TextEditBoxGetText("MailWindowTabSendEditBoxBrass"))

    s=s-1
    if s < 0
    then
        s=99 --math.floor(math.mod(Player.GetMoney(), 10000)/100)
    end

    if ButtonGetPressedFlag("MailWindowTabSendCODCheckBoxButton") or CheckSufficientFunds(g, s, b)
    then
        TextEditBoxSetText("MailWindowTabSendEditBoxSilver", L""..s)
    end
end

function MailWindowTabSend.OnPressSilverPlusButton()
    local g = tonumber(TextEditBoxGetText("MailWindowTabSendEditBoxGold"))
    local s = tonumber(TextEditBoxGetText("MailWindowTabSendEditBoxSilver"))
    local b = tonumber(TextEditBoxGetText("MailWindowTabSendEditBoxBrass"))

    s=s+1
    if s > 99
    then --math.floor(math.mod(Player.GetMoney(), 10000)/100) then 
        s=0 
    end
    
    if ButtonGetPressedFlag("MailWindowTabSendCODCheckBoxButton") or CheckSufficientFunds(g, s, b)
    then
        TextEditBoxSetText("MailWindowTabSendEditBoxSilver", L""..s)
    end
end

function MailWindowTabSend.OnPressBrassMinusButton()
    local g = tonumber(TextEditBoxGetText("MailWindowTabSendEditBoxGold"))
    local s = tonumber(TextEditBoxGetText("MailWindowTabSendEditBoxSilver"))
    local b = tonumber(TextEditBoxGetText("MailWindowTabSendEditBoxBrass"))

    b=b-1
    if b < 0 then 
        b= 99 --math.mod(Player.GetMoney(), 10000) 
    end

    if ButtonGetPressedFlag("MailWindowTabSendCODCheckBoxButton") or CheckSufficientFunds(g, s, b)
    then
        TextEditBoxSetText("MailWindowTabSendEditBoxBrass", L""..b)
    end
end

function MailWindowTabSend.OnPressBrassPlusButton()
    local g = tonumber(TextEditBoxGetText("MailWindowTabSendEditBoxGold"))
    local s = tonumber(TextEditBoxGetText("MailWindowTabSendEditBoxSilver"))
    local b = tonumber(TextEditBoxGetText("MailWindowTabSendEditBoxBrass"))

    b=b+1
    if b > 99  --math.mod(Player.GetMoney(), 100)
    then
        b=0 
    end

    if ButtonGetPressedFlag("MailWindowTabSendCODCheckBoxButton") or CheckSufficientFunds(g, s, b)
    then
        TextEditBoxSetText("MailWindowTabSendEditBoxBrass", L""..b)
    end
end

function MailWindowTabSend.OnLButtonUpToField()

    local NotInGuild = GameData.Guild.m_GuildName == L""
    local cantSendToGuildOfficers = true
    local cantSendToEntireGuild = true
    local hasNoFriends = SocialWindowTabFriends.NumberOfFriends == 0

    -- We have to unselect any selected friends or Guild members so that we don't Unselect them
    SocialWindowTabFriends.UpdateSelectedPlayerData()
    GuildWindowTabRoster.UpdateSelectedPlayerData()

    EA_Window_ContextMenu.CreateContextMenu( "MailWindow" )
    --Parameter list: .AddMenuItem(buttonText, callbackFunction, bDisabled, bCloseAfterClick)
    EA_Window_ContextMenu.AddMenuItem( GetMailString( StringTables.Mail.TEXT_MAIL_SEND_GUILD_MEMBER), MailWindowTabSend.OnSelectGuildMember, NotInGuild, true )
    -- Not supported at this time:
    --EA_Window_ContextMenu.AddMenuItem( GetMailString( StringTables.Mail.TEXT_MAIL_SEND_GUILD_OFFICERS), MailWindowTabSend.OnSelectGuildOfficers, cantSendToGuildOfficers, true )
    --EA_Window_ContextMenu.AddMenuItem( GetMailString( StringTables.Mail.TEXT_MAIL_SEND_GUILD_EVERYONE), MailWindowTabSend.OnSelectEntireGuild, cantSendToEntireGuild, true )
    EA_Window_ContextMenu.AddMenuItem( GetMailString( StringTables.Mail.TEXT_MAIL_SEND_FRIEND), MailWindowTabSend.OnSelectFriend, hasNoFriends, true )
    EA_Window_ContextMenu.Finalize()
end

function MailWindowTabSend.OnSelectGuildMember()
    if (WindowGetShowing("GuildWindow") == false) then
        GuildWindow.ToggleShowing()
    end
    
    GuildWindow.ShowTabRosterElements()
end

function MailWindowTabSend.OnSelectEntireGuild()
    TextEditBoxSetText("MailWindowTabSendToEditBox", L"<"..GetMailString( StringTables.Mail.TEXT_MAIL_SEND_GUILD_EVERYONE)..L">")
end

function MailWindowTabSend.OnSelectGuildOfficers()
    TextEditBoxSetText("MailWindowTabSendToEditBox", L"<"..GetMailString( StringTables.Mail.TEXT_MAIL_SEND_GUILD_OFFICERS)..L">")
end

function MailWindowTabSend.OnSelectFriend()
    if (WindowGetShowing("SocialWindow") == false) then
        SocialWindow.ToggleShowing()
    end
    SocialWindow.ShowTabFriendsElements()
end

function MailWindowTabSend.OnMouseOverAttachmentSlot(attachmentSlotNum, flags)
	if( MailWindowTabSend.attachments[attachmentSlotNum] )
    then
        local inventory = EA_BackpackUtilsMediator.GetItemsFromBackpack( MailWindowTabSend.attachments[attachmentSlotNum].backpack )
		local itemData =inventory[MailWindowTabSend.attachments[attachmentSlotNum]]
		if itemData ~= nil and itemData.uniqueID ~= 0 then
			Tooltips.CreateItemTooltip (itemData, "MailWindowTabSendAttachmentSlotsButton"..attachmentSlotNum, Tooltips.ANCHOR_WINDOW_BOTTOM)
		end
	end
end

local function HandleLButtonAttachmentSlot( attachmentSlotNum, showErrors )
	-- There's 3 possibilities here:
	--  1) If there's no item in the slot or the cursor doesn't have an item on it, do nothing.
	--	2) If the cursor contains an item that isn't from the backpack, do nothing.
	--	3) Since we verified there is a valid item on the cursor from the backpack, and the placement slot is empty, place it.

	-- 1) If there's an item in the slot or the cursor doesn't have an item on it, do nothing.
	if (Cursor.IconOnCursor() == false or MailWindowTabSend.attachments[attachmentSlotNum] )
    then
		return
	end

	--	2) If the cursor contains an item that isn't from the backpack, report an error saying so and do nothing else.
    local backpackType = EA_BackpackUtilsMediator.GetCurrentBackpackType()
    local cursor = EA_BackpackUtilsMediator.GetCursorForBackpack( backpackType )
	if ( Cursor.Data.Source ~= cursor )
    then
        if ( showErrors )
        then
            if ( Cursor.Data.Source == Cursor.SOURCE_INVENTORY_OVERFLOW )
            then
		        MailWindowTabSend.ShowSendMessageError( StringTables.Mail.DIALOG_ATTACHMENT_NOT_OVERFLOW )
            else
                MailWindowTabSend.ShowSendMessageError( StringTables.Mail.DIALOG_ATTACHMENT_BACKPACK_ONLY )
            end
        end
		return
	end

	--	3) Since we verified there is a valid item on the cursor from the backpack, and the placement slot is empty, place it.
	MailWindowTabSend.SetItemAttachment(attachmentSlotNum, Cursor.Data.SourceSlot)
end

function MailWindowTabSend.OnLButtonDownAttachmentSlot(attachmentSlotNum, flags)
    HandleLButtonAttachmentSlot(attachmentSlotNum, false)
end

function MailWindowTabSend.OnLButtonUpAttachmentSlot(attachmentSlotNum, flags)
	HandleLButtonAttachmentSlot(attachmentSlotNum, true)
end

function MailWindowTabSend.OnRButtonUpAttachmentSlot(attachmentSlotNum, flags)
	MailWindowTabSend.SetItemAttachment(attachmentSlotNum, 0)
end

function MailWindowTabSend.AttachItem( backpackSlotNum )
    local attachmentSlot = MailWindowTabSend.GetNextOpenSlot()
    -- MailWindowTabSend.GetNextOpenSlot returns 0 if there are no open slots
    if attachmentSlot > 0 and attachmentSlot <= MailWindowTabSend.MAX_ATTACHMENTS
    then
        MailWindowTabSend.SetItemAttachment(attachmentSlot, backpackSlotNum)
    end
end

function MailWindowTabSend.ShowSendMessageError(stringID)
	local dialogText = GetMailString(stringID)
    local confirmOK = GetMailString( StringTables.Mail.BUTTON_CONFIRM_OK)

    DialogManager.MakeOneButtonDialog( dialogText, confirmOK)
end

function MailWindowTabSend.OnLButtonUpSendButton()
    -- TODO: Ensure TO and maybe SUBJECT fields are filled in?
    -- TODO: Clear all the edit boxes at some point.
    
    -- Clear the results text
    WindowSetShowing("MailWindowTabSendResultText", false)

    local money = tonumber(MailWindowTabSendEditBoxGold.Text) * 10000 + 
                  tonumber(MailWindowTabSendEditBoxSilver.Text) * 100 + 
                  tonumber(MailWindowTabSendEditBoxBrass.Text)

	-- Ensure the player can't send a COD with no money being charged
	if money == 0 and ButtonGetPressedFlag("MailWindowTabSendCODCheckBoxButton") then
		MailWindowTabSend.ShowSendMessageError(StringTables.Mail.DIALOG_CONFIRM_NO_COD_CHARGE)
		return
	end

	-- Ensure the player can't send a COD with no item attached
	if ( ButtonGetPressedFlag("MailWindowTabSendCODCheckBoxButton") )
	then
	    if ( next( MailWindowTabSend.attachments ) == nil )
	    then
		    MailWindowTabSend.ShowSendMessageError(StringTables.Mail.DIALOG_CONFIRM_NO_COD_ITEM)
		    return	        
	    end
	end

	MailWindowTabMessage.OnClose()

	-- Create a table of bakpack slot IDs of all items that are attached
	local attachmentSlotIDs = {}
    local attachmentSlotBackpacks = {}
	for index, data in pairs(MailWindowTabSend.attachments) do
		if ( data )
        then
			table.insert(attachmentSlotIDs, data.slot)
            table.insert(attachmentSlotBackpacks, data.backpack)
		end
	end

    SendMailboxCommand(MailWindow.MAILBOX_SEND,								-- Msg type, according to warinterface::LuaSendMailboxCommand
						GameData.MailboxType.PLAYER,						-- Messagebox Type
                        0,													-- Message ID
                        L""..MailWindowTabSendToEditBox.Text,				-- WString for who the message is going to
                        L""..MailWindowTabSendSubjectEditBox.Text,			-- WString for the subject line
                        L""..MailWindowTabSendMessageBodyEditBox.Text,		-- WSring for the body of the message
                        money,												-- Total value of coins attached
                        attachmentSlotIDs,									-- IDs (which correspond to backpack slot #'s) of attachments
                        attachmentSlotBackpacks,                            -- Backpack types of corresponding slot ids
                        ButtonGetPressedFlag("MailWindowTabSendCODCheckBoxButton") -- COD
                        )
end

function MailWindowTabSend.OnLButtonUpCOD()
    -- Toggle the Check Box
    local bIsCOD = ButtonGetPressedFlag("MailWindowTabSendCODCheckBoxButton")

	MailWindowTabSend.SetCODFlag(bIsCOD)
end

function MailWindowTabSend.GetNextOpenSlot()
	for index = 1, MailWindowTabSend.MAX_ATTACHMENTS
    do
		if( not MailWindowTabSend.attachments[index] or not MailWindowTabSend.attachments[index].slot )
        then
			return index
		end
	end
	
	return 0
end
