----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

DeathWindow = {}

DeathWindow.NUM_RESPAWN_LOCS = 2


DeathWindow.TOOLTIP_ANCHOR = { Point = "topright",	RelativeTo = "DeathWindow", RelativePoint = "topleft",	XOffset=5, YOffset=75 }

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

DeathWindow.autoRespawnTimer = 0
DeathWindow.autoRespawnLocation = L""

----------------------------------------------------------------
-- CharacterWindow Functions
----------------------------------------------------------------

-- OnInitialize Handler
function DeathWindow.Initialize()		
			
	WindowRegisterEventHandler( "DeathWindow", SystemData.Events.PLAYER_DEATH, "DeathWindow.OnPlayerDeath")
	WindowRegisterEventHandler( "DeathWindow", SystemData.Events.PLAYER_DEATH_CLEARED, "DeathWindow.Close")
    WindowRegisterEventHandler( "DeathWindow", SystemData.Events.KILLER_NAME_UPDATED, "DeathWindow.OnKillerUpdated")

	-- Label Text
	LabelSetText( "DeathWindowYouHaveBeen", GetString( StringTables.Default.LABEL_DEATH_WINDOW_YOU_HAVE_BEEN ) )
	LabelSetText( "DeathWindowKilled", GetString( StringTables.Default.LABEL_DEATH_WINDOW_KILLED ) )
	LabelSetText( "DeathWindowBy", GetString( StringTables.Default.LABEL_DEATH_WINDOW_BY ) )
	ButtonSetText( "DeathWindowRespawnButton", GetString( StringTables.Default.LABEL_DEATH_WINDOW_RESPAWN ) )
	
	--it's possible for someone to reload their UI when this window is open
	--without this they can't respawn until the full time is up
	if GameData.Player.hitPoints.current == 0
	then
		DeathWindow.OnPlayerDeath( GetTimeUntilAutoRespawn() )
	end
end

-- OnUpdate Handler
function DeathWindow.Update( timePassed )

	if( DeathWindow.autoRespawnTimer > 0 ) then
	
		DeathWindow.autoRespawnTimer = DeathWindow.autoRespawnTimer - timePassed
		
		if( DeathWindow.autoRespawnTimer <= 0 ) then					
			DeathWindow.Close()
		else
            local iMins = math.floor( (DeathWindow.autoRespawnTimer + 1) / 60 )
			local secs = wstring.format( L"%d", math.mod(DeathWindow.autoRespawnTimer + 1, 60) )
            
            local text
            if ( iMins > 0 )
            then
                local mins = wstring.format( L"%d", iMins )
                text = GetStringFormat( StringTables.Default.TEXT_AUTO_RESPAWN_IN_Y_MINS_Z_SECS, { mins, secs } ) 
            else
                text = GetStringFormat( StringTables.Default.TEXT_AUTO_RESPAWN_IN_Z_SECS, { secs } ) 
            end
			
			LabelSetText("DeathWindowAutoRespawnTimerText", text )
		end
	
	end
	
end

-- OnShutdown Handler
function DeathWindow.Shutdown()

end

function DeathWindow.Close()
	DeathWindow.respawnTimer = 0	
	WindowSetShowing("DeathWindow", false )
end

function DeathWindow.OnPlayerDeath(autoRespawnTime)

	-- If no respawn data is set, clear the window
	if( GameData.DeathRespawnData.Locations[1].name == L"" ) then
		WindowSetShowing( "DeathWindow", false )
		return
	end
	
	DeathWindow.autoRespawnTimer = autoRespawnTime
	DeathWindow.autoRespawnLocation = GameData.DeathRespawnData.Locations[GameData.DeathRespawnData.autoRespawnLocation].name


	LabelSetText( "DeathWindowPlayerName", L"" )

    
    LabelSetText("DeathWindowAutoRespawnTimerText", L"" )
	
	WindowSetShowing( "DeathWindowPlayerName", false )
	WindowSetShowing( "DeathWindowBy", false )
	WindowSetShowing( "DeathWindow", true )
end	

function DeathWindow.OnPlayerRespawn()
	
	if( ButtonGetDisabledFlag(SystemData.ActiveWindow.name) == true ) then
		return
	end
	
	local index = WindowGetId(SystemData.ActiveWindow.name)    
	
	-- Set the respawn location & trigger the Respawn
	GameData.DeathRespawnData.selectedId = GameData.DeathRespawnData.Locations[index].id 
	
	BroadcastEvent( SystemData.Events.RELEASE_CORPSE )	
	Sound.Play( Sound.BUTTON_CLICK )
    
    DeathWindow.Close()
end	

function DeathWindow.OnKillerUpdated()
    LabelSetText( "DeathWindowPlayerName", GameData.Player.killerName )
    WindowSetShowing( "DeathWindowPlayerName", GameData.Player.killerName ~= L"" )
    WindowSetShowing( "DeathWindowBy", GameData.Player.killerName ~= L"" )
end
