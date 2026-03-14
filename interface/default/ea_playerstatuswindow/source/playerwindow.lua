----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

PlayerWindow = {}
PlayerWindow.RelicOwnershipCount = 0
PlayerWindow.FADE_OUT_ANIM_DELAY = 2
PlayerWindow.KillingSpreeRemainingTime = 0
----------------------------------------------------------------
-- Local Variables

----------------------------------------------------------------

PlayerWindow.Settings = 
{
    alwaysShowHitPoints   = false,
    alwaysShowAPPoints    = false
}

PlayerWindow.RelicBonusText = {}
PlayerWindow.RelicBonusText [GameData.Pairing.GREENSKIN_DWARVES]    = { value = L"" }
PlayerWindow.RelicBonusText [GameData.Pairing.EMPIRE_CHAOS]         = { value = L"" }
PlayerWindow.RelicBonusText [GameData.Pairing.ELVES_DARKELVES]      = { value = L"" }

PlayerWindow.RelicBonusDetails = {}
PlayerWindow.RelicBonusDetails [GameData.Factions.DWARF]            = { owned = false }
PlayerWindow.RelicBonusDetails [GameData.Factions.GREENSKIN]        = { owned = false }
PlayerWindow.RelicBonusDetails [GameData.Factions.HIGH_ELF]         = { owned = false }
PlayerWindow.RelicBonusDetails [GameData.Factions.DARK_ELF]         = { owned = false }
PlayerWindow.RelicBonusDetails [GameData.Factions.EMPIRE]           = { owned = false }
PlayerWindow.RelicBonusDetails [GameData.Factions.CHAOS]            = { owned = false }

local bUnflagCountdownStarted = false
local rvrFlagStartTimer     = 0

local isMouseOverPortrait   = false
local isFadeIn              = false -- Was the last fade a fade in (true) or a fade out (false)
local fadeOutAnimationDelay = 0

local playerIsMainAssist	= false

local prevMoraleLevel       = 0
local prevHitpointLevel     = 1
local PLAYERWINDOW_TOOLTIP_ANCHOR = { Point = "bottom",  RelativeTo = "PlayerWindow", RelativePoint = "top",   XOffset = 0, YOffset = 0 }

local MoraleLevelSliceMap =
{
    [1]  = { slice = "Morale-Mini-1" },
    [2]  = { slice = "Morale-Mini-2" },
    [3]  = { slice = "Morale-Mini-3" },
    [4]  = { slice = "Morale-Mini-4" }
}

local c_MAX_BUFF_SLOTS      = 20
local c_BUFF_STRIDE         = 5

----------------------------------------------------------------
-- Local/Utility Functions
----------------------------------------------------------------

local function UpdateStatusContainerVisibility()
    local show = ( SystemData.Settings.GamePlay.preventHealthBarFade
                or GameData.Player.inAgro
                or isMouseOverPortrait
                or ( GameData.Player.hitPoints.current < GameData.Player.hitPoints.maximum )
                or ( GameData.Player.actionPoints.current < GameData.Player.actionPoints.maximum ) )
    local currentAlpha = WindowGetAlpha( "PlayerWindowStatusContainer" )
    
    if ( show )
    then
        fadeOutAnimationDelay = 0
        -- Status container should be shown. Fade it in (unless we're already in the process of fading it in)
        if ( ( currentAlpha == 0.0 ) or ( ( currentAlpha < 1.0 ) and not isFadeIn ) )
        then
            isFadeIn = true
            WindowSetShowing( "PlayerWindowStatusContainer", true )
            WindowStartAlphaAnimation( "PlayerWindowStatusContainer", Window.AnimationType.SINGLE_NO_RESET, currentAlpha, 1.0, 0.5, false, 0, 0 )
        end
    else
        -- Status container should be hidden. Fade it out (unless we're already in the process of fading it out, or already in the "delay" phase)
        if ( ( fadeOutAnimationDelay == 0 ) and ( ( currentAlpha == 1 ) or ( ( currentAlpha > 0.0 ) and isFadeIn ) ) )
        then
            fadeOutAnimationDelay = PlayerWindow.FADE_OUT_ANIM_DELAY
        end
    end
end

local function PlayerRealmOwnsRelic(relicFaction, status)
    
    if (relicFaction == GameData.Factions.DWARF) or (relicFaction == GameData.Factions.EMPIRE) or (relicFaction == GameData.Factions.HIGH_ELF)
    then
        if (GameData.Player.realm == GameData.Realm.ORDER) and (status == GameData.RelicStatuses.SECURE)
        then
            return true
        elseif (GameData.Player.realm == GameData.Realm.DESTRUCTION) and (status == GameData.RelicStatuses.CAPTURED)
        then
            return true
        end
    elseif (relicFaction == GameData.Factions.GREENSKIN) or (relicFaction == GameData.Factions.CHAOS) or (relicFaction == GameData.Factions.DARK_ELF)
    then
        if (GameData.Player.realm == GameData.Realm.DESTRUCTION) and (status == GameData.RelicStatuses.SECURE)
        then
            return true
        elseif (GameData.Player.realm == GameData.Realm.ORDER) and (status == GameData.RelicStatuses.CAPTURED)
        then
            return true
        end
    end
    
    return false
    
end

----------------------------------------------------------------
-- PlayerWindow Functions
----------------------------------------------------------------

-- OnInitialize Handler
function PlayerWindow.Initialize()

    -- Register this window for movement with the Layout Editor
    LayoutEditor.RegisterWindow( "PlayerWindow",
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_PLAYER_WINDOW_NAME ),
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_PLAYER_WINDOW_DESC ),
                                false, false,
                                true, nil )
    
    -- Register for Player Status updates       
    WindowRegisterEventHandler( "PlayerWindow", SystemData.Events.PLAYER_CUR_ACTION_POINTS_UPDATED, "PlayerWindow.UpdateCurrentActionPoints")
    WindowRegisterEventHandler( "PlayerWindow", SystemData.Events.PLAYER_MAX_ACTION_POINTS_UPDATED, "PlayerWindow.UpdateMaximumActionPoints")
    WindowRegisterEventHandler( "PlayerWindow", SystemData.Events.PLAYER_CUR_HIT_POINTS_UPDATED,    "PlayerWindow.UpdateCurrentHitPoints")
    WindowRegisterEventHandler( "PlayerWindow", SystemData.Events.PLAYER_MAX_HIT_POINTS_UPDATED,    "PlayerWindow.UpdateMaximumHitPoints")
    WindowRegisterEventHandler( "PlayerWindow", SystemData.Events.PLAYER_START_RVR_FLAG_TIMER,      "PlayerWindow.OnStartRvRFlagTimer")
    WindowRegisterEventHandler( "PlayerWindow", SystemData.Events.PLAYER_RVR_FLAG_UPDATED,          "PlayerWindow.OnRvRFlagUpdated")
    WindowRegisterEventHandler( "PlayerWindow", SystemData.Events.PLAYER_CAREER_RANK_UPDATED,       "PlayerWindow.UpdateCareerRank")
    WindowRegisterEventHandler( "PlayerWindow", SystemData.Events.PLAYER_CAREER_CATEGORY_UPDATED,   "PlayerWindow.UpdateAdvancementNag" )
    WindowRegisterEventHandler( "PlayerWindow", SystemData.Events.PLAYER_MORALE_UPDATED,            "PlayerWindow.OnMoraleUpdated")
    WindowRegisterEventHandler( "PlayerWindow", SystemData.Events.PLAYER_EFFECTS_UPDATED,           "PlayerWindow.OnEffectsUpdated")
    WindowRegisterEventHandler( "PlayerWindow", SystemData.Events.PLAYER_AGRO_MODE_UPDATED,         "PlayerWindow.OnAgroModeUpdated")
    WindowRegisterEventHandler( "PlayerWindow", SystemData.Events.PLAYER_KILLING_SPREE_UPDATED,     "PlayerWindow.KillingSpreeUpdated")
    WindowRegisterEventHandler( "PlayerWindow", SystemData.Events.PLAYER_HEALTH_FADE_UPDATED,       "PlayerWindow.UpdateBasedOnUserSettings")
    WindowRegisterEventHandler( "PlayerWindow", SystemData.Events.PLAYER_GROUP_LEADER_STATUS_UPDATED, "PlayerWindow.UpdateCrown")
    WindowRegisterEventHandler( "PlayerWindow", SystemData.Events.GROUP_UPDATED,                    "PlayerWindow.UpdateCrown")
    WindowRegisterEventHandler( "PlayerWindow", SystemData.Events.PLAYER_MAIN_ASSIST_UPDATED,		"PlayerWindow.UpdateMainAssist")
	WindowRegisterEventHandler( "PlayerWindow", SystemData.Events.PLAYER_BATTLE_LEVEL_UPDATED,		"PlayerWindow.UpdatePlayerLevel")
	WindowRegisterEventHandler( "PlayerWindow", SystemData.Events.ADVANCED_WAR_RELIC_UPDATE,        "PlayerWindow.UpdateRelicBonuses")
	
                
    -- Initially hide some of the arbitrary indicator widgets until updates are processed
    WindowSetShowing( "PlayerWindowMoraleMini", false )
    WindowSetShowing( "PlayerWindowAdvancementIndicator", false )
    WindowSetShowing( "PlayerWindowRenownIndicator", false )
    WindowSetShowing( "PlayerWindowGroupLeaderCrown", false )
    WindowSetShowing( "PlayerWindowWarbandLeaderCrown", false )
    WindowSetShowing( "PlayerWindowMainAssistCrown", false )
    WindowSetShowing( "PlayerWindowDeathPortrait", false )
    WindowSetShowing( "PlayerWindowKillingSpree", false )
    WindowSetShowing( "PlayerWindowRelicBonus", false )
    
    -- Hiding the AP Text Label until something is done about the font size:
    -- See corresponding note in PlayerWindow.UpdateAPTextLabel
    WindowSetShowing ("PlayerWindowStatusContainerAPText", false)
    
    -- Set up the (initially hidden) XP bonus display window in the killing spree widget.
    WindowSetTintColor( "PlayerWindowKillingSpreeBoxInner", 0, 0, 0 )
    WindowSetAlpha( "PlayerWindowKillingSpreeBoxInner", 0.6 )
    
    -- Boolean used by function PlayerWindow.KillingSpreeUpdated
    PlayerWindow.KillingSpreeIsShowing = false
    
    local buffAnchor = 
    {
        Point           = "bottomleft",
        RelativePoint   = "topleft",
        RelativeTo      = "PlayerWindow", 
        XOffset         = 100,
        YOffset         = -38,
    }   
    
    PlayerWindow.playerBuffs = BuffTracker:Create( "PlayerBuffs", "Root", buffAnchor, GameData.BuffTargetType.SELF, c_MAX_BUFF_SLOTS, c_BUFF_STRIDE, SHOW_BUFF_FRAME_TIMER_LABELS )
    
    PlayerWindow.UpdatePlayer()
    PlayerWindow.OnRvRFlagUpdated()
    PlayerWindow.UpdateCurrentHitPoints()
    PlayerWindow.UpdateMaximumHitPoints()
    PlayerWindow.UpdateCurrentActionPoints()
    PlayerWindow.UpdateMaximumActionPoints()
    PlayerWindow.OnMoraleUpdated(0, 0)
    PlayerWindow.UpdateAdvancementNag()
    PlayerWindow.UpdateMainAssist( nil )
    PlayerWindow.UpdateRelicBonuses()
end

-- OnShutdown Handler
function PlayerWindow.Shutdown()
    PlayerWindow.playerBuffs:Shutdown()
end

function PlayerWindow.OnShown()
    -- The Player Buffs window is anchored to the Player Status window but is not a child of it, therefore
    -- the window does not get shown when the Player Status window is shown. So we must do it manually.
    PlayerWindow.playerBuffs:Show( true )
end

function PlayerWindow.OnHidden()
    -- The Player Buffs window is anchored to the Player Status window but is not a child of it, therefore
    -- the window does not get hidden when the Player Status window is hidden. So we must do it manually.
    PlayerWindow.playerBuffs:Show( false )
end

-- Updates the player's current amount of available action points
function PlayerWindow.UpdateCurrentActionPoints()

    StatusBarSetCurrentValue( "PlayerWindowStatusContainerAPPercentBar", GameData.Player.actionPoints.current )
    PlayerWindow.UpdateAPTextLabel()
    UpdateStatusContainerVisibility()
end

-- Updates the maximum number of APs available to the player
function PlayerWindow.UpdateMaximumActionPoints()

    StatusBarSetMaximumValue( "PlayerWindowStatusContainerAPPercentBar", GameData.Player.actionPoints.maximum ) 
    PlayerWindow.UpdateAPTextLabel()   
        
end

function PlayerWindow.OnAgroModeUpdated()
    UpdateStatusContainerVisibility()
end

function PlayerWindow.KillingSpreeUpdated( stage, time, bonus )
    PlayerWindow.KillingSpreeTotalTime = time
    PlayerWindow.KillingSpreeRemainingTime = time

    if (time > 0) then
        if (PlayerWindow.KillingSpreeIsShowing == false) then
            PlayerWindow.KillingSpreeIsShowing = true
            
            -- fade in
            WindowSetShowing( "PlayerWindowKillingSpree", true )
            WindowStartAlphaAnimation( "PlayerWindowKillingSpree", Window.AnimationType.SINGLE_NO_RESET, 0.0, 1.0, 0.5, false, 0, 0 )
        end
        
        LabelSetText( "PlayerWindowKillingSpreeText", GetStringFormat( StringTables.Default.LABEL_KILLING_SPREE_XP_BONUS, {bonus} ) )
    end
    
    if (time <= 0 and PlayerWindow.KillingSpreeIsShowing) then
        -- Fade out
        WindowStartAlphaAnimation ( "PlayerWindowKillingSpree", Window.AnimationType.SINGLE_NO_RESET_HIDE, 1.0, 0.0, 2.0, false, 0, 0 )
        
        PlayerWindow.KillingSpreeIsShowing = false
    end

end

-- Updates the AP text label
function PlayerWindow.UpdateAPTextLabel()   
    -- This is disabled because there are no fonts small enough not to be cut-off by this miniscule window.
    -- Feel free to re-enable this label when the size of either the window or the font has been adjusted.
    --local apText = GameData.Player.actionPoints.current..L"/"..GameData.Player.actionPoints.maximum
    --LabelSetText( "PlayerWindowStatusContainerAPText", apText )
end

function PlayerWindow.UpdateAdvancementNag()

    -- Show an advancement arrow when the player has gained advance points
    local showNag = false;

    local pointsData = GameData.Player.GetAdvancePointsAvailable()
    
    -- DEBUG(L"PlayerWindow.UpdateAdvancementNag()")
    -- DUMP_TABLE(pointsData)
    -- DEBUG(L"-----------------------------------")
    
    for index, pointsLeft in pairs(pointsData) do
        if pointsLeft > 0 then
            showNag = true
            break
        end
    end
    
    WindowSetShowing("PlayerWindowAdvancementIndicator", showNag )
    
end

-- Updates the player's current amount of morale based on how many abilities
-- have been unlocked through morale gain
function PlayerWindow.OnMoraleUpdated( moralePercent, moraleLevel )

    -- If the morale level has changed, handle showing/hiding the window and
    -- displaying the appropriate texture slice for morale
    if( prevMoraleLevel ~= moraleLevel and moraleLevel ~= 0 ) then  
            DynamicImageSetTextureSlice( "PlayerWindowMoraleMini", MoraleLevelSliceMap[moraleLevel].slice )
            WindowSetShowing( "PlayerWindowMoraleMini", true )
    elseif( moraleLevel == 0) then
        -- Don't show the morale mini if there are no unlocked abilities
        if( WindowGetShowing("PlayerWindowMoraleMini") == true ) then
            WindowSetShowing( "PlayerWindowMoraleMini", false )
        end
    end
    
    -- Cache the determined morale level
    prevMoraleLevel = moraleLevel;

end

function PlayerWindow.OnEffectsUpdated( updatedEffects, isFullList )
    PlayerWindow.playerBuffs:UpdateBuffs( updatedEffects, isFullList )
end

-- Updates the player's current amount of available hit points
function PlayerWindow.UpdateCurrentHitPoints()

    local text = wstring.format(L"%d/%d", GameData.Player.hitPoints.current, GameData.Player.hitPoints.maximum)

    StatusBarSetCurrentValue( "PlayerWindowStatusContainerHealthPercentBar", GameData.Player.hitPoints.current )   
    
    if( GameData.Player.hitPoints.current == 0 ) then
        WindowSetShowing( "PlayerWindowDeathPortrait", true )
    else
        -- Only hide the death portrait when the player's hitpoints were last set to 0
        if( prevHitpointLevel == 0 ) then
            WindowSetShowing( "PlayerWindowDeathPortrait", false )
        end
        UpdateStatusContainerVisibility()
    end
    
    -- Cache the previous hitpoint level
    prevHitpointLevel = GameData.Player.hitPoints.current
    
    PlayerWindow.UpdateHealthTextLabel()
    
end

-- Updates the maximum number of HPs available to the player
function PlayerWindow.UpdateMaximumHitPoints()

    StatusBarSetMaximumValue( "PlayerWindowStatusContainerHealthPercentBar", GameData.Player.hitPoints.maximum ) 
    PlayerWindow.UpdateHealthTextLabel()
        
end

-- Updates the Health text label
function PlayerWindow.UpdateHealthTextLabel()   
    
    local healthText = GameData.Player.hitPoints.current..L"/"..GameData.Player.hitPoints.maximum
    LabelSetText( "PlayerWindowStatusContainerHealthText", healthText )
    
end

-- Opens the contextual right-click menu
function PlayerWindow.ShowMenu()
    
    local disableUnflag = true
    if (GameData.Player.rvrZoneFlagged == false and GameData.Player.rvrPermaFlagged == true) then
        if (bUnflagCountdownStarted == false) then
            disableUnflag = false
        end
    end
    
    EA_Window_ContextMenu.CreateContextMenu( "PlayerWindow" )
    EA_Window_ContextMenu.AddMenuItem( GetStringFromTable("HUDStrings", StringTables.HUD.LABEL_FLAG_PLAYER_RVR), PlayerWindow.OnMenuClickFlagRvR, GameData.Player.rvrZoneFlagged or GameData.Player.rvrPermaFlagged, true )
    EA_Window_ContextMenu.AddMenuItem( GetStringFromTable("HUDStrings", StringTables.HUD.LABEL_UNFLAG_PLAYER_RVR), PlayerWindow.OnMenuClickUnFlagRvR, disableUnflag, true )
    
    -- Show the "Leave Party" option if the player is currently in a player-made party
    if( ( GroupWindow.inWorldGroup or IsWarBandActive() ) and not GameData.Player.isInScenario and not GameData.Player.isInSiege ) then
        EA_Window_ContextMenu.AddMenuItem( GetString( StringTables.Default.LABEL_GROUP_OPTIONS ), EA_Window_OpenParty.OpenToManageTab, false, true, EA_Window_ContextMenu.CONTEXT_MENU_1 )
        EA_Window_ContextMenu.AddMenuItem( GetStringFromTable("HUDStrings", StringTables.HUD.LABEL_LEAVE_GROUP), PlayerWindow.OnMenuClickLeaveGroup, false, true )
        if ( GameData.Player.isGroupLeader )
        then
			SystemData.UserInput.selectedGroupMember = GameData.Player.name
			EA_Window_ContextMenu.AddMenuItem( GetString( StringTables.Default.LABEL_MAKE_MAIN_ASSIST ), GroupWindow.OnMakeMainAssist, playerIsMainAssist, true, EA_Window_ContextMenu.CONTEXT_MENU_1 )
        end
    end
    
    -- Show the "Leave Scenario Party" option if the player is in a scenario party
    if( GroupWindow.inScenarioGroup ) then
        EA_Window_ContextMenu.AddMenuItem( GetStringFromTable("HUDStrings", StringTables.HUD.LABEL_LEAVE_SCENARIO_GROUP), PlayerWindow.OnMenuClickLeaveScenarioGroup, false, true )        
    end
    
    EA_Window_ContextMenu.Finalize()

end

function PlayerWindow.OnMenuClickFlagRvR()
    SendChatText( L"/rvr", L"" )
end

function PlayerWindow.OnMenuClickUnFlagRvR()
    bUnflagCountdownStarted = true
    WindowStartAlphaAnimation( "PlayerWindowRvRFlagIndicator", Window.AnimationType.LOOP, 0.1, 1.0, 0.8, false, 0, 0 )
    SendChatText( L"/rvr", L"" )
end

function PlayerWindow.OnMenuClickLeaveGroup()
    BroadcastEvent( SystemData.Events.GROUP_LEAVE )
end

function PlayerWindow.OnMenuClickLeaveScenarioGroup()
    ScenarioGroupWindow.LeaveGroup()
end

-- OnUpdate Handler
function PlayerWindow.Update( timePassed )    
    
    if( bUnflagCountdownStarted == true and GameData.Player.rvrPermaFlagged == false) then
        bUnflagCountdownStarted = false
    end
    
    if( rvrFlagStartTimer > 0 ) then
    
        rvrFlagStartTimer = rvrFlagStartTimer - timePassed
        if( rvrFlagStartTimer < 0 ) then
            rvrFlagStartTimer = 0
        end
        
        local time = wstring.format(L"%.0f", rvrFlagStartTimer + 0.5)           
        local text = GetStringFormat( StringTables.Default.TEXT_ENTERED_RVR_AREA, { time } )
    
        LabelSetText("PlayerWindowRvRFlagCountDown", wstring.format(L"%.0f", rvrFlagStartTimer + 0.5) )
    end
    
    if (fadeOutAnimationDelay > 0) then
        if ( WindowGetAlpha( "PlayerWindowStatusContainer" ) == 1.0 ) -- Don't begin fade out delay until status container is fully shown
        then
            fadeOutAnimationDelay = fadeOutAnimationDelay - timePassed
            if ( fadeOutAnimationDelay <= 0 ) then
                fadeOutAnimationDelay = 0
                isFadeIn = false
                WindowStartAlphaAnimation ( "PlayerWindowStatusContainer", Window.AnimationType.SINGLE_NO_RESET_HIDE, 1.0, 0.0, 2.0, false, 0, 0 )
            end
        end
    end
    
    if( PlayerWindow.KillingSpreeRemainingTime > 0 ) then
        PlayerWindow.KillingSpreeRemainingTime = PlayerWindow.KillingSpreeRemainingTime - timePassed
        if( PlayerWindow.KillingSpreeRemainingTime <= 0 ) then
            PlayerWindow.KillingSpreeRemainingTime = 0
        end

        -- Starts at 12 o'clock and decreases clockwise
        local startFill = 360 * (1 - (PlayerWindow.KillingSpreeRemainingTime / PlayerWindow.KillingSpreeTotalTime))
        CircleImageSetFillParams( "PlayerWindowKillingSpreeArc", -96 + startFill,  360 - startFill ) 
    end
    
    PlayerWindow.playerBuffs:Update( timePassed )
end

function PlayerWindow.OnStartRvRFlagTimer( )
    
    rvrFlagStartTimer = 10
    WindowSetShowing( "PlayerWindowRvRFlagCountDown", true )
    WindowSetShowing( "PlayerWindowRvRFlagIndicator", true )
    WindowStartAlphaAnimation( "PlayerWindowRvRFlagIndicator", Window.AnimationType.LOOP, 0.1, 1.0, 0.5, false, 0, 0 )
    
end

function PlayerWindow.UpdateBasedOnUserSettings()
    UpdateStatusContainerVisibility()
end

function PlayerWindow.OnRvRFlagUpdated()

    WindowSetShowing( "PlayerWindowRvRFlagIndicator", GameData.Player.rvrPermaFlagged or GameData.Player.rvrZoneFlagged)
    
    if (bUnflagCountdownStarted == true) then
        if (GameData.Player.rvrPermaFlagged == false) then
            WindowStopAlphaAnimation( "PlayerWindowRvRFlagIndicator" )
            bUnflagCountdownStarted = false
        end
    else
        WindowStopAlphaAnimation( "PlayerWindowRvRFlagIndicator" )
    end
    WindowSetShowing( "PlayerWindowRvRFlagCountDown", false )

end

function PlayerWindow.OnMouseoverRvRIndicator()

    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, GetString( StringTables.Default.TOOLTIP_RVR_INDICATOR  ) )    
    Tooltips.AnchorTooltip( PLAYERWINDOW_TOOLTIP_ANCHOR )
end

function PlayerWindow.MouseOverLevel()
    local levelString = PartyUtils.GetLevelText( GameData.Player.level, GameData.Player.battleLevel )
	if( GameData.Player.level ~= GameData.Player.battleLevel )
	then
		Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )    
        
        -- If the player is bolstered by someone else, display some text clarifying this.
        local statusString = nil
        if( GetBolsterBuddy() )
        then
            statusString = GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_APPRENTICE )           
        end
        
		Tooltips.SetTooltipText( 1, 1, levelString )
        if( statusString )
        then
            Tooltips.SetTooltipText( 2, 1, statusString )
        end
        
		Tooltips.Finalize()
		Tooltips.AnchorTooltip( PLAYERWINDOW_TOOLTIP_ANCHOR )
	end
end

function PlayerWindow.UpdatePlayer()
    -- Name
    LabelSetText( "PlayerWindowPlayerName", GameData.Player.name )
    LabelSetTextColor( "PlayerWindowPlayerName", DefaultColor.NAME_COLOR_PLAYER.r, DefaultColor.NAME_COLOR_PLAYER.g, DefaultColor.NAME_COLOR_PLAYER.b )
    
    -- Level
	PlayerWindow.UpdatePlayerLevel()
    
    PlayerWindow.UpdateAdvancementNag()
    PlayerWindow.UpdateCrown()       
end

function PlayerWindow.UpdatePlayerLevel()
	local color = PartyUtils.GetLevelTextColor( GameData.Player.level, GameData.Player.battleLevel )
    LabelSetText( "PlayerWindowLevelText", L""..GameData.Player.battleLevel )
	LabelSetTextColor( "PlayerWindowLevelText", color.r, color.g, color.b )
	WindowSetShowing( "PlayerWindowLevelBackground", true )    
    WindowSetShowing( "PlayerWindowLevelText", true )
end

function PlayerWindow.UpdateMainAssist( showIcon )

	-- If the player is the main assist, hide/show the necessary crown
	local playerIsMainAssist = showIcon
	if( playerIsMainAssist == nil )
	then
		playerIsMainAssist = ( IsPlayerMainAssist() == 1 )
	end
    WindowSetShowing( "PlayerWindowMainAssistCrown", playerIsMainAssist )
end

function PlayerWindow.UpdateCrown()

    -- If the player is the Group Leader, hide/show the necessary crown
    WindowSetShowing("PlayerWindowGroupLeaderCrown", GameData.Player.isGroupLeader == true)

end

-- OnMouseOver Handler for hit points
function PlayerWindow.MouseoverHitPoints()
                
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, GetString( StringTables.Default.LABEL_HIT_POINTS ))
    Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
    Tooltips.SetTooltipText( 2, 1, GetString( StringTables.Default.TEXT_HP_BAR_DESC ))
    Tooltips.SetTooltipText( 3, 1, GetString( StringTables.Default.TEXT_STATUS_BAR_RIGHT_CLICK ))
    Tooltips.SetTooltipColorDef( 3, 1, Tooltips.COLOR_EXTRA_TEXT_DEFAULT )
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( PLAYERWINDOW_TOOLTIP_ANCHOR )
        
end

-- OnMouseOverEnd Handler for hit points
function PlayerWindow.MouseoverEndHitPoints()
    
end

-- OnRButtonUp Handler for hit points
function PlayerWindow.OnHitPointsRButtonUp()

    if( PlayerWindow.Settings.alwaysShowHitPoints ) then
        PlayerWindow.Settings.alwaysShowHitPoints = false
    else        
        PlayerWindow.Settings.alwaysShowHitPoints = true
    end

end

-- OnMouseOver Handler for action points
function PlayerWindow.MouseoverActionPoints()
                
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, GetString( StringTables.Default.LABEL_ACTION_POINTS ))
    Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
    Tooltips.SetTooltipText( 2, 1, GetString( StringTables.Default.TEXT_AP_BAR_DESC ))
    Tooltips.SetTooltipText( 3, 1, GetString( StringTables.Default.TEXT_STATUS_BAR_RIGHT_CLICK ))
    Tooltips.SetTooltipColorDef( 3, 1, Tooltips.COLOR_EXTRA_TEXT_DEFAULT )
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( PLAYERWINDOW_TOOLTIP_ANCHOR )
    
end

-- OnMouseOverEnd Handler for action points
function PlayerWindow.MouseoverEndActionPoints()
    
end

-- OnRButtonUp Handler for action points
function PlayerWindow.OnAPPointsRButtonUp()

    if( PlayerWindow.Settings.alwaysShowAPPoints ) then
        PlayerWindow.Settings.alwaysShowAPPoints = false
    else        
        PlayerWindow.Settings.alwaysShowAPPoints = true
    end
    
end

function PlayerWindow.OnLButtonDown()

    -- Handle L Button Down so clicks don't go through to the world..
    -- And target Self
    BroadcastEvent( SystemData.Events.TARGET_SELF )
    
end

function PlayerWindow.OnRButtonUp()

    PlayerWindow.ShowMenu()

end

function PlayerWindow.MouseOverPortrait()
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, GameData.Player.name )
    Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
    local levelString = PartyUtils.GetLevelText( GameData.Player.level, GameData.Player.battleLevel )
    Tooltips.SetTooltipText( 2, 1, GetStringFormat( StringTables.Default.LABEL_RANK_X, { levelString } ) )
    Tooltips.SetTooltipText( 3, 1, GetStringFormatFromTable("HUDStrings", StringTables.HUD.LABEL_HUD_PLAYER_WINDOW_TOOLTIP_CAREER_NAME, {GameData.Player.career.name}) )
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( PLAYERWINDOW_TOOLTIP_ANCHOR )
    
    isMouseOverPortrait = true
    UpdateStatusContainerVisibility()
end

function PlayerWindow.MouseOverPortraitEnd()
    isMouseOverPortrait = false
    UpdateStatusContainerVisibility()
end

--called when the local player levels up
function PlayerWindow.UpdateCareerRank()
    Sound.Play( Sound.ADVANCE_RANK )
    PlayerWindow.UpdatePlayer()
end

function PlayerWindow.UpdateRelicBonuses()

    relicData = GetRelicStatuses()
    
    PlayerWindow.RelicOwnershipCount = 0
    
    -- Cache the data to the window in a format that allows quick lookups for pairings
  if (relicData~=nil) then
    for index, data in ipairs( relicData ) 
    do	    
        local race          = relicData[index].race
        local status        = relicData[index].status
        
        PlayerWindow.RelicBonusDetails[race].owned = PlayerRealmOwnsRelic(race, status)        
    end	
  end
  
	-- Clear out old status text	
    PlayerWindow.RelicBonusText[GameData.Pairing.GREENSKIN_DWARVES].value = L""
    PlayerWindow.RelicBonusText[GameData.Pairing.EMPIRE_CHAOS].value = L""
    PlayerWindow.RelicBonusText[GameData.Pairing.ELVES_DARKELVES].value = L""
	
	-- Check pairing ownership
	if (PlayerWindow.RelicBonusDetails[GameData.Factions.DWARF].owned == true) and (PlayerWindow.RelicBonusDetails[GameData.Factions.GREENSKIN].owned == true)
	then
	    local relicDesc = GetStringFromTable("RvRCityStrings", StringTables.RvRCity.TEXT_RELIC_BONUS_GVD)
	    PlayerWindow.RelicOwnershipCount = PlayerWindow.RelicOwnershipCount + 1
        PlayerWindow.RelicBonusText[GameData.Pairing.GREENSKIN_DWARVES].value = PlayerWindow.RelicBonusText[GameData.Pairing.GREENSKIN_DWARVES].value .. L"- " .. relicDesc
	end
	
	if (PlayerWindow.RelicBonusDetails[GameData.Factions.EMPIRE].owned == true) and (PlayerWindow.RelicBonusDetails[GameData.Factions.CHAOS].owned == true)
	then
	    local relicDesc = GetStringFromTable("RvRCityStrings", StringTables.RvRCity.TEXT_RELIC_BONUS_EVC)
	    PlayerWindow.RelicOwnershipCount = PlayerWindow.RelicOwnershipCount + 1
        PlayerWindow.RelicBonusText[GameData.Pairing.EMPIRE_CHAOS].value = PlayerWindow.RelicBonusText[GameData.Pairing.EMPIRE_CHAOS].value .. L"- " .. relicDesc
	end
	
	if (PlayerWindow.RelicBonusDetails[GameData.Factions.HIGH_ELF].owned == true) and (PlayerWindow.RelicBonusDetails[GameData.Factions.DARK_ELF].owned == true)
	then
	    local relicDesc = GetStringFromTable("RvRCityStrings", StringTables.RvRCity.TEXT_RELIC_BONUS_ELF)
	    PlayerWindow.RelicOwnershipCount = PlayerWindow.RelicOwnershipCount + 1
        PlayerWindow.RelicBonusText[GameData.Pairing.ELVES_DARKELVES].value = PlayerWindow.RelicBonusText[GameData.Pairing.ELVES_DARKELVES].value .. L"- " .. relicDesc        
	end
		
	if(PlayerWindow.RelicOwnershipCount > 0)
	then
	    WindowSetShowing("PlayerWindowRelicBonus", true)
	else
        WindowSetShowing("PlayerWindowRelicBonus", false)
	end
	
end

function PlayerWindow.MouseOverRelicBonus()

    if(PlayerWindow.RelicOwnershipCount < 1)
    then
        return
    end
        
    Tooltips.CreateTextOnlyTooltip(SystemData.ActiveWindow.name)
    
    Tooltips.SetTooltipText(1, 1, GetStringFromTable("RvRCityStrings", StringTables.RvRCity.TEXT_RELIC_BONUS)) 
    local currentLine = 2
    
    if(wstring.len(PlayerWindow.RelicBonusText[GameData.Pairing.GREENSKIN_DWARVES].value) > 1)
    then
        Tooltips.SetTooltipText(currentLine, 1, PlayerWindow.RelicBonusText[GameData.Pairing.GREENSKIN_DWARVES].value) 
        currentLine = currentLine + 1
    end
    
    if(wstring.len(PlayerWindow.RelicBonusText[GameData.Pairing.EMPIRE_CHAOS].value) > 1)
    then
        Tooltips.SetTooltipText(currentLine, 1, PlayerWindow.RelicBonusText[GameData.Pairing.EMPIRE_CHAOS].value) 
        currentLine = currentLine + 1
    end
    
    if(wstring.len(PlayerWindow.RelicBonusText[GameData.Pairing.ELVES_DARKELVES].value) > 1)
    then
        Tooltips.SetTooltipText(currentLine, 1, PlayerWindow.RelicBonusText[GameData.Pairing.ELVES_DARKELVES].value) 
        currentLine = currentLine + 1
    end
        
	Tooltips.Finalize()
	Tooltips.AnchorTooltip(PLAYERWINDOW_TOOLTIP_ANCHOR)
	
end