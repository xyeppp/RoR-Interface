----------------------------------------------------------------
-- Scenario Exit Loading Screen
----------------------------------------------------------------

---------------------------------------------------------------------------------


function EA_Window_LoadingScreen.InitNoDataLoadScreen()

end

function EA_Window_LoadingScreen.ShutdownNoDataLoadScreen()

end

function EA_Window_LoadingScreen.BeginNoDataLoadScreen( loadingData )


    local windowName = "EA_Window_LoadingScreenNoData"
    
    local zoneName = L""    
    if( loadingData.zoneId  > 0 ) then	
        zoneName = GetZoneName( loadingData.zoneId )
        if ( zoneName == L"" ) then
            zoneName = L"Zone "..loadingData.zoneId
        end
    end

    -- Set the Text
    local text = GetStringFormat( StringTables.Default.TEXT_LOADING_ZONE, { zoneName } )
    LabelSetText( windowName.."Text", wstring.upper(text) )	

    -- Fade in the Text
    WindowStartAlphaAnimation( windowName.."Text", Window.AnimationType.SINGLE_NO_RESET, 0, 1, 
            EA_Window_LoadingScreen.FADE_IN_TIME, true, delay, 0 )
                                
    -- Start Animating the Shield Glow
    WindowStartAlphaAnimation( windowName.."ShieldGlow", Window.AnimationType.LOOP, 0.1, 1.0, 0.75, false, delay, 0) 
    
end

function EA_Window_LoadingScreen.EndNoDataLoadScreen()

    local windowName = "EA_Window_LoadingScreenNoData"

    -- Fade out the Text
    WindowStartAlphaAnimation( windowName.."Text", Window.AnimationType.SINGLE_NO_RESET, 1, 0, 
              EA_Window_LoadingScreen.FADE_IN_TIME, true, 0, 0 )
    
    -- Stop Animating the Shield Glow
    WindowStopAlphaAnimation( windowName.."ShieldGlow" ) 
end

function EA_Window_LoadingScreen.UpdateNoDataLoadScreen( timePassed )

end

