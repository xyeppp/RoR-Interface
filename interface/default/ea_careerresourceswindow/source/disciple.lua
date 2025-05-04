DiscipleResource = CareerResourceFrame:Subclass ("EA_DiscipleResource")

CareerResource:RegisterResource (GameData.CareerLine.DISCIPLE, DiscipleResource)

local FILL_IMAGE        = 1
local BACKGROUND_IMAGE  = 2
local RESOURCE_TEXT     = 3

function DiscipleResource:Create (windowName)
    local frame = self:CreateFromTemplate (windowName)
    
    if (frame)
    then
        frame.m_Data = CareerResourceData:Create (GameData.CareerLine.DISCIPLE)

        frame.m_Windows =
        {
            [FILL_IMAGE]        = DynamicImage:CreateFrameForExistingWindow (windowName.."FillImage"),
            [BACKGROUND_IMAGE]  = DynamicImage:CreateFrameForExistingWindow (windowName.."BackgroundImage"),
            [RESOURCE_TEXT]     = Label:CreateFrameForExistingWindow(windowName.."Text")
        }
        
        frame.m_fillTextureInfo =
        {
            name    = "EA_Career_Di_32b",
            width   = 110,
            height  = 37,
            minX    = 0,
            minY    = 86,
            maxX    = 110,
            maxY    = 123,
        }
        
        frame:UpdateResourceDisplay (0, 0)
        frame:Show (true)
    end
    
    return frame
end

function DiscipleResource:Initialize()
    self:Update (0, 0)
end

function DiscipleResource:UpdateResourceDisplay (previousResourceValue, currentResourceValue)
    local fillImage     = self.m_Windows[FILL_IMAGE]
    local fillImageInfo = self.m_fillTextureInfo
    local fillPercent   = currentResourceValue / self:GetMaximum()
    local height        = math.floor ( (fillPercent * fillImageInfo.height) + 0.5 )
    local texY          = fillImageInfo.maxY - height

    fillImage:SetDimensions( fillImageInfo.width, height )
    fillImage:SetTextureDimensions( fillImageInfo.width, height )
    fillImage:SetTexture( fillImageInfo.name, fillImageInfo.minX, texY )
    
    self.m_Windows[RESOURCE_TEXT]:SetText( currentResourceValue )
    self.m_Windows[RESOURCE_TEXT]:Show( currentResourceValue ~= 0 )
end

function DiscipleResource:Update (timePassed)
    -- Currently not very useful, might be used for animations...
end
