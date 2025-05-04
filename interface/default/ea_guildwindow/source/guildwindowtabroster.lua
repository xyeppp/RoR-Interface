----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

GuildWindowTabRoster = {}

GuildWindowTabRoster.MAX_MEMBER_NOTE_LENGTH = 78

GuildWindowTabRoster.memberListData  = {}
GuildWindowTabRoster.memberListOrder = {}

GuildWindowTabRoster.SORT_ORDER_UP			= 1
GuildWindowTabRoster.SORT_ORDER_DOWN	    = 2

GuildWindowTabRoster.SORT_BUTTON_NAME		= 1
GuildWindowTabRoster.SORT_BUTTON_RANK		= 2
GuildWindowTabRoster.SORT_BUTTON_CAREER     = 3
GuildWindowTabRoster.SORT_BUTTON_TITLE		= 4
GuildWindowTabRoster.SORT_BUTTON_SPECIAL    = 5
GuildWindowTabRoster.SORT_BUTTON_STATUS		= 6
GuildWindowTabRoster.SORT_MAX_NUMBER		= 6

GuildWindowTabRoster.SortButtons = {} 
GuildWindowTabRoster.SortButtons[ GuildWindowTabRoster.SORT_BUTTON_NAME  ]	= { buttonName = "GWRosterSortBarNameButton",	label=StringTables.Guild.LABEL_GUILD_ROSTER_SORT_BUTTON_NAME,	tooltip=StringTables.Guild.TOOLTIP_GUILD_ROSTER_SORT_BUTTON_NAME }
GuildWindowTabRoster.SortButtons[ GuildWindowTabRoster.SORT_BUTTON_RANK ]	= { buttonName = "GWRosterSortBarRankButton",	label=false,	                                                tooltip=StringTables.Guild.TOOLTIP_GUILD_ROSTER_SORT_BUTTON_RANK }
GuildWindowTabRoster.SortButtons[ GuildWindowTabRoster.SORT_BUTTON_CAREER ]	= { buttonName = "GWRosterSortBarCareerButton",	label=false,	                                                tooltip=StringTables.Guild.TOOLTIP_GUILD_ROSTER_SORT_BUTTON_CAREER }
GuildWindowTabRoster.SortButtons[ GuildWindowTabRoster.SORT_BUTTON_TITLE ]	= { buttonName = "GWRosterSortBarTitleButton",	label=StringTables.Guild.LABEL_GUILD_ROSTER_SORT_BUTTON_TITLE,	tooltip=StringTables.Guild.TOOLTIP_GUILD_ROSTER_SORT_BUTTON_TITLE }
GuildWindowTabRoster.SortButtons[ GuildWindowTabRoster.SORT_BUTTON_STATUS ]	= { buttonName = "GWRosterSortBarStatusButton",	label=StringTables.Guild.LABEL_GUILD_ROSTER_SORT_BUTTON_STATUS,	tooltip=StringTables.Guild.TOOLTIP_GUILD_ROSTER_SORT_BUTTON_STATUS }
GuildWindowTabRoster.SortButtons[ GuildWindowTabRoster.SORT_BUTTON_SPECIAL ]= { buttonName = "GWRosterSortBarSpecialButton",label=StringTables.Guild.LABEL_GUILD_ROSTER_SORT_BUTTON_SPECIAL,tooltip=false }
GuildWindowTabRoster.FILTER_MEMBERS_ALL			= 1
GuildWindowTabRoster.FILTER_MEMBERS_ONLINE		= 2		-- Filter out offline members by only showing online members.

GuildWindowTabRoster.sort = {   type=GuildWindowTabRoster.SORT_BUTTON_TITLE,
                                order=GuildWindowTabRoster.SORT_ORDER_DOWN,
                                filter=GuildWindowTabRoster.FILTER_MEMBERS_ALL }

GuildWindowTabRoster.SelectedPlayerDataIndex	= 0
GuildWindowTabRoster.SelectedGuildMemberName	= ""

GuildWindowTabRoster.numAssignedBearers = 0

-- should probably remove solo but not right now...
GuildWindowTabRoster.PARTY_TYPE_SOLO		        = 1
GuildWindowTabRoster.PARTY_TYPE_PARTY_CLOSED        = 2
GuildWindowTabRoster.PARTY_TYPE_PARTY_OPEN          = 3
GuildWindowTabRoster.PARTY_TYPE_PARTY_GUILD         = 4
GuildWindowTabRoster.PARTY_TYPE_PARTY_ALLIANCE      = 5
GuildWindowTabRoster.PARTY_TYPE_WARBAND_CLOSED      = 6
GuildWindowTabRoster.PARTY_TYPE_WARBAND_OPEN        = 7
GuildWindowTabRoster.PARTY_TYPE_WARBAND_GUILD       = 8
GuildWindowTabRoster.PARTY_TYPE_WARBAND_ALLIANCE    = 9
GuildWindowTabRoster.NUM_PARTY_TYPES                = 9

GuildWindowTabRoster.PartyIcons                     = {00000, 00071, 00075, 00073, 00069, 00072, 00076, 00074, 00070}
GuildWindowTabRoster.partyTooltips                  = {L"",
                                                        GetGuildString(StringTables.Guild.TOOLTIP_PARTY_TYPE_PARTY_CLOSED),
                                                        GetGuildString(StringTables.Guild.TOOLTIP_PARTY_TYPE_PARTY_OPEN),
                                                        GetGuildString(StringTables.Guild.TOOLTIP_PARTY_TYPE_PARTY_GUILD),
                                                        GetGuildString(StringTables.Guild.TOOLTIP_PARTY_TYPE_PARTY_ALLIANCE),
                                                        GetGuildString(StringTables.Guild.TOOLTIP_PARTY_TYPE_WARBAND_CLOSED),
                                                        GetGuildString(StringTables.Guild.TOOLTIP_PARTY_TYPE_WARBAND_OPEN),
                                                        GetGuildString(StringTables.Guild.TOOLTIP_PARTY_TYPE_WARBAND_GUILD),
                                                        GetGuildString(StringTables.Guild.TOOLTIP_PARTY_TYPE_WARBAND_ALLIANCE)}

local STANDARD_ICON_NUM         = 20204
local RECRUITER_ICONS           = {00079, 00078}
local REALM_CAPTAIN_ICON_NUM    = 00078
local MAX_NUM_NOTES             = 500
local MAX_NUM_RECRUITERS        = 5
local numOfficerNotes           = 0
local numGuildMemberNotes       = 0
local numRecruiters             = 0

function FormatLastLoginTime(_timeInSeconds, _hour, _month, _day, _year)
	local tempRoundedNumber = 0

	if _timeInSeconds < 86400 then -- 60*60*24 = 86400	-- Last Login/Logout was less than 24 hours ago
		tempRoundedNumber = math.floor(_timeInSeconds / 86400)
		return GetFormatStringFromTable( "GuildStrings", StringTables.Guild.DATE_FORMAT_ROSTER_LOGIN_X_HOURS_AGO, {tempRoundedNumber} ) 
	end	

	if _timeInSeconds < 259200 then -- 86400*3= 259200	-- Last Login/logout was less than 2 days ago
		tempRoundedNumber = math.floor(_timeInSeconds / 259200)
		return GetFormatStringFromTable( "GuildStrings", StringTables.Guild.DATE_FORMAT_ROSTER_LOGIN_X_DAYS_AGO, {tempRoundedNumber} ) 
	end	

	-- insert a 0 at the beginning for better formatting  (1/2/2008 becomes 01/02/2008
	if _day   < 10 then _day   = L"0".._day   end	
	if _month < 10 then _month = L"0".._month end

	return GetFormatStringFromTable( "GuildStrings", StringTables.Guild.DATE_FORMAT_ROSTER_LOGIN_DD_MM_YY, {_day, _month, _year} )
end

local function UpdateNotesTotal( currentNumNotes, note )
    if( note and note ~= L"" and note ~= "" )
    then
        return currentNumNotes + 1
    end
    
    return currentNumNotes
end

-- When the server sends member data, some of that data needs to be processed in LUA. 
local function UpdateLUASpecificMemberData(index, memberData)
	-- Career Icon
	GuildWindowTabRoster.memberListData[index].careerIcon = Icons.GetCareerIconIDFromCareerNamesID(memberData.careerID)

	-- Location Status
    if (not GuildWindowTabRoster.IsMemberOnline(memberData)) then -- For offline members, show their last login date instead.
		local dateStr = FormatLastLoginTime(memberData.lastLogin, memberData.lastLoginNumberHour24, memberData.lastLoginNumberMonth, memberData.lastLoginNumberDay, memberData.lastLoginNumberYear)
		GuildWindowTabRoster.memberListData[index].statusString = dateStr
    else	-- otherwise, show the zone name
		GuildWindowTabRoster.memberListData[index].statusString = GetZoneName (memberData.zoneID)
    end
end

local function InitMemberListData()
    GuildWindowTabRoster.memberListData = {}
    numOfficerNotes             = 0
    numGuildMemberNotes         = 0
    numRecruiters               = 0
    
	GuildWindowTabRoster.memberListData = GetGuildMemberData()
	
	--[[
	-- TEST DATA
	if( rosterData[1] ) then
    	for i = 2, 500 do
            local newMember = DataUtils.CopyTable( rosterData[1] )
            newMember.name = L"Member"..towstring( i )
            newMember.zoneID = 0
            table.insert( GuildWindowTabRoster.memberListData, newMember )
    	end
    end
    ]]

	-- Some entries require direct handling via LUA:
	for index, memberData in pairs( GuildWindowTabRoster.memberListData ) do
		UpdateLUASpecificMemberData(index, memberData)

		numGuildMemberNotes = UpdateNotesTotal( numGuildMemberNotes, memberData.note )
		numOfficerNotes = UpdateNotesTotal( numOfficerNotes, memberData.onote )
        if memberData.recruiterStatus > 0
        then
            numRecruiters = numRecruiters + 1
        end
	end
end

-- This function filters the Roster List by not inserting a member's index into the memberListOrder. 
local function FilterMemberList()	
    GuildWindowTabRoster.memberListOrder = {}
	local skipMember = false

    for dataIndex, data in ipairs( GuildWindowTabRoster.memberListData ) do
		skipMember = false
		
		-- Offline Filter
		if GuildWindowTabRoster.sort.filter == GuildWindowTabRoster.FILTER_MEMBERS_ONLINE then
			if not GuildWindowTabRoster.IsMemberOnline(GuildWindowTabRoster.memberListData[dataIndex]) then
				skipMember = true
			end
		end

        if skipMember == false then
			table.insert(GuildWindowTabRoster.memberListOrder, dataIndex)
		end
    end
end

-- This function compares 2 guild members for purposes of sorting them in the list. The Sort Button Pressed determines how to sort it.
local function CompareMembers( index1, index2 )
    if( index2 == nil ) then
        return false
    end

    local player1 = GuildWindowTabRoster.memberListData[index1]
    local player2 = GuildWindowTabRoster.memberListData[index2]
    
    if (player1 == nil or player1.name == nil or player1.name == L"") then
        return false
    end
    
    if (player2 == nil or player2.name == nil or player2.name == L"") then
        return true
    end

    local type = GuildWindowTabRoster.sort.type
    local order = GuildWindowTabRoster.sort.order

    local compareResult
    
    -- Sorting by Name
    if( type == GuildWindowTabRoster.SORT_BUTTON_NAME ) then
        if( order == GuildWindowTabRoster.SORT_ORDER_UP ) then
            return ( WStringsCompare(player1.name, player2.name) < 0 )
        else
            return ( WStringsCompare(player1.name, player2.name) > 0 )
        end
    end

    -- Sorting by Career
    if( type == GuildWindowTabRoster.SORT_BUTTON_CAREER ) then
        if( order == GuildWindowTabRoster.SORT_ORDER_UP ) then
            return ( WStringsCompare(player1.careerString, player2.careerString) < 0 )
        else
            return ( WStringsCompare(player1.careerString, player2.careerString) > 0 )
        end
    end

     -- Sorting By Rank
    if( type == GuildWindowTabRoster.SORT_BUTTON_RANK )then

        if (player1.rank == player2.rank) then	-- if they match, then sort alphabetically)
            return ( WStringsCompare(player1.name, player2.name) < 0 )
        end

        if( order == GuildWindowTabRoster.SORT_ORDER_UP ) then
            return ( player1.rank < player2.rank )
        else
            return ( player1.rank > player2.rank )
        end
    end

     -- Sorting By Title (Based on Title#, not alphabetical)
    if( type == GuildWindowTabRoster.SORT_BUTTON_TITLE ) then

		-- Subsort alphabetically by name
		if player1.statusNumber == player2.statusNumber then
			return ( WStringsCompare(player1.name, player2.name) < 0 )
        end

		if( order == GuildWindowTabRoster.SORT_ORDER_UP ) then
			return ( player1.statusNumber < player2.statusNumber )
		else
            return ( player1.statusNumber > player2.statusNumber )
	    end		
    end

     -- Sort By Status
    if( type == GuildWindowTabRoster.SORT_BUTTON_STATUS ) then

        if (player1.zoneID > 0 and player2.zoneID > 0) then			-- Both members are Online
			-- Subsort by location name
			compareResult = WStringsCompare(player1.statusString, player2.statusString)
			if compareResult == 0 then	-- Both members are Online AND in the same location. Sub-sub sort by name.
				if( order == GuildWindowTabRoster.SORT_ORDER_UP ) then
					return ( WStringsCompare(player1.name, player2.name) < 0 )
				else
					return ( WStringsCompare(player1.name, player2.name) > 0 )
				end
			else
				WStringsCompare(player1.statusString, player2.statusString)
				if( order == GuildWindowTabRoster.SORT_ORDER_UP ) then
					return ( compareResult < 0 )
				else
					return ( compareResult > 0 )
				end
			end
		end		

        if (player1.zoneID <= 0 and player2.zoneID <= 0) then		-- Both members are OFFLINE
			-- Subsort by last login date
			if( order == GuildWindowTabRoster.SORT_ORDER_UP ) then
				return ( player1.lastLogin < player2.lastLogin )
			else
				return ( player1.lastLogin > player2.lastLogin )
			end
        end

        if( order == GuildWindowTabRoster.SORT_ORDER_UP ) then		-- One member is online, the other is OFFLINE
            return ( player1.zoneID < player2.zoneID )
        else
            return ( player1.zoneID > player2.zoneID )
        end
    end
end

-- This function sorts the list
local function SortMemberList()	
    table.sort( GuildWindowTabRoster.memberListOrder, CompareMembers )
end

local function CanAddNote()
    return numOfficerNotes + numGuildMemberNotes < MAX_NUM_NOTES
end

-- This function determines if the member is currently in the populator index range of the Roster Listbox
local function IsMemberInPopulatorList(memberID)

	for row, data in ipairs(GWRosterList.PopulatorIndices) do
		if memberID == GuildWindowTabRoster.memberListData[data].memberID then
			return true
		end
	end

	return false
end

-----------------------------------------------------------------------
-- Main Window Functions
-----------------------------------------------------------------------
function GuildWindowTabRoster.Initialize()
	InitMemberListData()
	GuildWindowTabRoster.UpdateMembersOnlineText()

	LabelSetText("GWRosterHideOfflineHeader", GetGuildString(StringTables.Guild.LABEL_GUILD_TAB_ROSTER_HIDE_OFFLINE) )
	GuildWindowTabRoster.InitializeSortButtons()
	GuildWindowTabRoster.InitializeCommandButtons()
	GuildWindowTabRoster.SetListRowTints()
    
	GuildWindowTabRoster.UpdateSortButtons()

	ButtonSetCheckButtonFlag("GWRosterHideOfflineCheckBox", true)
    
    WindowRegisterEventHandler("GWRoster", SystemData.Events.GUILD_NEWBIE_GUILD_STATUS_UPDATED, "GuildWindowTabRoster.OnNewbieGuildStatusUpdated")
    GuildWindowTabRoster.OnNewbieGuildStatusUpdated(GetNewbieGuildFlag())
end

function GuildWindowTabRoster.OnRosterInit()
	InitMemberListData()
	GuildWindowTabRoster.UpdateMemberList()
end

function GuildWindowTabRoster.Shutdown()

end

--------------------------------------
--	Sort Functions	(Note several localized helper functions for sorting are defined at the top)
--------------------------------------

-- Callback for hovering over a sort button
function GuildWindowTabRoster.OnMouseOverSortButton()
    local windowName	= SystemData.ActiveWindow.name
    local windowIndex	= WindowGetId (windowName)
    
    if( not GuildWindowTabRoster.SortButtons[windowIndex].tooltip )
    then
        return
    end

    Tooltips.CreateTextOnlyTooltip (windowName, nil)
    Tooltips.SetTooltipText (1, 1, GetStringFromTable("GuildStrings", GuildWindowTabRoster.SortButtons[windowIndex].tooltip) )
    Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)	
    Tooltips.Finalize ()
    
    local anchor = { Point="top", RelativeTo=windowName, RelativePoint="center", XOffset=0, YOffset=-32 }
    Tooltips.AnchorTooltip (anchor)
    Tooltips.SetTooltipAlpha (1)
end

-- Callback for clicking on a sort button
function GuildWindowTabRoster.OnSortMemberList()
    local type = WindowGetId( SystemData.ActiveWindow.name )
    -- If we are already using this sort type, toggle the order.
    if( type == GuildWindowTabRoster.sort.type ) then
        if( GuildWindowTabRoster.sort.order == GuildWindowTabRoster.SORT_ORDER_UP ) then
            GuildWindowTabRoster.sort.order = GuildWindowTabRoster.SORT_ORDER_DOWN
        else
            GuildWindowTabRoster.sort.order = GuildWindowTabRoster.SORT_ORDER_UP
        end
        
    -- Otherwise change the type and use the up order.
    else
        GuildWindowTabRoster.sort.type = type
        GuildWindowTabRoster.sort.order = GuildWindowTabRoster.SORT_ORDER_UP
    end

    GuildWindowTabRoster.UpdateMemberList()
    GuildWindowTabRoster.UpdateSortButtons()
end

-- Displays the clicked sort button as pressed down and positions an arrow above it
function GuildWindowTabRoster.UpdateSortButtons()
    
    local type = GuildWindowTabRoster.sort.type
    local order = GuildWindowTabRoster.sort.order

    for index = 1, GuildWindowTabRoster.SORT_MAX_NUMBER do
        local window = GuildWindowTabRoster.SortButtons[index].buttonName
        ButtonSetPressedFlag( window, index == GuildWindowTabRoster.sort.type )
    end
    
    -- Only move the arrow around for sorting on everything but the name
    if (type > 0) then
          WindowSetShowing( "GWRosterSortBarUpArrow", order == GuildWindowTabRoster.SORT_ORDER_UP )
          WindowSetShowing( "GWRosterSortBarDownArrow", order == GuildWindowTabRoster.SORT_ORDER_DOWN )

        if( order == GuildWindowTabRoster.SORT_ORDER_UP ) then		
            WindowClearAnchors( "GWRosterSortBarUpArrow" )
            WindowAddAnchor("GWRosterSortBarUpArrow", "right", GuildWindowTabRoster.SortButtons[type].buttonName, "right", -10, 0 )
        else
            WindowClearAnchors( "GWRosterSortBarDownArrow" )
            WindowAddAnchor("GWRosterSortBarDownArrow", "right", GuildWindowTabRoster.SortButtons[type].buttonName, "right", -10, 0 )
        end
    else
        WindowSetShowing( "GWRosterSortBarUpArrow", false )
        WindowSetShowing( "GWRosterSortBarDownArrow", false )
    end

end

--------------------------------------
--	List Functions
--------------------------------------

-- Sets the button text for each sort button
function GuildWindowTabRoster.InitializeSortButtons()
    for colNumber, data in ipairs(GuildWindowTabRoster.SortButtons) do
        if( data.label )
        then
		    ButtonSetText(data.buttonName, GetGuildString(data.label))
        end
        if( not data.tooltip )
        then
            ButtonSetDisabledFlag( data.buttonName, true )
        end
    end
end

-- Sets the background tinting for each row in the member list
function GuildWindowTabRoster.SetListRowTints()

	local row_mod = 0
	local targetRowWindow = ""

    for row = 1, GWRosterList.numVisibleRows do

        row_mod = math.mod(row, 2)
        local color = DataUtils.GetAlternatingRowColorGreyOnGrey( row_mod )
        targetRowWindow = "GWRosterListRow"..row
        
        WindowSetTintColor(targetRowWindow.."RowBackground", color.r, color.g, color.b )
        WindowSetAlpha(targetRowWindow.."RowBackground", color.a)
    end

end

local function MouseOverMember( rowWindow )
    WindowSetShowing( rowWindow.."RowBackground", false )
    
	local windowIndex	= WindowGetId( rowWindow )
    local windowParent	= WindowGetParent( rowWindow )
    local dataIndex     = ListBoxGetDataIndex( windowParent, windowIndex )
	local memberSelected = GuildWindowTabRoster.memberListData[dataIndex]
	
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, memberSelected.name )
    Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
    
    local none = GetString( StringTables.Default.LABEL_NONE )
    local noteText
    if( memberSelected.note and memberSelected.note ~= L"" )
    then
        noteText = GetFormatStringFromTable( "GuildStrings", StringTables.Guild.TOOLTIP_MEMBER_NOTE, { memberSelected.note } )
    else
        noteText = GetFormatStringFromTable( "GuildStrings", StringTables.Guild.TOOLTIP_MEMBER_NOTE, { none } )
    end
    Tooltips.SetTooltipText( 2, 1, noteText )
    
    local playerTitleNumber = GuildWindowTabAdmin.GetLocalMemberTitleNumber()
    if GuildWindowTabAdmin.GetGuildCommandPermission( SystemData.GuildPermissons.READ_OFFICER_NOTE, playerTitleNumber )
    then
        if( memberSelected.onote and memberSelected.onote ~= L"" )
        then
            noteText = GetFormatStringFromTable( "GuildStrings", StringTables.Guild.TOOLTIP_OFFICER_NOTE, { memberSelected.onote } )
        else
            noteText = GetFormatStringFromTable( "GuildStrings", StringTables.Guild.TOOLTIP_OFFICER_NOTE, { none } )
        end
        Tooltips.SetTooltipText( 3, 1, noteText )
    end
    
    Tooltips.Finalize()
    local anchor = { Point = "topright", RelativeTo = rowWindow, RelativePoint = "topleft", XOffset = 0, YOffset = 0 }
    Tooltips.AnchorTooltip( anchor )
end

function GuildWindowTabRoster.OnMouseOverMemberRow()
    MouseOverMember( WindowGetParent( SystemData.ActiveWindow.name ) )
end
function GuildWindowTabRoster.OnMouseOverEndMemberRow()
    WindowSetShowing( WindowGetParent( SystemData.ActiveWindow.name ).."RowBackground", true )
end

function GuildWindowTabRoster.OnMouseOverMemberRowChild()
    local memberRow = WindowGetParent(SystemData.ActiveWindow.name)
    MouseOverMember( WindowGetParent( memberRow ) )
end
function GuildWindowTabRoster.OnMouseOverEndMemberRowChild()
    local memberRow = WindowGetParent(SystemData.ActiveWindow.name)
    WindowSetShowing( WindowGetParent(memberRow).."RowBackground", true )
end

-- Updates everything in all the guild member rows, such as button states, text colors, etc.
function GuildWindowTabRoster.UpdateMemberRows()
	if GWRosterList.PopulatorIndices == nil then
		return -- (sigh) During login, this doesn't exist, so check for it to avoid a debug window error.
	end

	local memberData = nil
	local rowName = nil
	
	for row, data in ipairs(GWRosterList.PopulatorIndices) do
		memberData = GuildWindowTabRoster.memberListData[data]
		rowName = "GWRosterListRow"..row
	
		ButtonSetPressedFlag( rowName, false )

		DefaultColor.LabelSetTextColor(rowName.."MemberName", DefaultColor.GUILD_ROSTER_NAME)
		DefaultColor.LabelSetTextColor(rowName.."MemberRankNumber", DefaultColor.GUILD_ROSTER_RANK)
		DefaultColor.LabelSetTextColor(rowName.."MemberTitleString", DefaultColor.GUILD_ROSTER_TITLE)
		if not GuildWindowTabRoster.IsMemberOnline(memberData) then	-- If the member is offline, make the text grey
			DefaultColor.LabelSetTextColor(rowName.."MemberStatusString", DefaultColor.GUILD_MEDIUM_GRAY)
		else
			DefaultColor.LabelSetTextColor(rowName.."MemberStatusString", DefaultColor.GUILD_ROSTER_STATUS_ONLINE)
		end
	end

end

function GuildWindowTabRoster.GetMember()
    for index, data in ipairs( GuildWindowTabRoster.memberListData ) do
        if ( WStringsCompare( GameData.Player.name, data.name ) == 0 ) then
            return data
        end
    end

    return nil
end

function GuildWindowTabRoster.GetMemberID()
    local data = GuildWindowTabRoster.GetMember()
    if ( data == nil )
    then
        return 0
    end

    return data.memberID
end

function GuildWindowTabRoster.OnRButtonUpMemberRow()

	-- Figure out what Guild Member we've selected
	local windowIndex	= WindowGetId (SystemData.ActiveWindow.name)
    local windowParent	= WindowGetParent (SystemData.ActiveWindow.name)
    local dataIndex     = ListBoxGetDataIndex (windowParent, windowIndex)
	local memberSelected = GuildWindowTabRoster.memberListData[dataIndex]

	GuildWindowTabRoster.SelectedGuildMemberName	= memberSelected.name
	GuildWindowTabRoster.SelectedPlayerDataIndex	= dataIndex

	local bSelectedSelf = WStringsCompare(GameData.Player.name, memberSelected.name) == 0	-- Did we select ourself?
	local playerTitleNumber = GuildWindowTabAdmin.GetLocalMemberTitleNumber()
	local targetedPlayerTitleNumber = GuildWindowTabAdmin.GetMemberTitleNumberByMemberName(GuildWindowTabRoster.SelectedGuildMemberName)

	-- Determine how many, if any, Standard Bearer slots are open.
	local guildAdvancementData = GetGuildAdvancementData()

	local bearersMax = 0
	local bearersAssigned = GuildWindowTabRoster.numAssignedBearers

    if ( guildAdvancementData ~= nil )
    then
        bearersMax = guildAdvancementData.numberStandardBearersUnlocked
    end

	-- Create Context Menu
	local bCannotKickMember			= bSelectedSelf or (playerTitleNumber <= targetedPlayerTitleNumber) or (GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.KICK, playerTitleNumber) == false)
	local bCannotDemoteMember		= bSelectedSelf or (playerTitleNumber <= targetedPlayerTitleNumber) or (GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.DEMOTE, playerTitleNumber) == false) or (targetedPlayerTitleNumber == SystemData.GuildRanks.INITIATE)
	local bCannotPromoteMember		= bSelectedSelf or (playerTitleNumber <= targetedPlayerTitleNumber) or (GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.PROMOTE, playerTitleNumber) == false) or (targetedPlayerTitleNumber == SystemData.GuildRanks.OFFICER)
   	local bCannotAssignLeader		= bSelectedSelf or playerTitleNumber ~= SystemData.GuildRanks.LEADER

	local bCannotAssignBearer		= (GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.ASSIGN_BANNERS, playerTitleNumber) == false) or ( memberSelected.bearerStatus ~= SystemData.StandardBearerStatus.UNKNOWN )
	local bCannotUnassignBearer		= (GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.UNASSIGN_BANNERS, playerTitleNumber) == false) or ( memberSelected.bearerStatus == SystemData.StandardBearerStatus.UNKNOWN )
	local bCannotEditMemberNote		= (bSelectedSelf and (GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.EDIT_YOUR_PUBLIC_NOTES, targetedPlayerTitleNumber)== false) )
									or (bSelectedSelf==false and (GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.EDIT_ANYONES_PUBLIC_NOTES, playerTitleNumber) == false) )
	local bCannotEditOfficerNote	= GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.EDIT_ANYONES_OFFICER_NOTE, playerTitleNumber) == false
	local bIsInFriendsList			= SocialWindowTabFriends.IsPlayerFriend(GuildWindowTabRoster.SelectedGuildMemberName)
	local bCannotAddToFriendsList	= bSelectedSelf or bIsInFriendsList
	local bCannotAddToParty			= bSelectedSelf or (GroupWindow.groupData[1].name ~= nil and GroupWindow.groupData[1].name ~= L"")
	local bCannotSendTell			= bSelectedSelf or not GuildWindowTabRoster.IsMemberOnline(memberSelected)

    -- yeah I'm going to go with a CAN do attitude
    partyType = GuildWindowTabRoster.GetMemberPartyType( memberSelected )
	local bCanJoinParty             = (not bSelectedSelf) and ((partyType == GuildWindowTabRoster.PARTY_TYPE_PARTY_OPEN) or (partyType == GuildWindowTabRoster.PARTY_TYPE_PARTY_GUILD) or (partyType == GuildWindowTabRoster.PARTY_TYPE_PARTY_ALLIANCE))
	local bCanJoinWarband           = (not bSelectedSelf) and ((partyType == GuildWindowTabRoster.PARTY_TYPE_WARBAND_OPEN) or (partyType == GuildWindowTabRoster.PARTY_TYPE_WARBAND_GUILD) or (partyType == GuildWindowTabRoster.PARTY_TYPE_WARBAND_ALLIANCE))
	local bCanAssignRecruiter       = GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.SET_RECRUITERS, playerTitleNumber) and memberSelected.recruiterStatus == 0
	local bCanUnassignRecruiter     = GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.SET_RECRUITERS, playerTitleNumber) and memberSelected.recruiterStatus > 0
    local bCanAssignRealmCaptain    = GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.ASSIGN_REALM_CAPTAIN, playerTitleNumber)

    local customMenuItems = {}
    
	if bCannotPromoteMember == false then
        table.insert( customMenuItems, PlayerMenuWindow.NewCustomItem( GetGuildString(StringTables.Guild.CONTEXT_MENU_ROSTER_PROMOTE), GuildWindowTabRoster.CommandPromoteMember, bCannotPromoteMember ) )
	end
	if bCannotDemoteMember == false then
        table.insert( customMenuItems, PlayerMenuWindow.NewCustomItem( GetGuildString(StringTables.Guild.CONTEXT_MENU_ROSTER_DEMOTE), GuildWindowTabRoster.CommandDemoteMember, bCannotDemoteMember ) )
	end
	if bCannotAssignLeader == false then
        table.insert( customMenuItems, PlayerMenuWindow.NewCustomItem( GetGuildString(StringTables.Guild.CONTEXT_MENU_ROSTER_ASSIGN_LEADER), GuildWindowTabRoster.CommandAssignLeader, bCannotAssignLeader ) )
	end
	if bCannotAssignBearer == false then
        table.insert( customMenuItems, PlayerMenuWindow.NewCustomItem( GetGuildString(StringTables.Guild.CONTEXT_MENU_ROSTER_ASSIGN_BEARER), GuildWindowTabRoster.CommandAssignBearer, bearersAssigned >= bearersMax ) )
	end
	if bCannotUnassignBearer == false then
        table.insert( customMenuItems, PlayerMenuWindow.NewCustomItem( GetGuildString(StringTables.Guild.CONTEXT_MENU_ROSTER_UNASSIGN_BEARER), GuildWindowTabRoster.CommandUnassignBearer, memberSelected.bearerStatus == SystemData.StandardBearerStatus.UNKNOWN ) )
	end
	if bCannotEditMemberNote == false or bSelectedSelf then 
        table.insert( customMenuItems, PlayerMenuWindow.NewCustomItem( GetGuildString(StringTables.Guild.CONTEXT_MENU_ROSTER_EDIT_NOTE), GuildWindowTabRoster.EditMemberNote, bCannotEditMemberNote ) )
	end
	if bCannotEditOfficerNote == false then
        table.insert( customMenuItems, PlayerMenuWindow.NewCustomItem( GetGuildString(StringTables.Guild.CONTEXT_MENU_ROSTER_EDIT_OFFICER_NOTE), GuildWindowTabRoster.EditOfficerNote, false ) )
	end

	if bCanJoinParty -- is this member in an open party?  If so allow the player to join them
	then
        table.insert( customMenuItems, PlayerMenuWindow.NewCustomItem( GetGuildString(StringTables.Guild.CONTEXT_MENU_ROSTER_JOIN_PARTY), GuildWindowTabRoster.CommandJoinParty, false ) )
	end

	if bCanJoinWarband -- is this member in an open warband?  If so allow the player to join them
	then
        table.insert( customMenuItems, PlayerMenuWindow.NewCustomItem( GetGuildString(StringTables.Guild.CONTEXT_MENU_ROSTER_JOIN_WARBAND), GuildWindowTabRoster.CommandJoinWarband, false ) )
	end

	if bCanAssignRecruiter -- can this player assign recruiters?  If so allow the player to assign it
	then
        table.insert( customMenuItems, PlayerMenuWindow.NewCustomItem( GetGuildString(StringTables.Guild.CONTEXT_MENU_ROSTER_ASSIGN_RECRUITER), GuildWindowTabRoster.CommandAssignRecruiter, numRecruiters >= MAX_NUM_RECRUITERS ) )
	end

	if bCanUnassignRecruiter -- can this player unassign recruiters and is the person selected a recruiter?  If so allow the player to unassign it
	then
        table.insert( customMenuItems, PlayerMenuWindow.NewCustomItem( GetGuildString(StringTables.Guild.CONTEXT_MENU_ROSTER_UNASSIGN_RECRUITER), GuildWindowTabRoster.CommandUnassignRecruiter, false ) )
	end
    
    if bCanAssignRealmCaptain
    then
        if memberSelected.isRealmCaptain
        then
            table.insert( customMenuItems, PlayerMenuWindow.NewCustomItem( GetGuildString(StringTables.Guild.CONTEXT_MENU_ROSTER_UNASSIGN_REALM_CAPTAIN), GuildWindowTabRoster.CommandUnassignRealmCaptain, false ) )
        else
            table.insert( customMenuItems, PlayerMenuWindow.NewCustomItem( GetGuildString(StringTables.Guild.CONTEXT_MENU_ROSTER_ASSIGN_REALM_CAPTAIN), GuildWindowTabRoster.CommandAssignRealmCaptain, false ) )
        end
    end

    PlayerMenuWindow.ShowMenu( memberSelected.name, 0, customMenuItems )
end

-- Called when the user clicks on the "Hide Offline" Checkbox to filter offline members on/off.
function GuildWindowTabRoster.OnLButtonUpHideOfflineCheckBox()

	if ButtonGetPressedFlag("GWRosterHideOfflineCheckBox") == true then 
		GuildWindowTabRoster.sort.filter=GuildWindowTabRoster.FILTER_MEMBERS_ONLINE
	else
		GuildWindowTabRoster.sort.filter=GuildWindowTabRoster.FILTER_MEMBERS_ALL
	end

	GuildWindowTabRoster.UpdateMemberList()
end

----------------------------------------
-- Population Functions
----------------------------------------

-- Populates the career icon
function GuildWindowTabRoster.PopulateIcon(rowFrame, memberData)
	if memberData.careerIcon ~= nil and memberData.careerIcon ~=0 then
		local texture, x, y = GetIconData(memberData.careerIcon)
		DynamicImageSetTexture(rowFrame.."MemberCareerIcon", texture, x, y)
		WindowSetShowing(rowFrame.."MemberCareerIcon", true)
	else
		WindowSetShowing(rowFrame.."MemberCareerIcon", false)
	end
end

-- sets the standard icon
function GuildWindowTabRoster.SetStandardIcon(rowFrame, memberData)
	if( memberData.bearerStatus ~= SystemData.StandardBearerStatus.UNKNOWN )
	then
		local texture, x, y = GetIconData(STANDARD_ICON_NUM)
		DynamicImageSetTexture(rowFrame.."MemberStandardIcon", texture, x, y)
		WindowSetShowing(rowFrame.."MemberStandardIcon", true)
	else
		WindowSetShowing(rowFrame.."MemberStandardIcon", false)
	end
end

-- sets the recruiter icon
function GuildWindowTabRoster.SetRecruiterIcon(rowFrame, memberData)
	if( memberData.recruiterStatus > 0 )
	then
		local texture, x, y = GetIconData(RECRUITER_ICONS[memberData.recruiterStatus])
		DynamicImageSetTexture(rowFrame.."MemberRecruiterIcon", texture, x, y)
		WindowSetShowing(rowFrame.."MemberRecruiterIcon", true)
	else
		WindowSetShowing(rowFrame.."MemberRecruiterIcon", false)
	end
end

-- sets the Realm Captain icon
function GuildWindowTabRoster.SetRealmCaptainIcon(rowFrame, memberData)
	if( memberData.isRealmCaptain )
	then
		local texture, x, y = GetIconData(REALM_CAPTAIN_ICON_NUM)
		DynamicImageSetTexture(rowFrame.."MemberRealmCaptainIcon", texture, x, y)
		WindowSetShowing(rowFrame.."MemberRealmCaptainIcon", true)
	else
		WindowSetShowing(rowFrame.."MemberRealmCaptainIcon", false)
	end
end

-- Populates the party icon
function GuildWindowTabRoster.PopulatePartyIcon(rowFrame, memberData)
    partyType = GuildWindowTabRoster.GetMemberPartyType( memberData )

	if GuildWindowTabRoster.PartyIcons[partyType] ~= nil and GuildWindowTabRoster.PartyIcons[partyType] ~=0
	then
        local texture, x, y = GetIconData(GuildWindowTabRoster.PartyIcons[partyType])
        DynamicImageSetTexture(rowFrame.."MemberPartyIcon", texture, x, y)
        WindowSetShowing(rowFrame.."MemberPartyIcon", true)
	else
		WindowSetShowing(rowFrame.."MemberPartyIcon", false)
	end
end

-- Callback from the <list> function
function GuildWindowTabRoster.Populate()
    if nil == GWRosterList.PopulatorIndices then
		return
    end

	for row, data in ipairs(GWRosterList.PopulatorIndices) do
		local rowFrame   = "GWRosterListRow"..row
		local memberData = GuildWindowTabRoster.memberListData[data]
		if memberData ~= nil then
			GuildWindowTabRoster.PopulatePartyIcon(rowFrame, memberData)
			GuildWindowTabRoster.PopulateIcon(rowFrame, memberData)
			GuildWindowTabRoster.SetStandardIcon(rowFrame, memberData)
			GuildWindowTabRoster.SetRecruiterIcon(rowFrame, memberData)
            GuildWindowTabRoster.SetRealmCaptainIcon(rowFrame, memberData)
			
    		if not GuildWindowTabRoster.IsMemberOnline(memberData) then	-- If the member is offline, make the text grey
    			DefaultColor.LabelSetTextColor(rowFrame.."MemberStatusString", DefaultColor.GUILD_MEDIUM_GRAY)
    		else
    			DefaultColor.LabelSetTextColor(rowFrame.."MemberStatusString", DefaultColor.GUILD_ROSTER_STATUS_ONLINE)
    		end
		end
	end
end

function GuildWindowTabRoster.UpdateMembersOnlineText()
	local membersOnline = 0
	for index, data in ipairs(GuildWindowTabRoster.memberListData) do
		if data.zoneID >0 then 
			membersOnline = membersOnline +1
		end
	end	

	LabelSetText("GWRosterMembersOnlineText", GetFormatStringFromTable( "guildstrings", StringTables.Guild.TEXT_ROSTER_X_OF_Y_GUILD_MEMBERS_ONLINE, {membersOnline, #GuildWindowTabRoster.memberListData} ) )
end

--------------------------------------
--	Command Functions
--------------------------------------
function GuildWindowTabRoster.InitializeCommandButtons()
	ButtonSetText("GWRosterLeaveButton", GetGuildString(StringTables.Guild.BUTTON_GUILD_COMMAND_LEAVE))
	ButtonSetText("GWRosterInviteToGuildButton", GetGuildString(StringTables.Guild.BUTTON_GUILD_COMMAND_INVITE))
end

function GuildWindowTabRoster.OnLButtonUpLeaveButton()
	-- Create Confirmation Dialog
    local dialogText = GetGuildString( StringTables.Guild.TEXT_CONFIRM_LEAVE_GUILD)
    
    local confirmYes = GetGuildString( StringTables.Guild.BUTTON_CONFIRM_YES)
    local confirmNo = GetGuildString( StringTables.Guild.BUTTON_CONFIRM_NO)
    DialogManager.MakeTwoButtonDialog( dialogText, confirmYes, GuildWindowTabRoster.ConfirmedLeaveGuild, confirmNo, nil)
end

function GuildWindowTabRoster.ConfirmedLeaveGuild()
	BroadcastEvent( SystemData.Events.GUILD_COMMAND_LEAVE )
end

function GuildWindowTabRoster.OnLButtonUpInviteToGuildButton()
    local dialogTitle = GetGuildString(StringTables.Guild.BUTTON_GUILD_COMMAND_INVITE)
	local dialogText = GetGuildString(StringTables.Guild.DIALOG_ROSTER_INVTE_TO_GUILD)

	-- Params (Text to display on top of edit box, text to insert into edit box, function to call if SUBMIT is pressed, function to call if CANCEL is pressed)
	DialogManager.MakeTextEntryDialog( dialogTitle, dialogText, L"", GuildWindowTabRoster.OnSubmitPlayerToInvite, nil )
end

function GuildWindowTabRoster.OnSubmitPlayerToInvite(memberNameToInvite)
	if memberNameToInvite ~= nil
	then
	    SendChatText( L"/guildinvite "..memberNameToInvite, L"" )
	end
end

function GuildWindowTabRoster.CommandDemoteMember()
	BroadcastEvent( SystemData.Events.GUILD_COMMAND_DEMOTE )
end

function GuildWindowTabRoster.CommandPromoteMember()
	BroadcastEvent( SystemData.Events.GUILD_COMMAND_PROMOTE )
end

function GuildWindowTabRoster.CommandAssignLeader()
	-- Create Confirmation Dialog
	local guildPermissionData = GetGuildPermissionData()
    local dialogText = GetFormatStringFromTable( "GuildStrings", StringTables.Guild.DIALOG_CONFIRM_ASSIGN_LEADER, {GuildWindowTabRoster.SelectedGuildMemberName, guildPermissionData[SystemData.GuildRanks.LEADER].rankTitle} )
    
    local confirmYes = GetGuildString( StringTables.Guild.BUTTON_CONFIRM_YES)
    local confirmNo = GetGuildString( StringTables.Guild.BUTTON_CONFIRM_NO)
    DialogManager.MakeTwoButtonDialog( dialogText, confirmYes, GuildWindowTabRoster.ConfirmedAssignLeader, confirmNo, nil)
end

function GuildWindowTabRoster.ConfirmedAssignLeader()
	BroadcastEvent( SystemData.Events.GUILD_COMMAND_ASSIGN )
end

function GuildWindowTabRoster.CommandAssignBearer()
    SendChatText( L"/GuildAddStandardBearer "..GuildWindowTabRoster.SelectedGuildMemberName, L"" )
end

function GuildWindowTabRoster.CommandUnassignBearer()
    SendChatText( L"/GuildRemoveStandardBearer "..GuildWindowTabRoster.SelectedGuildMemberName, L"" )
end

function GuildWindowTabRoster.EditMemberNote()
    if( not CanAddNote() and
	    ( GuildWindowTabRoster.memberListData[GuildWindowTabRoster.SelectedPlayerDataIndex].note == nil or
	    GuildWindowTabRoster.memberListData[GuildWindowTabRoster.SelectedPlayerDataIndex].note == L"" or
	    GuildWindowTabRoster.memberListData[GuildWindowTabRoster.SelectedPlayerDataIndex].note == "" ) )
	then
	    DialogManager.MakeOneButtonDialog( GetFormatStringFromTable( "GuildStrings", StringTables.Guild.DIALOG_MAX_GUILD_NOTES_EVENTS, {MAX_NUM_NOTES} ), GetString( StringTables.Default.LABEL_OKAY ), nil )
	    return
	end
	
	local dialogTitle = GetGuildString( StringTables.Guild.CONTEXT_MENU_ROSTER_EDIT_NOTE )
	local dialogText = GetFormatStringFromTable( "GuildStrings", StringTables.Guild.DIALOG_EDIT_MEMBER_NOTE, {GuildWindowTabRoster.SelectedGuildMemberName} ) 
	DialogManager.MakeTextEntryDialog( dialogTitle, dialogText,
									   GuildWindowTabRoster.memberListData[GuildWindowTabRoster.SelectedPlayerDataIndex].note, 
									   GuildWindowTabRoster.OnAcceptedMemberNote, nil,
                                       GuildWindowTabRoster.MAX_MEMBER_NOTE_LENGTH, true )
end

function GuildWindowTabRoster.OnAcceptedMemberNote(note)
	if note ~= nil
	then
        SendChatText( L"/guildnote "..GuildWindowTabRoster.SelectedGuildMemberName..L" "..note, L"" )
	end
end

function GuildWindowTabRoster.EditOfficerNote()
	if( not CanAddNote() and
	    ( GuildWindowTabRoster.memberListData[GuildWindowTabRoster.SelectedPlayerDataIndex].onote == nil or
	    GuildWindowTabRoster.memberListData[GuildWindowTabRoster.SelectedPlayerDataIndex].onote == L"" or
	    GuildWindowTabRoster.memberListData[GuildWindowTabRoster.SelectedPlayerDataIndex].onote == "" ) )
	then
	    DialogManager.MakeOneButtonDialog( GetFormatStringFromTable( "GuildStrings", StringTables.Guild.DIALOG_MAX_GUILD_NOTES_EVENTS, {MAX_NUM_NOTES} ), GetString( StringTables.Default.LABEL_OKAY ), nil )
	    return
	end
	
	local dialogTitle = GetGuildString( StringTables.Guild.CONTEXT_MENU_ROSTER_EDIT_OFFICER_NOTE )
	local dialogText = GetFormatStringFromTable( "GuildStrings", StringTables.Guild.DIALOG_EDIT_OFFICER_NOTE, {GuildWindowTabRoster.SelectedGuildMemberName} ) 
	DialogManager.MakeTextEntryDialog( dialogTitle, dialogText,
									   GuildWindowTabRoster.memberListData[GuildWindowTabRoster.SelectedPlayerDataIndex].onote, 
									   GuildWindowTabRoster.OnAcceptedOfficerNote, nil,
                                       GuildWindowTabRoster.MAX_MEMBER_NOTE_LENGTH, true )
end

function GuildWindowTabRoster.OnAcceptedOfficerNote(onote)
	if onote ~= nil
	then
        SendChatText( L"/guildofficernote "..GuildWindowTabRoster.SelectedGuildMemberName..L" "..onote, L"" )
	end
end

function GuildWindowTabRoster.CommandJoinParty()
    SendChatText( L"/PartyJoin "..GuildWindowTabRoster.SelectedGuildMemberName, L"" )
end

function GuildWindowTabRoster.CommandJoinWarband()
    SendChatText( L"/WarbandJoin "..GuildWindowTabRoster.SelectedGuildMemberName, L"" )
end

function GuildWindowTabRoster.CommandAssignRecruiter()
    SendChatText( L"/GuildRecruiter "..GuildWindowTabRoster.SelectedGuildMemberName, L"" )
end

function GuildWindowTabRoster.CommandUnassignRecruiter()
    SendChatText( L"/GuildRecruiter "..GuildWindowTabRoster.SelectedGuildMemberName, L"" )
end

function GuildWindowTabRoster.CommandAssignRealmCaptain()
    SendChatText( L"/AddRealmCaptain "..GuildWindowTabRoster.SelectedGuildMemberName, L"" )
end

function GuildWindowTabRoster.CommandUnassignRealmCaptain()
    SendChatText( L"/RemoveRealmCaptain "..GuildWindowTabRoster.SelectedGuildMemberName, L"" )
end

--------------------------------------
--	Event Functions
--------------------------------------
function GuildWindowTabRoster.OnMouseOverCareerIcon()
	-- Figure out what Guild Member we're hovering over, so we can get their career name.
	local windowName	= SystemData.ActiveWindow.name
	local windowIndex	= WindowGetId (windowName)
    local dataIndex     = ListBoxGetDataIndex ("GWRosterList", windowIndex)
	local memberCareer = GuildWindowTabRoster.memberListData[dataIndex].careerString
    
    Tooltips.CreateTextOnlyTooltip (windowName, nil)
    Tooltips.SetTooltipText (1, 1, memberCareer)
    Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)	
    Tooltips.Finalize ()
    
    local anchor = { Point="right", RelativeTo=windowName, RelativePoint="left", XOffset=10, YOffset=0 }
    Tooltips.AnchorTooltip (anchor)
end

function GuildWindowTabRoster.OnMouseOverPartyIcon()
	local windowName	= SystemData.ActiveWindow.name
	local windowIndex	= WindowGetId (windowName)
    local dataIndex     = ListBoxGetDataIndex ("GWRosterList", windowIndex)
	local memberPartyType = L""

    partyType = GuildWindowTabRoster.GetMemberPartyType( GuildWindowTabRoster.memberListData[dataIndex] )
    
    -- if the player isn't in a party we won't show a tooltip
    if partyType == GuildWindowTabRoster.PARTY_TYPE_SOLO
    then
        return
    else
        memberPartyType = GuildWindowTabRoster.partyTooltips[partyType]
    end

    Tooltips.CreateTextOnlyTooltip (windowName, nil)
    Tooltips.SetTooltipText (1, 1, memberPartyType)
    Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)	
    Tooltips.Finalize ()
    
    local anchor = { Point = "topright", RelativeTo = WindowGetParent(windowName), RelativePoint = "topleft", XOffset = 0, YOffset = 0 }
    Tooltips.AnchorTooltip (anchor)
end

function GuildWindowTabRoster.OnMouseOverStandardIcon()
	local windowName	= SystemData.ActiveWindow.name
	local windowIndex	= WindowGetId (windowName)
	local tooltipText = GetGuildString(StringTables.Guild.TOOLTIP_TOOLTIP_STANDARD_BEARER)

    Tooltips.CreateTextOnlyTooltip (windowName, nil)
    Tooltips.SetTooltipText (1, 1, tooltipText)
    Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)	
    Tooltips.Finalize ()

    local anchor = { Point = "topright", RelativeTo = WindowGetParent(windowName), RelativePoint = "topleft", XOffset = 0, YOffset = 0 }
    Tooltips.AnchorTooltip (anchor)
end

function GuildWindowTabRoster.OnMouseOverRealmCaptainIcon()
	local windowName	= SystemData.ActiveWindow.name
	local windowIndex	= WindowGetId (windowName)
	local tooltipText = GetGuildString(StringTables.Guild.TOOLTIP_TOOLTIP_REALM_CAPTAIN)

    Tooltips.CreateTextOnlyTooltip (windowName, nil)
    Tooltips.SetTooltipText (1, 1, tooltipText)
    Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)	
    Tooltips.Finalize ()

    local anchor = { Point = "topright", RelativeTo = WindowGetParent(windowName), RelativePoint = "topleft", XOffset = 0, YOffset = 0 }
    Tooltips.AnchorTooltip (anchor)
end

function GuildWindowTabRoster.OnMouseOverRecruiterIcon()
	local windowName	= SystemData.ActiveWindow.name
	local windowIndex	= WindowGetId (windowName)
	local tooltipText = GetGuildString(StringTables.Guild.TOOLTIP_TOOLTIP_RECRUITER)

    Tooltips.CreateTextOnlyTooltip (windowName, nil)
    Tooltips.SetTooltipText (1, 1, tooltipText)
    Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)	
    Tooltips.Finalize ()

    local anchor = { Point = "topright", RelativeTo = WindowGetParent(windowName), RelativePoint = "topleft", XOffset = 0, YOffset = 0 }
    Tooltips.AnchorTooltip (anchor)
end

function GuildWindowTabRoster.UpdatePermissions()

	if GuildWindow.SelectedTab ~= GuildWindow.TABS_ROSTER then
		return
	end

	-- OPTIMIZEME: Only update the permissions if the player is the member that was updated

	-- Update the Command Buttons
	local localPlayerTitleNumber = GuildWindowTabAdmin.GetLocalMemberTitleNumber()
	local bCanInvitePlayersIntoGuild  = GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.INVITE, localPlayerTitleNumber)

	-- If the player doesn't have permission to invite players into the Guild, hide the Invite button
	WindowSetShowing("GWRosterInviteToGuildButton", bCanInvitePlayersIntoGuild)
end

--------------------------------------
--	Update Functions
--------------------------------------
function GuildWindowTabRoster.UpdateMemberList()
    -- Filter, Sort, and Update
    FilterMemberList()
    SortMemberList()
    ListBoxSetDisplayOrder( "GWRosterList", GuildWindowTabRoster.memberListOrder )
	GuildWindowTabRoster.UpdateMembersOnlineText()
	GuildWindowTabRoster.UpdateMemberRows()
    GuildWindowTabProfile.OnGuildMembersUpdated()
end

function GuildWindowTabRoster.OnMemberUpdated(memberDataTable)
	
	if memberDataTable == nil or GWRosterList.PopulatorIndices == nil then
		return
	end
	-- Loop through all the guild members to find the one that we want.
	-- OPTIMIZEME: Might be faster if we store the memberID as the index into the memberDataTable, but then we'd have to use pairs instead of ipairs,
	-- so depending on the circumstance, this may or may not buy us some performance.
	for index, memberData in ipairs(GuildWindowTabRoster.memberListData) do
		if memberData.memberID == memberDataTable.memberID
        then
            local hadNote = memberData.note and memberData.note ~= L"" and memberData.note ~= ""
            local hadOfficerNote = memberData.onote and memberData.onote ~= L"" and memberData.onote ~= ""
            local wasRecruiter = memberData.recruiterStatus > 0
            
            local hasNote = memberDataTable.note and memberDataTable.note ~= L"" and memberDataTable.note ~= ""
            local hasOfficerNote = memberDataTable.onote and memberDataTable.onote ~= L"" and memberDataTable.onote ~= ""
            local isRecruiter = memberDataTable.recruiterStatus > 0
            
            if hadNote and not hasNote
            then
                numGuildMemberNotes = numGuildMemberNotes - 1
            elseif not hadNote and hasNote
            then
                numGuildMemberNotes = numGuildMemberNotes + 1
            end
            
            if hadOfficerNote and not hasOfficerNote
            then
                numOfficerNotes = numOfficerNotes - 1
            elseif not hadOfficerNote and hasOfficerNote
            then
                numOfficerNotes = numOfficerNotes + 1
            end
            
            if wasRecruiter and not isRecruiter
            then
                numRecruiters = numRecruiters - 1
            elseif not wasRecruiter and isRecruiter
            then
                numRecruiters = numRecruiters + 1
            end
        
			GuildWindowTabRoster.memberListData[index] = DataUtils.CopyTable(memberDataTable)

			-- A couple of things cannot be set in C, so we'll do that stuff here:
			UpdateLUASpecificMemberData(index, memberDataTable)

			-- If the local player's info was updated, update the localPlayerCache
			if (WStringsCompare(GameData.Player.name, memberDataTable.name) == 0) then
				GuildWindow.UpdateLocalPlayerCache(memberDataTable)
			end
		end
	end

	GuildWindowTabRoster.UpdateMemberList()
	GuildWindowTabRoster.UpdatePermissions()
	GuildWindowTabAlliance.ForceUpdate()

end

local function UpdateMembersNotes(memberNotesData)
	for index, data in ipairs(GuildWindowTabRoster.memberListData) do
		-- If the member we're looking for matches the current memberNotesMember, then assign the notes.
		if memberNotesData.memberID == data.memberID then
			data.note = memberNotesData.note
			data.onote = memberNotesData.onote
			return true
		end	
	end
	
	return false
end

function GuildWindowTabRoster.OnMemberNotesUpdated(memberNotes)
	-- Note: memberNotes contains a table of members, each of which is a table consisting of [.memberID, .note, .onote].
	-- OPTIMIZEME: Might be faster if we store the memberID as the index into the memberDataTable, but then we'd have to use pairs instead of ipairs,
	-- so depending on the circumstance, this may or may not buy us some performance.

	-- Loop through all the notes contained in this msg
	for memberNotesIndex, memberNotesData in ipairs(memberNotes) do
		UpdateMembersNotes( memberNotesData )
	end
end

function GuildWindowTabRoster.OnMemberAdded(memberDataTable)
	local newDataIndex = #GuildWindowTabRoster.memberListData+1
	table.insert(GuildWindowTabRoster.memberListData, newDataIndex, memberDataTable)

	-- A couple of things cannot be set in C, so we'll do that stuff here:
	UpdateLUASpecificMemberData(newDataIndex, memberDataTable)

	GuildWindowTabRoster.UpdateMemberList()
end

function GuildWindowTabRoster.OnMemberRemoved(memberID)
	for index, data in ipairs(GuildWindowTabRoster.memberListData) do
		if data.memberID == memberID
        then
            local hadNote = data.note and data.note ~= L"" and data.note ~= ""
            local hadOfficerNote = data.onote and data.onote ~= L"" and data.onote ~= ""
            local wasRecruiter = data.recruiterStatus > 0
            
            if hadNote
            then
                numGuildMemberNotes = numGuildMemberNotes - 1
            end
            if hadOfficerNote
            then
                numOfficerNotes = numOfficerNotes - 1
            end
            if wasRecruiter
            then
                numRecruiters = numRecruiters - 1
            end
            
			table.remove(GuildWindowTabRoster.memberListData, index)
		end
	end

	GuildWindowTabRoster.UpdateMemberList()
end

function GuildWindowTabRoster.OnNewbieGuildStatusUpdated(isInNewbieGuild)
    -- Do not show the "Hide Offline" check box if the player is in a newbie guild
    WindowSetShowing("GWRosterHideOfflineHeader", not isInNewbieGuild)
    WindowSetShowing("GWRosterHideOfflineCheckBox", not isInNewbieGuild)
end


---------------------------------------
-- Util Functions
---------------------------------------
function GuildWindowTabRoster.IsPlayerInGuild( playerName )

    for _, memberData in ipairs( GuildWindowTabRoster.memberListData )
    do
        if( WStringsCompareIgnoreGrammer( playerName, memberData.name) == 0 )
        then
            return true 
        end
    end

    return false
end

function GuildWindowTabRoster.IsMemberOnline( memberData )
    return ( memberData ~= nil and memberData.zoneID ~= nil and memberData.zoneID ~= 0 )
end

function GuildWindowTabRoster.GetMemberPartyType( memberData )
    
    -- is the member in a warband
    if memberData.inWarband
    then
        -- is it guild only
        if memberData.guildParty
        then
            return GuildWindowTabRoster.PARTY_TYPE_WARBAND_GUILD
        -- is it alliance only
        elseif memberData.allianceParty
        then
            return GuildWindowTabRoster.PARTY_TYPE_WARBAND_ALLIANCE
        -- is it open
        elseif memberData.openParty
        then
            return GuildWindowTabRoster.PARTY_TYPE_WARBAND_OPEN
        -- well then it must be closed
        else
            return GuildWindowTabRoster.PARTY_TYPE_WARBAND_CLOSED
        end
    -- is the member in a party
    elseif memberData.inParty
    then
        -- is it guild only
        if memberData.guildParty
        then
            return GuildWindowTabRoster.PARTY_TYPE_PARTY_GUILD
        -- is it alliance only
        elseif memberData.allianceParty
        then
            return GuildWindowTabRoster.PARTY_TYPE_PARTY_ALLIANCE
        -- is it open
        elseif memberData.openParty
        then
            return GuildWindowTabRoster.PARTY_TYPE_PARTY_OPEN
        -- well then it must be closed
        else
            return GuildWindowTabRoster.PARTY_TYPE_PARTY_CLOSED
        end
    end
    -- otherwise we are solo
    return GuildWindowTabRoster.PARTY_TYPE_SOLO
end

