
MailWindowTabInbox = {}
MailWindowTabInbox.SelectedMessageID = 0		-- This is the message ID of the currently selected header

MailWindowTabInbox.listData = {}
MailWindowTabInbox.listDataOrder = {}
MailWindowTabInbox.SelectedMessageDataIndex = 0		-- This is the index into the .listData of where our selected message is.

MailWindowTabInbox.SORT_BY_NAME				= 1
MailWindowTabInbox.SORT_BY_SUBJECT			= 2
MailWindowTabInbox.SORT_BY_EXPIRATION_DATE	= 3
MailWindowTabInbox.SORT_BY_SEND_DATE		= 4
MailWindowTabInbox.SORT_BY_READ				= 5
MailWindowTabInbox.SORT_BY_UNREAD			= 6
MailWindowTabInbox.SORT_BY_COD				= 7

MailWindowTabInbox.SortMethod = MailWindowTabInbox.SORT_BY_EXPIRATION_DATE

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

local function CompareMailMessages(index1, index2)
    if( index2 == nil ) then
        return false
    end

    local header1 = MailWindowTabInbox.listData[index1]
    local header2 = MailWindowTabInbox.listData[index2]

	if header1 == nil then
		return false
	end

	if header2 == nil then
		return true
	end

	local compareResult

	-- Sort by From
    if (MailWindowTabInbox.SortMethod == MailWindowTabInbox.SORT_BY_NAME) then
		compareResult = WStringsCompare(header1.from, header2.from)
	    if compareResult == 0 then
			return (header1.expiresTimeStamp < header2.expiresTimeStamp)
		else
			return ( compareResult < 0 )
		end
    end

	-- Sort by Subject
    if (MailWindowTabInbox.SortMethod == MailWindowTabInbox.SORT_BY_SUBJECT) then
		compareResult = WStringsCompare(wstring.upper(header1.subject), wstring.upper(header2.subject))
	    if compareResult == 0 then
			return (header1.expiresTimeStamp < header2.expiresTimeStamp)
		else
			return ( compareResult < 0 )
		end
    end

    -- Sort by Expiration Date
    if (MailWindowTabInbox.SortMethod == MailWindowTabInbox.SORT_BY_EXPIRATION_DATE) then
		return (header1.expiresTimeStamp < header2.expiresTimeStamp)
    end

    -- Sort by Send Date
    if (MailWindowTabInbox.SortMethod == MailWindowTabInbox.SORT_BY_SEND_DATE) then
		return (header1.sentTimeStamp < header2.sentTimeStamp)
    end

	-- Sort by Read
    if (MailWindowTabInbox.SortMethod == MailWindowTabInbox.SORT_BY_READ) then
		if (header1.hasBeenRead == header2.hasBeenRead) then
			return header1.expiresTimeStamp < header2.expiresTimeStamp
		else
			return ((header1.hasBeenRead == true) and (header2.hasBeenRead == false))
		end
    end

	-- Sort by Unread
    if (MailWindowTabInbox.SortMethod == MailWindowTabInbox.SORT_BY_UNREAD) then
		if (header1.hasBeenRead == header2.hasBeenRead) then
			return header1.expiresTimeStamp < header2.expiresTimeStamp
		else
			return ((header1.hasBeenRead == false) and (header2.hasBeenRead == true))
		end
    end

    -- Sort by COD
    if (MailWindowTabInbox.SortMethod == MailWindowTabInbox.SORT_BY_COD) then
		if header1.isCOD == header2.isCOD then
			return header1.expiresTimeStamp < header2.expiresTimeStamp
		else
			return ( (header1.isCOD == true) and (header2.isCOD == false) )
		end
    end

end
----------------------------------------------------------------
-- Global Functions
----------------------------------------------------------------
function MailWindowTabInbox.Initialize()
	ButtonSetText("MailWindowTabInboxOpenMessageButton",   GetMailString( StringTables.Mail.BUTTON_MAIL_OPEN) )
	ButtonSetText("MailWindowTabInboxDeleteMessageButton", GetMailString( StringTables.Mail.BUTTON_MAIL_DELETE) )
	ButtonSetText("MailWindowTabInboxReturnMessageButton", GetMailString( StringTables.Mail.BUTTON_MAIL_RETURN) )
	ButtonSetDisabledFlag("MailWindowTabInboxReturnMessageButton",true)	

	--LabelSetText("MailWindowTabInboxSelectAllCheckBoxButtonHeader", GetMailString( StringTables.Mail.LABEL_MAIL_HEADER_INBOX_SELECT_ALL) )
	LabelSetText("MailWindowTabInboxSortComboBoxHeader", GetMailString(StringTables.Mail.HEADER_SORT_COMBOBOX))
	WindowRegisterEventHandler( "MailWindowTabInbox", SystemData.Events.MAILBOX_HEADER_UPDATED, "MailWindowTabInbox.OnHeaderUpdated")
	WindowRegisterEventHandler( "MailWindowTabInbox", SystemData.Events.MAILBOX_HEADERS_UPDATED,"MailWindowTabInbox.OnHeadersUpdated")
	WindowRegisterEventHandler( "MailWindowTabInbox", SystemData.Events.MAILBOX_MESSAGE_DELETED,"MailWindowTabInbox.OnMessageDeleted")

	MailWindowTabInbox.InitializeSortComboBox()
	MailWindowTabInbox.ClearHeaders()
end

function MailWindowTabInbox.InitializeSortComboBox()
    ComboBoxClearMenuItems("MailWindowTabInboxSortComboBox")

	ComboBoxAddMenuItem( "MailWindowTabInboxSortComboBox", GetMailString(StringTables.Mail.COMBOBOX_SORT_NAME))
	ComboBoxAddMenuItem( "MailWindowTabInboxSortComboBox", GetMailString(StringTables.Mail.COMBOBOX_SORT_SUBJECT))
	ComboBoxAddMenuItem( "MailWindowTabInboxSortComboBox", GetMailString(StringTables.Mail.COMBOBOX_SORT_EXPIRATION_DATE))
	ComboBoxAddMenuItem( "MailWindowTabInboxSortComboBox", GetMailString(StringTables.Mail.COMBOBOX_SORT_SEND_DATE))
	ComboBoxAddMenuItem( "MailWindowTabInboxSortComboBox", GetMailString(StringTables.Mail.COMBOBOX_SORT_READ))
	ComboBoxAddMenuItem( "MailWindowTabInboxSortComboBox", GetMailString(StringTables.Mail.COMBOBOX_SORT_UNREAD))
	ComboBoxAddMenuItem( "MailWindowTabInboxSortComboBox", GetMailString(StringTables.Mail.COMBOBOX_SORT_COD))

	ComboBoxSetSelectedMenuItem("MailWindowTabInboxSortComboBox", MailWindowTabInbox.SORT_BY_EXPIRATION_DATE )
end

function MailWindowTabInbox.Shutdown()
end

function MailWindowTabInbox.UpdateListButtonStates()
	if (MailWindowTabInboxList.PopulatorIndices ~= nil) then
        for row, index in ipairs(MailWindowTabInboxList.PopulatorIndices) do
            local rowWindow = "MailWindowTabInboxListRow"..row
            -- Highlight the selected row, unhighlight the rest
            ButtonSetPressedFlag(  rowWindow, (MailWindowTabInbox.listData[index].messageID == MailWindowTabInbox.SelectedMessageID) )
            ButtonSetStayDownFlag( rowWindow, (MailWindowTabInbox.listData[index].messageID == MailWindowTabInbox.SelectedMessageID) )
            
            -- Disable windows that cannot be purchased.
            --ButtonSetDisabledFlag(rowWindow, EA_Window_InteractionTraining.HasAbilityFilter( EA_Window_InteractionTraining.advanceData[data] ) )
        end
    end
	
	if MailWindowTabInbox.SelectedMessageDataIndex > 0 then	
		ButtonSetDisabledFlag("MailWindowTabInboxReturnMessageButton", not MailWindowTabInbox.listData[MailWindowTabInbox.SelectedMessageDataIndex].isReturnable)	
	end
end

-- Whenever the # of headers changes, we have to updated the header text and account for if no headers exist.
function MailWindowTabInbox.NumberOfHeadersChanged()
	local bNoMessages = #MailWindowTabInbox.listData == 0 or MailWindowTabInboxList.PopulatorIndices == nil
	if  bNoMessages then
		LabelSetText("MailWindowTabInboxMessageNumberText", GetMailString( StringTables.Mail.TEXT_MAIL_NO_MESSAGES ) )
	elseif #MailWindowTabInbox.listData < MailWindowTabInboxList.numVisibleRows then
		local low  = L""..MailWindowTabInboxList.PopulatorIndices[1]
		local high = L""..(low - 1 + #MailWindowTabInbox.listData)
		LabelSetText("MailWindowTabInboxMessageNumberText", GetStringFormatFromTable("MailStrings", StringTables.Mail.TEXT_MAIL_DISPLAYING, {low, high, L""..#MailWindowTabInbox.listData} )) 
	else
		local low  = L""..MailWindowTabInboxList.PopulatorIndices[1]
		local high = L""..(low - 1 + MailWindowTabInboxList.numVisibleRows)
		LabelSetText("MailWindowTabInboxMessageNumberText", GetStringFormatFromTable("MailStrings", StringTables.Mail.TEXT_MAIL_DISPLAYING, {low, high, L""..#MailWindowTabInbox.listData} )) 
	end

	WindowSetShowing("MailWindowTabInboxList", bNoMessages == false)
	WindowSetShowing("MailWindowTabInboxOpenMessageButton", bNoMessages == false)
	WindowSetShowing("MailWindowTabInboxDeleteMessageButton", bNoMessages == false)
	WindowSetShowing("MailWindowTabInboxReturnMessageButton", bNoMessages == false)
	WindowSetShowing("MailWindowTabInboxSortComboBoxHeader", bNoMessages == false)
	WindowSetShowing("MailWindowTabInboxSortComboBox", bNoMessages == false)
end

function MailWindowTabInbox.OnHeaderUpdated(headerData, mailboxType)
	if mailboxType ~= GameData.MailboxType.PLAYER then
		return
	end
	for index, data in ipairs(MailWindowTabInbox.listData) do
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

			if headerData[1].attachmentMoney == 0 and 
				(headerData[1].attachmentIconIDs == nil or #headerData[1].attachmentIconIDs == 0)
			then
				data.type		= L"Letter"
			else
				data.type		= L"Attachment"
			end
			break
		end
	end

	MailWindowTabInbox.ApplyFilters()
	MailWindowTabInbox.SortMail()
	MailWindowTabInbox.Populate()
	MailWindowTabInbox.NumberOfHeadersChanged()
end

function MailWindowTabInbox.ClearHeaders()
	MailWindowTabInbox.listData = {}
	MailWindowTabInbox.ApplyFilters()
	MailWindowTabInbox.SortMail()
	MailWindowTabInbox.Populate()
	MailWindowTabInbox.NumberOfHeadersChanged()
end

function MailWindowTabInbox.OnHeadersUpdated(headerList, mailboxType) -- This function should only be called by a LUA script that passes in all the Headers.
	if mailboxType ~= GameData.MailboxType.PLAYER then
		return
	end
	MailWindowTabInbox.listData = {}
	for index, data in ipairs(headerList)
	do
		MailWindowTabInbox.listData[index] = {}
		MailWindowTabInbox.listData[index].messageID		= data.messageID
		MailWindowTabInbox.listData[index].messageFlags		= data.messageFlags
		MailWindowTabInbox.listData[index].hasBeenRead		= data.hasBeenRead
		MailWindowTabInbox.listData[index].isReturnable		= data.isReturnable
		MailWindowTabInbox.listData[index].hasBeenReturned	= data.hasBeenReturned
		MailWindowTabInbox.listData[index].isCODPayment		= data.isCODPayment
		MailWindowTabInbox.listData[index].from				= data.strSenderName
		MailWindowTabInbox.listData[index].subject			= data.strSubject
		MailWindowTabInbox.listData[index].sent				= FormatTimeSent(data.messageSendDelta*-1)
		MailWindowTabInbox.listData[index].sentTimeStamp	= data.messageSendDelta*-1
		MailWindowTabInbox.listData[index].expiresTimeStamp	= data.messageExpireDelta
		MailWindowTabInbox.listData[index].expires			= FormatTimeExpires(data.messageExpireDelta)
		MailWindowTabInbox.listData[index].attachmentMoney	= data.attachmentMoney
		MailWindowTabInbox.listData[index].attachmentIconIDs = DataUtils.CopyTable(data.attachmentIconIDs)
		MailWindowTabInbox.listData[index].isCOD			= data.isCOD
		MailWindowTabInbox.listData[index].isMoneyTaken		= data.isMoneyTaken
		MailWindowTabInbox.listData[index].isCODPaid		= data.isCODPaid
		MailWindowTabInbox.listData[index].isReturned		= data.isReturned
		MailWindowTabInbox.listData[index].attachmentsTakenTable		= DataUtils.CopyTable(data.attachmentsTakenTable)

		if data.attachmentMoney == 0 and (data.attachmentIconIDs == nil or #data.attachmentIconIDs == 0)
		then
			MailWindowTabInbox.listData[index].type		= L"Letter"
		else
			MailWindowTabInbox.listData[index].type		= L"Attachment"
		end
	end

	MailWindowTabInbox.ApplyFilters()
	MailWindowTabInbox.SortMail()
	MailWindowTabInbox.Populate()
	MailWindowTabInbox.NumberOfHeadersChanged()
end

function MailWindowTabInbox.OnMessageDeleted(messageID, mailboxType)
	if mailboxType ~= GameData.MailboxType.PLAYER then
		return
	end

	for index, data in ipairs(MailWindowTabInbox.listData) do
		if data.messageID == messageID then
			table.remove(MailWindowTabInbox.listData, index)
			break
		end
	end

	MailWindowTabInbox.ApplyFilters()
	MailWindowTabInbox.SortMail()
	MailWindowTabInbox.Populate()
	MailWindowTabInbox.NumberOfHeadersChanged()

end

function MailWindowTabInbox.PopulateIcon(rowFrame, headerData)
    local iconFrame = rowFrame.."Icon"
	local sliceName = MailWindowUtils.GetHeaderIconSliceName(headerData)
	DynamicImageSetTextureSlice(iconFrame, sliceName)
end

function MailWindowTabInbox.PopulateCoinsAttachment(rowFrame, headerData)

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

function MailWindowTabInbox.PopulateItemAttachments(rowFrame, headerData)
	MailWindowUtils.PopulateItemAttachments(rowFrame, headerData)
end

function MailWindowTabInbox.Populate()
    if (nil == MailWindowTabInboxList.PopulatorIndices) then
		return
    end

	for row, data in ipairs(MailWindowTabInboxList.PopulatorIndices) do
		local headerData = MailWindowTabInbox.listData[data]
		local rowFrame   = "MailWindowTabInboxListRow"..row

		MailWindowTabInbox.PopulateIcon(rowFrame, headerData)
		MailWindowTabInbox.PopulateItemAttachments(rowFrame, headerData)
		MailWindowTabInbox.PopulateCoinsAttachment(rowFrame, headerData)

		-- If the message is already open, update it.
		if MailWindowTabMessage.messageBodyTable.messageID ~= nil and 
		   MailWindowTabMessage.messageBodyTable.messageID == headerData.messageID
		then
			MailWindowTabMessage.UpdateMessageAttachments(headerData)
		end
	end

	MailWindowTabInbox.UpdateListButtonStates()
	MailWindowTabInbox.NumberOfHeadersChanged()
end

function MailWindowTabInbox.SortMail()
	table.sort(MailWindowTabInbox.listDataOrder, CompareMailMessages)
	ListBoxSetDisplayOrder("MailWindowTabInboxList", MailWindowTabInbox.listDataOrder)
end

function MailWindowTabInbox.ApplyFilters()

	MailWindowTabInbox.listDataOrder = {}

    if (MailWindowTabInbox.listData == nil) then				-- This can occur during the initial load, in which case ignore it
        return
    end

	local filterPass = true
    for index, data in pairs(MailWindowTabInbox.listData) do
    
        -- Apply all filters in our filter list - those set to nil won't be applied and so the entry will automatically pass those.        
		if data.messageID == 0 then
			filterPass = false
		else
			filterPass = true
		end

        if (filterPass) then
            table.insert(MailWindowTabInbox.listDataOrder, index)
        end
    end

	MailWindowTabInbox.SortMail()
end

function MailWindowTabInbox.CreateMailHeaderContextMenu( windowNameToActUpon )
    if( windowNameToActUpon == nil or windowNameToActUpon == "" ) then	
        return
    end
    
    EA_Window_ContextMenu.CreateContextMenu( windowNameToActUpon ) 
    local bMarkedRead = true
	
    EA_Window_ContextMenu.AddMenuItem( GetMailString( StringTables.Mail.LABEL_MAIL_HEADER_MARK_READ ), MailWindowTabInbox.OnMarkRead, not bMarkedRead, true )
    EA_Window_ContextMenu.AddMenuItem( GetMailString( StringTables.Mail.LABEL_MAIL_HEADER_MARK_UNREAD ), MailWindowTabInbox.OnMarkUnread, not bMarkedRead, true )
    EA_Window_ContextMenu.Finalize()
end

function MailWindowTabInbox.OnMarkRead()
	SendMailboxCommand(MailWindow.MAILBOX_MESSAGE_MARK_READ,				-- Msg type, according to warinterface::LuaSendMailboxCommand
						GameData.MailboxType.PLAYER,							-- Mailbox Type
						MailWindowTabInbox.SelectedMessageID,				-- Message ID
						L"",												-- WString for who the message is going to
						L"",												-- WString for the subject line
						L"",												-- WSring for the body of the message
						0,													-- Total value of coins attached
						{},													-- Table of IDs which are backpack Slot IDs ({} for no attachments)
						{},													-- Table for backpack ids
						false												-- Message is COD
						)
end

function MailWindowTabInbox.OnMarkUnread()
	SendMailboxCommand(MailWindow.MAILBOX_MESSAGE_MARK_UNREAD,				-- Msg type, according to warinterface::LuaSendMailboxCommand
						GameData.MailboxType.PLAYER,						-- Mailbox Type
						MailWindowTabInbox.SelectedMessageID,				-- Message ID
						L"",												-- WString for who the message is going to
						L"",												-- WString for the subject line
						L"",												-- WSring for the body of the message
						0,													-- Total value of coins attached
						{},													-- Table of IDs which are backpack Slot IDs ({} for no attachments)
						{},													-- Table for backpack ids
						false												-- Message is COD
						)
end

function MailWindowTabInbox.OnLButtonOpenMessage()
	SendMailboxCommand(MailWindow.MAILBOX_OPEN_MESSAGE,						-- Msg type, according to warinterface::LuaSendMailboxCommand
						GameData.MailboxType.PLAYER,						-- Mailbox Type
						MailWindowTabInbox.SelectedMessageID,				-- Message ID
						L"",												-- WString for who the message is going to
						L"",												-- WString for the subject line
						L"",												-- WSring for the body of the message
						0,													-- Total value of coins attached
						{},													-- Table of IDs which are backpack Slot IDs ({} for no attachments)
						{},													-- Table for backpack ids
						false												-- Message is COD
						)
end

function MailWindowTabInbox.OnLButtonDeleteMessage()
	-- Figure out what Message Header we've clicked on
	local header = MailWindowTabInbox.listData[MailWindowTabInbox.SelectedMessageDataIndex]

	-- Only delete the message immediately if it's already been read, there's no attachements, and the COD, if any, has been paid.

	-- If there are still coins attached
	if ( (header.attachmentMoney > 0 and header.isMoneyTaken == false) or
		-- or an item is still attached
		(#header.attachmentIconIDs > 0 and #header.attachmentIconIDs ~= #header.attachmentsTakenTable) or
		-- or the message hasn't been read yet
		(header.hasBeenRead == false) 
	    ) 
	    and
        (  -- And this message is an unpaid COD
		  (header.isCOD == false) or (header.isCOD and header.isCODPaid == false )
	    )

	-- then create a confirmation dialog to ensure the user really wants to delete this message
	then
		local dialogText = GetMailString(StringTables.Mail.DIALOG_CONFIRM_DELETE_ATTACHED_MESSAGE )
		
		if header.hasBeenRead == false then	-- Customize the message based on being unread, or with attachment
			dialogText = GetMailString(StringTables.Mail.DIALOG_CONFIRM_DELETE_UNREAD_MESSAGE )
		end

		DialogManager.MakeTwoButtonDialog( dialogText, GetMailString(StringTables.Mail.BUTTON_CONFIRM_YES), MailWindowTabInbox.ConfirmDeleteMessage, GetMailString(StringTables.Mail.BUTTON_CONFIRM_NO), nil)

	-- Otherwise, no confirmation of deletion is needed. Just delete it.
	else
		MailWindowTabInbox.ConfirmDeleteMessage()
	end
end

function MailWindowTabInbox.ConfirmDeleteMessage()
	MailWindowTabMessage.OnClose()
	SendMailboxCommand(MailWindow.MAILBOX_DELETE_MESSAGE,					-- Msg type, according to warinterface::LuaSendMailboxCommand
						GameData.MailboxType.PLAYER,						-- Mailbox Type
						MailWindowTabInbox.SelectedMessageID,				-- Message ID
						L"",												-- WString for who the message is going to
						L"",												-- WString for the subject line
						L"",												-- WSring for the body of the message
						0,													-- Total value of coins attached
						{},													-- Table of IDs which are backpack Slot IDs ({} for no attachments)
						{},													-- Table for backpack ids
						false												-- Message is COD
						)
end

function MailWindowTabInbox.OnLButtonReturnMessage()
if ButtonGetDisabledFlag("MailWindowTabInboxReturnMessageButton") == true then return end
	MailWindowTabMessage.OnClose()
	SendMailboxCommand(MailWindow.MAILBOX_RETURN_MESSAGE,					-- Msg type, according to warinterface::LuaSendMailboxCommand
						GameData.MailboxType.PLAYER,						-- Mailbox Type
						MailWindowTabInbox.SelectedMessageID,				-- Message ID
						L"",												-- WString for who the message is going to
						L"",												-- WString for the subject line
						L"",												-- WSring for the body of the message
						0,													-- Total value of coins attached
						{},												-- Table of IDs which are backpack Slot IDs ({} for no attachments)
						{},													-- Table for backpack ids
						false												-- Message is COD
						)
end

function MailWindowTabInbox.OnVertScrollLButtonUp()
	MailWindowTabInbox.NumberOfHeadersChanged()
end

function MailWindowTabInbox.OnMouseOverCoinsImage()
	-- Figure out what Message Header we're hovering over, so we can get the amount of coins attached
	local windowName	= SystemData.ActiveWindow.name
	local windowIndex	= WindowGetId (windowName)
    local dataIndex     = ListBoxGetDataIndex ("MailWindowTabInboxList", windowIndex)
	local messageHeader = MailWindowTabInbox.listData[dataIndex]

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

function MailWindowTabInbox.OnMouseOverAttachmentItem()
  	-- Figure out what Message Header we're hovering over
  	local windowName	= SystemData.ActiveWindow.name
  	local windowIndex	= WindowGetId (windowName)
    local dataIndex     = ListBoxGetDataIndex ("MailWindowTabInboxList", windowIndex)
  	local messageHeader = MailWindowTabInbox.listData[dataIndex]
  
  	local text = L""
	local g, s, b = MoneyFrame.ConvertBrassToCurrency (messageHeader.attachmentMoney)
  	if messageHeader.isCOD then
  		text = GetFormatStringFromTable( "mailstrings", StringTables.Mail.TOOLTIP_MAIL_HEADER_COINS_COD, { g, s, b } )
  	else
		local numItemsTaken, numItemsNotTaken = MailWindowUtils.GetNumberOfTakenAndUntakenAttachmentItems(messageHeader)
		if numItemsTaken > 0 then
			text = GetStringFormatFromTable( "mailstrings", StringTables.Mail.TOOLTIP_MAIL_HEADER_ATTACHMENT_X_ITEM_TAKEN, {L""..numItemsTaken, L""..numItemsNotTaken} ) 
  		else
			text = GetStringFormatFromTable( "mailstrings", StringTables.Mail.TOOLTIP_MAIL_HEADER_ATTACHMENT_X_ITEM, {L""..numItemsNotTaken} ) 
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

function MailWindowTabInbox.OnSelChangedSortComboBox()
	local sortMethod = ComboBoxGetSelectedMenuItem("MailWindowTabInboxSortComboBox")
	MailWindowTabInbox.SetSortMethod(sortMethod)
	MailWindowTabInbox.SortMail()
end

function MailWindowTabInbox.SetSortMethod(index)
	MailWindowTabInbox.SortMethod = index
end