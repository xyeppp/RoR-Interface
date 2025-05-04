-----------------------------------------------------------------------------
-- "Singleton" class for the FrameManager.  
--
-- Management object to hold window frames (keyed on their UNIQUE names)
-- 
-----------------------------------------------------------------------------

FrameManager = 
{
    m_Frames = {}
}

function FrameManager:Add (frameName, frameObject)
    assert (frameName ~= nil)
    assert (type (frameName) == "string")
    assert (self.m_Frames[frameName] == nil)
    
    if (self.m_Frames[frameName] == nil)
    then
        self.m_Frames[frameName] = frameObject
    end
end

function FrameManager:Remove(frameName)
    assert (frameName ~= nil)
    assert (type (frameName) == "string")
    assert (self.m_Frames[frameName] ~= nil)
    
    -- Remove this frame, and all of its children from the managed frame table
    -- Currently implemented with a temporary table which will cause some GC churn...
    
    self.m_Frames[frameName] = nil
    
    -- Forgive the napping/playing analogy, it sounded less brutal than the alternative.
    
    -- 
    local nappingChildTable = {}
    local playingChildTable = self.m_Frames
    local patternString     = "^"..frameName
    
    for potentialNapper, _ in pairs (playingChildTable)
    do  
        -- For each window that is a child of this frame, add it to the removal list
        local windowName = potentialNapper
        while( windowName ~= nil and windowName ~= "" )
        do
        
            if( windowName == frameName )
            then
                nappingChildTable[ potentialNapper ] = true
                break
            end
            
            windowName = WindowGetParent( windowName )
        end
        
    end
    
    for childScheduledForNapping, _ in pairs (nappingChildTable)
    do
        self.m_Frames[childScheduledForNapping] = nil
    end
end

--
-- Sometimes it's desirable to allow different windows to resolve to the same frame object.
-- This will usually occur when the window represented by windowName is a child window of 
-- the window represented by frameObject.
--
-- The function is called ResolveWindowToFrame so that it's clear to the caller that this is
-- not a simple Add...even though calling FrameManager:Add works just as well.
--
-- The requirement that self.m_Frames[windowName] == nil is still enforced.  
-- It is not possible at this point to allow a single window to resolve to multiple frames.
-- 
function FrameManager:ResolveWindowToFrame (windowName, frameObject)
    self:Add (windowName, frameObject)
end

function FrameManager:Get (frameName)   
    assert (frameName ~= nil)
    assert (type (frameName) == "string")
    
    return self.m_Frames[frameName]
end

-- Alias for FrameManager:Get
function GetFrame (frameName)
    return (FrameManager:Get (frameName))
end

function FrameManager:Shutdown ()
    for windowName, windowObject in pairs (self.m_Frames)
    do
        windowObject:Destroy ()
    end
    
    self.m_Frames = {}
end

--
-- Queries the FrameManager for the mouse-over window's id and returns the
-- contained Frame object, or nil if a Frame by that name was not present.
--
function FrameManager:GetMouseOverWindow ()
    return self.m_Frames[SystemData.MouseOverWindow.name]
end

--
-- Similar to the GetMouseOverWindow function, this one uses the active window.
--
function FrameManager:GetActiveWindow ()
    return self.m_Frames[SystemData.ActiveWindow.name]
end

--
-- As long as the given windowName exists and does not have a managed frameObject this function
-- wraps it in a Frame, adds it to the managed frames, and returns the new Frame as a convenience.
-- Otherwise returns nil or the existing Frame.
--
function FrameManager:EnsureWindowHasFrame (windowName)
    local frame = GetFrame (windowName)
    
    -- Attempt to add the "frameless" window to the FrameManager table...
    if ((frame == nil) and (windowName ~= "") and (DoesWindowExist (windowName)))
    then 
        -- TODO: Remove runtime dependency on Frame if possible.
        frame = Frame:CreateFrameForExistingWindow (windowName)
    end
    
    return frame
end

--
-- FrameManager:
-- Input event handlers, fowarded to the appropriate frame objects
-- Unfortunately, this cannot use a reference to a generic FrameManager
-- table.  Which means that FrameManager must remain a singleton; but 
-- is just a limitation on extensibility, not the current implementation.
--
-- Functions like "FrameManager.OnMouseOver" and "FrameManager.OnLButtonDown"
-- can be directly used in XML declarations as long as the windows your 
-- mod defines are derived from Frame.  The FrameManager will forward
-- the calls on to the appropriate handlers in your Frame object
-- instatiations.
--
-- NOTE: These functions are implemented as needed, if the desired event
-- doesn't exist here, please add it for everyone else.
--
-- NOTE: When adding new handlers here, please remember to add a default handler
-- to Frame.lua so that the "if (frame.MethodName ~= nil) ..." check doesn't
-- need to be performed.
--

function FrameManager.OnMouseOver (flags, mouseX, mouseY)
    local frame = FrameManager:GetActiveWindow ()
    
    if (frame)
    then
        frame:OnMouseOver (flags, mouseX, mouseY)
    end
end

function FrameManager.OnMouseOverEnd (flags, mouseX, mouseY)
    local frame = FrameManager:GetActiveWindow ()
    
    if (frame)
    then
        frame:OnMouseOverEnd (flags, mouseX, mouseY)
    end
end

function FrameManager.OnLButtonDown (flags, mouseX, mouseY)
    local frame = FrameManager:GetActiveWindow ()
    
    if (frame)
    then
        frame:OnLButtonDown (flags, mouseX, mouseY)
    end
end

function FrameManager.OnLButtonUp (flags, mouseX, mouseY)
    local frame = FrameManager:GetActiveWindow ()
    
    if (frame)
    then
        frame:OnLButtonUp (flags, mouseX, mouseY)
    end
end

function FrameManager.OnRButtonDown (flags, mouseX, mouseY)
    local frame = FrameManager:GetActiveWindow ()
    
    if (frame)
    then
        frame:OnRButtonDown (flags, mouseX, mouseY)
    end
end

function FrameManager.OnRButtonUp (flags, mouseX, mouseY)
    local frame = FrameManager:GetActiveWindow ()
    
    if (frame)
    then
        frame:OnRButtonUp (flags, mouseX, mouseY)
    end
end

function FrameManager.OnMouseWheel (x, y, delta, flags)
    local frame = FrameManager:GetActiveWindow ()
    
    if (frame)
    then
        frame:OnMouseWheel (x, y, delta, flags)
    end
end

function FrameManager.OnUpdate (elapsedTime)
    local frame = FrameManager:GetActiveWindow ()
    
    if (frame)
    then
        frame:OnUpdate (elapsedTime)
    end
end

function FrameManager.OnInitializeCustomSettings ()
    local frame = FrameManager:GetActiveWindow ()
    
    if (frame)
    then
        frame:OnInitializeCustomSettings ()
    end
end

function FrameManager.OnTextChanged(text)
    local frame = FrameManager:GetActiveWindow ()
    
    if ( frame and frame.OnTextChanged )
    then
        frame:OnTextChanged( text )
    end
end
