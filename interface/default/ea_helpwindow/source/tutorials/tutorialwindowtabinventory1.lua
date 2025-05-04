TutorialWindowTabInventory1 = {}

-- Local Variables
local WINDOWNAME                    = "TutorialWindowTabInventory1"
local TEXTURE_FILENAME              = "EA_Tutorial_2.3InventoryandObject_d5.dds"
local TITLE_STRING_NAME             = "INVENTORY_1_TITLE_BAR_TEXT"
local LABEL_STRING_NAME_BASE        = "INVENTORY_1_LABEL"
local NUM_LABLES                    = 6

-- Callback Functions
function TutorialWindowTabInventory1.Initialize()
    
    TutorialWindow.SetLabelsForWindow( WINDOWNAME.."Label" , NUM_LABLES, LABEL_STRING_NAME_BASE )  
end

function TutorialWindowTabInventory1.OnShown()

    TutorialWindow.SetTitleString( TITLE_STRING_NAME )
    TutorialWindow.SetBackgroundImage( TEXTURE_FILENAME )
end
