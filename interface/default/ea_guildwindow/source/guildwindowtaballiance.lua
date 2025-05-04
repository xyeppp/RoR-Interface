----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

GuildWindowTabAlliance = {}

GuildWindowTabAlliance.guilds = {}				-- The data about the guilds
GuildWindowTabAlliance.guildsListbox = {}		-- The data populated in the listbox (includes player rows, etc.)
GuildWindowTabAlliance.guildsListboxOrder = {}  -- The order in which the guildsListbox data is populated
GuildWindowTabAlliance.guildsListboxOrderMyGuild = {}

GuildWindowTabAlliance.SelectedAllianceMemberName = L""

GuildWindowTabAlliance.CHANGE_ALLIANCE_MODE_INVITE  = 1
GuildWindowTabAlliance.CHANGE_ALLIANCE_MODE_KICK	= 2
GuildWindowTabAlliance.ChangingAllianceMode = 1

-- These are used to determine what the subtype of message is. These must match the switch statement in war_interface::LuaSendGuildAllianceCommand
GuildWindowTabAlliance.COMMAND_POLL_CREATE	= 1
GuildWindowTabAlliance.COMMAND_POLL_CANCEL	= 2
GuildWindowTabAlliance.COMMAND_POLL_VOTE	= 3

GuildWindowTabAlliance.AllianceRankTitles = {}
GuildWindowTabAlliance.AllianceRankTitles[1] = GetGuildString(StringTables.Guild.TEXT_ALLIANCE_RANK0)
GuildWindowTabAlliance.AllianceRankTitles[2] = GetGuildString(StringTables.Guild.TEXT_ALLIANCE_RANK1)
GuildWindowTabAlliance.AllianceRankTitles[3] = GetGuildString(StringTables.Guild.TEXT_ALLIANCE_RANK2)
GuildWindowTabAlliance.AllianceRankTitles[4] = GetGuildString(StringTables.Guild.TEXT_ALLIANCE_RANK3)
GuildWindowTabAlliance.AllianceRankTitles[5] = GetGuildString(StringTables.Guild.TEXT_ALLIANCE_RANK4)

GuildWindowTabAlliance.SORT_NAME = 1
GuildWindowTabAlliance.SORT_RANK = 2
GuildWindowTabAlliance.SORT_GUILD = 3
GuildWindowTabAlliance.sortDirection = DataUtils.SORT_ORDER_UP
GuildWindowTabAlliance.sortBy = GuildWindowTabAlliance.SORT_GUILD

GuildWindowTabAlliance.showMyGuild = false


local AllianceMemberSortKeys =
{
    ["name"]                    = {},
    ["allianceMemberRank"]      = { fallback = "name" },
    ["guildName"]               = { fallback = "allianceMemberRank" }
}

local AllianceMemberSortKeyMap =
{
    [GuildWindowTabAlliance.SORT_NAME]  = "name",
    [GuildWindowTabAlliance.SORT_RANK]  = "allianceMemberRank",
    [GuildWindowTabAlliance.SORT_GUILD] = "guildName",
}

local function CompareMembers( index1, index2 )
    if( index2 == nil ) then
        return false
    end

    local player1 = GuildWindowTabAlliance.guildsListbox[index1]
    local player2 = GuildWindowTabAlliance.guildsListbox[index2]
    
    if (player1 == nil or player1.name == nil or player1.name == L"") then
        return false
    end
    
    if (player2 == nil or player2.name == nil or player2.name == L"") then
        return true
    end

    local sortKey = AllianceMemberSortKeyMap[ GuildWindowTabAlliance.sortBy ]
    return DataUtils.OrderingFunction( player1, player2, sortKey, AllianceMemberSortKeys, GuildWindowTabAlliance.sortDirection )
end

-- This function sorts and filters the list
local function SortAllianceList()
    local orderTable = GuildWindowTabAlliance.guildsListboxOrder
    if GuildWindowTabAlliance.showMyGuild then
        orderTable = GuildWindowTabAlliance.guildsListboxOrderMyGuild
    end
    
    table.sort( orderTable, CompareMembers )
	ListBoxSetDisplayOrder( "GWAllianceInAllianceListboxMembers", orderTable )
end

----------------------------------------------------------------
-- GuildWindowTabAlliance Functions
----------------------------------------------------------------

function GuildWindowTabAlliance.Initialize()
	----------------------------
	-- In Alliance Components --
	----------------------------

	ButtonSetText("GWAllianceInAllianceLeaveAllianceButton", GetGuildString(StringTables.Guild.BUTTON_GUILD_COMMAND_LEAVE_ALLIANCE))
	ButtonSetText("GWAllianceInAllianceJoinAllianceButton", GetGuildString(StringTables.Guild.BUTTON_GUILD_COMMAND_JOIN_ALLIANCE))
	
    LabelSetText( "GWAllianceInAllianceShowGuildHeader", GetGuildString( StringTables.Guild.LABEL_SHOW_MY_GUILD ) )
	ButtonSetCheckButtonFlag( "GWAllianceInAllianceShowGuildCheckBox", true )
	
	WindowSetShowing("GWAllianceInAllianceJoinAllianceWithGuildLeaderHeader", false)	-- Only shows when joining an existing Alliance
	WindowSetShowing("GWAllianceInAllianceJoinAllianceWithGuildLeaderEditBox", false)	-- Only shows when joining an existing Alliance
	WindowSetShowing("GWAllianceInAllianceJoinAllianceWithGuildLeaderBackground", false)	-- Only shows when joining an existing Alliance

	GuildWindowTabAlliance.SetListRowTints()
	
	ButtonSetText( "GWAllianceInAllianceMemberNameSortButton", GetGuildString( StringTables.Guild.ALLIANCE_SORT_NAME ) )
	ButtonSetText( "GWAllianceInAllianceRankSortButton", GetGuildString( StringTables.Guild.ALLIANCE_SORT_RANK ) )
	ButtonSetText( "GWAllianceInAllianceGuildSortButton", GetGuildString( StringTables.Guild.ALLIANCE_SORT_GUILD ) )
	GuildWindowTabAlliance.HideAllSortButtonArrows()
	WindowSetShowing( "GWAllianceInAllianceGuildSortButtonUpArrow", true ) -- Default sort
	
    for index = 1, SystemData.Alliance.MAX_GUILDS
    do
        local alliedGuildWindow = "GWAllianceInAllianceAlliedGuildsScrollChild"..index
        local parentWindow = "GWAllianceInAllianceAlliedGuildsScrollChild"
        CreateWindowFromTemplate( alliedGuildWindow, "AlliedGuildSummary", parentWindow )
        if( index == 1 )
        then
            WindowAddAnchor( alliedGuildWindow, "topleft", parentWindow, "topleft", 0, 0 )
        else
            WindowAddAnchor( alliedGuildWindow, "bottomleft", parentWindow..(index-1), "topleft", 0, 0 )
        end
        WindowSetId( alliedGuildWindow, index )
        
        LabelSetText( alliedGuildWindow.."LeaderNameLabel", GetGuildString( StringTables.Guild.LABEL_ALLIANCE_LEADER_NAME ) )
        LabelSetText( alliedGuildWindow.."DateCreatedLabel", GetGuildString( StringTables.Guild.LABEL_ALLIANCE_DATE_CREATED ) )
        LabelSetText( alliedGuildWindow.."MembersLabel", GetGuildString( StringTables.Guild.LABEL_ALLIANCE_MEMBERS ) )
        LabelSetText( alliedGuildWindow.."RankLabel", GetGuildString( StringTables.Guild.LABEL_ALLIANCE_RANK ) )
        LabelSetText( alliedGuildWindow.."KeepLabel", GetGuildString( StringTables.Guild.LABEL_ALLIANCE_KEEP ) )
       
        DynamicImageSetTexture( alliedGuildWindow.."Heraldry", "render_scene_alliance_heraldry"..index, 0, 0 )
    end

	--------------------------------
	-- Not In Alliance Components --
	--------------------------------
	LabelSetText( "GWAllianceNotInAllianceFormAllianceInstructions", GetGuildString( StringTables.Guild.TEXT_HOW_TO_FORM_AN_ALLIANCE) )
	LabelSetText( "GWAllianceNotInAllianceAllianceNameHeader", GetGuildString( StringTables.Guild.HEADER_ENTER_ALLIANCE_NAME) )
	LabelSetText( "GWAllianceNotInAllianceGuildLeaderNameHeader", GetGuildString( StringTables.Guild.HEADER_ENTER_MEMBER_NAME) )
    ButtonSetText("GWAllianceNotInAllianceFormAllianceButton", GetGuildString( StringTables.Guild.BUTTON_GUILD_ALLIANCE_FORM_ALLIANCE ) )

	-------------------------
	-- Other Initialzation --
	-------------------------
    WindowRegisterEventHandler( "GWAlliance", SystemData.Events.ALLIANCE_UPDATED, "GuildWindowTabAlliance.ForceUpdate" )
    
    GuildWindowTabAlliance.ForceUpdate()
end

function GuildWindowTabAlliance.Shutdown()

end

function GuildWindowTabAlliance.OnLButtonUpShowGuildCheckBox()
    GuildWindowTabAlliance.showMyGuild = ButtonGetPressedFlag( "GWAllianceInAllianceShowGuildCheckBox" )
    SortAllianceList()
end

function GuildWindowTabAlliance.PopulateAllianceList()
	GuildWindowTabAlliance.guildsListbox = {}
	GuildWindowTabAlliance.guildsListboxOrder = {}
	GuildWindowTabAlliance.guildsListboxOrderMyGuild = {}
	
	local guildPollData = GetGuildPollData()

    -- Update alliance display data
    local nextRow = 1
    local guildCount = 0
    local kickPollCount = 0
    for guildIndex, guild in ipairs( GuildWindowTabAlliance.guilds )
    do
        guildCount = guildCount + 1
        
        local alliedGuildWindow = "GWAllianceInAllianceAlliedGuildsScrollChild"..guildCount

        LabelSetText( alliedGuildWindow.."Name", guild.name )
        LabelSetText( alliedGuildWindow.."LeaderName", guild.leaderName )
        local dateText = GetFormatStringFromTable( "guildstrings", StringTables.Guild.DATE_FORMAT_DAY_MONTH_YEAR_NUMBERS, { guild.creationDay, guild.creationMonth, guild.creationYear } )
        LabelSetText( alliedGuildWindow.."DateCreated", dateText )
        local membersText = GetStringFormatFromTable( "guildstrings", StringTables.Guild.LABEL_MEMBERS_ONLINE, { towstring( guild.online + guild.offline ), towstring( guild.online ) } )
        LabelSetText( alliedGuildWindow.."Members", membersText )
        LabelSetText( alliedGuildWindow.."Rank", towstring( guild.rank ) )
        
        local keepText = L""
        if( guild.keep.idNum ~= 0 )
        then
            keepText = GetKeepName( guild.keep.idNum )
        else
            keepText = GetString( StringTables.Default.LABEL_NONE )
        end
        LabelSetText( alliedGuildWindow.."Keep", keepText )
        
        if ( GameData.Guild.m_GuildID ~= guild.id )
        then
            WindowSetShowing( alliedGuildWindow.."KickVoteButton", true )
            
            local hasActiveKickPoll = false
            for pollId, pollData in pairs( guildPollData )
            do
                if ( ( pollData.subjectID == guild.id ) and ( pollData.pollType == GuildWindow.POLL_TYPE_KICK ) )
                then
                    hasActiveKickPoll = true
                    WindowSetId( alliedGuildWindow.."KickVoteButton", pollId )
                    if ( GameData.Guild.m_GuildID == pollData.creatorID )
                    then
                        ButtonSetText( alliedGuildWindow.."KickVoteButton", GetGuildString( StringTables.Guild.TEXT_ALLIANCE_VOTE_CANCEL_BUTTON ) )
                    else
                        ButtonSetText( alliedGuildWindow.."KickVoteButton", GetGuildString( StringTables.Guild.TEXT_ALLIANCE_VOTE_BUTTON ) )
                    end
                    kickPollCount = kickPollCount + 1
                    break
			    end
		    end
            
            if ( not hasActiveKickPoll )
            then
                WindowSetId( alliedGuildWindow.."KickVoteButton", -1 )
                ButtonSetText( alliedGuildWindow.."KickVoteButton", GetGuildString( StringTables.Guild.TEXT_ALLIANCE_KICK_GUILD_BUTTON ) )
            end
        else
            WindowSetShowing( alliedGuildWindow.."KickVoteButton", false )
        end
        
        WindowSetShowing( alliedGuildWindow, true )
    
        -- Add all the Alliance Officers from all the Guilds
        for playerIndex, player in ipairs( guild.players )
        do
            local playerEntry = {
                    name = player.name,
					allianceMemberRank = player.rank,
					allianceMemberRankTitle = GuildWindowTabAlliance.AllianceRankTitles[player.rank+1],
					guildID = guild.id,
					guildName = guild.name
                    }
            table.insert( GuildWindowTabAlliance.guildsListbox, nextRow, playerEntry )
            table.insert( GuildWindowTabAlliance.guildsListboxOrder, nextRow )
            
            nextRow = nextRow + 1
        end
    end
    
    -- Add all the members of your own Guild (so you can r-click on them to promote/demote).
    if GuildWindowTabRoster.memberListData ~= nil then
        for key, value in ipairs( GuildWindowTabRoster.memberListData ) do
            local playerEntry = {
                    name = value.name,
                    allianceMemberRank = value.rankInAlliance,
                    allianceMemberRankTitle = GuildWindowTabAlliance.AllianceRankTitles[value.rankInAlliance+1],
                    guildID = GameData.Guild.m_GuildID,
                    guildName = GameData.Guild.m_GuildName
                    }
            table.insert( GuildWindowTabAlliance.guildsListbox, nextRow, playerEntry )
            table.insert( GuildWindowTabAlliance.guildsListboxOrderMyGuild, nextRow )
            
            nextRow = nextRow + 1
        end
    end
    
    for index = guildCount + 1, SystemData.Alliance.MAX_GUILDS
    do
        WindowSetShowing( "GWAllianceInAllianceAlliedGuildsScrollChild"..index, false )
    end
    
    ScrollWindowUpdateScrollRect( "GWAllianceInAllianceAlliedGuilds" )
    
    if ( kickPollCount > 0 )
    then
        local kickPollText = GetFormatStringFromTable( "guildstrings", StringTables.Guild.TEXT_ALLIANCE_KICK_POLL_OVERVIEW, { towstring(kickPollCount) } )
        LabelSetText( "GWAllianceInAllianceKickPollCount", kickPollText )
        WindowSetShowing( "GWAllianceInAllianceKickPollCount", true )
        WindowSetShowing( "GWAllianceInAllianceKickPollIcon", true )
    else
        WindowSetShowing( "GWAllianceInAllianceKickPollCount", false )
        WindowSetShowing( "GWAllianceInAllianceKickPollIcon", false )
    end
    
    -- If the kick poll window is showing, update it
    if ( DoesWindowExist( "EA_AllianceKickPollWindow" ) and WindowGetShowing( "EA_AllianceKickPollWindow" ) )
    then
        local pollId = WindowGetId( "EA_AllianceKickPollWindow" )
        local pollData = guildPollData[pollId]
        if ( pollData == nil )
        then
            -- Poll no longer exists, close the window
            WindowSetShowing( "EA_AllianceKickPollWindow", false )
        else
            GuildWindowTabAlliance.UpdateKickPollWindow( pollData )
        end
    end
end

function GuildWindowTabAlliance.DrawMembersList()
	-- Drawing the Alliance Roster involves 4 things:
	GuildWindowTabAlliance.PopulateAllianceList()	-- 1) Populate each visible row with with either a Guild Name or a Guild Member
	GuildWindowTabAlliance.UpdateAllianceList()		-- 2)Filter, 3)Sort, and 4)Update
end

function GuildWindowTabAlliance.UpdateVisibleComponents()
    -- Show/hide components depending on whether we're in an alliance.
    local inAlliance = (GameData.Guild.Alliance.Id ~= 0)
    WindowSetShowing( "GWAllianceInAlliance", inAlliance )
    WindowSetShowing( "GWAllianceNotInAlliance", not inAlliance )
end

function GuildWindowTabAlliance.ForceUpdate()
    GameData.Guild.Alliance.UpdatedInfo = true
    GameData.Guild.Alliance.UpdatedMembers = true
    GameData.Guild.Alliance.UpdatedPlayerCounts = true
    GuildWindowTabAlliance.OnAllianceUpdated()
end

function GuildWindowTabAlliance.OnAllianceUpdated()
    if ( GameData.Guild.Alliance.UpdatedInfo ) then
		LabelSetText("GWAllianceInAllianceName", GameData.Guild.Alliance.Name)
        GuildWindowTabAlliance.UpdateVisibleComponents()
        GameData.Guild.Alliance.UpdatedInfo = false
    end
    
    if ( GameData.Guild.Alliance.UpdatedMembers ) then
        GuildWindowTabAlliance.guilds = GetAllianceMemberData()
        GuildWindowTabAlliance.DrawMembersList()
        GameData.Guild.Alliance.UpdatedMembers = false
    end
    
    if ( GameData.Guild.Alliance.UpdatedPlayerCounts ) then
        for rowIndex, rowData in ipairs(GuildWindowTabAlliance.guilds) do
            local online, offline = GetAllianceMemberCounts(rowData.id)
            GuildWindowTabAlliance.guilds[rowIndex].online = online
            GuildWindowTabAlliance.guilds[rowIndex].offline = offline
        end
        GameData.Guild.Alliance.UpdatedPlayerCounts = false
    end
	
	-- Does the count to see how many members are online and total members in the alliance
	local totalOnline = 0
	local total = 0
	
	for guildIndex, guild in ipairs (GuildWindowTabAlliance.guilds)
	do
	    totalOnline = totalOnline + guild.online
		total = total + guild.online + guild.offline
	end
	
	local onlineText = GetFormatStringFromTable( "guildstrings", StringTables.Guild.TEXT_ROSTER_X_OF_Y_ALLIANCE_MEMBERS_ONLINE, { total, totalOnline } )
	LabelSetText( "GWAllianceInAllianceTotalOnline", onlineText )
	
end

function GuildWindowTabAlliance.UpdateKickPollWindow( pollData )
    local yesVotes = 0
    local noVotes = 0
    for _, vote in pairs( pollData.votes )
    do
        if ( vote )
        then
            yesVotes = yesVotes + 1
        else
            noVotes = noVotes + 1
        end
    end
    
    LabelSetText( "EA_AllianceKickPollWindowYesTally", GetStringFormatFromTable( "guildstrings", StringTables.Guild.TEXT_ALLIANCE_KICK_POLL_CURRENT_TALLY, { towstring( yesVotes ) } ) )
    LabelSetText( "EA_AllianceKickPollWindowNoTally", GetStringFormatFromTable( "guildstrings", StringTables.Guild.TEXT_ALLIANCE_KICK_POLL_CURRENT_TALLY, { towstring( noVotes ) } ) )
        
    ButtonSetDisabledFlag( "EA_AllianceKickPollWindowCancelPollButton", GameData.Guild.m_GuildID ~= pollData.creatorID )
    local ourVote = pollData.votes[GameData.Guild.m_GuildID]
    if ( ourVote == nil )
    then
        ButtonSetDisabledFlag( "EA_AllianceKickPollWindowVoteYesButton", false )
        ButtonSetDisabledFlag( "EA_AllianceKickPollWindowVoteNoButton", false )
        WindowSetShowing( "EA_AllianceKickPollWindowYourVoteText", false )
    else
        ButtonSetDisabledFlag( "EA_AllianceKickPollWindowVoteYesButton", true )
        ButtonSetDisabledFlag( "EA_AllianceKickPollWindowVoteNoButton", true )
        WindowSetShowing( "EA_AllianceKickPollWindowYourVoteText", true )
        if ( ourVote )
        then
            LabelSetText( "EA_AllianceKickPollWindowYourVoteText", GetGuildString( StringTables.Guild.TEXT_ALLIANCE_KICK_POLL_YOU_VOTED_YES ) )
        else
            LabelSetText( "EA_AllianceKickPollWindowYourVoteText", GetGuildString( StringTables.Guild.TEXT_ALLIANCE_KICK_POLL_YOU_VOTED_NO ) )
        end
    end
end

function GuildWindowTabAlliance.OnLButtonUpFormAllianceButton()
	local allianceName = TextEditBoxGetText("GWAllianceNotInAllianceAllianceNameEditBox")
	local guildLeaderName = TextEditBoxGetText("GWAllianceNotInAllianceAllianceGuildLeaderEditBox")

	if allianceName == nil or allianceName == L"" or guildLeaderName == nil or guildLeaderName == L"" then
		return
	end

    SendChatText( L"/allianceform "..guildLeaderName..L" "..allianceName, L"" )
end

-- Sets the background tinting for each row in the member list
function GuildWindowTabAlliance.SetListRowTints()
    for row = 1, GWAllianceInAllianceListboxMembers.numVisibleRows do

        local row_mod = math.mod(row, 2)
        local color = DataUtils.GetAlternatingRowColorGreyOnGrey( row_mod )
        local targetRowWindow = "GWAllianceInAllianceListboxMembersRow"..row
        
        WindowSetTintColor(targetRowWindow.."Background", color.r, color.g, color.b )
        WindowSetAlpha(targetRowWindow.."Background", color.a)
        
        DefaultColor.LabelSetTextColor( targetRowWindow.."Name", DefaultColor.GUILD_ROSTER_NAME )
    end
end

function GuildWindowTabAlliance.OnLButtonUpLeaveAllianceButton()
	-- Create Confirmation Dialog
    DialogManager.MakeTwoButtonDialog( GetGuildString(StringTables.Guild.DIALOG_ALLIANCE_LEAVE_ARE_YOU_SURE ),
                                       GetString( StringTables.Default.LABEL_YES ),
                                       GuildWindowTabAlliance.ConfirmedLeaveAlliance,
                                       GetString( StringTables.Default.LABEL_NO ),
                                       nil,
                                       nil,
                                       nil,
                                       false,
                                       nil )
end

function GuildWindowTabAlliance.ConfirmedLeaveAlliance()
    SendChatText( L"/allianceleave", L"" )
end

function GuildWindowTabAlliance.ChangingAlliance(_isJoining)
	if _isJoining == nil then 
		_isJoining = false 
	end

	WindowSetShowing("GWAllianceInAllianceJoinAllianceWithGuildLeaderHeader", _isJoining)
	WindowSetShowing("GWAllianceInAllianceJoinAllianceWithGuildLeaderEditBox", _isJoining)
	WindowSetShowing("GWAllianceInAllianceJoinAllianceWithGuildLeaderBackground", _isJoining)
		
	WindowSetShowing("GWAllianceInAllianceLeaveAllianceButton",  not _isJoining)
	WindowSetShowing("GWAllianceInAllianceJoinAllianceButton",   not _isJoining)

	-- Clear any text that may already be in the edit box
	TextEditBoxSetText("GWAllianceNotInAllianceAllianceGuildLeaderEditBox", L"")

	WindowAssignFocus("GWAllianceInAllianceJoinAllianceWithGuildLeaderEditBox", _isJoining)
end

function GuildWindowTabAlliance.OnLButtonUpJoinAllianceButton()
	GuildWindowTabAlliance.ChangingAllianceMode = GuildWindowTabAlliance.CHANGE_ALLIANCE_MODE_INVITE
	LabelSetText( "GWAllianceInAllianceJoinAllianceWithGuildLeaderHeader", GetGuildString( StringTables.Guild.HEADER_INVITE_GUILD_INTO_ALLIANCE) )
	GuildWindowTabAlliance.ChangingAlliance(true)
end

function GuildWindowTabAlliance.OnKeyEnterJoinAllianceEditBox()
	local editBoxText = TextEditBoxGetText("GWAllianceInAllianceJoinAllianceWithGuildLeaderEditBox")

	if GuildWindowTabAlliance.ChangingAllianceMode == GuildWindowTabAlliance.CHANGE_ALLIANCE_MODE_INVITE 
	then
        SendChatText( L"/allianceinvite "..editBoxText, L"" )
	elseif GuildWindowTabAlliance.ChangingAllianceMode == GuildWindowTabAlliance.CHANGE_ALLIANCE_MODE_KICK then
        SendChatText( L"/alliancekick "..editBoxText, L"" )
	end

	GuildWindowTabAlliance.ChangingAlliance(false)
end

function GuildWindowTabAlliance.OnKeyEscapeJoinAllianceEditBox()
	GuildWindowTabAlliance.ChangingAllianceMode = GuildWindowTabAlliance.CHANGE_ALLIANCE_MODE_INVITE
	GuildWindowTabAlliance.ChangingAlliance(false)
end

function GuildWindowTabAlliance.OnLButtonUpKickVoteButton()
    local windowIndex = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
    local guild = GuildWindowTabAlliance.guilds[windowIndex]
    if( not guild )
    then
        return
    end
    
    -- Don't allow player to start or participate in a kick vote on their own guild
    if( GameData.Guild.m_GuildID == guild.id )
    then
        return
    end
    
    local pollId = WindowGetId( SystemData.ActiveWindow.name )
    local pollData = nil
    
    if ( pollId >= 0 )
    then
        local guildPollData = GetGuildPollData()
        pollData = guildPollData[pollId]
    end
    
    if ( pollData ~= nil )
    then
        -- Active poll, open poll window
        if ( not DoesWindowExist( "EA_AllianceKickPollWindow" ) )
        then
            -- Lazy creation of window
            CreateWindow( "EA_AllianceKickPollWindow", true )
            LabelSetText( "EA_AllianceKickPollWindowTitleBarText", GetGuildString( StringTables.Guild.TEXT_ALLIANCE_KICK_POLL_TITLEBAR ) )
            LabelSetText( "EA_AllianceKickPollWindowInfoText", GetGuildString( StringTables.Guild.TEXT_ALLIANCE_KICK_POLL_INSTRUCTIONS ) )
            ButtonSetText( "EA_AllianceKickPollWindowVoteYesButton", GetGuildString( StringTables.Guild.TEXT_ALLIANCE_KICK_POLL_VOTE_YES ) )
            ButtonSetText( "EA_AllianceKickPollWindowVoteNoButton", GetGuildString( StringTables.Guild.TEXT_ALLIANCE_KICK_POLL_VOTE_NO ) )
            ButtonSetText( "EA_AllianceKickPollWindowCancelPollButton", GetGuildString( StringTables.Guild.TEXT_ALLIANCE_KICK_POLL_CANCEL_POLL ) )
        else
            -- Window was already created, just show it
            WindowSetShowing( "EA_AllianceKickPollWindow", true )
        end
        
        WindowSetId( "EA_AllianceKickPollWindow", pollId )
        LabelSetText( "EA_AllianceKickPollWindowSubjectName", guild.name )
        GuildWindowTabAlliance.UpdateKickPollWindow( pollData )
    else
        -- No active poll. Confirm player wants to start one.
        local submitKickPollFunction = function()
	        SendGuildAllianceCommand(GuildWindowTabAlliance.COMMAND_POLL_CREATE, guild.id, 0, 0)
        end
    
        DialogManager.MakeTwoButtonDialog( GetFormatStringFromTable( "guildstrings", StringTables.Guild.DIALOG_ALLIANCE_START_KICK_VOTE_ARE_YOU_SURE, { guild.name } ),
                                           GetGuildString( StringTables.Guild.BUTTON_CONFIRM_YES ),
                                           submitKickPollFunction,
                                           GetGuildString( StringTables.Guild.BUTTON_CONFIRM_NO ),
                                           nil )
    end
end

function GuildWindowTabAlliance.OnRButtonUpAllianceMemberName()

	local windowIndex	= WindowGetId( SystemData.ActiveWindow.name )
    local windowParent	= WindowGetParent( SystemData.ActiveWindow.name )
    local dataIndex     = ListBoxGetDataIndex( windowParent, windowIndex )
    local customMenuItems = {}
    
    GuildWindowTabAlliance.SelectedAllianceMemberName = GuildWindowTabAlliance.guildsListbox[dataIndex].name
    local allianceMemberRank = GuildWindowTabAlliance.guildsListbox[dataIndex].allianceMemberRank
    
    local hasPermissionToPromote = false
    for rowIndex, data in ipairs( GuildWindowTabAlliance.guildsListbox ) do
		if WStringsCompareIgnoreGrammer( data.name, GameData.Player.name ) == 0 then
            hasPermissionToPromote = data.allianceMemberRank >= 3
		end
    end
	local bCannotDemoteMember = false
	local bCannotPromoteMember = false
    if allianceMemberRank <= 0 then bCannotDemoteMember = true end	-- Cannot demote someone below alliance rank 0
    if allianceMemberRank >= 4 then bCannotDemoteMember = true end	-- Cannot demote an alliance leader
    if allianceMemberRank  > 2 then bCannotPromoteMember = true end	-- Cannot promote someone above alliance rank 3
    
    if hasPermissionToPromote and GuildWindowTabAlliance.guildsListbox[dataIndex].guildID == GameData.Guild.m_GuildID then
        table.insert( customMenuItems, PlayerMenuWindow.NewCustomItem( GetGuildString( StringTables.Guild.CONTEXT_MENU_ROSTER_DEMOTE ), GuildWindowTabAlliance.DemoteAllianceMember, bCannotDemoteMember ) )
        table.insert( customMenuItems, PlayerMenuWindow.NewCustomItem( GetGuildString( StringTables.Guild.CONTEXT_MENU_ROSTER_PROMOTE ), GuildWindowTabAlliance.PromoteAllianceMember, bCannotPromoteMember ) )
    end
    
    PlayerMenuWindow.ShowMenu( GuildWindowTabAlliance.guildsListbox[dataIndex].name, 0, customMenuItems )
end

function GuildWindowTabAlliance.OnMouseOverAllianceMemberName()
    WindowSetShowing( SystemData.ActiveWindow.name.."Background", false )
end

function GuildWindowTabAlliance.OnMouseOverEndAllianceMemberName()
    WindowSetShowing( SystemData.ActiveWindow.name.."Background", true )
end

function GuildWindowTabAlliance.DemoteAllianceMember()
    SendChatText( L"/guildalliancedemote "..GuildWindowTabAlliance.SelectedAllianceMemberName, L"" )
end

function GuildWindowTabAlliance.PromoteAllianceMember()
    SendChatText( L"/guildalliancepromote "..GuildWindowTabAlliance.SelectedAllianceMemberName, L"" )
end

function GuildWindowTabAlliance.OnMouseOverColumnHeaderAllianceMemberRank()

    Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name, nil)
		Tooltips.SetTooltipText (1, 1, GetGuildString(StringTables.Guild.TOOLTIP_ALLIANCE_HEADER_RANK) )
		Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)
    Tooltips.Finalize ()

    local anchor = { Point="topright", RelativeTo="GWAllianceInAllianceGuildSortButton", RelativePoint="topleft", XOffset=0, YOffset=0 }
    Tooltips.AnchorTooltip (anchor)
end

function GuildWindowTabAlliance.UpdateAllianceList()
    -- Filter, Sort, and Update
    SortAllianceList()
end

--------------------------------
-- Sorting Functions
--------------------------------
function GuildWindowTabAlliance.HideAllSortButtonArrows()
    WindowSetShowing( "GWAllianceInAllianceMemberNameSortButtonUpArrow", false)
    WindowSetShowing( "GWAllianceInAllianceMemberNameSortButtonDownArrow", false)
    WindowSetShowing( "GWAllianceInAllianceRankSortButtonUpArrow", false)
    WindowSetShowing( "GWAllianceInAllianceRankSortButtonDownArrow", false)
    WindowSetShowing( "GWAllianceInAllianceGuildSortButtonUpArrow", false)
    WindowSetShowing( "GWAllianceInAllianceGuildSortButtonDownArrow", false)
end

function GuildWindowTabAlliance.OnLButtonUpSortButton()
    if( GuildWindowTabAlliance.guildsListbox == nil or #GuildWindowTabAlliance.guildsListbox <= 0 )
    then
        return
    end

    local sortId = WindowGetId( SystemData.ActiveWindow.name )

    GuildWindowTabAlliance.HideAllSortButtonArrows()
    if( GuildWindowTabAlliance.sortBy == sortId )
    then
        if( GuildWindowTabAlliance.sortDirection == DataUtils.SORT_ORDER_UP )
        then
            GuildWindowTabAlliance.sortDirection = DataUtils.SORT_ORDER_DOWN
            WindowSetShowing( SystemData.ActiveWindow.name.."DownArrow", true )
        else
            GuildWindowTabAlliance.sortDirection = DataUtils.SORT_ORDER_UP
            WindowSetShowing( SystemData.ActiveWindow.name.."UpArrow", true )
        end
    else
        GuildWindowTabAlliance.sortBy = sortId
        GuildWindowTabAlliance.sortDirection = DataUtils.SORT_ORDER_UP
        WindowSetShowing( SystemData.ActiveWindow.name.."UpArrow", true )
    end

    SortAllianceList()
end

---------------------------------------
-- Util Functions
---------------------------------------
function GuildWindowTabAlliance.IsPlayerInAlliance( playerName )

    for _, guildData in ipairs( GuildWindowTabAlliance.guilds )
    do
        for _, memberData in ipairs( guildData.players )
        do
            if( WStringsCompareIgnoreGrammer( playerName, memberData.name ) == 0 )
            then
                return true
            end
        end
    end

    return false
end

function GuildWindowTabAlliance.UpdatePermissions()

end

---------------------------------------
-- Kick Poll Window Functions
---------------------------------------
function GuildWindowTabAlliance.OnCloseKickPollWindow()
    WindowSetShowing( "EA_AllianceKickPollWindow", false )
end

function GuildWindowTabAlliance.OnKickPollVoteYesButton()
    local pollId = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
    SendGuildAllianceCommand(GuildWindowTabAlliance.COMMAND_POLL_VOTE, 0, pollId, 1)
end

function GuildWindowTabAlliance.OnKickPollVoteNoButton()
    local pollId = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
    SendGuildAllianceCommand(GuildWindowTabAlliance.COMMAND_POLL_VOTE, 0, pollId, 0)
end

function GuildWindowTabAlliance.OnKickPollCancelPollButton()
    if ( not ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) )
    then
        local pollId = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
        
        local confirmCancelPollFunction = function()
            SendGuildAllianceCommand(GuildWindowTabAlliance.COMMAND_POLL_CANCEL, 0, pollId, 0)
        end
        
        DialogManager.MakeTwoButtonDialog( GetGuildString( StringTables.Guild.DIALOG_ALLIANCE_CANCEL_KICK_VOTE_ARE_YOU_SURE ),
                                           GetGuildString( StringTables.Guild.BUTTON_CONFIRM_YES ),
                                           confirmCancelPollFunction,
                                           GetGuildString( StringTables.Guild.BUTTON_CONFIRM_NO ),
                                           nil )
    end
end
