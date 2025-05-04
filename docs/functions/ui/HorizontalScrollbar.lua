--- Sets the current scroll position
--- @param horizontalScrollbarName string The name of the HorizontalScrollbar.
--- @param scrollPos number The current scroll position.
function HorizontalScrollbarSetScrollPosition(horizontalScrollbarName, scrollPos) end

--- Returns the current scroll position
--- @param horizontalScrollbarName string The name of the HorizontalScrollbar.
--- @return scrollPos number The current scroll position.
function HorizontalScrollbarGetScrollPosition(horizontalScrollbarName) end

--- Sets the maximum scroll position
--- @param horizontalScrollbarName string The name of the HorizontalScrollbar.
--- @param maxScrollPos number The maximum scroll position.
function HorizontalScrollbarSetMaxScrollPosition(horizontalScrollbarName, maxScrollPos) end

--- Returns the maximum scroll position.
--- @param horizontalScrollbarName string The name of the HorizontalScrollbar.
--- @return maxScrollPos number The maximum scroll position.
function HorizontalScrollbarGetMaxScrollPosition(horizontalScrollbarName) end

--- Sets the page size.
--- @param horizontalScrollbarName string The name of the HorizontalScrollbar.
--- @param pageSize number The page size.
function HorizontalScrollbarSetPageSize(horizontalScrollbarName, pageSize) end

--- Returns the page size.
--- @param horizontalScrollbarName string The name of the HorizontalScrollbar.
--- @return pageSize number The current page size.
function HorizontalScrollbarGetPageSize(horizontalScrollbarName) end

--- Sets the line size.
--- @param horizontalScrollbarName string The name of the HorizontalScrollbar.
--- @param lineSize number The line size.
function HorizontalScrollbarSetLineSize(horizontalScrollbarName, lineSize) end

--- Returns the line size.
--- @param horizontalScrollbarName string The name of the HorizontalScrollbar.
--- @return lineSize number The current line size.
function HorizontalScrollbarGetLineSize(horizontalScrollbarName) end

HorizontalScrollbar = HorizontalScrollbar or {}

HorizontalScrollbar.OnScrollPosChanged = function(horizontalScrollbarName, scrollPos) end
