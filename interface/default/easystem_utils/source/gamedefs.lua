-- This file contains enumerations and global definitions

GameDefs = {}

-- UI Defs
GameDefs.HeadingColor = {r=255, g=204, b=102 }

-- Item Rarity
GameDefs.ItemRarity = {}
GameDefs.ItemRarity[SystemData.ItemRarity.UTILITY]      = { desc=GetString( StringTables.Default.LABEL_ITEM_RARITY_UTILITY ),   color=DefaultColor.RARITY_UTILITY  } 
GameDefs.ItemRarity[SystemData.ItemRarity.COMMON]       = { desc=GetString( StringTables.Default.LABEL_ITEM_RARITY_COMMON ),    color=DefaultColor.RARITY_COMMON }
GameDefs.ItemRarity[SystemData.ItemRarity.UNCOMMON]     = { desc=GetString( StringTables.Default.LABEL_ITEM_RARITY_UNCOMMON ),  color=DefaultColor.RARITY_UNCOMMON }
GameDefs.ItemRarity[SystemData.ItemRarity.RARE]         = { desc=GetString( StringTables.Default.LABEL_ITEM_RARITY_RARE ),      color=DefaultColor.RARITY_RARE }
GameDefs.ItemRarity[SystemData.ItemRarity.VERY_RARE]    = { desc=GetString( StringTables.Default.LABEL_ITEM_RARITY_VERY_RARE ), color=DefaultColor.RARITY_VERY_RARE  } 
GameDefs.ItemRarity[SystemData.ItemRarity.ARTIFACT]     = { desc=GetString( StringTables.Default.LABEL_ITEM_RARITY_ARTIFACT ),  color=DefaultColor.RARITY_ARTIFACT }

-- Item Enhancement data
GameDefs.MAX_ITEM_ENHANCEMENT_SLOTS = 3;

-- Item Bonuses and Bonus Types
GameDefs.MAX_BONUSES_PER_ITEM = 10

GameDefs.ITEMBONUS_NONE        = 0; 
GameDefs.ITEMBONUS_MUNDANE     = 1; -- I was told this is almost never used...
GameDefs.ITEMBONUS_MAGIC       = 2; -- Use BonusTypes to determine stat name
GameDefs.ITEMBONUS_USE         = 3; -- What happens when you use an item
GameDefs.ITEMBONUS_PROC        = 4; -- Should NEVER be used...
GameDefs.ITEMBONUS_CONTINUOUS  = 5; -- Look up ability description using...value as ability id.

-- Realm Colors
GameDefs.RealmColors = {}
GameDefs.RealmColors[0] = {r=255, g=255, b=255 } -- Neutral
GameDefs.RealmColors[1] = {r=0,   g=148, b=225 } -- Order
GameDefs.RealmColors[2] = {r=255, g=5,   b=5   } -- Destruction

-- Scenario Summary Window Alternating Row Colors
GameDefs.RowColors = {}
GameDefs.RowColors[0]        = {r=0,   g=0,   b=0,   a=0.0} -- Completely transparent
GameDefs.RowColors[1]        = {r=255, g=255, b=255, a=0.1} -- 10% white
GameDefs.RowColorsGreyOnGrey = {}
GameDefs.RowColorsGreyOnGrey[0]        = {r=255, g=255, b=255, a=0.03} -- 3% white
GameDefs.RowColorsGreyOnGrey[1]        = {r=255, g=255, b=255, a=0.08} -- 8% white
GameDefs.RowColorHighlighted = {r=16,  g=21,  b=27,  a=1.0} -- Dark Steel Blue
GameDefs.RowColorInvalid     = {r=255, g=0,   b=0,   a=1.0} -- Some kind of red

GameDefs.MAX_ITEM_SET_RANKS    = 10;
GameDefs.MAX_ITEMS_IN_SET      = 18;  

--[[

This data should be moved over to the GameDefs table, but in order to avoid doing all that
crazy search and replace, I am going to leave it all in its own table for now...er tables.

--]]

-- Item equip slots
ItemSlots = {  }

-- Item slot names
ItemSlots[GameData.EquipSlots.RIGHT_HAND]     =  { name=GetString( StringTables.Default.LABEL_RIGHT_HAND )}
ItemSlots[GameData.EquipSlots.LEFT_HAND]      =  { name=GetString( StringTables.Default.LABEL_LEFT_HAND ) }
ItemSlots[GameData.EquipSlots.EITHER_HAND]    =  { name=GetString( StringTables.Default.LABEL_RIGHT_HAND ) }
ItemSlots[GameData.EquipSlots.RANGED]         =  { name=GetString( StringTables.Default.LABEL_RANGED_SLOT ) }
ItemSlots[GameData.EquipSlots.BODY]           =  { name=GetString( StringTables.Default.LABEL_BODY )}
ItemSlots[GameData.EquipSlots.GLOVES]         =  { name=GetString( StringTables.Default.LABEL_GLOVES )}
ItemSlots[GameData.EquipSlots.BOOTS]          =  { name=GetString( StringTables.Default.LABEL_BOOTS )}
ItemSlots[GameData.EquipSlots.HELM]           =  { name=GetString( StringTables.Default.LABEL_HELM ) }
ItemSlots[GameData.EquipSlots.SHOULDERS]      =  { name=GetString( StringTables.Default.LABEL_SHOULDERS ) }
ItemSlots[GameData.EquipSlots.POCKET1]        =  { name=GetString( StringTables.Default.LABEL_POCKET ) }
ItemSlots[GameData.EquipSlots.POCKET2]        =  { name=GetString( StringTables.Default.LABEL_POCKET )}
ItemSlots[GameData.EquipSlots.BACK]           =  { name=GetString( StringTables.Default.LABEL_BACK )}
ItemSlots[GameData.EquipSlots.BELT]           =  { name=GetString( StringTables.Default.LABEL_BELT )}
ItemSlots[GameData.EquipSlots.EVENT]          =  { name=GetString( StringTables.Default.LABEL_EVENT )}
ItemSlots[GameData.EquipSlots.BANNER]         =  { name=GetString( StringTables.Default.LABEL_BANNER ) }
ItemSlots[GameData.EquipSlots.ACCESSORY1]     =  { name=GetString( StringTables.Default.LABEL_ACCESSORY1 ) } 
ItemSlots[GameData.EquipSlots.ACCESSORY2]     =  { name=GetString( StringTables.Default.LABEL_ACCESSORY2 ) } 
ItemSlots[GameData.EquipSlots.ACCESSORY3]     =  { name=GetString( StringTables.Default.LABEL_ACCESSORY3 ) } 
ItemSlots[GameData.EquipSlots.ACCESSORY4]     =  { name=GetString( StringTables.Default.LABEL_ACCESSORY4 ) }


TrophySlots = {}

-- These are the only 3 locations that trophies should be restricted to. 
--   Body trophy locations come in as Belt now, so we give it the generic term Waist for both.
TrophySlots[GameData.EquipSlots.BELT]           =  { name=GetString( StringTables.Default.LABEL_WAIST )}
TrophySlots[GameData.EquipSlots.HELM]           =  { name=GetString( StringTables.Default.LABEL_HELM ) }
TrophySlots[GameData.EquipSlots.SHOULDERS]      =  { name=GetString( StringTables.Default.LABEL_SHOULDERS ) }


-- Item bonus types
-- These bonus types are ONLY for stat bonuses (GameDefs.ITEMBONUS_MAGIC)
--
-- The format field, if set, is a formatting string key (into Default.txt string table) for how this bonus should 
-- appear in the ItemTooltip Window, and possibly other places it is used. If you add new formatting strings, they
-- should take 2 GetStringFormat() parameters: the numeric bonus value and the BonusTypes[XXX].name  
--

BonusTypes = {}
BonusTypes[GameData.BonusTypes.EBONUS_NONE                    ] =  { name=GetString( StringTables.Default.LABEL_NONE), desc=GetString( StringTables.Default.LABEL_NONE) }
BonusTypes[GameData.BonusTypes.EBONUS_STRENGTH                ] =  { name=GetString( StringTables.Default.LABEL_STRENGTH ), desc=GetString( StringTables.Default.TEXT_STRENGTH_DESC ) }
BonusTypes[GameData.BonusTypes.EBONUS_AGILITY                 ] =  { name=GetString( StringTables.Default.LABEL_AGILITY ), desc=GetString( StringTables.Default.TEXT_AGILITY_DESC )}
BonusTypes[GameData.BonusTypes.EBONUS_WILLPOWER               ] =  { name=GetString( StringTables.Default.LABEL_WILLPOWER ), desc=GetString( StringTables.Default.TEXT_WILLPOWER_DESC ) }
BonusTypes[GameData.BonusTypes.EBONUS_TOUGHNESS               ] =  { name=GetString( StringTables.Default.LABEL_TOUGHNESS ), desc=GetString( StringTables.Default.TEXT_TOUGHNESS_DESC ) }
BonusTypes[GameData.BonusTypes.EBONUS_WOUNDS                  ] =  { name=GetString( StringTables.Default.LABEL_WOUNDS ), desc=GetString( StringTables.Default.TEXT_WOUNDS_DESC ) }
BonusTypes[GameData.BonusTypes.EBONUS_INITIATIVE              ] =  { name=GetString( StringTables.Default.LABEL_INITIATIVE ), desc=GetString( StringTables.Default.TEXT_INITIATIVE_DESC ) }
BonusTypes[GameData.BonusTypes.EBONUS_WEAPONSKILL             ] =  { name=GetString( StringTables.Default.LABEL_WEAPONSKILL ), desc=GetString( StringTables.Default.TEXT_WEAPONSKILL_DESC ) }
BonusTypes[GameData.BonusTypes.EBONUS_BALLISTICSKILL          ] =  { name=GetString( StringTables.Default.LABEL_BALLISTICSKILL ), desc=GetString( StringTables.Default.TEXT_BALLISTICSKILL_DESC ) }
BonusTypes[GameData.BonusTypes.EBONUS_INTELLIGENCE            ] =  { name=GetString( StringTables.Default.LABEL_INTELLIGENCE ), desc=GetString( StringTables.Default.TEXT_INTELLIGENCE_DESC ) }
BonusTypes[GameData.BonusTypes.EBONUS_BLOCKSKILL              ] =  { name=GetString( StringTables.Default.LABEL_BLOCKSKILL ), desc=L"" }
BonusTypes[GameData.BonusTypes.EBONUS_PARRYSKILL              ] =  { name=GetString( StringTables.Default.LABEL_PARRYSKILL ), desc=L"" }
BonusTypes[GameData.BonusTypes.EBONUS_EVADESKILL              ] =  { name=GetString( StringTables.Default.LABEL_EVADESKILL ), desc=L"" }
BonusTypes[GameData.BonusTypes.EBONUS_DISRUPTSKILL            ] =  { name=GetString( StringTables.Default.LABEL_DISRUPTSKILL ), desc=L"" }
BonusTypes[GameData.BonusTypes.EBONUS_SPIRIT_RESIST				] =  { name=GetString( StringTables.Default.LABEL_SPIRITRESIST ), desc=GetString( StringTables.Default.TEXT_SPIRITRESIST_DESC ) }       
BonusTypes[GameData.BonusTypes.EBONUS_ELEMENTAL_RESIST			] =  { name=GetString( StringTables.Default.LABEL_ELEMENTALRESIST ), desc=GetString( StringTables.Default.TEXT_ELEMENTALRESIST_DESC ) }       
BonusTypes[GameData.BonusTypes.EBONUS_CORPOREAL_RESIST			] =  { name=GetString( StringTables.Default.LABEL_CORPOREALRESIST ), desc=GetString( StringTables.Default.TEXT_CORPOREALRESIST_DESC ) }       
-- other resists go here
BonusTypes[GameData.BonusTypes.EBONUS_INC_DAMAGE              ] =  { name=GetString( StringTables.Default.LABEL_BONUS_INC_DMG ), desc=L"" }  
BonusTypes[GameData.BonusTypes.EBONUS_OUT_DAMAGE              ] =  { name=GetString( StringTables.Default.LABEL_BONUS_OUT_DMG ), desc=L"" }  
BonusTypes[GameData.BonusTypes.EBONUS_ARMOR                   ] =  { name=GetString( StringTables.Default.LABEL_BONUS_ARMOR ), desc=L"" }  
BonusTypes[GameData.BonusTypes.EBONUS_VELOCITY                ] =  { name=GetString( StringTables.Default.LABEL_BONUS_VELOCITY ), desc=L"" }  
BonusTypes[GameData.BonusTypes.EBONUS_BLOCK                   ] =  { name=GetString( StringTables.Default.LABEL_BONUS_BLOCK ), desc=L"", format=StringTables.Default.LABEL_BONUS_PREFIX_POSITIVE_PERCENT, }  
BonusTypes[GameData.BonusTypes.EBONUS_PARRY                   ] =  { name=GetString( StringTables.Default.LABEL_BONUS_PARRY ), desc=L"", format=StringTables.Default.LABEL_BONUS_PREFIX_POSITIVE_PERCENT, }  
BonusTypes[GameData.BonusTypes.EBONUS_EVADE                   ] =  { name=GetString( StringTables.Default.LABEL_BONUS_EVADE ), desc=L"", format=StringTables.Default.LABEL_BONUS_PREFIX_POSITIVE_PERCENT, }  
BonusTypes[GameData.BonusTypes.EBONUS_DISRUPT                 ] =  { name=GetString( StringTables.Default.LABEL_BONUS_DISRUPT ), desc=L"", format=StringTables.Default.LABEL_BONUS_PREFIX_POSITIVE_PERCENT, }  
BonusTypes[GameData.BonusTypes.EBONUS_AP_REGEN                ] =  { name=GetString( StringTables.Default.LABEL_BONUS_AP_REGEN ), desc=L"" }  
BonusTypes[GameData.BonusTypes.EBONUS_MORALE_REGEN            ] =  { name=GetString( StringTables.Default.LABEL_BONUS_MORALE_GEN ), desc=L"" }  
BonusTypes[GameData.BonusTypes.EBONUS_COOLDOWN                ] =  { name=GetString( StringTables.Default.LABEL_BONUS_MORALE_GEN ), desc=L"" }  
BonusTypes[GameData.BonusTypes.EBONUS_BUILD_TIME              ] =  { name=GetString( StringTables.Default.LABEL_BONUS_BUILD_TIME ), desc=L"" }  
BonusTypes[GameData.BonusTypes.EBONUS_CRITICAL_DAMAGE         ] =  { name=GetString( StringTables.Default.LABEL_BONUS_CRIT_DMG ), desc=L"" }  
BonusTypes[GameData.BonusTypes.EBONUS_RANGE                   ] =  { name=GetString( StringTables.Default.LABEL_BONUS_RANGE ), desc=L"", multiplier=1/12 }       
BonusTypes[GameData.BonusTypes.EBONUS_AUTO_ATTACK_SPEED       ] =  { name=GetString( StringTables.Default.LABEL_BONUS_AUTO_ATK_SPEED ), desc=L"" }  
BonusTypes[GameData.BonusTypes.EBONUS_RADIUS                  ] =  { name=GetString( StringTables.Default.LABEL_BONUS_RADIUS ), desc=L"", multiplier=1/12 }  
BonusTypes[GameData.BonusTypes.EBONUS_AUTO_ATTACK_DAMAGE      ] =  { name=GetString( StringTables.Default.LABEL_BONUS_AUTO_ATK_DMG ), desc=L"" }  
BonusTypes[GameData.BonusTypes.EBONUS_AP_COST                 ] =  { name=GetString( StringTables.Default.LABEL_BONUS_AP_COST ), desc=L"" }  
BonusTypes[GameData.BonusTypes.EBONUS_CRITICAL_HIT_RATE       ] =  { name=GetString( StringTables.Default.LABEL_BONUS_CRIT_HIT_RATE ), desc=L"" }  
BonusTypes[GameData.BonusTypes.EBONUS_CRITICAL_DAMAGE_TAKEN   ] =  { name=GetString( StringTables.Default.LABEL_BONUS_CRIT_DMG_TAKEN ), desc=L"", multiplier=-1 }  
BonusTypes[GameData.BonusTypes.EBONUS_EFFECT_RESIST           ] =  { name=GetString( StringTables.Default.LABEL_BONUS_EFFECT_RESIST ), desc=L"" }   
BonusTypes[GameData.BonusTypes.EBONUS_EFFECT_BUFF             ] =  { name=GetString( StringTables.Default.LABEL_BONUS_EFFECT_BUFF ), desc=L"" }  
BonusTypes[GameData.BonusTypes.EBONUS_MIN_RANGE               ] =  { name=GetString( StringTables.Default.LABEL_BONUS_MIN_RANGE ), desc=L"" }  
BonusTypes[GameData.BonusTypes.EBONUS_DAMAGE_ABSORB           ] =  { name=GetString( StringTables.Default.LABEL_BONUS_DAMAGE_ABSORB ), desc=L"" }  
BonusTypes[GameData.BonusTypes.EBONUS_SETBACK_CHANCE			] =  { name=GetString( StringTables.Default.LABEL_BONUS_SETBACK_CHANCE ), desc=L"" }  
BonusTypes[GameData.BonusTypes.EBONUS_SETBACK_VALUE				] =  { name=GetString( StringTables.Default.LABEL_BONUS_SETBACK_VALUE ), desc=L"" }  
--BonusTypes[GameData.BonusTypes.EBONUS_XP_WORTH					] =  { name=GetString( StringTables.Default.LABEL_BONUS_XP_WORTH ), desc=L"" }  
--BonusTypes[GameData.BonusTypes.EBONUS_RENOWN_WORTH				] =  { name=GetString( StringTables.Default.LABEL_BONUS_RENOWN_WORTH ), desc=L"" }  
--BonusTypes[GameData.BonusTypes.EBONUS_INFLUENCE_WORTH			] =  { name=GetString( StringTables.Default.LABEL_BONUS_INFLUENCE_WORTH ), desc=L"" }  
--BonusTypes[GameData.BonusTypes.EBONUS_MONETARY_WORTH			] =  { name=GetString( StringTables.Default.LABEL_BONUS_MONETARY_WORTH ), desc=L"" }  
BonusTypes[GameData.BonusTypes.EBONUS_AGGRO_RADIUS				] =  { name=GetString( StringTables.Default.LABEL_BONUS_AGGRO_RADIUS ), desc=L"" }  
BonusTypes[GameData.BonusTypes.EBONUS_TARGET_DURATION			] =  { name=GetString( StringTables.Default.LABEL_BONUS_TARGET_DURATION ), desc=L"" }  
BonusTypes[GameData.BonusTypes.EBONUS_SPEC						] =  { name=GetString( StringTables.Default.LABEL_BONUS_SPEC ), desc=L"" }  
BonusTypes[GameData.BonusTypes.EBONUS_GOLD_LOOTED				] =  { name=GetString( StringTables.Default.LABEL_BONUS_GOLD_LOOTED ), desc=L"" }   
BonusTypes[GameData.BonusTypes.EBONUS_XP_RECEIVED				] =  { name=GetString( StringTables.Default.LABEL_BONUS_XP_RECEIVED ), desc=L"" }   
BonusTypes[GameData.BonusTypes.EBONUS_TRADE_SKILL_BUTCHERING	] =  { name=GetString( StringTables.Default.LABEL_BONUS_TRADE_SKILL_BUTCHERING ), desc=L"" }
BonusTypes[GameData.BonusTypes.EBONUS_TRADE_SKILL_SCAVENGING	] =  { name=GetString( StringTables.Default.LABEL_BONUS_TRADE_SKILL_SCAVENGING ), desc=L"" }
BonusTypes[GameData.BonusTypes.EBONUS_TRADE_SKILL_CULTIVATION	] =  { name=GetString( StringTables.Default.LABEL_BONUS_TRADE_SKILL_CULTIVATION ), desc=L"" }
BonusTypes[GameData.BonusTypes.EBONUS_TRADE_SKILL_APOTHECARY	] =  { name=GetString( StringTables.Default.LABEL_BONUS_TRADE_SKILL_APOTHECARY ), desc=L"" }
BonusTypes[GameData.BonusTypes.EBONUS_TRADE_SKILL_TALISMAN		] =  { name=GetString( StringTables.Default.LABEL_BONUS_TRADE_SKILL_TALISMAN ), desc=L"" }
BonusTypes[GameData.BonusTypes.EBONUS_TRADE_SKILL_SALVAGING		] =  { name=GetString( StringTables.Default.LABEL_BONUS_TRADE_SKILL_SALVAGING ), desc=L"" }
BonusTypes[GameData.BonusTypes.EBONUS_STEALTH					] =  { name=GetString( StringTables.Default.LABEL_BONUS_STEALTH ), desc=L"" }
BonusTypes[GameData.BonusTypes.EBONUS_STEALTH_DETECTION			] =  { name=GetString( StringTables.Default.LABEL_BONUS_STEALTH_DETECTION ), desc=L"" }
BonusTypes[GameData.BonusTypes.EBONUS_HATE_CAUSED				] =  { name=GetString( StringTables.Default.LABEL_BONUS_HATE_CAUSED ), desc=L"" }
BonusTypes[GameData.BonusTypes.EBONUS_HATE_RECEIVED				] =  { name=GetString( StringTables.Default.LABEL_BONUS_HATE_RECEIVED ), desc=L"" }
BonusTypes[GameData.BonusTypes.EBONUS_OFFHAND_CHANCE			] =  { name=GetString( StringTables.Default.LABEL_BONUS_OFFHAND_CHANCE ), desc=L"" }
BonusTypes[GameData.BonusTypes.EBONUS_OFFHAND_DAMAGE			] =  { name=GetString( StringTables.Default.LABEL_BONUS_OFFHAND_DAMAGE ), desc=L"" }
BonusTypes[GameData.BonusTypes.EBONUS_RENOWN_RECEIVED			] =  { name=GetString( StringTables.Default.LABEL_BONUS_RENOWN_RECEIVED ), desc=L"" }
BonusTypes[GameData.BonusTypes.EBONUS_INFLUENCE_RECEIVED		] =  { name=GetString( StringTables.Default.LABEL_BONUS_INFLUENCE_RECEIVED ), desc=L"" }
--BonusTypes[GameData.BonusTypes.EBONUS_DISMOUNT_CHANCE			] =  { name=GetString( StringTables.Default.LABEL_BONUS_DISMOUNT_CHANCE ), desc=L"" }
--BonusTypes[GameData.BonusTypes.EBONUS_GRAVITY					] =  { name=GetString( StringTables.Default.LABEL_BONUS_GRAVITY ), desc=L"" }
--BonusTypes[GameData.BonusTypes.EBONUS_LEVITATION_HEIGHT			] =  { name=GetString( StringTables.Default.LABEL_BONUS_LEVITATION_HEIGHT ), desc=L"" }
BonusTypes[GameData.BonusTypes.EBONUS_CRITICAL_HIT_RATE_MELEE	] =  { name=GetString( StringTables.Default.LABEL_BONUS_CRITICAL_HIT_RATE_MELEE ), desc=L"", format=StringTables.Default.LABEL_BONUS_PREFIX_POSITIVE_PERCENT, }
BonusTypes[GameData.BonusTypes.EBONUS_CRITICAL_HIT_RATE_RANGED	] =  { name=GetString( StringTables.Default.LABEL_BONUS_CRITICAL_HIT_RATE_RANGED ), desc=L"", format=StringTables.Default.LABEL_BONUS_PREFIX_POSITIVE_PERCENT, }
BonusTypes[GameData.BonusTypes.EBONUS_CRITICAL_HIT_RATE_MAGIC	] =  { name=GetString( StringTables.Default.LABEL_BONUS_CRITICAL_HIT_RATE_MAGIC ), desc=L"", format=StringTables.Default.LABEL_BONUS_PREFIX_POSITIVE_PERCENT, }
BonusTypes[GameData.BonusTypes.EBONUS_HEALTH_REGEN				] =  { name=GetString( StringTables.Default.LABEL_BONUS_HEALTH_REGEN ), desc=L"", multiplier=4  }
BonusTypes[GameData.BonusTypes.EBONUS_DAMAGE_MELEE				] =  { name=GetString( StringTables.Default.LABEL_BONUS_DAMAGE_MELEE ), desc=L"" }
BonusTypes[GameData.BonusTypes.EBONUS_DAMAGE_RANGED				] =  { name=GetString( StringTables.Default.LABEL_BONUS_DAMAGE_RANGED ), desc=L"" }
BonusTypes[GameData.BonusTypes.EBONUS_DAMAGE_MAGIC					] =  { name=GetString( StringTables.Default.LABEL_BONUS_DAMAGE_MAGIC ), desc=L"" }
BonusTypes[GameData.BonusTypes.EBONUS_ARMOR_PENETRATION_REDUCTION	] =  { name=GetString( StringTables.Default.LABEL_BONUS_ARMOR_PENETRATION_REDUCTION ), desc=L"", format=StringTables.Default.LABEL_BONUS_PREFIX_POSITIVE_PERCENT, }
BonusTypes[GameData.BonusTypes.EBONUS_CRITICAL_HIT_RATE_REDUCTION	] =  { name=GetString( StringTables.Default.LABEL_BONUS_CRITICAL_HIT_RATE_REDUCTION ), desc=L"", format=StringTables.Default.LABEL_BONUS_PREFIX_POSITIVE_PERCENT, }
BonusTypes[GameData.BonusTypes.EBONUS_BLOCK_STRIKETHROUGH			] =  { name=GetString( StringTables.Default.LABEL_BONUS_BLOCK_STRIKETHROUGH ), desc=L"", format=StringTables.Default.LABEL_BONUS_PREFIX_POSITIVE_PERCENT, }
BonusTypes[GameData.BonusTypes.EBONUS_PARRY_STRIKETHROUGH			] =  { name=GetString( StringTables.Default.LABEL_BONUS_PARRY_STRIKETHROUGH ), desc=L"", format=StringTables.Default.LABEL_BONUS_PREFIX_POSITIVE_PERCENT, }
BonusTypes[GameData.BonusTypes.EBONUS_EVADE_STRIKETHROUGH			] =  { name=GetString( StringTables.Default.LABEL_BONUS_EVADE_STRIKETHROUGH  ), desc=L"", format=StringTables.Default.LABEL_BONUS_PREFIX_POSITIVE_PERCENT, }
BonusTypes[GameData.BonusTypes.EBONUS_DISRUPT_STRIKETHROUGH			] =  { name=GetString( StringTables.Default.LABEL_BONUS_DISRUPT_STRIKETHROUGH ), desc=L"", format=StringTables.Default.LABEL_BONUS_PREFIX_POSITIVE_PERCENT, }
BonusTypes[GameData.BonusTypes.EBONUS_CRITICAL_HIT_RATE_HEALING		] =  { name=GetString( StringTables.Default.LABEL_BONUS_CRITICAL_HIT_RATE_HEALING ), desc=L"", format=StringTables.Default.LABEL_BONUS_PREFIX_POSITIVE_PERCENT, }
BonusTypes[GameData.BonusTypes.EBONUS_MAX_ACTION_POINTS				] =  { name=GetString( StringTables.Default.LABEL_BONUS_MAX_ACTION_POINTS ), desc=L"" }
BonusTypes[GameData.BonusTypes.EBONUS_SPEC_1						] =  { name=GetString(StringTables.Default.LABEL_BONUS_SPEC_1), desc=L"" }
BonusTypes[GameData.BonusTypes.EBONUS_SPEC_2						] =  { name=GetString(StringTables.Default.LABEL_BONUS_SPEC_2), desc=L"" }
BonusTypes[GameData.BonusTypes.EBONUS_SPEC_3						] =  { name=GetString(StringTables.Default.LABEL_BONUS_SPEC_3), desc=L"" }
BonusTypes[GameData.BonusTypes.EBONUS_HEALING_POWER					] =  { name=GetString( StringTables.Default.LABEL_BONUS_HEALING_POWER), desc=L"" }
BonusTypes[GameData.BonusTypes.EBONUS_INTERACT_TIME					] =  { name=GetString( StringTables.Default.LABEL_BONUS_INTERACT_TIME), desc=L"" }
BonusTypes[GameData.BonusTypes.EBONUS_FORTITUDE                     ] =  { name=GetString( StringTables.Default.LABEL_FORTITUDE ), desc=L"" }
BonusTypes[GameData.BonusTypes.EBONUS_OUT_HEAL             ] =  { name=GetString( StringTables.Default.LABEL_BONUS_OUT_HEAL ), desc=L"" }
BonusTypes[GameData.BonusTypes.EBONUS_OUT_DMG_SNAPSHOT            ] =  { name=GetString( StringTables.Default.LABEL_BONUS_OUT_DMG_SNAPSHOT ), desc=L"" }
BonusTypes[GameData.BonusTypes.EBONUS_OUT_HEAL_SNAPSHOT             ] =  { name=GetString( StringTables.Default.LABEL_BONUS_OUT_HEAL_SNAPSHOT ), desc=L"" }
BonusTypes[GameData.BonusTypes.EBONUS_INCOMING_HEAL             ] =  { name=GetString( StringTables.Default.LABEL_BONUS_INCOMING_HEAL ), desc=GetString( StringTables.Default.LABEL_NONE), format=StringTables.Default.LABEL_BONUS_PREFIX_POSITIVE_PERCENT, }
BonusTypes[GameData.BonusTypes.EBONUS_ARMOR_PENETRATION             ] =  { name=GetString( StringTables.Default.LABEL_BONUS_ARMOR_PENETRATION ), desc=L"", format=StringTables.Default.LABEL_BONUS_PREFIX_POSITIVE_PERCENT, }	
BonusTypes[GameData.BonusTypes.EBONUS_CRITICAL_HEAL             ] =  { name=GetString( StringTables.Default.LABEL_BONUS_CRITICAL_HEAL ), desc=L"" }
BonusTypes[GameData.BonusTypes.EBONUS_LOOT_CHANCE             ] =  { name=GetString( StringTables.Default.LABEL_BONUS_LOOT_CHANCE ), desc=GetString( StringTables.Default.LABEL_NONE), format=StringTables.Default.LABEL_BONUS_PREFIX_POSITIVE_PERCENT, }
BonusTypes[GameData.BonusTypes.EBONUS_CASTER_DURATION             ] =  { name=GetString( StringTables.Default.LABEL_BONUS_CASTER_DURATION ), desc=L"" }
-- These bonuses require player info that is not available during startup
-- NOTE: ideally this would show the specialization paths of the career that the item is for, rather than that of the player,
--    but since not all items have a career restriction set, this was considered a reasonable solution by design.
function GameDefs.UpdateSpecBonuses()		
	BonusTypes[GameData.BonusTypes.EBONUS_SPEC_1] =  { name=GetStringFormat(StringTables.Default.LABEL_BONUS_SPEC_X, { GetSpecializationPathName( GameData.Player.SPECIALIZATION_PATH_1 ) }), desc=L"" }
	BonusTypes[GameData.BonusTypes.EBONUS_SPEC_2] =  { name=GetStringFormat(StringTables.Default.LABEL_BONUS_SPEC_X, { GetSpecializationPathName( GameData.Player.SPECIALIZATION_PATH_2 ) }), desc=L"" }
	BonusTypes[GameData.BonusTypes.EBONUS_SPEC_3] =  { name=GetStringFormat(StringTables.Default.LABEL_BONUS_SPEC_X, { GetSpecializationPathName( GameData.Player.SPECIALIZATION_PATH_3 ) }), desc=L"" }
end											

RegisterEventHandler( SystemData.Events.PLAYER_CAREER_LINE_UPDATED, "GameDefs.UpdateSpecBonuses")

-- if we reload the UI, then call this right away. Valid path IDs start at 1.
if GameData.Player.SPECIALIZATION_PATH_3 ~= nil and GameData.Player.SPECIALIZATION_PATH_3 > 0 then
	GameDefs.UpdateSpecBonuses()
end



--[[
    Player statistic names and descriptions...stuff like strength, intelligence, resistances, etc...
--]]
StatInfo = {}
StatInfo[GameData.Stats.NONE]              =  { name=L"",                                                          desc=L"",                                                       skip = true }
StatInfo[GameData.Stats.STRENGTH]          =  { name=GetString( StringTables.Default.LABEL_STRENGTH ),             desc=GetString( StringTables.Default.TEXT_STRENGTH_DESC )                   }
StatInfo[GameData.Stats.AGILITY]           =  { name=GetString( StringTables.Default.LABEL_AGILITY ),              desc=GetString( StringTables.Default.TEXT_AGILITY_DESC ),       skip = true }
StatInfo[GameData.Stats.WILLPOWER]         =  { name=GetString( StringTables.Default.LABEL_WILLPOWER ),            desc=GetString( StringTables.Default.TEXT_WILLPOWER_DESC )                  }
StatInfo[GameData.Stats.TOUGHNESS]         =  { name=GetString( StringTables.Default.LABEL_TOUGHNESS ),            desc=GetString( StringTables.Default.TEXT_TOUGHNESS_DESC )                  }
StatInfo[GameData.Stats.WOUNDS]            =  { name=GetString( StringTables.Default.LABEL_WOUNDS ),               desc=GetString( StringTables.Default.TEXT_WOUNDS_DESC )                     }
StatInfo[GameData.Stats.INITIATIVE]        =  { name=GetString( StringTables.Default.LABEL_INITIATIVE ),           desc=GetString( StringTables.Default.TEXT_INITIATIVE_DESC )                 }
StatInfo[GameData.Stats.WEAPONSKILL]       =  { name=GetString( StringTables.Default.LABEL_WEAPONSKILL_SHORT ),    desc=GetString( StringTables.Default.TEXT_WEAPONSKILL_DESC )                }
StatInfo[GameData.Stats.BALLISTICSKILL]    =  { name=GetString( StringTables.Default.LABEL_BALLISTICSKILL_SHORT ), desc=GetString( StringTables.Default.TEXT_BALLISTICSKILL_DESC )             }
StatInfo[GameData.Stats.INTELLIGENCE]      =  { name=GetString( StringTables.Default.LABEL_INTELLIGENCE ),         desc=GetString( StringTables.Default.TEXT_INTELLIGENCE_DESC )               }
StatInfo[GameData.Stats.BLOCKSKILL]        =  { name=GetString( StringTables.Default.LABEL_BLOCKSKILL ),           desc=L""                                                                    }
StatInfo[GameData.Stats.PARRYSKILL]        =  { name=GetString( StringTables.Default.LABEL_PARRYSKILL ),           desc=L""                                                                    }
StatInfo[GameData.Stats.EVADESKILL]        =  { name=GetString( StringTables.Default.LABEL_EVADESKILL ),           desc=L""                                                                    }
StatInfo[GameData.Stats.DISRUPTSKILL]      =  { name=GetString( StringTables.Default.LABEL_DISRUPTSKILL ),         desc=L""                                                                    }
StatInfo[GameData.Stats.SPIRITRESIST]      =  { name=GetString( StringTables.Default.LABEL_SPIRITRESIST_SHORT ),    desc=GetString( StringTables.Default.TEXT_SPIRITRESIST_DESC )                }       
StatInfo[GameData.Stats.ELEMENTALRESIST]   =  { name=GetString( StringTables.Default.LABEL_ELEMENTALRESIST_SHORT ),   desc=GetString( StringTables.Default.TEXT_ELEMENTALRESIST_DESC )               }       
StatInfo[GameData.Stats.CORPOREALRESIST]   =  { name=GetString( StringTables.Default.LABEL_CORPOREALRESIST_SHORT ),    desc=GetString( StringTables.Default.TEXT_CORPOREALRESIST_DESC )                }         


ItemTypes = {}
ItemTypes[ GameData.ItemTypes.SWORD ]           =  { name=GetString( StringTables.Default.LABEL_ITEM_SWORD ) } 
ItemTypes[ GameData.ItemTypes.AXE ]             =  { name=GetString( StringTables.Default.LABEL_ITEM_AXE ) }
ItemTypes[ GameData.ItemTypes.HAMMER ]          =  { name=GetString( StringTables.Default.LABEL_ITEM_HAMMER ) }
ItemTypes[ GameData.ItemTypes.SHIELD ]			=  { name=GetString( StringTables.Default.LABEL_ITEM_ADV_SHIELD ) }
ItemTypes[ GameData.ItemTypes.ROBE ]            =  { name=GetString( StringTables.Default.LABEL_ITEM_ROBE ) }
ItemTypes[ GameData.ItemTypes.BOW ]             =  { name=GetString( StringTables.Default.LABEL_ITEM_BOW ) }
ItemTypes[ GameData.ItemTypes.GUN ]             =  { name=GetString( StringTables.Default.LABEL_ITEM_GUN ) }
ItemTypes[ GameData.ItemTypes.STAFF ]           =  { name=GetString( StringTables.Default.LABEL_ITEM_STAFF ) }
ItemTypes[ GameData.ItemTypes.DAGGER ]          =  { name=GetString( StringTables.Default.LABEL_ITEM_DAGGER ) }
ItemTypes[ GameData.ItemTypes.SPEAR ]           =  { name=GetString( StringTables.Default.LABEL_ITEM_SPEAR ) }
ItemTypes[ GameData.ItemTypes.PISTOL ]          =  { name=GetString( StringTables.Default.LABEL_ITEM_PISTOL ) }
ItemTypes[ GameData.ItemTypes.LIGHTARMOR ]      =  { name=GetString( StringTables.Default.LABEL_ITEM_LIGHT_ARMOR ) }
ItemTypes[ GameData.ItemTypes.MEDIUMARMOR ]     =  { name=GetString( StringTables.Default.LABEL_ITEM_MEDIUM_ARMOR ) }
ItemTypes[ GameData.ItemTypes.HEAVYARMOR ]      =  { name=GetString( StringTables.Default.LABEL_ITEM_HEAVY_ARMOR ) }
ItemTypes[ GameData.ItemTypes.QUEST ]           =  { name=GetString( StringTables.Default.LABEL_ITEM_QUEST ) }
ItemTypes[ GameData.ItemTypes.MEDIUMROBE ]      =  { name=GetString( StringTables.Default.LABEL_ITEM_MEDIUM_ROBE) }
ItemTypes[ GameData.ItemTypes.ENHANCEMENT ]     =  { name = GetString (StringTables.Default.LABEL_ITEM_ENHANCEMENT) }
ItemTypes[ GameData.ItemTypes.TROPHY ]          =  { name = GetString (StringTables.Default.LABEL_ITEM_TROPHY) }
ItemTypes[ GameData.ItemTypes.CHARM ]           =  { name = GetString (StringTables.Default.LABEL_ITEM_CHARM) }
ItemTypes[ GameData.ItemTypes.DYE ]				=  { name = GetString (StringTables.Default.LABEL_ITEM_DYE) }
ItemTypes[ GameData.ItemTypes.POTION ]          =  { name = GetString (StringTables.Default.LABEL_ITEM_POTION) }
ItemTypes[ GameData.ItemTypes.SALVAGING ]       =  { name = GetString (StringTables.Default.LABEL_ITEM_SALVAGING) }
ItemTypes[ GameData.ItemTypes.MARKETING ]       =  { name = GetString (StringTables.Default.LABEL_ITEM_MARKETING) }
ItemTypes[ GameData.ItemTypes.CRAFTING ]        =  { name = GetString (StringTables.Default.LABEL_ITEM_CRAFTING) }
ItemTypes[ GameData.ItemTypes.ACCESSORY ]       =  { name = GetString (StringTables.Default.LABEL_ITEM_ACCESSORY) }
ItemTypes[ GameData.ItemTypes.SIEGE ]           =  { name = GetString (StringTables.Default.LABEL_ITEM_SIEGE) }

 
-- Career Names and Identifiers

-- NOTE: Always using the male variant of the career name for naming purposes 
-- (at least until someone yells about it...)
CareerNames = {}

for _, careerId in pairs(GameData.CareerLine)
do
    CareerNames[careerId] = { name = GetStringFromTable("CareerLinesMale", careerId) }
end

-- RaceNames
RaceNames = {}
RaceNames[1] = { name = GetPregameString (StringTables.Pregame.RACE_DWARF) }
RaceNames[2] = { name = GetPregameString (StringTables.Pregame.RACE_ORC) }  -- yes, these two are wrong!!
RaceNames[3] = { name = GetPregameString (StringTables.Pregame.RACE_GOBLIN) }
RaceNames[4] = { name = GetPregameString (StringTables.Pregame.RACE_ELVES) }
RaceNames[5] = { name = GetPregameString (StringTables.Pregame.RACE_DARK_ELVES) }
RaceNames[6] = { name = GetPregameString (StringTables.Pregame.RACE_EMPIRE) }
RaceNames[7] = { name = GetPregameString (StringTables.Pregame.RACE_CHAOS) }

-- Skill Types (NOTE: These are NOT the same as item types)

SkillTypes = {}
SkillTypes[GameData.SkillType.SWORD]              = { name = GetString (StringTables.Default.LABEL_ITEM_SWORD),             icon = 192 } 
SkillTypes[GameData.SkillType.AXE]                = { name = GetString (StringTables.Default.LABEL_ITEM_AXE),               icon = 171 }
SkillTypes[GameData.SkillType.HAMMER]             = { name = GetString (StringTables.Default.LABEL_ITEM_HAMMER),            icon = 181 }
SkillTypes[GameData.SkillType.BASIC_SHIELD]       = { name = GetString (StringTables.Default.LABEL_ITEM_BASIC_SHIELD),      icon = 173 }
SkillTypes[GameData.SkillType.ADVANCED_SHIELD]    = { name = GetString (StringTables.Default.LABEL_ITEM_ADV_SHIELD),        icon = 170 }
SkillTypes[GameData.SkillType.ROBE]               = { name = GetString (StringTables.Default.LABEL_ITEM_ROBE),              icon = 189 }
SkillTypes[GameData.SkillType.BOW]                = { name = GetString (StringTables.Default.LABEL_ITEM_BOW),               icon = 174 }
SkillTypes[GameData.SkillType.CROSSBOW]           = { name = GetString (StringTables.Default.LABEL_ITEM_CROSS_BOW),         icon = 194 }
SkillTypes[GameData.SkillType.GUN]                = { name = GetString (StringTables.Default.LABEL_ITEM_GUN),               icon = 180 }
SkillTypes[GameData.SkillType.EXPERT_SHIELD]      = { name = GetString (StringTables.Default.LABEL_ITEM_EXPERT_SHIELD),     icon = 178 }
SkillTypes[GameData.SkillType.STAFF]              = { name = GetString (StringTables.Default.LABEL_ITEM_STAFF),             icon = 191 }
SkillTypes[GameData.SkillType.DAGGER]             = { name = GetString (StringTables.Default.LABEL_ITEM_DAGGER),            icon = 176 }
SkillTypes[GameData.SkillType.THROWN]             = { name = GetString (StringTables.Default.LABEL_ITEM_THROWN),            icon = 193 }
SkillTypes[GameData.SkillType.SPEAR]              = { name = GetString (StringTables.Default.LABEL_ITEM_SPEAR),             icon = 190 }
SkillTypes[GameData.SkillType.PISTOL]             = { name = GetString (StringTables.Default.LABEL_ITEM_PISTOL),            icon = 187 }
SkillTypes[GameData.SkillType.LANCE]              = { name = GetString (StringTables.Default.LABEL_ITEM_LANCE),             icon = 183 }
SkillTypes[GameData.SkillType.REPEATING_CROSSBOW] = { name = GetString (StringTables.Default.LABEL_ITEM_REP_CROSS_BOW),     icon = 188 }
SkillTypes[GameData.SkillType.LIGHT_ARMOR]        = { name = GetString (StringTables.Default.LABEL_ITEM_LIGHT_ARMOR),       icon = 184 }
SkillTypes[GameData.SkillType.MEDIUM_ARMOR]       = { name = GetString (StringTables.Default.LABEL_ITEM_MEDIUM_ARMOR),      icon = 185 }
SkillTypes[GameData.SkillType.HEAVY_ARMOR]        = { name = GetString (StringTables.Default.LABEL_ITEM_HEAVY_ARMOR),       icon = 182 }
SkillTypes[GameData.SkillType.DUAL_WIELD]         = { name = GetString (StringTables.Default.LABEL_ITEM_DUAL_WIELD),        icon = 177 }
SkillTypes[GameData.SkillType.GREAT_WEAPONS]      = { name = GetString (StringTables.Default.LABEL_ITEM_GREAT_WEAPONS),     icon = 179 }
SkillTypes[GameData.SkillType.MEDIUM_ROBE]        = { name = GetString (StringTables.Default.LABEL_ITEM_MEDIUM_ROBE),       icon = 186 }
SkillTypes[GameData.SkillType.CHARM]              = { name = GetString (StringTables.Default.LABEL_ITEM_CHARM),             icon = 175 }
SkillTypes[GameData.SkillType.BASIC_RIDING]       = { name = GetString (StringTables.Default.LABEL_ITEM_BASIC_RIDING),      icon = 172 }
SkillTypes[GameData.SkillType.ADVANCED_RIDING]    = { name = GetString (StringTables.Default.LABEL_ITEM_ADVANCED_RIDING),   icon = 169 }
SkillTypes[GameData.SkillType.SHOOT_ON_THE_MOVE]  = { name = GetString (StringTables.Default.LABEL_ITEM_SHOOT_ON_THE_MOVE),     icon = 174 }

-- Target Info

GameDefs.CON_COLORS = { }
GameDefs.CON_COLORS[GameData.ConType.NO_LEVEL]    = { r=155,   g=155,  b=155 }
GameDefs.CON_COLORS[GameData.ConType.TRIVIAL]     = { r=166,   g=168,  b=173 }
GameDefs.CON_COLORS[GameData.ConType.EFFORTLESS]  = { r=56,    g=225,  b=99  }
GameDefs.CON_COLORS[GameData.ConType.EASY]        = { r=59,    g=160,  b=231 }
GameDefs.CON_COLORS[GameData.ConType.EQUAL]       = { r=255,   g=255,  b=255 }
GameDefs.CON_COLORS[GameData.ConType.CHALLENGING] = { r=244,   g=199,  b=43  }
GameDefs.CON_COLORS[GameData.ConType.DANGEROUS]   = { r=246,   g=70,   b=36  }
GameDefs.CON_COLORS[GameData.ConType.DEADLY]      = { r=240,   g=62,   b=217 }
GameDefs.CON_COLORS[GameData.ConType.FRIENDLY]    = { r=0,     g=178,  b=255 }

GameDefs.CON_DESCS = {}
GameDefs.CON_DESCS[GameData.ConType.NO_LEVEL]    =  L""
GameDefs.CON_DESCS[GameData.ConType.TRIVIAL]     =  GetString( StringTables.Default.LABEL_CON_TRIVIAL )
GameDefs.CON_DESCS[GameData.ConType.EFFORTLESS]  =  GetString( StringTables.Default.LABEL_CON_EFFORTLESS )
GameDefs.CON_DESCS[GameData.ConType.EASY]        =  GetString( StringTables.Default.LABEL_CON_EASY )
GameDefs.CON_DESCS[GameData.ConType.EQUAL]       =  GetString( StringTables.Default.LABEL_CON_EQUAL )
GameDefs.CON_DESCS[GameData.ConType.CHALLENGING] =  GetString( StringTables.Default.LABEL_CON_CHALLENGING )
GameDefs.CON_DESCS[GameData.ConType.DANGEROUS]   =  GetString( StringTables.Default.LABEL_CON_DANGEROUS )
GameDefs.CON_DESCS[GameData.ConType.DEADLY]      =  GetString( StringTables.Default.LABEL_CON_DEADLY )
GameDefs.CON_DESCS[GameData.ConType.FRIENDLY]    =  L""

GameDefs.TIER_NAMES = {}
GameDefs.TIER_NAMES[ 0 ] = L""
GameDefs.TIER_NAMES[ 1 ] = GetString( StringTables.Default.LABEL_MONSTER_TIER_CHAMPION )
GameDefs.TIER_NAMES[ 2 ] = GetString( StringTables.Default.LABEL_MONSTER_TIER_HERO )
GameDefs.TIER_NAMES[ 3 ] = GetString( StringTables.Default.LABEL_MONSTER_TIER_LORD )


-- Quest Defs
GameDefs.CompleteCounterColor = { r=255, g=170, b=0} 
GameDefs.IncompleteCounterColor = { r=235, g=235, b=235 }
GameDefs.CompleteQuestTitleColor = GameDefs.CompleteCounterColor 
GameDefs.IncompleteQuestTitleColor = { r=222, g=192, b=50 } 

-- Tome Icons
GameDefs.TomeSectionIcons = {}
GameDefs.TomeSectionIcons[GameData.Tome.SECTION_WAR_JOURNAL]        = { small="MiniSection-Chapters", large="SectionSymbolChapters" }
GameDefs.TomeSectionIcons[GameData.Tome.SECTION_ZONE_MAPS]          = { small="MiniSection-Map", large="SectionSymbolMap" }
GameDefs.TomeSectionIcons[GameData.Tome.SECTION_BESTIARY]           = { small="MiniSection-Bestiary", large="SectionSymbolBestiary" }
GameDefs.TomeSectionIcons[GameData.Tome.SECTION_HISTORY_AND_LORE]   = { small="MiniSection-Lore", large="SectionSymbolLore" }
GameDefs.TomeSectionIcons[GameData.Tome.SECTION_NOTEWORTHY_PERSONS] = { small="MiniSection-Lore", large="SectionSymbolLore" }
GameDefs.TomeSectionIcons[GameData.Tome.SECTION_GAME_MANUAL]        = { small=nil, large=nil }
GameDefs.TomeSectionIcons[GameData.Tome.SECTION_PLAYER_TITLES]      = { small="MiniSection-Rewards", large="SectionSymbolRewards" }
GameDefs.TomeSectionIcons[GameData.Tome.SECTION_ACHIEVEMENTS]       = { small="MiniSection-Achievements", large="SectionSymbolAchievements" }
GameDefs.TomeSectionIcons[GameData.Tome.SECTION_OLD_WORLD_ARMORY]   = { small="MiniSection-Armory", large="SectionSymbolArmory" }
GameDefs.TomeSectionIcons[GameData.Tome.SECTION_ARMORY_SIGILS]      = { small="MiniSection-Armory", large="SectionSymbolArmory" }
GameDefs.TomeSectionIcons[GameData.Tome.SECTION_TACTICS]            = { small="MiniSection-Rewards", large="SectionSymbolRewards" }
GameDefs.TomeSectionIcons[GameData.Tome.SECTION_LIVE_EVENT]         = { small=nil, large="NewEventsAlertSymbol" }

GameDefs.TomeSectionNames = {}
GameDefs.TomeSectionNames[GameData.Tome.SECTION_WAR_JOURNAL]        = GetString( StringTables.Default.LABEL_WAR_JOURNAL )
GameDefs.TomeSectionNames[GameData.Tome.SECTION_ZONE_MAPS]          = GetString( StringTables.Default.LABEL_WORLD_MAP )
GameDefs.TomeSectionNames[GameData.Tome.SECTION_BESTIARY]           = GetString( StringTables.Default.LABEL_BESTIARY )
GameDefs.TomeSectionNames[GameData.Tome.SECTION_HISTORY_AND_LORE]   = GetString( StringTables.Default.LABEL_HISTORY_AND_LORE )
GameDefs.TomeSectionNames[GameData.Tome.SECTION_NOTEWORTHY_PERSONS] = GetString( StringTables.Default.LABEL_NOTEWORTHY_PERSONS )
GameDefs.TomeSectionNames[GameData.Tome.SECTION_GAME_MANUAL]        = GetString( StringTables.Default.LABEL_GAME_MANUAL )
GameDefs.TomeSectionNames[GameData.Tome.SECTION_PLAYER_TITLES]      = GetString( StringTables.Default.LABEL_TITLES )
GameDefs.TomeSectionNames[GameData.Tome.SECTION_ACHIEVEMENTS]       = GetString( StringTables.Default.LABEL_ACHIEVEMENTS )
GameDefs.TomeSectionNames[GameData.Tome.SECTION_OLD_WORLD_ARMORY]   = GetString( StringTables.Default.LABEL_OLD_WORLD_ARMORY )
GameDefs.TomeSectionNames[GameData.Tome.SECTION_ARMORY_SIGILS]      = GetString( StringTables.Default.LABEL_SIGILS )
GameDefs.TomeSectionNames[GameData.Tome.SECTION_TACTICS]            = GetString( StringTables.Default.LABEL_TACTICS )
GameDefs.TomeSectionNames[GameData.Tome.SECTION_LIVE_EVENT]         = GetStringFromTable( "LiveEventStrings", StringTables.LiveEventStrings.LABEL_LIVE_EVENT )

-- Icons
GameDefs.Icons = {}
GameDefs.Icons.ICON_XP_REWARD       = 35
GameDefs.Icons.ICON_GOLD_REWARD     = 34
GameDefs.Icons.ICON_TITLE_REWARD    = 5182 -- Arbitrary #
GameDefs.Icons.ICON_QUEST_REWARD    = 101 -- Arbitrary #
GameDefs.Icons.ICON_TACTIC_REWARD   = 147

-- Maps
GameDefs.MapLevel = {}
GameDefs.MapLevel.WORLD_MAP      = SystemData.MapLevel.WORLD
GameDefs.MapLevel.PAIRING_MAP    = SystemData.MapLevel.PAIRING
GameDefs.MapLevel.ZONE_MAP       = SystemData.MapLevel.ZONE
GameDefs.MapLevel.AREA_MAP       = SystemData.MapLevel.AREA
GameDefs.MapLevel.NUM_MODES      = 4

-- City Zones
GameDefs.ZoneCityIds =
{
	[62]	= GameData.CityId.DWARF,		-- Peaceful  
	[97]	= GameData.CityId.DWARF,		-- Peaceful  
	[61]	= GameData.CityId.GREENSKIN,	-- Peaceful  
	[96]	= GameData.CityId.GREENSKIN,	-- Peaceful  
    [162]	= GameData.CityId.EMPIRE,		-- Peaceful    
    [168]	= GameData.CityId.EMPIRE,		-- Contested
    [161]	= GameData.CityId.CHAOS,		-- Peaceful
    [167]	= GameData.CityId.CHAOS,		-- Contested
}

GameDefs.PeacefulCityZoneIDs =
{
	[62]	= GameData.CityId.DWARF,		-- Peaceful  
	[97]	= GameData.CityId.DWARF,		-- Peaceful  
	[61]	= GameData.CityId.GREENSKIN,	-- Peaceful  
	[96]	= GameData.CityId.GREENSKIN,	-- Peaceful  
    [162]	= GameData.CityId.EMPIRE,		-- Peaceful    
    [161]	= GameData.CityId.CHAOS,		-- Peaceful
}

GameDefs.GuildHallCityMap =
{
    [198] = GameData.CityId.EMPIRE, -- Order Guild Hall - Sigmar's Hammer
    [178] = GameData.CityId.CHAOS,  -- Destruction Guild Hall - The Viper Pit
}

GameDefs.NUM_CITY_RANKS = 5

-- Siege Objects
GameDefs.SiegeObjectStateNames = {}
GameDefs.SiegeObjectStateNames[GameData.SiegeObjectState.EMPTY]        = GetStringFromTable( "SiegeStrings", StringTables.Siege.LABEL_STATE_EMPTY )
GameDefs.SiegeObjectStateNames[GameData.SiegeObjectState.BUILDING]          = GetStringFromTable( "SiegeStrings", StringTables.Siege.LABEL_STATE_BUILDING )
GameDefs.SiegeObjectStateNames[GameData.SiegeObjectState.READY]           = GetStringFromTable( "SiegeStrings", StringTables.Siege.LABEL_STATE_READY )
GameDefs.SiegeObjectStateNames[GameData.SiegeObjectState.IN_USE]   = GetStringFromTable( "SiegeStrings", StringTables.Siege.LABEL_STATE_IN_USE )
GameDefs.SiegeObjectStateNames[GameData.SiegeObjectState.REPAIRING] = GetStringFromTable( "SiegeStrings", StringTables.Siege.LABEL_STATE_REPAIRING )
GameDefs.SiegeObjectStateNames[GameData.SiegeObjectState.DESTROYED]        = GetStringFromTable( "SiegeStrings", StringTables.Siege.LABEL_STATE_DESTROYED )

-- Reserved Hotbar Slot Ids
-- By convention, WAR uses the last hotbar to store granted, stance, and morale abilities
GameDefs.TOTAL_HOTBAR_COUNT             = GameData.HOTBAR_TOTAL_SLOT_COUNT / GameData.HOTBAR_BUTTONS_PER_BAR
GameDefs.HOTBAR_SWAPPABLE_SLOT_COUNT    = GameData.HOTBAR_SWAPPABLE_PAGE_COUNT * GameData.HOTBAR_BUTTONS_PER_BAR
GameDefs.GRANTED_ABILITY_HOTBAR_ID      = GameDefs.TOTAL_HOTBAR_COUNT - 1
GameDefs.STANCE_ABILITY_HOTBAR_ID       = GameDefs.TOTAL_HOTBAR_COUNT - 1
GameDefs.FIRST_GRANTED_ABILITY_SLOT     = GameData.HOTBAR_TOTAL_SLOT_COUNT - (GameData.HOTBAR_BUTTONS_PER_BAR * 2)
GameDefs.LAST_GRANTED_ABILITY_SLOT      = GameDefs.FIRST_GRANTED_ABILITY_SLOT + 5
GameDefs.FIRST_STANCE_ABILITY_SLOT      = GameDefs.LAST_GRANTED_ABILITY_SLOT + 1
GameDefs.LAST_STANCE_ABILITY_SLOT       = GameDefs.FIRST_STANCE_ABILITY_SLOT + 4
GameDefs.PET_HOTBAR_ID                  = GameDefs.TOTAL_HOTBAR_COUNT - 2
GameDefs.FIRST_PET_ABILITY_SLOT         = ((GameDefs.PET_HOTBAR_ID - 1) * GameData.HOTBAR_BUTTONS_PER_BAR) + 1
GameDefs.LAST_PET_ABILITY_SLOT          = GameDefs.FIRST_PET_ABILITY_SLOT + 6
