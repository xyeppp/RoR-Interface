BlackOrcResource = CareerResourceFrame:Subclass ("EA_BlackOrcResource")

CareerResource:RegisterResource (GameData.CareerLine.BLACK_ORC, BlackOrcResource)

local sliceLookups =
{
    [0] = 
    { 
        sliceName   = "BlackOrc-Good", width = 118,  height = 62,
        anchor      = 
        {
            Point           = "center",
            RelativePoint   = "center",
            RelativeTo      = "",
            XOffset         = 0,
            YOffset         = 10,
        },
    },
    
    [1] = 
    { 
        sliceName   = "BlackOrc-Betta", width = 118, height = 60,
        anchor      = 
        {
            Point           = "center",
            RelativePoint   = "center",
            RelativeTo      = "",
            XOffset         = 0,
            YOffset         = 4,
        },        
    },
    
    [2] = 
    { 
        sliceName   = "BlackOrc-Best", width = 118, height = 85,
        anchor      = 
        {
            Point           = "center",
            RelativePoint   = "center",
            RelativeTo      = "",
            XOffset         = 0,
            YOffset         = -6,
        },    
    },
}

function BlackOrcResource:Create (windowName)
    for sliceIndex = 0, 2
    do            
        sliceLookups[sliceIndex].anchor.RelativeTo = windowName
    end
    
    local frame = self:CreateFromTemplate (windowName)
    
    if (frame)
    then
        frame.m_Data = CareerResourceData:Create (GameData.CareerLine.BLACK_ORC)

        frame.m_Image = DynamicImage:CreateFrameForExistingWindow (windowName.."Image")
        frame:UpdateResourceDisplay (0, 0)
        frame:Show (true)
    end
    
    return frame
end

function BlackOrcResource:UpdateResourceDisplay (previousResourceValue, currentResourceValue)    
    local slice = sliceLookups[currentResourceValue]
        
    self.m_Image:SetDimensions (slice.width, slice.height)
    self.m_Image:SetTextureDimensions (slice.width, slice.height)
    self.m_Image:SetTextureSlice (slice.sliceName)
    self.m_Image:SetAnchor (slice.anchor)
    self.m_Data:SetPrevious (previousResourceValue)
end

function BlackOrcResource:Update (timePassed)
    -- Currently not very useful, might be used for animations...
end
