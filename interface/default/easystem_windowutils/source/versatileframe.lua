----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

VersatileFrame = 
{
	DEBUG_ON = false,
	
	windowSettings = {},
	
	-- strings
    TOOLTIP_MINIMIZE_WINDOW = GetString( StringTables.Default.TOOLTIP_VERSATILE_FRAME_MINIMIZE_BUTTON ),
    TOOLTIP_MAXIMIZE_WINDOW = GetString( StringTables.Default.TOOLTIP_VERSATILE_FRAME_MAXIMIZE_BUTTON ),
}

	
----------------------------------------------------------------
-- Local Functions
----------------------------------------------------------------

local function SendDebug( text )
    
	if VersatileFrame.DEBUG_ON then
        DEBUG( text )
    end
end


----------------------------------------------------------------
-- VersatileFrame Functions
----------------------------------------------------------------

function VersatileFrame.Initialize()
SendDebug(L"VersatileFrame.Initialize")

	local windowName = SystemData.ActiveWindow.name
	local settings = VersatileFrame.getWindowSettings( windowName )
	
	if settings ~= nil then
		-- Init the Versatile Frame / TitleBar
		--WindowSetShowing( mainWindowName, not settings.isMinimized )
		VersatileFrame.UpdateTitleBarButtons( windowName, settings)
		
		-- NOTE: this could probably be moved into an Initialize funciton so only called once,
		--  but this way leaves us open to dynamically resizing the window as well
		settings.width, settings.height = WindowGetDimensions(settings.mainWindowName)
SendDebug( L"  Saving dims for window="..StringToWString(settings.mainWindowName)..L" as width="..settings.width..L", height="..settings.height )

		VersatileFrame.UpdateShowing( windowName )
	else
		-- TODO: provide default settings
	end
end

function VersatileFrame.getWindowSettings( windowName )
SendDebug(L"VersatileFrame.getWindowSettings for "..StringToWString(windowName) )

	return VersatileFrame.windowSettings[windowName]
end



-- function VersatileFrame.setWindowSettings( windowName, windowSettings )
--   windowSettings should be a table with data similar to this one:
--
--[[
local windowName = "WindowNameFromXML"
local windowSettings =
{
	isMinimized = false,
	isDocked = true,
	parentWindow = windowName,
	anchorWindow = windowName,
	anchorWindowPoint = "bottom",			-- attribte point in XML
	anchorPoint = "top",					-- attribte relativePoint in XML
	x="0",
	y="10",
	
	mainWindow = LuaTableOfWindowDataAndFuncs,
	mainWindowName = windowName,				-- assumption: local windowName is declared
	titleBarString = L"WindowTitle",
	
	showCloseButton = true,
	showMinMaxButton = true,
	showOptionsButton = true,
	
	closeButtonCallback = LuaTableOfWindowDataAndFuncs.someCloseFunction,		-- set this to override the default behavior of hiding both the VersatileFrame and its main window
	optionsButtonCallback = LuaTableOfWindowDataAndFuncs.someOptionsFunction,	-- 
	minMaxButtonCallback = LuaTableOfWindowDataAndFuncs.someMinMaxFunction,		-- using this will override the normal window resizing behavior
	minimizeCallback = LuaTableOfWindowDataAndFuncs.someMinimizeFunction,		-- better to use these 2 callbacks, which will be called in
	maximizeCallback = LuaTableOfWindowDataAndFuncs.someMaximizeFunction,       -- tandem with default resizing behavior
}

VersatileFrame.setWindowSettings( windowName, windowSettings )

--]]
--
function VersatileFrame.setWindowSettings( windowName, windowSettings )
SendDebug(L"VersatileFrame.setWindowSettings for "..StringToWString(windowName) )

	-- set default values for any unset settings
	windowSettings.isDocked = windowSettings.isDocked or true
	windowSettings.isMinimized = windowSettings.isMinimized or false
	windowSettings.showCloseButton = windowSettings.showCloseButton or false
	windowSettings.showMinMaxButton = windowSettings.showMinMaxButton or false
	windowSettings.showOptionsButton = windowSettings.showOptionsButton or false

	VersatileFrame.windowSettings[windowName] = windowSettings
	
	windowSettings.width, windowSettings.height = WindowGetDimensions(windowSettings.mainWindowName)
	VersatileFrame.UpdateTitleBarButtons( windowName, windowSettings )
	
	--VersatileFrame.UpdateShowing( windowName )
	-- TODO: do we need to adjust parentWindowSize?
end

function VersatileFrame.setMultipleWindowSettings( tableOfWindowSettings )
SendDebug(L"VersatileFrame.setMultipleWindowSettings" )

	for windowName, windowSettings in pairs( tableOfWindowSettings ) do
		VersatileFrame.setWindowSettings( windowName, windowSettings )
	end
	-- TODO: do we need to adjust parentWindowSize?
end


function VersatileFrame.UpdateTitleBarButtons( windowName, settings )

	if settings.titleBarString then
		LabelSetText( windowName.."BarText", settings.titleBarString )
	end
	
	
	WindowSetShowing( windowName.."Close", settings.showCloseButton )
	WindowSetShowing( windowName.."MinMaxToggle", settings.showMinMaxButton )
	WindowSetShowing( windowName.."Options", settings.showOptionsButton )
	-- TODO: may want a docked button too
	
	local anchorWindow = windowName
	local anchorPoint = "topright"
	
	if settings.showCloseButton then
		anchorWindow = windowName.."Close"
		anchorPoint = "topleft"
	end

	if settings.showMinMaxButton then
		WindowClearAnchors( windowName.."MinMaxToggle" )
		local anchorOffset = 0
		if anchorWindow == windowName then
			anchorOffset = -10
		end
		WindowAddAnchor( windowName.."MinMaxToggle", anchorPoint, anchorWindow, "topright", anchorOffset, 0 )
		anchorWindow = windowName.."MinMaxToggle"
		anchorPoint = "topleft"
	end

	if settings.showOptionsButton then
	
		WindowClearAnchors( windowName.."Options" )
		WindowAddAnchor( windowName.."Options", anchorPoint, anchorWindow, "topright", 0, 4 )
		--anchorWindow = windowName.."Options"
		--anchorPoint = "topleft"
		VersatileFrame.UpdateMinimizedButton( windowName, settings.isMinimized )
	end
	
	--VersatileFrame.UpdateDockedButton( windowName, settings.isDocked )

end


function VersatileFrame.toggleDockedButton( windowName )

	local settings = VersatileFrame.getWindowSettings( windowName )
	if settings ~= nil then
		settings.isDocked = not settings.isDocked
		VersatileFrame.UpdateDockedButton( windowName, settings.isDocked )
	else
		-- TODO: provide default settings
	end
end

function VersatileFrame.toggleMinimizeButton( windowName, settings )
SendDebug(L"VersatileFrame.toggleMinimizeButton")

	if settings ~= nil then
	
		VersatileFrame.UpdateMinimizedButton( windowName, settings.isMinimized )	
		-- TODO: actually change the window size
	else
		-- TODO: provide default settings
	end
end


-- NOTE: It is assumed windowName correctly has a Close and MinMaxToggle button
function VersatileFrame.UpdateDockedButton( windowName, isDocked )

	-- TODO: we may want to allow externally docked windows to be movable.
	--   Dragging them should then automatically set the windows docked flag to false
	--   ?or maybe drag the parent window as well?
	--
	WindowSetMovable( windowName, (not isDocked) )
	--WindowSetShowing( windowName.."Close", (not isDocked) )
	--WindowSetShowing( windowName.."MinMaxToggle", isDocked )
end

-- NOTE: It is assumed windowName correctly has a MinMaxToggle button
function VersatileFrame.UpdateMinimizedButton( windowName, isMinimized )

	WindowSetShowing( windowName.."MinMaxToggleMinButton", (not isMinimized) )
	WindowSetShowing( windowName.."MinMaxToggleMaxButton", isMinimized )
end

-- Minimize/Maximize Button Handler
function VersatileFrame.UpdateShowing( windowName )
SendDebug(L"VersatileFrame.UpdateShowing")

	local settings = VersatileFrame.getWindowSettings( windowName )
	if settings.isMinimized == true then
		VersatileFrame.Minimize( windowName, settings )
	else
		VersatileFrame.Maximize( windowName, settings )
	end
	VersatileFrame.UpdateMinimizedButton( windowName, settings.isMinimized )
	
	if settings.isClosed ~= nil then
		WindowSetShowing( windowName, not settings.isClosed )
		if settings.mainWindowName then
			WindowSetShowing( settings.mainWindowName, not settings.isClosed )
		end
	end
	
	if settings.parentWindow then
		VersatileFrame.ResizeWindow( settings.parentWindow )
	end
	
end


-- Close Button Handler
function VersatileFrame.OnCloseButtonPressed()
SendDebug(L"VersatileFrame.OnCloseButtonPressed")

	local windowName = WindowGetParent( SystemData.ActiveWindow.name )
	local settings = VersatileFrame.getWindowSettings( windowName )
	
	if settings.closeButtonCallback and type( settings.closeButtonCallback ) == "function" then
		settings.closeButtonCallback( windowName )
	elseif settings.mainWindowName then
		WindowSetShowing( windowName, false )
		WindowSetShowing( settings.mainWindowName, false )
	end
end


-- Options Button Handler
function VersatileFrame.OnOptionsButtonPressed()
SendDebug(L"VersatileFrame.OnOptionsButtonPressed")

	local windowName = WindowGetParent( SystemData.ActiveWindow.name )
	local settings = VersatileFrame.getWindowSettings( windowName )
	
	if settings.optionsButtonCallback and type( settings.optionsButtonCallback ) == "function" then
		settings.optionsButtonCallback( windowName )
	end
end


-- Options Button Handler
function VersatileFrame.OnOptionsButtonMouseOver()
SendDebug(L"VersatileFrame.OnOptionsButtonMouseOver")

	local windowName = WindowGetParent( SystemData.ActiveWindow.name )
	local settings = VersatileFrame.getWindowSettings( windowName )
	
	if settings.optionsButtonMouseOverCallback and type( settings.optionsButtonMouseOverCallback ) == "function" then
		settings.optionsButtonMouseOverCallback( windowName )
	end
end

-- Minimize/Maximize Button Handler
function VersatileFrame.OnMinMaxTogglePressed()
SendDebug(L"VersatileFrame.OnMinMaxTogglePressed")

	local windowName = WindowGetParent( SystemData.ActiveWindow.name )
	local settings = VersatileFrame.getWindowSettings( windowName )
	
	settings.isMinimized = not settings.isMinimized
	VersatileFrame.UpdateShowing( windowName )
	
	VersatileFrame.DisplayTooltip( windowName )
end


-- Minimize/Maximize Mouse Over Handler
function VersatileFrame.OnMinMaxToggleMouseOver()
SendDebug(L"VersatileFrame.OnMinMaxToggleMouseOver")

SendDebug(L"    SystemData.ActiveWindow.name  = "..StringToWString(SystemData.ActiveWindow.name) )
SendDebug(L"    parent  = "..StringToWString(WindowGetParent(SystemData.ActiveWindow.name)) )
	local windowName = WindowGetParent( SystemData.ActiveWindow.name )
	VersatileFrame.DisplayTooltip( windowName )

end


function VersatileFrame.DisplayTooltip( windowName )

	local text 
	if WindowGetShowing( windowName.."MinMaxToggleMinButton" ) == true then
		text = VersatileFrame.TOOLTIP_MINIMIZE_WINDOW
	else
		text = VersatileFrame.TOOLTIP_MAXIMIZE_WINDOW
	end
	Tooltips.CreateTextOnlyTooltip( windowName.."MinMaxToggle", text )
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_TOP)
end

function VersatileFrame.Minimize( windowName, settings )
SendDebug(L"VersatileFrame.Minimize")
	
	-- show only the Titlebar and set the window dimensions to its dimensions
	--local minimizedWidth, minimizedHeight = WindowGetDimensions( settings.minimizedWindowName )
	WindowSetDimensions( settings.mainWindowName, settings.width, 0 )
	
	if settings.mainWindow and settings.mainWindow.Hide then
		settings.mainWindow.Hide()
	else
		WindowSetShowing( settings.mainWindowName, false )
	end
	
	settings.isMinimized = true
end

function VersatileFrame.Maximize( windowName, settings )
SendDebug(L"VersatileFrame.Maximize")

	if windowName == nil then
		ERROR( L"VersatileFrame.Maximize ERROR: windowName must be provided" )
		return
	end
	
	settings = settings or VersatileFrame.getWindowSettings( windowName )
	if settings == nil then
		ERROR( L"VersatileFrame.Maximize ERROR: no settings found for window = "..StringToWString(windowName) )
		return
	end
	
	-- show entire window and set the window dimensions back to normal 
	WindowSetDimensions( settings.mainWindowName, settings.width, settings.height )
SendDebug( L" maximizing "..StringToWString(settings.mainWindowName)..L" to previous dims, width="..settings.width..L", height="..settings.height )
	
	if settings.mainWindow and settings.mainWindow.Show then
		settings.mainWindow.Show()
	else
		WindowSetShowing( settings.mainWindowName, true )
	end
	
	settings.isMinimized = false
end


-- NOTE: instead of resetting anchors all of the time depending on whether the window is min/maximized, 
--   I've made minimize just change the window height to 0 and maximize restore it.
--
function VersatileFrame.ResizeWindow( parentWindow )
SendDebug(L"VersatileFrame.ResizeWindow")

	local x, y
	local width, height = 0, 0
	
	-- NOTE: need to make sure settings.y for first window includes the size of the parent window
	--	 title bar and any other windows not set in the VersatileFrame Manager
	for name, settings in pairs(VersatileFrame.windowSettings) do
	
		if (settings.parentWindow ~= parentWindow) or 
		   ( (settings.isClosed ~= nil) and (settings.isClosed == true) ) then
			continue
		end
		
		x, y = WindowGetDimensions(name)
		height = height + y 
		if settings.y then		-- settings.y is the vertical offset from it's anchor
			height = height + settings.y	
		end	
		if x > width then
			width = x
		end
		
		if settings.isMinimized == false then
			x, y = WindowGetDimensions(settings.mainWindowName)
			height = height + y
		end
		--[[
		if settings.isMinimized == true then
			lastVisibleWindow = name
		else
			lastVisibleWindow = settings.mainWindowName
		end
		--]]
	end
	WindowSetDimensions(parentWindow, width, height)
end
