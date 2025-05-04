----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

Calendar = {}

Calendar.month = 9
Calendar.year = 2008
Calendar.MIN_YEAR = 2008
Calendar.MAX_YEAR = 2026
Calendar.selectedDayWindow = L""
Calendar.selectedDay = 0
Calendar.todaysMonth = 0
Calendar.todaysDay = 0
Calendar.todaysYear = 0

-- OnInitialize Handler
function Calendar.Initialize()

    Calendar.InitializeWeekDayLabels()

end

function Calendar.InitializeWeekDayLabels()
    -- TODO: If the user's system settings change, these need updated.
    local dayIndex = GetFirstDayOfWeek()
    for labelIndex = 1, 7
    do
        LabelSetText( "GuildWindowCalendarDOTW"..labelIndex, wstring.sub( GetWeekDayName( dayIndex, true ), 0, 1 ) )
        dayIndex = dayIndex + 1
        if ( dayIndex > 7 )
        then
            dayIndex = dayIndex - 7
        end
    end
end

function Calendar.Reset()
	-- When the calendar opens for the first time, set it to today's date.
	Calendar.SetTodaysDate()
	Calendar.month = Calendar.todaysMonth
	Calendar.year = Calendar.todaysYear
	
	Calendar.Update()
end

function Calendar.Shutdown()

end

function Calendar.SetTodaysDate()
	local todaysDate = GetTodaysDate()
	Calendar.todaysMonth = todaysDate.todaysMonth
	Calendar.todaysDay	 = todaysDate.todaysDay
	Calendar.todaysYear	 = todaysDate.todaysYear
end

function Calendar.GetNumberOfDaysInMonth(_month, _year)
	if (_month == 2) then
		local rem = math.mod(_year, 4)  -- Leap years are all years divisible by 4, with the exception of those divisible by 100, but not by 400 
		if (rem == 0) then				-- We'll ignore that tho. (The next skip would be in the year 2100)
			return 29
		else
			return 28
		end
	end

	if (_month == 4 or _month == 6 or _month == 9 or _month == 11) then
		return 30
	end

	return 31
end

-- This function only works for the gregorian calendar. Based upon the Zeller's Congruence algorithm.
-- Returns 1 (Monday) through 7 (Sunday)
function Calendar.GetDayOfWeek(_day, _month, _year)

	if (_month < 3) then
		_month = _month + 10
		_year = _year - 1
	else
		_month = _month-2
	end

	local century = math.floor(_year / 100)
	_year = math.mod(_year, 100)
	
	local ans = math.mod(math.floor((26*_month - 2) / 10) + _day + _year + math.floor(_year/4) + math.floor(century/4) - 2*century, 7)
	if (ans < 0) then
		ans = ans+7
	end

    -- We now have the result 0 (Sunday) through 6 (Saturday).
    -- We'll translate that to the system format of 1 (Monday) through 7 (Sunday).
    if ( ans == 0 )
    then
        ans = 7
    end

	return ans
end

function Calendar.Update()

	LabelSetText( "CalendarYearMonthLabel", GetYearMonthName( Calendar.year, Calendar.month ) )

	local daysInMonth = Calendar.GetNumberOfDaysInMonth( Calendar.month, Calendar.year )
	local previousMonth = Calendar.month - 1
	local previousMonthsYear = Calendar.year
	if (previousMonth <= 1)
    then
		previousMonth = 12
		previousMonthsYear = previousMonthsYear - 1
	end
	local daysInPreviousMonth = Calendar.GetNumberOfDaysInMonth(previousMonth, previousMonthsYear)

    -- Get the day that this month starts on.
    local firstDayOfMonth = Calendar.GetDayOfWeek( 1, Calendar.month, Calendar.year )

    -- Calculate where this first day is displayed based on the user's "first day of week" setting.
    local firstDayOfWeek = GetFirstDayOfWeek()
    local firstDayOffset = firstDayOfMonth - firstDayOfWeek
    if ( firstDayOffset < 0 )
    then
        firstDayOffset = firstDayOffset + 7
    end

	for counter=1, firstDayOffset do
		WindowSetShowing("GuildWindowCalendarDay"..counter.."Text", false)
		--LabelSetText( "GuildWindowCalendarDay"..counter.."Text", L""..daysInPreviousMonth-firstDayOffset+counter )
		--LabelSetTextColor("GuildWindowCalendarDay"..counter.."Text", 140, 140, 140) -- Days outside the current month are grey
	end

    WindowSetShowing( "GuildWindowCalendarCurrentDayFrame", false )

	for counter=1, daysInMonth do
		local dayoffset = firstDayOffset + counter
		WindowSetShowing("GuildWindowCalendarDay"..dayoffset.."Text", true)
		LabelSetText( "GuildWindowCalendarDay"..dayoffset.."Text", L""..counter )
		if counter < Calendar.todaysDay and Calendar.month == Calendar.todaysMonth and Calendar.year == Calendar.todaysYear then
			LabelSetTextColor("GuildWindowCalendarDay"..dayoffset.."Text", DefaultColor.Calendar.Day.LabelColor.Past.r, DefaultColor.Calendar.Day.LabelColor.Past.g, DefaultColor.Calendar.Day.LabelColor.Past.b) -- days prior to today are greyed out
		elseif (counter == Calendar.todaysDay and Calendar.month == Calendar.todaysMonth and Calendar.year == Calendar.todaysYear) then
			LabelSetTextColor("GuildWindowCalendarDay"..dayoffset.."Text", DefaultColor.Calendar.Day.LabelColor.Present.r, DefaultColor.Calendar.Day.LabelColor.Present.g, DefaultColor.Calendar.Day.LabelColor.Present.b)	  -- Highlight today's date
        	-- Move current day frame to the current day
        	WindowClearAnchors( "GuildWindowCalendarCurrentDayFrame" )
        	WindowAddAnchor( "GuildWindowCalendarCurrentDayFrame", "topleft",     "GuildWindowCalendarDay"..dayoffset, "topleft",     2, 3 )
        	WindowAddAnchor( "GuildWindowCalendarCurrentDayFrame", "bottomright", "GuildWindowCalendarDay"..dayoffset, "bottomright", -2, -3 )
        	WindowSetAlpha( "GuildWindowCalendarCurrentDayFrame", 0.25 )
        	WindowSetShowing( "GuildWindowCalendarCurrentDayFrame", true )
		else
			LabelSetTextColor("GuildWindowCalendarDay"..dayoffset.."Text", DefaultColor.Calendar.Day.LabelColor.Future.r, DefaultColor.Calendar.Day.LabelColor.Future.g, DefaultColor.Calendar.Day.LabelColor.Future.b)
		end
	end
	
	local newCounter = 1
	for counter=daysInMonth + firstDayOffset +1, 42 do
		-- Border days are grey
		WindowSetShowing("GuildWindowCalendarDay"..counter.."Text", false)
		--LabelSetText( "GuildWindowCalendarDay"..counter.."Text", L""..newCounter )
		--LabelSetTextColor("GuildWindowCalendarDay"..counter.."Text", 140, 140, 140) -- Days outside the current month are grey
		newCounter = newCounter + 1
	end

	Calendar.SetDayTints()
end

function Calendar.SetDayTints()
	GuildWindowTabCalendar.SetDayTints()
end

function Calendar.OnMouseOverDay()
	local windowParent	= WindowGetParent (SystemData.ActiveWindow.name)
	if (Calendar.selectedDayWindow == windowParent) then
--		WindowSetTintColor(windowParent.."Background", DefaultColor.Calendar.Day.TintColor.MOUSEOVER.r, DefaultColor.Calendar.Day.TintColor.MOUSEOVER.g, DefaultColor.Calendar.Day.TintColor.MOUSEOVER.b ) -- Don't overwrite the selected color with the mouseover color
		WindowSetAlpha(windowParent.."Background", DefaultColor.Calendar.Day.TintColor.MOUSEOVER.a)
	else
		WindowSetTintColor(windowParent.."Background", DefaultColor.Calendar.Day.TintColor.MOUSEOVER.r, DefaultColor.Calendar.Day.TintColor.MOUSEOVER.g, DefaultColor.Calendar.Day.TintColor.MOUSEOVER.b ) -- Don't overwrite the selected color with the mouseover color
		WindowSetAlpha(windowParent.."Background", DefaultColor.Calendar.Day.TintColor.MOUSEOVER.a)
	end
end

function Calendar.OnMouseOverDayEnd()
	Calendar.SetDayTints()
end

function Calendar.OnLButtonUpPlusButton()
	if (Calendar.month >= 12) then
		if (Calendar.year < Calendar.MAX_YEAR) then
			Calendar.year = Calendar.year + 1
			Calendar.month = 1
		end
	else
		Calendar.month = Calendar.month + 1
	end
	Calendar.selectedDayWindow = L""
	Calendar.Update()
end

function Calendar.OnLButtonUpMinusButton()
	if (Calendar.month <= 1) then
		if (Calendar.year > Calendar.MIN_YEAR) then
			Calendar.year = Calendar.year - 1
			Calendar.month = 12
		end
	else
		Calendar.month = Calendar.month - 1
	end
	Calendar.selectedDayWindow = L""
	Calendar.Update()
end

function Calendar.OnLButtonUpDay()
	Calendar.OnRButtonUpDay()	-- R button event doesnt work, so we'll use the L Button event for now.
end

function Calendar.OnRButtonUpDay()
	local windowParent = WindowGetParent (SystemData.ActiveWindow.name)

	-- Figure out if the clicked day falls within the current month
	local CalendarDayID = WindowGetId( windowParent )
	local daysInMonth = Calendar.GetNumberOfDaysInMonth(Calendar.month, Calendar.year)

    -- Get the day that this month starts on.
    local firstDayOfMonth = Calendar.GetDayOfWeek( 1, Calendar.month, Calendar.year )

    -- Calculate where this first day is displayed based on the user's "first day of week" setting.
    local firstDayOfWeek = GetFirstDayOfWeek()
    local firstDayOffset = firstDayOfMonth - firstDayOfWeek
    if ( firstDayOffset < 0 )
    then
        firstDayOffset = firstDayOffset + 7
    end

	if (CalendarDayID > firstDayOffset and CalendarDayID <= firstDayOffset+daysInMonth) then
		Calendar.selectedDayWindow	= windowParent
		Calendar.selectedDay = tonumber(LabelGetText( Calendar.selectedDayWindow.."Text" )) -- Convert string to number
	else
		Calendar.selectedDayWindow	= L""
		Calendar.selectedDay = 0
	end

	local localPlayerTitleNumber = GuildWindowTabAdmin.GetLocalMemberTitleNumber()
	local bCanEditOwnAppointments =		-- Does the user have permission to create and edit their own events?
		GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.EDIT_YOUR_EVENTS, localPlayerTitleNumber) and
		GameData.Guild.m_GuildRank >= GuildWindowTabCalendar.RankUnlocked	-- If Guild isnt high enough rank, user cant create a new event.

	local numberOfGuildEvents = GuildWindowTabCalendar.GetNumberOfGuildEvents()

	local bCanCreateNewAppointments =	-- User can create new events if they have persmission to edit their own event or edit anyone's event.
		( GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.EDIT_ALL_EVENTS, localPlayerTitleNumber) or
		bCanEditOwnAppointments ) and 
		GameData.Guild.m_GuildRank >= GuildWindowTabCalendar.RankUnlocked and 	-- If Guild isnt high enough rank, user cant create a new event.
		numberOfGuildEvents < GuildWindowTabCalendar.MAX_EVENTS	-- If the Guild already has its max# of events, then user cant create a new one.

	local bCanEditAllAppointments = 
		GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.EDIT_ALL_EVENTS, localPlayerTitleNumber) and
		GameData.Guild.m_GuildRank >= GuildWindowTabCalendar.RankUnlocked

	local bPermissionToAddEvent = (bCanEditAllAppointments or bCanEditOwnAppointments) and bCanCreateNewAppointments

	-- If we are editing a new or current event, then add context menu to set the selected day as the start or end time.
	if GuildWindowTabCalendar.Appointment_Mode == GuildWindowTabCalendar.APPOINTMENT_ADD or
		GuildWindowTabCalendar.Appointment_Mode == GuildWindowTabCalendar.APPOINTMENT_EDIT then
		
		EA_Window_ContextMenu.CreateContextMenu( SystemData.ActiveWindow.name ) 
			EA_Window_ContextMenu.AddMenuItem( GetGuildString(StringTables.Guild.CONTEXT_MENU_CALENDAR_DAY_SET_STARTDATE), GuildWindowTabCalendar.SetStartDate, false, true )
			EA_Window_ContextMenu.AddMenuItem( GetGuildString(StringTables.Guild.CONTEXT_MENU_CALENDAR_DAY_SET_ENDDATE), GuildWindowTabCalendar.SetEndDate, false, true )
		EA_Window_ContextMenu.Finalize()

	elseif bPermissionToAddEvent then
		-- for reference: function EA_Window_ContextMenu.AddMenuItem( buttonText, callbackFunction, bDisabled, bCloseAfterClick )
		EA_Window_ContextMenu.CreateContextMenu( SystemData.ActiveWindow.name ) 
			EA_Window_ContextMenu.AddMenuItem( GetGuildString(StringTables.Guild.CONTEXT_MENU_CALENDAR_DAY_CREATE_NEW_EVENT), GuildWindowTabCalendar.CreateNewEventFromSelectedCalendarDay, false, true )
		EA_Window_ContextMenu.Finalize()
	end
end
