MORALE_BAR_NAME                     = "EA_MoraleBar"
ACTION_BAR_NAME                     = "EA_ActionBar"
LEFT_CAP_NAME                       = ACTION_BAR_NAME.."1".."LeftCap"
RIGHT_CAP_NAME                      = ACTION_BAR_NAME.."1".."RightCap"
GRANTED_ABILITY_BAR_NAME            = "EA_GrantedAbilities"
STANCE_ABILITY_BAR_NAME             = "EA_StanceBar"
PET_STANCE_BAR_NAME                 = "EA_CareerResourceWindowActionBar"
CAST_BAR_NAME                       = "LayerTimerWindow"
CAREER_WINDOW_NAME                  = "EA_CareerResourceWindow"
QUICK_LOCK_NAME                     = "ActionBarLockToggler"    -- Under no circumstances should this ever share a prefix with ACTION_BAR_NAME
TACTICS_WINDOW_NAME                 = "EA_TacticsEditor"

CREATED_HOTBAR_COUNT                = 5

LAYOUT_MODE_FIRST_LAYOUT            = 1
LAYOUT_MODE_1_ACTION_BAR            = LAYOUT_MODE_FIRST_LAYOUT            
LAYOUT_MODE_2_ACTION_BARS           = 2
LAYOUT_MODE_2_ACTION_BARS_STACKED   = 3
LAYOUT_MODE_3_ACTION_BARS           = 4
LAYOUT_MODE_4_ACTION_BARS           = 5
LAYOUT_MODE_5_ACTION_BARS           = 6
LAYOUT_MODE_LAST_LAYOUT             = LAYOUT_MODE_5_ACTION_BARS

LAYOUT_MODE_TO_NUM_BARS_SHOWING =
{
    [LAYOUT_MODE_1_ACTION_BAR]          = 1,
    [LAYOUT_MODE_2_ACTION_BARS]         = 2,
    [LAYOUT_MODE_2_ACTION_BARS_STACKED] = 2,
    [LAYOUT_MODE_3_ACTION_BARS]         = 3,
    [LAYOUT_MODE_4_ACTION_BARS]         = 4,
    [LAYOUT_MODE_5_ACTION_BARS]         = 5
}

ClusterAnchorPoints =
{
    [LAYOUT_MODE_1_ACTION_BAR] =                -- Bar1
    {
        [ACTION_BAR_NAME.."1"]                  = { Point = "bottom",       RelativePoint = "bottom",       RelativeTo = "Root",                XOffset = 11,   YOffset = 0,    },
        [QUICK_LOCK_NAME]                       = { Point = "topleft",      RelativePoint = "topright",     RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = 0,    },
        [MORALE_BAR_NAME]                       = { Point = "bottomright",  RelativePoint = "bottomright",  RelativeTo = "Root",                XOffset = -16,  YOffset = 0,    },
        [TACTICS_WINDOW_NAME]                   = { Point = "bottomleft",   RelativePoint = "bottomleft",   RelativeTo = "Root",                XOffset = 5,    YOffset = 0,    },
        [GRANTED_ABILITY_BAR_NAME]              = { Point = "top",          RelativePoint = "bottomleft",   RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 110,  YOffset = -12,  },
        [STANCE_ABILITY_BAR_NAME]               = { Point = "topleft",      RelativePoint = "bottomleft",   RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = -12,  },
        [PET_STANCE_BAR_NAME]                   = { Point = "left",         RelativePoint = "right",        RelativeTo = CAREER_WINDOW_NAME,    XOffset = -4,   YOffset = 10,   },
        [CAST_BAR_NAME]                         = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = -80,  },
        [LEFT_CAP_NAME]                         = { Point = "bottomleft",   RelativePoint = "bottomright",  RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = 0,    },
        [RIGHT_CAP_NAME]                        = { Point = "bottomright",  RelativePoint = "bottomleft",   RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = 0,    },
        [GameData.CareerLine.WITCH_ELF]         = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.ARCHMAGE]          = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.BLACK_ORC]         = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.DISCIPLE]          = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.BRIGHT_WIZARD]     = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.CHOPPA]		    = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.ENGINEER]          = { Point = "top",          RelativePoint = "bottomright",  RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -112, YOffset = 0,    },
        [GameData.CareerLine.SLAYER]		    = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.IRON_BREAKER]      = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.MAGUS]             = { Point = "top",          RelativePoint = "bottomright",  RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 28,   YOffset = 0,    },
        [GameData.CareerLine.WHITE_LION]        = { Point = "top",          RelativePoint = "bottomright",  RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 28,   YOffset = 0,    },
        [GameData.CareerLine.BLACKGUARD]        = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -12,  YOffset = -13,  },
        [GameData.CareerLine.SHAMAN]            = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.SORCERER]          = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.SQUIG_HERDER]      = { Point = "top",          RelativePoint = "bottomright",  RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 94,   YOffset = 0,    },
        [GameData.CareerLine.SWORDMASTER]       = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.WARRIOR_PRIEST]    = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.WITCH_HUNTER]      = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 9,    },
    },
    
    [LAYOUT_MODE_2_ACTION_BARS] =               -- Bar1  Bar2
    {
        [ACTION_BAR_NAME.."1"]                  = { Point = "bottom",       RelativePoint = "bottomright",  RelativeTo = "Root",                XOffset = 0,    YOffset = 0,    },
        [QUICK_LOCK_NAME]                       = { Point = "topleft",      RelativePoint = "bottomleft",   RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = 0,    },
        [ACTION_BAR_NAME.."2"]                  = { Point = "bottomright",  RelativePoint = "bottomleft",   RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = 0,    },
        [MORALE_BAR_NAME]                       = { Point = "topright",     RelativePoint = "bottomright",  RelativeTo = ACTION_BAR_NAME.."2",  XOffset = -16,  YOffset = 0,    },
        [TACTICS_WINDOW_NAME]                   = { Point = "topleft",      RelativePoint = "bottomleft",   RelativeTo = ACTION_BAR_NAME.."1",  XOffset =  20,  YOffset = 0,    },
        [GRANTED_ABILITY_BAR_NAME]              = { Point = "topleft",      RelativePoint = "bottomleft",   RelativeTo = ACTION_BAR_NAME.."2",  XOffset = 125,  YOffset = -12,  },
        [STANCE_ABILITY_BAR_NAME]               = { Point = "top",          RelativePoint = "bottomleft",   RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = -12,  },
        [PET_STANCE_BAR_NAME]                   = { Point = "left",         RelativePoint = "right",        RelativeTo = CAREER_WINDOW_NAME,    XOffset = -2,   YOffset = 12,   },
        [CAST_BAR_NAME]                         = { Point = "topright",     RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = -80,  },
        [LEFT_CAP_NAME]                         = { Point = "bottomleft",   RelativePoint = "bottomright",  RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = 0,    },
        [RIGHT_CAP_NAME]                        = { Point = "bottomright",  RelativePoint = "bottomleft",   RelativeTo = ACTION_BAR_NAME.."2",  XOffset = 0,    YOffset = 0,    },
        [GameData.CareerLine.WITCH_ELF]         = { Point = "topright",     RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = 0,    },
        [GameData.CareerLine.ARCHMAGE]          = { Point = "topright",     RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = 0,    },
        [GameData.CareerLine.BLACK_ORC]         = { Point = "topright",     RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = 0,    },
        [GameData.CareerLine.DISCIPLE]          = { Point = "topright",     RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = 0,    },
        [GameData.CareerLine.BRIGHT_WIZARD]     = { Point = "topright",     RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = 0,    },
        [GameData.CareerLine.CHOPPA]			= { Point = "topright",     RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = 0,    },
        [GameData.CareerLine.ENGINEER]          = { Point = "topright",     RelativePoint = "bottomright",  RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 135,  YOffset = 0,    },
        [GameData.CareerLine.SLAYER]			= { Point = "topright",     RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = 0,    },
        [GameData.CareerLine.IRON_BREAKER]      = { Point = "topright",     RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = 0,    },
        [GameData.CareerLine.MAGUS]             = { Point = "topright",     RelativePoint = "bottomright",  RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 123,  YOffset = 0,    },
        [GameData.CareerLine.WHITE_LION]        = { Point = "topright",     RelativePoint = "bottomright",  RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 123,  YOffset = 0,    },
        [GameData.CareerLine.BLACKGUARD]        = { Point = "topright",     RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = -13,  },
        [GameData.CareerLine.SHAMAN]            = { Point = "topright",     RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -1,   YOffset = 0,    },
        [GameData.CareerLine.SORCERER]          = { Point = "topright",     RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = 0,    },
        [GameData.CareerLine.SQUIG_HERDER]      = { Point = "topright",     RelativePoint = "bottomright",  RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 95,   YOffset = 0,    },
        [GameData.CareerLine.SWORDMASTER]       = { Point = "topright",     RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = 0,    },
        [GameData.CareerLine.WARRIOR_PRIEST]    = { Point = "topright",     RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = 0,    },
        [GameData.CareerLine.WITCH_HUNTER]      = { Point = "topright",     RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = 9,    },
    },
    
    [LAYOUT_MODE_2_ACTION_BARS_STACKED] =       -- Bar1 
    {                                           -- Bar2
        [ACTION_BAR_NAME.."2"]                  = { Point = "bottom",       RelativePoint = "bottom",       RelativeTo = "Root",                XOffset = 11,   YOffset = 0,    },
        [ACTION_BAR_NAME.."1"]                  = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."2",  XOffset = 0,    YOffset = 0,    },
        [QUICK_LOCK_NAME]                       = { Point = "topleft",      RelativePoint = "topright",     RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = 0,    },
        [MORALE_BAR_NAME]                       = { Point = "bottomright",  RelativePoint = "bottomright",  RelativeTo = "Root",                XOffset = -16,  YOffset = 0,    },
        [TACTICS_WINDOW_NAME]                   = { Point = "bottomleft",   RelativePoint = "bottomleft",   RelativeTo = "Root",                XOffset = 5,    YOffset = 0,    },
        [GRANTED_ABILITY_BAR_NAME]              = { Point = "top",          RelativePoint = "bottomleft",   RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 108,  YOffset = -12,  },
        [STANCE_ABILITY_BAR_NAME]               = { Point = "topleft",      RelativePoint = "bottomleft",   RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = -12,  },
        [PET_STANCE_BAR_NAME]                   = { Point = "left",         RelativePoint = "right",        RelativeTo = CAREER_WINDOW_NAME,    XOffset = -4,   YOffset = 10,   },
        [CAST_BAR_NAME]                         = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = -80,  },
        [LEFT_CAP_NAME]                         = { Point = "bottomleft",   RelativePoint = "bottomright",  RelativeTo = ACTION_BAR_NAME.."2",  XOffset = 0,    YOffset = 0,    },
        [RIGHT_CAP_NAME]                        = { Point = "bottomright",  RelativePoint = "bottomleft",   RelativeTo = ACTION_BAR_NAME.."2",  XOffset = 0,    YOffset = 0,    },
        [GameData.CareerLine.WITCH_ELF]         = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.ARCHMAGE]          = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.BLACK_ORC]         = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.DISCIPLE]          = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.BRIGHT_WIZARD]     = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.CHOPPA]			= { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.ENGINEER]          = { Point = "top",          RelativePoint = "bottomright",  RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -112, YOffset = 0,    },
        [GameData.CareerLine.SLAYER]			= { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.IRON_BREAKER]      = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.MAGUS]             = { Point = "top",          RelativePoint = "bottomright",  RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 28,   YOffset = 0,    },
        [GameData.CareerLine.WHITE_LION]        = { Point = "top",          RelativePoint = "bottomright",  RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 28,   YOffset = 0,    },
        [GameData.CareerLine.BLACKGUARD]        = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -12,  YOffset = -13,  },
        [GameData.CareerLine.SHAMAN]            = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.SORCERER]          = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.SQUIG_HERDER]      = { Point = "top",          RelativePoint = "bottomright",  RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 94,   YOffset = 0,    },
        [GameData.CareerLine.SWORDMASTER]       = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.WARRIOR_PRIEST]    = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.WITCH_HUNTER]      = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 9,    },
    },
    
    [LAYOUT_MODE_3_ACTION_BARS] =               --    Bar1
    {                                           -- Bar3  Bar2
        [ACTION_BAR_NAME.."1"]                  = { Point = "bottom",       RelativePoint = "bottom",       RelativeTo = "Root",                XOffset = 0,    YOffset = -68  },
        [ACTION_BAR_NAME.."2"]                  = { Point = "bottom",       RelativePoint = "topright",     RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = 0     },
        [ACTION_BAR_NAME.."3"]                  = { Point = "bottom",       RelativePoint = "topleft",      RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = 0     },
        [QUICK_LOCK_NAME]                       = { Point = "topleft",      RelativePoint = "bottomleft",   RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = 0,    },
        [MORALE_BAR_NAME]                       = { Point = "topright",     RelativePoint = "bottomright",  RelativeTo = ACTION_BAR_NAME.."3",  XOffset = 0,    YOffset = 0     },
        [GRANTED_ABILITY_BAR_NAME]              = { Point = "topleft",      RelativePoint = "bottomleft",   RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 20,   YOffset = 0,    },
        [TACTICS_WINDOW_NAME]                   = { Point = "topleft",      RelativePoint = "bottomleft",   RelativeTo = ACTION_BAR_NAME.."2",  XOffset = 0,    YOffset = 0     },
        [STANCE_ABILITY_BAR_NAME]               = { Point = "top",          RelativePoint = "bottomleft",   RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = -12,  },
        [PET_STANCE_BAR_NAME]                   = { Point = "left",         RelativePoint = "right",        RelativeTo = CAREER_WINDOW_NAME,    XOffset = -4,   YOffset = 10,   },
        [CAST_BAR_NAME]                         = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = -80   },
        [LEFT_CAP_NAME]                         = { Point = "bottomleft",   RelativePoint = "bottomright",  RelativeTo = ACTION_BAR_NAME.."2",  XOffset = 0,    YOffset = 0     },
        [RIGHT_CAP_NAME]                        = { Point = "bottomright",  RelativePoint = "bottomleft",   RelativeTo = ACTION_BAR_NAME.."3",  XOffset = 0,    YOffset = 0     },
        [GameData.CareerLine.WITCH_ELF]         = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.ARCHMAGE]          = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.BLACK_ORC]         = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.DISCIPLE]          = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.BRIGHT_WIZARD]     = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.CHOPPA]		    = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.ENGINEER]          = { Point = "top",          RelativePoint = "bottomright",  RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -112, YOffset = 0,    },
        [GameData.CareerLine.SLAYER]		    = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.IRON_BREAKER]      = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.MAGUS]             = { Point = "top",          RelativePoint = "bottomright",  RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 28,   YOffset = 0,    },
        [GameData.CareerLine.WHITE_LION]        = { Point = "top",          RelativePoint = "bottomright",  RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 28,   YOffset = 0,    },
        [GameData.CareerLine.BLACKGUARD]        = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -12,  YOffset = -13,  },
        [GameData.CareerLine.SHAMAN]            = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.SORCERER]          = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.SQUIG_HERDER]      = { Point = "top",          RelativePoint = "bottomright",  RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 94,   YOffset = 0,    },
        [GameData.CareerLine.SWORDMASTER]       = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.WARRIOR_PRIEST]    = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.WITCH_HUNTER]      = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 9,    },
    },
    
    [LAYOUT_MODE_4_ACTION_BARS] =               -- Bar1  Bar2
    {                                           -- Bar3  Bar4
        [ACTION_BAR_NAME.."1"]                  = { Point = "bottom",       RelativePoint = "bottomright",  RelativeTo = "Root",                XOffset = 0,    YOffset = -68,  },
        [ACTION_BAR_NAME.."2"]                  = { Point = "bottomright",  RelativePoint = "bottomleft",   RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = 0,    },
        [ACTION_BAR_NAME.."3"]                  = { Point = "bottom",       RelativePoint = "bottomright",  RelativeTo = "Root",                XOffset = 0,    YOffset = 0,    },
        [ACTION_BAR_NAME.."4"]                  = { Point = "bottomright",  RelativePoint = "bottomleft",   RelativeTo = ACTION_BAR_NAME.."3",  XOffset = 0,    YOffset = 0,    },
        [QUICK_LOCK_NAME]                       = { Point = "topleft",      RelativePoint = "bottomleft",   RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = 0,    },
        [MORALE_BAR_NAME]                       = { Point = "topright",     RelativePoint = "bottomright",  RelativeTo = ACTION_BAR_NAME.."2",  XOffset = -16,  YOffset = 0,    },
        [TACTICS_WINDOW_NAME]                   = { Point = "topleft",      RelativePoint = "bottomleft",   RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 20,   YOffset = 0,    },
        [GRANTED_ABILITY_BAR_NAME]              = { Point = "topleft",      RelativePoint = "bottomleft",   RelativeTo = ACTION_BAR_NAME.."2",  XOffset = 125,  YOffset = -12,  },
        [STANCE_ABILITY_BAR_NAME]               = { Point = "top",          RelativePoint = "bottomleft",   RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = -12,  },
        [PET_STANCE_BAR_NAME]                   = { Point = "left",         RelativePoint = "right",        RelativeTo = CAREER_WINDOW_NAME,    XOffset = -4,   YOffset = 10,   },
        [CAST_BAR_NAME]                         = { Point = "topright",     RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = -100, },
        [LEFT_CAP_NAME]                         = { Point = "bottomleft",   RelativePoint = "bottomright",  RelativeTo = ACTION_BAR_NAME.."3",  XOffset = 0,    YOffset = 0,    },
        [RIGHT_CAP_NAME]                        = { Point = "bottomright",  RelativePoint = "bottomleft",   RelativeTo = ACTION_BAR_NAME.."4",  XOffset = 0,    YOffset = 0,    },
        [GameData.CareerLine.WITCH_ELF]         = { Point = "topright",     RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = 0,    },
        [GameData.CareerLine.ARCHMAGE]          = { Point = "topright",     RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = 0,    },
        [GameData.CareerLine.BLACK_ORC]         = { Point = "topright",     RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = 0,    },
        [GameData.CareerLine.DISCIPLE]          = { Point = "topright",     RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = 0,    },
        [GameData.CareerLine.BRIGHT_WIZARD]     = { Point = "topright",     RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = 0,    },
        [GameData.CareerLine.CHOPPA]			= { Point = "topright",     RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = 0,    },
        [GameData.CareerLine.ENGINEER]          = { Point = "topright",     RelativePoint = "bottomright",  RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 112,  YOffset = 0,    },
        [GameData.CareerLine.SLAYER]			= { Point = "topright",     RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = 0,    },
        [GameData.CareerLine.IRON_BREAKER]      = { Point = "topright",     RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = 0,    },
        [GameData.CareerLine.MAGUS]             = { Point = "topright",     RelativePoint = "bottomright",  RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 123,  YOffset = 0,    },
        [GameData.CareerLine.WHITE_LION]        = { Point = "topright",     RelativePoint = "bottomright",  RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 123,  YOffset = 0,    },
        [GameData.CareerLine.BLACKGUARD]        = { Point = "topright",     RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = -13,  },
        [GameData.CareerLine.SHAMAN]            = { Point = "topright",     RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -1,   YOffset = 0,    },
        [GameData.CareerLine.SORCERER]          = { Point = "topright",     RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = 0,    },
        [GameData.CareerLine.SQUIG_HERDER]      = { Point = "topright",     RelativePoint = "bottomright",  RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 95,   YOffset = 0,    },
        [GameData.CareerLine.SWORDMASTER]       = { Point = "topright",     RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = 0,    },
        [GameData.CareerLine.WARRIOR_PRIEST]    = { Point = "topright",     RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = 0,    },
        [GameData.CareerLine.WITCH_HUNTER]      = { Point = "topright",     RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = 9,    },
    },
                                                --    Bar1
    [LAYOUT_MODE_5_ACTION_BARS] =               -- Bar2  Bar3
    {                                           -- Bar4  Bar5
        [ACTION_BAR_NAME.."1"]                  = { Point = "bottom",       RelativePoint = "bottom",       RelativeTo = "Root",                XOffset = 0,    YOffset = -138  },
        [ACTION_BAR_NAME.."2"]                  = { Point = "bottom",       RelativePoint = "bottomright",  RelativeTo = "Root",                XOffset = 0,    YOffset = -68,  },
        [ACTION_BAR_NAME.."3"]                  = { Point = "bottomright",  RelativePoint = "bottomleft",   RelativeTo = ACTION_BAR_NAME.."2",  XOffset = 0,    YOffset = 0,    },
        [ACTION_BAR_NAME.."4"]                  = { Point = "bottom",       RelativePoint = "bottomright",  RelativeTo = "Root",                XOffset = 0,    YOffset = 0,    },
        [ACTION_BAR_NAME.."5"]                  = { Point = "bottomright",  RelativePoint = "bottomleft",   RelativeTo = ACTION_BAR_NAME.."4",  XOffset = 0,    YOffset = 0,    },
        [QUICK_LOCK_NAME]                       = { Point = "topleft",      RelativePoint = "bottomleft",   RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = 0,    },
        [MORALE_BAR_NAME]                       = { Point = "topright",     RelativePoint = "bottomright",  RelativeTo = ACTION_BAR_NAME.."3",  XOffset = 0,    YOffset = 0     },
        [GRANTED_ABILITY_BAR_NAME]              = { Point = "topleft",      RelativePoint = "bottomleft",   RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 20,   YOffset = 0,    },
        [TACTICS_WINDOW_NAME]                   = { Point = "topleft",      RelativePoint = "bottomleft",   RelativeTo = ACTION_BAR_NAME.."2",  XOffset = 0,    YOffset = 0     },
        [STANCE_ABILITY_BAR_NAME]               = { Point = "top",          RelativePoint = "bottomleft",   RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = -12,  },
        [PET_STANCE_BAR_NAME]                   = { Point = "left",         RelativePoint = "right",        RelativeTo = CAREER_WINDOW_NAME,    XOffset = -4,   YOffset = 10,   },
        [CAST_BAR_NAME]                         = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 0,    YOffset = -80   },
        [LEFT_CAP_NAME]                         = { Point = "bottomleft",   RelativePoint = "bottomright",  RelativeTo = ACTION_BAR_NAME.."4",  XOffset = 0,    YOffset = 0     },
        [RIGHT_CAP_NAME]                        = { Point = "bottomright",  RelativePoint = "bottomleft",   RelativeTo = ACTION_BAR_NAME.."5",  XOffset = 0,    YOffset = 0     },
        [GameData.CareerLine.WITCH_ELF]         = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.ARCHMAGE]          = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.BLACK_ORC]         = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.DISCIPLE]          = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.BRIGHT_WIZARD]     = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.CHOPPA]		    = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.ENGINEER]          = { Point = "top",          RelativePoint = "bottomright",  RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -112, YOffset = 0,    },
        [GameData.CareerLine.SLAYER]		    = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.IRON_BREAKER]      = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.MAGUS]             = { Point = "top",          RelativePoint = "bottomright",  RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 28,   YOffset = 0,    },
        [GameData.CareerLine.WHITE_LION]        = { Point = "top",          RelativePoint = "bottomright",  RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 28,   YOffset = 0,    },
        [GameData.CareerLine.BLACKGUARD]        = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -12,  YOffset = -13,  },
        [GameData.CareerLine.SHAMAN]            = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.SORCERER]          = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.SQUIG_HERDER]      = { Point = "top",          RelativePoint = "bottomright",  RelativeTo = ACTION_BAR_NAME.."1",  XOffset = 94,   YOffset = 0,    },
        [GameData.CareerLine.SWORDMASTER]       = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.WARRIOR_PRIEST]    = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 0,    },
        [GameData.CareerLine.WITCH_HUNTER]      = { Point = "top",          RelativePoint = "bottom",       RelativeTo = ACTION_BAR_NAME.."1",  XOffset = -11,  YOffset = 9,    },
    },
}

-- Window name string table entries.  Used by the LayoutEditor system to display the window name and description when appropriate.
-- Stored in this table for easy lookup and centralized registration, 
-- Keyed on window name so that the cluster manager can actually register the windows contained with the LayoutManager.
ClusterUICustomizationData =
{
    [ACTION_BAR_NAME.."1"]      = { nameKey = StringTables.HUD.LABEL_HUD_EDIT_ACTIONBAR_X_WINDOW_NAME,      descKey = StringTables.HUD.LABEL_HUD_EDIT_ACTIONBAR_X_WINDOW_DESC,  params = { L"1" },  minMode = LAYOUT_MODE_1_ACTION_BAR,     hideable = false },
    [ACTION_BAR_NAME.."2"]      = { nameKey = StringTables.HUD.LABEL_HUD_EDIT_ACTIONBAR_X_WINDOW_NAME,      descKey = StringTables.HUD.LABEL_HUD_EDIT_ACTIONBAR_X_WINDOW_DESC,  params = { L"2" },  minMode = LAYOUT_MODE_2_ACTION_BARS,    hideable = false },
    [ACTION_BAR_NAME.."3"]      = { nameKey = StringTables.HUD.LABEL_HUD_EDIT_ACTIONBAR_X_WINDOW_NAME,      descKey = StringTables.HUD.LABEL_HUD_EDIT_ACTIONBAR_X_WINDOW_DESC,  params = { L"3" },  minMode = LAYOUT_MODE_3_ACTION_BARS,    hideable = false },
    [ACTION_BAR_NAME.."4"]      = { nameKey = StringTables.HUD.LABEL_HUD_EDIT_ACTIONBAR_X_WINDOW_NAME,      descKey = StringTables.HUD.LABEL_HUD_EDIT_ACTIONBAR_X_WINDOW_DESC,  params = { L"4" },  minMode = LAYOUT_MODE_4_ACTION_BARS,    hideable = false },
    [ACTION_BAR_NAME.."5"]      = { nameKey = StringTables.HUD.LABEL_HUD_EDIT_ACTIONBAR_X_WINDOW_NAME,      descKey = StringTables.HUD.LABEL_HUD_EDIT_ACTIONBAR_X_WINDOW_DESC,  params = { L"5" },  minMode = LAYOUT_MODE_5_ACTION_BARS,    hideable = false },
    [MORALE_BAR_NAME]           = { nameKey = StringTables.HUD.LABEL_HUD_EDIT_MORALEBAR_WINDOW_NAME,        descKey = StringTables.HUD.LABEL_HUD_EDIT_MORALEBAR_WINDOW_DESC,                        minMode = LAYOUT_MODE_1_ACTION_BAR,     hideable = true  },
    [GRANTED_ABILITY_BAR_NAME]  = { nameKey = StringTables.HUD.LABEL_HUD_EDIT_GRANTEDBAR_WINDOW_NAME,       descKey = StringTables.HUD.LABEL_HUD_EDIT_GRANTEDBAR_WINDOW_DESC,                       minMode = LAYOUT_MODE_1_ACTION_BAR,     hideable = true  },
    [STANCE_ABILITY_BAR_NAME]   = { nameKey = StringTables.HUD.LABEL_HUD_EDIT_STANCEBAR_WINDOW_NAME,        descKey = StringTables.HUD.LABEL_HUD_EDIT_STANCEBAR_WINDOW_DESC,                        minMode = LAYOUT_MODE_1_ACTION_BAR,     hideable = true  },
    [PET_STANCE_BAR_NAME]       = { nameKey = StringTables.HUD.LABEL_HUD_EDIT_PET_STANCE_BAR_NAME,          descKey = StringTables.HUD.LABEL_HUD_EDIT_PET_STANCE_BAR_DESC,                          minMode = LAYOUT_MODE_1_ACTION_BAR,     hideable = true  },
    [CAREER_WINDOW_NAME]        = { nameKey = StringTables.HUD.LABEL_HUD_EDIT_CAREERRESOURCE_WINDOW_NAME,   descKey = StringTables.HUD.LABEL_HUD_EDIT_CAREERRESOURCE_WINDOW_DESC,                   minMode = LAYOUT_MODE_1_ACTION_BAR,     hideable = true  },
    [LEFT_CAP_NAME]             = { nameKey = StringTables.HUD.LABEL_HUD_EDIT_LEFT_CAP_WINDOW_NAME,         descKey = StringTables.HUD.LABEL_HUD_EDIT_LEFT_CAP_WINDOW_DESC,                         minMode = LAYOUT_MODE_1_ACTION_BAR,     hideable = true  },
    [RIGHT_CAP_NAME]            = { nameKey = StringTables.HUD.LABEL_HUD_EDIT_RIGHT_CAP_WINDOW_NAME,        descKey = StringTables.HUD.LABEL_HUD_EDIT_RIGHT_CAP_WINDOW_DESC,                        minMode = LAYOUT_MODE_1_ACTION_BAR,     hideable = true  },
    [TACTICS_WINDOW_NAME]       = { nameKey = StringTables.HUD.LABEL_HUD_EDIT_TACTICS_WINDOW_NAME,          descKey = StringTables.HUD.LABEL_HUD_EDIT_TACTICS_WINDOW_DESC,                          minMode = LAYOUT_MODE_1_ACTION_BAR,     hideable = true  },
    [CAST_BAR_NAME]             = { nameKey = StringTables.HUD.LABEL_HUD_EDIT_CAST_BAR_WINDOW_NAME,         descKey = StringTables.HUD.LABEL_HUD_EDIT_CAST_BAR_WINDOW_DESC,                         minMode = LAYOUT_MODE_1_ACTION_BAR,     hideable = true  },
}