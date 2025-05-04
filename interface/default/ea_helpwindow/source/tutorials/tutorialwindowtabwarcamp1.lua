TutorialWindowTabWarCamp1 = {}

-- Local Variables
local WINDOWNAME                    = "TutorialWindowTabWarCamp1"
local TEXTURE_FILENAME              = "EA_Tutorial_2.8WarCamp_d5.dds"
local TITLE_STRING_NAME             = "WAR_CAMP_1_TITLE_BAR_TEXT"
local LABEL_STRING_NAME_BASE        = "WAR_CAMP_1_LABEL"
local NUM_LABLES                    = 6

-- Callback Functions
function TutorialWindowTabWarCamp1.Initialize()
    
    TutorialWindow.SetLabelsForWindow( WINDOWNAME.."Label" , NUM_LABLES, LABEL_STRING_NAME_BASE )  
end

function TutorialWindowTabWarCamp1.OnShown()

    TutorialWindow.SetTitleString( TITLE_STRING_NAME )
    TutorialWindow.SetBackgroundImage( TEXTURE_FILENAME )
end
