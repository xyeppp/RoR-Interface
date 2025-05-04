PQData =
{
    STATE_CLEAR = 1,
    STATE_SHOW_TOP_CONTRIBUTORS = 2,
    STATE_SHOW_ROLLS = 3,
    STATE_TRANSITION = 4,
    STATE_SHOW_FINAL_RESULTS = 5,
    
    -- City PQs are a special case that don't have reset back to the first phase when they are complete
    INFINITE_DURATION_MAX_TIME  = 999999,
    INFINITE_DURATION_THRESHOLD = 100000,
    --DEFAULT_PQ_DURATION = 60 * 10, 			-- 10 minutes before the PQ Windows will turn off in a City PQ

    windowsCallbacks = {}
}

---------------------------------------------
-- PQData functions
---------------------------------------------

function PQData.Initialize()
    
    -- ASSUMPTION: for now we assume that we only need one state machine
    PQData.stateMachineName = "PQData"
    PQData.machine = nil
    PQData.state =
    {	
        [PQData.STATE_CLEAR]                    = { handler=PQData.Clear,                time=TimedStateMachine.TIMER_OFF,   nextState=PQData.STATE_SHOW_TOP_CONTRIBUTORS },
        [PQData.STATE_SHOW_TOP_CONTRIBUTORS]    = { handler=PQData.ShowTopContributors,  time=15,                             nextState=PQData.STATE_SHOW_ROLLS, },
        [PQData.STATE_SHOW_ROLLS]               = { handler=PQData.ShowRolls,            time=8,                             nextState=PQData.STATE_TRANSITION, },
        [PQData.STATE_TRANSITION]               = { handler=PQData.ShowTransitionScreen, time=2,                             nextState=PQData.STATE_SHOW_FINAL_RESULTS, },
        [PQData.STATE_SHOW_FINAL_RESULTS]       = { handler=PQData.ShowFinalResults,     time=TimedStateMachine.TIMER_OFF,   nextState=PQData.STATE_CLEAR, },
    }
    
    PQData.Clear()
    
    PQData.machine = TimedStateMachine.New( PQData.state, PQData.STATE_CLEAR )
    TimedStateMachineManager.AddStateMachine( PQData.stateMachineName, PQData.machine )
    
    RegisterEventHandler( SystemData.Events.PUBLIC_QUEST_SHOW_SCOREBOARD, "PQData.SynchronizeToScoreboard")
    RegisterEventHandler( SystemData.Events.PUBLIC_QUEST_RESETTING,       "PQData.SynchronizeIfFailure")
    RegisterEventHandler( SystemData.Events.OBJECTIVE_AREA_EXIT,          "PQData.OnObjectiveLeave")
    RegisterEventHandler( SystemData.Events.PLAYER_ZONE_CHANGED,          "PQData.OnZoneChange")

end

function PQData.Shutdown()

    UnregisterEventHandler( SystemData.Events.PUBLIC_QUEST_SHOW_SCOREBOARD, "PQData.SynchronizeToScoreboard")
    UnregisterEventHandler( SystemData.Events.PUBLIC_QUEST_RESETTING,       "PQData.SynchronizeIfFailure")
    UnregisterEventHandler( SystemData.Events.OBJECTIVE_AREA_EXIT,          "PQData.OnObjectiveLeave")
    UnregisterEventHandler( SystemData.Events.PLAYER_ZONE_CHANGED,          "PQData.OnZoneChange")

end

---------------------------------------------
-- Timer synchronization functions
---------------------------------------------
function PQData.SynchronizeToScoreboard()
    -- DEBUG(L"PQData.SynchronizeToScoreboard()")
    PQData.SynchronizeTimes()
    TimedStateMachine.RunState( PQData.machine, PQData.STATE_SHOW_TOP_CONTRIBUTORS )
end

function PQData.SynchronizeToFinalResults()
    -- DEBUG(L"PQData.SynchronizeToFinalResults()")
    PQData.SynchronizeTimes()
    TimedStateMachine.RunState( PQData.machine, PQData.STATE_SHOW_FINAL_RESULTS )
end

function PQData.SynchronizeToClear()
    -- DEBUG(L"PQData.SynchronizeToClear()")
    PQData.SynchronizeTimes()
    TimedStateMachine.RunState( PQData.machine, PQData.STATE_CLEAR )
end


function PQData.SynchronizeTimes()
    -- DEBUG(L"PQData.SynchronizeTimes()")
    -- DEBUG(L"GameData.PQData.timeUntilPQReset == "..GameData.PQData.timeUntilPQReset)
    PQData.timeUntilPQReset = GameData.PQData.timeUntilPQReset
    if PQData.timeUntilPQReset ~= nil and PQData.timeUntilPQReset > PQData.INFINITE_DURATION_THRESHOLD
    then
        if PQData.DEFAULT_PQ_DURATION ~= nil
        then
            PQData.timeUntilPQReset = PQData.timeUntilPQReset + PQData.DEFAULT_PQ_DURATION - PQData.INFINITE_DURATION_MAX_TIME
        end
        PQData.isCityPQ = true
        --DEBUG(L"PQData.isCityPQ == true ")
    else
        PQData.isCityPQ = false
    end

    if PQData.timeUntilPQReset == nil or PQData.timeUntilPQReset < 0
    then
        PQData.timeUntilPQReset = 0
    end
end

function PQData.SynchronizeIfFailure()
    if (PQData.currentState == PQData.STATE_CLEAR)
    then
        PQData.SynchronizeToFinalResults()
    end
end

function PQData.OnObjectiveLeave(objectiveID)
    if (objectiveID == GameData.PQData.id)
    then
        PQData.SynchronizeToClear()
        ClearPQLootData()
    end
end

function PQData.OnZoneChange()
    -- When zoning, the server may inform us of a new PQ for the new zone before the new zone finishes loading. Therefore only
    -- hide the current PQ if it is for a different zone than the new zone. Ignore zone values of 0 which are temporary loading values.
    if ( ( PQData.currentState ~= PQData.STATE_CLEAR ) and ( GameData.Player.zone ~= 0 ) and ( GameData.Player.zone ~= GameData.PQData.zone ) )
    then
        PQData.SynchronizeToClear()
        ClearPQLootData()
    end
end

function PQData.GetFakedTimerTime()
    if PQData.currentState == PQData.STATE_CLEAR
    then
        return 0
    elseif PQData.currentState == PQData.STATE_SHOW_TOP_CONTRIBUTORS
    then
        return TimedStateMachineManager.GetTimeBeforeNextState( PQData.stateMachineName ) +
               PQData.state[PQData.STATE_SHOW_ROLLS].time +
               PQData.state[PQData.STATE_TRANSITION].time
    elseif PQData.currentState == PQData.STATE_SHOW_ROLLS
    then
        return TimedStateMachineManager.GetTimeBeforeNextState( PQData.stateMachineName ) +
               PQData.state[PQData.STATE_TRANSITION].time
    elseif PQData.currentState == PQData.STATE_TRANSITION
    then
        return TimedStateMachineManager.GetTimeBeforeNextState( PQData.stateMachineName )
    elseif PQData.currentState == PQData.STATE_SHOW_FINAL_RESULTS
    then
        return PQData.timeUntilPQReset
    end
end

function PQData.HideAllWindows()
    for _, windowCallback in pairs(PQData.windowsCallbacks)
    do
        if (windowCallback and windowCallback.Hide)
        then
            windowCallback.Hide()
        end
    end
end

function PQData.AddWindow( windowCallback )
    if (windowCallback == nil)
    then
        ERROR(L"PQData.AddWindow() expects table argument.  Received nil.")
        return
    end
    
    if (PQData.currentState == PQData.STATE_CLEAR)
    then
        -- Add the window to the list
        table.insert( PQData.windowsCallbacks, windowCallback )
    else
        ERROR(L"PQ Callbacks not allowed to be added unless the state machine is not running")
    end
end


function PQData.OnUpdate( timePassed )

    if (GameData.PQData.timeUntilPQReset == nil) or
       (PQData.timeUntilPQReset == 0)
    then
        return
    end
    
    -- We save the timeUntilPQReset to the client C++ variable in case the UI is reloaded
    -- OPTIMIZATION: this probably could just get moved to an OnShutdown Handler
    -- One reason for doing it here is it resolves different triggers that cause us to initially
    --   set PQData.timeUntilPQReset
    GameData.PQData.timeUntilPQReset = GameData.PQData.timeUntilPQReset - timePassed
    PQData.timeUntilPQReset          = PQData.timeUntilPQReset - timePassed 
        
    if (PQData.timeUntilPQReset <= 0)
    then
        -- DEBUG(L"  PQData.timeUntilPQReset = "..PQData.timeUntilPQReset)
        PQData.SynchronizeToClear()
        ClearPQLootData()
    end

end


function PQData.ParseScoreboardData( contributorsData )

    PQData.PQName               = contributorsData.PQName
    PQData.metMinContribution   = contributorsData.metMinContribution
    PQData.optedOut             = contributorsData.optedOut
    PQData.forcedOut            = contributorsData.forcedOut
    PQData.playerData           = contributorsData.playerData 
    
    if( PQData.playerData.bonus > 0 )
    then
        PQData.playerData.contribution = L"+"..PQData.playerData.bonus
    elseif( PQData.playerData.bonus == 0 )
    then
        PQData.playerData.contribution = L"  -"
    else
        PQData.playerData.contribution = L""
    end
    
end

function PQData.SetResettingData()
    PQData.isResetting          = true
    PQData.PQName               = GameData.PQData.pqName
    PQData.metMinContribution   = false
    PQData.optedOut             = false
    PQData.forcedOut            = false
end

---------------------------------------------
-- State Change Callback Processing
---------------------------------------------
function PQData.Clear()
    -- DEBUG(L"PQData.Clear()")
    PQData.currentState = PQData.STATE_CLEAR

    PQData.playerData           = {}
    PQData.timeUntilPQReset     = 0
    PQData.metMinContribution   = false
    PQData.optedOut             = false
    PQData.forcedOut            = false
    PQData.isResetting          = false
    
    for _, windowCallback in pairs(PQData.windowsCallbacks)
    do
        if (windowCallback and windowCallback.Clear)
        then
            windowCallback.Clear()
        end
    end
        
    PQData.HideAllWindows()
    
    PQData.isCityPQ = false
end

function PQData.ShowTopContributors()
    -- DEBUG(L"PQData.ShowTopContributors()")
    PQData.currentState = PQData.STATE_SHOW_TOP_CONTRIBUTORS
    local contributorsData = GetPQTopContributors()
    
    if contributorsData == nil
    then
        return
    end
    
    PQData.ParseScoreboardData( contributorsData )
    
    for _, windowCallback in pairs(PQData.windowsCallbacks)
    do
        if (windowCallback and windowCallback.ShowTopContributors)
        then
            windowCallback.ShowTopContributors(contributorsData)
        end
    end

end


function PQData.ShowRolls()
    -- DEBUG(L"PQData.ShowRolls()")
    PQData.currentState = PQData.STATE_SHOW_ROLLS

    for _, windowCallback in pairs(PQData.windowsCallbacks)
    do
        if (windowCallback and windowCallback.ShowRolls)
        then
            windowCallback.ShowRolls()
        end
    end
end


function PQData.ShowTransitionScreen()
    -- DEBUG(L"PQData.ShowTransitionScreen()")
    PQData.currentState = PQData.STATE_TRANSITION

    for _, windowCallback in pairs(PQData.windowsCallbacks)
    do
        if (windowCallback and windowCallback.ShowTransitionScreen)
        then
            windowCallback.ShowTransitionScreen()
        end
    end
end

function PQData.ShowFinalResults()
    -- DEBUG(L"PQData.ShowFinalResults()")
    PQData.currentState = PQData.STATE_SHOW_FINAL_RESULTS

    local winnersData = GetPQLootWinners()
    if winnersData ~= nil
    then
        PQData.ParseScoreboardData( winnersData )
    elseif (GameData.PQData.pqName ~= nil) and (GameData.PQData.pqName ~= L"")
    then
        PQData.SetResettingData()
    else
        ERROR(L"PQData.ShowFinalResults Error: no data found")
        return
    end
    
    for _, windowCallback in pairs(PQData.windowsCallbacks)
    do
        if (windowCallback and windowCallback.ShowFinalResults)
        then
            windowCallback.ShowFinalResults(winnersData)
        end
    end
end
