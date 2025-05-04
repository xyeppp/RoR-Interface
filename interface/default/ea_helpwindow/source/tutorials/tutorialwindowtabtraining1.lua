TutorialWindowTabTraining1 = {}

-- Local Variables
local WINDOWNAME                    = "TutorialWindowTabTraining1"
local TEXTURE_FILENAME              = "EA_Tutorial_2.4TrainingandAbilities_d5.dds"
local TITLE_STRING_NAME             = "TRAINING_1_TITLE_BAR_TEXT"
local LABEL_STRING_NAME_BASE        = "TRAINING_1_LABEL"
local NUM_LABLES                    = 5

-- Callback Functions
function TutorialWindowTabTraining1.Initialize()
    
    TutorialWindow.SetLabelsForWindow( WINDOWNAME.."Label" , NUM_LABLES, LABEL_STRING_NAME_BASE )  
end

function TutorialWindowTabTraining1.OnShown()

    TutorialWindow.SetTitleString( TITLE_STRING_NAME )
    TutorialWindow.SetBackgroundImage( TEXTURE_FILENAME )
end
