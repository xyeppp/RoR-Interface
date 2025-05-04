--- Retrieves a color based on a point clicked on the color picker.
--- @param ColorPickerWindowName string The name of the color picker.
--- @param r number The r value of the color.
--- @param g number The g value of the color.
--- @param b number The b value of the color.
--- @return left number Coordinates x,y position of the topleft point Color Rect on the Color Picker window.
--- @return top number Coordinates x,y position of the topleft point Color Rect on the Color Picker window.
function ColorPickerGetCoordinatesForColor(ColorPickerWindowName, r, g, b) end

--- Retrieves a color based on a point clicked on the color picker.
--- @param ColorPickerWindowName string The name of the color picker.
--- @param x number The x position of the mouse click.
--- @param y number The y position of the mouse click.
--- @return color table containing the r, g, and b values of the color, the id and the x, y position of the top left of the color or nil if a color was not picked.
function ColorPickerGetColorAtPoint(ColorPickerWindowName, x, y) end

--- Retrieves a color based on a point clicked on the color picker.
--- @param ColorPickerWindowName string The name of the color picker.
--- @param Id number The user specified Id of the color.
--- @return r number The red value of the color.
--- @return g number The green value of the color.
--- @return b number The blue value of the color.
--- @return id number The id of the color.
--- @return x number The x postion of the color.
--- @return y number The y postion of the color.
function ColorPickerGetColorById(ColorPickerWindowName, Id) end

--- Creates a color
--- @param ColorPickerWindowName string The name of the color picker.
--- @param Colors table A table of color tables with color information (r, g, b) and their ids.  The id is user defined and has no actually significance to the color picker, but it is a useful way to track colors in lua without having to compare each r, g, b values.  Each color table can also contain optional x, y coordinates of the colors top left corner.  The order with which the colors are placed is dependent upon the order of the table.  Example: Colors = { {r=143, g=57, b=54, id=5 }, {r=50, g=10, b=113, id=17, x=100, y=200}, ...  }
--- @param Stride number The number of color columns per row.
--- @param OffsetX number The amount of pixels between each color on the x axis.
--- @param OffsetY number The amount of pixels between each color on the y axis.
function ColorPickerCreateWithColorTable(ColorPickerWindowName, Colors, Stride, OffsetX, OffsetY) end

--- Creates a color
--- @param ColorPickerWindowName string The name of the color picker.
--- @param r number the red value of the color (0 to 255).
--- @param g number the green value of the color (0 to 255).
--- @param b number the blue value of the color (0 to 255).
--- @param id number a user defined id that can be specified with the color, these ids do not have to be unique.
function ColorPickerAddColor(ColorPickerWindowName, r, g, b, id) end

--- Creates a color
--- @param ColorPickerWindowName string The name of the color picker.
--- @param r number the red value of the color (0 to 255).
--- @param g number the green value of the color (0 to 255).
--- @param b number the blue value of the color (0 to 255).
--- @param id number a user defined id that can be specified with the color, these ids do not have to be unique.
--- @param x number the left corner of where the color is to be positioned.
--- @param y number the top corner of where the color is to be positioned.
function ColorPickerAddColorAtPosition(ColorPickerWindowName, r, g, b, id, x, y) end

--- Clear all the colors from a  color picker.
--- @param ColorPickerWindowName string The name of the color picker.
function ColorPickerClear(ColorPickerWindowName) end

--- Retrieves the color spacing of a given color picker.
--- @param ColorPickerWindowName string The name of the color picker.
--- @return x number The x spacing of a single color in the color picker.
--- @return y number The y spacing of a single color in the color picker.
function ColorPickerGetColorSpacing(ColorPickerWindowName) end

--- Retrieves the color size of a given color picker.
--- @param ColorPickerWindowName string The name of the color picker.
--- @return width number The width of a single color’s texture in the color picker.
--- @return height number The height of a single color’s texture in the color picker.
function ColorPickerGetTexDims(ColorPickerWindowName) end

--- Retrieves the color size of a given color picker.
--- @param ColorPickerWindowName string The name of the color picker.
--- @return width number The width of a single color in the color picker.
--- @return height number The height of a single color in the color picker.
function ColorPickerGetColorSize(ColorPickerWindowName) end

ColorPicker = ColorPicker or {}

--- Called when the user mouses over a color point.
--- @param r number The red value of the color.
--- @param g number The green value of the color.
--- @param b number The blue value of the color.
--- @param id number The id of the color.
function ColorPicker.OnPointMouseOver(ColorPickerWindowName, r, g, b, id) end
