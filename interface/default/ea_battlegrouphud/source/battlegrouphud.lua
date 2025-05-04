----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

BattlegroupHUD = {}
BattlegroupHUD.version = 1.2
BattlegroupHUD.NUM_GROUPS = 4
BattlegroupHUD.PLAYERS_PER_GROUP = 6
BattlegroupHUD.needsRefresh = false

BattlegroupHUD.WindowSettings = {}

----------------------------------------------------------------
-- Local Functions
----------------------------------------------------------------

--
-- Window name "constant" functions
--

local function GetGroupWndName(groupIndex)
    return "BattlegroupHUDGroup"..groupIndex.."LayoutWindow"
end

local function GetMemberWndName(groupIndex, memberIndex)
    local groupWndName = GetGroupWndName(groupIndex)
    return groupWndName.."Member"..memberIndex
end

--
-- Misc window name functions
--

local function GetGroupByWndName(wndName)
    for groupIndex = 1, BattlegroupHUD.NUM_GROUPS do
        -- Compare substrings to take non-parent windows into account
        -- NOTE: This won't work if we ever put more than 9 groups in the window, which is very unlikely but who knows!
        local groupWndName = GetGroupWndName(groupIndex)
        local groupWndNameLen = string.len(groupWndName)
        if ( string.len(wndName) >= groupWndNameLen and string.sub(wndName, 1, groupWndNameLen) == groupWndName ) then
            return groupIndex
        end
    end
    return 0
end

local function GetMemberByWndName(wndName)
    local groupIndex = GetGroupByWndName(wndName)
    if ( groupIndex == 0 ) then
        return 0, 0
    end
    for memberIndex = 1, BattlegroupHUD.PLAYERS_PER_GROUP do
        -- Compare substrings to take non-parent windows into account
        -- NOTE: This won't work if we ever put more than 9 members in one group, which is very unlikely but who knows!
        local memberWndName = GetMemberWndName(groupIndex, memberIndex)
        local memberWndNameLen = string.len(memberWndName)
        if ( string.len(wndName) >= memberWndNameLen and string.sub(wndName, 1, memberWndNameLen) == memberWndName ) then
            return groupIndex, memberIndex
        end
    end
    return 0, 0
end
----------------------------------------------------------------
-- BattlegroupHUD Functions
----------------------------------------------------------------

function BattlegroupHUD.Initialize()
                                
    -- Setup components
    for groupIndex = 1, BattlegroupHUD.NUM_GROUPS do
        local groupLayoutWindow = GetGroupWndName(groupIndex)
        -- Register this window for movement with the Layout Editor
        LayoutEditor.RegisterWindow( groupLayoutWindow,  
                                GetFormatStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_WB_MEMBERS_NAME, { groupIndex } ),
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_WB_MEMBERS_DESC),
                                false, false,
                                true, nil )
                                
        for memberIndex = 1, BattlegroupHUD.PLAYERS_PER_GROUP do
            
            local memberWindow = GetMemberWndName(groupIndex, memberIndex)
            StatusBarSetMaximumValue( memberWindow.."HPBar", 100 )
            StatusBarSetMaximumValue( memberWindow.."APBar", 100 )  
            WindowSetShowing( memberWindow.."DeathIcon", false )                 
            
        end
        
    end
    
    CreateWindowFromTemplate( "BattlegroupHUDSetOpacityWindow", "BattlegroupHUDSetOpacityWindow", "Root" )
    WindowSetShowing( "BattlegroupHUDSetOpacityWindow", false )
    LabelSetText( "BattlegroupHUDSetOpacityWindowTitleBarText", GetString( StringTables.Default.LABEL_OPACITY ) )
    
    -- Restore saved background alpha setting
    if( BattlegroupHUD.WindowSettings.backgroundAlpha )
    then
        BattlegroupHUD.SetBackgroundAlpha( BattlegroupHUD.WindowSettings.backgroundAlpha )
    end
    
    
    RegisterEventHandler( SystemData.Events.SCENARIO_BEGIN, "BattlegroupHUD.OnScenarioBegin" )
    RegisterEventHandler( SystemData.Events.CITY_SCENARIO_BEGIN, "BattlegroupHUD.OnScenarioBegin" )
    RegisterEventHandler( SystemData.Events.SCENARIO_END, "BattlegroupHUD.OnScenarioEnd" )
    RegisterEventHandler( SystemData.Events.CITY_SCENARIO_END, "BattlegroupHUD.OnScenarioEnd" )
    RegisterEventHandler( SystemData.Events.BATTLEGROUP_UPDATED, "BattlegroupHUD.Update" )
    RegisterEventHandler( SystemData.Events.BATTLEGROUP_MEMBER_UPDATED, "BattlegroupHUD.SingleMemberUpdate" )
    
    
    BattlegroupHUD.Hide()
    BattlegroupHUD.Update()
end

function BattlegroupHUD.OnScenarioBegin()
    -- Hide the battlegroup window when in a scenario or city scenario
    if( GameData.Player.isInScenario or GameData.Player.isInSiege ) then
        BattlegroupHUD.Hide()
    end
end

function BattlegroupHUD.OnScenarioEnd()
    -- Hide the BattlegroupHUD until the next update comes through after a scenario ends
    BattlegroupHUD.Hide()
    BattlegroupHUD.Update()
end

function BattlegroupHUD.OnRButtonUp()

    -- Remember the window clicked on, so we know where to pop the opacity slider
    BattlegroupHUD.contextMenuOpenedFrom = SystemData.ActiveWindow.name
    
    -- Show the player context-driven menu when right-clicking on warband members
    local groupIndex, memberIndex = GetMemberByWndName(SystemData.ActiveWindow.name)
    if ( groupIndex == 0 or memberIndex == 0 ) then
        return
    end
    
    local player = PartyUtils.GetWarbandMember( groupIndex, memberIndex )
    if( player == nil or player.name == nil or player.name == L"" )
    then
        return
    end
    
    BattlegroupHUD.ShowMenu( player.name, not player.online )
    
end

function BattlegroupHUD.Hide()
    for idx=1, BattlegroupHUD.NUM_GROUPS
    do
        LayoutEditor.Hide( GetGroupWndName(idx) )
    end
    GroupWindow.ConditionalShow()
end

function BattlegroupHUD.OnUpdate(elapsedTime)
    if ( BattlegroupHUD.needsRefresh == true )
    then
	    BattlegroupHUD.needsRefresh = false
	    
	    local somethingShowing = false
	    
	    if( GameData.Player.isInScenario or GameData.Player.isInSiege )
		then
			BattlegroupHUD.Hide()
			return
		end
	    
		for groupIndex = 1, BattlegroupHUD.NUM_GROUPS do
	        
			local groupWindow = GetGroupWndName( groupIndex )
			local warbandParty = PartyUtils.GetWarbandParty( groupIndex )
			local numMembers = table.getn( warbandParty.players )
	        
			local showParty = true
			if( EA_Window_OpenPartyManage ~= nil )
			then
				showParty = ButtonGetPressedFlag( "EA_Window_OpenPartyManageWarband"..groupIndex.."Show" )
			end
	        
			if ( showParty and numMembers >= 1 )
			then
	                
				-- This group has members and the user has selected for it to be displayed.
				somethingShowing = true
				LayoutEditor.Show( groupWindow )
	            
				local foundLeader = false
				local foundMainAssist = false
	            
				for memberIndex = 1, BattlegroupHUD.PLAYERS_PER_GROUP do
	                
					local memberWindow = groupWindow.."Member"..memberIndex
	                
					if ( numMembers >= memberIndex ) then
	                    
						-- There is a member in this slot.
						WindowSetShowing( memberWindow, true )
	                    
						local member = BattlegroupHUD.SingleMemberUpdate( groupIndex, memberIndex )
						if( member and member.isGroupLeader )
						then
							foundLeader = true
						end
						if( member and member.isMainAssist )
						then
							foundMainAssist = true
						end

					else
						-- There isn't a member in this slot.
						WindowSetShowing( memberWindow, false )
	                    
					end
	                
				end
	            
				WindowSetShowing( groupWindow.."GroupLeaderIcon", foundLeader )
				WindowSetShowing( groupWindow.."MainAssistIcon", foundMainAssist )
	            
			else
	            
				-- This group has no members, or the user has disabled its display.
				LayoutEditor.Hide( groupWindow )
	            
			end
	        
		end
	    
		if( somethingShowing )
		then
			GroupWindow.ConditionalShow()
		end
    end
end

function BattlegroupHUD.Update()

    BattlegroupHUD.needsRefresh = true
    groupWindow = GetGroupWndName( 1 )
    LayoutEditor.Show( groupWindow )
end

function BattlegroupHUD.SingleMemberUpdate( partyIndex, memberIndex )

    local member = PartyUtils.GetWarbandMember( partyIndex, memberIndex )
    if( member == nil )
    then
        return
    end
    
    local groupWindow = GetGroupWndName( partyIndex )
    local memberWindow = groupWindow.."Member"..memberIndex
    
    LabelSetText( memberWindow.."LabelName", member.name )
    WindowSetGameActionData( memberWindow, GameData.PlayerActions.SET_TARGET, 0, member.name )

    LabelSetText( memberWindow.."LabelHealth", member.healthPercent..L"%" )
    local texture, x, y = GetIconData( Icons.GetCareerIconIDFromCareerLine( member.careerLine ) )
    DynamicImageSetTexture( memberWindow.."CareerIcon", texture, x, y )
    -- \TODO: Eventually when the UI preferences window is in the game, the user will
    -- be able to set if he/she wants the changes below to take place at specific
    -- health intervals or not
    local isDead = false

    if( not member.online )
    then
        LabelSetText( memberWindow.."LabelHealth", GetString( StringTables.Default.LABEL_PARTY_MEMBER_OFFLINE ) )
        BattlegroupHUD.AdjustStatusSettings( memberWindow, DefaultColor.HEALTH_TEXT_DEAD, 0.5, false )
    elseif( member.healthPercent >= 100 and member.actionPointPercent >= 100 )
    then
        BattlegroupHUD.AdjustStatusSettings( memberWindow, DefaultColor.HEALTH_TEXT_FULL, 0.5, false )
    elseif( member.healthPercent > 0 )
    then
        BattlegroupHUD.AdjustStatusSettings( memberWindow, DefaultColor.HEALTH_TEXT_NOT_FULL, 1.0, true )
    else
        BattlegroupHUD.AdjustStatusSettings( memberWindow, DefaultColor.HEALTH_TEXT_DEAD, 1.0, false )
        isDead = true
    end
	
	if( member.isDistant and member.online and not isDead )
    then
        LabelSetText( memberWindow.."LabelHealth", GetString( StringTables.Default.LABEL_PARTY_MEMBER_IS_DISTANT ) )
        BattlegroupHUD.AdjustStatusSettings( memberWindow, DefaultColor.HEALTH_TEXT_DEAD, 0.5, false )
	end

    if( isDead )
    then
        WindowSetShowing( memberWindow.."DeathIcon", true )
        LabelSetText( memberWindow.."LabelHealth", GetString( StringTables.Default.LABEL_PLAYER_DEAD_ALLCAPS ) )
        LabelSetTextColor( memberWindow.."LabelName", DefaultColor.HEALTH_TEXT_DEAD.r, DefaultColor.HEALTH_TEXT_DEAD.g, DefaultColor.HEALTH_TEXT_DEAD.b )
    elseif( StatusBarGetCurrentValue(memberWindow.."HPBar") == 0 )
    then
        -- Only change these settings if the player was previously dead
        WindowSetShowing( memberWindow.."DeathIcon", false )
        LabelSetTextColor( memberWindow.."LabelName", DefaultColor.NAME_COLOR_PLAYER.r, DefaultColor.NAME_COLOR_PLAYER.g, DefaultColor.NAME_COLOR_PLAYER.b )
    end

    -- Set the current health/AP values
    StatusBarSetCurrentValue( memberWindow.."HPBar", member.healthPercent )
    StatusBarSetCurrentValue( memberWindow.."APBar", member.actionPointPercent )

    -- Set name color based on rvr status
    if( member.isRVRFlagged )
    then
        LabelSetTextColor( memberWindow.."LabelName", DefaultColor.YELLOW.r, DefaultColor.YELLOW.g, DefaultColor.YELLOW.b )
    else
        LabelSetTextColor( memberWindow.."LabelName", DefaultColor.NAME_COLOR_PLAYER.r, DefaultColor.NAME_COLOR_PLAYER.g, DefaultColor.NAME_COLOR_PLAYER.b )
    end

    if( member.isGroupLeader )
    then
        WindowClearAnchors( groupWindow.."GroupLeaderIcon" )
        WindowAddAnchor( groupWindow.."GroupLeaderIcon", "top", memberWindow.."LabelName", "bottom", 0, 2 )
    end

    -- It is not optimal to check these things here, since this function is run all the time.
    -- Group status like main assist, leader and  master looter should all be handled in a group update
    -- that is called only when a status changes or the member population of the group changes
    if( member.isMainAssist )
    then
        WindowClearAnchors( groupWindow.."MainAssistIcon" )
        WindowAddAnchor( groupWindow.."MainAssistIcon", "right", memberWindow, "center", 0, 0 )
    end
    
    return member
end

function BattlegroupHUD.AdjustStatusSettings( memberWindow, color, alpha, showBar )

    LabelSetTextColor( memberWindow.."LabelHealth", color.r, color.g, color.b )
    WindowSetFontAlpha( memberWindow.."LabelHealth", alpha )
    WindowSetShowing( memberWindow.."HPBar", showBar )
    WindowSetShowing( memberWindow.."APBar", showBar )
    
end

function BattlegroupHUD.OnShown()
end

function BattlegroupHUD.OnHidden()

end

function BattlegroupHUD.OnLButtonUpPlayerRow()
    -- Targeting is handled by the WindowSetGameActionData() call.
    if( GetDesiredInteractAction() == SystemData.InteractActions.TELEPORT )
    then
        UseItemTargeting.SendTeleport()
    end
end

function BattlegroupHUD.OnMenuClickSetBackgroundOpacity()

    if( not BattlegroupHUD.contextMenuOpenedFrom )
    then
        return
    end
    
    local alpha = WindowGetAlpha( BattlegroupHUD.contextMenuOpenedFrom.."Background" )
    SliderBarSetCurrentPosition( "BattlegroupHUDSetOpacityWindowSlider", alpha )

    -- Anchor the slider to the right of the clicked on member window
    WindowClearAnchors( "BattlegroupHUDSetOpacityWindow" )
    WindowAddAnchor( "BattlegroupHUDSetOpacityWindow", "right", BattlegroupHUD.contextMenuOpenedFrom, "left", 0, 0 )

    WindowSetShowing( "BattlegroupHUDSetOpacityWindow", true )
end

function BattlegroupHUD.OnOpacitySlide( slidePos )
    BattlegroupHUD.WindowSettings.backgroundAlpha = slidePos
    BattlegroupHUD.SetBackgroundAlpha( slidePos )
end

function BattlegroupHUD.SetBackgroundAlpha( alpha )

    for groupIndex = 1, BattlegroupHUD.NUM_GROUPS
    do
        for memberIndex = 1, BattlegroupHUD.PLAYERS_PER_GROUP
        do
            local memberWindow = GetMemberWndName(groupIndex, memberIndex)
            WindowSetAlpha( memberWindow.."Background", alpha )
        end
    end

end

function BattlegroupHUD.CloseSetOpacityWindow()
    WindowSetShowing( "BattlegroupHUDSetOpacityWindow", false )
end

function BattlegroupHUD.OnMenuClickLeaveGroup()
    BroadcastEvent( SystemData.Events.GROUP_LEAVE )
end

function BattlegroupHUD.OnMenuClickMakeLeader()    
    SendChatText( L"/warbandleader "..SystemData.UserInput.selectedGroupMember, L"" )
end

function BattlegroupHUD.OnMenuClickMakeMainAssist()    
    if( ButtonGetDisabledFlag(SystemData.ActiveWindow.name ) == true ) then
        return
    end
    
    BroadcastEvent( SystemData.Events.GROUP_SET_MAIN_ASSIST )    
end

function BattlegroupHUD.OnMenuClickTellMember()
    local text = L"/tell "..SystemData.UserInput.selectedGroupMember..L" "
    EA_ChatWindow.SwitchChannelWithExistingText(text)
end

function BattlegroupHUD.OnMenuClickTargetMember()
    SendChatText( L"/target "..SystemData.UserInput.selectedGroupMember, L"" )
end

function BattlegroupHUD.OnMenuClickAssistMember()
    SendChatText( L"/assist "..SystemData.UserInput.selectedGroupMember, L"" )
end

-- Opens the contextual right-click menu
function BattlegroupHUD.ShowMenu( playerName, isOffline )

    SystemData.UserInput.selectedGroupMember = playerName

	local isPlayerSelf = WStringsCompareIgnoreGrammer( playerName, GameData.Player.name ) == 0
    
    -- Build the Custom Section of the Player Menu    
    local customMenuItems = {}            
    
    -- Opacity Slider
    table.insert( customMenuItems, PlayerMenuWindow.NewCustomItem( GetString( StringTables.Default.LABEL_SET_OPACITY ), BattlegroupHUD.OnMenuClickSetBackgroundOpacity, false ))

    -- Loot Options
    table.insert( customMenuItems, PlayerMenuWindow.NewCustomItem( GetString( StringTables.Default.LABEL_GROUP_OPTIONS ), EA_Window_OpenParty.OpenToManageTab, false ))
    
    -- Show the "Make Leader" option if the player is a group leader
    local disableMakeLeader = isPlayerSelf or isOffline
    if( GameData.Player.isGroupLeader ) then
        table.insert( customMenuItems, PlayerMenuWindow.NewCustomItem( GetString( StringTables.Default.LABEL_MAKE_LEADER ), BattlegroupHUD.OnMenuClickMakeLeader, disableMakeLeader ))
    end
    
    -- Main Assist
    local mainAssistMember = PartyUtils.GetWarbandMainAssist()
    if( GameData.Player.isGroupLeader or ( mainAssistMember ~= nil and WStringsCompareIgnoreGrammer( mainAssistMember.name, GameData.Player.name ) == 0 )  )
    then
        local disableMainAssist = ( mainAssistMember ~= nil and WStringsCompareIgnoreGrammer( mainAssistMember.name, playerName ) == 0 ) or isOffline
        table.insert( customMenuItems, PlayerMenuWindow.NewCustomItem( GetString( StringTables.Default.LABEL_MAKE_MAIN_ASSIST ), BattlegroupHUD.OnMenuClickMakeMainAssist, disableMainAssist ))
    end
	
    -- Show the "Leave Party" option if the player is currently in a player-made party
    if( GroupWindow.inWorldGroup or IsWarBandActive() ) then
        table.insert( customMenuItems, PlayerMenuWindow.NewCustomItem( GetStringFromTable("HUDStrings", StringTables.HUD.LABEL_LEAVE_GROUP), BattlegroupHUD.OnMenuClickLeaveGroup, false ))
    end
  
     -- Create the Menu
    PlayerMenuWindow.ShowMenu( playerName, 0, customMenuItems ) 

end

function BattlegroupHUD.OnMouseOverCareerIcon()

    local groupIndex, memberIndex = GetMemberByWndName( SystemData.ActiveWindow.name )
    if ( groupIndex == 0 or memberIndex == 0 ) then
        return
    end

    local player = PartyUtils.GetWarbandMember( groupIndex, memberIndex )
    if ( player == nil ) then
        return
    end

    local levelString = PartyUtils.GetLevelText( player.level, player.battleLevel )
    
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, player.name )
    Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
    Tooltips.SetTooltipText( 2, 1, GetStringFormat( StringTables.Default.LABEL_RANK_X, { levelString } ) )
    Tooltips.SetTooltipText( 3, 1, GetStringFormatFromTable("HUDStrings", StringTables.HUD.LABEL_HUD_PLAYER_WINDOW_TOOLTIP_CAREER_NAME, {player.careerName}) )
    Tooltips.SetTooltipText( 4, 1, GetZoneName( player.zoneNum ) )
    if( player.isRVRFlagged )
    then
        Tooltips.SetTooltipText( 5, 1, GetStringFromTable("HUDStrings", StringTables.HUD.LABEL_PLAYER_IS_RVR_FLAGGED) )
    end
    Tooltips.Finalize()
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_VARIABLE )
end

function BattlegroupHUD.GetWarbandMember( playerName )
    for groupIndex = 1, BattlegroupHUD.NUM_GROUPS
    do
        for memberIndex = 1, BattlegroupHUD.PLAYERS_PER_GROUP
        do
            local member = PartyUtils.GetWarbandMember( groupIndex, memberIndex )
            if( (member ~= nil) and (member.name == playerName) )
            then
                return member
            end
        end
    end
    return nil
end
