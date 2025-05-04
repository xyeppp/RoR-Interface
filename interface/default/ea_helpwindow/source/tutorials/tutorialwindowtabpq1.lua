TutorialWindowTabPQ1 = {}

-- Local Variables
local WINDOWNAME                    = "TutorialWindowTabPQ1"
local TEXTURE_FILENAME              = "EA_Tutorial_2.9PublicQuest_d5.dds"
local TITLE_STRING_NAME             = "PQ_1_TITLE_BAR_TEXT"
local LABEL_STRING_NAME_BASE        = "PQ_1_LABEL"
local NUM_LABLES                    = 7

-- Callback Functions
function TutorialWindowTabPQ1.Initialize()
    
    TutorialWindow.SetLabelsForWindow( WINDOWNAME.."Label" , NUM_LABLES, LABEL_STRING_NAME_BASE )  
end

function TutorialWindowTabPQ1.OnShown()

    TutorialWindow.SetTitleString( TITLE_STRING_NAME )
    TutorialWindow.SetBackgroundImage( TEXTURE_FILENAME )
end
