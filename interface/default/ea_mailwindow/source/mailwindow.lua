----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------
MailWindow = {}

MailWindow.TABS_INBOX		= 1
MailWindow.TABS_SEND		= 2
MailWindow.TABS_AUCTION		= 3
MailWindow.TABS_MAX_NUMBER	= 3

MailWindow.SelectedTab		= MailWindow.TABS_INBOX

MailWindow.Tabs = {} 
MailWindow.Tabs[ MailWindow.TABS_INBOX  ]	= { window = "MailWindowTabInbox",   name="MailWindowTabsInbox",   populationFunction = MailWindowTabInbox.Populate,	label=StringTables.Mail.LABEL_MAIL_TAB_INBOX,   tooltip=StringTables.Mail.TOOLTIP_MAIL_TAB_INBOX,	filterWindow="EA_Window_InteractionTrainingFiltersCore"   }
MailWindow.Tabs[ MailWindow.TABS_SEND	]   = { window = "MailWindowTabSend",	 name="MailWindowTabsSend",    populationFunction = nil,						    label=StringTables.Mail.LABEL_MAIL_TAB_SEND,	tooltip=StringTables.Mail.TOOLTIP_MAIL_TAB_SEND,    filterWindow="EA_Window_InteractionTrainingFiltersPath2"  }
MailWindow.Tabs[ MailWindow.TABS_AUCTION]   = { window = "MailWindowTabAuction", name="MailWindowTabsAuction", populationFunction = MailWindowTabAuction.Populate,	label=StringTables.Mail.LABEL_MAIL_TAB_AUCTION,	tooltip=StringTables.Mail.TOOLTIP_MAIL_TAB_AUCTION, filterWindow="EA_Window_InteractionTrainingFiltersCore"  }

-- These are used to determine what the subtype of message is. These must match the switch statement in war_interface::LuaSendMailboxCommand
MailWindow.MAILBOX_CLOSE			= 0
MailWindow.MAILBOX_SEND				= 1
MailWindow.MAILBOX_OPEN_MESSAGE		= 2
MailWindow.MAILBOX_DELETE_MESSAGE	= 3
MailWindow.MAILBOX_RETURN_MESSAGE	= 4
MailWindow.MAILBOX_TAKE_MONEY		= 5
MailWindow.MAILBOX_TAKE_ITEM		= 6
MailWindow.MAILBOX_TAKE_ALL			= 7
MailWindow.MAILBOX_MESSAGE_MARK_READ	= 8
MailWindow.MAILBOX_MESSAGE_MARK_UNREAD	= 9

MailWindow.PostageCostTotal = 0
MailWindow.PostageCostBase = 0
MailWindow.PostageCostItemMultiplier = 0

MailWindow.ATTACHMENTS_MAX_ROWS	= 2
MailWindow.ATTACHMENTS_MAX_COLS	= 8

----------------------------------------------------------------
-- MailWindow Functions
----------------------------------------------------------------
function MailWindow.Initialize()
    
    WindowRegisterEventHandler ("MailWindow", SystemData.Events.PLAYER_MONEY_UPDATED,         "MailWindow.UpdateMoney" )
    WindowRegisterEventHandler( "MailWindow", SystemData.Events.INTERACT_MAILBOX_OPEN,        "MailWindow.OnOpen")
    WindowRegisterEventHandler( "MailWindow", SystemData.Events.INTERACT_MAILBOX_CLOSED,      "MailWindow.OnClose")
    WindowRegisterEventHandler( "MailWindow", SystemData.Events.INTERACT_DONE,                "MailWindow.OnClose")
    WindowRegisterEventHandler( "MailWindow", SystemData.Events.MAILBOX_RESULTS_UPDATED,      "MailWindow.OnResultsUpdated")
    WindowRegisterEventHandler( "MailWindow", SystemData.Events.MAILBOX_POSTAGE_COST_UPDATED, "MailWindow.OnPostageCostOpened")

    -- Header text
    LabelSetText("MailWindowTitleBarText", GetMailString( StringTables.Mail.LABEL_MAIL_WINDOW ) )

    -- Tab Text
    MailWindow.SetTabLabels()

    -- Show the Inbox Tab by default
    MailWindow.ShowTabInboxElements()
    MailWindow.SetListRowTints()
    MailWindow.SetListRowHeaders()

    MailWindow.UpdateMoney()
end

function MailWindow.Shutdown()
end

function MailWindow.OnOpen()	-- Registered Event Trigger
    WindowSetShowing( "MailWindow", true )
end

function MailWindow.OnClose()	-- Registered Event Trigger	(Server closed the mailbox)
    MailWindow.Hide()
	MailWindowTabSend.ClearEntries()
end

function MailWindow.OnClose()	-- User Event Trigger (User requested to close the mailbox)
    MailWindowTabMessage.OnClose()
    WindowSetShowing( "MailWindow", false )		-- Close the window directly so we dont have to wait for the server msg
    MailWindowTabInbox.SelectedMessageID = 0
    MailWindowTabInbox.SelectedMessageDataIndex = 0
    MailWindowTabAuction.SelectedMessageDataIndex = 0
	MailWindowTabSend.ClearEntries()
    SendMailboxCommand(MailWindow.MAILBOX_CLOSE,    -- Msg type, must match switch statement in War interface
                       GameData.MailboxType.PLAYER,	-- Mailbox Type
                       0,							-- Message ID
                       L"",							-- WString for who the message is going to
                       L"",							-- WString for the subject line
                       L"",							-- WSring for the body of the message
                       0,							-- Total value of coins attached
                       {},							-- Table of IDs which are backpack Slot IDs ({} for no attachments)
                       {},							-- Table for backpack ids
                       false
                       )
end

function MailWindow.OnShown()

end

function MailWindow.OnHidden()

end

function MailWindow.Hide()
    MailWindowTabMessage.OnClose()
    MailWindowTabInbox.SelectedMessageID = 0
    MailWindowTabInbox.SelectedMessageDataIndex = 0
    MailWindowTabAuction.SelectedMessageDataIndex = 0
    WindowSetShowing( "MailWindow", false );	
end

function MailWindow.CreateDefaultContextMenu( windowNameToActUpon )
    if( windowNameToActUpon == nil or windowNameToActUpon == "" ) then
        return
    end
    
    EA_Window_ContextMenu.CreateContextMenu( windowNameToActUpon ) 
    local movable = WindowGetMovable( EA_Window_ContextMenu.activeWindow )

    EA_Window_ContextMenu.AddMenuItem( GetMailString( StringTables.Mail.LABEL_MAIL_WINDOW_LOCK ), MailWindow.OnLock, not movable, true )
    EA_Window_ContextMenu.AddMenuItem( GetMailString( StringTables.Mail.LABEL_MAIL_WINDOW_UNLOCK ), MailWindow.OnUnlock, movable, true )
    EA_Window_ContextMenu.AddMenuItem( GetMailString( StringTables.Mail.LABEL_MAIL_WINDOW_SET_OPACITY ), EA_Window_ContextMenu.OnWindowOptionsSetAlpha, false, true )
    EA_Window_ContextMenu.Finalize()
end

function MailWindow.OnRButtonUp()
    MailWindow.CreateDefaultContextMenu( "MailWindow" )
end

function MailWindow.OnMouseOverCoinsImage()
    if MailWindow.SelectedTab == MailWindow.TABS_INBOX then
        MailWindowTabInbox.OnMouseOverCoinsImage()
    elseif MailWindow.SelectedTab == MailWindow.TABS_AUCTION then
        MailWindowTabAuction.OnMouseOverCoinsImage()
    end
end

function MailWindow.OnMouseOverAttachmentItem()
    if MailWindow.SelectedTab == MailWindow.TABS_INBOX then
        MailWindowTabInbox.OnMouseOverAttachmentItem()
    elseif MailWindow.SelectedTab == MailWindow.TABS_AUCTION then
        MailWindowTabAuction.OnMouseOverAttachmentItem()
    end
end

function MailWindow.OnRButtonUpMailHeader()

    if WindowGetShowing("MailWindowTabMessage") then
        MailWindowTabMessage.OnClose()
    end

    local selectedRow = WindowGetId(SystemData.MouseOverWindow.name)

    -- Automatically select the header row of where the R Click was.
    if MailWindow.SelectedTab == MailWindow.TABS_INBOX then
        dataIndex = ListBoxGetDataIndex("MailWindowTabInboxList", selectedRow)
        MailWindowTabInbox.SelectedMessageID = MailWindowTabInbox.listData[dataIndex].messageID
        MailWindowTabInbox.SelectedMessageDataIndex = dataIndex

        MailWindowTabInbox.UpdateListButtonStates()
        MailWindowTabInbox.CreateMailHeaderContextMenu( "MailWindowTabInboxListRow"..selectedRow.."Header" )

    elseif MailWindow.SelectedTab == MailWindow.TABS_AUCTION then
        dataIndex = ListBoxGetDataIndex("MailWindowTabAuctionList", selectedRow)
        MailWindowTabAuction.SelectedMessageID = MailWindowTabAuction.listData[dataIndex].messageID
        MailWindowTabAuction.SelectedMessageDataIndex = dataIndex

        MailWindowTabAuction.UpdateListButtonStates()
        MailWindowTabAuction.CreateMailHeaderContextMenu( "MailWindowTabAuctionListRow"..selectedRow.."Header" )
    end

end

function MailWindow.OnLock()
    WindowSetMovable( EA_Window_ContextMenu.activeWindow, false )
end

function MailWindow.OnUnlock()    
    WindowSetMovable( EA_Window_ContextMenu.activeWindow, true )
end

---------------------------------------
-- Tab Controls
---------------------------------------

function MailWindow.SetTabLabels()
    for index, TabIndex in ipairs(MailWindow.Tabs)
    do
        ButtonSetText(MailWindow.Tabs[index].name, GetMailString(MailWindow.Tabs[index].label ) )
    end

end

function MailWindow.ToggleAllTabs(showTabs)
    
    --for tabIndex = 1, MailWindow.TABS_MAX_NUMBER do
    --    WindowSetShowing( "MailWindowViewMode"..tabIndex, showTabs )
    --end
end

function MailWindow.SetHighlightedTabText(tabNumber)

    for index, TabIndex in ipairs(MailWindow.Tabs) do
        if (index ~= tabNumber) then
            ButtonSetPressedFlag( TabIndex.name, false )
        else
            ButtonSetPressedFlag( TabIndex.name, true )
        end
    end
end

function MailWindow.HideTabAllElements()
    MailWindow.HideTabInboxElements()
    MailWindow.HideTabSendElements()
    MailWindow.HideTabAuctionElements()
end

function MailWindow.HideTabCurrentElements()
    MailWindow.HideTabAllElements()

    local showing = WindowGetShowing( "MailWindowTabInbox" )
    if (MailWindow.SelectedTab == MailWindow.TABS_INBOX and not showing) then MailWindow.HideTabInboxElements()  end

    showing = WindowGetShowing( "MailWindowTabSend" )
    if (MailWindow.SelectedTab == MailWindow.TABS_SEND and not showing) then MailWindow.HideTabSendElements() end

    showing = WindowGetShowing( "MailWindowTabAuction" )
    if (MailWindow.SelectedTab == MailWindow.TABS_AUCTION and not showing) then MailWindow.HideTabAuctionElements() end

end

-- Hide and Show Inbox Tab
function MailWindow.HideTabInboxElements()

    WindowSetShowing("MailWindowTabInbox", false)
end

function MailWindow.ShowTabInboxElements()

    MailWindow.HideTabCurrentElements()
    WindowSetShowing("MailWindowTabInbox", true)
    
    MailWindow.SelectedTab = MailWindow.TABS_INBOX
    MailWindow.SetHighlightedTabText(MailWindow.SelectedTab)
end

-- Hide and Show Send Tab
function MailWindow.HideTabSendElements()
    WindowSetShowing("MailWindowTabSend", false)
end

function MailWindow.ShowTabSendElements()

    MailWindow.HideTabCurrentElements()
    WindowSetShowing("MailWindowTabSend", true)
    
    MailWindow.SelectedTab = MailWindow.TABS_SEND
    MailWindow.SetHighlightedTabText(MailWindow.SelectedTab)
    
    local isTrial, _ = GetAccountData()
    
    if( isTrial )
    then
        EA_TrialAlertWindow.Show(SystemData.TrialAlert.ALERT_MAIL)
    end
end

-- Hide and Show Auction Tab
function MailWindow.HideTabAuctionElements()
    WindowSetShowing("MailWindowTabAuction", false)
end

function MailWindow.ShowTabAuctionElements()

    MailWindow.HideTabCurrentElements()
    WindowSetShowing("MailWindowTabAuction", true)
    
    MailWindow.SelectedTab = MailWindow.TABS_AUCTION
    MailWindow.SetHighlightedTabText(MailWindow.SelectedTab)
end

function MailWindow.OnMouseOverTab()

end

function MailWindow.OnLButtonUpTab()
    MailWindow.HideTabCurrentElements()
    MailWindowTabMessage.OnClose()
    local windowName	= SystemData.ActiveWindow.name
    local windowIndex	= WindowGetId (windowName)

    WindowSetShowing(MailWindow.Tabs[windowIndex].window, true)
    MailWindow.SelectedTab = windowIndex
    MailWindow.SetHighlightedTabText(MailWindow.SelectedTab)

    if windowIndex == MailWindow.TABS_SEND then
        MailWindowTabSend.ClearEntries()
        
        local isTrial, _ = GetAccountData()
    
        if( isTrial )
        then
            EA_TrialAlertWindow.Show(SystemData.TrialAlert.ALERT_MAIL)
        end
    end

    MailWindow.OnResultsUpdated()	-- Clear any results that may be displayed

    if (MailWindow.Tabs[MailWindow.SelectedTab].populationFunction ~= nil) then
        MailWindow.Tabs[MailWindow.SelectedTab].populationFunction()
        MailWindow.SetListRowTints()
        MailWindow.SetListRowHeaders()
        --WindowSetShowing("MailWindowTabInboxMetaFiltersComboBoxButton", false)	-- Disabled for now
    else
        --WindowSetShowing("MailWindowTabInboxMetaFiltersComboBoxButton", false)
    end
end

function MailWindow.SetListRowTints()
    local numVisibleRows = MailWindowTabInboxList.numVisibleRows	-- Assume Inbox as default

    if MailWindow.SelectedTab == MailWindow.TABS_AUCTION then
        numVisibleRows = MailWindowTabAuctionList.numVisibleRows
    end

    local row_mod = 1
    local color = DataUtils.GetAlternatingRowColor( row_mod )
    local targetRowWindow = ""

    --for row = 1, MailWindowTabInboxList.numVisibleRows do
    for row = 1, numVisibleRows do
        row_mod = math.mod(row, 2)
        color = DataUtils.GetAlternatingRowColor( row_mod )
        targetRowWindow = MailWindow.Tabs[ MailWindow.SelectedTab  ].window.."ListRow"..row
        
        WindowSetTintColor(targetRowWindow.."RowBackground", color.r, color.g, color.b )
        WindowSetAlpha(targetRowWindow.."RowBackground", color.a)
    end
end

function MailWindow.SetListRowHeaders()
    local numVisibleRows = MailWindowTabInboxList.numVisibleRows	-- Assume Inbox as default

    if MailWindow.SelectedTab == MailWindow.TABS_AUCTION then
        numVisibleRows = MailWindowTabAuctionList.numVisibleRows
    end

    local labelName = ""

    for row = 1, numVisibleRows do
        labelName = MailWindow.Tabs[ MailWindow.SelectedTab].window.."ListRow"..row.."Header"
        LabelSetText( labelName.."From", GetMailString(StringTables.Mail.LABEL_MAIL_HEADER_FROM) )
        LabelSetText( labelName.."Subject",GetMailString(StringTables.Mail.LABEL_MAIL_HEADER_SUBJECT) )
        LabelSetText( labelName.."Sent", GetMailString(StringTables.Mail.LABEL_MAIL_HEADER_SENT) )
        LabelSetText( labelName.."Expires", GetMailString(StringTables.Mail.LABEL_MAIL_HEADER_EXPIRES) )
    end
end

function MailWindow.UpdateMoney()
    MoneyFrame.FormatMoney ("MailWindowTabSendMoneyInBackpackFrame", Player.GetMoney(), MoneyFrame.SHOW_EMPTY_WINDOWS);
end

function MailWindow.SelectMailHeader()

    local selectedRow = WindowGetId(SystemData.MouseOverWindow.name)
    local dataIndex = 0
    local messageID = 0

    if WindowGetShowing("MailWindowTabMessage") then
        MailWindowTabMessage.OnClose()
    end

    if MailWindow.SelectedTab == MailWindow.TABS_INBOX then
        if selectedRow > 0 and MailWindowTabInbox.listData ~= nil then	-- WindowID could be 0 in windowed mode if we click out and then back into WAR.
            dataIndex = ListBoxGetDataIndex("MailWindowTabInboxList", selectedRow)
            messageID = MailWindowTabInbox.listData[dataIndex].messageID
            if MailWindowTabInbox.SelectedMessageID == messageID then	-- If the row is already selected, then open it.
                MailWindowTabInbox.OnLButtonOpenMessage()
            else
                MailWindowTabInbox.SelectedMessageID = messageID
                MailWindowTabInbox.SelectedMessageDataIndex = dataIndex
            end
            MailWindowTabInbox.UpdateListButtonStates()
        end
    elseif MailWindow.SelectedTab == MailWindow.TABS_AUCTION then
        if selectedRow > 0 and MailWindowTabAuction.listData ~= nil then	-- WindowID could be 0 in windowed mode if we click out and then back into WAR.
            dataIndex = ListBoxGetDataIndex("MailWindowTabAuctionList", selectedRow)
            messageID = MailWindowTabAuction.listData[dataIndex].messageID
            if MailWindowTabAuction.SelectedMessageID == messageID then	-- If the row is already selected, then open it.
                MailWindowTabAuction.OnLButtonOpenMessage()
            else
                MailWindowTabAuction.SelectedMessageID = messageID
                MailWindowTabAuction.SelectedMessageDataIndex = dataIndex
            end
            MailWindowTabAuction.UpdateListButtonStates()
        end
    end
end

function MailWindow.OnPostageCostOpened(base, itemMultiplier)
    MailWindow.PostageCostBase = base
    MailWindow.PostageCostItemMultiplier = itemMultiplier
end

function MailWindow.OnResultsUpdated(resultCode, mailboxType)

    -- No valid returnCode means we can just hide the result text window (which is better performance than setting it to "")
    if resultCode == nil or resultCode <= 0 then
        WindowSetShowing(MailWindow.Tabs[ MailWindow.TABS_INBOX ].window.."ResultText", false)
        WindowSetShowing(MailWindow.Tabs[ MailWindow.TABS_SEND ].window.."ResultText", false)
        WindowSetShowing(MailWindow.Tabs[ MailWindow.TABS_AUCTION].window.."ResultText", false)
        return
    end

    -- Show the result text on the correct Tab
    WindowSetShowing(MailWindow.Tabs[ MailWindow.TABS_INBOX ].window.."ResultText", MailWindow.SelectedTab == MailWindow.TABS_INBOX)
    WindowSetShowing(MailWindow.Tabs[ MailWindow.TABS_SEND ].window.."ResultText", MailWindow.SelectedTab == MailWindow.TABS_SEND)
    WindowSetShowing(MailWindow.Tabs[ MailWindow.TABS_AUCTION].window.."ResultText", MailWindow.SelectedTab == MailWindow.TABS_AUCTION)

    local labelName = MailWindow.Tabs[ MailWindow.SelectedTab ].window.."ResultText"

    --These must match the wh_const enum EMailResult
    if resultCode == 1 then LabelSetText(labelName, GetMailString( StringTables.Mail.TEXT_MAIL_RESULT1) )
        elseif resultCode == 2 then LabelSetText(labelName, GetMailString( StringTables.Mail.TEXT_MAIL_RESULT2) )
        elseif resultCode == 3 then LabelSetText(labelName, GetMailString( StringTables.Mail.TEXT_MAIL_RESULT3) )
        elseif resultCode == 4 then 
            LabelSetText(labelName, GetMailString( StringTables.Mail.TEXT_MAIL_RESULT4)  )
            MailWindowTabSend.ClearEntries()	-- Since the message we just sent was successful, we can clear everything in the Send Window.
        elseif resultCode == 5 then LabelSetText(labelName, GetMailString( StringTables.Mail.TEXT_MAIL_RESULT5) )
        elseif resultCode == 6 then LabelSetText(labelName, GetMailString( StringTables.Mail.TEXT_MAIL_RESULT6) )
        elseif resultCode == 7 then LabelSetText(labelName, GetMailString( StringTables.Mail.TEXT_MAIL_RESULT7) )
        elseif resultCode == 8 then LabelSetText(labelName, GetMailString( StringTables.Mail.TEXT_MAIL_RESULT8) )
        elseif resultCode == 9 then LabelSetText(labelName, GetMailString( StringTables.Mail.TEXT_MAIL_RESULT9) )
        elseif resultCode ==10 then LabelSetText(labelName, GetMailString( StringTables.Mail.TEXT_MAIL_RESULT10) )
        elseif resultCode ==11 then LabelSetText(labelName, GetMailString( StringTables.Mail.TEXT_MAIL_RESULT11) )
        elseif resultCode ==12 then LabelSetText(labelName, GetMailString( StringTables.Mail.TEXT_MAIL_RESULT12) )
        elseif resultCode ==13 then LabelSetText(labelName, GetMailString( StringTables.Mail.TEXT_MAIL_RESULT13) )
        elseif resultCode ==14 then LabelSetText(labelName, GetMailString( StringTables.Mail.TEXT_MAIL_RESULT14) )
        elseif resultCode ==15 then LabelSetText(labelName, GetMailString( StringTables.Mail.TEXT_MAIL_RESULT15) )
        elseif resultCode ==16 then LabelSetText(labelName, GetMailString( StringTables.Mail.TEXT_MAIL_RESULT16) ) 
        elseif resultCode ==17 then LabelSetText(labelName, GetMailString( StringTables.Mail.TEXT_MAIL_RESULT17) )
        elseif resultCode ==18 then LabelSetText(labelName, GetMailString( StringTables.Mail.TEXT_MAIL_RESULT18) )
    end
end