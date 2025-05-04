WarriorPriestResource = CareerResourceFrame:Subclass ("EA_WarriorPriestResource")

CareerResource:RegisterResource (GameData.CareerLine.WARRIOR_PRIEST, WarriorPriestResource)

local FILL_IMAGE        = 1
local BACKGROUND_IMAGE  = 2
local RESOURCE_TEXT     = 3

function WarriorPriestResource:Create (windowName)
    local frame = self:CreateFromTemplate (windowName)
    
    if (frame)
    then
        frame.m_Data = CareerResourceData:Create (GameData.CareerLine.WARRIOR_PRIEST)

        frame.m_Windows =
        {
            [FILL_IMAGE]        = DynamicImage:CreateFrameForExistingWindow (windowName.."FillImage"),
            [BACKGROUND_IMAGE]  = DynamicImage:CreateFrameForExistingWindow (windowName.."BackgroundImage"),
            [RESOURCE_TEXT]     = Label:CreateFrameForExistingWindow(windowName.."Text")
        }
        
        frame.m_fillTextureInfo =
        {
            name    = "EA_Career_WP_32b",
            width   = 103,
            height  = 60,
            minX    = 0,
            minY    = 68,
            maxX    = 103,
            maxY    = 128,
        }
        
        frame:UpdateResourceDisplay (0, 0)
        frame:Show (true)
    end
    
    return frame
end

function WarriorPriestResource:UpdateResourceDisplay (previousResourceValue, currentResourceValue)
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

function WarriorPriestResource:Update (timePassed)
    -- Currently not very useful, might be used for animations...
end
