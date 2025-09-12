--- Scans the specified directory and loads all of the .mod definition files.
--- @param directory string The directory from which to search for modules.
--- @param setName wstring The name to use to describe this set of modules.  For example, “EA Default” or “Add Ons”
function ModulesLoadFromDirectory(directory, setName) end

--- Loads a list of .mod files from a list.
--- @param listFilePath string The file path for the list of mod files.
--- @param setName wstring The name to use to describe this set of modules.  For example, “EA Default” or “Add Ons”
--- @param allowRaw wstring Are raw versions of this file permitted?
function ModulesLoadFromListFile(listFilePath, setName, allowRaw) end

--- Loads a single module path.
--- @param modFilePath string The file path for the mod file.
--- @param setName wstring The name to use to describe this set of modules.  For example, “EA Default” or “Add Ons”
--- @param allowRaw wstring Are raw versions of this mod permitted?
function ModuleLoad(modFilePath, setName, allowRaw) end

--- This loads a restricted module that is not added to the the Mod Data.
--- @param modFilePath string The file path for the mod file.
--- @param allowRaw wstring Are raw versions of this mod permitted?
function ModuleRestrictedLoad(modFilePath, allowRaw) end

--- Loads all of the the lua/xml data and runs the initialization sequence for each enabled mod.
function ModulesInitializeAllEnabled() end

--- Loads all of the the lua/xml data and runs the initialization sequence for each Restricted mod.
function ModulesInitializeRestricted() end

--- Returns a table containing the data for all loaded Ui Modules.
--- @return modDataTable table A table of Ui Modules
function ModulesGetData() end

--- Enables / Disables a single module.
--- @param moduleName string The name of the module.
--- @param enabled boolean Should this module be enabled?
function ModuleSetEnabled(moduleName, enabled) end

--- Initialize a single module.
--- @param moduleName string The name of the module.
function ModuleInitialize(moduleName) end

UiModuleManager = UiModuleManager or {}
