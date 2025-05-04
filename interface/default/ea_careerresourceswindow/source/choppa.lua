ChoppaResource = CareerResourceFrame:Subclass( "EA_ChoppaResource" )

CareerResource:RegisterResource( GameData.CareerLine.CHOPPA, ChoppaResource )

local g_resource_max = 100
local g_first_border = 25
local g_second_border = 75
local g_resource_window = "EA_CareerResourceWindow"
local g_updateAnchors = false

function ChoppaResource:Create( windowName )
    local frame = self:CreateFromTemplate( windowName )
    if (frame)
    then
        frame.m_Data = CareerResourceData:Create( GameData.CareerLine.CHOPPA )

        frame.m_Windows =
        {
            ["Ring"]    = DynamicImage:CreateFrameForExistingWindow( windowName.."Ring" ),
            ["Default"] = DynamicImage:CreateFrameForExistingWindow( windowName.."Default" ),
            ["Angry"]   = Frame:CreateFrameForExistingWindow( windowName.."Angry" ),
            ["RedGlow"] = Frame:CreateFrameForExistingWindow( windowName.."RedGlow" ),
            ["GreenGlow"] = DynamicImage:CreateFrameForExistingWindow( windowName.."GreenGlow" ),
            ["YellowGlow"] = DynamicImage:CreateFrameForExistingWindow( windowName.."YellowGlow" ),
        }
        
		WindowSetShowing( windowName.."Needle", true )
        
        AnimatedImageStartAnimation( windowName.."RedGlow", 0, true, false, 0 )
        
        frame.m_Windows["Ring"]:Show( true )
        
        frame:UpdateResourceDisplay( 0, 0 )
        frame:Show( true )
        g_updateAnchors = true
    end
 
    return frame
end

function ChoppaResource:Initialize()
    self:Update( 0, 0 )
end

local function IsInMiddleSegment( currentValue )
    if( currentValue >= g_first_border and currentValue < g_second_border )
    then
        return true
    end
    return false
end

local function IsInFirstSegment( currentValue )
    if( currentValue < g_first_border )
    then
        return true
    end
    return false
end

local function IsInLastSegment( currentValue )
    if( currentValue >= g_second_border )
    then
        return true
    end
    return false    
end

function ChoppaResource:UpdateResourceDisplay( previousResourceValue, currentResourceValue )

    local rotationModifier = 180 / g_resource_max
        
    local rotate = ( currentResourceValue * rotationModifier ) - 90
    if ( rotate < 0 )
    then
        rotate = 360 + rotate
    end
 
    DynamicImageSetRotation( g_resource_window.."Needle", rotate )

    -- Show the background glow images
    self.m_Windows["GreenGlow"]:Show( IsInFirstSegment( currentResourceValue ) )
    self.m_Windows["YellowGlow"]:Show( IsInMiddleSegment( currentResourceValue ) )
    self.m_Windows["RedGlow"]:Show( IsInLastSegment( currentResourceValue ) )
    
    -- Show the default or animated angry head
    self.m_Windows["Default"]:Show( not IsInLastSegment( currentResourceValue ) )
    self.m_Windows["Angry"]:Show( IsInLastSegment( currentResourceValue ) )
   
    self.m_Data:SetPrevious( previousResourceValue )
end

function ChoppaResource:Update( timePassed )
    -- Currently not very useful, might be used for animations...
    if( g_updateAnchors == true )
    then
        -- Make sure the anchoring is correct after the initial rotation, since rotating an image seem to break anchoring at some times
        WindowClearAnchors( g_resource_window.."Needle" )
        WindowAddAnchor( g_resource_window.."Needle" , "top", "EA_CareerResourceWindow", "top", 0, 4)
    end
end
