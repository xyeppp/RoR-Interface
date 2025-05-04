
---------------------------------------------
-- static data decleration
---------------------------------------------

TimedStateMachineManager = 
{
    machines = {}
}


TimedStateMachine = {}
TimedStateMachine.TIMER_OFF = 65535

---------------------------------------------
-- END of static data decleration
---------------------------------------------

---------------------------------------------
-- TimedStateMachineManager functions
---------------------------------------------

--
-- Note: this function will automatically begin running the machine from it's current state. 
--   If you don't want anything to run immediately just set it to a state 
--   with handler=nil and time=TimedStateMachine.TIMER_OFF
--
function TimedStateMachineManager.AddStateMachine( name, machine )
    TimedStateMachineManager.machines[name] = machine
    
    TimedStateMachine.RunState(machine)
end

function TimedStateMachineManager.RemoveStateMachine( name )
    TimedStateMachineManager.machines[name] = nil
end


function TimedStateMachineManager.GetCurrentState( name )
    if TimedStateMachineManager.machines[name] ~= nil
    then
        return TimedStateMachineManager.machines[name].currentState
    end
end


function TimedStateMachineManager.GetTimeBeforeNextState( name )
    if TimedStateMachineManager.machines[name] ~= nil then
        return TimedStateMachineManager.machines[name].timeBeforeNextState
    end
end

-- OPTIMIZATION: Rather than call Update for every state machine every frame,
--   it would be nice to have a timer utility that could keep track of how long before a timer would
--   actually do something. This could then be kept in a sorted list so that in the case where nothing
--   needs updating, only one comparison is made
-- 
function TimedStateMachineManager.Update( timePassed )
    for name, machine in pairs(TimedStateMachineManager.machines)
    do
        TimedStateMachine.Update( machine, timePassed )
    end
end

function TimedStateMachineManager.Clear()
    TimedStateMachineManager.machines = {}
end



---------------------------------------------
-- TimedStateMachine functions
---------------------------------------------

-- function TimedStateMachine.New( stateData, startState )
--
-- Inputs:
--   stateData	- (table) array of states. Each state should be a table containing:
--		handler		- (function) called when state is enterred (nil if no functionality is needed for this state)
--		time		- (real number) seconds to remain in this state (or TimedStateMachine.TIMER_OFF to stay in this state)
--      nextState	- (integer number) index of next state to change to when the timer for the current state finishes 
-- 
--   startState	- (integer number, optional) index into the stateData for starting state
--				     defaults to 1.
--
-- Returns a table containing:
--   stateData (from Inputs)
--   startState  (from Inputs)
--   currentState (set to startState)
--   timeBeforeNextState
--   timerPaused (set to false)
--
--
function TimedStateMachine.New( stateData, startState )

    startState = startState or 1
    
    local newStateMachine = {}
    newStateMachine.startState      = startState
    newStateMachine.currentState    = startState
    newStateMachine.stateData       = stateData
    newStateMachine.timerPaused     = false
    
    return newStateMachine
end

function TimedStateMachine.Pause( stateMachine )
    stateMachine.timerPaused = true
end

function TimedStateMachine.Unpause( stateMachine )
    stateMachine.timerPaused = false
end

function TimedStateMachine.RunState( stateMachine, newState )

    stateMachine.timerPaused = false
    
    if newState ~= nil and newState <= #stateMachine.stateData then
        stateMachine.currentState = newState
    end
    
    local stateEntry = stateMachine.stateData[stateMachine.currentState]
    stateMachine.timeBeforeNextState = stateEntry.time
    if stateEntry.handler ~= nil
    then
        stateEntry.handler()
    end
end

function TimedStateMachine.Reset( stateMachine )
    TimedStateMachine.RunState( stateMachine, stateMachine.startState )
end

function TimedStateMachine.ProgressToNextState( stateMachine )
    local nextState = stateMachine.stateData[stateMachine.currentState].nextState
    TimedStateMachine.RunState( stateMachine, nextState )
end

function TimedStateMachine.Update( stateMachine, timePassed )

    if (stateMachine.timerPaused == true) or (stateMachine.timeBeforeNextState == TimedStateMachine.TIMER_OFF)
    then
        return
    end
    
    stateMachine.timeBeforeNextState = stateMachine.timeBeforeNextState - timePassed

    if stateMachine.timeBeforeNextState <= 0
    then
        TimedStateMachine.ProgressToNextState(stateMachine)
    end
    
end
