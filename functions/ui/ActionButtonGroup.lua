--- Sets the icon for the specified button index
--- @param actionButtonGroupName string The name of the ActionButtonGroup.
--- @param buttonIndex number The index of the button you wish to set.
--- @param iconNum number The icon number you wish to use.
function ActionButtonGroupSetIcon(actionButtonGroupName, buttonIndex, iconNum) end

--- Sets the text for the specified button index
--- @param actionButtonGroupName string The name of the ActionButtonGroup.
--- @param buttonIndex number The index of the button you wish to set.
--- @param text wstring The text you wish displayed on the button.
function ActionButtonGroupSetText(actionButtonGroupName, buttonIndex, text) end

--- Sets the timer for the specified button index
--- @param actionButtonGroupName string The name of the ActionButtonGroup.
--- @param buttonIndex number The index of the button you wish to set.
--- @param maxTimer number The full duration of the timer.
--- @param remainingTimer number The time remaining on this timer.
function ActionButtonGroupSetTimer(actionButtonGroupName, buttonIndex, maxTimer, remainingTimer) end

--- Associates a a key-bindable action to clicking a button in this group.
--- @param windowName string Name of the window
--- @param buttonIndex number The index of the button you wish to set.
--- @param gameActionId number The keybinding action id to trigger when the window is clicked.
function ActionButtonGroupSetGameActionTrigger(windowName, buttonIndex, gameActionId) end

--- Associates a game action (a key-bindable action) to clicking on this window.
--- @param windowName string Name of the window
--- @param buttonIndex number The index of the button you wish to set.
--- @param gameActionType number The Type of the action.
--- @param gameActionId number The id number of the action.
--- @param gameActionText number The text associated with the action.
function ActionButtonGroupSetGameActionData(windowName, buttonIndex, gameActionType, gameActionId, gameActionText) end

--- Associates a game action (a key-bindable action) to clicking on this window.
--- @param windowName string Name of the window
--- @param buttonIndex number The index of the button you wish to set.
--- @param red number The red color value (0-255)
--- @param green number The green color value (0-255)
--- @param blue number The blue color value (0-255)
function ActionButtonGroupSetTintColor(windowName, buttonIndex, red, green, blue) end

--- Sets the number of rows & columns in this ActionButtonGroup.
--- @param windowName string The name of the ActionButtonGroup.
--- @param numRows number The number of rows of buttons.
--- @param numCols number The number of columns of buttons.
function ActionButtonGroupSetNumButtons(windowName, numRows, numCols) end

--- Sets the time format to use for the ActionButtonGroup.
--- @param windowName string The name of the ActionButtonGroup.
--- @param timeFormat number The format which the timers should appear in see the Window.TimeFormat constants.
function ActionButtonGroupSetTimeFormat(windowName, timeFormat) end

--- Sets the time abbreviations for the ActionButtonGroup.
--- @param windowName string The name of the ActionButtonGroup.
--- @param days wstring The abbreviation to use for days.
--- @param hours wstring The abbreviation to use for hours.
--- @param minutes wstring The abbreviation to use for minutes.
--- @param seconds wstring The abbreviation to use for seconds.
function ActionButtonGroupSetTimeAbbreviations(windowName, days, hours, minutes, seconds) end

ActionButtonGroup = ActionButtonGroup or {}

ActionButtonGroup.OnActionButtonLButtonDown = function(actionButtonGroupName, buttonIndex) end
ActionButtonGroup.OnActionButtonLButtonUp = function(actionButtonGroupName, buttonIndex) end
ActionButtonGroup.OnActionButtonRButtonDown = function(actionButtonGroupName, buttonIndex) end
ActionButtonGroup.OnActionButtonRButtonUp = function(actionButtonGroupName, buttonIndex) end
ActionButtonGroup.OnActionButtonMouseOver = function(actionButtonGroupName, buttonIndex) end
ActionButtonGroup.OnActionButtonMouseOverEnd = function(actionButtonGroupName, buttonIndex) end

ActionButtonGroup.TimeFormat = {
    SECONDS = 1,
    LARGEST_UNIT_ROUNDUP = 2,
    LARGEST_UNIT_TRUNCATE = 3,
    NUM_FORMATS = 4,
}
