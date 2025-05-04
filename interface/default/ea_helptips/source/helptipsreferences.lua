----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

HelpTipsReferences = {}


-- ToK mappings
-- HelpTipsReferences.ToKIdMappings[ TokID ] = { type, relatedWindow }
local function tipTypes( label, variable )
    return { typeLabel = label, typeVar = variable }
end


HelpTipsReferences.MENU_BAR         = "MenuBarWindow"
HelpTipsReferences.ABILITIES_BUTTON = HelpTipsReferences.MENU_BAR.."ToggleAbilitiesWindow"
HelpTipsReferences.BACKPACK_BUTTON  = HelpTipsReferences.MENU_BAR.."ToggleBackpackWindow"
HelpTipsReferences.GUILD_BUTTON     = HelpTipsReferences.MENU_BAR.."ToggleGuildWindow"
HelpTipsReferences.MAIN_MENU_CUSTOMIZE_UI = HelpTipsReferences.MENU_BAR.."ToggleMenuWindow" 
HelpTipsReferences.TOME_BUTTON      = HelpTipsReferences.MENU_BAR.."ToggleTomeWindowNewEntries"
HelpTipsReferences.HELP_BUTTON      = HelpTipsReferences.MENU_BAR.."ToggleHelpWindow"
HelpTipsReferences.HOT_BAR          = "EA_ActionBar1"
HelpTipsReferences.INFLUENCE_BAR    = "EA_Window_PublicQuestTrackerInfluenceBar"
HelpTipsReferences.CHAT_WINDOW      = "EA_ChatWindowGroup1"
HelpTipsReferences.PLAYER_PORTRAIT  = "PlayerWindow"
HelpTipsReferences.ZONE_CONTROL_BAR = "EA_Window_ZoneControl"
HelpTipsReferences.XP_BAR           = "XpBarWindow"
HelpTipsReferences.TARGET_PORTRAIT  = "TargetWindow"
HelpTipsReferences.OPEN_PARTIES     = "OpenPartiesSearchButton"
HelpTipsReferences.PQ_TRACKER       = "EA_Window_PublicQuestTracker"
HelpTipsReferences.QUEST_TRACKER    = "EA_Window_QuestTracker"
HelpTipsReferences.RENOWN_BAR       = "RpBarWindow"
HelpTipsReferences.MAP_WINDOW       = "EA_Window_OverheadMap"
HelpTipsReferences.SCENARIOS_BUTTON = HelpTipsReferences.MAP_WINDOW.."MapScenarioQueue"
HelpTipsReferences.TACTICS_BAR      = "EA_TacticsEditor"
HelpTipsReferences.MORALE_BAR       = "EA_MoraleBar"


HelpTipsReferences.ToKIdMappings = 
{
    [11800] = HelpTipsReferences.ABILITIES_BUTTON,
    [11801] = HelpTipsReferences.HOT_BAR,
    [11805] = HelpTipsReferences.ABILITIES_BUTTON,
    [11809] = HelpTipsReferences.BACKPACK_BUTTON,
    [11822] = HelpTipsReferences.INFLUENCE_BAR,
    [11823] = HelpTipsReferences.CHAT_WINDOW,
    [11824] = HelpTipsReferences.CHAT_WINDOW,
    [11826] = HelpTipsReferences.PLAYER_PORTRAIT,
    [11827] = HelpTipsReferences.ZONE_CONTROL_BAR,
    [11828] = HelpTipsReferences.HOT_BAR,
    [11835] = HelpTipsReferences.ABILITIES_BUTTON,
    [11840] = HelpTipsReferences.XP_BAR,
    --[11843] = Mail icon,
    [11845] = HelpTipsReferences.TARGET_PORTRAIT,
    [11851] = HelpTipsReferences.GUILD_BUTTON,
    [11854] = HelpTipsReferences.PLAYER_PORTRAIT,
    [11856] = HelpTipsReferences.HELP_BUTTON,
    [11859] = HelpTipsReferences.INFLUENCE_BAR,
    [11866] = HelpTipsReferences.PLAYER_PORTRAIT,
	--Mail icon
    [11869] = HelpTipsReferences.MAIN_MENU_CUSTOMIZE_UI,
    [11872] = HelpTipsReferences.TARGET_PORTRAIT,
    [11873] = HelpTipsReferences.TARGET_PORTRAIT,
    [11874] = HelpTipsReferences.MORALE_BAR,
	--Open Parties button
    [11880] = HelpTipsReferences.PQ_TRACKER,
    [11881] = HelpTipsReferences.PQ_TRACKER,
    [11882] = HelpTipsReferences.QUEST_TRACKER,
    [11883] = HelpTipsReferences.QUEST_TRACKER,
    [11885] = HelpTipsReferences.PLAYER_PORTRAIT,
    [11889] = HelpTipsReferences.RENOWN_BAR,
    [11896] = HelpTipsReferences.PLAYER_PORTRAIT,
    [11900] = HelpTipsReferences.SCENARIOS_BUTTON,
    [11908] = HelpTipsReferences.TACTICS_BAR,
    [11913] = HelpTipsReferences.TOME_BUTTON,
    [11919] = HelpTipsReferences.ZONE_CONTROL_BAR,
    [11921] = HelpTipsReferences.ZONE_CONTROL_BAR,
    [11950] = HelpTipsReferences.ZONE_CONTROL_BAR
}

HelpTipsReferences.TipTypes =
{
    [1] = tipTypes( GetString( StringTables.Default.LABEL_SHOW_BEGINNER_TIPS ),  SystemData.Settings.GamePlay.showBeginnerHelpTips ),
    [2] = tipTypes( GetString( StringTables.Default.LABEL_SHOW_GAMEPLAY_TIPS ), SystemData.Settings.GamePlay.showGameplayHelpTips ),
    [3] = tipTypes( GetString( StringTables.Default.LABEL_SHOW_UI_TIPS ), SystemData.Settings.GamePlay.showUiHelpTips ),
    [4] = tipTypes( GetString( StringTables.Default.LABEL_SHOW_ADVANCED_TIPS ), SystemData.Settings.GamePlay.showAdvancedHelpTips )
}


