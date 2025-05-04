ShamanResource = CareerResourceFrame:Subclass ("EA_ShamanResource")

CareerResource:RegisterResource (GameData.CareerLine.SHAMAN, ShamanResource)

local TEETH_IMAGE       = 0
local RED_HEAD_IMAGE    = 1
local YELLOW_HEAD_IMAGE = 2
local YELLOW_TEXT       = 3
local RED_TEXT          = 4

local RED_CLOSED    = 12
local RED_OPEN      = 14
local YELLOW_CLOSED = 17
local YELLOW_OPEN   = 19

-- Anchor offsets for the open/closed jaws
local Mastication =
{
    [RED_CLOSED] =
    {
        Point = "topleft",
        RelativePoint = "topleft",
        RelativeTo = "",
        XOffset = -22,
        YOffset = 18,
    },
    
    [RED_OPEN] =
    {
        Point = "topleft",
        RelativePoint = "topleft",
        RelativeTo = "",
        XOffset = -20,
        YOffset = -5,
    },
    
    [YELLOW_CLOSED] =
    {
        Point = "topleft",
        RelativePoint = "topleft",
        RelativeTo = "",
        XOffset = 40,
        YOffset = 18,
    },
    
    [YELLOW_OPEN] =
    {
        Point = "topleft",
        RelativePoint = "topleft",
        RelativeTo = "",
        XOffset = 38,
        YOffset = -5,
    },    
}

--
-- Overridden points string function
-- Replaces CareerResourceData:GetPointsString
--

function Shaman_GetPointsString (self)
    local current = self:GetCurrent ()
    
    if (current < 0)
    then
        return GetStringFormat (StringTables.Default.TEXT_CUR_HEALING_WAAAGH, {-current, self:GetMaximum ()})
    elseif (current > 0)
    then
        return GetStringFormat (StringTables.Default.TEXT_CUR_DAMAGE_WAAAGH, {current, self:GetMaximum ()})
    end
    
    return GetString (StringTables.Default.TEXT_NO_WAAAGH)
end


function ShamanResource:Create (windowName)
    local frame = self:CreateFromTemplate (windowName)
    
    for _, anchorData in pairs (Mastication)
    do
        anchorData.RelativeTo = windowName
    end
    
    if (frame)
    then
        frame.m_Data = CareerResourceData:Create (GameData.CareerLine.SHAMAN, Shaman_GetPointsString)

        frame.m_Windows =
        {
            [TEETH_IMAGE      ] = DynamicImage:CreateFrameForExistingWindow (windowName.."Jaws"),
            [RED_HEAD_IMAGE   ] = DynamicImage:CreateFrameForExistingWindow (windowName.."RedHead"),
            [YELLOW_HEAD_IMAGE] = DynamicImage:CreateFrameForExistingWindow (windowName.."YellowHead"),
            [YELLOW_TEXT      ] = Label:CreateFrameForExistingWindow (windowName.."GoldText"),
            [RED_TEXT         ] = Label:CreateFrameForExistingWindow (windowName.."RedText"),            
        }
        
        frame:UpdateResourceDisplay (0, 0)
        frame:Show (true)
    end
    
    return frame
end

function ShamanResource:CloseMouths ()
    self.m_Windows[RED_HEAD_IMAGE]:SetAnchor (Mastication[RED_CLOSED])
    self.m_Windows[YELLOW_HEAD_IMAGE]:SetAnchor (Mastication[YELLOW_CLOSED])
end

function ShamanResource:OpenRedMouth ()
    self.m_Windows[RED_HEAD_IMAGE]:SetAnchor (Mastication[RED_OPEN])
    self.m_Windows[YELLOW_HEAD_IMAGE]:SetAnchor (Mastication[YELLOW_CLOSED])
end

function ShamanResource:OpenYellowMouth ()
    self.m_Windows[RED_HEAD_IMAGE]:SetAnchor (Mastication[RED_CLOSED])
    self.m_Windows[YELLOW_HEAD_IMAGE]:SetAnchor (Mastication[YELLOW_OPEN])
end

function ShamanResource:UpdateResourceDisplay (previousResourceValue, currentResourceValue)
    currentResourceValue = self.m_Data:GetCurrent () -- this is evil because it calls back into the client
    
    if (currentResourceValue < 0)
    then
        self:OpenRedMouth ()
        self.m_Windows[RED_TEXT]:SetText (-currentResourceValue)
    elseif (currentResourceValue > 0)
    then
        self:OpenYellowMouth ()
        self.m_Windows[YELLOW_TEXT]:SetText (currentResourceValue)
    else
        self:CloseMouths ()
    end
    
    self.m_Windows[YELLOW_TEXT]:Show (currentResourceValue > 0)
    self.m_Windows[RED_TEXT]:Show (currentResourceValue < 0)

    self.m_Data:SetPrevious (previousResourceValue)
end

function ShamanResource:Update (timePassed)
    -- Currently not very useful, might be used for positional animations...
end
