
TutorialWindowTabQuests1 = {}

-- Local Variables
local WINDOWNAME                    = "TutorialWindowTabQuests1"
local TEXTURE_FILENAME              = "EA_Tutorial_2.1Quest_d5.dds"
local TITLE_STRING_NAME             = "QUESTS_1_TITLE_BAR_TEXT"
local LABEL_STRING_NAME_BASE        = "QUESTS_1_LABEL"
local NUM_LABLES                    = 5


-- Callback Functions
function TutorialWindowTabQuests1.Initialize()
    
    TutorialWindow.SetLabelsForWindow( WINDOWNAME.."Label" , NUM_LABLES, LABEL_STRING_NAME_BASE )  
end

function TutorialWindowTabQuests1.OnShown()

    TutorialWindow.SetTitleString( TITLE_STRING_NAME )
    TutorialWindow.SetBackgroundImage( TEXTURE_FILENAME )
end
