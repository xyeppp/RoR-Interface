----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_ScenarioLobby = {}

EA_Window_ScenarioLobby.MAX_SCENARIOS  = 10

EA_Window_ScenarioLobby.TOOLTIP_ANCHOR = { Point = "topright",   RelativeTo = "EA_Window_ScenarioLobby", RelativePoint = "topleft",   XOffset=5, YOffset=75 }

EA_Window_ScenarioLobby.ITEM_WIDTH = 375
EA_Window_ScenarioLobby.WINDOW_WIDTH = 400
EA_Window_ScenarioLobby.WINDOW_HEADER_HEIGHT = 100
EA_Window_ScenarioLobby.ITEM_HEIGHT = 85

EA_Window_ScenarioLobby.AUTO_CANCEL_TIME = 60 -- Seconds
EA_Window_ScenarioLobby.JOIN_WAIT_TIME = 59
EA_Window_ScenarioLobby.NEED_REJOIN_TIME = 60
EA_Window_ScenarioLobby.AUTO_CANCEL_TIME_CITY_JOIN = 240 -- auto cancel for city join window
EA_Window_ScenarioLobby.WAIT_TIME_CITY_JOIN = 60

EA_Window_ScenarioLobby.INSTANCETYPE_SCENARIO = 3
EA_Window_ScenarioLobby.INSTANCETYPE_CITY = 4

EA_Window_ScenarioLobby.autoCancelTime = 0
EA_Window_ScenarioLobby.waitTime	   = 0
EA_Window_ScenarioLobby.startTime	   = 0
EA_Window_ScenarioLobby.autoCancelCityInstance = 0
EA_Window_ScenarioLobby.cityInstanceWait = 0
EA_Window_ScenarioLobby.fightFlagPressed = false
EA_Window_ScenarioLobby.isLowLevel = false

EA_Window_ScenarioLobby.selectedQueue    = nil
EA_Window_ScenarioLobby.AllQueue    = 0
EA_Window_ScenarioLobby.AllData    = {}

EA_Window_ScenarioLobby.JOIN_MODE_SOLO  = 1
EA_Window_ScenarioLobby.JOIN_MODE_GROUP = 2
EA_Window_ScenarioLobby.NUM_JOIN_MODES  = 2

EA_Window_ScenarioLobby.joinModes = {}
EA_Window_ScenarioLobby.joinModes[ EA_Window_ScenarioLobby.JOIN_MODE_SOLO ] = { text=GetString( StringTables.Default.LABEL_JOIN_SOLO),      joinSingleEvent=SystemData.Events.INTERACT_JOIN_SCENARIO_QUEUE,         joinAllEvent=SystemData.Events.INTERACT_JOIN_SCENARIO_QUEUE_ALL  }
EA_Window_ScenarioLobby.joinModes[ EA_Window_ScenarioLobby.JOIN_MODE_GROUP ] = { text=GetString( StringTables.Default.LABEL_JOIN_GROUP),    joinSingleEvent=SystemData.Events.INTERACT_GROUP_JOIN_SCENARIO_QUEUE,   joinAllEvent=SystemData.Events.INTERACT_GROUP_JOIN_SCENARIO_QUEUE_ALL  }


EA_Window_ScenarioLobby.joinMode        = EA_Window_ScenarioLobby.JOIN_MODE_SOLO

EA_Window_ScenarioLobby.playerActiveQueues = nil    -- List of scenarios for which the player is actively queued.

local Is_StateMachine_Running = false
local SEND_BEGIN = 1
local SEND_FINISH = 2
EA_Window_ScenarioLobby.StateTimer = 0.1 --Update Timer

----------------------------------------------------------------
-- EA_Window_ScenarioLobby Functions
----------------------------------------------------------------

-- OnInitialize Handler
function EA_Window_ScenarioLobby.Initialize()
    -- Lobby Window
    LabelSetText( "EA_Window_ScenarioLobbyTitleBarText", GetString( StringTables.Default.LABEL_SCENARIO_LOBBY) )               
               
    for mode = 1, EA_Window_ScenarioLobby.NUM_JOIN_MODES do
        local text = EA_Window_ScenarioLobby.joinModes[mode].text
        LabelSetText("EA_Window_ScenarioLobbyJoinMode"..mode.."Label", text )
    end
       
    ButtonSetText("EA_Window_ScenarioLobbyCancelButton", GetString( StringTables.Default.LABEL_CANCEL ) )
    ButtonSetText("EA_Window_ScenarioLobbyJoinButton", GetString( StringTables.Default.LABEL_SCENARIO_JOIN ) )	
    ButtonSetText("EA_Window_ScenarioLobbyJoinAllButton", GetString( StringTables.Default.LABEL_SCENARIO_JOIN_ALL ) )	

	CreateMapInstance( "EA_Window_ScenarioLobbyScenarioMap", SystemData.MapTypes.NORMAL )
    EA_Window_ScenarioLobby.SelectJoinMode( EA_Window_ScenarioLobby.JOIN_MODE_SOLO ) 
    EA_Window_ScenarioLobby.OnGroupUpdated()

	-- In-Queue Window
	CreateWindow("EA_Window_InScenarioQueue", false )
	ButtonSetText("EA_Window_InScenarioQueueLeaveButton", GetString( StringTables.Default.LABEL_LEAVE ) )	
	WindowSetAlpha("EA_Window_InScenarioQueue", 0.75)
	
	-- Join-Instance Window
	CreateWindow("EA_Window_ScenarioJoinPrompt", false )
	LabelSetText("EA_Window_ScenarioJoinPromptBoxTitleBarText", GetString( StringTables.Default.TEXT_SCENARIO_LAUNCHING ) )
	LabelSetText("EA_Window_ScenarioJoinPromptBoxText", GetString( StringTables.Default.TEXT_SCENARIO_JOIN_PROMPT ) )
	ButtonSetText("EA_Window_ScenarioJoinPromptBoxJoinNowButton", GetString( StringTables.Default.TEXT_JOIN_SCENARIO_NOW ) )
	ButtonSetText("EA_Window_ScenarioJoinPromptBoxJoinWaitButton", GetString( StringTables.Default.TEXT_JOIN_SCENARIO_WAIT ) )
	ButtonSetText("EA_Window_ScenarioJoinPromptBoxJoinCancelButton", GetString( StringTables.Default.TEXT_JOIN_SCENARIO_CANCEL ) )
	LabelSetText("EA_Window_ScenarioJoinPromptBoxInCombatText", GetString( StringTables.Default.TEXT_SCENARIO_JOIN_IN_COMBAT ) )
	DefaultColor.SetLabelColor( "EA_Window_ScenarioJoinPromptBoxInCombatText", DefaultColor.RED )
	
	-- Scenario Starting Window
	CreateWindow("EA_Window_ScenarioStarting", false )
	WindowSetAlpha("EA_Window_ScenarioStarting", 0.75)
    ButtonSetText("EA_Window_ScenarioStartingJoinNowButton", GetString( StringTables.Default.LABEL_JOIN ) )	
    ButtonSetText("EA_Window_ScenarioStartingJoinCancelButton", GetString( StringTables.Default.LABEL_LEAVE ) )	
    LabelSetText("EA_Window_ScenarioStartingInCombatText", GetString( StringTables.Default.TEXT_SCENARIO_JOIN_IN_COMBAT ) )
	DefaultColor.SetLabelColor( "EA_Window_ScenarioStartingInCombatText", DefaultColor.RED )
	
	EA_Window_ScenarioLobby.UpdateStartingScenario()
	
	-- City Join-Instance Window
	CreateWindow("EA_Window_CityCaptureJoinPromptWindow", false )
    LabelSetText("EA_Window_CityCaptureJoinPromptWindowBoxTitleBarText", GetString( StringTables.Default.LABEL_CITY_CAPTURE_LAUNCHING ) )
	LabelSetText("EA_Window_CityCaptureJoinPromptWindowBoxText", GetString( StringTables.Default.LABEL_JOIN_CITY_CAPTURE ) )
    ButtonSetText("EA_Window_CityCaptureJoinPromptWindowBoxJoinNowButton", GetString( StringTables.Default.LABEL_YES_I_WANT_TO_PARTICIPATE ) )
    ButtonSetText("EA_Window_CityCaptureJoinPromptWindowBoxJoinWaitButton", GetString( StringTables.Default.LABEL_WAIT_NEED_MORE_TIME ) )
	ButtonSetText("EA_Window_CityCaptureJoinPromptWindowBoxJoinCancelButton", GetString( StringTables.Default.LABEL_NO_I_DO_NOT_WANT_TO_PARTICIPATE ) )       
    LabelSetText("EA_Window_CityCaptureJoinPromptWindowBoxLowLevel", GetString( StringTables.Default.TEXT_CITY_JOIN_LOW_LEVEL ) )
    DefaultColor.SetLabelColor( "EA_Window_CityCaptureJoinPromptWindowBoxLowLevel", DefaultColor.RED )
    WindowSetShowing( "EA_Window_CityCaptureJoinPromptWindowBoxLowLevel", false )
    
    CreateWindow("EA_Window_CityInstanceWait", false )
    WindowSetShowing("EA_Window_CityInstanceWait", false)   
	  
    WindowRegisterEventHandler( "EA_Window_ScenarioLobby", SystemData.Events.INTERACT_SHOW_SCENARIO_QUEUE_LIST, "EA_Window_ScenarioLobby.UpdateQueueList")
    WindowRegisterEventHandler( "EA_Window_ScenarioLobby", SystemData.Events.SCENARIO_ACTIVE_QUEUE_UPDATED, "EA_Window_ScenarioLobby.OnPlayerActiveQueuesUpdated" )
    WindowRegisterEventHandler( "EA_Window_ScenarioLobby", SystemData.Events.SCENARIO_SHOW_JOIN_PROMPT, "EA_Window_ScenarioLobby.ShowJoinPrompt" )
    WindowRegisterEventHandler( "EA_Window_ScenarioLobby", SystemData.Events.PLAYER_COMBAT_FLAG_UPDATED, "EA_Window_ScenarioLobby.OnPlayerCombatFlagUpdated" ) 
    WindowRegisterEventHandler( "EA_Window_ScenarioLobby", SystemData.Events.PLAYER_IS_BEING_THROWN, "EA_Window_ScenarioLobby.OnPlayerCombatFlagUpdated" )      
    
    WindowRegisterEventHandler( "EA_Window_ScenarioLobby", SystemData.Events.SCENARIO_STARTING_SCENARIO_UPDATED, "EA_Window_ScenarioLobby.UpdateStartingScenario" )        
    WindowRegisterEventHandler( "EA_Window_ScenarioLobby", SystemData.Events.GROUP_UPDATED, "EA_Window_ScenarioLobby.OnGroupUpdated")
    WindowRegisterEventHandler( "EA_Window_ScenarioLobby", SystemData.Events.BATTLEGROUP_UPDATED, "EA_Window_ScenarioLobby.OnGroupUpdated")
    WindowRegisterEventHandler( "EA_Window_ScenarioLobby", SystemData.Events.SCENARIO_SHOW_LEVELED_OUT_OF_BRACKETS, "EA_Window_ScenarioLobby.OnLeveledOutOfBrackets")
    WindowRegisterEventHandler( "EA_Window_ScenarioLobby", SystemData.Events.SCENARIO_SHOW_LEVELED_NEED_REJOIN_BRACKET, "EA_Window_ScenarioLobby.OnLevelNeedRejoinQueue")
    WindowRegisterEventHandler( "EA_Window_ScenarioLobby", SystemData.Events.CITY_CAPTURE_SHOW_JOIN_PROMPT, "EA_Window_ScenarioLobby.ShowCityCaptureJoinPrompt" )
    WindowRegisterEventHandler( "EA_Window_ScenarioLobby", SystemData.Events.LOADING_BEGIN, "EA_Window_ScenarioLobby.HideCityCapturePrompt" )
    WindowRegisterEventHandler( "EA_Window_ScenarioLobby", SystemData.Events.CITY_SCENARIO_INSTANCE_ID_SELECTED, "EA_Window_ScenarioLobby.HasInstanceEnableButton" )
    WindowRegisterEventHandler( "EA_Window_ScenarioLobby", SystemData.Events.CITY_CAPTURE_SHOW_LOW_LEVEL_JOIN_PROMPT, "EA_Window_ScenarioLobby.ShowCityCaptureLowLevelJoinPrompt" )
    
    
    EA_Window_ScenarioLobby.OnPlayerActiveQueuesUpdated()
     
    --DEBUG(L"Initialization Complete...")
    --EA_Window_ScenarioLobby.ShowCityCaptureJoinPrompt()
    
	WindowRegisterCoreEventHandler( "EA_Window_ScenarioLobbyScenarioMap", "OnShown", "EA_Window_ScenarioLobby.OnGroupUpdated" )

--Creating a StateMachine for updates instead of manual timers (saves me the hassel to have onUpdate that runs every frame)
	EA_Window_ScenarioLobby.stateMachineName = "EA_Window_ScenarioLobby"
	EA_Window_ScenarioLobby.state = {[SEND_BEGIN] = { handler=nil,time=EA_Window_ScenarioLobby.StateTimer,nextState=SEND_FINISH } , [SEND_FINISH] = { handler=EA_Window_ScenarioLobby.AllJoin,time=0,nextState=SEND_BEGIN, } , }
	Is_StateMachine_Running = false
end

-- OnShutdown Handler
function EA_Window_ScenarioLobby.Shutdown()
    RemoveMapInstance( "EA_Window_ScenarioLobbyScenarioMap" )
end

function EA_Window_ScenarioLobby.StartMachine()
	local stateMachine = TimedStateMachine.New( EA_Window_ScenarioLobby.state,SEND_BEGIN)
	TimedStateMachineManager.AddStateMachine( EA_Window_ScenarioLobby.stateMachineName, stateMachine )
end

function EA_Window_ScenarioLobby.Hide()
	WindowSetShowing( "EA_Window_ScenarioLobby", false )
end

function EA_Window_ScenarioLobby.UpdateQueueList()
	
	WindowSetShowing("EA_Window_ScenarioLobby", GameData.ScenarioQueueData[1].id ~= 0 )
	
	EA_Window_ScenarioLobby.ShowScenario( 1 )
	
	-- Hide the Prev/Next Buttons when we only have one scenario
	local showButtons = GameData.ScenarioQueueData[2].id ~= 0
	
    WindowSetShowing("EA_Window_ScenarioLobbyPreviousScenarioButton", showButtons )
	WindowSetShowing("EA_Window_ScenarioLobbyNextScenarioButton", showButtons )	

end

function EA_Window_ScenarioLobby.ShowScenario( index )

    EA_Window_ScenarioLobby.selectedQueue    = nil

    local queueData = GameData.ScenarioQueueData[index]
    if( queueData == nil ) then
        return
    end
    EA_Window_ScenarioLobby.selectedQueue = index
    

	local name = GetScenarioName( queueData.id )
	if( name == L"" ) then
		name = L"Scenario #"..queueData.id 
	end
	
	LabelSetText( "EA_Window_ScenarioLobbyScenarioName", name )
	LabelSetText( "EA_Window_ScenarioLobbyScenarioDesc", GetScenarioLobbyDesc( queueData.id ) )

    MapSetMapView( "EA_Window_ScenarioLobbyScenarioMap", GameDefs.MapLevel.ZONE_MAP, queueData.zone )
        
    EA_Window_ScenarioLobby.UpdateLobbyJoinButtons() 
    
end

function EA_Window_ScenarioLobby.UpdateLobbyJoinButtons()
    
   local scenarioId = GameData.ScenarioQueueData[EA_Window_ScenarioLobby.selectedQueue].id
   local withGroup  = (EA_Window_ScenarioLobby.joinMode == EA_Window_ScenarioLobby.JOIN_MODE_GROUP)

   local playerQueuedForThisScenario = EA_Window_ScenarioLobby.IsPlayerInQueue( scenarioId, withGroup )
   local playerQueuedForAllScenarios = EA_Window_ScenarioLobby.IsPlayerInAllQueues( withGroup )
   
   ButtonSetDisabledFlag("EA_Window_ScenarioLobbyJoinButton", playerQueuedForThisScenario )
   ButtonSetDisabledFlag("EA_Window_ScenarioLobbyJoinAllButton", playerQueuedForAllScenarios )

end

function EA_Window_ScenarioLobby.OnPreviousScenario()
    
    local scenarioIndex = EA_Window_ScenarioLobby.selectedQueue - 1
    
    -- Roll Over
    if( scenarioIndex < 1 ) then
        for index = EA_Window_ScenarioLobby.MAX_SCENARIOS, 1, -1 do
            if( GameData.ScenarioQueueData[index].id ~= 0 ) then                
                scenarioIndex = index
                break
            end
        end    
    end 
    
    EA_Window_ScenarioLobby.ShowScenario( scenarioIndex )
end

function EA_Window_ScenarioLobby.OnNextScenario()
    
    local scenarioIndex = EA_Window_ScenarioLobby.selectedQueue + 1
    
    -- Roll Over
    if( scenarioIndex > EA_Window_ScenarioLobby.MAX_SCENARIOS 
        or GameData.ScenarioQueueData[scenarioIndex].id == 0 ) then
           scenarioIndex = 1   
    end
    
     EA_Window_ScenarioLobby.ShowScenario( scenarioIndex )
end



function EA_Window_ScenarioLobby.OnMouseOverMapPoint()
    Tooltips.CreateMapPointTooltip( "EA_Window_ScenarioLobbyScenarioMap", EA_Window_ScenarioLobbyScenarioMap.MouseoverPoints, Tooltips.ANCHOR_CURSOR, Tooltips.MAP_TYPE_OTHER )   
end

function EA_Window_ScenarioLobby.SelectJoinMode( mode ) 
    EA_Window_ScenarioLobby.joinMode = mode    
    for mode = 1, EA_Window_ScenarioLobby.NUM_JOIN_MODES do
        local pressed = mode == EA_Window_ScenarioLobby.joinMode
        ButtonSetPressedFlag("EA_Window_ScenarioLobbyJoinMode"..mode.."Button", pressed )
    end
end

function EA_Window_ScenarioLobby.OnSelectJoinMode()    
    local mode = WindowGetId( SystemData.ActiveWindow.name )
    
    if( ButtonGetDisabledFlag("EA_Window_ScenarioLobbyJoinMode"..mode.."Button" ) ) then
        return
    end
    
    EA_Window_ScenarioLobby.SelectJoinMode( mode )
    EA_Window_ScenarioLobby.UpdateLobbyJoinButtons()
end

function EA_Window_ScenarioLobby.OnQueueAsPartyMouseOver()
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, GetString(StringTables.Default.TEXT_MUST_BE_LEADER_TO_QUEUE_PARTY) )
    Tooltips.Finalize()
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT )
end

function EA_Window_ScenarioLobby.OnGroupUpdated()
    local inLeadershipPosition = GameData.Player.isGroupLeader or GameData.Player.isWarbandAssistant
    -- Disable the join selections option when the player is not grouped or is not the group leader/assistant.
    for mode = 2, EA_Window_ScenarioLobby.NUM_JOIN_MODES do
        ButtonSetDisabledFlag("EA_Window_ScenarioLobbyJoinMode"..mode.."Button", not inLeadershipPosition )
    end
    -- If they had group selected but now only solo is enabled, then forceably select solo
    if (EA_Window_ScenarioLobby.joinMode == EA_Window_ScenarioLobby.JOIN_MODE_GROUP and not inLeadershipPosition) then
        EA_Window_ScenarioLobby.SelectJoinMode( EA_Window_ScenarioLobby.JOIN_MODE_SOLO ) 
        EA_Window_ScenarioLobby.UpdateLobbyJoinButtons()
    end
end

function EA_Window_ScenarioLobby.OnCancel()
    -- Just close the window
    WindowSetShowing("EA_Window_ScenarioLobby", false )
end


function EA_Window_ScenarioLobby.OnJoinSingleQueue()

    if( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) )
    then
        return
    end

    -- Join the Queue for this scenario
	local index = EA_Window_ScenarioLobby.selectedQueue
	GameData.ScenarioQueueData.selectedId = GameData.ScenarioQueueData[index].id
    
    local joinSingleEvent = EA_Window_ScenarioLobby.joinModes[ EA_Window_ScenarioLobby.joinMode ].joinSingleEvent
    
    BroadcastEvent( joinSingleEvent )   
    WindowSetShowing("EA_Window_ScenarioLobby", false)
end

function EA_Window_ScenarioLobby.OnJoinAllQueues()

    if( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) )
    then
        return
    end 
	EA_Window_ScenarioLobby.AllData    = {}
	
	for _, availQueueData in ipairs( GameData.ScenarioQueueData )
    do  
        if( availQueueData.id ~= 0 and availQueueData.id ~= 3000 and availQueueData.id ~= 3001)
        then
			table.insert(EA_Window_ScenarioLobby.AllData,availQueueData.id)
        end  
    end
	if Is_StateMachine_Running == false then
		EA_Window_ScenarioLobby.StartMachine()		
		Is_StateMachine_Running = true
	end
end

function EA_Window_ScenarioLobby.AllJoin()
  	if Is_StateMachine_Running == true then
	if EA_Window_ScenarioLobby.AllData[1] ~= nil then
	GameData.ScenarioQueueData.selectedId = EA_Window_ScenarioLobby.AllData[1]
    local joinSingleEvent = EA_Window_ScenarioLobby.joinModes[ EA_Window_ScenarioLobby.joinMode ].joinSingleEvent   
    BroadcastEvent( joinSingleEvent )   
	table.remove(EA_Window_ScenarioLobby.AllData,1)
	return
	end	
	end
EA_Window_ScenarioLobby.AllData = {}	
Is_StateMachine_Running = false
TimedStateMachineManager.RemoveStateMachine( EA_Window_ScenarioLobby.stateMachineName )
end

function EA_Window_ScenarioLobby.OnLeaveActiveQueue()
	GameData.ScenarioQueueData.selectedId = GameData.ScenarioData.activeQueue
    BroadcastEvent( SystemData.Events.INTERACT_LEAVE_SCENARIO_QUEUE )    
end

function EA_Window_ScenarioLobby.OnLeaveActiveQueueFromLobby()
    -- A cancel request initiated from the lobby window
	EA_Window_ScenarioLobby.OnLeaveActiveQueue()    
    WindowSetShowing("EA_Window_ScenarioJoinPrompt", false)
    WindowSetShowing("EA_Window_ScenarioStarting", false)	
end

-- In-Queue Window

function EA_Window_ScenarioLobby.OnPlayerActiveQueuesUpdated()	

    EA_Window_ScenarioLobby.playerActiveQueues = GetScenarioQueueData()    

    -- If the Lobby Window is showing, update the join buttons
    if( WindowGetShowing("EA_Window_ScenarioLobby") )
    then
         EA_Window_ScenarioLobby.UpdateLobbyJoinButtons()
    end
	
	WindowSetShowing("EA_Window_ScenarioJoinPrompt", false)
end

function EA_Window_ScenarioLobby.UpdateWaitTime( timePassed )
	if(EA_Window_ScenarioLobby.waitTime > 0 ) then		
		EA_Window_ScenarioLobby.waitTime = EA_Window_ScenarioLobby.waitTime - timePassed
		if( EA_Window_ScenarioLobby.waitTime <= 0 ) then
			EA_Window_ScenarioLobby.waitTime = 0					
			LabelSetText( "EA_Window_InScenarioQueueTimer", GetString( StringTables.Default.TEXT_WAITING_ON_PLAYERS ))
		else
			local time = TimeUtils.FormatClock( EA_Window_ScenarioLobby.waitTime )
			local text = GetStringFormat( StringTables.Default.TEXT_JOIN_WAIT_TIME, { time } )
			LabelSetText( "EA_Window_InScenarioQueueTimer", text )	
		end				
	end	
end


-- Join Window
function EA_Window_ScenarioLobby.ShowJoinPrompt()

	local name = GetScenarioName( GameData.ScenarioData.startingScenario )
	if( name == L"" ) then
		name = L"Scenario #"..GameData.ScenarioData.startingScenario
	end		
	LabelSetText("EA_Window_ScenarioJoinPromptBoxName", name )
	
	WindowSetShowing("EA_Window_ScenarioJoinPrompt", true)
	EA_Window_ScenarioLobby.UpdateLaunchingJoinButtons()		
	
	EA_Window_ScenarioLobby.autoCancelTime = EA_Window_ScenarioLobby.AUTO_CANCEL_TIME
	
	Sound.Play(Sound.SCENARIO_INVITE)
end


function EA_Window_ScenarioLobby.OnPlayerCombatFlagUpdated()

    -- If the Join Prompt windw is showing, update the buttons
    if( WindowGetShowing("EA_Window_ScenarioJoinPrompt" ) or WindowGetShowing("EA_Window_ScenarioStarting" ))
    then
        EA_Window_ScenarioLobby.UpdateLaunchingJoinButtons()
    end

end

function EA_Window_ScenarioLobby.UpdateLaunchingJoinButtons()

	-- Disable the 'Join Now' Button if the player is in combat & Show the description text.
	local flagValue = false
	if( GameData.Player.inCombat == true)
	then
	    flagValue = true
	end
	
	ButtonSetDisabledFlag("EA_Window_ScenarioJoinPromptBoxJoinNowButton", flagValue )
    ButtonSetDisabledFlag("EA_Window_ScenarioStartingJoinNowButton", flagValue )
    
    WindowSetShowing("EA_Window_ScenarioStartingInCombatText", flagValue )
    WindowSetShowing("EA_Window_ScenarioJoinPromptBoxInCombatText", flagValue )

end


function EA_Window_ScenarioLobby.UpdateAutoCancelTime( timePassed ) 
	if(EA_Window_ScenarioLobby.autoCancelTime > 0 ) then		
		EA_Window_ScenarioLobby.autoCancelTime = EA_Window_ScenarioLobby.autoCancelTime - timePassed
		if( EA_Window_ScenarioLobby.autoCancelTime <= 0 ) then
			EA_Window_ScenarioLobby.autoCancelTime = 0
			 EA_Window_ScenarioLobby.OnJoinInstanceCancel()
		end	
		
		local time = TimeUtils.FormatClock( EA_Window_ScenarioLobby.autoCancelTime )
		local text = GetStringFormat( StringTables.Default.TEXT_JOIN_SCENARIO_RESPOND_TIME, { time } )
		LabelSetText("EA_Window_ScenarioJoinPromptBoxRespondTime", text )		
	end	
end

function EA_Window_ScenarioLobby.OnJoinInstanceNow()
    
    if( ButtonGetDisabledFlag("EA_Window_ScenarioJoinPromptBoxJoinNowButton" ) )
    then
        return
    end

    BroadcastEvent( SystemData.Events.SCENARIO_INSTANCE_JOIN_NOW )    
    WindowSetShowing("EA_Window_ScenarioJoinPrompt", false)
    LabelSetText( "EA_Window_InScenarioQueueTimer", GetString( StringTables.Default.TEXT_WAITING_ON_PLAYERS ))
	EA_Window_ScenarioLobby.startTime = 0.1
	WindowSetShowing( "EA_Window_ScenarioStarting", true )    

end

function EA_Window_ScenarioLobby.OnJoinInstanceWait()
    BroadcastEvent( SystemData.Events.SCENARIO_INSTANCE_JOIN_WAIT ) 
    WindowSetShowing("EA_Window_ScenarioJoinPrompt", false)       
    EA_Window_ScenarioLobby.startTime = EA_Window_ScenarioLobby.JOIN_WAIT_TIME
    WindowSetShowing( "EA_Window_ScenarioStarting", true )
    EA_Window_ScenarioLobby.UpdateLaunchingJoinButtons()
end

function EA_Window_ScenarioLobby.OnJoinInstanceCancel()
    BroadcastEvent( SystemData.Events.SCENARIO_INSTANCE_CANCEL )  
    WindowSetShowing("EA_Window_ScenarioJoinPrompt", false)  
end

-- City Capture Join Window
function EA_Window_ScenarioLobby.ShowCityCaptureJoinPrompt()
	-- We should check whether or not the player is in a group and/or whether or not 
	-- the group leader has selected an instance or not
	-- if not => disable the "Fight" button
	-- if he has, enable the "Fight" button	
	
	if( EA_Window_ScenarioLobby.autoCancelCityInstance > 0 ) then
	    --
	    WindowSetShowing("EA_Window_CityCaptureJoinPromptWindow", true)
	    WindowSetShowing("EA_Window_CityInstanceWait", false)
	    ButtonSetDisabledFlag("EA_Window_CityCaptureJoinPromptWindowBoxJoinWaitButton", true)
	else
		EA_Window_ScenarioLobby.autoCancelCityInstance = EA_Window_ScenarioLobby.AUTO_CANCEL_TIME_CITY_JOIN
	    WindowSetShowing("EA_Window_CityCaptureJoinPromptWindow", true)
	end
end

function EA_Window_ScenarioLobby.ShowCityCaptureLowLevelJoinPrompt()
    WindowSetShowing( "EA_Window_CityCaptureJoinPromptWindowBoxLowLevel", true )    
		
    if( EA_Window_ScenarioLobby.autoCancelCityInstance > 0 ) then
	    --
	    WindowSetShowing("EA_Window_CityCaptureJoinPromptWindow", true)
	    WindowSetShowing("EA_Window_CityInstanceWait", false)
	    ButtonSetDisabledFlag("EA_Window_CityCaptureJoinPromptWindowBoxJoinWaitButton", true)
	    ButtonSetDisabledFlag("EA_Window_CityCaptureJoinPromptWindowBoxJoinNowButton", true)
	else
		EA_Window_ScenarioLobby.autoCancelCityInstance = EA_Window_ScenarioLobby.AUTO_CANCEL_TIME_CITY_JOIN
	    WindowSetShowing("EA_Window_CityCaptureJoinPromptWindow", true)
	    ButtonSetDisabledFlag("EA_Window_CityCaptureJoinPromptWindowBoxJoinNowButton", true)
	    EA_Window_ScenarioLobby.isLowLevel = true
	end
end

function EA_Window_ScenarioLobby.UpdateCityAutoCancelTime( timePassed )
    --
    if(EA_Window_ScenarioLobby.autoCancelCityInstance > 0 ) then		
		EA_Window_ScenarioLobby.autoCancelCityInstance = EA_Window_ScenarioLobby.autoCancelCityInstance - timePassed
		if( not EA_Window_ScenarioLobby.isLowLevel) then
		    EA_Window_ScenarioLobby.CheckFightPressedFlag()
		end
		if( EA_Window_ScenarioLobby.autoCancelCityInstance <= 0 ) then
			EA_Window_ScenarioLobby.autoCancelCityInstance = 0
			 EA_Window_ScenarioLobby.OnLeaveCityCapture()
		end	
		
		local time = TimeUtils.FormatClock( EA_Window_ScenarioLobby.autoCancelCityInstance )
		local text = GetStringFormat( StringTables.Default.TEXT_JOIN_SCENARIO_RESPOND_TIME, { time } )
		LabelSetText("EA_Window_CityCaptureJoinPromptWindowBoxRespondTime", text )		
	end	
    
end

function EA_Window_ScenarioLobby.OnJoinCityCapture()
    local buttonDisabled = ButtonGetDisabledFlag("EA_Window_CityCaptureJoinPromptWindowBoxJoinNowButton")
    if( buttonDisabled ) then
    -- button is disabled, do nothing
    else
        local groupdata = GetNumGroupmates()
        local isPlayerSolo = IsPlayerSolo()
        --d(isPlayerSolo)

            if( GameData.Player.isGroupLeader == true ) then
                --DEBUG(L"Group Leader has clicked")
                --DEBUG(L"Sending Instance List request to server...")
                BroadcastEvent( SystemData.Events.CITY_CAPTURE_REQUEST_INSTANCE_DATA )
                --DEBUG(L"Closing Prompt")   
                EA_Window_ScenarioLobby.HideCityCapturePrompt()        
            else
                if( isPlayerSolo == 1 ) then
                    --DEBUG(L"Not IN a group")
                    --DEBUG(L"Sending Instance List request to server...")
                    BroadcastEvent( SystemData.Events.CITY_CAPTURE_REQUEST_INSTANCE_DATA )
                    --DEBUG(L"Closing Prompt")      
                    EA_Window_ScenarioLobby.HideCityCapturePrompt()
                else
                    --DEBUG(L"Non Leader has clicked")
                    --DEBUG(L"Sending Instance List request to server...")
                    BroadcastEvent( SystemData.Events.CITY_CAPTURE_REQUEST_INSTANCE_DATA )   
                    EA_Window_ScenarioLobby.fightFlagPressed = true
                end 
            end
    end
    --d(EA_Window_ScenarioLobby.fightFlagPressed)
end

function EA_Window_ScenarioLobby.OnLeaveCityCapture()
    BroadcastEvent( SystemData.Events.CITY_CAPTURE_FLEE )
    EA_Window_ScenarioLobby.HideCityCapturePrompt()
end

function EA_Window_ScenarioLobby.OnWaitCityCapture()
    --
    local buttonDisabled = ButtonGetDisabledFlag("EA_Window_CityCaptureJoinPromptWindowBoxJoinWaitButton")
    if( buttonDisabled ) then
    --
        --DEBUG(L"Button Disabled")
    else
        --DEBUG(L"Clicked Wait...")
        EA_Window_ScenarioLobby.cityInstanceWait = EA_Window_ScenarioLobby.WAIT_TIME_CITY_JOIN
        WindowSetShowing("EA_Window_CityInstanceWait", true)
        WindowSetShowing("EA_Window_CityCaptureJoinPromptWindow", false)
    end
end

function EA_Window_ScenarioLobby.UpdateCityCaptureWaitTime( timePassed )
    --
    if(EA_Window_ScenarioLobby.cityInstanceWait > 0 ) then		
		EA_Window_ScenarioLobby.cityInstanceWait = EA_Window_ScenarioLobby.cityInstanceWait - timePassed
		if( EA_Window_ScenarioLobby.cityInstanceWait <= 0 ) then
			EA_Window_ScenarioLobby.cityInstanceWait = 0
			if( EA_Window_ScenarioLobby.isLowLevel ) then
			    EA_Window_ScenarioLobby.ShowCityCaptureLowLevelJoinPrompt()
			else
			    EA_Window_ScenarioLobby.ShowCityCaptureJoinPrompt()
	        end
		end		
	end	
end

function EA_Window_ScenarioLobby.HideCityCapturePrompt()
    --DEBUG(L"Hiding City Capture Join Prompt")
    -- reset all window elements to their natural state
    WindowSetShowing( "EA_Window_CityCaptureJoinPromptWindowBoxLowLevel", false )
    ButtonSetDisabledFlag("EA_Window_CityCaptureJoinPromptWindowBoxJoinNowButton", false)
    ButtonSetDisabledFlag("EA_Window_CityCaptureJoinPromptWindowBoxJoinWaitButton", false)
    WindowSetShowing("EA_Window_CityCaptureJoinPromptWindow", false)        
    -- reset all the vars used
    EA_Window_ScenarioLobby.autoCancelCityInstance = 0
    EA_Window_ScenarioLobby.cityInstanceWait = 0
    EA_Window_ScenarioLobby.fightFlagPressed = false
    EA_Window_ScenarioLobby.isLowLevel = false
end


-- Scenario Starting Window
function EA_Window_ScenarioLobby.UpdateStartingScenario()

	local name = GetScenarioName( GameData.ScenarioData.startingScenario )
	if( name == L"" ) then
		name = L"Scenario #"..GameData.ScenarioData.startingScenario
	end		
	local text = GetStringFormat( StringTables.Default.TEXT_SCENARIO_STARTING, { name } )

	LabelSetText( "EA_Window_ScenarioStartingName", text )
	LabelSetText( "EA_Window_ScenarioStartingTimer", GetString( StringTables.Default.TEXT_SCENARIO_WAIT_TIME ) )		
	
	if( GameData.ScenarioData.startingScenario == 0 ) then
	    WindowSetShowing( "EA_Window_ScenarioStarting", false ) 
	    EA_Window_ScenarioLobby.startTime = 0
	elseif( EA_Window_ScenarioLobby.startTime > 0 ) then
	    WindowSetShowing( "EA_Window_ScenarioStarting", true ) 
	end
end

function EA_Window_ScenarioLobby.UpdateStartTime( timePassed )

	if(EA_Window_ScenarioLobby.startTime > 0 ) then		
		EA_Window_ScenarioLobby.startTime = EA_Window_ScenarioLobby.startTime - timePassed
		if( EA_Window_ScenarioLobby.startTime <= 0 ) then
			EA_Window_ScenarioLobby.startTime = 0					
            WindowSetShowing( "EA_Window_ScenarioStarting", false ) 
		else
			local time = TimeUtils.FormatClock( EA_Window_ScenarioLobby.startTime )
			local text = GetStringFormat( StringTables.Default.TEXT_JOIN_WAIT_TIME, { time } )
			LabelSetText( "EA_Window_ScenarioStartingTimer", text )	
		end				
	end	
end

function EA_Window_ScenarioLobby.OnLeveledOutOfBrackets( scenarioId )
    
    -- The player has leveled out of all avaiable brackets for this scenario.
    local name = GetScenarioName( scenarioId )
	if( name == L"" ) then
		name = L"#"..scenarioId
	end	
	
    local text = GetStringFormat( StringTables.Default.TEXT_SCENARIO_LEVELED_OUT_OF_ALL_BRACKETS, { name } )
    DialogManager.MakeOneButtonDialog( text, GetString( StringTables.Default.LABEL_OKAY ), nil )

end


function EA_Window_ScenarioLobby.OnLevelNeedRejoinQueue( scenarioId )
 
    -- The player has leveled out their current bracket and must rejoin.
    local name = GetScenarioName( scenarioId )
	if( name == L"" ) then
		name = L"#"..scenarioId
	end	
    
    local text = GetStringFormat( StringTables.Default.TEXT_SCENARIO_LEVELED_OUT_OF_BRACKET, { name } )
    
    local DoRejoinQueue = function()
        GameData.ScenarioQueueData.selectedId = scenarioId
        BroadcastEvent( SystemData.Events.INTERACT_JOIN_SCENARIO_QUEUE )
    end
    
    DialogManager.MakeTwoButtonDialog( text, GetString( StringTables.Default.LABEL_YES ), DoRejoinQueue, GetString( StringTables.Default.LABEL_NO ), nil )
end

function EA_Window_ScenarioLobby.OnRButtonUp()
    EA_Window_ContextMenu.CreateDefaultContextMenu( "EA_Window_ScenarioLobby" )
end

function EA_Window_ScenarioLobby.CheckFightPressedFlag()    
    if( EA_Window_ScenarioLobby.fightFlagPressed ) then
        -- button has been pressed, disable the button
        ButtonSetDisabledFlag("EA_Window_CityCaptureJoinPromptWindowBoxJoinNowButton", true)
    else
        -- the flag has been reset, could be because an instance has been selected, enable the button
        ButtonSetDisabledFlag("EA_Window_CityCaptureJoinPromptWindowBoxJoinNowButton", false)
    end
end

function EA_Window_ScenarioLobby.HasInstanceEnableButton()
    EA_Window_ScenarioLobby.fightFlagPressed = false
end

-------------------------------------------------------------
-- Util Functions
-------------------------------------------------------------


function EA_Window_ScenarioLobby.IsPlayerInQueue( scenarioId, withGroup )

    if( EA_Window_ScenarioLobby.playerActiveQueues == nil )
    then
        return false
    end

    for index, activeQueueData in ipairs( EA_Window_ScenarioLobby.playerActiveQueues )
    do
        -- Player can queue for a scenario as a group even if already queued solo, but not the reverse.
        if( activeQueueData.id == scenarioId and (activeQueueData.grouped == withGroup or not withGroup) )
        then
            return true
        end    
    end

    return false
end


function EA_Window_ScenarioLobby.IsPlayerInAllQueues( withGroup )
if Is_StateMachine_Running == true then return true end
      
    for _, availQueueData in ipairs( GameData.ScenarioQueueData )
    do
        -- The Available Queue List contains 0 entries at the end        
        if( availQueueData.id ~= 0 and availQueueData.id ~= 3000 and availQueueData.id ~= 3001)
        then
             if( not EA_Window_ScenarioLobby.IsPlayerInQueue( availQueueData.id, withGroup ) )
             then
                return false
             end
        end
    
    end  
    return true
end
