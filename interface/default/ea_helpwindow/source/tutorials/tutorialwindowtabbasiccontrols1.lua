TutorialWindowTabBasicControls1 = {}

-- Local Variables
local WINDOWNAME                    = "TutorialWindowTabBasicControls1"
local TEXTURE_FILENAME              = "EA_Tutorial_2.0BasicControl01_d5.dds"
local TITLE_STRING_NAME             = "BASIC_CONTROLS_1_TITLE_BAR_TEXT"
local LABEL_STRING_NAME_BASE        = "BASIC_CONTROLS_1_LABEL"
local NUM_LABLES                    = 6

-- Callback Functions
function TutorialWindowTabBasicControls1.Initialize()
    
    TutorialWindow.SetLabelsForWindow( WINDOWNAME.."Label" , NUM_LABLES, LABEL_STRING_NAME_BASE )  
end

function TutorialWindowTabBasicControls1.OnShown()

    TutorialWindow.SetTitleString( TITLE_STRING_NAME )
    TutorialWindow.SetBackgroundImage( TEXTURE_FILENAME )
end
