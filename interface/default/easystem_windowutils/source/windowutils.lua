
-- NOTE: This file is doccumented with NaturalDocs style comments. All comments begining with "--#' will
-- be included in the output.

------------------------------------------------------------------------------------------------------------------------------------------------
--# Title: Window Utils
--#     This file contains window utility functions.
------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------
-- WindowUtil Global Variables
----------------------------------------------------------------
WindowUtils =
{
    resizing = false,
    resizeWindow = nil,
    resizeAnchor = "",
    resizeEndCallback = nil,
    resizeMin = { x=0, y=0 },

    stateButtons = {},

    openWindowList = {},

    FONT_DEFAULT_TEXT_LINESPACING           = 20,
    FONT_DEFAULT_SUB_HEADING_LINESPACING    = 22,

    Cascade =
    {
        -- This mode tracks the window in the open list but does not enforce layout.
        MODE_NONE        = 0,
        -- This mode automatically places the window somewhere on the screen and may close other
        --   windows with this mode if there are too many to fit new ones.
        MODE_AUTOMATIC   = 1,
        -- There can be only one of these windows up.  Any other windows also using this mode will be closed
        --   when opening a window using this mode. Also autoplaced.
        MODE_HIGHLANDER  = 2,
        
        WINDOW_TOP_DISTANCE = 175,
        WINDOW_SPACING      = 35,
        
        List = { },
        pendingResolve = false,
    },
}

----------------------------------------------------------------
-- WindowUtil Local Functions
----------------------------------------------------------------
local function NewCascadeEntry(windowName, closeCallback, layoutMode)
    return { name = windowName, closeFunction = closeCallback, mode = layoutMode } 
end

----------------------------------------------------------------
-- WindowUtil Functions
----------------------------------------------------------------

function WindowUtils.Initialize()
    
    CreateWindow( "ResizingWindowFrame", false )
    
    RegisterEventHandler( SystemData.Events.L_BUTTON_UP_PROCESSED, "WindowUtils.OnLButtonUpProcessed")  
    
    WindowRegisterEventHandler( "Root", SystemData.Events.ESCAPE_KEY_PROCESSED, "WindowUtils.EscapeKeyProcessed")
    
    WindowUtils.openWindowList = { }
end

function WindowUtils.Shutdown()

    UnregisterEventHandler( SystemData.Events.L_BUTTON_UP_PROCESSED,   "WindowUtils.OnLButtonUpProcessed")  
    
end


function WindowUtils.Update( timePassed )

    -- Update the resize frame
    if( WindowUtils.resizing ) then
    
        local x, y = WindowGetDimensions( "ResizingWindowFrame" )  
        local resize = false;
        
        if( x < WindowUtils.resizeMin.x  ) then
            x = WindowUtils.resizeMin.x
            resize = true
        end
        if( y < WindowUtils.resizeMin.y ) then
            y = WindowUtils.resizeMin.y
            resize = true
        end
        
        if( resize ) then
            --DEBUG(L"Resizing: "..x..L", "..y )
            WindowSetDimensions( "ResizingWindowFrame", x, y )
        end

    end
end

-- Implementation Functions
-- Handles mouseover tooltips for a generic window (button)

function WindowUtils.OnMouseOverButton (btnName, key, text, anchor )
    
    Tooltips.CreateTextOnlyTooltip( SystemData.MouseOverWindow.name, nil ) 
    
    local row = 1
    local column = 1
    Tooltips.SetTooltipText( row, column, btnName )

    if( key ~= nil ) then
        column = column + 1 
        Tooltips.SetTooltipColor( row, column, 140, 100, 0 )
        Tooltips.SetTooltipText( row, column, L"("..key..L")" )
    end
    
   if( text ~= nil ) then
        row = row + 1
        column =  1 
        Tooltips.SetTooltipText( row, column, text )
    end
    
    Tooltips.Finalize()

	if( anchor ~= nil ) 
	then
	    Tooltips.AnchorTooltip( anchor )
	else
		Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_BOTTOM )
	end
end

function WindowUtils.BeginResize( windowName, anchorCorner, minX, minY, endCallback )

    if ( WindowUtils.resizing ) then
        return
    end
    if ( not WindowGetMovable(windowName) ) then
        return
    end

    -- Anchor the resizing frame to the window
    local width, height = WindowGetDimensions( windowName )
    local scale = WindowGetScale(windowName)

    WindowSetScale( "ResizingWindowFrame", scale )
    WindowSetDimensions( "ResizingWindowFrame", width, height )
    
    WindowAddAnchor( "ResizingWindowFrame", anchorCorner, windowName, anchorCorner, 0, 0 )

    WindowSetResizing( "ResizingWindowFrame", true, anchorCorner, false );
    WindowSetShowing( "ResizingWindowFrame", true )
    
    WindowUtils.resizing = true
    WindowUtils.resizeWindow = windowName
    WindowUtils.resizeAnchor = anchorCorner
    WindowUtils.resizeMin.x = minX
    WindowUtils.resizeMin.y = minY
    WindowUtils.resizeEndCallback = endCallback
    --DEBUG(L"BeginResize: "..minX..L", "..minY )    
    
    SetHardwareCursor(SystemData.Cursor.RESIZE2)
end 

function WindowUtils.EndResize()

    if ( not WindowUtils.resizing ) then
        return
    end

    local width, height = WindowGetDimensions( "ResizingWindowFrame" )
    local posX, posY = WindowGetScreenPosition( "ResizingWindowFrame"  )
    
    -- Detatch and Hide the Resizing Frame  
    WindowSetResizing( "ResizingWindowFrame", false, "", false );
    WindowClearAnchors( "ResizingWindowFrame" )
    WindowSetShowing( "ResizingWindowFrame", false )    
     
    -- Assign the settings to the new window
    WindowSetDimensions( WindowUtils.resizeWindow, width, height )      
    
    local uiScale = InterfaceCore.GetScale()
    WindowClearAnchors( WindowUtils.resizeWindow )
    WindowAddAnchor( WindowUtils.resizeWindow, "topleft", "Root", "topleft", posX/uiScale, posY/uiScale )   

    -- Clear the Resizing Data
    WindowUtils.resizing = false
    WindowUtils.resizeWindow = nil
    WindowUtils.resizeAnchor = nil
    
    if( WindowUtils.resizeEndCallback ~= nil ) then
        WindowUtils.resizeEndCallback()
        WindowUtils.resizeEndCallback = nil
    end
    
    ClearCursor()
end

--------------------------------------------------------------------------------------
-- General Button Callbacks

function WindowUtils.OnLButtonUpProcessed( flags, x, y )
    -- End the resize
    if( WindowUtils.resizing ) then    
        WindowUtils.EndResize()      
    end
end

-- Function To Toggle Showing a Window
function WindowUtils.ToggleShowing( windowName )
    if( windowName == nil or not DoesWindowExist( windowName ) )
    then
        ERROR(L"WindowUtils.ToggleShowing(): Trying to toggle window that does not exist.")
        return
    end
    
    local showing = WindowGetShowing( windowName )
    WindowSetShowing( windowName, not showing )
end

-- Open Window List Functions
function WindowUtils.AddToOpenList( windowName, closeCallback, layoutMode )
    --DEBUG(L"WindowUtils.AddToOpenList: "..StringToWString(windowName) )
    
    for windowIndex, openWindowName in ipairs( WindowUtils.openWindowList )
    do
        if ( openWindowName == windowName ) then
            --ERROR(L"Returning out of WindowUtils.AddToOpenList because of duplicate name trying to be added: "..StringToWString(windowName))
            return -- do not add windows twice to the openlist
        end
    end
    
    if (layoutMode == nil) or (layoutMode == WindowUtils.Cascade.MODE_NONE)
    then
        -- Do nothing.
    elseif (layoutMode == WindowUtils.Cascade.MODE_AUTOMATIC)
    then
        WindowUtils.Cascade.SetResolvePending()
        --  Place this window at the end of the list.
        table.insert( WindowUtils.Cascade.List, #WindowUtils.Cascade.List + 1, NewCascadeEntry(windowName, closeCallback, layoutMode) )
        WindowUtils.Cascade.Resolve()
    elseif (layoutMode == WindowUtils.Cascade.MODE_HIGHLANDER)
    then
        WindowUtils.Cascade.SetResolvePending()

        -- Do we have any other Highlander windows up?
        if ( ( #WindowUtils.Cascade.List > 0) and
             (WindowUtils.Cascade.List[1].mode == WindowUtils.Cascade.MODE_HIGHLANDER) )
        then
            --   If yes, close it.
            if (WindowUtils.Cascade.List[1].closeFunction ~= nil)
            then
                WindowUtils.Cascade.List[1].closeFunction()
            else
                WindowSetShowing( windowName, false )
                table.remove( WindowUtils.Cascade.List, 1 )
            end
        end

        -- Place this window in the 'furthest left' slot, move other windows over.
        table.insert( WindowUtils.Cascade.List, 1, NewCascadeEntry(windowName, closeCallback, layoutMode) )
        WindowUtils.Cascade.Resolve()
    end
    
    table.insert( WindowUtils.openWindowList, windowName )
    --DEBUG(L"Num Windows in the Open List: "..#WindowUtils.openWindowList)
end

function WindowUtils.RemoveFromOpenList( windowName )
    --DEBUG(L"WindowUtils.RemoveFromOpenList: "..StringToWString(windowName) )

    for window = 1, #WindowUtils.Cascade.List
    do
        if( windowName == WindowUtils.Cascade.List[window].name )
        then
            table.remove( WindowUtils.Cascade.List, window )
            
            if (not WindowUtils.Cascade.IsResolvePending())
            then
                WindowUtils.Cascade.Resolve()
            end
            break
        end
    end

    for window = 1, #WindowUtils.openWindowList
    do
        if( windowName == WindowUtils.openWindowList[window] )
        then
            table.remove( WindowUtils.openWindowList, window )
            --DEBUG(L"Num Windows in the Open List: "..#WindowUtils.openWindowList)       
            return
        end
    end
    
    --DEBUG(L"Failed to Remove Window from Open List!")
    --DEBUG(L"Num Windows in the Open List: "..#WindowUtils.openWindowList)
end

function WindowUtils.ClearOpenList()
    -- Make a copy of openWindowList, because WindowSetShowing will modify it
    copyOpenWindowList = {}
    for window = 1, #WindowUtils.openWindowList
    do
        table.insert(copyOpenWindowList, WindowUtils.openWindowList[window])
    end
    for window = 1, #copyOpenWindowList
    do
        if( WindowGetShowing( copyOpenWindowList[ window ] ) )
        then
            WindowSetShowing( copyOpenWindowList[ window ], false )
        end
    end
    WindowUtils.openWindowList = {}
end


function WindowUtils.EscapeKeyProcessed()
    --DEBUG(L"WindowUtils.EscapeKeyProcessed()")
    if( SystemData.InputProcessed.EscapeKey == true ) then
        return
    end

    -- Default handing for the escape key

    -- (1) Cancel the active ability, returns false if there was nothing to cancel
    if( Player.CancelSpell() ) 
    then
        return;
    end 

    -- (2) Close Windows 
    if( #WindowUtils.openWindowList > 0 ) 
    then
        --CHAT_DEBUG(L"Closing Window: "..StringToWString(WindowUtils.openWindowList[ #WindowUtils.openWindowList ]) )
        --DEBUG(L"Num Windows in the Open List: "..#WindowUtils.openWindowList)
        --DEBUG(L"Window Trying To Hide: "..StringToWString(WindowUtils.openWindowList[ #WindowUtils.openWindowList ]))
        
        if( WindowGetShowing( WindowUtils.openWindowList[ #WindowUtils.openWindowList ] ) )
        then
            WindowSetShowing( WindowUtils.openWindowList[ #WindowUtils.openWindowList ], false )
        else
            -- The window is not showing but it is the top window in the openList... This is an error, so try to remove it
            WindowUtils.RemoveFromOpenList( WindowUtils.openWindowList[ #WindowUtils.openWindowList ] )
        end
        return
    end
    
    -- (3) Clear Hostile Target
    if( TargetInfo:UnitName(TargetInfo.HOSTILE_TARGET) ~= L"" ) 
    then
        --CHAT_DEBUG(L"Clearing Hostile Target")
        ClearTarget( GameData.TargetType.HOSTILE )
        return
    end
    
    -- (4) Clear Friendly Target
    if( TargetInfo:UnitName(TargetInfo.FRIENDLY_TARGET) ~= L"" ) 
    then
        --CHAT_DEBUG(L"Clearing Friendly Target")
        ClearTarget( GameData.TargetType.FRIENDLY )
        return
    end
    
    -- (4) Toggle the Main Menu
    --CHAT_DEBUG(L"Toggling Menu" )
    if( MenuBarWindow )
    then
        MenuBarWindow.ToggleMenuWindow()
    end
end

function WindowUtils.TrapClick()
    -- Just prevents the click from going through to the world.
end

function WindowUtils.OnShown(closeCallback, mode)
    local windowName = SystemData.ActiveWindow.name
    -- DEBUG(L"WindowUtils.OnShown(): "..StringToWString(windowName))
    
    WindowUtils.AddToOpenList( windowName, closeCallback, mode )
    
    if( WindowUtils.stateButtons[ windowName ]  ) then
        for index, buttonName in ipairs(  WindowUtils.stateButtons[ windowName ] ) do
            ButtonSetPressedFlag( buttonName, true )
        end
    end
end

function WindowUtils.OnHidden()
    --DEBUG(L"WindowUtils.OnHidden(): "..StringToWString(SystemData.ActiveWindow.name))
    WindowUtils.RemoveFromOpenList( SystemData.ActiveWindow.name )
    
    if( WindowUtils.stateButtons[ SystemData.ActiveWindow.name ]  ) then
        for index, buttonName in ipairs(  WindowUtils.stateButtons[ SystemData.ActiveWindow.name ] ) do
            ButtonSetPressedFlag( buttonName, false )
        end
    end
end

function WindowUtils.HideParentWindow()
   WindowSetShowing( WindowGetParent( SystemData.ActiveWindow.name ), false )
end

function WindowUtils.AddWindowStateButton( buttonName, windowName )

    if( WindowUtils.stateButtons[ windowName ] == nil ) then
        WindowUtils.stateButtons[ windowName ] = {}
    end
    
    table.insert( WindowUtils.stateButtons[ windowName ], buttonName )

end

----------------------------------------------------------------
-- WindowUtil Cascade Functions
----------------------------------------------------------------
function WindowUtils.Cascade.SetResolvePending()
    WindowUtils.Cascade.pendingResolve = true
end

function WindowUtils.Cascade.IsResolvePending()
    return WindowUtils.Cascade.pendingResolve
end

function WindowUtils.Cascade.Resolve()
    -- DEBUG(L"WindowUtils.Cascade.Resolve()")
    
    -- Traverse the list, relayout windows.
    local keepList   = {}
    local removeList = {}
    
    -- First loop, determine which windows to keep.
    local canPlaceMoreWindows = true
    local currentX = WindowUtils.Cascade.WINDOW_SPACING
    for windowIndex = #WindowUtils.Cascade.List, 1, -1
    do
        local windowData = WindowUtils.Cascade.List[windowIndex]
        local windowName = windowData.name

        -- Will it fit?
        local rawX, rawY = WindowGetDimensions(windowName)
        local windowScale = WindowGetScale(windowName)
        
        local scaledWidth  = rawX * windowScale
        local fullX, fullY = WindowGetDimensions("Root")
        -- DEBUG(L"  Size "..scaledWidth..L" + current "..currentX..L" < "..fullX)
        
        if (canPlaceMoreWindows) and (scaledWidth + currentX < fullX)
        then
            currentX = currentX + scaledWidth + WindowUtils.Cascade.WINDOW_SPACING
            table.insert(keepList, 1, windowData)
        else
            table.insert(removeList, windowData)
            canPlaceMoreWindows = false
        end
    end
    
    -- Second loop, place the kept windows
    local layoutX = WindowUtils.Cascade.WINDOW_SPACING
    local layoutY = WindowUtils.Cascade.WINDOW_TOP_DISTANCE
    for _, windowData in pairs(keepList)
    do
        local windowName = windowData.name
        local rawX, rawY = WindowGetDimensions(windowName)
        
        -- If so, space it and place it.
        WindowClearAnchors( windowName )
        WindowAddAnchor( windowName, "topleft", "Root", "topleft", layoutX, layoutY )
        -- DEBUG(L"    placing "..StringToWString(windowName)..L" at ("..layoutX..L", "..layoutY..L")")
        
        -- Move position point over to where next window will go.
        layoutX = layoutX + rawX + WindowUtils.Cascade.WINDOW_SPACING
    end

    -- Third loop, close the remove windows
    for _, windowData in pairs(removeList)
    do
        local windowName = windowData.name
        -- DEBUG(L"    removing "..StringToWString(windowName))

        if (windowData.closeFunction ~= nil)
        then
            windowData.closeFunction()
        else
            WindowSetShowing(windowName, false)
        end
    end
    
    WindowUtils.Cascade.pendingResolve = false

end
