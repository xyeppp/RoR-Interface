
----------------------------------------------------------------
-- Campaign Zones Def
----------------------------------------------------------------

EA_Window_WorldMap.campaignHotSpotData = {}

EA_Window_WorldMap.orderCityScenario = 2111
EA_Window_WorldMap.destructionCityScenario = 2110

EA_Window_WorldMap.campaignZones = 
{ 
    --------------------------------------
    -- Greenskins Vs. Dwarfs
    --------------------------------------
    
    -- GvD: Destruction Fort
    --[  4] = EA_Window_WorldMap.ICON_FORT_MINI,   
    
    -- GvD: Destruction Zone
    [  3]  = EA_Window_WorldMap.ICON_ZONE_MINI,  
            
    -- GvD: Center Zone
    [  5]  = EA_Window_WorldMap.ICON_ZONE_MINI,

    -- GvD: Order Zone
    [  9] = EA_Window_WorldMap.ICON_ZONE_MINI,

    -- GvD: Order Fort    
    --[ 10] = EA_Window_WorldMap.ICON_FORT_MINI,
        
    --------------------------------------
    -- Empire Vs. Chaos
    --------------------------------------

    -- EvC: Destruction Fort      
    --[104] = EA_Window_WorldMap.ICON_FORT_MINI,
    
    -- EvC:  Destruction Zone
    [103] = EA_Window_WorldMap.ICON_ZONE_MINI,
    
    -- EvC:  Center Zone
    [105] = EA_Window_WorldMap.ICON_ZONE_MINI,
    
    -- EvC:  Order Zone
    [109] = EA_Window_WorldMap.ICON_ZONE_MINI,
    
    -- EvC:  Order Forts
    --[110] = EA_Window_WorldMap.ICON_FORT_MINI,     
     
    --------------------------------------
    -- High Elves Vs. Dark Elves
    --------------------------------------
               
    -- HEvDE: Destruction Fort
    --[204] = EA_Window_WorldMap.ICON_FORT_MINI,
    
    -- HEvDE: Destruction Zone
    [203] = EA_Window_WorldMap.ICON_ZONE_MINI,
    
    -- HEvDE: Center Zone
    [205] = EA_Window_WorldMap.ICON_ZONE_MINI,
    
    -- HEvDE: Order Zone
    [209] = EA_Window_WorldMap.ICON_ZONE_MINI,
    
    -- HEvDE: Order Fort
    --[210] = EA_Window_WorldMap.ICON_FORT_MINI,

    --------------------------------------
    -- Cities
    --------------------------------------
    
    -- Destruction City        
    [161] = EA_Window_WorldMap.ICON_CITY_MINI,         
                    
    -- Order City        
    [162] = EA_Window_WorldMap.ICON_CITY_MINI,        

}



----------------------------------------------------------------
-- Campaign Util Functions
----------------------------------------------------------------

function EA_Window_WorldMap.InitCampaignTracker( trackerWindowName )

    -- Set the id on all of the zones
    for zoneId, _ in pairs( EA_Window_WorldMap.campaignZones )
    do
        local zoneWindowName = trackerWindowName.."Zone"..zoneId
        WindowSetId( zoneWindowName, zoneId )  
    end
    
    -- Reset hotspot data
    EA_Window_WorldMap.campaignHotSpotData[trackerWindowName] = {}
end


function EA_Window_WorldMap.UpdateCampaignTracker( trackerWindowName )

    -- Update the Control icons for all campaign zones 
    for zoneId, iconType in pairs( EA_Window_WorldMap.campaignZones )
    do
        local zoneWindowName = trackerWindowName.."Zone"..zoneId        
            
        local zoneData = GetCampaignZoneData( zoneId ) 
        if( zoneData ~= nil)
        then             
            local currentSliceName =  EA_Window_WorldMap.GetIconSliceForZone( zoneId, zoneData.pairingId, zoneData.controllingRealm, iconType )
            DynamicImageSetTextureSlice( zoneWindowName.."ControlIcon", currentSliceName  )
                        
            -- Gray out the Icons when locked
            if( zoneData.isLocked )
            then
                DefaultColor.SetWindowTint( zoneWindowName, DefaultColor.LIGHT_GRAY )
            else
                DefaultColor.SetWindowTint( zoneWindowName, DefaultColor.ZERO_TINT )
            end
            
            
            -- If this is a city zone, set the locks based the # forts captured
            if( GameDefs.ZoneCityIds[zoneId] ~= nil )
            then
                local cityData = GetCampaignCityData( GameDefs.ZoneCityIds[zoneId] )                
                WindowSetShowing(  zoneWindowName.."Lock1", cityData.numFortressesCaptured <= 1 )
                WindowSetShowing(  zoneWindowName.."Lock2", cityData.numFortressesCaptured == 0 )
      
            else                    
                -- Otherwise just use the zone control                 
                WindowSetShowing(  zoneWindowName.."ControlIconLock", false )--zoneData.controllingRealm ~= GameData.Realm.NONE )        
            end 
            
        end                        
        
    end
end

function EA_Window_WorldMap.ShowCampaignTrackerHotspots( trackerWindowName, show )
    for zoneId, iconType in pairs( EA_Window_WorldMap.campaignZones )
    do
        local hotspotSize = GameData.HotSpotSize.NONE
        if (show) then
            hotspotSize = GetZoneLargestHotspotSize( zoneId )
        end
            
        -- Figure out the size of the currently displayed hotspot from our saved array. Anything that's not in the array defaults to NONE.
        local oldHotspotSize = GameData.HotSpotSize.NONE
        if (EA_Window_WorldMap.campaignHotSpotData[trackerWindowName][zoneId] ~= nil) then
            oldHotspotSize = EA_Window_WorldMap.campaignHotSpotData[trackerWindowName][zoneId]
        end
            
        -- If the hotspot has changed size, then we need to update it
        if (hotspotSize ~= oldHotspotSize) then
            EA_Window_WorldMap.campaignHotSpotData[trackerWindowName][zoneId] = hotspotSize
                
            local parentWindowName = trackerWindowName.."Zone"..zoneId.."ControlIcon"
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
                templateName = templateName.."Tiny"
                                    
                CreateWindowFromTemplate( hotspotWindowName, templateName, parentWindowName)
                WindowAddAnchor( hotspotWindowName, "center", parentWindowName, "center", 0, 0 )
            end
        end
    end
end


----------------------------------------------------------------
-- Campaign HUD Map Window Functions
----------------------------------------------------------------


EA_Window_CampaignMap = {}

function EA_Window_CampaignMap.Initialize()

    LayoutEditor.RegisterWindow( "EA_Window_CampaignMap",
                                 GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_CAMPAIGN_STATUS_WINDOW_NAME ),
                                 GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_CAMPAIGN_STATUS_WINDOW_DESC ),
                                 false, false,
                                 true, nil )
    LayoutEditor.SetDefaultHidden( "EA_Window_CampaignMap", true )

    EA_Window_WorldMap.InitCampaignTracker( "EA_Window_CampaignMapTracker" )
    EA_Window_WorldMap.UpdateCampaignTracker( "EA_Window_CampaignMapTracker" )
    EA_Window_WorldMap.ShowCampaignTrackerHotspots( "EA_Window_CampaignMapTracker", true )

    WindowRegisterEventHandler( "EA_Window_CampaignMap", SystemData.Events.CAMPAIGN_PAIRING_UPDATED, "EA_Window_CampaignMap.OnCampaignPairingUpdated")
    WindowRegisterEventHandler( "EA_Window_CampaignMap", SystemData.Events.CAMPAIGN_CITY_UPDATED, "EA_Window_CampaignMap.OnCampaignCityUpdated")
    
    WindowRegisterEventHandler( "EA_Window_CampaignMap", SystemData.Events.PAIRING_MAP_HOTSPOT_DATA_UPDATED, "EA_Window_CampaignMap.OnPairingMapHotspotDataUpdated")
    
    if ( EA_Window_WorldMap.Settings.initializedCampaignTrackerShowing == nil )
    then
        -- Default campaign tracker to hidden
        LayoutEditor.UserHide( "EA_Window_CampaignMap" )
        EA_Window_WorldMap.Settings.initializedCampaignTrackerShowing = true
    end
end

function EA_Window_CampaignMap.Shutdown()
    LayoutEditor.UnregisterWindow( "EA_Window_CampaignMap" )
end

function EA_Window_CampaignMap.OnCampaignPairingUpdated( pairingId )
    EA_Window_WorldMap.UpdateCampaignTracker( "EA_Window_CampaignMapTracker" )
end

function EA_Window_CampaignMap.OnCampaignCityUpdated()
    EA_Window_WorldMap.UpdateCampaignTracker( "EA_Window_CampaignMapTracker" )
end

function EA_Window_CampaignMap.OnPairingMapHotspotDataUpdated()
    EA_Window_WorldMap.ShowCampaignTrackerHotspots( "EA_Window_CampaignMapTracker", true )
end

function EA_Window_CampaignMap.OnShown()
    EA_Window_WorldMap.UpdateCampaignTrackerButton()         
end

function EA_Window_CampaignMap.OnHidden()
    EA_Window_WorldMap.UpdateCampaignTrackerButton()
end


function EA_Window_CampaignMap.OnMouseOverZone()

    local zoneId    = WindowGetId( SystemData.ActiveWindow.name )
    EA_Window_WorldMap.CreateAppropriateZoneTooltip(zoneId, nil, nil)
    
end

function EA_Window_CampaignMap.OnClickZone()
    -- This function can be called from the Campaign Tracker HUD, in which case the map isn't visible and needs to be shown
    if (not WindowGetShowing("EA_Window_WorldMap")) then
        WindowSetShowing("EA_Window_WorldMap", true)
    end
    
    local selectedZone = WindowGetId(SystemData.MouseOverWindow.name)
    EA_Window_WorldMap.SetMap(GameDefs.MapLevel.ZONE_MAP, selectedZone)
end
