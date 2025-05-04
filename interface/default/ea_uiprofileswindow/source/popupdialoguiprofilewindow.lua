
----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_UiProfilePopupDialog = {}


EA_Window_UiProfilePopupDialog.titleText = L""
EA_Window_UiProfilePopupDialog.instructionsText = L""
EA_Window_UiProfilePopupDialog.okayButtonText = L""
EA_Window_UiProfilePopupDialog.excludeActiveProfile = false
EA_Window_UiProfilePopupDialog.okayButtonCallback = L""
EA_Window_UiProfilePopupDialog.cancelButtonCallback = L""


local WINDOWNAME = "EA_Window_UiProfilePopupDialog"

local MIN_TEXT_HEIGHT = 50
local WINDOW_FRAME_HEIGHT = 150

function EA_Window_UiProfilePopupDialog.Begin( titleText, instructionsText, okayButtonText, okayButtonCallback, cancelButtonText, cancelButtonCallback )

    if( DoesWindowExist( WINDOWNAME ) )
    then
        return
    end


    -- Set the Params    
    EA_Window_UiProfilePopupDialog.titleText             = titleText
    EA_Window_UiProfilePopupDialog.instructionsText      = instructionsText
    EA_Window_UiProfilePopupDialog.okayButtonText        = okayButtonText
    EA_Window_UiProfilePopupDialog.okayButtonCallback    = okayButtonCallback
    EA_Window_UiProfilePopupDialog.cancelButtonText      = cancelButtonText
    EA_Window_UiProfilePopupDialog.cancelButtonCallback  = cancelButtonCallback


    -- Create the Window & Show it.
    CreateWindow( WINDOWNAME, true )    
    
    EA_Window_ManageUiProfiles.UpdateProfileButtons()    
end

function EA_Window_UiProfilePopupDialog.End()

    if( not DoesWindowExist( WINDOWNAME ) )
    then
        return
    end    

    -- Destroy the Window
    DestroyWindow( WINDOWNAME )
    
    
    EA_Window_ManageUiProfiles.UpdateProfileButtons()    
end

function EA_Window_UiProfilePopupDialog.Exists()
    return  DoesWindowExist( WINDOWNAME )
end

----------------------------------------------------------------
-- EA_Window_UiProfilePopupDialog Functions
----------------------------------------------------------------

function EA_Window_UiProfilePopupDialog.Initialize()

    -- Text
    LabelSetText( WINDOWNAME.."TitleBarText", EA_Window_UiProfilePopupDialog.titleText )           
    LabelSetText( WINDOWNAME.."Instructions", EA_Window_UiProfilePopupDialog.instructionsText ) 
      
    -- Size the Window
    local _, textHeight = LabelGetTextDimensions( WINDOWNAME.."Instructions" )        
    textHeight = math.max( MIN_TEXT_HEIGHT, textHeight )    
    
    local width, height = WindowGetDimensions( WINDOWNAME )
    height = textHeight + WINDOW_FRAME_HEIGHT    
    WindowSetDimensions( WINDOWNAME, width, height )
           
    -- Buttons
    ButtonSetText( WINDOWNAME.."OkayButton", EA_Window_UiProfilePopupDialog.okayButtonText )
    
    if( EA_Window_UiProfilePopupDialog.cancelButtonText )   
    then
        ButtonSetText( WINDOWNAME.."CancelButton", EA_Window_UiProfilePopupDialog.cancelButtonText )   
    else
    
        -- Hide the 'Cancel' Buttons
        WindowSetShowing( WINDOWNAME.."CancelButton", false )
        WindowSetShowing( WINDOWNAME.."Close", false )
        
        -- Center the 'Okay' Button
        WindowClearAnchors( WINDOWNAME.."OkayButton" )
        WindowAddAnchor( WINDOWNAME.."OkayButton", "bottom", WINDOWNAME, "bottom", 0, -10 )
    end
    
end


function EA_Window_UiProfilePopupDialog.OnOkayButton()
    
    -- Trigger the Callback
    EA_Window_UiProfilePopupDialog.okayButtonCallback()
    
    EA_Window_UiProfilePopupDialog.End()
end

function EA_Window_UiProfilePopupDialog.OnCancelButton()
    
    -- Trigger the Callback
    EA_Window_UiProfilePopupDialog.cancelButtonCallback()

    EA_Window_UiProfilePopupDialog.End()
end


function EA_Window_UiProfilePopupDialog.Center()

    if( not DoesWindowExist( WINDOWNAME ) )
    then
        return
    end
    
    
    WindowClearAnchors( WINDOWNAME )
    WindowAddAnchor( WINDOWNAME, "center", "Root", "center", 0 , 0 )
end