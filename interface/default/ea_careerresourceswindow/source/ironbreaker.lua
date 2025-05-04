IronBreakerResource = CareerResourceFrame:Subclass ("EA_IronBreakerResource")

CareerResource:RegisterResource (GameData.CareerLine.IRON_BREAKER, IronBreakerResource)

local GLOW_IMAGE        = 1
local BACKGROUND_IMAGE  = 2
local RESOURCE_TEXT     = 3

function IronBreakerResource:Create (windowName)
    local frame = self:CreateFromTemplate (windowName)
    
    if (frame)
    then
        frame.m_Data = CareerResourceData:Create (GameData.CareerLine.IRON_BREAKER)

        frame.m_Windows =
        {
            [GLOW_IMAGE]        = DynamicImage:CreateFrameForExistingWindow (windowName.."GlowImage"),
            [BACKGROUND_IMAGE]  = DynamicImage:CreateFrameForExistingWindow (windowName.."BackgroundImage"),
            [RESOURCE_TEXT]     = Label:CreateFrameForExistingWindow (windowName.."Text"),
        }
        
        frame:UpdateResourceDisplay (0, 0)
        frame:Show (true)
    end
    
    return frame
end

function IronBreakerResource:Initialize()
    self:Update (0, 0)
end

function IronBreakerResource:UpdateResourceDisplay (previousResourceValue, currentResourceValue)
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

function IronBreakerResource:Update (timePassed)
    -- Currently not very useful, might be used for animations...
end
