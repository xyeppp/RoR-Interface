-----------------------------------------------------------------------------
-- Object wrapper and base class for a Frame.  
--
-- Create Frames from templates, and get a table that wraps access to
-- relevant windowing functions so that there's much less need to refer
-- to hardcoded window names
-- 
-----------------------------------------------------------------------------

--
-- Frame:
-- The base window object...
--

Frame = 
{ 
    FORCE_HIDE      = 94,
    FORCE_OVERRIDE  = 6321,
    LOOPING_ANIM    = true,
    ONESHOT_ANIM    = false,
    HIDE_ON_FINISH  = true,
    SHOWN_ON_FINISH = false,
}

Frame.__index = Frame

--
-- Define a template table that can be used as a factory for subclassed Frame tables.
-- The returned table can be used as a Frame.
--
function Frame:Subclass (templateName)
    local derivedObject = setmetatable ({}, self)
    
    derivedObject.__index       = derivedObject
    derivedObject.m_Template    = templateName  -- it's totally cool for this to be nil
    
    for k, v in pairs (self)
    do
        if (type (v) == "function")
        then
            derivedObject["Parent"..k] = v
        end
    end
    
    return derivedObject
end

--
-- It is sometimes desirable to create a new Frame without actually bringing
-- a new Window into existence.  This function is used both internally and externally
-- to create the table object that wraps a window which has already been created.
-- It returns the same Frame table that CreateFromTemplate returns, but without calling
-- CreateWindowFromTemplate.  
--
function Frame:CreateFrameForExistingWindow (windowName)
    local newFrame = setmetatable ({}, self)
    
    newFrame.m_Name             = windowName
    newFrame.m_Id               = EA_IdGenerator:GetNewId ()

    WindowSetId (newFrame.m_Name, newFrame.m_Id)

    FrameManager:Add (newFrame.m_Name, newFrame)

    return newFrame
end

--
-- Create a new instance of a uniquely named window from the template
-- member that was defined when this Frame was subclassed.
-- Automatically generates a new (and "unique") id for the window
-- and stores the newly created window in the FrameManager.
-- 
function Frame:CreateFromTemplate (windowName, parentName)   
    if (self.m_Template == nil or self.m_Template == "")
    then
        -- If self was not created with Frame:Subclass 
        -- or was itself just a subclass of Frame,
        -- do not allow this function to create anything
        return nil
    end
    
    parentName = parentName or "Root"
            
    if (CreateWindowFromTemplate (windowName, self.m_Template, parentName) == true)
    then
        local newFrame = self:CreateFrameForExistingWindow (windowName)
        
        -- Hide all newly created windows by default...
        newFrame:Show (false)
        
        return newFrame
    end
    
    return nil
end

function Frame:ClearAnchors()
    WindowClearAnchors (self:GetName ())
end

function Frame:SetAnchor (anchor, anchor2)
    assert (DoesWindowExist (self:GetName ()))
    
    if (anchor)
    then
        WindowClearAnchors (self:GetName ())
        
        local relativeTo    = anchor.RelativeTo or "Root"
        local point         = anchor.Point or "topleft"
        local relativePoint = anchor.RelativePoint or "topleft"
        local x             = anchor.XOffset or 0
        local y             = anchor.YOffset or 0
        
        assert (DoesWindowExist (relativeTo))
        
        WindowAddAnchor (self:GetName (), point, relativeTo, relativePoint, x, y)

        -- Only set anchor2 if anchor was valid.        
        if (anchor2)
        then
            relativeTo    = anchor2.RelativeTo or "Root"
            point         = anchor2.Point or "topleft"
            relativePoint = anchor2.RelativePoint or "topleft"
            x             = anchor2.XOffset or 0
            y             = anchor2.YOffset or 0        
            
            assert (DoesWindowExist (relativeTo))
            
            WindowAddAnchor (self:GetName (), point, relativeTo, relativePoint, x, y)
        end
    end
end

function Frame:ForceProcessAnchors ()
    WindowForceProcessAnchors (self:GetName ())
end

function Frame:Destroy ()   
    DestroyWindow (self:GetName ())
    FrameManager:Remove(self:GetName ())
end

function Frame:Show (showState, override)
    assert (showState ~= nil)
    
    if ((self.m_Showing ~= showState) or (override == Frame.FORCE_OVERRIDE))
    then
        WindowSetShowing (self:GetName (), showState)
        self.m_Showing = showState
    end
    
    return self.m_Showing
end

function Frame:IsShowing ()
    if (self.m_Showing == nil)
    then
        self.m_Showing = WindowGetShowing (self:GetName ())
    end
        
    return self.m_Showing
end

function Frame:GetName ()
    return self.m_Name
end

function Frame:GetId ()
    return self.m_Id
end

function Frame:SetMovable (isMovable)
    WindowSetMovable (self:GetName (), isMovable)
end

function Frame:SetRelativeScale (scale)
    WindowSetRelativeScale (self:GetName (), scale)
end

function Frame:SetScale (scale)
    WindowSetScale (self:GetName (), scale)
end

function Frame:GetScale ()
    return WindowGetScale (self:GetName ())
end

function Frame:GetParent ()
    return GetFrame (WindowGetParent (self:GetName ()))
end

function Frame:SetParent (parent)
    WindowSetParent (self:GetName (), parent )
end

function Frame:GetDimensions ()
    if (self.m_Width == nil)
    then
        self.m_Width, self.m_Height = WindowGetDimensions (self:GetName ())
    end
    
    return self.m_Width, self.m_Height
end

function Frame:SetDimensions (width, height, override)
    if (self.m_Width ~= width or self.m_Height ~= height or (override == Frame.FORCE_OVERRIDE))
    then
        WindowSetDimensions (self:GetName (), width, height)
        self.m_Width    = width
        self.m_Height   = height
    end
end

function Frame:GetUnscaledScreenPosition ()
    -- Never returning the cached versions of screen position because there is no default Frame event handler
    -- for the moved, scaled, sized events.
    
    self.m_UnscaledScreenX, self.m_UnscaledScreenY = WindowGetScreenPosition (self:GetName ())

    local interfaceScale = InterfaceCore.GetScale()

    if (interfaceScale == nil or interfaceScale == 0)
    then
        interfaceScale = 1
    end

    self.m_UnscaledScreenX = self.m_UnscaledScreenX / interfaceScale
    self.m_UnscaledScreenY = self.m_UnscaledScreenY / interfaceScale
    
    return self.m_UnscaledScreenX, self.m_UnscaledScreenY
end

function Frame:SetAlpha (alpha)
    WindowSetAlpha (self:GetName (), alpha)
end

function Frame:SetFontAlpha (alpha)
    WindowSetFontAlpha (self:GetName (), alpha)
end

function Frame:SetTint(color)
    self:SetTintColor(color.r, color.g, color.b)
end


function Frame:SetTintColor (r, g, b)
    if (self.m_TintColorRed ~= r or self.m_TintColorGreen ~= g or self.m_TintColorBlue ~= b)
    then
        WindowSetTintColor (self:GetName (), r, g, b)
        
        self.m_TintColorRed     = r 
        self.m_TintColorGreen   = g 
        self.m_TintColorBlue    = b
    end
end

function Frame:StartAlphaAnimation (tweenType, initialAlpha, terminalAlpha, animationRate, delay, loopCount)
    self:Show (true, Frame.FORCE_OVERRIDE)
    
    local unsupportedParameter = false -- "SetStartBeforeDelay" does not appear to be used.
    WindowStartAlphaAnimation (self:GetName (), tweenType, initialAlpha, terminalAlpha, animationRate, unsupportedParameter, delay, loopCount)
end

function Frame:StopAlphaAnimation (forceHide)
    if (forceHide == Frame.FORCE_HIDE)
    then
        self:Show (false, Frame.FORCE_OVERRIDE)
    end
    
    WindowStopAlphaAnimation (self:GetName ())
end

function Frame:ResizeOnChildren( recurseOnChildrensChildren, borderSpacing )
    -- Reset the width and height for future calls to get dimensions
    self.m_Width = nil
    self.m_Height = nil
    
    WindowResizeOnChildren( self:GetName(), recurseOnChildrensChildren, borderSpacing )
end

-- 
-- Default Input Event handlers so that extended windows do not
-- need to implement them
--

function Frame:OnMouseOver (flags, mouseX, mouseY)      end
function Frame:OnMouseOverEnd (flags, mouseX, mouseY)   end
function Frame:OnLButtonDown (flags, mouseX, mouseY)    end
function Frame:OnLButtonUp (flags, mouseX, mouseY)      end
function Frame:OnRButtonDown (flags, mouseX, mouseY)    end
function Frame:OnRButtonUp (flags, mouseX, mouseY)      end
function Frame:OnMouseWheel (x, y, delta, flags)        end
function Frame:OnUpdate (elapsedTime)                   end
function Frame:OnInitializeCustomSettings ()            end

-- FrameForLayoutEditor uses the LayoutEditor Show/Hide functions to show or hide itself
FrameForLayoutEditor = Frame:Subclass ()

function FrameForLayoutEditor:Show( showState )
    self.m_Showing = showState
    
    if ( LayoutEditor and self.m_LayoutRegistered )
    then
        if ( showState )
        then
            LayoutEditor.Show( self:GetName() )
        else
            LayoutEditor.Hide( self:GetName() )
        end
    else
        WindowSetShowing( self:GetName(), showState )
    end
    
    return showState
end

function FrameForLayoutEditor:RegisterLayout( windowDisplayName, windowDesc, allowSizeWidth, allowSizeHeight, allowHiding, setHiddenCallback, allowableAnchorList, neverLockAspect, minSize, resizeEndCallback, moveEndCallback )
    if ( LayoutEditor and not self.m_LayoutRegistered )
    then
        LayoutEditor.RegisterWindow( self:GetName(), windowDisplayName, windowDesc, allowSizeWidth, allowSizeHeight, allowHiding, setHiddenCallback, allowableAnchorList, neverLockAspect, minSize, resizeEndCallback, moveEndCallback )
        self.m_LayoutRegistered = true
        
        if ( not self.m_Showing )
        then
            LayoutEditor.Hide( self:GetName() )
        end
    end
end

function FrameForLayoutEditor:UnregisterLayout()
    if ( LayoutEditor and self.m_LayoutRegistered )
    then
        LayoutEditor.UnregisterWindow( self:GetName() )
        self.m_LayoutRegistered = false
    end
end