--- Sets the text currently displayed.
--- @param labelName string The name of the label.
--- @param text wstring The text string.
function LabelSetText(labelName, text) end

--- Returns the text currently displayed.
--- @param labelName string The name of the label.
--- @return wstring The text string.
function LabelGetText(labelName) end

--- Sets the color for the text display.
--- @param labelName string The name of the label.
--- @param red number The red value for the text color (0-255)
--- @param green number The green value for the text color (0-255)
--- @param blue number The blue value for the text color (0-255)
function LabelSetTextColor(labelName, red, green, blue) end

--- Returns the current text color for the display.
--- @param labelName string The name of the label.
--- @return red number The red value for the text color (0-255)
--- @return green number The green value for the text color (0-255)
--- @return blue number The blue value for the text color (0-255)
function LabelGetTextColor(labelName, red, green, blue) end

--- Sets the link color for the text display.
--- @param labelName string The name of the label.
--- @param red number The red value for the text color (0-255)
--- @param green number The green value for the text color (0-255)
--- @param blue number The blue value for the text color (0-255)
function LabelSetLinkColor(labelName, red, green, blue) end

--- Returns the current hyper-link color for the display.
--- @param labelName string The name of the label.
--- @return red number The red value for the hyper-link color (0-255)
--- @return green number The green value for the text color (0-255)
--- @return blue number The blue value for the text color (0-255)
function LabelGetLinkColor(labelName, red, green, blue) end

--- Sets the font for the text display
--- @param labelName string The name of the label.
--- @param fontName string The name of the font to use.
--- @param lineSpacing number The line spacing value to  use.
function LabelSetFont(labelName, fontName, lineSpacing) end

--- Returns the name of the font currently used.
--- @param labelName string The name of the label.
--- @return fontName string The name of the font.
function LabelGetFont(labelName) end

--- Returns the the current text dimensions.
--- @param labelName string The name of the label.
--- @return x number The width of the current text
--- @return y number The height of the current text
function LabelGetTextDimensions(labelName) end

--- This is a debugging function that renders the current text out to a texture.
--- @param labelName string The name of the label.
function LabelDumpGeometry(labelName) end

--- Turns on/off word wrapping
--- @param labelName string The name of the label.
--- @param wrapOn string Is word wrapping enabled? True = yes, False = no.
function LabelSetWordWrap(labelName, wrapOn) end

--- Returns if word wrapping is enabled.
--- @param labelName string The name of the label.
--- @return wrapOn string Is word wrapping enabled? True = yes, False = no.
function LabelGetWordWrap(labelName) end

--- Sets text alignment.
--- @param labelName string The name of the label.
--- @param textAlign string The alignment setting.
function LabelSetTextAlign(labelName, textAlign) end

Label = Label or {}

Label.OnHyperLinkClicked = function(labelName, linkParam) end
Label.OnHyperLinkMouseOver = function(labelName, linkParam) end
