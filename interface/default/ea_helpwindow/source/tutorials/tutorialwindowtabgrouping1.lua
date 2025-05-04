
TutorialWindowTabGrouping1 = {}

-- Local Variables
local WINDOWNAME                    = "TutorialWindowTabGrouping1"
local TEXTURE_FILENAME              = "EA_Tutorial_2.5SocialandGrouping01_d5.dds"
local TITLE_STRING_NAME             = "GROUPING_1_TITLE_BAR_TEXT"
local LABEL_STRING_NAME_BASE        = "GROUPING_1_LABEL"
local NUM_LABLES                    = 5

-- Callback Functions
function TutorialWindowTabGrouping1.Initialize()
    
    TutorialWindow.SetLabelsForWindow( WINDOWNAME.."Label" , NUM_LABLES, LABEL_STRING_NAME_BASE )  
end

function TutorialWindowTabGrouping1.OnShown()

    TutorialWindow.SetTitleString( TITLE_STRING_NAME )
    TutorialWindow.SetBackgroundImage( TEXTURE_FILENAME )
end
