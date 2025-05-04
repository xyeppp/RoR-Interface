----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

TimeUtils = {}

TimeUtils.SECONDS_PER_MINUTE = 60
TimeUtils.MINUTES_PER_HOUR = 60
TimeUtils.HOURS_PER_DAY = 24

TimeUtils.SECONDS_PER_HOUR = TimeUtils.SECONDS_PER_MINUTE * TimeUtils.MINUTES_PER_HOUR
TimeUtils.SECONDS_PER_DAY = TimeUtils.SECONDS_PER_HOUR * TimeUtils.HOURS_PER_DAY

TimeUtils.THRESHOLD_FOR_SECONDS_DISPLAY = 90


----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

----------------------------------------------------------------
-- TimeUtils Functions
----------------------------------------------------------------

--
-- Time is given in seconds
-- The output rounds to the nearest minute if we're above 90 seconds, and gives seconds otherwise.
-- From 3:30 down to 2:30 we'll display "3 minutes", from 2:30 down to 1:30 we'll display "2 minutes",
-- and below that we'll display "X seconds".
-- Returns formattedTime or time, minutes, seconds depending on value of returnStringValue
--
-- NOTE: Call sparingly. - If changes are made to this function, make sure to update the equivalent function in ActionButtonGroup.cpp
function TimeUtils.FormatSeconds(time, returnStringValue)
    if not (time > 0) 
    then
        time = 0
    end
    
    time = math.floor( time + 0.9 ) -- Equivalent to math.ceil(time) except for small values of time
    
    if (returnStringValue == nil or returnStringValue == true)
    then
        return TimeUtils.GetFormattedTimeString (time, math.floor( time / 60 + 0.5 ))
    end
    
    local mins = math.floor( time / 60 )
    local secs = time - mins * 60
    return time, mins, secs
end

--
-- Time is given in seconds
-- The output always returns a value in seconds, rounded to the nearest Nth of a second, where
-- N is the fractional granularity.  (ie, if half seconds are desired pass in .5, if tenths of seconds
-- are desired, pass in .1)
-- Returns formattedTime or seconds depending on value of returnStringValue
-- If using the string version, alwaysIncludeDecimal determines whether 5 shows up as 5s or 5.0s
--
-- NOTE: Call sparingly. - If changes are made to this function, make sure to update the equivalent function in ActionButtonGroup.cpp
function TimeUtils.FormatRoundedSeconds( time, factor, returnStringValue, alwaysIncludeDecimal )
    if not ( time > 0 ) 
    then
        time = 0
    end
    
    local reciprocal = ( 1 / factor )
    time = math.floor( ( time + factor / 2 )  * reciprocal ) * factor
	       
    if ( returnStringValue == nil or returnStringValue == true )
    then
		-- Show the decimal if requested
        if ( alwaysIncludeDecimal == nil or alwaysIncludeDecimal == true )
        then
            time = wstring.format( L"%0.1f", time )

		-- Show the decimal only if needed        
        elseif( math.floor( time ) ~= time )
        then
			time = wstring.format( L"%0.1f", time )
			
			-- If the decimal is not needed because of imprecision, skip it
			if( wstring.sub( time , -2 ) == L".0" ) 
            then
				time = wstring.sub( time, 0, wstring.len( time ) - 2 )            
            end
        end
        return GetStringFormat( StringTables.Default.LABEL_X_S, { time } )
    end
    
    return time
end

-- NOTE: Call sparingly
function TimeUtils.GetFormattedTimeString (time, mins)
    if time > TimeUtils.THRESHOLD_FOR_SECONDS_DISPLAY then
        return GetStringFormat( StringTables.Default.LABEL_X_M, { mins } )
    end
    
    return GetStringFormat( StringTables.Default.LABEL_X_S, { time } )
end

-- Given a time in seconds, provides the breakdown of secs, mins, hours, days.
--
-- Returns secs, mins, hours, days
--
function TimeUtils.ParseSeconds(time)
    if not (time > 0) then
        time = 0
    end
    
    time = math.floor( time + 0.9 )
    local secs = time % TimeUtils.SECONDS_PER_MINUTE 
    time = math.floor( time / TimeUtils.SECONDS_PER_MINUTE )
    local mins = time % TimeUtils.MINUTES_PER_HOUR 
    time = math.floor( time / TimeUtils.MINUTES_PER_HOUR )
    local hours = time % TimeUtils.HOURS_PER_DAY 
    local days = math.floor( time / TimeUtils.HOURS_PER_DAY )
    
    return secs, mins, hours, days
end

-- Provides a wstring representation for the highest units present, 
-- with only a single character used for the units. Decimal portion is rounded off. 
-- The numeric portion will only be 1 or 2 decimal places so the string will always be 
-- either 2 or 3 characters (except for times greater than 99 days)
--
-- If the numeric portion would round down to 1 then we switch units to the next level of granularity.
-- For example: The output rounds down to the nearest minute if we're above 90 seconds, and gives seconds otherwise.
-- From 3:30 down to 2:30 we'll display "3 minutes", from 2:30 down to 1:30 we'll display "2 minutes",
-- and below that we'll display "X seconds".
--
-- Returns timeString
--
function TimeUtils.FormatTimeCondensed(time)
    if not (time > 0) then
        time = 0
    end
    
    local timeString = L""
    
    if( time > (TimeUtils.SECONDS_PER_DAY *1.5) ) then 
        timeString = GetStringFormat( StringTables.Default.LABEL_X_D, { math.floor( (time / TimeUtils.SECONDS_PER_DAY) + 0.5 ) } )
    elseif( time > (TimeUtils.SECONDS_PER_HOUR *1.5) ) then 
        timeString = GetStringFormat( StringTables.Default.LABEL_X_H, { math.floor( (time / TimeUtils.SECONDS_PER_HOUR) + 0.5 ) } )
    elseif( time > (TimeUtils.SECONDS_PER_MINUTE *1.5) ) then 
        timeString = GetStringFormat( StringTables.Default.LABEL_X_M, { math.floor( (time / TimeUtils.SECONDS_PER_MINUTE) + 0.5 ) } )
    else
        timeString = GetStringFormat( StringTables.Default.LABEL_X_S, { math.floor( time + 0.5 ) } )
    end
    
    return timeString
end

-- Provides a wstring representation for the highest units present, 
-- with only a single character used for the units. Decimal portion is rounded off. 
-- The numeric portion will only be 1 or 2 decimal places so the string will always be 
-- either 2 or 3 characters (except for times greater than 99 days)
--
-- Rounds down to the next unit of time measurement. So if we are at 1m and 59s we will
-- display 1m altough we are closer to 2m.
--
-- Returns timeString
--
function TimeUtils.FormatTimeCondensedTruncate(time)
    if not (time > 0) then
        time = 0
    end
    
    local timeString = L""
    
    if( time > TimeUtils.SECONDS_PER_DAY ) then 
        timeString = GetStringFormat( StringTables.Default.LABEL_X_D, { math.floor( time / TimeUtils.SECONDS_PER_DAY ) } )
    elseif( time > TimeUtils.SECONDS_PER_HOUR ) then 
        timeString = GetStringFormat( StringTables.Default.LABEL_X_H, { math.floor( time / TimeUtils.SECONDS_PER_HOUR ) } )
    elseif( time > TimeUtils.SECONDS_PER_MINUTE ) then 
        timeString = GetStringFormat( StringTables.Default.LABEL_X_M, { math.floor( time / TimeUtils.SECONDS_PER_MINUTE ) } )
    else
        timeString = GetStringFormat( StringTables.Default.LABEL_X_S, { math.floor( time ) } )
    end
    
    return timeString
end


--
-- Same as TimeUtils.FormatTimeCondensed but it shows the days, hours, minutes and seconds
--
-- Returns timeString
--
function TimeUtils.FormatTime(time)
    if not (time > 0) then
        time = 0
    end
    
    local timeString = L""
    
    if( ( time + 0.5 ) > TimeUtils.SECONDS_PER_DAY )
    then 
        local days = math.floor( ( time + 0.5 ) / TimeUtils.SECONDS_PER_DAY )
        time = time - days * TimeUtils.SECONDS_PER_DAY
        timeString = timeString..L" "..GetStringFormat( StringTables.Default.LABEL_X_D, { days } )
    end
    
    if( ( time + 0.5 ) > TimeUtils.SECONDS_PER_HOUR )
    then 
        local hours = math.floor( ( time + 0.5 ) / TimeUtils.SECONDS_PER_HOUR )
        time = time - hours * TimeUtils.SECONDS_PER_HOUR
        timeString = timeString..L" "..GetStringFormat( StringTables.Default.LABEL_X_H, { hours } )
    end
    
    if( ( time + 0.5 ) > TimeUtils.SECONDS_PER_MINUTE )
    then
        local min = math.floor( ( time + 0.5 ) / TimeUtils.SECONDS_PER_MINUTE )
        time = time - min * TimeUtils.SECONDS_PER_MINUTE
        timeString = timeString..L" "..GetStringFormat( StringTables.Default.LABEL_X_M, { min } )
    end
    
    if( time > 0 )
    then
        timeString = timeString..L" "..GetStringFormat( StringTables.Default.LABEL_X_S, { math.floor( time + 0.5 ) } )
    end
    
    return timeString
end

-- Returns time the HH:MM::SS format
function TimeUtils.FormatClock( time )

    if time > 0 then
        time = math.floor( time + 0.5 )
    else
        time = 0
    end
    
    local hrs  = math.floor( time / 3600 )
    time = time - hrs * 3600
    local mins = math.floor( time / 60 )
    local secs = time - mins * 60
    
    local text = L""
    if( hrs > 0 ) then
        text = wstring.format(L"%d:%02d:%02d", hrs, mins, secs )
    else 
        text = wstring.format(L"%d:%02d", mins, secs)
    end
    
    return text
end       
