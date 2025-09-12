--- Adds the specified TextLog to the LogDisplay
--- @param logDisplayName string The name of the LogDisplay.
--- @param textLogName string Name of the TextLog to add.
--- @param addEntries boolean Should entries already in the log be added to the display?
function LogDisplayAddLog(logDisplayName, textLogName, addEntries) end

--- Removes the specified TextLog to the LogDisplay
--- @param logDisplayName string The name of the LogDisplay.
--- @param logName string The name of the TextLog.
function LogDisplayRemoveLog(logDisplayName, logName) end

--- Sets the maximum number of entries to display in the LogDisplay.
--- @param logDisplayName string The name of the LogDisplay.
--- @param limit number Maximum number of entries to display.  A negative value specifies unlimited.
function LogSetLimit(logDisplayName, limit) end

--- Sets if the timestamps should be display at the beginning of each entry.
--- @param logDisplayName string The name of the LogDisplay.
--- @param showTimestamp boolean Should the timestamp be displayed?
function LogDisplaySetShowTimestamp(logDisplayName, showTimestamp) end

--- Return if the timestamps is currently displayed at the beginning of each entry.
--- @param logDisplayName string The name of the LogDisplay.
--- @return showTimestamp boolean Is the timestamp currently displayed?
function LogDisplayGetShowTimestamp(logDisplayName) end

--- Sets if the TextLog name should be display at the beginning of each entry.
--- @param logDisplayName string The name of the LogDisplay.
--- @param showLogName boolean Should the TextLog name be displayed?
function LogDisplaySetShowLogName(logDisplayName, showLogName) end

--- Returns if the TextLog name is currently displayed at the beginning of each entry.
--- @param logDisplayName string The name of the LogDisplay.
--- @return showLogName boolean Is the TextLog name currently displayed?
function LogDisplayGetShowLogName(logDisplayName) end

--- Sets if the Filter Type name should be display at the beginning of each entry.
--- @param logDisplayName string The name of the LogDisplay.
--- @param showFilterName boolean Should the Filter Type name be displayed?
function LogDisplaySetShowFilterName(logDisplayName, showFilterName) end

--- Returns if the Filter Type name is currently displayed at the beginning of each entry.
--- @param logDisplayName string The name of the LogDisplay.
--- @return showFilterName boolean Is the Filter Type currently displayed?
function LogDisplayGetShowFilterName(logDisplayName) end

--- Sets the text color to use for the specified TextLog and Filter Type.
--- @param logDisplayName string The name of the LogDisplay.
--- @param textLogName string The of the TextLog.
--- @param filterId number The filter id within the TextLog.
--- @param red number The red value for the text color (0-255)
--- @param green number The green value for the text color (0-255)
--- @param blue number The blue value for the text color (0-255)
function LogDisplaySetFilterColor(logDisplayName, textLogName, filterId, red, green, blue) end

--- Returns the color currently used for the specified TextLog and Filter Type.
--- @param logDisplayName string The name of the LogDisplay.
--- @param textLogName string The of the TextLog.
--- @param filterId number The filter id within the TextLog.
--- @return red number The red value for the text color (0-255)
--- @return green number The green value for the text color (0-255)
--- @return blue number The blue value for the text color (0-255)
function LogDisplayGetFilterColor(logDisplayName, textLogName, filterId) end

--- Sets the specified Filter Type for the specified TextLog should be displayed.
--- @param logDisplayName string The name of the LogDisplay.
--- @param textLogName string The of the TextLog.
--- @param filterId number The filter id within the TextLog.
--- @param showFilterType boolean Should the filter type be displayed?
function LogDisplaySetFilterState(logDisplayName, textLogName, filterId, showFilterType) end

--- Returns if the specified Filter Type for the specified TextLog is currentlydisplayed.
--- @param logDisplayName string The name of the LogDisplay.
--- @param textLogName string The of the TextLog.
--- @param filterId number The filter id within the TextLog.
--- @return showFilterType boolean Is the the filter type currently displayed?
function LogDisplayGetFilterState(logDisplayName, textLogName, filterId) end

--- Sets if a filter sub type should be shown.
--- @param logDisplayName string The name of the LogDisplay.
--- @param textLogName string The of the TextLog.
--- @param filterId number The filter id within the TextLog.
--- @param showFilterType boolean Should the filter type be displayed?
--- @param filterSubTypeName string The name of the filter sub type.
--- @param hideSubType string Should the sub type be hidden?
function LogDisplayHideFilterSubType(logDisplayName, textLogName, filterId, showFilterType, filterSubTypeName, hideSubType) end

--- Sets the amount of time the text should be displayed before fading out.
--- @param logDisplayName string The name of the LogDisplay.
--- @param textDisplayTime number How long the text should be displayed before fading.
function LogDisplaySetTextFadeTime(logDisplayName, textDisplayTime) end

--- Returns the current the amount of time the text is displayed before fading out.
--- @param logDisplayName string The name of the LogDisplay.
--- @return textDisplayTime number The time the text is currently displayed before fading.
function LogDisplayGetTextFadeTime(logDisplayName) end

--- Returns whether a Scrollbar is needed for this display.
--- @param logDisplayName string The name of the LogDisplay.
--- @return bool Returns whether a Scrollbar is needed for this display.
function LogDisplayIsScrollbarActive(logDisplayName) end

--- Sets the Font for the text display
--- @param logDisplayName string The name of the LogDisplay.
--- @param fontName number The name of the Font to use.
function LogDisplaySetFont(logDisplayName, fontName) end

--- Returns the the name of the Font for the text display.
--- @param logDisplayName string The name of the LogDisplay.
--- @return fontName string The name of the Font to use.
function LogDisplayGetFont(logDisplayName) end

--- Scrolls the display all the way to the bottom.
--- @param logDisplayName string The name of the LogDisplay.
function LogDisplayScrollToBottom(logDisplayName) end

--- Returns if the display is scrolled all the way to the bottom.
--- @param logDisplayName string The name of the LogDisplay.
--- @return atBottom boolean Is the display scroll to the bottom?
function LogDisplayIsScrolledToBottom(logDisplayName) end

--- Resets the fade time for all of the text lines.
--- @param logDisplayName string The name of the LogDisplay.
function LogDisplayResetLineFadeTime(logDisplayName) end

--- Sets if the scrollbar should be shown or hidden.
--- @param logDisplayName string The name of the LogDisplay.
--- @param showBar boolean Should the scrollbar be shown?
function LogDisplayShowScrollbar(logDisplayName, showBar) end

--- Scrolls the display all the way to the top.
--- @param logDisplayName string The name of the LogDisplay.
--- @param logDisplayName string The name of the LogDisplay.
function LogDisplayScrollToTop(logDisplayName) end

--- Returns if the display is scrolled all the way to the top.
--- @param logDisplayName string The name of the LogDisplay.
--- @return atTop boolean Is the display scroll to the top?
function LogDisplayIsScrolledToTop(logDisplayName) end

LogDisplay = LogDisplay or {}
