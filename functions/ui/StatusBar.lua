--- Sets the current value for the StatusBar.
--- @param statusBarName string The name of the StatusBar.
--- @param curValue number The value to display on the status bar.
function StatusBarSetCurrentValue(statusBarName, curValue) end

--- Returns the the current value for the StatusBar.
--- @param statusBarName string The name of the StatusBar.
--- @return curValue number The value to display on the status bar.
function StatusBarGetCurrentValue(statusBarName) end

--- Sets the maximum value for the StatusBar.
--- @param statusBarName string The name of the StatusBar.
--- @param maxValue number The max value to display on the status bar.
function StatusBarSetMaximumValue(statusBarName, maxValue) end

--- Returns the the maximum value for the StatusBar.
--- @param statusBarName string The name of the StatusBar.
--- @return maxValue number The max value to display on the status bar.
function StatusBarGetMaximumValue(statusBarName) end

--- Stops interpolating to a new value and applies it immediately instead.
--- @param statusBarName string The name of the StatusBar.
function StatusBarStopInterpolating(statusBarName) end

--- Sets the color tint value for the window used as the ‘filled’ portion of the StatusBar.
--- @param statusBarName string The name of the StatusBar.
--- @param red number The 0 to 255 hue value for red tint level.
--- @param green number The 0 to 255 hue value for green tint level.
--- @param blue number The 0 to 255 hue value for blue tint level.
function StatusBarSetForegroundTint(statusBarName, red, green, blue) end

--- Sets the color tint value for the window used as the ‘unfilled’ portion of the StatusBar.
--- @param statusBarName string The name of the StatusBar.
--- @param red number The 0 to 255 hue value for red tint level.
--- @param green number The 0 to 255 hue value for green tint level.
--- @param blue number The 0 to 255 hue value for blue tint level.
function StatusBarSetBackgroundTint(statusBarName, red, green, blue) end

StatusBar = StatusBar or {}
