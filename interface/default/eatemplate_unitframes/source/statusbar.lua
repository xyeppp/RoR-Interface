-----------------------------------------------------------------------------
-- Hostile template for a health bar, based on the same ideas behind UnitFrames.
-- UnitFrames actually uses this health bar implementation.
-- Look and feel depends on the friendly flag of the main UnitFrame, since
-- tinting is no longer an option as of FM4 (3/5/08 gnelson)
-- 
-----------------------------------------------------------------------------

UnitFrameHostileStatusBar = Frame:Subclass ("UnitFrameHostileStatusBar")

--
-- Create a new instance of a UnitFrameHostileStatusBar and initialize it.
-- 
function UnitFrameHostileStatusBar:Create (windowName, parentWindow)
    local statusBar = self:CreateFromTemplate (windowName, parentWindow)

    if (statusBar == nil)
    then
        return nil
    end

    statusBar.m_MaxValue        = 100
            
    -- Target Health is displayed as a percent; hide the text
    -- TODO: Revisit this when targets are groupmembers and (I think) it should be legal to display actual health values...
    StatusBarSetMaximumValue (windowName, statusBar.m_MaxValue)
    
    return statusBar
end

--
-- Event handlers.  These are the generic handlers from the template.  
-- They need to extract the current window being interacted with to 
-- know which UnitFrameHostileStatusBar to actually operate on.
--


function UnitFrameHostileStatusBar:SetValue (percent)
    local myName = self:GetName ()
    
    StatusBarSetCurrentValue (myName, percent)
end

function UnitFrameHostileStatusBar:StopInterpolating ()
    StatusBarStopInterpolating (self:GetName ())
end

function UnitFrameHostileStatusBar:SetForegroundTint (colorTable)
    StatusBarSetForegroundTint (self:GetName (), colorTable.r, colorTable.g, colorTable.b)
end

function UnitFrameHostileStatusBar:SetBackgroundTint (colorTable)
    StatusBarSetBackgroundTint (self:GetName (), colorTable.r, colorTable.g, colorTable.b)
end


-----------------------------------------------------------------------------
-- Friendly template for a health bar, based on the same ideas behind UnitFrames.
-- UnitFrames actually uses this health bar implementation.
-- Look and feel depends on the friendly flag of the main UnitFrame, since
-- tinting is no longer an option as of FM4 (3/5/08 gnelson)
-- 
-----------------------------------------------------------------------------

UnitFrameFriendlyStatusBar = Frame:Subclass ("UnitFrameFriendlyStatusBar")

--
-- Create a new instance of a UnitFrameFriendlyStatusBar and initialize it.
-- 
function UnitFrameFriendlyStatusBar:Create (windowName, parentWindow)
    local statusBar = self:CreateFromTemplate (windowName, parentWindow)

    if (statusBar == nil)
    then
        return nil
    end

    statusBar.m_MaxValue        = 100
            
    -- Target Health is displayed as a percent; hide the text
    -- TODO: Revisit this when targets are groupmembers and (I think) it should be legal to display actual health values...
    StatusBarSetMaximumValue (windowName, statusBar.m_MaxValue)
    
    return statusBar
end

--
-- Event handlers.  These are the generic handlers from the template.  
-- They need to extract the current window being interacted with to 
-- know which UnitFrameHostileStatusBar to actually operate on.
--

function UnitFrameFriendlyStatusBar:SetValue (percent)
    local myName = self:GetName ()
    
    StatusBarSetCurrentValue (myName, percent)
end

function UnitFrameFriendlyStatusBar:StopInterpolating ()
    StatusBarStopInterpolating (self:GetName ())
end

function UnitFrameFriendlyStatusBar:SetForegroundTint (colorTable)
    StatusBarSetForegroundTint (self:GetName (), colorTable.r, colorTable.g, colorTable.b)
end

function UnitFrameFriendlyStatusBar:SetBackgroundTint (colorTable)
    StatusBarSetBackgroundTint (self:GetName (), colorTable.r, colorTable.g, colorTable.b)
end
