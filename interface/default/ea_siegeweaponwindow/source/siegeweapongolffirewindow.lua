----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------
----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

SiegeWeaponGolfFireWindow = {}

SiegeWeaponGolfFireWindow.TOOLTIP_ANCHOR = { Point = "bottom",  RelativeTo = "SiegeWeaponGolfFireWindow", RelativePoint = "top",   XOffset = 0, YOffset = 0 }


-- Variables for the golf swing
SiegeWeaponGolfFireWindow.backSwingTime  = { remaining=0, maxTime=0 }
SiegeWeaponGolfFireWindow.forewardSwingTime  = { remaining=0, maxTime=0 }
SiegeWeaponGolfFireWindow.meterWidth = 0
SiegeWeaponGolfFireWindow.sliderOffset = 0

SiegeWeaponGolfFireWindow.currentSliderOffset = 0

SiegeWeaponGolfFireWindow.BACKWARD_SWING_ANIMATION =
{
    windowName = "SiegeWeaponGolfFireWindowSwingMeterSlider",
    animType = Window.AnimationType.SINGLE_NO_RESET,
    startX = 0,
    startY = -10,
    endX   = 0,
    endY   = -10,
    timeRate = 1.0,
    setStartBeforeDelay = false,
    delay=0,
    loopCount=0,

}

SiegeWeaponGolfFireWindow.FORWARD_SWING_ANIMATION =
{
    windowName = "SiegeWeaponGolfFireWindowSwingMeterSlider",
    animType = Window.AnimationType.SINGLE_NO_RESET,
    startX = 0,
    startY = -10,
    endX   = 0,
    endY   = -10,
    timeRate = 1.0,
    setStartBeforeDelay = false,
    delay=0,
    loopCount=0,

}

-- Windows that should be drawn on the screen when in Sniper Mode
local function DrawWindow( wndName, setShowing )
    return { windowName = wndName, shouldSetShowing = setShowing }
end

SiegeWeaponGolfFireWindow.windows =
{
    DrawWindow( "SiegeWeaponGeneralFireWindow", true ),        
    DrawWindow( "SiegeWeaponGolfFireWindow", true ),    
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
    DrawWindow( "SiegeWeaponUsersWindow", false ),
    
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

function SiegeWeaponGolfFireWindow.Initialize()       
    
    WindowRegisterEventHandler( "SiegeWeaponGolfFireWindow", SystemData.Events.SIEGE_WEAPON_GOLF_BEGIN, "SiegeWeaponGolfFireWindow.OnBeginFireMode" )
    WindowRegisterEventHandler( "SiegeWeaponGolfFireWindow", SystemData.Events.SIEGE_WEAPON_GOLF_END, "SiegeWeaponGolfFireWindow.OnEndFireMode" )  
    WindowRegisterEventHandler( "SiegeWeaponGolfFireWindow", SystemData.Events.SIEGE_WEAPON_GOLF_RESET, "SiegeWeaponGolfFireWindow.Reset" )  
    WindowRegisterEventHandler( "SiegeWeaponGolfFireWindow", SystemData.Events.SIEGE_WEAPON_GOLF_START_BACK_SWING, "SiegeWeaponGolfFireWindow.OnStartBackSwing" )  
    WindowRegisterEventHandler( "SiegeWeaponGolfFireWindow", SystemData.Events.SIEGE_WEAPON_GOLF_START_FORWARD_SWING, "SiegeWeaponGolfFireWindow.OnStartForwardSwing" )  

end


function SiegeWeaponGolfFireWindow.Update( timePassed )

    -- Backward Swing
    if( SiegeWeaponGolfFireWindow.backSwingTime.remaining > 0 ) 
    then
         SiegeWeaponGolfFireWindow.backSwingTime.remaining = SiegeWeaponGolfFireWindow.backSwingTime.remaining - timePassed
         
         local timePercent = (SiegeWeaponGolfFireWindow.backSwingTime.maxTime-SiegeWeaponGolfFireWindow.backSwingTime.remaining)/SiegeWeaponGolfFireWindow.backSwingTime.maxTime
         SiegeWeaponGolfFireWindow.UpdateSwingMeter( timePercent )         
    end
    
    -- Forward Swing 
    if( SiegeWeaponGolfFireWindow.forewardSwingTime.remaining > 0 ) 
    then
         SiegeWeaponGolfFireWindow.forewardSwingTime.remaining = SiegeWeaponGolfFireWindow.forewardSwingTime.remaining - timePassed
         
         local timePercent = (SiegeWeaponGolfFireWindow.forewardSwingTime.remaining)/SiegeWeaponGolfFireWindow.forewardSwingTime.maxTime
         SiegeWeaponGolfFireWindow.UpdateSwingMeter( timePercent )         
    end

end

function SiegeWeaponGolfFireWindow.OnBeginFireMode( targetPercent )

    if( SiegeWeaponControlWindow.controlData == nil ) 
    then
        return
    end
      
    -- Set the Instructions Text
    local text = GetStringFromTable("SiegeStrings", StringTables.Siege.TEXT_GOLF_MODE_INSTRUCTIONS )
    SiegeWeaponGeneralFireWindow.SetInstructions( text )    
    
    -- Cache the width of the Golf Swing Meter
    local width, height = WindowGetDimensions( "SiegeWeaponGolfFireWindowSwingMeter" )    
    SiegeWeaponGolfFireWindow.meterWidth = width  
    
    -- Size the Gradient Bar to match the target percent      
    local width, height = WindowGetDimensions( "SiegeWeaponGolfFireWindowSwingMeterSweetSpotGradient" )    
    width = SiegeWeaponGolfFireWindow.meterWidth * (targetPercent/100)
    WindowSetDimensions( "SiegeWeaponGolfFireWindowSwingMeterSweetSpotGradient", width, height )   
    
    -- Cache the offset needed to center the slider
    local width, height = WindowGetDimensions( "SiegeWeaponGolfFireWindowSwingMeterSlider" )   
    SiegeWeaponGolfFireWindow.sliderOffset = width / 2    
    
    -- Reset the Slider
    SiegeWeaponGolfFireWindow.Reset()   
    
    SiegeWeaponGeneralFireWindow.Begin( SiegeWeaponGolfFireWindow.windows )
    SiegeWeaponControlWindow.ShowUsersNames( true )
     
end

function SiegeWeaponGolfFireWindow.OnEndFireMode()
    SiegeWeaponGeneralFireWindow.End( SiegeWeaponGolfFireWindow.windows )
   SiegeWeaponControlWindow.ShowUsersNames( false )
end

function SiegeWeaponGolfFireWindow.Reset()
        
    local text = L""
    if( GameData.SiegeWeapon.isPlayerController )
    then
        text = GetStringFromTable("SiegeStrings", StringTables.Siege.TEXT_GOLF_SWING_STAGE_READY_CONTROLLER )
    else
        local controllerName = SiegeWeaponControlWindow.currentUsers[1].name
        text = GetStringFormatFromTable("SiegeStrings", StringTables.Siege.TEXT_GOLF_SWING_STAGE_READY_NON_CONTROLLER, { controllerName } )
    end   
    
    LabelSetText( "SiegeWeaponGolfFireWindowClickInstructionText", text )
    DefaultColor.SetLabelColor( "SiegeWeaponGolfFireWindowClickInstructionText", DefaultColor.WHITE  )   
    
    WindowSetShowing( "SiegeWeaponGolfFireWindowSucess", false )

    -- Clear the Slider Tint 
    DefaultColor.SetWindowTint( "SiegeWeaponGolfFireWindowSwingMeterSlider", DefaultColor.WHITE )      

    SiegeWeaponGolfFireWindow.UpdateSwingMeter( 0 )
end


function SiegeWeaponGolfFireWindow.UpdateSwingMeter( barPercent )
         
    local xOffset = SiegeWeaponGolfFireWindow.meterWidth*barPercent - SiegeWeaponGolfFireWindow.sliderOffset                
    local yOffset = -10
                            
    WindowSetOffsetFromParent( "SiegeWeaponGolfFireWindowSwingMeterSlider", xOffset, yOffset )        
    
    
    SiegeWeaponGolfFireWindow.currentSliderOffset = xOffset
end



function SiegeWeaponGolfFireWindow.OnStartBackSwing( totalTime )
    
    -- Set the animation paramters
    SiegeWeaponGolfFireWindow.backSwingTime = { remaining=totalTime, maxTime=totalTime }     
    
    -- Set the Click Instruction
    local text = GetStringFromTable("SiegeStrings", StringTables.Siege.TEXT_GOLF_SWING_STAGE_BACKSWING )
    LabelSetText( "SiegeWeaponGolfFireWindowClickInstructionText", text )
    
    --[[
    local startPos = { x=0, y=-20 }
    local endPos = { x=SiegeWeaponGolfFireWindow.meterWidth+
     
    
    WindowStartPositionAnimation( "SiegeWeaponGolfFireWindowSwingMeterSlider", 
                                  Window.AnimationType.SINGLE_NO_RESET

    --]]
end

function SiegeWeaponGolfFireWindow.OnStartForwardSwing( forwardSwingTime, percentPower, isLateRelease )
        
    -- Set the % Text    
    local powerText = L""..percentPower
    local text = GetStringFormatFromTable("SiegeStrings", StringTables.Siege.TEXT_GOLF_SWING_SUCCESS, { powerText } ) 
                    
    LabelSetText("SiegeWeaponGolfFireWindowSucessText", text )    
    WindowSetShowing( "SiegeWeaponGolfFireWindowSucess", true )
        
    -- Anchor the text to the current slider location.    
    local xOffset = SiegeWeaponGolfFireWindow.currentSliderOffset
    local yOffset = -10    
    WindowClearAnchors( "SiegeWeaponGolfFireWindowSucess" )
    WindowAddAnchor( "SiegeWeaponGolfFireWindowSucess", "topleft", "SiegeWeaponGolfFireWindowSwingMeter", "top", xOffset, yOffset )      
    
    -- Update the Swing
    local curSwingPercent = (SiegeWeaponGolfFireWindow.backSwingTime.maxTime-SiegeWeaponGolfFireWindow.backSwingTime.remaining)/SiegeWeaponGolfFireWindow.backSwingTime.maxTime
    SiegeWeaponGolfFireWindow.backSwingTime  = { remaining=0, maxTime=0 }     
    SiegeWeaponGolfFireWindow.forewardSwingTime  = { remaining=forwardSwingTime, maxTime=forwardSwingTime/curSwingPercent }     
    
    -- Clear the Click Instruction    
    LabelSetText( "SiegeWeaponGolfFireWindowClickInstructionText", L"" )
    
    -- Color The Slider & Text according to the late hit.
    if( isLateRelease ) 
    then
        DefaultColor.SetWindowTint( "SiegeWeaponGolfFireWindowSwingMeterSlider", DefaultColor.RED )         
        DefaultColor.SetWindowTint( "SiegeWeaponGolfFireWindowSucessSlider", DefaultColor.RED  )  
        DefaultColor.SetLabelColor( "SiegeWeaponGolfFireWindowSucessText", DefaultColor.RED  )  
    else
        DefaultColor.SetWindowTint( "SiegeWeaponGolfFireWindowSwingMeterSlider", DefaultColor.WHITE )   
        DefaultColor.SetWindowTint( "SiegeWeaponGolfFireWindowSucessSlider", DefaultColor.WHITE )          
        DefaultColor.SetLabelColor( "SiegeWeaponGolfFireWindowSucessText", DefaultColor.YELLOW  )  
    end
end
