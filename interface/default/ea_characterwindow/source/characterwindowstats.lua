
-- IDs for select stat icons
CharacterWindow.LABEL_MELEE_BONUS = "CharacterWindow.LABEL_MELEE_BONUS"
CharacterWindow.LABEL_MELEE_SPEED = "CharacterWindow.LABEL_MELEE_SPEED"
CharacterWindow.LABEL_MELEE_CRIT_BONUS = "CharacterWindow.LABEL_MELEE_CRIT_BONUS"
CharacterWindow.LABEL_MELEE_CRIT_DAMAGE = "CharacterWindow.LABEL_MELEE_CRIT_DAMAGE"
-- Range selections
CharacterWindow.LABEL_RANGED_SPEED = "CharacterWindow.LABEL_RANGED_SPEED"
CharacterWindow.LABEL_RANGED_BONUS = "CharacterWindow.LABEL_RANGED_BONUS"
CharacterWindow.LABEL_RANGED_CRIT_BONUS = "CharacterWindow.LABEL_RANGED_CRIT_BONUS"
CharacterWindow.LABEL_RANGED_CRIT_DAMAGE = "CharacterWindow.LABEL_RANGED_CRIT_DAMAGE"
-- Spell selections
CharacterWindow.LABEL_SPELL_HEALING_BONUS = "CharacterWindow.LABEL_SPELL_HEALING_BONUS"

-- Icon info for the stats icons
CharacterWindow.StatIconInfo = {  }
-- Stats selections
CharacterWindow.StatIconInfo[GameData.Stats.STRENGTH]   =  { iconNum=100 }
CharacterWindow.StatIconInfo[GameData.Stats.TOUGHNESS]   =  { iconNum=103 }
CharacterWindow.StatIconInfo[GameData.Stats.WOUNDS]   =  { iconNum=104 }
CharacterWindow.StatIconInfo[GameData.Stats.INITIATIVE]   =  { iconNum=105 }
CharacterWindow.StatIconInfo[GameData.Stats.WEAPONSKILL]   =  { iconNum=106 }
CharacterWindow.StatIconInfo[GameData.Stats.BALLISTICSKILL]   =  { iconNum=107 }
CharacterWindow.StatIconInfo[GameData.Stats.INTELLIGENCE]   =  { iconNum=108 }
CharacterWindow.StatIconInfo[GameData.Stats.WILLPOWER]   =  { iconNum=102 }
-- Defense selections
CharacterWindow.StatIconInfo[StringTables.Default.LABEL_ARMOR]   =  { iconNum=121 }
CharacterWindow.StatIconInfo[GameData.Stats.CORPOREALRESIST]   =  { iconNum=164 }
CharacterWindow.StatIconInfo[GameData.Stats.SPIRITRESIST]   =  { iconNum=155 }
CharacterWindow.StatIconInfo[GameData.Stats.ELEMENTALRESIST]   =  { iconNum=162 }
CharacterWindow.StatIconInfo[GameData.Stats.BLOCKSKILL]   =  { iconNum=165 }
CharacterWindow.StatIconInfo[GameData.Stats.PARRYSKILL]   =  { iconNum=110 }
CharacterWindow.StatIconInfo[GameData.Stats.EVADESKILL]   =  { iconNum=111 }
CharacterWindow.StatIconInfo[GameData.Stats.DISRUPTSKILL]   =  { iconNum=112 }
-- Melee selections
CharacterWindow.StatIconInfo[StringTables.Default.LABEL_WEAPON_DPS]   =  { iconNum=159 }
CharacterWindow.StatIconInfo[CharacterWindow.LABEL_MELEE_BONUS]   =  { iconNum=156 }
CharacterWindow.StatIconInfo[StringTables.Default.LABEL_ARMOR_PENETRATION]   =  { iconNum=166 }
CharacterWindow.StatIconInfo[CharacterWindow.LABEL_MELEE_SPEED]   =  { iconNum=111 }
CharacterWindow.StatIconInfo[CharacterWindow.LABEL_MELEE_CRIT_BONUS]   =  { iconNum=163 }
-- Range selections
CharacterWindow.StatIconInfo[StringTables.Default.LABEL_RANGED]   =  { iconNum=157 }
CharacterWindow.StatIconInfo[CharacterWindow.LABEL_RANGED_SPEED]   =  { iconNum=111 }
CharacterWindow.StatIconInfo[CharacterWindow.LABEL_RANGED_BONUS]   =  { iconNum=156 }
CharacterWindow.StatIconInfo[CharacterWindow.LABEL_RANGED_CRIT_BONUS]   =  { iconNum=163 }
-- Spell selections
CharacterWindow.StatIconInfo[StringTables.Default.LABEL_SPELL_BONUS]   =  { iconNum=156 }
CharacterWindow.StatIconInfo[StringTables.Default.LABEL_DAMAGE_CRIT_PERCENT]   =  { iconNum=163 }
CharacterWindow.StatIconInfo[StringTables.Default.LABEL_HEAL_CRIT_PERCENT]   =  { iconNum=160 }
CharacterWindow.StatIconInfo[CharacterWindow.LABEL_SPELL_HEALING_BONUS]   =  { iconNum=160 }

-- stat data
CharacterWindow.STAT_ICON_BASE_ID = 100

CharacterWindow.currentStatSelection = 1
CharacterWindow.previousStatSelection = 0
CharacterWindow.currentTitleSelection = 0

local g_currentStrength
local g_currentWillpower
local g_currentToughness
local g_currentWounds
local g_currentInitiative
local g_currentWeaponskill
local g_currentBallisticskill
local g_currentIntelligence
local g_currentBlock
local g_currentParry
local g_currentEvade
local g_currentDisrupt
local g_currentSpirit
local g_currentElemental
local g_currentCorporeal

-- Standard Clamp function that could be put in a math utils mod
local function Clamp( value, min, max )
    if( value > max )
    then
        return max
    elseif( value < min )
    then
        return min
    end
    return value
end

function CharacterWindow.UpdateStatCombobox()

    -- Clear ComboBox before populating to avoid duplicates
    ComboBoxClearMenuItems("CharacterWindowContentsStatCombobox")
    ComboBoxAddMenuItem("CharacterWindowContentsStatCombobox", GetString( StringTables.Default.LABEL_STATS ))
    ComboBoxAddMenuItem("CharacterWindowContentsStatCombobox", GetString( StringTables.Default.LABEL_DEFENSE ))
    ComboBoxAddMenuItem("CharacterWindowContentsStatCombobox", GetString( StringTables.Default.LABEL_MELEE ))
    ComboBoxAddMenuItem("CharacterWindowContentsStatCombobox", GetString( StringTables.Default.LABEL_RANGED ))
    ComboBoxAddMenuItem("CharacterWindowContentsStatCombobox", GetString( StringTables.Default.LABEL_MAGIC ))

    -- Reset selections
    CharacterWindow.currentStatSelection = 1
    CharacterWindow.previousStatSelection = 0
    ComboBoxSetSelectedMenuItem("CharacterWindowContentsStatCombobox", 1)
    CharacterWindow.UpdateStatsLabels()
end

function CharacterWindow.OnFilterSelChanged( curSel )
    CharacterWindow.currentStatSelection = curSel
    CharacterWindow.UpdateStatsNew()
end

function CharacterWindow.UpdateStatsNew()
    -- Always update the stat labels, since their values are stored and needed in the other labels
    CharacterWindow.UpdateStatsLabels()
    if CharacterWindow.currentStatSelection == 2 then
        CharacterWindow.UpdateDefenseLabels()
    elseif CharacterWindow.currentStatSelection == 3 then
        CharacterWindow.UpdateMeleeLabels()
    elseif CharacterWindow.currentStatSelection == 4 then
        CharacterWindow.UpdateRangedLabels()
    elseif CharacterWindow.currentStatSelection == 5 then
        CharacterWindow.UpdateMagicLabels()
    end

    CharacterWindow.UpdateStatIcons()
    CharacterWindow.previousStatSelection = CharacterWindow.currentStatSelection
end

function CharacterWindow.StatsMouseOver()
    local windowID = WindowGetId(SystemData.ActiveWindow.name)
    
    CharacterWindow.CreateTooltip("CharacterWindowContentsStatsWindow"..windowID, CharacterWindow.GetStatsToolTip(windowID), CharacterWindow.GetStatsToolTipLine2(windowID) )
end

function CharacterWindow.GetStatsToolTip(index)
    if CharacterWindow.currentStatSelection == 1 then
        return CharacterWindow.GetStatsLabelsTooltip(index)
    elseif CharacterWindow.currentStatSelection == 2 then
        return CharacterWindow.GetDefenseLabelsTooltip(index)
    elseif CharacterWindow.currentStatSelection == 3 then
        return CharacterWindow.GetMeleeLabelsTooltip(index)
    elseif CharacterWindow.currentStatSelection == 4 then
        return CharacterWindow.GetRangedLabelsTooltip(index)
    elseif CharacterWindow.currentStatSelection == 5 then
        return CharacterWindow.GetMagicLabelsTooltip(index)
    end
    
    return
end

function CharacterWindow.GetStatsToolTipLine2(index)
    if CharacterWindow.currentStatSelection == 1 then
        return CharacterWindow.GetStatsLabelsTooltipLine2(index)
    elseif CharacterWindow.currentStatSelection == 2 then
        return CharacterWindow.GetDefenseLabelsTooltipLine2(index)
    elseif CharacterWindow.currentStatSelection == 3 then
        return CharacterWindow.GetMeleeLabelsTooltipLine2(index)
    elseif CharacterWindow.currentStatSelection == 4 then
        return CharacterWindow.GetRangedLabelsTooltipLine2(index)
    elseif CharacterWindow.currentStatSelection == 5 then
        return CharacterWindow.GetMagicLabelsTooltipLine2(index)
    end
    
    return
end

function CharacterWindow.UpdateStatsLabels()
    CharacterWindow.UpdateStrengthLabel("CharacterWindowContentsStatsWindow1")
    CharacterWindow.UpdateBallisticskillLabel("CharacterWindowContentsStatsWindow2")
    CharacterWindow.UpdateIntelligenceLabel("CharacterWindowContentsStatsWindow3")
    CharacterWindow.UpdateToughnessLabel("CharacterWindowContentsStatsWindow4")
    CharacterWindow.UpdateWeaponskillLabel("CharacterWindowContentsStatsWindow5")
    CharacterWindow.UpdateInitiativeLabel("CharacterWindowContentsStatsWindow6")
    CharacterWindow.UpdateWillpowerLabel("CharacterWindowContentsStatsWindow7")
    CharacterWindow.UpdateWoundsLabel("CharacterWindowContentsStatsWindow8")
end

function CharacterWindow.UpdateDefenseLabels()
    CharacterWindow.UpdateArmorLabel("CharacterWindowContentsStatsWindow1")
    CharacterWindow.UpdateSpiritResistLabel("CharacterWindowContentsStatsWindow2")
    CharacterWindow.UpdateCorporealResistLabel("CharacterWindowContentsStatsWindow3")
    CharacterWindow.UpdateElementalResistLabel("CharacterWindowContentsStatsWindow4")
    CharacterWindow.UpdateBlockskillLabel("CharacterWindowContentsStatsWindow5")
    CharacterWindow.UpdateParryskillLabel("CharacterWindowContentsStatsWindow6")
    CharacterWindow.UpdateEvadeskillLabel("CharacterWindowContentsStatsWindow7")
    CharacterWindow.UpdateDisruptskillLabel("CharacterWindowContentsStatsWindow8")
end

function CharacterWindow.UpdateMeleeLabels()
    CharacterWindow.UpdateMeleeDPSLabel("CharacterWindowContentsStatsWindow1")
    CharacterWindow.UpdateMeleeBonusLabel("CharacterWindowContentsStatsWindow2")
    CharacterWindow.UpdateArmorPenetrationLabel("CharacterWindowContentsStatsWindow3")
    LabelSetText( "CharacterWindowContentsStatsWindow4Left", L"" )
    LabelSetText( "CharacterWindowContentsStatsWindow4Right", L"" )

    CharacterWindow.UpdateMeleeSpeedLabel("CharacterWindowContentsStatsWindow5")
    CharacterWindow.UpdateMeleeCritBonusLabel("CharacterWindowContentsStatsWindow6")
    LabelSetText( "CharacterWindowContentsStatsWindow7Left", L"" )
    LabelSetText( "CharacterWindowContentsStatsWindow7Right", L"" )
    LabelSetText( "CharacterWindowContentsStatsWindow8Left", L"" )
    LabelSetText( "CharacterWindowContentsStatsWindow8Right", L"" )
end

function CharacterWindow.UpdateRangedLabels()
    CharacterWindow.UpdateRangedDPSLabel("CharacterWindowContentsStatsWindow1")
    CharacterWindow.UpdateRangedSpeedLabel("CharacterWindowContentsStatsWindow2")
    CharacterWindow.UpdateRangedBonusLabel("CharacterWindowContentsStatsWindow3")
    CharacterWindow.UpdateRangedCritBonusLabel("CharacterWindowContentsStatsWindow4")
    LabelSetText( "CharacterWindowContentsStatsWindow5Left", L"" )
    LabelSetText( "CharacterWindowContentsStatsWindow5Right", L"" )
    LabelSetText( "CharacterWindowContentsStatsWindow6Left", L"" )
    LabelSetText( "CharacterWindowContentsStatsWindow6Right", L"" )
    LabelSetText( "CharacterWindowContentsStatsWindow7Left", L"" )
    LabelSetText( "CharacterWindowContentsStatsWindow7Right", L"" )
    LabelSetText( "CharacterWindowContentsStatsWindow8Left", L"" )
    LabelSetText( "CharacterWindowContentsStatsWindow8Right", L"" )
end

function CharacterWindow.UpdateMagicLabels()
    CharacterWindow.UpdateSpellBonusLabel("CharacterWindowContentsStatsWindow1")
    CharacterWindow.UpdateSpellCritBonusLabel("CharacterWindowContentsStatsWindow2")
    CharacterWindow.UpdateSpellHealingBonusLabel("CharacterWindowContentsStatsWindow3")
    CharacterWindow.UpdateSpellHealCritBonusLabel("CharacterWindowContentsStatsWindow4")
    LabelSetText( "CharacterWindowContentsStatsWindow5Left", L"" )
    LabelSetText( "CharacterWindowContentsStatsWindow5Right", L"" )
    LabelSetText( "CharacterWindowContentsStatsWindow6Left", L"" )
    LabelSetText( "CharacterWindowContentsStatsWindow6Right", L"" )
    LabelSetText( "CharacterWindowContentsStatsWindow7Left", L"" )
    LabelSetText( "CharacterWindowContentsStatsWindow7Right", L"" )
    LabelSetText( "CharacterWindowContentsStatsWindow8Left", L"" )
    LabelSetText( "CharacterWindowContentsStatsWindow8Right", L"" )
end

function CharacterWindow.GetStatsLabelsTooltip(index)
    local retString = L""
    if (1 == index) then
        retString = GetString( StringTables.Default.LABEL_STRENGTH )
        retString = retString..CharacterWindow.GetBasicStatTooltip(GameData.Stats.STRENGTH, g_currentStrength)
        return retString
    elseif (2 == index) then
        retString = GetString( StringTables.Default.LABEL_BALLISTICSKILL )
        retString = retString..CharacterWindow.GetBasicStatTooltip(GameData.Stats.BALLISTICSKILL, g_currentBallisticskill)
        return retString
    elseif (3 == index) then
        retString = GetString( StringTables.Default.LABEL_INTELLIGENCE )
        retString = retString..CharacterWindow.GetBasicStatTooltip(GameData.Stats.INTELLIGENCE, g_currentIntelligence)
        return retString
    elseif (4 == index) then
        retString = GetString( StringTables.Default.LABEL_TOUGHNESS )
        retString = retString..CharacterWindow.GetBasicStatTooltip(GameData.Stats.TOUGHNESS, g_currentToughness)
        return retString
    elseif (5 == index) then
        retString = GetString( StringTables.Default.LABEL_WEAPONSKILL )
        retString = retString..CharacterWindow.GetBasicStatTooltip(GameData.Stats.WEAPONSKILL, g_currentWeaponskill)
        return retString
    elseif (6 == index) then
        retString = GetString( StringTables.Default.LABEL_INITIATIVE )
        retString = retString..CharacterWindow.GetBasicStatTooltip(GameData.Stats.INITIATIVE, g_currentInitiative)
        return retString
    elseif (7 == index) then
        retString = GetString( StringTables.Default.LABEL_WILLPOWER )
        retString = retString..CharacterWindow.GetBasicStatTooltip(GameData.Stats.WILLPOWER, g_currentWillpower)
        return retString
    elseif (8 == index) then
        retString = GetString( StringTables.Default.LABEL_WOUNDS )
        retString = retString..CharacterWindow.GetBasicStatTooltip(GameData.Stats.WOUNDS, g_currentWounds)
        return retString
    end
    
    return
end

function CharacterWindow.GetDefenseLabelsTooltip(index)
    local retString = L""
    if (1 == index) then
        retString = GetString( StringTables.Default.LABEL_ARMOR )
        retString = retString..L": "
        retString = retString..GameData.Player.armorValue
        return retString
    elseif (2 == index) then
        retString = GetString( StringTables.Default.LABEL_SPIRITRESIST )
        retString = retString..CharacterWindow.GetBasicStatTooltip(GameData.Stats.SPIRITRESIST, g_currentSpirit)
        return retString
    elseif (3 == index) then
        retString = GetString( StringTables.Default.LABEL_CORPOREALRESIST )
        retString = retString..CharacterWindow.GetBasicStatTooltip(GameData.Stats.CORPOREALRESIST, g_currentCorporeal)
        return retString
    elseif (4 == index) then
        retString = GetString( StringTables.Default.LABEL_ELEMENTALRESIST )
        retString = retString..CharacterWindow.GetBasicStatTooltip(GameData.Stats.ELEMENTALRESIST, g_currentElemental)
        return retString
    elseif (5 == index) then
        retString = GetString( StringTables.Default.LABEL_BONUS_BLOCK )
        retString = retString..CharacterWindow.GetBasicStatPercentageTooltip(GameData.Stats.BLOCKSKILL, g_currentBlock)
        return retString
    elseif (6 == index) then
        retString = GetString( StringTables.Default.LABEL_BONUS_PARRY )
        retString = retString..CharacterWindow.GetBasicStatPercentageTooltip(GameData.Stats.PARRYSKILL, g_currentParry)
        return retString
    elseif (7 == index) then
        retString = GetString( StringTables.Default.LABEL_BONUS_EVADE )
        retString = retString..CharacterWindow.GetBasicStatPercentageTooltip(GameData.Stats.EVADESKILL, g_currentEvade)
        return retString
    elseif (8 == index) then
        retString = GetString( StringTables.Default.LABEL_BONUS_DISRUPT )
        retString = retString..CharacterWindow.GetBasicStatPercentageTooltip(GameData.Stats.DISRUPTSKILL, g_currentDisrupt)
        return retString
    end
    
    return
end

function CharacterWindow.GetStrengthTooltipDesc()
    local AbilDam = g_currentStrength / 5
    local AutoDam = g_currentStrength / 10
    local ParryStrikethrough = g_currentStrength / 100
    local BlockStrikethrough = g_currentStrength / 200
    local Params = {wstring.format(L"%.01f",AbilDam), wstring.format(L"%.01f",AutoDam), wstring.format(L"%.01f",ParryStrikethrough), wstring.format(L"%.01f",BlockStrikethrough)}
    return GetFormatStringFromTable("Default", StringTables.Default.TEXT_STRENGTH_DESC, Params )
end

function CharacterWindow.GetBallisticSkillTooltipDesc()
    local AbilDam = g_currentBallisticskill / 5
    local AutoDam = g_currentBallisticskill / 10
    local DodgeStrikethrough = g_currentBallisticskill / 100
    local BlockStrikethrough = g_currentBallisticskill / 200
    local Params = {wstring.format(L"%.01f",AbilDam), wstring.format(L"%.01f",AutoDam), wstring.format(L"%.01f",DodgeStrikethrough), wstring.format(L"%.01f",BlockStrikethrough)}
    return GetFormatStringFromTable("Default", StringTables.Default.TEXT_BALLISTICSKILL_DESC, Params )
end

function CharacterWindow.GetIntelligenceTooltipDesc()
    local AbilDam = g_currentIntelligence / 5
    local DisruptStrikethrough = g_currentIntelligence / 100
    local BlockStrikethrough = g_currentIntelligence / 200
    local Params = {wstring.format(L"%.01f",AbilDam), wstring.format(L"%.01f",DisruptStrikethrough), wstring.format(L"%.01f",BlockStrikethrough)}
    return GetFormatStringFromTable("Default", StringTables.Default.TEXT_INTELLIGENCE_DESC, Params )
end

function CharacterWindow.GetToughnessTooltipDesc()
    local DamReducToughness = g_currentToughness / 5
    local DamReducFortitude = CharacterWindow.CalculateValueWithBonus( GameData.BonusTypes.EBONUS_FORTITUDE, 0 ) / 5
    local BlockChance = g_currentToughness / 200
    return GetFormatStringFromTable( "Default", StringTables.Default.TEXT_TOUGHNESS_DESC, {wstring.format(L"%.01f",DamReducToughness),wstring.format(L"%.01f",DamReducFortitude), wstring.format(L"%.01f",BlockChance)} )
end

function CharacterWindow.GetWeaponSkillTooltipDesc()
    local BlockStrikethrough = g_currentWeaponskill / 200
    local Params = {CharacterWindow.CalcArmorPenetration(), wstring.format(L"%.01f",BlockStrikethrough)}
    return GetFormatStringFromTable("Default", StringTables.Default.TEXT_WEAPONSKILL_DESC, Params )
end

function CharacterWindow.GetInitiativeTooltipDesc()
    local CritHit = 15 + GameData.Player.battleLevelWithRenown / 4.0 - g_currentInitiative / 100 * 5
    -- Adding 100 and then subtracting 100 to be able to show negative numbers
    -- GetBonus always returns a positive number
    CritHit = CharacterWindow.CalculateValueWithBonus( GameData.BonusTypes.EBONUS_CRITICAL_HIT_RATE_REDUCTION, CritHit + 100) - 100
    local ParryChance = g_currentInitiative / 100 * 3
    local DodgeChance = g_currentInitiative / 100 * 3
    local Params = {wstring.format(L"%.01f",CritHit), wstring.format(L"%.01f",ParryChance), wstring.format(L"%.01f",DodgeChance)}
    return GetFormatStringFromTable("Default", StringTables.Default.TEXT_INITIATIVE_DESC, Params )
end

function CharacterWindow.GetWillPowerTooltipDesc()
    local AbilDam = g_currentWillpower / 5
    local DisruptChance = g_currentWillpower / 100 * 3
    local Params = {wstring.format(L"%.01f",AbilDam), wstring.format(L"%.01f",DisruptChance)}
    return GetFormatStringFromTable("Default", StringTables.Default.TEXT_WILLPOWER_DESC, Params )
end

function CharacterWindow.GetWoundsTooltipDesc()
    local DamReduc = g_currentWounds * 10
    return GetFormatStringFromTable( "Default", StringTables.Default.TEXT_WOUNDS_DESC, {wstring.format(L"%.01f",DamReduc)} )
end

function CharacterWindow.GetStatsLabelsTooltipLine2(index)
    if (1 == index) then
        return CharacterWindow.GetStrengthTooltipDesc()
    elseif (2 == index) then
        return CharacterWindow.GetBallisticSkillTooltipDesc()
    elseif (3 == index) then
        return CharacterWindow.GetIntelligenceTooltipDesc()
    elseif (4 == index) then
        return CharacterWindow.GetToughnessTooltipDesc()
    elseif (5 == index) then
        return CharacterWindow.GetWeaponSkillTooltipDesc()
    elseif (6 == index) then
        return CharacterWindow.GetInitiativeTooltipDesc()
    elseif (7 == index) then
        return CharacterWindow.GetWillPowerTooltipDesc()
    elseif (8 == index) then
        return CharacterWindow.GetWoundsTooltipDesc()
    end
    
    return
end

function CharacterWindow.GetArmorTooltipDesc()
    local DamReduc = GameData.Player.armorValue / (GameData.Player.battleLevelWithRenown * 44) * .4
    local DamReduc = DamReduc * 100
    return GetFormatStringFromTable( "Default", StringTables.Default.TEXT_ARMOR_DESC, {wstring.format(L"%.01f",DamReduc)} )
end

-- Calculate the value of the stat after diminishing returns has been applied to the current value,
-- this function tries to mimic the servers behavior
local function GetEffectiveStatValue( baseValue, currentValue )
    local thresholdMult = 25
    local threshold = GameData.Player.battleLevelWithRenown * thresholdMult + 50
    local capMult = 40
    local cap = GameData.Player.battleLevelWithRenown * capMult + 50

    -- After the dimishing returns kick in, we only get half the effectiveness from stats
    if( currentValue > threshold )
    then
        currentValue = ( currentValue - threshold ) / 2 + threshold
    end
    
    -- An absolute stat cap.... terrible design, but theoretically only happens if items are being created with bad parameters
    if( currentValue > cap )
    then
        currentValue = cap
    end
    
    if( baseValue > currentValue )
    then
        baseValue = currentValue
    end
    
    -- Truncate for nicer output
    baseValue = math.floor( baseValue )
    currentValue = math.floor( currentValue ) 
    
    return baseValue, currentValue
end

function CharacterWindow.IsStatDiminished( currentValue )
    local thresholdMult = 25
    local threshold = GameData.Player.battleLevelWithRenown * thresholdMult + 50
    if( currentValue > threshold )
    then
        return true
    end
    return false
end

-- Calculates the reduction in damage from the current resist stat value, takes diminishing returns in account
-- this function tries to mimic the servers behavior
local function GetEffectiveResistValue( defense )
    local attackLevelCoeff = GameData.Player.battleLevelWithRenown * 8.4
    
    local defenseBeforeSoftCap = 0.4 / 0.2 * attackLevelCoeff
    if ( defense > defenseBeforeSoftCap )
    then
        -- Diminishing returns
        defense = ( defense - defenseBeforeSoftCap ) / 3.0 + defenseBeforeSoftCap
    end

    if ( attackLevelCoeff == 0 )
    then
        attackLevelCoeff = 1.0
    end
    
    local DamReduc = Clamp( 0.2 * ( defense / attackLevelCoeff ), 0.0, 0.75 );
    return DamReduc * 100
end

-- Checks if resist value is above threshold for dimishing returns
function CharacterWindow.IsResistDiminished( currentValue )
    local attackLevelCoeff = GameData.Player.battleLevelWithRenown * 8.4
    local defenseBeforeSoftCap = 0.4 / 0.2 * attackLevelCoeff
    if ( currentValue > defenseBeforeSoftCap )
    then
        return true
    end
    return false
end

function CharacterWindow.GetSpiritResistTooltipDesc()
    local DamReduc = GetEffectiveResistValue( g_currentSpirit )  
    return GetFormatStringFromTable( "Default", StringTables.Default.TEXT_SPIRITRESIST_DESC, {wstring.format(L"%.01f",DamReduc)} )
end

function CharacterWindow.GetCorporealResistTooltipDesc()
    local DamReduc = GetEffectiveResistValue( g_currentCorporeal )  
    return GetFormatStringFromTable( "Default", StringTables.Default.TEXT_CORPOREALRESIST_DESC, {wstring.format(L"%.01f",DamReduc)} )
end

function CharacterWindow.GetElementalResistTooltipDesc()
    local DamReduc = GetEffectiveResistValue( g_currentElemental )  
    return GetFormatStringFromTable( "Default", StringTables.Default.TEXT_ELEMENTALRESIST_DESC, {wstring.format(L"%.01f",DamReduc)} )
end

function CharacterWindow.GetBlockTooltipDesc(index)
    return GetFormatStringFromTable( "Default", StringTables.Default.TEXT_BONUS_BLOCK_DESC, {wstring.format(L"%.01f",g_currentBlock)} )
end

function CharacterWindow.GetParryTooltipDesc(index)
    return GetFormatStringFromTable( "Default", StringTables.Default.TEXT_BONUS_PARRY_DESC, {wstring.format(L"%.01f",g_currentParry)} )
end

function CharacterWindow.GetEvadeTooltipDesc(index)
    return GetFormatStringFromTable( "Default", StringTables.Default.TEXT_BONUS_EVADE_DESC, {wstring.format(L"%.01f",g_currentEvade)} )
end

function CharacterWindow.GetDisruptTooltipDesc(index)
    return GetFormatStringFromTable( "Default", StringTables.Default.TEXT_BONUS_DISRUPT_DESC, {wstring.format(L"%.01f",g_currentDisrupt)} )
end

function CharacterWindow.GetDefenseLabelsTooltipLine2(index)
    if (1 == index) then
        return CharacterWindow.GetArmorTooltipDesc()
    elseif (2 == index) then
        return CharacterWindow.GetSpiritResistTooltipDesc()
    elseif (3 == index) then
        return CharacterWindow.GetCorporealResistTooltipDesc()
    elseif (4 == index) then
        return CharacterWindow.GetElementalResistTooltipDesc()
    elseif (5 == index) then
        return CharacterWindow.GetBlockTooltipDesc(index)
    elseif (6 == index) then
        return CharacterWindow.GetParryTooltipDesc(index)
    elseif (7 == index) then
        return CharacterWindow.GetEvadeTooltipDesc(index)
    elseif (8 == index) then
        return CharacterWindow.GetDisruptTooltipDesc(index)
    end
    
    return
end

function CharacterWindow.GetMeleeDPSTooltipDesc()
    local Params = {wstring.format(L"%.01f",CharacterWindow.equipmentData[GameData.EquipSlots.RIGHT_HAND].dps), wstring.format(L"%.01f",CharacterWindow.equipmentData[GameData.EquipSlots.LEFT_HAND].dps)}
    return GetFormatStringFromTable( "Default", StringTables.Default.TEXT_MELEE_WEAPON_DPS_DESC, Params )
end

function CharacterWindow.GetArmorPenetrationTooltipDesc()
    local Params = {CharacterWindow.CalcArmorPenetration()}
    return GetFormatStringFromTable( "Default", StringTables.Default.TEXT_MELEE_ARMORE_PENETRATION_DESC, Params )
end

function CharacterWindow.GetSpeedTooltipDesc()
    return L""
end

function CharacterWindow.GetCritBonusTooltipDesc(bonusType, szAttackType)
    local critBonusGeneral = CharacterWindow.CalculateValueWithBonus(bonusType, 0)
    local critBonus = CharacterWindow.CalculateValueWithBonus(GameData.BonusTypes.EBONUS_CRITICAL_HIT_RATE, critBonusGeneral)
    local Params = {szAttackType, wstring.format(L"%.01f", critBonus)}
    return GetFormatStringFromTable( "Default", StringTables.Default.TEXT_CRIT_BONUS_DESC, Params )
end


local function GetTotalBonusPower( statValue, bonusType )
    local statAddition = statValue / 5
    local bonusAddition = CharacterWindow.CalculateValueWithBonus( bonusType, 0 ) / 5
    local total = statAddition + bonusAddition 
	return wstring.format( L"%.01f", total ), total, statAddition
end


local function UpdatePowerBonusLabel( attackType, statType, statValue, bonusType )
    if( attackType and statType and statValue and bonusType )
    then
        local statAddition = statValue / 5
        local bonusAddition = CharacterWindow.CalculateValueWithBonus( bonusType, 0 ) / 5
        local total = statAddition + bonusAddition 
        
        local spellType = attackType
        local spellAbrev
        local damageBonusText = L""
        local damageBonusTitle = L""
        
        if( spellType ~= GetString( StringTables.Default.LABEL_HEALING ) )
        then
            spellType = GetString( StringTables.Default.LABEL_DAMAGE )
            spellAbrev = GetString( StringTables.Default.LABEL_DPS )
            damageBonus = CharacterWindow.CalculateValueWithBonus( GameData.BonusTypes.EBONUS_OUT_DAMAGE, 0 )
            damageBonusText = L"<BR><BR>"..GetString( StringTables.Default.TEXT_BONUS_OUT_DAMAGE )..L" +"..damageBonus
            damageBonusTitle = L" / "..damageBonus
        else
            spellAbrev = GetString( StringTables.Default.LABEL_HPS )            
        end
        local params = { spellType, wstring.format( L"%.01f", total ), spellAbrev }
        local tooltipTitle = GetFormatStringFromTable( "Default", StringTables.Default.LABEL_BONUS_TITLE, params )
        
        params = 
        {
            attackType,
            wstring.format( L"%.01f", total ),
            statType, wstring.format( L"%.01f", statAddition ),
            wstring.format( L"%.01f", bonusAddition ),
            spellAbrev
        }
        
        local tooltipDesc = GetFormatStringFromTable( "Default", StringTables.Default.TEXT_BONUS_POWER_DESC, params )
        
        tooltipTitle = tooltipTitle..damageBonusTitle
        tooltipDesc = tooltipDesc..damageBonusText
        
        return tooltipTitle, tooltipDesc
    else
        ERROR(L"Invalid parameters to UpdatePowerBonusLabel")
    end
end



local function GetPowerBonusLabelHealing() 
    local title, desc = UpdatePowerBonusLabel( GetString( StringTables.Default.LABEL_HEALING ), GetString( StringTables.Default.LABEL_WILLPOWER ), g_currentWillpower, GameData.BonusTypes.EBONUS_HEALING_POWER )
    return title, desc
end

local function GetPowerBonusLabelMagic()
    local title, desc = UpdatePowerBonusLabel( GetString( StringTables.Default.LABEL_MAGIC ), GetString( StringTables.Default.LABEL_INTELLIGENCE ), g_currentIntelligence, GameData.BonusTypes.EBONUS_DAMAGE_MAGIC )
    return title, desc
end

local function GetPowerBonusLabelMelee()
    local title, desc = UpdatePowerBonusLabel( GetString( StringTables.Default.LABEL_MELEE ), GetString( StringTables.Default.LABEL_STRENGTH ), g_currentStrength, GameData.BonusTypes.EBONUS_DAMAGE_MELEE )
    return title, desc
end

local function GetPowerBonusLabelRanged()
    local title, desc = UpdatePowerBonusLabel( GetString( StringTables.Default.LABEL_RANGED ), GetString( StringTables.Default.LABEL_BALLISTICSKILL ), g_currentBallisticskill, GameData.BonusTypes.EBONUS_DAMAGE_RANGED )
    return title, desc
end

function CharacterWindow.GetMeleeLabelsTooltip(index)
    local retString = L""
    if (1 == index) then
        retString = GetString( StringTables.Default.LABEL_WEAPON_DPS )..L":"
        retString = retString..CharacterWindow.GetMeleeDPSLabelRight()
        return retString
    elseif (2 == index) then
        local title, desc = GetPowerBonusLabelMelee()
        return title
    elseif (3 == index) then
        retString = GetString( StringTables.Default.LABEL_MELEE_ARMOR_PENETRATION )..L":"..CharacterWindow.CalcArmorPenetration()..L"%"
        return retString
    elseif (4 == index) then
        return
    elseif (5 == index) then
		local weaponSpeed = CharacterWindow.equipmentData[GameData.EquipSlots.RIGHT_HAND].speed
		local currentVal = CharacterWindow.CalculateValueWithBonus( GameData.BonusTypes.EBONUS_AUTO_ATTACK_SPEED, weaponSpeed )
		retString = GetString( StringTables.Default.LABEL_SPEED )..L":"..wstring.format( L"%.01f", currentVal )
        return retString
    elseif (6 == index) then
        local critBonus = CharacterWindow.CalculateValueWithBonus(GameData.BonusTypes.EBONUS_CRITICAL_HIT_RATE_MELEE, 0)
        critBonus = CharacterWindow.CalculateValueWithBonus(GameData.BonusTypes.EBONUS_CRITICAL_HIT_RATE, critBonus)
        retString = GetString( StringTables.Default.LABEL_CRIT_BONUS )..L":"..critBonus..L"%"
        return retString
    elseif (7 == index) then
        return
    elseif (8 == index) then
        return
    end
    
    return
end

function CharacterWindow.GetMeleeLabelsTooltipLine2(index)
    if (1 == index) then
        return CharacterWindow.GetMeleeDPSTooltipDesc()
    elseif (2 == index) then
        local title, desc = GetPowerBonusLabelMelee()
        return desc
    elseif (3 == index) then
        return CharacterWindow.GetArmorPenetrationTooltipDesc()
    elseif (4 == index) then
        return
    elseif (5 == index) then
        return CharacterWindow.GetSpeedTooltipDesc()
    elseif (6 == index) then
        return CharacterWindow.GetCritBonusTooltipDesc(GameData.BonusTypes.EBONUS_CRITICAL_HIT_RATE_MELEE, GetString( StringTables.Default.LABEL_ATTACK ) )
    elseif (7 == index) then
        return
    elseif (8 == index) then
        return
    end
    
    return
end

function CharacterWindow.GetRangedLabelsTooltip(index)
    local retString = L""
    if (1 == index) then
        retString = GetString( StringTables.Default.LABEL_WEAPON_DPS )..L":"..wstring.format(L"%.01f",CharacterWindow.equipmentData[GameData.EquipSlots.RANGED].dps)
        return retString
    elseif (2 == index) then
		local weaponSpeed = CharacterWindow.equipmentData[GameData.EquipSlots.RANGED].speed
		local currentVal = CharacterWindow.CalculateValueWithBonus( GameData.BonusTypes.EBONUS_AUTO_ATTACK_SPEED, weaponSpeed )
		retString = GetString( StringTables.Default.LABEL_SPEED )..L":"..wstring.format( L"%.01f", currentVal )
        return retString
    elseif (3 == index) then
        local title, desc = GetPowerBonusLabelRanged()
        return title
    elseif (4 == index) then
        local critBonus = CharacterWindow.CalculateValueWithBonus(GameData.BonusTypes.EBONUS_CRITICAL_HIT_RATE_RANGED, 0)
        critBonus = CharacterWindow.CalculateValueWithBonus(GameData.BonusTypes.EBONUS_CRITICAL_HIT_RATE, critBonus)
        retString = GetString( StringTables.Default.LABEL_CRIT_BONUS )..L":"..critBonus..L"%"
        return retString
    elseif (5 == index) then
        return
    elseif (6 == index) then
        return
    elseif (7 == index) then
        return
    elseif (8 == index) then
        return
    end
    
    return
end

function CharacterWindow.GetRangedDPSTooltipDesc()
    local Params = {wstring.format(L"%.01f",CharacterWindow.equipmentData[GameData.EquipSlots.RANGED].dps)}
    return GetFormatStringFromTable( "Default", StringTables.Default.TEXT_RANGED_WEAPON_DPS_DESC, Params )
end

function CharacterWindow.GetRangedLabelsTooltipLine2(index)
    if (1 == index) then
        return CharacterWindow.GetRangedDPSTooltipDesc()
    elseif (2 == index) then
        return CharacterWindow.GetSpeedTooltipDesc()
    elseif (3 == index) then
        local title, desc = GetPowerBonusLabelRanged()
        return desc
    elseif (4 == index) then
        return CharacterWindow.GetCritBonusTooltipDesc(GameData.BonusTypes.EBONUS_CRITICAL_HIT_RATE_RANGED, GetString( StringTables.Default.LABEL_ATTACK ) )
    elseif (5 == index) then
        return
    elseif (6 == index) then
        return
    elseif (7 == index) then
        return
    elseif (8 == index) then
        return
    end
    
    return
end

function CharacterWindow.GetMagicLabelsTooltip(index)
    if (1 == index) then
        local title, desc = GetPowerBonusLabelMagic()
        return title
    elseif (2 == index) then
        local critBonus = CharacterWindow.CalculateValueWithBonus(GameData.BonusTypes.EBONUS_CRITICAL_HIT_RATE_MAGIC, 0)
        critBonus = CharacterWindow.CalculateValueWithBonus(GameData.BonusTypes.EBONUS_CRITICAL_HIT_RATE, critBonus)
        local retString = GetString( StringTables.Default.LABEL_CRIT_BONUS )..L":"..critBonus..L"%"
        return retString
    elseif (3 == index) then
        local title, desc = GetPowerBonusLabelHealing()
        return title
    elseif (4 == index) then
        local critBonus = CharacterWindow.CalculateValueWithBonus(GameData.BonusTypes.EBONUS_CRITICAL_HIT_RATE_HEALING, 0)
        critBonus = CharacterWindow.CalculateValueWithBonus(GameData.BonusTypes.EBONUS_CRITICAL_HIT_RATE, critBonus)
        local retString = GetString( StringTables.Default.LABEL_CRIT_BONUS )..L":"..critBonus..L"%"
        return retString
    elseif (5 == index) then
        return
    elseif (6 == index) then
        return
    elseif (7 == index) then
        return
    elseif (8 == index) then
        return
    end
    
    return
end

function CharacterWindow.GetMagicLabelsTooltipLine2(index)
    if (1 == index) then
        local title, desc = GetPowerBonusLabelMagic()
        return desc
    elseif (2 == index) then
        return CharacterWindow.GetCritBonusTooltipDesc(GameData.BonusTypes.EBONUS_CRITICAL_HIT_RATE_MAGIC, GetString( StringTables.Default.LABEL_ATTACK ) )
    elseif (3 == index) then
        local title, desc = GetPowerBonusLabelHealing()
        return desc
    elseif (4 == index) then
        return CharacterWindow.GetCritBonusTooltipDesc(GameData.BonusTypes.EBONUS_CRITICAL_HIT_RATE_HEALING, GetString( StringTables.Default.LABEL_HEAL_LOWER ) )
    elseif (5 == index) then
        return
    elseif (6 == index) then
        return
    elseif (7 == index) then
        return
    elseif (8 == index) then
        return
    end
    
    return
end

function CharacterWindow.GetBasicStatTooltip(statID, currentValue)
        local retString = L""..L": "
        retString = retString..wstring.format( L"%d", currentValue )
        retString = retString..L"("
        retString = retString..wstring.format( L"%d", GameData.Player.Stats[statID].baseValue )
        local bonusValue = currentValue-GameData.Player.Stats[statID].baseValue
        if( bonusValue > 0 )
        then
            retString = retString..L"+"
        end
        if( bonusValue ~= 0 )
        then
            retString = retString..wstring.format( L"%d", bonusValue )
        end
        retString = retString..L")"
        return retString
end

function CharacterWindow.GetBasicStatPercentageTooltip(statID, currentValue )
        if (currentValue > 100 )
        then
            currentValue = 100
        end
        local initialValue = GameData.Player.Stats[statID].baseValue / 100
        local differenceValue = currentValue - initialValue
        -- Due to floating point issues, a difference of zero sometimes appears a slightly negative difference, which leads to "-0.0". To avoid that, force anything below a threshold to be exactly zero
        if ( math.abs( differenceValue ) < 0.1 )
        then
            differenceValue = 0
        end
        
        local retString = L""..L": "
        retString = retString..wstring.format( L"%.01f", currentValue )
        retString = retString..L"("
        retString = retString..wstring.format( L"%.01f", initialValue )
        retString = retString..L"+"
        retString = retString..wstring.format( L"%.01f", differenceValue )
        retString = retString..L")"
        return retString
end

function CharacterWindow.UpdateStatIcon(wndName, iconNum)
    if (wndName == nil) or (wndName == "") then
        return
    end
    if (iconNum == 0) then
        WindowSetShowing(wndName, false)
        return
    end
    
    local texture, x, y = GetIconData( iconNum ) 
    DynamicImageSetTexture( wndName, texture, x, y )
    WindowSetShowing(wndName, true)
end

function CharacterWindow.UpdateStatIcons()
    local texture, x, y
    -- Stats selections
    if CharacterWindow.currentStatSelection == 1 then
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow1IconBase", CharacterWindow.StatIconInfo[GameData.Stats.STRENGTH].iconNum )
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow2IconBase", CharacterWindow.StatIconInfo[GameData.Stats.BALLISTICSKILL].iconNum )
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow3IconBase", CharacterWindow.StatIconInfo[GameData.Stats.INTELLIGENCE].iconNum )
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow4IconBase", CharacterWindow.StatIconInfo[GameData.Stats.TOUGHNESS].iconNum )
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow5IconBase", CharacterWindow.StatIconInfo[GameData.Stats.WEAPONSKILL].iconNum )
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow6IconBase", CharacterWindow.StatIconInfo[GameData.Stats.INITIATIVE].iconNum )
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow7IconBase", CharacterWindow.StatIconInfo[GameData.Stats.WILLPOWER].iconNum )
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow8IconBase", CharacterWindow.StatIconInfo[GameData.Stats.WOUNDS].iconNum )
    -- Defense selections
    elseif CharacterWindow.currentStatSelection == 2 then
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow1IconBase", CharacterWindow.StatIconInfo[StringTables.Default.LABEL_ARMOR].iconNum )
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow2IconBase", CharacterWindow.StatIconInfo[GameData.Stats.SPIRITRESIST].iconNum )
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow3IconBase", CharacterWindow.StatIconInfo[GameData.Stats.CORPOREALRESIST].iconNum )
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow4IconBase", CharacterWindow.StatIconInfo[GameData.Stats.ELEMENTALRESIST].iconNum )
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow5IconBase", CharacterWindow.StatIconInfo[GameData.Stats.BLOCKSKILL].iconNum )
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow6IconBase", CharacterWindow.StatIconInfo[GameData.Stats.PARRYSKILL].iconNum )
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow7IconBase", CharacterWindow.StatIconInfo[GameData.Stats.EVADESKILL].iconNum )
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow8IconBase", CharacterWindow.StatIconInfo[GameData.Stats.DISRUPTSKILL].iconNum )
    elseif CharacterWindow.currentStatSelection == 3 then
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow1IconBase", CharacterWindow.StatIconInfo[StringTables.Default.LABEL_WEAPON_DPS].iconNum )
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow2IconBase", CharacterWindow.StatIconInfo[CharacterWindow.LABEL_MELEE_BONUS].iconNum )
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow3IconBase", CharacterWindow.StatIconInfo[StringTables.Default.LABEL_ARMOR_PENETRATION].iconNum )
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow4IconBase", 0 )
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow5IconBase", CharacterWindow.StatIconInfo[CharacterWindow.LABEL_MELEE_SPEED].iconNum )
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow6IconBase", CharacterWindow.StatIconInfo[CharacterWindow.LABEL_MELEE_CRIT_BONUS].iconNum )
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow7IconBase", 0 )
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow8IconBase", 0 )
    elseif CharacterWindow.currentStatSelection == 4 then
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow1IconBase", CharacterWindow.StatIconInfo[StringTables.Default.LABEL_RANGED].iconNum )
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow2IconBase", CharacterWindow.StatIconInfo[CharacterWindow.LABEL_RANGED_SPEED].iconNum )
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow3IconBase", CharacterWindow.StatIconInfo[CharacterWindow.LABEL_RANGED_BONUS].iconNum )
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow4IconBase", CharacterWindow.StatIconInfo[CharacterWindow.LABEL_RANGED_CRIT_BONUS].iconNum )
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow5IconBase", 0 )
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow6IconBase", 0 )
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow7IconBase", 0 )
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow8IconBase", 0 )
    elseif CharacterWindow.currentStatSelection == 5 then
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow1IconBase", CharacterWindow.StatIconInfo[StringTables.Default.LABEL_SPELL_BONUS].iconNum )
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow2IconBase", CharacterWindow.StatIconInfo[StringTables.Default.LABEL_DAMAGE_CRIT_PERCENT].iconNum )
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow3IconBase", CharacterWindow.StatIconInfo[CharacterWindow.LABEL_SPELL_HEALING_BONUS].iconNum )
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow4IconBase", CharacterWindow.StatIconInfo[StringTables.Default.LABEL_HEAL_CRIT_PERCENT].iconNum )
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow5IconBase", 0 )
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow6IconBase", 0 )
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow7IconBase", 0 )
        CharacterWindow.UpdateStatIcon("CharacterWindowContentsStatsWindow8IconBase", 0 )
    end
end

function CharacterWindow.UpdateResistLabel( wndName, leftText, rightText, currentVal, baseVal )
    LabelSetText( wndName.."Left", leftText )
    LabelSetText( wndName.."Right", rightText )
    if( CharacterWindow.IsResistDiminished( currentVal ) == true )
    then
        LabelSetTextColor( wndName.."Right", DefaultColor.ChatTextColors[23].r, DefaultColor.ChatTextColors[23].g, DefaultColor.ChatTextColors[23].b )
    else
        CharacterWindow.UpdateLabel( wndName, leftText, rightText, currentVal, baseVal )
    end
end

function CharacterWindow.UpdateStatLabel( wndName, leftText, rightText, currentVal, baseVal )
    LabelSetText( wndName.."Left", leftText )
    LabelSetText( wndName.."Right", rightText )
    if( CharacterWindow.IsStatDiminished( currentVal ) == true )
    then
        LabelSetTextColor( wndName.."Right", DefaultColor.ChatTextColors[23].r, DefaultColor.ChatTextColors[23].g, DefaultColor.ChatTextColors[23].b )
    else
        CharacterWindow.UpdateLabel( wndName, leftText, rightText, currentVal, baseVal )
    end
end

function CharacterWindow.UpdateLabel(wndName, leftText, rightText, currentVal, baseVal)
    LabelSetText( wndName.."Left", leftText )
    LabelSetText( wndName.."Right", rightText )
    if currentVal > baseVal then
        LabelSetTextColor( wndName.."Right", DefaultColor.ChatTextColors[59].r, DefaultColor.ChatTextColors[59].g, DefaultColor.ChatTextColors[59].b )
    elseif currentVal < baseVal then
        LabelSetTextColor( wndName.."Right", DefaultColor.RED.r, DefaultColor.RED.g, DefaultColor.RED.b )
    else
        LabelSetTextColor( wndName.."Right", DefaultColor.WHITE.r, DefaultColor.WHITE.g, DefaultColor.WHITE.b )
    end
end


function CharacterWindow.UpdateStrengthLabel(wndName)
    local leftText = GetString( StringTables.Default.LABEL_STRENGTH )..L":"
    local baseVal = GameData.Player.Stats[GameData.Stats.STRENGTH].baseValue
    local currentVal = CharacterWindow.CalculateValueWithBonus( GameData.BonusTypes.EBONUS_STRENGTH, baseVal )
    baseVal, currentVal = GetEffectiveStatValue( baseVal, currentVal )
    local rightText = L""..currentVal
    g_currentStrength = currentVal
    CharacterWindow.UpdateStatLabel(wndName, leftText, rightText, currentVal, baseVal)
end

function CharacterWindow.UpdateToughnessLabel(wndName)
    local leftText = GetString( StringTables.Default.LABEL_TOUGHNESS )..L":"
    local baseVal = GameData.Player.Stats[GameData.Stats.TOUGHNESS].baseValue
    local currentVal = CharacterWindow.CalculateValueWithBonus( GameData.BonusTypes.EBONUS_TOUGHNESS, baseVal )
    baseVal, currentVal = GetEffectiveStatValue( baseVal, currentVal ) 
    local rightText = L""..currentVal
    g_currentToughness = currentVal
    CharacterWindow.UpdateStatLabel(wndName, leftText, rightText, currentVal, baseVal)
end

function CharacterWindow.UpdateWoundsLabel(wndName)
    local leftText = GetString( StringTables.Default.LABEL_WOUNDS )..L":"
    local baseVal = GameData.Player.Stats[GameData.Stats.WOUNDS].baseValue
    local currentVal = CharacterWindow.CalculateValueWithBonus( GameData.BonusTypes.EBONUS_WOUNDS, baseVal )
    baseVal, currentVal = GetEffectiveStatValue( baseVal, currentVal )   
    local rightText = L""..currentVal
    g_currentWounds = currentVal
    CharacterWindow.UpdateStatLabel(wndName, leftText, rightText, currentVal, baseVal)
end

function CharacterWindow.UpdateInitiativeLabel(wndName)
    local leftText = GetString( StringTables.Default.LABEL_INITIATIVE )..L":"
    local baseVal = GameData.Player.Stats[GameData.Stats.INITIATIVE].baseValue
    local currentVal = CharacterWindow.CalculateValueWithBonus( GameData.BonusTypes.EBONUS_INITIATIVE, baseVal ) 
    baseVal, currentVal = GetEffectiveStatValue( baseVal, currentVal )     
    local rightText = L""..currentVal
    g_currentInitiative = currentVal
    CharacterWindow.UpdateStatLabel(wndName, leftText, rightText, currentVal, baseVal)
end

function CharacterWindow.UpdateWeaponskillLabel(wndName)
    local leftText = GetString( StringTables.Default.LABEL_WEAPONSKILL )..L":"
    local baseVal = GameData.Player.Stats[GameData.Stats.WEAPONSKILL].baseValue
    local currentVal = CharacterWindow.CalculateValueWithBonus( GameData.BonusTypes.EBONUS_WEAPONSKILL, baseVal ) 
    baseVal, currentVal = GetEffectiveStatValue( baseVal, currentVal )  
    local rightText = L""..currentVal
    g_currentWeaponskill = currentVal
    CharacterWindow.UpdateStatLabel(wndName, leftText, rightText, currentVal, baseVal)
end

function CharacterWindow.UpdateBallisticskillLabel(wndName)
    local leftText = GetString( StringTables.Default.LABEL_BALLISTICSKILL )..L":"
    local baseVal = GameData.Player.Stats[GameData.Stats.BALLISTICSKILL].baseValue
    local currentVal = CharacterWindow.CalculateValueWithBonus( GameData.BonusTypes.EBONUS_BALLISTICSKILL, baseVal )
    baseVal, currentVal = GetEffectiveStatValue( baseVal, currentVal )
    local rightText = L""..currentVal
    g_currentBallisticskill = currentVal
    CharacterWindow.UpdateStatLabel(wndName, leftText, rightText, currentVal, baseVal)
end

function CharacterWindow.UpdateIntelligenceLabel(wndName)
    local leftText = GetString( StringTables.Default.LABEL_INTELLIGENCE )..L":"
    local baseVal = GameData.Player.Stats[GameData.Stats.INTELLIGENCE].baseValue
    local currentVal = CharacterWindow.CalculateValueWithBonus( GameData.BonusTypes.EBONUS_INTELLIGENCE, baseVal )
    baseVal, currentVal = GetEffectiveStatValue( baseVal, currentVal )
    local rightText = L""..currentVal
    g_currentIntelligence = currentVal
    CharacterWindow.UpdateStatLabel(wndName, leftText, rightText, currentVal, baseVal)
end

function CharacterWindow.UpdateWillpowerLabel(wndName)
    local leftText = GetString( StringTables.Default.LABEL_WILLPOWER )..L":"
    local baseVal = GameData.Player.Stats[GameData.Stats.WILLPOWER].baseValue
    local currentVal = CharacterWindow.CalculateValueWithBonus( GameData.BonusTypes.EBONUS_WILLPOWER, baseVal )
    baseVal, currentVal = GetEffectiveStatValue( baseVal, currentVal )
    local rightText = L""..currentVal
    g_currentWillpower = currentVal
    CharacterWindow.UpdateStatLabel(wndName, leftText, rightText, currentVal, baseVal)
end

function CharacterWindow.UpdateArmorLabel(wndName)
    local leftText = GetString( StringTables.Default.LABEL_ARMOR )..L":"
    local rightText = L""..GameData.Player.armorValue
    local currentVal = GameData.Player.armorValue
    local baseVal = GameData.Player.armorValue
    CharacterWindow.UpdateLabel(wndName, leftText, rightText, currentVal, baseVal)
end

function CharacterWindow.UpdateCorporealResistLabel(wndName)
    local leftText = GetString( StringTables.Default.LABEL_CORPOREALRESIST )..L":"
    local baseVal = GameData.Player.Stats[GameData.Stats.CORPOREALRESIST].baseValue
    local currentVal = CharacterWindow.CalculateValueWithBonus( GameData.BonusTypes.EBONUS_CORPOREAL_RESIST, baseVal )
    local rightText = wstring.format(L"%d", currentVal)
    g_currentCorporeal = currentVal
    CharacterWindow.UpdateResistLabel(wndName, leftText, rightText, currentVal, baseVal)
end

function CharacterWindow.UpdateSpiritResistLabel(wndName)
    local leftText = GetString( StringTables.Default.LABEL_SPIRITRESIST )..L":"
    local baseVal = GameData.Player.Stats[GameData.Stats.SPIRITRESIST].baseValue
    local currentVal = CharacterWindow.CalculateValueWithBonus( GameData.BonusTypes.EBONUS_SPIRIT_RESIST, baseVal )
    local rightText = wstring.format(L"%d", currentVal)
    g_currentSpirit = currentVal
    CharacterWindow.UpdateResistLabel(wndName, leftText, rightText, currentVal, baseVal)
end

function CharacterWindow.UpdateElementalResistLabel(wndName)
    local leftText = GetString( StringTables.Default.LABEL_ELEMENTALRESIST )..L":"
    local baseVal = GameData.Player.Stats[GameData.Stats.ELEMENTALRESIST].baseValue
    local currentVal = CharacterWindow.CalculateValueWithBonus( GameData.BonusTypes.EBONUS_ELEMENTAL_RESIST, baseVal )
    local rightText = wstring.format(L"%d", currentVal)
    g_currentElemental = currentVal    
    CharacterWindow.UpdateResistLabel(wndName, leftText, rightText, currentVal, baseVal)
end

function CharacterWindow.UpdateBlockskillLabel(wndName)
    local leftText = GetString( StringTables.Default.LABEL_BONUS_BLOCK )..L":"
    local baseVal = 0
    if(CharacterWindow.equipmentData[GameData.EquipSlots.LEFT_HAND] ~= nil)
    then
        baseVal = CharacterWindow.equipmentData[GameData.EquipSlots.LEFT_HAND].blockRating / 100 * 3
    end
    local toughnessValue = CharacterWindow.CalculateValueWithBonus( GameData.BonusTypes.EBONUS_TOUGHNESS, GameData.Player.Stats[GameData.Stats.TOUGHNESS].baseValue )
    local currentVal = CharacterWindow.CalculateValueWithBonus( GameData.BonusTypes.EBONUS_BLOCK, baseVal ) + toughnessValue / 200
    if( currentVal > 100 )
    then
        currentVal = 100
    end
    local rightText = wstring.format(L"%.01f",currentVal)
    g_currentBlock = currentVal
    CharacterWindow.UpdateLabel(wndName, leftText, rightText, currentVal, baseVal)
end

function CharacterWindow.UpdateParryskillLabel(wndName)
    local leftText = GetString( StringTables.Default.LABEL_BONUS_PARRY )..L":"
    local baseVal = GameData.Player.Stats[GameData.Stats.PARRYSKILL].baseValue / 100
    local initiativeValue = CharacterWindow.CalculateValueWithBonus( GameData.BonusTypes.EBONUS_INITIATIVE, GameData.Player.Stats[GameData.Stats.INITIATIVE].baseValue ) 
    local currentVal = CharacterWindow.CalculateValueWithBonus( GameData.BonusTypes.EBONUS_PARRY, baseVal ) + initiativeValue / 100 * 3

    if( currentVal > 100 )
    then
        currentVal = 100
    end
    local rightText = wstring.format(L"%.01f",currentVal)
    g_currentParry = currentVal
    CharacterWindow.UpdateLabel(wndName, leftText, rightText, currentVal, baseVal)
end

function CharacterWindow.UpdateEvadeskillLabel(wndName)
    local leftText = GetString( StringTables.Default.LABEL_BONUS_EVADE )..L":"
    local baseVal = GameData.Player.Stats[GameData.Stats.EVADESKILL].baseValue / 100
    local initiativeValue = CharacterWindow.CalculateValueWithBonus( GameData.BonusTypes.EBONUS_INITIATIVE, GameData.Player.Stats[GameData.Stats.INITIATIVE].baseValue ) 
    local currentVal = CharacterWindow.CalculateValueWithBonus( GameData.BonusTypes.EBONUS_EVADE, baseVal ) + initiativeValue / 100 * 3
    if( currentVal > 100 )
    then
        currentVal = 100
    end
    local rightText = wstring.format(L"%.01f",currentVal)
    g_currentEvade = currentVal
    CharacterWindow.UpdateLabel(wndName, leftText, rightText, currentVal, baseVal)
end

function CharacterWindow.UpdateDisruptskillLabel(wndName)
    local leftText = GetString( StringTables.Default.LABEL_BONUS_DISRUPT )..L":"
    local baseVal = GameData.Player.Stats[GameData.Stats.DISRUPTSKILL].baseValue / 100
    local willpowerValue = CharacterWindow.CalculateValueWithBonus( GameData.BonusTypes.EBONUS_WILLPOWER, GameData.Player.Stats[GameData.Stats.WILLPOWER].baseValue ) 
    local currentVal = CharacterWindow.CalculateValueWithBonus( GameData.BonusTypes.EBONUS_DISRUPT, baseVal ) + willpowerValue / 100 * 3
    if( currentVal > 100 )
    then
        currentVal = 100
    end
    local rightText = wstring.format(L"%.01f",currentVal)
    g_currentDisrupt = currentVal
    CharacterWindow.UpdateLabel(wndName, leftText, rightText, currentVal, baseVal)
end

function GetDPSModifier( itemData )
        
    local DPS_MODIFIER_GENERAL_WEAPON = 5
    local DPS_MODIFIER_GREATER_WEAPON = 7.25

    local modifier = DPS_MODIFIER_GENERAL_WEAPON
    if(itemData.isTwoHanded == true and itemData.type ~= GameData.ItemTypes.STAFF)
    then
        modifier = DPS_MODIFIER_GREATER_WEAPON
    end
    
    return modifier

end

local function MeleeDPSFormula( itemData )

    local modifier = GetDPSModifier(itemData)
    local displayDPS = (((itemData.dps - modifier) * GameData.Player.battleLevel) / GameData.Player.level) + modifier
    
    -- If the DPS value from this formula minus the modifier is < 1, then we should use
    -- the weapon's DPS instead of the formula-driven DPS
    local validatedDPS = displayDPS - modifier
    if(validatedDPS < 1)
    then
        return itemData.dps
    end
    
    return displayDPS
    
end

function CharacterWindow.GetMeleeDPSLabelRight()
       
    -- Calculate right hand DPS first    
    local displayRightHandDps = MeleeDPSFormula(CharacterWindow.equipmentData[GameData.EquipSlots.RIGHT_HAND])
    
    -- Then calculate the left hand DPS
    local displayLeftHandDps = MeleeDPSFormula(CharacterWindow.equipmentData[GameData.EquipSlots.LEFT_HAND])

    -- Set the DPS labels and tooltips appropriately
    local retText = L""
    if ( displayRightHandDps > 0) then
        retText = wstring.format( L"%.01f", displayRightHandDps )
    else
        retText = L"0"
    end
    if ( displayLeftHandDps > 0 ) then
        retText = retText..L" / "..wstring.format( L"%.01f", displayLeftHandDps )
    else
        retText = retText..L" / "..L"0"
    end
    return retText
end

function CharacterWindow.UpdateMeleeDPSLabel(wndName)
    local leftText = GetString( StringTables.Default.LABEL_WEAPON_DPS )..L":"
    local rightText = CharacterWindow.GetMeleeDPSLabelRight()
    -- Update the color of the dps label with the current battleLevel
    local currentVal = GameData.Player.battleLevel
    local baseVal = GameData.Player.level
    CharacterWindow.UpdateLabel(wndName, leftText, rightText, currentVal, baseVal)
end

function CharacterWindow.UpdateMeleeBonusLabel(wndName)
    local leftText = GetString( StringTables.Default.LABEL_BONUS )..L":"
	local rightText, currentVal, baseVal = GetTotalBonusPower( g_currentStrength, GameData.BonusTypes.EBONUS_DAMAGE_MELEE )
    rightText = rightText..L" / "..CharacterWindow.CalculateValueWithBonus( GameData.BonusTypes.EBONUS_OUT_DAMAGE, 0 )
    CharacterWindow.UpdateLabel(wndName, leftText, rightText, currentVal, baseVal)
end

function CharacterWindow.CalcArmorPenetration()
    return wstring.format(L"%.01f", ( ( g_currentWeaponskill * ( GameData.Player.battleLevel / GameData.Player.battleLevelWithRenown ) / ( GameData.Player.battleLevel * 7.5 + 50 ) * .25 ) * 100.0 ) )
end

function CharacterWindow.UpdateArmorPenetrationLabel(wndName)
    local leftText = GetString( StringTables.Default.LABEL_MELEE_ARMOR_PENETRATION )..L":"
    local baseVal = GameData.Player.Stats[GameData.Stats.WEAPONSKILL].baseValue
    local currentVal = CharacterWindow.CalculateValueWithBonus( GameData.BonusTypes.EBONUS_WEAPONSKILL, baseVal )
    g_currentWeaponskill = currentVal
    local rightText = L""..CharacterWindow.CalcArmorPenetration()..L"%"
    CharacterWindow.UpdateLabel(wndName, leftText, rightText, currentVal, baseVal)
end

function CharacterWindow.UpdateMeleeSpeedLabel(wndName)
    local leftText = GetString( StringTables.Default.LABEL_SPEED )..L":"
	local weaponSpeed = CharacterWindow.equipmentData[GameData.EquipSlots.RIGHT_HAND].speed
	local currentVal = CharacterWindow.CalculateValueWithBonus( GameData.BonusTypes.EBONUS_AUTO_ATTACK_SPEED, weaponSpeed )
	local baseVal = weaponSpeed
    local rightText = L""..wstring.format( L"%.01f", currentVal )
	-- If currentVal < baseVal then we have a bonus, so we flip the input to UpdateLabel
    CharacterWindow.UpdateLabel( wndName, leftText, rightText, baseVal, currentVal )
end

function CharacterWindow.UpdateMeleeCritBonusLabel(wndName)
    local leftText = GetString( StringTables.Default.LABEL_CRIT_BONUS )..L":"
    local critBonus = CharacterWindow.CalculateValueWithBonus(GameData.BonusTypes.EBONUS_CRITICAL_HIT_RATE_MELEE, 0)
    critBonus = CharacterWindow.CalculateValueWithBonus(GameData.BonusTypes.EBONUS_CRITICAL_HIT_RATE, critBonus)
    local rightText = wstring.format(L"%d", critBonus)..L"%"
    local currentVal = critBonus
    local baseVal = 0
    CharacterWindow.UpdateLabel(wndName, leftText, rightText, currentVal, baseVal)
end

function CharacterWindow.UpdateRangedDPSLabel(wndName)
    local leftText = GetString( StringTables.Default.LABEL_WEAPON_DPS )..L":"
    local rightText = L""
    if (CharacterWindow.equipmentData[GameData.EquipSlots.RANGED].dps > 0) then
        rightText = rightText..wstring.format(L"%.01f",CharacterWindow.equipmentData[GameData.EquipSlots.RANGED].dps)
    else
        rightText = rightText..L"0"
    end
    local currentVal = 0
    local baseVal = 0
    CharacterWindow.UpdateLabel(wndName, leftText, rightText, currentVal, baseVal)
end

function CharacterWindow.UpdateRangedSpeedLabel(wndName)
    local leftText = GetString( StringTables.Default.LABEL_SPEED )..L":"
	local weaponSpeed = CharacterWindow.equipmentData[GameData.EquipSlots.RANGED].speed
	local currentVal = CharacterWindow.CalculateValueWithBonus( GameData.BonusTypes.EBONUS_AUTO_ATTACK_SPEED, weaponSpeed )
	local baseVal = weaponSpeed
	local rightText = L""..wstring.format( L"%.01f", currentVal )
	-- If currentVal < baseVal then we have a bonus, so we flip the input to UpdateLabel
    CharacterWindow.UpdateLabel( wndName, leftText, rightText, baseVal, currentVal )
end

function CharacterWindow.UpdateRangedBonusLabel(wndName)
    local leftText = GetString( StringTables.Default.LABEL_BONUS )..L":"
	local rightText, currentVal, baseVal = GetTotalBonusPower( g_currentBallisticskill, GameData.BonusTypes.EBONUS_DAMAGE_RANGED )
    rightText = rightText..L" / "..CharacterWindow.CalculateValueWithBonus( GameData.BonusTypes.EBONUS_OUT_DAMAGE, 0 )
    CharacterWindow.UpdateLabel(wndName, leftText, rightText, currentVal, baseVal)
end

function CharacterWindow.UpdateRangedCritBonusLabel(wndName)
    local leftText = GetString( StringTables.Default.LABEL_CRIT_BONUS )..L":"
    local critBonus = CharacterWindow.CalculateValueWithBonus(GameData.BonusTypes.EBONUS_CRITICAL_HIT_RATE_RANGED, 0)
    critBonus = CharacterWindow.CalculateValueWithBonus(GameData.BonusTypes.EBONUS_CRITICAL_HIT_RATE, critBonus)
    local rightText = wstring.format(L"%d", critBonus)..L"%"
    local currentVal = critBonus
    local baseVal = 0
    CharacterWindow.UpdateLabel(wndName, leftText, rightText, currentVal, baseVal)
end

function CharacterWindow.UpdateSpellBonusLabel(wndName)
    local leftText = GetString( StringTables.Default.LABEL_BONUS )..L":"
    local rightText, currentVal, baseVal = GetTotalBonusPower( g_currentIntelligence, GameData.BonusTypes.EBONUS_DAMAGE_MAGIC )
    CharacterWindow.UpdateLabel(wndName, leftText, rightText, currentVal, baseVal)
end

function CharacterWindow.UpdateSpellCritBonusLabel(wndName)
    local leftText = GetString( StringTables.Default.LABEL_CRIT_BONUS )..L":"
    local critBonus = CharacterWindow.CalculateValueWithBonus(GameData.BonusTypes.EBONUS_CRITICAL_HIT_RATE_MAGIC, 0)
    critBonus = CharacterWindow.CalculateValueWithBonus(GameData.BonusTypes.EBONUS_CRITICAL_HIT_RATE, critBonus)
    local rightText = wstring.format(L"%d", critBonus)..L"%"
    local currentVal = critBonus
    local baseVal = 0
    CharacterWindow.UpdateLabel(wndName, leftText, rightText, currentVal, baseVal)
end

function CharacterWindow.UpdateSpellHealCritBonusLabel(wndName)
    local leftText = GetString( StringTables.Default.LABEL_CRIT_BONUS )..L":"
    local critBonus = CharacterWindow.CalculateValueWithBonus(GameData.BonusTypes.EBONUS_CRITICAL_HIT_RATE_HEALING, 0)
    critBonus = CharacterWindow.CalculateValueWithBonus(GameData.BonusTypes.EBONUS_CRITICAL_HIT_RATE, critBonus)
    local rightText = wstring.format(L"%d", critBonus)..L"%"
    local currentVal = critBonus
    local baseVal = 0
    CharacterWindow.UpdateLabel(wndName, leftText, rightText, currentVal, baseVal)
end


function CharacterWindow.UpdateSpellHealingBonusLabel(wndName)
    local leftText = GetString( StringTables.Default.LABEL_BONUS_HEALING )..L":"
	local rightText, currentVal, baseVal = GetTotalBonusPower( g_currentWillpower, GameData.BonusTypes.EBONUS_HEALING_POWER )
    CharacterWindow.UpdateLabel(wndName, leftText, rightText, currentVal, baseVal)
end


function CharacterWindow.UpdateBaseLabel(wndName)
    local leftText = ""
    local rightText = L""
    local currentVal = 0
    local baseVal = 0
    CharacterWindow.UpdateLabel(wndName, leftText, rightText, currentVal, baseVal)
end

function CharacterWindow.CalculateValueWithBonus(bonusType, baseValue)
    return GetBonus(bonusType, baseValue)
end

function CharacterWindow.RefreshStatsData()
    CharacterWindow.UpdateStatsNew()
    WindowUnregisterEventHandler ("CharacterWindow", SystemData.Events.ITEM_SET_DATA_UPDATED )
    CharacterWindow.registeredForItemSetData = nil
end
