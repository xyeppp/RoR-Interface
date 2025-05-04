----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------
MailWindowTabPending = {}

MailWindowTabPending.listData = nil

----------------------------------------------------------------
-- Global Functions
----------------------------------------------------------------
function MailWindowTabPending.Initialize()
	ButtonSetText("MailWindowTabPendingOpenMessageButton", L"OPEN")
	MailWindowTabPending.LoadHeaders()
end

function MailWindowTabPending.Shutdown()
end

function MailWindowTabPending.Populate()
	MailWindow.UpdateDisplayingHeadersText()
end

function MailWindowTabPending.ApplyFilters()
	MailWindowTabPending.listDataOrder = {}

	table.sort(MailWindowTabPending.listData, MailWindowTabPending.DefaultSort)
	
	--table.insert(MailWindowTabPending.listDataOrder, index)

	ListBoxSetDisplayOrder("MailWindowTabPendingList", MailWindowTabPending.listDataOrder)
end

function MailWindowTabPending.LoadHeaders()
	MailWindowTabPending.listData = {}

	--MailWindowTabPending.listData[1] = {}
	--MailWindowTabInbox.listData[1].messageID = 0

	MailWindowTabPending.ApplyFilters()
	MailWindowTabPending.Populate()

	MailWindow.UpdateDisplayingHeadersText()
end


function MailWindowTabPending.DefaultSort(a, b)
   return false
end
