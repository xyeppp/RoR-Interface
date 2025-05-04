----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_WorldMap = {}
EA_Window_WorldMap.ZoneControlData = { }
EA_Window_WorldMap.GlyphData = { }

EA_Window_WorldMap.FADE_TIME = 1.0

EA_Window_WorldMap.currentLevel = 0
EA_Window_WorldMap.currentMap   = 0

EA_Window_WorldMap.viewWindows = { }
EA_Window_WorldMap.viewWindows[GameDefs.MapLevel.WORLD_MAP]   = "EA_Window_WorldMapWorldView"
EA_Window_WorldMap.viewWindows[GameDefs.MapLevel.PAIRING_MAP] = "EA_Window_WorldMapPairingView"
EA_Window_WorldMap.viewWindows[GameDefs.MapLevel.ZONE_MAP]    = "EA_Window_WorldMapZoneView"


EA_Window_WorldMap.viewButtons = { }
EA_Window_WorldMap.viewButtons[GameDefs.MapLevel.WORLD_MAP]   = "EA_Window_WorldMapViewModesWorldButton"
EA_Window_WorldMap.viewButtons[GameDefs.MapLevel.PAIRING_MAP] = "EA_Window_WorldMapViewModesPairingButton"
EA_Window_WorldMap.viewButtons[GameDefs.MapLevel.ZONE_MAP]    = "EA_Window_WorldMapViewModesZoneButton"


EA_Window_WorldMap.MAX_TRACKED_QUESTS = 10
EA_Window_WorldMap.currentQuestData = {}

EA_Window_WorldMap.childMapList   = {}
EA_Window_WorldMap.siblingMapList = {}


EA_Window_WorldMap.questTrackerWindowCount = 0
EA_Window_WorldMap.activeQuestZone = 0


EA_Window_WorldMap.TombKingsQuestWindowID = nil

---------------------------------------------------------------
-- Saved Variables
----------------------------------------------------------------
EA_Window_WorldMap.Settings = {}


----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

----------------------------------------------------------------
-- EA_Window_WorldMap Functions
----------------------------------------------------------------

-- OnInitialize Handler
function EA_Window_WorldMap.Initialize()


    WindowRegisterEventHandler( "EA_Window_WorldMap", SystemData.Events.RESOLUTION_CHANGED,       "EA_Window_WorldMap.OnResolutionChange" )
    WindowRegisterEventHandler( "EA_Window_WorldMap", SystemData.Events.CUSTOM_UI_SCALE_CHANGED,  "EA_Window_WorldMap.OnResolutionChange" )
    WindowRegisterEventHandler( "EA_Window_WorldMap", SystemData.Events.PLAYER_ZONE_CHANGED,      "EA_Window_WorldMap.OnPlayerZoneChanged")
    WindowRegisterEventHandler( "EA_Window_WorldMap", SystemData.Events.QUEST_LIST_UPDATED,       "EA_Window_WorldMap.OnQuestListUpdated")
    WindowRegisterEventHandler( "EA_Window_WorldMap", SystemData.Events.QUEST_INFO_UPDATED,       "EA_Window_WorldMap.OnQuestUpdated")
    RRQProgressBar.AddListener( EA_Window_WorldMap.OnRRQsUpdated )

    -- Set the Button States
    for _, buttonName in pairs( EA_Window_WorldMap.viewButtons )
    do
        ButtonSetStayDownFlag( buttonName, true ) 
    end


    EA_Window_WorldMap.InitializeZoneView()
    EA_Window_WorldMap.InitializePairingView()
    EA_Window_WorldMap.InitializeWorldView()
    
    
    EA_Window_WorldMap.OnResolutionChange()
    
    EA_Window_WorldMap.OnRRQsUpdated()
end

function EA_Window_WorldMap.GetResolutionScale()
    local screenWidth, screenHeight = GetScreenResolution()
    local scaleX = screenWidth / InterfaceCore.artResolution.x
    local scaleY = screenHeight / InterfaceCore.artResolution.y
    return math.min(scaleX, scaleY)
end

function EA_Window_WorldMap.OnResolutionChange()
    WindowSetScale( "EA_Window_WorldMap", EA_Window_WorldMap.GetResolutionScale() )
end

-- OnShutdown Handler
function EA_Window_WorldMap.Shutdown()
    
    EA_Window_WorldMap.ShutdownZoneView()
    EA_Window_WorldMap.ShutdownPairingView()
    EA_Window_WorldMap.ShutdownWorldView()
end

function EA_Window_WorldMap.OnShown()

    -- DEBUG(L"EA_Window_WorldMap.OnShown(), currentLevel = "..EA_Window_WorldMap.currentLevel)
    -- DEBUG(L"  Player Zone = "..GameData.Player.zone )

    -- start on zone-level map the player is in when opened
    EA_Window_WorldMap.SetMap( GameDefs.MapLevel.ZONE_MAP, GameData.Player.zone )
            
    ScreenFlashWindow.SetEnabled( true )
    WindowUtils.OnShown()
end

function EA_Window_WorldMap.OnHidden()    
    ScreenFlashWindow.SetEnabled( false )
    WindowUtils.OnHidden()
end


----------------------------------------------------------------
-- Input Handlers
----------------------------------------------------------------
function EA_Window_WorldMap.Hide()
    BroadcastEvent( SystemData.Events.TOGGLE_WORLD_MAP_WINDOW )
end

function EA_Window_WorldMap.HandleMouseWheel(x, y, delta, flags)
    -- DEBUG(L"EA_Window_WorldMap.HandleMouseWheel("..delta..L", "..x..L", "..y..L")")
    if (delta < 0) then
        EA_Window_WorldMap.ZoomOut()
    elseif (delta > 0) then
        EA_Window_WorldMap.ZoomIn()
    end
end

function EA_Window_WorldMap.OnPlayerZoneChanged()

    -- If the player zones viewing the current zone map, update the map to the new zone.
    
    if( EA_Window_WorldMap.currentLevel == GameDefs.MapLevel.ZONE_MAP) 
    then
        EA_Window_WorldMap.SetMap(GameDefs.MapLevel.ZONE_MAP, GameData.Player.zone )
    
    elseif (EA_Window_WorldMap.currentLevel == GameDefs.MapLevel.PAIRING_MAP) 
    then
        EA_Window_WorldMap.UpdatePairingMapCurrentZoneMarker()
    end
    
end

----------------------------------------------------------------
-- Master Navigation
----------------------------------------------------------------
function EA_Window_WorldMap.SetMap( mapLevel, mapIndex )

    --DEBUG(L"EA_Window_WorldMap.SetMap( "..mapLevel..L", "..mapIndex..L" )")
    --DEBUG(L"  currently showing level "..(EA_Window_WorldMap.currentLevel)..L" map "..EA_Window_WorldMap.currentMap)

    -- If nil, do nothing
    if ( (mapLevel == nil) or (mapIndex == nil) ) 
    then
        ERROR( L"EA_Window_WorldMap.SetMap(): Invalid Params" )
        return
    end
    
    -- If we don't have a view for this level, ignore.
    if( EA_Window_WorldMap.viewWindows[ mapLevel ] == nil )
    then
        ERROR( L"EA_Window_WorldMap.SetMap(): Invalid Map Level" )
        return
    end
    
    -- If no change
    if (EA_Window_WorldMap.currentLevel == mapLevel) and
       (EA_Window_WorldMap.currentMap   == mapIndex) 
    then
        if( EA_Window_WorldMap.currentLevel == GameDefs.MapLevel.ZONE_MAP ) then
            EA_Window_WorldMap.RefreshObjectiveTimers()
        end
        
        return
    end
    
    -- Assign the new map
    EA_Window_WorldMap.currentLevel = mapLevel
    EA_Window_WorldMap.currentMap = mapIndex
      
    if( EA_Window_WorldMap.currentLevel == GameDefs.MapLevel.ZONE_MAP )
    then    
        EA_Window_WorldMap.ShowZone( EA_Window_WorldMap.currentMap )       
    elseif( EA_Window_WorldMap.currentLevel == GameDefs.MapLevel.PAIRING_MAP )
    then    
        EA_Window_WorldMap.ShowPairing( EA_Window_WorldMap.currentMap )
    end   
       
    -- Show only the appropriate view
    for index, windowName in pairs( EA_Window_WorldMap.viewWindows )
    do
        WindowSetShowing( windowName, index == EA_Window_WorldMap.currentLevel )
    end
    
    -- Set the Button States
    for index, buttonName in pairs( EA_Window_WorldMap.viewButtons )
    do
        ButtonSetPressedFlag( buttonName, index == EA_Window_WorldMap.currentLevel ) 
    end

    -- this will show or hide the RRQ Bars/ HUD toggle based on whether we have an RRQ
    -- and whether we are on the correct map level or pairing
    EA_Window_WorldMap.OnRRQsUpdated()
end


----------------------------------------------------------------
-- View Mode Navigation
-----------------------------------------------------------------

function EA_Window_WorldMap.OnClickViewZoneMapButton()
    if( EA_Window_WorldMap.currentLevel == GameDefs.MapLevel.ZONE_MAP )
    then
        return
    end
    
    local playerMaps = MapGetPlayerLocationMaps()
    local newZoom = GameDefs.MapLevel.ZONE_MAP
  
    if (playerMaps[newZoom] ~= nil) then
        EA_Window_WorldMap.SetMap(newZoom, playerMaps[newZoom])
    end
end

function EA_Window_WorldMap.OnMouseOverViewZoneMapButton()
    local text = GetStringFromTable("MapSystem", StringTables.MapSystem.TOOLTIP_ZONE_MAP_BUTTON ) 
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, text )
    Tooltips.AnchorTooltip(Tooltips.ANCHOR_WINDOW_TOP)
end

function EA_Window_WorldMap.OnClickViewPairingMapButton()
     if( EA_Window_WorldMap.currentLevel == GameDefs.MapLevel.PAIRING_MAP )
    then
        return
    end
    
    if( EA_Window_WorldMap.currentLevel == GameDefs.MapLevel.ZONE_MAP )
    then
        EA_Window_WorldMap.ZoomOut()    
        return
    end

    if( EA_Window_WorldMap.currentLevel == GameDefs.MapLevel.WORLD_MAP )
    then
        EA_Window_WorldMap.ZoomIn()    
        return
    end
end

function EA_Window_WorldMap.OnMouseOverViewPairingMapButton()
    local text = GetStringFromTable("MapSystem", StringTables.MapSystem.TOOLTIP_PAIRING_MAP_BUTTON ) 
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, text )
    Tooltips.AnchorTooltip(Tooltips.ANCHOR_WINDOW_TOP)
end


function EA_Window_WorldMap.OnClickViewWorldMapButton()
    if( EA_Window_WorldMap.currentLevel == GameDefs.MapLevel.WORLD_MAP )
    then
        return
    end

    EA_Window_WorldMap.SetMap(GameDefs.MapLevel.WORLD_MAP, 1)  
end

function EA_Window_WorldMap.OnMouseOverViewWorldMapButton()
    local text = GetStringFromTable("MapSystem", StringTables.MapSystem.TOOLTIP_WORLD_MAP_BUTTON ) 
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, text )
    Tooltips.AnchorTooltip(Tooltips.ANCHOR_WINDOW_TOP)
end



function EA_Window_WorldMap.ZoomIn()
    -- We're zooming to the child map which we're in.
    local playerMaps = MapGetPlayerLocationMaps()
    local newZoom = EA_Window_WorldMap.currentLevel+1

    if (newZoom <= GameDefs.MapLevel.ZONE_MAP and playerMaps[newZoom] ~= nil) then
        EA_Window_WorldMap.SetMap(newZoom, playerMaps[newZoom])
    end
end

function EA_Window_WorldMap.ZoomOut()
    local parentMap = MapGetParentMap(EA_Window_WorldMap.currentLevel, EA_Window_WorldMap.currentMap)
    
    if (parentMap ~= nil and parentMap.mapLevel ~= nil and parentMap.mapNumber ~= nil) then
        EA_Window_WorldMap.SetMap(parentMap.mapLevel, parentMap.mapNumber)
    end
end

function EA_Window_WorldMap.CreateAppropriateZoneTooltip( zoneId, anchor, clickText )

    -- Find out if it is a normal zone, city, or fort -- we have different types of tooltips for each
    local iconType = nil
    local pairingNum = 0
    for index, pairingData in pairs(EA_Window_WorldMap.pairingMapZones) do
        iconType = pairingData[zoneId]
        if (iconType ~= nil) then
            pairingNum = index
            break
        end
    end
    
    if (iconType ~= nil) then
        -- no rvr campaign data for TK zones (GetCampaignZoneData), but we can still use the RRQ
        if not EA_Window_WorldMap.pairingHasZoneControl[pairingNum]
        then
            if pairingNum == GameData.ExpansionMapRegion.TOMB_KINGS
            then
                -- zone control is different for Tomb Kings
                local controllingRealm = GameData.Realm.NONE
                local rrqData = RRQProgressBar.GetFirstQuestDataOfType(GameData.RRQDisplayType.ERRQDISPLAY_TOMB_KINGS)
                if rrqData ~= nil and rrqData.realmWithAccess > 0 then
                    controllingRealm = rrqData.realmWithAccess
                end
                Tooltips.CreatePairingMapZoneTooltip( controllingRealm,
                                                      GetZoneName( zoneId ),
                                                      1,
                                                      GetZoneRanksForCurrentRealm( zoneId ),
                                                      SystemData.ActiveWindow.name,
                                                      nil )
            end

            return 
        end
    
        
        if ((iconType == EA_Window_WorldMap.ICON_ZONE) or (iconType == EA_Window_WorldMap.ICON_ZONE_MINI)) then
		
			local zoneData = GetCampaignZoneData( zoneId )    
			if (zoneData == nil)
			then
				return
			end
			
            Tooltips.CreatePairingMapZoneTooltip( zoneData.controllingRealm,
                                                  GetZoneName( zoneId ),
                                                  zoneData.tierId,
                                                  GetZoneRanksForCurrentRealm( zoneId ),
                                                  SystemData.ActiveWindow.name,
                                                  anchor,
                                                  clickText )
        elseif ((iconType == EA_Window_WorldMap.ICON_FORT) or (iconType == EA_Window_WorldMap.ICON_FORT_MINI)) then
		
			local zoneData = GetCampaignZoneData( zoneId )    
			if (zoneData == nil)
			then
				return
			end
			
            local timeLeft = 0
            local pairingData = GetCampaignPairingData(EA_Window_WorldMap.currentPairing)
            if (pairingData ~= nil) then
                if ((pairingData.captureTimeRemaining > 0) and (pairingData.controllingRealm ~= zoneData.initialRealm)) then
                    timeLeft = pairingData.captureTimeRemaining
                elseif ((pairingData.fortressPQTimeRemaining > 0) and (pairingData.contestedZone == zoneId)) then
                    timeLeft = pairingData.fortressPQTimeRemaining
                end
            end
            Tooltips.CreatePairingMapFortTooltip( zoneData.pairingId,
                                                  zoneData.initialRealm,
                                                  zoneData.controllingRealm,
                                                  GetZoneName( zoneId ),
                                                  GetZoneRanksForCurrentRealm( zoneId ),
                                                  timeLeft,
                                                  SystemData.ActiveWindow.name,
                                                  anchor,
                                                  clickText )
        elseif ((iconType == EA_Window_WorldMap.ICON_CITY) or (iconType == EA_Window_WorldMap.ICON_CITY_MINI)) then
            
            local zoneIdForRanks = zoneId
			local cityRatingTimeLeft = 0
            local citySiegeTimeLeft = 0
			local cityControllingRealm = GameData.Realm.DESTRUCTION;
			local citySiegeStatus = RoR_CitySiege.GetCity(GameDefs.ZoneCityIds[zoneId]);
            local cityState = SystemData.CityStates.NONE
			
            if (citySiegeStatus ~= nil) then
                cityRatingTimeLeft = citySiegeStatus.ratingTimer
                citySiegeTimeLeft = citySiegeStatus.timeLeft
				cityControllingRealm = citySiegeStatus.controllingRealm;
				cityState = citySiegeStatus.state
				
				-- zoneId is always the peaceful version. If the city is contested, we must translate it into the contested zone ID.
				if (citySiegeStatus.controllingRealm ~= citySiegeStatus.initialRealm) then
					zoneIdForRanks = MapUtils.GetContestedCityZoneFromPeacefulZone(zoneId)
				end
            end
			            
            Tooltips.CreatePairingMapCityTooltip( cityControllingRealm,
                                                  GetZoneName( zoneId ),
                                                  GetZoneRanksForCurrentRealm( zoneIdForRanks ),
                                                  cityRatingTimeLeft,
                                                  citySiegeTimeLeft,
                                                  cityState,
                                                  GameDefs.ZoneCityIds[zoneId],
                                                  SystemData.ActiveWindow.name,
                                                  anchor,
                                                  clickText )
        end
    end
end

--manages setting up the RRQ tracking window elements, but only when there's actually an ongoing RRQ
function EA_Window_WorldMap.OnRRQsUpdated()

    local bShow = false

    -- Tomb Kings tracker on the bottom-right
    rrqData = RRQProgressBar.GetFirstQuestDataOfType(GameData.RRQDisplayType.ERRQDISPLAY_TOMB_KINGS)
    if rrqData ~= nil
    then
        -- lazy window creation, so make sure it exists and create if we need to
        if not DoesWindowExist("EA_Window_WorldMapTombKingsBarContainerStatus")
        then
            -- setup Realm Resource Quest Status Window
            EA_Window_WorldMap.TombKingsQuestWindowID = RRQProgressBar.Create( "EA_Window_WorldMapTombKingsBarContainerStatus", 
                                                                                "EA_Window_WorldMapTombKingsBarContainer",
                                                                                rrqData.displayType)
                                                                                
            --HUD RRQ tracker options, like RvR Campaign tracker
            LabelSetText( "EA_Window_WorldMapTombKingsTrackerToggleName",   GetStringFromTable("WorldControl", StringTables.WorldControl.LABEL_TOGGLE_RRQ)  )
        end

        if not (RRQProgressBar.GetRRQuestIDfromWindowID( EA_Window_WorldMap.TombKingsQuestWindowID ) == rrqData.rrquestID)
        then
            RRQProgressBar.SetRRQuestID( EA_Window_WorldMap.TombKingsQuestWindowID, rrqData.rrquestID )
        end
        
        if ( EA_Window_WorldMap.currentPairing == GameData.ExpansionMapRegion.TOMB_KINGS )
        then
            EA_Window_WorldMap.UpdatePairingZoneIcons( EA_Window_WorldMap.currentPairing )
        end
        
        -- we only want this visible if there is currently an ongoing RRQ
        bShow = true
    end
    
    -- also, only show on certain views like World Map or Tomb Kings pairing
    bShow = bShow and EA_Window_WorldMap.ShouldShowRRQ()
    WindowSetShowing("EA_Window_WorldMapTombKingsBarContainer", bShow)
    WindowSetShowing("EA_Window_WorldMapTombKingsTrackerToggle", bShow)
    
end

function EA_Window_WorldMap.UpdateRRQTrackerButton()

    local showing = not LayoutEditor.IsWindowUserHidden( "EA_Window_RRQTracker" )
    ButtonSetPressedFlag( "EA_Window_WorldMapTombKingsTrackerToggleCheckBox", showing )
end

function EA_Window_WorldMap.ToggleHUDRRQTracker()
    local shouldShow = LayoutEditor.IsWindowUserHidden( "EA_Window_RRQTracker" )
    if ( shouldShow )
    then
        LayoutEditor.UserShow( "EA_Window_RRQTracker" )
    else
        LayoutEditor.UserHide( "EA_Window_RRQTracker" )
    end
    EA_Window_WorldMap.UpdateRRQTrackerButton()
end

-- only show the Tomb Kings realm resource quest elements when looking at the World Map, TK Pairing, or TK zone maps
function EA_Window_WorldMap.ShouldShowRRQ()
    if ( EA_Window_WorldMap.currentLevel == GameDefs.MapLevel.WORLD_MAP or 
        ( EA_Window_WorldMap.currentLevel == GameDefs.MapLevel.PAIRING_MAP ) or 
        EA_Window_WorldMap.currentLevel == GameDefs.MapLevel.ZONE_MAP and EA_Window_WorldMap.currentMap == 191 )
    then
        return true
    end
    -- also show for any zone whose parent map is the Land of the Dead pairing map. Such as, TK lair instances
    local parentMap = MapGetParentMap(EA_Window_WorldMap.currentLevel, EA_Window_WorldMap.currentMap)
    if parentMap ~= nil and parentMap.mapNumber == GameData.ExpansionMapRegion.TOMB_KINGS
    then
        return true
    end
    return false
end

----------------------------------------------------------------
-- EA_Window_RRQTracker (HUD) Functions
----------------------------------------------------------------

EA_Window_RRQTracker = {}
EA_Window_RRQTracker.RealmResourceQuestWindowID = nil

function EA_Window_RRQTracker.Initialize()

    LayoutEditor.RegisterWindow( "EA_Window_RRQTracker",
                                 GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_RRQ_STATUS_WINDOW_NAME ),
                                 GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_RRQ_STATUS_WINDOW_DESC ),
                                 false, false,
                                 true, nil )
    LayoutEditor.SetDefaultHidden( "EA_Window_RRQTracker", GameData.Player.level < GameData.LandOfTheDead.MinAccessLevel )
                                 
    if ( EA_Window_WorldMap.Settings.showHUDRRQTracker ~= nil )
    then
        -- Convert legacy setting from pre-1.4.1. This is now done via the Layout Editor.
        if ( EA_Window_WorldMap.Settings.showHUDRRQTracker )
        then
            LayoutEditor.UserShow( "EA_Window_RRQTracker" )
        else
            LayoutEditor.UserHide( "EA_Window_RRQTracker" )
        end
        EA_Window_WorldMap.Settings.showHUDRRQTracker = nil
        EA_Window_WorldMap.Settings.initializedHUDRRQTrackerShowing = true
    end
                                    
    if ( EA_Window_WorldMap.Settings.initializedHUDRRQTrackerShowing == nil )
    then
        -- HUD tracker defaults to ON for level characters able to access Land of the Dead, OFF for others
        if ( GameData.Player.level >= GameData.LandOfTheDead.MinAccessLevel )
        then
            LayoutEditor.UserShow( "EA_Window_RRQTracker" )
        else
            LayoutEditor.UserHide( "EA_Window_RRQTracker" )
        end
        EA_Window_WorldMap.Settings.initializedHUDRRQTrackerShowing = true
    end
    
    WindowRegisterEventHandler( "EA_Window_RRQTracker", SystemData.Events.PLAYER_CAREER_RANK_UPDATED, "EA_Window_RRQTracker.OnRankUpdated") 
    
    RRQProgressBar.AddListener( EA_Window_RRQTracker.OnRRQsUpdated )
    
    EA_Window_RRQTracker.OnRRQsUpdated()
end

function EA_Window_RRQTracker.Shutdown()
    LayoutEditor.UnregisterWindow( "EA_Window_RRQTracker" )
end

function EA_Window_RRQTracker.OnRankUpdated()
    -- When the player levels to the rank necessary to access the Land of the Dead, force the RRQ HUD tracker on. The player can later turn it off if they don't want it.

    if (GameData.Player.level == GameData.LandOfTheDead.MinAccessLevel and IsPlayerInitialized() )
	then
        LayoutEditor.UserShow( "EA_Window_RRQTracker" )
        LayoutEditor.SetDefaultHidden( "EA_Window_RRQTracker", false )
        EA_Window_RRQTracker.OnRRQsUpdated()
    end
end

function EA_Window_RRQTracker.OnShown()
    --in order to save the position of this window it has to be loaded in the .mod file
    --however, if the window was being shown the last time those settings were saved
    --it can show up when there is no RRQ, check to see if we really should show
    if RRQProgressBar.GetFirstQuestDataOfType(GameData.RRQDisplayType.ERRQDISPLAY_TOMB_KINGS) == nil
    then
        LayoutEditor.Hide( "EA_Window_RRQTracker" )
    end
    
    EA_Window_WorldMap.UpdateRRQTrackerButton()
end

function EA_Window_RRQTracker.OnHidden()
    EA_Window_WorldMap.UpdateRRQTrackerButton()
end

function EA_Window_RRQTracker.OnRRQsUpdated()
    --just tie our tracker to the first RRQ, but could support more later
    local rrqData = RRQProgressBar.GetFirstQuestDataOfType(GameData.RRQDisplayType.ERRQDISPLAY_TOMB_KINGS)
        
    -- if there are RRQs, take the first one and display it
    -- check the Display Type also, some are Tome only and use different bars
    if rrqData ~= nil
    then
        -- lazy window creation, so make sure it exists and create if we need to
        if not DoesWindowExist("EA_Window_RRQTrackerBarContainerStatus")
        then
            
            EA_Window_RRQTracker.RealmResourceQuestWindowID = RRQProgressBar.Create( "EA_Window_RRQTrackerBarContainerStatus", 
                                                                                    "EA_Window_RRQTrackerBarContainer", 
                                                                                    rrqData.displayType) 
            -- note: A change in displayType won't happen until a reloadui, like on zone or relog.
            -- but since RRQs aren't exactly changing more than every week, that should be fine
        end

        if not (RRQProgressBar.GetRRQuestIDfromWindowID( EA_Window_RRQTracker.RealmResourceQuestWindowID ) == rrqData.rrquestID)
        then
            RRQProgressBar.SetRRQuestID( EA_Window_RRQTracker.RealmResourceQuestWindowID, rrqData.rrquestID )
        end

        LayoutEditor.Show( "EA_Window_RRQTracker" )
    else
        -- shouldn't be visible if we have nothing useful to show, if we have no quests
        LayoutEditor.Hide( "EA_Window_RRQTracker" )
    end
    
end
