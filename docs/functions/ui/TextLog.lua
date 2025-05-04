--- Creates a new TextLog.
--- @param textLogName string The name of the TextLog.
--- @param entryLimit number The maximum number of log entries.
function TextLogCreate(textLogName, entryLimit) end

--- Destroys the specified TextLog.
--- @param textLogName string The name of the TextLog.
function TextLogDestroy(textLogName) end

--- Adds a new filter type to the specified text log.
--- @param textLogName string The name of the TextLog.
--- @param filterId number The unique ID number for this filter type.
--- @param filterPrefix wstring The text to be pre-pended to entries of this type.
function TextLogAddFilterType(textLogName, filterId, filterPrefix) end

--- Adds a new entry to the specified text log.
--- @param textLogName string The name of the TextLog.
--- @param filterId number The filter type id for this entry.
--- @param text wstring The entry text.
function TextLogAddEntry(textLogName, filterId, text) end

--- Adds a new entry to the specified text log. This is the single-byte text version of this call. The text is converted to wide-string internally for output.
--- @param textLogName string The name of the TextLog.
--- @param filterId number The filter type id for this entry.
--- @param text string The entry text.
function TextLogAddSingleByteEntry(textLogName, filterId, text) end

--- Sets if the the TextLog should be incrementally saved a file as new entires are added.
--- @param textLogName string The name of the TextLog.
--- @param incrementalSavingOn number Should the log file be saved incrementally?
--- @param filePath string The path of the file to use.
function TextLogSetIncrementalSaving(textLogName, incrementalSavingOn, filePath) end

--- Returns if incremental saving is currently enabled for the specified TextLog.
--- @param textLogName string The name of the TextLog.
--- @return incrementalSavingOn Is incremental saving enabled?
function TextLogGetIncrementalSaving(textLogName) end

--- Clears the current contents of the TextLog.
--- @param textLogName string The name of the TextLog.
function TextLogClear(textLogName) end

--- Saves the current contents of the TextLog out to the specified file.
--- @param textLogName string The name of the TextLog.
--- @param filePath string The path of the file to use.
function TextLogSaveLog(textLogName, filePath) end

--- Loads in a saved version of the TextLog from disk.
--- @param textLogName string The name of the TextLog.
--- @param filePath string The path of the file to load from.
function TextLogLoadFromFile(textLogName, filePath) end

--- Sets if the log is currently enabled.
--- @param textLogName string The name of the TextLog.
--- @param isEnabled boolean Should the log be enabled?
function TextLogSetEnabled(textLogName, isEnabled) end

--- Returns if the log is currently enabled.
--- @param textLogName string The name of the TextLog.
--- @return isEnabled boolean Is the log be enabled?
function TextLogGetEnabled(textLogName) end

--- Returns the number of entires currently in the TextLog.
--- @param textLogName string The name of the TextLog.
--- @return numEntries number The number of entries currently in the log.
function TextLogGetNumEntries(textLogName) end

--- Returns the data for a particular entry id.
--- @param textLogName string The name of the TextLog.
--- @param entryIndex number Th entry index number (between 1 and TextLogGetNumEntries)
--- @return timestamp wstring The timestamp for the entry in the format [YY/MM/DD][HH:MM:SS]
--- @return filterType number The FilterType for the entry.
--- @return text wstring The entry text.
function TextLogGetEntry(textLogName, entryIndex) end

--- Returns the event id broadcast when this text log is updated.
--- @param textLogName string The name of the TextLog.
--- @return eventId number The event id.
function TextLogGetUpdateEventId(textLogName) end

TextLog = TextLog or {}
