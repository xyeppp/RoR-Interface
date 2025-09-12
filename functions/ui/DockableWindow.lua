--- Sets the text displayed on the button
--- @param dockableWindowName string The name of the dockable window.
--- @param text wstring The text string.
function DockableWindowSetTabString(dockableWindowName, text) end

--- Returns the text displayed on the tab for this dockable window.
--- @param dockableWindowName string The name of the DockableWindow.
--- @return string szTabString The text displayed on the tab.
function DockableWindowGetTabString(dockableWindowName) end

--- Set’s the Offset of the first tab from the left side of the window.
--- @param windowName string The name of the window.
--- @param offset number The offset to use on the tab.  May be any integer value.
function DockableWindowSetTabOffset(windowName, offset) end

--- Returns the tab offset for the specified window.
--- @param windowName string The name of the window.
--- @return offset number The tab offset value for the window.
function DockableWindowGetTabOffset(windowName) end

--- Docks a window to a root window
--- @param dockableRootWindowName string The name of the DockableWindow that will be the root.
--- @param dockableChildWindowName string The name of the DockableWindow that will be docked to the root.
function DockableWindowDock(dockableRootWindowName, dockableChildWindowName) end

--- Undocks a window from a root window
--- @param dockableRootWindowName string The name of the DockableWindow that is the root of the window group.
--- @param dockableChildWindowName string The name of the DockableWindow that will be unddocked from the root.
function DockableWindowUnDock(dockableRootWindowName, dockableChildWindowName) end

--- Returns the string name of the root window of the dockable window group
--- @param dockableWindowName string The name of the DockableWindow who’s root we want the name of.
--- @return szRootName string the name of the root window.  If the window is the root the window name is returned.
function DockableWindowGetRootName(dockableWindowName) end

--- Sets the top window of a dockable window group
--- @param rootWindowName string The name of the DockableWindow that is the root.
--- @param topWindowName string The name of the DockableWindow that will be set to the top.
function DockableWindowSetTopWindow(rootWindowName, topWindowName) end

--- Returns the string name of the top window of the dockable window group
--- @param dockableWindowName string The name of the DockableWindow whose top window we want the name of.
--- @return szTopName string the name of the top window.
function DockableWindowGetTopWindowName(dockableWindowName) end

--- Returns the string name of the child window of the dockable window group
--- @param dockableWindowName string The name of the DockableWindow who’s child we want the name of.
--- @param index number The index of the child we want to access.  If this is greater than the number of children then we will return an empty string.
--- @return szChildName string the name of the child window.
function DockableWindowGetChildName(dockableWindowName, index) end

--- Set’s the parent offset to use when the root window is deleted.
--- @param windowName string The name of the window.
--- @param x number The x offset to set the parent offset to when the root window is deleted.
--- @param y number The y offset to set the parent offset to when the root window is deleted.
function DockableWindowSetOffsetOnRootDelete(windowName, x, y) end

--- Returns true if the window is a child of the root window
--- @param RootWindowName string The name of the root window.
--- @param windowName string The name of the window to check for child status.
--- @return bool returns true if the window is a child of the root window
function DockableWindowIsChildOf(rootWindowName, windowName) end

--- Returns the string name of the child window of the dockable window group
--- @param dockableWindowName string The name of the DockableWindow who’s child we want the name of.
--- @param bMovable bool True if it will now be movable and false if it will not
function DockableWindowSetMovable(dockableWindowName, bMovable) end

--- Sets if a dockable window’s tab should be shown (and drawn) on the screen.
--- @param windowName string The name of the dockable window.
--- @param showing boolean Should the tab be drawn?
function DockableWindowSetTabShowing(windowName, showing) end

--- Sets if a dockable window’s tab should be shown (and drawn) on the screen.
--- @param alphaValue number The value to set all of the Tabs to.
function DockableWindowSetAllTabsAlpha(alphaValue) end

--- Returns the current show state of the dockable window’s tab
--- @param windowName string The name of the dockable window window.
--- @return shown bool true if the window is shown and false if it isn’t
function DockableWindowGetTabShowing(windowName) end

DockableWindow = DockableWindow or {}

DockableWindow.OnDock = function(dockableWindowName, RootWindowName, ChildWindowName) end
DockableWindow.OnUnDock = function(dockableWindowName, RootWindowName, ChildWindowName) end
DockableWindow.OnPositionTabs = function(dockableWindowName, TabHeight) end
