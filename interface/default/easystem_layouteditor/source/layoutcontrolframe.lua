
------------------------------------------------------------------------------------------------------------------------------------------------
--# Title: Layout Control Frame
--#     This file contains the implementaion for the LayoutControlFrame, which allows the user to manipulate a HUD window
--#     with the Layout Editor
------------------------------------------------------------------------------------------------------------------------------------------------

LayoutControlFrame = Frame:Subclass( "LayoutControlFrameWindow" )

LayoutControlFrame.OFFSET = 25
LayoutControlFrame.MIN_SIZE = { x = 20, y = 20 }    -- Minimum size of actual window -- does not include frame offset

LayoutControlFrame.TOP_LEFT        = 1
LayoutControlFrame.TOP_RIGHT       = 2
LayoutControlFrame.BOTTOM_LEFT     = 3
LayoutControlFrame.BOTTOM_RIGHT    = 4
LayoutControlFrame.TOP             = 5
LayoutControlFrame.BOTTOM          = 6
LayoutControlFrame.LEFT            = 7
LayoutControlFrame.RIGHT           = 8

-- Data for The Resize Anchors
LayoutControlFrame.ANCHOR_OFFSETS = 
{
   ["topleft"]     = { addWidth=false, addHeight=false },
   ["topright"]    = { addWidth=true,  addHeight=false },
   ["bottomleft"]  = { addWidth=false, addHeight=true },
   ["bottomright"] = { addWidth=true,  addHeight=true },
}

LayoutControlFrame.RESIZE_PARAMS = 
{ 
    [LayoutControlFrame.TOP_LEFT ]      = { sizePoint="bottomright",   lockAspect=true,   anchorPoint="bottomright", windowName="TopLeftResize" },
    [LayoutControlFrame.TOP_RIGHT ]     = { sizePoint="bottomleft",    lockAspect=true,   anchorPoint="bottomleft", windowName="TopRightResize"  },
    [LayoutControlFrame.BOTTOM_LEFT ]   = { sizePoint="topright",      lockAspect=true,   anchorPoint="topright",    windowName="BottomLeftResize"  },
    [LayoutControlFrame.BOTTOM_RIGHT ]  = { sizePoint="topleft",       lockAspect=true,   anchorPoint="topleft",     windowName="BottomRightResize"  },
    [LayoutControlFrame.TOP ]           = { sizePoint="bottom",        lockAspect=false,  anchorPoint="bottomleft",  windowName="TopResize"  },
    [LayoutControlFrame.BOTTOM ]        = { sizePoint="top",           lockAspect=false,  anchorPoint="topleft",     windowName="BottomResize"  },
    [LayoutControlFrame.LEFT ]          = { sizePoint="right",         lockAspect=false,  anchorPoint="topright",    windowName="LeftResize"  },
    [LayoutControlFrame.RIGHT ]         = { sizePoint="left",          lockAspect=false,  anchorPoint="topleft",     windowName="RightResize"  },
}


-- Data for The Resize Anchors
LayoutControlFrame.RESIZE_CONTROL_ANCHORS = 
{ 
    [LayoutControlFrame.TOP_LEFT ]      = { point="bottomright",  xOffset=-LayoutControlFrame.OFFSET, yOffset=-LayoutControlFrame.OFFSET, },
    [LayoutControlFrame.TOP_RIGHT ]     = { point="bottomleft",   xOffset=LayoutControlFrame.OFFSET, yOffset=-LayoutControlFrame.OFFSET, },
    [LayoutControlFrame.BOTTOM_LEFT ]   = { point="topright",     xOffset=-LayoutControlFrame.OFFSET, yOffset=LayoutControlFrame.OFFSET, },
    [LayoutControlFrame.BOTTOM_RIGHT ]  = { point="topleft",      xOffset=LayoutControlFrame.OFFSET, yOffset=LayoutControlFrame.OFFSET, },
    [LayoutControlFrame.TOP ]           = { point="bottomleft",   xOffset=LayoutControlFrame.OFFSET, yOffset=-LayoutControlFrame.OFFSET, },
    [LayoutControlFrame.BOTTOM ]        = { point="topleft",      xOffset=LayoutControlFrame.OFFSET, yOffset=LayoutControlFrame.OFFSET, },
    [LayoutControlFrame.LEFT ]          = { point="topright",     xOffset=-LayoutControlFrame.OFFSET, yOffset=LayoutControlFrame.OFFSET, },
    [LayoutControlFrame.RIGHT ]         = { point="topleft",      xOffset=LayoutControlFrame.OFFSET, yOffset=LayoutControlFrame.OFFSET, },
}


local function AnchorFrame( frame, anchorToFrame, anchorId )
            
    -- Anchor this frame to the appropriate corner of the Resize Frame    
    local anchorData = LayoutControlFrame.RESIZE_CONTROL_ANCHORS[anchorId]                   
    local anchor = { Point=anchorData.point, RelativeTo=anchorToFrame:GetName(), RelativePoint=anchorData.point, XOffset=anchorData.xOffset, YOffset=anchorData.yOffset }
    frame:SetAnchor( anchor )

end

local function CopySize_ControlsToLayout( sourceFrame, destFrame )
    LayoutEditorUtils.CopySize( sourceFrame, destFrame, -2*LayoutControlFrame.OFFSET, -2*LayoutControlFrame.OFFSET, true)
end

local function CopySize_LayoutToControls( sourceFrame, destFrame )
    LayoutEditorUtils.CopySize( sourceFrame, destFrame, 2*LayoutControlFrame.OFFSET, 2*LayoutControlFrame.OFFSET, false )
end


-- Implementation
function LayoutControlFrame:Create( windowName, parentName )
    local frame = self:CreateFromTemplate(windowName, parentName )

    if (frame == nil)
    then
        return nil
    end
    
    -- 1) Set Up The Frame        
    frame.m_activeFrame     = nil  
    frame.m_resizing        = false
    frame.m_resizeButton    = nil
    frame.m_moving          = false      
        
    DefaultColor.SetWindowTint( windowName, DefaultColor.YELLOW )     
    
    frame:Show( false )
        
    -- Anchor the Resize Frame according to the Offset.
    WindowAddAnchor( windowName.."ResizeFrame", "topleft", windowName, "topleft", LayoutControlFrame.OFFSET, LayoutControlFrame.OFFSET )
    WindowAddAnchor( windowName.."ResizeFrame", "bottomright", windowName, "bottomright", -LayoutControlFrame.OFFSET, -LayoutControlFrame.OFFSET )
    WindowSetShowing( windowName.."ResizeFrame", false )
    
    
    -- Create a Snap Frame    
    local snapWindowName = windowName.."SnapFrame"    
    frame.m_snapFrame    = LayoutSnapFrame:Create( snapWindowName, LayoutEditor.WINDOW_NAME )  
    
    
    frame.m_adjustOffset = { x=0, y=0 }
    
    return frame
end

function LayoutControlFrame:DestroyInstance()
    self.m_snapFrame:Destroy()
    self:Destroy()            
end

function LayoutControlFrame:Attach()

    local uiScale = InterfaceCore.GetScale()
    local scaledOffset  = LayoutControlFrame.OFFSET*uiScale

    -- Anchor the active frame to the Control Frame
    CopySize_LayoutToControls( self.m_activeFrame, self )        
    LayoutEditorUtils.CopyScreenPosition( self.m_activeFrame, self, -scaledOffset, -scaledOffset )        
    AnchorFrame( self.m_activeFrame, self, LayoutControlFrame.TOP_LEFT  )
    
    -- Only Show the Side Resize-Button if the window allows resizing.
    local resizeWidth = self.m_activeFrame.m_windowData.allowSizeWidth 
    local resizeHeight = self.m_activeFrame.m_windowData.allowSizeHeight
    
    WindowSetShowing( self:GetName().."TopResize", resizeHeight )
    WindowSetShowing( self:GetName().."BottomResize", resizeHeight )
    WindowSetShowing( self:GetName().."LeftResize", resizeWidth )
    WindowSetShowing( self:GetName().."RightResize", resizeWidth )

    self:Show( true )
end

function LayoutControlFrame:Detach()

    self:EndResize()
    self:EndMoving()

    local uiScale = InterfaceCore.GetScale()
    local scaledOffset  = LayoutControlFrame.OFFSET*uiScale
                
    -- Detach the frame from the Control Frame                   
    LayoutEditorUtils.CopyScreenPosition( self, self.m_activeFrame, scaledOffset, scaledOffset )
    WindowClearAnchors( self:GetName() )    
    
    self:Show( false )
end

function LayoutControlFrame:SetActiveFrame( frame )
        
    -- Ignore duplicate clicks to the same frame
    if( self.m_activeFrame and frame )
    then
        if(self.m_activeFrame:GetName() == frame:GetName() )
        then
            return
        end
    end    
    
    -- End manipulation on the old active frame
    if( self.m_activeFrame ) 
    then      
        self:Detach()                
        self.m_activeFrame:SetActive(false)
    end
    
    -- Assign the new active frame
    self.m_activeFrame = frame
        
    -- Begin manipulation on the new active frame
    if( self.m_activeFrame )
    then    
        self.m_activeFrame:SetActive(true)    
        self:Attach()
    end       
    
end

function LayoutControlFrame:GetActiveFrame()
    return self.m_activeFrame
end

function LayoutControlFrame:Update( timePassed )

    if( not self.m_activeFrame )
    then
        return
    end
    
    -- 1) When resizing, restrict the size to the minimum dimensions
    if( self.m_resizing )
    then
        local minSize = self.m_activeFrame.m_windowData.minSize
        if ( minSize == nil )
        then
            -- If no minimum size specified, use the default
            minSize = LayoutControlFrame.MIN_SIZE
        end
        
        local frameBorder = LayoutControlFrame.OFFSET*2
        local minSizeIncludingFrame = { x = minSize.x + frameBorder, y = minSize.y + frameBorder }
        
        local x, y = WindowGetDimensions( self:GetName() )         
        
        local clampedX = x
        if ( x < minSizeIncludingFrame.x  ) 
        then
            clampedX = minSizeIncludingFrame.x
        end
        
        local clampedY = y
        if ( y < minSizeIncludingFrame.y ) 
        then
            clampedY = minSizeIncludingFrame.y
        end
        
        -- Why isn't the frame function working correctly here?
        --self:SetDimensions( x, y )   
        
        if( clampedX ~= x or clampedY ~= y )
        then
            WindowSetDimensions( self:GetName(), clampedX, clampedY )     
        end
    end
    
    -- 2) When moving, restrict the frame from only going the offset width
    -- off the edge.
    if( self.m_moving ) 
    then
        local uiScale                   = InterfaceCore.GetScale()
        local screenWidth, screenHeight = GetScreenResolution()
        local screenX, screenY          = WindowGetScreenPosition( self:GetName() ) 
        local width, height             = WindowGetDimensions( self:GetName() ) 
        
        width   = width*uiScale
        height  = height*uiScale
        
        local clampedX = screenX
        local clampedY = screenY
        
        local sourceIsSticky = WindowIsSticky( self.m_activeFrame:GetSourceWindowName() )
        
        -- Don't allow more than the "grabby bars" to go off the screen if the source window is sticky...
        local scaledWidthOffset     = LayoutControlFrame.OFFSET * uiScale 
        local scaledHeightOffset    = LayoutControlFrame.OFFSET * uiScale
        
        -- Allow 90% of the window to go off the screen if the source is not sticky (so we don't lose the LayoutFrame)
        if( sourceIsSticky == false )
        then
            local sourceWindowName          = self.m_activeFrame:GetSourceWindowName()
            local sourceWindowScale         = WindowGetScale( sourceWindowName )
            local sourceWidth, sourceHeight = WindowGetDimensions( sourceWindowName )

            scaledWidthOffset   = scaledWidthOffset + (sourceWidth * sourceWindowScale * .9)
            scaledHeightOffset  = scaledHeightOffset + (sourceHeight * sourceWindowScale * .9)
        end
        
        if( screenX < -scaledWidthOffset )
        then
            clampedX = -scaledWidthOffset
        end
        
        if( screenY < -scaledHeightOffset )
        then
            clampedY = -scaledHeightOffset
        end
        
        if( screenX + width > screenWidth + scaledWidthOffset )
        then
            clampedX = screenWidth + scaledWidthOffset - width
        end
        
        if( screenY + height > screenHeight + scaledHeightOffset )
        then
            clampedY = screenHeight + scaledHeightOffset - height
        end
        
        if( clampedX ~= screenX or clampedY ~= screenY )
        then
            clampedX = clampedX/uiScale
            clampedY = clampedY/uiScale
        
            local anchor = { Point="topleft", RelativeTo="Root", RelativePoint="topleft", XOffset=clampedX, YOffset=clampedY }
            self:SetAnchor( anchor )    
        end
        
        
        -- Update the Window Snapping Frame
        self.m_activeFrame:UpdateScreenRect()
        self.m_snapFrame:Update()
        
    
    -- 3) If the frame is being adjusted via the arrow keys, process it.    
    elseif( self.m_adjustOffset.x ~= 0 or self.m_adjustOffset.y ~= 0 )
    then
        self:AdjustPosition( self.m_adjustOffset.x, self.m_adjustOffset.y )
    end
    
end

-- Movment Functions
function LayoutControlFrame:BeginMoving()

    if( self.m_moving == true )
    then
        return
    end
    
    self.m_moving = true
    WindowSetMoving( self:GetName(), true )
    
    self.m_snapFrame:SetActiveFrame(self)
end

function LayoutControlFrame:EndMoving()

    if( self.m_moving == false )
    then
        return
    end
    
    self.m_moving = false
    WindowSetMoving( self:GetName(), false )
    
    -- If the snap frame has a snap showing,
    -- Copy over that screen location
    if( self.m_snapFrame:HasSnap() )
    then        
        LayoutEditorUtils.CopyScreenPosition( self.m_snapFrame, self.m_activeFrame, 0, 0 )
        self:Attach()    
    end    
    
    self.m_snapFrame:SetActiveFrame(nil)    
    self.m_activeFrame:UpdateScreenRect()
    
    if ( self.m_activeFrame.m_windowData.OnMoveEnd )
    then
        self.m_activeFrame.m_windowData.OnMoveEnd()
    end
end

-- Resize Functions
function LayoutControlFrame:BeginResize( buttonId )
    
    if( not self.m_activeFrame )
    then
        return
    end
    
    if( self.m_resizing == true ) 
    then
        return
    end


    self.m_resizing = true 
    self.m_resizeButton = buttonId
    
    local resizeData = LayoutControlFrame.RESIZE_PARAMS[ buttonId ]    
    local neverLockAspect = self.m_activeFrame.m_windowData.neverLockAspect
    WindowSetResizing( self:GetName(), true, resizeData.sizePoint, resizeData.lockAspect and not neverLockAspect )
    
    -- Show the Resize Frame
    WindowSetShowing( self:GetName().."ResizeFrame", true )
    
    -- Anchor the Control window by the opposite corner    
    local width, height = WindowGetDimensions( self:GetName() ) 
    local uiScale = InterfaceCore.GetScale()
    local screenX, screenY = WindowGetScreenPosition( self:GetName() ) 
    local offsetX = screenX/uiScale;
    local offsetY = screenY/uiScale;    
 
    local anchorData = LayoutControlFrame.ANCHOR_OFFSETS[resizeData.anchorPoint]
    if( anchorData.addWidth )
    then
        offsetX = offsetX + width
    end
    
    if( anchorData.addHeight )
    then
        offsetY = offsetY + height
    end
    
    local anchor = { Point="topleft", RelativeTo="Root", RelativePoint=resizeData.anchorPoint, XOffset=offsetX, YOffset=offsetY }   

    self:SetAnchor( anchor )
    
    -- Anchor the Active frame to the control frame by the same corner
    AnchorFrame( self.m_activeFrame, self, buttonId )

end

function LayoutControlFrame:EndResize()
    
    if( not self.m_activeFrame )
    then
        return
    end
    
    if( self.m_resizing == false ) 
    then
        return
    end


    -- Stop Resizing    
    WindowSetResizing( self:GetName(), false, "", false )        
    
    -- Hide the Resize Frame
    WindowSetShowing( self:GetName().."ResizeFrame", false )
    
    -- Determine the desired dimensions for the Layout Frame
    local width, height = WindowGetDimensions( self:GetName() )
    width  = (width - 2*LayoutControlFrame.OFFSET)
    height = (height - 2*LayoutControlFrame.OFFSET)
        
    
    -- If the aspect ratio is locked, we want to scale the window instead of re-sizing.
    local resizeData = LayoutControlFrame.RESIZE_PARAMS[ self.m_resizeButton ]    
    local neverLockAspect = self.m_activeFrame.m_windowData.neverLockAspect
    if( resizeData.lockAspect and not neverLockAspect )
    then
    
        -- Scale the layout frame to match these dimensions   
        self.m_activeFrame:ScaleWindowToDimensions( width, height )    
        
        -- Re-size the control frame to match the current active frame
        -- as the ScaleWindowToDimensions() may have adjusted the dimensions
        -- to preserve the window's desired aspect ratio.
        CopySize_LayoutToControls( self.m_activeFrame, self )
    
    else
    
        -- Size the layout frame to match these dimensions   
        self.m_activeFrame:SizeWindowToDimensions( width, height )   
    
    end          
  
    
    self.m_resizing = false 
    self.m_resizeButton = nil
    
    if ( self.m_activeFrame.m_windowData.OnResizeEnd )
    then
        self.m_activeFrame.m_windowData.OnResizeEnd()
    end
        
end


-- Offsets the Window by the specified amount in current screen coordinates.
function LayoutControlFrame:AdjustPosition( xOffset, yOffset)

    local uiScale = InterfaceCore.GetScale()    
    local screenX, screenY = WindowGetScreenPosition( self:GetName() )                
    
    local xPos = (screenX + xOffset)/uiScale
    local yPos = (screenY + yOffset)/uiScale
        
    local anchor = { Point="topleft", RelativeTo="Root", RelativePoint="topleft", XOffset=xPos, YOffset=yPos }
    self:SetAnchor( anchor )

end

-- Button Callbacks

function LayoutControlFrame:OnLButtonDown()

    if( not self.m_activeFrame )
    then
        DEBUG(L"LayoutControlFrame:OnLButtonDown() not processed")
        return
    end

    self:BeginMoving()
end

function LayoutControlFrame:OnRButtonDown()
    
    if( not self.m_activeFrame )
    then
        return
    end

end


function LayoutControlFrame:OnRButtonUp()

    if( not self.m_activeFrame )
    then
        return
    end

    -- Bring up the context menu for the active frame
    self:CreateContextMenu()
end

function LayoutControlFrame:OnMButtonDown()
    
    if( not self.m_activeFrame )
    then
        return
    end

end

function LayoutControlFrame:OnMButtonUp()

    if( not self.m_activeFrame )
    then
        return
    end
    
    -- Toggle Locked with the middle mouse button
    if( self.m_activeFrame:IsLocked() )
    then
        self:OnContextMenuUnlockFrame()
    else
        self:OnContextMenuLockFrame()
    end
end


function LayoutControlFrame:OnLButtonUpProcessed()
    
    if( not self.m_activeFrame )
    then
        return
    end

    self:EndMoving()
    self:EndResize()    
end


function LayoutControlFrame:OnRawDeviceInput( deviceId, itemId, itemDown )

    local UP_ARROW_BUTTON_ID    = 200
    local DOWN_ARROW_BUTTON_ID  = 208
    local LEFT_ARROW_BUTTON_ID  = 203
    local RIGHT_ARROW_BUTTON_ID = 205


    -- When Arrow Keys are pressed adjust the screen position
    -- in the appropriate direction.
        
    if( (deviceId == SystemData.InputDevice.KEYBOARD) )
    then
         if( itemId == UP_ARROW_BUTTON_ID )
         then
         
            if( itemDown == 1)
            then
                self.m_adjustOffset.y = -1
            else
                self.m_adjustOffset.y = 0
            end
         
         elseif( itemId == DOWN_ARROW_BUTTON_ID )
         then

            if(  itemDown == 1 )
            then
                self.m_adjustOffset.y = 1
            else
                self.m_adjustOffset.y = 0
            end
    
         elseif( itemId == LEFT_ARROW_BUTTON_ID )
         then
         
            if( itemDown == 1 )
            then
                self.m_adjustOffset.x = -1
            else
                self.m_adjustOffset.x = 0
            end
    
         elseif( itemId == RIGHT_ARROW_BUTTON_ID )
         then
         
            if( itemDown == 1 )
            then
                self.m_adjustOffset.x = 1
            else
                self.m_adjustOffset.x = 0
            end
                
         end     
    end
    
end

-- Context Menu
function LayoutControlFrame:CreateContextMenu()
        
    EA_Window_ContextMenu.CreateContextMenu( self.m_activeFrame:GetSourceWindowName() )
    
    -- Alpha
    EA_Window_ContextMenu.AddMenuItem( GetString( StringTables.Default.LABEL_SET_OPACITY ), EA_Window_ContextMenu.OnWindowOptionsSetAlpha, false, true )

    -- Lock    
    local text = GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_LOCK_FRAME )
    local disabled = self.m_activeFrame:IsLocked()
    EA_Window_ContextMenu.AddMenuItem( text, LayoutControlFrame.OnContextMenuLockFrameProxy, disabled, true )
    
    -- Unlock
    local text = GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_UNLOCK_FRAME )
    local disabled = not self.m_activeFrame:IsLocked()
    EA_Window_ContextMenu.AddMenuItem( text, LayoutControlFrame.OnContextMenuUnlockFrameProxy, disabled, true )
    
    -- Hide
    if( self.m_activeFrame.m_windowData.allowHiding )
    then
        local text = GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_HIDE_FRAME )
        local disabled = self.m_activeFrame:IsHidden()
        EA_Window_ContextMenu.AddMenuItem( text, LayoutControlFrame.OnContextMenuHideFrameProxy, disabled, true )        
        
        local text = GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_SHOW_FRAME )
        local disabled = not self.m_activeFrame:IsHidden()
        EA_Window_ContextMenu.AddMenuItem( text, LayoutControlFrame.OnContextMenuShowFrameProxy, disabled, true )
    end
    
   
    
    EA_Window_ContextMenu.Finalize()
end

function LayoutControlFrame.OnContextMenuLockFrameProxy()
    local controlFrame = GetFrame( LayoutEditor.WINDOW_NAME.."Edit"..EA_Window_ContextMenu.activeWindow.."Controls" )
    controlFrame:OnContextMenuLockFrame() 
end
function LayoutControlFrame:OnContextMenuLockFrame()
    
    if( not self.m_activeFrame )
    then
        return
    end    
    
    if( self.m_activeFrame:IsLocked() )
    then
        return
    end
    
    self.m_activeFrame:SetLocked( true )  
end

function LayoutControlFrame.OnContextMenuUnlockFrameProxy()
    local controlFrame = GetFrame( LayoutEditor.WINDOW_NAME.."Edit"..EA_Window_ContextMenu.activeWindow.."Controls" )
    controlFrame:OnContextMenuUnlockFrame() 
end
function LayoutControlFrame:OnContextMenuUnlockFrame()

    if( not self.m_activeFrame )
    then
        return
    end    
    
    if( not self.m_activeFrame:IsLocked() )
    then
        return
    end
    
    self.m_activeFrame:SetLocked( false )
end

function LayoutControlFrame.OnContextMenuHideFrameProxy()
    local controlFrame = GetFrame( LayoutEditor.WINDOW_NAME.."Edit"..EA_Window_ContextMenu.activeWindow.."Controls" )
    controlFrame:OnContextMenuHideFrame() 
end
function LayoutControlFrame:OnContextMenuHideFrame()

    if( not self.m_activeFrame )
    then
        return
    end    
    
    if( self.m_activeFrame:IsHidden() )
    then
        return
    end  
    
    
    self.m_activeFrame:SetHidden( true )
end

function LayoutControlFrame.OnContextMenuShowFrameProxy()
    local controlFrame = GetFrame( LayoutEditor.WINDOW_NAME.."Edit"..EA_Window_ContextMenu.activeWindow.."Controls" )
    controlFrame:OnContextMenuShowFrame() 
end
function LayoutControlFrame:OnContextMenuShowFrame()

    if( not self.m_activeFrame )
    then
        return
    end    
    
    if( not self.m_activeFrame:IsHidden() )
    then
        return
    end    
    
    self.m_activeFrame:SetHidden( false )
end
