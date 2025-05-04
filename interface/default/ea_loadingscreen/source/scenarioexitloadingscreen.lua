----------------------------------------------------------------
-- Scenario Exit Loading Screen
----------------------------------------------------------------

---------------------------------------------------------------------------------

function EA_Window_LoadingScreen.InitScenarioExitLoadScreen()

end

function EA_Window_LoadingScreen.BeginScenarioExitLoadScreen( loadingData)

    local windowName = "EA_Window_LoadingScreenScenarioExit"    
    local contentsWindowName = "EA_Window_LoadingScreenScenarioExitContents"    
        
    -- Size the Window Images to fit the Screen Height while keeping the same aspect ratio    
    local uiScale                   = InterfaceCore.GetScale()
    local screenWidth, screenHeight = GetScreenResolution()    
    local imageWidth, imageHeight   = WindowGetDimensions( contentsWindowName.."LeftImage" )
    
    imageWidth = (screenHeight/uiScale)*(imageWidth/imageHeight)
    imageHeight  = screenHeight/uiScale    
    
    WindowSetDimensions( contentsWindowName.."LeftImage", imageWidth, imageHeight ) 
    WindowSetDimensions( contentsWindowName.."RightImage", imageWidth, imageHeight )
    
    -- Show the ScenarioSummaryWindow
    WindowSetShowing("ScenarioSummaryWindow", true )    
    ScenarioSummaryWindow.SetDisplayMode( ScenarioSummaryWindow.MODE_LOADING_SCREEN )

    local delay    = EA_Window_LoadingScreen.FADE_IN_TIME

    -- Fade in the Contents & Score Screen 
    WindowStartAlphaAnimation( contentsWindowName, Window.AnimationType.SINGLE_NO_RESET, 0, 1, 
            EA_Window_LoadingScreen.FADE_IN_TIME, true, delay, 0 )
        
   -- Start Animating the Shield Glow
    WindowStartAlphaAnimation( windowName.."ShieldGlow", Window.AnimationType.LOOP, 0.1, 1.0, 0.75, false, delay, 0) 
    
end

function EA_Window_LoadingScreen.EndScenarioExitLoadScreen()

    local windowName = "EA_Window_LoadingScreenScenarioExit"    
    local contentsWindowName = "EA_Window_LoadingScreenScenarioExitContents"
    
    -- Fade out the contents
    WindowStartAlphaAnimation( contentsWindowName, Window.AnimationType.SINGLE_NO_RESET, 1, 0, 
              EA_Window_LoadingScreen.FADE_IN_TIME, true, 0, 0 )

    -- Stop Animating the Shield Glow
    WindowStopAlphaAnimation( windowName.."ShieldGlow" ) 
end

function EA_Window_LoadingScreen.StopScenarioExitLoadScreen()

    -- Restore the Frame to the ScenarioSummaryWindow if it is currently in loading mode
    if ( ScenarioSummaryWindow.currentMode == ScenarioSummaryWindow.MODE_LOADING_SCREEN )
    then
        ScenarioSummaryWindow.SetDisplayMode( ScenarioSummaryWindow.MODE_IN_PROGRESS )
    end
end
