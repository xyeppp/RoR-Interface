----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

CraftingUtils = {}

CraftingUtils.SalvagingDifficulty =
{
	[GameData.Salvaging.TRIVAL]			= { color=DefaultColor.WHITE,   string=GetStringFromTable( "Default", StringTables.Default.TEXT_SALVAGING_DIFFICULTY_TRIVIAL ),		},
	[GameData.Salvaging.EASY]			= { color=DefaultColor.GREEN,	string=GetStringFromTable( "Default", StringTables.Default.TEXT_SALVAGING_DIFFICULTY_EASY ),		},
	[GameData.Salvaging.CHALLENGING]	= { color=DefaultColor.YELLOW,	string=GetStringFromTable( "Default", StringTables.Default.TEXT_SALVAGING_DIFFICULTY_CHALLENGING ),	},
	[GameData.Salvaging.DIFFICULT]		= { color=DefaultColor.ORANGE,	string=GetStringFromTable( "Default", StringTables.Default.TEXT_SALVAGING_DIFFICULTY_DIFFICULT ),	},
	[GameData.Salvaging.IMPOSSIBLE]		= { color=DefaultColor.RED,		string=GetStringFromTable( "Default", StringTables.Default.TEXT_SALVAGING_DIFFICULTY_IMPOSSIBLE ),	},
}

-- helper function
function CraftingUtils.GetSalvagingStatString( statString )
    return GetStringFormat( StringTables.Default.TEXT_SALVAGE_STAT_ITEM, { CraftingUtils.SalvagingStatStringLookUp[statString] } )
end

CraftingUtils.SalvagingStatStringLookUp =
{
    [GameData.BonusTypes.EBONUS_STRENGTH]                   = GetString( StringTables.Default.LABEL_STRENGTH ),
    [GameData.BonusTypes.EBONUS_AGILITY]                    = GetString( StringTables.Default.LABEL_AGILITY ),
    [GameData.BonusTypes.EBONUS_WILLPOWER]                  = GetString( StringTables.Default.LABEL_WILLPOWER ),
    [GameData.BonusTypes.EBONUS_TOUGHNESS]                  = GetString( StringTables.Default.LABEL_TOUGHNESS ),
    [GameData.BonusTypes.EBONUS_WOUNDS]                     = GetString( StringTables.Default.LABEL_WOUNDS ),
    [GameData.BonusTypes.EBONUS_INITIATIVE]                 = GetString( StringTables.Default.LABEL_INITIATIVE ),
    [GameData.BonusTypes.EBONUS_INTELLIGENCE]               = GetString( StringTables.Default.LABEL_INTELLIGENCE ),
    [GameData.BonusTypes.EBONUS_WEAPONSKILL]                = GetString( StringTables.Default.LABEL_WEAPONSKILL ),  
    [GameData.BonusTypes.EBONUS_BALLISTICSKILL]             = GetString( StringTables.Default.LABEL_BALLISTICSKILL ),
    [GameData.BonusTypes.EBONUS_BLOCKSKILL]                 = GetString( StringTables.Default.LABEL_BLOCKSKILL ),
    [GameData.BonusTypes.EBONUS_PARRYSKILL]                 = GetString( StringTables.Default.LABEL_PARRYSKILL ),
    [GameData.BonusTypes.EBONUS_EVADESKILL]                 = GetString( StringTables.Default.LABEL_EVADESKILL ),
    [GameData.BonusTypes.EBONUS_DISRUPTSKILL]               = GetString( StringTables.Default.LABEL_DISRUPTSKILL ),
    [GameData.BonusTypes.EBONUS_SPIRIT_RESIST]              = GetString( StringTables.Default.LABEL_SPIRITRESIST ),  
    [GameData.BonusTypes.EBONUS_ELEMENTAL_RESIST]           = GetString( StringTables.Default.LABEL_ELEMENTALRESIST ),
    [GameData.BonusTypes.EBONUS_CORPOREAL_RESIST]           = GetString( StringTables.Default.LABEL_CORPOREALRESIST ),
    [GameData.BonusTypes.EBONUS_CRITICAL_HIT_RATE_MELEE]    = GetString( StringTables.Default.LABEL_BONUS_CRITICAL_HIT_RATE_MELEE ),
    [GameData.BonusTypes.EBONUS_DAMAGE_MELEE]               = GetString( StringTables.Default.LABEL_BONUS_DAMAGE_MELEE ),
    [GameData.BonusTypes.EBONUS_CRITICAL_HIT_RATE_MAGIC]    = GetString( StringTables.Default.LABEL_BONUS_CRITICAL_HIT_RATE_MAGIC ),
    [GameData.BonusTypes.EBONUS_DAMAGE_MAGIC]               = GetString( StringTables.Default.LABEL_BONUS_DAMAGE_MAGIC ),
    [GameData.BonusTypes.EBONUS_CRITICAL_HIT_RATE_RANGED]   = GetString( StringTables.Default.LABEL_BONUS_CRITICAL_HIT_RATE_RANGED ),
    [GameData.BonusTypes.EBONUS_DAMAGE_RANGED]              = GetString( StringTables.Default.LABEL_BONUS_DAMAGE_RANGED ),
    [GameData.BonusTypes.EBONUS_CRITICAL_HIT_RATE_HEALING]  = GetString( StringTables.Default.LABEL_BONUS_CRITICAL_HIT_RATE_HEALING ),
    [GameData.BonusTypes.EBONUS_HEALING_POWER]              = GetString( StringTables.Default.LABEL_BONUS_HEALING_POWER ),
}
