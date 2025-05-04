----------------------------------------------------------------
-- Scenario Enter Loading Screen
----------------------------------------------------------------
local numTrialNoteItemWindows = 0

EA_Window_LoadingScreen.preloadedMapZoneId = 0


function EA_Window_LoadingScreen.InitScenarioEnterLoadScreen()

    WindowRegisterEventHandler( "EA_Window_LoadingScreenScenarioEnter", SystemData.Events.SCENARIO_STARTING_SCENARIO_UPDATED, "EA_Window_LoadingScreen.OnStartingScenarioUpdated" )        
    
    local windowName = "EA_Window_LoadingScreenScenarioEnter"
    local contentsWindowName = "EA_Window_LoadingScreenScenarioEnterContents"
    local textContainerName = contentsWindowName.."TextContainer"
    
    -- LOADING Heading
    local loadingText = GetStringFromTable( "HUDStrings", StringTables.HUD.TEXT_LOADING_SCREEN_LOADING )    
    LabelSetText( textContainerName.."HeadingLine1", loadingText )
        
    -- INSTRUCTIONS Heading
    local instructionsText = GetStringFromTable( "HUDStrings", StringTables.HUD.TEXT_LOADING_SCREEN_INSTRUCTIONS )    
    LabelSetText( textContainerName.."InstructionsLabel", instructionsText )       
        
    AnimatedImageSetPlaySpeed( windowName.."PageFlipAnim", EA_Window_LoadingScreen.FLIP_FPS )
    
    -- Create the Map    
    CreateMapInstance( textContainerName.."MapDisplay", SystemData.MapTypes.NORMAL ) 
    
    -- Streaming 
    local streamingText = GetStringFromTable( "HUDStrings", StringTables.HUD.TEXT_LOADING_SCREEN_STREAMING )
    local streamingText2 = GetStringFromTable( "HUDStrings", StringTables.HUD.TEXT_LOADING_SCREEN_STREAMING2 )
    LabelSetText( textContainerName.."StreamingText", streamingText )
    LabelSetText( textContainerName.."StreamingText2", streamingText2 )
end

function EA_Window_LoadingScreen.ShutdownScenarioEnterLoadScreen()

    local textContainerName = "EA_Window_LoadingScreenScenarioEnterContentsTextContainer"
    
    -- Remove the Map    
    RemoveMapInstance( textContainerName.."MapDisplay" )
end

function EA_Window_LoadingScreen.BeginScenarioEnterLoadScreen( loadingData )
        
    local windowName = "EA_Window_LoadingScreenScenarioEnter"
    local contentsWindowName = "EA_Window_LoadingScreenScenarioEnterContents"
    local textContainerName = contentsWindowName.."TextContainer"

    WindowSetScale( textContainerName, InterfaceCore.GetResolutionScale() )

    -- Update Heading
    local scenarioName = GetStringFormatFromTable( "HUDStrings", StringTables.HUD.TEXT_LOADING_SCREEN_SCENARIO_NAME, 
                                                    { GetScenarioName( loadingData.scenarioId ) } )   
    LabelSetText( textContainerName.."HeadingLine2", wstring.upper(scenarioName) )
    
    -- Update the Text
    LabelSetText( textContainerName.."ScenarioDescText", GetScenarioLobbyDesc( loadingData.scenarioId ) )
            
    -- Load the map if needed
    if( EA_Window_LoadingScreen.preloadedMapZoneId ~= loadingData.zoneId )
    then
        MapSetMapView( textContainerName.."MapDisplay", GameDefs.MapLevel.ZONE_MAP, loadingData.zoneId )
    end

    -- if it is a trial set up the right side of the window
    if( EA_Window_LoadingScreen.isTrial )
    then
        numTrialNoteItemWindows = EA_Window_LoadingScreen.AddTrialNotes(contentsWindowName, textContainerName, numTrialNoteItemWindows)
    else
        WindowSetShowing( contentsWindowName.."BlankBookImage", false)
    end
    
    -- Size the Window Image to fit the Screen Height while keeping the same aspect ratio
    local uiScale                   = InterfaceCore.GetScale()
    local screenWidth, screenHeight = GetScreenResolution()    
    local imageWidth, imageHeight   = WindowGetDimensions( windowName )
    
    imageWidth = (screenHeight/uiScale)*(imageWidth/imageHeight)
    imageHeight  = screenHeight/uiScale    
    
    WindowSetDimensions( windowName, imageWidth, imageHeight ) 
    
    local blankBookDelay    = EA_Window_LoadingScreen.FADE_IN_TIME
    local animDelay         = EA_Window_LoadingScreen.FADE_IN_TIME*1.5
    local contentsDelay     = EA_Window_LoadingScreen.FADE_IN_TIME*2.5

    -- Fade in the Blank Book Image
    WindowStartAlphaAnimation( windowName.."BlankBookImage", Window.AnimationType.SINGLE_NO_RESET, 0, 1, 
            EA_Window_LoadingScreen.FADE_IN_TIME, true, blankBookDelay, 0 )    
    
    -- Start the Page Flip Anim
    WindowSetShowing( windowName.."PageFlipAnim", true )
    AnimatedImageStartAnimation( windowName.."PageFlipAnim", 0, false, true, animDelay )

    -- Play the flip sound
    Sound.Play( Sound.TOME_TURN_PAGE )  

    -- Fade in the contents
    WindowStartAlphaAnimation( contentsWindowName, Window.AnimationType.SINGLE_NO_RESET, 0, 1, 
            EA_Window_LoadingScreen.FADE_IN_TIME, true, contentsDelay, 0 )
                                        
    -- Start the Loading Anim
    WindowSetShowing( textContainerName.."LoadingAnim", true )            
    AnimatedImageStartAnimation( textContainerName.."LoadingAnim", 0, true, false, 0 )

end

function EA_Window_LoadingScreen.EndScenarioEnterLoadScreen()

    local windowName = "EA_Window_LoadingScreenScenarioEnter"
    local contentsWindowName = "EA_Window_LoadingScreenScenarioEnterContents"
    local textContainerName = contentsWindowName.."TextContainer"
    
    
    local blankBookDelay    = EA_Window_LoadingScreen.FADE_IN_TIME
    
    -- Fade out the Blank Book Image
    WindowStartAlphaAnimation( windowName.."BlankBookImage", Window.AnimationType.SINGLE_NO_RESET, 1, 0, 
            EA_Window_LoadingScreen.FADE_IN_TIME, true, blankBookDelay, 0 )
    
    
    -- Fade out the contents screen
    WindowStartAlphaAnimation( contentsWindowName, Window.AnimationType.SINGLE_NO_RESET, 1, 0, 
              EA_Window_LoadingScreen.FADE_IN_TIME, true, 0, 0 )
              
    
    -- Stop the Loading Anim
    AnimatedImageStopAnimation( textContainerName.."LoadingAnim" )

end


function EA_Window_LoadingScreen.OnStartingScenarioUpdated( scenarioId, zoneId )

    local textContainerName = "EA_Window_LoadingScreenScenarioEnterContentsTextContainer"    
    
    -- Pre-Load the map for the Scenario Enter loading screen as soon as the starting scenario is updated.
    if( scenarioId ~= 0 )
    then
        MapSetMapView( textContainerName.."MapDisplay", GameDefs.MapLevel.ZONE_MAP, zoneId )
        EA_Window_LoadingScreen.preloadedMapZoneId = zoneId
    end
    
end

function EA_Window_LoadingScreen.UpdateStreamingScenarioEnterLoadScreen( isStreaming )

    local textContainerName = "EA_Window_LoadingScreenScenarioEnterContentsTextContainer"
        
    WindowSetShowing( textContainerName.."StreamingText", isStreaming )
    WindowSetShowing( textContainerName.."StreamingText2", isStreaming )
        
    if ( isStreaming )
    then
        WindowSetTintColor( textContainerName.."LoadingAnim", 255, 10, 50 )
    else
        WindowSetTintColor( textContainerName.."LoadingAnim", 255, 255, 255 )
    end
end