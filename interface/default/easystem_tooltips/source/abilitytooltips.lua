
local function GetAbilityCastTimeText (abilityData)
    if (abilityData.numTacticSlots > 0)
    then
        return GetString (StringTables.Default.LABEL_ABILITY_TOOLTIP_PASSIVE_CAST)
    end
    
    local castTime = GetAbilityCastTime (abilityData.id)
    
    if (castTime > 0) 
    then
        local _, castTimeFraction = math.modf (castTime)
        local params = nil
        
        if (castTimeFraction ~= 0)
        then
            params = { wstring.format( L"%.1f", castTime) }
        else
            params = { wstring.format( L"%d", castTime) }
        end
            
        return (GetStringFormat (StringTables.Default.LABEL_ABILITY_TOOLTIP_CAST_TIME, params))
    end    
    
    return (GetString (StringTables.Default.LABEL_ABILITY_TOOLTIP_INSTANT_CAST))
end

local function GetAbilityCostText (abilityData)
    if (abilityData.moraleLevel ~= 0) 
    then    
        local params = { abilityData.moraleLevel }
        return (GetStringFormat (StringTables.Default.LABEL_ABILITY_TOOLTIP_MORALE_COST, params))
    elseif (abilityData.numTacticSlots ~= 0) 
    then
        local params = { abilityData.numTacticSlots, Tooltips.TacticsTypeStrings[abilityData.tacticType] }
        return (GetStringFormat (StringTables.Default.LABEL_ABILITY_TOOLTIP_TACTIC_COST, params))
    else
        local apCost = GetAbilityActionPointCost (abilityData.id)
        
        if (apCost > 0)
        then
            local params = { apCost }
            
            if (abilityData.hasAPCostPerSecond)
            then
                return (GetStringFormat (StringTables.Default.LABEL_ABILITY_TOOLTIP_AP_COST_PER_SECOND, params))
            else
                return (GetStringFormat (StringTables.Default.LABEL_ABILITY_TOOLTIP_ACTION_POINT_COST, params))
            end
        end
    end
    
    return (GetString (StringTables.Default.LABEL_ABILITY_TOOLTIP_NO_COST))
end

local function GetAbilityRangeText (abilityData)
    local labelText = GetString (StringTables.Default.LABEL_ABILITY_TOOLTIP_NO_RANGE)
    local minRange, maxRange = GetAbilityRanges (abilityData.id)
    
    local fConstFootToMeter = 0.3048
    local bUseInternationalSystemUnit = SystemData.Territory.KOREA    
    
    if ((minRange > 0) and (maxRange > 0))
    then
        local stringID = StringTables.Default.LABEL_ABILITY_TOOLTIP_MIN_RANGE_TO_MAX_RANGE
        if bUseInternationalSystemUnit
        then
            minRange = string.format( "%d", minRange * fConstFootToMeter + 0.5 )
            maxRange = string.format( "%d", maxRange * fConstFootToMeter + 0.5 )
            stringID = StringTables.Default.LABEL_ABILITY_TOOLTIP_MIN_TO_MAX_RANGE_METERS
        end
        local params = { minRange, maxRange }
        labelText = GetStringFormat (stringID, params)  
    elseif (maxRange > 0) 
    then
        local stringID = StringTables.Default.LABEL_ABILITY_TOOLTIP_MAX_RANGE
        if bUseInternationalSystemUnit
        then
            maxRange = string.format( "%d", maxRange * fConstFootToMeter + 0.5 )
            stringID = StringTables.Default.LABEL_ABILITY_TOOLTIP_MAX_RANGE_METERS
        end
        local params = { maxRange }
        labelText = GetStringFormat (stringID, params)
    end
    
    return (labelText)
end

local function GetAbilityLevelText (abilityData)
    local upgradeRank = GetAbilityUpgradeRank (abilityData.id)
    
    if (upgradeRank > 0)
    then
        return (GetStringFormat (StringTables.Default.LABEL_ABILITY_TOOLTIP_ABILITY_RANK, {upgradeRank}))
    end
    
    return (GetString (StringTables.Default.LABEL_ABILITY_TOOLTIP_ABILITY_NO_RANK))
end

local function GetAbilityCooldownText( cooldown )
    if ( cooldown > 0 ) 
    then
        -- For abilities with cooldowns under a min, we care about the first decimal.
        -- For instance some abilities have a 1.5 sec cooldown
        local timeText
        if( cooldown < 60 )
        then
            timeText = TimeUtils.FormatRoundedSeconds( cooldown, 0.1, true, false )
        else
            timeText = TimeUtils.FormatSeconds( cooldown, true )
        end
        return ( GetStringFormat( StringTables.Default.LABEL_ABILITY_TOOLTIP_COOLDOWN, { timeText } ) )
    end
    
    return (GetString (StringTables.Default.LABEL_ABILITY_TOOLTIP_NO_COOLDOWN))
end

-- Ability Tooltip
-- extraText will be drawn after a seperator at the bottom of the tooltip if present.
-- extraTextColor should be a table like { r = red, g = green, b = blue }, 
-- If there is no color specified, the extraText will draw be grey.
function Tooltips.CreateAbilityTooltip( abilityData, mouseoverWindow, anchor, extraText, extraTextColor ) 

    if( abilityData == nil ) 
    then
        return
    end
    
    local windowName = "AbilityTooltip"

    Tooltips.SetAbilityTooltipData( windowName, abilityData, extraText, extraTextColor ) 
        
    -- Create the tooltip...anchoring magically works!
    Tooltips.CreateCustomTooltip( mouseoverWindow, windowName )
    
    Tooltips.AnchorTooltip( anchor, false, true )
    
end

function Tooltips.SetAbilityTooltipData( windowName, abilityData, extraText, extraTextColor ) 

    local labelText = L""
    local c_BASE_TOOLTIP_WIDTH = 350
    local c_TOOLTIP_BUFFER = 15

    -- Name, Desc    
    LabelSetText (windowName.."Desc", GetAbilityDesc (abilityData.id))
    
    -- Left Column (spec line, cost, cast time)
    
    LabelSetText( windowName.."Name",         GetStringFormat(StringTables.Default.LABEL_ABILITY_TOOLTIP_ABILITY_NAME, {abilityData.name}))
    LabelSetText( windowName.."SpecLine",     DataUtils.GetAbilitySpecLine (abilityData))
    LabelSetText( windowName.."Cost",         GetAbilityCostText (abilityData))
    LabelSetText( windowName.."CastTime",     GetAbilityCastTimeText (abilityData))
    
    -- Right Column (type, range, cooldown)
    
    LabelSetText( windowName.."Type",         DataUtils.GetAbilityTypeText (abilityData))
    LabelSetText( windowName.."Level",        GetAbilityLevelText (abilityData))
    LabelSetText( windowName.."Range",        GetAbilityRangeText (abilityData))
    
    -- Get the cooldown including potential bonuses from c instead of the value stored in abilityData.cooldown
    local realCooldown = GetAbilityCooldown( abilityData.id ) / 1000
    LabelSetText( windowName.."Cooldown", GetAbilityCooldownText( realCooldown ) )
    
    -- Requirements...
    local reqs = GetAbilityRequirements( abilityData.id )
    
    for reqsIndex = 1, GameData.ABILITY_REQUIREMENT_COUNT
    do
        local reqsLabel = windowName.."Requirements"..reqsIndex
        
        if ((reqs[reqsIndex] ~= nil) and (DoesWindowExist (reqsLabel)))
        then
            LabelSetText (reqsLabel, reqs[reqsIndex])
        else
            LabelSetText (reqsLabel, L"")
        end
    end
    
    -- Extra Text
    Tooltips.SetExtraText( windowName, "ActionText", "ActionTextLine", extraText, extraTextColor)
    
    local x, y = WindowGetDimensions(windowName.."Desc")    
    WindowSetDimensions(windowName.."Desc", c_BASE_TOOLTIP_WIDTH, y )
    
    -- Resizing/reformating calculations
    
    local nameWidth, nameHeight = LabelGetTextDimensions(windowName.."Name")
    local typeWidth, typeHeight = LabelGetTextDimensions(windowName.."Type")  

    local costWidth, costHeight = LabelGetTextDimensions(windowName.."Cost")
    local rangeWidth, rangeHeight = LabelGetTextDimensions(windowName.."Range")  

    local casttimeWidth, casttimeHeight = LabelGetTextDimensions(windowName.."CastTime")
    local cooldownWidth, cooldownHeight = LabelGetTextDimensions(windowName.."Cooldown")  
    
    local width1 = nameWidth + typeWidth + c_TOOLTIP_BUFFER
    local width2 = costWidth + rangeWidth + c_TOOLTIP_BUFFER
    local width3 = casttimeWidth + cooldownWidth + c_TOOLTIP_BUFFER
    
    local newWidth = math.max( math.max( width1, width2 ), width3 )
    
    for reqsIndex = 1, GameData.ABILITY_REQUIREMENT_COUNT
    do
        local reqWidth, _ = LabelGetTextDimensions(windowName.."Requirements"..reqsIndex) + c_TOOLTIP_BUFFER
        newWidth = math.max( newWidth, reqWidth )
    end
   
    x, y = WindowGetDimensions(windowName.."Desc")  
   
    if( newWidth > c_BASE_TOOLTIP_WIDTH ) then        
        WindowSetDimensions(windowName.."Desc", newWidth, y )
    else
        WindowSetDimensions(windowName.."Desc", c_BASE_TOOLTIP_WIDTH, y )
    end       
    
    LabelSetText( windowName.."Desc", GetAbilityDesc (abilityData.id))

end

