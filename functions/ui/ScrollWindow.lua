--- Sets the current scroll position offset.
--- @param scrollWindowName string The name of the ScrollWindow
--- @param scrollPos number The current scroll position offset.
function ScrollWindowSetOffset(scrollWindowName, scrollPos) end

--- Returns the current scroll position offset.
--- @param scrollWindowName string The name of the ScrollWindow
--- @return scrollPos number The current scroll position offset.
function ScrollWindowGetOffset(scrollWindowName) end

--- Updates the childscrollwindow and scrollbar to reflect it’s current contents.
--- @param scrollWindowName string The name of the ScrollWindow
function ScrollWindowUpdateScrollRect(scrollWindowName) end

ScrollWindow = ScrollWindow or {}
