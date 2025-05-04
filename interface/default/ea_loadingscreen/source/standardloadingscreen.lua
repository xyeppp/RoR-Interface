----------------------------------------------------------------
-- Standard Loading Screen for Zones
----------------------------------------------------------------
local numTrialNoteItemWindows = 0

-- Texture Info to change the divider based on the zone's racial affiliation.
EA_Window_LoadingScreen.racialDividers =
{
    [0]                         = { sliceId="" },                     
    [GameData.Races.DWARF]      = { sliceId="dwarf-filigree" },       
    [GameData.Races.ORC]        = { sliceId="greenskin-filigree" },   
    [GameData.Races.GOBLIN]     = { sliceId="greenskin-filigree" },  
    [GameData.Races.HIGH_ELF]   = { sliceId="highelf-filigree" },   
    [GameData.Races.DARK_ELF]   = { sliceId="darkelf-filigree" },     
    [GameData.Races.EMPIRE]     = { sliceId="empire-filigree" },     
    [GameData.Races.CHAOS]      = { sliceId="chaos-filigree" },       

}

function EA_Window_LoadingScreen.InitStandardLoadScreen()
    
    local windowName = "EA_Window_LoadingScreenStandard"
    local contentsWindowName = "EA_Window_LoadingScreenStandardContents"
    local textContainerName = contentsWindowName.."TextContainer"
    
    -- LOADING Heading
    local loadingHeading = GetStringFromTable( "HUDStrings", StringTables.HUD.TEXT_LOADING_SCREEN_LOADING )    
    LabelSetText( textContainerName.."HeadingLine1", loadingHeading )
    
    -- TIPS: Heading
    local tipsHeading = GetStringFromTable( "HUDStrings", StringTables.HUD.TEXT_LOADING_SCREEN_TIP )    
    LabelSetText( textContainerName.."TipLabel", tipsHeading )

    AnimatedImageSetPlaySpeed( windowName.."PageFlipAnim", EA_Window_LoadingScreen.FLIP_FPS )
    
    -- Streaming 
    local streamingText = GetStringFromTable( "HUDStrings", StringTables.HUD.TEXT_LOADING_SCREEN_STREAMING )
    local streamingText2 = GetStringFromTable( "HUDStrings", StringTables.HUD.TEXT_LOADING_SCREEN_STREAMING2 )
    LabelSetText( textContainerName.."StreamingText", streamingText )
    LabelSetText( textContainerName.."StreamingText2", streamingText2 )
end


function EA_Window_LoadingScreen.BeginStandardLoadScreen( loadingData )

    local windowName = "EA_Window_LoadingScreenStandard"
    local contentsWindowName = "EA_Window_LoadingScreenStandardContents"
    local textContainerName = contentsWindowName.."TextContainer"    
    
    WindowSetScale( textContainerName, InterfaceCore.GetResolutionScale() )
        
    -- Update the Heading    
    local zoneName = GetStringFormatFromTable( "HUDStrings", StringTables.HUD.TEXT_LOADING_SCREEN_ZONE_NAME, { GetZoneName( loadingData.zoneId) } )   
    LabelSetText( textContainerName.."HeadingLine2", wstring.upper(zoneName) )
    
    -- Update the Text
    LabelSetText( textContainerName.."ZoneDescText", loadingData.zoneText )
    LabelSetText( textContainerName.."TipText", loadingData.tipText )    
    
    -- if it is a trial set up the right side of the window
    if( EA_Window_LoadingScreen.isTrial )
    then
        numTrialNoteItemWindows = EA_Window_LoadingScreen.AddTrialNotes(contentsWindowName, textContainerName, numTrialNoteItemWindows)
    else
        WindowSetShowing( contentsWindowName.."BlankBookImage", false)
    end
    
    -- Update the Divider Image
    WindowSetShowing( textContainerName.."DividerImage", loadingData.raceId ~= 0 )
    if( loadingData.raceId ~= 0 )
    then
        local sliceId = EA_Window_LoadingScreen.racialDividers[loadingData.raceId].sliceId 
        DynamicImageSetTextureSlice( textContainerName.."DividerImage", sliceId )
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
            
    
    -- Start the Book Anim
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

function EA_Window_LoadingScreen.EndStandardLoadScreen()
    
    local windowName = "EA_Window_LoadingScreenStandard"
    local contentsWindowName = "EA_Window_LoadingScreenStandardContents"
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


function EA_Window_LoadingScreen.UpdateStreamingStandardLoadScreen( isStreaming )

    local textContainerName = "EA_Window_LoadingScreenStandardContentsTextContainer"
        
    WindowSetShowing( textContainerName.."StreamingText", isStreaming )
    WindowSetShowing( textContainerName.."StreamingText2", isStreaming )
        
    if ( isStreaming )
    then
        WindowSetTintColor( textContainerName.."LoadingAnim", 255, 10, 50 )
    else
        WindowSetTintColor( textContainerName.."LoadingAnim", 255, 255, 255 )
    end
end