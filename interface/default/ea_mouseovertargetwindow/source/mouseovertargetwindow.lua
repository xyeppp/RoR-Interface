----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

MouseOverTargetWindow = 
{
    unitFrame = nil
}

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

MouseOverTargetWindow.WINDOW_MIN_HEIGHT = 18
MouseOverTargetWindow.WINDOW_MIN_WIDTH = 25
MouseOverTargetWindow.HP_LEVEL_HEIGHT   = 40

MouseOverTargetWindow.BACKGROUND_MIN_HEIGHT = 42
MouseOverTargetWindow.BACKGROUND_WIDTH      = 210

MouseOverTargetWindow.DEFAULT_CON_TEXT_COLOR = {r=249, g=243, b=169, a=255 }

-- TODO: It ends up that MouseOverTargetWindow is getting the player target updated
-- event before the real target window has a chance to show its targeting frame.
-- As such, there's no good way to determine which target frame is ABOUT to show...
-- (because TargetInfo:UnitName really needs to be an API function, and not a Lua function)
--
-- So, until the UnitName function is part of the game-API here's a little cheesy
-- countdown so that the mouse-over target gets updated properly...none of this matters
-- if the mouse over target is a static object, because those are always attached to the 
-- mouse cursor...which might actually be a good idea for the units as well...

-- When this timer is 0 it means there is no update pending.  
local c_APPROXIMATE_TIME_BEFORE_TARGET_WINDOW_APPEARS = 0.1
local anchorUpdateTimer = 0;

local c_MOUSEOVER_TARGET          = "mouseovertarget"
local c_MOUSEOVER_TARGET_WINDOW_UNIT_WINDOW = "MouseOverTargetUnitWindow"
local c_MOUSEOVER_CONTAINER_WINDOW = "MouseOverTargetWindow"

local c_MOUSEOVER_CONTAINER_WINDOW_ANCHOR  = 
{ 
    Point           = "topright", 
    RelativeTo      = c_MOUSEOVER_CONTAINER_WINDOW,
    RelativePoint   = "topright", 
    XOffset         = 0,
    YOffset         = 0,
}


----------------------------------------------------------------
-- ActionsWindow Functions
----------------------------------------------------------------

-- OnInitialize Handler
function MouseOverTargetWindow.Initialize()

    MouseOverTargetWindow.unitFrame = UnitFrames:CreateNewFrame (c_MOUSEOVER_TARGET_WINDOW_UNIT_WINDOW, UnitFrames.UNITFRAME_MOUSEOVER_TARGET, c_MOUSEOVER_TARGET)
    MouseOverTargetWindow.unitFrame:SetParent( c_MOUSEOVER_CONTAINER_WINDOW )
    MouseOverTargetWindow.unitFrame:SetScale( WindowGetScale( c_MOUSEOVER_CONTAINER_WINDOW ) )
    MouseOverTargetWindow.unitFrame:SetAnchor( c_MOUSEOVER_CONTAINER_WINDOW_ANCHOR )
    
    LayoutEditor.RegisterWindow( "MouseOverTargetWindow",
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_MOUSEOVER_TARGET_WINDOW_NAME ),
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_MOUSEOVER_TARGET_WINDOW_DESC ),
                                false, false,
                                true, nil )
        
    WindowRegisterEventHandler ("MouseOverTargetWindow", SystemData.Events.PLAYER_TARGET_UPDATED, "MouseOverTargetWindow.UpdateTarget")
        
end

function MouseOverTargetWindow.UpdateTarget( targetClassification, targetId, targetType )
    if( targetClassification ~= c_MOUSEOVER_TARGET )
    then
        return
    end

    -- This is a little cheesy, but works until we can better differentiate
    -- between target changes and target hp updates. -bmazza
    local oldMouseOverEntityId = TargetInfo:UnitEntityId("mouseovertarget")

    TargetInfo:UpdateFromClient ()    
    MouseOverTargetWindow.unitFrame:UpdateUnit ()

end














