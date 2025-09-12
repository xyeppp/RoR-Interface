--- Loads UI resources from an xml file.
--- @param directory string The directory from which to load.
--- @param xmlFileName number The name of the main xml file
--- @param allowRaw boolean Can we load raw versions of these files, or should be only look in a Mythic-Approved archive?
function LoadResources(directory, xmlFileName, allowRaw) end

--- Registers a new set of windows with the UI system.
--- @param setId number The id # for the window set
--- @param initializationFunction string The lua-callback function to be called for initialization.
--- @param shutdownFunction string The lua-callback function to be called when this set is de-activated.
function RegisterWindowSet(setId, initializationFunction, shutdownFunction) end

--- Creates a window from an XML definition.
--- @param windowName string The name of the XML definition
--- @param show boolean Shows the window after creation if true, hides the window if false.
function CreateWindow(windowName, show) end

--- Creates a window of the specified name from an XML definition.
--- @param windowName string The desired name for the created window.
--- @param templateName string The name of the XML template to use for creation.
--- @param parent string The name of the parent this new window should be a child of.
--- @return bool Whether or not the window could be created.
function CreateWindowFromTemplate(windowName, templateName, parent) end

--- Creates a window of the specified name from an XML definition.
--- @param windowName string The desired name for the created window.
--- @param templateName string The name of the XML template to use for creation.
--- @param parent string The name of the parent this new window should be a child of.
--- @param showWindow boolean Show the window on creation.
--- @return bool Whether or not the window could be created.
function CreateWindowFromTemplateShow(windowName, templateName, parent, showWindow) end

--- Removes a window and all of it’s children from the current UI.
--- @param windowName string The name of the window.
function DestroyWindow(windowName) end

--- Returns the current screen resolution.
--- @return xRes number The x screen resolution, in pixels.
--- @return yRes number The y screen resolution, in pixels.
function GetScreenResolution() end

--- Broadcasts an event with the UI system’s assigned event processor.
--- @param eventId number The event id to broadcast.
function BroadcastEvent(eventId) end

--- Broadcasts an event with the UI system’s assigned event processor.
--- @param csvFilePath string The path for the csv file.
--- @param baseLuaVarName string The lua-table name to which to add the csv data.
function BuildTableFromCSV(csvFilePath, baseLuaVarName) end

--- Returns the data for the specified icon.
--- @param iconId string The icon id
--- @return texutureName string The texture name for the icon.
--- @return xTexCoord number The x pixel texture coordinate in the texture.
--- @return yTexCoord number The y pixel texture coordinate in the texture.
--- @return disabledTexutureName string The texture name for the disable version of the icon.
function GetIconData(iconId) end

--- Returns the data for the specified map icon.
--- @param iconId string The map icon id
--- @return texutureName string The texture name for the icon.
--- @return xTexCoord number The x pixel texture coordinate in the texture.
--- @return yTexCoord number The y pixel texture coordinate in the texture.
--- @return xSize number The x pixel size of the icon.
--- @return ySize number The y pixel size of the icon.
--- @return rTintColor number The red tint color value for the icon (0-255).
--- @return gTintColor number The green tint color value for the icon (0-255).
--- @return bTintColor number The blue tint color value for the icon (0-255).
function GetMapIconData(iconId, texture, textureX, textureY, sizeX, sizeY, pointX, pointY) end

--- Creates a new string table of the specified name from the data file.
--- @param tableName string The name for this new string table.
--- @param fileDirectory string The directory for the string table file
--- @param fileName string The file name of the string table file.
--- @param cacheDir string The cache directory to use for the string table file.
--- @param enumRoot string A lua-table name to use to create an enumeration for the string table.
function LoadStringTable(tableName, fileDirectory, fileName, cacheDir, enumRoot) end

--- Unloads the specified string table.
--- @param tableName string The name of the string table.
function UnloadStringTable(tableName) end

--- Returns the specified string from a string table
--- @param tableName string The name of the string table.
--- @param id number Index within this string table.
--- @return text string The string table entry text.
function GetStringFromTable(tableName, id) end

--- Returns a string from a string table with the substitution tags replaced by values in the params table.
--- @param tableName string The name of the string table.
--- @param id number Index within this string table.
--- @param params wstringTable A table of wide-string parameters
--- @return text string The string table entry text.
function GetStringFormatFromTable(tableName, id, params) end

--- Creates log files for all the functions & variables available to Lua.
--- @param functionsFileName string Name of file to export the list of functions.
--- @param variablesFileName string Name of file to export the list of variables.
function LogSystem(functionsFileName, variablesFileName) end

--- Creates a NaturalDocs style output file that lists all registered functions and variables.
--- @param fileName string Name of file to export the NaturalDocs output.
function CreateUIDocumentFile(fileName) end

--- Converts a string to a wstring
--- @param stringText string The string-type text.
--- @return wStringText wstring The wide-string conversion.
function StringToWString(stringText) end

--- Converts a string to a wstring
--- @param wstringText wstring The wstring-type text,
--- @return stringText string The string conversion.
function WStringToString(wstringText) end

--- Sets the master UI scale.
--- @param scale number Global scaling factor for the UI.  A scale of 1.0 is 100%.
function ScaleInterface(scale) end

--- Enables lua_errors for UI debugging.
--- @param enabled boolean True = turns on, False = turns off
function SetUseLuaErrorHandling(enabled) end

--- Returns if lua-error handling is currently turned on.
--- @return enabled boolean True = turns on, False = turns off
function GetUseLuaErrorHandling() end

--- Sets if the lua debug library should be loaded when reloading the UI.
--- @param enabled boolean True = turns on, False = turns off
function SetLoadLuaDebugLibrary(enabled) end

--- Returns if the Lua debug library will be loaded when reloading the UI
--- @return enabled boolean True = yes, False = no
function GetLoadLuaDebugLibrary() end

--- Sets if the UI should check for circular dependencies.
--- @param enabled boolean True = turns on, False = turns off
function SetCheckForCircularDependencies(enabled) end

--- Returns if the UI is currently checking for circular dependencies.
--- @return enabled boolean True = yes, False = no
function GetCheckForCircularDependencies() end

--- Inform the UI system that we are currently dragging something
--- @param itemDraggingg boolean Sets item dragging to to true/fasle
function SetItemDragging(itemDraggingg) end

--- Registers a generic lua callback event handler that is not tied to a window.
--- @param eventId number The id number of the event for which to register a callback.
--- @param callback string Full name of the lua callback function.
function RegisterEventHandler(eventId, callback) end

--- Unregisters a generic event handler that is not tied to a window.
--- @param eventId number The id number of the event for which to register a callback.
--- @param callback string Full name of the lua callback function.
function UnregisterEventHandler(eventId, callback) end

--- Force anchor processing for all windows.
function ForceProcessAllWindowAnchors() end

MythicInterface = MythicInterface or {}
