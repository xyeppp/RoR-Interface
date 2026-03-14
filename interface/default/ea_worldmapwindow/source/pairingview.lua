----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

-- Toggles
EA_Window_WorldMap.HOTSPOT_OVERLAY   = 1
EA_Window_WorldMap.PATH_OVERLAY      = 2

-- NUM_PAIRINGS does not include expansion "pairing" maps, such as for Tomb Kings
EA_Window_WorldMap.NUM_PAIRINGS = 3
EA_Window_WorldMap.NUM_TIERS = 4
EA_Window_WorldMap.CAMPAIGN_TIER = 4

EA_Window_WorldMap.pairingButtons = 
{
    [GameData.Pairing.GREENSKIN_DWARVES]   = "EA_Window_WorldMapPairingViewPairingButton1",
    [GameData.Pairing.EMPIRE_CHAOS]        = "EA_Window_WorldMapPairingViewPairingButton2",
    [GameData.Pairing.ELVES_DARKELVES]     = "EA_Window_WorldMapPairingViewPairingButton3",
    [GameData.ExpansionMapRegion.TOMB_KINGS]          = "EA_Window_WorldMapPairingViewPairingButton100",
}

-- this table was created so that we can have a pairing map for Tomb Kings
-- Tomb Kings is a special case, there is currently no real Campaign Pairing RvR data/zone control
-- it works on the new Realm Resource Quest system. This lets us skip code that works with
-- zone control related UI elements for this new "pairing"
EA_Window_WorldMap.pairingHasZoneControl = 
{
    [GameData.Pairing.GREENSKIN_DWARVES]              = true,
    [GameData.Pairing.EMPIRE_CHAOS]                   = true,
    [GameData.Pairing.ELVES_DARKELVES]                = true,
    [GameData.ExpansionMapRegion.TOMB_KINGS]          = false,
}

EA_Window_WorldMap.pairingHasFortresses = 
{
    [GameData.Pairing.GREENSKIN_DWARVES]              = true,
    [GameData.Pairing.EMPIRE_CHAOS]                   = true,
    [GameData.Pairing.ELVES_DARKELVES]                = true,
    [GameData.ExpansionMapRegion.TOMB_KINGS]          = false,
}

EA_Window_WorldMap.pairingHasCapitalCities = 
{
    [GameData.Pairing.GREENSKIN_DWARVES]              = true,
    [GameData.Pairing.EMPIRE_CHAOS]                   = true,
    [GameData.Pairing.ELVES_DARKELVES]                = false,
    [GameData.ExpansionMapRegion.TOMB_KINGS]          = false,
}

EA_Window_WorldMap.currentPairing = 0

EA_Window_WorldMap.FORTRESS_TIMERS = 1
EA_Window_WorldMap.CITY_TIMERS = 2

EA_Window_WorldMap.pairingTimers =
{
    [EA_Window_WorldMap.FORTRESS_TIMERS] =
    {
        [GameData.Realm.ORDER]       = { timeLeft = 0, suffix = "FortTimerOrder" },
        [GameData.Realm.DESTRUCTION] = { timeLeft = 0, suffix = "FortTimerDest" },
    },
    
    [EA_Window_WorldMap.CITY_TIMERS] =
    {
        [GameData.Realm.ORDER]       = { timeLeft = 0, suffix = "CityTimerOrder" },
        [GameData.Realm.DESTRUCTION] = { timeLeft = 0, suffix = "CityTimerDest" },
    },
}

EA_Window_WorldMap.zoneHotSpotData = {}

---------------------------------------------------------------
-- Saved Variables
----------------------------------------------------------------
EA_Window_WorldMap.Settings.pairingLayers = {}

EA_Window_WorldMap.Settings.pairingLayers[EA_Window_WorldMap.PATH_OVERLAY] = true 
EA_Window_WorldMap.Settings.pairingLayers[EA_Window_WorldMap.HOTSPOT_OVERLAY] = true

----------------------------------------------------------------
-- Map Setup Variables
----------------------------------------------------------------

EA_Window_WorldMap.pairingMapZones = 
{

    [GameData.Pairing.GREENSKIN_DWARVES] =
    {
        -- Tier 1
        [  6] = EA_Window_WorldMap.ICON_ZONE,
        [ 11] = EA_Window_WorldMap.ICON_ZONE,
        
        -- Tier 2
        [  7] = EA_Window_WorldMap.ICON_ZONE,
        [  1] = EA_Window_WorldMap.ICON_ZONE,
        
        -- Tier 3
        [  8] = EA_Window_WorldMap.ICON_ZONE,
        [  2] = EA_Window_WorldMap.ICON_ZONE,
        
        -- Tier 4
        
        -- Destruction City        
        [ 61] = EA_Window_WorldMap.ICON_CITY,
        [161] = EA_Window_WorldMap.ICON_CITY_MINI,
        
        -- Destruction Forts
        [  4] = EA_Window_WorldMap.ICON_FORT_MINI,        
        [104] = EA_Window_WorldMap.ICON_FORT_MINI,
        [204] = EA_Window_WorldMap.ICON_FORT_MINI,
        
        -- Destruction Zone
        [  3] = EA_Window_WorldMap.ICON_ZONE,
        
        -- Center Zones
        [  5] = EA_Window_WorldMap.ICON_ZONE,
        [  26] = EA_Window_WorldMap.ICON_ZONE_MINI,
        [  27] = EA_Window_WorldMap.ICON_ZONE_MINI,
        
        -- Order Zone
        [  9] = EA_Window_WorldMap.ICON_ZONE,
        
        -- Order Forts
        [ 10] = EA_Window_WorldMap.ICON_FORT_MINI,
        [110] = EA_Window_WorldMap.ICON_FORT_MINI,
        [210] = EA_Window_WorldMap.ICON_FORT_MINI,
                        
        -- Order City        
        [ 62] = EA_Window_WorldMap.ICON_CITY,
        [162] = EA_Window_WorldMap.ICON_CITY_MINI,     
    },
    
    
    [GameData.Pairing.EMPIRE_CHAOS] =
    {
        -- Tier 1
        [106] = EA_Window_WorldMap.ICON_ZONE,
        [100] = EA_Window_WorldMap.ICON_ZONE,
        
        -- Tier 2
        [107] = EA_Window_WorldMap.ICON_ZONE,
        [101] = EA_Window_WorldMap.ICON_ZONE,
        
        -- Tier 3
        [108] = EA_Window_WorldMap.ICON_ZONE,
        [102] = EA_Window_WorldMap.ICON_ZONE,
        
        -- Tier 4
        
        -- Destruction City        
        [061] = EA_Window_WorldMap.ICON_CITY_MINI,
        [161] = EA_Window_WorldMap.ICON_CITY,
        
        -- Destruction Forts
        [  4] = EA_Window_WorldMap.ICON_FORT_MINI,        
        [104] = EA_Window_WorldMap.ICON_FORT_MINI,
        [204] = EA_Window_WorldMap.ICON_FORT_MINI,
        
        -- Destruction Zone
        [103] = EA_Window_WorldMap.ICON_ZONE,
        
        -- Center Zones
        [105] = EA_Window_WorldMap.ICON_ZONE,
        [120] = EA_Window_WorldMap.ICON_ZONE_MINI,
        
        -- Order Zone
        [109] = EA_Window_WorldMap.ICON_ZONE,
        
        -- Order Forts
        [ 10] = EA_Window_WorldMap.ICON_FORT_MINI,
        [110] = EA_Window_WorldMap.ICON_FORT_MINI,
        [210] = EA_Window_WorldMap.ICON_FORT_MINI,
                        
        -- Order City      
        [062] = EA_Window_WorldMap.ICON_CITY_MINI,  
        [162] = EA_Window_WorldMap.ICON_CITY,         
    },

    [GameData.Pairing.ELVES_DARKELVES] =
    {
        -- Tier 1
        [206] = EA_Window_WorldMap.ICON_ZONE,
        [200] = EA_Window_WorldMap.ICON_ZONE,
        
        -- Tier 2
        [207] = EA_Window_WorldMap.ICON_ZONE,
        [201] = EA_Window_WorldMap.ICON_ZONE,
        
        -- Tier 3
        [208] = EA_Window_WorldMap.ICON_ZONE,
        [202] = EA_Window_WorldMap.ICON_ZONE,
        
        -- Tier 4
        
        -- Destruction City        
        [061] = EA_Window_WorldMap.ICON_CITY_MINI,
        [161] = EA_Window_WorldMap.ICON_CITY_MINI,
        
        -- Destruction Forts
        [  4] = EA_Window_WorldMap.ICON_FORT_MINI,        
        [104] = EA_Window_WorldMap.ICON_FORT_MINI,
        [204] = EA_Window_WorldMap.ICON_FORT,
        
        -- Destruction Zone
        [203] = EA_Window_WorldMap.ICON_ZONE,
        
        -- Center Zones
        [205] = EA_Window_WorldMap.ICON_ZONE,
        [220] = EA_Window_WorldMap.ICON_ZONE_MINI,
        
        -- Order Zone
        [209] = EA_Window_WorldMap.ICON_ZONE,
        
        -- Order Forts
        [ 10] = EA_Window_WorldMap.ICON_FORT_MINI,
        [110] = EA_Window_WorldMap.ICON_FORT_MINI,
        [210] = EA_Window_WorldMap.ICON_FORT,
                        
        -- Order City        
        [062] = EA_Window_WorldMap.ICON_CITY_MINI,  
        [162] = EA_Window_WorldMap.ICON_CITY_MINI,         
    },
    
    [GameData.ExpansionMapRegion.TOMB_KINGS] =
    {
		-- Tier 4
       [191] = EA_Window_WorldMap.ICON_ZONE,
	   
        -- Arena        
       [413] = EA_Window_WorldMap.ICON_ZONE,
    }
}

local function GetPairingWindowName( pairingId )
    return "EA_Window_WorldMapPairingViewPairing"..pairingId
end

local function GetZoneWindowName( pairingId, zoneId )
    return "EA_Window_WorldMapPairingViewPairing"..pairingId.."Zone"..zoneId
end



----------------------------------------------------------------
-- Pairing Functions
----------------------------------------------------------------

function EA_Window_WorldMap.InitializePairingView()

    -- Pairing Buttons
    LabelSetText( "EA_Window_WorldMapPairingViewRealmWarsHeader",  GetStringFromTable("MapSystem", StringTables.MapSystem.LABEL_REALM_WARS ) )
    for index, buttonName in pairs( EA_Window_WorldMap.pairingButtons )
    do
        local text = L""
        if index < GameData.ExpansionMapRegion.FIRST
        then
            text = GetStringFromTable("MapSystem", StringTables.MapSystem.LABEL_PAIRING_1 + index - 1) 
        else
            text = GetStringFromTable("MapSystem", StringTables.MapSystem.LABEL_EXPANSION_MAP_REGION_100 + index - GameData.ExpansionMapRegion.FIRST) 
        end

        ButtonSetText( buttonName, GetStringFormatFromTable("MapSystem", StringTables.MapSystem.LABEL_PAIRING_NAME_BUTTON, {text} ) )        
    end

    -- Map Options
    LabelSetText( "EA_Window_WorldMapPairingViewOverlayHeader",       GetStringFromTable("MapSystem", StringTables.MapSystem.LABEL_MAP_FEATURES ) )
    LabelSetText( "EA_Window_WorldMapPairingViewHotspotToggleName",   GetStringFromTable("MapSystem", StringTables.MapSystem.LABEL_TOGGLE_HOTSPOT ) )
    LabelSetText( "EA_Window_WorldMapPairingViewPathToggleName",      GetStringFromTable("MapSystem", StringTables.MapSystem.LABEL_TOGGLE_TRAVEL ) )

    LabelSetText( "EA_Window_WorldMapPairingViewOptionsText",   GetStringFromTable("MapSystem", StringTables.MapSystem.TEXT_PAIRING_MAP_FEATURES ) )

    LabelSetText( "EA_Window_WorldMapPairingViewCampaignTrackerToggleName",   GetStringFromTable("MapSystem", StringTables.MapSystem.LABEL_TOGGLE_HUD_CAMPAIGN_TRACKER ) )

    -- RvR
    LabelSetText( "EA_Window_WorldMapPairingViewRvRHeader",      GetStringFromTable("MapSystem", StringTables.MapSystem.LABEL_PAIRING_RVR_HEADER ) )
    LabelSetText( "EA_Window_WorldMapPairingViewRvRText",      GetStringFromTable("MapSystem", StringTables.MapSystem.TEXT_PAIRING_RVR ) )
    
    WindowRegisterEventHandler( "EA_Window_WorldMap", SystemData.Events.CITY_SCENARIO_UPDATE_TIME, "EA_Window_WorldMap.RefreshCityTimers")
	
    WindowRegisterEventHandler( "EA_Window_WorldMap", SystemData.Events.CAMPAIGN_ZONE_UPDATED, "EA_Window_WorldMap.OnCampaignZoneUpdated")
    WindowRegisterEventHandler( "EA_Window_WorldMap", SystemData.Events.CAMPAIGN_PAIRING_UPDATED, "EA_Window_WorldMap.OnCampaignPairingUpdated")
    WindowRegisterEventHandler( "EA_Window_WorldMap", SystemData.Events.CAMPAIGN_CITY_UPDATED, "EA_Window_WorldMap.OnCampaignCityUpdated")
    
    WindowRegisterEventHandler( "EA_Window_WorldMap", SystemData.Events.PAIRING_MAP_HOTSPOT_DATA_UPDATED, "EA_Window_WorldMap.OnPairingMapHotspotDataUpdated")
    
    EA_Window_WorldMap.InitializeWarStatus()

end

function EA_Window_WorldMap.ShutdownPairingView()

end

function EA_Window_WorldMap.ShowPairing( pairingId )

    EA_Window_WorldMap.CreateCustomPairingWindow(pairingId)
    EA_Window_WorldMap.InitializeCustomPairingWindow()
    EA_Window_WorldMap.UpdatePairingZoneIcons( EA_Window_WorldMap.currentPairing )
    EA_Window_WorldMap.RefreshFortressTimers()
    EA_Window_WorldMap.RefreshCityTimers()
    
    -- Update the Title
    local text 
    if EA_Window_WorldMap.currentPairing < GameData.ExpansionMapRegion.FIRST
    then
        text = GetStringFromTable("MapSystem", StringTables.MapSystem.LABEL_PAIRING_1 + EA_Window_WorldMap.currentPairing - 1)
    else
        text = GetStringFromTable("MapSystem", StringTables.MapSystem.LABEL_EXPANSION_MAP_REGION_100 + EA_Window_WorldMap.currentPairing - GameData.ExpansionMapRegion.FIRST) 
    end
    
    LabelSetText( "EA_Window_WorldMapPairingViewBorderTitleText", GetStringFormatFromTable("MapSystem", StringTables.MapSystem.LABEL_PAIRING_NAME_HEADING, {text} ) )        
    
    
    -- Select the Current pairing
    for index, buttonName in pairs( EA_Window_WorldMap.pairingButtons )
    do
        ButtonSetDisabledFlag(buttonName, EA_Window_WorldMap.currentPairing == index )
    end
   
    -- Update The Layers
    local windowName = "EA_Window_WorldMapPairingView"
    local pairingWindowName = GetPairingWindowName( EA_Window_WorldMap.currentPairing )
    
    local shouldShowPathOverlays = EA_Window_WorldMap.Settings.pairingLayers[EA_Window_WorldMap.PATH_OVERLAY]
    WindowSetShowing( pairingWindowName.."Paths", shouldShowPathOverlays)
    ButtonSetPressedFlag(windowName.."PathToggleCheckBox", shouldShowPathOverlays)
    
    local shouldShowHotspots = EA_Window_WorldMap.Settings.pairingLayers[EA_Window_WorldMap.HOTSPOT_OVERLAY]
    EA_Window_WorldMap.ShowHotspots( shouldShowHotspots )
    ButtonSetPressedFlag(windowName.."HotspotToggleCheckBox", shouldShowHotspots)
    
end

function EA_Window_WorldMap.OnShownPairingMap()
    -- Refresh the War Status to update any timers 
    EA_Window_WorldMap.UpdateWarStatus()
end


----------------------------------------------------------------
-- Update Callbacks
----------------------------------------------------------------

function EA_Window_WorldMap.OnCampaignZoneUpdated( zoneId )

    EA_Window_WorldMap.UpdatePairingZoneIcon( zoneId )
end

function EA_Window_WorldMap.OnCampaignPairingUpdated( pairingId )

    if( pairingId == EA_Window_WorldMap.currentPairing )
    then
        EA_Window_WorldMap.UpdatePairingZoneIcons( EA_Window_WorldMap.currentPairing )
        EA_Window_WorldMap.RefreshFortressTimers()
    end    
    
    EA_Window_WorldMap.UpdateWarStatus()
end

function EA_Window_WorldMap.OnCampaignCityUpdated( cityId )
    
    EA_Window_WorldMap.UpdateWarStatus()
end

function EA_Window_WorldMap.OnPairingMapHotspotDataUpdated( )
    EA_Window_WorldMap.ShowCampaignTrackerHotspots( "EA_Window_WorldMapPairingViewCampaignTracker", true )

    -- Only update hotspots on the main map if showing them is enabled
    if (EA_Window_WorldMap.Settings.pairingLayers[EA_Window_WorldMap.HOTSPOT_OVERLAY]) then
        EA_Window_WorldMap.ShowHotspots( true )
    end
end


----------------------------------------------------------------
-- Overlay Control and Pin Filtering
----------------------------------------------------------------
function EA_Window_WorldMap.ToggleOverlays()
    local mouseOverWindowId = WindowGetId(SystemData.ActiveWindow.name)
    local checkBox = SystemData.ActiveWindow.name.."CheckBox"
    
    EA_Window_WorldMap.Settings.pairingLayers[mouseOverWindowId] = not EA_Window_WorldMap.Settings.pairingLayers[mouseOverWindowId]
    local showLayer = EA_Window_WorldMap.Settings.pairingLayers[mouseOverWindowId]
    ButtonSetPressedFlag(checkBox, showLayer)

    if( mouseOverWindowId == EA_Window_WorldMap.PATH_OVERLAY) 
    then
        local pairingWindowName = GetPairingWindowName( EA_Window_WorldMap.currentPairing )
        WindowSetShowing( pairingWindowName.."Paths", showLayer)
        WindowSetShowing( pairingWindowName.."Background", not showLayer)
    elseif( mouseOverWindowId == EA_Window_WorldMap.HOTSPOT_OVERLAY ) 
    then
        EA_Window_WorldMap.ShowHotspots( showLayer )
    end
end

function EA_Window_WorldMap.ShowHotspots( show )
    local pairingIndex = EA_Window_WorldMap.currentPairing
    if ((pairingIndex >= 1) and (pairingIndex <= 3)) then
        for zoneId, iconType in pairs( EA_Window_WorldMap.pairingMapZones[pairingIndex] )
        do
            local hotspotSize = GameData.HotSpotSize.NONE
            if (show) then
                hotspotSize = GetZoneLargestHotspotSize( zoneId )
            end
            
            -- Figure out the size of the currently displayed hotspot from our saved array. Anything that's not in the array defaults to NONE.
            local oldHotspotSize = GameData.HotSpotSize.NONE
            if (EA_Window_WorldMap.zoneHotSpotData[zoneId] ~= nil) then
                oldHotspotSize = EA_Window_WorldMap.zoneHotSpotData[zoneId]
            end
            
            -- If the hotspot has changed size, then we need to update it
            if (hotspotSize ~= oldHotspotSize) then
                EA_Window_WorldMap.zoneHotSpotData[zoneId] = hotspotSize
                
                local parentWindowName = GetZoneWindowName( pairingIndex, zoneId ).."ControlIcon"
                local hotspotWindowName = parentWindowName.."HotSpot"
                
                if (hotspotSize == GameData.HotSpotSize.NONE) then
                    DestroyWindow( hotspotWindowName )
                else
                    if (oldHotspotSize ~= GameData.HotSpotSize.NONE) then
                        -- Must destroy old hotspot icon before we can create new one
                        DestroyWindow( hotspotWindowName )
                    end

                    -- Construct template name from hotspot size and zone type
                    local templateName = "EA_DynamicImage_"
                    if (hotspotSize == GameData.HotSpotSize.SMALL) then
                        templateName = templateName.."Small"
                    elseif (hotspotSize == GameData.HotSpotSize.MEDIUM) then
                        templateName = templateName.."Medium"
                    elseif (hotspotSize == GameData.HotSpotSize.LARGE) then
                        templateName = templateName.."Large"
                    end
                    templateName = templateName.."HotSpot_"
                    if (iconType == EA_Window_WorldMap.ICON_ZONE) then
                        templateName = templateName.."Full"
                    elseif ((iconType == EA_Window_WorldMap.ICON_ZONE_MINI) or (iconType == EA_Window_WorldMap.ICON_FORT) or (iconType == EA_Window_WorldMap.ICON_CITY)) then
                        templateName = templateName.."Small"
                    else
                        templateName = templateName.."Tiny"
                    end
                    
                    CreateWindowFromTemplate( hotspotWindowName, templateName, parentWindowName)
                    WindowAddAnchor( hotspotWindowName, "center", parentWindowName, "center", 0, 0 )
                end
            end
        end
    end
end

function EA_Window_WorldMap.ToggleHUDCampaignTracker()
    local shouldShow = LayoutEditor.IsWindowUserHidden( "EA_Window_CampaignMap" )
    if ( shouldShow )
    then
        LayoutEditor.UserShow( "EA_Window_CampaignMap" )
    else
        LayoutEditor.UserHide( "EA_Window_CampaignMap" )
    end
    EA_Window_WorldMap.UpdateCampaignTrackerButton()
end


function EA_Window_WorldMap.UpdateCampaignTrackerButton()

    local showing = not LayoutEditor.IsWindowUserHidden( "EA_Window_CampaignMap" )
    ButtonSetPressedFlag( "EA_Window_WorldMapPairingViewCampaignTrackerToggleCheckBox", showing )
end


----------------------------------------------------------------
-- Zone Icon Functions
----------------------------------------------------------------

function EA_Window_WorldMap.UpdatePairingZoneIcon( zoneId )
    
    if( zoneId == nil )
    then    
        ERROR(L" EA_Window_WorldMap.UpdatePairingZoneIcon( zoneId ): Zone Id is NULL" )
        return
    end
    
    if( EA_Window_WorldMap.currentPairing == 0 )
    then
        return
    end
    
    local iconType = EA_Window_WorldMap.pairingMapZones[ EA_Window_WorldMap.currentPairing ][zoneId]    
    if( iconType == nil )
    then 
        -- This zone is not displayed in the current pairing
        return
    end
    
    local zoneWindowName = GetZoneWindowName( EA_Window_WorldMap.currentPairing, zoneId )
    EA_Window_WorldMap.UpdateIconForZone( zoneId, iconType, zoneWindowName )
    
end

function EA_Window_WorldMap.UpdatePairingZoneIcons( pairingId )

    if( EA_Window_WorldMap.pairingMapZones[ pairingId ] == nil )
    then
        ERROR(L" EA_Window_WorldMap.UpdatePairingZoneIcons( pairingId ): Pairing Id is NULL" )
        return
    end
      
    -- Update the Control icons for all zones in this pairing
    for zoneId, _ in pairs( EA_Window_WorldMap.pairingMapZones[pairingId] )
    do
        EA_Window_WorldMap.UpdatePairingZoneIcon( zoneId ) 
    end
    
end

----------------------------------------------------------------
-- Fortress/City Timers
----------------------------------------------------------------
function EA_Window_WorldMap.RefreshFortressTimers()
    EA_Window_WorldMap.pairingTimers[EA_Window_WorldMap.FORTRESS_TIMERS][GameData.Realm.ORDER].timeLeft = 0
    EA_Window_WorldMap.pairingTimers[EA_Window_WorldMap.FORTRESS_TIMERS][GameData.Realm.DESTRUCTION].timeLeft = 0
    if (EA_Window_WorldMap.pairingHasFortresses[EA_Window_WorldMap.currentPairing]) then
        local pairingWindowName = GetPairingWindowName(EA_Window_WorldMap.currentPairing)
        
        local pairingData = GetCampaignPairingData(EA_Window_WorldMap.currentPairing)
        if (pairingData ~= nil) then
            if (pairingData.captureTimeRemaining > 0) then
                if (pairingData.controllingRealm == GameData.Realm.ORDER) then
                    EA_Window_WorldMap.pairingTimers[EA_Window_WorldMap.FORTRESS_TIMERS][GameData.Realm.DESTRUCTION].timeLeft = pairingData.captureTimeRemaining
                elseif (pairingData.controllingRealm == GameData.Realm.DESTRUCTION) then
                    EA_Window_WorldMap.pairingTimers[EA_Window_WorldMap.FORTRESS_TIMERS][GameData.Realm.ORDER].timeLeft = pairingData.captureTimeRemaining
                end
            elseif (pairingData.fortressPQTimeRemaining > 0) then
                if (pairingData.contestedZone == pairingData.orderFortressZone) then
                    EA_Window_WorldMap.pairingTimers[EA_Window_WorldMap.FORTRESS_TIMERS][GameData.Realm.ORDER].timeLeft = pairingData.fortressPQTimeRemaining
                elseif (pairingData.contestedZone == pairingData.destructionFortressZone) then
                    EA_Window_WorldMap.pairingTimers[EA_Window_WorldMap.FORTRESS_TIMERS][GameData.Realm.DESTRUCTION].timeLeft = pairingData.fortressPQTimeRemaining
                end
            end
        end
        
        for _, timer in pairs(EA_Window_WorldMap.pairingTimers[EA_Window_WorldMap.FORTRESS_TIMERS])
        do
			if DoesWindowExist(pairingWindowName..timer.suffix) then
            if (timer.timeLeft > 0) then
                LabelSetText(pairingWindowName..timer.suffix, TimeUtils.FormatClock(timer.timeLeft))
                WindowSetShowing(pairingWindowName..timer.suffix, true)
            else
                WindowSetShowing(pairingWindowName..timer.suffix, false)
            end
			end
        end
    end
end

function EA_Window_WorldMap.RefreshCityTimers()
    EA_Window_WorldMap.pairingTimers[EA_Window_WorldMap.CITY_TIMERS][GameData.Realm.ORDER].timeLeft = 0
    EA_Window_WorldMap.pairingTimers[EA_Window_WorldMap.CITY_TIMERS][GameData.Realm.DESTRUCTION].timeLeft = 0
    if (EA_Window_WorldMap.pairingHasCapitalCities[EA_Window_WorldMap.currentPairing]) then
        local pairingWindowName = GetPairingWindowName(EA_Window_WorldMap.currentPairing)
        
		local cityDataMap = {}
        if (EA_Window_WorldMap.currentPairing == GameData.Pairing.GREENSKIN_DWARVES) then
            cityDataMap[GameData.Realm.ORDER] = RoR_CitySiege.GetCity(GameData.CityId.DWARF)
            cityDataMap[GameData.Realm.DESTRUCTION] = RoR_CitySiege.GetCity(GameData.CityId.GREENSKIN)
        elseif (EA_Window_WorldMap.currentPairing == GameData.Pairing.EMPIRE_CHAOS) then
            cityDataMap[GameData.Realm.ORDER] = RoR_CitySiege.GetCity(GameData.CityId.EMPIRE)
            cityDataMap[GameData.Realm.DESTRUCTION] = RoR_CitySiege.GetCity(GameData.CityId.CHAOS)
        end
		
		for realm, cityData in pairs(cityDataMap)
		do
			if (cityData ~= nil and cityData.state ~= SystemData.CityStates.NONE and cityData.state ~= SystemData.CityStates.SAFE) then
				EA_Window_WorldMap.pairingTimers[EA_Window_WorldMap.CITY_TIMERS][realm].timeLeft = cityData.timeLeft
			end
		end
        
        for _, timer in pairs(EA_Window_WorldMap.pairingTimers[EA_Window_WorldMap.CITY_TIMERS])
        do
		if DoesWindowExist(pairingWindowName..timer.suffix) then
            if (timer.timeLeft > 0) then
                LabelSetText(pairingWindowName..timer.suffix, TimeUtils.FormatClock(timer.timeLeft))
                WindowSetShowing(pairingWindowName..timer.suffix, true)
            else
                WindowSetShowing(pairingWindowName..timer.suffix, false)
            end
		end	
        end
    end
end

function EA_Window_WorldMap.CountdownPairingTimers(timePassed)
    for _, timerArray in pairs(EA_Window_WorldMap.pairingTimers)
    do
        for _, timer in pairs(timerArray)
        do
            if (timer.timeLeft > 0) then
                local newTimer = timer.timeLeft - timePassed
                if (newTimer > 0) then
                    if (math.floor(newTimer + 0.5) < math.floor(timer.timeLeft + 0.5)) then
                        LabelSetText(GetPairingWindowName(EA_Window_WorldMap.currentPairing)..timer.suffix, TimeUtils.FormatClock(newTimer))
                    end
                    timer.timeLeft = newTimer
                else
                    WindowSetShowing(GetPairingWindowName(EA_Window_WorldMap.currentPairing)..timer.suffix, false)
                    timer.timeLeft = 0
                end
            end
        end
    end
end

----------------------------------------------------------------
-- Custom Pairing Window
----------------------------------------------------------------
function EA_Window_WorldMap.DestroyCustomPairingWindow(pairingIndex)

    if(pairingIndex == nil) 
    then
        return
    end
        
    -- Destroy the Windows
    DestroyWindow( GetPairingWindowName( pairingIndex ) )
end
            
function EA_Window_WorldMap.CreateCustomPairingWindow(pairingIndex)
    
    if( EA_Window_WorldMap.currentPairing == pairingIndex )
    then
        return
    end

    if( EA_Window_WorldMap.currentPairing ~= 0 )
    then
        EA_Window_WorldMap.DestroyCustomPairingWindow(EA_Window_WorldMap.currentPairing)
    end

    EA_Window_WorldMap.currentPairing = pairingIndex
    EA_Window_WorldMap.zoneHotSpotData = {}

    CreateWindowFromTemplate( GetPairingWindowName( pairingIndex ) , "WorldMapPairing"..pairingIndex.."Window", "EA_Window_WorldMapRegionMap")
    WindowSetScale( GetPairingWindowName( pairingIndex ), EA_Window_WorldMap.GetResolutionScale() )

end

function EA_Window_WorldMap.InitializeCustomPairingWindow()
    
    local pairingIndex = EA_Window_WorldMap.currentPairing 
    local pairingWindowName = GetPairingWindowName( pairingIndex )
    
    -- Initialize all of the Text for the large zone Icons
    for zoneId, iconType in pairs( EA_Window_WorldMap.pairingMapZones[ pairingIndex ] )
    do
        if( iconType == EA_Window_WorldMap.ICON_ZONE )
        then    
            local labelWindowName = GetZoneWindowName( pairingIndex, zoneId ).."Text"
            LabelSetText( labelWindowName, GetStringFormat( StringTables.Default.LABEL_PAIRING_MAP_ZONE_NAME, {StringUtils.ToUpperZoneName( GetZoneName(zoneId))})  )    
        end
    end
    
    -- Initialize the Racial Text    
    LabelSetText( pairingWindowName.."Order",       StringUtils.GetRaceNameNounFromPairingAndRealm( pairingIndex, GameData.Realm.ORDER, true ) )
    LabelSetText( pairingWindowName.."Destruction", StringUtils.GetRaceNameNounFromPairingAndRealm( pairingIndex, GameData.Realm.DESTRUCTION, true ) )

    -- Initialize the Tier Text    
    if EA_Window_WorldMap.pairingHasZoneControl[EA_Window_WorldMap.currentPairing]
    then
        LabelSetText( pairingWindowName.."Tier1Text",  GetString( StringTables.Default.LABEL_TIER_ONE ) )
        LabelSetText( pairingWindowName.."Tier2Text",  GetString( StringTables.Default.LABEL_TIER_TWO ) )
        LabelSetText( pairingWindowName.."Tier3Text",  GetString( StringTables.Default.LABEL_TIER_THREE ) )
        LabelSetText( pairingWindowName.."Tier4Text",  GetString( StringTables.Default.LABEL_TIER_FOUR ) )
    end

    EA_Window_WorldMap.UpdatePairingMapCurrentZoneMarker()
end

function EA_Window_WorldMap.UpdatePairingMapCurrentZoneMarker()
   
    local pairingWindowName = GetPairingWindowName( EA_Window_WorldMap.currentPairing )
    
    -- Set the current zone marker    
    local currentZoneMarkerName = pairingWindowName.."CurrentZone"
    local playerZoneOnMap = EA_Window_WorldMap.pairingMapZones[ EA_Window_WorldMap.currentPairing ][GameData.Player.zone] ~= nil
    local currentZoneMarkerID = 0
    
    if( playerZoneOnMap )
    then
    
        local zoneWindowName = GetZoneWindowName( EA_Window_WorldMap.currentPairing, GameData.Player.zone )
    
        WindowClearAnchors( currentZoneMarkerName )
        WindowAddAnchor( currentZoneMarkerName, "center", zoneWindowName, "center", 0, 0  )
        currentZoneMarkerID = GameData.Player.zone    
    end
    
    WindowSetShowing( currentZoneMarkerName, playerZoneOnMap )
    WindowSetId( currentZoneMarkerName, currentZoneMarkerID )
end


function EA_Window_WorldMap.OnZoneButtonSelect()
    local selectedZone = WindowGetId( SystemData.ActiveWindow.name )
    EA_Window_WorldMap.SetMap(GameDefs.MapLevel.ZONE_MAP, selectedZone)
end

function EA_Window_WorldMap.OnMouseOverPairingMapZone()
    local zoneId    = WindowGetId( SystemData.ActiveWindow.name )
    EA_Window_WorldMap.CreateAppropriateZoneTooltip(zoneId, nil, nil)
end


----------------------------------------------------------------
-- Tooltips
----------------------------------------------------------------

function EA_Window_WorldMap.OnPairingTierMouseOver()
    local tierNumber = WindowGetId(SystemData.ActiveWindow.name)
    local tierNameStr = L""
    local tierRanksStr = L""
    if (tierNumber == 1) then
        tierNameStr = GetStringFromTable("MapSystem", StringTables.MapSystem.TOOLTIP_TIER1)
        tierRanksStr = GetStringFromTable("MapSystem", StringTables.MapSystem.TOOLTIP_SUGGESTED_RANK_RANGE_TIER1)
    elseif (tierNumber == 2) then
        tierNameStr = GetStringFromTable("MapSystem", StringTables.MapSystem.TOOLTIP_TIER2)
        tierRanksStr = GetStringFromTable("MapSystem", StringTables.MapSystem.TOOLTIP_SUGGESTED_RANK_RANGE_TIER2)
    elseif (tierNumber == 3) then
        tierNameStr = GetStringFromTable("MapSystem", StringTables.MapSystem.TOOLTIP_TIER3)
        tierRanksStr = GetStringFromTable("MapSystem", StringTables.MapSystem.TOOLTIP_SUGGESTED_RANK_RANGE_TIER3)
    elseif (tierNumber == 4) then
        tierNameStr = GetStringFromTable("MapSystem", StringTables.MapSystem.TOOLTIP_TIER4)
        tierRanksStr = GetStringFromTable("MapSystem", StringTables.MapSystem.TOOLTIP_SUGGESTED_RANK_RANGE_TIER4)
	end
    Tooltips.CreatePairingMapTierToolTip(tierNameStr, tierRanksStr, SystemData.ActiveWindow.name, Tooltips.ANCHOR_BOTTOM)
end


------------------------------------------------------------------
-- Pairing Status SideBar
------------------------------------------------------------------

    
function EA_Window_WorldMap.InitializeWarStatus()
        
    -- Set the Header for the overall Campaign Status    
    local text = GetStringFromTable("MapSystem", StringTables.MapSystem.LABEL_CAMPAIGN_STATUS )
    LabelSetText( "EA_Window_WorldMapPairingViewCampaignStatusHeader", text)
    
    EA_Window_WorldMap.InitCampaignTracker( "EA_Window_WorldMapPairingViewCampaignTracker" )
    EA_Window_WorldMap.ShowCampaignTrackerHotspots( "EA_Window_WorldMapPairingViewCampaignTracker", true )
    
    -- Set the Labels for each pairing.
    for pairingIndex = 1, EA_Window_WorldMap.NUM_PAIRINGS
    do
        local labelName  = "EA_Window_WorldMapPairingViewTitle"..pairingIndex
        
        -- Title
        local text = GetStringFromTable("MapSystem", StringTables.MapSystem.LABEL_PAIRING_1 + pairingIndex - 1)
        LabelSetText( labelName, GetStringFormatFromTable("MapSystem", StringTables.MapSystem.LABEL_PAIRING_NAME, {text} ) )        
    end

    EA_Window_WorldMap.UpdateWarStatus()

end



function EA_Window_WorldMap.UpdateWarStatus()

    -- Update the Icons
    EA_Window_WorldMap.UpdateCampaignTracker( "EA_Window_WorldMapPairingViewCampaignTracker" )
    
    local pairingsCaptured = { [GameData.Realm.ORDER] = {}, [GameData.Realm.DESTRUCTION] = {} }
    
    -- Update the display for each pairing
    for pairingIndex = 1, EA_Window_WorldMap.NUM_PAIRINGS
    do   
        
            local text = L""
        
            -- Update the pairing status
            local pairingData = GetCampaignPairingData( pairingIndex )
            if( pairingData )
            then    
        
                if( pairingData.controllingRealm ~= GameData.Realm.NONE )
                then
                
                    text = GetStringFormatFromTable("MapSystem", StringTables.MapSystem.TEXT_CAMPAIGN_PAIRING_CAPTURED, 
                                                    { GetRealmName( pairingData.controllingRealm ) } )                                                     
                                                
                    table.insert( pairingsCaptured[ pairingData.controllingRealm ], pairingIndex )            

                elseif( pairingData.isLocked )
                then
                   
                   text = GetStringFromTable("MapSystem", StringTables.MapSystem.TEXT_CAMPAIGN_PAIRING_LOCKED )                                                   

                
                else
                
                    text = GetStringFormatFromTable("MapSystem", StringTables.MapSystem.TEXT_CAMPAIGN_PAIRING_OPEN, 
                                                    { GetZoneName( pairingData.contestedZone ) } )
                                                        
                end        
                
            end        
                    
            local labelName  = "EA_Window_WorldMapPairingViewText"..pairingIndex
            LabelSetText( labelName, text)  
    end
    
    -- Update the overall Campaign Status
    local text1 = L""
    local text2 = L""
        
    -- No Pairings Captured
    if( (#pairingsCaptured[GameData.Realm.ORDER] == 0) and 
        (#pairingsCaptured[GameData.Realm.DESTRUCTION] == 0 ) )
    then
            
        text1 = GetStringFromTable("MapSystem", StringTables.MapSystem.TEXT_CAMPAIGN_STATUS_NO_FORTS_CAPTURED )
    
    -- Two Pairings Captured (City Open)
    elseif( (#pairingsCaptured[GameData.Realm.ORDER] == 2) or 
            (#pairingsCaptured[GameData.Realm.DESTRUCTION] == 2 ) )    
    then
        
        local cityId = 0
        if( #pairingsCaptured[GameData.Realm.ORDER] == 2)
        then
            cityId = GameData.CityId.CHAOS
        elseif( #pairingsCaptured[GameData.Realm.DESTRUCTION] == 2 )
        then
            cityId = GameData.CityId.EMPIRE
        end
        
        local cityName = GetCityName( cityId )
        local cityData = GetCampaignCityData( cityId )

        text1 = GetStringFormatFromTable("MapSystem", StringTables.MapSystem.TEXT_CAMPAIGN_CITY_OPEN, { cityName } )
    
    -- Max of one pairing Captured per realm  
    else
        
        -- Show the Order Status
        if( pairingsCaptured[GameData.Realm.ORDER][1] )
        then   
            local pairingId = pairingsCaptured[GameData.Realm.ORDER][1]
            local pairingData = GetCampaignPairingData( pairingId )
                   
            local realmName = GetRealmName( GameData.Realm.ORDER )     
            local zoneName = GetZoneName( pairingData.destructionFortressZone )
            local cityName = GetCityName( GameData.CityId.CHAOS )
            text1 = GetStringFormatFromTable("MapSystem", StringTables.MapSystem.TEXT_CAMPAIGN_STATUS_ONE_FORT_CAPTURED, {realmName, zoneName, cityName } )
        end
        
        -- Show the Destruction Status        
        if( pairingsCaptured[GameData.Realm.DESTRUCTION][1] )
        then   
            local pairingId = pairingsCaptured[GameData.Realm.DESTRUCTION][1]
            local pairingData = GetCampaignPairingData( pairingId )
            
            local realmName = GetRealmName( GameData.Realm.DESTRUCTION )     
            local zoneName = GetZoneName( pairingData.orderFortressZone )
            local cityName = GetCityName( GameData.CityId.EMPIRE )
            text2 = GetStringFormatFromTable("MapSystem", StringTables.MapSystem.TEXT_CAMPAIGN_STATUS_ONE_FORT_CAPTURED, {realmName, zoneName, cityName } )
        end
        
    end
    
    -- Update the Text
    LabelSetText( "EA_Window_WorldMapPairingViewCampaignStatusText1", text1)
    LabelSetText( "EA_Window_WorldMapPairingViewCampaignStatusText2", text2)
end

