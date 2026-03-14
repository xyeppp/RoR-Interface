----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

LiveEvents = {}
LiveEvents.savedVariables = {}

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

-- OnInitialize Handler
function LiveEvents.Initialize()
	LiveEvents.InitializeAutoEvents()
end

-- OnShutDown Handler
function LiveEvents.Shutdown()
end

function LiveEvents.InitializeAutoEvents()
	-- NOTE: These Guild Events are auto-generated client side only. The server knows nothing about them.
	LiveEvents.autoGuildEvents = {}
end

function LiveEvents.CreateAutoEvents()
    if not GuildWindowTabCalendar
    then
        return
    end

	-- Ensure Guild is high enough rank for calendar events
	if GameData.Guild.m_GuildRank < GuildWindowTabCalendar.RankUnlocked then
		return
	end

	local bEventExists = false
	local eventName = L""
	local prefixString = GetStringFromTable("LiveEventStrings", StringTables.LiveEventStrings.TEXT_CALENDAR_SYSTEM_EVENT_NAME_PREFIX)

	-- Loop through all our auto appointments
	for autoEventIndex, autoAppointmentData in ipairs(LiveEvents.autoGuildEvents) do
		bEventExists = false

		-- Loop through all our existing appointments
		for index, data in ipairs(GuildWindowTabCalendar.appointmentListData) do
			eventName = prefixString..L" "..autoAppointmentData.subject
			-- Check to make sure the event hasn't already been created
			if (WStringsCompare(eventName, data.subject) == 0) then
				bEventExists = true
			end
		end

		if bEventExists == false then
			table.insert( GuildWindowTabCalendar.appointmentListData, #GuildWindowTabCalendar.appointmentListData+1, autoAppointmentData)
		end
	end
end
