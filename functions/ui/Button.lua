--- Sets the text displayed on the button
--- @param buttonName string The name of the button.
--- @param text wstring The text string.
function ButtonSetText(buttonName, text) end

--- Returns the text currently displayed on the button.
--- @param buttonName string The name of the button.
--- @return wstring The text string.
function ButtonGetText(buttonName) end

--- Sets if button should display it’s ‘pressed’ state.
--- @param buttonName string The name of the button.
--- @param isPressed boolean Should the pressed state be set?
function ButtonSetPressedFlag(buttonName, isPressed) end

--- Returns if button is currently pressed.
--- @param buttonName string The name of the button.
--- @return boolean Is the button currently pressed?
function ButtonGetPressedFlag(buttonName) end

--- Sets if button should be highlighted.
--- @param buttonName string The name of the button.
--- @param isHighlighted boolean Should the highlighted state be set?
function ButtonSetHighlightFlag(buttonName, isHighlighted) end

--- Sets if button should be highlighted.
--- @param buttonName string The name of the button.
--- @param buttonName string The name of the button.
--- @return boolean Is the button currently highlighted?
function ButtonGetHighlightFlag(buttonName) end

--- Sets if button is disabled. When disabled, the button will display it’s ‘disabled’ artwork and never highlight images.
--- @param buttonName string The name of the button.
--- @param isDisabled. boolean Should the button be disabled?
function ButtonSetDisabledFlag(buttonName, isDisabled) end

--- Returns if the button is currently set to disabled.
--- @param buttonName string The name of the button.
--- @return isDisabled. boolean Is the button currently disabled?
function ButtonGetDisabledFlag(buttonName) end

--- Sets if button if the button should remained pressed when the user release the left mouse button.
--- @param buttonName string The name of the button.
--- @param stayDown boolean Should the button stay down when pressed?
function ButtonSetStayDownFlag(buttonName, stayDown) end

--- Returns if a button is currently set to ‘stay down’ when pressed.
--- @param buttonName string The name of the button.
--- @return stayDown boolean Does the button stay down when pressed?
function ButtonGetStayDownFlag(buttonName) end

--- Sets if the button should behave like a check button. When set, the button will toggle between pressed and unpressed with each click.
--- @param buttonName string The name of the button.
--- @param isCheckButton boolean Should the button behave like a check button?
function ButtonSetCheckButtonFlag(buttonName, isCheckButton) end

--- Returns if the button is currently behaving like a check button.
--- @param buttonName string The name of the button.
--- @return isCheckButton boolean Is the button behaving like a check button?
function ButtonGetCheckButtonFlag(buttonName) end

--- Starts a scriped flash animation with the highlighted image.
--- @param buttonName string The name of the button.
--- @param flashDuration string The duration to flash the button (in seconds).
--- @param flashFrequency string How frequently the flash should occur (in seconds).
function ButtonStartFlash(buttonName, flashDuration, flashFrequency) end

--- Stops an active flash animation.
--- @param buttonName string The name of the button.
function ButtonStopFlash(buttonName) end

--- Sets the texture used for a particular button state.
--- @param buttonName string The name of the button.
--- @param buttonState number The button state to set, see <Button State> for valid values.
--- @param textureName string The name of the ui Texture to use.
--- @param x number The x coordinate within the texture.
--- @param y number The y coordinate within the texture.
function ButtonSetTexture(buttonName, buttonState, textureName, x, y) end

--- Sets the text color used for a particular button state.
--- @param buttonName string The name of the button.
--- @param buttonState number The button state to set, see <Button State> for valid values.
--- @param r number The red value for the text color.
--- @param g number The green value for the text color.
--- @param b number The blue value for the text color.
function ButtonSetTextColor(buttonName, buttonState, r, g, b) end

--- Returns the the current text dimensions.
--- @param buttonName string The name of the button.
--- @return x number The width of the current text
--- @return y number The height of the current text
function ButtonGetTextDimensions(buttonName) end

Button = Button or {}

Button.ButtonState = {
    NORMAL = 1,
    HIGHLIGHTED = 2,
    PRESSED = 3,
    PRESSED_HIGHLIGHTED = 4,
    DISABLED = 5,
    DISABLED_PRESSED = 6,
}
