TutorialWindowTabCombat1 = {}

-- Local Variables
local WINDOWNAME                    = "TutorialWindowTabCombat1"
local TEXTURE_FILENAME              = "EA_Tutorial_2.2Combat_d5.dds"
local TITLE_STRING_NAME             = "COMBAT_1_TITLE_BAR_TEXT"
local LABEL_STRING_NAME_BASE        = "COMBAT_1_LABEL"
local NUM_LABLES                    = 7


-- Callback Functions
function TutorialWindowTabCombat1.Initialize()
    
    TutorialWindow.SetLabelsForWindow( WINDOWNAME.."Label" , NUM_LABLES, LABEL_STRING_NAME_BASE )  
end

function TutorialWindowTabCombat1.OnShown()

    TutorialWindow.SetTitleString( TITLE_STRING_NAME )
    TutorialWindow.SetBackgroundImage( TEXTURE_FILENAME )
end
