--- Sets the current scroll position
--- @param verticalScrollbarName string The name of the VerticalScrollbar.
--- @param scrollPos number The current scroll position.
function VerticalScrollbarSetScrollPosition(verticalScrollbarName, scrollPos) end

--- Returns the current scroll position
--- @param verticalScrollbarName string The name of the VerticalScrollbar.
--- @return scrollPos number The current scroll position.
function VerticalScrollbarGetScrollPosition(verticalScrollbarName) end

--- Sets the maximum scroll position
--- @param verticalScrollbarName string The name of the VerticalScrollbar.
--- @param maxScrollPos number The maximum scroll position.
function VerticalScrollbarSetMaxScrollPosition(verticalScrollbarName, maxScrollPos) end

--- Returns the maximum scroll position.
--- @param verticalScrollbarName string The name of the VerticalScrollbar.
--- @return maxScrollPos number The maximum scroll position.
function VerticalScrollbarGetMaxScrollPosition(verticalScrollbarName) end

--- Sets the page size.
--- @param verticalScrollbarName string The name of the VerticalScrollbar.
--- @param pageSize number The page size.
function VerticalScrollbarSetPageSize(verticalScrollbarName, pageSize) end

--- Returns the page size.
--- @param verticalScrollbarName string The name of the VerticalScrollbar.
--- @return pageSize number The current page size.
function VerticalScrollbarGetPageSize(verticalScrollbarName) end

--- Sets the line size.
--- @param verticalScrollbarName string The name of the VerticalScrollbar.
--- @param lineSize number The line size.
function VerticalScrollbarSetLineSize(verticalScrollbarName, lineSize) end

--- Returns the line size.
--- @param verticalScrollbarName string The name of the VerticalScrollbar.
--- @return lineSize number The current line size.
function VerticalScrollbarGetLineSize(verticalScrollbarName) end

VerticalScrollbar = VerticalScrollbar or {}

VerticalScrollbar.OnScrollPosChanged = function(verticalScrollbarName, scrollPos) end
