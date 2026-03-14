----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

-- Data for map addon points: Lua windows we create on top of the zone map
EA_Window_WorldMap.lastZoneContainingAddonPoints = 0
EA_Window_WorldMap.currentZoneTransitionPoints = 0
EA_Window_WorldMap.currentMapTextPoints = 0
EA_Window_WorldMap.activeObjectiveTimers = {}
EA_Window_WorldMap.inactiveObjectiveTimers = {}

-- Map Filters

-- The World Map groups map points into categories rather than allowing direct manipulation 
EA_Window_WorldMap.filterCategories = {}
EA_Window_WorldMap.filterCategories[1] = { stringId=StringTables.MapSystem.TEXT_ZONE_MAP_FILTER_TYPE_GROUP,
                                            filterTypes = { SystemData.MapPips.GROUP_MEMBER,
                                                            SystemData.MapPips.WARBAND_MEMBER }
                                         }


EA_Window_WorldMap.filterCategories[2] = { stringId=StringTables.MapSystem.TEXT_ZONE_MAP_FILTER_TYPE_SCENARIO,
                                            filterTypes = { SystemData.MapPips.ORDER_ARMY,
                                                            SystemData.MapPips.DESTRUCTION_ARMY }
                                         }

EA_Window_WorldMap.filterCategories[3] = { stringId=StringTables.MapSystem.TEXT_ZONE_MAP_FILTER_TYPE_PQ,
                                            filterTypes = { SystemData.MapPips.PUBLIC_QUEST }
                                         }

EA_Window_WorldMap.filterCategories[4] = { stringId=StringTables.MapSystem.TEXT_ZONE_MAP_FILTER_TYPE_QUEST,
                                            filterTypes = { SystemData.MapPips.QUEST_AREA,
                                                            SystemData.MapPips.LIVE_EVENT_WAYPOINT }
                                         }

EA_Window_WorldMap.filterCategories[5] = { stringId=StringTables.MapSystem.TEXT_ZONE_MAP_FILTER_TYPE_QUEST_NPCS,
                                            filterTypes = { SystemData.MapPips.QUEST_OFFER_NPC,
                                                            SystemData.MapPips.REPEATABLE_QUEST_OFFER_NPC,
															SystemData.MapPips.LIVE_EVENT_QUEST_OFFER_NPC,
                                                            SystemData.MapPips.QUEST_PENDING_NPC,
                                                            SystemData.MapPips.QUEST_COMPLETE_NPC }
                                         }

EA_Window_WorldMap.filterCategories[6] = { stringId=StringTables.MapSystem.TEXT_ZONE_MAP_FILTER_TYPE_NPCS,
                                            filterTypes = { SystemData.MapPips.STORE_NPC,
                                                            SystemData.MapPips.TRAINER_NPC,
                                                            SystemData.MapPips.AUCTION_HOUSE_NPC,
                                                            SystemData.MapPips.TRAVEL_NPC,
                                                            SystemData.MapPips.VAULT_KEEPER_NPC,
                                                            SystemData.MapPips.BINDER_NPC,
                                                            SystemData.MapPips.GUILD_REGISTRAR_NPC,
                                                            SystemData.MapPips.HEALER_NPC,
                                                            SystemData.MapPips.RVR_NPC,
                                                            SystemData.MapPips.MERCHANT_LASTNAME,
                                                            SystemData.MapPips.MERCHANT_DYE,
                                                            SystemData.MapPips.EQUIPMENT_UPGRADE_NPC }
                                          }
                                          
----------------------------------------------------------------
-- ZoneView Settings
----------------------------------------------------------------
EA_Window_WorldMap.Settings.mapPinFilters = {}

-- Default All Catagories to 'On'
EA_Window_WorldMap.Settings.filterCategories = {}
for index, category in ipairs( EA_Window_WorldMap.filterCategories )
do
    EA_Window_WorldMap.Settings.filterCategories[index] = true
end

----------------------------------------------------------------
-- ZoneView Functions
----------------------------------------------------------------

function EA_Window_WorldMap.InitializeZoneView()

    -- Map Display
    CreateMapInstance( "EA_Window_WorldMapZoneViewMapDisplay", SystemData.MapTypes.MAINMAP )
        
    -- Zone Control
    EA_Window_WorldMap.InitializeZoneControl()     
    EA_Window_WorldMap.InitializeGlyphDisplay()
    
    -- Init the MapPip Filters
    for index, pipType in pairs( SystemData.MapPips ) do
        if( EA_Window_WorldMap.Settings.mapPinFilters[pipType] == nil ) then
            EA_Window_WorldMap.Settings.mapPinFilters[pipType] = true
        end 
    end
    
    for index, filterType in pairs( SystemData.MapPips ) do
            
        -- Default any new filter types to on
        if( EA_Window_WorldMap.Settings.mapPinFilters[filterType] == nil ) 
        then
            EA_Window_WorldMap.Settings.mapPinFilters[filterType]  = true
        end
    
        local show = EA_Window_WorldMap.Settings.mapPinFilters[filterType] 
        MapSetPinFilter("EA_Window_WorldMapZoneViewMapDisplay", filterType, show )
    end
  
    
    -- Initialize The Map Point Toggles
    for index, category in ipairs( EA_Window_WorldMap.filterCategories ) 
    do
        
        local windowName  = "EA_Window_WorldMapZoneViewMapFilter"..index         
        local showPoint   =  EA_Window_WorldMap.Settings.filterCategories[ index ]
                
        -- Id
        WindowSetId( windowName, index )
        
        -- Filter Name
        local name = GetStringFromTable("MapSystem", category.stringId )
        LabelSetText( windowName.."Name",  name)               
        
        -- Button State
        ButtonSetStayDownFlag(windowName.."CheckBox",  true )
        ButtonSetPressedFlag( windowName.."CheckBox", showPoint )
        
        -- Set the Map Filters
        for _, filterType in pairs( category.filterTypes )
        do        
            MapSetPinFilter("EA_Window_WorldMapZoneViewMapDisplay", filterType, showPoint )
        end              
    end
    
    
    -- Initialize the labels
    LabelSetText( "EA_Window_WorldMapZoneViewZoneControlHeader",      GetStringFromTable("MapSystem", StringTables.MapSystem.LABEL_ZONE_CONTROL ) )
    LabelSetText( "EA_Window_WorldMapZoneViewMapMarkersHeader",       GetStringFromTable("MapSystem", StringTables.MapSystem.LABEL_MAP_MARKERS ) )
    LabelSetText( "EA_Window_WorldMapZoneViewQuestTrackerHeader",     GetStringFromTable("MapSystem", StringTables.MapSystem.LABEL_QUESTS ) )
    
    WindowRegisterEventHandler( "EA_Window_WorldMapZoneViewMapDisplay", SystemData.Events.WORLD_MAP_POINTS_LOADED, "EA_Window_WorldMap.OnWorldMapPointsLoaded" )
    WindowRegisterEventHandler( "EA_Window_WorldMapZoneViewMapDisplay", SystemData.Events.OBJECTIVE_MAP_TIMER_UPDATED, "EA_Window_WorldMap.OnObjectiveTimerUpdated" )
    
    -- Add an OnMouseOver handler for the Title part of the scrollwork border. Because the scrollwork template is used in many other places, this is the only way to make
    -- the handler only apply to the Zone View.
    WindowRegisterCoreEventHandler( "EA_Window_WorldMapZoneViewBorderTitleText", "OnMouseOver", "EA_Window_WorldMap.OnTitleMouseOver" )
            
    EA_Window_WorldMap.InitializeQuestTracker()

end


function EA_Window_WorldMap.ShutdownZoneView()

    RemoveMapInstance( "EA_Window_WorldMapZoneViewMapDisplay" )
    EA_Window_WorldMap.ShutdownZoneControl()
    EA_Window_WorldMap.ShutdownGlyphDisplay()
end



function EA_Window_WorldMap.OnMouseOverPoint()
    Tooltips.CreateMapPointTooltip( "EA_Window_WorldMapZoneViewMapDisplay", EA_Window_WorldMapZoneViewMapDisplay.MouseoverPoints, Tooltips.ANCHOR_CURSOR, Tooltips.MAP_TYPE_MAINMAP )    
end

function EA_Window_WorldMap.OnMouseOverTransitionPoint()
    local zoneId    = WindowGetId( SystemData.ActiveWindow.name )
    EA_Window_WorldMap.CreateAppropriateZoneTooltip(zoneId, nil, nil)
end

function EA_Window_WorldMap.OnTitleMouseOver()
    EA_Window_WorldMap.CreateAppropriateZoneTooltip(EA_Window_WorldMap.currentMap, Tooltips.ANCHOR_WINDOW_BOTTOM, L"")
end

function EA_Window_WorldMap.OnClickMap()
    MapUtils.ClickMap( "EA_Window_WorldMapZoneViewMapDisplay", EA_Window_WorldMapZoneViewMapDisplay.MouseoverPoints )     
end

function EA_Window_WorldMap.ShowZone( zoneId )
    
    -- Zone 0 is never valid, but GameData.Player.zone will sometimes be '0' 
    -- while logging in or zoning.
    if( zoneId == 0 )
    then
        return
    end
    
    -- Remove any old transition points, text points, and objective timers
    EA_Window_WorldMap.ClearZoneTransitionPoints()
    EA_Window_WorldMap.ClearMapTextPoints()
    EA_Window_WorldMap.ClearObjectiveTimers()
    
    MapSetMapView( "EA_Window_WorldMapZoneViewMapDisplay", EA_Window_WorldMap.currentLevel, EA_Window_WorldMap.currentMap )
    
    -- Update the Title    
    local text = GetStringFromTable("ZoneNames", EA_Window_WorldMap.currentMap )    
    LabelSetText("EA_Window_WorldMapZoneViewBorderTitleText", GetStringFormat( StringTables.Default.LABEL_ZONE_MAP_ZONE_NAME, {text} ) )

    -- Update the Quest List
    EA_Window_WorldMap.ShowQuests( zoneId )
    
    -- Update the zone control bar
    local zoneData = nil
    
    -- but not all zones have the usual rvr campaign zone control (like Tomb Kings zones)
    if GlyphDisplay.DoesZoneHaveZoneControl( zoneId ) 
    then
        zoneData = GetCampaignZoneData( zoneId )   
    end
    
    if (zoneData == nil) 
    then
        ThreePartBar.Hide(EA_Window_WorldMap.ZoneControlData.barID)
        
        local entryId = TomeGetWarJournalGlyphEntryForZone( zoneId )
        if entryId ~= nil 
        then
            -- some zones without zone control may use that space for something else
            -- such as Glyphs for the Necropolis of Zandri zone
            -- show locked/unlocked glyphs tracker for this zone where the zone control bar was
            GlyphDisplay.SetEntryID( EA_Window_WorldMap.GlyphData.instanceId, entryId )
            GlyphDisplay.Show( EA_Window_WorldMap.GlyphData.instanceId )
            LabelSetText( "EA_Window_WorldMapZoneViewZoneControlHeader",      GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_GLYPH_TRACKER_NAME ) )
            WindowSetShowing( "EA_Window_WorldMapZoneViewZoneControlHeader", true )
        else
            GlyphDisplay.Hide( EA_Window_WorldMap.GlyphData.instanceId )
            WindowSetShowing( "EA_Window_WorldMapZoneViewZoneControlHeader", false )
        end
    else
         GlyphDisplay.SetEntryID( EA_Window_WorldMap.GlyphData.instanceId, 0 )
         GlyphDisplay.Hide( EA_Window_WorldMap.GlyphData.instanceId )
         
         -- Show zone control bar if the zone is in the same tier and pairing as you
         local showZoneControl = true
         if ( zoneId ~= GameData.Player.zone )
         then
             local playerZoneData = GetCampaignZoneData( GameData.Player.zone )
             showZoneControl = ( playerZoneData and ( playerZoneData.tierId == zoneData.tierId ) and ( playerZoneData.pairingId == zoneData.pairingId ) )
         end
         
         if ( showZoneControl )
         then
             ThreePartBar.Show(EA_Window_WorldMap.ZoneControlData.barID)
             ThreePartBar.SetZone(EA_Window_WorldMap.ZoneControlData.barID, zoneId )
             LabelSetText( "EA_Window_WorldMapZoneViewZoneControlHeader",      GetStringFromTable("MapSystem", StringTables.MapSystem.LABEL_ZONE_CONTROL ) )
             WindowSetShowing( "EA_Window_WorldMapZoneViewZoneControlHeader", true )
         else
             ThreePartBar.Hide(EA_Window_WorldMap.ZoneControlData.barID)
             WindowSetShowing( "EA_Window_WorldMapZoneViewZoneControlHeader", false )
         end
    end
    
end

function EA_Window_WorldMap.OnWorldMapPointsLoaded( mapDisplay )
    if (mapDisplay == "EA_Window_WorldMapZoneViewMapDisplay") then
        -- Remove old transition points, text points, and objective timers
        EA_Window_WorldMap.ClearZoneTransitionPoints()
        EA_Window_WorldMap.ClearMapTextPoints()
        EA_Window_WorldMap.ClearObjectiveTimers()
        
        -- Add new transition points, text points, and objective timers
        EA_Window_WorldMap.CreateZoneTransitionPoints()
        EA_Window_WorldMap.CreateMapTextPoints()
        EA_Window_WorldMap.CreateObjectiveTimers()
        EA_Window_WorldMap.lastZoneContainingAddonPoints = EA_Window_WorldMap.currentMap
    end
end

function EA_Window_WorldMap.Update( timePassed )
    if (EA_Window_WorldMap.currentLevel == GameDefs.MapLevel.ZONE_MAP) then
        EA_Window_WorldMap.UpdateCoordinates()
        EA_Window_WorldMap.CountdownActiveObjectiveTimers( timePassed )
    end
end

----------------------------------------------------------------
-- Transition Points
----------------------------------------------------------------

function EA_Window_WorldMap.ClearZoneTransitionPoints()
    local parentWindow = "EA_Window_WorldMapZoneViewBorder"
    local zoneId = EA_Window_WorldMap.lastZoneContainingAddonPoints
    if (EA_Window_WorldMap.currentZoneTransitionPoints > 0) then
        for pointIndex = 1,EA_Window_WorldMap.currentZoneTransitionPoints do
            DestroyWindow(parentWindow.."TransitionPoint_"..zoneId.."_"..pointIndex)
        end
    end
    EA_Window_WorldMap.currentZoneTransitionPoints = 0
end

function doAnchors(trPointWindow, anPoint, maDisplay, relPos, anX, anY)
  if anX==nil then anX = 0 end
  if anY==nil then anY = 0 end
  WindowAddAnchor(trPointWindow, anPoint, maDisplay, relPos, anX, anY)
end

function EA_Window_WorldMap.CreateZoneTransitionPoints()
    local mapDisplay = "EA_Window_WorldMapZoneViewMapDisplay"
    local transitionPointData = GetZoneTransitionPoints( mapDisplay )
    local parentWindow = "EA_Window_WorldMapZoneViewBorder"
    local currentZoneId = EA_Window_WorldMap.currentMap
    local mapDisplayWidth, mapDisplayHeight = WindowGetDimensions( mapDisplay )
    
    for pointIndex, transitionPoint in ipairs(transitionPointData)
    do
        local transPointWindow = parentWindow.."TransitionPoint_"..currentZoneId.."_"..pointIndex
            
        -- Figure out which template to use and where to anchor it
        local templateName = ""
        local anchorPoint = ""
        local anchorX = 0
        local anchorY = 0
            
        if (transitionPoint.x == 0) then
            templateName = "ZoneTransitionPointWest"
            anchorPoint = "topleft"
            anchorX = -12 -- Minor adjustment to make it overlap the border better
            anchorY = (transitionPoint.y / 65535) * mapDisplayHeight
        elseif (transitionPoint.x == 65535) then
            templateName = "ZoneTransitionPointEast"
            anchorPoint = "topright"
            anchorX = 5 -- Minor adjustment to make it overlap the border better
            anchorY = (transitionPoint.y / 65535) * mapDisplayHeight
        elseif (transitionPoint.y == 0) then
            templateName = "ZoneTransitionPointNorth"
            anchorPoint = "topleft"
            anchorX = (transitionPoint.x / 65535) * mapDisplayWidth
            anchorY = -5 -- Minor adjustment to make it overlap the border better
        elseif (transitionPoint.y == 65535) then
            templateName = "ZoneTransitionPointSouth"
            anchorPoint = "bottomleft"
            anchorX = (transitionPoint.x / 65535) * mapDisplayWidth
            anchorY = 12 -- Minor adjustment to make it overlap the border better
        else
            -- Use north pointing arrow for points in middle of map
            templateName = "ZoneTransitionPointNorth"
            anchorPoint = "topleft"
            anchorX = (transitionPoint.x / 65535) * mapDisplayWidth
            anchorY = (transitionPoint.y / 65535) * mapDisplayHeight
        end
            
        CreateWindowFromTemplate(transPointWindow, templateName, parentWindow)
        doAnchors(transPointWindow, anchorPoint, mapDisplay, "center", anchorX, anchorY)
        WindowSetId(transPointWindow, transitionPoint.zone)
    end
    EA_Window_WorldMap.currentZoneTransitionPoints = #transitionPointData
end

----------------------------------------------------------------
-- Text Points
----------------------------------------------------------------

function EA_Window_WorldMap.ClearMapTextPoints()
    local zoneId = EA_Window_WorldMap.lastZoneContainingAddonPoints
    if (EA_Window_WorldMap.currentMapTextPoints > 0) then
        for pointIndex = 1,EA_Window_WorldMap.currentMapTextPoints do
            DestroyWindow("TextPoint_"..zoneId.."_"..pointIndex)
        end
    end
    EA_Window_WorldMap.currentMapTextPoints = 0
end

function EA_Window_WorldMap.CreateMapTextPoints()
    local mapDisplay = "EA_Window_WorldMapZoneViewMapDisplay"
    local textPointData = GetMapTextPoints( mapDisplay )
    local currentZoneId = EA_Window_WorldMap.currentMap
    
    for pointIndex, textPoint in ipairs(textPointData)
    do
        local textPointWindow = "TextPoint_"..currentZoneId.."_"..pointIndex
            
        local x, y = MapGetPointForCoordinates(mapDisplay, textPoint.x, textPoint.y)
        
        local align = ""
        local relPoint = ""
        if (textPoint.align == "center") then
            align = "center"
            relPoint = "top"
        elseif (textPoint.align == "right") then
            align = "right"
            relPoint = "topright"
        else
            align = "left"
            relPoint = "topleft"
        end
            
        CreateWindowFromTemplate(textPointWindow, "MapTextPoint", mapDisplay)
        doAnchors(textPointWindow, "topleft", mapDisplay, relPoint, x, y)
        LabelSetFont(textPointWindow, textPoint.font, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING)
        LabelSetTextColor(textPointWindow, textPoint.red, textPoint.green, textPoint.blue)
        LabelSetTextAlign(textPointWindow, align)
        LabelSetText(textPointWindow, GetStringFromTable("MapTextPoints", textPoint.id))
    end
    EA_Window_WorldMap.currentMapTextPoints = #textPointData
end

----------------------------------------------------------------
-- Battlefield Objective Timers
----------------------------------------------------------------

function EA_Window_WorldMap.ClearObjectiveTimers()
    local zoneId = EA_Window_WorldMap.lastZoneContainingAddonPoints
    for objectiveId, _ in pairs(EA_Window_WorldMap.activeObjectiveTimers) do
        DestroyWindow("ObjectiveTimer_"..zoneId.."_"..objectiveId)
    end
    for objectiveId, _ in pairs(EA_Window_WorldMap.inactiveObjectiveTimers) do
        DestroyWindow("ObjectiveTimer_"..zoneId.."_"..objectiveId)
    end
    
    EA_Window_WorldMap.activeObjectiveTimers = {}
    EA_Window_WorldMap.inactiveObjectiveTimers = {}
end

function EA_Window_WorldMap.CreateObjectiveTimers()
    local mapDisplay = "EA_Window_WorldMapZoneViewMapDisplay"
    local currentZoneId = EA_Window_WorldMap.currentMap
    if (currentZoneId == 0) then
        return
    end
    
    local objectivesData = nil

    --[[
    if GlyphDisplay.DoesZoneHaveZoneControl( currentZoneId ) 
    then
        objectivesData = GetZoneObjectivesData( currentZoneId )
    end
    d("world map window _ create timers")
    d(objectivesData)
    ]]--
    
    if (objectivesData ~= nil) then
        for _, objectivePoint in ipairs(objectivesData)
        do
            local objectiveTimerWindow = "ObjectiveTimer_"..currentZoneId.."_"..objectivePoint.objId
            
            local x, y = MapGetPointForCoordinates(mapDisplay, objectivePoint.objPositionX, objectivePoint.objPositionY)
            
            CreateWindowFromTemplate(objectiveTimerWindow, "ObjectiveMapTimer", mapDisplay)
            doAnchors(objectiveTimerWindow, "topleft", mapDisplay, "topleft", x, y)
            WindowSetId(objectiveTimerWindow, objectivePoint.objId)
        
            if (objectivePoint.objMapTimer > 0) then
                LabelSetText(objectiveTimerWindow, TimeUtils.FormatClock(objectivePoint.objMapTimer))
                EA_Window_WorldMap.activeObjectiveTimers[objectivePoint.objId] = objectivePoint.objMapTimer
            else
                WindowSetShowing(objectiveTimerWindow, false)
                EA_Window_WorldMap.inactiveObjectiveTimers[objectivePoint.objId] = 0
            end
        end
    end
end

function EA_Window_WorldMap.RefreshObjectiveTimers()
    local currentZoneId = EA_Window_WorldMap.currentMap
    if (currentZoneId == 0) then
        return
    end
    
    local objectivesData = GetZoneObjectivesData( currentZoneId )
    if (objectivesData ~= nil) then
        for _, objectivePoint in ipairs(objectivesData)
        do
            EA_Window_WorldMap.RefreshObjectiveTimer(objectivePoint.objId, objectivePoint.objMapTimer)
        end
    end
end

function EA_Window_WorldMap.RefreshObjectiveTimer(objectiveId, timeLeft)
    local objectiveTimerWindow = "ObjectiveTimer_"..EA_Window_WorldMap.currentMap.."_"..objectiveId
        
    if (EA_Window_WorldMap.activeObjectiveTimers[objectiveId] ~= nil) then
        if (timeLeft > 0) then
            LabelSetText(objectiveTimerWindow, TimeUtils.FormatClock(timeLeft))
            EA_Window_WorldMap.activeObjectiveTimers[objectiveId] = timeLeft
        else
            WindowSetShowing(objectiveTimerWindow, false)
            EA_Window_WorldMap.activeObjectiveTimers[objectiveId] = nil
            EA_Window_WorldMap.inactiveObjectiveTimers[objectiveId] = 0
        end
    elseif (EA_Window_WorldMap.inactiveObjectiveTimers[objectiveId] ~= nil) then
        if (timeLeft > 0) then
            WindowSetShowing(objectiveTimerWindow, true)
            LabelSetText(objectiveTimerWindow, TimeUtils.FormatClock(timeLeft))
            EA_Window_WorldMap.activeObjectiveTimers[objectiveId] = timeLeft
            EA_Window_WorldMap.inactiveObjectiveTimers[objectiveId] = nil
        end
    end
end

function EA_Window_WorldMap.CountdownActiveObjectiveTimers( timePassed )
    for objectiveId, currentTimer in pairs(EA_Window_WorldMap.activeObjectiveTimers) do
        local newTimer = currentTimer - timePassed
        if (newTimer > 0) then
            if (math.floor(newTimer + 0.5) < math.floor(currentTimer + 0.5)) then
                local objectiveTimerWindow = "ObjectiveTimer_"..EA_Window_WorldMap.currentMap.."_"..objectiveId
                LabelSetText(objectiveTimerWindow, TimeUtils.FormatClock(newTimer))
            end
            EA_Window_WorldMap.activeObjectiveTimers[objectiveId] = newTimer
        else
            local objectiveTimerWindow = "ObjectiveTimer_"..EA_Window_WorldMap.currentMap.."_"..objectiveId
            WindowSetShowing(objectiveTimerWindow, false)
            EA_Window_WorldMap.activeObjectiveTimers[objectiveId] = nil
            EA_Window_WorldMap.inactiveObjectiveTimers[objectiveId] = 0
        end
    end
end

function EA_Window_WorldMap.OnObjectiveTimerUpdated(objectiveId, timeLeft)
    if (WindowGetShowing("EA_Window_WorldMap") and (EA_Window_WorldMap.currentLevel == GameDefs.MapLevel.ZONE_MAP)) then
        EA_Window_WorldMap.RefreshObjectiveTimer(objectiveId, timeLeft)
    end
end
    
----------------------------------------------------------------
-- Overlay Control and Pin Filtering
----------------------------------------------------------------
function EA_Window_WorldMap.TogglePinFilter()
    
    local filterType = WindowGetId(SystemData.ActiveWindow.name)
    local showPin = not EA_Window_WorldMap.Settings.filterCategories[ filterType ]

    -- Set The Category Button
    EA_Window_WorldMap.Settings.filterCategories[ filterType ] = showPin
    ButtonSetPressedFlag( SystemData.ActiveWindow.name.."CheckBox", showPin )
        
    -- Set the Map Pins Filters
    local category = EA_Window_WorldMap.filterCategories[filterType]
    for _, pinType in pairs( category.filterTypes )
    do        
        MapSetPinFilter("EA_Window_WorldMapZoneViewMapDisplay", pinType, showPin )        
        EA_Window_WorldMap.Settings.mapPinFilters[ pinType ] = showPin
    end      
    
    
            
    -- Notify the Tome that this map has been viewed.       
    if (EA_Window_WorldMap.currentLevel == GameDefs.MapLevel.ZONE_MAP) 
    then
        if( WindowGetShowing( "EA_Window_WorldMap")  == true ) 
        then
            EA_Window_WorldMap.SetRvRStatusZone( mapIndex )
            TomeWindow.OnViewEntry( GameData.Tome.SECTION_ZONE_MAPS, mapIndex )
        end
    end
    
end

----------------------------------------------------------------
-- Coordinate Updates
----------------------------------------------------------------
function EA_Window_WorldMap.UpdateCoordinates()
    local mapPositionX, mapPositionY = WindowGetScreenPosition("EA_Window_WorldMapZoneViewMapDisplay")
    local resolutionScale = InterfaceCore.GetResolutionScale()
    local x, y = MapGetCoordinatesForPoint("EA_Window_WorldMapZoneViewMapDisplay",
                                           (SystemData.MousePosition.x - mapPositionX) / resolutionScale,
                                           (SystemData.MousePosition.y - mapPositionY) / resolutionScale)
        
    if (x == nil) then
        x = L"-"
    end
        
    if (y == nil) then
        y = L"-"
    end
        
    LabelSetText("EA_Window_WorldMapZoneViewCoordinates", L""..x..L", "..y)
end

----------------------------------------------------------------
-- Zone Control
----------------------------------------------------------------
function EA_Window_WorldMap.InitializeZoneControl()

    EA_Window_WorldMap.ZoneControlData.zone  = 0
    EA_Window_WorldMap.ZoneControlData.barID = ThreePartBar.Create( "EA_Window_WorldMapZoneViewZoneControlBar", 
                                                                "EA_Window_WorldMapZoneViewZoneControlContainer",                                                                  
                                                                false, nil )
                                                                
end

function EA_Window_WorldMap.ShutdownZoneControl()
    ThreePartBar.Destroy(EA_Window_WorldMap.ZoneControlData.barID)
end

function EA_Window_WorldMap.SetRvRStatusZone( zoneNumber )
    EA_Window_WorldMap.ZoneControlData.zone = zoneNumber
end

----------------------------------------------------------------
-- Glyph Display
----------------------------------------------------------------

function EA_Window_WorldMap.InitializeGlyphDisplay()

    EA_Window_WorldMap.GlyphData.instanceId = GlyphDisplay.Create( "EA_Window_WorldMapZoneViewGlyphTracker", 
                                                                "EA_Window_WorldMapZoneViewGlyphContainer",                                                                  
                                                                nil )

end

function EA_Window_WorldMap.ShutdownGlyphDisplay()
    GlyphDisplay.Destroy(EA_Window_WorldMap.GlyphData.instanceId)
end
----------------------------------------------------------------
-- Quest Tracker
----------------------------------------------------------------
function EA_Window_WorldMap.InitializeQuestTracker()

    EA_Window_WorldMap.questTrackerWindowCount = 0    
    EA_Window_WorldMap.ShowQuests( GameData.Player.zone )
    
end

function EA_Window_WorldMap.UpdateQuestTracker( timePassed )

    -- Update the timers
   for index, data in ipairs( EA_Window_WorldMap.currentQuestData ) do		
        if( data.hasTimer ) then		
            -- Timers are decremented by Data Utils
            local questData = DataUtils.GetQuestData( data.questId )			                    
            local time = TimeUtils.FormatClock( questData.timeLeft )    
            LabelSetText( "EA_Window_WorldMapZoneViewQuestTrackerData"..index.."TimerValue", time )
        end
   end 

end

function EA_Window_WorldMap.ShowQuests( zoneNum )

    EA_Window_WorldMap.activeQuestZone = zoneNum

    -- Build a list of all the quests in this zone.    
    EA_Window_WorldMap.currentQuestData = {}
    
    local quests = DataUtils.GetQuests()
    for index, questData in ipairs( quests ) do        
        for zoneIndex, zoneData in ipairs( questData.zones ) do
            if( zoneData.id == zoneNum ) then
                table.insert( EA_Window_WorldMap.currentQuestData, questData ) 
            end
        end    
    end        
    table.sort( EA_Window_WorldMap.currentQuestData, DataUtils.AlphabetizeByNames )   
    

    
    -- Updates the Quest List to show all the Quests in the zone.
    local questTrackerCount = 0
    

    local parentWindow = "EA_Window_WorldMapZoneViewQuestTrackerContentsChild"
    local anchorWindow = "EA_Window_WorldMapZoneViewQuestTrackerContentsChildDataAnchor"
    local xOffset = 0
    local yOffset = 20

    for questIndex, questData in ipairs( EA_Window_WorldMap.currentQuestData ) do               
        
        questTrackerCount = questTrackerCount + 1                       
        
        -- Create the Tracker window if necessary
        local trackerWindowName = parentWindow.."Data"..questTrackerCount
        if( EA_Window_WorldMap.questTrackerWindowCount < questTrackerCount ) then
        
            CreateWindowFromTemplate( trackerWindowName, "ParchmentQuestTrackerData", parentWindow )
            WindowSetScale( trackerWindowName, EA_Window_WorldMap.GetResolutionScale() )   
                             
            doAnchors( trackerWindowName, "bottomleft", anchorWindow, "topleft", xOffset, 0 )

            EA_Window_WorldMap.questTrackerWindowCount = EA_Window_WorldMap.questTrackerWindowCount + 1
            
        end
            
        anchorWindow = trackerWindowName            
            
        -- Set the Data    
        EA_Window_WorldMap.SetQuestTrackerData( trackerWindowName, questData )
                        
   end
                
   -- Show/Hide the appropriate number of Quest Tracker windows.
   for index = 1, EA_Window_WorldMap.questTrackerWindowCount do
        local show = index <= questTrackerCount
        local windowName = parentWindow.."Data"..index
        if( WindowGetShowing(windowName ) ~= show ) then
            WindowSetShowing(windowName, show ) 
        end
    end    
    
    
    PageWindowUpdatePages( "EA_Window_WorldMapZoneViewQuestTracker" )   
    EA_Window_WorldMap.UpdateQuestTrackerNavButtons()
end


function EA_Window_WorldMap.SetQuestTrackerData( trackerWindowName, questData )


    local questDataHeight = 20

    -- Set the Id
    WindowSetId( trackerWindowName, questData.id )

    -- Set the Quest Name
    ButtonSetText(trackerWindowName.."Name", questData.name )
    local x, y = WindowGetDimensions( trackerWindowName.."Name" )
    questDataHeight = questDataHeight + y
        
    -- Set the Timer
    if( questData.maxTimer ~= 0 ) then                
        
        local time = TimeUtils.FormatClock( questData.timeLeft )
        LabelSetText( trackerWindowName.."TimerValue", time )        
        WindowSetShowing( trackerWindowName.."TimerValue", true )
        
        WindowSetShowing( trackerWindowName.."ClockImage", true )
        
        LabelSetText( trackerWindowName.."TimerName", L"" )           

    else            
        LabelSetText( trackerWindowName.."TimerValue", L"" )      
        LabelSetText( trackerWindowName.."TimerName", L"" )
        WindowSetShowing( trackerWindowName.."TimerValue", false )  
        WindowSetShowing( trackerWindowName.."ClockImage", false )
    end


    -- Set the Conditions Text
    local conditionsText = L""
    for condition, conditionData in ipairs(questData.conditions)
    do

        local conditionName = questData.conditions[condition].name
        local curCounter    = questData.conditions[condition].curCounter
        local maxCounter    = questData.conditions[condition].maxCounter
        
        -- Add a newline if this is not the first condition
        if( conditionsText ~= L"" )
        then
            conditionsText = conditionsText..L"\n"
        end            
            
        -- Append the condition name    
        conditionsText = conditionsText..conditionName
        
        -- Append the condition counter when applicable
        if( maxCounter > 0 ) 
        then
            conditionsText = conditionsText..L" - "..curCounter..L"/"..maxCounter
        end
    end
    
    LabelSetText( trackerWindowName.."ConditionsText", conditionsText )
    local x, y = WindowGetDimensions( trackerWindowName.."ConditionsText" )
    questDataHeight = questDataHeight + y  
    

    -- Size the Quest trackerWindowName
    local x, y = WindowGetDimensions( trackerWindowName )    
    WindowSetDimensions( trackerWindowName, x, questDataHeight )            
 
    -- Set the Icon
    QuestUtils.SetCompletionIcon( questData, trackerWindowName.."Complete" )

    -- Set the Track Button
    ButtonSetPressedFlag(trackerWindowName.."TrackToggle", questData.tracking )
    
    -- Set the Map Button
    ButtonSetPressedFlag(trackerWindowName.."MapToggle", questData.trackingPin )

end


-- Quest Navigation

function EA_Window_WorldMap.UpdateQuestTrackerNavButtons()

    local viewWindow = "EA_Window_WorldMapZoneView"

    local curPage   = PageWindowGetCurrentPage( viewWindow.."QuestTracker" )
    local numPages  = PageWindowGetNumPages( viewWindow.."QuestTracker" )
    
    -- Update the Text
    local text = GetStringFormatFromTable( "MapSystem", StringTables.MapSystem.LABEL_PAGE_X_OF_Y, { L""..curPage, L""..numPages } ) 
    LabelSetText( viewWindow.."QuestTrackerPageText", text )
    
    -- Enabe/Disable the Buttons
    ButtonSetDisabledFlag( viewWindow.."QuestTrackerPreviousPageButton", curPage == 1 )
    ButtonSetDisabledFlag( viewWindow.."QuestTrackerNextPageButton", curPage >= numPages ) 
end

function EA_Window_WorldMap.OnMouseOverQuestTrackerPreviousPage()
    local text = GetStringFromTable("MapSystem", StringTables.MapSystem.TOOL_TIP_PREVIOUS_QUESTS )
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, text )
    Tooltips.AnchorTooltip(Tooltips.ANCHOR_WINDOW_RIGHT)
end

function EA_Window_WorldMap.OnQuestTrackerPreviousPage()

    if( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) )
    then
        return;
    end

    local viewWindow = "EA_Window_WorldMapZoneView"
    local curPage   = PageWindowGetCurrentPage( viewWindow.."QuestTracker" )
    
    PageWindowSetCurrentPage( viewWindow.."QuestTracker", curPage-1 )
    
    EA_Window_WorldMap.UpdateQuestTrackerNavButtons()
end

function EA_Window_WorldMap.OnMouseOverQuestTrackerNextPage()
    local text = GetStringFromTable("MapSystem", StringTables.MapSystem.TOOL_TIP_MORE_QUESTS )
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, text )
    Tooltips.AnchorTooltip(Tooltips.ANCHOR_WINDOW_LEFT)
end

function EA_Window_WorldMap.OnQuestTrackerNextPage()

    if( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) )
    then
        return;
    end
    
    local viewWindow = "EA_Window_WorldMapZoneView"
    local curPage   = PageWindowGetCurrentPage( viewWindow.."QuestTracker" )
    
    PageWindowSetCurrentPage( viewWindow.."QuestTracker", curPage+1 )
    
    EA_Window_WorldMap.UpdateQuestTrackerNavButtons()
end


-- Updates the entire list
function EA_Window_WorldMap.OnQuestListUpdated()      
   --DEBUG(L"EA_Window_WorldMap.OnQuestListUpdated() ")
    if (EA_Window_WorldMap.currentLevel == GameDefs.MapLevel.ZONE_MAP) then    
        EA_Window_WorldMap.ShowQuests( EA_Window_WorldMap.activeQuestZone )    
    end    
    
end

function EA_Window_WorldMap.OnQuestUpdated( )
    
    if (EA_Window_WorldMap.currentLevel == GameDefs.MapLevel.ZONE_MAP) then
        local questId = GameData.Player.Quests.updatedQuest
        --DEBUG(L" QuestTrackerWindow.OnQuestUpdated - QuestId = "..questId )

        -- Find the index in the display
        for index, data in ipairs( EA_Window_WorldMap.currentQuestData ) do		
            if( data.questId == questId ) then
                EA_Window_WorldMap.UpdateQuestTracker( index )
                
                return
            end
       end 
    end
    
end

function EA_Window_WorldMap.UpdateQuestTracker( quest )
    if (EA_Window_WorldMap.currentQuestData[quest] ~= nil) then
        local targetWindow = "EA_Window_WorldMapZoneViewQuestTrackerData"..quest
        QuestUtils.SetQuestTrackerData( targetWindow, EA_Window_WorldMap.currentQuestData[quest] )                                                                                                                     
    end
end

function EA_Window_WorldMap.OnMouseOverToggleTrackQuest()
    local text = GetString( StringTables.Default.TEXT_TOGGLE_TRACK_QUEST )
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, text )
    Tooltips.AnchorTooltip(Tooltips.ANCHOR_WINDOW_TOP)
end

function EA_Window_WorldMap.ToggleTrackQuest()
    local questId = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
    QuestUtils.ToggleTrackQuest( questId )
end

function EA_Window_WorldMap.ToggleTrackQuestMapPin()
    local questId = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
    QuestUtils.ToggleTrackQuestMapPin( questId ) 
end

function EA_Window_WorldMap.OnMouseOverToggleTrackQuestMapPin()
    local text = GetString( StringTables.Default.TEXT_TOGGLE_TRACK_QUEST_MAP )
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, text )
    Tooltips.AnchorTooltip(Tooltips.ANCHOR_WINDOW_TOP)
end


function EA_Window_WorldMap.ShowQuestConditions()

end


function EA_Window_WorldMap.HideQuestConditions()

end

function EA_Window_WorldMap.OnMouseOverQuest()
    local trackerName = SystemData.ActiveWindow.name
    local questId = WindowGetId( trackerName ) 
    QuestUtils.MouseOverQuestTracker( trackerName, questId )
end

function EA_Window_WorldMap.OnMouseOverQuestName()
    local trackerName = WindowGetParent( SystemData.ActiveWindow.name )
    local questId = WindowGetId( trackerName ) 
    QuestUtils.MouseOverQuestTracker( trackerName, questId )
end

function EA_Window_WorldMap.OnClickQuestName()
    local trackerName = WindowGetParent( SystemData.ActiveWindow.name )
    local questId = WindowGetId( trackerName ) 
    QuestUtils.OpenTomeForQuest( questId )
end
