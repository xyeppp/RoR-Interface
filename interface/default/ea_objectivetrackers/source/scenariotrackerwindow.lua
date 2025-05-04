----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_ScenarioTracker = {}

EA_Window_ScenarioTracker.EMPTY_SIZE = { x=300, y=223 } -- Used to provide a size guide for the layout editor.


EA_Window_ScenarioTracker.WIDTH = 300

EA_Window_ScenarioTracker.objectiveData = {}
EA_Window_ScenarioTracker.currentObjective = -1

EA_Window_ScenarioTracker.OBJECTIVE_WINDOW_COUNT  = 8
EA_Window_ScenarioTracker.OBJECTIVE_WINDOW_HEIGHT     = 53
EA_Window_ScenarioTracker.SCENARIOQUEST_WINDOW_HEIGHT = 23


----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

local CompleteCounterColor      = DefaultColor.TEAL
local IncompleteCounterColor    = DefaultColor.WHITE
local CompleteQuestTitleColor   = CompleteCounterColor 
local IncompleteQuestTitleColor = IncompleteCounterColor

----------------------------------------------------------------
-- Local functions
----------------------------------------------------------------

----------------------------------------------------------------
-- EA_Window_ScenarioTracker Functions
----------------------------------------------------------------
-- OnInitialize Handler
function EA_Window_ScenarioTracker.Initialize()

    LayoutEditor.RegisterWindow( "EA_Window_ScenarioTracker",
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_SCENARIO_TRACKER_WINDOW_NAME ),
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_SCENARIO_TRACKER_WINDOW_DESC ),
                                false, false,
                                true, nil,
                                { "topleft", "top", "topright" } )
                                

    WindowRegisterEventHandler( "EA_Window_ScenarioTracker", SystemData.Events.SCENARIO_BEGIN,          "EA_Window_ScenarioTracker.ScenarioStart")
    WindowRegisterEventHandler( "EA_Window_ScenarioTracker", SystemData.Events.SCENARIO_UPDATE_POINTS,  "EA_Window_ScenarioTracker.UpdatePoints")
    WindowRegisterEventHandler( "EA_Window_ScenarioTracker", SystemData.Events.SCENARIO_END,            "EA_Window_ScenarioTracker.Hide")

    WindowRegisterEventHandler( "EA_Window_ScenarioTracker", SystemData.Events.PUBLIC_QUEST_ADDED,          "EA_Window_ScenarioTracker.OnQuestAdded")
    WindowRegisterEventHandler( "EA_Window_ScenarioTracker", SystemData.Events.PUBLIC_QUEST_UPDATED,        "EA_Window_ScenarioTracker.OnQuestUpdated")
    WindowRegisterEventHandler( "EA_Window_ScenarioTracker", SystemData.Events.PUBLIC_QUEST_REMOVED,        "EA_Window_ScenarioTracker.OnQuestRemoved")
    WindowRegisterEventHandler( "EA_Window_ScenarioTracker", SystemData.Events.PLAYER_OBJECTIVES_UPDATED,   "EA_Window_ScenarioTracker.UpdateObjectives")
    WindowRegisterEventHandler( "EA_Window_ScenarioTracker", SystemData.Events.OBJECTIVE_OWNER_UPDATED,     "EA_Window_ScenarioTracker.UpdateObjectives")
    WindowRegisterEventHandler( "EA_Window_ScenarioTracker", SystemData.Events.OBJECTIVE_CONTROL_POINTS_UPDATED, "EA_Window_ScenarioTracker.UpdateControl" )
            
    WindowRegisterEventHandler( "EA_Window_ScenarioTracker", SystemData.Events.LOADING_END,                  "EA_Window_ScenarioTracker.Refresh" )
    WindowRegisterEventHandler( "EA_Window_ScenarioTracker", SystemData.Events.INTERFACE_RELOADED,           "EA_Window_ScenarioTracker.Refresh" )
    
    for barIndex = 1, EA_Window_ScenarioTracker.OBJECTIVE_WINDOW_COUNT
    do
        local controlBarWindow = "EA_Window_ScenarioTracker".."Overview".."Point"..barIndex.."ControlBar"
        StatusBarSetMaximumValue( controlBarWindow, 100 )
    end
    
    EA_Window_ScenarioTracker.UpdateVisibility()
end


-- OnUpdate Handler
function EA_Window_ScenarioTracker.Update( timePassed )

    -- Update the timers
    EA_Window_ScenarioTracker.UpdateScenarioTimer()
    EA_Window_ScenarioTracker.UpdateObjectiveTimer()
    EA_Window_ScenarioTracker.UpdateScenarioQuestTimer()

end

-- OnShutdown Handler
function EA_Window_ScenarioTracker.Shutdown()

end

function EA_Window_ScenarioTracker.Refresh()
    EA_Window_ScenarioTracker.InitializeLabels()
    EA_Window_ScenarioTracker.UpdateLocation()
    EA_Window_ScenarioTracker.UpdatePoints()
    EA_Window_ScenarioTracker.UpdateObjectives()
    EA_Window_ScenarioTracker.UpdateTracker()
    EA_Window_ScenarioTracker.UpdateControlBar()
    EA_Window_ScenarioTracker.UpdateVisibility()
end

function EA_Window_ScenarioTracker.Show()
    LayoutEditor.Show( "EA_Window_ScenarioTracker" )
end

function EA_Window_ScenarioTracker.Hide()
    LayoutEditor.Hide( "EA_Window_ScenarioTracker" )
end

function EA_Window_ScenarioTracker.InitializeLabels()
    local goalText = GetStringFormatFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.TEXT_SCENARIO_POINT_GOAL, { L""..GameData.ScenarioData.pointMax } )
    LabelSetText( "EA_Window_ScenarioTrackerScoreboardGoal", goalText )
end

function EA_Window_ScenarioTracker.ScenarioStart()
    -- DEBUG(L"EA_Window_ScenarioTracker.ScenarioStart()")
    
    EA_Window_ScenarioTracker.InitializeLabels()
    EA_Window_ScenarioTracker.UpdateLocation()
    EA_Window_ScenarioTracker.UpdateScenarioTimer()
    EA_Window_ScenarioTracker.UpdatePoints()

    EA_Window_ScenarioTracker.Show()
end

function EA_Window_ScenarioTracker.UpdateVisibility()
    if ( GameData.Player.isInScenario and not GameData.Player.isInCampaignScenario )
    then
        LayoutEditor.Show( "EA_Window_ScenarioTracker" )
    else
        LayoutEditor.Hide( "EA_Window_ScenarioTracker" )
    end
end

----------------------------------------------------------------
-- Scenario Name
----------------------------------------------------------------
function EA_Window_ScenarioTracker.UpdateLocation()
    LabelSetText( "EA_Window_ScenarioTrackerLocationScenarioName", GetScenarioName( GameData.ScenarioData.id ) )
end

----------------------------------------------------------------
-- Overall scenario updates
----------------------------------------------------------------
function EA_Window_ScenarioTracker.UpdatePoints()
    local scoreboardName = "EA_Window_ScenarioTrackerScoreboard"
    local orderPoints = L""..GameData.ScenarioData.orderPoints
    LabelSetText( scoreboardName.."PointsOrder", orderPoints )
    
    local destructionPoints = L""..GameData.ScenarioData.destructionPoints
    LabelSetText( scoreboardName.."PointsDestruction", destructionPoints )
end

function EA_Window_ScenarioTracker.UpdateScenarioTimer()
    local questWindowString = "EA_Window_ScenarioTrackerLocation"
    
    local timeLeft = GameData.ScenarioData.timeLeft
    local text = TimeUtils.FormatClock(timeLeft)
    LabelSetText( questWindowString.."TimerValue", text )
end

function EA_Window_ScenarioTracker.UpdateObjective( objectiveID )
    -- We don't currently persist tracker information, maybe we should?
end

function EA_Window_ScenarioTracker.UpdateObjectives()
    -- DEBUG(L"EA_Window_ScenarioTracker.UpdateObjectives()")

    if (not GameData.Player.isInScenario)
    then
        return
    end

    EA_Window_ScenarioTracker.objectiveData = GetGameDataObjectives()

    local displayIndex = 1
    for _, data in pairs(EA_Window_ScenarioTracker.objectiveData)
    do
        local targetFrame = "EA_Window_ScenarioTrackerOverviewPoint"..displayIndex

        if (data.name ~= L"")
        then
            -- DEBUG(L"  Objective: "..index)
            WindowSetShowing(targetFrame, true)
            
            LabelSetText( targetFrame.."Name", data.name )

            local owner = TrackerUtils.GetFlagSliceForOwner(data.controllingRealm,data.isFortress)
            DynamicImageSetTextureSlice(targetFrame.."Owner", owner)
            displayIndex = displayIndex + 1
        else
            WindowSetShowing(targetFrame, false)
        end
    end
    
    local objectiveCount = displayIndex
    for index = objectiveCount, EA_Window_ScenarioTracker.OBJECTIVE_WINDOW_COUNT
    do
        local targetFrame = "EA_Window_ScenarioTrackerOverviewPoint"..index
        WindowSetShowing(targetFrame, false)
    end
    
    local rowCount = math.ceil(objectiveCount / 2)
    WindowSetDimensions("EA_Window_ScenarioTrackerOverview", EA_Window_ScenarioTracker.WIDTH,
                                                             EA_Window_ScenarioTracker.OBJECTIVE_WINDOW_HEIGHT * rowCount)
end

----------------------------------------------------------------
-- Per Objective Updates
----------------------------------------------------------------
function EA_Window_ScenarioTracker.UpdateControl()
    -- DEBUG(L"EA_Window_ScenarioTracker.UpdateControl()")

    DataUtils.activeObjectivesData = GetActiveObjectivesData()
    
    if (EA_Window_ScenarioTracker.currentObjective ~= GameData.ActiveObjectives.updatedObjectiveIndex)
    then
        EA_Window_ScenarioTracker.currentObjective = GameData.ActiveObjectives.updatedObjectiveIndex
        -- DEBUG(L"  EA_Window_ScenarioTracker.currentObjective = "..EA_Window_ScenarioTracker.currentObjective)
    end

    EA_Window_ScenarioTracker.UpdateControlBar()
end

function EA_Window_ScenarioTracker.UpdateControlBar()
    -- DEBUG(L"EA_Window_ScenarioTracker.UpdateControlBar()")
    
    local objectiveData = DataUtils.activeObjectivesData[EA_Window_ScenarioTracker.currentObjective]
    
    if objectiveData == nil
    then
        return
    end
    
    local overviewIndex = -1
    local namelessCount = 0
    for index, data in ipairs(EA_Window_ScenarioTracker.objectiveData)
    do
        if (data.name == L"")
        then
            namelessCount = namelessCount + 1
        else        
            if (data.id == objectiveData.id) and (objectiveData.isCapturePoint)
            then
                overviewIndex = index - namelessCount
                break
            end
        end
    end
    
    if (overviewIndex ~= -1)
    then
        local controlBarWindow = "EA_Window_ScenarioTracker".."Overview".."Point"..overviewIndex.."ControlBar"
        
        local controlFill = math.abs(objectiveData.curControlPoints)
        StatusBarSetCurrentValue( controlBarWindow, controlFill )
        
        local realm = GameData.Realm.NONE
        if ( objectiveData.curControlPoints < 0 )
        then
            realm = GameData.Realm.ORDER
        elseif ( objectiveData.curControlPoints > 0 )
        then
            realm = GameData.Realm.DESTRUCTION
        end
        
        local barColor = DefaultColor.RealmColors[realm]
        WindowSetTintColor( controlBarWindow, barColor.r, barColor.g, barColor.b )
        
        if (not WindowGetShowing(controlBarWindow))
        then
            WindowSetShowing(controlBarWindow, true)
        end
    end

end
    
function EA_Window_ScenarioTracker.UpdateObjectiveTimer()
    -- DEBUG(L"EA_Window_ScenarioTracker.UpdateObjectiveTimer()")
    local namelessCount = 0
    for overviewIndex, overallData in ipairs(EA_Window_ScenarioTracker.objectiveData)
    do
        local foundMatch = false
        
        if (overallData.name == L"")
        then
            local timerWindow = "EA_Window_ScenarioTracker".."Overview".."Point"..(overviewIndex - namelessCount).."Time"
            LabelSetText( timerWindow, L"" )
            namelessCount = namelessCount + 1
        else
        
            local timerWindow = "EA_Window_ScenarioTracker".."Overview".."Point"..(overviewIndex - namelessCount).."Time"
            
            for _, objectiveData in ipairs(DataUtils.activeObjectivesData)
            do
                if (objectiveData.id == overallData.id)
                then
                    -- DEBUG(L"  Match on id #"..overallData.id)
                    if (objectiveData.Quest ~= nil) and
                       (objectiveData.Quest[1] ~= nil) and
                       (objectiveData.Quest[1].timerState ~= GameData.PQTimerState.NONE)
                    then
                        local timeLeft = DataUtils.GetPQTimerRemaining( objectiveData.Quest[1].timerState, objectiveData.Quest[1].timerValue )
                        local text = TimeUtils.FormatClock(timeLeft)
                        LabelSetText( timerWindow, text )
                    else
                        LabelSetText( timerWindow, L"" )
                    end
                    
                    foundMatch = true
                    break
                end
            end
            
            if (not foundMatch)
            then
                LabelSetText( timerWindow, L"" )
            end

        end
    end

end

function EA_Window_ScenarioTracker.UpdateScenarioQuestTimer()
    local timerWindow = "EA_Window_ScenarioTrackerScenarioQuest"
    local foundMatch = false

    if (not WindowGetShowing(timerWindow))
    then
        return
    end
    
    -- Find the first active objective with no name
    for _, objectiveData in ipairs(DataUtils.activeObjectivesData)
    do
        if (objectiveData.name == L"")
        then
            if (objectiveData.Quest ~= nil) and
               (objectiveData.Quest[1] ~= nil) and
               (objectiveData.Quest[1].timerState ~= GameData.PQTimerState.NONE)
            then
                local timeLeft = DataUtils.GetPQTimerRemaining( objectiveData.Quest[1].timerState, objectiveData.Quest[1].timerValue )
                local text = TimeUtils.FormatClock(timeLeft)
                LabelSetText( timerWindow.."TimerValue", text )
            else
                LabelSetText( timerWindow.."TimerValue", L"" )
            end
            
            foundMatch = true
            break
        end
    end
    
    if (not foundMatch)
    then
        LabelSetText( timerWindow.."TimerValue", L"" )
    end
end

----------------------------------------------------------------
-- Quests
----------------------------------------------------------------
function EA_Window_ScenarioTracker.OnQuestAdded() 
    
    DataUtils.activeObjectivesData = GetActiveObjectivesData()
    local index = GameData.ActiveObjectives.updatedObjectiveIndex    
    
    -- DEBUG(L"EA_Window_ScenarioTracker.OnQuestAdded: index="..index )

    -- Update the Window to Include the new objective       
    EA_Window_ScenarioTracker.UpdateTracker()
    
    -- Sound
    Sound.Play( Sound.PUBLIC_QUEST_ADDED )
    
    -- Flicker the one we just entered
    local namelessCount = 0
    for objectiveIndex = 1, EA_Window_ScenarioTracker.OBJECTIVE_WINDOW_COUNT
    do
        local windowData = EA_Window_ScenarioTracker.objectiveData[objectiveIndex]
        
        if (windowData ~= nil)
        then
            if (windowData.name == L"")
            then
                namelessCount = namelessCount + 1
            else
                if ((DataUtils.activeObjectivesData[index]).id == windowData.id)
                then
                    local objectiveWindowString = "EA_Window_ScenarioTracker".."Overview".."Point"..(objectiveIndex-namelessCount).."Name"
                    WindowStartAlphaAnimation( objectiveWindowString, Window.AnimationType.LOOP, 1.0, 0.5, 0.5, false, 0.0, 0 )
                end
            end
        end
    end
    
end


function EA_Window_ScenarioTracker.OnQuestUpdated() 
    DataUtils.activeObjectivesData = GetActiveObjectivesData()
    local index = GameData.ActiveObjectives.updatedObjectiveIndex
    -- DEBUG(L"EA_Window_ScenarioTracker.OnQuestUpdated: index="..index )

    -- Update the Window to Include the new objective       
    EA_Window_ScenarioTracker.UpdateTracker()
end

function EA_Window_ScenarioTracker.OnQuestRemoved()
    DataUtils.activeObjectivesData = GetActiveObjectivesData()
    local index = GameData.ActiveObjectives.updatedObjectiveIndex
    -- DEBUG(L"EA_Window_ScenarioTracker.OnQuestUpdated: index="..index )
    
    EA_Window_ScenarioTracker.UpdateTracker()
    
    -- Stop all from flickering that we are not at
    local namelessCount = 0
    for objectiveIndex = 1, EA_Window_ScenarioTracker.OBJECTIVE_WINDOW_COUNT
    do
        local windowData = EA_Window_ScenarioTracker.objectiveData[objectiveIndex]
        
        if (windowData ~= nil)
        then
            if (windowData.name == L"")
            then
                namelessCount = namelessCount + 1
            else
                local atObjective = false
                for _, activeData in ipairs(DataUtils.activeObjectivesData)
                do
                    if (activeData.id == windowData.id)
                    then
                        atObjective = true
                        break
                    end
                end
                
                if (not atObjective)
                then
                    local objectiveWindowString = "EA_Window_ScenarioTracker".."Overview".."Point"..(objectiveIndex-namelessCount).."Name"
                    WindowStopAlphaAnimation( objectiveWindowString )
                end
            end
        end
    end

end


function EA_Window_ScenarioTracker.UpdateScenarioQuests()
    local questWindowName = "EA_Window_ScenarioTrackerScenarioQuest"
    local scenarioQuestCount = 0

    -- Look for active quests with no name (so they are hidden from the overview objectives)
    for _, objectiveData in ipairs(DataUtils.activeObjectivesData)
    do
        if (objectiveData.name == L"") and (objectiveData.Quest ~= nil) and (objectiveData.Quest[1] ~= nil)
        then
            LabelSetText(questWindowName.."Name", objectiveData.Quest[1].name)
            
            scenarioQuestCount = scenarioQuestCount + 1
        end
        
        -- Window only handles one of these for now.
        if (scenarioQuestCount >= 1)
        then
            break
        end
    end
    
    WindowSetShowing(questWindowName, scenarioQuestCount ~= 0)
    WindowSetDimensions(questWindowName, EA_Window_ScenarioTracker.WIDTH, (EA_Window_ScenarioTracker.SCENARIOQUEST_WINDOW_HEIGHT * scenarioQuestCount))
end


function EA_Window_ScenarioTracker.UpdateTracker( )
   
    local objectiveWindowString = "EA_Window_ScenarioTracker".."Overview".."Point"

    -- Show/hide control bars as needed
    for objectiveIndex = 1, EA_Window_ScenarioTracker.OBJECTIVE_WINDOW_COUNT
    do
        local controlBarWindow = objectiveWindowString..objectiveIndex.."ControlBar"
        local windowData       = EA_Window_ScenarioTracker.objectiveData[objectiveIndex]
        
        local foundCapturePoint = false
        if (windowData ~= nil)
        then
            for _, objectiveData in ipairs(DataUtils.activeObjectivesData)
            do
                if (objectiveData.id == windowData.id)
                then
                    foundCapturePoint = objectiveData.isCapturePoint
                    break
                end
            end
        end

        WindowSetShowing( controlBarWindow, foundCapturePoint )
    end
    
    EA_Window_ScenarioTracker.UpdateControlBar()
    EA_Window_ScenarioTracker.UpdateScenarioQuests()

end


function EA_Window_ScenarioTracker.MouseOverDescription()
    local line1 = GetScenarioName( GameData.ScenarioData.id )  
    local line2 = GetScenarioScoreDesc( GameData.ScenarioData.id  ) 

    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, line1)
    Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
    Tooltips.SetTooltipText( 2, 1, line2)

    Tooltips.Finalize()
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT ) 
end

function EA_Window_ScenarioTracker.OnMouseOverQuest()

    local objective  = WindowGetId(SystemData.ActiveWindow.name)
    local questIndex = 1

    local windowData  = EA_Window_ScenarioTracker.objectiveData[objective]
    local objectiveData = nil
    if (windowData ~= nil)
    then
        for index, data in ipairs(DataUtils.activeObjectivesData)
        do
            if (data.id == windowData.id)
            then
                objectiveData = data
                break
            end
        end
    end
    
    if (objectiveData == nil)
    then
        return
    end
    
    local questData     = objectiveData.Quest[questIndex]

    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )    
    local row = 1
    local column = 1

    -- Name
    local text = questData.name
    Tooltips.SetTooltipFont( row, column, "font_default_sub_heading", WindowUtils.FONT_DEFAULT_SUB_HEADING_LINESPACING  )
    Tooltips.SetTooltipText( row, column, text )
    Tooltips.SetTooltipColor( row, column, 255, 204, 102 )

    row = row + 1
    column = 1
        
    -- Text
    local text = questData.desc
    Tooltips.SetTooltipText( row, column, text )
    
    Tooltips.Finalize()
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT )

end
