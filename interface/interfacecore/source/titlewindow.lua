TitleWindow = 
{
}

local loadTimer = 0
local FADE_IN_TIME = 1.0
local LOAD_ANIM_TIME = 2.5


function TitleWindow.Initialize()

    -- Set the Background Texture Dimensions according to the resolution
    if( SystemData.screenResolution.x / SystemData.screenResolution.y > 1.5 ) then
        -- widescreen ratio: 1440x900
        DynamicImageSetTextureDimensions( "TitleWindowBackground", 1280, 720 )
    else
        -- normal ratio: 1024x768
        DynamicImageSetTextureDimensions( "TitleWindowBackground", 1024, 768 )
    end 
    
    WindowRegisterEventHandler( "TitleWindow", SystemData.Events.TITLE_SCREEN_INIT_LOADING_UI, "TitleWindow.BeginLoadSequence" )
    
    
    LabelSetText( "TitleWindowLoadingScreenLegalText",   GetPregameString( StringTables.Pregame.TEXT_WAR_LEGAL ) )
    WindowSetShowing( "TitleWindowLoadingScreen", false )
    
    LabelSetText( "TitleWindowLoadingText", wstring.upper( GetPregameString( StringTables.Pregame.LABEL_LOADING ) ) )
    WindowSetShowing( "TitleWindowLoadingText", false )

    -- If the GOA Texture exists, hide the ESRB Logo.
    if( DynamicImageHasTexture( "TitleWindowLoadingScreenGOALogo" ) ) 
    then
        WindowSetShowing( "TitleWindowLoadingScreenESRBLogo", false )
    end
    
    -- Now hide the GOA logo, no matter what version we are. (The only reason it is not being removed entirely is so that we can use its existence
    -- to determine whether the ESRB logo should be shown.)
    WindowSetShowing( "TitleWindowLoadingScreenGOALogo", false )

    -- Only show game rating text and icon for Korea territory client
    if ( SystemData.Territory.KOREA )
    then
        LabelSetText( "TitleWindowLoadingScreenGameRatingText", GetPregameString( StringTables.Pregame.TEXT_TITLE_WINDOW_KOREA_ONLY_GAME_RATING ) )
        WindowSetShowing( "TitleWindowLoadingScreenGameRatingText", true )
        WindowSetShowing( "TitleWindowLoadingScreenGameRatingIcon", true )
    else
        WindowSetShowing( "TitleWindowLoadingScreenGameRatingText", false )
        WindowSetShowing( "TitleWindowLoadingScreenGameRatingIcon", false )
    end
end

function TitleWindow.Update( timePassed )

    if( loadTimer ~= 0 )
    then
        loadTimer = loadTimer - timePassed
        if( loadTimer <= 0 )
        then            
            loadTimer = 0
            
            BroadcastEvent( SystemData.Events.TITLE_SCREEN_INIT_LOADING_UI_COMPLETE )
        end
    end

end

function TitleWindow.BeginLoadSequence()
    
    -- Fade in the Loading Frame    
    WindowSetShowing( "TitleWindowLoadingScreen", true )
    WindowStartAlphaAnimation( "TitleWindowLoadingScreen", Window.AnimationType.SINGLE_NO_RESET, 0, 1, 
            FADE_IN_TIME, true, 0, 0 )
            
    loadTimer = LOAD_ANIM_TIME
    
    -- Fade in the LOADING text after a delay
    WindowSetShowing( "TitleWindowLoadingText", true )
    WindowStartAlphaAnimation( "TitleWindowLoadingText", Window.AnimationType.SINGLE_NO_RESET, 0, 1, 
            FADE_IN_TIME, true, FADE_IN_TIME, 0 )
end
