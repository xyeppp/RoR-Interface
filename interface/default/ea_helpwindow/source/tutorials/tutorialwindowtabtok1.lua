TutorialWindowTabTOK1 = {}

-- Local Variables
local WINDOWNAME                    = "TutorialWindowTabTOK1"
local TEXTURE_FILENAME              = "EA_Tutorial_2.6TomeofKnowledge_d5.dds"
local TITLE_STRING_NAME             = "TOK_1_TITLE_BAR_TEXT"
local LABEL_STRING_NAME_BASE        = "TOK_1_LABEL"
local NUM_LABLES                    = 7

-- Callback Functions
function TutorialWindowTabTOK1.Initialize()
    
    TutorialWindow.SetLabelsForWindow( WINDOWNAME.."Label" , NUM_LABLES, LABEL_STRING_NAME_BASE )  
end

function TutorialWindowTabTOK1.OnShown()

    TutorialWindow.SetTitleString( TITLE_STRING_NAME )
    TutorialWindow.SetBackgroundImage( TEXTURE_FILENAME )
end
