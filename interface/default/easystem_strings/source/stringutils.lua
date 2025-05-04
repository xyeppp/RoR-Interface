
-- NOTE: This file is doccumented with NaturalDocs style comments. All comments begining with "--#' will
-- be included in the output.

------------------------------------------------------------------------------------------------------------------------------------------------
--# Title: String Utils
--#     This file contains string manipulation and string table access functions.
------------------------------------------------------------------------------------------------------------------------------------------------

local function StrTable( name, subDir, fileName, luaName, pregame )
   return { tableName = name, subDirectory = subDir, sourceFileName=fileName, luaEnumTable=luaName, loadInPregame=pregame }
end



StringUtils = 
{

    tables = 
    {
        StrTable("Default", "", "default.txt",  "StringTables.Default", true ),
        StrTable("GuildStrings", "/interface", "guildstrings.txt", "StringTables.Guild", false ),
        StrTable("SocialStrings", "", "socialstrings.txt",  "StringTables.Social", false ),
        StrTable("HelpStrings", "/interface", "helpstrings.txt",  "StringTables.Help", false ),
        StrTable("SignText", "", "signtext.txt",  "", false ),
        StrTable("AbilityResults", "", "abilityresults.txt",  "", false ),
        StrTable("ComponentEffects", "", "componenteffects.txt",  "", false ),
        StrTable("AbilityNames", "", "abilitynames.txt",  "", false ),
        StrTable("ScenarioNames", "", "scenarionames.txt",  "", false ),
        StrTable("ScenarioLobbyDesc", "", "scenariolobby.txt",  "", false ),
        StrTable("ScenarioScoreDesc", "", "scenarioscore.txt",  "", false ),
        StrTable("ObjectiveNames", "", "objectivenames.txt",  "", false ),
        StrTable("KeepNames", "", "keepnames.txt",  "", false ),
        StrTable("CityNames", "", "citynames.txt",  "", false ),
        StrTable("ZoneNames", "/zones", "zone_names.txt",  "", true ),
        StrTable("ZoneRanksOrder", "/zones", "zone_ranks_order.txt",  "", false ),
        StrTable("ZoneRanksDestruction", "/zones", "zone_ranks_destruction.txt",  "", false ),
        StrTable("CareerNamesMale", "", "careernames_m.txt",  "", true ),
        StrTable("CareerNamesFemale", "", "careernames_f.txt",  "", true ),
        StrTable("CareerLinesMale", "", "careerlines_m.txt",  "", true ),
        StrTable("CareerLinesFemale", "", "careerlines_f.txt",  "", true ),
        StrTable("RaceNamesMale", "", "racenames_m.txt",  "", true ),
        StrTable("RaceNamesFemale", "", "racenames_f.txt",  "", true ),
        StrTable("BindableActions", "", "bindableactions.txt",  "StringTables.BindableActions", false ),
        StrTable("WorldControl", "", "worldcontrol.txt",  "StringTables.WorldControl", false ),
        StrTable("MapSystem", "", "mapsystem.txt",  "StringTables.MapSystem", true ),
        StrTable("BindLocations", "", "bindlocations.txt",  "", false ),
        StrTable("SpecializationPathNames", "", "specializationpathnames.txt",  "", true ),
        StrTable("SpecializationPathDescriptions", "", "specializationpathdescriptions.txt",  "", false ),
        StrTable("TomeSectionNames", "", "tomesectionnames.txt",  "", true ),
        StrTable("PackageNames", "", "packagenames.txt",  "", false ),
        StrTable("PackageDescriptions", "", "packageinfo.txt",  "", false ),
        StrTable("CombatEvents", "", "combatevents.txt",  "StringTables.CombatEvents", false ),
        StrTable("HelpTipNames", "", "helptipnames.txt",  "", false ),
        StrTable("HelpTipDescriptions", "", "helptipdesc.txt",  "", false ),
        StrTable("HelpTipDescriptionsAlternate", "", "helptipdescalt.txt",  "", false ),
        StrTable("LandmarkSpecialTypes", "", "landmarkspecialtypes.txt",  "", false ),
        StrTable("MapTextPoints", "", "maptextpointstrings.txt",  "", false ),
        StrTable("KeepUpgradeNames", "", "keepupgradenames.txt",  "", false ),
        StrTable("KeepUpgradeDescs", "", "keepupgradedescs.txt",  "", false ),
        StrTable("ContentCurrentEventNames", "", "contentcurrenteventnames.txt", "", false ),
        StrTable("ContentCurrentEventDescs", "", "contentcurrenteventdescs.txt", "", false ),

        --Renown Titles (Separated by Race and Gender),
        StrTable("Renown_DarkElves_Male", "/renowntitles", "darkelves_m.txt",  "", true ),
        StrTable("Renown_DarkElves_Female", "/renowntitles", "darkelves_f.txt",  "", true ),
        StrTable("Renown_Dwarves_Male", "/renowntitles", "dwarves_m.txt",  "", true ),
        StrTable("Renown_Dwarves_Female", "/renowntitles", "dwarves_f.txt",  "", true ),
        StrTable("Renown_HighElves_Male", "/renowntitles", "highelves_m.txt",  "", true ),
        StrTable("Renown_HighElves_Female", "/renowntitles", "highelves_f.txt",  "", true ),
        StrTable("Renown_Orcs_Male", "/renowntitles", "orcs_m.txt",  "", true ),
        StrTable("Renown_Orcs_Female", "/renowntitles", "orcs_f.txt",  "", true ),
        StrTable("Renown_Goblins_Male", "/renowntitles", "goblin_m.txt",  "", true ),
        StrTable("Renown_Goblins_Female", "/renowntitles", "goblin_f.txt",  "", true ),
        StrTable("Renown_Humans_Male", "/renowntitles", "human_m.txt",  "", true ),
        StrTable("Renown_Humans_Female", "/renowntitles", "human_f.txt",  "", true ),
        StrTable("Renown_Chaos_Male", "/renowntitles", "chaos_m.txt",  "", true ),
        StrTable("Renown_Chaos_Female", "/renowntitles", "chaos_f.txt",  "", true ),

        StrTable("NPCTitles", "", "npctitles.txt",  "", true ),

        StrTable("MapPointTypes", "", "mappointtypes.txt",  "StringTables.MapPointTypes", false ),
        StrTable("MapPointFilterNames", "/interface", "mappinfilternames.txt",  "StringTables.MapPinFilterNames", false ),
        StrTable("SiegeWeaponTypes", "", "siegeweapontypes.txt",  "", false ),
        
        -- Interface Strings...
        StrTable("MailStrings", "/interface", "mailstrings.txt",  "StringTables.Mail", false ),
        StrTable("SiegeStrings", "/interface", "siegestrings.txt",  "StringTables.Siege", true ),
        StrTable("RvRCityStrings", "/interface", "rvrcitystrings.txt",  "StringTables.RvRCity", false ),
        StrTable("HUDStrings", "/interface", "hudstrings.txt",  "StringTables.HUD", true ),
        StrTable("ShortKeyNames", "/interface", "shortkeynames.txt",  "StringTables.ShortKeyNames", true ),
        StrTable("TrainingStrings", "", "training.txt",  "StringTables.Training", false ),
        StrTable("AuctionHouseStrings", "/interface", "auctionhouse.txt",  "StringTables.AuctionHouse", false ),
        StrTable("InteractionStoreStrings", "/interface/InteractionWindow", "store.txt",  "StringTables.InteractionStore", false ),    
        StrTable("CustomizeUiStrings", "/interface/", "customizeuistrings.txt",  "StringTables.CustomizeUi", true ),
        StrTable("UserSettingsStrings", "/interface/", "usersettingsstrings.txt",  "StringTables.UserSettings", true ),
        StrTable("ChatStrings", "/interface", "chatstrings.txt",  "StringTables.Chat", false ),
        StrTable("DyeNames", "/", "dyenames.txt",  "", false ),
        StrTable("ObjectiveTracker", "/interface/ObjectiveTrackers", "objectivetrackertext.txt",  "StringTables.ObjectiveTracker", false ),
        StrTable("BackpackStrings", "/interface/", "backpack.txt",  "StringTables.Backpack", false ),
        StrTable("LCDStrings", "/interface/", "lcdstrings.txt",  "StringTables.LCDStrings", true ),
        StrTable("LiveEventStrings", "/interface/", "liveeventstrings.txt", "StringTables.LiveEventStrings", true ),
        StrTable("CurrentEventsStrings", "/interface/", "currentevents.txt", "StringTables.CurrentEvents", false ),
        StrTable("TutorialStrings", "/interface/", "tutorialstrings.txt", "StringTables.Tutorial", false ),
        
        StrTable("UiModuleCategories", "", "uimodulecategories.txt", "", true ),
        
        StrTable("TrialStrings", "/tome/loadingscreens/", "trialstrings.txt", "StringTables.TrialStrings", false ),
        StrTable("TrialAlert", "/interface/", "trialalert.txt",  "StringTables.TrialAlert", true ),
    }
}

StringUtils.AM = 1
StringUtils.PM = 2

function StringUtils.Initialize()

    for index = 1, #StringUtils.tables, 1 
    do
        local data = StringUtils.tables[index]               
        
        if (data.loadInPregame or InterfaceCore.inGame)
        then
            LoadStringTable( data.tableName, "data/strings/<LANG>"..data.subDirectory, data.sourceFileName, "cache/<LANG>", data.luaEnumTable )
        end
    end
  
end

function StringUtils.Shutdown()

    for index = #StringUtils.tables, 1, -1 
    do
        local data = StringUtils.tables[index]               
        
        if (data.loadInPregame or InterfaceCore.inGame)
        then
            UnloadStringTable( data.tableName )
        end
    end

end



----------------------------------------------------------------
-- String Table Accessor Functions
----------------------------------------------------------------

----------------------------------------------------------------------------------------------------
--# Function: GetString()
--#     Returns a string from the Default string table.
--#
--#     Parameters:
--#         stringId       - (number) The index into the string table, typically of the format StringTables.Default.ENUM_NAME. 
--#
--#     Returns:
--#         string         - (wstring) The text for the string table entry. Returns "" when not found.
--#
--#     Notes:
--#         none
--#
--#     Example:
--#     > local text = GetString( StringTables.Default.LABEL_QUESTS )
--#
----------------------------------------------------------------------------------------------------
function GetString( id )
    if( id == nil ) then
        ERROR(L"Invalid params to GetString( id): id is nil")
        return L""
    end

    return GetStringFromTable("Default", id )
end

----------------------------------------------------------------------------------------------------
--# Function: GetGuildString()
--#     Returns a string from the Guild string table.
--#
--#     Parameters:
--#         stringId       - (number) The index into the string table, typically of the format StringTables.Guild.ENUM_NAME. 
--#
--#     Returns:
--#         string         - (wstring) The text for the string table entry. Returns "" when not found.
--#
--#     Notes:
--#         none
--#
--#     Example:
--#     > LabelSetText("GuildWindowTitleBarText", GetGuildString( StringTables.Guild.LABEL_GUILD_WINDOW ) )
--#
----------------------------------------------------------------------------------------------------
function GetGuildString( id, lineNumber )
    if( id == nil ) then
		if lineNumber ~= nil then 
			ERROR(L"Invalid params to GetGuildString(id): id is nil at line number "..lineNumber)
		else
			ERROR(L"Invalid params to GetGuildString(id): id is nil")
		end
        return L""
    end

    return GetStringFromTable("GuildStrings", id )
end

----------------------------------------------------------------------------------------------------
--# Function: GetMailString()
--#     Returns a string from the Mail string table.
--#
--#     Parameters:
--#         stringId       - (number) The index into the string table, typically of the format StringTables.Default.ENUM_NAME. 
--#         stringId       - (number) The index into the string table, typically of the format StringTables.Mail.ENUM_NAME. 
--#
--#     Returns:
--#         string         - (wstring) The text for the string table entry. Returns "" when not found.
--#
--#     Notes:
--#         none
--#
--#     Example:
--#     > LabelSetText("MailWindowTitleBarText", GetMailString( StringTables.Mail.LABEL_MAIL_WINDOW ) )
--#
----------------------------------------------------------------------------------------------------
function GetMailString( id )
    if( id == nil ) then
        ERROR(L"Invalid params to GetMailString(id): id is nil")
        return L""
    end

    return GetStringFromTable("MailStrings", id )
end

----------------------------------------------------------------------------------------------------
--# Function: GetHelpString()
--#     Returns a string from the Help string table.
--#		Used for the following windows: Help, FAQ, Manual, Appeals, Bug Report, and Feedback.  
--#
--#     Parameters:
--#         stringId       - (number) The index into the string table, typically of the format StringTables.Help.ENUM_NAME.
--#
--#     Returns:
--#         string         - (wstring) The text for the string table entry. Returns "" when not found.
--#
--#     Notes:
--#         none
--#
--#     Example:
--#     > LabelSetText("EA_Window_HelpTitleBarText", GetHelpString( StringTables.Help.LABEL_HELP_WINDOW ) )
--#
----------------------------------------------------------------------------------------------------
function GetHelpString( id )
    if( id == nil ) then
        ERROR(L"Invalid params to GetHelpString(id): id is nil")
        return L""
    end

    return GetStringFromTable("HelpStrings", id )
end

----------------------------------------------------------------------------------------------------
--# Function: GetChatString()
--#     Returns a string from the Chat string table.
--#
--#     Parameters:
--#         stringId       - (number) The index into the string table, typically of the format StringTables.Default.ENUM_NAME. 
--#         stringId       - (number) The index into the string table, typically of the format StringTables.Chat.ENUM_NAME. 
--#
--#     Returns:
--#         string         - (wstring) The text for the string table entry. Returns "" when not found.
--#
--#     Notes:
--#         none
--#
--#     Example:
--#     > LabelSetText("ChatWindowHistoryTitleBar", GetChatString( StringTables.Default.LABEL_CHAT_HISTORY ) )
--#
----------------------------------------------------------------------------------------------------
function GetChatString( id )
    if( id == nil ) then
        ERROR(L"Invalid params to GetChatString(id): id is nil")
        return L""
    end

    return GetStringFromTable("ChatStrings", id )
end

----------------------------------------------------------------------------------------------------
--# Function: GetHelpTipStrings()
--#     Returns a string from the HelpTip string table.
--#
--#     Parameters:
--#         stringId       - (number) The index into the string table 
--#
--#     Returns:
--#         string         - (wstring) The text for the tip name. Returns "" when not found.
--#         string         - (wstring) The text for the tip description. Returns "" when not found.
--#     Notes:
--#         none
--#
--#     Example:
--#     > local tipName, tipDesc = GetHelpTipStrings( id )
--#
----------------------------------------------------------------------------------------------------
function GetHelpTipStrings( id )
    if( id == nil ) then
        ERROR(L"Invalid params to GetHelpTipStrings(id): id is nil")
        return L""
    end    
    return GetStringFromTable("HelpTipNames", id ), GetStringFromTable("HelpTipDescriptions", id )
end

----------------------------------------------------------------------------------------------------
--# Function: GetStringFormat()
--#     Returns a formated string from the Default string table.
--#
--#     Parameters:
--#         stringId       - (number) The index into the string table, typically of the format StringTables.Default.ENUM_NAME. 
--#         paramTable     - (table) A table containing all of the subsitution parameters. This function will auotmatically convert number params to wstrings.
--#
--#     Returns:
--#         string         - (wstring) The text for the string table entry. Returns "" when not found.
--#
--#     Notes:
--#         none
--#
--#     Example:
--#     > local text = GetStringFormat( StringTables.Default.TEXT_WAR_INTRODUCTION, { GameData.Player.name, GameData.Player.career.name } )
--#
----------------------------------------------------------------------------------------------------
function GetStringFormat( id, paramTable )
    return GetFormatStringFromTable("Default", id, paramTable)
end

----------------------------------------------------------------------------------------------------
--# Function: GetFormatStringFromTable()
--#     Returns a formatted string from the specified string table.
--#
--#     Parameters:
--#         tableName      - (string) Name of the string table.
--#         stringId       - (number) The index into the string table. 
--#         paramTable     - (table) A table containing all of the substitution parameters. This function will automatically convert numbers and strings to wstrings.
--#
--#     Returns:
--#         string         - (wstring) The text for the string table entry. Returns an empty wstring when not found.
--#
--#     Notes:
--#         This function is destructive to the paramTable input.  After GetFormatStringFromTable is called 
--#         in all of its key-value pairs, the value will now reference a widestring, and not what it formerly referenced.
--#
--#     Example:
--#     > local text = GetFormatStringFromTable( "Default", StringTables.Default.TEXT_WAR_INTRODUCTION, { GameData.Player.name, GameData.Player.career.name } )
--#
----------------------------------------------------------------------------------------------------
function GetFormatStringFromTable( tableName, id, paramTable )
    local text = L"";
    
    if( tableName == nil)
    then
        ERROR(L"Invalid parameter to GetFormatStringFromTable( tableName, id, paramTable ): tableName is nil")
    elseif( id == nil ) 
    then
        ERROR(L"Invalid parameter to GetFormatStringFromTable( tableName, id, paramTable ): id is nil")
        return text
    elseif( paramTable == nil) 
    then
        ERROR(L"Invalid parameter to GetFormatStringFromTable( tableName, id, paramTable ): paramTable is nil")
        return text
    end
      
    -- If the C-substitution is enabled, use it.
    if( GetStringFormatFromTable ~= nil ) 
    then
        -- Convert all params to wstrings   
        for index, parameter in ipairs (paramTable)
        do
            paramTable[index] = WideStringFromData (parameter)
        end
    
        text = GetStringFormatFromTable( tableName, id, paramTable ) or L""
    
    -- Else, Use the Lua subsitution
    else        
         text = GetStringFromTable(tableName, id ) or L""
             
        -- Replace each param tag with the variable
        
        for index, parameter in ipairs (paramTable)
        do
            local tag           = L"<<"..index..L">>"    
            paramTable[index]   = WideStringFromData (parameter)
            text                = wstring.gsub (text, tag, paramTable[index])
        end
    end 
    
    return text
end

function GetAbilityDesc( id, upgradeRank )
    if( id == nil ) then
        ERROR(L"Invalid params to GetAbilityDesc (id, upgradeRank): id is nil")
        return L""
    end
    
    upgradeRank = upgradeRank or 0
    
    return GetAbilityDescription (id, upgradeRank)
end

function GetAbilityName( id )
    if (id == nil ) then
        ERROR(L"Invalid params to GetAbilityName( id): id is nil")
        return L""
    end
    
    return GetStringFromTable("AbilityNames", id)
end

function GetCityName( id )
    if (id == nil ) then
        ERROR(L"Invalid params to GetCityName( id): id is nil")
        return L""
    end
    
    if( id < 1 ) then
        return L""
    end
    
    return GetStringFromTable("CityNames", id)
end

function GetCityNameForRealm( id )
    if (id == GameData.Realm.ORDER) then
        return GetStringFromTable("CityNames", GameData.CityId.EMPIRE)
    elseif (id == GameData.Realm.DESTRUCTION) then
        return GetStringFromTable("CityNames", GameData.CityId.CHAOS)
    else
        ERROR(L"Invalid params to GetCityNameForRealm(id): unknown city id")
        return L""
    end
end


function GetRealmName( id )

    if (id == nil ) then
        ERROR(L"Invalid params to GetRealmName( id): id is nil")
        return L""
    end
    
    if( id == GameData.Realm.ORDER )
    then
        return GetStringFromTable("MapSystem", StringTables.MapSystem.LABEL_REALM_NAME_ORDER)
    end
        
    if( id == GameData.Realm.DESTRUCTION )           
    then
        return GetStringFromTable("MapSystem", StringTables.MapSystem.LABEL_REALM_NAME_DESTRUCTION) 
    end
    
    if( id == GameData.Realm.NONE )  
    then    
        return GetStringFromTable("WorldControl", StringTables.WorldControl.LABEL_REALM_NONE)
    end
    
    return L""
end

function GetZoneName( id )
    if (id == nil ) then
        ERROR(L"Invalid params to GetZoneName( id): id is nil")
        return L""
    end
    
    if( id < 1 ) then
        return L""
    end
    
    return GetStringFromTable("ZoneNames", id)
end

function GetObjectiveName( id )
    if (id == nil ) then
        ERROR(L"Invalid params to ObjectiveNames( id): id is nil")
        return L""
    end
    
    if( id < 1 ) then
        return L""
    end
    
    return GetStringFromTable("ObjectiveNames", id)
end

function GetZoneRanksForCurrentRealm( id )
    if (id == nil ) then
        ERROR(L"Invalid params to GetZoneRanksForCurrentRealm( id): id is nil")
        return L""
    end
    
    if( id < 1 ) then
        return L""
    end
    
    if( GameData.Player.realm == GameData.Realm.ORDER )
    then
        return GetStringFromTable("ZoneRanksOrder", id)
    end
    
    if( GameData.Player.realm == GameData.Realm.DESTRUCTION )
    then
        return GetStringFromTable("ZoneRanksDestruction", id)
    end
    
    return L""
end


function GetZoneAreaName( zone, id )
    
    if (zone == nil ) then
        ERROR(L"Invalid params to GetZoneName( zone, id): zone is nil")
        return L""
    end
    
    if (id == nil ) then
        ERROR(L"Invalid params to GetZoneName( zone, id): id is nil")
        return L""
    end
    
    if( id < 1 ) then
        return L""
    end
    
    local tableName = string.format( "zone%03d_area_names", zone )
    
    return GetStringFromTable( tableName, id)
end

function GetKeepName( id )
        
    if (id == nil ) then
        ERROR(L"Invalid params to GetKeepName(id): id is nil")
        return L""
    end
    
    if( id < 1 ) then
        return L""
    end
        
    return GetStringFromTable("KeepNames", id)
end

function GetKeepUpgradeName( id )
        
    if (id == nil ) then
        ERROR(L"Invalid params to GetKeepUpgradeName(id): id is nil")
        return L""
    end
    
    if( id < 1 ) then
        return L""
    end
        
    return GetStringFromTable("KeepUpgradeNames", id)
end

function GetKeepUpgradeDesc( id )
        
    if (id == nil ) then
        ERROR(L"Invalid params to GetKeepUpgradeDesc(id): id is nil")
        return L""
    end
    
    if( id < 1 ) then
        return L""
    end
        
    return GetStringFromTable("KeepUpgradeDescs", id)
end

function GetCareerLine( id, gender )

    if( id == nil ) 
    then
        ERROR(L"Invalid params to GetCareerLine( id, gender ): id is nil")
        return L""
    end        
    
    if( gender == GameData.Gender.MALE ) 
    then
        return GetStringFromTable("CareerLinesMale", id)
        
    elseif( gender == GameData.Gender.FEMALE ) 
    then
        return GetStringFromTable("CareerLinesFemale", id)
        
    else
                
        -- If no valid gender is specified, just look for the first non-empty string.     
        local text = GetStringFromTable("CareerLinesMale", id)
        
        if( text == L"" )
        then
            text = GetStringFromTable("CareerLinesFemale", id)
        end
        
        return text
    end

end

function GetSpecializationPathName( id )
    if (id == nil ) then
        ERROR(L"Invalid params to GetSpecializationPathName( id ): id is nil")
        return L""
    end
    
    return GetStringFromTable("SpecializationPathNames", id)
end

function GetSpecializationPathDescription( id )
    if (id == nil ) then
        ERROR(L"Invalid params to GetSpecializationPathDescription( id ): id is nil")
        return L""
    end
    
    return GetStringFromTable("SpecializationPathDescriptions", id)
end


function GetScenarioName( id )
    if (id == nil ) then
        ERROR(L"Invalid params to GetScenarioName( id): id is nil")
        return L""
    end
    
    return GetStringFromTable("ScenarioNames", id)
end

function GetScenarioLobbyDesc( id )
    if (id == nil ) then
        ERROR(L"Invalid params to GetScenarioLobbyDesc( id): id is nil")
        return L""
    end
    
    return GetStringFromTable("ScenarioLobbyDesc", id)
end

function GetScenarioScoreDesc( id )
    if (id == nil ) then
        ERROR(L"Invalid params to GetScenarioScoreDesc( id): id is nil")
        return L""
    end
    
    return GetStringFromTable("ScenarioScoreDesc", id)
end

function GetDyeNameString( id )
    if (id == nil ) then
        ERROR(L"Invalid params to GetDyeNameString( id): id is nil")
        return L""
    end
    
    return GetStringFromTable("DyeNames", id)
end

----------------------------------------------------------------
-- String Fetch utility functions
function GetDyeNameString( id )
    if (id == nil ) then
        ERROR(L"Invalid params to GetDyeNameString( id): id is nil")
        return L""
    end
    
    return GetStringFromTable("DyeNames", id)
end

----------------------------------------------------------------

function StringUtils.GetFriendlyRaceForCurrentPairing( currentPairing, inCaps )

    local pairingId = currentPairing or GetZonePairing()
    local realmId = GameData.Player.realm
    
    return StringUtils.GetRaceNameNounFromPairingAndRealm( pairingId, realmId, inCaps )
end



function StringUtils.GetRaceNameNounFromPairingAndRealm( pairingId, realmId, inCaps )

    if( realmId == GameData.Realm.ORDER )
    then
        if( pairingId == GameData.Pairing.GREENSKIN_DWARVES )
        then
            if( inCaps )
            then
                return GetString( StringTables.Default.LABEL_DWARF_CAPS )
            else                        
                return GetString( StringTables.Default.LABEL_DWARF )
            end
        elseif( pairingId == GameData.Pairing.EMPIRE_CHAOS )
        then
            if( inCaps )
            then
                return GetString( StringTables.Default.LABEL_EMPIRE_CAPS )
            else                        
                return GetString( StringTables.Default.LABEL_EMPIRE )
            end
        elseif( pairingId == GameData.Pairing.ELVES_DARKELVES )
        then
            if( inCaps )
            then
                return GetString( StringTables.Default.LABEL_HIGH_ELF_CAPS )
            else                        
                return GetString( StringTables.Default.LABEL_HIGH_ELF )
            end
        end
    elseif( realmId == GameData.Realm.DESTRUCTION )
    then
        if( pairingId == GameData.Pairing.GREENSKIN_DWARVES )
        then
            if( inCaps )
            then
                return GetString( StringTables.Default.LABEL_GREENSKIN_CAPS )
            else                        
                return GetString( StringTables.Default.LABEL_GREENSKIN )
            end
        elseif( pairingId == GameData.Pairing.EMPIRE_CHAOS )
        then
            if( inCaps )
            then
                return GetString( StringTables.Default.LABEL_CHAOS_CAPS )
            else                        
                return GetString( StringTables.Default.LABEL_CHAOS )
            end
        elseif( pairingId == GameData.Pairing.ELVES_DARKELVES )
        then
            if( inCaps )
            then
                return GetString( StringTables.Default.LABEL_DARK_ELF_CAPS )
            else                        
                return GetString( StringTables.Default.LABEL_DARK_ELF )
            end
        end
    end
    
    return L""
end


function StringUtils.GetRaceNameAdjectiveFromPairingAndRealm( pairingId, realmId )

    if( realmId == GameData.Realm.ORDER )
    then
        if( pairingId == GameData.Pairing.GREENSKIN_DWARVES )
        then
            return GetString( StringTables.Default.LABEL_DWARF_ADJECTIVE )
            
        elseif( pairingId == GameData.Pairing.EMPIRE_CHAOS )
        then
            return GetString( StringTables.Default.LABEL_EMPIRE_ADJECTIVE )

        elseif( pairingId == GameData.Pairing.ELVES_DARKELVES )
        then
            return GetString( StringTables.Default.LABEL_HIGH_ELF_ADJECTIVE )
        end
        
    elseif( realmId == GameData.Realm.DESTRUCTION )
    then
        if( pairingId == GameData.Pairing.GREENSKIN_DWARVES )
        then
            return GetString( StringTables.Default.LABEL_GREENSKIN_ADJECTIVE )

        elseif( pairingId == GameData.Pairing.EMPIRE_CHAOS )
        then
            return GetString( StringTables.Default.LABEL_CHAOS_ADJECTIVE )
          
        elseif( pairingId == GameData.Pairing.ELVES_DARKELVES )
        then                       
            return GetString( StringTables.Default.LABEL_DARK_ELF_ADJECTIVE )
        end
    end
        
    return L""
end

function StringUtils.GetFactionNameNoun( factionId )

    if( factionId == GameData.Factions.DWARF )
    then
        return GetString( StringTables.Default.LABEL_DWARF )
    elseif( factionId == GameData.Factions.GREENSKIN )
    then
        return GetString( StringTables.Default.LABEL_GREENSKIN )
    elseif( factionId == GameData.Factions.HIGH_ELF )
    then
        return GetString( StringTables.Default.LABEL_HIGH_ELF )
    elseif( factionId == GameData.Factions.DARK_ELF )
    then
        return GetString( StringTables.Default.LABEL_DARK_ELF )
    elseif( factionId == GameData.Factions.EMPIRE )
    then
        return GetString( StringTables.Default.LABEL_EMPIRE )
    elseif( factionId == GameData.Factions.CHAOS )
    then
        return GetString( StringTables.Default.LABEL_CHAOS )
    end
    
    return L""
end


----------------------------------------------------------------
-- String Manipulation Functions that are not defined in lua.
----------------------------------------------------------------

function StringSplit (inString, delimiter)
    local list = {}
    local pos = 1
  
    -- If delimiter is empty, use space as a default...
    if (delimiter == nil or delimiter == "") then 
       delimiter = " ";
    end
    
    while 1 do
        local first, last = string.find (inString, delimiter, pos, true);
    
        if first then -- found?
            table.insert (list, string.sub (inString, pos, first - 1));
            pos = last + 1;
        else
            table.insert (list, string.sub (inString, pos));
            break
        end
    end
  
    return list;
end

function WStringSplit (inString, delimiter)
    local list = {}
    local pos = 1
  
    -- If delimiter is empty, use space as a default...
    if (delimiter == nil or delimiter == L"") then 
       delimiter = L" ";
    end
    
    while 1 do
        local first, last = wstring.find (inString, delimiter, pos, true);
    
        if first then -- found?
            table.insert (list, wstring.sub (inString, pos, first - 1));
            pos = last + 1;
        else
            table.insert (list, wstring.sub (inString, pos));
            break
        end
    end
  
    return list;
end


function StringsCompare( string1, string2 )

    if( string1 == nil ) then ERROR(L"Invalid params to StringsCompare( string1, string2 ): string1 is nil") end
    if( string2 == nil ) then ERROR(L"Invalid params to StringsCompare( string1, string2 ): string2 is nil") end


    -- Equals is built in
    if( string1 == string2 ) then
        return 0
    end
    
    -- Comparison is not.
    local len1 = string.len(string1)
    local len2 = string.len(string1)
    
    for index = 1, len1 do
        if( index > len2) then
            return 1
        end
            
        local char1 = string.byte( string1, index )
        local char2 = string.byte( string2, index )

        if( char1 < char2 ) then
            return -1
        elseif( char1 > char2 ) then
            return 1
        end     
    end
    
    return -1
end


function WStringsCompare( string1, string2 )

    if( string1 == nil ) then ERROR(L"Invalid params to WStringsCompare( string1, string2 ): string1 is nil") end
    if( string2 == nil ) then ERROR(L"Invalid params to WStringsCompare( string1, string2 ): string2 is nil") end

    -- There is now support in our Lua VM for wstring comparisons.
    if( string1 == string2 ) 
    then
        return 0
    elseif (string1 < string2)
    then
        return -1
    end

    return 1
end


function WStringsCompareIgnoreGrammer( string1, string2 )

    if( string1 == nil ) then ERROR(L"Invalid params to WStringsCompare( string1, string2 ): string1 is nil") end
    if( string2 == nil ) then ERROR(L"Invalid params to WStringsCompare( string1, string2 ): string2 is nil") end

    string1 = WStringsRemoveGrammar(string1)
    string2 = WStringsRemoveGrammar(string2)

    -- There is now support in our Lua VM for wstring comparisons.
    if( string1 == string2 ) 
    then
        return 0
    elseif (string1 < string2)
    then
        return -1
    end

    return 1
end

function WStringsRemoveGrammar(inputString)
    return wstring.gsub(inputString, L"(^.)", L"")
end


----------------------------------------------------------------
-- String Util formating functions
----------------------------------------------------------------

function StringUtils.FormatNumberWString( number )
    
    -- Local variables
    local formatted_string  = L""
    local number_string     = L""..number
    
    local number_length     = wstring.len (number_string)
    local commas_needed     = math.ceil (number_length / 3) - 1
    
    if (commas_needed == 0) then
        formatted_string = number_string
        return formatted_string
    end
        
    local counter = 0   
    for i = number_length, 1, -3 do
        
        local sub_end       = (number_length) - (counter * 3)
        local sub_begin     = (sub_end - 2)
                
        local substring = wstring.sub (number_string, sub_begin, sub_end)
        formatted_string = L","..substring..formatted_string
                
        counter = counter + 1
        
        if (counter == commas_needed) then
            local remainder = wstring.sub (number_string, 0, sub_begin-1)
            formatted_string = remainder..formatted_string
            break;
        end
    end
        
    --DEBUG (formatted_string)
    
    return formatted_string
end

-- String Sorting Functions

StringUtils.SORT_ORDER_UP      = 1
StringUtils.SORT_ORDER_DOWN    = 2

function StringUtils.SortByString( string1, string2, order )     
    if( order == StringUtils.SORT_ORDER_UP ) then
        return (string1 < string2)
    else
        return (string1 > string2)
    end 
end

function StringUtils.ToUpperZoneName( zoneName )

    if( zoneName == nil or zoneName == L"" )
    then
        return L""
    end
    
    -- DEBUG( L"Zone Name: "..zoneName )
    
    local result = WStringSplit(zoneName, L"^")
    if ( result ~= nil )
    then
       if ( result[1] ~= nil )
       then
            -- DUMP_TABLE(result)
            result[1] = wstring.upper( result[1] )

            if ( result[2] ~= nil )
            then
                return result[1]..L"^"..result[2]
            else
                return result[1]
            end
        end
    end

    return zoneName
end

-- Ths function formats a number into a string by inserting the localized delimiter where appropriate
function StringUtils.FormatNumberIntoDelimitedString(number)
	local returnString = L""..number
	local numDigits = wstring.len(returnString)
	
	local counter = 1
	for i=numDigits, 1, -1 do	-- Count backwards
		if math.mod(counter, 3) == 0 and i > 1 then	-- Insert the localized delimiter charactaer 3rd digit, unless this is the first digit
			returnString = wstring.sub(returnString, 1, i-1)..GetString(StringTables.Default.TEXT_NUMBER_DELIMITER)..wstring.sub(returnString, i)
		end
		counter = counter + 1
	end

	return returnString
end

-- This function formats the params into a localized date format (for example: mm/dd/yyyy)
-- Note: This function will not work in code used in pregame because the GuildStrings string table is not loaded.
function StringUtils.FormatDateString(month, day, year)
	-- insert a 0 at the beginning for better formatting  (1/2/2008 becomes 01/02/2008
	if day   < 10 then day   = L"0"..day   end	
	if month < 10 then month = L"0"..month end

	return GetFormatStringFromTable( "GuildStrings", StringTables.Guild.DATE_FORMAT_ROSTER_LOGIN_DD_MM_YY, {day, month, year} )
end

-- This function takes the params and return a time-formatted string. It accepts 12 or 24 hour times, and the ampm param is optional.
-- Note: This function will not work in code used in pregame because the GuildStrings string table is not loaded.
function StringUtils.FormatTimeString(hour, minute, ampm)
	local ampm = L""

	if (hour < 12 or (ampm ~= nil and ampm == StringUtils.AM) ) then
        ampm=GetStringFromTable( "GuildStrings", StringTables.Guild.LABEL_CALENDAR_AM )
        if (hour == 0) then
	        hour = 12
        end
    else
		ampm=GetStringFromTable( "GuildStrings", StringTables.Guild.LABEL_CALENDAR_PM )
        if (hour > 12 or (ampm ~= nil and ampm == StringUtils.PM) ) then
			hour = hour - 12
		end

        if (hour <= 0) then
            hour = 12
        end
    end

    if minute >=10 then
        return L""..hour..L":"..minute..L" "..ampm
    else
        return L""..hour..L":0"..minute..L" "..ampm
    end
end

-- This function returns true of any of the characters in the passed in string contain meta tags
function StringUtils.HasMetaTag(text)
	local textString = wstring.upper( text )
	if textString == nil then
		return
	end

	-- Loop through each character of the string and check if any opening meta tags exist (No need to check for closing tags, that would be a waste)
	for index = 1, wstring.len(textString) do
		if textString[index] == L"(" or 
			textString[index] == L"[" or 
			textString[index] == L"{" or 
			textString[index] == L"<"
		then
			return true
		end
	end
end

function StringUtils.AppendItemToList( currentListText, newItemText )
    return GetStringFormatFromTable( "Default", StringTables.Default.LABEL_LIST_FORMAT, { currentListText, newItemText } )
end
