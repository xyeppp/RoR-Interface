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

	--[[
	LiveEvents.autoGuildEvents[1] = {}
	LiveEvents.autoGuildEvents[1].appointmentID				= 0
	LiveEvents.autoGuildEvents[1].guildID					= -1
	LiveEvents.autoGuildEvents[1].creatorID					= -1
	LiveEvents.autoGuildEvents[1].creatorName				= GetStringFromTable("LiveEventStrings", StringTables.LiveEventStrings.TEXT_CALENDAR_SYSTEM_EVENT_CREATOR_NAME)
	LiveEvents.autoGuildEvents[1].bIsPlayersEvent			= false
	LiveEvents.autoGuildEvents[1].subject					= GetStringFromTable("LiveEventStrings", StringTables.LiveEventStrings.TEXT_CALENDAR_SYSTEM_EVENT_NAME_KEG_END)
	LiveEvents.autoGuildEvents[1].details					= GetStringFromTable("LiveEventStrings", StringTables.LiveEventStrings.TEXT_CALENDAR_SYSTEM_EVENT_DESC_KEG_END)
	LiveEvents.autoGuildEvents[1].locked					= true
	LiveEvents.autoGuildEvents[1].shared					= false

	LiveEvents.autoGuildEvents[1].startMonth				= 12
	LiveEvents.autoGuildEvents[1].startDay					= 22
	LiveEvents.autoGuildEvents[1].startYear					= 2018
	LiveEvents.autoGuildEvents[1].startHour					= 8
	LiveEvents.autoGuildEvents[1].startMinute				= 0
															-- GetTimeStamp params: (Month, Day, Year, Hour, Minute)
	LiveEvents.autoGuildEvents[1].startTime					= GetTimeStamp(LiveEvents.autoGuildEvents[1].startMonth, LiveEvents.autoGuildEvents[1].startDay, LiveEvents.autoGuildEvents[1].startYear, LiveEvents.autoGuildEvents[1].startHour, LiveEvents.autoGuildEvents[1].startMinute)
	LiveEvents.autoGuildEvents[1].startDayString			= StringUtils.FormatDateString(LiveEvents.autoGuildEvents[1].startMonth, LiveEvents.autoGuildEvents[1].startDay, LiveEvents.autoGuildEvents[1].startYear)
	LiveEvents.autoGuildEvents[1].startTimeString			= StringUtils.FormatTimeString(LiveEvents.autoGuildEvents[1].startHour, LiveEvents.autoGuildEvents[1].startMinute)

	LiveEvents.autoGuildEvents[1].endMonth					= 1
	LiveEvents.autoGuildEvents[1].endDay					= 5
	LiveEvents.autoGuildEvents[1].endYear					= 2019
	LiveEvents.autoGuildEvents[1].endHour					= 8
	LiveEvents.autoGuildEvents[1].endMinute					= 0

    LiveEvents.autoGuildEvents[1].endTime					= GetTimeStamp(LiveEvents.autoGuildEvents[1].endMonth, LiveEvents.autoGuildEvents[1].endDay, LiveEvents.autoGuildEvents[1].endYear, LiveEvents.autoGuildEvents[1].endHour, LiveEvents.autoGuildEvents[1].endMinute)
	LiveEvents.autoGuildEvents[1].endDayString				= StringUtils.FormatDateString(LiveEvents.autoGuildEvents[1].endMonth, LiveEvents.autoGuildEvents[1].endDay, LiveEvents.autoGuildEvents[1].endYear)
	LiveEvents.autoGuildEvents[1].endTimeString				= StringUtils.FormatTimeString(LiveEvents.autoGuildEvents[1].endHour, LiveEvents.autoGuildEvents[1].endMinute)
	--]]
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
