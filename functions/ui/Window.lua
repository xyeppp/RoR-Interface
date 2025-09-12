--- Registers a lua callback for a game event.
--- @param windowName string The name of the window.
--- @param eventName string The name of the event for which to register a callback.
--- @param callback string Full name of the lua function to be called when this event occurs.
function WindowRegisterCoreEventHandler(windowName, eventName, callback) end

--- Clear’s the window’s current callback for an event.
--- @param windowName string The name of the window.
--- @param eventName string The id name of the event for which to unregister a callback.
function WindowUnregisterCoreEventHandler(windowName, eventName) end

--- Registers a lua callback for a game event.
--- @param windowName string The name of the window.
--- @param eventId number The id number of the event for which to register a callback.
--- @param callback string Full name of the lua function to be called when this event occurs.
function WindowRegisterEventHandler(windowName, eventId, callback) end

--- Clear’s the window’s current callback for an event.
--- @param windowName string The name of the window.
--- @param eventId number The id number of the event for which to unregister a callback.
function WindowUnregisterEventHandler(windowName, eventId) end

--- Set’s the id value for the window
--- @param windowName string The name of the window.
--- @param id number The id number to assign to the window.  May be any integer value.
function WindowSetId(windowName, id) end

--- Returns the id for the specified window.
--- @param windowName string The name of the window.
--- @return number The id number for the window.
function WindowGetId(windowName) end

--- Set’s the tab order for the window
--- @param windowName string The name of the window.
--- @param tabOrder number The TabOrder number to assign to the window.  May be any integer value.
function WindowSetTabOrder(windowName, tabOrder) end

--- Returns the TabOrder for the specified window.
--- @param windowName string The name of the window.
--- @return number The tab order number for the window.
function WindowGetTabOrder(windowName) end

--- Sets the alpha value for the window’s texture elements.  This value is propagated to all child elements as the ‘parent alpha’ value.  A window’s alpha and parent alpha values are multiples to produce the combined alpha result seen on the screen.
--- @param windowName string The name of the window.
--- @param alpha number The alpha value 0.0 to 1.0.
function WindowSetAlpha(windowName, alpha) end

--- Returns the current alpha value for the window.
--- @param windowName string The name of the window.
--- @return number The alpha value 0.0 to 1.0.
function WindowGetAlpha(windowName) end

--- Sets the tint color window’s texture elements.
--- @param windowName string The name of the window.
--- @param red number The red tint value (0-255)
--- @param green number The green tint value (0-255)
--- @param blue number The blue tint value (0-255)
function WindowSetTintColor(windowName, red, green, blue) end

--- Returns the tint color window’s texture elements.
--- @param windowName string The name of the window.
--- @return number The red tint value (0-255)
--- @return number The green tint value (0-255)
--- @return number The blue tint value (0-255)
function WindowGetTintColor(windowName) end

--- Sets the alpha value for the window’s text elements.  This value is propagated to all child elements.
--- @param windowName string The name of the window.
--- @param alpha number The alpha value 0.0 to 1.0.
function WindowSetFontAlpha(windowName, alpha) end

--- Returns the current font alpha value for the window.
--- @param windowName string The name of the window.
--- @return number The alpha value 0.0 to 1.0.
function WindowGetFontAlpha(windowName) end

--- Sets the position of the window from it’s parent.
--- @param windowName string The name of the window.
--- @param xOffset number The x pixel offset from the parent’s top left corner.
--- @param yOffset number The y Pixel offset from the parent’s top left corner.
function WindowSetOffsetFromParent(windowName, xOffset, yOffset) end

--- Returns window’s offset from it’s parent window.
--- @param windowName string The name of the window.
--- @return number The x pixel offset from the parent’s top left corner.
--- @return number The y Pixel offset from the parent’s top left corner.
function WindowGetOffsetFromParent(windowName) end

--- Returns the screen position of the window.
--- @param windowName string The name of the window.
--- @return number The x pixel of the top left corner.
--- @return number The y Pixel of the top corner.
function WindowGetScreenPosition(windowName) end

--- Sets the x, y size of the window.
--- @param windowName string The name of the window.
--- @param xOffset number The x unscaled size
--- @param yOffset number The y unscaled size.
function WindowSetDimensions(windowName, xOffset, yOffset) end

--- Returns the x, y size of the window.
--- @param windowName string The name of the window.
--- @return number The x unscaled size
--- @return number The y unscaled size.
function WindowGetDimensions(windowName) end

--- Sets if a window should be shown (and drawn) on the screen.  When a window is not showing, it will not receive updates or mouse events.  Generic event handlers will still be processed.
--- @param windowName string The name of the window.
--- @param showing boolean Should the window be drawn?
function WindowSetShowing(windowName, showing) end

--- Returns if the window is currently shown (and being drawn) on the screen.
--- @param windowName string The name of the window.
--- @return boolean Is the window currently being drawn?
function WindowGetShowing(windowName) end

--- Sets the layer that the window should be drawn on.
--- @param windowName string The name of the window.
--- @param layer number The layer the window is drawn on.  See Window.Layers for values.
function WindowSetLayer(windowName, layer) end

--- Returns if the layer the window is currently drawn on.
--- @param windowName string The name of the window.
--- @return number The layer the window is drawn on.  See Window.Layers for values.
function WindowGetLayer(windowName) end

--- Sets if the window should handle mouse input.
--- @param windowName string The name of the window.
--- @param handleinput number Should the window handle mouse input?
function WindowSetHandleInput(windowName, handleinput) end

--- Returns if the the is window currently handling mouse input.
--- @param windowName string The name of the window.
--- @return boolean Is the window currently handling mouse input?
function WindowGetHandleInput(windowName) end

--- Returns if the window is currently set to popable.  When popable is true, the window will ‘pop’ to the front of it’s layer when clicked.
--- @param windowName string The name of the window.
--- @param popable number Should the window be popable?
function WindowSetPopable(windowName, popable) end

--- Returns if the window is currently set to popable.
--- @param windowName string The name of the window.
--- @return boolean Is the window popable
function WindowGetPopable(windowName) end

--- Sets if a window can be moved.  When true, the window can be clicked on and dragged around the screen.
--- @param windowName string The name of the window.
--- @param movable boolean Should the window be movable?
function WindowSetMovable(windowName, movable) end

--- Returns if the window can be moved with the mouse.
--- @param windowName string The name of the window.
--- @return boolean Is the window currently movable?
function WindowGetMovable(windowName) end

--- Determines whether or not the window is sticky or unsticky.
--- @param windowName string The name of the window.
--- @return boolean Is the window sticky?  True, or false.
function WindowIsSticky(windowName) end

--- Sets if the window is currently attached to the cursor.
--- @param windowName string The name of the window.
--- @param moving boolean Should the window be moving?
function WindowSetMoving(windowName, moving) end

--- Returns if the window is currently being moved.
--- @param windowName string The name of the window.
--- @return boolean Is the window be moving?
function WindowGetMoving(windowName) end

--- Clears all of the anchors from the window.  When all the anchors are removed from a window, it will reposition itself to it’s parent position.
--- @param windowName string The name of the window.
function WindowClearAnchors(windowName) end

--- Adds a new anchor to the window.
--- @param windowName string The name of the window.
--- @param anchorPoint string The name point on the at which to anchor the window.  { “topleft”, “top”, “topright”, “left”, “center”, “right”, “bottomleft”, “bottom”, “bottomright” }
--- @param relativeTo string The name of another window to which you want to anchor this one.
--- @param relativePoint string The point on this that you wish to attach to the anchor window.  { “topleft”, “top”, “topright”, “left”, “center”, “right”, “bottomleft”, “bottom”, “bottomright” }
--- @param xOffset number The x pixel offset from this anchor location.
--- @param yOffset number The y pixel offset from this anchor location.
function WindowAddAnchor(windowName, anchorPoint, relativeTo, relativePoint, xOffset, yOffset) end

--- Returns how many anchors this window has.
--- @param windowName string The name of the window.
--- @return number The number of anchors this window has.
function WindowGetAnchorCount(windowName) end

--- Returns anchor information
--- @param windowName string The name of the window.
--- @param anchorId number Desired anchor’s id.  Ranges from 1 to Window:GetAnchorCount for this window.
--- @return string point
--- @return string relativePoint
--- @return string relativeTo
--- @return number x offset
--- @return number y offset
function WindowGetAnchor(windowName, anchorId) end

--- Forces the window anchors to be processed.
--- @param windowName string The name of the window.
function WindowForceProcessAnchors(windowName) end

--- Assigns or clears the direct focus to this window element.  As a result, all parent window element will also come into focus.
--- @param windowName string The name of the window.
--- @param focus string True = Set Focus, False = Clear Focus
function WindowAssignFocus(windowName, focus) end

--- Returns whether or not the window has focus.
--- @param windowName string The name of the window.
--- @return boolean True = Has Focus, False = No Focus
function WindowHasFocus(windowName) end

--- Sets the window to be continuously resized while the mouse is dragging.
--- @param windowName string The name of the window.
--- @param resizing string True = Resizing is on, False = Resizing is off.
function WindowSetResizing(windowName, resizing) end

--- Returns if a window is currently being resized
--- @param windowName string The name of the window.
--- @return string True = Resizing is on, False = Resizing is off.//*
function WindowGetResizing(windowName) end

--- Starts an automated alpha-animation on the window derived from the function parameters.
--- @param windowName string The name of the window.
--- @param animType number The animation type, see Animation Types for valid values.
--- @param startAlpha number The starting alpha value for the animation.
--- @param endAlpha number The ending alpha value for the animation.
--- @param duration number The duration (in seconds) to fade between the min alpha and max alpha.
--- @param setStartBeforeDelay boolean Should the window be set to the start animation value prior to the delay?
--- @param delay number The delay between this function call and when the animation should start.
--- @param numLoop number The number of times to loop the animation.  When 0, looks indefinably.
function WindowStartAlphaAnimation(windowName, animType, startAlpha, endAlpha, duration, setStartBeforeDelay, delay, numLoop) end

--- Stops the current alpha animation and reset’s the window to it’s true alpha value.
--- @param windowName string The name of the window.
function WindowStopAlphaAnimation(windowName) end

--- Starts an automated position-animation on the window derived from the function parameters.
--- @param windowName string The name of the window.
--- @param animType number The animation type, see Animation Types for valid values.
--- @param startX number The starting x offset from parent for the animation (start and end for POP type anims)
--- @param startY number The starting y offset from parent for the animation (start and end for POP type anims)
--- @param endX number The ending x offset from parent for the animation (mid-point for POP type anims)
--- @param endY number The ending y  offset from parent for the animation (mid-point for POP type anims)
--- @param duration number The duration (in seconds) to fade between the min alpha and max alpha.
--- @param setStartBeforeDelay boolean Should the window be set to the start animation value prior to the delay?
--- @param delay number The delay between this function call and when the animation should start.
--- @param numLoop number The number of times to loop the animation.  When 0, looks indefinably.
function WindowStartPositionAnimation(windowName, animType, startX, startY, endX, endY, duration, setStartBeforeDelay, delay, numLoop) end

--- Stops the current position animation and reset’s the window to it’s anchored position.
--- @param windowName string The name of the window.
function WindowStopPositionAnimation(windowName) end

--- Starts an automated scale-animation on the window derived from the function parameters.
--- @param windowName string The name of the window.
--- @param animType number The animation type, see Animation Types for valid values.
--- @param startAlpha number The starting alpha value for the animation.
--- @param endAlpha number The ending alpha value for the animation.
--- @param duration number The duration (in seconds) to fade between the min alpha and max alpha.
--- @param setStartBeforeDelay boolean Should the window be set to the start animation value prior to the delay?
--- @param delay number The delay between this function call and when the animation should start.
--- @param numLoop number The number of times to loop the animation.  When 0, looks indefinably.
function WindowStartScaleAnimation(windowName, animType, startAlpha, endAlpha, duration, setStartBeforeDelay, delay, numLoop) end

--- Stops the current scale animation and reset’s the window to it’s true scale.
--- @param windowName string The name of the window.
function WindowStopScaleAnimation(windowName) end

--- This will remove the window from it’s current parent, and adds it as a child of the specified window.
--- @param windowName string The name of the window.
--- @param parentWindowName string The name of the new parent window.
function WindowSetParent(windowName, parentWindowName) end

--- Returns the parent for the specified window.
--- @param windowName string The name of the window.
--- @return string The name of the new parent window.
function WindowGetParent(windowName) end

--- Sets the current scale value on the window.
--- @param windowName string The name of the window.
--- @param scale number Value between 0.0 and 1.0.
function WindowSetScale(windowName, scale) end

--- Returns the current scale value on the window.
--- @param windowName string The name of the window.
--- @return number Value between 0.0 and 1.0.
function WindowGetScale(windowName) end

--- Scales the window relative to it’s current scale.  For example, a relative scale of 0.5 will scale a window to half it’s current size.
--- @param windowName string The name of the window.
--- @param scale number Value between 0.0 and 1.0.
function WindowSetRelativeScale(windowName, scale) end

--- Determines the existence of the specified window.
--- @param windowName string The name of the window.
--- @return boolean true if the window named by windowName exists, false otherwise.
function DoesWindowExist(windowName) end

--- Resizes a parent window based upon the max sizes of its children
--- @param windowName string Name of the parent window to resize.
--- @param recursive boolean Whether or not to recurse through the children of your children.
--- @param borderSpacing number Amount of padding to add to the bottom and right.
function WindowResizeOnChildren(windowName, recursive, borderSpacing) end

--- Associates a a key-bindable action to clicking on this window.
--- @param windowName string Name of the window
--- @param gameActionId number The keybinding action id to trigger when the window is clicked.
function WindowSetGameActionTrigger(windowName, gameActionId) end

--- Associates a game action (a key-bindable action) to clicking on this window.
--- @param windowName string Name of the window
--- @param gameActionType number The Type of the action.
--- @param gameActionId number The id number of the action.
--- @param gameActionText number The text associated with the action.
function WindowSetGameActionData(windowName, gameActionType, gameActionId, gameActionText) end

--- Sets the GameActionButton to use to trigger the Game Action associated with this window.
--- @param windowName string The name of the window.
--- @param gameActionButton number The GameActionButton to use for this window see Game Action Buttons for values.
function WindowSetGameActionButton(windowName, gameActionButton) end

--- Returns if the current button used to trigger game actions.
--- @param windowName string The name of the window.
--- @return number The current GameAction button See Game Action Buttons for values.
function WindowGetGameActionButton(windowName) end

--- Returns if this window is currently locked for editing game actions.
--- @param windowName string The name of the window.
--- @return number Returns if the window is locked for game actions or not.
function WindowIsGameActionLocked(windowName) end

--- This function sets if the window should be drawn if the main UI is hidden.
--- @param windowName string The name of the window.
--- @param showWhenUiHidden boolean Should this window be drawn the the main UI is hidden?
function WindowSetDrawWhenInterfaceHidden(windowName, showWhenUiHidden) end

--- This function restores a window to it’s default anchors, size, scale, and alpha
--- @param windowName string The name of the window.
function WindowRestoreDefaultSettings(windowName) end


Window = Window or {}

Window.AnimationType = {
    SINGLE = 1,
    SINGLE_NO_RESET = 2,
    EASE_OUT = 3,
    LOOP = 4,
    REPEAT = 5,
    POP = 6,
    POP_AND_EASE = 7,
}

Window.Layers = {
    BACKGROUND = "background",
    DEFAULT = "default",
    SECONDARY = "secondary",
    POPUP = "popup",
    OVERLAY = "overlay",
}

Window.GameActionButtons = {
    LEFT = "left",
    RIGHT = "right",
}
