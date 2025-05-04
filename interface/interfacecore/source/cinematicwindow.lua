----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_CinematicDisplay = {}

----------------------------------------------------------------
-- Local Functions
----------------------------------------------------------------

local function OpenCinematicPageInBrowser()
    OpenURL(GameData.URLs.URL_CINEMATIC)
end

----------------------------------------------------------------
-- EA_Window_CinematicDisplay Functions
----------------------------------------------------------------

function EA_Window_CinematicDisplay.Show()
    if ( CanPlayCinematic() )
    then
        if ( DoesWindowExist( "EA_Window_CinematicDisplay" ) )
        then
            WindowSetShowing("EA_Window_CinematicDisplay", true)
        else
            CreateWindow("EA_Window_CinematicDisplay", true)
        end
        PregamePlayCinematic()
    else
        DialogManager.MakeTwoButtonDialog( GetPregameString(StringTables.Pregame.DIALOG_CONFIRM_OPEN_CINEMATIC),
                                           GetString(StringTables.Default.LABEL_YES), OpenCinematicPageInBrowser, 
                                           GetString(StringTables.Default.LABEL_NO), nil,
                                           nil, nil, false, nil, nil )
    end
end

function EA_Window_CinematicDisplay.Hide()
    WindowSetShowing("EA_Window_CinematicDisplay", false)
    PregameStopCinematic()
end

function EA_Window_CinematicDisplay.ToggleShowing()
    if ( DoesWindowExist( "EA_Window_CinematicDisplay" ) and WindowGetShowing( "EA_Window_CinematicDisplay" ) )
    then
        EA_Window_CinematicDisplay.Hide()
    else
        EA_Window_CinematicDisplay.Show()
    end
end