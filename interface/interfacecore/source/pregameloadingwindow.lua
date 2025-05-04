----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

PregameLoadingWindow = {}


----------------------------------------------------------------
-- PregameLoadingWindow Functions
----------------------------------------------------------------

-- OnInitialize Handler
function PregameLoadingWindow.Initialize()
    
    LabelSetText( "PregameLoadingWindowText", GetPregameString( StringTables.Pregame.LABEL_LOADING_INTERFACE ) )
    
    -- Size the Window Image to fit the Screen Height while keeping the same aspect ratio
    local windowName = "PregameLoadingWindowImage"
    
    local uiScale                   = InterfaceCore.GetScale()
    local screenWidth, screenHeight = GetScreenResolution()    
    local imageWidth, imageHeight   = WindowGetDimensions( windowName )
    
    imageWidth = (screenHeight/uiScale)*(imageWidth/imageHeight)
    imageHeight  = screenHeight/uiScale    
    
    WindowSetDimensions( windowName, imageWidth, imageHeight ) 
    
end


function PregameLoadingWindow.OnLButtonDown()
	-- Trap mouse clicks
end

