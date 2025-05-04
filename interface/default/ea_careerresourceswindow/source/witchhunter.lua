WitchHunterResource = CareerResourceFrame:Subclass ("EA_WitchHunterResource")

CareerResource:RegisterResource (GameData.CareerLine.WITCH_HUNTER, WitchHunterResource)

function WitchHunterResource:Create (windowName)
    local frame = self:CreateFromTemplate (windowName)
    
    if (frame)
    then
        frame.m_Data = CareerResourceData:Create (GameData.CareerLine.WITCH_HUNTER)

        frame.m_Windows =
        {
            [1]           = DynamicImage:CreateFrameForExistingWindow (windowName.."Spike1"),
            [2]           = DynamicImage:CreateFrameForExistingWindow (windowName.."Spike2"),
            [3]           = DynamicImage:CreateFrameForExistingWindow (windowName.."Spike3"),
            [4]           = DynamicImage:CreateFrameForExistingWindow (windowName.."Spike4"),
            [5]           = DynamicImage:CreateFrameForExistingWindow (windowName.."Spike5"),
            ["Skull"]     = DynamicImage:CreateFrameForExistingWindow (windowName.."Image"),
            ["Eyes"]      = DynamicImage:CreateFrameForExistingWindow (windowName.."Eyes"),
        }
        
        frame:UpdateResourceDisplay (0, 0)
        frame:Show (true)
        WindowStartAlphaAnimation( windowName.."Eyes", Window.AnimationType.LOOP, 1, 0, 1.5, false, 0, 0 )
    end
    
    return frame
end

function WitchHunterResource:UpdateResourceDisplay (previousResourceValue, currentResourceValue)
    -- DEBUG(L"WitchHunterResource:UpdateResourceDisplay ("..previousResourceValue..L", "..currentResourceValue..L")")
    for spikeIndex = 1, 5
    do
        self.m_Windows[spikeIndex]:Show( (spikeIndex <= currentResourceValue) )
    end
    self.m_Windows["Eyes"]:Show( currentResourceValue >= 5 )

    self.m_Data:SetPrevious (previousResourceValue)
end

function WitchHunterResource:Update (timePassed)
    -- Currently not very useful, might be used for animations...
end
