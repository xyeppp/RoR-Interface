--- Returns the number of pages that this page window will display at once.
--- @param pageWindowName string The name of the PageWindow.
--- @return numPagesDisplayed number The number of pages displayed at once.
function PageWindowGetNumPagesDisplayed(pageWindowName) end

--- Sets the left most page on the display.
--- @param pageWindowName string The name of the PageWindow.
--- @param curPage number The index number for the left most page.
function PageWindowSetCurrentPage(pageWindowName, curPage) end

--- Returns the index of the current left-most page.
--- @param pageWindowName string The name of the PageWindow.
--- @return curPage number The index number for the left most page.
function PageWindowGetCurrentPage(pageWindowName) end

--- Processes all of the child windows to update the page layout.
--- @param pageWindowName string The name of the PageWindow.
function PageWindowUpdatePages(pageWindowName) end

--- Clears out all registered Page-Break windows.
--- @param pageWindowName string The name of the PageWindow.
function PageWindowClearPageBreaks(pageWindowName) end

--- Adds a new Page-Break window.  This window will always be displayed at the top of a page.
--- @param pageWindowName string The name of the PageWindow.
--- @param pageBreakWindowName string The name of a child window of the childcontentswindow.
function PageWindowAddPageBreak(pageWindowName, pageBreakWindowName) end

--- Removes the Page-Break for a specific window.
--- @param pageWindowName string The name of the PageWindow.
--- @param pageBreakWindowName string The name of a child window of the childcontentswindow.
function PageWindowRemovePageBreak(pageWindowName, pageBreakWindowName) end

--- Clears out all registered Splitable windows.
--- @param pageWindowName string The name of the PageWindow.
function PageWindowClearSplitableWindows(pageWindowName) end

--- Adds a new Splittable window.  When this window overhangs the page, it will duplicated so that it split between the pages rather than pushed to the next page.
--- @param pageWindowName string The name of the PageWindow.
--- @param splitableWindowName string The name of a child window of the childcontentswindow.
function PageWindowAddSplitableWindow(pageWindowName, splitableWindowName) end

--- Removes the splittable flag for a specific window.
--- @param pageWindowName string The name of the PageWindow.
--- @param splitableWindowName string The name of a child window of the childcontentswindow.
function PageWindowRemoveSplitableWindow(pageWindowName, splitableWindowName) end

PageWindow = PageWindow or {}
