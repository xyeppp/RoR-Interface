
------------------------------------------------------------------------------------------------------------------------------------------------
--# Title: Layout Frame
--#     This file contains the implementaion for the LayoutFrame, which allows the user to select HUD windows for manipulation.
------------------------------------------------------------------------------------------------------------------------------------------------

LayoutFrame = Frame:Subclass("LayoutFrameWindow" )

-- Frame Colors
LayoutFrame.FRAME_COLOR_ACTIVE   = DefaultColor.YELLOW 
LayoutFrame.FRAME_COLOR_LOCKED   = DefaultColor.RED 
LayoutFrame.FRAME_COLOR_UNLOCKED = DefaultColor.BLUE 
LayoutFrame.FRAME_COLOR_HIDDEN   = DefaultColor.MEDIUM_GRAY 

LayoutFrame.BACKGROUND_COLOR_ACTIVE   = DefaultColor.GOLD 
LayoutFrame.BACKGROUND_COLOR_LOCKED   = DefaultColor.ORANGE 
LayoutFrame.BACKGROUND_COLOR_UNLOCKED = DefaultColor.GREEN 
LayoutFrame.BACKGROUND_COLOR_HIDDEN   = DefaultColor.MEDIUM_GRAY 

LayoutFrame.NAME_COLOR_ACTIVE   = DefaultColor.YELLOW 
LayoutFrame.NAME_COLOR_LOCKED   = DefaultColor.WHITE 
LayoutFrame.NAME_COLOR_UNLOCKED = DefaultColor.WHITE 
LayoutFrame.NAME_COLOR_HIDDEN   = DefaultColor.MEDIUM_GRAY 

LayoutFrame.ANCHOR_POINT_TOP_LEFT       = 1
LayoutFrame.ANCHOR_POINT_TOP            = 2
LayoutFrame.ANCHOR_POINT_TOP_RIGHT      = 3
LayoutFrame.ANCHOR_POINT_LEFT           = 4
LayoutFrame.ANCHOR_POINT_CENTER         = 5
LayoutFrame.ANCHOR_POINT_RIGHT          = 6
LayoutFrame.ANCHOR_POINT_BOTTOM_LEFT    = 7
LayoutFrame.ANCHOR_POINT_BOTTOM         = 8
LayoutFrame.ANCHOR_POINT_BOTTOM_RIGHT   = 9


LayoutFrame.ANCHOR_POINTS =
{ 
    [LayoutFrame.ANCHOR_POINT_TOP_LEFT      ] = { name="topleft",       widthMultipler=0.0,  heightMultiplier=0.0 },
    [LayoutFrame.ANCHOR_POINT_TOP           ] = { name="top",           widthMultipler=0.5,  heightMultiplier=0.0 },
    [LayoutFrame.ANCHOR_POINT_TOP_RIGHT     ] = { name="topright",      widthMultipler=1.0,  heightMultiplier=0.0 },
    [LayoutFrame.ANCHOR_POINT_LEFT          ] = { name="left",          widthMultipler=0.0,  heightMultiplier=0.5 },
    [LayoutFrame.ANCHOR_POINT_CENTER        ] = { name="center",        widthMultipler=0.5,  heightMultiplier=0.5 },
    [LayoutFrame.ANCHOR_POINT_RIGHT         ] = { name="right",         widthMultipler=1.0,  heightMultiplier=0.5 },
    [LayoutFrame.ANCHOR_POINT_BOTTOM_LEFT   ] = { name="bottomleft",    widthMultipler=0.0,  heightMultiplier=1.0 },
    [LayoutFrame.ANCHOR_POINT_BOTTOM        ] = { name="bottom",        widthMultipler=0.5,  heightMultiplier=1.0 },
    [LayoutFrame.ANCHOR_POINT_BOTTOM_RIGHT  ] = { name="bottomright",   widthMultipler=1.0,  heightMultiplier=1.0 },
}


-- Local Windows

local function ComputeAnchorScreenPositions( windowName )

    local uiScale = InterfaceCore.GetScale()
    local screenX, screenY = WindowGetScreenPosition( windowName ) 
    
    local width, height = WindowGetDimensions( windowName ) 
    local scale = WindowGetScale( windowName ) 
        
    width   = width*scale
    height  = height*scale
    
    
    --d( "ComputeAnchorScreenPositions: "..windowName.." ( "..width..", "..height.." )" )
    
    
    -- Compute the XY coordates for each anchor point
        
    local positions = {}    
    for index, anchorPoint in ipairs( LayoutFrame.ANCHOR_POINTS )
    do    
        positions[index] = { 
                             x=screenX + width*anchorPoint.widthMultipler,
                             y=screenY + height*anchorPoint.heightMultiplier
                           }
                           
                           
        --DEBUG(L""..StringToWString(windowName)..L" Anchor="..StringToWString(anchorPoint.name)..L" x="..positions[index].x..L" yt="..positions[index].y )
    end   
    
    return positions

end

local function AnchorWindow( windowName, anchorToWindowName, anchorList )

    -- Get the XY coordinates for the anchors
    local windowPositions = ComputeAnchorScreenPositions( windowName )
    local anchorToWindowPositions = ComputeAnchorScreenPositions( anchorToWindowName )    
    
    -- Find the closest anchors that are in the allowable anchor list
    local anchorIndex    = nil
    local anchorDistance = 0
    for index, anchorPoint in ipairs( LayoutFrame.ANCHOR_POINTS )
    do  
        if ( (anchorList ~= nil) and (not anchorList[anchorPoint.name]) )
        then
            continue
        end
        
        local xDistance = windowPositions[index].x - anchorToWindowPositions[index].x 
        local yDistance = windowPositions[index].y - anchorToWindowPositions[index].y 
    
        local distance = math.sqrt( xDistance*xDistance + yDistance*yDistance )
        
        if( (anchorIndex == nil) or ( distance < anchorDistance ) )
        then
            anchorIndex = index
            anchorDistance = distance
        end
        
    end
           
    -- Anchor the Window
    local anchorScale = WindowGetScale( WindowGetParent( windowName ) )
    
    if (anchorIndex ~= nil)
    then
        local point         = LayoutFrame.ANCHOR_POINTS[anchorIndex].name
        local anchorToPoint = LayoutFrame.ANCHOR_POINTS[anchorIndex].name
        local xOffset       = (windowPositions[anchorIndex].x - anchorToWindowPositions[anchorIndex].x ) / anchorScale
        local yOffset       = (windowPositions[anchorIndex].y - anchorToWindowPositions[anchorIndex].y ) / anchorScale
        
        WindowClearAnchors( windowName )
        WindowAddAnchor( windowName, point, anchorToWindowName, anchorToPoint, xOffset, yOffset )
    else
        ERROR(L"Window "..StringToWString(windowName)..L" has restricted all anchor points.  It cannot be anchored.")
    end
        
    --DEBUG(L""..StringToWString(windowName)..L" Anchor="..StringToWString(point)..L" xOffset="..xOffset..L" yOffset="..yOffset )
end


-- Global Functions

function LayoutFrame.NewWindowData( wndName, dspName, desc, sizeWidth, sizeHeight, canHide, setHiddenCallback, allowableAnchorList, neverLockAspect, minSize, resizeEndCallback, moveEndCallback )
    local allowableAnchors = {}
    
    if (allowableAnchorList == nil)
    then
        allowableAnchors = { ["topleft"]    = true,
                             ["top"]        = true,
                             ["topright"]   = true,
                             ["left"]       = true,
                             ["center"]     = true,
                             ["right"]      = true,
                             ["bottomleft"] = true,
                             ["bottom"]     = true,
                             ["bottomright"]= true, }
    else
        for _, anchorName in ipairs(allowableAnchorList)
        do
            allowableAnchors[anchorName] = true
        end
    end
    
    return 
    {
        windowName = wndName,
        displayName = dspName,
        descText = desc,
        
        allowSizeWidth = sizeWidth,
        allowSizeHeight = sizeHeight,  
        neverLockAspect = neverLockAspect,
        minSize = minSize,
        OnResizeEnd = resizeEndCallback,
        OnMoveEnd = moveEndCallback,
        
        allowHiding = canHide,
        OnSetHidden = setHiddenCallback,
        
        isLocked = false,
        isUserHidden = false,       -- Is the window hidden due to the user choosing to hide it?
        isAppHidden = false,        -- Is the window hidden due to the window itself deciding it should not be shown?
        isDefaultHidden = false,    -- When we restore defaults, should the window be hidden?
        
        anchorsAllowed = allowableAnchors
    }
end

-- Implementation

function LayoutFrame:Create( windowData, parentWindow )
    local frame = self:CreateFromTemplate ( parentWindow.."Edit"..windowData.windowName, parentWindow )

    if (frame == nil)
    then
        return nil
    end
    
    -- 1) Set Up The Frame    
    
    frame.m_windowData          = windowData
    frame.m_sourceWindowName    = windowData.windowName      
    frame.m_active              = false    
    
    frame.m_originalLocked      = windowData.isLocked
    frame.m_originalHidden      = windowData.isUserHidden
    
       
    --  Name field  
    --  -> This is created outside of the window so that it can be clicked seperately.
    local labelName = frame:GetName().."Name"
    LabelSetText( labelName, windowData.displayName )    
        
    -- 2) Cache the Source Window's Original Settings
    
    -- Alpha
    frame.m_originalAlpha = WindowGetAlpha( frame.m_sourceWindowName )
    
    -- Scale
    frame.m_originalScale = WindowGetScale( frame.m_sourceWindowName )
    
    -- Dimensions
    local width, height = WindowGetDimensions( frame.m_sourceWindowName )
    frame.m_originalWidth    = width
    frame.m_originalHeight   = height    
    
    -- Position
    frame.m_originalAnchors = {}
    local numAnchors = WindowGetAnchorCount( frame.m_sourceWindowName )
    if ( numAnchors > 0 )
    then
        for index = 1, numAnchors
        do
            local point, relativePoint, relativeTo, xoffs, yoffs = WindowGetAnchor( frame.m_sourceWindowName, index )   
            frame.m_originalAnchors[index] = { Point=point, RelativeTo=relativeTo, RelativePoint=relativePoint, XOffset=xoffs, YOffset=yoffs }  
        end
    else
        frame.m_originalOffsetX, frame.m_originalOffsetY = WindowGetOffsetFromParent( frame.m_sourceWindowName )
    end
      
    -- Screen Offset
    local uiScale = InterfaceCore.GetScale()
    local screenX, screenY = WindowGetScreenPosition( frame.m_sourceWindowName ) 
    frame.m_originalScreenOffsetX = screenX/uiScale;
    frame.m_originalScreenOffsetY = screenY/uiScale; 
    
    frame:SetLocked( windowData.isLocked )

    -- Snapping Data
    self.m_anchorScreenPositions = ComputeAnchorScreenPositions( frame:GetName() ) 
    self.m_snappedFrames = {}
    
    return frame
end

function LayoutFrame:GetSourceWindowName()
    return self.m_sourceWindowName
end

function LayoutFrame:GetDisplayName()
    return self.m_windowData.displayName
end

function LayoutFrame:GetAttachAnchorList()
    return self.m_windowData.anchorsAllowed
end

function LayoutFrame:Attach()

    -- Copy the Source Window Settings over to the Active Frame    
    local uiScale           = InterfaceCore.GetScale()        
    local width, height     = WindowGetDimensions( self.m_sourceWindowName )
    local scale             = WindowGetScale( self.m_sourceWindowName )
    local screenX, screenY  = WindowGetScreenPosition( self.m_sourceWindowName ) 

    -- Set the Size      
    local frameWidth  = width*scale/uiScale
    local frameheight = height*scale/uiScale
    self:SetDimensions( frameWidth, frameheight )
        
    -- Set the Screen Position
    screenX = screenX/uiScale;
    screenY = screenY/uiScale; 
    local anchor = { Point="topleft", RelativeTo="Root", RelativePoint="topleft", XOffset=screenX, YOffset=screenY }
    self:SetAnchor( anchor )
    
    -- Anchor the Source Window to the Layout Frame
    WindowClearAnchors( self.m_sourceWindowName )
    WindowAddAnchor( self.m_sourceWindowName, "topleft", self:GetName(), "topleft", 0, 0 )
    
    -- Force the size to it's original dimensions (We may have removed an duel anchor)
    WindowSetDimensions( self.m_sourceWindowName, width, height )

    self:UpdateScreenRect()

    self:Show( true )
end

function LayoutFrame:Detach( saveChanges )
    
    -- If we're saving the changes, we only need to determine the best new anchor
    if( saveChanges )
    then
        AnchorWindow( self.m_sourceWindowName, "Root", self:GetAttachAnchorList() ) 
        return
    end
    
    
    -- Otherwise, restore all of the origional settings
    
    -- Restore the Alpha
    WindowSetAlpha( self.m_sourceWindowName, self.m_originalAlpha )
    
    -- Restore the Size
    WindowSetDimensions( self.m_sourceWindowName, self.m_originalWidth , self.m_originalHeight )
            
    -- Restore the Scale
    WindowSetScale( self.m_sourceWindowName, self.m_originalScale )
    
    -- Restore the Position
    if ( #self.m_originalAnchors > 0 )
    then
        WindowClearAnchors( self.m_sourceWindowName )
        for index, anchor in ipairs( self.m_originalAnchors )
        do
            WindowAddAnchor( self.m_sourceWindowName, anchor.Point, anchor.RelativeTo, anchor.RelativePoint, anchor.XOffset, anchor.YOffset )
        end
    else
        WindowSetOffsetFromParent( self.m_sourceWindowName, self.m_originalOffsetX, self.m_originalOffsetY )
    end
    
    self:Show( false )
    
    if( self.m_windowData.allowHiding )
    then
        self:SetHidden( self.m_originalHidden )
    end
    
    self:SetLocked( self.m_originalLocked )
      
end

function LayoutFrame:UpdateFrameColor()

    local frameColor = nil
    local backgroundColor = nil
    local nameColor = nil
        
    if( self:IsLocked() )
    then
        frameColor = LayoutFrame.FRAME_COLOR_LOCKED        
        backgroundColor = LayoutFrame.BACKGROUND_COLOR_LOCKED
        nameColor = LayoutFrame.NAME_COLOR_LOCKED
        
    elseif( self:IsHidden() )    
    then
        frameColor = LayoutFrame.FRAME_COLOR_HIDDEN        
        backgroundColor = LayoutFrame.BACKGROUND_COLOR_HIDDEN
        nameColor = LayoutFrame.NAME_COLOR_HIDDEN
        
        if( self.m_active ) then
            nameColor = LayoutFrame.NAME_COLOR_ACTIVE
        else
            nameColor = LayoutFrame.NAME_COLOR_HIDDEN
        end
        
    elseif( self.m_active ) 
    then
        frameColor =  LayoutFrame.FRAME_COLOR_ACTIVE
        backgroundColor = LayoutFrame.BACKGROUND_COLOR_ACTIVE
        nameColor = LayoutFrame.NAME_COLOR_ACTIVE
        
    else
        frameColor = LayoutFrame.FRAME_COLOR_UNLOCKED        
        backgroundColor = LayoutFrame.BACKGROUND_COLOR_UNLOCKED
        nameColor = LayoutFrame.NAME_COLOR_UNLOCKED
    end

    DefaultColor.SetWindowTint( self:GetName().."Frame", frameColor )
    DefaultColor.SetWindowTint( self:GetName().."Background", backgroundColor )
    
    DefaultColor.SetLabelColor( self:GetName().."Name", nameColor )

end

function LayoutFrame:SetActive( active )
    self.m_active = active
    self:UpdateFrameColor()        
     
end

function LayoutFrame:IsActive()
    return self.m_active
end

function LayoutFrame:SetLocked( locked )
    self.m_windowData.isLocked = locked
    self:UpdateFrameColor()    
    
    -- Update the Window Browser
    LayoutEditor.UpdateWindowBrowserForFrame( self )
    
 end

function LayoutFrame:IsLocked()
    return self.m_windowData.isLocked
end

function LayoutFrame:SetHidden( hidden )
    self.m_windowData.isUserHidden = hidden
       
    -- If the source window has an OnSetHidden Callback,
    -- Call that function.  Otherwise just show/hide the window.
    if( self.m_windowData.OnSetHidden )
    then
        self.m_windowData.OnSetHidden()
    else
        WindowSetShowing( self:GetSourceWindowName(), not self.m_windowData.isUserHidden and not self.m_windowData.isAppHidden )  
    end
    
    -- Update the Window Browser
    LayoutEditor.UpdateWindowBrowserForFrame( self )

    
    self:UpdateFrameColor()
end

function LayoutFrame:IsHidden()
    return self.m_windowData.isUserHidden
end

function LayoutFrame:AllowHiding()
    return self.m_windowData.allowHiding
end

function LayoutFrame:AllowSizeWidth()
    return self.m_windowData.allowSizeWidth
end

function LayoutFrame:AllowSizeHeight()
    return self.m_windowData.allowSizeHeight
end

function LayoutFrame:Save()
          
    local uiScale = InterfaceCore.GetScale()                   
    local screenX, screenY = WindowGetScreenPosition( self:GetName() ) 
    local xOffset = screenX --/uiScale 
    local yOffset = screenY --/uiScale       
      
    local width, height = WindowGetDimensions( self.m_sourceWindowName )
        
    -- Transfer the Anchors over to the Source Window          
    WindowClearAnchors( self.m_sourceWindowName )    
    WindowAddAnchor( self.m_sourceWindowName, "topleft", "Root", "topleft", xOffset, yOffset )
    
end

function LayoutFrame:RestoreDefaults()
    WindowRestoreDefaultSettings( self.m_sourceWindowName )
    self:SetHidden( self.m_windowData.isDefaultHidden )
end


function LayoutFrame:Reset()
   
    -- Restore the Size
    WindowSetDimensions( self.m_sourceWindowName, self.m_originalWidth , self.m_originalHeight )
          
    -- Restore the Scale
    WindowSetScale( self.m_sourceWindowName, self.m_originalScale )
    
    -- Restore the Screen Position
    local anchor = { Point="topleft", RelativeTo="Root", RelativePoint="topleft", XOffset=self.m_originalScreenOffsetX, YOffset=self.m_originalScreenOffsetY }
    self:SetAnchor( anchor )

end


function LayoutFrame:Update( timePassed )
    
    if( self.m_resizing ) 
    then
        self:ProcessResize()
    end   
    
end

function LayoutFrame:ScaleWindowToDimensions( desiredWidth, desiredHeight )
       
   -- Scale the Window according frame's desired size according to its initial dimensions   
   --  (A-Scale)*(A-Size) = (B-Scale)*(B-Size)

   local uiScale = InterfaceCore.GetScale()    
      
   local desiredScaledWidth = desiredWidth*uiScale
   local desiredScaledHeight = desiredHeight*uiScale    
   
   local currentWidth, currentHeight = WindowGetDimensions( self.m_sourceWindowName )
   local currentScale = WindowGetScale( self.m_sourceWindowName )
   
   local currentScaledWidth  = currentWidth*currentScale
   local currentScaledHeight = currentHeight*currentScale
          
   local xScale =  ( (desiredScaledWidth - currentScaledWidth) + currentScaledWidth )/ (currentScaledWidth )
   local yScale =  ( (desiredScaledHeight - currentScaledHeight) + currentScaledHeight )/ ( currentScaledHeight )
      
   -- Use the minimum scale to keep the ratio
   local scale = 1.0
   if( xScale < yScale )
   then
        scale = xScale*currentScale
   else   
        scale = yScale*currentScale
   end
   
   -- Scale the Source Window to reflect these new scaled dimenisons
   WindowSetScale( self.m_sourceWindowName, scale )    
   
   -- Resize the Frame to force the correct aspect ratio    
   -- Force the frame back to the correct dimensions 
   local frameWidth = currentWidth*scale/uiScale
   local frameHeight = currentHeight*scale/uiScale
   self:SetDimensions( frameWidth, frameHeight )
   
   self:UpdateScreenRect()
   
end

function LayoutFrame:SizeWindowToDimensions( desiredWidth, desiredHeight )
       
   -- Scale the Window's dimensions to match this new size.   
   --  (A-Scale)*(A-Size) = (B-Scale)*(B-Size)

   local uiScale = InterfaceCore.GetScale()       
   local windowScale = WindowGetScale( self.m_sourceWindowName )   
      
   local newWidth   = desiredWidth*uiScale/windowScale
   local newHeight  = desiredHeight*uiScale/windowScale
   
   -- Scale the Source Window to reflect these new scaled dimenisons
   WindowSetDimensions( self.m_sourceWindowName, newWidth, newHeight )    
   
   self:SetDimensions( desiredWidth, desiredHeight )
   
   self:UpdateScreenRect()
   
end

function LayoutFrame:UpdateScreenRect()

    -- Recalcuate all of the anchor positions
   self.m_anchorScreenPositions = ComputeAnchorScreenPositions( self:GetName() ) 

end


function LayoutFrame:GetAnchorScreenPositions()
    return self.m_anchorScreenPositions
end
   
   