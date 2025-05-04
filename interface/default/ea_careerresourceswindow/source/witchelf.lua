WitchElfResource = CareerResourceFrame:Subclass ("EA_WitchElfResource")

CareerResource:RegisterResource (GameData.CareerLine.WITCH_ELF, WitchElfResource)

local SPIKE_1 = 1
local SPIKE_2 = 2
local SPIKE_3 = 3
local SPIKE_4 = 4
local SPIKE_5 = 5

function WitchElfResource:Create (windowName)
    local frame = self:CreateFromTemplate (windowName)
    
    if (frame)
    then
        frame.m_Data = CareerResourceData:Create (GameData.CareerLine.WITCH_ELF)

        frame.m_Windows =
        {
            [SPIKE_1]     = DynamicImage:CreateFrameForExistingWindow (windowName.."Spike1"),
            [SPIKE_2]     = DynamicImage:CreateFrameForExistingWindow (windowName.."Spike2"),
            [SPIKE_3]     = DynamicImage:CreateFrameForExistingWindow (windowName.."Spike3"),
            [SPIKE_4]     = DynamicImage:CreateFrameForExistingWindow (windowName.."Spike4"),
            [SPIKE_5]     = DynamicImage:CreateFrameForExistingWindow (windowName.."Spike5"),
        }
        
        frame:UpdateResourceDisplay( 0, 0 )
    end
    
    return frame
end

function WitchElfResource:UpdateResourceDisplay( previousResourceValue, currentResourceValue )
    self:Show (currentResourceValue > 0)
    
    self.m_Windows[SPIKE_5]:Show( currentResourceValue >= SPIKE_5 )
    self.m_Windows[SPIKE_4]:Show( currentResourceValue >= SPIKE_4 )
    self.m_Windows[SPIKE_3]:Show( currentResourceValue >= SPIKE_3 )
    self.m_Windows[SPIKE_2]:Show( currentResourceValue >= SPIKE_2 )
    self.m_Windows[SPIKE_1]:Show( currentResourceValue >= SPIKE_1 )
    self.m_Data:SetPrevious( previousResourceValue )
end

function WitchElfResource:Update( timePassed )
    -- Currently not very useful, might be used for animations...
end
