BlackGuardResource = CareerResourceFrame:Subclass ("EA_BlackGuardResource")

CareerResource:RegisterResource (GameData.CareerLine.BLACKGUARD, BlackGuardResource)

local RESOURCE_TEXT = 1
local BG_IMAGE = 2
local GLOW_IMAGE = 3

function BlackGuardResource:Create (windowName)
    local frame = self:CreateFromTemplate (windowName)
    
    if (frame)
    then
        frame.m_Data = CareerResourceData:Create (GameData.CareerLine.BLACKGUARD)

        frame.m_Windows =
        {
            [RESOURCE_TEXT] = Label:CreateFrameForExistingWindow (windowName.."Text"),
            [BG_IMAGE]      = DynamicImage:CreateFrameForExistingWindow (windowName.."BackgroundImage"),
            [GLOW_IMAGE]    = DynamicImage:CreateFrameForExistingWindow (windowName.."GlowImage"),
        }
        
        frame:UpdateResourceDisplay (0, 0)
        frame:Show (true)
        frame.m_Windows[RESOURCE_TEXT]:Show (true)
    end
    
    return frame
end

function BlackGuardResource:Initialize()
    self:Update (0, 0)
end

function BlackGuardResource:UpdateResourceDisplay (previousResourceValue, currentResourceValue)
    local glowPercent = currentResourceValue / self:GetMaximum()
    
    local glowWindow = self.m_Windows[GLOW_IMAGE]
    
    if( glowPercent < 1.0 )
    then
        glowWindow:StopAlphaAnimation()
        glowWindow:SetAlpha( glowPercent )
    else
        glowWindow:StartAlphaAnimation(Window.AnimationType.LOOP, 1, 0, 0.5, 0, 0 )
    end
    
    self.m_Windows[RESOURCE_TEXT]:SetText( currentResourceValue )
    self.m_Windows[RESOURCE_TEXT]:Show( currentResourceValue ~= 0 )
end

function BlackGuardResource:Update (timePassed)
    -- Currently not very useful, might be used for animations...
end
