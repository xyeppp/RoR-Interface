--- Adds a new item to the menu list.
--- @param comboBoxName string The name of the ComboBox.
--- @param menuItemText wstring Text for the menu item.
function ComboBoxAddMenuItem(comboBoxName, menuItemText) end

--- Clears out all items currently in the menu.
--- @param comboBoxName string The name of the ComboBox.
function ComboBoxClearMenuItems(comboBoxName) end

--- Sets the current selected menu item
--- @param comboBoxName string The name of the ComboBox.
--- @param menuItemIndex number The index of the menu item to select.  Must be between 1 and the current number of menu items.
function ComboBoxSetSelectedMenuItem(comboBoxName, menuItemIndex) end

--- Returns the index of the current selected menu item
--- @param comboBoxName string The name of the ComboBox.
--- @return number The index of the currently selected menu item.
function ComboBoxGetSelectedMenuItem(comboBoxName) end

--- Returns the text of the current selected menu item
--- @param comboBoxName string The name of the ComboBox.
--- @return wstring The text of the currently selected menu item.
function ComboBoxGetSelectedText(comboBoxName) end

--- Sets if ComboBox is disabled.
--- @param comboBoxName string The name of the ComboBox.
--- @param isDisabled boolean Should the ComboBox be disabled?
function ComboBoxSetDisabledFlag(comboBoxName, isDisabled) end

--- Returns if the ComboBox is currently disabled.
--- @param comboBoxName string The name of the ComboBox.
--- @return boolean Is the ComboBox currently disabled?
function ComboBoxGetDisabledFlag(comboBoxName) end

--- Returns if the ComboBox is currently open.
--- @param comboBoxName string The name of the ComboBox.
--- @return boolean Is the ComboBox currently open?
function ComboBoxIsMenuOpen(comboBoxName) end

--- Lua-exposed function for the OpenMenu() wrapper, ExternalOpenMenu().  Allows Lua to provide alternative ways of opening / closing the combo box.
--- @param comboBoxName string The name of the ComboBox.
--- @return bool true iff the menu was opened (i.e. it was closed previously).
function ComboBoxExternalOpenMenu(comboBoxName) end

ComboBox = ComboBox or {}

--- Called when the selected menu item is changed.
--- @param selectedIndex number The index of the newly selected item.  ( 1 through the max number of items in the menu ).
ComboBox.OnSelChanged = function(comboBoxName, selectedIndex) end
