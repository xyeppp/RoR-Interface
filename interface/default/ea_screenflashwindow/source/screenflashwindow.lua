----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

ScreenFlashWindow = {}


ScreenFlashWindow.DAMAGE_ALERT_COLOR = { r=255, g=0, b=0 }


ScreenFlashWindow.ANIMATION_DATA =
{
    duration = 1.5,
    delay = 0,
    startAlpha = 0.0,
    endAlpha = 1.0,
}


ScreenFlashWindow.enabledCount = 0;

ScreenFlashWindow.lastPlayerHitPoints = 0;

ScreenFlashWindow.curFlashTimer = 0

-- Scenario Frame Data

----------------------------------------------------------------
-- ScreenFlashWindow Functions
----------------------------------------------------------------

-- OnInitialize Handler
function ScreenFlashWindow.Initialize()
    
    
    -- WindowRegisterEventHandler( "ScreenFlashWindow", SystemData.Events.PLAYER_CUR_HIT_POINTS_UPDATED, "ScreenFlashWindow.OnPlayerHitPointsUpdated")
    
    
    -- WindowSetTintColor("ScreenFlashWindow", ScreenFlashWindow.DAMAGE_ALERT_COLOR.r, ScreenFlashWindow.DAMAGE_ALERT_COLOR.g, ScreenFlashWindow.DAMAGE_ALERT_COLOR.b )

end

function ScreenFlashWindow.OnUpdate( timePassed )

    -- if( ScreenFlashWindow.curFlashTimer > 0 ) then
    --     ScreenFlashWindow.curFlashTimer = ScreenFlashWindow.curFlashTimer - timePassed    
        
    --     if( ScreenFlashWindow.curFlashTimer < 0 ) then        
    --         ScreenFlashWindow.curFlashTimer = 0            
    --         WindowSetShowing( "ScreenFlashWindow", false )
    --     end
    -- end
end


-- This window can be enabled by many different windows in the game, so a simple
-- 'is enabled' flag isn't sufficent. Instead, we use a reference count to allow
-- for multiple windows to request this display.
function ScreenFlashWindow.SetEnabled( enabled )

    if( enabled ) then
        ScreenFlashWindow.enabledCount  = ScreenFlashWindow.enabledCount + 1
    else
        ScreenFlashWindow.enabledCount  = ScreenFlashWindow.enabledCount - 1
        
        if( ScreenFlashWindow.enabledCount < 0 ) then
            ScreenFlashWindow.enabledCount = 0            
        end        
    end

end

function ScreenFlashWindow.IsEnabled()
    return ScreenFlashWindow.enabledCount > 0
end

function ScreenFlashWindow.StartFlash()

    -- Don't show anything if the Flash Window is not enabled.
    if( not ScreenFlashWindow.IsEnabled() ) then
        return;    
    end


    -- Only play one flash at a time.
    if( ScreenFlashWindow.curFlashTimer > 0 ) then
        return
    end

    WindowSetShowing( "ScreenFlashWindow", true )
    WindowStartAlphaAnimation(  "ScreenFlashWindow",
                                Window.AnimationType.POP_AND_EASE,
                                ScreenFlashWindow.ANIMATION_DATA.startAlpha,                                
                                ScreenFlashWindow.ANIMATION_DATA.endAlpha,
                                ScreenFlashWindow.ANIMATION_DATA.duration,
                                true, 0, 0 )
                                
    ScreenFlashWindow.curFlashTimer = ScreenFlashWindow.ANIMATION_DATA.duration

end

function ScreenFlashWindow.OnPlayerHitPointsUpdated( )

    -- If the Player's Hitpoints have dropped, flash the window
    if( GameData.Player.hitPoints.current < ScreenFlashWindow.lastPlayerHitPoints ) then    
        ScreenFlashWindow.StartFlash()    
    end 

    ScreenFlashWindow.lastPlayerHitPoints = GameData.Player.hitPoints.current
end
