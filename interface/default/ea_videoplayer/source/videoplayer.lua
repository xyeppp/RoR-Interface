----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_VideoPlayer = 
{     
    -- Animation Values    
    FADE_OUT_TIME = 1.0,
    FADE_IN_TIME = 0.0,
}

-- Scenario Frame Data

----------------------------------------------------------------
-- EA_Window_VideoPlayer Functions
----------------------------------------------------------------

-- OnInitialize Handler
function EA_Window_VideoPlayer.Initialize()
    WindowRegisterEventHandler( "EA_Window_VideoPlayer", SystemData.Events.VIDEO_PLAYER_START, "EA_Window_VideoPlayer.OnVideoBegin" )
    WindowRegisterEventHandler( "EA_Window_VideoPlayer", SystemData.Events.VIDEO_PLAYER_STOP, "EA_Window_VideoPlayer.OnVideoEnd" )
      

    if( VideoPlayerIsPlaying() ) 
    then
        EA_Window_VideoPlayer.OnVideoBegin()
    end
end

function EA_Window_VideoPlayer.OnLButtonDown()
    -- This Callback is here to prevent mouse clicks from going through the window background
end

function EA_Window_VideoPlayer.OnVideoBegin()  
    --DEBUG( L"EA_Window_VideoPlayer.OnVideoBegin()")

    -- Set the Background Texture Dimensions according to the resolution
    if( SystemData.screenResolution.x / SystemData.screenResolution.y > 1.5 ) then
        -- widescreen ratio: 1440x900
        DynamicImageSetTextureDimensions( "EA_Window_VideoPlayerImage", 1280, 720 )
    else
        -- normal ratio: 1024x768
        DynamicImageSetTextureDimensions( "EA_Window_VideoPlayerImage", 1024, 768 )
    end 
    

   
    -- Show the Player
    WindowSetShowing( "EA_Window_VideoPlayer", true )   
    
    -- Fade in the Background
    local backgroundWindowName = "EA_Window_VideoPlayerBackground" 
    WindowStartAlphaAnimation( backgroundWindowName, Window.AnimationType.SINGLE_NO_RESET, 0, 1, 
            EA_Window_VideoPlayer.FADE_IN_TIME, true, 0, 0 )
          
end

function EA_Window_VideoPlayer.OnVideoEnd()
    --DEBUG( L"EA_Window_VideoPlayer.OnVideoEnd()")

    if( WindowGetShowing( "EA_Window_VideoPlayer" ) == false )
    then
        return
    end
    
    -- Fade out the background
    local backgroundWindowName = "EA_Window_VideoPlayerBackground" 
    WindowStartAlphaAnimation( backgroundWindowName, Window.AnimationType.SINGLE_NO_RESET_HIDE, 1, 0, 
             EA_Window_VideoPlayer.FADE_OUT_TIME, true, 0, 0 )
    
end