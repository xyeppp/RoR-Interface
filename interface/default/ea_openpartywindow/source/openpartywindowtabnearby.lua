EA_Window_OpenPartyNearby = {}

EA_Window_OpenPartyNearby.REFRESH_DELAY_TIMER = 2

EA_Window_OpenPartyNearby.SORT_LEADERNAME = 1
EA_Window_OpenPartyNearby.SORT_NUM_PLAYERS = 2
EA_Window_OpenPartyNearby.SORT_DISTANCE = 3
EA_Window_OpenPartyNearby.SORT_INTEREST = 4

EA_Window_OpenPartyNearby.MAX_GROUP_MEMBERS = 5

-- Server initially sends us information in this order
EA_Window_OpenPartyNearby.sortDirection = DataUtils.SORT_ORDER_DOWN
EA_Window_OpenPartyNearby.sortBy = EA_Window_OpenPartyNearby.SORT_DISTANCE

EA_Window_OpenPartyNearby.previousInfluenceId = 0

EA_Window_OpenPartyNearby.OpenPartyTable = {}

-- Used to keep the polling of data to a minimum
EA_Window_OpenPartyNearby.RequestDelay = 0

local PARENT_WINDOW = "EA_Window_OpenPartyNearby"


local GroupSortKeys =
{
    ["numGroupMembers"] = { fallback = "leaderName" },
    ["timedDistance"]   = { fallback = "leaderName" },
    ["locationType"]    = { fallback = "leaderName" },
    ["leaderName"]      = {}
}

local GroupSortKeyMap =
{
    [EA_Window_OpenPartyNearby.SORT_LEADERNAME]   = "leaderName",
    [EA_Window_OpenPartyNearby.SORT_NUM_PLAYERS]  = "numGroupMembers",
    [EA_Window_OpenPartyNearby.SORT_DISTANCE]     = "timedDistance",
    [EA_Window_OpenPartyNearby.SORT_INTEREST]     = "locationType"
}

local function CompareGroups( index1, index2 )
    if( index1 == nil ) then
        return false
    end
    if( index2 == nil ) then
        return true
    end

    local data1 = EA_Window_OpenPartyNearby.OpenPartyTable[ index1 ]
    local data2 = EA_Window_OpenPartyNearby.OpenPartyTable[ index2 ]

    if( data1 == nil or data1.leaderName == nil )
    then
        return false
    end
    if( data2 == nil or data2.leaderName == nil )
    then
        return true
    end

    local sortKey = GroupSortKeyMap[ EA_Window_OpenPartyNearby.sortBy ]
    return DataUtils.OrderingFunction( data1, data2, sortKey, GroupSortKeys, EA_Window_OpenPartyNearby.sortDirection )
end

local function SortOpenPartyListData()
    table.sort( EA_Window_OpenPartyNearby.partyListOrder, CompareGroups )
    ListBoxSetDisplayOrder( PARENT_WINDOW.."List", EA_Window_OpenPartyNearby.partyListOrder )
end

local function InitOpenPartyListData()
    EA_Window_OpenPartyNearby.OpenPartyTable = {}
    EA_Window_OpenPartyNearby.OpenPartyTable = GetOpenPartyFullList()

    --[[ Test Data
    for i = 1, 20 do
        local data = GetOpenPartyFullList()[1]
        if( data ) then
            data.leaderName = data.leaderName..i
            data.timedDistance = math.random( 0, 300 )
            data.isWarband = math.random( 0, 1 ) == 0
            table.insert( EA_Window_OpenPartyNearby.OpenPartyTable, data )
        end
    end
    --]]

    EA_Window_OpenPartyNearby.partyListOrder = {}
    for dataIndex, data in ipairs( EA_Window_OpenPartyNearby.OpenPartyTable )
    do
        table.insert( EA_Window_OpenPartyNearby.partyListOrder, dataIndex )
        
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

    SortOpenPartyListData()
end

local function GetOpenPartyDataFromDisplayIndex( displayIndex )
    if( EA_Window_OpenPartyNearbyList.PopulatorIndices == nil )
    then
        return nil
    end

    local dataIndex = EA_Window_OpenPartyNearbyList.PopulatorIndices[ displayIndex ]
    return EA_Window_OpenPartyNearby.OpenPartyTable[ dataIndex ]
end

function EA_Window_OpenPartyNearby.Initialize()

    ButtonSetText( PARENT_WINDOW.."DoneButton", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_OPENPARTY_DONE) )
    ButtonSetText( PARENT_WINDOW.."RefreshButton", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_OPENPARTY_REFRESH) )
    LabelSetText( PARENT_WINDOW.."OpenPartyFlagLabel", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_OPENPARTY_FLAG) )
    ButtonSetPressedFlag( PARENT_WINDOW.."OpenPartyFlagButton", GameData.Player.isOpenPartyInterested )
    
    -- Legend
    LabelSetText( PARENT_WINDOW.."LegendGuildText", GetStringFromTable("SocialStrings", StringTables.Social.OPEN_PARTY_LEGEND_GUILD) )
    local texture, x, y = GetIconData( EA_Window_OpenParty.ICON_GUILD )
    DynamicImageSetTexture( PARENT_WINDOW.."LegendGuildIcon", texture, x, y )
    LabelSetText( PARENT_WINDOW.."LegendAllianceText", GetStringFromTable("SocialStrings", StringTables.Social.OPEN_PARTY_LEGEND_ALLIANCE) )
    local texture, x, y = GetIconData( EA_Window_OpenParty.ICON_ALLIANCE )
    DynamicImageSetTexture( PARENT_WINDOW.."LegendAllianceIcon", texture, x, y )
    LabelSetText( PARENT_WINDOW.."LegendFriendText", GetStringFromTable("SocialStrings", StringTables.Social.OPEN_PARTY_LEGEND_FRIEND) )
    local texture, x, y = GetIconData( EA_Window_OpenParty.ICON_FRIEND )
    DynamicImageSetTexture( PARENT_WINDOW.."LegendFriendIcon", texture, x, y )
    LabelSetText( PARENT_WINDOW.."LegendIgnoredText", GetStringFromTable("SocialStrings", StringTables.Social.OPEN_PARTY_LEGEND_IGNORED) )
    local texture, x, y = GetIconData( EA_Window_OpenParty.ICON_IGNORE )
    DynamicImageSetTexture( PARENT_WINDOW.."LegendIgnoredIcon", texture, x, y )

    -- Sort buttons
    ButtonSetText( PARENT_WINDOW.."PartyLeaderSortButton", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_PARTYLEADER) )
    ButtonSetText( PARENT_WINDOW.."NumPlayersSortButton", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_NUM_PLAYERS) )
    ButtonSetText( PARENT_WINDOW.."DistanceSortButton", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_PARTYDIST) )
    ButtonSetText( PARENT_WINDOW.."InterestSortButton", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_INTEREST) )
    EA_Window_OpenPartyNearby.HideAllSortButtonArrows()
    -- Set default sorting
    EA_Window_OpenPartyNearby.sortBy = EA_Window_OpenPartyNearby.SORT_DISTANCE
    EA_Window_OpenPartyNearby.sortDirection = DataUtils.SORT_ORDER_UP
    WindowSetShowing( PARENT_WINDOW.."DistanceSortButtonUpArrow", true )

    -- Event handlers
    WindowRegisterEventHandler( PARENT_WINDOW, SystemData.Events.PLAYER_CHAPTER_UPDATED,            "EA_Window_OpenPartyNearby.OnPlayerChapterChanged" )
    WindowRegisterEventHandler( PARENT_WINDOW, SystemData.Events.SOCIAL_OPENPARTY_UPDATED,          "EA_Window_OpenPartyNearby.OnOpenPartyUpdated" )
    WindowRegisterEventHandler( PARENT_WINDOW, SystemData.Events.SOCIAL_OPENPARTYINTEREST_UPDATED,  "EA_Window_OpenPartyNearby.OnOpenPartySettingUpdated" )
    WindowRegisterEventHandler( PARENT_WINDOW, SystemData.Events.GROUP_SETTINGS_PRIVACY_UPDATED,    "EA_Window_OpenPartyNearby.OnOpenPartySettingUpdated" )
    WindowRegisterEventHandler( PARENT_WINDOW, SystemData.Events.BATTLEGROUP_UPDATED,               "EA_Window_OpenPartyNearby.OnOpenPartySettingUpdated" )
    WindowRegisterEventHandler( PARENT_WINDOW, SystemData.Events.GROUP_UPDATED,                     "EA_Window_OpenPartyNearby.OnOpenPartySettingUpdated" )
    
    
    LabelSetText( PARENT_WINDOW.."HelpText", GetStringFromTable("SocialStrings", StringTables.Social.OPEN_PARTY_NEARBY_HELP) )


    InitOpenPartyListData()
    EA_Window_OpenPartyNearby.OnOpenPartySettingUpdated()
end

function EA_Window_OpenPartyNearby.OnUpdate( timePassed )
    if (EA_Window_OpenPartyNearby.RequestDelay > 0)
    then
        EA_Window_OpenPartyNearby.RequestDelay = EA_Window_OpenPartyNearby.RequestDelay - timePassed
        if (EA_Window_OpenPartyNearby.RequestDelay < 0)
        then
            EA_Window_OpenPartyNearby.RequestDelay = 0
        end
    end
end

function EA_Window_OpenPartyNearby.ToggleOpenPartyInterestFlag()
    if( ButtonGetDisabledFlag( PARENT_WINDOW.."OpenPartyFlagButton") )
    then
        return
    end

    if( IsWarBandActive() )
    then
        if( GameData.Player.Group.Settings.isPublic == true )
        then
            SendChatText( L"/warbandconvert 0", L"" )
        else
            SendChatText( L"/warbandconvert 1", L"" )
        end
    elseif( PartyUtils.IsPartyActive() )
    then
        if( GameData.Player.Group.Settings.isPublic == true )
        then
            SendChatText( L"/partyprivate", L"" )
        else
            SendChatText( L"/partyopen", L"" )
        end
    else
        -- Player is solo
        SendChatText( L"/openpartyinterest", L"" )
    end
    
    -- Toggle the button here
    local isPressed = ButtonGetPressedFlag( PARENT_WINDOW.."OpenPartyFlagButton" )
    ButtonSetPressedFlag( PARENT_WINDOW.."OpenPartyFlagButton", not isPressed )
end

function EA_Window_OpenPartyNearby.OnOpenPartySettingUpdated()
    -- Ensure the button is set to what the server is
    if( IsWarBandActive() or PartyUtils.IsPartyActive() )
    then
        ButtonSetDisabledFlag( PARENT_WINDOW.."OpenPartyFlagButton", GameData.Player.isGroupLeader == false )
        ButtonSetPressedFlag( PARENT_WINDOW.."OpenPartyFlagButton", GameData.Player.Group.Settings.isPublic == true )
    else
        ButtonSetDisabledFlag( PARENT_WINDOW.."OpenPartyFlagButton", false )
        ButtonSetPressedFlag( PARENT_WINDOW.."OpenPartyFlagButton", GameData.Player.isOpenPartyInterested == true )
    end
end

function EA_Window_OpenPartyNearby.OnPlayerChapterChanged()
    -- As long as we are not in an RVR area
    if (GameData.Player.influenceID ~= 0 and (EA_Window_OpenPartyNearby.previousInfluenceId == 0
                or GameData.Player.influenceID ~= EA_Window_OpenPartyNearby.previousInfluenceId) )
    then
        EA_Window_OpenPartyNearby.previousInfluenceId = GameData.Player.influenceID
        SendOpenPartySearchRequest( GameData.OpenPartyRequestType.ALL_BRIEF )
    end
end

function EA_Window_OpenPartyNearby.RequestUpdateFullList()
    if (EA_Window_OpenPartyNearby.RequestDelay == 0)
    then
        SendOpenPartySearchRequest( GameData.OpenPartyRequestType.ALL )
        EA_Window_OpenPartyNearby.RequestDelay = EA_Window_OpenPartyNearby.REFRESH_DELAY_TIMER
    end
end

function EA_Window_OpenPartyNearby.PopulateOpenParties()
    if( EA_Window_OpenPartyNearbyList.PopulatorIndices == nil )
    then
        return
    end

    for rowIndex, dataIndex in ipairs( EA_Window_OpenPartyNearbyList.PopulatorIndices )
    do
    	local rowWindow = PARENT_WINDOW.."ListRow"..rowIndex
		local groupData = EA_Window_OpenPartyNearby.OpenPartyTable[ dataIndex ]
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
            if( groupData.timedDistance >= 60 )
            then
                LabelSetText( rowWindow.."TimedDistanceText", GetFormatStringFromTable( "SocialStrings",  StringTables.Social.LABEL_SOCIAL_TIMEDIST_MIN, { math.floor(groupData.timedDistance/60) } ) )
            else
                LabelSetText( rowWindow.."TimedDistanceText", GetFormatStringFromTable( "SocialStrings",  StringTables.Social.LABEL_SOCIAL_TIMEDIST_SEC, { groupData.timedDistance } ) )
            end

            -- Set location text
            LabelSetText( rowWindow.."LocationTypeText", EA_Window_OpenParty.GetLocationTypeName( groupData.locationType ) )
            local color = EA_Window_OpenParty.GetLocationTypeColor( groupData.locationType )
            LabelSetTextColor( rowWindow.."LocationTypeText", color.r, color.g, color.b )

            -- Set button text
            ButtonSetText( rowWindow.."JoinPartyButton", GetString( StringTables.Default.LABEL_JOIN ) )
            
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

-- Get the list of available parties.  This is by request, if the user Refreshes or opens the main window this will
-- poll the server to find all available parties.
function EA_Window_OpenPartyNearby.OnOpenPartyUpdated()

    InitOpenPartyListData()

    if( EA_Window_OpenPartyNearby.OpenPartyTable == nil or #EA_Window_OpenPartyNearby.OpenPartyTable <= 0 )
    then
        LabelSetText( PARENT_WINDOW.."NoOpenPartiesHeader", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_HEADER_NOOPENPARTY) )
        WindowSetShowing( PARENT_WINDOW.."NoOpenPartiesHeader", true )
    else
        WindowSetShowing( PARENT_WINDOW.."NoOpenPartiesHeader", false )
    end

end

function EA_Window_OpenPartyNearby.UpdatePartyTooltipFromButton()
    local rowWindow = WindowGetParent( SystemData.MouseOverWindow.name )
    local windowIdx = WindowGetId( rowWindow )
    EA_Window_OpenPartyNearby.UpdatePartyTooltip( windowIdx, rowWindow )
end

function EA_Window_OpenPartyNearby.UpdatePartyTooltipFromWindow()
    local windowIdx = WindowGetId( SystemData.MouseOverWindow.name )
    EA_Window_OpenPartyNearby.UpdatePartyTooltip( windowIdx, SystemData.MouseOverWindow.name )
end

function EA_Window_OpenPartyNearby.UpdatePartyTooltip( displayIndex, rowWindow )

    if( rowWindow == nil )
    then
        return
    end

    local openPartyData = GetOpenPartyDataFromDisplayIndex( displayIndex )
    if( openPartyData )
    then
        local tooltipAnchor = { Point = "topright", RelativeTo = rowWindow, RelativePoint = "topleft", XOffset = 32, YOffset = 0 }
        EA_Window_OpenPartyNearby.CreateOpenPartyTooltip( openPartyData, SystemData.MouseOverWindow.name, tooltipAnchor )
    end
end

function EA_Window_OpenPartyNearby.JoinPartySpecified()
    if( EA_Window_OpenPartyNearbyList.PopulatorIndices == nil
        or ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) == true )
    then
        return
    end

    local windowId = WindowGetId( SystemData.ActiveWindow.name )
    local dataId = EA_Window_OpenPartyNearbyList.PopulatorIndices[ windowId ]
    local groupData = EA_Window_OpenPartyNearby.OpenPartyTable[ dataId ]

    local text = L"/partyjoin "..groupData.leaderName
    if( groupData.isWarband == true )
    then
        text = L"/warbandjoin "..groupData.leaderName
    end
    
    SendChatText( text, L"" )
    EA_Window_OpenParty.ToggleFullWindow()
end

function EA_Window_OpenPartyNearby.OnRButtonUpGroupLeaderLine()

    local windowId = WindowGetId( SystemData.ActiveWindow.name )
    local partyData = GetOpenPartyDataFromDisplayIndex( windowId )
    
    if( partyData == nil )
    then
        return
    end

    PlayerMenuWindow.ShowMenu( partyData.leaderName, 0 )
end

--------------------------------
-- Sorting Functions
--------------------------------
function EA_Window_OpenPartyNearby.HideAllSortButtonArrows()
    WindowSetShowing( PARENT_WINDOW.."PartyLeaderSortButtonUpArrow", false)
    WindowSetShowing( PARENT_WINDOW.."PartyLeaderSortButtonDownArrow", false)
    WindowSetShowing( PARENT_WINDOW.."NumPlayersSortButtonUpArrow", false)
    WindowSetShowing( PARENT_WINDOW.."NumPlayersSortButtonDownArrow", false)
    WindowSetShowing( PARENT_WINDOW.."DistanceSortButtonUpArrow", false)
    WindowSetShowing( PARENT_WINDOW.."DistanceSortButtonDownArrow", false)
    WindowSetShowing( PARENT_WINDOW.."InterestSortButtonUpArrow", false)
    WindowSetShowing( PARENT_WINDOW.."InterestSortButtonDownArrow", false)
end

function EA_Window_OpenPartyNearby.OnLButtonUpSortButton()
    if( EA_Window_OpenPartyNearby.OpenPartyTable == nil or #EA_Window_OpenPartyNearby.OpenPartyTable <= 0 )
    then
        return
    end

    local sortId = WindowGetId( SystemData.ActiveWindow.name )

    EA_Window_OpenPartyNearby.HideAllSortButtonArrows()
    if( EA_Window_OpenPartyNearby.sortBy == sortId )
    then
        if( EA_Window_OpenPartyNearby.sortDirection == DataUtils.SORT_ORDER_UP )
        then
            EA_Window_OpenPartyNearby.sortDirection = DataUtils.SORT_ORDER_DOWN
            WindowSetShowing( SystemData.ActiveWindow.name.."DownArrow", true )
        else
            EA_Window_OpenPartyNearby.sortDirection = DataUtils.SORT_ORDER_UP
            WindowSetShowing( SystemData.ActiveWindow.name.."UpArrow", true )
        end
    else
        EA_Window_OpenPartyNearby.sortBy = sortId
        EA_Window_OpenPartyNearby.sortDirection = DataUtils.SORT_ORDER_UP
        WindowSetShowing( SystemData.ActiveWindow.name.."UpArrow", true )
    end

    SortOpenPartyListData()
end



----------------------------------------------------------
-- Tooltip Function
----------------------------------------------------------
local numMemberWindowsCreated = 0
function EA_Window_OpenPartyNearby.CreateOpenPartyTooltip( groupLeaderData, mouseoverWindow, anchor )

    local TOOLTIP_WIN = "EA_Tooltip_OpenParty"
    local SET_SEPERATOR         = 15
    local SET_PIECE_INDENT      = 5
    local DIVLINE_ANCHOR_TOP    = { Point = "bottomleft", RelativeTo = TOOLTIP_WIN.."NoteText", RelativePoint = "bottomleft", XOffset = 0, YOffset = 5 }
    local DIVLINE_ANCHOR_BOTTOM = { Point = "bottomright", RelativeTo = TOOLTIP_WIN.."NoteText", RelativePoint = "bottomright", XOffset = 0, YOffset = 7 }


    if( groupLeaderData == nil ) then
        return
    end

    local labelText = L"";
    local c_BASE_TOOLTIP_WIDTH = 300;
    local height, width
    
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

    LabelSetText (TOOLTIP_WIN.."LocationText", GetString (StringTables.Default.LABEL_SOLO_LOCATION))

    if (groupLeaderData.locationType == GameData.OpenPartyInterest.RVR)
    then
        LabelSetText (TOOLTIP_WIN.."ObjectiveText",     groupLeaderData.pvpAreaName)
    else
        if (groupLeaderData.influenceID ~= 0)
        then
            if (groupLeaderData.objectiveName ~= nil and groupLeaderData.objectiveName ~= L"Empty" and groupLeaderData.objectiveName ~= L"" )
            then
                LabelSetText (TOOLTIP_WIN.."ObjectiveText",     GetChapterName(groupLeaderData.influenceID)..L": "..groupLeaderData.objectiveName)
            else
                LabelSetText (TOOLTIP_WIN.."ObjectiveText",     GetChapterName(groupLeaderData.influenceID))
            end
        else
            LabelSetText (TOOLTIP_WIN.."ObjectiveText", L" ")
        end
    end

    local stringText = EA_Window_OpenParty.GetLocationTypeName(groupLeaderData.locationType)
    LabelSetText (TOOLTIP_WIN.."LocationTypeText", L"("..stringText..L")")

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

    -- Create the tooltip...anchoring magically works!
    Tooltips.CreateCustomTooltip (mouseoverWindow, TOOLTIP_WIN)

    local itemSetSizeData = { }
    local height    = SET_SEPERATOR
    local width     = c_BASE_TOOLTIP_WIDTH
    local offsX     = SET_PIECE_INDENT
    itemSetSizeData[TOOLTIP_WIN.."GroupLeaderCrownImage"] = { minHeight = 0, isGroupMember=true }
    itemSetSizeData[TOOLTIP_WIN.."GroupLeaderRankText"]   = { minHeight = 0, isGroupMember=true }
    itemSetSizeData[TOOLTIP_WIN.."GroupLeaderNameText"]   = { minHeight = 0, isGroupMember=true }
    itemSetSizeData[TOOLTIP_WIN.."GroupLeaderCareerIcon"] = { minHeight = 0, isGroupMember=true }
    itemSetSizeData[TOOLTIP_WIN.."PartyTypeText"]         = { minHeight = 0 }
    itemSetSizeData[TOOLTIP_WIN.."LocationText"]          = { minHeight = 0 }
    itemSetSizeData[TOOLTIP_WIN.."ObjectiveText"]         = { minHeight = 0 }
    itemSetSizeData[TOOLTIP_WIN.."LocationTypeText"]      = { minHeight = 0 }
    itemSetSizeData[TOOLTIP_WIN.."NoteText"]              = { minHeight = 0 }

    if (groupInformationSet == true)
    then
        for idx=1, (memberDisplayedIndex-1) do
            itemSetSizeData[TOOLTIP_WIN.."GroupMember"..idx.."NameText"] = { minHeight = 0, isGroupMember=true }
            itemSetSizeData[TOOLTIP_WIN.."GroupMember"..idx.."RankText"] = { minHeight = 0, isGroupMember=true }
            itemSetSizeData[TOOLTIP_WIN.."GroupMember"..idx.."CareerIcon"] = { minHeight = 0, isGroupMember=true }
        end
    end
    for labelName, sizeData in pairs (itemSetSizeData) do
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

    WindowSetShowing(TOOLTIP_WIN.."BackgroundBorder", true)
    WindowSetShowing(TOOLTIP_WIN.."BackgroundInner", true)
    Tooltips.AnchorTooltip (anchor)
end
