--[[
    Default implementation for several trivial Career Resource Mechanic functions:
    
    GetCurrent
    GetMaximum
    MouseOver (which creates a tooltip)
    UpdateTooltip
--]]

CareerResourceFrame = FrameForLayoutEditor:Subclass ()

function CareerResourceFrame:GetCurrent ()
    return self.m_Data:GetCurrent ()
end

function CareerResourceFrame:GetMaximum ()
    return self.m_Data:GetMaximum ()
end

local CAREER_RESOURCE_TOOLTIP_UPDATE_DELAY = .25 -- update 4 times a second
local updateTimer = 0

local function UpdateCareerResourceTooltip (timePassed)
    updateTimer = updateTimer + timePassed
    
    if (updateTimer >= CAREER_RESOURCE_TOOLTIP_UPDATE_DELAY)
    then
        updateTimer = 0
        
        -- CareerResource.m_CurrentDisplay is not checked for nil because, if it IS nil, then why is this function being called?
        
        Tooltips.SetTooltipText (3, 1, CareerResource.m_CurrentDisplay.m_Data:GetPointsString ())
        Tooltips.Finalize()
    end
end

function CareerResourceFrame:OnMouseOver (flags, x, y)
    local data = self.m_Data
    
    Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name)
    Tooltips.SetTooltipText (1, 1, data:GetLabelString ())
    Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)
    Tooltips.SetTooltipText (2, 1, data:GetDescriptionString ())
    Tooltips.SetTooltipText (3, 1, data:GetPointsString ())
    Tooltips.SetTooltipColorDef (3, 1, Tooltips.COLOR_HEADING);
    Tooltips.Finalize ();
    
    local anchor = Tooltips.ANCHOR_WINDOW_VARIABLE
    if( DoesWindowExist( "MouseOverTargetWindow" ) and SystemData.Settings.GamePlay.staticAbilityTooltipPlacement )
    then
        anchor = Tooltips.ANCHOR_MOUSE_OVER_TARGET_WINDOW
    end
    
    Tooltips.AnchorTooltip (anchor)
    Tooltips.SetUpdateCallback (UpdateCareerResourceTooltip)
end

function CareerResourceFrame:OnInitializeCustomSettings ()
    if (ActionBarClusterManager)
    then
        ActionBarClusterManager:OnInitializeCustomSettingsForFrame (self)
    end
end
