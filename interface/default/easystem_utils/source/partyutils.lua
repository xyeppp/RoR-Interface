
-- NOTE: This file is documented with NaturalDocs style comments. All comments begining with "--#' will
-- be included in the output.

PartyUtils = {}

PartyUtils.PARTIES_PER_WARBAND = 4
PartyUtils.PLAYERS_PER_PARTY = 6
PartyUtils.PLAYERS_PER_PARTY_WITHOUT_LOCAL = PartyUtils.PLAYERS_PER_PARTY - 1

local warbandParties = {}
local partyData = {}

------------------------------------------------------------------------------------------------------------------------------------------------
--# Title: Party Utils
--#     This file contains data manipulation and access utilities similar to <DataUtils>.
------------------------------------------------------------------------------------------------------------------------------------------------

function PartyUtils.Initialize()
    GameData.Party.warbandDirty = true
    GameData.Party.partyDirty = true
end


function PartyUtils.Shutdown()
end

----------------------------------------------------------------------------------------------------
--# Function: PartyUtils.GetPartyData()
--#         This function returns a table of party members. Prefer this
--#         util function to <GetGroupData()>.
--#
--#     Parameters:
--#         None
--#
--#     Returns:
--#         See <GetGroupData()>
--#
----------------------------------------------------------------------------------------------------
function PartyUtils.GetPartyData()
    if( GameData.Party.partyDirty )
    then
        partyData = GetGroupData()
        GameData.Party.partyDirty = false
    end
    return partyData
end

----------------------------------------------------------------------------------------------------
--# Function: PartyUtils.GetPartyMember()
--#         This function returns a table for a single party member.
--#
--#     Parameters:
--#         memberIndex - (number) index of the party member to retrieve
--#
--#     Returns:
--#         See <GetGroupData()>
--#
----------------------------------------------------------------------------------------------------
function PartyUtils.GetPartyMember( memberIndex )
    if( memberIndex == nil
        or memberIndex < 1
        or memberIndex > PartyUtils.PLAYERS_PER_PARTY_WITHOUT_LOCAL )
    then
        return nil
    end

    local member = PartyUtils.GetPartyData()[memberIndex]
    if( GetAndClearPartyMemberDirtyFlag( memberIndex ) )
    then
        local memberData = GetGroupMemberStatusData( memberIndex )
        member.healthPercent = memberData.healthPercent
        member.actionPointPercent = memberData.actionPointPercent
        member.moraleLevel = memberData.moraleLevel
        member.level = memberData.level
        member.battleLevel = memberData.battleLevel
        member.Pet.healthPercent = memberData.petHealthPercent
        member.isRVRFlagged = memberData.isRVRFlagged
        member.zoneNum = memberData.zoneNum
        member.online = memberData.online
        member.isDistant = memberData.isDistant
        member.worldObjNum = memberData.worldObjNum
    end
    return member
end

----------------------------------------------------------------------------------------------------
--# Function: PartyUtils.IsPartyMemberValid()
--#         This function checks to see if a given party member index is valid (has a player)
--#
--#     Parameters:
--#         memberIndex - (number) the index to check
--#
--#     Returns:
--#         True if a member exists at the given index, false otherwise
--#
----------------------------------------------------------------------------------------------------
function PartyUtils.IsPartyMemberValid( memberIndex )
    local member = PartyUtils.GetPartyMember( memberIndex )
    if( member ~= nil and member.name ~= nil and member.name ~= L"" )
    then
        return true
    end
    return false
end

----------------------------------------------------------------------------------------------------
--# Function: PartyUtils.IsPartyActive()
--#         This function checks to see if the player is in an active party by checking the
--#         validity of member index 1
--#
--#     Parameters:
--#         None
--#
--#     Returns:
--#         True if party is active
--#
----------------------------------------------------------------------------------------------------
function PartyUtils.IsPartyActive( memberIndex )
    return PartyUtils.IsPartyMemberValid( 1 )
end

----------------------------------------------------------------------------------------------------
--# Function: PartyUtils.GetWarbandData()
--#         This function returns a table of warband parties and members. Prefer this
--#         util function to <GetBattlegroupMemberData()>.
--#         For continuous warband updates, you should use <PartyUtils.GetWarbandMember()>
--#         when a <SystemData.Events.BATTLEGROUP_MEMBER_UPDATED> is received.
--#
--#     Parameters:
--#         None
--#
--#     Returns:
--#         See <GetBattlegroupMemberData()>
--#
----------------------------------------------------------------------------------------------------
function PartyUtils.GetWarbandData()
    if( GameData.Party.warbandDirty )
    then
        warbandParties = GetBattlegroupMemberData()
        
        --[[ Test Data
        local member = DataUtils.CopyTable(warbandParties[1].players[1])
        for _, party in ipairs( warbandParties )
        do
            for i = 1, 6
            do
                party.players[i] = member
            end
        end
        --]]
        
        GameData.Party.warbandDirty = false
    end
    return warbandParties
end

----------------------------------------------------------------------------------------------------
--# Function: PartyUtils.GetWarbandParty()
--#         Gets the table for a single party in a warband
--#
--#     Parameters:
--#         partyIndex  - (number) Index of the party you wish to retrieve (1 - PartyUtils.PARTIES_PER_WARBAND)
--#
--#     Returns:
--#         nil if index was bad, otherwise the same data as <GetBattlegroupMemberData()>[partyIndex]
--#
----------------------------------------------------------------------------------------------------
function PartyUtils.GetWarbandParty( partyIndex )
    if( partyIndex == nil
        or partyIndex < 1
        or partyIndex > PartyUtils.PARTIES_PER_WARBAND )
    then
        return nil
    end

    local warband = PartyUtils.GetWarbandData()
    return warband[partyIndex]
end

----------------------------------------------------------------------------------------------------
--# Function: PartyUtils.GetWarbandMember()
--#         Gets the table for a specific member within the warband
--#
--#     Parameters:
--#         partyIndex  - (number) Index of the party you wish to retrieve (1 - PartyUtils.PARTIES_PER_WARBAND)
--#         memberIndex - (number) Index of the member within their party (1 - PartyUtils.PLAYERS_PER_PARTY)
--#
--#     Returns:
--#         nil if index was bad, otherwise the same data as <GetBattlegroupMemberData()>[partyIndex].players[playerIndex]
--#
----------------------------------------------------------------------------------------------------
function PartyUtils.GetWarbandMember( partyIndex, memberIndex )
    if( memberIndex == nil
        or memberIndex < 1
        or memberIndex > PartyUtils.PLAYERS_PER_PARTY )
    then
        return nil
    end
    
    local party = PartyUtils.GetWarbandParty( partyIndex )
    if( party == nil or party.players == nil )
    then
        return
    end
    
    local member = party.players[memberIndex]
    
    if( GetAndClearWarbandMemberDirtyFlag( partyIndex, memberIndex ) )
    then       
        local memberData = GetWarbandMemberStatus( partyIndex, memberIndex )
        member.healthPercent = memberData.healthPercent
        member.actionPointPercent = memberData.actionPointPercent
        member.moraleLevel = memberData.moraleLevel
        member.level = memberData.level
        member.battleLevel = memberData.battleLevel
        member.isRVRFlagged = memberData.isRVRFlagged
        member.zoneNum = memberData.zoneNum
        member.online = memberData.online
        member.isDistant = memberData.isDistant
        member.worldObjNum = memberData.worldObjNum
    end
    
    return member
end

----------------------------------------------------------------------------------------------------
--# Function: PartyUtils.GetWarbandMainAssist()
--#         Gets the member table for warband's main assist
--#
--#     Parameters:
--#         None
--#
--#     Returns:
--#         nil if no main assist found, otherwise the same sort of member table
--#         returned by <PartyUtils.GetWarbandMember()>
--#
----------------------------------------------------------------------------------------------------
function PartyUtils.GetWarbandMainAssist()
    local warband = PartyUtils.GetWarbandData()
    for _, party in ipairs( warband )
    do
        for _, member in ipairs( party.players )
        do
            if( member.isMainAssist )
            then
                return member
            end
        end
    end

    return nil
end

----------------------------------------------------------------------------------------------------
--# Function: PartyUtils.GetWarbandLeader()
--#         Gets the member table for warband's leader
--#
--#     Parameters:
--#         None
--#
--#     Returns:
--#         nil if no leader found, otherwise the same sort of member table
--#         returned by <PartyUtils.GetWarbandMember()>
--#
----------------------------------------------------------------------------------------------------
function PartyUtils.GetWarbandLeader()
    local warband = PartyUtils.GetWarbandData()
    for _, party in ipairs( warband )
    do
        for _, member in ipairs( party.players )
        do
            if( member.isGroupLeader )
            then
                return member
            end
        end
    end

    return nil
end

----------------------------------------------------------------------------------------------------
--# Function: PartyUtils.IsPlayerInWarband()
--#         Checks to see if a given player name exists in the warband
--#
--#     Parameters:
--#         playerName  - (wstring) the player's name to check
--#
--#     Returns:
--#         2 values: partyIndex and memberIndex of the player if found
--#         If the player was not found, returns nil
--#
----------------------------------------------------------------------------------------------------
function PartyUtils.IsPlayerInWarband( playerName )
    if( playerName == nil )
    then
        return nil, nil
    end

    local warband = PartyUtils.GetWarbandData()
    for partyIndex, party in ipairs( warband )
    do
        for memberIndex, member in ipairs( party.players )
        do
            if( WStringsCompareIgnoreGrammer( playerName, member.name ) == 0 )
            then
                return partyIndex, memberIndex
            end
        end
    end

    return nil, nil
end

----------------------------------------------------------------------------------------------------
--# Function: PartyUtils.IsWarbandFull()
--#         Determines if the player's warband is completely full
--#
--#     Parameters:
--#         None
--#
--#     Returns:
--#         true if the warband is full, false otherwise
--#
----------------------------------------------------------------------------------------------------
function PartyUtils.IsWarbandFull()
    local warband = PartyUtils.GetWarbandData()
    for _, party in ipairs( warband )
    do
        if( table.getn(party.players) < PartyUtils.PLAYERS_PER_PARTY )
        then
            return false
        end
    end

    return true
end

----------------------------------------------------------------------------------------------------
--# Function: PartyUtils.MoveWarbandMember()
--#         Moves a player to the specified warband party
--#
--#     Parameters:
--#         playerName  - (wstring) the player to move
--#         partyIndex  - (number) index of warband party to move to
--#
--#     Returns:
--#         Nothing
--#
----------------------------------------------------------------------------------------------------
function PartyUtils.MoveWarbandMember( playerName, partyIndex )
    if(    playerName == nil or playerName == L""
        or partyIndex == nil or partyIndex < 1 or partyIndex > PartyUtils.PARTIES_PER_WARBAND )
    then
        return
    end

    -- Message the server.
    SendChatText( L"/warbandmove "..playerName..L" "..partyIndex, L"" )
end

----------------------------------------------------------------------------------------------------
--# Function: PartyUtils.SwapWarbandMembers()
--#         Swaps two players in the warband
--#
--#     Parameters:
--#         playerName1 - (wstring) the first player to swap
--#         playerName2 - (wstring) the other player to swap with
--#
--#     Returns:
--#         Nothing
--#
----------------------------------------------------------------------------------------------------
function PartyUtils.SwapWarbandMembers( playerName1, playerName2 )
    if(    playerName1 == nil or playerName1 == L""
        or playerName2 == nil or playerName2 == L"" )
    then
        return
    end

    -- Message the server.
    SendChatText( L"/warbandswap "..playerName1..L" "..playerName2, L"" )
end

----------------------------------------------------------------------------------------------------
--# Function: PartyUtils.SetWarbandLeader()
--#         Sets the warband's leader using the value in <SystemData.UserInput.selectedGroupMember>.
--#         This function assumes the player has permission to set the leader.
--#
--#     Parameters:
--#         None
--#
--#     Returns:
--#         Nothing
--#
----------------------------------------------------------------------------------------------------
function PartyUtils.SetWarbandLeader()
    SendChatText( L"/warbandleader "..SystemData.UserInput.selectedGroupMember, L"" )
end

----------------------------------------------------------------------------------------------------
--# Function: PartyUtils.SetWarbandLeader()
--#         Sets the member specified in <SystemData.UserInput.selectedGroupMember> to a warband
--#         assistant. This function assumes the player has permission to promote.
--#
--#     Parameters:
--#         None
--#
--#     Returns:
--#         Nothing
--#
----------------------------------------------------------------------------------------------------
function PartyUtils.SetWarbandAssistant()
    SendChatText( L"/warbandpromote "..SystemData.UserInput.selectedGroupMember, L"" )
end

----------------------------------------------------------------------------------------------------
--# Function: PartyUtils.DemoteWarbandAssistant()
--#         Demotes the member specified in <SystemData.UserInput.selectedGroupMember>.
--#         This function assumes the player has permission to demote.
--#
--#     Parameters:
--#         None
--#
--#     Returns:
--#         Nothing
--#
----------------------------------------------------------------------------------------------------
function PartyUtils.DemoteWarbandAssistant()
    SendChatText( L"/warbanddemote "..SystemData.UserInput.selectedGroupMember, L"" )
end

----------------------------------------------------------------------------------------------------
--# Function: PartyUtils.SetMainAssist()
--#         Sets the party's main assist using the value in <SystemData.UserInput.selectedGroupMember>.
--#         This function assumes the player has permission to change the main assist.
--#
--#     Parameters:
--#         None
--#
--#     Returns:
--#         Nothing
--#
----------------------------------------------------------------------------------------------------
function PartyUtils.SetMainAssist()
    BroadcastEvent( SystemData.Events.GROUP_SET_MAIN_ASSIST )
end

----------------------------------------------------------------------------------------------------
--# Function: PartyUtils.SetMasterLooter()
--#         Sets the party's master looter using the value in <SystemData.UserInput.selectedGroupMember>.
--#         This function assumes the player has permission to change the loot options.
--#
--#     Parameters:
--#         None
--#
--#     Returns:
--#         Nothing
--#
----------------------------------------------------------------------------------------------------
function PartyUtils.SetMasterLooter()
    BroadcastEvent( SystemData.Events.GROUP_SET_MASTER_LOOT_ON )
end

----------------------------------------------------------------------------------------------------
--# Function: PartyUtils.OnSummonPlayer()
--#         Context menu function to summon a group member to the players current location.
--#
--#     Parameters:
--#         None
--#
--#     Returns:
--#         Nothing
--#
----------------------------------------------------------------------------------------------------
function PartyUtils.OnSummonPlayer()
	local playerToSummon = SystemData.UserInput.selectedGroupMember
	local player = nil
	
	if( IsWarBandActive() )
	then
		local partyIndex, memberIndex = PartyUtils.IsPlayerInWarband( playerToSummon )
		player = PartyUtils.GetWarbandMember( partyIndex, memberIndex )
	else
		local party = PartyUtils.GetPartyData()
		for index, member in ipairs( party )
		do
			if( member and member.name == playerToSummon )
			then
				player = member
			end
		end
	end
	if( player and player.level )
	then
		local invSlot = DataUtils.HasRequiredSummoningStone( player.level )
		if( invSlot )
		then
			SetTargetToSummon( playerToSummon )
			SendUseItem( GameData.ItemLocs.INVENTORY, invSlot, 0, 0, 0 )
		end
	end
end

----------------------------------------------------------------------------------------------------
--# Function: PartyUtils.BolsterOffer()
--#         Context menu function to bolster a group member of the players party. So the two players
--#			end up with a similar battle level
--#
--#     Parameters:
--#         None
--#
--#     Returns:
--#         Nothing
--#
----------------------------------------------------------------------------------------------------
function PartyUtils.BolsterOffer()
	BroadcastEvent( SystemData.Events.BOLSTER_OFFER ) 
end

function PartyUtils.BolsterCancel()
	BroadcastEvent( SystemData.Events.BOLSTER_CANCEL ) 
end

----------------------------------------------------------------------------------------------------
--# Function: PartyUtils.GetBolsterMenuText( name )
--#         Helper function to get the text for context menus that need to display bolster options
--#
--#     Parameters:
--#         name	-	name of party member
--#
--#     Returns:
--#         bolsterText	-	context menu text for bolstering depending on bolster status
--#
----------------------------------------------------------------------------------------------------
function PartyUtils.GetBolsterMenuText( name )
	local bolsterText = nil
	local bolsterBuddy = GetBolsterBuddy()
	local bolsterCallback = nil
	if( bolsterBuddy ~= nil and bolsterBuddy == name )
	then
		bolsterText = GetString( StringTables.Default.LABEL_END_APPRENTICESHIP )
		bolsterCallback = PartyUtils.BolsterCancel
	elseif( bolsterBuddy == nil )
	then
		bolsterText = GetString( StringTables.Default.LABEL_MAKE_APPRENTICE )
		bolsterCallback = PartyUtils.BolsterOffer
	end
	
	return bolsterText, bolsterCallback
end


function PartyUtils.GetLevelTextColor( level, battleLevel )

	local isBolsteredUp = battleLevel > level
	local isBolsteredDown = battleLevel < level
	
	local color = DefaultColor.WHITE
	if( isBolsteredUp )
	then
		color = DefaultColor.GREEN	
	elseif( isBolsteredDown )
	then
		color = DefaultColor.RED
	end

    return color
end

function PartyUtils.GetLevelText( level, battleLevel )

	local isBolsteredUp = battleLevel > level
	local isBolsteredDown = battleLevel < level
	
    local levelString = level
    if( isBolsteredUp )
    then
        local levelBonus = battleLevel - level
        levelString = GetFormatStringFromTable( "HUDStrings", StringTables.HUD.LABEL_ADDITION, { level, levelBonus, battleLevel } )        
    elseif( isBolsteredDown )
    then
        local levelBonus = level - battleLevel
        levelString = GetFormatStringFromTable( "HUDStrings", StringTables.HUD.LABEL_SUBTRACTION, { level, levelBonus, battleLevel } )        
    end

    return levelString
end
