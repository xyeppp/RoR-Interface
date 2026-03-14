----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------
MailWindowTabMessage = {}

MailWindowTabMessage.messageBodyTable = {}

MailWindowTabMessage.attachmentSlot = 0 -- this is used to keep track of which slot has been right clicked to remove an item

----------------------------------------------------------------
-- Global Functions
----------------------------------------------------------------
function MailWindowTabMessage.Initialize()

	ActionButtonGroupSetNumButtons( "MailWindowTabMessageAttachmentSlots", MailWindow.ATTACHMENTS_MAX_ROWS, MailWindow.ATTACHMENTS_MAX_COLS )
	
	LabelSetText("MailWindowTabMessageTitleBarText", GetMailString( StringTables.Mail.LABEL_MAIL_MESSAGE_WINDOW ) )
	LabelSetText("MailWindowTabMessageFromHeader",		GetMailString(StringTables.Mail.LABEL_MAIL_HEADER_FROM) )

	ButtonSetText("MailWindowTabMessageCommandReplyButton", GetMailString(StringTables.Mail.BUTTON_MAIL_REPLY) )
	ButtonSetText("MailWindowTabMessageCommandTakeItemButton", GetMailString(StringTables.Mail.BUTTON_MAIL_TAKE_ITEM) )
	ButtonSetText("MailWindowTabMessageDeleteMessageButton", GetMailString( StringTables.Mail.BUTTON_MAIL_DELETE) )
    ButtonSetText("MailWindowTabMessageReportSpamMessageButton", GetMailString(StringTables.Mail.BUTTON_MAIL_REPORT_SPAM))
	ButtonSetDisabledFlag("MailWindowTabMessageReportSpamMessageButton",true)	

	WindowRegisterEventHandler( "MailWindowTabMessage", SystemData.Events.MAILBOX_MESSAGE_OPENED, "MailWindowTabMessage.OnMessageOpened")
	WindowRegisterEventHandler( "MailWindowTabMessage", SystemData.Events.INTERACT_MAILBOX_CLOSED,"MailWindowTabMessage.OnClose")

end

function MailWindowTabMessage.Shutdown()
end

function MailWindowTabMessage.OnOpen()
	-- Stub function. MailWindowTabMessage.OnMessageOpened(messageBodyTable) actually does the work of opening the Message Window.
end

function MailWindowTabMessage.OnClose()
    WindowSetShowing( "MailWindowTabMessage", false )		-- Close the window directly so we dont have to wait for the server msg
end

function MailWindowTabMessage.OnMessageOpened(messageBodyTable, mailboxType)
	-- The param is filled in from C, which populates all the non-Header data for the message.
	WindowSetShowing("MailWindowTabMessage", true)
	MailWindowTabMessage.messageBodyTable = {}
		MailWindowTabMessage.messageBodyTable.messageID			= messageBodyTable.messageID
		MailWindowTabMessage.messageBodyTable.messageBody		= messageBodyTable.strMessageBody
		MailWindowTabMessage.messageBodyTable.attachments		= DataUtils.CopyTable (messageBodyTable.itemsAttached)
	MailWindowTabMessage.PopulateFields(mailboxType)
end

function MailWindowTabMessage.UpdateCommandButtons(headerData)
	-- Only show the Take Items Button if there is something to take

	local bShowTakeItemsButton = false

	-- Check for Coins
	if headerData.attachmentMoney > 0 and headerData.isMoneyTaken == false then
		bShowTakeItemsButton = true
	end

	-- Check for items
	if MailWindowUtils.ContainsUntakenAttachmentItems(headerData) then
		bShowTakeItemsButton = true
	end

	WindowSetShowing("MailWindowTabMessageCommandTakeItemButton", bShowTakeItemsButton)
end

function MailWindowTabMessage.UpdateMessageAttachments(headerData)
-- Coin Attachment
	local greyOut = headerData.isMoneyTaken or headerData.isCODPaid

	MoneyFrame.FormatMoney ("MailWindowTabMessageCoinsFrame", headerData.attachmentMoney, MoneyFrame.SHOW_EMPTY_WINDOWS, greyOut)
	MailWindowTabMessage.MoneyAttached = headerData.attachmentMoney

	-- Customize the Header based on if message is COD or not
	if headerData.isCOD
	then
		LabelSetText("MailWindowTabMessageAttachmentHeader",  GetMailString( StringTables.Mail.LABEL_MAIL_HEADER_ATTACHMENT_COD ) )
	else
		LabelSetText("MailWindowTabMessageAttachmentHeader",  GetMailString( StringTables.Mail.LABEL_MAIL_HEADER_ATTACHMENT ) )
	end

	local header = MailWindowTabInbox.listData[MailWindowTabInbox.SelectedMessageDataIndex]
	if MailWindow.SelectedTab == MailWindow.TABS_AUCTION then
		header = MailWindowTabAuction.listData[MailWindowTabAuction.SelectedMessageDataIndex]
	end

	-- Item Attachments
	for slot = 1, #MailWindowTabMessage.messageBodyTable.attachments do
		ActionButtonGroupSetIcon( "MailWindowTabMessageAttachmentSlots", slot, MailWindowTabMessage.messageBodyTable.attachments[slot].iconNum )
		if MailWindowTabMessage.messageBodyTable.attachments[slot].stackCount > 1 then
			ActionButtonGroupSetText( "MailWindowTabMessageAttachmentSlots", slot, L""..MailWindowTabMessage.messageBodyTable.attachments[slot].stackCount )
		else
			ActionButtonGroupSetText( "MailWindowTabMessageAttachmentSlots", slot, L"" )
		end

		-- Grey out the items that have been taken
		if MailWindowUtils.IsAttachmentTaken(header, slot) then
			ActionButtonGroupSetTintColor("MailWindowTabMessageAttachmentSlots", slot, DefaultColor.MEDIUM_GRAY.r, DefaultColor.MEDIUM_GRAY.g, DefaultColor.MEDIUM_GRAY.b)
		else
			ActionButtonGroupSetTintColor("MailWindowTabMessageAttachmentSlots", slot, DefaultColor.ZERO_TINT.r, DefaultColor.ZERO_TINT.g, DefaultColor.ZERO_TINT.b)
		end
	end

	for slot = #MailWindowTabMessage.messageBodyTable.attachments +1, MailWindow.ATTACHMENTS_MAX_ROWS * MailWindow.ATTACHMENTS_MAX_COLS do
		ActionButtonGroupSetIcon( "MailWindowTabMessageAttachmentSlots", slot, 0 )
		ActionButtonGroupSetText( "MailWindowTabMessageAttachmentSlots", slot, L"" )
		ActionButtonGroupSetTintColor("MailWindowTabMessageAttachmentSlots", slot, DefaultColor.ZERO_TINT.r, DefaultColor.ZERO_TINT.g, DefaultColor.ZERO_TINT.b)
	end
end

function MailWindowTabMessage.PopulateFields(mailboxType)
	local mailboxTable = {}
	if mailboxType ~= nil and mailboxType == GameData.MailboxType.AUCTION then
		mailboxTable = MailWindowTabAuction.listData
	else
		mailboxTable = MailWindowTabInbox.listData
	end

	-- Get everything we need from the Header, (the Message Body Text and Attached Item Details was received via .OnMessageOpened)
	for index, data in ipairs(mailboxTable) do
		if data.messageID == MailWindowTabMessage.messageBodyTable.messageID then
				MailWindowTabMessage.UpdateMessageAttachments(data)
				MailWindowTabMessage.UpdateCommandButtons(data)
				LabelSetText("MailWindowTabMessageFromText", data.from)
				LabelSetText("MailWindowTabMessageSubjectText", data.subject)
	ButtonSetDisabledFlag("MailWindowTabMessageReportSpamMessageButton", not data.isReturnable)	
			break
		end
	end

	LabelSetText("MailWindowTabMessageBodyScrollChildText", MailWindowTabMessage.messageBodyTable.messageBody)
	ScrollWindowSetOffset( "MailWindowTabMessageBody", 0 )
	ScrollWindowUpdateScrollRect( "MailWindowTabMessageBody" )
end

function MailWindowTabMessage.OnLButtonUpReplyButton()
	if MailWindow.SelectedTab ~= MailWindow.TABS_INBOX then
		return
	end

	MailWindow.ShowTabSendElements()
	MailWindowTabSend.PopulateFieldsFromOnLButtonUpReplyButton() -- Let the Send Tab handle populating its own fields.
end

function MailWindowTabMessage.OnLButtonUpTakeCoins()
	if MailWindow.SelectedTab == MailWindow.TABS_INBOX then
		SendMailboxCommand(MailWindow.MAILBOX_TAKE_MONEY, GameData.MailboxType.PLAYER, MailWindowTabInbox.SelectedMessageID, L"", L"", L"", 0, {}, {}, false )
	elseif MailWindow.SelectedTab == MailWindow.TABS_AUCTION then
		SendMailboxCommand(MailWindow.MAILBOX_TAKE_MONEY, GameData.MailboxType.AUCTION, MailWindowTabAuction.SelectedMessageID, L"", L"", L"", 0, {}, {}, false )
	end
end

function MailWindowTabMessage.OnLButtonUpTakeItem()
	if MailWindow.SelectedTab == MailWindow.TABS_INBOX then
		SendMailboxCommand(MailWindow.MAILBOX_TAKE_ITEM, GameData.MailboxType.PLAYER, MailWindowTabInbox.SelectedMessageID, L"", L"", L"", 0, {}, {}, false )
	elseif 	MailWindow.SelectedTab == MailWindow.TABS_AUCTION then
		SendMailboxCommand(MailWindow.MAILBOX_TAKE_ITEM, GameData.MailboxType.AUCTION, MailWindowTabAuction.SelectedMessageID, L"", L"", L"", 0, {}, {}, false )
	end
end

function MailWindowTabMessage.OnLButtonUpTakeAll()

	-- Loop through out list of headers
	for index, data in ipairs(MailWindowTabInbox.listData)
	do
        -- Find the message we've opened
		if data.messageID == MailWindowTabMessage.messageBodyTable.messageID
		then
            -- Create Confirmation Dialog to verify payment of COD charge
			if (data.isCOD) and (not data.isCODPaid)
			then
			    local g, s, b = MoneyFrame.ConvertBrassToCurrency (MailWindowTabMessage.MoneyAttached)
				local dialogText = GetFormatStringFromTable( "mailstrings", StringTables.Mail.DIALOG_CONFIRM_COD_CHARGE, { g, s, b } )
			    
				local confirmYes = GetMailString( StringTables.Mail.BUTTON_CONFIRM_YES)
				local confirmNo = GetMailString( StringTables.Mail.BUTTON_CONFIRM_NO)
				DialogManager.MakeTwoButtonDialog( dialogText, confirmYes, MailWindowTabMessage.ConfirmTakeAll, confirmNo, nil)
				
				-- Bail out, let the dialog box decide whether we'll actually collect or not.
                return
			end
			break
		end
	end
	
	-- If it isn't a COD message, there's no need for a confirm dialog. Just take all attachments.
	MailWindowTabMessage.ConfirmTakeAll()
end

function MailWindowTabMessage.ConfirmTakeAll()
	if MailWindow.SelectedTab == MailWindow.TABS_INBOX then
		SendMailboxCommand(MailWindow.MAILBOX_TAKE_ALL, GameData.MailboxType.PLAYER, MailWindowTabInbox.SelectedMessageID, L"", L"", L"", 0, {}, {}, false )
	elseif 	MailWindow.SelectedTab == MailWindow.TABS_AUCTION then
	    -- if the message is from an auction we need to close it
	    MailWindowTabMessage.OnClose()
		SendMailboxCommand(MailWindow.MAILBOX_TAKE_ALL, GameData.MailboxType.AUCTION, MailWindowTabAuction.SelectedMessageID, L"", L"", L"", 0, {}, {}, false  )
	end
end

function MailWindowTabMessage.OnLButtonDeleteMessage()
	-- Figure out what Message Header we've clicked on
	local header = MailWindowTabInbox.listData[MailWindowTabInbox.SelectedMessageDataIndex]
	if MailWindow.SelectedTab == MailWindow.TABS_AUCTION then
		header = MailWindowTabAuction.listData[MailWindowTabAuction.SelectedMessageDataIndex]
	end

	if MailWindowUtils.ShowDeleteConfirmationDialog(header) then -- then create a confirmation dialog
		local dialogText = GetMailString(StringTables.Mail.DIALOG_CONFIRM_DELETE_ATTACHED_MESSAGE )
		
		if header.hasBeenRead == false then	-- Customize the message based on being unread, or with attachment
			dialogText = GetMailString(StringTables.Mail.DIALOG_CONFIRM_DELETE_UNREAD_MESSAGE )
		end

		DialogManager.MakeTwoButtonDialog( dialogText, GetMailString(StringTables.Mail.BUTTON_CONFIRM_YES), MailWindowTabMessage.ConfirmDeleteMessage, GetMailString(StringTables.Mail.BUTTON_CONFIRM_NO), nil)
	else
		MailWindowTabMessage.ConfirmDeleteMessage()
	end
end

function MailWindowTabMessage.ConfirmDeleteMessage()
	local mailboxType = GameData.MailboxType.PLAYER
	local messageID = MailWindowTabInbox.SelectedMessageID
	if MailWindow.SelectedTab == MailWindow.TABS_AUCTION then
		mailboxType = GameData.MailboxType.AUCTION
		messageID = MailWindowTabAuction.SelectedMessageID
	end

	SendMailboxCommand(MailWindow.MAILBOX_DELETE_MESSAGE,					-- Msg type, according to warinterface::LuaSendMailboxCommand
						mailboxType,										-- Mailbox Type
						messageID,											-- Message ID
						L"",												-- WString for who the message is going to
						L"",												-- WString for the subject line
						L"",												-- WSring for the body of the message
						0,													-- Total value of coins attached
						{},													-- Table of IDs which are backpack Slot IDs ({} for no attachments)
						{},													-- Table for backpack ids
						false												-- Message is COD
						)
	MailWindowTabMessage.OnClose()

	if MailWindow.SelectedTab == MailWindow.TABS_INBOX then
		MailWindow.ShowTabInboxElements()
	elseif MailWindow.SelectedTab == MailWindow.TABS_AUCTION then 
		MailWindow.ShowTabAuctionElements()
	end
end

function MailWindowTabMessage.OnMouseOverAttachmentSlot(attachmentSlotNum, flags)
	if attachmentSlotNum > #MailWindowTabMessage.messageBodyTable.attachments then
		return
	end

	if MailWindowTabMessage.messageBodyTable.attachments[attachmentSlotNum] ~= 0 then
		local itemData = --DataUtils.GetItems()[MailWindowTabMessage.messageBodyTable.attachments[attachmentSlotNum]]
						MailWindowTabMessage.messageBodyTable.attachments[attachmentSlotNum]
		if itemData ~= nil and itemData.uniqueID ~= 0 then
			Tooltips.CreateItemTooltip (itemData, "MailWindowTabMessageAttachmentSlotsButton"..attachmentSlotNum, Tooltips.ANCHOR_WINDOW_BOTTOM)
		end
	end
end


function MailWindowTabMessage.OnMouseOverEndAttachmentSlot(attachmentSlotNum, flags)
end

function MailWindowTabMessage.OnRButtonUpAttachmentSlot(attachmentSlotNum, flags)
    MailWindowTabMessage.attachmentSlot = attachmentSlotNum
	-- Loop through out list of headers
	for index, data in ipairs(MailWindowTabInbox.listData)
	do
        -- Find the message we've opened
		if data.messageID == MailWindowTabMessage.messageBodyTable.messageID
		then
            -- Create Confirmation Dialog to verify payment of COD charge
			if (data.isCOD) and (not data.isCODPaid)
			then
			    local g, s, b = MoneyFrame.ConvertBrassToCurrency (MailWindowTabMessage.MoneyAttached)
				local dialogText = GetFormatStringFromTable( "mailstrings", StringTables.Mail.DIALOG_CONFIRM_COD_CHARGE, { g, s, b } )
			    
				local confirmYes = GetMailString( StringTables.Mail.BUTTON_CONFIRM_YES)
				local confirmNo = GetMailString( StringTables.Mail.BUTTON_CONFIRM_NO)
				DialogManager.MakeTwoButtonDialog( dialogText, confirmYes, MailWindowTabMessage.TakeAttachmentConfirmed, confirmNo, nil)
				
				-- Bail out, let the dialog box decide whether we'll actually collect or not.
                return
			end
			break
		end
	end

    MailWindowTabMessage.TakeAttachmentConfirmed()
end

-- we use this in order to be able to show the COD message if there is a COD on the mail
function MailWindowTabMessage.TakeAttachmentConfirmed()
--Here's the params: NOTE: We're hijacking the MONEy param to indicate which attachment slot # to take.
--        LUA_NUMBER,             // Command Type. These are pulled from MailWindow.MAILBOX_*
--        LUA_NUMBER,             // Mailbox Type
--        LUA_NUMBER,             // Message ID
--        LUA_WSTRING_DIRECT,     // Character name the message is intended for
--        LUA_WSTRING_DIRECT,     // Subject
--        LUA_WSTRING_DIRECT,     // Message Body
--        LUA_NUMBER,             // Money Attached
--        LUA_NUMBER_TABLE,       // Table of attachment IDs (which correlate to Backpack slot #'s) 
--        LUA_BOOLEAN             // true if this message is COD, false otherwise
	-- Note: Be sure to subtract 1 from the MailWindowTabMessage.attachmentSlot since LUA is 1-based
	if MailWindow.SelectedTab == MailWindow.TABS_INBOX then
		SendMailboxCommand(MailWindow.MAILBOX_TAKE_ITEM, GameData.MailboxType.PLAYER, MailWindowTabInbox.SelectedMessageID, L"", L"", L"", MailWindowTabMessage.attachmentSlot-1, {}, {}, false )
	elseif 	MailWindow.SelectedTab == MailWindow.TABS_AUCTION then
	    -- if the message is from an auction we need to close it
	    MailWindowTabMessage.OnClose()
		SendMailboxCommand(MailWindow.MAILBOX_TAKE_ITEM, GameData.MailboxType.AUCTION, MailWindowTabAuction.SelectedMessageID, L"", L"", L"", MailWindowTabMessage.attachmentSlot-1, {}, {}, false )
	end
end

-- When "Report Spam" button is clicked, the mail sender's name and associated
-- message is reported via HelpUtils.AutoReportGoldSeller() function.
-- The message is also deleted from the player's inbox and the offender is put
-- on temporary ignore.
function MailWindowTabMessage.OnLButtonReportSpamMessage()
if ButtonGetDisabledFlag("MailWindowTabMessageReportSpamMessageButton") == true then return end
    local senderName = nil
    local subject = L""
    
    -- Find opened message and save the sender's name
    for index, data in ipairs(MailWindowTabInbox.listData)
    do
        if (data.messageID == MailWindowTabMessage.messageBodyTable.messageID)
        then
            senderName = WStringsRemoveGrammar(data.from)
            subject = data.subject
            break
        end
    end
    
    if (senderName == nil)
    then
        return
    end
    
	local mailboxType = GameData.MailboxType.PLAYER
	local messageID = MailWindowTabInbox.SelectedMessageID

    -- Delete the message
	SendMailboxCommand(MailWindow.MAILBOX_DELETE_MESSAGE,					-- Msg type, according to warinterface::LuaSendMailboxCommand
						mailboxType,										-- Mailbox Type
						messageID,											-- Message ID
						L"",												-- WString for who the message is going to
						L"",												-- WString for the subject line
						L"",												-- WSring for the body of the message
						0,													-- Total value of coins attached
						{},													-- Table of IDs which are backpack Slot IDs ({} for no attachments)
						{},													-- Table for backpack ids
						false												-- Message is COD
						)
                        
	MailWindowTabMessage.OnClose()
    HelpUtils.AutoReportGoldSeller(senderName, L"[Mail Message ID]: "..messageID..L" [Mail Subject]: "..subject..L" [Mail Message Body]: "..MailWindowTabMessage.messageBodyTable.messageBody)
    AddTemporaryIgnore(senderName)
end
