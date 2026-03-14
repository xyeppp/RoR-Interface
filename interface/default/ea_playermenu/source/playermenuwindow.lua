----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

PlayerMenuWindow = {}

PlayerMenuWindow.curPlayer = {}
PlayerMenuWindow.curPlayer.name = L""
PlayerMenuWindow.curPlayer.objNum = 0

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

----------------------------------------------------------------
-- PlayerMenuWindow Functions
----------------------------------------------------------------

-- OnInitialize Handler
function PlayerMenuWindow.Initialize()
    RegisterEventHandler( SystemData.Events.R_BUTTON_UP_PROCESSED, "PlayerMenuWindow.OnRButtonUpProcessed")
    RegisterEventHandler( SystemData.Events.L_BUTTON_DOWN_PROCESSED, "PlayerMenuWindow.OnLButtonDownProcessed")
    RegisterEventHandler( SystemData.Events.R_BUTTON_DOWN_PROCESSED, "PlayerMenuWindow.OnRButtonDownProcessed")
    RegisterEventHandler( SystemData.Events.TOGGLE_MENU, "PlayerMenuWindow.ToggleMenu")
end

function PlayerMenuWindow.Shutdown()

end

function PlayerMenuWindow.Done()
    PlayerMenuWindow.curPlayer.name = L""
    PlayerMenuWindow.curPlayer.objNum = 0
end

function PlayerMenuWindow.OnLButtonDownProcessed()
    if( SystemData.InputProcessed.LButtonDown == false ) then
        PlayerMenuWindow.Done()
    end 
end

function PlayerMenuWindow.OnRButtonDownProcessed()
    PlayerMenuWindow.Done()
end

function PlayerMenuWindow.OnRButtonUpProcessed()

    -- Did we R-Click into the world window with a valid MouseoverTarget?
    if( SystemData.InputProcessed.RButtonDown == false 
        and SystemData.InputProcessed.RButtonUp == false 
        and TargetInfo:UnitEntityId( c_MOUSEOVER_TARGET ) ~= 0 
        and TargetInfo:UnitType( c_MOUSEOVER_TARGET ) == SystemData.TargetObjectType.ALLY_PLAYER ) then
        PlayerMenuWindow.ShowMenu( TargetInfo:UnitEntityName( c_MOUSEOVER_TARGET ), TargetInfo:UnitEntityId( c_MOUSEOVER_TARGET ) )
    end

end


function PlayerMenuWindow.NewCustomItem( in_buttonText, in_callbackFunction, in_bDisabled )
    return { buttonText=in_buttonText, callbackFunction=in_callbackFunction, bDisabled=in_bDisabled }
end

function PlayerMenuWindow.ShowMenu( playerName, playerObjNum, customItems) 
    PlayerMenuWindow.curPlayer.name = wstring.gsub( playerName, L"(^.)", L"" )
    PlayerMenuWindow.curPlayer.objNum = playerObjNum

    -- Create the Menu    
    local menuTitleText = GetStringFormat( StringTables.Default.LABEL_PLAYER_MENU_TITLE, { playerName } )    
    EA_Window_ContextMenu.CreateContextMenu( SystemData.ActiveWindow.name, EA_Window_ContextMenu.CONTEXT_MENU_1, menuTitleText )
    
    local targetSelf = ( WStringsCompareIgnoreGrammer( PlayerMenuWindow.curPlayer.name, GameData.Player.name ) == 0 )

    -- Add Each Section
    PlayerMenuWindow.AddCustomItems( customItems )    
    PlayerMenuWindow.AddInteractionMenuItems( targetSelf )
    PlayerMenuWindow.AddSocialMenuItems( targetSelf )
    PlayerMenuWindow.AddGroupMenuItems( targetSelf )
    PlayerMenuWindow.AddGuildMenuItems( targetSelf )
    
    -- Add Cancel at the very end of the list & finalize     
    EA_Window_ContextMenu.AddMenuDivider( EA_Window_ContextMenu.CONTEXT_MENU_1 )
    EA_Window_ContextMenu.AddMenuItem( GetString( StringTables.Default.LABEL_PLAYER_MENU_CANCEL ), PlayerMenuWindow.OnCancel, false, true, EA_Window_ContextMenu.CONTEXT_MENU_1 )        
    EA_Window_ContextMenu.Finalize()

end

---------------------------------------------------------------------
-- Menu Sections
---------------------------------------------------------------------

function PlayerMenuWindow.AddCustomItems( customItems )   
    if( customItems == nil or type(customItems) ~= "table" or customItems[1] == nil )
    then
        return
    end
    
    EA_Window_ContextMenu.AddMenuDivider( EA_Window_ContextMenu.CONTEXT_MENU_1 )
    
    -- Add Each Item to the menu
    for _, menuItem in ipairs( customItems )
    do
        EA_Window_ContextMenu.AddMenuItem( menuItem.buttonText, menuItem.callbackFunction, menuItem.bDisabled, true, EA_Window_ContextMenu.CONTEXT_MENU_1 )
    end
    
end
    

function PlayerMenuWindow.AddInteractionMenuItems( targetSelf )

    local targetGameAction = EA_Window_ContextMenu.GameActionData( GameData.PlayerActions.SET_TARGET, 0,  PlayerMenuWindow.curPlayer.name )
 
    EA_Window_ContextMenu.AddMenuDivider( EA_Window_ContextMenu.CONTEXT_MENU_1 )
    
    local disableAllButTarget = (targetSelf == true)

    -- Talk to the Player
    EA_Window_ContextMenu.AddMenuItem( GetString( StringTables.Default.LABEL_PLAYER_MENU_TALK ), PlayerMenuWindow.OnTalk, disableAllButTarget, true, EA_Window_ContextMenu.CONTEXT_MENU_1 )

    -- Target the Player
    EA_Window_ContextMenu.AddMenuItem( GetString( StringTables.Default.LABEL_PLAYER_MENU_TARGET ), PlayerMenuWindow.OnTarget, false, true, EA_Window_ContextMenu.CONTEXT_MENU_1, targetGameAction )

    -- Assist the Player
    EA_Window_ContextMenu.AddMenuItem( GetString( StringTables.Default.LABEL_ASSIST ), PlayerMenuWindow.OnAssist, disableAllButTarget, true, EA_Window_ContextMenu.CONTEXT_MENU_1, nil )

	-- Duel the Player
	EA_Window_ContextMenu.AddMenuItem( GetString( StringTables.Default.LABEL_PLAYER_MENU_INITIATE_DUEL ), PlayerMenuWindow.OnDuel, GameData.Player.inCombat, true, EA_Window_ContextMenu.CONTEXT_MENU_1, nil )

    -- Trade the the Player
    local isTrial, isBuddied = GetAccountData()
    if( isTrial == false )
    then
        EA_Window_ContextMenu.AddMenuItem( GetString( StringTables.Default.LABEL_PLAYER_MENU_TRADE ), PlayerMenuWindow.OnTrade, disableAllButTarget, true, EA_Window_ContextMenu.CONTEXT_MENU_1, targetGameAction )
    end

    -- Inspect the Player
    EA_Window_ContextMenu.AddMenuItem( GetString( StringTables.Default.LABEL_PLAYER_MENU_INSPECT ), PlayerMenuWindow.OnInspect, disableAllButTarget, true, EA_Window_ContextMenu.CONTEXT_MENU_1, targetGameAction )

    -- Follow the Player
    EA_Window_ContextMenu.AddMenuItem( GetString( StringTables.Default.LABEL_PLAYER_MENU_FOLLOW ), PlayerMenuWindow.OnFollow, disableAllButTarget, true, EA_Window_ContextMenu.CONTEXT_MENU_1, targetGameAction )

end

function PlayerMenuWindow.AddSocialMenuItems( targetSelf )

    local disableAddToFriends = SocialWindow.IsPlayerOnFriendsList( PlayerMenuWindow.curPlayer.name ) or (targetSelf == true)
    local disableAddToIgnore  = SocialWindow.IsPlayerOnIgnoreList( PlayerMenuWindow.curPlayer.name ) or (targetSelf == true)
    
    EA_Window_ContextMenu.AddMenuDivider( EA_Window_ContextMenu.CONTEXT_MENU_1 )

    -- Add Player to Friends List
    EA_Window_ContextMenu.AddMenuItem( GetString( StringTables.Default.LABEL_PLAYER_MENU_ADD_TO_FRIENDS ), PlayerMenuWindow.OnAddFriend, disableAddToFriends, true, EA_Window_ContextMenu.CONTEXT_MENU_1 )

    -- Add Player to Ignore List
    EA_Window_ContextMenu.AddMenuItem( GetString( StringTables.Default.LABEL_PLAYER_MENU_ADD_TO_IGNORE ), PlayerMenuWindow.OnAddIgnore, disableAddToIgnore, true, EA_Window_ContextMenu.CONTEXT_MENU_1 )
end

function  PlayerMenuWindow.AddGroupMenuItems( targetSelf )
   
    local isGroupMember         = GroupWindow.IsPlayerInGroup(  PlayerMenuWindow.curPlayer.name )
    local isBattleGroupMember   = ( PartyUtils.IsPlayerInWarband( PlayerMenuWindow.curPlayer.name ) ~= nil )

    local inFullGroup = GroupWindow.groupData[GroupWindow.MAX_GROUP_MEMBERS].name ~= L"" and IsWarBandActive() == false
    
    local disableGroupInvite = (inFullGroup == true) or (isGroupMember == true) or (isBattleGroupMember == true) or (targetSelf == true)
    local disableGroupKick   = ( (GameData.Player.isGroupLeader == false) and (GameData.Player.isWarbandAssistant == false) ) or ( (isGroupMember == false) and (isBattleGroupMember == false) ) or (targetSelf == true)
    local disableGroupJoin   = (isGroupMember == true) or (isBattleGroupMember == true) or (targetSelf == true)

    EA_Window_ContextMenu.AddMenuDivider( EA_Window_ContextMenu.CONTEXT_MENU_1 )
    
    -- Invite To Group
    EA_Window_ContextMenu.AddMenuItem( GetString( StringTables.Default.LABEL_PLAYER_MENU_GROUP_INVITE ), PlayerMenuWindow.OnGroupInvite, disableGroupInvite, true, EA_Window_ContextMenu.CONTEXT_MENU_1 )
    
    -- Kick From Group
    EA_Window_ContextMenu.AddMenuItem( GetString( StringTables.Default.LABEL_PLAYER_MENU_GROUP_KICK ), PlayerMenuWindow.OnGroupKick, disableGroupKick, true, EA_Window_ContextMenu.CONTEXT_MENU_1 )

    -- Join Open Group
    EA_Window_ContextMenu.AddMenuItem( GetString( StringTables.Default.LABEL_PLAYER_MENU_GROUP_JOIN ), PlayerMenuWindow.OnGroupJoin, disableGroupJoin, true, EA_Window_ContextMenu.CONTEXT_MENU_1 )

    if( ( not targetSelf ) and 
        ( not GameData.Player.isInScenario and not GameData.Player.isInSiege ) and
        ( isGroupMember or isBattleGroupMember )
      )
    then
        local playerName = PlayerMenuWindow.curPlayer.name
        local player = nil
        if( isGroupMember )
        then
            player = GroupWindow.GetGroupMember( playerName )
        else
            player = BattlegroupHUD.GetWarbandMember( playerName )
        end
        
        if( not player )
        then
            ERROR(L"Invalid group / warband member")
            return
        end
        
		-- Summon Options
        local singleSummonInvSlot = DataUtils.HasRequiredSummoningStone( player.level )
		local disablePlayerSummon = GameData.Player.inCombat or singleSummonInvSlot == nil
		EA_Window_ContextMenu.AddMenuItem( GetString( StringTables.Default.LABEL_SUMMON_PLAYER ), PartyUtils.OnSummonPlayer, disablePlayerSummon, true, EA_Window_ContextMenu.CONTEXT_MENU_1 )
        
		-- Bolster Player (Make apprentice; only allow bolstering if the player is NOT a chicken)
		if( GameData.Player.isChicken == false )
		then
            if( player.level < GameData.Player.level ) -- Only allow bolster up
		    then
                local bolsterText, bolsterCallback = PartyUtils.GetBolsterMenuText( playerName )
                if( bolsterText and bolsterCallback )
                then
                    EA_Window_ContextMenu.AddMenuItem( bolsterText, bolsterCallback, false, true, EA_Window_ContextMenu.CONTEXT_MENU_1 )
                end
            end	
        end	
    end
    
end

function  PlayerMenuWindow.AddGuildMenuItems( targetSelf )

    -- If the player is not in a guild, do not add this section
    if( GameData.Guild.m_GuildName == L"" )
    then
        return
    end
   
    -- If the player is in a guild, check to see if they have invite permissions.
   	local localPlayerTitleNumber = GuildWindowTabAdmin.GetLocalMemberTitleNumber()
	local bCanInvitePlayersIntoGuild  = GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.INVITE, localPlayerTitleNumber)
    
    -- If the player doesn't have invite permission, do not add this section    
    if( bCanInvitePlayersIntoGuild == false )
    then
        return
    end
    
    local disableGuildInvite = GuildWindowTabRoster.IsPlayerInGuild( PlayerMenuWindow.curPlayer.name ) or (targetSelf == true)
    local disableGuildKick   = (not disableGuildInvite) or (targetSelf == true)
    
    EA_Window_ContextMenu.AddMenuDivider( EA_Window_ContextMenu.CONTEXT_MENU_1 )

    -- Invite player to Guild
    EA_Window_ContextMenu.AddMenuItem( GetString( StringTables.Default.LABEL_PLAYER_MENU_GUILD_INVITE ), PlayerMenuWindow.OnGuildInvite, disableGuildInvite, true, EA_Window_ContextMenu.CONTEXT_MENU_1 )
    
    -- Kick player from Guild
    EA_Window_ContextMenu.AddMenuItem( GetString( StringTables.Default.LABEL_PLAYER_MENU_GUILD_KICK ), PlayerMenuWindow.OnGuildKick, disableGuildKick, true, EA_Window_ContextMenu.CONTEXT_MENU_1 )

end


---------------------------------------------------------------------
-- Function Handlers
---------------------------------------------------------------------

function PlayerMenuWindow.OnTalk()  
    if( ButtonGetDisabledFlag(SystemData.ActiveWindow.name ) == true ) then
        return
    end
   
    local text = L"/tell "..PlayerMenuWindow.curPlayer.name..L" "
    EA_ChatWindow.SwitchChannelWithExistingText(text)
    PlayerMenuWindow.Done()
end

function PlayerMenuWindow.OnTarget()

end

function PlayerMenuWindow.OnAssist()
    SendChatText( L"/assist "..SystemData.UserInput.selectedGroupMember, L"" )
end

function PlayerMenuWindow.OnDuel() 
	SendChatText( L"/duel "..PlayerMenuWindow.curPlayer.name, L"" )
	PlayerMenuWindow.Done()
end

function PlayerMenuWindow.OnFollow()    
    if( ButtonGetDisabledFlag(SystemData.ActiveWindow.Name ) == true ) then
        return
    end

    SendChatText( L"/follow "..PlayerMenuWindow.curPlayer.name, L"" )
    PlayerMenuWindow.Done()
end

function PlayerMenuWindow.OnTrade() 
    if( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) == true ) then
        return
    else
        EA_Window_Trade.InitiateTradeWithCurrentTarget ( PlayerMenuWindow.curPlayer.name )
    end
    
    PlayerMenuWindow.Done()
end

function PlayerMenuWindow.OnTarget()
    -- Do nothing, targeting is handled with the game action.
end

function PlayerMenuWindow.OnGroupInvite()   
    if( ButtonGetDisabledFlag(SystemData.ActiveWindow.name ) == true ) then
        return
    end

    SendChatText( L"/invite "..PlayerMenuWindow.curPlayer.name, L"" )
    PlayerMenuWindow.Done()
end

function PlayerMenuWindow.OnGroupKick() 
    if( ButtonGetDisabledFlag(SystemData.ActiveWindow.name ) == true ) then
        return
    end
    
    SendChatText( L"/partyremove "..PlayerMenuWindow.curPlayer.name, L"" )
    PlayerMenuWindow.Done()
end

function PlayerMenuWindow.OnGroupJoin()
    if( ButtonGetDisabledFlag(SystemData.ActiveWindow.name ) == true ) then
        return
    end
    
    SendChatText( L"/join "..PlayerMenuWindow.curPlayer.name, L"" )
    PlayerMenuWindow.Done()
end

function PlayerMenuWindow.OnGuildInvite()
    if( ButtonGetDisabledFlag(SystemData.ActiveWindow.name ) == true ) then
        return
    end

    SendChatText( L"/guildinvite "..PlayerMenuWindow.curPlayer.name, L"" )
    PlayerMenuWindow.Done()
end

function PlayerMenuWindow.OnGuildKick()
    if( ButtonGetDisabledFlag(SystemData.ActiveWindow.name ) == true ) then
        return
    end

    SendChatText( L"/guildkick "..PlayerMenuWindow.curPlayer.name, L"" )
    PlayerMenuWindow.Done()
end

function PlayerMenuWindow.OnAddFriend()
    if( ButtonGetDisabledFlag(SystemData.ActiveWindow.name ) == true ) then
        return
    end

    SendChatText( L"/friendadd "..PlayerMenuWindow.curPlayer.name, L"" )
    PlayerMenuWindow.Done()
end

function PlayerMenuWindow.OnAddIgnore()
    if( ButtonGetDisabledFlag(SystemData.ActiveWindow.name ) == true ) then
        return
    end

    SendChatText( L"/ignoreadd "..PlayerMenuWindow.curPlayer.name, L"" )
    PlayerMenuWindow.Done()
end

function PlayerMenuWindow.OnReportSpam(wndGroupId, cursorX, cursorY)
    if (ButtonGetDisabledFlag(SystemData.ActiveWindow.name) == true)
    then
        return
    end
    
	if ReportText == nil then return end
    -- Do bunch of window/tab checks.  We want to make sure we're grabbing text from the
    -- correct chat window.
    local wndGroup = EA_ChatWindowGroups[wndGroupId]
    local activeTabId = wndGroup.activeTab
    local activeTabName = EA_ChatTabManager.GetTabName( wndGroup.Tabs[activeTabId].tabManagerId )
    
    local offendingMessage = towstring(LogDisplayGetStringFromCursorPos(activeTabName.."TextLog", cursorX, cursorY))
	local FormatedMessage = wstring.gsub(towstring(wstring.gsub(towstring(offendingMessage),L"<br>", L"")),L"\n", L"")

	local SearchInt = 0
	local SearchID = 0
	for i=1,TextLogGetNumEntries("Chat")-1 do

		local _, filterId, text = TextLogGetEntry( "Chat", i )
		text = text:match( L"%[.+%]+%[.+%]:(.+)")
		--if text == nil then continue end

		if string.find(tostring(ReportText),tostring(text)) then
		
		SearchInt = i
		SearchID = filterId

	
		end
	end

FinalTable = {}
FinalText = L""
ReportTable = {}
local counter = 1
	for a = 1, SearchInt do
		local timer, filterId, text = TextLogGetEntry( "Chat", a )
		if filterId == SearchID and (SearchID ~= 0)then 
		ReportTable[counter] = timer..text
		counter = counter+1
		end
	end


	for q = 0,3 do
	if ReportTable ~= nil then
	FinalTable[4-q] = ReportTable[#ReportTable-q]
	else
	FinalTable[1] = ReportText
	end
	end
	
	if #ReportTable == 0 then FinalTable[1] = ReportText end
	
	
	for q = 1,4 do
	if FinalTable[q] ~= nil then 
	FinalText = FinalText..towstring(L"\n"..towstring(FinalTable[q]))
	end
	end	
	
counter = 1
ReportTable2 = {}
	for b = SearchInt+1, TextLogGetNumEntries("Chat")-1 do
		local timer, filterId, text = TextLogGetEntry( "Chat", b )
		if filterId == SearchID and (counter <= 3) and (SearchID ~= 0) then 
		ReportTable2[counter] = timer..text
		counter = counter+1
		end
	end

	for q = 1,3 do
	if ReportTable2[q] ~= nil then 
	FinalText = FinalText..towstring(L"\n"..towstring(ReportTable2[q]))
	end
	end	

    HelpUtils.AutoReportGoldSeller(PlayerMenuWindow.curPlayer.name, FinalText)
    AddTemporaryIgnore(PlayerMenuWindow.curPlayer.name)
    PlayerMenuWindow.Done()
end

function PlayerMenuWindow.OnInspect()
    if( ButtonGetDisabledFlag(SystemData.ActiveWindow.name ) == true ) then
        return
    end

    SendPlayerInspectionRequest()
    PlayerMenuWindow.Done()
end

function PlayerMenuWindow.OnCancel()
    -- Do nothing, the menu will be closed automatically.
end