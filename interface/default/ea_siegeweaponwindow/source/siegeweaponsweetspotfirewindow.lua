----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------
----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

SiegeWeaponSweetSpotFireWindow = {}

SiegeWeaponSweetSpotFireWindow.TOOLTIP_ANCHOR = { Point = "bottom",  RelativeTo = "SiegeWeaponSweetSpotFireWindow", RelativePoint = "top",   XOffset = 0, YOffset = 0 }


-- Variables for the golf swing
SiegeWeaponSweetSpotFireWindow.swingTime  = { curTime=0, maxTime=0, direction=1 }
SiegeWeaponSweetSpotFireWindow.meterWidth = 0
SiegeWeaponSweetSpotFireWindow.meterHeight = 0
SiegeWeaponSweetSpotFireWindow.sliderOffset = 0

SiegeWeaponSweetSpotFireWindow.currentSliderOffset = 0

-- Windows that should be drawn on the screen when in Sniper Mode
local function DrawWindow( wndName, setShowing )
    return { windowName = wndName, shouldSetShowing = setShowing }
end

SiegeWeaponSweetSpotFireWindow.windows =
{
    DrawWindow( "SiegeWeaponGeneralFireWindow", true ),        
    DrawWindow( "SiegeWeaponSweetSpotFireWindow", true ),    
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
-- Local Variables
----------------------------------------------------------------

----------------------------------------------------------------
-- SiegeWeapon Functions
----------------------------------------------------------------

function SiegeWeaponSweetSpotFireWindow.Initialize()       
    
    WindowRegisterEventHandler( "SiegeWeaponSweetSpotFireWindow", SystemData.Events.SIEGE_WEAPON_SWEET_SPOT_BEGIN, "SiegeWeaponSweetSpotFireWindow.OnBeginFireMode" )
    WindowRegisterEventHandler( "SiegeWeaponSweetSpotFireWindow", SystemData.Events.SIEGE_WEAPON_SWEET_SPOT_END, "SiegeWeaponSweetSpotFireWindow.OnEndFireMode" )  
    WindowRegisterEventHandler( "SiegeWeaponSweetSpotFireWindow", SystemData.Events.SIEGE_WEAPON_SWEET_SPOT_RESET, "SiegeWeaponSweetSpotFireWindow.Reset" )  
    WindowRegisterEventHandler( "SiegeWeaponSweetSpotFireWindow", SystemData.Events.SIEGE_WEAPON_SWEET_SPOT_START_MOVING, "SiegeWeaponSweetSpotFireWindow.OnStartSwing" )  
    WindowRegisterEventHandler( "SiegeWeaponSweetSpotFireWindow", SystemData.Events.SIEGE_WEAPON_SWEET_SPOT_FIRE_RESULTS, "SiegeWeaponSweetSpotFireWindow.OnFireResults" )  

end


function SiegeWeaponSweetSpotFireWindow.Update( timePassed )

    --  Swing
    if( SiegeWeaponSweetSpotFireWindow.swingTime.maxTime ~= 0 ) 
    then


         SiegeWeaponSweetSpotFireWindow.swingTime.curTime = SiegeWeaponSweetSpotFireWindow.swingTime.curTime + timePassed*SiegeWeaponSweetSpotFireWindow.swingTime.direction         
            
         if( SiegeWeaponSweetSpotFireWindow.swingTime.curTime > SiegeWeaponSweetSpotFireWindow.swingTime.maxTime )
         then
            SiegeWeaponSweetSpotFireWindow.swingTime.curTime = SiegeWeaponSweetSpotFireWindow.swingTime.maxTime;
            SiegeWeaponSweetSpotFireWindow.swingTime.direction = -1
            
         elseif( SiegeWeaponSweetSpotFireWindow.swingTime.curTime < 0 )
         then
                SiegeWeaponSweetSpotFireWindow.swingTime.curTime = 0;
                SiegeWeaponSweetSpotFireWindow.swingTime.direction = 1     
         end
      
         
         local timePercent = SiegeWeaponSweetSpotFireWindow.swingTime.curTime/SiegeWeaponSweetSpotFireWindow.swingTime.maxTime   
        
         SiegeWeaponSweetSpotFireWindow.UpdateSwingMeter( timePercent )  
    end       
         
   
end

function SiegeWeaponSweetSpotFireWindow.OnBeginFireMode( randomRangePercent )

    if( SiegeWeaponControlWindow.controlData == nil ) 
    then
        return
    end
          
    -- Set the Instructions Text
    local text = GetStringFromTable("SiegeStrings", StringTables.Siege.TEXT_SWEET_SPOT_MODE_INSTRUCTIONS )
    SiegeWeaponGeneralFireWindow.SetInstructions( text )    
    
    -- Cache the width of the Golf Swing Meter
    local width, height = WindowGetDimensions( "SiegeWeaponSweetSpotFireWindowSwingMeter" )    
    SiegeWeaponSweetSpotFireWindow.meterWidth = width  
    SiegeWeaponSweetSpotFireWindow.meterHeight = height
        
    -- Cache the offset needed to center the slider
    local width, height = WindowGetDimensions( "SiegeWeaponSweetSpotFireWindowSwingMeterSlider" )   
    SiegeWeaponSweetSpotFireWindow.sliderOffset = width / 2    
    
    -- Reset the Slider
    SiegeWeaponSweetSpotFireWindow.Reset()   
    
    SiegeWeaponGeneralFireWindow.Begin( SiegeWeaponSweetSpotFireWindow.windows )   
   
   
end

function SiegeWeaponSweetSpotFireWindow.OnEndFireMode()
   SiegeWeaponGeneralFireWindow.End( SiegeWeaponSweetSpotFireWindow.windows )
end

function SiegeWeaponSweetSpotFireWindow.Reset()
        
    local text = GetStringFromTable("SiegeStrings", StringTables.Siege.SWEET_SPOT_STAGE_READY ) 
    
    LabelSetText( "SiegeWeaponSweetSpotFireWindowClickInstructionText", text )
    DefaultColor.SetLabelColor( "SiegeWeaponSweetSpotFireWindowClickInstructionText", DefaultColor.WHITE  )   
    
    WindowSetShowing( "SiegeWeaponSweetSpotFireWindowSucess", false )

    -- Hide the Sweet Spot
    WindowSetShowing( "SiegeWeaponSweetSpotFireWindowSwingMeterSweetSpotImage", false )

    -- Clear the Slider Tint 
    DefaultColor.SetWindowTint( "SiegeWeaponSweetSpotFireWindowSwingMeterSlider", DefaultColor.WHITE )      

    SiegeWeaponSweetSpotFireWindow.UpdateSwingMeter( 0 )
    
end


function SiegeWeaponSweetSpotFireWindow.UpdateSwingMeter( barPercent )

    local xOffset = SiegeWeaponSweetSpotFireWindow.meterWidth*barPercent - SiegeWeaponSweetSpotFireWindow.sliderOffset                
    local yOffset = -10
                            
    WindowSetOffsetFromParent( "SiegeWeaponSweetSpotFireWindowSwingMeterSlider", xOffset, yOffset )        
        
    SiegeWeaponSweetSpotFireWindow.currentSliderOffset = xOffset
end



function SiegeWeaponSweetSpotFireWindow.OnStartSwing( totalTime, sweetSpotStartPercent, sweetSpotWidthPercent )
    
    SiegeWeaponSweetSpotFireWindow.Reset()
    
    -- Set the animation paramters
    SiegeWeaponSweetSpotFireWindow.swingTime = { curTime=0, maxTime=totalTime, direction=1 }     
    
    -- Set the Click Instruction
    local text = GetStringFromTable("SiegeStrings", StringTables.Siege.SWEET_SPOT_STAGE_SWING )
    LabelSetText( "SiegeWeaponSweetSpotFireWindowClickInstructionText", text )    

    -- Position the Sweet Spot
    local xOffset = SiegeWeaponSweetSpotFireWindow.meterWidth * (sweetSpotStartPercent/100)
    local width   = SiegeWeaponSweetSpotFireWindow.meterWidth * (sweetSpotWidthPercent/100) 
    
    WindowClearAnchors( "SiegeWeaponSweetSpotFireWindowSwingMeterSweetSpotImage" )
    WindowAddAnchor( "SiegeWeaponSweetSpotFireWindowSwingMeterSweetSpotImage", "left", "SiegeWeaponSweetSpotFireWindowSwingMeter", "left", xOffset, 0 )
    WindowSetDimensions( "SiegeWeaponSweetSpotFireWindowSwingMeterSweetSpotImage", width, SiegeWeaponSweetSpotFireWindow.meterHeight )
   
   
   -- Show the Sweet Spot
   WindowSetShowing( "SiegeWeaponSweetSpotFireWindowSwingMeterSweetSpotImage", true  ) 
end

function SiegeWeaponSweetSpotFireWindow.OnFireResults( isWithinSweetSpot )
        
    -- Stop the Swing
    SiegeWeaponSweetSpotFireWindow.swingTime  = { curTime=0, maxTime=0, direction=1 }     
         
    -- Color The Slider & Text according to the result
    if( isWithinSweetSpot ) 
    then
        DefaultColor.SetWindowTint( "SiegeWeaponSweetSpotFireWindowSwingMeterSlider", DefaultColor.GREEN )         
        DefaultColor.SetWindowTint( "SiegeWeaponSweetSpotFireWindowSucessSlider", DefaultColor.GREEN  )  
        DefaultColor.SetLabelColor( "SiegeWeaponSweetSpotFireWindowClickInstructionText", DefaultColor.GREEN  )      
       
        local text = GetStringFromTable("SiegeStrings", StringTables.Siege.SWEET_SPOT_STAGE_FIRED_SUCESS )
        LabelSetText( "SiegeWeaponSweetSpotFireWindowClickInstructionText", text )    
    
    else
        
        DefaultColor.SetWindowTint( "SiegeWeaponSweetSpotFireWindowSwingMeterSlider", DefaultColor.RED )   
        DefaultColor.SetWindowTint( "SiegeWeaponSweetSpotFireWindowSucessSlider", DefaultColor.WHITE )          
        DefaultColor.SetLabelColor( "SiegeWeaponSweetSpotFireWindowClickInstructionText", DefaultColor.RED  )  
        
        local STRING_ID_BASE = "SWEET_SPOT_STAGE_FIRED_FAILED_"
        local NUM_FAIL_STRINGS = 3
        
        local stringId = StringTables.Siege[ STRING_ID_BASE..math.random( 1, NUM_FAIL_STRINGS ) ]
        local text = GetStringFromTable("SiegeStrings", stringId )
        LabelSetText( "SiegeWeaponSweetSpotFireWindowClickInstructionText", text )    
        
    end
    
    
end
