
TutorialWindowTabGrouping2 = {}

-- Local Variables
local WINDOWNAME                    = "TutorialWindowTabGrouping2"
local TEXTURE_FILENAME              = "EA_Tutorial_2.5SocialandGrouping02_d5.dds"
local TITLE_STRING_NAME             = "GROUPING_2_TITLE_BAR_TEXT"
local LABEL_STRING_NAME_BASE        = "GROUPING_2_LABEL"
local NUM_LABLES                    = 6

-- Callback Functions
function TutorialWindowTabGrouping2.Initialize()
    
    TutorialWindow.SetLabelsForWindow( WINDOWNAME.."Label" , NUM_LABLES, LABEL_STRING_NAME_BASE )  
end

function TutorialWindowTabGrouping2.OnShown()

    TutorialWindow.SetTitleString( TITLE_STRING_NAME )
    TutorialWindow.SetBackgroundImage( TEXTURE_FILENAME )
end
