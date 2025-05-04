--[[ 
******************************************************************************************************************************************

    Glow Functions

******************************************************************************************************************************************
--]]

-- Default glow function, never allows abilities to glow.
local function NoGlow (self, powerPool, powerPoolMax, powerThreshold, powerCap)
    return 0
end

local function GetDefaultAbilityGlow (self, powerPool, powerPoolMax, powerThreshold, powerCap)
    if (powerPool < powerThreshold) 
    then
        return 0
    elseif ((powerThreshold > 0) and (powerPool == powerThreshold))
    then
        return 1
    end
    
    local glowLevel = powerPool - powerThreshold
    glowLevel = math.floor (glowLevel / self.improvesEvery) + 1
    return math.min (glowLevel, powerCap)
end

local function GetExactAbilityGlow (self, powerPool, powerPoolMax, powerThreshold, powerCap)
    if ((powerThreshold > 0) and (powerPool == powerThreshold))
    then
        return 1
    end
    
    return 0
end

local function GetTippingPointAbilityGlow (self, powerPool, powerPoolMax, powerThreshold, powerCap)
    -- powerPool can be greater than powerPoolMax.  powerPoolMax is being used as the tipping point in this case.
    -- When this function is used, powerPool needs to range from 0 to powerPoolMax * 2
    
    if (powerPool == 0)
    then
        return 0
    end

    -- This has exceeded the threshold by too much and should not cause the icon to glow...
    if (powerPool >= (powerThreshold + powerPoolMax))
    then 
        return 0
    end

    if (powerCap == 0)
    then
        return 0
    end

    local glowLevel = 0

    if (powerPool >= powerThreshold)
    then
        if ((powerPool - powerThreshold) + 1 == powerCap)
        then
            glowLevel = 2
        else
            glowLevel = 1
        end
    end

    return glowLevel
end


--[[ 
******************************************************************************************************************************************

    Conversion Functions 

******************************************************************************************************************************************
--]]

local function TippingPointConvert (self, currentPoints)
    if (currentPoints > self.maxPool)
    then
        return (self.maxPool - currentPoints)
    end
    
    return (currentPoints)
end

--[[ 
******************************************************************************************************************************************

    Career Resource Data Tables

******************************************************************************************************************************************
--]]

EA_CareerResourceData =
{
    [GameData.CareerLine.ARCHMAGE] = 
    { 
        improvesEvery           = 1,  
        maxGlow                 = 5, 
        maxPool                 = 5,   
        tooltipLabelId          = StringTables.Default.LABEL_ARCHMAGE_POINTS, 
        tooltipDescriptionId    = StringTables.Default.TEXT_ARCHMAGE_POINTS_DESC, 
        tooltipPointsId         = 0,
        GetGlowLevel            = GetTippingPointAbilityGlow, 
        ConvertCurrentPoints    = TippingPointConvert,
    },
    
    [GameData.CareerLine.WITCH_ELF] = 
    { 
        improvesEvery           = 1,  
        maxGlow                 = 5, 
        maxPool                 = 5,
        tooltipLabelId          = StringTables.Default.LABEL_WITCH_ELF_POINTS, 
        tooltipDescriptionId    = StringTables.Default.TEXT_WITCH_ELF_POINTS_DESC, 
        tooltipPointsId         = StringTables.Default.LABEL_CUR_CAREER_POINTS,
        GetGlowLevel            = GetDefaultAbilityGlow,      
    },
    
    [GameData.CareerLine.BLACK_ORC] = 
    { 
        improvesEvery           = 1,  
        maxGlow                 = 1, 
        maxPool                 = 2,
        tooltipLabelId          = StringTables.Default.LABEL_BUILDER_POINTS,
        tooltipDescriptionId    = StringTables.Default.TEXT_BUILDER_POINTS_DESC, 
        tooltipPointsId         = StringTables.Default.LABEL_CUR_CAREER_POINTS,
        GetGlowLevel            = GetExactAbilityGlow,
    },
    
    [GameData.CareerLine.DISCIPLE] =
    {
        improvesEvery           = 0,  
        maxGlow                 = 0, 
        maxPool                 = 250,
        tooltipLabelId          = StringTables.Default.LABEL_DISCIPLE_POINTS, 
        tooltipDescriptionId    = StringTables.Default.TEXT_DISCIPLE_POINTS_DESC, 
        tooltipPointsId         = StringTables.Default.TEXT_CUR_DISCIPLE_POINTS,
        GetGlowLevel            = NoGlow,      
    },
    
    [GameData.CareerLine.BRIGHT_WIZARD] = 
    { 
        improvesEvery           = 0,  
        maxGlow                 = 0, 
        maxPool                 = 100,   
        tooltipLabelId          = StringTables.Default.LABEL_BRIGHTWIZARD_POINTS, 
        tooltipDescriptionId    = StringTables.Default.TEXT_BRIGHTWIZARD_POINTS_DESC, 
        tooltipPointsId         = StringTables.Default.TEXT_CUR_BRIGHTWIZARD_POINTS,
        GetGlowLevel            = NoGlow,        
    },    

    [GameData.CareerLine.CHOPPA] = 
    { 
        improvesEvery           = 0, 
        maxGlow                 = 0, 
        maxPool                 = 100, 
        tooltipLabelId          = StringTables.Default.LABEL_BERSERK,
        tooltipDescriptionId    = StringTables.Default.TEXT_BERSERK_CHOPPA_DESC, 
        tooltipPointsId         = StringTables.Default.LABEL_CUR_CAREER_POINTS,
        GetGlowLevel            = NoGlow,  
    },
    
    [GameData.CareerLine.ENGINEER] = 
    { 
        improvesEvery           = 0,  
        maxGlow                 = 0, 
        maxPool                 = 0,
        tooltipLabelId          = 0, 
        tooltipDescriptionId    = 0, 
        tooltipPointsId         = 0,        
        GetGlowLevel            = NoGlow,      
    },
    
    [GameData.CareerLine.SLAYER] = 
    { 
        improvesEvery           = 0,
        maxGlow                 = 0, 
        maxPool                 = 100, 
        tooltipLabelId          = StringTables.Default.LABEL_ENRAGE,
        tooltipDescriptionId    = StringTables.Default.TEXT_ENRAGE_BAR_DESC, 
        tooltipPointsId         = StringTables.Default.LABEL_CUR_CAREER_POINTS,
        GetGlowLevel            = NoGlow,  
    },
    
    [GameData.CareerLine.IRON_BREAKER] = 
    { 
        improvesEvery           = 25, 
        maxGlow                 = 4, 
        maxPool                 = 100, 
        tooltipLabelId          = StringTables.Default.LABEL_GRUDGE, 
        tooltipDescriptionId    = StringTables.Default.TEXT_GRUDGE_BAR_DESC, 
        tooltipPointsId         = StringTables.Default.LABEL_CUR_CAREER_POINTS,
        GetGlowLevel            = GetDefaultAbilityGlow,
    },
    
    [GameData.CareerLine.MAGUS] = 
    { 
        improvesEvery           = 0,  
        maxGlow                 = 0, 
        maxPool                 = 0,
        tooltipLabelId          = 0, 
        tooltipDescriptionId    = 0, 
        tooltipPointsId         = 0,        
        GetGlowLevel            = NoGlow,      
    },
    
    [GameData.CareerLine.WHITE_LION] =
    { 
        improvesEvery           = 0,  
        maxGlow                 = 0, 
        maxPool                 = 0,
        tooltipLabelId          = 0, 
        tooltipDescriptionId    = 0, 
        tooltipPointsId         = 0,        
        GetGlowLevel            = NoGlow,      
    },    
    
    [GameData.CareerLine.BLACKGUARD] =
    { 
        improvesEvery           = 25, 
        maxGlow                 = 4, 
        maxPool                 = 100, 
        tooltipLabelId          = StringTables.Default.LABEL_HATE,
        tooltipDescriptionId    = StringTables.Default.TEXT_HATE_BAR_DESC,
        tooltipPointsId         = StringTables.Default.LABEL_CUR_CAREER_POINTS,
        GetGlowLevel            = GetDefaultAbilityGlow,      
    },
    
    [GameData.CareerLine.SHAMAN] = 
    { 
        improvesEvery           = 1,  
        maxGlow                 = 5, 
        maxPool                 = 5,   
        tooltipLabelId          = StringTables.Default.LABEL_WAAAGH, 
        tooltipDescriptionId    = StringTables.Default.TEXT_WAAAGH_POINTS_DESC, 
        tooltipPointsId         = 0,
        GetGlowLevel            = GetTippingPointAbilityGlow, 
        ConvertCurrentPoints    = TippingPointConvert,
    },
    
    [GameData.CareerLine.SORCERER] =
    {
        improvesEvery           = 1,  
        maxGlow                 = 0, 
        maxPool                 = 100,
        tooltipLabelId          = StringTables.Default.LABEL_SORCEROR_POINTS,
        tooltipDescriptionId    = StringTables.Default.TEXT_SORCEROR_POINTS_DESC, 
        tooltipPointsId         = StringTables.Default.TEXT_CUR_SORCEROR_POINTS,
        GetGlowLevel            = NoGlow,
    },
    
    [GameData.CareerLine.SQUIG_HERDER] =
    {
        improvesEvery           = 0,
        maxGlow                 = 0, 
        maxPool                 = 0,
        tooltipLabelId          = 0,
        tooltipDescriptionId    = 0, 
        tooltipPointsId         = 0,
        GetGlowLevel            = NoGlow,
    },    
    
    [GameData.CareerLine.SWORDMASTER] = 
    { 
        improvesEvery           = 1,  
        maxGlow                 = 1, 
        maxPool                 = 2,
        tooltipLabelId          = StringTables.Default.LABEL_SWORD_MASTER_POINTS,
        tooltipDescriptionId    = StringTables.Default.TEXT_SWORD_MASTER_POINTS_DESC, 
        tooltipPointsId         = 0,
        GetGlowLevel            = GetExactAbilityGlow,        
    },    
    
    [GameData.CareerLine.WARRIOR_PRIEST] = 
    { 
        improvesEvery           = 1,  
        maxGlow                 = 5, 
        maxPool                 = 250, 
        tooltipLabelId          = StringTables.Default.LABEL_RIGHTEOUS_FURY, 
        tooltipDescriptionId    = StringTables.Default.TEXT_RIGHTEOUS_FURY_POINTS_DESC, 
        tooltipPointsId         = StringTables.Default.LABEL_CUR_CAREER_POINTS,
        GetGlowLevel            = GetDefaultAbilityGlow,      
    },
    
    [GameData.CareerLine.WITCH_HUNTER] = 
    { 
        improvesEvery           = 1,  
        maxGlow                 = 5, 
        maxPool                 = 5,
        tooltipLabelId          = StringTables.Default.LABEL_WITCH_HUNTER_POINTS, 
        tooltipDescriptionId    = StringTables.Default.TEXT_WITCH_HUNTER_POINTS_DESC, 
        tooltipPointsId         = StringTables.Default.LABEL_CUR_CAREER_POINTS,
        GetGlowLevel            = GetDefaultAbilityGlow,              
    },
};

--[[ 
******************************************************************************************************************************************

    CareerResourceData : Common Table used by all career resource displays and the action bar system to obtain point mechanic information

******************************************************************************************************************************************
--]]

-- There are not multiple instances of this table, because there is only one career resource
-- active at a time, this is the table for all of them.  This also means that there is currently no
-- way to override this table's functionality.
CareerResourceData = {}

function CareerResourceData:Create (careerLine, tooltipPointsFunction)
    local careerTable = EA_CareerResourceData[careerLine]
    assert (careerTable)
    
    self.m_DataTable            = careerTable
    self.m_Previous             = 0
    
    if (tooltipPointsFunction and type (tooltipPointsFunction) == "function")
    then
        self:OverrideGetPointsString (tooltipPointsFunction)
    else
        -- Restore original if necessary...
        self:OverrideGetPointsString ()
    end
    
    return self
end

function CareerResourceData:OverrideGetPointsString (newPointsStringFunction)
    if (newPointsStringFunction and not self.m_OriginalPointsStringFunction) 
    then
        self.m_OriginalPointsStringFunction = self.GetString
        self.GetPointsString                = newPointsStringFunction
    elseif (not newPointsStringFunction and self.m_OriginalPointsStringFunction) 
    then
        self.GetPointsString                = self.m_OriginalPointsStringFunction
        self.m_OriginalPointsStringFunction = nil
    end
end

function CareerResourceData:GetCurrent ()
    local current = GetCareerResource (GameData.BuffTargetType.SELF)
    
    if (self.m_DataTable.ConvertCurrentPoints)
    then
        return (self.m_DataTable:ConvertCurrentPoints (current))
    end
    
    return current
end

function CareerResourceData:GetMaximum ()
    return self.m_DataTable.maxPool
end

function CareerResourceData:GetPrevious ()
    return self.m_Previous
end

function CareerResourceData:SetPrevious (previous)
    self.m_Previous = previous
end

function CareerResourceData:GetPointsString ()    
    return GetStringFormat (self.m_DataTable.tooltipPointsId, {self:GetCurrent (), self:GetMaximum ()})
end

function CareerResourceData:GetLabelString ()
    return GetString (self.m_DataTable.tooltipLabelId)
end

function CareerResourceData:GetDescriptionString ()
    return GetString (self.m_DataTable.tooltipDescriptionId)
end
