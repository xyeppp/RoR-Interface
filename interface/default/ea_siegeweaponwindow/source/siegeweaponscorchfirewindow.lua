----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

SiegeWeaponScorchFireWindow = {}

-- Variables for the current weapon

SiegeWeaponScorchFireWindow.remainingFireTime = 0

SiegeWeaponScorchFireWindow.TARGET_COLOR = { r=255, g=0, b=0 }
SiegeWeaponScorchFireWindow.NO_TARGET_COLOR = { r=150, g=150, b=150 }


-- Windows that should be drawn on the screen when in Sniper Mode
local function DrawWindow( wndName, setShowing )
    return { windowName = wndName, shouldSetShowing = setShowing }
end

SiegeWeaponScorchFireWindow.windows =
{    
    DrawWindow( "SiegeWeaponGeneralFireWindow", true ),        
    DrawWindow( "SiegeWeaponScorchFireWindow", true ),    
    DrawWindow( "SiegeWeaponInfoWindow", false ),
    DrawWindow( "SiegeWeaponStatusWindow", false ),
    DrawWindow( "PlayerWindow", false ),
    DrawWindow( "ScreenFlashWindow", false ),
    DrawWindow( "AlertTextContainerWindow", false ),
    DrawWindow( "EA_Window_EventTextContainer", false ),
    DrawWindow( "LayerTimerWindow", false ),
    DrawWindow( "GroupWindow", false ),
    
    -- Objective Trackers
    DrawWindow( "EA_Window_PublicQuestTracker", false ),
    DrawWindow( "EA_Window_BattlefieldObjectiveTracker" , false ),
    DrawWindow( "EA_Window_KeepObjectiveTracker", false ),
    DrawWindow( "EA_Window_CityTracker", false ),
    DrawWindow( "EA_Window_ScenarioTracker", false ),
    DrawWindow( "EA_Window_PublicQuestResults", false ),
    DrawWindow( "EA_Window_LootRoll", false ),
}

----------------------------------------------------------------
-- SiegeWeapon Functions
----------------------------------------------------------------

function SiegeWeaponScorchFireWindow.Initialize()       
    
    WindowRegisterEventHandler( "SiegeWeaponScorchFireWindow", SystemData.Events.SIEGE_WEAPON_SCORCH_BEGIN, "SiegeWeaponScorchFireWindow.OnBeginFireMode" )
    WindowRegisterEventHandler( "SiegeWeaponScorchFireWindow", SystemData.Events.SIEGE_WEAPON_SCORCH_END, "SiegeWeaponScorchFireWindow.OnEndFireMode" )  
    WindowRegisterEventHandler( "SiegeWeaponScorchFireWindow", SystemData.Events.SIEGE_WEAPON_SCORCH_POWER_UPDATED, "SiegeWeaponScorchFireWindow.OnPowerUpdated" )  
    WindowRegisterEventHandler( "SiegeWeaponScorchFireWindow", SystemData.Events.SIEGE_WEAPON_SCORCH_WIND_UPDATED, "SiegeWeaponScorchFireWindow.OnWindUpdated" )  

    -- Set the Power Text
    LabelSetText( "SiegeWeaponScorchFireWindowPowerMeterTitle", GetStringFromTable("SiegeStrings", StringTables.Siege.TEXT_FIRE_POWER ) )
    LabelSetText( "SiegeWeaponScorchFireWindowWindMeterTitle", GetStringFromTable("SiegeStrings", StringTables.Siege.TEXT_WIND ) )
      
end


function SiegeWeaponScorchFireWindow.Update( timePassed )
    
end

function SiegeWeaponScorchFireWindow.OnBeginFireMode( maximumFireTime )

    SiegeWeaponScorchFireWindow.remainingFireTime = maximumFireTime

    if( SiegeWeaponControlWindow.controlData == nil ) then
        return
    end

    -- Initialize the map
    CreateMapInstance( "SiegeWeaponScorchFireWindowAimWindowMapDisplay", SystemData.MapTypes.OVERHEAD )    
    MapSetMapView( "SiegeWeaponScorchFireWindowAimWindowMapDisplay", GameDefs.MapLevel.ZONE_MAP, GameData.Player.zone  )
    
    -- Zoom the map all the way out
    SiegeWeaponScorchFireWindow.cachedOverheadZoomLevel = GetOverheadMapZoomLevel()
    SetOverheadMapZoomLevel( SystemData.OverheadMap.MIN_ZOOM_LEVEL )
    
    
    -- Hide all point types not related to firing siege weapons
    for index, filterType in pairs( SystemData.MapPips ) do
        MapSetPinFilter("SiegeWeaponScorchFireWindowAimWindowMapDisplay", filterType, false )
    end   
    MapSetPinFilter("SiegeWeaponScorchFireWindowAimWindowMapDisplay", SystemData.MapPips.PLAYER_SIEGE_WEAPON, true ) 
    MapSetPinFilter("SiegeWeaponScorchFireWindowAimWindowMapDisplay", SystemData.MapPips.PLAYER_SIEGE_AIM_LOCATION, true ) 
         
    
    -- Set the Instructions Text
    local text = GetStringFromTable("SiegeStrings", StringTables.Siege.TEXT_SCORCH_MODE_INSTRUCTIONS )
    SiegeWeaponGeneralFireWindow.SetInstructions( text )
    
    SiegeWeaponGeneralFireWindow.Begin( SiegeWeaponScorchFireWindow.windows )
  
end

function SiegeWeaponScorchFireWindow.OnEndFireMode()
    SiegeWeaponGeneralFireWindow.End( SiegeWeaponScorchFireWindow.windows )
        
    SiegeSetWindDirectionImage( "" )
     
    RemoveMapInstance( "SiegeWeaponScorchFireWindowAimWindowMapDisplay" )    
   
    -- Restore the Map Zoom
    SetOverheadMapZoomLevel( SiegeWeaponScorchFireWindow.cachedOverheadZoomLevel )
end

function SiegeWeaponScorchFireWindow.OnPowerUpdated( powerValue )
    
    -- Adjust the anchoring of the power meter to reflect the new value.    
    local backgroundWidth, backgroundHeight = WindowGetDimensions( "SiegeWeaponScorchFireWindowPowerMeterBackgroundImage" )
    local barWidth, barHeight = WindowGetDimensions( "SiegeWeaponScorchFireWindowPowerMeterCurrentForceBar" )
        
    local yOffset = (backgroundHeight - barHeight) * ( (100 - powerValue)/100 )
    
    WindowClearAnchors( "SiegeWeaponScorchFireWindowPowerMeterCurrentForceBar" )
    WindowAddAnchor( "SiegeWeaponScorchFireWindowPowerMeterCurrentForceBar", "top", "SiegeWeaponScorchFireWindowPowerMeterBackgroundImage", "top", 0, yOffset )

end

function SiegeWeaponScorchFireWindow.OnWindUpdated( windDirection, windForce )

    -- Set the Window Arrow Image based on the force
    for index = 1, 4 
    do 
        local show = index == windForce
        local windowName = "SiegeWeaponScorchFireWindowWindMeterArrow"..index

        WindowSetShowing(windowName, show )
        if( show )
        then        
            SiegeSetWindDirectionImage( windowName )
        end  
    end 
  
end
