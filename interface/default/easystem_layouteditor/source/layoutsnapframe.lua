
------------------------------------------------------------------------------------------------------------------------------------------------
--# Title: Layout Snap Frame
--#     This file contains the implementaion for the Snap Frame for the Layout Editor. This tracks the screen location of every
--#     window and suggests windows that the active frame may be snapped to.
------------------------------------------------------------------------------------------------------------------------------------------------


-- Snap Frame Class
LayoutSnapFrame = Frame:Subclass("LayoutSnapFrameWindow" )

LayoutSnapFrame.SNAP_PAIRS =
{ 
    -- Window 1                                 -- Window 2
    {LayoutFrame.ANCHOR_POINT_TOP_LEFT,         LayoutFrame.ANCHOR_POINT_BOTTOM_LEFT },
    {LayoutFrame.ANCHOR_POINT_TOP_LEFT,         LayoutFrame.ANCHOR_POINT_TOP_RIGHT },
    {LayoutFrame.ANCHOR_POINT_TOP,              LayoutFrame.ANCHOR_POINT_BOTTOM },
    {LayoutFrame.ANCHOR_POINT_TOP_RIGHT,        LayoutFrame.ANCHOR_POINT_BOTTOM_RIGHT },
    {LayoutFrame.ANCHOR_POINT_TOP_RIGHT,        LayoutFrame.ANCHOR_POINT_TOP_LEFT },
    {LayoutFrame.ANCHOR_POINT_LEFT,             LayoutFrame.ANCHOR_POINT_RIGHT },
    {LayoutFrame.ANCHOR_POINT_RIGHT,            LayoutFrame.ANCHOR_POINT_LEFT },
    {LayoutFrame.ANCHOR_POINT_RIGHT,            LayoutFrame.ANCHOR_POINT_LEFT },
    {LayoutFrame.ANCHOR_POINT_BOTTOM_LEFT,      LayoutFrame.ANCHOR_POINT_BOTTOM_RIGHT },
    {LayoutFrame.ANCHOR_POINT_BOTTOM_LEFT,      LayoutFrame.ANCHOR_POINT_TOP_LEFT },
    {LayoutFrame.ANCHOR_POINT_BOTTOM,           LayoutFrame.ANCHOR_POINT_TOP },    
    {LayoutFrame.ANCHOR_POINT_BOTTOM_RIGHT,     LayoutFrame.ANCHOR_POINT_TOP_RIGHT },
    {LayoutFrame.ANCHOR_POINT_BOTTOM_RIGHT,     LayoutFrame.ANCHOR_POINT_BOTTOM_LEFT },
}

local function GetAnchorDistance( anchorsList1, anchor1, anchorsList2, anchor2 )

    local xDistance = anchorsList1[anchor1].x - anchorsList2[anchor2].x 
    local yDistance = anchorsList1[anchor1].y - anchorsList2[anchor2].y 

    return math.sqrt( xDistance*xDistance + yDistance*yDistance )
end


-- Implementation
function LayoutSnapFrame:Create( windowName, parentName )
    local frame = self:CreateFromTemplate(windowName, parentName )

    if (frame == nil)
    then
        return nil
    end
    
    -- 1) Set Up The Frame         
    frame.m_activeControlFrame = nil  
    frame.m_snapToFrame = nil
    frame.m_snapToIndex = 0
    
    frame.m_lastPosition = { x=0, y=0 }
        
    DefaultColor.SetWindowTint( windowName, DefaultColor.ORANGE )     
    
    frame:Show( false )
    
    
    return frame
end

function LayoutSnapFrame:SetActiveFrame( controlFrame )
    
    if( not LayoutEditor.IsWindowSnappingEnabled()  )
    then
        return
    end           
   
    self.m_activeControlFrame = controlFrame          

    -- Size the snap frame to the same size as our source frame
    if( self.m_activeControlFrame )
    then            
        local sourceFrame = self.m_activeControlFrame:GetActiveFrame()              
        LayoutEditorUtils.CopySize( sourceFrame, self, 0, 0, false)
        self:FindSnap()
    else
        self.m_snapToFrame = nil
        self.m_snapToIndex = 0
        self:UpdateDisplay()
    end
end

function LayoutSnapFrame:Update()

    if( self.m_activeControlFrame )
    then 
    
        -- If the ControlFrame has moved, update the snap
        local screenX, screenY = WindowGetScreenPosition( self.m_activeControlFrame:GetName() )    
        
        if( screenX ~= self.m_lastPosition.x or screenY ~= self.m_lastPosition.y )
        then
        
            self.m_lastPosition.x = screenX
            self.m_lastPosition.x = screenY
            self:FindSnap()
        end
    end

end


-- Loop Through all of the windows and search for a valid snap point.
function LayoutSnapFrame:FindSnap()
    
    local layoutFrame = self.m_activeControlFrame:GetActiveFrame()
    local anchorPositions = layoutFrame:GetAnchorScreenPositions()
    
    local maxSnapDistance = LayoutEditor.GetWindowSnapDistance()

    local distance = maxSnapDistance + 1
    local snapFrame = nil
    local snapIndex = nil
    
    for _, frame in pairs( LayoutEditor.framesList ) 
    do       
        if( frame ~= layoutFrame )
        then          
        
            local comparePositions = frame:GetAnchorScreenPositions()            
            
            for index, snapPair in ipairs( LayoutSnapFrame.SNAP_PAIRS )
            do
                local dist = GetAnchorDistance( anchorPositions, snapPair[1], comparePositions, snapPair[2] )
                
                -- If the distance between the anchors is within the snap threshold, save the value
                if( (dist <= maxSnapDistance) and (dist < distance) )
                then
                    distance = dist
                    snapFrame = frame
                    snapIndex = index
                end
           end
        end
    end    
    
    -- Update the Snap Frame
    if( snapFrame ~= self.m_snapToFrame or snapIndex ~= self.m_snapToIndex )
    then    
        self.m_snapToFrame = snapFrame
        self.m_snapToIndex = snapIndex
        self:UpdateDisplay()    
    end
    
end

function LayoutSnapFrame:HasSnap()
    return (self.m_snapToFrame ~= nil)
end


function LayoutSnapFrame:UpdateDisplay()

    if( self.m_snapToFrame == nil )
    then
        -- Hide the Snap Frame when there 
        -- is not a valid snap point
        self:Show( false )
        self:ClearAnchors()
        return
    end   
    
   
    -- Position the Snap Point
    
    
    self:Show( true )

    local anchorPt   = LayoutSnapFrame.SNAP_PAIRS[ self.m_snapToIndex][2]
    local anchorToPt = LayoutSnapFrame.SNAP_PAIRS[ self.m_snapToIndex][1]


    -- Anchor the SnapFrame to it's anchor point.
    local anchor = { Point=LayoutFrame.ANCHOR_POINTS[anchorPt].name, 
                     RelativeTo=self.m_snapToFrame:GetName(),
                     RelativePoint=LayoutFrame.ANCHOR_POINTS[anchorToPt].name, 
                     XOffset=0, 
                     YOffset=0 }
                     
    self:SetAnchor( anchor )
end
    