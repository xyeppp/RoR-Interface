-----------------------------------------------------------------------------
-- Templates for a health bar, based on the same ideas behind UnitFrames.
-- UnitFrames actually uses this health bar implementation.
-- 
-----------------------------------------------------------------------------

RvRIndicator = Frame:Subclass ("RvRFlagIndicator")

local RvRTooltips =
{
    [SystemData.TargetObjectType.NONE]              = L"",
    [SystemData.TargetObjectType.SELF]              = GetString( StringTables.Default.TOOLTIP_RVR_INDICATOR),
    [SystemData.TargetObjectType.ALLY_PLAYER]       = L"",
    [SystemData.TargetObjectType.ALLY_NON_PLAYER]   = L"",
    [SystemData.TargetObjectType.ENEMY_PLAYER]      = GetString (StringTables.Default.TOOLTIP_PLAYER_RVR_INDICATOR),
    [SystemData.TargetObjectType.ENEMY_NON_PLAYER]  = GetString (StringTables.Default.TOOLTIP_MONSTER_RVR_INDICATOR),
    [SystemData.TargetObjectType.STATIC]            = L"",
    [SystemData.TargetObjectType.STATIC_ATTACKABLE] = L"",
}

--
-- Create a new instance of a RvRIndicator and initialize it.
-- 
function RvRIndicator:Create (windowName, parentWindow)
    local rvrFrame = self:CreateFromTemplate (windowName, parentWindow)
    
    if (rvrFrame)
    then
        -- Make the RvR flag icon smaller.
        rvrFrame:SetRelativeScale (.55);
    end
    
    return rvrFrame
end

function RvRIndicator:SetTargetType (targetType)
    self.m_TargetType = targetType
end

function RvRIndicator:GetTargetType ()
    return self.m_TargetType 
end

function RvRIndicator.OnMouseOver()
    local frame = FrameManager:GetMouseOverWindow ()
    
    if (frame ~= nil)
    then
        local frameName = frame:GetName ()
        local targetType = frame:GetTargetType ()
        
        if (RvRTooltips[targetType] ~= L"")
        then
            Tooltips.CreateTextOnlyTooltip (frameName, RvRTooltips[targetType])

            local tooltip_anchor = 
            { 
                Point           = "bottom",  
                RelativeTo      = WindowGetParent (frameName), 
                RelativePoint   = "top",   
                XOffset         = 0, 
                YOffset         = 20 
            }

            Tooltips.AnchorTooltip (tooltip_anchor)
        end
    end
end
