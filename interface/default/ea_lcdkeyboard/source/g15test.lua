EA_LCDKeyboard = {}
----------------------------------------------------------------
-- The File Contains some test G15 Functionality.
----------------------------------------------------------------

EA_LCDKeyboard.Page0 = "Page0"
EA_LCDKeyboard.Page1 = "Page1"
EA_LCDKeyboard.Page2 = "Page2"
EA_LCDKeyboard.Page3 = "Page3"
EA_LCDKeyboard.Page4 = "Page4"

function EA_LCDKeyboard.Initialize()
	-------------------------------------
	-- Screen 0 (Startup / Server Queue)
	-------------------------------------
	
	LCDCreatePage( EA_LCDKeyboard.Page0 )

	LCDCreateBitmap( EA_LCDKeyboard.Page0, "Logo" )
	LCDBitmapSetImage( EA_LCDKeyboard.Page0, "Logo", "Textures/LCDLogo.bmp", true )
	LCDCreateStaticText( EA_LCDKeyboard.Page0, "Title", 1, "center", 160 - 36, 2 )
	LCDSetLocation( EA_LCDKeyboard.Page0, "Title", 36, 0 )
	LCDSetSize( EA_LCDKeyboard.Page0, "Title", 160 - 36, 27 )
	local title = GetStringFromTable( "LCDStrings", StringTables.LCDStrings.GAME_TITLE )..L"\n"..GetStringFromTable( "LCDStrings", StringTables.LCDStrings.GAME_SUBTITLE )
	LCDStaticTextSetText( EA_LCDKeyboard.Page0, "Title", title )
	LCDCreateStaticText( EA_LCDKeyboard.Page0, "Status", 1, "center", 160 - 36, 1 )
	LCDSetLocation( EA_LCDKeyboard.Page0, "Status", 36, 30 )

	-- Update the server queue
	LCDRegisterEventHandler( EA_LCDKeyboard.Page0, SystemData.Events.CHARACTER_QUEUE_UPDATED, "EA_LCDKeyboard.UpdateServerQueueStatus" )
	
	LCDShowPage(EA_LCDKeyboard.Page0)
	
	-------------------------------------
	-- Screen 1 (Character Info)
	-------------------------------------
	LCDCreatePage( EA_LCDKeyboard.Page1 )

	-- HP
	LCDCreateStaticText( EA_LCDKeyboard.Page1, "HPTitle", 1, "left", 30, 1 )
	LCDSetLocation( EA_LCDKeyboard.Page1, "HPTitle", 0, 0 )
	LCDStaticTextSetText( EA_LCDKeyboard.Page1, "HPTitle", GetStringFromTable( "LCDStrings", StringTables.LCDStrings.HIT_POINT_TITLE ) )
	LCDCreateProgressBar( EA_LCDKeyboard.Page1, "HP", "filled", 0, 100 )
	LCDSetLocation( EA_LCDKeyboard.Page1, "HP", 30, 0 )
	LCDSetSize( EA_LCDKeyboard.Page1, "HP", 130, 9 )

	-- AP
	LCDCreateStaticText( EA_LCDKeyboard.Page1, "APTitle", 1, "left", 30, 1 )
	LCDSetLocation( EA_LCDKeyboard.Page1, "APTitle", 0, 11 )
	LCDStaticTextSetText( EA_LCDKeyboard.Page1, "APTitle", GetStringFromTable( "LCDStrings", StringTables.LCDStrings.ACTION_POINT_TITLE ) )
	LCDCreateProgressBar( EA_LCDKeyboard.Page1, "AP", "filled", 0, 100 )
	LCDSetLocation( EA_LCDKeyboard.Page1, "AP", 30, 11 )
	LCDSetSize( EA_LCDKeyboard.Page1, "AP", 130, 9 )

	-- CP
	LCDCreateStaticText( EA_LCDKeyboard.Page1, "CPTitle", 1, "left", 30, 1 )
	LCDSetLocation( EA_LCDKeyboard.Page1, "CPTitle", 0, 22 )
	LCDStaticTextSetText( EA_LCDKeyboard.Page1, "CPTitle", GetStringFromTable( "LCDStrings", StringTables.LCDStrings.CAREER_POINT_TITLE ) )
	LCDCreateStaticText( EA_LCDKeyboard.Page1, "CP", 1, "left", 130, 1 )
	LCDSetLocation( EA_LCDKeyboard.Page1, "CP", 30, 22 )
	LCDStaticTextSetText( EA_LCDKeyboard.Page1, "CP", L"0" )

	LCDRegisterEventHandler( EA_LCDKeyboard.Page1, SystemData.Events.PLAYER_CUR_HIT_POINTS_UPDATED, "EA_LCDKeyboard.UpdateHP" )
	LCDRegisterEventHandler( EA_LCDKeyboard.Page1, SystemData.Events.PLAYER_CUR_ACTION_POINTS_UPDATED, "EA_LCDKeyboard.UpdateAP" )
	LCDRegisterEventHandler( EA_LCDKeyboard.Page1, SystemData.Events.PLAYER_CAREER_RESOURCE_UPDATED, "EA_LCDKeyboard.UpdateCareerPoints" )
	
	-------------------------------------
	-- Screen 2 (RvR Tracker)
	-------------------------------------
	LCDCreatePage( EA_LCDKeyboard.Page2 )
	LCDCreateBitmap( EA_LCDKeyboard.Page2, "Logo" )
	LCDBitmapSetImage( EA_LCDKeyboard.Page2, "Logo", "Textures/LCDLogo.bmp", true )
	LCDCreateStaticText( EA_LCDKeyboard.Page2, "Title", 1, "center", 160 - 36, 1 )
	LCDSetLocation( EA_LCDKeyboard.Page2, "Title", 36, 0 )
	LCDStaticTextSetText( EA_LCDKeyboard.Page2, "Title", GetStringFromTable( "LCDStrings", StringTables.LCDStrings.SCENARIO_QUEUE_TITLE ) )
	LCDCreateStaticText( EA_LCDKeyboard.Page2, "Status", 1, "center", 160 - 36, 2 )
	LCDSetLocation( EA_LCDKeyboard.Page2, "Status", 36, 12 )
	LCDStaticTextSetText( EA_LCDKeyboard.Page2, "Status", GetStringFromTable( "LCDStrings", StringTables.LCDStrings.SCENARIO_QUEUE_NONE ) )

	LCDRegisterEventHandler( EA_LCDKeyboard.Page2, SystemData.Events.SCENARIO_ACTIVE_QUEUE_UPDATED, "EA_LCDKeyboard.UpdateScenarioQueue" )
	-- Scenario Starting
	LCDRegisterEventHandler( EA_LCDKeyboard.Page2, SystemData.Events.SCENARIO_SHOW_JOIN_PROMPT, "EA_LCDKeyboard.ShowScenarioJoinPrompt" )	
	
	-------------------------------------
	-- Screen 3 (Alert Log)
	-------------------------------------
	LCDCreatePage( EA_LCDKeyboard.Page3 )

	-- Alert Log
	LCDCreateStaticText( EA_LCDKeyboard.Page3, "AlertText", 1, "left", 160, 3 )
	
	LCDRegisterEventHandler( EA_LCDKeyboard.Page3, SystemData.Events.CONVERSATION_TEXT_ARRIVED, "EA_LCDKeyboard.UpdateAlertLog_ChatText" )
	
	-------------------------------------
	-- Screen 4 (Technical Data)
	-------------------------------------
	LCDCreatePage( EA_LCDKeyboard.Page4 )

	-- Server Name
	LCDCreateStaticText( EA_LCDKeyboard.Page4, "Server", 1, "center", 160, 1 )
	LCDStaticTextSetText( EA_LCDKeyboard.Page4, "Server", GetStringFormatFromTable( "Pregame", StringTables.Pregame.TEXT_SERVER_NAME, { GameData.Account.ServerName } ) )
	
	-- Set up buttons to change between pages
	LCDSetButtonHandler( EA_LCDKeyboard.Page0, "EA_LCDKeyboard.HandleLCDButton" )
	LCDSetButtonHandler( EA_LCDKeyboard.Page1, "EA_LCDKeyboard.HandleLCDButton" )
	LCDSetButtonHandler( EA_LCDKeyboard.Page2, "EA_LCDKeyboard.HandleLCDButton" )
	LCDSetButtonHandler( EA_LCDKeyboard.Page3, "EA_LCDKeyboard.HandleLCDButton" )
	LCDSetButtonHandler( EA_LCDKeyboard.Page4, "EA_LCDKeyboard.HandleLCDButton" )
end

function EA_LCDKeyboard.Update(timePassed)
end

function EA_LCDKeyboard.UpdateServerQueueStatus(waitSeconds, queuePos, queueSize)
	local title = GetStringFromTable( "LCDStrings", StringTables.LCDStrings.GAME_TITLE )..L"\n"..GetStringFromTable( "LCDStrings", StringTables.LCDStrings.SERVER_QUEUE_TITLE )
	LCDStaticTextSetText( EA_LCDKeyboard.Page0, "Title", title )
	local text = GetStringFormatFromTable( "LCDStrings", StringTables.LCDStrings.SERVER_QUEUE_POSITION, { L""..queuePos, L""..queueSize } );
	if( queuePos == 0 ) then
		text = GetStringFromTable( "LCDStrings", StringTables.LCDStrings.SERVER_QUEUE_DONE )
	end
	LCDStaticTextSetText( EA_LCDKeyboard.Page0, "Status", text )
end

function EA_LCDKeyboard.UpdateHP()
	local percent = GameData.Player.hitPoints.current / GameData.Player.hitPoints.maximum * 100
	LCDProgressBarSetProgress( EA_LCDKeyboard.Page1, "HP", percent )
end

function EA_LCDKeyboard.UpdateAP()
	local percent = GameData.Player.actionPoints.current / GameData.Player.actionPoints.maximum * 100
	LCDProgressBarSetProgress( EA_LCDKeyboard.Page1, "AP", percent )
end

function EA_LCDKeyboard.UpdateCareerPoints(previousResourceValue, currentResourceValue)
	LCDStaticTextSetText( EA_LCDKeyboard.Page1, "CP", L""..currentResourceValue )
end

function EA_LCDKeyboard.UpdateScenarioQueue()
	local queuedScenarioData = GetScenarioQueueData()
	LCDStaticTextSetText( EA_LCDKeyboard.Page2, "Title", GetStringFromTable( "LCDStrings", StringTables.LCDStrings.SCENARIO_QUEUE_TITLE ) )
	if( queuedScenarioData ~= nil ) then
		--DEBUG(L"In Queue")
		if( queuedScenarioData.totalQueuedScenarios > 2 ) then
			LCDStaticTextSetText( EA_LCDKeyboard.Page2, "Status", GetStringFromTable( "LCDStrings", StringTables.LCDStrings.SCENARIO_QUEUE_MULTIPLE ) )
		else
			local text = GetScenarioName( queuedScenarioData[1].id )
			if( queuedScenarioData.totalQueuedScenarios > 1 ) then
				text = text..L"\n"..GetScenarioName( queuedScenarioData[2].id )
			end
			LCDStaticTextSetText( EA_LCDKeyboard.Page2, "Status", text )
		end
	else
		--DEBUG(L"NOT in Queue")
		LCDStaticTextSetText( EA_LCDKeyboard.Page2, "Status", GetStringFromTable( "LCDStrings", StringTables.LCDStrings.SCENARIO_QUEUE_NONE ))
	end
end

function EA_LCDKeyboard.ShowScenarioJoinPrompt()
	-- Force Show Page 2
	LCDShowPage( EA_LCDKeyboard.Page2 )
	
	local name = GetScenarioName( GameData.ScenarioData.startingScenario )
	if( name == L"" ) then
		name = L"Scenario #"..GameData.ScenarioData.startingScenario
	end
	
	LCDStaticTextSetText( EA_LCDKeyboard.Page2, "Title", name )
	LCDStaticTextSetText( EA_LCDKeyboard.Page2, "Status", GetStringFromTable( "LCDStrings", StringTables.LCDStrings.SCENARIO_QUEUE_STARTING ) )
end

EA_LCDKeyboard.alertText = L""
EA_LCDKeyboard.alertTextLineCount = 0
function EA_LCDKeyboard.UpdateAlertLog_ChatText()
	-- Don't show our side of the conversation.
	if( GameData.ChatData.type ~= SystemData.ChatLogFilters.TELL_RECEIVE ) then
		return
	end
	
	local text = GetStringFormatFromTable( "LCDStrings", StringTables.LCDStrings.TELL_ALERT, { GameData.ChatData.name } )..L"\n"
	if( EA_LCDKeyboard.alertTextLineCount > 2 ) then
		-- We need to remove the first line before dumping.
		local count = 0
		local newAlertText = L""
		for line in EA_LCDKeyboard.alertText:gmatch(L"[^\r\n]+") do
			if( count ~= 0 ) then
				newAlertText = newAlertText..line..L"\n"
			end
			count = count + 1
		end
		EA_LCDKeyboard.alertText = newAlertText	
	end
	
	EA_LCDKeyboard.alertText = EA_LCDKeyboard.alertText..text
	EA_LCDKeyboard.alertTextLineCount = EA_LCDKeyboard.alertTextLineCount + 1
	
	LCDStaticTextSetText( EA_LCDKeyboard.Page3, "AlertText", EA_LCDKeyboard.alertText )
end

function EA_LCDKeyboard.HandleLCDButton(button, down)
	if( down ) then
		if( button == 1 ) then
			LCDShowPage( EA_LCDKeyboard.Page1 )
		end
		
		if( button == 2 ) then
			LCDShowPage( EA_LCDKeyboard.Page2 )
		end
		
		if( button == 3 ) then
			LCDShowPage( EA_LCDKeyboard.Page3 )
		end
		
		if( button == 4 ) then
			LCDShowPage( EA_LCDKeyboard.Page4 )
		end
	end
end
