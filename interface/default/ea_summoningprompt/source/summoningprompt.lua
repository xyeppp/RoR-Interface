
EA_SummoningAcceptPrompt = {}

local g_autoDeclineTime = 0

-- OnInitialize Handler
function EA_SummoningAcceptPrompt.Initialize()
    
    WindowRegisterEventHandler( "EA_SummoningAcceptPrompt", SystemData.Events.PLAYER_COMBAT_FLAG_UPDATED, "EA_SummoningAcceptPrompt.OnPlayerCombatFlagUpdated" )    
    WindowRegisterEventHandler( "EA_SummoningAcceptPrompt", SystemData.Events.GROUP_UPDATED, "EA_SummoningAcceptPrompt.OnGroupUpdated")
    WindowRegisterEventHandler( "EA_SummoningAcceptPrompt", SystemData.Events.SUMMON_SHOW_PROMPT, "EA_SummoningAcceptPrompt.ShowPrompt" )
    WindowRegisterEventHandler( "EA_SummoningAcceptPrompt", SystemData.Events.L_BUTTON_DOWN_PROCESSED, "UseItemTargeting.OnLButtonProcessed")
    WindowRegisterEventHandler( "EA_SummoningAcceptPrompt", SystemData.Events.PLAYER_IS_BEING_THROWN, "EA_SummoningAcceptPrompt.OnPlayerCombatFlagUpdated" ) 
    
    
	LabelSetText("EA_SummoningAcceptPromptBoxTitleBarText", GetString( StringTables.Default.LABEL_SUMMONING_TITLE ) )
	LabelSetText("EA_SummoningAcceptPromptBoxText", GetString( StringTables.Default.TEXT_SUMMONING_PROMPT ) )
	ButtonSetText("EA_SummoningAcceptPromptBoxAcceptButton", GetString( StringTables.Default.TEXT_ACCEPT_SUMMON ) )
	ButtonSetText("EA_SummoningAcceptPromptBoxDeclineButton", GetString( StringTables.Default.TEXT_DECLINE_SUMMON ) )
	LabelSetText("EA_SummoningAcceptPromptBoxInCombatText", GetString( StringTables.Default.TEXT_SUMMON_IN_COMBAT ) )
	DefaultColor.SetLabelColor( "EA_SummoningAcceptPromptBoxInCombatText", DefaultColor.RED )
	
    WindowSetShowing("EA_SummoningAcceptPrompt", false)
    
end


-- Join Window
function EA_SummoningAcceptPrompt.ShowPrompt( summoner )
    
    local name = summoner.name
    local destination = summoner.destination
    
    local text = GetStringFormat( StringTables.Default.TEXT_SUMMONING_DESC, { name, destination } )
    
	LabelSetText("EA_SummoningAcceptPromptBoxName", text )
	
	WindowSetShowing("EA_SummoningAcceptPrompt", true)
	EA_SummoningAcceptPrompt.UpdateButtons()		
	
	g_autoDeclineTime = summoner.autoDeclineTime
	
	Sound.Play( Sound.WINDOW_OPEN )
end


function EA_SummoningAcceptPrompt.OnPlayerCombatFlagUpdated()
    if( WindowGetShowing( "EA_SummoningAcceptPrompt" ) )
    then
        EA_SummoningAcceptPrompt.UpdateButtons()
    end

end

function EA_SummoningAcceptPrompt.UpdateButtons()
	-- Disable the Accept Button if the player is in combat and show the description text.
	local flagValue = false
	if( GameData.Player.inCombat == true or GameData.Player.isBeingThrown == true )
	then
	    flagValue = true
	end
	
	ButtonSetDisabledFlag("EA_SummoningAcceptPromptBoxAcceptButton", flagValue )
    WindowSetShowing("EA_SummoningAcceptPromptBoxInCombatText", flagValue )
end

function EA_SummoningAcceptPrompt.OnGroupUpdated()
    if( WindowGetShowing( "EA_SummoningAcceptPrompt" ) )
    then
        WindowSetShowing("EA_SummoningAcceptPrompt", not isPlayerSolo )
    end
end

function EA_SummoningAcceptPrompt.UpdateAutoDeclineTime( timePassed ) 
	if( g_autoDeclineTime > 0 ) then		
		g_autoDeclineTime = g_autoDeclineTime - timePassed
		if( g_autoDeclineTime <= 0 ) then
			g_autoDeclineTime = 0
			EA_SummoningAcceptPrompt.OnDecline()
		end	
		
		local time = TimeUtils.FormatClock( g_autoDeclineTime )
		local text = GetStringFormat( StringTables.Default.TEXT_JOIN_SCENARIO_RESPOND_TIME, { time } )
		LabelSetText("EA_SummoningAcceptPromptBoxRespondTime", text )		
	end	
end

function EA_SummoningAcceptPrompt.OnAccept()
    if( ButtonGetDisabledFlag( "EA_SummoningAcceptPromptBoxAcceptButton" ) )
    then
        return
    end

    BroadcastEvent( SystemData.Events.SUMMON_ACCEPT )
    -- TODO: Might need to wait with closing the window until the server agrees    
    WindowSetShowing( "EA_SummoningAcceptPrompt", false )
    Sound.Play( Sound.WINDOW_CLOSE )
end


function EA_SummoningAcceptPrompt.OnDecline()
    BroadcastEvent( SystemData.Events.SUMMON_DECLINE ) 
    -- TODO: Might need to wait with closing the window until the server agrees
    WindowSetShowing("EA_SummoningAcceptPrompt", false)  
    Sound.Play( Sound.WINDOW_CLOSE )
end
