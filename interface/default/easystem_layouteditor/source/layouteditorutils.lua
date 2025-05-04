
------------------------------------------------------------------------------------------------------------------------------------------------
--# Title: Layout Editor Utils
------------------------------------------------------------------------------------------------------------------------------------------------

LayoutEditorUtils = {}

-- Local Functions
function LayoutEditorUtils.CopyAnchors( sourceWindow, destinationWindow, xOffset, yOffset )

    WindowClearAnchors( destinationWindow )

    local numAnchors = WindowGetAnchorCount( sourceWindow )
    for index = 1, numAnchors
    do
        local point, relativePoint, relativeTo, xoffs, yoffs = WindowGetAnchor( sourceWindow, index )           
        WindowAddAnchor( destinationWindow , point, relativeTo, relativePoint, xoffs+xOffset, yoffs+yOffset )
    end
end

function LayoutEditorUtils.CopyScreenPosition( sourceFrame, destFrame, xOffset, yOffset )

    local uiScale = InterfaceCore.GetScale()    
    local screenX, screenY = WindowGetScreenPosition( sourceFrame:GetName() )        
    
    local xPos = math.floor( (screenX + xOffset)/uiScale + 0.5 )
    local yPos = math.floor( (screenY + yOffset)/uiScale + 0.5 )
        
    local anchor = { Point="topleft", RelativeTo="Root", RelativePoint="topleft", XOffset=xPos, YOffset=yPos }
    destFrame:SetAnchor( anchor )

    --d( ""..sourceFrame:GetName().." -> "..destFrame:GetName()..": x="..xPos.." y="..yPos )
end

function LayoutEditorUtils.CopySize( sourceFrame, destFrame, xOffset, yOffset, offsetInDestCoords )
        
    local width, height = WindowGetDimensions( sourceFrame:GetName() )
           
    local sourceScale = WindowGetScale( sourceFrame:GetName() )
    local destScale   = WindowGetScale( destFrame:GetName() )
    local scaleConvert = destScale / sourceScale
    
    if( offsetInDestCoords ) 
    then
        width  = width*scaleConvert + xOffset
        height = height*scaleConvert + yOffset
    else
        width  = (width + xOffset) * scaleConvert
        height = (height + yOffset)* scaleConvert
    end
    
    destFrame:SetDimensions(  width, height ) 
end
