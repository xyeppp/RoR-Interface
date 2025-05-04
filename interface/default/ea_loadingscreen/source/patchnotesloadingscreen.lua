----------------------------------------------------------------
-- Patch Notes Loading Screen for initial load
----------------------------------------------------------------


function EA_Window_LoadingScreen.InitPatchNotesLoadScreen()
    
    local windowName = "EA_Window_LoadingScreenPatchNotes"
    local contentsWindowName = windowName.."Contents"
    local textContainerName = contentsWindowName.."Child"
    
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
    LabelSetText( contentsWindowName.."StreamingText", streamingText )
    LabelSetText( contentsWindowName.."StreamingText2", streamingText2 )
end

local numPatchNoteItemWindows = 0

function EA_Window_LoadingScreen.BeginPatchNotesLoadScreen( loadingData, patchNotesData )
    local windowName = "EA_Window_LoadingScreenPatchNotes"
    local contentsWindowName = windowName.."Contents"
    local textContainerName = contentsWindowName.."Child"
        
    -- Update the Heading    
    local zoneName = GetStringFormatFromTable( "HUDStrings", StringTables.HUD.TEXT_LOADING_SCREEN_ZONE_NAME, { GetZoneName( loadingData.zoneId) } )
    LabelSetText( textContainerName.."HeadingLine2", wstring.upper(zoneName) )
    
    -- Update the Text
    LabelSetText( textContainerName.."ZoneDescText", loadingData.zoneText )
    LabelSetText( textContainerName.."TipText", loadingData.tipText )
    
    PageWindowAddPageBreak( contentsWindowName, textContainerName.."NotesPageBreak" )
    LabelSetText( textContainerName.."NotesHeading", GetStringFormatFromTable( "HUDStrings", StringTables.HUD.TEXT_LOADING_SCREEN_PATCH_NOTES_HEADER, { GameData.Player.name } ) )
    LabelSetText( textContainerName.."NotesHeading2", GetStringFromTable( "HUDStrings", StringTables.HUD.TEXT_LOADING_SCREEN_PATCH_NOTES_HEADER2 ) )
    
    local index = 1
    local itemWindowName = textContainerName.."NoteItem"
    local anchorWindow = textContainerName.."NotesHeading2"
    local function CreateNoteWindows( notes )
        for _, patchNoteText in ipairs( notes )
        do
            local patchNoteWindow = itemWindowName..index
            if index > numPatchNoteItemWindows
            then
                numPatchNoteItemWindows = numPatchNoteItemWindows + 1
                CreateWindowFromTemplate( patchNoteWindow, "EA_Template_LoadScreen_PatchNoteItem", textContainerName )
            end
            
            LabelSetText( patchNoteWindow.."Text", patchNoteText )
            WindowSetShowing( patchNoteWindow, true )
            WindowResizeOnChildren( patchNoteWindow, false, 0 )
            WindowClearAnchors( patchNoteWindow )
            WindowAddAnchor( patchNoteWindow, "bottomleft", anchorWindow, "topleft", 0, 15 )
            anchorWindow = patchNoteWindow
            
            index = index + 1
        end
    end
    
    CreateNoteWindows( patchNotesData.mainItems )
    CreateNoteWindows( patchNotesData.secondaryItems )
    
    for i = index, numPatchNoteItemWindows
    do
        local patchNoteWindow = itemWindowName..i
        WindowSetShowing( patchNoteWindow, false )
    end

    -- Size the Window Image to fit the Screen Height while keeping the same aspect ratio
    local uiScale                   = InterfaceCore.GetScale()
    local screenWidth, screenHeight = GetScreenResolution()
    local imageWidth, imageHeight   = WindowGetDimensions( windowName )

    local desiredHeight = screenHeight / uiScale
    local scaleFactor = (desiredHeight / imageHeight) * uiScale

    WindowSetScale( windowName, scaleFactor )
    PageWindowUpdatePages( contentsWindowName )


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
    WindowSetShowing( contentsWindowName.."LoadingAnim", true )
    AnimatedImageStartAnimation( contentsWindowName.."LoadingAnim", 0, true, false, 0 )

end

function EA_Window_LoadingScreen.EndPatchNotesLoadScreen()
    local windowName = "EA_Window_LoadingScreenPatchNotes"
    local contentsWindowName = windowName.."Contents"
    local textContainerName = contentsWindowName.."Child"
    
    local blankBookDelay    = EA_Window_LoadingScreen.FADE_IN_TIME
    
    -- Fade out the Blank Book Image
    WindowStartAlphaAnimation( windowName.."BlankBookImage", Window.AnimationType.SINGLE_NO_RESET, 1, 0, 
            EA_Window_LoadingScreen.FADE_IN_TIME, true, blankBookDelay, 0 )
    
    -- Fade out the contents screen
    WindowStartAlphaAnimation( contentsWindowName, Window.AnimationType.SINGLE_NO_RESET, 1, 0, 
              EA_Window_LoadingScreen.FADE_IN_TIME, true, 0, 0 )
              
    -- Stop the Loading Anim
    AnimatedImageStopAnimation( contentsWindowName.."LoadingAnim" )
end

function EA_Window_LoadingScreen.UpdateStreamingPatchNotesLoadScreen( isStreaming )

    local contentsWindowName = "EA_Window_LoadingScreenPatchNotesContents"
        
    WindowSetShowing( contentsWindowName.."StreamingText", isStreaming )
    WindowSetShowing( contentsWindowName.."StreamingText2", isStreaming )
        
    if ( isStreaming )
    then
        WindowSetTintColor( contentsWindowName.."LoadingAnim", 255, 10, 50 )
    else
        WindowSetTintColor( contentsWindowName.."LoadingAnim", 255, 255, 255 )
    end
end
