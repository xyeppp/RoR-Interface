
-- NOTE: This file is doccumented with NaturalDocs style comments. All comments begining with "--#' will
-- be included in the output.

------------------------------------------------------------------------------------------------------------------------------------------------
--# Title: Default Color
--#     This file contains EA Mythic default color definitions
------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------
-- DefaultColor Global Variables
----------------------------------------------------------------
DefaultColor = {}

----------------------------------------------------------------
-- Legacy Helper Function
----------------------------------------------------------------
function NewColor( red, green, blue )
    return { r=red, g=green, b=blue }
end

------------------------------------------------------------------
-- Global Color Values
------------------------------------------------------------------
DefaultColor.GREEN       = { r=44,  g=206, b=44  }
DefaultColor.RED         = { r=206, g=44,  b=44  }
DefaultColor.MAGENTA     = { r=255, g=0,   b=255  }
DefaultColor.BLUE        = { r=67,  g=112, b=214 }
DefaultColor.LIGHT_BLUE  = { r=53,  g=185, b=223 }
DefaultColor.WHITE       = { r=234, g=234, b=234 }
DefaultColor.YELLOW      = { r=226, g=216, b=45  }
DefaultColor.ORANGE      = { r=255, g=100, b=0   }
DefaultColor.GOLD        = { r=242, g=169, b=53  }
DefaultColor.PURPLE      = { r=194, g=56,  b=153 }
DefaultColor.TEAL        = { r=11,  g=192, b=185 }
DefaultColor.BLACK       = { r=0,   g=0,   b=0   }
DefaultColor.LIGHT_GRAY  = { r=190, g=190, b=190  }
DefaultColor.MEDIUM_LIGHT_GRAY  = { r=100, g=100, b=100  }
DefaultColor.MEDIUM_GRAY = { r=75,  g=75,  b=75  }
DefaultColor.DARK_GRAY   = { r=32,  g=32,  b=32  }
DefaultColor.BROWN       = { r=96,  g=57,  b=19  }
DefaultColor.CLEAR_WHITE = { r=255, g=255, b=255 } 
DefaultColor.ZERO_TINT   = { r=255, g=255, b=255 }



-- Realm Colors
DefaultColor.RealmColors = {}
DefaultColor.RealmColors[0]      = {r=255, g=255, b=255 } -- Neutral
DefaultColor.RealmColors[1]      = {r=0,   g=148, b=225 } -- Order
DefaultColor.RealmColors[2]      = {r=255, g=5,   b=5   } -- Destruction
DefaultColor.ContestedColor      = {r=255, g=255, b=0   } -- Yellow
DefaultColor.OrderMapColor       = {r=45,  g=63,  b=133 } -- Blue
DefaultColor.DestructionMapColor = {r=170, g=25,  b=25  } -- Red

----------------------------------
-- Scenario Group Status Colors --
----------------------------------
DefaultColor.Reserved   = {r=170, g=25,  b=25}      -- Red
DefaultColor.Available  = {r=75,  g=75,  b=255}     -- Blue

-----------------------------
-- Default List Row Colors --
-----------------------------
DefaultColor.RowColors = {}                                  -- Use these for alternating row color tints
DefaultColor.RowColors[0] = {r=255, g=255, b=255, a=0.03}    -- 3% White
DefaultColor.RowColors[1] = {r=255, g=255, b=255, a=0.10}    -- 10% white

DefaultColor.RowColors.MaximumAlternatingRowColors  = 2  -- Specifies how many rows should be the same color before alternating to the next set
DefaultColor.RowColors.NumberOfAlternatingRowColors = 2  -- Specifies how many rows should be the same color before alternating to the next set

DefaultColor.RowColors.SELECTED         = { r=116, g=121, b=127, a=1.0} -- Dark Steel Blue
DefaultColor.RowColors.AVAILABLE        = { r=60,  g=180, b=60,  a=1.0 }
DefaultColor.RowColors.UNAVAILABLE      = { r=180, g=60,  b=60,  a=1.0 }
DefaultColor.RowColors.UNAVAILABLE_TEXT = { r=180, g=180, b=180, a=1.0 }

DefaultColor.ROW_BACKGROUND_HIGHLIGHT = { r=66, g=35, b=0, a=1 }    -- color to highlight list rows while mouseover

----------------------------------------------------------------
-- Calendar Colors
----------------------------------------------------------------
DefaultColor.Calendar = {}
DefaultColor.Calendar.Day = {}
DefaultColor.Calendar.Day.LabelColor = {}
DefaultColor.Calendar.Day.LabelColor.Past       = {r=128, g=128, b=128}
DefaultColor.Calendar.Day.LabelColor.Present    = {r=255, g=255, b=255}
DefaultColor.Calendar.Day.LabelColor.Future     = {r=255, g=255, b=255}
DefaultColor.Calendar.Day.TintColor = {}
DefaultColor.Calendar.Day.TintColor.MOUSEOVER   = {r=128, g=192, b=255, a=0.25}
DefaultColor.Calendar.Day.TintColor.SELECTED    = {r=128, g=192, b=255, a=0.5}


DefaultColor.ChatTextColors = {}
DefaultColor.ChatTextColors[1]  = {r=247, g=198, b=198, a=1}
DefaultColor.ChatTextColors[2]  = {r=237, g=146, b=141, a=1}
DefaultColor.ChatTextColors[3]  = {r=231, g=113, b=104, a=1}
DefaultColor.ChatTextColors[4]  = {r=225, g= 78, b= 70, a=1}
DefaultColor.ChatTextColors[5]  = {r=255, g=  0, b=  0, a=1}    -- Red  (A)
DefaultColor.ChatTextColors[6]  = {r=220, g= 43, b= 25, a=1}
DefaultColor.ChatTextColors[7]  = {r=186, g= 42, b= 26, a=1}
DefaultColor.ChatTextColors[8]  = {r=166, g= 40, b= 26, a=1}
DefaultColor.ChatTextColors[9]  = {r=129, g= 24, b= 35, a=1}

DefaultColor.ChatTextColors[10] = {r=246, g=198, b=179, a=1}
DefaultColor.ChatTextColors[11] = {r=238, g=156, b=139, a=1}
DefaultColor.ChatTextColors[12] = {r=234, g=130, b=109, a=1}
DefaultColor.ChatTextColors[13] = {r=229, g=105, b= 83, a=1}
DefaultColor.ChatTextColors[14] = {r=255, g= 63, b=  0, a=1}    -- Red Orange   (B)
DefaultColor.ChatTextColors[15] = {r=223, g= 66, b= 56, a=1}
DefaultColor.ChatTextColors[16] = {r=188, g= 61, b= 52, a=1}
DefaultColor.ChatTextColors[17] = {r=167, g= 56, b= 49, a=1}
DefaultColor.ChatTextColors[18] = {r=129, g= 46, b= 42, a=1}

DefaultColor.ChatTextColors[19] = {r=248, g=210, b=183, a=1}    -- Lightest
DefaultColor.ChatTextColors[20] = {r=243, g=186, b=141, a=1}
DefaultColor.ChatTextColors[21] = {r=238, g=156, b=104, a=1}
DefaultColor.ChatTextColors[22] = {r=235, g=139, b= 68, a=1}
DefaultColor.ChatTextColors[23] = {r=255, g=127, b=  0, a=1}    -- Orange   (C)
DefaultColor.ChatTextColors[24] = {r=232, g=123, b= 20, a=1}
DefaultColor.ChatTextColors[25] = {r=194, g=110, b= 26, a=1}
DefaultColor.ChatTextColors[26] = {r=172, g=101, b= 27, a=1}
DefaultColor.ChatTextColors[27] = {r=133, g= 81, b= 26, a=1}    -- Darkest

DefaultColor.ChatTextColors[28] = {r=250, g=224, b=189, a=1}    -- Lightest
DefaultColor.ChatTextColors[29] = {r=247, g=210, b=147, a=1}
DefaultColor.ChatTextColors[30] = {r=244, g=186, b=110, a=1}
DefaultColor.ChatTextColors[31] = {r=242, g=176, b= 73, a=1}
DefaultColor.ChatTextColors[32] = {r=255, g=127, b=  0, a=1}    -- Gold (D)
DefaultColor.ChatTextColors[33] = {r=238, g=157, b= 22, a=1}
DefaultColor.ChatTextColors[34] = {r=198, g=138, b= 24, a=1}
DefaultColor.ChatTextColors[35] = {r=175, g=126, b= 24, a=1}
DefaultColor.ChatTextColors[36] = {r=136, g=101, b= 26, a=1}    -- Darkest

DefaultColor.ChatTextColors[37] = {r=254, g=253, b=188, a=1}    -- Lightest
DefaultColor.ChatTextColors[38] = {r=253, g=252, b=155, a=1}
DefaultColor.ChatTextColors[39] = {r=253, g=251, b=114, a=1}
DefaultColor.ChatTextColors[40] = {r=234, g=249, b= 49, a=1}
DefaultColor.ChatTextColors[41] = {r=255, g=255, b=  0, a=1}    -- Yellow   (E)
DefaultColor.ChatTextColors[42] = {r=254, g=248, b=  0, a=1}
DefaultColor.ChatTextColors[43] = {r=207, g=204, b=  0, a=1}
DefaultColor.ChatTextColors[44] = {r=182, g=180, b=  0, a=1}
DefaultColor.ChatTextColors[45] = {r=139, g=138, b=  2, a=1}    -- Darkest

DefaultColor.ChatTextColors[46] = {r=207, g=232, b=200, a=1}    -- Lightest
DefaultColor.ChatTextColors[47] = {r=164, g=214, b=160, a=1}
DefaultColor.ChatTextColors[48] = {r=137, g=202, b=127, a=1}
DefaultColor.ChatTextColors[49] = {r= 95, g=186, b= 95, a=1}
DefaultColor.ChatTextColors[50] = {r=127, g=255, b=127, a=1}    -- Turquoise (F)
DefaultColor.ChatTextColors[51] = {r= 62, g=177, b= 52, a=1}
DefaultColor.ChatTextColors[52] = {r= 67, g=152, b= 48, a=1}
DefaultColor.ChatTextColors[53] = {r= 65, g=137, b= 45, a=1}
DefaultColor.ChatTextColors[54] = {r= 56, g=108, b= 39, a=1}    -- Darkest

DefaultColor.ChatTextColors[55] = {r=164, g=214, b=199, a=1}
DefaultColor.ChatTextColors[56] = {r=105, g=191, b=177, a=1}
DefaultColor.ChatTextColors[57] = {r= 56, g=178, b=137, a=1}
DefaultColor.ChatTextColors[58] = {r=  0, g=162, b=106, a=1}
DefaultColor.ChatTextColors[59] = {r=  0, g=255, b=  0, a=1}    -- Green    (G)
DefaultColor.ChatTextColors[60] = {r=  0, g=146, b= 81, a=1}
DefaultColor.ChatTextColors[61] = {r=  0, g=128, b= 73, a=1}
DefaultColor.ChatTextColors[62] = {r=  0, g=115, b= 67, a=1}
DefaultColor.ChatTextColors[63] = {r=  0, g= 91, b= 54, a=1}

DefaultColor.ChatTextColors[64] = {r=163, g=214, b=222, a=1}
DefaultColor.ChatTextColors[65] = {r=104, g=191, b=197, a=1}
DefaultColor.ChatTextColors[66] = {r= 54, g=178, b=186, a=1}
DefaultColor.ChatTextColors[67] = {r=  0, g=163, b=175, a=1}
DefaultColor.ChatTextColors[68] = {r=  0, g=127, b=127, a=1}    -- Teal (H)
DefaultColor.ChatTextColors[69] = {r=  0, g=145, b=157, a=1}
DefaultColor.ChatTextColors[70] = {r=  0, g=128, b=137, a=1}
DefaultColor.ChatTextColors[71] = {r=  0, g=115, b=125, a=1}
DefaultColor.ChatTextColors[72] = {r=  0, g= 91, b= 99, a=1}

DefaultColor.ChatTextColors[73] = {r=156, g=177, b=219, a=1}
DefaultColor.ChatTextColors[74] = {r=115, g=146, b=201, a=1}
DefaultColor.ChatTextColors[75] = {r= 92, g=118, b=180, a=1}
DefaultColor.ChatTextColors[76] = {r= 48, g= 96, b=166, a=1}
DefaultColor.ChatTextColors[77] = {r=  0, g=  0, b=255, a=1}    -- Blue (I)
DefaultColor.ChatTextColors[78] = {r=  1, g= 78, b=154, a=1}
DefaultColor.ChatTextColors[79] = {r=  3, g= 70, b=134, a=1}
DefaultColor.ChatTextColors[80] = {r=  2, g= 64, b=122, a=1}
DefaultColor.ChatTextColors[81] = {r=  3, g= 52, b= 97, a=1}

DefaultColor.ChatTextColors[82] = {r=132, g=128, b=183, a=1}
DefaultColor.ChatTextColors[83] = {r=108, g=101, b=165, a=1}
DefaultColor.ChatTextColors[84] = {r= 82, g= 82, b=152, a=1}
DefaultColor.ChatTextColors[85] = {r= 68, g= 57, b=136, a=1}
DefaultColor.ChatTextColors[86] = {r= 31, g= 31, b=125, a=1}    -- Indigo   (J)
DefaultColor.ChatTextColors[87] = {r= 37, g= 35, b=124, a=1}
DefaultColor.ChatTextColors[88] = {r= 35, g= 32, b=109, a=1}
DefaultColor.ChatTextColors[89] = {r= 32, g= 31, b=100, a=1}
DefaultColor.ChatTextColors[90] = {r= 26, g= 26, b= 79, a=1}

DefaultColor.ChatTextColors[91] = {r=174, g=155, b=198, a=1}
DefaultColor.ChatTextColors[92] = {r=145, g=117, b=172, a=1}
DefaultColor.ChatTextColors[93] = {r=120, g= 90, b=155, a=1}
DefaultColor.ChatTextColors[94] = {r=105, g= 56, b=134, a=1}
DefaultColor.ChatTextColors[95] = {r= 53, g= 19, b= 75, a=1}    -- Dark Violet (K)
DefaultColor.ChatTextColors[96] = {r= 83, g= 20, b=117, a=1}
DefaultColor.ChatTextColors[97] = {r= 74, g= 20, b=104, a=1}
DefaultColor.ChatTextColors[98] = {r= 68, g= 20, b= 95, a=1}
DefaultColor.ChatTextColors[99] = {r= 53, g= 19, b= 75, a=1}

DefaultColor.ChatTextColors[100] = {r=216, g=187, b=217, a=1}
DefaultColor.ChatTextColors[101] = {r=187, g=142, b=187, a=1}
DefaultColor.ChatTextColors[102] = {r=175, g=109, b=164, a=1}
DefaultColor.ChatTextColors[103] = {r=156, g= 74, b=143, a=1}
DefaultColor.ChatTextColors[104] = {r=117, g= 24, b= 98, a=1}   -- Light Violet (K)
DefaultColor.ChatTextColors[105] = {r=145, g= 27, b=121, a=1}
DefaultColor.ChatTextColors[106] = {r=128, g= 26, b=107, a=1}
DefaultColor.ChatTextColors[107] = {r=117, g= 24, b= 98, a=1}
DefaultColor.ChatTextColors[108] = {r= 94, g= 22, b= 79, a=1}

DefaultColor.ChatTextColors[109] = {r=255, g=110, b=190, a=1}
DefaultColor.ChatTextColors[110] = {r=255, g= 95, b=180, a=1}
DefaultColor.ChatTextColors[111] = {r=255, g= 80, b=170, a=1}
DefaultColor.ChatTextColors[112] = {r=255, g= 65, b=160, a=1}
DefaultColor.ChatTextColors[113] = {r=255, g= 50, b=150, a=1}   -- Pinkish
DefaultColor.ChatTextColors[114] = {r=255, g= 35, b=140, a=1}
DefaultColor.ChatTextColors[115] = {r=255, g= 20, b=130, a=1}
DefaultColor.ChatTextColors[116] = {r=255, g=  5, b=120, a=1}
DefaultColor.ChatTextColors[117] = {r=255, g=  0, b=110, a=1}

DefaultColor.ChatTextColors[118] = {r=250, g=170, b=  0, a=1}   -- Light Brownish
DefaultColor.ChatTextColors[119] = {r=225, g=150, b=  0, a=1}
DefaultColor.ChatTextColors[120] = {r=199, g=130, b=  0, a=1}   
DefaultColor.ChatTextColors[121] = {r=166, g=110, b=  0, a=1}
DefaultColor.ChatTextColors[122] = {r=133, g= 90, b=  0, a=1}   -- Brownish
DefaultColor.ChatTextColors[123] = {r=100, g= 70, b=  0, a=1}   
DefaultColor.ChatTextColors[124] = {r= 75, g= 50, b=  0, a=1}
DefaultColor.ChatTextColors[125] = {r= 50, g= 30, b=  0, a=1}
DefaultColor.ChatTextColors[126] = {r= 25, g= 10, b=  0, a=1}   -- Dark Brownish

DefaultColor.ChatTextColors[127] = {r=153, g=102, b=  0, a=1}   -- Lightest
DefaultColor.ChatTextColors[128] = {r=131, g= 81, b= 26, a=1}
DefaultColor.ChatTextColors[129] = {r=107, g= 42, b= 26, a=1}   -- Semi-Sweet Chocolate
DefaultColor.ChatTextColors[130] = {r=180, g=  1, b= 26, a=1}
DefaultColor.ChatTextColors[131] = {r= 78, g= 47, b= 47, a=1}   -- Brown
DefaultColor.ChatTextColors[132] = {r=140, g= 78, b= 53, a=1}   -- Bronze
DefaultColor.ChatTextColors[133] = {r=219, g= 93, b= 70, a=1}   -- Tan
DefaultColor.ChatTextColors[134] = {r=129, g= 46, b= 42, a=1}
DefaultColor.ChatTextColors[135] = {r= 59, g= 20, b= 11, a=1}   -- Darkest

DefaultColor.ChatTextColors[136] = {r=255, g=255, b=255, a=1}   -- White
DefaultColor.ChatTextColors[137] = {r=224, g=224, b=224, a=1}
DefaultColor.ChatTextColors[138] = {r=192, g=192, b=192, a=1}
DefaultColor.ChatTextColors[139] = {r=160, g=160, b=160, a=1}
DefaultColor.ChatTextColors[140] = {r=128, g=128, b=128, a=1}   -- Grey
DefaultColor.ChatTextColors[141] = {r= 96, g= 96, b= 96, a=1}
DefaultColor.ChatTextColors[142] = {r= 64, g= 64, b= 64, a=1}
DefaultColor.ChatTextColors[143] = {r= 32, g= 32, b= 32, a=1}
DefaultColor.ChatTextColors[144] = {r=  0, g=  0, b=  0, a=1}   -- Black

----------------------------------------------------------------
-- Chat Channel Colors
----------------------------------------------------------------
DefaultColor.ChatChannelColors = {}
DefaultColor.ChatChannelColors[SystemData.ChatLogFilters.GUILD]         = {r=144, g=237, b=250, a=0.25}
DefaultColor.ChatChannelColors[SystemData.ChatLogFilters.ALLIANCE]      = {r=18, g=202, b=209, a=0.25}
DefaultColor.ChatChannelColors[SystemData.ChatLogFilters.REALM_WAR_T1]  = {r=0xDB, g=0x93, b=0x70, a=0.25}

----------------------------------------------------------------
-- Crafting Hint Text Colors
----------------------------------------------------------------
DefaultColor.COLOR_NEED_CONTAINER       = { r=255, g=255, b=255 }
DefaultColor.COLOR_NEED_STABILIZERS     = { r=44,  g=171, b=82  }
DefaultColor.COLOR_NEED_INGREDIENTS     = { r=206, g=97,  b=33  }
DefaultColor.COLOR_NEED_DETERMINENT     = { r=189, g=40,  b=33  }
DefaultColor.COLOR_TALISMAN_GENRAL_HINT = { r=49,  g=206, b=255 }


------------------------------------------------------------------
-- Alert Text Colors Center Messaging System
------------------------------------------------------------------
DefaultColor.AlertTextColors = {}
DefaultColor.AlertTextColors[ "White" ]     = NewColor( 255, 255, 255 )     -- White
DefaultColor.AlertTextColors[ "Red" ]       = NewColor( 206, 44,  44 )      -- Red
DefaultColor.AlertTextColors[ "Blue"]       = NewColor( 67,  112, 214 )     -- Blue
DefaultColor.AlertTextColors[ "Yellow" ]    = NewColor( 226, 216, 45 )      -- Yellow
DefaultColor.AlertTextColors[ "Gold" ]      = NewColor( 242, 169, 53 )      -- Gold
DefaultColor.AlertTextColors[ "Purple" ]    = NewColor( 194, 56,  153 )     -- Purple
DefaultColor.AlertTextColors[ "Teal" ]      = NewColor( 11,  192, 185 )     -- Teal
DefaultColor.AlertTextColors[ "Olive" ]     = NewColor( 115, 160, 0 )

-------------------------------------------------------------------
-- Names Colors (Above Head and in Target Window(s)
-------------------------------------------------------------------
DefaultColor.NAME_COLOR_PLAYER              = { r=255, g=255, b=255 }
DefaultColor.NAME_COLOR_TITLE               = { r=212, g=212, b=212 }
DefaultColor.NAME_COLOR_GUILDNAME           = { r=212, g=212, b=212 }
DefaultColor.NAME_COLOR_NPC                 = { r=112, g=147, b=255 }
DefaultColor.NAME_COLOR_NPC_TITLE           = { r=57,  g=100, b=237 }
DefaultColor.NAME_COLOR_GROUPMATE           = { r=22,  g=232, b=22 }
DefaultColor.NAME_COLOR_GROUPMATE_TITLE     = { r=73,  g=162, b=73 }
DefaultColor.NAME_COLOR_GROUPMATE_GUILDNAME = { r=73,  g=162, b=73 }
DefaultColor.NAME_COLOR_WARBANDMATE         = { r=183, g=237, b=170 }
DefaultColor.NAME_COLOR_GUILDMATE           = { r=172, g=237, b=238 }
DefaultColor.NAME_COLOR_GUILDMATE_TITLE     = { r=73,  g=162, b=73 }
DefaultColor.NAME_COLOR_GUILDMATE_GUILDNAME = { r=73,  g=162, b=73 }
DefaultColor.NAME_COLOR_THREAT              = { r=253, g=54,  b=50 }
DefaultColor.NAME_COLOR_THREAT_TITLE        = { r=180, g=30,  b=35 }
DefaultColor.NAME_COLOR_NONTHREAT           = { r=206, g=197, b=57 }
DefaultColor.NAME_COLOR_NONTHREAT_TITLE     = { r=152, g=136, b=2 }

-------------------------------------------------------------------
-- Health Text Color (for Warband/SGroup UI)
-------------------------------------------------------------------
DefaultColor.HEALTH_TEXT_FULL               = { r=112, g=233, b=31 }
DefaultColor.HEALTH_TEXT_NOT_FULL           = { r=226, g=209, b=18 }
DefaultColor.HEALTH_TEXT_DEAD               = { r=253, g=54,  b=50 }

----------------------------------------------------------------
-- Experience Indicator Colors
----------------------------------------------------------------
DefaultColor.XP_COLOR_UNFILLED  = { r=66,  g=35,  b=0   }
DefaultColor.XP_COLOR_FILLED    = { r=236, g=124, b=5   }
DefaultColor.XP_COLOR_RESTED    = { r=150, g=5,   b=236 }

----------------------------------------------------------------
-- Guild Window
----------------------------------------------------------------
DefaultColor.GUILD_RANK                     = { r=115, g=160, b=0   }   -- Greenish
DefaultColor.GUILD_ROSTER_NAME              = { r=226, g=216, b=45  }   -- Yellowish
DefaultColor.GUILD_ROSTER_RANK              = { r=242, g=169, b=53  }   -- Orangeish
DefaultColor.GUILD_ROSTER_TITLE             = { r=255, g=255, b=255 }   -- White
DefaultColor.GUILD_ROSTER_STATUS_ONLINE     = { r=255, g=255, b=255 }   -- White
DefaultColor.GUILD_ADMIN_TITLE_SELECTED     = { r=226, g=216, b=45  }   -- Yellowish
DefaultColor.GUILD_ADMIN_TITLE_UNSELECTED   = { r=255, g=255, b=255 }   -- White
DefaultColor.GUILD_MEDIUM_GRAY              = { r=128, g=128, b=128 }   -- Medium Gray
DefaultColor.GUILD_ADMIN_PERMISSION_NORMAL  = { r=255, g=255, b=255 }   -- White
DefaultColor.GUILD_ADMIN_PERMISSION_DISABLED= { r=128, g=128, b=128 }   -- Medium Gray

----------------------------------------------------------------
-- Color Picker
----------------------------------------------------------------
DefaultColor.COLOR_PICKER_ALPHA = 1.0

DefaultColor.ColorPickerColors = {}
-- Format: id is the id of the color as listed in the CSV file. r=red, g=green, b=blue, a=alpha
DefaultColor.ColorPickerColors[1] = {}
DefaultColor.ColorPickerColors[1][1] = {id=100, r= 86, g= 25, b= 57, a=DefaultColor.COLOR_PICKER_ALPHA}
DefaultColor.ColorPickerColors[1][2] = {id=101, r=115, g= 40, b= 79, a=DefaultColor.COLOR_PICKER_ALPHA}
DefaultColor.ColorPickerColors[1][3] = {id=102, r=169, g= 80, b=105, a=DefaultColor.COLOR_PICKER_ALPHA}
DefaultColor.ColorPickerColors[1][4] = {id=0}

DefaultColor.ColorPickerColors[2] = {}  -- Row 2 (Indigos)
DefaultColor.ColorPickerColors[2][1] = {id=104, r= 40, g=  9, b= 49, a=DefaultColor.COLOR_PICKER_ALPHA}
DefaultColor.ColorPickerColors[2][2] = {id=105, r= 52, g= 21, b= 88, a=DefaultColor.COLOR_PICKER_ALPHA}
DefaultColor.ColorPickerColors[2][3] = {id=106, r= 87, g= 61, b=117, a=DefaultColor.COLOR_PICKER_ALPHA}
DefaultColor.ColorPickerColors[2][4] = {id=107, r=141, g=100, b=151, a=DefaultColor.COLOR_PICKER_ALPHA}

DefaultColor.ColorPickerColors[3] = {}  -- Row 3 (Blues)
DefaultColor.ColorPickerColors[3][1] = {id=108, r= 10, g= 11, b= 38, a=DefaultColor.COLOR_PICKER_ALPHA} 
DefaultColor.ColorPickerColors[3][2] = {id=109, r= 16, g= 29, b= 68, a=DefaultColor.COLOR_PICKER_ALPHA}
DefaultColor.ColorPickerColors[3][3] = {id=110, r= 40, g= 62, b=112, a=DefaultColor.COLOR_PICKER_ALPHA}
DefaultColor.ColorPickerColors[3][4] = {id=111, r= 43, g= 87, b=153, a=DefaultColor.COLOR_PICKER_ALPHA}

DefaultColor.ColorPickerColors[4] = {}  -- Row 4 (Teals)
DefaultColor.ColorPickerColors[4][1] = {id=112, r= 17, g= 31, b= 38, a=DefaultColor.COLOR_PICKER_ALPHA}
DefaultColor.ColorPickerColors[4][2] = {id=113, r= 22, g= 65, b= 69, a=DefaultColor.COLOR_PICKER_ALPHA}
DefaultColor.ColorPickerColors[4][3] = {id=114, r= 29, g=103, b=105, a=DefaultColor.COLOR_PICKER_ALPHA}
DefaultColor.ColorPickerColors[4][4] = {id=115, r= 38, g=142, b=133, a=DefaultColor.COLOR_PICKER_ALPHA}

DefaultColor.ColorPickerColors[5] = {}  -- Row 5 (Greens)
DefaultColor.ColorPickerColors[5][1] = {id=116, r= 15, g= 33, b= 12, a=DefaultColor.COLOR_PICKER_ALPHA}
DefaultColor.ColorPickerColors[5][2] = {id=117, r= 28, g= 53, b= 24, a=DefaultColor.COLOR_PICKER_ALPHA}
DefaultColor.ColorPickerColors[5][3] = {id=118, r= 49, g=102, b= 41, a=DefaultColor.COLOR_PICKER_ALPHA}
DefaultColor.ColorPickerColors[5][4] = {id=119, r= 91, g=130, b= 85, a=DefaultColor.COLOR_PICKER_ALPHA}

DefaultColor.ColorPickerColors[6] = {}  -- Row 6 (Dark Yellows)
DefaultColor.ColorPickerColors[6][1] = {id=120, r= 66, g= 63, b= 19, a=DefaultColor.COLOR_PICKER_ALPHA}
DefaultColor.ColorPickerColors[6][2] = {id=121, r=102, g= 97, b= 21, a=DefaultColor.COLOR_PICKER_ALPHA}
DefaultColor.ColorPickerColors[6][3] = {id=122, r=136, g=140, b= 32, a=DefaultColor.COLOR_PICKER_ALPHA}
DefaultColor.ColorPickerColors[6][4] = {id=0}

DefaultColor.ColorPickerColors[7] = {}  -- Row 7 (Oranges and Yellows)
DefaultColor.ColorPickerColors[7][1] = {id=124, r=115, g= 50, b=  7, a=DefaultColor.COLOR_PICKER_ALPHA}
DefaultColor.ColorPickerColors[7][2] = {id=125, r=150, g= 79, b=  4, a=DefaultColor.COLOR_PICKER_ALPHA}
DefaultColor.ColorPickerColors[7][3] = {id=126, r=164, g=118, b=  9, a=DefaultColor.COLOR_PICKER_ALPHA}
DefaultColor.ColorPickerColors[7][4] = {id=127, r=187, g=166, b= 26, a=DefaultColor.COLOR_PICKER_ALPHA}

DefaultColor.ColorPickerColors[8] = {}  -- Row 8 (Browns)
DefaultColor.ColorPickerColors[8][1] = {id=128, r= 58, g= 38, b= 31, a=DefaultColor.COLOR_PICKER_ALPHA}
DefaultColor.ColorPickerColors[8][2] = {id=129, r= 90, g= 68, b= 46, a=DefaultColor.COLOR_PICKER_ALPHA}
DefaultColor.ColorPickerColors[8][3] = {id=130, r=131, g=103, b= 81, a=DefaultColor.COLOR_PICKER_ALPHA}
DefaultColor.ColorPickerColors[8][4] = {id=131, r=157, g=147, b=105, a=DefaultColor.COLOR_PICKER_ALPHA}

DefaultColor.ColorPickerColors[9] = {}  -- Row 9 (Reds)
DefaultColor.ColorPickerColors[9][1] = {id=132, r= 51, g= 10, b=  9, a=DefaultColor.COLOR_PICKER_ALPHA}
DefaultColor.ColorPickerColors[9][2] = {id=133, r= 93, g= 23, b= 31, a=DefaultColor.COLOR_PICKER_ALPHA}
DefaultColor.ColorPickerColors[9][3] = {id=134, r=113, g= 25, b= 19, a=DefaultColor.COLOR_PICKER_ALPHA}
DefaultColor.ColorPickerColors[9][4] = {id=135, r=140, g= 55, b= 52, a=DefaultColor.COLOR_PICKER_ALPHA}

DefaultColor.ColorPickerColors[10] = {} -- Row 10 (Light Grays)
DefaultColor.ColorPickerColors[10][1] = {id=136, r= 38, g= 37, b= 32, a=DefaultColor.COLOR_PICKER_ALPHA}
DefaultColor.ColorPickerColors[10][2] = {id=137, r= 79, g= 77, b= 70, a=DefaultColor.COLOR_PICKER_ALPHA}
DefaultColor.ColorPickerColors[10][3] = {id=138, r=120, g=115, b=105, a=DefaultColor.COLOR_PICKER_ALPHA}
DefaultColor.ColorPickerColors[10][4] = {id=139, r=156, g=153, b=147, a=DefaultColor.COLOR_PICKER_ALPHA}

DefaultColor.ColorPickerColors[11] = {} -- Row 11 (Dark Grays)
DefaultColor.ColorPickerColors[11][1] = {id=  2,  r= 12, g= 12, b= 12, a=DefaultColor.COLOR_PICKER_ALPHA}   -- Default Destruction
DefaultColor.ColorPickerColors[11][2] = {id=140, r= 75, g= 78, b= 84, a=DefaultColor.COLOR_PICKER_ALPHA}
DefaultColor.ColorPickerColors[11][3] = {id=141, r=103, g=111, b=122, a=DefaultColor.COLOR_PICKER_ALPHA}
DefaultColor.ColorPickerColors[11][4] = {id=142, r=166, g=171, b=179, a=DefaultColor.COLOR_PICKER_ALPHA}

-- These are the 3 edge colors of the color picker which don't fit within any particular row
-- Since we're dynamically creating windows and assigning colors based on the data in DefaultColor.ColorPickerColors,
-- we can't add these into those tables, we'll have to specifically create and color them outside the nifty CreateColorSwatch() loop
DefaultColor.ColorPickerEdgeColors = {}
DefaultColor.ColorPickerEdgeColors[1] = {id=201, r= 91, g=140, b=177, a=DefaultColor.COLOR_PICKER_ALPHA}    -- Blueish
DefaultColor.ColorPickerEdgeColors[2] = {id=202, r=163, g=142, b= 56, a=DefaultColor.COLOR_PICKER_ALPHA}    -- Yellowish
DefaultColor.ColorPickerEdgeColors[3] = {id=1, r=206, g=206, b=206, a=DefaultColor.COLOR_PICKER_ALPHA}  -- Default Order

-- Given the actual row number, this function returns the color that row number should be, based on DefaultColor.RowColors
function DefaultColor.GetRowColor( rowIndex )

    local row_mod = math.mod(rowIndex, DefaultColor.RowColors.NumberOfAlternatingRowColors)

    if( DefaultColor.RowColors[row_mod] ~= nil ) then
        return DefaultColor.RowColors[row_mod]
    end

    return DefaultColor.RowColors[0]
end

-- Given a tintable window name and a table of R,G,B, (optional Alpha) values, this function sets that windows tint and alpha.
function DefaultColor.SetWindowTint( windowName, colorTable )

    WindowSetTintColor(windowName, colorTable.r, colorTable.g, colorTable.b )
    if (colorTable.a ~= nil)
    then
        WindowSetAlpha(windowName, colorTable.a)
    end
end

-- Given a tintable label name and a table of R,G,B, (optional Alpha) values, this function sets that windows tint and alpha.
function DefaultColor.SetLabelColor( windowName, colorTable )

    LabelSetTextColor(windowName, colorTable.r, colorTable.g, colorTable.b )
    if (colorTable.a ~= nil) then
        WindowSetAlpha(windowName, colorTable.a)
    end
end

function DefaultColor.SetListRowTint( windowName, rowIndex, isSelected )
    
    if( isSelected == true )
    then
        DefaultColor.SetWindowTint( windowName, DefaultColor.RowColors.SELECTED )
    else        
        local color = DefaultColor.GetRowColor( rowIndex )
        DefaultColor.SetWindowTint( windowName, color )
    end
end

-- Helper function to reduce the really long parameter list of calling LabelSetTextColor
function DefaultColor.LabelSetTextColor(labelName, colorTable)
    LabelSetTextColor (labelName, colorTable.r, colorTable.g, colorTable.b)
end

-- Helper function to reduce the really long parameter list of calling LabelSetTextColor
function DefaultColor.ButtonSetTextColor(labelName, colorTable)
    --DEBUG(L"[DefaultColor.ButtonSetTextColor]   labelName = "..StringToWString(labelName))
    ButtonSetTextColor(labelName, Button.ButtonState.NORMAL, colorTable.r, colorTable.g, colorTable.b)
end

----------------------------------------------------------------
-- Combat Event Colors
----------------------------------------------------------------
DefaultColor.COLOR_INCOMING_DAMAGE           = { r=255, g=0,   b=0   }
DefaultColor.COLOR_OUTGOING_DAMAGE           = { r=235, g=235, b=235 }
DefaultColor.COLOR_INCOMING_SPECIAL_DAMAGE   = { r=255, g=66,  b=0   }
DefaultColor.COLOR_OUTGOING_SPECIAL_DAMAGE   = { r=235, g=215, b=135 }
DefaultColor.COLOR_INCOMING_HEALING          = { r=0,   g=200, b=0   }
DefaultColor.COLOR_OUTGOING_HEALING          = { r=0,   g=138, b=0   }
DefaultColor.COLOR_INCOMING_MISS             = { r=228, g=228, b=228 }
DefaultColor.COLOR_OUTGOING_MISS             = { r=156, g=156, b=156 }
DefaultColor.COLOR_EXPERIENCE_GAIN           = { r=255, g=170, b=0   }
DefaultColor.COLOR_RENOWN_GAIN               = { r=194, g=56,  b=153 }
DefaultColor.COLOR_INFLUENCE_GAIN            = { r=0,   g=170, b=163 }

function DefaultColor.GetCombatEventColor( hitTargetObjectNumber, hitAmount, textType )
    local color = DefaultColor.COLOR_INCOMING_DAMAGE

    if ( hitAmount > 0 )
    then
        if ( hitTargetObjectNumber == GameData.Player.worldObjNum )
        then
            color = DefaultColor.COLOR_INCOMING_HEALING
        else
            color = DefaultColor.COLOR_OUTGOING_HEALING
        end
    elseif ( hitAmount < 0 )
    then
        if ( ( textType == GameData.CombatEvent.HIT ) or 
             ( textType == GameData.CombatEvent.CRITICAL ) )
        then
            if ( hitTargetObjectNumber == GameData.Player.worldObjNum )
            then
                color = DefaultColor.COLOR_INCOMING_DAMAGE
            else
                color = DefaultColor.COLOR_OUTGOING_DAMAGE
            end
        elseif ( ( textType == GameData.CombatEvent.ABILITY_HIT ) or
                 ( textType == GameData.CombatEvent.ABILITY_CRITICAL ) )
        then
            if ( hitTargetObjectNumber == GameData.Player.worldObjNum )
            then
                color = DefaultColor.COLOR_INCOMING_SPECIAL_DAMAGE
            else
                color = DefaultColor.COLOR_OUTGOING_SPECIAL_DAMAGE
            end
        end
    else -- the amount of damage equals zero
        if ( hitTargetObjectNumber == GameData.Player.worldObjNum )
        then
            color = DefaultColor.COLOR_INCOMING_MISS
        else
            color = DefaultColor.COLOR_OUTGOING_MISS
        end
    end

    return color
end

----------------------------------------------------------------
-- Training Colors
----------------------------------------------------------------
DefaultColor.OWNED_SPECIALIZATION_LEVEL_TEXT     = { r=191, g=102, b=0   }

----------------------------------------------------------------
-- Item Rarity Colors
----------------------------------------------------------------

DefaultColor.RARITY_UTILITY    ={ r=150, g=150, b=150 } -- Gray
DefaultColor.RARITY_COMMON ={ r=255, g=255, b=255 } -- White
DefaultColor.RARITY_UNCOMMON = { r= 24, g=240, b=  0 } -- Green
DefaultColor.RARITY_RARE = { r=  0, g=100, b=195 } -- Blue
DefaultColor.RARITY_VERY_RARE = { r=146, g= 56, b=208 }  -- Purple
DefaultColor.RARITY_ARTIFACT = { r=200, g=60, b=0 }  -- Dark Orange

-- this isn't actually a rarity value as much as a special case that we wish to show as a different color regardless of the set item's rarity
DefaultColor.RARITY_ITEM_SET = { r=240, g=190, b=40 } -- Gold

----------------------------------------------------------------
-- Tooltip Colors
----------------------------------------------------------------

DefaultColor.TOOLTIP_HEADING              = { r=255,  g=204,  b=102   }
DefaultColor.TOOLTIP_BODY                 = { r=255,  g=255,  b=255   }
DefaultColor.TOOLTIP_MEETS_REQUIREMENTS   = { r=255,  g=255,  b=255   }
DefaultColor.TOOLTIP_FAILS_REQUIREMENTS   = { r=210,  g=0,    b=0     }
DefaultColor.TOOLTIP_EXTRA_TEXT_DEFAULT   = { r=175,  g=175,  b=175   }
DefaultColor.TOOLTIP_WARNING              = { r=200,  g=0,    b=0     }
DefaultColor.TOOLTIP_ACTION               = { r=0,    g=255,  b=0     }
DefaultColor.TOOLTIP_ITEM_SET_ENABLED     = { r=0,    g=255,  b=0     }
DefaultColor.TOOLTIP_ITEM_SET_DISABLED    = { r=175,  g=175,  b=175   }
DefaultColor.TOOLTIP_ITEM_BONUS           = { r=255,  g=255,  b=0     }
DefaultColor.TOOLTIP_ITEM_DISABLED        = { r=175,  g=175,  b=175   }
DefaultColor.TOOLTIP_ITEM_HIGHLIGHT       = { r=255,  g=255,  b=0     }   -- yellow
DefaultColor.TOOLTIP_DEFAULT_ACTION       = { r=125,  g=125,  b=125   } 
DefaultColor.TOOLTIP_ABILITY_ACTION       = { r=125,  g=125,  b=125   } 

----------------------------------------------------------------
-- Pregame Colors
----------------------------------------------------------------

DefaultColor.PREGAME_RED              = { r=253,  g=54,  b=50   }


----------------------------------------------------------------
-- Ability Type Colors
----------------------------------------------------------------

DefaultColor.AbilityType = {}
DefaultColor.AbilityType.DAMAGING  = { r=255, g=64,  b=33  }
DefaultColor.AbilityType.HEALING   = { r=55,  g=255, b=42  }
DefaultColor.AbilityType.BUFF      = { r=11,  g=55,  b=168 }
DefaultColor.AbilityType.DEBUFF    = { r=250, g=112, b=255 }
DefaultColor.AbilityType.OFFENSIVE = { r=0,   g=255, b=0   }

----------------------------------------------------------------
-- Action Cooldown Colors (and alpha)
----------------------------------------------------------------

DefaultColor.ActionCooldown = { r = 20, g = 20, b = 50, a = .75 }
