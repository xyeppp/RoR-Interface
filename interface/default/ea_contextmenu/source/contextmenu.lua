----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_ContextMenu = {}
EA_Window_ContextMenu.activeWindow = nil
EA_Window_ContextMenu.contextMenus = {}
EA_Window_ContextMenu.numContextMenus = 0
EA_Window_ContextMenu.CONTEXT_MENU_1 = 1
EA_Window_ContextMenu.CONTEXT_MENU_2 = 2
EA_Window_ContextMenu.CONTEXT_MENU_3 = 3
EA_Window_ContextMenu.MIN_WIDTH = 245



-- Spacing
EA_Window_ContextMenu.MINIMUM_X_OFFSET = 10

EA_Window_ContextMenu.BORDER_SPACING = 5
EA_Window_ContextMenu.TITLE_SPACING = 10
EA_Window_ContextMenu.TITLE_OFFSET = 5
EA_Window_ContextMenu.BUTTON_TEXT_OFFSET = 5

-- Menu Item Types
EA_Window_ContextMenu.MENU_ITEM_DEFAULT   = 1
EA_Window_ContextMenu.MENU_ITEM_CASCADING = 2
EA_Window_ContextMenu.MENU_ITEM_DIVIDER   = 3
EA_Window_ContextMenu.NUM_MENU_ITEM_TYPES = 3

EA_Window_ContextMenu.ItemTypes =
{
    [EA_Window_ContextMenu.MENU_ITEM_DEFAULT]   = { 
                                                    name = "DefaultItem",
                                                    template = "EA_Button_ContextMenuItem",
                                                    hasText = true,
                                                    extraWidth = 0,
                                                    anchors = {
                                                                [1]={ Point = "bottom",  RelativePoint = "top", XOffset = 0, YOffset = 0 } 
                                                              }
                                                  },
                                                  
    [EA_Window_ContextMenu.MENU_ITEM_CASCADING]   = {
                                                     name = "CascadingItem", 
                                                     template = "EA_Button_CascadingContextMenuItem",
                                                     hasText = true,
                                                     extraWidth = 18,   -- Width of the arrow plus a little extra padding
                                                     anchors = {
                                                                [1]={ Point = "bottom",  RelativePoint = "top", XOffset = 0, YOffset = 0 } 
                                                               }
                                                    },
                                                  
    [EA_Window_ContextMenu.MENU_ITEM_DIVIDER]   = { 
                                                    name = "Divider",
                                                    template = "EA_Window_DefaultContextMenuDivider",
                                                    hasText = false,
                                                    extraWidth = 0,
                                                    anchors = {
                                                                [1]={ Point = "bottomleft",  RelativePoint = "topleft", XOffset = 0, YOffset = 0 }, 
                                                                [2]={ Point = "bottomright",  RelativePoint = "topright", XOffset = 0, YOffset = 0 } 
                                                              }
                                                  },


}



----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

local function CreateContextMenu( windowName )
    if( not DoesWindowExist( windowName ) )
    then
        CreateWindowFromTemplate( windowName, "EA_Window_ContextMenu", "Root" )
    end
    
    EA_Window_ContextMenu.numContextMenus = EA_Window_ContextMenu.numContextMenus + 1
    WindowSetId( windowName, EA_Window_ContextMenu.numContextMenus )
    EA_Window_ContextMenu.contextMenus[ EA_Window_ContextMenu.numContextMenus ] =
    {
        numMenuItems = {},
        numActiveMenuItems = {},
        numTotalActiveMenuItems = 0,
        
        name = windowName,
        anchorWindow = name,
        functionTable = {},
        greatestWidth = 0,
        numUserDefinedMenuItems = 0,
        userDefinedMenuItems = {},
    }
        
    for index = 1, EA_Window_ContextMenu.NUM_MENU_ITEM_TYPES
    do
        EA_Window_ContextMenu.contextMenus[ EA_Window_ContextMenu.numContextMenus ].numMenuItems[index] = 0;
        EA_Window_ContextMenu.contextMenus[ EA_Window_ContextMenu.numContextMenus ].numActiveMenuItems[index] = 0; 
    end  
    
    
    WindowSetShowing( windowName, false )
end


function EA_Window_ContextMenu.GameActionData( param_actionType, param_actionId, param_actionText )
    return { actionType=param_actionType, actionId=param_actionId, actionText=param_actionText }
end


----------------------------------------------------------------
-- Context Menu Functions
----------------------------------------------------------------

-- OnInitialize Handler
function EA_Window_ContextMenu.Initialize()
    EA_Window_ContextMenu.numContextMenus = 0
    
    -- Create three context menus
    for index=1, 3
    do
        CreateContextMenu( "EA_Window_ContextMenu"..(EA_Window_ContextMenu.numContextMenus + 1) )
    end
    
    --Register events to close the window
    WindowRegisterEventHandler( "EA_Window_ContextMenu1", SystemData.Events.L_BUTTON_DOWN_PROCESSED, "EA_Window_ContextMenu.OnLButtonProcessed")
    WindowRegisterEventHandler( "EA_Window_ContextMenu1", SystemData.Events.R_BUTTON_DOWN_PROCESSED, "EA_Window_ContextMenu.OnRButtonProcessed")
    
    if( not DoesWindowExist( "EA_Window_SetOpacity") )
    then
        CreateWindow( "EA_Window_SetOpacity", false )
    end
    
    LabelSetText("EA_Window_SetOpacityTitleBarText", GetString( StringTables.Default.LABEL_OPACITY ) )
end

-- OnShutdown Handler
function EA_Window_ContextMenu.Shutdown()
end

function EA_Window_ContextMenu.Show( contextMenuNumber )
    local windowName = "EA_Window_ContextMenu1"
    if( contextMenuNumber )
    then
        windowName = "EA_Window_ContextMenu"..contextMenuNumber
    end
    WindowSetShowing( windowName, true )
end

function EA_Window_ContextMenu.Hide( contextMenuNumber )
    local windowName = "EA_Window_ContextMenu1"
    if( contextMenuNumber )
    then
        windowName = "EA_Window_ContextMenu"..contextMenuNumber
    end
    WindowSetShowing( windowName, false )
end

function EA_Window_ContextMenu.HideAll()
    for index = 1, EA_Window_ContextMenu.numContextMenus
    do
        if( EA_Window_ContextMenu.contextMenus[index] )
        then
            WindowSetShowing( EA_Window_ContextMenu.contextMenus[index].name, false )
        end
    end
end

-- Call this first before adding any menu items... if just using the default context menu
-- this will be called for you in the function CreateDefaultContextMenu
-- If windowNameToActUpon is empty string  (""), then it uses the last known activeWindow
function EA_Window_ContextMenu.CreateContextMenu( windowNameToActUpon, contextMenuNumber, menuTitleText )
    if( not contextMenuNumber )
    then
        contextMenuNumber = EA_Window_ContextMenu.CONTEXT_MENU_1
    end
    
    if ( windowNameToActUpon == "" ) 
    then
        windowNameToActUpon = EA_Window_ContextMenu.activeWindow
    end
    --Set up the ContextMenu for a new menu
    local contextMenu = EA_Window_ContextMenu.contextMenus[ contextMenuNumber ]
    if( contextMenu )
    then
        EA_Window_ContextMenu.activeWindow = windowNameToActUpon
        
        -- Reset the Data
        contextMenu.anchorWindow = contextMenu.name.."Anchor"
        contextMenu.functionTable = {}
        contextMenu.greatestWidth = 0
        contextMenu.numUserDefinedMenuItems = 0
        contextMenu.numTotalActiveMenuItems = 0  
              
        for index = 1, EA_Window_ContextMenu.NUM_MENU_ITEM_TYPES
        do
            contextMenu.numActiveMenuItems[index] = 0
        end     
        
        -- Set the Title       
        WindowClearAnchors( contextMenu.name.."Anchor" )         
        if( menuTitleText == nil or menuTitleText == L"" )
        then
            menuTitleText = L""            
            WindowAddAnchor( contextMenu.name.."Anchor", "top", contextMenu.name, "top", 0, EA_Window_ContextMenu.BORDER_SPACING  )            
        else
            WindowAddAnchor( contextMenu.name.."Anchor", "bottom", contextMenu.name.."Title", "top", 0, EA_Window_ContextMenu.TITLE_SPACING  )
        end        
        LabelSetText( contextMenu.name.."Title", menuTitleText )
        
        -- Clear Any User-Defined Menu Items
        for index, menuItemName in ipairs( contextMenu.userDefinedMenuItems )
        do
            WindowSetParent( menuItemName, "Root" )
            WindowSetShowing( menuItemName, false )
        end

        
        contextMenu.userDefinedMenuItems = {}
    end
end


-- This function does the real work of adding a menu item to a context menu.  It not meant to be called externally.
-- It handles things like setting the text of the item, creating the item from a template on demand, naming the item
-- setting the up the function callback, and anchoring the item
local function InternalAddMenuItem( type, buttonText, callbackFunction, bDisabled, bCloseAfterClick, contextMenuNumber, gameActionData )

    if( not contextMenuNumber )
    then
        contextMenuNumber = EA_Window_ContextMenu.CONTEXT_MENU_1
    end
    
    local contextMenu = EA_Window_ContextMenu.contextMenus[ contextMenuNumber ]
    
    if( not contextMenu )
    then
        return
    end
    
    -- Access the Menu Item Type Data
    local menuTypeData = EA_Window_ContextMenu.ItemTypes[type]
    if( menuTypeData == nil )
    then
        return
    end
    
    
    -- Create the Item if needed
    contextMenu.numActiveMenuItems[type] = contextMenu.numActiveMenuItems[type] + 1
    local menuItemWindowName = contextMenu.name..menuTypeData.name..contextMenu.numActiveMenuItems[type]
    
    if( contextMenu.numMenuItems[type] < contextMenu.numActiveMenuItems[type] ) 
    then
        contextMenu.numMenuItems[type] = contextMenu.numMenuItems[type] + 1
        CreateWindowFromTemplate( menuItemWindowName, menuTypeData.template, contextMenu.name )
    end
    
    -- Update the total number of active menu items    
    contextMenu.numTotalActiveMenuItems = contextMenu.numTotalActiveMenuItems + 1

    -- Set up the Function Table (if applicable)
    if( callbackFunction )
    then
        contextMenu.functionTable[ contextMenu.numTotalActiveMenuItems ] = {}
        contextMenu.functionTable[ contextMenu.numTotalActiveMenuItems ].callbackFunction = callbackFunction
        contextMenu.functionTable[ contextMenu.numTotalActiveMenuItems ].closeAfterClick = bCloseAfterClick
    end

    -- Set up the Button Text (if applicable )
    if( buttonText )
    then
        WindowSetDimensions( menuItemWindowName, 1000, 28 )
        WindowSetId( menuItemWindowName, contextMenu.numTotalActiveMenuItems )
        ButtonSetText( menuItemWindowName, buttonText )
        ButtonSetDisabledFlag( menuItemWindowName, bDisabled == true)
        
        -- Record the width of the largest button for determining the width of the overall window    
        local x, _ = ButtonGetTextDimensions( menuItemWindowName )
        contextMenu.greatestWidth = math.max( x + EA_Window_ContextMenu.BUTTON_TEXT_OFFSET*2 + menuTypeData.extraWidth, contextMenu.greatestWidth )
    end
    
    -- Set the game action (if applicable)
    if( gameActionData )
    then
        WindowSetGameActionData( menuItemWindowName, gameActionData.actionType, gameActionData.actionId, gameActionData.actionText )
    else
        WindowSetGameActionData( menuItemWindowName, 0, 0, L"" )
    end
        

    
    -- Anchor the window to the menu
    WindowClearAnchors( menuItemWindowName )    
    for index, anchor in ipairs( menuTypeData.anchors )
    do    
        WindowAddAnchor( menuItemWindowName, anchor.Point, contextMenu.anchorWindow, anchor.RelativePoint, anchor.XOffset, anchor.YOffset )
    end
    
    
    contextMenu.anchorWindow = menuItemWindowName 
end

-- Add a single default menu item button to the context menu... bCloseAfterClick is whether you wish the context menu to
-- close after you have clicked on one of the buttons in it. If you do not specify which context menu you wish to add 
-- the menu item to it will default to the first one.
function EA_Window_ContextMenu.AddMenuItem( buttonText, callbackFunction, bDisabled, bCloseAfterClick, contextMenuNumber, gameActionData )
    
    InternalAddMenuItem( EA_Window_ContextMenu.MENU_ITEM_DEFAULT, buttonText, callbackFunction, bDisabled, bCloseAfterClick, contextMenuNumber, gameActionData )

end


-- Adds a divider to the context menu
function EA_Window_ContextMenu.AddMenuDivider( contextMenuNumber )
    
    InternalAddMenuItem( EA_Window_ContextMenu.MENU_ITEM_DIVIDER, nil, nil, false, false, contextMenuNumber, nil )

end



-- Add a single cascading menu item button to the context menu... Adding a cascading menu item is useful if you want to
-- spawn a sub menu off of the menu item.  The callbackFunction you provide should be a function that spawns a new context
-- menu. It will be called when you mouse over the menu item. If you do not specify which context menu you wish to add 
-- the menu item to it will default to the first one.
function EA_Window_ContextMenu.AddCascadingMenuItem( buttonText, callbackFunction, bDisabled, contextMenuNumber )

    InternalAddMenuItem( EA_Window_ContextMenu.MENU_ITEM_CASCADING, buttonText, callbackFunction, bDisabled, false, contextMenuNumber )
    
end

-- Add a single user defined window to the context menu.
-- The window must already exist and have its own callbacks and event handlers specified.
-- The context menu will take care of hiding and showing the menu item as well as anchoring it.
-- You must specify which context menu you wish to add the menu item to.
-- If none is specified it will default to the first one.
function EA_Window_ContextMenu.AddUserDefinedMenuItem( windowName, contextMenuNumber )
    if( windowName == nil or windowName == "" ) then
        return
    end
    
    if( not contextMenuNumber )
    then
        contextMenuNumber = EA_Window_ContextMenu.CONTEXT_MENU_1
    end
    
    local contextMenu = EA_Window_ContextMenu.contextMenus[ contextMenuNumber ]
    
    if( not contextMenu )
    then
        return
    end
    
    contextMenu.numUserDefinedMenuItems = contextMenu.numUserDefinedMenuItems + 1
    contextMenu.userDefinedMenuItems[ contextMenu.numUserDefinedMenuItems ] = windowName
    
    -- Set up the button
    WindowSetId( windowName, contextMenu.numUserDefinedMenuItems )
    WindowSetParent( windowName, contextMenu.name )
    
    -- Record the width of the largest button for determining the width of the overall window
    local x, y = WindowGetDimensions( windowName )
    if( x > contextMenu.greatestWidth )
    then
        contextMenu.greatestWidth = x
    end
    
    -- Anchor the window to the menu
    WindowClearAnchors( windowName )
    WindowAddAnchor( windowName, "bottom", contextMenu.anchorWindow, "top", 0, 0 )
    contextMenu.anchorWindow = windowName 
end

-- Completes the menu and calls Show( contextMenuNumber ). You need to call this after adding all your menu items to a Context Menu.
-- anchor is a Table with all information of where the Context Menu should be anchored. 
-- It contains {Point, RelativePoint, RelativeTo, XOffset, YOffset} values.
function EA_Window_ContextMenu.Finalize( contextMenuNumber, anchor )
    if( not contextMenuNumber )
    then
        contextMenuNumber = EA_Window_ContextMenu.CONTEXT_MENU_1
    end
    
    local contextMenu = EA_Window_ContextMenu.contextMenus[ contextMenuNumber ]
    
    if( not contextMenu or contextMenu.numTotalActiveMenuItems < 1 and contextMenu.numUserDefinedMenuItems < 1 )
    then
        return
    end
    
    -- Size the Menu according to its contents
    
    local x = contextMenu.greatestWidth
    local y = 0
    local numItemsInContextMenu = contextMenu.numTotalActiveMenuItems + contextMenu.numUserDefinedMenuItems

    
    -- Add the Height of the Title (if applicable) 
    local _, titleHeight = LabelGetTextDimensions( contextMenu.name.."Title" )
    if( titleHeight > 0 )
    then
        y = y + titleHeight + EA_Window_ContextMenu.TITLE_SPACING + EA_Window_ContextMenu.TITLE_OFFSET 
    end
    
    
    -- Size the User-Defined Elements            
    for index, windowName in ipairs( contextMenu.userDefinedMenuItems )
    do
        local tempX, tempY = WindowGetDimensions( windowName )
        x = math.max( tempX, x )
        y = y + tempY
        WindowSetShowing( windowName, true )
    end
    
    x = math.max( EA_Window_ContextMenu.MIN_WIDTH, x )
    
    
    -- Show/Hide the appropriate number of menu items windows.
    for type, itemTypeData in ipairs( EA_Window_ContextMenu.ItemTypes )
    do
        for index = 1, contextMenu.numMenuItems[type]
        do    
            local bShow = index <= contextMenu.numActiveMenuItems[type]
            local windowName = contextMenu.name..itemTypeData.name..index
            
            WindowSetShowing( windowName, bShow )            
            
            if( bShow )
            then            
                local _, tempY = WindowGetDimensions( windowName )
                WindowSetDimensions( windowName, x, tempY )                        
                y = y + tempY                        
            end
        end
    end       
           
    -- Add the border offsets
    x = x + EA_Window_ContextMenu.BORDER_SPACING * 2
    y = y + EA_Window_ContextMenu.BORDER_SPACING * 2
    
    WindowSetDimensions( contextMenu.name, x, y )
    
    local relativeWindow = "Root"
    local point, relativePoint
    if( contextMenuNumber == EA_Window_ContextMenu.CONTEXT_MENU_1 )
    then
        if (not anchor)
        then
            x, y = WindowGetOffsetFromParent( "CursorWindow" )
            x = x + EA_Window_ContextMenu.MINIMUM_X_OFFSET
            point = "topleft"
            relativePoint = "topleft"
        else
            -- anchor was specified, use this information.
            x = anchor.XOffset
            y = anchor.YOffset
            point = anchor.Point
            relativePoint = anchor.RelativePoint
            relativeWindow = anchor.RelativeTo
        end
    else
        if (not anchor)
        then
            x = 10
            y = -4
            point = "topright"
            relativePoint = "topleft"
            relativeWindow = SystemData.MouseOverWindow.name
        else
            -- anchor was specified, use this information.
            x = anchor.XOffset
            y = anchor.YOffset
            point = anchor.Point
            relativePoint = anchor.RelativePoint
            if (anchor.RelativeTo == "")
            then
                relativeWindow = SystemData.MouseOverWindow.name
            else
                relativeWindow = anchor.RelativeTo
            end
        end
        
        -- determine if we need to cascade left instead of right
        -- 1. get screen width
        local screenX, screenY = GetScreenResolution()
        
        -- 2. get parent menu width and upper left x position
        local parentMenuNumber = contextMenuNumber - 1
        local parentMenuWindowName = "EA_Window_ContextMenu"..parentMenuNumber
        local parentMenuX, parentMenuY = WindowGetScreenPosition(parentMenuWindowName)
        local parentMenuRawWidth, parentMenuRawHeight = WindowGetDimensions(parentMenuWindowName)
        local parentMenuScale = WindowGetScale( parentMenuWindowName )
        local parentMenuWidth = parentMenuRawWidth * parentMenuScale
        
        -- 3. get current menu width
        local menuRawWidth, menuRawHeight = WindowGetDimensions(contextMenu.name)
        local menuScale = WindowGetScale( contextMenu.name)
        local menuWidth = menuRawWidth * menuScale
       
        -- 4. did we exceed the width of the screen
        if ( parentMenuX + parentMenuWidth + x + menuWidth > screenX ) 
        then
            point = "topleft"
            relativePoint = "topright"
            x = -10
        end            

    end
    
    WindowClearAnchors( contextMenu.name )
    WindowAddAnchor( contextMenu.name, point, relativeWindow, relativePoint, x, y )
    EA_Window_ContextMenu.Show( contextMenuNumber )
end

-- For default context menus just use this function in your OnRButtonUp
-- Callback functions
function EA_Window_ContextMenu.CreateDefaultContextMenu( windowNameToActUpon )
    if( windowNameToActUpon == nil or windowNameToActUpon == "" )
    then
        return
    end
    
    EA_Window_ContextMenu.CreateContextMenu( windowNameToActUpon, EA_Window_ContextMenu.CONTEXT_MENU_1 ) 
    local movable = WindowGetMovable( EA_Window_ContextMenu.activeWindow )

    EA_Window_ContextMenu.AddMenuItem( GetString( StringTables.Default.LABEL_TO_LOCK ), EA_Window_ContextMenu.OnLock, not movable, true, EA_Window_ContextMenu.CONTEXT_MENU_1 )
    EA_Window_ContextMenu.AddMenuItem( GetString( StringTables.Default.LABEL_TO_UNLOCK ), EA_Window_ContextMenu.OnUnlock, movable, true, EA_Window_ContextMenu.CONTEXT_MENU_1 )
    EA_Window_ContextMenu.AddMenuItem( GetString( StringTables.Default.LABEL_SET_OPACITY ), EA_Window_ContextMenu.OnWindowOptionsSetAlpha, false, true, EA_Window_ContextMenu.CONTEXT_MENU_1 )
    EA_Window_ContextMenu.Finalize( EA_Window_ContextMenu.CONTEXT_MENU_1 )
end

-- For default context menus with only the opacity setting just use this function in your OnRButtonUp
-- Callback functions
function EA_Window_ContextMenu.CreateOpacityOnlyContextMenu( windowNameToActUpon )
    if( windowNameToActUpon == nil or windowNameToActUpon == "" )
    then
        return
    end
    
    EA_Window_ContextMenu.CreateContextMenu( windowNameToActUpon, EA_Window_ContextMenu.CONTEXT_MENU_1 ) 
    EA_Window_ContextMenu.AddMenuItem( GetString( StringTables.Default.LABEL_SET_OPACITY ), EA_Window_ContextMenu.OnWindowOptionsSetAlpha, false, true, EA_Window_ContextMenu.CONTEXT_MENU_1 )
    EA_Window_ContextMenu.Finalize( EA_Window_ContextMenu.CONTEXT_MENU_1 )
end

function EA_Window_ContextMenu.OnLButtonUpDefaultMenuItem()
    local clickedWindowName = SystemData.ActiveWindow.name
    if( ButtonGetDisabledFlag( clickedWindowName ) == true ) then
        return
    end
    
    local windowId = WindowGetId( clickedWindowName )
    local contextMenuId = WindowGetId( WindowGetParent( clickedWindowName ) )
    if ( windowId ~= nil and EA_Window_ContextMenu.contextMenus[contextMenuId].functionTable[windowId] ~= nil ) then
        EA_Window_ContextMenu.contextMenus[contextMenuId].functionTable[windowId].callbackFunction()
        if( EA_Window_ContextMenu.contextMenus[contextMenuId].functionTable[windowId].closeAfterClick ) then
            EA_Window_ContextMenu.HideAll()
        end
    end
end

function EA_Window_ContextMenu.OnMouseOverDefaultMenuItem()
    -- Hide any cascaded ContextMenus if we mouse over a Default Menu Item
    -- (ie. non-cascading)
    local winName = WindowGetParent( SystemData.MouseOverWindow.name )  
    if ("EA_Window_ContextMenu3" == winName) then
        return
    elseif ("EA_Window_ContextMenu2" == winName) then
        EA_Window_ContextMenu.Hide(EA_Window_ContextMenu.CONTEXT_MENU_3)
    elseif ("EA_Window_ContextMenu1" == winName) then
        EA_Window_ContextMenu.Hide(EA_Window_ContextMenu.CONTEXT_MENU_2)
        EA_Window_ContextMenu.Hide(EA_Window_ContextMenu.CONTEXT_MENU_3)
    end
end

function EA_Window_ContextMenu.OnMouseOverCascadingMenuItem()
    local mouseOverWinName = SystemData.MouseOverWindow.name
    if( ButtonGetDisabledFlag( mouseOverWinName ) == true ) then
        return
    end
    
    local windowId = WindowGetId( mouseOverWinName )
    local contextMenuId = WindowGetId( WindowGetParent( mouseOverWinName ) )
    if ( windowId ~= nil and EA_Window_ContextMenu.contextMenus[contextMenuId].functionTable[windowId] ~= nil ) then
        EA_Window_ContextMenu.contextMenus[contextMenuId].functionTable[windowId].callbackFunction()
    end
end

function EA_Window_ContextMenu.OnLButtonProcessed()
    local contextMenuName = "EA_Window_ContextMenu"
    local wndName = SystemData.MouseOverWindow.name 
    while wndName ~= nil
        and wndName ~= ""
        and wndName ~= "NONE"         
        and DoesWindowExist( wndName) do
        if (string.sub( wndName, 1, string.len(contextMenuName)) == contextMenuName)
        then
            return
        end
        wndName = WindowGetParent(wndName)
    end
    
    EA_Window_ContextMenu.HideAll()
end

function EA_Window_ContextMenu.OnRButtonProcessed()
    local contextMenuName = "EA_Window_ContextMenu"
    local wndName = SystemData.MouseOverWindow.name 
    while wndName ~= nil
        and wndName ~= ""
        and wndName ~= "NONE"         
        and DoesWindowExist( wndName) do
        if (string.sub( wndName, 1, string.len(contextMenuName)) == contextMenuName)
        then
            return
        end
        wndName = WindowGetParent(wndName)
    end
    EA_Window_ContextMenu.HideAll()
end


function EA_Window_ContextMenu.OnLock()
    WindowSetMovable( EA_Window_ContextMenu.activeWindow, false )   
end

function EA_Window_ContextMenu.OnUnlock()    
    WindowSetMovable( EA_Window_ContextMenu.activeWindow, true ) 
end

function EA_Window_ContextMenu.OnWindowOptionsSetAlpha()
    -- Open the Alpha Slider    
    local alpha = WindowGetAlpha( EA_Window_ContextMenu.activeWindow )    
    SliderBarSetCurrentPosition("EA_Window_SetOpacitySlider", alpha )    
    
    -- Anchor the OpacityWindow in the middle of the active window.
    WindowClearAnchors( "EA_Window_SetOpacity" )
    WindowAddAnchor( "EA_Window_SetOpacity", "center", EA_Window_ContextMenu.activeWindow, "center", 0 , 0 )

    WindowSetShowing( "EA_Window_SetOpacity", true )
end

function EA_Window_ContextMenu.OnSlideWindowOptionsAlpha( slidePos )
    local alpha = slidePos
    
    -- Requirements call for 10%-100% range, not 0% to 100%.
    if (alpha < 0.1) then
        alpha = 0.1
    end
    -- this if statement is a stop gap to prevent this call from happening with a bad window
    -- the bad call when using ctrl+alt+del should be tracked down
    if (EA_Window_ContextMenu.activeWindow ~= nil) then
        WindowSetAlpha( EA_Window_ContextMenu.activeWindow, alpha )
    end
end

function EA_Window_ContextMenu.CloseSetOpacityWindow()
    WindowSetShowing( "EA_Window_SetOpacity", false )
end
