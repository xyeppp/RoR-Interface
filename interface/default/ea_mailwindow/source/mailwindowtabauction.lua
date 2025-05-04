
MailWindowTabAuction = {}
MailWindowTabAuction.SelectedMessageID = 0		-- This is the message ID of the currently selected header

MailWindowTabAuction.listData = {}
MailWindowTabAuction.listDataOrder = {}
MailWindowTabAuction.SelectedMessageDataIndex = 0

----------------------------------------------------------------
-- Local Functions
----------------------------------------------------------------
local function FormatTimeSent(timeInSeconds)
	if timeInSeconds <   600 then -- 60*10 = 600
		return GetStringFormatFromTable( "MailStrings", StringTables.Mail.TEXT_MAIL_SENT_LESSTHAN_X_MINS_AGO, {L"<", L""..10} ) 
	end	

	if timeInSeconds <  3600 then -- 60*60 = 3600
		return GetStringFormatFromTable( "MailStrings", StringTables.Mail.TEXT_MAIL_SENT_LESSTHAN_X_HOUR_AGO,  {L"<",  L""..1} )
	end	

	if timeInSeconds < 86400 then -- 60*60*24 = 86400
		return GetStringFormatFromTable( "MailStrings", StringTables.Mail.TEXT_MAIL_SENT_LESSTHAN_X_DAY_AGO,	{L"<",  L""..1} )
	end

	timeInSeconds = math.floor((timeInSeconds-1) / 86400)
	return GetStringFormatFromTable( "MailStrings", StringTables.Mail.TEXT_MAIL_SENT_LESSTHAN_X_DAYS_AGO, {L""..timeInSeconds})
end

local function FormatTimeExpires(timeInSeconds)
	if timeInSeconds < (600 ) then	-- 60*10 = 600
		return GetStringFormatFromTable( "MailStrings", StringTables.Mail.TEXT_MAIL_EXPIRES_LESSTHAN_X_MINS, {L"<", L""..10})
	end	

	if timeInSeconds < (3600) then	-- 60*60 = 3600
		return GetStringFormatFromTable( "MailStrings", StringTables.Mail.TEXT_MAIL_EXPIRES_LESSTHAN_X_HOUR, {L"<",  L""..1})
	end	

	if timeInSeconds < (86400) then	-- 60*60*24 = 86400
		return GetStringFormatFromTable( "MailStrings", StringTables.Mail.TEXT_MAIL_EXPIRES_LESSTHAN_X_DAY, {L"<",  L""..1})
	end	
	
	timeInSeconds = math.floor((timeInSeconds-1) / 86400)
	return GetStringFormatFromTable( "MailStrings", StringTables.Mail.TEXT_MAIL_EXPIRES_LESSTHAN_X_DAYS, {L""..timeInSeconds} )
end

----------------------------------------------------------------
-- Global Functions
----------------------------------------------------------------
function MailWindowTabAuction.Initialize()
	ButtonSetText("MailWindowTabAuctionOpenMessageButton",   GetMailString( StringTables.Mail.BUTTON_MAIL_OPEN) )
	ButtonSetText("MailWindowTabAuctionDeleteMessageButton", GetMailString( StringTables.Mail.BUTTON_MAIL_DELETE) )
	ButtonSetText("MailWindowTabAuctionReturnMessageButton", GetMailString( StringTables.Mail.BUTTON_MAIL_RETURN) )
	ButtonSetDisabledFlag("MailWindowTabAuctionReturnMessageButton",true)	

	--LabelSetText("MailWindowTabAuctionSelectAllCheckBoxButtonHeader", GetMailString( StringTables.Mail.LABEL_MAIL_HEADER_Auction_SELECT_ALL) )
	WindowRegisterEventHandler( "MailWindowTabAuction", SystemData.Events.MAILBOX_HEADER_UPDATED, "MailWindowTabAuction.OnHeaderUpdated")
	WindowRegisterEventHandler( "MailWindowTabAuction", SystemData.Events.MAILBOX_HEADERS_UPDATED,"MailWindowTabAuction.OnHeadersUpdated")
	WindowRegisterEventHandler( "MailWindowTabAuction", SystemData.Events.MAILBOX_MESSAGE_DELETED,"MailWindowTabAuction.OnMessageDeleted")

	MailWindowTabAuction.ClearHeaders()
end

function MailWindowTabAuction.Shutdown()
end

function MailWindowTabAuction.UpdateListButtonStates()
	if (MailWindowTabAuctionList.PopulatorIndices ~= nil) then
        for row, index in ipairs(MailWindowTabAuctionList.PopulatorIndices) do
            local rowWindow = "MailWindowTabAuctionListRow"..row
            -- Highlight the selected row, unhighlight the rest
            ButtonSetPressedFlag(  rowWindow, (MailWindowTabAuction.listData[index].messageID == MailWindowTabAuction.SelectedMessageID) )
            ButtonSetStayDownFlag( rowWindow, (MailWindowTabAuction.listData[index].messageID == MailWindowTabAuction.SelectedMessageID) )
            
            -- Disable windows that cannot be purchased.
            --ButtonSetDisabledFlag(rowWindow, EA_Window_InteractionTraining.HasAbilityFilter( EA_Window_InteractionTraining.advanceData[data] ) )
        end
    end
	
	if MailWindowTabAuction.SelectedMessageDataIndex > 0 then	
		ButtonSetDisabledFlag("MailWindowTabAuctionReturnMessageButton", not MailWindowTabAuction.listData[MailWindowTabAuction.SelectedMessageDataIndex].isReturnable)	
	end
end

-- Whenever the # of headers changes, we have to updated the header text and account for if no headers exist.
function MailWindowTabAuction.NumberOfHeadersChanged()
	local bNoMessages = #MailWindowTabAuction.listData == 0 or MailWindowTabAuctionList.PopulatorIndices == nil

	if bNoMessages then
		LabelSetText("MailWindowTabAuctionMessageNumberText", GetMailString( StringTables.Mail.TEXT_MAIL_NO_MESSAGES ) )
	elseif #MailWindowTabAuction.listData < MailWindowTabAuctionList.numVisibleRows then
		local low  = L""..MailWindowTabAuctionList.PopulatorIndices[1]
		local high = L""..(low - 1 + #MailWindowTabAuction.listData)
		LabelSetText("MailWindowTabAuctionMessageNumberText", GetStringFormatFromTable("MailStrings", StringTables.Mail.TEXT_MAIL_DISPLAYING, {low, high, L""..#MailWindowTabAuction.listData} )) 
	else
		local low  = L""..MailWindowTabAuctionList.PopulatorIndices[1]
		local high = L""..(low - 1 + MailWindowTabAuctionList.numVisibleRows)
		LabelSetText("MailWindowTabAuctionMessageNumberText", GetStringFormatFromTable("MailStrings", StringTables.Mail.TEXT_MAIL_DISPLAYING, {low, high, L""..#MailWindowTabAuction.listData} )) 
	end

	WindowSetShowing("MailWindowTabAuctionList", bNoMessages == false)
	WindowSetShowing("MailWindowTabAuctionOpenMessageButton", bNoMessages == false)
	WindowSetShowing("MailWindowTabAuctionDeleteMessageButton", bNoMessages == false)
	WindowSetShowing("MailWindowTabAuctionReturnMessageButton", bNoMessages == false)
end

function MailWindowTabAuction.OnHeaderUpdated(headerData, mailboxType)
	if mailboxType ~= GameData.MailboxType.AUCTION then
		return
	end

	for index, data in ipairs(MailWindowTabAuction.listData) do
		if data.messageID == headerData[1].messageID then
			data.messageFlags		= headerData[1].messageFlags
			data.hasBeenRead		= headerData[1].hasBeenRead
			data.isReturnable		= headerData[1].isReturnable
			data.hasBeenReturned	= headerData[1].hasBeenReturned
			data.isCODPayment		= headerData[1].isCODPayment
			data.from				= headerData[1].strSenderName
			data.subject			= headerData[1].strSubject
			data.sent				= FormatTimeSent(headerData[1].messageSendDelta*-1)
			data.sentTimeStamp		= headerData[1].messageSendDelta*-1
			data.expiresTimeStamp	= headerData[1].messageExpireDelta
			data.expires			= FormatTimeExpires(headerData[1].messageExpireDelta)
			data.attachmentMoney	= headerData[1].attachmentMoney
			data.attachmentIconIDs  = DataUtils.CopyTable(headerData[1].attachmentIconIDs)
			data.isCOD				= headerData[1].isCOD
			data.isMoneyTaken		= headerData[1].isMoneyTaken
			data.attachmentsTakenTable = DataUtils.CopyTable(headerData[1].attachmentsTakenTable)
			data.isCODPaid			= headerData[1].isCODPaid
			data.isReturned			= headerData[1].isReturned

			if headerData[1].attachmentMoney == 0 and (headerData[1].attachmentIconIDs == nil or #headerData[1].attachmentIconIDs == 0) then
				data.type		= L"Letter"
			else
				data.type		= L"Attachment"
			end
			break
		end
	end

	MailWindowTabAuction.ApplyFilters()
	MailWindowTabAuction.Populate()
	MailWindowTabAuction.NumberOfHeadersChanged()
end

function MailWindowTabAuction.ClearHeaders()
	MailWindowTabAuction.listData = {}
	MailWindowTabAuction.ApplyFilters()
	MailWindowTabAuction.Populate()
	MailWindowTabAuction.NumberOfHeadersChanged()
end

function MailWindowTabAuction.OnHeadersUpdated(headerList, mailboxType) -- This function expects 2 params from a C LUA script event that passes in all the Headers, and the mailbox type.
	if mailboxType ~= GameData.MailboxType.AUCTION then
		return
	end

	MailWindowTabAuction.listData = {}
	for index, data in ipairs(headerList)
	do
		MailWindowTabAuction.listData[index] = {}
		MailWindowTabAuction.listData[index].messageID			= data.messageID
		MailWindowTabAuction.listData[index].messageFlags		= data.messageFlags
		MailWindowTabAuction.listData[index].hasBeenRead		= data.hasBeenRead
		MailWindowTabAuction.listData[index].isReturnable		= data.isReturnable
		MailWindowTabAuction.listData[index].hasBeenReturned	= data.hasBeenReturned
		MailWindowTabAuction.listData[index].isCODPayment		= data.isCODPayment
		MailWindowTabAuction.listData[index].from				= data.strSenderName
		MailWindowTabAuction.listData[index].subject			= data.strSubject
		MailWindowTabAuction.listData[index].sent				= FormatTimeSent(data.messageSendDelta*-1)
		MailWindowTabAuction.listData[index].sentTimeStamp		= data.messageSendDelta*-1
		MailWindowTabAuction.listData[index].expiresTimeStamp	= data.messageExpireDelta
		MailWindowTabAuction.listData[index].expires			= FormatTimeExpires(data.messageExpireDelta)
		MailWindowTabAuction.listData[index].attachmentMoney	= data.attachmentMoney
		MailWindowTabAuction.listData[index].attachmentIconIDs	= DataUtils.CopyTable(data.attachmentIconIDs)
		MailWindowTabAuction.listData[index].isCOD				= data.isCOD
		MailWindowTabAuction.listData[index].isMoneyTaken		= data.isMoneyTaken
		MailWindowTabAuction.listData[index].isCODPaid			= data.isCODPaid
		MailWindowTabAuction.listData[index].isReturned			= data.isReturned
		MailWindowTabAuction.listData[index].attachmentsTakenTable	= DataUtils.CopyTable(data.attachmentsTakenTable)

		if data.attachmentMoney == 0 and (data.attachmentIconIDs == nil or #data.attachmentIconIDs == 0) then
			MailWindowTabAuction.listData[index].type		= L"Letter"
		else
			MailWindowTabAuction.listData[index].type		= L"Attachment"
		end
	end

	MailWindowTabAuction.ApplyFilters()
	MailWindowTabAuction.Populate()
	MailWindowTabAuction.NumberOfHeadersChanged()
end

function MailWindowTabAuction.OnMessageDeleted(messageID, mailboxType)
	if mailboxType ~= GameData.MailboxType.AUCTION then
		return
	end

	for index, data in ipairs(MailWindowTabAuction.listData) do
		if data.messageID == messageID then
			table.remove(MailWindowTabAuction.listData, index)
			break
		end
	end

	MailWindowTabAuction.ApplyFilters()
	MailWindowTabAuction.Populate()
	MailWindowTabAuction.NumberOfHeadersChanged()

end

function MailWindowTabAuction.PopulateIcon(rowFrame, headerData)
    local iconFrame = rowFrame.."Icon"
	local sliceName = MailWindowUtils.GetHeaderIconSliceName(headerData)
	DynamicImageSetTextureSlice(iconFrame, sliceName)
end

function MailWindowTabAuction.PopulateCoinsAttachment(rowFrame, headerData)

	if headerData.isMoneyTaken then
		WindowSetShowing(rowFrame.."CoinsImage", true)
		WindowSetTintColor(rowFrame.."CoinsImage", 128, 128, 128)
	elseif headerData.attachmentMoney ~= nil and headerData.attachmentMoney > 0 then
		WindowSetShowing(rowFrame.."CoinsImage", true)
		WindowSetTintColor(rowFrame.."CoinsImage", 255, 255, 255)
	else
		WindowSetShowing(rowFrame.."CoinsImage", false)
	end
end

function MailWindowTabAuction.PopulateItemAttachment(rowFrame, headerData)
	MailWindowUtils.PopulateItemAttachments(rowFrame, headerData)
end

function MailWindowTabAuction.Populate()
    if (MailWindowTabAuctionList.PopulatorIndices == nil) then
		return
    end

	for row, data in ipairs(MailWindowTabAuctionList.PopulatorIndices) do
		local headerData = MailWindowTabAuction.listData[data]
		local rowFrame   = "MailWindowTabAuctionListRow"..row

		MailWindowTabAuction.PopulateIcon(rowFrame, headerData)
		MailWindowTabAuction.PopulateItemAttachment(rowFrame, headerData)
		MailWindowTabAuction.PopulateCoinsAttachment(rowFrame, headerData)

		-- If the message is already open, update it.
		if MailWindowTabMessage.messageBodyTable.messageID ~= nil and 
		   MailWindowTabMessage.messageBodyTable.messageID == headerData.messageID
		then
			MailWindowTabMessage.UpdateMessageAttachments(headerData)
		end
	end

	MailWindowTabAuction.UpdateListButtonStates()
	MailWindowTabAuction.NumberOfHeadersChanged()
end

function MailWindowTabAuction.ApplyFilters()

	MailWindowTabAuction.listDataOrder = {}

    if (MailWindowTabAuction.listData == nil) then				-- This can occur during the initial load, in which case ignore it
        return
    end

    table.sort(MailWindowTabAuction.listData, MailWindowTabAuction.DefaultSort)

	local filterPass = false
    for index, data in pairs(MailWindowTabAuction.listData) do
    
        -- Apply all filters in our filter list - those set to nil won't be applied and so the entry will automatically pass those.        
		if data.messageID == 0 then
			filterPass = false
		else
			filterPass = true
		end
        --for row, filterFunction in pairs(EA_Window_InteractionTraining.filterList) do
        --    if filterPass then
        --        filterPass = filterPass --and filterFunction(EA_Window_InteractionTraining.advanceData[index])
        --    end
        --end
        
        local showEntry = filterPass
        
        if (showEntry) then
            table.insert(MailWindowTabAuction.listDataOrder, index)
        end
    end
	
    ListBoxSetDisplayOrder("MailWindowTabAuctionList", MailWindowTabAuction.listDataOrder)
end

function MailWindowTabAuction.CreateMailHeaderContextMenu( windowNameToActUpon )
    if( windowNameToActUpon == nil or windowNameToActUpon == "" ) then	
        return
    end
    
    EA_Window_ContextMenu.CreateContextMenu( windowNameToActUpon ) 
    local bMarkedRead = true
	
    EA_Window_ContextMenu.AddMenuItem( GetMailString( StringTables.Mail.LABEL_MAIL_HEADER_MARK_READ ), MailWindowTabAuction.OnMarkRead, not bMarkedRead, true )
    EA_Window_ContextMenu.AddMenuItem( GetMailString( StringTables.Mail.LABEL_MAIL_HEADER_MARK_UNREAD ), MailWindowTabAuction.OnMarkUnread, not bMarkedRead, true )
    EA_Window_ContextMenu.Finalize()
end

function MailWindowTabAuction.OnMarkRead()
	SendMailboxCommand(MailWindow.MAILBOX_MESSAGE_MARK_READ,				-- Msg type, according to warinterface::LuaSendMailboxCommand
						GameData.MailboxType.AUCTION,						-- Mailbox Type
						MailWindowTabAuction.SelectedMessageID,				-- Message ID
						L"",												-- WString for who the message is going to
						L"",												-- WString for the subject line
						L"",												-- WSring for the body of the message
						0,													-- Total value of coins attached
						{},													-- Table of IDs which are backpack Slot IDs ({} for no attachments)
						{},													-- Table for backpack ids
						false												-- Message is COD
						)
end

function MailWindowTabAuction.OnMarkUnread()
	SendMailboxCommand(MailWindow.MAILBOX_MESSAGE_MARK_UNREAD,				-- Msg type, according to warinterface::LuaSendMailboxCommand
						GameData.MailboxType.AUCTION,						-- Mailbox Type
						MailWindowTabAuction.SelectedMessageID,				-- Message ID
						L"",												-- WString for who the message is going to
						L"",												-- WString for the subject line
						L"",												-- WSring for the body of the message
						0,													-- Total value of coins attached
						{},													-- Table of IDs which are backpack Slot IDs ({} for no attachments)
						{},													-- Table for backpack ids
						false												-- Message is COD
						)
end

function MailWindowTabAuction.OnLButtonOpenMessage()
	SendMailboxCommand(MailWindow.MAILBOX_OPEN_MESSAGE,						-- Msg type, according to warinterface::LuaSendMailboxCommand
						GameData.MailboxType.AUCTION,						-- Mailbox Type
						MailWindowTabAuction.SelectedMessageID,				-- Message ID
						L"",												-- WString for who the message is going to
						L"",												-- WString for the subject line
						L"",												-- WSring for the body of the message
						0,													-- Total value of coins attached
						{},													-- Table of IDs which are backpack Slot IDs ({} for no attachments)
						{},													-- Table for backpack ids
						false												-- Message is COD
						)
end

function MailWindowTabAuction.OnLButtonDeleteMessage()
	-- Figure out what Message Header we've clicked on
	local header = MailWindowTabAuction.listData[MailWindowTabAuction.SelectedMessageDataIndex]
	
	if MailWindowUtils.ShowDeleteConfirmationDialog(header) then	-- then create a confirmation dialog
		local dialogText = GetMailString(StringTables.Mail.DIALOG_CONFIRM_DELETE_ATTACHED_MESSAGE )
		
		if header.hasBeenRead == false then	-- Customize the message based on being unread, or with attachment
			dialogText = GetMailString(StringTables.Mail.DIALOG_CONFIRM_DELETE_UNREAD_MESSAGE )
		end

		DialogManager.MakeTwoButtonDialog( dialogText, GetMailString(StringTables.Mail.BUTTON_CONFIRM_YES), MailWindowTabAuction.ConfirmDeleteMessage, GetMailString(StringTables.Mail.BUTTON_CONFIRM_NO), nil)
	else
		MailWindowTabAuction.ConfirmDeleteMessage()
	end

end
	
function MailWindowTabAuction.ConfirmDeleteMessage()
	MailWindowTabMessage.OnClose()
	SendMailboxCommand(MailWindow.MAILBOX_DELETE_MESSAGE,					-- Msg type, according to warinterface::LuaSendMailboxCommand
						GameData.MailboxType.AUCTION,						-- Mailbox Type
						MailWindowTabAuction.SelectedMessageID,				-- Message ID
						L"",												-- WString for who the message is going to
						L"",												-- WString for the subject line
						L"",												-- WSring for the body of the message
						0,													-- Total value of coins attached
						{},													-- Table of IDs which are backpack Slot IDs ({} for no attachments)
                        {},													-- Table for backpack ids
						false												-- Message is COD
						)
end

function MailWindowTabAuction.OnLButtonReturnMessage()
if ButtonGetDisabledFlag("MailWindowTabAuctionReturnMessageButton") == true then return end
	MailWindowTabMessage.OnClose()
	SendMailboxCommand(MailWindow.MAILBOX_RETURN_MESSAGE,					-- Msg type, according to warinterface::LuaSendMailboxCommand
						GameData.MailboxType.AUCTION,					-- Mailbox Type
						MailWindowTabAuction.SelectedMessageID,				-- Message ID
						L"",												-- WString for who the message is going to
						L"",												-- WString for the subject line
						L"",												-- WSring for the body of the message
						0,													-- Total value of coins attached
						{},													-- Table of IDs which are backpack Slot IDs ({} for no attachments)
                        {},													-- Table for backpack ids
						false												-- Message is COD
						)
end

function MailWindowTabAuction.OnVertScrollLButtonUp()
	MailWindowTabAuction.NumberOfHeadersChanged()
end

function MailWindowTabAuction.OnMouseOverCoinsImage()
	-- Figure out what Message Header we're hovering over, so we can get the amount of coins attached
	local windowName	= SystemData.ActiveWindow.name
	local windowIndex	= WindowGetId (windowName)
    local dataIndex     = ListBoxGetDataIndex ("MailWindowTabAuctionList", windowIndex)
	local messageHeader = MailWindowTabAuction.listData[dataIndex]

	local text = L""
	local g, s, b = MoneyFrame.ConvertBrassToCurrency (messageHeader.attachmentMoney)

	if messageHeader.isCOD
	then
		text = GetFormatStringFromTable( "mailstrings", StringTables.Mail.TOOLTIP_MAIL_HEADER_COINS_COD, { g, s, b } )
	else
		if messageHeader.isMoneyTaken
		then
			text = GetFormatStringFromTable( "mailstrings", StringTables.Mail.TOOLTIP_MAIL_HEADER_COINS_TAKEN, { g, s, b } )
		else
			text = GetFormatStringFromTable( "mailstrings", StringTables.Mail.TOOLTIP_MAIL_HEADER_COINS, { g, s, b } )
		end
	end

    Tooltips.CreateTextOnlyTooltip (windowName, nil)
    Tooltips.SetTooltipText (1, 1, text)
    Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)
    Tooltips.Finalize ()

    local anchor = { Point="top", RelativeTo=windowName, RelativePoint="bottom", XOffset=0, YOffset=-10 }
    Tooltips.AnchorTooltip (anchor)
    Tooltips.SetTooltipAlpha (1)
end

function MailWindowTabAuction.OnMouseOverAttachmentItem()
  	-- Figure out what Message Header we're hovering over
  	local windowName	= SystemData.ActiveWindow.name
  	local windowIndex	= WindowGetId (windowName)
    local dataIndex     = ListBoxGetDataIndex ("MailWindowTabAuctionList", windowIndex)
  	local messageHeader = MailWindowTabAuction.listData[dataIndex]
  
  	local text = L""
	local g, s, b = MoneyFrame.ConvertBrassToCurrency (messageHeader.attachmentMoney)

  	if messageHeader.isCOD then
  		text = GetFormatStringFromTable( "mailstrings", StringTables.Mail.TOOLTIP_MAIL_HEADER_COINS_COD, { g, s, b } )
  	else
  		if messageHeader.isAttachmentTaken then
  			text = GetMailString(StringTables.Mail.TOOLTIP_MAIL_HEADER_ATTACHMENT_ITEM_TAKEN)
  		else
  			text = GetMailString(StringTables.Mail.TOOLTIP_MAIL_HEADER_ATTACHMENT_ITEM)
  		end
  	end
  
      Tooltips.CreateTextOnlyTooltip (windowName, nil)
      Tooltips.SetTooltipText (1, 1, text)
      Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)
      Tooltips.Finalize ()
  
      local anchor = { Point="top", RelativeTo=windowName, RelativePoint="bottom", XOffset=0, YOffset=-10 }
      Tooltips.AnchorTooltip (anchor)
      Tooltips.SetTooltipAlpha (1)
end

----------------------------------------------------------------
-- Sorting functions
----------------------------------------------------------------

function MailWindowTabAuction.DefaultSort(a, b)
    if ((a == nil) or (b == nil))
    then
        return false
    end

	return a.sentTimeStamp < b.sentTimeStamp
end
