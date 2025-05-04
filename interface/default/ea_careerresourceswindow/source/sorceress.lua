SorceressResource = CareerResourceFrame:Subclass ("EA_SorceressResource")

CareerResource:RegisterResource (GameData.CareerLine.SORCERER, SorceressResource)

function SorceressResource:Create (windowName)
    local frame = self:CreateFromTemplate (windowName)
    
    if (frame)
    then
        frame.m_Data = CareerResourceData:Create (GameData.CareerLine.SORCERER)

        frame.m_Windows =
        {
            ["Text"]      = Label:CreateFrameForExistingWindow(windowName.."Text"),
            ["Frame"]     = DynamicImage:CreateFrameForExistingWindow (windowName.."Image"),
            ["Orb"]       = DynamicImage:CreateFrameForExistingWindow (windowName.."Orb"),
        }
        
        frame.GetLevel =    function (resourceAmount)
                                if     (resourceAmount == 0) then   return 0
                                elseif (resourceAmount <= 10) then  return 1 
                                elseif (resourceAmount <= 30) then  return 2
                                elseif (resourceAmount <= 70) then  return 3
                                elseif (resourceAmount <= 90) then  return 4
                                elseif (resourceAmount <= 100) then return 5 end
                            end

        frame:UpdateResourceDisplay (0, 0)
        frame:Show (true)
        frame.m_Windows["Frame"]:Show(true)
    end
    
    return frame
end

function SorceressResource:UpdateResourceDisplay (previousResourceValue, currentResourceValue)
    local resourceLevel = self.GetLevel(currentResourceValue)
    
    if (resourceLevel > 0)
    then
        local sliceName = "Sorcerer-Orb"..resourceLevel
        self.m_Windows["Orb"]:Show(true)
        self.m_Windows["Orb"]:SetTextureSlice(sliceName)
        self.m_Windows["Text"]:SetText(L""..currentResourceValue)
        self.m_Windows["Text"]:Show(true)
    else
        self.m_Windows["Orb"]:Show(false)
        self.m_Windows["Text"]:Show(false)
    end

    self.m_Data:SetPrevious (previousResourceValue)
end

function SorceressResource:Update (timePassed)
    -- Currently not very useful, might be used for animations...
end
