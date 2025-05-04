ArchmageResource = CareerResourceFrame:Subclass ("EA_ArchmageResource")

CareerResource:RegisterResource (GameData.CareerLine.ARCHMAGE, ArchmageResource)

function ArchMage_GetPointsString (self)
    local current = self:GetCurrent ()
    
    if (current < 0)
    then
        return GetStringFormat (StringTables.Default.TEXT_HEALING_ARCHMAGE_POINTS, {-current, self:GetMaximum ()})
    elseif (current > 0)
    then
        return GetStringFormat (StringTables.Default.TEXT_DAMAGE_ARCHMAGE_POINTS, {current, self:GetMaximum ()})
    end
    
    return GetString (StringTables.Default.TEXT_NO_ARCHMAGE_POINTS)    
end

local IMAGE     = 0
local GOLD_TEXT = 3
local BLUE_TEXT = 4

function ArchmageResource:Create (windowName)
    local frame = self:CreateFromTemplate (windowName)
    
    if (frame)
    then
        frame.m_Data = CareerResourceData:Create (GameData.CareerLine.ARCHMAGE, ArchMage_GetPointsString)

        frame.m_Windows =
        {
            [IMAGE]     = DynamicImage:CreateFrameForExistingWindow (windowName.."Image"),
            [GOLD_TEXT] = Label:CreateFrameForExistingWindow (windowName.."ImageGoldText"),
            [BLUE_TEXT] = Label:CreateFrameForExistingWindow (windowName.."ImageBlueText"),
        }
        
        frame:UpdateResourceDisplay (0, 0)
        frame:Show (true)
    end
    
    return frame
end

function ArchmageResource:UpdateResourceDisplay (previousResourceValue, currentResourceValue)
    currentResourceValue = self.m_Data:GetCurrent () -- see shaman resource: evil because this calls back into the client 
    
    local sliceName = "ArchmageDefault"

    if (currentResourceValue < 0)
    then
        sliceName = "ArchmageBlueHighlight"
        self.m_Windows[BLUE_TEXT]:SetText (-currentResourceValue)
    elseif (currentResourceValue > 0)
    then
        sliceName = "ArchmageGoldHighlight"
        self.m_Windows[GOLD_TEXT]:SetText (currentResourceValue)
    end
    
    self.m_Windows[IMAGE]:SetTextureSlice (sliceName)
    self.m_Windows[GOLD_TEXT]:Show (currentResourceValue > 0)
    self.m_Windows[BLUE_TEXT]:Show (currentResourceValue < 0)

    self.m_Data:SetPrevious (previousResourceValue)
end

function ArchmageResource:Update (timePassed)
    -- Currently not very useful, might be used for animations...
end
