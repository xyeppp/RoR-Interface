SwordmasterResource = CareerResourceFrame:Subclass ("EA_SwordmasterResource")

CareerResource:RegisterResource (GameData.CareerLine.SWORDMASTER, SwordmasterResource)

local sliceLookups =
{
    [0] = 
    { 
        sliceName   = "SwordmasterGood", width = 128,  height = 80,
        anchor      = 
        {
            Point           = "center",
            RelativePoint   = "center",
            RelativeTo      = "",
            XOffset         = 0,
            YOffset         = 0,
        },
    },
    
    [1] = 
    { 
        sliceName   = "SwordmasterBetta", width = 128, height = 75,
        anchor      = 
        {
            Point           = "center",
            RelativePoint   = "center",
            RelativeTo      = "",
            XOffset         = 0,
            YOffset         = 3,
        },        
    },
    
    [2] = 
    { 
        sliceName   = "SwordmasterBest", width = 128, height = 101,
        anchor      = 
        {
            Point           = "center",
            RelativePoint   = "center",
            RelativeTo      = "",
            XOffset         = 0,
            YOffset         = -12,
        },    
    },
}

function Swordmaster_GetPointsString (self)
    local current = self:GetCurrent ()
    
    if (current == 0)
    then
        return L""
    elseif (current == 1)
    then
        return GetString (StringTables.Default.LABEL_SWORD_MASTER_IMPROVED_BALANCE)
    elseif (current == 2)
    then
        return GetString (StringTables.Default.LABEL_SWORD_MASTER_PERFECT_BALANCE)
    end
    
    return L""
end

function SwordmasterResource:Create (windowName)
    for sliceIndex = 0, 2
    do            
        sliceLookups[sliceIndex].anchor.RelativeTo = windowName
    end
    
    local frame = self:CreateFromTemplate (windowName)
    
    if (frame)
    then
        frame.m_Data = CareerResourceData:Create (GameData.CareerLine.SWORDMASTER, Swordmaster_GetPointsString)

        frame.m_Image = DynamicImage:CreateFrameForExistingWindow (windowName.."Image")
        frame:UpdateResourceDisplay (0, 0)
        frame:Show (true)
    end
    
    return frame
end

function SwordmasterResource:UpdateResourceDisplay (previousResourceValue, currentResourceValue)    
    local slice = sliceLookups[currentResourceValue]
        
    self.m_Image:SetDimensions (slice.width, slice.height)
    self.m_Image:SetTextureDimensions (slice.width, slice.height)
    self.m_Image:SetTextureSlice (slice.sliceName)
    self.m_Image:SetAnchor (slice.anchor)
    self.m_Data:SetPrevious (previousResourceValue)
end

function SwordmasterResource:Update (timePassed)
    -- Currently not very useful, might be used for animations...
end
