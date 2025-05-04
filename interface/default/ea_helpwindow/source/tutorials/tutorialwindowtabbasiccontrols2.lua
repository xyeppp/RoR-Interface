TutorialWindowTabBasicControls2 = {}

-- Local Variables
local WINDOWNAME                    = "TutorialWindowTabBasicControls2"
local TEXTURE_FILENAME              = "EA_Tutorial_2.0BasicControl02_d5.dds"
local TITLE_STRING_NAME             = "BASIC_CONTROLS_2_TITLE_BAR_TEXT"
local LABEL_STRING_NAME_BASE        = "BASIC_CONTROLS_2_LABEL"
local NUM_LABLES                    = 5


-- Callback Functions
function TutorialWindowTabBasicControls2.Initialize()
    
    TutorialWindow.SetLabelsForWindow( WINDOWNAME.."Label" , NUM_LABLES, LABEL_STRING_NAME_BASE )  
end

function TutorialWindowTabBasicControls2.OnShown()

    TutorialWindow.SetTitleString( TITLE_STRING_NAME )
    TutorialWindow.SetBackgroundImage( TEXTURE_FILENAME )
end
