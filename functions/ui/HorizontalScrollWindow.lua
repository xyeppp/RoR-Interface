--- Sets the current scroll position offset.
--- @param horizScrollWindowName string The name of the HorizontalScrollWindow
--- @param scrollPos number The current scroll position offset.
function HorizontalScrollWindowSetOffset(horizScrollWindowName, scrollPos) end

--- Returns the current scroll position offset.
--- @param horizScrollWindowName string The name of the HorizontalScrollWindow
--- @return scrollPos number The current scroll position offset.
function HorizontalScrollWindowGetOffset(horizScrollWindowName) end

--- Updates the childscrollwindow and scrollbar to reflect it’s current contents.
--- @param horizScrollWindowName string The name of the HorizontalScrollWindow
function HorizontalScrollWindowUpdateScrollRect(horizScrollWindowName) end

HorizontalScrollWindow = HorizontalScrollWindow or {}
