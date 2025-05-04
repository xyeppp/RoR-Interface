EA_Window_RvRTracker =
{
}

local lastZoneContainingAddonPoints = 0
local activeObjectiveTimers = {}
local inactiveObjectiveTimers = {}

----------------------------------------------------------------
-- EA_Window_RvRTracker Functions
----------------------------------------------------------------

function EA_Window_RvRTracker.Initialize()
    LayoutEditor.RegisterWindow( "EA_Window_RvRTracker",
                                 GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_RVR_TRACKER_NAME ),
                                 GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_RVR_TRACKER_DESC ),
                                 false,
                                 false,
                                 true,
                                 nil )
    CreateMapInstance( "EA_Window_RvRTracker", SystemData.MapTypes.RVRTRACKER )
    
    WindowRegisterEventHandler( "EA_Window_RvRTracker", SystemData.Events.LOADING_END, "EA_Window_RvRTracker.UpdateMap" )
    WindowRegisterEventHandler( "EA_Window_RvRTracker", SystemData.Events.PLAYER_ZONE_CHANGED, "EA_Window_RvRTracker.UpdateMap" )
    WindowRegisterEventHandler( "EA_Window_RvRTracker", SystemData.Events.PLAYER_RVRLAKE_CHANGED, "EA_Window_RvRTracker.UpdateShowing" )
    
    WindowRegisterEventHandler( "EA_Window_RvRTracker", SystemData.Events.WORLD_MAP_POINTS_LOADED, "EA_Window_RvRTracker.OnWorldMapPointsLoaded" )
    WindowRegisterEventHandler( "EA_Window_RvRTracker", SystemData.Events.OBJECTIVE_MAP_TIMER_UPDATED, "EA_Window_RvRTracker.OnObjectiveTimerUpdated" )
    
    EA_Window_RvRTracker.UpdateMap()
    EA_Window_RvRTracker.UpdateShowing()
end

function EA_Window_RvRTracker.Shutdown()
    RemoveMapInstance( "EA_Window_RvRTracker" )
    LayoutEditor.UnregisterWindow( "EA_Window_RvRTracker" )
end

function EA_Window_RvRTracker.UpdateMap()
    EA_Window_RvRTracker.ClearObjectiveTimers()
    MapSetMapView( "EA_Window_RvRTracker", GameDefs.MapLevel.ZONE_MAP, GameData.Player.zone )
end

function EA_Window_RvRTracker.UpdateShowing()
    if ( GameData.Player.isInRvRLake )
    then
        LayoutEditor.Show( "EA_Window_RvRTracker" )
        EA_Window_RvRTracker.RefreshObjectiveTimers()
    else
        LayoutEditor.Hide( "EA_Window_RvRTracker" )
    end
end

function EA_Window_RvRTracker.OnMouseOverPoint()
    -- Make sure we're not handling input that is actually intended for a window on top of us
    if ( SystemData.MouseOverWindow.name == SystemData.ActiveWindow.name )
    then
        Tooltips.CreateMapPointTooltip( SystemData.ActiveWindow.name, EA_Window_RvRTracker.MouseoverPoints, Tooltips.ANCHOR_CURSOR_LEFT, Tooltips.MAP_TYPE_MINIMAP )    
    end
end

----------------------------------------------------------------
-- Battlefield Objective Timers
----------------------------------------------------------------

function EA_Window_RvRTracker.OnWorldMapPointsLoaded( mapDisplay )
    if (mapDisplay == "EA_Window_RvRTracker")
    then
        EA_Window_RvRTracker.ClearObjectiveTimers()
        EA_Window_RvRTracker.CreateObjectiveTimers()
        lastZoneContainingAddonPoints = GameData.Player.zone
    end
end

function EA_Window_RvRTracker.ClearObjectiveTimers()
    local zoneId = lastZoneContainingAddonPoints
    for objectiveId, _ in pairs(activeObjectiveTimers)
    do
        DestroyWindow("EA_Window_RvRTrackerObjectiveTimer_"..zoneId.."_"..objectiveId)
    end
    for objectiveId, _ in pairs(inactiveObjectiveTimers)
    do
        DestroyWindow("EA_Window_RvRTrackerObjectiveTimer_"..zoneId.."_"..objectiveId)
    end
    
    activeObjectiveTimers = {}
    inactiveObjectiveTimers = {}
end

function EA_Window_RvRTracker.CreateObjectiveTimers()
    local mapDisplay = "EA_Window_RvRTracker"
    if (GameData.Player.zone == 0)
    then
        return
    end
    
    --[[
    local objectivesData = nil
    if GlyphDisplay.DoesZoneHaveZoneControl( GameData.Player.zone ) 
    then
        objectivesData = GetZoneObjectivesData( GameData.Player.zone )
    end
    d("RVRTracker _ create Timers")
    d(objectivesData)
    ]]--

    
    if (objectivesData ~= nil)
    then
        for _, objectivePoint in ipairs(objectivesData)
        do
            local objectiveTimerWindow = "EA_Window_RvRTrackerObjectiveTimer_"..GameData.Player.zone.."_"..objectivePoint.objId
            
            local x, y = MapGetPointForCoordinates(mapDisplay, objectivePoint.objPositionX, objectivePoint.objPositionY)
            
            CreateWindowFromTemplate(objectiveTimerWindow, "ObjectiveRvRTrackerTimer", mapDisplay)
            WindowAddAnchor(objectiveTimerWindow, "topleft", mapDisplay, "topleft", x, y)
            WindowSetId(objectiveTimerWindow, objectivePoint.objId)
        
            if (objectivePoint.objMapTimer > 0)
            then
                LabelSetText(objectiveTimerWindow, TimeUtils.FormatClock(objectivePoint.objMapTimer))
                activeObjectiveTimers[objectivePoint.objId] = objectivePoint.objMapTimer
            else
                WindowSetShowing(objectiveTimerWindow, false)
                inactiveObjectiveTimers[objectivePoint.objId] = 0
            end
        end
    end
end

function EA_Window_RvRTracker.RefreshObjectiveTimers()
    if (GameData.Player.zone == 0)
    then
        return
    end
    
    local objectivesData = GetZoneObjectivesData( GameData.Player.zone )

    if (objectivesData ~= nil)
    then
        for _, objectivePoint in ipairs(objectivesData)
        do
            EA_Window_RvRTracker.RefreshObjectiveTimer(objectivePoint.objId, objectivePoint.objMapTimer)
        end
    end
end

function EA_Window_RvRTracker.RefreshObjectiveTimer(objectiveId, timeLeft)
    local objectiveTimerWindow = "EA_Window_RvRTrackerObjectiveTimer_"..GameData.Player.zone.."_"..objectiveId
        
    if (activeObjectiveTimers[objectiveId] ~= nil)
    then
        if (timeLeft > 0)
        then
            LabelSetText(objectiveTimerWindow, TimeUtils.FormatClock(timeLeft))
            activeObjectiveTimers[objectiveId] = timeLeft
        else
            WindowSetShowing(objectiveTimerWindow, false)
            activeObjectiveTimers[objectiveId] = nil
            inactiveObjectiveTimers[objectiveId] = 0
        end
    elseif (inactiveObjectiveTimers[objectiveId] ~= nil)
    then
        if (timeLeft > 0)
        then
            WindowSetShowing(objectiveTimerWindow, true)
            LabelSetText(objectiveTimerWindow, TimeUtils.FormatClock(timeLeft))
            activeObjectiveTimers[objectiveId] = timeLeft
            inactiveObjectiveTimers[objectiveId] = nil
        end
    end
end

function EA_Window_RvRTracker.CountdownActiveObjectiveTimers( timePassed )
    for objectiveId, currentTimer in pairs(activeObjectiveTimers)
    do
        local newTimer = currentTimer - timePassed
        if (newTimer > 0)
        then
            if (math.floor(newTimer + 0.5) < math.floor(currentTimer + 0.5))
            then
                local objectiveTimerWindow = "EA_Window_RvRTrackerObjectiveTimer_"..GameData.Player.zone.."_"..objectiveId
                LabelSetText(objectiveTimerWindow, TimeUtils.FormatClock(newTimer))
            end
            activeObjectiveTimers[objectiveId] = newTimer
        else
            local objectiveTimerWindow = "EA_Window_RvRTrackerObjectiveTimer_"..GameData.Player.zone.."_"..objectiveId
            WindowSetShowing(objectiveTimerWindow, false)
            activeObjectiveTimers[objectiveId] = nil
            inactiveObjectiveTimers[objectiveId] = 0
        end
    end
end

function EA_Window_RvRTracker.OnObjectiveTimerUpdated(objectiveId, timeLeft)
    if ( GameData.Player.isInRvRLake )
    then
        EA_Window_RvRTracker.RefreshObjectiveTimer(objectiveId, timeLeft)
    end
end