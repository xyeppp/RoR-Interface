
-- NOTE: This file is documented with NaturalDocs style comments. All comments begining with "--#' will
-- be included in the output.

------------------------------------------------------------------------------------------------------------------------------------------------
--# Title: Backpack Utils Mediator
--#     This file decouples windows that call Backpack functions from being directly dependent on 
--#     window "EA_Window_Backpack" or even the entire EA_BackpackWindow module. This means that alternative
--#     backpack mods could be created without breaking the other windows. If table EA_Window_Backpack is not
--#     loaded these function calls simply do nothing.
--#     
--#     Note: This is only for windows/functions that call Backpack functions after initialization. If you 
--#     need to access the EA_Window_Backpack table/functions during script/window Initialization, your module
--#     will still need to list <Dependency name="EA_BackpackWindow" /> in it's .mod file.
--#
--#     Modders that wish to create their own backpack window/behavior simply need to change the Lua table 
--#     returned by EA_BackpackUtilsMediator.GetBackpack() and define the following fields and functions:
--#			<backpackData>.windowName	- string for XML window to be opened/used ("EA_Window_Backpack" is the Mythic backpack window)
--#			function <backpackData>.Show()
--#			function <backpackData>.Hide()
--#			function <backpackData>.ToggleShowing()
--#			function <backpackData>.RequestLockForSlot( slotNum, backpackType, windowName, highLightColor )	
--#			function <backpackData>.ReleaseLockForSlot( slotNum, backpackType, windowName )
--#			function <backpackData>.ReleaseAllLocksForWindow( windowName )
--#			function <backpackData>.EnableSoftLocks( softLocksEnabled )	
--#     
--#     <backpackData> refers to whatever you name your custom Lua table. 
--#		Note that the implementation for each function can be empty if desired.
--#     The types for the parameters above are:
--#			slotNum - number, 1 based going from top down in the order they are displayed in the backpack icon view
--#			windowName - string, e.g. "EA_Window_Trade"
--#			highLightColor - table, containing the fields: r, g, and b, e.g. {r=0,g=255,b=0}
--#			softLocksEnabled - boolean, turning on/off soft locking
--
--    TODO: Right now the Backpack is runtime dependent on a bunch of other windows, mainly used for customized tooltips 
--        and the RButton autoplace feature.  These function calls should also be moved into this or another mediator to
--        lessen the coupling.
--
--     NOTE: An alternative to having modders modify the EA_BackpackUtilsMediator.GetBackpack() function in this file
--        could be to have EA_Window_Backpack (or any backpack mod) register its table dynamically.
--        
--     NOTE: If using the mediator during script/window Initialization is really needed, maybe we could add a way
--        to allow functions to register with the mediator to be called at the very end of initialization.
--
--     NOTE: It would be nice if this can be abstracted out into a more generalized Window Mediator object.
--        The table name and function name could then be passed in as strings to a general DoFunction() call.
--        We could then use this for all run-time dependencies, and even as a way of abstracting out window tables
--        so that mods can replace them at will. The big drawback to this is that we probably need to use a loadstring()
--        call to translate the windowTableName and functionName into the actual function reference.  Once we verified the function 
--        exists once we can cache the mapping between string and function. But the worst case scenario is that the function
--        is never defined but called repeatedly (and loadstring() is supposed to be a very expensive call.)
--        I guess one alternative to using loadstring() is to require the window tables to register their functions in
--        this mapping once they exist. The danger here is that any function that doesn't get registered would *never* be callable.
--        Another note for this idea in general is type-o's in the windowTableName or functionName would not be distinguishable
--        from functions that were not defined intentionally. For this reason I would want to require that all functions
--        defined in the EA version of a window table must also be defined for a mod version so that we can produce a visible error 
--        anytime a function is called before it exists.  
--
------------------------------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------
-- EA_BackpackUtilsMediator Global Variables
----------------------------------------------------------------
EA_BackpackUtilsMediator = {}


-- One of the main actions taken when right clicking an item in the backpack is to 
--   "auto move" the item into an open item slot. The table provides a list of windows
--   registered for this behavior. Each window's info (lua table) contains:
--      windowName 
--      callbackFunction
--      priority (from 1 to ??, defaults to 50, higher numbered windows will get called before lower numbered ones)
--
EA_BackpackUtilsMediator.registeredAutoMoveFunctions = {}
EA_BackpackUtilsMediator.autoMoveFunctionsAreSorted = false


----------------------------------------------------------------
-- EA_BackpackUtilsMediator Functions
----------------------------------------------------------------

--# Function: EA_BackpackUtilsMediator.GetBackpack()
--#        If using a custom mod in place of the built in EA_Window_Backpack, simply change
--#        the Lua Table returned by this function
function EA_BackpackUtilsMediator.GetBackpack()
    return EA_Window_Backpack
end

--# Function: EA_BackpackUtilsMediator.GetBackpackWindowName()
--#        If using a custom mod in place of the built in EA_Window_Backpack, you must supply a windowName field.
--#        
--#        Returns "" if the backpack is not loaded or no windowName field is specified
function EA_BackpackUtilsMediator.GetBackpackWindowName()

    local backpack = EA_BackpackUtilsMediator.GetBackpack()
    if backpack and backpack.windowName then
        return EA_BackpackUtilsMediator.SuccessReturnHandler( backpack.windowName )
    else
        return EA_BackpackUtilsMediator.FailedReturnHandler( L"EA_BackpackUtilsMediator.GetBackpackWindowName", "" )
    end
end


-- Provides a hook in case we want to take special actions when a function does not exist.
-- For now we just display an error message to the debug log/window, but another alternative
--    would be to adds an extra boolean return argument to confirm that the function was successfully called
--
function EA_BackpackUtilsMediator.FailedReturnHandler( functionName, ... )
    ERROR( L"function: "..functionName..L" has not been initialized.")
    return( ... )
end

-- Provides a hook in case we want to take special actions to show whether the function was found or not
-- 
function EA_BackpackUtilsMediator.SuccessReturnHandler( ... )
    return( ... )
end


-- verifies that a Backpack Show function exists and calls it
function EA_BackpackUtilsMediator.ShowBackpack()

    local backpack = EA_BackpackUtilsMediator.GetBackpack()
    if backpack and backpack.Show and type(backpack.Show) == "function" then
        return EA_BackpackUtilsMediator.SuccessReturnHandler( backpack.Show() )
    else
        return EA_BackpackUtilsMediator.FailedReturnHandler( L"EA_BackpackUtilsMediator.ShowBackpack" )
    end
end

-- verifies that a Backpack Hide function exists and calls it
function EA_BackpackUtilsMediator.HideBackpack()

    local backpack = EA_BackpackUtilsMediator.GetBackpack()
    if backpack and backpack.Hide and type(backpack.Hide) == "function" then
        return EA_BackpackUtilsMediator.SuccessReturnHandler( backpack.Hide() )
    else
        return EA_BackpackUtilsMediator.FailedReturnHandler( L"EA_BackpackUtilsMediator.HideBackpack" )
    end
end

-- verifies that a Backpack ToggleBackpackWindow function exists and calls it
function EA_BackpackUtilsMediator.ToggleBackpackWindow()

    local backpack = EA_BackpackUtilsMediator.GetBackpack()
    if backpack and backpack.ToggleShowing and type(backpack.ToggleShowing) == "function" then
        return EA_BackpackUtilsMediator.SuccessReturnHandler( EA_BackpackUtilsMediator.SuccessReturnHandler( backpack.ToggleShowing() ) )
    else
        return EA_BackpackUtilsMediator.FailedReturnHandler( L"EA_BackpackUtilsMediator.ToggleBackpackWindow" )
    end
end


-- verifies that a Backpack RequestLockForSlot function exists and calls it
function EA_BackpackUtilsMediator.RequestLockForSlot(slotNum, backpackType, windowName, highLightColor)

    local backpack = EA_BackpackUtilsMediator.GetBackpack()
    if backpack and backpack.RequestLockForSlot and type(backpack.RequestLockForSlot) == "function" then
        return EA_BackpackUtilsMediator.SuccessReturnHandler( backpack.RequestLockForSlot(slotNum, backpackType, windowName, highLightColor) )
    else
        return EA_BackpackUtilsMediator.FailedReturnHandler( L"EA_BackpackUtilsMediator.RequestLockForSlot" )
    end
end

-- verifies that a Backpack ReleaseLockForSlot function exists and calls it
function EA_BackpackUtilsMediator.ReleaseLockForSlot(slotNum, backpackType, windowName)

    local backpack = EA_BackpackUtilsMediator.GetBackpack()
    if backpack and backpack.ReleaseLockForSlot and type(backpack.ReleaseLockForSlot) == "function" then
        return EA_BackpackUtilsMediator.SuccessReturnHandler( backpack.ReleaseLockForSlot(slotNum, backpackType, windowName) )
    else
        return EA_BackpackUtilsMediator.FailedReturnHandler( L"EA_BackpackUtilsMediator.ReleaseLockForSlot" )
    end
end

-- verifies that a Backpack ReleaseAllLocksForWindow function exists and calls it
function EA_BackpackUtilsMediator.ReleaseAllLocksForWindow(windowName)

    local backpack = EA_BackpackUtilsMediator.GetBackpack()
    if backpack and backpack.ReleaseAllLocksForWindow and type(backpack.ReleaseAllLocksForWindow) == "function" then
        return EA_BackpackUtilsMediator.SuccessReturnHandler( backpack.ReleaseAllLocksForWindow(windowName) )
    else
        return EA_BackpackUtilsMediator.FailedReturnHandler( L"EA_BackpackUtilsMediator.ReleaseAllLocksForWindow" )
    end
end

-- verifies that a Backpack EnableSoftLocks function exists and calls it
function EA_BackpackUtilsMediator.EnableSoftLocks( softLocksEnabled )

    local backpack = EA_BackpackUtilsMediator.GetBackpack()
    if backpack and backpack.EnableSoftLocks and type(backpack.EnableSoftLocks) == "function" then
        return EA_BackpackUtilsMediator.SuccessReturnHandler( backpack.EnableSoftLocks(softLocksEnabled) )
    else
        return EA_BackpackUtilsMediator.FailedReturnHandler( L"EA_BackpackUtilsMediator.EnableSoftLocks" )
    end
end

function EA_BackpackUtilsMediator.GetCurrentBackpackType()
    local backpack = EA_BackpackUtilsMediator.GetBackpack()
    if( backpack )
    then
        return EA_BackpackUtilsMediator.SuccessReturnHandler( backpack.GetCurrentBackpackType() )
    else
        return EA_BackpackUtilsMediator.FailedReturnHandler( L"EA_BackpackUtilsMediator.GetCurrentBackpackType" )
    end
end

function EA_BackpackUtilsMediator.GetItemsFromBackpack( backpackType )
    local backpack = EA_BackpackUtilsMediator.GetBackpack()
    if( backpack )
    then
        return EA_BackpackUtilsMediator.SuccessReturnHandler( backpack.GetItemsFromBackpack( backpackType ) )
    else
        return EA_BackpackUtilsMediator.FailedReturnHandler( L"EA_BackpackUtilsMediator.GetItemsFromBackpack" )
    end
end

function EA_BackpackUtilsMediator.GetCursorForBackpack( backpackType )
    local backpack = EA_BackpackUtilsMediator.GetBackpack()
    if( backpack )
    then
        return EA_BackpackUtilsMediator.SuccessReturnHandler( backpack.GetCursorForBackpack( backpackType ) )
    else
        return EA_BackpackUtilsMediator.FailedReturnHandler( L"EA_BackpackUtilsMediator.GetCursorForBackpack" )
    end
end

-- This is part of another change list that isn't ready to checkin yet.
--[[

--# Function: EA_BackpackUtilsMediator.RegisterForBackpackAutoMove()
--#        Register a callbackFunction to get called if a backpack item is right clicked on while
--#        windowName is open. priority is a value between 1 and 100, with higher priority
--#        windows getting checked before lowered numbed ones. (priority defaults to 50)
function EA_BackpackUtilsMediator.RegisterForBackpackAutoMove( windowName, callbackFunction, priority )
	priority = priority or 50
	
	local newEntry = { windowName=windowName, callback=callbackFunction, priority=priority, }
    table.insert( EA_BackpackUtilsMediator.registeredAutoMoveFunctions, newEntry )
    EA_BackpackUtilsMediator.autoMoveFunctionsAreSorted = false
end


--# Function: EA_BackpackUtilsMediator.UnregisterForBackpackAutoMove()
--#        
--#        
function EA_BackpackUtilsMediator.UnregisterForBackpackAutoMove( windowName )

	for i, windowInfo in ipairs( EA_BackpackUtilsMediator.registeredAutoMoveFunctions ) do
		if windowInfo.windowName == windowName then
			table.remove( EA_BackpackUtilsMediator.registeredAutoMoveFunctions, i )
		end
	end
end

-- returns the sorted list of AutoMove functions
function EA_BackpackUtilsMediator.GetBackpackAutoMoveFunctions()

	if EA_BackpackUtilsMediator.autoMoveFunctionsAreSorted == false then
		table.sort( EA_BackpackUtilsMediator.registeredAutoMoveFunctions, function(a,b) return a.priority < b.priority  end )
		EA_BackpackUtilsMediator.autoMoveFunctionsAreSorted = true
	end
    return EA_BackpackUtilsMediator.registeredAutoMoveFunctions
end

-- retuns true if a registered AutoMove window is open, false otherwise
function EA_BackpackUtilsMediator.AttemptAutoMove( slot )
	
	local autoMoveFunctions = EA_BackpackUtilsMediator.GetBackpackAutoMoveFunctions()
	for i, windowInfo in ipairs( autoMoveFunctions ) do
	
		if WindowGetShowing(windowInfo.windowName) == true then
			windowInfo.callbackFunction( slot )
			return true
		end
	end
	
	return false
end

function EA_BackpackUtilsMediator.Shutdown()
	EA_BackpackUtilsMediator.registeredAutoMoveFunctions = {}
end
--]]
