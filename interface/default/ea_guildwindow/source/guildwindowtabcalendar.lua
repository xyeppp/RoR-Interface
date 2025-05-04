GuildWindowTabCalendar = {}

GuildWindowTabCalendar.RankUnlocked = 2

GuildWindowTabCalendar.MAX_EVENTS = 10

GuildWindowTabCalendar.appointmentListData = {}
GuildWindowTabCalendar.appointmentListOrder = {}

GuildWindowTabCalendar.signupListData = {}
GuildWindowTabCalendar.signupListOrder = {}

GuildWindowTabCalendar.SelectedAppointmentIndex = 0
GuildWindowTabCalendar.SelectedSignupMemberIndex = 0

-- Note: These indices MUST MATCH those used in war_interface::LuaSendGuildAppointmentData
GuildWindowTabCalendar.APPOINTMENT_ADD					= 1
GuildWindowTabCalendar.APPOINTMENT_EDIT					= 2
GuildWindowTabCalendar.APPOINTMENT_DELETE				= 3
GuildWindowTabCalendar.APPOINTMENT_SIGNUP				= 4
GuildWindowTabCalendar.APPOINTMENT_LEAVE				= 5
GuildWindowTabCalendar.APPOINTMENT_KICK					= 6
GuildWindowTabCalendar.APPOINTMENT_FLAG_ATTENDANCE		= 7
GuildWindowTabCalendar.APPOINTMENT_VIEW					= 8

GuildWindowTabCalendar.Appointment_Mode					= 0		-- Used to determine if we are adding a new appointment or editing an existing one.

GuildWindowTabCalendar.SORT_ORDER_UP		= 1
GuildWindowTabCalendar.SORT_ORDER_DOWN	    = 2

GuildWindowTabCalendar.SORT_BUTTON_NAME		= 1
GuildWindowTabCalendar.SORT_BUTTON_STATUS	= 2
GuildWindowTabCalendar.SORT_MAX_NUMBER		= 2

GuildWindowTabCalendar.SortButtons = {} 
GuildWindowTabCalendar.SortButtons[ GuildWindowTabCalendar.SORT_BUTTON_NAME  ]	= { buttonName = "GWCalendarSelectedAppointmentSignupsSortBarNameButton",	label=StringTables.Guild.BUTTON_CALENDAR_SIGNUPS_SORT_NAME,	tooltip=StringTables.Guild.TOOLTIP_CALENDAR_SIGNUPS_SORT_NAME }
GuildWindowTabCalendar.SortButtons[ GuildWindowTabCalendar.SORT_BUTTON_STATUS ]	= { buttonName = "GWCalendarSelectedAppointmentSignupsSortBarStatusButton",	label=StringTables.Guild.BUTTON_CALENDAR_SIGNUPS_SORT_STATUS,tooltip=StringTables.Guild.TOOLTIP_CALENDAR_SIGNUPS_SORT_STATUS }

GuildWindowTabCalendar.sortSignups = { type=GuildWindowTabCalendar.SORT_BUTTON_NAME, order=GuildWindowTabCalendar.SORT_ORDER_UP }

local YEAR_COMBO_BOX_OFFSET = Calendar.MIN_YEAR - 1

local CHECKBOX_CHECKED_ICON = 57
local CHECKBOX_UNCHECKED_ICON = 58
local CHECKED_STRING = L"<icon"..CHECKBOX_CHECKED_ICON..L">  "
local UNCHECKED_STRING = L"<icon"..CHECKBOX_UNCHECKED_ICON..L">  "

local FILTER_GUILD = 1
local FILTER_ALLIANCE = 2
local FILTER_SERVER = 3
GuildWindowTabCalendar.EventFilters = {
    [FILTER_GUILD] = { active=true, stringId=StringTables.Guild.GUILD_CALENDAR_FILTERS_GUILD },
    [FILTER_ALLIANCE] = { active=true, stringId=StringTables.Guild.GUILD_CALENDAR_FILTERS_ALLIANCE },
    [FILTER_SERVER] = { active=true, stringId=StringTables.Guild.GUILD_CALENDAR_FILTERS_SERVER }
}

--------------------------------------------------------------------
-- Local Functions for Signups
--------------------------------------------------------------------
local function FilterSignupList()
    GuildWindowTabCalendar.signupListOrder = {}
    for dataIndex, data in ipairs( GuildWindowTabCalendar.signupListData ) do
        table.insert(GuildWindowTabCalendar.signupListOrder, dataIndex)
    end
end

local function CompareSignups( index1, index2 )

    if (index2 == nil) then
        return false
    end

    local signedUpMember1 = GuildWindowTabCalendar.signupListData[index1]
    local signedUpMember2 = GuildWindowTabCalendar.signupListData[index2]

    -- Sorting by Name
    if( GuildWindowTabCalendar.sortSignups.type == GuildWindowTabCalendar.SORT_BUTTON_NAME ) then
        if( GuildWindowTabCalendar.sortSignups.order == GuildWindowTabCalendar.SORT_ORDER_UP ) then
            return ( WStringsCompare(signedUpMember1.name, signedUpMember2.name) < 0 )
        else
            return ( WStringsCompare(signedUpMember1.name, signedUpMember2.name) > 0 )
        end
    end

     -- Sorting By Status
    if( GuildWindowTabCalendar.sortSignups.type == GuildWindowTabCalendar.SORT_BUTTON_STATUS )then
        if (signedUpMember1.accepted == signedUpMember2.accepted) then	-- if they match, then sort alphabetically)
            return ( WStringsCompare(signedUpMember1.name, signedUpMember2.name) < 0 )
        end

        if( GuildWindowTabCalendar.sortSignups.order == GuildWindowTabRoster.SORT_ORDER_UP ) then
            return ( signedUpMember1.accepted < signedUpMember2.accepted )
        else
            return ( signedUpMember1.accepted > signedUpMember2.accepted )
        end
    end

end

local function SortSignupList()
    table.sort( GuildWindowTabCalendar.signupListOrder, CompareSignups )
end

local function InitSignupListData()

    GuildWindowTabCalendar.signupListData = {}
    if( not GuildWindowTabCalendar.appointmentListData or
        not GuildWindowTabCalendar.appointmentListData[GuildWindowTabCalendar.SelectedAppointmentIndex] or
        not GuildWindowTabCalendar.appointmentListData[GuildWindowTabCalendar.SelectedAppointmentIndex].appointmentID or
        GuildWindowTabCalendar.appointmentListData[GuildWindowTabCalendar.SelectedAppointmentIndex].guildID ~= GameData.Guild.m_GuildID )
    then
        return
    end
    
    local signupData = GetGuildSignupData(GuildWindowTabCalendar.appointmentListData[GuildWindowTabCalendar.SelectedAppointmentIndex].appointmentID)
    local LocalPlayerIsAlreadySignedUp = false
    
    if( signupData == nil ) then
        DEBUG(L"SignupData == nil")
        return
    end

    for key, value in ipairs( signupData ) do
        -- These should match the data that was retrieved from war_interface::GetGuildSignupData
        GuildWindowTabCalendar.signupListData[key] = {}
  	local icon = L""

		for index, memberData in ipairs(GuildWindowTabRoster.memberListData) do
			if memberData.memberID == value.memberID then
				 icon = L"<icon"..towstring(Icons.GetCareerIconIDFromCareerNamesID(tonumber(memberData.careerID)))..L">" or L""
			end
		end
 	
	
        GuildWindowTabCalendar.signupListData[key].name = icon..value.name
        GuildWindowTabCalendar.signupListData[key].rank = value.rank
		GuildWindowTabCalendar.signupListData[key].accepted = value.accepted

        GuildWindowTabCalendar.signupListData[key].memberID = value.memberID
    end

end

local function GetMilitaryTime( hours, isPM )
    if( isPM )
    then
        hours = hours + 12
        if( hours >= 24 )
        then
            hours = 12
        end
    elseif( hours == 12 )
    then
        hours = 0
    end
    return hours
end

----------------------------------------
-- Window Handling Functions
----------------------------------------
function GuildWindowTabCalendar.Initialize()

	GuildWindowTabCalendar.InitializeSortButtons()
	GuildWindowTabCalendar.InitializeEventFilters()

	LabelSetText( "GWCalendarNewAppointmentLockSignupHeader", GetGuildString(StringTables.Guild.HEADER_GUILD_CALENDAR_LOCK_SIGNUP) )
	LabelSetText( "GWCalendarNewAppointmentShareHeader", GetGuildString(StringTables.Guild.HEADER_GUILD_CALENDAR_SHARE_WITH_ALLIANCES) )

	LabelSetText( "GWCalendarNewAppointmentStartTimeHeader", GetGuildString(StringTables.Guild.HEADER_GUILD_CALENDAR_START_TIME) )
	LabelSetText( "GWCalendarNewAppointmentEndTimeHeader", GetGuildString(StringTables.Guild.HEADER_GUILD_CALENDAR_END_TIME) )
	LabelSetText( "GWCalendarNewAppointmentStartTimeAtHeader", GetGuildString(StringTables.Guild.HEADER_GUILD_CALENDAR_AT) )
	LabelSetText( "GWCalendarNewAppointmentEndTimeAtHeader", GetGuildString(StringTables.Guild.HEADER_GUILD_CALENDAR_AT) )

	LabelSetText( "GWCalendarSelectedAppointmentCreatorHeader", GetGuildString(StringTables.Guild.HEADER_GUILD_CALENDAR_CREATOR) )
	LabelSetText( "GWCalendarSelectedAppointmentStartDateHeader", GetGuildString(StringTables.Guild.HEADER_GUILD_CALENDAR_START) )
	LabelSetText( "GWCalendarSelectedAppointmentEndDateHeader", GetGuildString(StringTables.Guild.HEADER_GUILD_CALENDAR_END) )
	LabelSetText( "GWCalendarSelectedAppointmentShareHeader", GetGuildString(StringTables.Guild.HEADER_GUILD_CALENDAR_SHARED_WITH_ALLIANCES) )

	ButtonSetText( "GWCalendarNewAppointmentButton", GetGuildString(StringTables.Guild.BUTTON_CALENDAR_NEW) )
	ButtonSetText( "GWCalendarNewAppointmentCancelButton", GetGuildString(StringTables.Guild.BUTTON_CALENDAR_CANCEL) )
	ButtonSetText( "GWCalendarNewAppointmentCreateButton", GetGuildString(StringTables.Guild.BUTTON_CALENDAR_CREATE) )

	ButtonSetText( "GWCalendarSelectedAppointmentBackButton", GetGuildString(StringTables.Guild.BUTTON_CALENDAR_BACK) )
	ButtonSetText( "GWCalendarSelectedAppointmentSignupButton", GetGuildString(StringTables.Guild.BUTTON_CALENDAR_SIGNUP) )
	ButtonSetText( "GWCalendarSelectedAppointmentLeaveButton", GetGuildString(StringTables.Guild.BUTTON_CALENDAR_LEAVE) )

	ButtonSetText( "GWCalendarSelectedAppointmentEditButton", GetGuildString(StringTables.Guild.BUTTON_CALENDAR_EDIT) )
	ButtonSetText( "GWCalendarSelectedAppointmentDeleteButton", GetGuildString(StringTables.Guild.BUTTON_CALENDAR_DELETE) )

	ButtonSetCheckButtonFlag("GWCalendarNewAppointmentLockSignupCheckBox", true)
	ButtonSetCheckButtonFlag("GWCalendarNewAppointmentShareCheckBox", true)

	Calendar.SetTodaysDate()

	GuildWindowTabCalendar.SetListRowTints()
	GuildWindowTabCalendar.SetSignupListRowTints()
	GuildWindowTabCalendar.SetAppointmentMode(0)
	GuildWindowTabCalendar.InitializeComboBoxes()

	WindowRegisterEventHandler( "GuildWindowTabCalendar", SystemData.Events.GUILD_APPOINTMENTS_UPDATED, "GuildWindowTabCalendar.OnAppointmentsUpdated")
	WindowRegisterEventHandler( "GuildWindowTabCalendar", SystemData.Events.PLAYER_INFO_CHANGED, "GuildWindowTabCalendar.OnPlayerInfoChanged")
	WindowRegisterEventHandler( "GuildWindowTabCalendar", SystemData.Events.GUILD_MEMBER_UPDATED, "GuildWindowTabCalendar.OnPlayerInfoChanged")
end

-- Sets the button text for each sort button
function GuildWindowTabCalendar.InitializeSortButtons()
    for colNumber, data in ipairs(GuildWindowTabCalendar.SortButtons) do
		ButtonSetText(data.buttonName, GetGuildString(data.label))
    end
end

function GuildWindowTabCalendar.InitializeEventFilters()
    local filterComboBox = "GWCalendarFiltersFilterComboBox"
    ComboBoxClearMenuItems( filterComboBox )
    
    for _, data in ipairs( GuildWindowTabCalendar.EventFilters )
    do
        if( data.active )
        then
            ComboBoxAddMenuItem( filterComboBox, CHECKED_STRING..GetGuildString(data.stringId) )
        else
            ComboBoxAddMenuItem( filterComboBox, UNCHECKED_STRING..GetGuildString(data.stringId) )
        end
    end

    ButtonSetText( filterComboBox.."SelectedButton", GetGuildString(StringTables.Guild.HEADER_GUILD_CALENDAR_FILTERS) )

end

function GuildWindowTabCalendar.OnClose()
    GuildWindowTabCalendar.ResetEditBoxes()	-- Clear the edit box texts and any focus these edit boxes may have
	--GuildWindowTabCalendar.SetFocus(false)
end

function GuildWindowTabCalendar.Shutdown()
end

function GuildWindowTabCalendar.OnAppointmentsUpdated()
	GuildWindowTabCalendar.UpdateAppointmentList()
	GuildWindowTabCalendar.UpdateSignupList()
	GuildWindowTabCalendar.SetDayTints()
end

----------------------------------------
-- Helper Functions
----------------------------------------

-- This function clears, fills in, and assigns all the combo boxes which appear in the new / edit window. 
-- The Parameter, appointmentID, is used to determine if we should assign the combo box to the defaults(new), or use an existing appointmentID
-- The other params specify if we're creating a new event based on the selected calendar day. 
function GuildWindowTabCalendar.SetComboBoxes(appointmentID, bStartDate, bEndDate, selectedMonth, selectedDay, selectedYear)
    
	if bStartDate ~= nil and bStartDate == true then
		ComboBoxSetSelectedMenuItem("GWCalendarNewAppointmentStartTimeMonthComboBox", selectedMonth)
		ComboBoxSetSelectedMenuItem("GWCalendarNewAppointmentStartTimeDayComboBox", selectedDay)
		ComboBoxSetSelectedMenuItem("GWCalendarNewAppointmentStartTimeYearComboBox", selectedYear - YEAR_COMBO_BOX_OFFSET)
		ComboBoxSetSelectedMenuItem("GWCalendarNewAppointmentStartTimeHourComboBox", 12)
		ComboBoxSetSelectedMenuItem("GWCalendarNewAppointmentStartTimeMinuteComboBox", 1)
		ComboBoxSetSelectedMenuItem("GWCalendarNewAppointmentStartTimeAMPMComboBox", 2)
	end

	if bEndDate ~= nil and bEndDate == true then
		ComboBoxSetSelectedMenuItem("GWCalendarNewAppointmentEndTimeMonthComboBox", selectedMonth)
		ComboBoxSetSelectedMenuItem("GWCalendarNewAppointmentEndTimeDayComboBox", selectedDay)
		ComboBoxSetSelectedMenuItem("GWCalendarNewAppointmentEndTimeYearComboBox", selectedYear - YEAR_COMBO_BOX_OFFSET)
		ComboBoxSetSelectedMenuItem("GWCalendarNewAppointmentEndTimeHourComboBox", 12)
		ComboBoxSetSelectedMenuItem("GWCalendarNewAppointmentEndTimeMinuteComboBox", 1)
		ComboBoxSetSelectedMenuItem("GWCalendarNewAppointmentEndTimeAMPMComboBox", 2)
	end

	if appointmentID ~= nil and appointmentID > 0 then
		ComboBoxSetSelectedMenuItem("GWCalendarNewAppointmentStartTimeMonthComboBox", GuildWindowTabCalendar.appointmentListData[appointmentID].startMonth)
		ComboBoxSetSelectedMenuItem("GWCalendarNewAppointmentEndTimeMonthComboBox", GuildWindowTabCalendar.appointmentListData[appointmentID].endMonth)

		ComboBoxSetSelectedMenuItem("GWCalendarNewAppointmentStartTimeYearComboBox", GuildWindowTabCalendar.appointmentListData[appointmentID].startYear - YEAR_COMBO_BOX_OFFSET)
		ComboBoxSetSelectedMenuItem("GWCalendarNewAppointmentEndTimeYearComboBox", GuildWindowTabCalendar.appointmentListData[appointmentID].endYear - YEAR_COMBO_BOX_OFFSET)

		-- The minutes are saved in increments of 5 (00, 05, 10, 15, 20... 55), so we have to reduce that into an index within the combo box.
		ComboBoxSetSelectedMenuItem("GWCalendarNewAppointmentStartTimeMinuteComboBox", GuildWindowTabCalendar.appointmentListData[appointmentID].startMinute / 5 + 1 )
		ComboBoxSetSelectedMenuItem("GWCalendarNewAppointmentEndTimeMinuteComboBox", GuildWindowTabCalendar.appointmentListData[appointmentID].endMinute / 5 + 1)

		-- The hour and minute is stored in military time (0000..2359). There is no storage of AMPM, so we have to adjust for the hour and the AMPM manually
		if GuildWindowTabCalendar.appointmentListData[appointmentID].startHour > 12 then
			ComboBoxSetSelectedMenuItem("GWCalendarNewAppointmentStartTimeHourComboBox", GuildWindowTabCalendar.appointmentListData[appointmentID].startHour-12)
			ComboBoxSetSelectedMenuItem("GWCalendarNewAppointmentStartTimeAMPMComboBox", 2)
		else
            local hour = GuildWindowTabCalendar.appointmentListData[appointmentID].startHour
            local am_pm = 1
		    if( hour == 0 )
		    then
		        hour = 12
		    elseif( hour == 12 )
		    then
		        am_pm = 2
		    end
			ComboBoxSetSelectedMenuItem("GWCalendarNewAppointmentStartTimeHourComboBox", hour)
			ComboBoxSetSelectedMenuItem("GWCalendarNewAppointmentStartTimeAMPMComboBox", am_pm)
		end

		if GuildWindowTabCalendar.appointmentListData[appointmentID].endHour > 12 then
			ComboBoxSetSelectedMenuItem("GWCalendarNewAppointmentEndTimeHourComboBox", GuildWindowTabCalendar.appointmentListData[appointmentID].endHour-12)
			ComboBoxSetSelectedMenuItem("GWCalendarNewAppointmentEndTimeAMPMComboBox", 2)
		else
		    local hour = GuildWindowTabCalendar.appointmentListData[appointmentID].endHour
            local am_pm = 1
		    if( hour == 0 )
		    then
		        hour = 12
		    elseif( hour == 12 )
		    then
		        am_pm = 2
		    end
			ComboBoxSetSelectedMenuItem("GWCalendarNewAppointmentEndTimeHourComboBox", hour)
			ComboBoxSetSelectedMenuItem("GWCalendarNewAppointmentEndTimeAMPMComboBox", am_pm)
		end

		ComboBoxSetSelectedMenuItem("GWCalendarNewAppointmentStartTimeDayComboBox", GuildWindowTabCalendar.appointmentListData[appointmentID].startDay)
		ComboBoxSetSelectedMenuItem("GWCalendarNewAppointmentEndTimeDayComboBox", GuildWindowTabCalendar.appointmentListData[appointmentID].endDay)
	end
end

-- This function clears and populates the combo boxes with data. It calls another function to assign display values.
function GuildWindowTabCalendar.InitializeComboBoxes(appointmentID)

	if appointmentID == nil then
		appointmentID = 0
	end

-- Month
    ComboBoxClearMenuItems("GWCalendarNewAppointmentStartTimeMonthComboBox")
	ComboBoxClearMenuItems("GWCalendarNewAppointmentEndTimeMonthComboBox")

    for month = 0, 11 do	-- In order to index the string table, we subtract 1 from the normal range 1..12
        ComboBoxAddMenuItem( "GWCalendarNewAppointmentStartTimeMonthComboBox", GetGuildString(StringTables.Guild.DATE_MONTH_ABBREVIATED_1 + month) )
		ComboBoxAddMenuItem( "GWCalendarNewAppointmentEndTimeMonthComboBox", GetGuildString(StringTables.Guild.DATE_MONTH_ABBREVIATED_1 + month) )
    end

-- Year
    ComboBoxClearMenuItems("GWCalendarNewAppointmentStartTimeYearComboBox")
	ComboBoxClearMenuItems("GWCalendarNewAppointmentEndTimeYearComboBox")

    for year = Calendar.MIN_YEAR, Calendar.MAX_YEAR do
        ComboBoxAddMenuItem( "GWCalendarNewAppointmentStartTimeYearComboBox", L""..year )
		ComboBoxAddMenuItem( "GWCalendarNewAppointmentEndTimeYearComboBox", L""..year )
    end

-- Hour
    ComboBoxClearMenuItems("GWCalendarNewAppointmentStartTimeHourComboBox")
	ComboBoxClearMenuItems("GWCalendarNewAppointmentEndTimeHourComboBox")

    for hour = 1, 12 do
        ComboBoxAddMenuItem( "GWCalendarNewAppointmentStartTimeHourComboBox", L""..hour )
		ComboBoxAddMenuItem( "GWCalendarNewAppointmentEndTimeHourComboBox", L""..hour )
    end

-- Minute
    ComboBoxClearMenuItems("GWCalendarNewAppointmentStartTimeMinuteComboBox")
	ComboBoxClearMenuItems("GWCalendarNewAppointmentEndTimeMinuteComboBox")

	ComboBoxAddMenuItem( "GWCalendarNewAppointmentStartTimeMinuteComboBox", L"00" )
	ComboBoxAddMenuItem( "GWCalendarNewAppointmentEndTimeMinuteComboBox", L"00")
	ComboBoxAddMenuItem( "GWCalendarNewAppointmentStartTimeMinuteComboBox", L"05" )
	ComboBoxAddMenuItem( "GWCalendarNewAppointmentEndTimeMinuteComboBox", L"05")

    for minute = 2, 11 do
        ComboBoxAddMenuItem( "GWCalendarNewAppointmentStartTimeMinuteComboBox", L""..minute * 5 )
		ComboBoxAddMenuItem( "GWCalendarNewAppointmentEndTimeMinuteComboBox", L""..minute * 5)
    end

-- AMPM
    ComboBoxClearMenuItems("GWCalendarNewAppointmentStartTimeAMPMComboBox")
	ComboBoxClearMenuItems("GWCalendarNewAppointmentEndTimeAMPMComboBox")

    for ampm = 0, 1 do	-- In order to index the string table, we subtract 1 from the normal range 1..2
        ComboBoxAddMenuItem( "GWCalendarNewAppointmentStartTimeAMPMComboBox", GetGuildString(StringTables.Guild.LABEL_CALENDAR_AM + ampm) )
		ComboBoxAddMenuItem( "GWCalendarNewAppointmentEndTimeAMPMComboBox", GetGuildString(StringTables.Guild.LABEL_CALENDAR_AM + ampm) )
    end
    
    ComboBoxSetSelectedMenuItem( "GWCalendarNewAppointmentStartTimeMonthComboBox",  Calendar.todaysMonth )
    ComboBoxSetSelectedMenuItem( "GWCalendarNewAppointmentStartTimeYearComboBox", Calendar.todaysYear - YEAR_COMBO_BOX_OFFSET )
    ComboBoxSetSelectedMenuItem( "GWCalendarNewAppointmentEndTimeMonthComboBox", Calendar.todaysMonth )
    ComboBoxSetSelectedMenuItem( "GWCalendarNewAppointmentEndTimeYearComboBox", Calendar.todaysYear - YEAR_COMBO_BOX_OFFSET )

	GuildWindowTabCalendar.UpdateComboBoxStartDay()
	GuildWindowTabCalendar.UpdateComboBoxEndDay()

	GuildWindowTabCalendar.SetComboBoxes(appointmentID)
end

function GuildWindowTabCalendar.UpdateComboBoxStartDay(selection)
	local month = ComboBoxGetSelectedMenuItem("GWCalendarNewAppointmentStartTimeMonthComboBox")
	local year	= ComboBoxGetSelectedMenuItem("GWCalendarNewAppointmentStartTimeYearComboBox") + YEAR_COMBO_BOX_OFFSET
	local previousEntry = ComboBoxGetSelectedMenuItem("GWCalendarNewAppointmentStartTimeMonthComboBox")

	local maxDaysInMonthAndYear = Calendar.GetNumberOfDaysInMonth(month, year)

    ComboBoxClearMenuItems("GWCalendarNewAppointmentStartTimeDayComboBox")

    for day = 1, maxDaysInMonthAndYear do
        ComboBoxAddMenuItem( "GWCalendarNewAppointmentStartTimeDayComboBox", L""..day )
    end

	if selection ~=nil and selection >0 then
		ComboBoxSetSelectedMenuItem("GWCalendarNewAppointmentStartTimeDayComboBox", selection)
    elseif previousEntry > maxDaysInMonthAndYear then	-- Restore the previously selected day, unless it doesn't exist in the select month/year
		ComboBoxSetSelectedMenuItem("GWCalendarNewAppointmentStartTimeDayComboBox", Calendar.todaysDay)
	else
		ComboBoxSetSelectedMenuItem("GWCalendarNewAppointmentStartTimeDayComboBox", previousEntry)
	end
end

function GuildWindowTabCalendar.UpdateComboBoxEndDay(selection)
	local month = ComboBoxGetSelectedMenuItem("GWCalendarNewAppointmentEndTimeMonthComboBox")
	local year	= ComboBoxGetSelectedMenuItem("GWCalendarNewAppointmentEndTimeYearComboBox") + YEAR_COMBO_BOX_OFFSET
	local previousEntry = ComboBoxGetSelectedMenuItem("GWCalendarNewAppointmentEndTimeDayComboBox")

	local maxDaysInMonthAndYear = Calendar.GetNumberOfDaysInMonth(month, year)

    ComboBoxClearMenuItems("GWCalendarNewAppointmentEndTimeDayComboBox")

    for day = 1, maxDaysInMonthAndYear do
        ComboBoxAddMenuItem( "GWCalendarNewAppointmentEndTimeDayComboBox", L""..day )
    end

    if selection ~=nil and selection >0 and selection <= maxDaysInMonthAndYear then		-- Choose the day that was selected from the combobox drop down
		ComboBoxSetSelectedMenuItem("GWCalendarNewAppointmentEndTimeDayComboBox", selection)
    elseif previousEntry > maxDaysInMonthAndYear then	-- Restore the previously selected day, unless it doesn't exist in the select month/year
		ComboBoxSetSelectedMenuItem("GWCalendarNewAppointmentEndTimeDayComboBox", maxDaysInMonthAndYear)
	else												-- Choose the day that was already selected
		ComboBoxSetSelectedMenuItem("GWCalendarNewAppointmentEndTimeDayComboBox", previousEntry)
	end
end

function GuildWindowTabCalendar.ResetEditBoxes(appointmentID)
	if appointmentID == nil or appointmentID == 0 then
		TextEditBoxSetText("GWCalendarNewAppointmentEventNameEditBox", GetGuildString(StringTables.Guild.HEADER_GUILD_CALENDAR_EVENT_NAME) ) -- Set the edit box to "Event Name"
		TextEditBoxSetText("GWCalendarNewAppointmentDescriptionEditBox", GetGuildString(StringTables.Guild.HEADER_GUILD_CALENDAR_DESCRIPTION) ) -- Set edit box to "Description"

		ButtonSetPressedFlag("GWCalendarNewAppointmentLockSignupCheckBox", false)
		ButtonSetPressedFlag("GWCalendarNewAppointmentShareCheckBox", false)
	else
		TextEditBoxSetText("GWCalendarNewAppointmentEventNameEditBox", GuildWindowTabCalendar.appointmentListData[appointmentID].subject)
		TextEditBoxSetText("GWCalendarNewAppointmentDescriptionEditBox", GuildWindowTabCalendar.appointmentListData[appointmentID].details)
	    
		ButtonSetPressedFlag("GWCalendarNewAppointmentLockSignupCheckBox", GuildWindowTabCalendar.appointmentListData[appointmentID].locked)
		ButtonSetPressedFlag("GWCalendarNewAppointmentShareCheckBox", GuildWindowTabCalendar.appointmentListData[appointmentID].shared)
	end
end

-- This function gets called when the user opens any of the Start or End time combo boxes and selects something new(be it month, day, year, etc)
function GuildWindowTabCalendar.OnSelChangedTime()
	local windowID = WindowGetId(SystemData.ActiveWindow.name)

	if windowID <= 6 then
		-- The user selected a combo box from the Start Time row. Ensure the other combo boxes update too (In case something is out of range)
		GuildWindowTabCalendar.UpdateComboBoxStartDay(ComboBoxGetSelectedMenuItem("GWCalendarNewAppointmentStartTimeDayComboBox") )
	else
		-- The user selected a combo box from the End Time row. Ensure the other combo boxes update too (In case something is out of range)
		GuildWindowTabCalendar.UpdateComboBoxEndDay(ComboBoxGetSelectedMenuItem("GWCalendarNewAppointmentEndTimeDayComboBox"))
	end
end

function GuildWindowTabCalendar.UpdateCalendarWatermark()
	local calendarUnlocked = (GameData.Guild.m_GuildRank >= GuildWindowTabCalendar.RankUnlocked)

	WindowSetShowing( "GuildWindowCalendar",				calendarUnlocked )
	WindowSetShowing( "GWCalendarFilters",					calendarUnlocked )
	WindowSetShowing( "GWCalendarNewAppointmentButton",		calendarUnlocked )
	WindowSetShowing( "GWCalendarAppointmentSeperator",		calendarUnlocked )
	WindowSetShowing( "GWCalendarAppointments",				calendarUnlocked )
	WindowSetShowing( "GWCalendarVertSeparator",            calendarUnlocked )
	WindowSetShowing( "GWCalendarTotalAppointments",        calendarUnlocked )
    if( calendarUnlocked )
    then
        GuildWindowTabCalendar.SetAppointmentMode(0)
        GuildWindowTabCalendar.UpdateAppointmentList()
    end

	WindowSetShowing( "GWCalendarLocked",					calendarUnlocked == false)

	if calendarUnlocked == false then
		LabelSetText("GWCalendarLockedText", GetFormatStringFromTable( "guildstrings", StringTables.Guild.TEXT_CALENDAR_UNLOCKS_AT_RANK_X, {GuildWindowTabCalendar.RankUnlocked} ) )
	end
end

function GuildWindowTabCalendar.SetListRowTints()
-- This function Tints the rows that are listed in the Guild Window Appointment Summary list
    for row = 1, GWCalendarAppointmentsList.numVisibleRows do
        local row_mod = math.mod(row, 2)
        color = DataUtils.GetAlternatingRowColor( row_mod )
        
        local targetRowWindow = "GWCalendarAppointmentsListRow"..row
        WindowSetTintColor(targetRowWindow.."RowBackground", color.r, color.g, color.b )
        WindowSetAlpha(targetRowWindow.."RowBackground", color.a )
    end
end

-- Returns 0 if no event exists on the passed in date; Otherwise returns the dataIndex into the table of events
function GuildWindowTabCalendar.DoesEventExist(month, day, year)

	local startTimeStamp = 0
	local endTimeStamp = 0
	local paramTimeStamp = GetTimeStamp(month, day, year, 12, 0)

	for dataIndex, data in ipairs(GuildWindowTabCalendar.appointmentListData) do
		startTimeStamp = GetTimeStamp(data.startMonth, data.startDay, data.startYear, 0, 0)
		endTimeStamp = GetTimeStamp(data.endMonth, data.endDay, data.endYear, 23, 59)
		
		if paramTimeStamp >= startTimeStamp and paramTimeStamp <= endTimeStamp then
			return dataIndex
		end
	end

	return 0
end

function GuildWindowTabCalendar.SetDayTints()
-- This function loops through all the "day" windows in the Calendar and decides how each one should be tinted.

    -- Get the day that this month starts on.
    local firstDayOfMonth = Calendar.GetDayOfWeek( 1, Calendar.month, Calendar.year )

    -- Calculate where this first day is displayed based on the user's "first day of week" setting.
    local firstDayOfWeek = GetFirstDayOfWeek()
    local firstDayOffset = firstDayOfMonth - firstDayOfWeek
    if ( firstDayOffset < 0 )
    then
        firstDayOffset = firstDayOffset + 7
    end

    local targetRowWindow
    local appointmentDataIndex = 0
    local appointmentData = nil
	
    local filters = GuildWindowTabCalendar.EventFilters

    for day = 1, 42 do	-- 42 is the #of Day windows we have. (6 rows * 7 days/row) = 42 windows.
        appointmentDataIndex = 0
		appointmentData = nil
		
		targetDayWindow = "GuildWindowCalendarDay"..day

		-- If a day label is hidden, that means there's no actual day that falls on it. That means there's no event for it, so skip checking for one.
		-- Also, skip any days that are in the past.
		-- (For example, if the 1st falls on a Tuesday, then day 1 and day 2 are actually hidden and have no labels, and therefore no events)
		if (WindowGetShowing(targetDayWindow.."Text") == true) then
			appointmentDataIndex = GuildWindowTabCalendar.DoesEventExist(Calendar.month, day-firstDayOffset, Calendar.year)
			if appointmentDataIndex > 0 then
				appointmentData = GuildWindowTabCalendar.appointmentListData[appointmentDataIndex]
			end
		end

		-- For now, we no longer select calendar days
		--if (Calendar.selectedDayWindow == targetDayWindow) then					-- Highlight the day that was selected
		--	WindowSetTintColor(targetDayWindow.."Background", DefaultColor.Calendar.Day.TintColor.SELECTED.r, DefaultColor.Calendar.Day.TintColor.SELECTED.g, DefaultColor.Calendar.Day.TintColor.SELECTED.b )
		--	WindowSetAlpha(targetDayWindow.."Background", DefaultColor.Calendar.Day.TintColor.SELECTED.a )
		--else																	-- If there is an appointment, tint it
			if appointmentData ~= nil and appointmentData.guildID < 0 and filters[FILTER_SERVER].active -- Tint non-guild events Yellow
            then
				WindowSetTintColor(targetDayWindow.."Background", DefaultColor.YELLOW.r, DefaultColor.YELLOW.g, DefaultColor.YELLOW.b )
				WindowSetAlpha(targetDayWindow.."Background", DefaultColor.ChatChannelColors[SystemData.ChatLogFilters.GUILD].a )
			elseif appointmentData ~= nil and GameData.Guild.m_GuildID == appointmentData.guildID and filters[FILTER_GUILD].active -- Tint it the standard guild chat color
            then
				WindowSetTintColor(targetDayWindow.."Background", DefaultColor.ChatChannelColors[SystemData.ChatLogFilters.GUILD].r, DefaultColor.ChatChannelColors[SystemData.ChatLogFilters.GUILD].g, DefaultColor.ChatChannelColors[SystemData.ChatLogFilters.GUILD].b )
				WindowSetAlpha(targetDayWindow.."Background", DefaultColor.ChatChannelColors[SystemData.ChatLogFilters.GUILD].a )
			elseif appointmentData ~= nil and appointmentData.guildID > 0 and GameData.Guild.m_GuildID ~= appointmentData.guildID and filters[FILTER_ALLIANCE].active -- Tint it the standard alliance chat color
			then
				WindowSetTintColor(targetDayWindow.."Background", DefaultColor.ChatChannelColors[SystemData.ChatLogFilters.ALLIANCE].r, DefaultColor.ChatChannelColors[SystemData.ChatLogFilters.ALLIANCE].g, DefaultColor.ChatChannelColors[SystemData.ChatLogFilters.ALLIANCE].b )
				WindowSetAlpha(targetDayWindow.."Background", DefaultColor.ChatChannelColors[SystemData.ChatLogFilters.ALLIANCE].a )
			else
				WindowSetTintColor(targetDayWindow.."Background", 255, 255, 255 )
				WindowSetAlpha(targetDayWindow.."Background", 0 )
			end
		--end
    end	
end

-------------------------------------
-- Calendar Commands
-------------------------------------

-- This function shows the components for creating a new appointment and hides any other components
function GuildWindowTabCalendar.CalendarCommandNewAppointment()
	if ButtonGetDisabledFlag("GWCalendarNewAppointmentButton") == true then
		return
	end

	GuildWindowTabCalendar.SetAppointmentMode(GuildWindowTabCalendar.APPOINTMENT_ADD)
	GuildWindowTabCalendar.SetComboBoxes(0, true, true, Calendar.todaysMonth, Calendar.todaysDay, Calendar.todaysYear)
end

function GuildWindowTabCalendar.OnLButtonUpCalendarCommandNewAppointmentCreateButton()

	local appointmentID = 0
	local guildID = 0

	if GuildWindowTabCalendar.SelectedAppointmentIndex > 0 then
		appointmentID = GuildWindowTabCalendar.appointmentListData[GuildWindowTabCalendar.SelectedAppointmentIndex].appointmentID
		guildID = GuildWindowTabCalendar.appointmentListData[GuildWindowTabCalendar.SelectedAppointmentIndex].guildID
	end

    local startHour = GetMilitaryTime( ComboBoxGetSelectedMenuItem("GWCalendarNewAppointmentStartTimeHourComboBox"),
                                       ComboBoxGetSelectedMenuItem("GWCalendarNewAppointmentStartTimeAMPMComboBox") == 2 )
    local endHour = GetMilitaryTime( ComboBoxGetSelectedMenuItem("GWCalendarNewAppointmentEndTimeHourComboBox"),
                                     ComboBoxGetSelectedMenuItem("GWCalendarNewAppointmentEndTimeAMPMComboBox") == 2 )
                                     
    SendGuildAppointmentData(
        GuildWindowTabCalendar.Appointment_Mode,				-- Param 0
        appointmentID,	-- Param 1	AppointmentID
        guildID,		-- Param 2	GuildID
        0,		-- Param 3	MemberID
        ComboBoxGetSelectedMenuItem("GWCalendarNewAppointmentStartTimeMonthComboBox"),		-- Param 4 Start Month
		ComboBoxGetSelectedMenuItem("GWCalendarNewAppointmentStartTimeDayComboBox"),		-- Param 5 Start Day
		ComboBoxGetSelectedMenuItem("GWCalendarNewAppointmentStartTimeYearComboBox") + YEAR_COMBO_BOX_OFFSET,	-- Param 6 Start Year
		startHour,	                                                                    -- Param 7 Start Hour
		(ComboBoxGetSelectedMenuItem("GWCalendarNewAppointmentStartTimeMinuteComboBox")-1) * 5,	-- Param 8 Start Minute
        ComboBoxGetSelectedMenuItem("GWCalendarNewAppointmentStartTimeAMPMComboBox") -1,	-- Param 9 Start AMPM
        ComboBoxGetSelectedMenuItem("GWCalendarNewAppointmentEndTimeMonthComboBox"),		-- Param 10 End Month
		ComboBoxGetSelectedMenuItem("GWCalendarNewAppointmentEndTimeDayComboBox"),			-- Param 11 End Day
		ComboBoxGetSelectedMenuItem("GWCalendarNewAppointmentEndTimeYearComboBox") + YEAR_COMBO_BOX_OFFSET,	-- Param 12 End Year
		endHour,			                                                                -- Param 13 End Hour
		(ComboBoxGetSelectedMenuItem("GWCalendarNewAppointmentEndTimeMinuteComboBox")-1) * 5,	-- Param 14 End Minute
        ComboBoxGetSelectedMenuItem("GWCalendarNewAppointmentEndTimeAMPMComboBox") -1,		-- Param 15 End AMPM
        GWCalendarNewAppointmentEventNameEditBox.Text,										-- Param 16	The name of the event
        GWCalendarNewAppointmentDescriptionEditBox.Text,									-- Param 17 Event Description
        ButtonGetPressedFlag("GWCalendarNewAppointmentShareCheckBox"),						-- Param 18	True if event is shared with alliances
        ButtonGetPressedFlag("GWCalendarNewAppointmentLockSignupCheckBox")					-- Param 19 True if signups are locked
    )

	--GuildWindowTabCalendar.SetFocus(0)
    --GuildWindowTabCalendar.ShowSummaryComponents(true)

	-- Clear the edit boxes and go back to the default appointment mode
	GuildWindowTabCalendar.SetAppointmentMode(0)
end

-- There are 3 sets of window components in the Guild Calendar. 
--	1) The Event List. This is the default. It displays all the events in a single list.
--	2) The New / Edit Components. This shows the editboxes for creating a new appointment or editing an existing appointment.
--	3) The Selected Appointment. This shows the details of an appointment, as well as the Signup list for that selected appointment.
-- This function shows and hides the appropriate components depending on the passed param
function GuildWindowTabCalendar.SetAppointmentMode(mode)
	if mode == nil then
		mode = 0
	end
	GuildWindowTabCalendar.Appointment_Mode	= mode

	WindowSetShowing("GWCalendarAppointments", true) -- Always show
	WindowSetShowing("GWCalendarFilters", true ) -- Always show
	WindowSetShowing("GuildWindowCalendar", mode ~= GuildWindowTabCalendar.APPOINTMENT_VIEW ) -- Always show except when viewing a single appt
	WindowSetShowing("GWCalendarAppointmentSeperator", mode ~= GuildWindowTabCalendar.APPOINTMENT_VIEW ) -- Always show except when viewing a single appt
	WindowSetShowing("GWCalendarNewAppointment", mode == GuildWindowTabCalendar.APPOINTMENT_ADD or mode == GuildWindowTabCalendar.APPOINTMENT_EDIT)	-- Only show if creating or editing an Event
	WindowSetShowing("GWCalendarSelectedAppointment", mode == GuildWindowTabCalendar.APPOINTMENT_VIEW) -- Only show if viewing selected Event)
	WindowSetShowing("GWCalendarTotalAppointments", mode == 0 ) -- only show when not in a sub mode

	GuildWindowTabCalendar.UpdateButtons(GuildWindowTabCalendar.Appointment_Mode)

	-- The only time we need to clear the edit boxes is when we're creating a new event.
	if mode == GuildWindowTabCalendar.APPOINTMENT_ADD then
		GuildWindowTabCalendar.ResetEditBoxes()
	end

	-- If we aren't viewing or editing an appointment, then an event wasn't selected from the Event List. 
	if mode ~= GuildWindowTabCalendar.APPOINTMENT_VIEW and mode ~= GuildWindowTabCalendar.APPOINTMENT_EDIT then
		GuildWindowTabCalendar.SelectedAppointmentIndex = 0
	end	

	-- If we're editing an existing event, we need to populate all the comboboxes with the data from the event
	if mode == GuildWindowTabCalendar.APPOINTMENT_EDIT then
		GuildWindowTabCalendar.InitializeComboBoxes(GuildWindowTabCalendar.SelectedAppointmentIndex)
		GuildWindowTabCalendar.ResetEditBoxes(GuildWindowTabCalendar.SelectedAppointmentIndex)
		ButtonSetText( "GWCalendarNewAppointmentCreateButton", GetGuildString(StringTables.Guild.BUTTON_CALENDAR_SAVE) )
	else
		ButtonSetText( "GWCalendarNewAppointmentCreateButton", GetGuildString(StringTables.Guild.BUTTON_CALENDAR_CREATE) )
	end
	
	GuildWindowTabCalendar.UpdatePermissions()
end

-- When the user clicks CANCEL during the creation of a new appointment, this function gets called.
-- We need to clear all the edit boxes and switch back to the default calendar tab display
function GuildWindowTabCalendar.OnLButtonUpCalendarCommandNewAppointmentCancelButton()
	GuildWindowTabCalendar.SetAppointmentMode(0)
end

-- Callback from the Appointment (Event) <List> that updates a single row.
function GuildWindowTabCalendar.UpdateAppointmentRow()
    if (GWCalendarAppointmentsList.PopulatorIndices == nil) then
        DEBUG(L" No Appointment List!")
        return
    end

    for rowIndex, dataIndex in ipairs (GWCalendarAppointmentsList.PopulatorIndices) do
    	local dataRow = "GWCalendarAppointmentsListRow"..rowIndex
		local memberData = GuildWindowTabCalendar.appointmentListData[dataIndex]
		
		WindowSetShowing( dataRow.."ConfirmedIcon", false )
        if( memberData.localPlayerSignedUp == 0 )
        then
            DynamicImageSetTextureSlice( dataRow.."ConfirmedIcon", "roster-status-yellow" )
            WindowSetShowing( dataRow.."ConfirmedIcon", true )
        elseif( memberData.localPlayerSignedUp ~= nil )
        then
            DynamicImageSetTextureSlice( dataRow.."ConfirmedIcon", "roster-status-green" )
            WindowSetShowing( dataRow.."ConfirmedIcon", true )
        end

		if memberData.guildID < 0 then	-- If this is a System Event, color it like a system event
			LabelSetTextColor(dataRow.."Subject", DefaultColor.YELLOW.r, DefaultColor.YELLOW.g, DefaultColor.YELLOW.b)
		elseif memberData.guildID == GameData.Guild.m_GuildID then	-- If this is a Guild event, color it as such
			LabelSetTextColor(dataRow.."Subject", DefaultColor.ChatChannelColors[SystemData.ChatLogFilters.GUILD].r, DefaultColor.ChatChannelColors[SystemData.ChatLogFilters.GUILD].g, DefaultColor.ChatChannelColors[SystemData.ChatLogFilters.GUILD].b)
		else	-- Otherwise assume this is an alliance event
			LabelSetTextColor(dataRow.."Subject", DefaultColor.ChatChannelColors[SystemData.ChatLogFilters.ALLIANCE].r, DefaultColor.ChatChannelColors[SystemData.ChatLogFilters.ALLIANCE].g, DefaultColor.ChatChannelColors[SystemData.ChatLogFilters.ALLIANCE].b)
		end

        -- use smaller font on the Day and Time fields for korean build so the text won't cut off
        if ( SystemData.Territory.KOREA )
        then
		    LabelSetFont( dataRow.."StartDay",  "font_alert_outline_half_small", WindowUtils.FONT_DEFAULT_TEXT_LINESPACING )
		    LabelSetFont( dataRow.."StartTime", "font_alert_outline_half_small", WindowUtils.FONT_DEFAULT_TEXT_LINESPACING )
		end
	end
end

-- Populates the icon that indicates if the member in the signup list has been confirmed or not.
function GuildWindowTabCalendar.PopulateSignupIcon(rowFrame, memberData)
	if memberData.accepted == 0 then
		DynamicImageSetTextureSlice( rowFrame.."ConfirmedIcon", "roster-status-yellow" )
	else
		DynamicImageSetTextureSlice( rowFrame.."ConfirmedIcon", "roster-status-green" )
	end
end

-- Callback from the <List> that updates a single row for the signup list.
function GuildWindowTabCalendar.UpdateSignupRow()
    if (GWCalendarSelectedAppointmentSignupsList.PopulatorIndices == nil) then
        DEBUG(L" No Signup List!")
        return
    end

    for rowIndex, dataIndex in ipairs (GWCalendarSelectedAppointmentSignupsList.PopulatorIndices) do
    	local rowFrame   = "GWCalendarSelectedAppointmentSignupsListRow"..rowIndex
		local memberData = GuildWindowTabCalendar.signupListData[dataIndex]
		if memberData ~= nil then
			GuildWindowTabCalendar.PopulateSignupIcon(rowFrame, memberData)
		end
    end
end

function GuildWindowTabCalendar.OnMouseOverNewAppointmentButton()
	Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name, nil)
    Tooltips.SetTooltipText (1, 1, GetGuildString( StringTables.Guild.TOOLTIP_CALENDAR_NEW_EVENT_BUTTON) )
    Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)
    Tooltips.Finalize ()
    
    local anchor = { Point="bottom", RelativeTo=SystemData.MouseOverWindow.name, RelativePoint="top", XOffset=0, YOffset=10 }
    Tooltips.AnchorTooltip (anchor)
end

function GuildWindowTabCalendar.OnMouseOverEventName()
	local windowIndex   = WindowGetId( SystemData.ActiveWindow.name )
    local windowParent  = WindowGetParent( SystemData.ActiveWindow.name )
    local dataIndex     = ListBoxGetDataIndex( WindowGetParent( windowParent ), windowIndex )
	local eventSelected = GuildWindowTabCalendar.appointmentListData[dataIndex]
	
	local creatorName = GuildWindowTabCalendar.GetEventCreatorName( eventSelected )

	Tooltips.CreateTextOnlyTooltip( SystemData.MouseOverWindow.name, nil )
	Tooltips.SetTooltipText( 1, 1, eventSelected.subject, true )
	Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
	Tooltips.SetTooltipText( 2, 1, GetGuildString( StringTables.Guild.HEADER_GUILD_CALENDAR_CREATOR )..L" "..creatorName )
	if( eventSelected.localPlayerSignedUp == 0 )
	then
        Tooltips.SetTooltipText( 3, 1, GetGuildString( StringTables.Guild.TOOLTIP_CALENDAR_SIGNUPS_NOT_ACCEPTED ) )
	elseif( eventSelected.localPlayerSignedUp ~= nil )
	then
        Tooltips.SetTooltipText( 3, 1, GetGuildString( StringTables.Guild.TOOLTIP_CALENDAR_SIGNUPS_ACCEPTED ) )
	end
	Tooltips.SetTooltipActionText( GetGuildString( StringTables.Guild.TOOLTIP_CALENDAR_EVENT_NAME ) )
    Tooltips.Finalize ()
    
    local anchor = { Point="topright", RelativeTo=SystemData.MouseOverWindow.name, RelativePoint="topleft", XOffset=0, YOffset=0 }
    Tooltips.AnchorTooltip (anchor)
end

function GuildWindowTabCalendar.OnMouseOverSignupRow()
	Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name, nil)
    Tooltips.SetTooltipText (1, 1, GetGuildString( StringTables.Guild.TOOLTIP_CALENDAR_SIGNUPS_NAME) )
    Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)
    Tooltips.Finalize ()

    local anchor = { Point="top", RelativeTo=SystemData.MouseOverWindow.name, RelativePoint="bottom", XOffset=0, YOffset=-10 }
    Tooltips.AnchorTooltip (anchor)
    Tooltips.SetTooltipAlpha (1)	
end

function GuildWindowTabCalendar.OnMouseOverSignupListSortButton()
    local windowName	= SystemData.ActiveWindow.name
    local windowIndex	= WindowGetId (windowName)

    Tooltips.CreateTextOnlyTooltip (windowName, nil)
    Tooltips.SetTooltipText (1, 1, GetStringFromTable("GuildStrings", GuildWindowTabCalendar.SortButtons[windowIndex].tooltip) )
    Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)	
    Tooltips.Finalize ()
    
    local anchor = { Point="top", RelativeTo=windowName, RelativePoint="bottomright", XOffset=0, YOffset=-15 }
    Tooltips.AnchorTooltip (anchor)
    Tooltips.SetTooltipAlpha (1)
end

function GuildWindowTabCalendar.UpdateSortButtons()

	-- Loop through all the sort buttons and set the selected one as "pressed" and not "pressed" for all the others
    for index = 1, GuildWindowTabCalendar.SORT_MAX_NUMBER do
        local window = GuildWindowTabCalendar.SortButtons[index].buttonName
        ButtonSetPressedFlag( window, index == GuildWindowTabCalendar.sortSignups.type )
    end

	-- If we're sorting up, show the up arrow. Same for the down arrow
    WindowSetShowing( "SelectedAppointmentSignupListUpArrow",	GuildWindowTabCalendar.sortSignups.order == GuildWindowTabCalendar.SORT_ORDER_UP )
	WindowSetShowing( "SelectedAppointmentSignupListDownArrow", GuildWindowTabCalendar.sortSignups.order == GuildWindowTabCalendar.SORT_ORDER_DOWN )

	-- Now anchor the up or down arrow to the correct sort button.
	if( GuildWindowTabCalendar.sortSignups.order == GuildWindowTabCalendar.SORT_ORDER_UP ) then
		WindowClearAnchors( "SelectedAppointmentSignupListUpArrow" )
		WindowAddAnchor("SelectedAppointmentSignupListUpArrow", "right", GuildWindowTabCalendar.SortButtons[GuildWindowTabCalendar.sortSignups.type].buttonName, "right", -8, 0 )
	else
		WindowClearAnchors( "SelectedAppointmentSignupListDownArrow" )
		WindowAddAnchor("SelectedAppointmentSignupListDownArrow", "right", GuildWindowTabCalendar.SortButtons[GuildWindowTabCalendar.sortSignups.type].buttonName, "right", -8, 0 )
	end

end

function GuildWindowTabCalendar.OnLButtonUpSignupListSortButton()
    local type = WindowGetId( SystemData.ActiveWindow.name )
    
    if( type == GuildWindowTabCalendar.sortSignups.type ) then		-- If we are already using this sort type, toggle the order.
        if( GuildWindowTabCalendar.sortSignups.order == GuildWindowTabCalendar.SORT_ORDER_UP ) then
            GuildWindowTabCalendar.sortSignups.order = GuildWindowTabCalendar.SORT_ORDER_DOWN
        else
            GuildWindowTabCalendar.sortSignups.order = GuildWindowTabCalendar.SORT_ORDER_UP
        end
    else															-- Otherwise change the type and use the up order.
        GuildWindowTabCalendar.sortSignups.type = type
        GuildWindowTabCalendar.sortSignups.order = GuildWindowTabCalendar.SORT_ORDER_UP
    end

    SortSignupList()
    ListBoxSetDisplayOrder( "GWCalendarSelectedAppointmentSignupsList", GuildWindowTabCalendar.signupListOrder )

    GuildWindowTabCalendar.UpdateSortButtons()
end

function GuildWindowTabCalendar.UpdateSelectedEventData(dataIndex)
	local eventSelected = GuildWindowTabCalendar.appointmentListData[dataIndex]

	local creatorName = GuildWindowTabCalendar.GetEventCreatorName(eventSelected)

	LabelSetText("GWCalendarSelectedAppointmentCreator", creatorName)
	if GameData.Guild.m_GuildID == eventSelected.guildID then
		LabelSetTextColor("GWCalendarSelectedAppointmentCreator", 255, 255, 255)
	else
		DefaultColor.LabelSetTextColor("GWCalendarSelectedAppointmentCreator", DefaultColor.ChatChannelColors[SystemData.ChatLogFilters.ALLIANCE])
	end
	LabelSetText("GWCalendarSelectedAppointmentEventName", eventSelected.subject)
	LabelSetText("GWCalendarSelectedAppointmentStartDate", eventSelected.startDayString..L" "..eventSelected.startTimeString)
	LabelSetText("GWCalendarSelectedAppointmentEndDate", eventSelected.endDayString..L" "..eventSelected.endTimeString)
	LabelSetText("GWCalendarSelectedAppointmentDescription", eventSelected.details)
	
	-- Display a lock icon on the Signup Button if this event's signups have been locked, and then disable the button
	WindowSetShowing("GWCalendarSelectedAppointmentSignupButtonLock", eventSelected.locked)
	ButtonSetDisabledFlag("GWCalendarSelectedAppointmentSignupButton", eventSelected.locked)

	if eventSelected.shared then
		LabelSetText( "GWCalendarSelectedAppointmentShareText", GetGuildString(StringTables.Guild.LABEL_APPOINTMENT_YES) )
	else
		LabelSetText( "GWCalendarSelectedAppointmentShareText", GetGuildString(StringTables.Guild.LABEL_APPOINTMENT_NO) )
	end
	--ButtonSetPressedFlag("GWCalendarSelectedAppointmentShareCheckBox", eventSelected.shared == true)

	-- Members can only sign up for events from their own Guild, not events from their Alliance, so show/hide the Signups components.
	if GameData.Guild.m_GuildID == eventSelected.guildID then
		WindowSetShowing("GWCalendarSelectedAppointmentSignups", true)
		GuildWindowTabCalendar.UpdatePermissions()
	else
		WindowSetShowing("GWCalendarSelectedAppointmentSignups", false)
		WindowSetShowing("GWCalendarSelectedAppointmentSignupButton", false)
		WindowSetShowing("GWCalendarSelectedAppointmentSignupButtonLock", false)
		WindowSetShowing("GWCalendarSelectedAppointmentEditButton", false)
		WindowSetShowing("GWCalendarSelectedAppointmentDeleteButton", false)
	end
end

function GuildWindowTabCalendar.OnLButtonUpEventNameButton()
	local windowIndex   = WindowGetId (SystemData.ActiveWindow.name)
    local windowParent  = WindowGetParent (SystemData.ActiveWindow.name)
    local dataIndex     = ListBoxGetDataIndex (WindowGetParent(windowParent), windowIndex)
	
    --if (GuildWindowTabCalendar.appointmentListData[dataIndex].appointmentID == 0) then
    --    return	-- Some entries are blank in order to fill up the tints when only a few appts exist. We dont want to use these fakes.
    --end

	GuildWindowTabCalendar.SelectedAppointmentIndex = dataIndex

	-- Whenever we select an Event, we need to update the signup list with that event's signup data.
	GuildWindowTabCalendar.UpdateSignupList()

	-- We also need to update the event data
	GuildWindowTabCalendar.UpdateSelectedEventData(dataIndex)

	GuildWindowTabCalendar.SetAppointmentMode(GuildWindowTabCalendar.APPOINTMENT_VIEW)
end

--------------------------------------------------------------------
-- Functions for Events (Appointments)
--------------------------------------------------------------------
local function FilterAppointmentList()	

	local filters = GuildWindowTabCalendar.EventFilters

    GuildWindowTabCalendar.appointmentListOrder = {}
    for dataIndex, data in ipairs( GuildWindowTabCalendar.appointmentListData )
    do
		if data.guildID < 0 and filters[FILTER_SERVER].active
        then
			table.insert(GuildWindowTabCalendar.appointmentListOrder, dataIndex)
		elseif GameData.Guild.m_GuildID == data.guildID and filters[FILTER_GUILD].active
        then
			table.insert(GuildWindowTabCalendar.appointmentListOrder, dataIndex)
		elseif data.guildID > 0 and GameData.Guild.m_GuildID ~= data.guildID and filters[FILTER_ALLIANCE].active
        then
			table.insert(GuildWindowTabCalendar.appointmentListOrder, dataIndex)
		end
    end
end

local function CompareAppointments( index1, index2 )
    if (index2 == nil) then
        return false
	end

    local event1 = GuildWindowTabCalendar.appointmentListData[index1]
    local event2 = GuildWindowTabCalendar.appointmentListData[index2]

	if event1.startTime < event2.startTime then
		return true		
	end

	if event1.endTime < event2.endTime then
		return true
	end

end

local function SortAppointmentList()	
    table.sort( GuildWindowTabCalendar.appointmentListOrder, CompareAppointments )
end

local function InitAppointmentListData()

    GuildWindowTabCalendar.appointmentListData = {}
        
    local guildAppointmentData = GetGuildAppointmentData()
    
    if( guildAppointmentData == nil ) then
        DEBUG(L"guildAppointmentData == nil")
        return
    end

    for key, value in ipairs( guildAppointmentData ) do
        -- These should match the data that was retrieved from war_interface::LuaGetGuildAppointmentData
        GuildWindowTabCalendar.appointmentListData[key] = {}

        GuildWindowTabCalendar.appointmentListData[key].appointmentID	= value.appointmentID
        GuildWindowTabCalendar.appointmentListData[key].guildID			= value.guildID
		GuildWindowTabCalendar.appointmentListData[key].creatorID		= value.creatorID	-- ID of the guild member that created this appointment
		GuildWindowTabCalendar.appointmentListData[key].bIsPlayersEvent = value.bIsPlayersEvent	-- True if the player created this event, false otherwise
		GuildWindowTabCalendar.appointmentListData[key].subject			= value.summary
        GuildWindowTabCalendar.appointmentListData[key].details			= value.details
        GuildWindowTabCalendar.appointmentListData[key].locked			= value.locked
        GuildWindowTabCalendar.appointmentListData[key].shared			= value.shared
        GuildWindowTabCalendar.appointmentListData[key].localPlayerSignedUp = value.localPlayerSignedUp

		GuildWindowTabCalendar.appointmentListData[key].startTime		= value.startTime
        GuildWindowTabCalendar.appointmentListData[key].startMonth		= value.startMonth
        GuildWindowTabCalendar.appointmentListData[key].startDay		= value.startDay
        GuildWindowTabCalendar.appointmentListData[key].startYear		= value.startYear
        GuildWindowTabCalendar.appointmentListData[key].startHour		= value.startHour
        GuildWindowTabCalendar.appointmentListData[key].startMinute		= value.startMinute
		GuildWindowTabCalendar.appointmentListData[key].startDayString	= StringUtils.FormatDateString(value.startMonth, value.startDay, value.startYear)
		GuildWindowTabCalendar.appointmentListData[key].startTimeString	= StringUtils.FormatTimeString(value.startHour, value.startMinute)

		GuildWindowTabCalendar.appointmentListData[key].endTime			= value.endTime
        GuildWindowTabCalendar.appointmentListData[key].endMonth		= value.endMonth
        GuildWindowTabCalendar.appointmentListData[key].endDay			= value.endDay
        GuildWindowTabCalendar.appointmentListData[key].endYear			= value.endYear
        GuildWindowTabCalendar.appointmentListData[key].endHour			= value.endHour
        GuildWindowTabCalendar.appointmentListData[key].endMinute		= value.endMinute
		GuildWindowTabCalendar.appointmentListData[key].endDayString	= StringUtils.FormatDateString(value.endMonth, value.endDay, value.endYear)
		GuildWindowTabCalendar.appointmentListData[key].endTimeString	= StringUtils.FormatTimeString(value.endHour, value.endMinute)
    end
    
    LiveEvents.CreateAutoEvents()
end

-- Returns the event creator's name. 
function GuildWindowTabCalendar.GetEventCreatorName(eventSelected)

	-- If this is not a Guild nor an Alliance created event, all we need to do is just return the creator's name
	if eventSelected.guildID < 0 and eventSelected.creatorName ~= nil then
		return eventSelected.creatorName
	end

	-- If this is a Guild Event, return the name of the member who created it.
	if GameData.Guild.m_GuildID == eventSelected.guildID then		-- Guild Event
		for index, memberData in ipairs(GuildWindowTabRoster.memberListData) do
			if memberData.memberID == eventSelected.creatorID then
				return memberData.name
			end
		end
	else
		-- If this is an Alliance Event, return the name of the Alliance that created it.
		for index, allianceData in ipairs(GuildWindowTabAlliance.guilds) do
			if allianceData.id == eventSelected.guildID then
				return allianceData.name
			end
		end
	end

	-- If we got here, thats not good. Return an empty string. 
	-- (It's possible someone created an event, and then left the Guild, for example. Its also possible no creatorName exists for a System event.)
	return L""
end

function GuildWindowTabCalendar.UpdateAppointmentSortedList()
    FilterAppointmentList()
    SortAppointmentList()
    GuildWindowTabCalendar.SetDayTints()

    ListBoxSetDisplayOrder( "GWCalendarAppointmentsList", GuildWindowTabCalendar.appointmentListOrder )
end

function GuildWindowTabCalendar.UpdateAppointmentList()
    -- Filter, Sort, and Update
    InitAppointmentListData()
	GuildWindowTabCalendar.UpdateAppointmentSortedList()
	GuildWindowTabCalendar.UpdateButtons(GuildWindowTabCalendar.Appointment_Mode)

	-- If the user is looking at a selected appointment, update its info
	if GuildWindowTabCalendar.Appointment_Mode == GuildWindowTabCalendar.APPOINTMENT_VIEW and GuildWindowTabCalendar.SelectedAppointmentIndex > 0 then
		GuildWindowTabCalendar.UpdateSelectedEventData(GuildWindowTabCalendar.SelectedAppointmentIndex)
	end
end

function GuildWindowTabCalendar.UpdateSignupList()
    -- Filter, Sort, and Update
    InitSignupListData()
    FilterSignupList()
    SortSignupList()

    ListBoxSetDisplayOrder( "GWCalendarSelectedAppointmentSignupsList", GuildWindowTabCalendar.signupListOrder )

	GuildWindowTabCalendar.UpdateSortButtons()
	GuildWindowTabCalendar.UpdatePermissions()	-- Update showing or hiding the Signup and Leave buttons
end

function GuildWindowTabCalendar.SetSignupListRowTints()
-- This function Tints the rows that are listed in the Guild Window Signup list
    for row = 1, GWCalendarSelectedAppointmentSignupsList.numVisibleRows do
        local row_mod = math.mod(row, 2)
        color = DataUtils.GetAlternatingRowColor( row_mod )
        
        local targetRowWindow = "GWCalendarSelectedAppointmentSignupsListRow"..row
        WindowSetTintColor(targetRowWindow.."RowBackground", color.r, color.g, color.b )
        WindowSetAlpha(targetRowWindow.."RowBackground", color.a )
    end
end

function GuildWindowTabCalendar.OnMouseOverSelectedSignupsListConfirmedIcon()
	local windowName		= SystemData.MouseOverWindow.name
	local windowIndex		= WindowGetId (windowName)
    local dataIndex			= ListBoxGetDataIndex ("GWCalendarSelectedAppointmentSignupsList", windowIndex)
	local memberAccepted	= GuildWindowTabCalendar.signupListData[dataIndex].accepted
    
    Tooltips.CreateTextOnlyTooltip (windowName, nil)
	Tooltips.SetTooltipText (1, 1, GetGuildString( StringTables.Guild.TOOLTIP_CALENDAR_SIGNUPS_NAME) )

    if memberAccepted == 0 then 
		Tooltips.SetTooltipText (2, 1, GetGuildString(StringTables.Guild.TOOLTIP_CALENDAR_SIGNUPS_NOT_ACCEPTED) )
	else
		Tooltips.SetTooltipText (2, 1, GetGuildString(StringTables.Guild.TOOLTIP_CALENDAR_SIGNUPS_ACCEPTED) )
	end
    Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)	
    Tooltips.Finalize ()
    
    local anchor = { Point="top", RelativeTo=windowName, RelativePoint="bottom", XOffset=0, YOffset=-10 }
    Tooltips.AnchorTooltip (anchor)
    Tooltips.SetTooltipAlpha (1)
end

function GuildWindowTabCalendar.OnLButtonUpCalendarSelectedAppointmentSignupButton()
	if ButtonGetDisabledFlag("GWCalendarSelectedAppointmentSignupButton") == true then
		return		-- You can't Signup for an event if its signups has been locked, so do nothing.
	end

    local index = GuildWindowTabCalendar.SelectedAppointmentIndex
    SendGuildAppointmentData(
        GuildWindowTabCalendar.APPOINTMENT_SIGNUP,							-- Param 0
        GuildWindowTabCalendar.appointmentListData[index].appointmentID,	-- Param 1
        GuildWindowTabCalendar.appointmentListData[index].guildID,			-- Param 2
        0,		-- Param 3
        0,		-- Param 4
        0,		-- Param 5
        0,		-- Param 6
        0,		-- Param 7
        0,		-- Param 8
        0,		-- Param 9
        0,		-- Param 10
        0,		-- Param 11
        0,		-- Param 12
        0,		-- Param 13
        0,		-- Param 14
        0,		-- Param 15
        L"",	-- Param 16
        L"",	-- Param 17
        false,	-- Param 18
        false	-- Param 19
    )
end


function GuildWindowTabCalendar.OnLButtonUpCalendarSelectedAppointmentBackButton()
	GuildWindowTabCalendar.SetAppointmentMode(0)
end

function GuildWindowTabCalendar.OnLButtonUpCalendarSelectedAppointmentLeaveButton()
    local index = GuildWindowTabCalendar.SelectedAppointmentIndex
    SendGuildAppointmentData(
        GuildWindowTabCalendar.APPOINTMENT_LEAVE,							-- Param 0
        GuildWindowTabCalendar.appointmentListData[index].appointmentID,	-- Param 1
        GuildWindowTabCalendar.appointmentListData[index].guildID,			-- Param 2
        0,		-- Param 3
        0,		-- Param 4
        0,		-- Param 5
        0,		-- Param 6
        0,		-- Param 7
        0,		-- Param 8
        0,		-- Param 9
        0,		-- Param 10
        0,		-- Param 11
        0,		-- Param 12
        0,		-- Param 13
        0,		-- Param 14
        0,		-- Param 15
        L"",	-- Param 16
        L"",	-- Param 17
        false,	-- Param 18
        false	-- Param 19
    )
end

function GuildWindowTabCalendar.OnLButtonUpCalendarSelectedAppointmentEditButton()
	GuildWindowTabCalendar.SetAppointmentMode(GuildWindowTabCalendar.APPOINTMENT_EDIT)
end

function GuildWindowTabCalendar.OnLButtonUpCalendarSelectedAppointmentDeleteButton()
	-- Create Confirmation Dialog
    local dialogText = GetGuildString( StringTables.Guild.DIALOG_CONFIRM_DELETE_APPOINTMENT)
    
    local confirmYes = GetGuildString( StringTables.Guild.BUTTON_CONFIRM_YES)
    local confirmNo = GetGuildString( StringTables.Guild.BUTTON_CONFIRM_NO)
    DialogManager.MakeTwoButtonDialog( dialogText, confirmYes, GuildWindowTabCalendar.ConfirmedDeleteAppointment, confirmNo, nil)
end

function GuildWindowTabCalendar.ConfirmedDeleteAppointment()
	local index = GuildWindowTabCalendar.SelectedAppointmentIndex
    
    SendGuildAppointmentData(
        GuildWindowTabCalendar.APPOINTMENT_DELETE,							-- Param 0
        GuildWindowTabCalendar.appointmentListData[index].appointmentID,	-- Param 1
        GuildWindowTabCalendar.appointmentListData[index].guildID,			-- Param 2
        0,		-- Param 3
        0,		-- Param 4
        0,		-- Param 5
        0,		-- Param 6
        0,		-- Param 7
        0,		-- Param 8
        0,		-- Param 9
        0,		-- Param 10
        0,		-- Param 11
        0,		-- Param 12
        0,		-- Param 13
        0,		-- Param 14
        0,		-- Param 15
        L"",	-- Param 16
        L"",	-- Param 17
        false,	-- Param 18
        false	-- Param 19
    )

    GuildWindowTabCalendar.SetAppointmentMode(0)
end

function GuildWindowTabCalendar.OnRButtonUpSignupRow()
	-- Ensure the user has permission to Accept/Reject members from the calendar event sign up list.
	local localPlayerTitleNumber = GuildWindowTabAdmin.GetLocalMemberTitleNumber()
	local localPlayerMemberID	 = GuildWindowTabRoster.GetMemberID()

	local bCanEditAllEvents			= GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.EDIT_ALL_EVENTS, localPlayerTitleNumber)
	local bCanEditOwnAppointments	= GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.EDIT_YOUR_EVENTS, localPlayerTitleNumber)
	local bCanCreateNewAppointments = bCanEditAllEvents or bCanEditOwnAppointments

	if bCanCreateNewAppointments == false and bCanEditOwnAppointments == false then
		return
	end

    local windowIndex	= WindowGetId (SystemData.ActiveWindow.name)
    local windowParent	= WindowGetParent (SystemData.ActiveWindow.name)
    local dataIndex     = ListBoxGetDataIndex (WindowGetParent (windowParent), windowIndex)
    
	-- Only members who created the event or have permission to edit other's events can see a context menu to accept/reject signed up members.
	GuildWindowTabCalendar.SelectedSignupMemberIndex = dataIndex

	-- If this isn't your event and you don't have permission to edit everyone's event, then no context menu for you!
	if GuildWindowTabCalendar.signupListData[dataIndex].memberID ~= localPlayerMemberID and bCanEditAllEvents == false then
		return
	end

    if (GuildWindowTabCalendar.signupListData[dataIndex].name == L"") then
        return	-- Some entries are blank in order to fill up the tints when only a few appts exist. We dont want to highlight these fakes.
    end

	local bAccepted = GuildWindowTabCalendar.signupListData[dataIndex].accepted == 0

	-- for reference: function EA_Window_ContextMenu.AddMenuItem( buttonText, callbackFunction, bDisabled, bCloseAfterClick )
    EA_Window_ContextMenu.CreateContextMenu( SystemData.ActiveWindow.name ) 
		EA_Window_ContextMenu.AddMenuItem( GetGuildString(StringTables.Guild.CONTEXT_MENU_CALENDAR_SIGNUP_ACCEPT), GuildWindowTabCalendar.CommandSignupAcceptMember, not bAccepted, true )
		EA_Window_ContextMenu.AddMenuItem( GetGuildString(StringTables.Guild.CONTEXT_MENU_CALENDAR_SIGNUP_PENDING), GuildWindowTabCalendar.CommandSignupAcceptMember, bAccepted, true )
		EA_Window_ContextMenu.AddMenuItem( GetGuildString(StringTables.Guild.CONTEXT_MENU_CALENDAR_SIGNUP_KICK), GuildWindowTabCalendar.CommandSignupRejectMember, false, true )
	EA_Window_ContextMenu.Finalize()
end

function GuildWindowTabCalendar.CommandSignupAcceptMember()
	local index = GuildWindowTabCalendar.SelectedAppointmentIndex
    local memberIndex = GuildWindowTabCalendar.SelectedSignupMemberIndex

	SendGuildAppointmentData(
        GuildWindowTabCalendar.APPOINTMENT_FLAG_ATTENDANCE,					-- Param 0
        GuildWindowTabCalendar.appointmentListData[index].appointmentID,	-- Param 1
        GuildWindowTabCalendar.appointmentListData[index].guildID,			-- Param 2
        GuildWindowTabCalendar.signupListData[memberIndex].memberID,		-- Param 3
        0,		-- Param 4
        0,		-- Param 5
        0,		-- Param 6
        0,		-- Param 7
        0,		-- Param 8
        0,		-- Param 9
        0,		-- Param 10
        0,		-- Param 11
        0,		-- Param 12
        0,		-- Param 13
        0,		-- Param 14
        0,		-- Param 15
        L"",	-- Param 16
        L"",	-- Param 17
        false,	-- Param 18
        false	-- Param 19
    )

	GuildWindowTabCalendar.SelectedSignupMemberIndex = 0

end

function GuildWindowTabCalendar.CommandSignupRejectMember()
    SendGuildAppointmentData(
        GuildWindowTabCalendar.APPOINTMENT_KICK,																	-- Param 0
        GuildWindowTabCalendar.appointmentListData[GuildWindowTabCalendar.SelectedAppointmentIndex].appointmentID,	-- Param 1
        GuildWindowTabCalendar.appointmentListData[GuildWindowTabCalendar.SelectedAppointmentIndex].guildID,		-- Param 2
        GuildWindowTabCalendar.signupListData[GuildWindowTabCalendar.SelectedSignupMemberIndex].memberID,			-- Param 3
        0,		-- Param 4
        0,		-- Param 5
        0,		-- Param 6
        0,		-- Param 7
        0,		-- Param 8
        0,		-- Param 9
        0,		-- Param 10
        0,		-- Param 11
        0,		-- Param 12
        0,		-- Param 13
        0,		-- Param 14
        0,		-- Param 15
        L"",	-- Param 16
        L"",	-- Param 17
        false,	-- Param 18
        false	-- Param 19
    )

    GuildWindowTabCalendar.SelectedSignupMemberIndex = 0
end

function GuildWindowTabCalendar.OnSelectFilter( selectedIndex )
    GuildWindowTabCalendar.EventFilters[selectedIndex].active = not GuildWindowTabCalendar.EventFilters[selectedIndex].active
    GuildWindowTabCalendar.InitializeEventFilters()
    WindowRegisterEventHandler( "GWCalendarFiltersFilterComboBox", SystemData.Events.L_BUTTON_UP_PROCESSED, "GuildWindowTabCalendar.ReopenComboBox" )
    
    GuildWindowTabCalendar.UpdateAppointmentSortedList()
end

function GuildWindowTabCalendar.ReopenComboBox()
    ComboBoxExternalOpenMenu( "GWCalendarFiltersFilterComboBox" )
    WindowUnregisterEventHandler( "GWCalendarFiltersFilterComboBox", SystemData.Events.L_BUTTON_UP_PROCESSED )
end


function GuildWindowTabCalendar.OnLButtonUpCheckboxLockSignup()

end

function GuildWindowTabCalendar.OnLButtonUpCheckboxShare()

end

-------------------------------------------------------
-- Permissions
-------------------------------------------------------

function GuildWindowTabCalendar.UpdatePermissions()

	if GuildWindow.SelectedTab ~= GuildWindow.TABS_CALENDAR then
		return
	end

	local localPlayerTitleNumber = GuildWindowTabAdmin.GetLocalMemberTitleNumber()

	if localPlayerTitleNumber == nil then
		return
	end

	local bCanEditOwnAppointments =		-- Does the user have permission to create and edit their own events?
		GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.EDIT_YOUR_EVENTS, localPlayerTitleNumber) and
		GameData.Guild.m_GuildRank >= GuildWindowTabCalendar.RankUnlocked	-- If Guild isnt high enough rank, user cant create a new event.

	local bCanCreateNewAppointments =	-- User can create new events if they have persmission to edit their own event or edit anyone's event.
		( GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.EDIT_ALL_EVENTS, localPlayerTitleNumber) or
		bCanEditOwnAppointments ) and
		GameData.Guild.m_GuildRank >= GuildWindowTabCalendar.RankUnlocked	-- If Guild isnt high enough rank, user cant create a new event.

	local bCanEditAllAppointments = 
		GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.EDIT_ALL_EVENTS, localPlayerTitleNumber) and
		GameData.Guild.m_GuildRank >= GuildWindowTabCalendar.RankUnlocked

	-- Was this event created by the local player?
	local bIsPlayersEvent = false
	if GuildWindowTabCalendar.SelectedAppointmentIndex > 0 then
		bIsPlayersEvent = GuildWindowTabCalendar.appointmentListData[GuildWindowTabCalendar.SelectedAppointmentIndex].bIsPlayersEvent
	end
	
	local bIsAllianceSharedEvent = false
	if GuildWindowTabCalendar.SelectedAppointmentIndex > 0
    then
        bIsAllianceSharedEvent = GameData.Guild.m_GuildID ~= GuildWindowTabCalendar.appointmentListData[GuildWindowTabCalendar.SelectedAppointmentIndex].guildID
    end

	-- Does the local player have permission to sign up for events?
	local bCanSignup = GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.CALENDAR_SIGNUP, localPlayerTitleNumber)

	--Hide buttons the user doesn't ever have permission to use
	WindowSetShowing( "GWCalendarNewAppointmentButton", (bCanCreateNewAppointments or bCanEditOwnAppointments) and GuildWindowTabCalendar.Appointment_Mode == 0 )
	WindowSetShowing( "GWCalendarSelectedAppointmentEditButton", ((bIsPlayersEvent and bCanEditOwnAppointments) or bCanEditAllAppointments) and not bIsAllianceSharedEvent )
	WindowSetShowing( "GWCalendarSelectedAppointmentDeleteButton", ((bIsPlayersEvent and bCanEditOwnAppointments) or bCanEditAllAppointments) and not bIsAllianceSharedEvent )

	-- If the user is already signed up for the selected event, then show the leave button (and hide the Signup Button)
	local LocalPlayerIsAlreadySignedUp = false
	for dataIndex, data in ipairs( GuildWindowTabCalendar.signupListData ) do
		if (WStringsCompare(GameData.Player.name, data.name) == 0) then
            LocalPlayerIsAlreadySignedUp = true
			break
        end
	end

	if LocalPlayerIsAlreadySignedUp then
		WindowSetShowing( "GWCalendarSelectedAppointmentLeaveButton", true )
		WindowSetShowing( "GWCalendarSelectedAppointmentSignupButtonLock", false )	-- Hide the lock icon if the leave button is shown
	else
		WindowSetShowing( "GWCalendarSelectedAppointmentLeaveButton", false )
		local eventSelected = GuildWindowTabCalendar.appointmentListData[GuildWindowTabCalendar.SelectedAppointmentIndex]
		WindowSetShowing("GWCalendarSelectedAppointmentSignupButtonLock", eventSelected~= nil and eventSelected.locked == true)
	end

	WindowSetShowing( "GWCalendarSelectedAppointmentSignupButton", (bCanSignup and LocalPlayerIsAlreadySignedUp == false) and not bIsAllianceSharedEvent )
end

function GuildWindowTabCalendar.OnPlayerInfoChanged()
	GuildWindowTabCalendar.UpdatePermissions()
end

function GuildWindowTabCalendar.SetStartDate()
	GuildWindowTabCalendar.SetComboBoxes(0, true, false, Calendar.month, Calendar.selectedDay, Calendar.year)
end

function GuildWindowTabCalendar.SetEndDate()
	GuildWindowTabCalendar.SetComboBoxes(0, false, true, Calendar.month, Calendar.selectedDay, Calendar.year)
end

function GuildWindowTabCalendar.CreateNewEventFromSelectedCalendarDay()
	GuildWindowTabCalendar.SetAppointmentMode(GuildWindowTabCalendar.APPOINTMENT_ADD)
	GuildWindowTabCalendar.SetComboBoxes(0, true, true, Calendar.month, Calendar.selectedDay, Calendar.year)
end

function GuildWindowTabCalendar.OnMouseOverSignupButtonLock()
	Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name, nil)
    Tooltips.SetTooltipText (1, 1, GetGuildString( StringTables.Guild.TOOLTIP_CALENDAR_SIGNUP_BUTTON_LOCKED) )
    Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)
    Tooltips.Finalize ()
    
    local anchor = { Point="top", RelativeTo=SystemData.MouseOverWindow.name, RelativePoint="bottomright", XOffset=0, YOffset=-10 }
    Tooltips.AnchorTooltip (anchor)
    Tooltips.SetTooltipAlpha (1)
end

function GuildWindowTabCalendar.UpdateButtons(mode)
	-- Disable unless we're viewing the Event List, or we've reached the max# of guild events (which is 10)
	local numberOfGuildEvents = GuildWindowTabCalendar.GetNumberOfGuildEvents()
	ButtonSetDisabledFlag("GWCalendarNewAppointmentButton", mode ~= 0 or numberOfGuildEvents >= GuildWindowTabCalendar.MAX_EVENTS)
	
	LabelSetText( "GWCalendarTotalAppointments", GetFormatStringFromTable( "guildstrings", StringTables.Guild.HINT_TEXT_MAX_CALENDAR_EVENTS, {numberOfGuildEvents, GuildWindowTabCalendar.MAX_EVENTS} ) )
end

function GuildWindowTabCalendar.GetNumberOfGuildEvents()
	-- Returns the numberof events that the local player's Guild has
	local numberofGuildEvents = 0
	for dataIndex, data in ipairs( GuildWindowTabCalendar.appointmentListData ) do
		if data.guildID == GameData.Guild.m_GuildID then
			numberofGuildEvents = numberofGuildEvents + 1
		end
	end

	return numberofGuildEvents
end
