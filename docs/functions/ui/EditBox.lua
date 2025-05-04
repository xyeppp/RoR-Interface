--- Sets the text currently displayed.
--- @param editBoxName string The name of the EditBox.
--- @param text wstring The text string.
function EditBoxSetText(editBoxName, text) end

--- Returns the text currently displayed.
--- @param editBoxName string The name of the EditBox.
--- @return wstring The text string.
function EditBoxGetText(editBoxName) end

--- Returns the text currently displayed as a vector of lines.
--- @param editBoxName string The name of the EditBox.
--- @return text wstring vector The text string vector.
function EditBoxGetTextLines(editBoxName) end

--- Inserts text at the current cursor location.
--- @param editBoxName string The name of the EditBox.
--- @param text wstring The text string to insert.
function EditBoxInsertText(editBoxName, text) end

--- Sets the color for the text display.
--- @param editBoxName string The name of the EditBox.
--- @param red number The red value for the text color (0-255)
--- @param green number The green value for the text color (0-255)
--- @param blue number The blue value for the text color (0-255)
function EditBoxSetTextColor(editBoxName, red, green, blue) end

--- Returns the current text color for the display.
--- @param editBoxName string The name of the EditBox.
--- @return red number The red value for the text color (0-255)
--- @return green number The green value for the text color (0-255)
--- @return blue number The blue value for the text color (0-255)
function EditBoxGetTextColor(editBoxName, red, green, blue) end

--- Selects all of the text.
--- @param editBoxName string The name of the EditBox.
function TextEditBoxSelectAll(editBoxName) end

--- Sets the font for the text display
--- @param editBoxName string The name of the EditBox.
--- @param fontName string The name of the font to use.
--- @param lineSpacing number The line spacing value to  use.
function EditBoxSetFont(editBoxName, fontName, lineSpacing) end

--- Returns the name of the font currently used.
--- @param editBoxName string The name of the EditBox.
--- @return fontName number The name of the Font.
function EditBoxGetFont(editBoxName) end

--- Returns the input history for the EditBox.
--- @param editBoxName string The name of the EditBox.
--- @return history wstring-table The items in the history.  Index 1 is the most recent item.
function EditBoxGetHistory(editBoxName) end

--- Sets the input history for the edit box.
--- @param editBoxName string The name of the EditBox.
--- @param history wstring-table The items in the history.  Index 1 is the most recent item.
function EditBoxSetHistory(editBoxName, history) end

--- Allows you to disable text from automatically being added to the EditBox display when a key is pressed.
--- @param editBoxName string The name of the EditBox.
--- @param handle boolean The name of the EditBox.
function EditBoxSetHandleKeyDown(editBoxName, handle) end

EditBox = EditBox or {}

EditBox.OnTextChanged = function(editBoxName, text) end
