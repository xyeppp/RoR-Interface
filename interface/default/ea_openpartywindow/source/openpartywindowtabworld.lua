
EA_Window_OpenPartyWorld = {}

local PARENT_WINDOW = "EA_Window_OpenPartyWorld"

EA_Window_OpenPartyWorld.SORT_LEADERNAME = 1
EA_Window_OpenPartyWorld.SORT_NUM_PLAYERS = 2
EA_Window_OpenPartyWorld.SORT_LOCATION = 3
EA_Window_OpenPartyWorld.SORT_INTEREST = 4

EA_Window_OpenPartyWorld.sortDirection = DataUtils.SORT_ORDER_DOWN
EA_Window_OpenPartyWorld.sortBy = EA_Window_OpenPartyWorld.SORT_LOCATION

EA_Window_OpenPartyWorld.Settings = {}
EA_Window_OpenPartyWorld.Settings.hideFullParties = true

EA_Window_OpenPartyWorld.buttonsDisabled = false

local CurrentInterests = {
    tier = 0,
    interest = 0,
    specificInterest1 = 0,
    specificInterest2 = 0,
    specificInterest3 = 0,
    specificInterest4 = 0
}
local LastInterestsSet = {
    tier = 0,
    interest = 0,
    specificInterest1 = 0,
    specificInterest2 = 0,
    specificInterest3 = 0,
    specificInterest4 = 0
}

EA_Window_OpenPartyWorld.PartyTable = {}

-- Used to keep the polling of data to a minimum
EA_Window_OpenPartyWorld.RequestDelay = 0
EA_Window_OpenPartyWorld.REFRESH_DELAY_TIMER = 2

local GroupSortKeys =
{
    ["numGroupMembers"] = { fallback = "leaderName" },
    ["timedDistance"]   = { fallback = "leaderName" },
    ["locationType"]    = { fallback = "leaderName" },
    ["leaderName"]      = {}
}

local GroupSortKeyMap =
{
    [EA_Window_OpenPartyWorld.SORT_LEADERNAME]   = "leaderName",
    [EA_Window_OpenPartyWorld.SORT_NUM_PLAYERS]  = "numGroupMembers",
    [EA_Window_OpenPartyWorld.SORT_LOCATION]     = "timedDistance",
    [EA_Window_OpenPartyWorld.SORT_INTEREST]     = "locationType"
}

local function CompareGroups( index1, index2 )
    if( index1 == nil ) then
        return false
    end
    if( index2 == nil ) then
        return true
    end

    local data1 = EA_Window_OpenPartyWorld.PartyTable[ index1 ]
    local data2 = EA_Window_OpenPartyWorld.PartyTable[ index2 ]

    if( data1 == nil or data1.leaderName == nil )
    then
        return false
    end
    if( data2 == nil or data2.leaderName == nil )
    then
        return true
    end

    local sortKey = GroupSortKeyMap[ EA_Window_OpenPartyWorld.sortBy ]
    return DataUtils.OrderingFunction( data1, data2, sortKey, GroupSortKeys, EA_Window_OpenPartyWorld.sortDirection )
end

local function SortWorldPartyListData()
    table.sort( EA_Window_OpenPartyWorld.partyListOrder, CompareGroups )
    ListBoxSetDisplayOrder( PARENT_WINDOW.."List", EA_Window_OpenPartyWorld.partyListOrder )
end

local function InitOpenPartyListData()
    EA_Window_OpenPartyWorld.PartyTable = {}
    EA_Window_OpenPartyWorld.PartyTable = GetOpenPartyWorldList()
    
    local totalVisible = 0
    local partiesHidden = 0
    local warbandsHidden = 0

    EA_Window_OpenPartyWorld.partyListOrder = {}
    for dataIndex, data in ipairs( EA_Window_OpenPartyWorld.PartyTable )
    do
        -- Don't add to list order (and thus hide) if this is a full warband
        if data.isWarband and data.numGroupMembers >= EA_Window_OpenParty.TOTAL_NUM_WARBAND_MEMBERS
        then
            warbandsHidden = warbandsHidden + 1
            continue
        end
        -- Hide full parties as well, if the user has elected to do so
        if  not data.isWarband
            and EA_Window_OpenPartyWorld.Settings.hideFullParties and data.numGroupMembers >= EA_Window_OpenParty.TOTAL_NUM_GROUP_MEMBERS
        then
            partiesHidden = partiesHidden + 1
            continue
        end
        
        table.insert( EA_Window_OpenPartyWorld.partyListOrder, dataIndex )
        totalVisible = totalVisible + 1
        
        -- Tack on some extra fields to see if groups contain players the user is associated with
        data.containsFriend = false
        data.containsGuildMember = false
        data.containsAllianceMember = false
        data.containsIgnoredPlayer = false

        -- We're only showing one so the order of precedence is as follows: ignore, friend, guild, alliance
        -- First check against the leader
        data.containsIgnoredPlayer = ( SocialWindowTabIgnore and SocialWindowTabIgnore.IsPlayerIgnored( data.leaderName ) )
        if( data.containsIgnoredPlayer )
        then
            continue
        end

        data.containsFriend = ( SocialWindowTabFriends and SocialWindowTabFriends.IsPlayerFriend( data.leaderName ) )
        if( data.containsFriend )
        then
            continue
        end

        data.containsGuildMember = ( GuildWindowTabRoster and GuildWindowTabRoster.IsPlayerInGuild( data.leaderName ) )
        if( data.containsGuildMember )
        then
            continue
        end

        data.containsAllianceMember = ( GuildWindowTabAlliance and GuildWindowTabAlliance.IsPlayerInAlliance( data.leaderName ) )
        if( data.containsAllianceMember )
        then
            continue
        end

        -- Then check against group members if any of the above weren't found
        if( data.Group )
        then
            for _, groupMember in ipairs( data.Group )
            do
                if( not data.containsIgnoredPlayer )
                then
                    data.containsIgnoredPlayer = ( SocialWindowTabIgnore and SocialWindowTabIgnore.IsPlayerIgnored( groupMember.m_memberName ) )
                    if( data.containsIgnoredPlayer )
                    then
                        break
                    end
                end
                if( not data.containsFriend )
                then
                    data.containsFriend = ( SocialWindowTabFriends and SocialWindowTabFriends.IsPlayerFriend( groupMember.m_memberName ) )
                    if( data.containsFriend )
                    then
                        break
                    end
                end
                if( not data.containsGuildMember )
                then
                    data.containsGuildMember = ( GuildWindowTabRoster and GuildWindowTabRoster.IsPlayerInGuild( groupMember.m_memberName ) )
                    if( data.containsGuildMember )
                    then
                        break
                    end
                end
                if( not data.containsAllianceMember )
                then
                    data.containsAllianceMember = ( GuildWindowTabAlliance and GuildWindowTabAlliance.IsPlayerInAlliance( groupMember.m_memberName ) )
                    if( data.containsAllianceMember )
                    then
                        break
                    end
                end
            end
        end
    end

    SortWorldPartyListData()
    
    return totalVisible, partiesHidden, warbandsHidden
end

local function GetPartyDataFromDisplayIndex( displayIndex )
    if( EA_Window_OpenPartyWorldList.PopulatorIndices == nil )
    then
        return nil
    end

    local dataIndex = EA_Window_OpenPartyWorldList.PopulatorIndices[ displayIndex ]
    return EA_Window_OpenPartyWorld.PartyTable[ dataIndex ]
end

local INTEREST_OPTIONS = {}

local function BuildComboBoxLookup( optionsTable, allZoneIds, filter )
    for tier = 1, 4
    do
        optionsTable[tier] = {}

        table.insert( optionsTable[tier], { id=-1, name=L"---" } )

        for key, subTable in pairs( allZoneIds )
        do
            if( filter == key )
            then
                continue
            end
            for _, zoneNum in ipairs( subTable[tier] )
            do
                local zoneData = { id=zoneNum, name=GetZoneName(zoneNum) }
                table.insert( optionsTable[tier], zoneData )
            end
        end

        table.sort( optionsTable[tier],
            function( a, b )
                return a.name < b.name
            end
        )
    end
end

local function InitComboBoxLookupTables()

    local ZONE_OPTIONS_FOR_TIER = {}
    local SCENARIO_OPTIONS_FOR_TIER = {}
    local DUNGEON_OPTIONS_FOR_TIER = {}

    -- Define this table in a more human readable format so it's easier to update later
    local allZones =
    {
        [GameData.Pairing.GREENSKIN_DWARVES]        = { [1] = {6, 11},    [2] = {7, 1},     [3] = {8, 2},     [4] = {4, 3, 5, 27, 26, 9, 10} },
        [GameData.Pairing.EMPIRE_CHAOS]             = { [1] = {100, 106}, [2] = {101, 107}, [3] = {102, 108}, [4] = {161, 104, 103, 105, 120, 109, 110, 162} },
        [GameData.Pairing.ELVES_DARKELVES]          = { [1] = {200, 206}, [2] = {201, 207}, [3] = {202, 208}, [4] = {204, 203, 205, 220, 209, 210} },
        [GameData.ExpansionMapRegion.TOMB_KINGS]    = { [1] = {}, [2] = {}, [3] = {}, [4] = {191} },
    }
    -- Then add all the id's to a 1-based table for combo box population/lookup
    BuildComboBoxLookup( ZONE_OPTIONS_FOR_TIER, allZones )

    local allScenarios =
    {
        [GameData.Pairing.GREENSKIN_DWARVES]     = { [1] = {30},        [2] = {31},         [3] = {33, 38},         [4] = {34, 39, 43, 44} },
        [GameData.Pairing.EMPIRE_CHAOS]          = { [1] = {130},       [2] = {131},        [3] = {132, 139},       [4] = {133, 134, 136, 137} },
        [GameData.Pairing.ELVES_DARKELVES]       = { [1] = {230},       [2] = {231},        [3] = {232, 236},       [4] = {234, 235, 237, 238} }
    }
    BuildComboBoxLookup( SCENARIO_OPTIONS_FOR_TIER, allScenarios )

    local allDungeons =
    {
        [GameData.Realm.ORDER]          = { [1] = {}, [2] = {152}, [3] = {},        [4] = {177, 176} },
        [GameData.Realm.DESTRUCTION]    = { [1] = {}, [2] = {155}, [3] = {},        [4] = {195, 196} },
        [GameData.Realm.NONE]           = { [1] = {}, [2] = {},    [3] = {60},      [4] = {160, 260, 179, 241, 242, 243, 244} },
    }
    local filter = GameData.Realm.ORDER
    if( GameData.Player.realm == GameData.Realm.ORDER )
    then
        filter = GameData.Realm.DESTRUCTION
    end
    BuildComboBoxLookup( DUNGEON_OPTIONS_FOR_TIER, allDungeons, filter )

    -- interest options
    local function InterestTable( paramId, paramName, subOptions )
        local newtable = { id = paramId, name = paramName }
        newtable.zones = subOptions
        return newtable
    end
    table.insert( INTEREST_OPTIONS, InterestTable( GameData.OpenPartyInterest.NOT_SET, GetStringFromTable("SocialStrings", StringTables.Social.OPEN_PARTY_SEARCH_OPTION_ANY), ZONE_OPTIONS_FOR_TIER ) )
    table.insert( INTEREST_OPTIONS, InterestTable( GameData.OpenPartyInterest.PVE, GetStringFromTable("SocialStrings", StringTables.Social.OPEN_PARTY_SEARCH_OPTION_PVE), ZONE_OPTIONS_FOR_TIER ) )
    table.insert( INTEREST_OPTIONS, InterestTable( GameData.OpenPartyInterest.RVR, GetStringFromTable("SocialStrings", StringTables.Social.OPEN_PARTY_SEARCH_OPTION_RVR), ZONE_OPTIONS_FOR_TIER ) )
    table.insert( INTEREST_OPTIONS, InterestTable( GameData.OpenPartyInterest.PQ, GetStringFromTable("SocialStrings", StringTables.Social.OPEN_PARTY_SEARCH_OPTION_PQ), ZONE_OPTIONS_FOR_TIER ) )
    table.insert( INTEREST_OPTIONS, InterestTable( GameData.OpenPartyInterest.SCENARIO, GetStringFromTable("SocialStrings", StringTables.Social.OPEN_PARTY_SEARCH_OPTION_SCENARIO), SCENARIO_OPTIONS_FOR_TIER ) )
    table.insert( INTEREST_OPTIONS, InterestTable( GameData.OpenPartyInterest.DUNGEON, GetStringFromTable("SocialStrings", StringTables.Social.OPEN_PARTY_SEARCH_OPTION_DUNGEON), DUNGEON_OPTIONS_FOR_TIER ) )
end


function EA_Window_OpenPartyWorld.Initialize()
    -- Sort buttons
    ButtonSetText( PARENT_WINDOW.."PartyLeaderSortButton", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_PARTYLEADER) )
    ButtonSetText( PARENT_WINDOW.."NumPlayersSortButton", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_NUM_PLAYERS) )
    ButtonSetText( PARENT_WINDOW.."LocationSortButton", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_SORT_BUTTON_LOCATION) )
    ButtonSetText( PARENT_WINDOW.."InterestSortButton", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_INTEREST) )
    EA_Window_OpenPartyWorld.HideAllSortButtonArrows()
    -- Set default sorting
    EA_Window_OpenPartyWorld.sortBy = EA_Window_OpenPartyWorld.SORT_DISTANCE
    EA_Window_OpenPartyWorld.sortDirection = DataUtils.SORT_ORDER_UP
    WindowSetShowing( PARENT_WINDOW.."LocationSortButtonUpArrow", true )
    
    ButtonSetText( PARENT_WINDOW.."DoneButton", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_OPENPARTY_DONE) )
    
    LabelSetText( PARENT_WINDOW.."HelpText", GetStringFromTable("SocialStrings", StringTables.Social.OPEN_PARTY_WORLD_HELP) )
    
    LabelSetText( PARENT_WINDOW.."LocationSelectLabel", GetStringFromTable("SocialStrings", StringTables.Social.OPEN_PARTY_SEARCH_SELECT_LOCATION) )
    LabelSetText( PARENT_WINDOW.."InterestSelectLabel", GetStringFromTable("SocialStrings", StringTables.Social.OPEN_PARTY_SEARCH_SELECT_INTEREST) )
    
    ButtonSetText( PARENT_WINDOW.."SetInterestsButton", GetStringFromTable("SocialStrings", StringTables.Social.OPEN_PARTY_SEARCH_SET_INTERESTS) )
    ButtonSetText( PARENT_WINDOW.."SearchButton", GetStringFromTable("SocialStrings", StringTables.Social.OPEN_PARTY_SEARCH_FOR_OTHERS) )
    LabelSetText( PARENT_WINDOW.."SearchableCheckLabel", GetStringFromTable("SocialStrings", StringTables.Social.OPEN_PARTY_SEARCHABLE) )
    
    LabelSetText( PARENT_WINDOW.."HideFullPartiesCheckLabel", GetStringFromTable("SocialStrings", StringTables.Social.HIDE_FULL_PARTIES) )
    ButtonSetPressedFlag( PARENT_WINDOW.."HideFullPartiesCheckButton", EA_Window_OpenPartyWorld.Settings.hideFullParties )
    
    InitComboBoxLookupTables()
    
    WindowRegisterEventHandler( PARENT_WINDOW, SystemData.Events.ALL_MODULES_INITIALIZED, "EA_Window_OpenPartyWorld.PostInit" )
    WindowRegisterEventHandler( PARENT_WINDOW, SystemData.Events.SOCIAL_OPENPARTYWORLD_SETTINGS_UPDATED, "EA_Window_OpenPartyWorld.OnSettingsUpdated" )
    WindowRegisterEventHandler( PARENT_WINDOW, SystemData.Events.SOCIAL_OPENPARTY_WORLD_UPDATED, "EA_Window_OpenPartyWorld.OnPartyListUpdated" )
    WindowRegisterEventHandler( PARENT_WINDOW, SystemData.Events.BATTLEGROUP_UPDATED, "EA_Window_OpenPartyWorld.OnGroupUpdated" )
    WindowRegisterEventHandler( PARENT_WINDOW, SystemData.Events.GROUP_UPDATED,       "EA_Window_OpenPartyWorld.OnGroupUpdated" )
    WindowRegisterEventHandler( PARENT_WINDOW, SystemData.Events.PLAYER_CAREER_RANK_UPDATED, "EA_Window_OpenPartyWorld.PopulateComboBoxes" )
    
    EA_Window_OpenPartyWorld.OnPartyListUpdated()
    EA_Window_OpenPartyWorld.OnGroupUpdated()
end

function EA_Window_OpenPartyWorld.OnGroupUpdated()
    EA_Window_OpenPartyWorld.buttonsDisabled = (PartyUtils.IsPartyActive() or IsWarBandActive()) and (not GameData.Player.isGroupLeader)
    if( EA_Window_OpenPartyWorld.buttonsDisabled )
    then
        WindowSetAlpha( PARENT_WINDOW.."SetInterestsButton", 0.3 )
        WindowSetFontAlpha( PARENT_WINDOW.."SetInterestsButton", 0.3 )
    else
        WindowSetAlpha( PARENT_WINDOW.."SetInterestsButton", 1.0 )
        WindowSetFontAlpha( PARENT_WINDOW.."SetInterestsButton", 1.0 )
    end
    ButtonSetDisabledFlag( PARENT_WINDOW.."SetInterestsButton", EA_Window_OpenPartyWorld.buttonsDisabled )
    ButtonSetDisabledFlag( PARENT_WINDOW.."SearchableCheckButton", EA_Window_OpenPartyWorld.buttonsDisabled )
end

function EA_Window_OpenPartyWorld.OnUpdate( timePassed )
    if (EA_Window_OpenPartyWorld.RequestDelay > 0)
    then
        EA_Window_OpenPartyWorld.RequestDelay = EA_Window_OpenPartyWorld.RequestDelay - timePassed
        if (EA_Window_OpenPartyWorld.RequestDelay < 0)
        then
            EA_Window_OpenPartyWorld.RequestDelay = 0
        end
    end
end

function EA_Window_OpenPartyWorld.PostInit()
    EA_Window_OpenPartyWorld.PopulateComboBoxes()
    EA_Window_OpenPartyWorld.OnSettingsUpdated()
end

local lastInitialTier = 0
function EA_Window_OpenPartyWorld.PopulateComboBoxes()
    local initialTier = Player.GetTier()
    if( initialTier < 1 or initialTier > 4 )
    then
        initialTier = 1
    end
    if( initialTier == lastInitialTier )
    then
        return
    end
    lastInitialTier = initialTier

    -- Add tiers
    ComboBoxClearMenuItems( PARENT_WINDOW.."TierComboBox" )
    ComboBoxAddMenuItem( PARENT_WINDOW.."TierComboBox", GetStringFromTable("SocialStrings", StringTables.Social.OPEN_PARTY_SEARCH_PARAM_TIER_1) )
    ComboBoxAddMenuItem( PARENT_WINDOW.."TierComboBox", GetStringFromTable("SocialStrings", StringTables.Social.OPEN_PARTY_SEARCH_PARAM_TIER_2) )
    ComboBoxAddMenuItem( PARENT_WINDOW.."TierComboBox", GetStringFromTable("SocialStrings", StringTables.Social.OPEN_PARTY_SEARCH_PARAM_TIER_3) )
    ComboBoxAddMenuItem( PARENT_WINDOW.."TierComboBox", GetStringFromTable("SocialStrings", StringTables.Social.OPEN_PARTY_SEARCH_PARAM_TIER_4) )
    ComboBoxSetSelectedMenuItem( PARENT_WINDOW.."TierComboBox", initialTier )
    
    ComboBoxClearMenuItems( PARENT_WINDOW.."InterestComboBox" )
    for _, data in ipairs( INTEREST_OPTIONS )
    do
        ComboBoxAddMenuItem( PARENT_WINDOW.."InterestComboBox", data.name )
    end
    ComboBoxSetSelectedMenuItem( PARENT_WINDOW.."InterestComboBox", 1 )
    
    EA_Window_OpenPartyWorld.PopulateSpecificComboBoxes()
end

function EA_Window_OpenPartyWorld.PopulateSpecificComboBoxes()
    local tier = math.max( 1, ComboBoxGetSelectedMenuItem( PARENT_WINDOW.."TierComboBox" ) )
    local interest = math.max( 1, ComboBoxGetSelectedMenuItem( PARENT_WINDOW.."InterestComboBox" ) )
    local zoneTable = INTEREST_OPTIONS[interest].zones[tier]

    for i = 1, 4
    do
        ComboBoxClearMenuItems( PARENT_WINDOW.."InterestSpecificComboBox"..i )
        for _, data in ipairs( zoneTable )
        do
            if( i == 1 and data.id < 0 )
            then
                ComboBoxAddMenuItem( PARENT_WINDOW.."InterestSpecificComboBox"..i, GetStringFromTable("SocialStrings", StringTables.Social.OPEN_PARTY_SEARCH_OPTION_ANY) )
            else
                ComboBoxAddMenuItem( PARENT_WINDOW.."InterestSpecificComboBox"..i, data.name )
            end
        end
        ComboBoxSetSelectedMenuItem( PARENT_WINDOW.."InterestSpecificComboBox"..i, 1 )
        
        ComboBoxSetDisabledFlag( PARENT_WINDOW.."InterestSpecificComboBox"..i, i > 1 )
    end
end

local function GetCurrentSelections()
    local tier = math.max( 1, ComboBoxGetSelectedMenuItem( PARENT_WINDOW.."TierComboBox" ) )
    local interestIndex = math.max( 1, ComboBoxGetSelectedMenuItem( PARENT_WINDOW.."InterestComboBox" ) )
    local specificInterest1 = math.max( 1, ComboBoxGetSelectedMenuItem( PARENT_WINDOW.."InterestSpecificComboBox1" ) )
    local specificInterest2 = math.max( 1, ComboBoxGetSelectedMenuItem( PARENT_WINDOW.."InterestSpecificComboBox2" ) )
    local specificInterest3 = math.max( 1, ComboBoxGetSelectedMenuItem( PARENT_WINDOW.."InterestSpecificComboBox3" ) )
    local specificInterest4 = math.max( 1, ComboBoxGetSelectedMenuItem( PARENT_WINDOW.."InterestSpecificComboBox4" ) )

    -- look up the actual id's for the selected settings
    local interest = INTEREST_OPTIONS[interestIndex].id
    specificInterest1 = INTEREST_OPTIONS[interestIndex].zones[tier][specificInterest1].id
    specificInterest2 = INTEREST_OPTIONS[interestIndex].zones[tier][specificInterest2].id
    specificInterest3 = INTEREST_OPTIONS[interestIndex].zones[tier][specificInterest3].id
    specificInterest4 = INTEREST_OPTIONS[interestIndex].zones[tier][specificInterest4].id

    return tier, interest, specificInterest1, specificInterest2, specificInterest3, specificInterest4
end

function EA_Window_OpenPartyWorld.UpdateComboBoxDisable()
    local zones = {}
    _, _, zones[1], zones[2], zones[3], zones[4] = GetCurrentSelections()
    
    local disable = false
    for i = 1, 4
    do
        ComboBoxSetDisabledFlag( PARENT_WINDOW.."InterestSpecificComboBox"..i, disable )
        if( disable )
        then
            ComboBoxSetSelectedMenuItem( PARENT_WINDOW.."InterestSpecificComboBox"..i, 1 )
        end

        if( zones[i] < 0 )
        then
            disable = true
        end
    end
end

--------------------------------
-- Button Handlers
--------------------------------

function EA_Window_OpenPartyWorld.SetInterests()
    if( EA_Window_OpenPartyWorld.buttonsDisabled )
    then
        return
    end

    local tier, interest, specificInterest1, specificInterest2, specificInterest3, specificInterest4 = GetCurrentSelections()
    SetOpenPartyWorldInterests( tier, interest, specificInterest1, specificInterest2, specificInterest3, specificInterest4 )
    
    LastInterestsSet.tier = tier
    LastInterestsSet.interest = interest
    LastInterestsSet.specificInterest1 = specificInterest1
    LastInterestsSet.specificInterest2 = specificInterest2
    LastInterestsSet.specificInterest3 = specificInterest3
    LastInterestsSet.specificInterest4 = specificInterest4
end

function EA_Window_OpenPartyWorld.Search()
    if (EA_Window_OpenPartyWorld.RequestDelay == 0)
    then
        local tier, interest, specificInterest1, specificInterest2, specificInterest3, specificInterest4 = GetCurrentSelections()
        SendOpenPartyWorldSearch( tier, interest, specificInterest1, specificInterest2, specificInterest3, specificInterest4 )
        EA_Window_OpenPartyWorld.RequestDelay = EA_Window_OpenPartyWorld.REFRESH_DELAY_TIMER
    end
end

function EA_Window_OpenPartyWorld.SetSearchable()
    if( EA_Window_OpenPartyWorld.buttonsDisabled )
    then
        return
    end

    if( ButtonGetPressedFlag( PARENT_WINDOW.."SearchableCheckButton" ) )
    then
        UnsetOpenPartyWorldInterests()
    else
        if( LastInterestsSet.tier > 0 )
        then
            SetOpenPartyWorldInterests(
                LastInterestsSet.tier,
                LastInterestsSet.interest,
                LastInterestsSet.specificInterest1,
                LastInterestsSet.specificInterest2,
                LastInterestsSet.specificInterest3,
                LastInterestsSet.specificInterest4
                )
        else
            EA_Window_OpenPartyWorld.SetInterests()
        end
    end
    
    
end

function EA_Window_OpenPartyWorld.MouseOverSearchable()
    if( CurrentInterests.tier > 0 )
    then
        Tooltips.CreateTextOnlyTooltip(SystemData.ActiveWindow.name)
        Tooltips.SetTooltipText( 1, 1, GetStringFromTable("SocialStrings", StringTables.Social.TEXT_INTEREST_COLON) )
        Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
        Tooltips.SetTooltipText( 2, 1, GetFormatStringFromTable( "Default", StringTables.Default.LABEL_TIER_X, {CurrentInterests.tier} )..
                                       L" "..EA_Window_OpenParty.GetLocationTypeName( CurrentInterests.interest ) )
        Tooltips.SetTooltipText( 3, 1, GetZoneName( CurrentInterests.specificInterest1 ) )
        Tooltips.SetTooltipText( 4, 1, GetZoneName( CurrentInterests.specificInterest2 ) )
        Tooltips.SetTooltipText( 5, 1, GetZoneName( CurrentInterests.specificInterest3 ) )
        Tooltips.SetTooltipText( 6, 1, GetZoneName( CurrentInterests.specificInterest4 ) )
        Tooltips.Finalize()
        Tooltips.AnchorTooltip( Tooltips.ANCHOR_CURSOR )
    else
        Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, GetStringFromTable("SocialStrings", StringTables.Social.TOOLTIP_NO_INTERESTS_SET) )
        Tooltips.AnchorTooltip( Tooltips.ANCHOR_CURSOR )
    end
end

function EA_Window_OpenPartyWorld.UpdatePartyTooltipFromButton()
    local rowWindow = WindowGetParent( SystemData.MouseOverWindow.name )
    local windowIdx = WindowGetId( rowWindow )
    EA_Window_OpenPartyWorld.UpdatePartyTooltip( windowIdx, rowWindow )
end

function EA_Window_OpenPartyWorld.UpdatePartyTooltipFromWindow()
    local windowIdx = WindowGetId( SystemData.MouseOverWindow.name )
    EA_Window_OpenPartyWorld.UpdatePartyTooltip( windowIdx, SystemData.MouseOverWindow.name )
end

function EA_Window_OpenPartyWorld.UpdatePartyTooltip( displayIndex, rowWindow )

    if( rowWindow == nil )
    then
        return
    end

    local openPartyData = GetPartyDataFromDisplayIndex( displayIndex )
    if( openPartyData )
    then
        local tooltipAnchor = { Point = "topright", RelativeTo = rowWindow, RelativePoint = "topleft", XOffset = 32, YOffset = 0 }
        EA_Window_OpenPartyWorld.CreateOpenPartyTooltip( openPartyData, SystemData.MouseOverWindow.name, tooltipAnchor )
    end
end

function EA_Window_OpenPartyWorld.OnRButtonUpGroupLeaderLine()
    local windowId = WindowGetId( SystemData.ActiveWindow.name )
    local partyData = GetPartyDataFromDisplayIndex( windowId )

    if( partyData == nil )
    then
        return
    end

    PlayerMenuWindow.ShowMenu( partyData.leaderName, 0 )
end

function EA_Window_OpenPartyWorld.JoinPartySpecified()
    if( EA_Window_OpenPartyWorldList.PopulatorIndices == nil
        or ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) == true )
    then
        return
    end

    local windowId = WindowGetId( SystemData.ActiveWindow.name )
    local dataId = EA_Window_OpenPartyWorldList.PopulatorIndices[ windowId ]
    local groupData = EA_Window_OpenPartyWorld.PartyTable[ dataId ]
    
    local maxGroupMembers = EA_Window_OpenParty.TOTAL_NUM_WARBAND_MEMBERS
    if( not groupData.isWarband )
    then
        maxGroupMembers = EA_Window_OpenParty.TOTAL_NUM_GROUP_MEMBERS
    end

    if( not groupData.isOpen or groupData.numGroupMembers >= maxGroupMembers )
    then
        local text = L"/tell "..groupData.leaderName..L" "
        EA_ChatWindow.SwitchChannelWithExistingText(text)
    else
        local chatText = L"/partyjoin "..groupData.leaderName
        if( groupData.isWarband == true )
        then
            chatText = L"/warbandjoin "..groupData.leaderName
        end
        
        SendChatText( chatText, L"" )
    end
end

function EA_Window_OpenPartyWorld.OnHideFullParties()
    local newState = not ButtonGetPressedFlag( PARENT_WINDOW.."HideFullPartiesCheckButton" )
    EA_Window_OpenPartyWorld.Settings.hideFullParties = newState
    ButtonSetPressedFlag( PARENT_WINDOW.."HideFullPartiesCheckButton", newState )
    
    EA_Window_OpenPartyWorld.OnPartyListUpdated()
end

--------------------------------
-- Data Events
--------------------------------
function EA_Window_OpenPartyWorld.OnSettingsUpdated( tier, interest, specificInterests )
    ButtonSetPressedFlag( PARENT_WINDOW.."SearchableCheckButton", GameData.Player.isOpenPartyWorldSearchable )
    if not tier then return end

    CurrentInterests.tier = tier
    if( tier > 0 )
    then
        CurrentInterests.interest = interest
        CurrentInterests.specificInterest1 = specificInterests[1]
        CurrentInterests.specificInterest2 = specificInterests[2]
        CurrentInterests.specificInterest3 = specificInterests[3]
        CurrentInterests.specificInterest4 = specificInterests[4]
    end
end

function EA_Window_OpenPartyWorld.OnPartyListUpdated()
    local totalVisible, partiesHidden, warbandsHidden = InitOpenPartyListData()
    
    if( EA_Window_OpenPartyWorld.PartyTable == nil or totalVisible <= 0 )
    then
        LabelSetText( PARENT_WINDOW.."NoResultsHeader", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_HEADER_NO_WORLD_RESULTS) )
        WindowSetShowing( PARENT_WINDOW.."NoResultsHeader", true )
    else
        WindowSetShowing( PARENT_WINDOW.."NoResultsHeader", false )
    end
end

function EA_Window_OpenPartyWorld.PopulateParties()
    if( EA_Window_OpenPartyWorldList.PopulatorIndices == nil )
    then
        return
    end

    for rowIndex, dataIndex in ipairs( EA_Window_OpenPartyWorldList.PopulatorIndices )
    do
    	local rowWindow = PARENT_WINDOW.."ListRow"..rowIndex
		local groupData = EA_Window_OpenPartyWorld.PartyTable[ dataIndex ]
		if( groupData ~= nil )
        then
            -- Set background color
            local rowMod = math.mod( rowIndex, 2 )
            local color = DataUtils.GetAlternatingRowColor( rowMod )
            WindowSetTintColor( rowWindow.."Background", color.r, color.g, color.b )
            WindowSetAlpha( rowWindow.."Background", color.a )

            -- Disable the join button if the player is the leader
			local isPlayersGroup = WStringsCompareIgnoreGrammer( groupData.leaderName, GameData.Player.name ) == 0
            --ButtonSetDisabledFlag( rowWindow.."JoinPartyButton", isPlayersGroup )
            -- Don't yet have a disabled state for this button, so hide for now instead
            WindowSetShowing( rowWindow.."JoinPartyButton", not isPlayersGroup )

            -- Color the leader's name based on type of group
            local maxGroupMembers = EA_Window_OpenParty.TOTAL_NUM_WARBAND_MEMBERS
            if( groupData.isWarband )
            then
                LabelSetTextColor( rowWindow.."LeaderNameText", EA_Window_OpenParty.WarbandTextColor.r, EA_Window_OpenParty.WarbandTextColor.b, EA_Window_OpenParty.WarbandTextColor.g )
            else
                LabelSetTextColor( rowWindow.."LeaderNameText", EA_Window_OpenParty.PartyTextColor.r, EA_Window_OpenParty.PartyTextColor.b, EA_Window_OpenParty.PartyTextColor.g )
                maxGroupMembers = EA_Window_OpenParty.TOTAL_NUM_GROUP_MEMBERS
            end

            -- Set num players text
            LabelSetText( rowWindow.."RatioText", GetFormatStringFromTable( "SocialStrings", StringTables.Social.LABEL_SOCIAL_GROUP_RATIO, { groupData.numGroupMembers, maxGroupMembers } ) )

            -- Set distance text
            LabelSetText( rowWindow.."LocationText", GetZoneName( groupData.leaderZone ) )

            -- Set location text
            LabelSetText( rowWindow.."InterestText", EA_Window_OpenParty.GetLocationTypeName( groupData.locationType ) )
            local color = EA_Window_OpenParty.GetLocationTypeColor( groupData.locationType )
            LabelSetTextColor( rowWindow.."InterestText", color.r, color.g, color.b )

            -- Set button text
            if( groupData.isOpen and groupData.numGroupMembers < maxGroupMembers )
            then
                ButtonSetText( rowWindow.."JoinPartyButton", GetString( StringTables.Default.LABEL_JOIN ) )
            else
                ButtonSetText( rowWindow.."JoinPartyButton", GetString( StringTables.Default.LABEL_PLAYER_MENU_TALK ) )
            end

            -- Set friend/guild/etc icon
            -- We're only showing one so the order of precedence is as follows: ignore, friend, guild, alliance
            WindowSetShowing( rowWindow.."FriendIcon", false )
            if( groupData.containsIgnoredPlayer )
            then
                local texture, x, y = GetIconData( EA_Window_OpenParty.ICON_IGNORE )
                DynamicImageSetTexture( rowWindow.."FriendIcon", texture, x, y )
                WindowSetShowing( rowWindow.."FriendIcon", true )
            elseif( groupData.containsFriend )
            then
                local texture, x, y = GetIconData( EA_Window_OpenParty.ICON_FRIEND )
                DynamicImageSetTexture( rowWindow.."FriendIcon", texture, x, y )
                WindowSetShowing( rowWindow.."FriendIcon", true )
            elseif( groupData.containsGuildMember )
            then
                local texture, x, y = GetIconData( EA_Window_OpenParty.ICON_GUILD )
                DynamicImageSetTexture( rowWindow.."FriendIcon", texture, x, y )
                WindowSetShowing( rowWindow.."FriendIcon", true )
            elseif( groupData.containsAllianceMember )
            then
                local texture, x, y = GetIconData( EA_Window_OpenParty.ICON_ALLIANCE )
                DynamicImageSetTexture( rowWindow.."FriendIcon", texture, x, y )
                WindowSetShowing( rowWindow.."FriendIcon", true )
            end

		end
    end
end

--------------------------------
-- Sorting Functions
--------------------------------
function EA_Window_OpenPartyWorld.HideAllSortButtonArrows()
    WindowSetShowing( PARENT_WINDOW.."PartyLeaderSortButtonUpArrow", false)
    WindowSetShowing( PARENT_WINDOW.."PartyLeaderSortButtonDownArrow", false)
    WindowSetShowing( PARENT_WINDOW.."NumPlayersSortButtonUpArrow", false)
    WindowSetShowing( PARENT_WINDOW.."NumPlayersSortButtonDownArrow", false)
    WindowSetShowing( PARENT_WINDOW.."LocationSortButtonUpArrow", false)
    WindowSetShowing( PARENT_WINDOW.."LocationSortButtonDownArrow", false)
    WindowSetShowing( PARENT_WINDOW.."InterestSortButtonUpArrow", false)
    WindowSetShowing( PARENT_WINDOW.."InterestSortButtonDownArrow", false)
end

function EA_Window_OpenPartyWorld.OnLButtonUpSortButton()
    if( EA_Window_OpenPartyWorld.PartyTable == nil or #EA_Window_OpenPartyWorld.PartyTable <= 0 )
    then
        return
    end

    local sortId = WindowGetId( SystemData.ActiveWindow.name )

    EA_Window_OpenPartyWorld.HideAllSortButtonArrows()
    if( EA_Window_OpenPartyWorld.sortBy == sortId )
    then
        if( EA_Window_OpenPartyWorld.sortDirection == DataUtils.SORT_ORDER_UP )
        then
            EA_Window_OpenPartyWorld.sortDirection = DataUtils.SORT_ORDER_DOWN
            WindowSetShowing( SystemData.ActiveWindow.name.."DownArrow", true )
        else
            EA_Window_OpenPartyWorld.sortDirection = DataUtils.SORT_ORDER_UP
            WindowSetShowing( SystemData.ActiveWindow.name.."UpArrow", true )
        end
    else
        EA_Window_OpenPartyWorld.sortBy = sortId
        EA_Window_OpenPartyWorld.sortDirection = DataUtils.SORT_ORDER_UP
        WindowSetShowing( SystemData.ActiveWindow.name.."UpArrow", true )
    end

    SortWorldPartyListData()
end


----------------------------------------------------------
-- Tooltip Function
----------------------------------------------------------
local numMemberWindowsCreated = 0
function EA_Window_OpenPartyWorld.CreateOpenPartyTooltip( groupLeaderData, mouseoverWindow, anchor )

    local TOOLTIP_WIN = "EA_Tooltip_OpenPartyWorld"
    local SET_SEPERATOR         = 15
    local SET_PIECE_INDENT      = 5
    local DIVLINE_ANCHOR_TOP    = { Point = "bottomleft", RelativeTo = TOOLTIP_WIN.."NoteText", RelativePoint = "bottomleft", XOffset = 0, YOffset = 5 }
    local DIVLINE_ANCHOR_BOTTOM = { Point = "bottomright", RelativeTo = TOOLTIP_WIN.."NoteText", RelativePoint = "bottomright", XOffset = 0, YOffset = 7 }
    local c_BASE_TOOLTIP_WIDTH = 300;
    local height, width

    if( groupLeaderData == nil ) then
        return
    end

    -- Rank and Name
    LabelSetText (TOOLTIP_WIN.."GroupLeaderRankText", L"("..GetString(StringTables.Default.LABEL_RANK)..L" "..groupLeaderData.leaderLevel..L")")
    LabelSetText (TOOLTIP_WIN.."GroupLeaderNameText", groupLeaderData.leaderName)

    if (groupLeaderData.isWarband == true)
    then
        local warbandColor = EA_Window_OpenParty.WarbandTextColor
        LabelSetText (TOOLTIP_WIN.."PartyTypeText", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_TYPE_BATTLEGROUP))
        LabelSetTextColor(TOOLTIP_WIN.."PartyTypeText", warbandColor.r, warbandColor.b, warbandColor.g)
    else
        LabelSetText (TOOLTIP_WIN.."PartyTypeText", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_TYPE_GROUP))
        LabelSetTextColor(TOOLTIP_WIN.."PartyTypeText", 253, 253, 253)
    end
    if (groupLeaderData.leaderCareer ~= nil and groupLeaderData.leaderCareer ~= 0)
    then
        local iconId = Icons.GetCareerIconIDFromCareerLine(groupLeaderData.leaderCareer)
        local texture, x, y = GetIconData(iconId)
        DynamicImageSetTexture(TOOLTIP_WIN.."GroupLeaderCareerIcon", texture, x, y)
    end

    LabelSetText (TOOLTIP_WIN.."LocationText", GetStringFromTable("SocialStrings", StringTables.Social.TEXT_INTEREST_COLON))

    local stringText = EA_Window_OpenParty.GetLocationTypeName(groupLeaderData.locationType)
    LabelSetText (TOOLTIP_WIN.."LocationTypeText", L"("..stringText..L")")
    
    LabelSetText (TOOLTIP_WIN.."SpecificInterest1", GetZoneName( groupLeaderData.specificInterest1 ) )
    LabelSetText (TOOLTIP_WIN.."SpecificInterest2", GetZoneName( groupLeaderData.specificInterest2 ) )
    LabelSetText (TOOLTIP_WIN.."SpecificInterest3", GetZoneName( groupLeaderData.specificInterest3 ) )
    LabelSetText (TOOLTIP_WIN.."SpecificInterest4", GetZoneName( groupLeaderData.specificInterest4 ) )

    local noteText = GetString(StringTables.Default.LABEL_NOTE)
    if(groupLeaderData.partyNote ~= L"") then
        noteText = GetString(StringTables.Default.LABEL_NOTE)..L" "..groupLeaderData.partyNote
    else
        noteText = GetString(StringTables.Default.LABEL_NOTE)..L" "..GetString(StringTables.Default.LABEL_NOTE_NONE)
    end
    LabelSetText (TOOLTIP_WIN.."NoteText", noteText)

    local colorDef = EA_Window_OpenParty.GetLocationTypeColor(groupLeaderData.locationType)
    LabelSetTextColor(TOOLTIP_WIN.."LocationTypeText", colorDef.r, colorDef.g, colorDef.b)

    local numMembersInTable = 0
    if( groupLeaderData.Group )
    then
        numMembersInTable = #groupLeaderData.Group
    end
    local memberDisplayedIndex = 1
    local groupInformationSet = false
    if( numMembersInTable > 0 )
    then
        for idx=1, numMembersInTable do
            if( WStringsCompareIgnoreGrammer( groupLeaderData.Group[idx].m_memberName, groupLeaderData.leaderName ) == 0 )
            then
                continue
            end
            
            groupInformationSet = true
        
            if( not DoesWindowExist( TOOLTIP_WIN.."GroupMember"..memberDisplayedIndex ) )
            then
                CreateWindowFromTemplate( TOOLTIP_WIN.."GroupMember"..memberDisplayedIndex, "EA_Template_OpenPartyTooltipMember", TOOLTIP_WIN )
                if( memberDisplayedIndex == 1 )
                then
                    WindowAddAnchor( TOOLTIP_WIN.."GroupMember"..memberDisplayedIndex, "bottomleft", TOOLTIP_WIN.."GroupLeader", "topleft", 0, 0 )
                else
                    WindowAddAnchor( TOOLTIP_WIN.."GroupMember"..memberDisplayedIndex, "bottomleft", TOOLTIP_WIN.."GroupMember"..(memberDisplayedIndex-1), "topleft", 0, 0 )
                end
                numMemberWindowsCreated = numMemberWindowsCreated + 1
            end
        
            if (groupLeaderData.Group[idx].m_careerID ~= nil and groupLeaderData.Group[idx].m_careerID ~= 0)
            then
                local iconId = Icons.GetCareerIconIDFromCareerLine(groupLeaderData.Group[idx].m_careerID)
                local texture, x, y = GetIconData(iconId)
                DynamicImageSetTexture(TOOLTIP_WIN.."GroupMember"..memberDisplayedIndex.."CareerIcon", texture, x, y)
            end
            LabelSetText (TOOLTIP_WIN.."GroupMember"..memberDisplayedIndex.."RankText", L"("..GetString(StringTables.Default.LABEL_RANK)..L" "..groupLeaderData.Group[idx].m_level..L")")
            LabelSetText (TOOLTIP_WIN.."GroupMember"..memberDisplayedIndex.."NameText", groupLeaderData.Group[idx].m_memberName)
            WindowSetShowing(TOOLTIP_WIN.."GroupMember"..memberDisplayedIndex, true)
            
            memberDisplayedIndex = memberDisplayedIndex + 1
        end

        if( (memberDisplayedIndex - 1) < numMemberWindowsCreated )
        then
            -- Hide all data for other members
            local startIndex = math.max( memberDisplayedIndex, 1 )
            for idx=startIndex, numMemberWindowsCreated do
                WindowSetShowing(TOOLTIP_WIN.."GroupMember"..idx, false)
            end
        end
    else
        -- Hide all data for other members
        for idx=1, numMemberWindowsCreated do
            WindowSetShowing(TOOLTIP_WIN.."GroupMember"..idx, false)
        end
    end
    
    Tooltips.CreateCustomTooltip (mouseoverWindow, TOOLTIP_WIN)
    
    local partySizeData = {}
    local height    = SET_SEPERATOR
    local width     = c_BASE_TOOLTIP_WIDTH
    local offsX     = SET_PIECE_INDENT
    partySizeData[TOOLTIP_WIN.."GroupLeaderCrownImage"] = { minHeight = 0, isGroupMember=true }
    partySizeData[TOOLTIP_WIN.."GroupLeaderRankText"]   = { minHeight = 0, isGroupMember=true }
    partySizeData[TOOLTIP_WIN.."GroupLeaderNameText"]   = { minHeight = 0, isGroupMember=true }
    partySizeData[TOOLTIP_WIN.."GroupLeaderCareerIcon"] = { minHeight = 0, isGroupMember=true }
    partySizeData[TOOLTIP_WIN.."PartyTypeText"]         = { minHeight = 0 }
    partySizeData[TOOLTIP_WIN.."LocationText"]          = { minHeight = 0 }
    partySizeData[TOOLTIP_WIN.."LocationTypeText"]      = { minHeight = 0 }
    partySizeData[TOOLTIP_WIN.."SpecificInterest1"]     = { minHeight = 0 }
    partySizeData[TOOLTIP_WIN.."SpecificInterest2"]     = { minHeight = 0 }
    partySizeData[TOOLTIP_WIN.."SpecificInterest3"]     = { minHeight = 0 }
    partySizeData[TOOLTIP_WIN.."SpecificInterest4"]     = { minHeight = 0 }
    partySizeData[TOOLTIP_WIN.."NoteText"]              = { minHeight = 0 }

    if (groupInformationSet == true)
    then
        for idx=1, (memberDisplayedIndex-1) do
            partySizeData[TOOLTIP_WIN.."GroupMember"..idx.."NameText"] = { minHeight = 0, isGroupMember=true }
            partySizeData[TOOLTIP_WIN.."GroupMember"..idx.."RankText"] = { minHeight = 0, isGroupMember=true }
            partySizeData[TOOLTIP_WIN.."GroupMember"..idx.."CareerIcon"] = { minHeight = 0, isGroupMember=true }
        end
    end
    for labelName, sizeData in pairs (partySizeData) do
        local x, y = WindowGetOffsetFromParent(labelName)
        if (sizeData.isGroupMember ~= nil and sizeData.isGroupMember == true )
        then
            local newX, newY = WindowGetOffsetFromParent(WindowGetParent(labelName))
            x = x+newX
            y = y+newY
        end

        local sizeX, sizeY = WindowGetDimensions (labelName)

        if ((y+sizeY) > height) then
            height = (y+sizeY)
        end

        if ((x + sizeX) > width) then
            width = (x+sizeX)
        end
    end

    local baseWidth = width
    height = height + SET_SEPERATOR
    width = width + SET_PIECE_INDENT
    WindowSetDimensions( TOOLTIP_WIN, width, height )


    -- Clear the anchors on the divider line (horizontal rule) and reposition its width based on the window's width
    -- so it doesn't look weird when the window stretches to fit the group member names
    local notesWidth, notesHeight = WindowGetDimensions (TOOLTIP_WIN.."NoteText")
    local divLineWidthDiff = (baseWidth - notesWidth) - (SET_PIECE_INDENT * 2)

    WindowClearAnchors(TOOLTIP_WIN.."DivLine")
    WindowAddAnchor(TOOLTIP_WIN.."DivLine", DIVLINE_ANCHOR_TOP.Point, DIVLINE_ANCHOR_TOP.RelativeTo, DIVLINE_ANCHOR_TOP.RelativePoint, DIVLINE_ANCHOR_TOP.XOffset, DIVLINE_ANCHOR_TOP.YOffset)
    if (divLineWidthDiff > 0) then
        WindowAddAnchor(TOOLTIP_WIN.."DivLine", DIVLINE_ANCHOR_BOTTOM.Point, DIVLINE_ANCHOR_BOTTOM.RelativeTo, DIVLINE_ANCHOR_BOTTOM.RelativePoint, DIVLINE_ANCHOR_BOTTOM.XOffset+divLineWidthDiff, DIVLINE_ANCHOR_BOTTOM.YOffset)
    else
        WindowAddAnchor(TOOLTIP_WIN.."DivLine", DIVLINE_ANCHOR_BOTTOM.Point, DIVLINE_ANCHOR_BOTTOM.RelativeTo, DIVLINE_ANCHOR_BOTTOM.RelativePoint, DIVLINE_ANCHOR_BOTTOM.XOffset, DIVLINE_ANCHOR_BOTTOM.YOffset)
    end

    -- Create the tooltip...anchoring magically works!
    Tooltips.AnchorTooltip (anchor)
end