----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

SiegeWeaponSniperFireWindow = {}


SiegeWeaponSniperFireWindow.HEALTH_BAR_COLOR = {r=0, g=255, b=0 }
SiegeWeaponSniperFireWindow.REUSE_TIMER_BAR_COLOR = {r=255, g=255, b=0 }


SiegeWeaponSniperFireWindow.TOOLTIP_ANCHOR = { Point = "bottom",  RelativeTo = "SiegeWeaponSniperFireWindow", RelativePoint = "top",   XOffset = 0, YOffset = 0 }

SiegeWeaponSniperFireWindow.CROSS_HAIRS_SIZE_MIN = 400
SiegeWeaponSniperFireWindow.CROSS_HAIRS_SIZE_MAX = 1000
SiegeWeaponSniperFireWindow.CROSS_HAIRS_SIZE_RANGE = SiegeWeaponSniperFireWindow.CROSS_HAIRS_SIZE_MAX - SiegeWeaponSniperFireWindow.CROSS_HAIRS_SIZE_MIN

-- Variables for the current weapon
SiegeWeaponSniperFireWindow.curTarget = { name=L"", objectNum=0 }
SiegeWeaponSniperFireWindow.aimTime  ={ current=0, maxNeeded=0 }
SiegeWeaponSniperFireWindow.remainingReloadTime = 0

SiegeWeaponSniperFireWindow.TARGET_COLOR = { r=255, g=0, b=0 }
SiegeWeaponSniperFireWindow.TARGET_COLOR_NO_LOS = { r=255, g=100, b=0 }
SiegeWeaponSniperFireWindow.NO_TARGET_COLOR = { r=150, g=150, b=150 }
SiegeWeaponSniperFireWindow.INVALID_TARGET_COLOR = { r=0, g=178, b=255 }


-- Windows that should be drawn on the screen when in Sniper Mode
local function DrawWindow( wndName, setShowing )
    return { windowName = wndName, shouldSetShowing = setShowing }
end

SiegeWeaponSniperFireWindow.windows =
{
    DrawWindow( "SiegeWeaponGeneralFireWindow", true ),        
    DrawWindow( "SiegeWeaponSniperFireWindow", true ),    
    DrawWindow( "SiegeWeaponInfoWindow", false ),
    DrawWindow( "SiegeWeaponStatusWindow", false ),
    DrawWindow( "PlayerWindow", false ),
    DrawWindow( "PrimaryTargetLayoutWindow", false ),
    DrawWindow( "SecondaryTargetLayoutWindow", false ),
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
-- Local Variables
----------------------------------------------------------------

----------------------------------------------------------------
-- SiegeWeapon Functions
----------------------------------------------------------------

function SiegeWeaponSniperFireWindow.Initialize()       
    
    WindowRegisterEventHandler( "SiegeWeaponSniperFireWindow", SystemData.Events.SIEGE_WEAPON_SNIPER_BEGIN, "SiegeWeaponSniperFireWindow.OnBeginFireMode" )
    WindowRegisterEventHandler( "SiegeWeaponSniperFireWindow", SystemData.Events.SIEGE_WEAPON_SNIPER_END, "SiegeWeaponSniperFireWindow.OnEndFireMode" )  
    WindowRegisterEventHandler( "SiegeWeaponSniperFireWindow", SystemData.Events.SIEGE_WEAPON_SNIPER_AIM_TIME_UPDATED, "SiegeWeaponSniperFireWindow.OnAimTimeUpdated" )  
    WindowRegisterEventHandler( "SiegeWeaponSniperFireWindow", SystemData.Events.SIEGE_WEAPON_SNIPER_AIM_TARGET_UPDATED, "SiegeWeaponSniperFireWindow.OnAimTargetUpdated" )  
    WindowRegisterEventHandler( "SiegeWeaponSniperFireWindow", SystemData.Events.SIEGE_WEAPON_SNIPER_AIM_TARGET_LOS_UPDATED, "SiegeWeaponSniperFireWindow.OnAimTargetLOSUpdated" )  
    WindowRegisterEventHandler( "SiegeWeaponSniperFireWindow", SystemData.Events.SIEGE_WEAPON_REUSE_TIMER_UPDATED, "SiegeWeaponSniperFireWindow.OnUpdateReuseTimer" )

    -- Update the Cross Hairs
    SiegeWeaponSniperFireWindow.UpdateCrossHairsSize( SiegeWeaponSniperFireWindow.CROSS_HAIRS_SIZE_MIN  )
end


function SiegeWeaponSniperFireWindow.Update( timePassed )

    -- If the weapon is reloading, decrement the reload time
    if( SiegeWeaponSniperFireWindow.remainingReloadTime > 0 ) then
        SiegeWeaponSniperFireWindow.remainingReloadTime = SiegeWeaponSniperFireWindow.remainingReloadTime - timePassed
        if( SiegeWeaponSniperFireWindow.remainingReloadTime < 0 ) then
            SiegeWeaponSniperFireWindow.remainingReloadTime = 0
            SiegeWeaponSniperFireWindow.UpdateCrossHairsColor()
        end
    else
        
        -- Otherwise, Increment the aim time
        if( SiegeWeaponSniperFireWindow.aimTime.current ~= SiegeWeaponSniperFireWindow.aimTime.maxNeeded ) then
        
            SiegeWeaponSniperFireWindow.aimTime.current = SiegeWeaponSniperFireWindow.aimTime.current + timePassed
            
            -- Update the cross Hairs size.
            local aimPercent = math.min( SiegeWeaponSniperFireWindow.aimTime.current / SiegeWeaponSniperFireWindow.aimTime.maxNeeded, 1.0 ) 
            local size = SiegeWeaponSniperFireWindow.CROSS_HAIRS_SIZE_MAX - aimPercent*SiegeWeaponSniperFireWindow.CROSS_HAIRS_SIZE_RANGE
            SiegeWeaponSniperFireWindow.UpdateCrossHairsSize( size  )
            
        end  
    
    end
    
end

function SiegeWeaponSniperFireWindow.OnBeginFireMode()

    if( SiegeWeaponControlWindow.controlData == nil ) then
        return
    end
    
    -- Set the Instructions Text
    local text = GetStringFromTable("SiegeStrings", StringTables.Siege.TEXT_SNIPER_MODE_INSTRUCTIONS )
    SiegeWeaponGeneralFireWindow.SetInstructions( text )
    
    SiegeWeaponGeneralFireWindow.Begin( SiegeWeaponSniperFireWindow.windows )
   
end

function SiegeWeaponSniperFireWindow.OnEndFireMode()
    SiegeWeaponGeneralFireWindow.End( SiegeWeaponSniperFireWindow.windows )
end

function SiegeWeaponSniperFireWindow.UpdateCrossHairsSize( size )
   WindowSetDimensions( "SiegeWeaponSniperFireWindowCrossHairs", size, size )
end

function SiegeWeaponSniperFireWindow.UpdateCrossHairsColor()
 
    -- Update the tint on the reticule
    local color = SiegeWeaponSniperFireWindow.NO_TARGET_COLOR 
    
    -- Yellow if the Reload timer is running
    if( SiegeWeaponSniperFireWindow.remainingReloadTime > 0 ) 
    then
        color = SiegeWeaponControlWindow.REUSE_TIMER_BAR_COLOR    
        
    -- Red if we have a target    
    elseif( SiegeWeaponSniperFireWindow.curTarget.objectNum ~= 0 ) 
    then
    
        if( SiegeWeaponSniperFireWindow.curTarget.isValid == false )
        then
             color = SiegeWeaponSniperFireWindow.INVALID_TARGET_COLOR    
             
        elseif( SiegeWeaponSniperFireWindow.curTargetLOS == true ) 
        then
            color = SiegeWeaponSniperFireWindow.TARGET_COLOR 
            
        else
            color = SiegeWeaponSniperFireWindow.TARGET_COLOR_NO_LOS     
        end
    end
    
    WindowSetTintColor( "SiegeWeaponSniperFireWindowCrossHairs", color.r, color.g, color.b )

end

function SiegeWeaponSniperFireWindow.OnAimTimeUpdated( maxTimeNeeded, curAimTime )
    SiegeWeaponSniperFireWindow.aimTime = { current=curAimTime, maxNeeded=maxTimeNeeded }
end

function SiegeWeaponSniperFireWindow.OnAimTargetUpdated( targetName, targetObjNum, targetIsValid )
    SiegeWeaponSniperFireWindow.curTarget = { name=targetName, objectNum=targetObjNum, isValid=targetIsValid }
    SiegeWeaponSniperFireWindow.UpdateCrossHairsColor()
end


function SiegeWeaponSniperFireWindow.OnAimTargetLOSUpdated( inLos )
    SiegeWeaponSniperFireWindow.curTargetLOS = inLos
    SiegeWeaponSniperFireWindow.UpdateCrossHairsColor()
end

function SiegeWeaponSniperFireWindow.OnUpdateReuseTimer()
    SiegeWeaponSniperFireWindow.remainingReloadTime = GameData.SiegeWeapon.currentReuseTimer
    SiegeWeaponSniperFireWindow.UpdateCrossHairsColor()
end
