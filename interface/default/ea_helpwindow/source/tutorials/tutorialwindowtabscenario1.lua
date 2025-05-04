TutorialWindowTabScenario1 = {}

-- Local Variables
local WINDOWNAME                    = "TutorialWindowTabScenario1"
local TEXTURE_FILENAME              = "EA_Tutorial_2.7Scenarios_d5.dds"
local TITLE_STRING_NAME             = "SCENARIO_1_TITLE_BAR_TEXT"
local LABEL_STRING_NAME_BASE        = "SCENARIO_1_LABEL"
local NUM_LABLES                    = 7

-- Callback Functions
function TutorialWindowTabScenario1.Initialize()
    
    TutorialWindow.SetLabelsForWindow( WINDOWNAME.."Label" , NUM_LABLES, LABEL_STRING_NAME_BASE )  
end

function TutorialWindowTabScenario1.OnShown()

    TutorialWindow.SetTitleString( TITLE_STRING_NAME )
    TutorialWindow.SetBackgroundImage( TEXTURE_FILENAME )
end
