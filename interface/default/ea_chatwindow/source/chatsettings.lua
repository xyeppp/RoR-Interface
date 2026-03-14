----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

ChatSettings = {}

ChatSettings.Channels = {}
ChatSettings.ChannelSwitches = {}

----------------------------------------------------------------
-- Saved Variables
----------------------------------------------------------------

ChatSettings.ChannelColors = {}

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------
 -- This is so that we can have different chat settings per territory
local koreaChatSettings = {}
local everywhereElseChatSettings = {}

local function SwitchText( switch, replace, remember )
    return { commands = switch, replacement = replace, rememberChan = remember }
end

local function BuildSlashCommands( commandStr )
    local commandTable = {};
    local commandList = WStringSplit( commandStr );
    
    for val, cmd in pairs(commandList) do
        if ( cmd ~= L"" ) then
            commandTable[ cmd..L" " ] = 1;
        end
    end
    
    return commandTable;
end

local function ChannelColor( red, green, blue )
    return { r = red, g = green, b = blue }
end

local function ChatChannel( iname, iid, ilogName, ionFlag, iColor, iswitchTextIdx, icmd )
    local newChannel = 
    {
        name         = iname,
        id           = iid,
        logName      = ilogName,
        isOn         = ionFlag,
        defaultColor = iColor
    };

    if ( iswitchTextIdx and icmd )
    then
        newChannel.slashCmds    = BuildSlashCommands( ChatSettings.ChannelSwitches[iswitchTextIdx].commands )
        newChannel.labelText    = ChatSettings.ChannelSwitches[iswitchTextIdx].replacement
        newChannel.serverCmd    = icmd
        newChannel.remember     = ChatSettings.ChannelSwitches[iswitchTextIdx].rememberChan
    end

    return newChannel;
end

local function Font( iname, iid, idefault, ishownName )
    local newChannel = 
    {
        fontName         = iname,
        id           = iid,
        isDefault    = idefault,
        shownName    = ishownName,
    };

    return newChannel;
end

local function CopyChannel( sourceTable, channelIndex, destTable, isOnInDest, newColor )
    destTable.Channels[ channelIndex ] = DataUtils.CopyTable( sourceTable.Channels[ channelIndex ] )
    destTable.Channels[ channelIndex ].isOn = isOnInDest

    if( newColor )
    then
        destTable.Channels[ channelIndex ].color = newColor
    end

end

----------------------------------------------------------------
-- ChatSettings Functions
----------------------------------------------------------------

function ChatSettings.SetupChannels()

    ChatSettings.ChannelSwitches = {}
    ChatSettings.ChannelSwitches[ SystemData.ChatLogFilters.SAY ]               = SwitchText( GetChatString(StringTables.Chat.CHAT_CHANNEL_SWITCH_SAY)..L" ", GetChatString(StringTables.Chat.CHAT_CHANNEL_REPLACE_SAY), true )
    ChatSettings.ChannelSwitches[ SystemData.ChatLogFilters.TELL_RECEIVE ]      = SwitchText( L"", L"", false )
    ChatSettings.ChannelSwitches[ SystemData.ChatLogFilters.TELL_SEND ]         = SwitchText( GetChatString(StringTables.Chat.CHAT_CHANNEL_SWITCH_TELL)..L" ", GetChatString(StringTables.Chat.CHAT_CHANNEL_REPLACE_TELL), false )
    ChatSettings.ChannelSwitches[ SystemData.ChatLogFilters.GROUP ]             = SwitchText( GetChatString(StringTables.Chat.CHAT_CHANNEL_SWITCH_GROUP)..L" ", GetChatString(StringTables.Chat.CHAT_CHANNEL_REPLACE_GROUP), true )
    ChatSettings.ChannelSwitches[ SystemData.ChatLogFilters.MONSTER_SAY ]       = SwitchText( L"", L"", true )
    ChatSettings.ChannelSwitches[ SystemData.ChatLogFilters.DEBUG ]             = SwitchText( L"", L"", true )
    ChatSettings.ChannelSwitches[ SystemData.ChatLogFilters.GUILD ]             = SwitchText( GetChatString(StringTables.Chat.CHAT_CHANNEL_SWITCH_GUILD)..L" ", GetChatString(StringTables.Chat.CHAT_CHANNEL_REPLACE_GUILD), true )
    ChatSettings.ChannelSwitches[ SystemData.ChatLogFilters.GUILD_OFFICER ]     = SwitchText( GetChatString(StringTables.Chat.CHAT_CHANNEL_SWITCH_OFFICER)..L" ", GetChatString(StringTables.Chat.CHAT_CHANNEL_REPLACE_OFFICER), true )
    ChatSettings.ChannelSwitches[ SystemData.ChatLogFilters.EMOTE ]             = SwitchText( GetChatString(StringTables.Chat.CHAT_CHANNEL_SWITCH_EMOTE)..L" ", GetChatString(StringTables.Chat.CHAT_CHANNEL_REPLACE_EMOTE), true )
    ChatSettings.ChannelSwitches[ SystemData.ChatLogFilters.MONSTER_EMOTE ]     = SwitchText( L"", L"", true )
    ChatSettings.ChannelSwitches[ SystemData.ChatLogFilters.SHOUT ]             = SwitchText( GetChatString(StringTables.Chat.CHAT_CHANNEL_SWITCH_SHOUT)..L" ", GetChatString(StringTables.Chat.CHAT_CHANNEL_REPLACE_SHOUT), true )
    ChatSettings.ChannelSwitches[ SystemData.ChatLogFilters.ALLIANCE ]          = SwitchText( GetChatString(StringTables.Chat.CHAT_CHANNEL_SWITCH_ALLIANCE)..L" ", GetChatString(StringTables.Chat.CHAT_CHANNEL_REPLACE_ALLIANCE), true )
    ChatSettings.ChannelSwitches[ SystemData.ChatLogFilters.ALLIANCE_OFFICER ]  = SwitchText( GetChatString(StringTables.Chat.CHAT_CHANNEL_SWITCH_ALLIANCE_OFFICER)..L" ", GetChatString(StringTables.Chat.CHAT_CHANNEL_REPLACE_ALLIANCE_OFFICER), true )
    ChatSettings.ChannelSwitches[ SystemData.ChatLogFilters.BATTLEGROUP ]       = SwitchText( GetChatString(StringTables.Chat.CHAT_CHANNEL_SWITCH_BATTLEGROUP)..L" ", GetChatString(StringTables.Chat.CHAT_CHANNEL_REPLACE_BATTLEGROUP), true )
    ChatSettings.ChannelSwitches[ SystemData.ChatLogFilters.SCENARIO ]          = SwitchText( GetChatString(StringTables.Chat.CHAT_CHANNEL_SWITCH_SCENARIO)..L" ", GetChatString(StringTables.Chat.CHAT_CHANNEL_REPLACE_SCENARIO), true )
    ChatSettings.ChannelSwitches[ SystemData.ChatLogFilters.SCENARIO_GROUPS ]   = SwitchText( GetChatString(StringTables.Chat.CHAT_CHANNEL_SWITCH_SCENARIO_GROUP)..L" ", GetChatString(StringTables.Chat.CHAT_CHANNEL_REPLACE_SCENARIO_GROUP), true )
    ChatSettings.ChannelSwitches[ SystemData.ChatLogFilters.ADVICE ]            = SwitchText( GetChatString(StringTables.Chat.CHAT_CHANNEL_SWITCH_ADVICE)..L" ", GetChatString(StringTables.Chat.CHAT_CHANNEL_REPLACE_ADVICE), true )
    ChatSettings.ChannelSwitches[ SystemData.ChatLogFilters.REALM_WAR_T1 ]      = SwitchText( GetChatString(StringTables.Chat.CHAT_CHANNEL_SWITCH_REALM_WAR_T1)..L" ", GetChatString(StringTables.Chat.CHAT_CHANNEL_REPLACE_REALM_WAR_T1), true )
    ChatSettings.ChannelSwitches[ SystemData.ChatLogFilters.REALM_WAR_T2 ]      = SwitchText( GetChatString(StringTables.Chat.CHAT_CHANNEL_SWITCH_REALM_WAR_T2)..L" ", GetChatString(StringTables.Chat.CHAT_CHANNEL_REPLACE_REALM_WAR_T2), true )
    ChatSettings.ChannelSwitches[ SystemData.ChatLogFilters.REALM_WAR_T3 ]      = SwitchText( GetChatString(StringTables.Chat.CHAT_CHANNEL_SWITCH_REALM_WAR_T3)..L" ", GetChatString(StringTables.Chat.CHAT_CHANNEL_REPLACE_REALM_WAR_T3), true )
    ChatSettings.ChannelSwitches[ SystemData.ChatLogFilters.REALM_WAR_T4 ]      = SwitchText( GetChatString(StringTables.Chat.CHAT_CHANNEL_SWITCH_REALM_WAR_T4)..L" ", GetChatString(StringTables.Chat.CHAT_CHANNEL_REPLACE_REALM_WAR_T4), true )
    ChatSettings.ChannelSwitches[ SystemData.ChatLogFilters.CHANNEL_1 ]         = SwitchText( GetChatString(StringTables.Chat.CHAT_CHANNEL_SWITCH_CHANNEL_1)..L" ", GetChatString(StringTables.Chat.CHAT_CHANNEL_REPLACE_CHANNEL_1), true )
    ChatSettings.ChannelSwitches[ SystemData.ChatLogFilters.CHANNEL_2 ]         = SwitchText( GetChatString(StringTables.Chat.CHAT_CHANNEL_SWITCH_CHANNEL_2)..L" ", GetChatString(StringTables.Chat.CHAT_CHANNEL_REPLACE_CHANNEL_2), true )
    ChatSettings.ChannelSwitches[ SystemData.ChatLogFilters.CHANNEL_3 ]         = SwitchText( GetChatString(StringTables.Chat.CHAT_CHANNEL_SWITCH_CHANNEL_3)..L" ", GetChatString(StringTables.Chat.CHAT_CHANNEL_REPLACE_CHANNEL_3), true )
    ChatSettings.ChannelSwitches[ SystemData.ChatLogFilters.CHANNEL_4 ]         = SwitchText( GetChatString(StringTables.Chat.CHAT_CHANNEL_SWITCH_CHANNEL_4)..L" ", GetChatString(StringTables.Chat.CHAT_CHANNEL_REPLACE_CHANNEL_4), true )
    ChatSettings.ChannelSwitches[ SystemData.ChatLogFilters.CHANNEL_5 ]         = SwitchText( GetChatString(StringTables.Chat.CHAT_CHANNEL_SWITCH_CHANNEL_5)..L" ", GetChatString(StringTables.Chat.CHAT_CHANNEL_REPLACE_CHANNEL_5), true )
    ChatSettings.ChannelSwitches[ SystemData.ChatLogFilters.CHANNEL_6 ]         = SwitchText( GetChatString(StringTables.Chat.CHAT_CHANNEL_SWITCH_CHANNEL_6)..L" ", GetChatString(StringTables.Chat.CHAT_CHANNEL_REPLACE_CHANNEL_6), true )
    ChatSettings.ChannelSwitches[ SystemData.ChatLogFilters.CHANNEL_7 ]         = SwitchText( GetChatString(StringTables.Chat.CHAT_CHANNEL_SWITCH_CHANNEL_7)..L" ", GetChatString(StringTables.Chat.CHAT_CHANNEL_REPLACE_CHANNEL_7), true )
    ChatSettings.ChannelSwitches[ SystemData.ChatLogFilters.CHANNEL_8 ]         = SwitchText( GetChatString(StringTables.Chat.CHAT_CHANNEL_SWITCH_CHANNEL_8)..L" ", GetChatString(StringTables.Chat.CHAT_CHANNEL_REPLACE_CHANNEL_8), true )
    ChatSettings.ChannelSwitches[ SystemData.ChatLogFilters.CHANNEL_9 ]         = SwitchText( GetChatString(StringTables.Chat.CHAT_CHANNEL_SWITCH_CHANNEL_9)..L" ", GetChatString(StringTables.Chat.CHAT_CHANNEL_REPLACE_CHANNEL_9), true )

    ChatSettings.Channels = {}
    --                                                                                       Channel Name                                                                Channel Id                                          Log Name    Filter On By Default    Default Color                   ChannelSwitches id                          Channel commands (what gets sent to the server to echo the text.)
    ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    ChatSettings.Channels[ SystemData.ChatLogFilters.SAY ]                    = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_SAY),                      SystemData.ChatLogFilters.SAY,                      "Chat",     true,                   ChannelColor(235, 235, 235),    SystemData.ChatLogFilters.SAY,              GetChatString(StringTables.Chat.CHAT_CHANNEL_CMD_SAY) )
    ChatSettings.Channels[ SystemData.ChatLogFilters.TELL_RECEIVE ]           = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_TELL_RECEIVED),            SystemData.ChatLogFilters.TELL_RECEIVE,             "Chat",     true,                   ChannelColor(32, 134, 229),     SystemData.ChatLogFilters.TELL_RECEIVE,     L"" )
    ChatSettings.Channels[ SystemData.ChatLogFilters.TELL_SEND ]              = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_TELL_SENT),                SystemData.ChatLogFilters.TELL_SEND,                "Chat",     true,                   ChannelColor(32, 134, 229),     SystemData.ChatLogFilters.TELL_SEND,        GetChatString(StringTables.Chat.CHAT_CHANNEL_CMD_TELL) )
    ChatSettings.Channels[ SystemData.ChatLogFilters.GROUP ]                  = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_GROUP),                    SystemData.ChatLogFilters.GROUP,                    "Chat",     true,                   ChannelColor(29, 217, 33),      SystemData.ChatLogFilters.GROUP,            GetChatString(StringTables.Chat.CHAT_CHANNEL_CMD_GROUP) )
    ChatSettings.Channels[ SystemData.ChatLogFilters.BATTLEGROUP ]            = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_BATTLEGROUP),              SystemData.ChatLogFilters.BATTLEGROUP,              "Chat",     true,                   ChannelColor(178, 255, 116),    SystemData.ChatLogFilters.BATTLEGROUP,      GetChatString(StringTables.Chat.CHAT_CHANNEL_CMD_BATTLEGROUP) )
    ChatSettings.Channels[ SystemData.ChatLogFilters.MONSTER_SAY ]            = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_MONSTER),                  SystemData.ChatLogFilters.MONSTER_SAY,              "Chat",     false,                  ChannelColor(190, 190, 190),    SystemData.ChatLogFilters.MONSTER_SAY,      L"" )
    ChatSettings.Channels[ SystemData.ChatLogFilters.DEBUG ]                  = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_DEBUG),                    SystemData.ChatLogFilters.DEBUG,                    "Chat",     false,                  ChannelColor(255, 255, 1),      SystemData.ChatLogFilters.DEBUG,            L"" )
    ChatSettings.Channels[ SystemData.ChatLogFilters.GUILD ]                  = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_GUILD),                    SystemData.ChatLogFilters.GUILD,                    "Chat",     true,                   DefaultColor.ChatChannelColors[SystemData.ChatLogFilters.GUILD],    SystemData.ChatLogFilters.GUILD,            GetChatString(StringTables.Chat.CHAT_CHANNEL_CMD_GUILD) )
    ChatSettings.Channels[ SystemData.ChatLogFilters.GUILD_OFFICER ]          = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_OFFICER),                  SystemData.ChatLogFilters.GUILD_OFFICER,            "Chat",     true,                   ChannelColor(144, 237, 250),    SystemData.ChatLogFilters.GUILD_OFFICER,    GetChatString(StringTables.Chat.CHAT_CHANNEL_CMD_OFFICER) )
    ChatSettings.Channels[ SystemData.ChatLogFilters.EMOTE ]                  = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_EMOTE),                    SystemData.ChatLogFilters.EMOTE,                    "Chat",     true,                   ChannelColor(238, 113, 21),     SystemData.ChatLogFilters.EMOTE,            GetChatString(StringTables.Chat.CHAT_CHANNEL_CMD_EMOTE) )
    ChatSettings.Channels[ SystemData.ChatLogFilters.MONSTER_EMOTE ]          = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_MONSTER_EMOTE),            SystemData.ChatLogFilters.MONSTER_EMOTE,            "Chat",     false,                  ChannelColor(238, 113, 21),     SystemData.ChatLogFilters.MONSTER_EMOTE,    L"")
    ChatSettings.Channels[ SystemData.ChatLogFilters.SHOUT ]                  = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_SHOUT),                    SystemData.ChatLogFilters.SHOUT,                    "Chat",     true,                   ChannelColor(239, 221, 19),    SystemData.ChatLogFilters.SHOUT,            GetChatString(StringTables.Chat.CHAT_CHANNEL_CMD_SHOUT) )
    ChatSettings.Channels[ SystemData.ChatLogFilters.ALLIANCE ]               = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_ALLIANCE),                 SystemData.ChatLogFilters.ALLIANCE,                 "Chat",     true,                   DefaultColor.ChatChannelColors[SystemData.ChatLogFilters.ALLIANCE],     SystemData.ChatLogFilters.ALLIANCE,         GetChatString(StringTables.Chat.CHAT_CHANNEL_CMD_ALLIANCE) )
    ChatSettings.Channels[ SystemData.ChatLogFilters.ALLIANCE_OFFICER ]       = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_ALLIANCE_OFFICER),         SystemData.ChatLogFilters.ALLIANCE_OFFICER,         "Chat",     true,                   ChannelColor(18, 202, 209),     SystemData.ChatLogFilters.ALLIANCE_OFFICER, GetChatString(StringTables.Chat.CHAT_CHANNEL_CMD_ALLIANCE_OFFICER) )
    ChatSettings.Channels[ SystemData.ChatLogFilters.SCENARIO ]               = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_SCENARIO),                 SystemData.ChatLogFilters.SCENARIO,                 "Chat",     true,                   ChannelColor(231, 189, 115),    SystemData.ChatLogFilters.SCENARIO,         GetChatString(StringTables.Chat.CHAT_CHANNEL_CMD_SCENARIO) )
    ChatSettings.Channels[ SystemData.ChatLogFilters.SCENARIO_GROUPS ]        = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_SCENARIO_GROUP),           SystemData.ChatLogFilters.SCENARIO_GROUPS,          "Chat",     true,                   ChannelColor(231, 189, 115),    SystemData.ChatLogFilters.SCENARIO_GROUPS,  GetChatString(StringTables.Chat.CHAT_CHANNEL_CMD_SCENARIO_GROUP) )
    ChatSettings.Channels[ SystemData.ChatLogFilters.RVR ]                    = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_RVR),                      SystemData.ChatLogFilters.RVR,                      "Chat",     true,                   ChannelColor(55, 65, 248) )
    ChatSettings.Channels[ SystemData.ChatLogFilters.CITY_ANNOUNCE ]          = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_CITY_ANNOUNCE),            SystemData.ChatLogFilters.CITY_ANNOUNCE,            "Chat",     true,                   ChannelColor(32, 224, 32) )
    ChatSettings.Channels[ SystemData.ChatLogFilters.KILLS_DEATH_YOURS ]      = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_KILLS_DEATH_YOURS),        SystemData.ChatLogFilters.KILLS_DEATH_YOURS,        "Chat",     true,                   ChannelColor(235, 235, 235) )
    ChatSettings.Channels[ SystemData.ChatLogFilters.KILLS_DEATH_OTHER ]      = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_KILLS_DEATH_OTHER),        SystemData.ChatLogFilters.KILLS_DEATH_OTHER,        "Chat",     false,                  ChannelColor(235, 235, 235) )
    ChatSettings.Channels[ SystemData.ChatLogFilters.ZONE_AREA ]              = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_ZONE_AREA),                SystemData.ChatLogFilters.ZONE_AREA,                "Chat",     true,                   ChannelColor(235, 235, 235) )
    ChatSettings.Channels[ SystemData.ChatLogFilters.QUEST ]                  = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_QUEST),                    SystemData.ChatLogFilters.QUEST,                    "Chat",     true,                   ChannelColor(251, 236, 3) )
    ChatSettings.Channels[ SystemData.ChatLogFilters.LOOT ]                   = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_LOOT),                     SystemData.ChatLogFilters.LOOT,                     "Chat",     true,                   ChannelColor(219, 159, 162) )
    ChatSettings.Channels[ SystemData.ChatLogFilters.LOOT_COIN ]              = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_LOOT_COIN),                SystemData.ChatLogFilters.LOOT_COIN,                "Chat",     true,                   ChannelColor(222, 197, 165) )
    ChatSettings.Channels[ SystemData.ChatLogFilters.LOOT_ROLL ]              = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_LOOT_ROLL),                SystemData.ChatLogFilters.LOOT_ROLL,                "Chat",     true,                   ChannelColor(121, 92, 99) )
    ChatSettings.Channels[ SystemData.ChatLogFilters.TRADE ]                  = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_TRADE),                    SystemData.ChatLogFilters.TRADE,                    "Chat",     true,                   ChannelColor(110, 110, 110) )
    ChatSettings.Channels[ SystemData.ChatLogFilters.CRAFTING ]               = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_CRAFTING),                 SystemData.ChatLogFilters.CRAFTING,                 "Chat",     true,                   ChannelColor(165, 159, 73) )
    ChatSettings.Channels[ SystemData.ChatLogFilters.USER_ERROR ]             = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_USER_ERROR),               SystemData.ChatLogFilters.USER_ERROR,               "Chat",     true,                   ChannelColor(150, 150, 150) ) 
    ChatSettings.Channels[ SystemData.ChatLogFilters.MISC ]                   = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_MISC),                     SystemData.ChatLogFilters.MISC,                     "Chat",     true,                   ChannelColor(110, 110, 110) )
    ChatSettings.Channels[ SystemData.ChatLogFilters.ADVICE ]                 = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_ADVICE),                   SystemData.ChatLogFilters.ADVICE,                   "Chat",     true,                   ChannelColor(255, 128, 0),      SystemData.ChatLogFilters.ADVICE,           GetChatString(StringTables.Chat.CHAT_CHANNEL_CMD_ADVICE) ) 
    ChatSettings.Channels[ SystemData.ChatLogFilters.REALM_WAR_T1 ]           = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_REALM_WAR_T1),             SystemData.ChatLogFilters.REALM_WAR_T1,             "Chat",     true,                   DefaultColor.ChatChannelColors[SystemData.ChatLogFilters.REALM_WAR_T1],      SystemData.ChatLogFilters.REALM_WAR_T1,           GetChatString(StringTables.Chat.CHAT_CHANNEL_CMD_REALM_WAR_T1) ) 
    ChatSettings.Channels[ SystemData.ChatLogFilters.REALM_WAR_T2 ]           = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_REALM_WAR_T2),             SystemData.ChatLogFilters.REALM_WAR_T2,             "Chat",     true,                   DefaultColor.ChatChannelColors[SystemData.ChatLogFilters.REALM_WAR_T1],      SystemData.ChatLogFilters.REALM_WAR_T2,           GetChatString(StringTables.Chat.CHAT_CHANNEL_CMD_REALM_WAR_T2) ) 
    ChatSettings.Channels[ SystemData.ChatLogFilters.REALM_WAR_T3 ]           = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_REALM_WAR_T3),             SystemData.ChatLogFilters.REALM_WAR_T3,             "Chat",     true,                   DefaultColor.ChatChannelColors[SystemData.ChatLogFilters.REALM_WAR_T1],      SystemData.ChatLogFilters.REALM_WAR_T3,           GetChatString(StringTables.Chat.CHAT_CHANNEL_CMD_REALM_WAR_T3) ) 
    ChatSettings.Channels[ SystemData.ChatLogFilters.REALM_WAR_T4 ]           = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_REALM_WAR_T4),             SystemData.ChatLogFilters.REALM_WAR_T4,             "Chat",     true,                   DefaultColor.ChatChannelColors[SystemData.ChatLogFilters.REALM_WAR_T1],      SystemData.ChatLogFilters.REALM_WAR_T4,           GetChatString(StringTables.Chat.CHAT_CHANNEL_CMD_REALM_WAR_T4) ) 
    ChatSettings.Channels[ SystemData.ChatLogFilters.CHANNEL_1 ]              = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_CHANNEL_1),                SystemData.ChatLogFilters.CHANNEL_1,                "Chat",     true,                   ChannelColor(231, 189, 115),    SystemData.ChatLogFilters.CHANNEL_1,        GetChatString(StringTables.Chat.CHAT_CHANNEL_CMD_CHANNEL_1) )
    ChatSettings.Channels[ SystemData.ChatLogFilters.CHANNEL_2 ]              = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_CHANNEL_2),                SystemData.ChatLogFilters.CHANNEL_2,                "Chat",     true,                   ChannelColor(231, 189, 115),    SystemData.ChatLogFilters.CHANNEL_2,        GetChatString(StringTables.Chat.CHAT_CHANNEL_CMD_CHANNEL_2) )
    ChatSettings.Channels[ SystemData.ChatLogFilters.CHANNEL_3 ]              = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_CHANNEL_3),                SystemData.ChatLogFilters.CHANNEL_3,                "Chat",     true,                   ChannelColor(235, 235, 235),    SystemData.ChatLogFilters.CHANNEL_3,        GetChatString(StringTables.Chat.CHAT_CHANNEL_CMD_CHANNEL_3) )
    ChatSettings.Channels[ SystemData.ChatLogFilters.CHANNEL_4 ]              = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_CHANNEL_4),                SystemData.ChatLogFilters.CHANNEL_4,                "Chat",     true,                   ChannelColor(235, 235, 235),    SystemData.ChatLogFilters.CHANNEL_4,        GetChatString(StringTables.Chat.CHAT_CHANNEL_CMD_CHANNEL_4) )
    ChatSettings.Channels[ SystemData.ChatLogFilters.CHANNEL_5 ]              = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_CHANNEL_5),                SystemData.ChatLogFilters.CHANNEL_5,                "Chat",     true,                   ChannelColor(235, 235, 235),    SystemData.ChatLogFilters.CHANNEL_5,        GetChatString(StringTables.Chat.CHAT_CHANNEL_CMD_CHANNEL_5) )
    ChatSettings.Channels[ SystemData.ChatLogFilters.CHANNEL_6 ]              = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_CHANNEL_6),                SystemData.ChatLogFilters.CHANNEL_6,                "Chat",     true,                   ChannelColor(235, 235, 235),    SystemData.ChatLogFilters.CHANNEL_6,        GetChatString(StringTables.Chat.CHAT_CHANNEL_CMD_CHANNEL_6) )
    ChatSettings.Channels[ SystemData.ChatLogFilters.CHANNEL_7 ]              = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_CHANNEL_7),                SystemData.ChatLogFilters.CHANNEL_7,                "Chat",     true,                   ChannelColor(235, 235, 235),    SystemData.ChatLogFilters.CHANNEL_7,        GetChatString(StringTables.Chat.CHAT_CHANNEL_CMD_CHANNEL_7) )
    ChatSettings.Channels[ SystemData.ChatLogFilters.CHANNEL_8 ]              = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_CHANNEL_8),                SystemData.ChatLogFilters.CHANNEL_8,                "Chat",     true,                   ChannelColor(235, 235, 235),    SystemData.ChatLogFilters.CHANNEL_8,        GetChatString(StringTables.Chat.CHAT_CHANNEL_CMD_CHANNEL_8) )
    ChatSettings.Channels[ SystemData.ChatLogFilters.CHANNEL_9 ]              = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_CHANNEL_9),                SystemData.ChatLogFilters.CHANNEL_9,                "Chat",     false,                  ChannelColor(235, 235, 235),    SystemData.ChatLogFilters.CHANNEL_9,        GetChatString(StringTables.Chat.CHAT_CHANNEL_CMD_CHANNEL_9) )
    ChatSettings.Channels[ SystemData.ChatLogFilters.COMBAT_DEFAULT ]         = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_COMBAT_DEFAULT),           SystemData.ChatLogFilters.COMBAT_DEFAULT,           "Combat",   true,                   ChannelColor(235, 235, 235) ) 
    ChatSettings.Channels[ SystemData.ChatLogFilters.YOUR_DMG_FROM_PC ]       = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_YOUR_DMG_PC),              SystemData.ChatLogFilters.YOUR_DMG_FROM_PC,         "Combat",   true,                   ChannelColor(217, 28, 28) )
    ChatSettings.Channels[ SystemData.ChatLogFilters.YOUR_DMG_FROM_NPC ]      = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_YOUR_DMG_NPC),             SystemData.ChatLogFilters.YOUR_DMG_FROM_NPC,        "Combat",   true,                   ChannelColor(235, 100, 100) )
    ChatSettings.Channels[ SystemData.ChatLogFilters.YOUR_HITS ]              = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_YOUR_HITS),                SystemData.ChatLogFilters.YOUR_HITS,                "Combat",   true,                   ChannelColor(238, 113, 21) )
    ChatSettings.Channels[ SystemData.ChatLogFilters.YOUR_HEALS ]             = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_YOUR_HEALS),               SystemData.ChatLogFilters.YOUR_HEALS,               "Combat",   true,                   ChannelColor(34, 139, 34) )
    ChatSettings.Channels[ SystemData.ChatLogFilters.OTHER_HITS ]             = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_OTHER_HITS),               SystemData.ChatLogFilters.OTHER_HITS,               "Combat",   true,                   ChannelColor(110, 110, 110) ) 
    ChatSettings.Channels[ SystemData.ChatLogFilters.PET_DMG ]                = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_PET_DMG),                  SystemData.ChatLogFilters.PET_DMG,                  "Combat",   true,                   ChannelColor(235, 213, 135) ) 
    ChatSettings.Channels[ SystemData.ChatLogFilters.PET_HITS ]               = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_PET_HITS),                 SystemData.ChatLogFilters.PET_HITS,                 "Combat",   true,                   ChannelColor(235, 213, 135) ) 
    ChatSettings.Channels[ SystemData.ChatLogFilters.RVR_KILLS_ORDER ]        = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_RVR_KILLS_ORDER),          SystemData.ChatLogFilters.RVR_KILLS_ORDER,          "Combat",   true,                   ChannelColor(0, 148, 225) )
    ChatSettings.Channels[ SystemData.ChatLogFilters.RVR_KILLS_DESTRUCTION ]  = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_RVR_KILLS_DESTRUCTION),    SystemData.ChatLogFilters.RVR_KILLS_DESTRUCTION,    "Combat",   true,                   ChannelColor(255, 39, 39) ) 
    ChatSettings.Channels[ SystemData.ChatLogFilters.EXP ]                    = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_EXP),                      SystemData.ChatLogFilters.EXP,                      "Combat",   true,                   ChannelColor(255, 168, 5) ) 
    ChatSettings.Channels[ SystemData.ChatLogFilters.RENOWN ]                 = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_RENOWN),                   SystemData.ChatLogFilters.RENOWN,                   "Combat",   true,                   ChannelColor(195, 54, 150) ) 
    ChatSettings.Channels[ SystemData.ChatLogFilters.INFL ]                   = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_INFL),                     SystemData.ChatLogFilters.INFL,                     "Combat",   true,                   ChannelColor(1, 167, 165) ) 
    ChatSettings.Channels[ SystemData.ChatLogFilters.TOK ]                    = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_TOK),                      SystemData.ChatLogFilters.TOK,                      "Combat",   true,                   ChannelColor(55, 65, 248) ) 
    ChatSettings.Channels[ SystemData.ChatLogFilters.ABILITY_ERROR ]          = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_ABILITY_ERROR),            SystemData.ChatLogFilters.ABILITY_ERROR,            "Combat",   true,                   ChannelColor(110, 110, 110) )
    ChatSettings.Channels[ SystemData.SystemLogFilters.GENERAL ]              = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_SYSTEM_GENERAL),           SystemData.SystemLogFilters.GENERAL,                "System",   false,                  ChannelColor(DefaultColor.CLEAR_WHITE.r, DefaultColor.CLEAR_WHITE.g, DefaultColor.CLEAR_WHITE.b) ) 
    ChatSettings.Channels[ SystemData.SystemLogFilters.NOTICE ]               = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_SYSTEM_NOTICE),            SystemData.SystemLogFilters.NOTICE,                 "System",   false,                  ChannelColor(DefaultColor.YELLOW.r, DefaultColor.YELLOW.g, DefaultColor.YELLOW.b) ) 
    ChatSettings.Channels[ SystemData.SystemLogFilters.ERROR ]                = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_SYSTEM_ERROR),             SystemData.SystemLogFilters.ERROR,                  "System",   false,                  ChannelColor(DefaultColor.ORANGE.r, DefaultColor.ORANGE.g, DefaultColor.ORANGE.b) ) 

    if ( IsInternalBuild() == true and SystemData.ChatLogFilters.COMBAT_DEBUG ~= nil ) then
        ChatSettings.Channels[ SystemData.ChatLogFilters.COMBAT_DEBUG ]       = ChatChannel( GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_COMBAT_DEBUG),             SystemData.ChatLogFilters.COMBAT_DEBUG,             "Combat",   true,                   ChannelColor(235, 235, 235) )
    end

    -- Korea Differences from the default version
    koreaChatSettings.Channels = {}
    CopyChannel( ChatSettings, SystemData.ChatLogFilters.RVR, koreaChatSettings, false )
    CopyChannel( ChatSettings, SystemData.ChatLogFilters.CITY_ANNOUNCE, koreaChatSettings, false )
    CopyChannel( ChatSettings, SystemData.ChatLogFilters.KILLS_DEATH_YOURS, koreaChatSettings, false )
    CopyChannel( ChatSettings, SystemData.ChatLogFilters.ZONE_AREA, koreaChatSettings, false )
    CopyChannel( ChatSettings, SystemData.ChatLogFilters.QUEST, koreaChatSettings, false )
    CopyChannel( ChatSettings, SystemData.ChatLogFilters.LOOT, koreaChatSettings, false )
    CopyChannel( ChatSettings, SystemData.ChatLogFilters.LOOT_COIN, koreaChatSettings, false )
    CopyChannel( ChatSettings, SystemData.ChatLogFilters.LOOT_ROLL, koreaChatSettings, false )
    CopyChannel( ChatSettings, SystemData.ChatLogFilters.TRADE, koreaChatSettings, false )
    CopyChannel( ChatSettings, SystemData.ChatLogFilters.CRAFTING, koreaChatSettings, false )
    CopyChannel( ChatSettings, SystemData.ChatLogFilters.USER_ERROR, koreaChatSettings, false )
    CopyChannel( ChatSettings, SystemData.ChatLogFilters.MISC, koreaChatSettings, false )

    -- Combat
    CopyChannel( ChatSettings, SystemData.ChatLogFilters.ABILITY_ERROR, koreaChatSettings, false )
    CopyChannel( ChatSettings, SystemData.ChatLogFilters.RVR_KILLS_ORDER, koreaChatSettings, false )
    CopyChannel( ChatSettings, SystemData.ChatLogFilters.RVR_KILLS_DESTRUCTION, koreaChatSettings, false )
    CopyChannel( ChatSettings, SystemData.ChatLogFilters.OTHER_HITS, koreaChatSettings, false )
    CopyChannel( ChatSettings, SystemData.ChatLogFilters.EXP, koreaChatSettings, false )
    CopyChannel( ChatSettings, SystemData.ChatLogFilters.RENOWN, koreaChatSettings, false )
    CopyChannel( ChatSettings, SystemData.ChatLogFilters.INFL, koreaChatSettings, false )
    CopyChannel( ChatSettings, SystemData.ChatLogFilters.TOK, koreaChatSettings, false )

    ChatSettings.Ordering = {
        SystemData.ChatLogFilters.SAY,
        SystemData.ChatLogFilters.SHOUT,
        SystemData.ChatLogFilters.TELL_RECEIVE,
        SystemData.ChatLogFilters.TELL_SEND,
        SystemData.ChatLogFilters.GROUP,
        SystemData.ChatLogFilters.BATTLEGROUP,
        SystemData.ChatLogFilters.SCENARIO,
        SystemData.ChatLogFilters.SCENARIO_GROUPS,
        SystemData.ChatLogFilters.GUILD,
        SystemData.ChatLogFilters.GUILD_OFFICER,
        SystemData.ChatLogFilters.ALLIANCE,
        SystemData.ChatLogFilters.ALLIANCE_OFFICER,
        SystemData.ChatLogFilters.EMOTE,
        SystemData.ChatLogFilters.MONSTER_EMOTE,
        SystemData.ChatLogFilters.MONSTER_SAY,
        SystemData.ChatLogFilters.QUEST,
        SystemData.ChatLogFilters.LOOT,
        SystemData.ChatLogFilters.LOOT_COIN,
        SystemData.ChatLogFilters.LOOT_ROLL,
        SystemData.ChatLogFilters.TRADE,
        SystemData.ChatLogFilters.CRAFTING,
        SystemData.ChatLogFilters.CITY_ANNOUNCE,
        SystemData.ChatLogFilters.ZONE_AREA,
        SystemData.ChatLogFilters.USER_ERROR,
        SystemData.ChatLogFilters.ADVICE,
        SystemData.ChatLogFilters.REALM_WAR_T1,
        SystemData.ChatLogFilters.REALM_WAR_T2,
        SystemData.ChatLogFilters.REALM_WAR_T3,
        SystemData.ChatLogFilters.REALM_WAR_T4,
        SystemData.ChatLogFilters.COMBAT_DEFAULT,
        SystemData.ChatLogFilters.ABILITY_ERROR,
        SystemData.ChatLogFilters.KILLS_DEATH_YOURS,
        SystemData.ChatLogFilters.KILLS_DEATH_OTHER,
        SystemData.ChatLogFilters.RVR_KILLS_DESTRUCTION,
        SystemData.ChatLogFilters.RVR_KILLS_ORDER,
        SystemData.ChatLogFilters.YOUR_DMG_FROM_PC,
        SystemData.ChatLogFilters.YOUR_DMG_FROM_NPC,
        SystemData.ChatLogFilters.YOUR_HITS,
        SystemData.ChatLogFilters.YOUR_HEALS,
        SystemData.ChatLogFilters.OTHER_HITS,
        SystemData.ChatLogFilters.PET_DMG,
        SystemData.ChatLogFilters.PET_HITS,
        SystemData.ChatLogFilters.EXP,
        SystemData.ChatLogFilters.RENOWN,
        SystemData.ChatLogFilters.INFL,
        SystemData.ChatLogFilters.TOK,
        SystemData.ChatLogFilters.RVR,
        SystemData.ChatLogFilters.MISC,
        SystemData.ChatLogFilters.CHANNEL_1,
        SystemData.ChatLogFilters.CHANNEL_2,
        SystemData.ChatLogFilters.CHANNEL_3,
        SystemData.ChatLogFilters.CHANNEL_4,
        SystemData.ChatLogFilters.CHANNEL_5, 
        SystemData.ChatLogFilters.CHANNEL_6, 
        SystemData.ChatLogFilters.CHANNEL_7, 
        SystemData.ChatLogFilters.CHANNEL_8, 
        SystemData.ChatLogFilters.CHANNEL_9,
        SystemData.SystemLogFilters.GENERAL,
        SystemData.SystemLogFilters.NOTICE,
        SystemData.SystemLogFilters.ERROR
    }
    
    -- These are the colors for the color picker
    ChatSettings.Colors = {
        {r=235, g=235, b=235, id=1},
        {r=32, g=134, b=229, id=2},
        {r=29, g=217, b=33, id=3},
        {r=178, g=255, b=116, id=4},
        {r=239, g=221, b=19, id=5},
        {r=190, g=190, b=190, id=6},
        {r=255, g=255, b=1, id=7},
        {r=144, g=237, b=250, id=8},
        {r=238, g=113, b=21, id=9},
        {r=18, g=202, b=209, id=10},
        {r=231, g=189, b=115, id=11},
        {r=55, g=65, b=248, id=12},
        {r=32, g=224, b=32, id=13},
        {r=251, g=236, b=3, id=14},
        {r=217, g=28, b=28, id=15},
        {r=238, g=113, b=21, id=16},
        {r=235, g=213, b=135, id=17},
        {r=255, g=39, b=39, id=18},
        {r=255, g=168, b=5, id=19},
        {r=195, g=54, b=150, id=20},
        {r=1, g=167, b=167, id=21},
        {r=55, g=65, b=248, id=22},
        {r=110, g=110, b=110, id=23},
        {r=239, g=221, b=19, id=24},
        {r=1, g=167, b=165, id=25},
    }    
end

function ChatSettings.SetupChannelColorDefaults( resetAll )

    if ( resetAll ) then
        ChatSettings.ChannelColors = {}
    end

    for key, value in pairs( ChatSettings.Channels ) do
        if ( resetAll or ChatSettings.ChannelColors[ key ] == nil ) then
            ChatSettings.ChannelColors[ key ] = value.defaultColor
        end
    end

end

function ChatSettings.SetupFontDefaults()
    ChatSettings.Fonts = {}
    --                               name of font     id  default  name to be shown
    ChatSettings.Fonts[1] = Font( "font_journal_body", 1, false, "Cronos Pro - Small" )
    ChatSettings.Fonts[2] = Font( "font_journal_text", 2, false, "Cronos Pro - Medium" )
    ChatSettings.Fonts[3] = Font( "font_default_text_small", 3, false, "Age of Reckoning - Small" )
    ChatSettings.Fonts[4] = Font( "font_default_text_large", 4, false, "Age of Reckoning - Large" )
    ChatSettings.Fonts[5] = Font( "font_clear_tiny", 5, false, "Myriad Pro - Very Small" )
    ChatSettings.Fonts[6] = Font( "font_clear_small", 6, false, "Myriad Pro - Small" )
    ChatSettings.Fonts[7] = Font( "font_clear_medium", 7, true, "Myriad Pro - Medium" )
    ChatSettings.Fonts[8] = Font( "font_clear_large", 8, false, "Myriad Pro - Large" )
    ChatSettings.Fonts[9] = Font( "font_clear_small_bold", 9, false, "Myriad Pro SemiExt - Small" )
    ChatSettings.Fonts[10] = Font( "font_clear_medium_bold", 10, false, "Myriad Pro SemiExt - Medium" )
    ChatSettings.Fonts[11] = Font( "font_clear_large_bold", 11, false, "Myriad Pro SemiExt - Large" )
end

function ChatSettings.UpdateChannelNames()

    local channels = GetChatChannelNames()
    
    -- Remove slash commands for channels 1-9, we'll add them below for channels we're actually in
    ChatSettings.Channels[SystemData.ChatLogFilters.CHANNEL_1].slashCmds = nil
    ChatSettings.Channels[SystemData.ChatLogFilters.CHANNEL_2].slashCmds = nil
    ChatSettings.Channels[SystemData.ChatLogFilters.CHANNEL_3].slashCmds = nil
    ChatSettings.Channels[SystemData.ChatLogFilters.CHANNEL_4].slashCmds = nil
    ChatSettings.Channels[SystemData.ChatLogFilters.CHANNEL_5].slashCmds = nil
    ChatSettings.Channels[SystemData.ChatLogFilters.CHANNEL_6].slashCmds = nil
    ChatSettings.Channels[SystemData.ChatLogFilters.CHANNEL_7].slashCmds = nil
    ChatSettings.Channels[SystemData.ChatLogFilters.CHANNEL_8].slashCmds = nil
    ChatSettings.Channels[SystemData.ChatLogFilters.CHANNEL_9].slashCmds = nil
    
    -- We don't get name entries for channels we're not in, so set the defaults again for all channels with switches
    for channelIndex, _ in pairs( ChatSettings.ChannelSwitches )
    do
        -- If there's a name entry, use that instead of the default
        if( channels[channelIndex] ~= nil )
        then
            ChatSettings.Channels[channelIndex].labelText =
                GetFormatStringFromTable( "ChatStrings", StringTables.Chat.CHAT_CHANNEL_REPLACE_CHANNEL_X, { channels[channelIndex].number, channels[channelIndex].name } )
                
            -- Add slash command since we're in this channel
            ChatSettings.Channels[channelIndex].slashCmds = BuildSlashCommands( ChatSettings.ChannelSwitches[channelIndex].commands )
        else
            ChatSettings.Channels[channelIndex].labelText = ChatSettings.ChannelSwitches[channelIndex].replacement
        end
    end
end

local DEFAULT_WINDOW_MAX_ALPHA = 0.7

local function CreateDefaultWindowGroup(x, y)
    local winGroup = {}
    winGroup.windowDims = {}
    winGroup.windowDims.x = x
    winGroup.windowDims.y = y
    winGroup.windowDims.width = 400
    winGroup.windowDims.height = 300
    winGroup.windowDims.scale = 1.0

    winGroup.activeTab = 1
    winGroup.scrollOffset = 0
    winGroup.canAutoHide = true
    winGroup.maxAlpha = DEFAULT_WINDOW_MAX_ALPHA
    winGroup.movable = true
    winGroup.Tabs = {}
    return winGroup
end

local function CreateDefaultTab( chatLog, stringId, fontName )
    local tab = {}
    tab.tabText = GetStringFromTable("ChatStrings", stringId )
    tab.defaultLog = chatLog
    tab.font = fontName
    tab.showTimestamp = false
    tab.flashOnActivity = false
    tab.Filters = {}

    return tab
end

local function SetAllFiltersTo( filters, defaultBoolValue )
    for channel, _ in pairs( ChatSettings.Channels )
    do
        filters[channel] = defaultBoolValue
    end
end

function ChatSettings.GetDefaultWindowGroupsTable()
    -- get the default font from ChatSettings
    local fontName = "font_clear_medium"
    for k, font in ipairs( ChatSettings.Fonts )
    do
       if ( font.isDefault )
       then
            fontName = font.fontName
            break
       end
    end

    local windowGroup = {}
    windowGroup[1] = CreateDefaultWindowGroup(0, 1.0)

    windowGroup[1].Tabs[1] = CreateDefaultTab( "Chat", StringTables.Chat.LABEL_CHAT_DEFAULT, fontName )
    SetAllFiltersTo( windowGroup[1].Tabs[1].Filters, true )
    windowGroup[1].Tabs[1].Filters[ SystemData.ChatLogFilters.MONSTER_SAY ]            = false
    windowGroup[1].Tabs[1].Filters[ SystemData.ChatLogFilters.DEBUG ]                  = false
    windowGroup[1].Tabs[1].Filters[ SystemData.ChatLogFilters.MONSTER_EMOTE ]          = false
    windowGroup[1].Tabs[1].Filters[ SystemData.ChatLogFilters.KILLS_DEATH_OTHER ]      = false
    windowGroup[1].Tabs[1].Filters[ SystemData.ChatLogFilters.COMBAT_DEFAULT ]         = false
    windowGroup[1].Tabs[1].Filters[ SystemData.ChatLogFilters.YOUR_DMG_FROM_PC ]       = false
    windowGroup[1].Tabs[1].Filters[ SystemData.ChatLogFilters.YOUR_DMG_FROM_NPC ]      = false
    windowGroup[1].Tabs[1].Filters[ SystemData.ChatLogFilters.YOUR_HITS ]              = false
    windowGroup[1].Tabs[1].Filters[ SystemData.ChatLogFilters.YOUR_HEALS ]             = false
    windowGroup[1].Tabs[1].Filters[ SystemData.ChatLogFilters.OTHER_HITS ]             = false
    windowGroup[1].Tabs[1].Filters[ SystemData.ChatLogFilters.PET_DMG ]                = false
    windowGroup[1].Tabs[1].Filters[ SystemData.ChatLogFilters.PET_HITS ]               = false
    windowGroup[1].Tabs[1].Filters[ SystemData.ChatLogFilters.RVR_KILLS_ORDER ]        = false
    windowGroup[1].Tabs[1].Filters[ SystemData.ChatLogFilters.RVR_KILLS_DESTRUCTION ]  = false
    windowGroup[1].Tabs[1].Filters[ SystemData.ChatLogFilters.EXP ]                    = false
    windowGroup[1].Tabs[1].Filters[ SystemData.ChatLogFilters.RENOWN ]                 = false
    windowGroup[1].Tabs[1].Filters[ SystemData.ChatLogFilters.INFL ]                   = false
    windowGroup[1].Tabs[1].Filters[ SystemData.ChatLogFilters.TOK ]                    = false
    windowGroup[1].Tabs[1].Filters[ SystemData.ChatLogFilters.ABILITY_ERROR ]          = false
    windowGroup[1].Tabs[1].Filters[ SystemData.ChatLogFilters.CHANNEL_8 ]              = false
    windowGroup[1].Tabs[1].Filters[ SystemData.ChatLogFilters.CHANNEL_9 ]              = false
    
    windowGroup[1].Tabs[2] = CreateDefaultTab( "Combat", StringTables.Chat.LABEL_COMBAT_DEFAULT, fontName )
    windowGroup[1].Tabs[3] = CreateDefaultTab( "Chat", StringTables.Chat.LABEL_RVR_DEFAULT, fontName )
    windowGroup[1].Tabs[4] = CreateDefaultTab( "Chat", StringTables.Chat.LABEL_MISC_DEFAULT,fontName )
    
    -- Set all filters to off for RvR tab, except for scneario/scenario party, and region-rvr
    SetAllFiltersTo( windowGroup[1].Tabs[3].Filters, false )
    windowGroup[1].Tabs[3].Filters[SystemData.ChatLogFilters.SCENARIO] = true
    windowGroup[1].Tabs[3].Filters[SystemData.ChatLogFilters.SCENARIO_GROUPS] = true
    windowGroup[1].Tabs[3].Filters[SystemData.ChatLogFilters.CHANNEL_2] = true
    windowGroup[1].Tabs[3].Filters[SystemData.ChatLogFilters.REALM_WAR_T1] = true
    windowGroup[1].Tabs[3].Filters[SystemData.ChatLogFilters.REALM_WAR_T2] = true
    windowGroup[1].Tabs[3].Filters[SystemData.ChatLogFilters.REALM_WAR_T3] = true
    windowGroup[1].Tabs[3].Filters[SystemData.ChatLogFilters.REALM_WAR_T4] = true
    
    -- Set all filters to off for Misc tab, except for monster say and monster emote
    SetAllFiltersTo( windowGroup[1].Tabs[4].Filters, false )
    windowGroup[1].Tabs[4].Filters[SystemData.ChatLogFilters.MONSTER_SAY] = true
    windowGroup[1].Tabs[4].Filters[SystemData.ChatLogFilters.MONSTER_EMOTE] = true

    return windowGroup
end

-- Override the default GetDefaultWindowGroupTable with the korean one
function koreaChatSettings.GetDefaultWindowGroupsTable()
    local windowGroup = {}

    -- get the default font from ChatSettings
    local fontName = "font_clear_medium"
    for k, font in ipairs( ChatSettings.Fonts )
    do
       if ( font.isDefault )
       then
            fontName = font.fontName
            break
       end
    end


    windowGroup[1] = CreateDefaultWindowGroup(0, 1.0)
    windowGroup[1].Tabs[1] = CreateDefaultTab( "Chat", StringTables.Chat.LABEL_CHAT_DEFAULT, fontName )

    windowGroup[1].Tabs[2] = CreateDefaultTab( "Chat", StringTables.Chat.LABEL_GUILD_DEFAULT, fontName )
    SetAllFiltersTo( windowGroup[1].Tabs[2].Filters, false )
    windowGroup[1].Tabs[2].Filters[SystemData.ChatLogFilters.GUILD] = true
    windowGroup[1].Tabs[2].Filters[SystemData.ChatLogFilters.GUILD_OFFICER] = true
    windowGroup[1].Tabs[2].Filters[SystemData.ChatLogFilters.ALLIANCE] = true
    windowGroup[1].Tabs[2].Filters[SystemData.ChatLogFilters.ALLIANCE_OFFICER] = true


    windowGroup[1].Tabs[3] = CreateDefaultTab( "Chat", StringTables.Chat.LABEL_SCENARIO_DEFAULT, fontName )
    SetAllFiltersTo( windowGroup[1].Tabs[3].Filters, false )
    windowGroup[1].Tabs[3].Filters[SystemData.ChatLogFilters.SCENARIO] = true
    windowGroup[1].Tabs[3].Filters[SystemData.ChatLogFilters.SCENARIO_GROUPS] = true
    windowGroup[1].Tabs[3].Filters[SystemData.ChatLogFilters.GUILD] = true
    windowGroup[1].Tabs[3].Filters[SystemData.ChatLogFilters.GUILD_OFFICER] = true
    windowGroup[1].Tabs[3].Filters[SystemData.ChatLogFilters.ALLIANCE] = true
    windowGroup[1].Tabs[3].Filters[SystemData.ChatLogFilters.ALLIANCE_OFFICER] = true
    windowGroup[1].Tabs[3].Filters[SystemData.ChatLogFilters.EMOTE] = true
    windowGroup[1].Tabs[3].Filters[SystemData.ChatLogFilters.TELL_RECEIVE] = true
    windowGroup[1].Tabs[3].Filters[SystemData.ChatLogFilters.TELL_SEND] = true
    windowGroup[1].Tabs[3].Filters[SystemData.ChatLogFilters.SAY] = true
    windowGroup[1].Tabs[3].Filters[SystemData.ChatLogFilters.SHOUT] = true

    windowGroup[2] = CreateDefaultWindowGroup(1.2, 1.0)
    windowGroup[2].Tabs[1] = CreateDefaultTab( "Chat", StringTables.Chat.LABEL_SYSTEM_DEFAULT, fontName )
    SetAllFiltersTo( windowGroup[2].Tabs[1].Filters, false )
    windowGroup[2].Tabs[1].Filters[SystemData.ChatLogFilters.QUEST] = true
    windowGroup[2].Tabs[1].Filters[SystemData.ChatLogFilters.LOOT] = true
    windowGroup[2].Tabs[1].Filters[SystemData.ChatLogFilters.LOOT_COIN] = true
    windowGroup[2].Tabs[1].Filters[SystemData.ChatLogFilters.LOOT_ROLL] = true
    windowGroup[2].Tabs[1].Filters[SystemData.ChatLogFilters.TRADE] = true
    windowGroup[2].Tabs[1].Filters[SystemData.ChatLogFilters.CRAFTING] = true
    windowGroup[2].Tabs[1].Filters[SystemData.ChatLogFilters.CITY_ANNOUNCE] = true
    windowGroup[2].Tabs[1].Filters[SystemData.ChatLogFilters.ZONE_AREA] = true
    windowGroup[2].Tabs[1].Filters[SystemData.ChatLogFilters.USER_ERROR] = true
    windowGroup[2].Tabs[1].Filters[SystemData.ChatLogFilters.KILLS_DEATH_YOURS] = true
    windowGroup[2].Tabs[1].Filters[SystemData.ChatLogFilters.KILLS_DEATH_OTHER] = true
    windowGroup[2].Tabs[1].Filters[SystemData.ChatLogFilters.RVR_KILLS_ORDER] = true
    windowGroup[2].Tabs[1].Filters[SystemData.ChatLogFilters.RVR_KILLS_DESTRUCTION] = true
    windowGroup[2].Tabs[1].Filters[SystemData.ChatLogFilters.EXP] = true
    windowGroup[2].Tabs[1].Filters[SystemData.ChatLogFilters.RENOWN] = true
    windowGroup[2].Tabs[1].Filters[SystemData.ChatLogFilters.INFL] = true
    windowGroup[2].Tabs[1].Filters[SystemData.ChatLogFilters.TOK] = true
    windowGroup[2].Tabs[1].Filters[SystemData.ChatLogFilters.RVR] = true
    windowGroup[2].Tabs[1].Filters[SystemData.ChatLogFilters.MISC] = true
    windowGroup[2].Tabs[1].Filters[ SystemData.SystemLogFilters.GENERAL ] = true
    windowGroup[2].Tabs[1].Filters[ SystemData.SystemLogFilters.NOTICE ] = true
    windowGroup[2].Tabs[1].Filters[ SystemData.SystemLogFilters.ERROR ] = true

    -- The combat log defaults are setup in the channels
    windowGroup[2].Tabs[2] = CreateDefaultTab( "Combat", StringTables.Chat.LABEL_COMBAT_DEFAULT, fontName )

    windowGroup[2].Tabs[3] = CreateDefaultTab( "Chat", StringTables.Chat.LABEL_MISC_DEFAULT, fontName )
    SetAllFiltersTo( windowGroup[2].Tabs[3].Filters, false )
    windowGroup[2].Tabs[3].Filters[SystemData.ChatLogFilters.MONSTER_SAY] = true
    windowGroup[2].Tabs[3].Filters[SystemData.ChatLogFilters.MONSTER_EMOTE] = true

    return windowGroup
 end

function ChatSettings.SetUpTerritory()
    local tableToCopy = everywhereElseChatSettings
    if( SystemData.Territory.KOREA )
    then
        tableToCopy = koreaChatSettings
    end

    -- Add/replace the given elements of the newChatSettings in the global ChatSettings table
    for k, v in pairs( tableToCopy )
    do
        if( type(v) == "table" )
        then
            -- This is a settings table like .Channels or .Color, Add/replace each element
            for index, data in pairs( v )
            do
                ChatSettings[k][index] = data
            end
        else
            ChatSettings[k] = v
        end
    end

    -- Clear out all the different settings since we have stored them in the chat settings
    koreaChatSettings = nil
    everywhereElseChatSettings = nil
end

----------------------------------------------------------------
-- Initialization
----------------------------------------------------------------

ChatSettings.SetupChannels()
ChatSettings.UpdateChannelNames()
ChatSettings.SetupChannelColorDefaults( true )
ChatSettings.SetupFontDefaults()

--Always call this last
ChatSettings.SetUpTerritory()
