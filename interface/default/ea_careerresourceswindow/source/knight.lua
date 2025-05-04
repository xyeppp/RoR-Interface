KnightResource = CareerResourceFrame:Subclass ("EA_KnightResource")

local TEXT   = 1
local SKULL  = 2
local EYES = 3
local FLAMES = 4

CareerResource:RegisterResource (GameData.CareerLine.KNIGHT, KnightResource)

function KnightResource:Create (windowName)
    local frame = self:CreateFromTemplate (windowName)
    
    if (frame)
    then
        frame.m_Data = CareerResourceData:Create (GameData.CareerLine.KNIGHT)

        frame.m_Windows =
        {
            ["Text"]      = Label:CreateFrameForExistingWindow(windowName.."Text"),
            ["Skull"]   = DynamicImage:CreateFrameForExistingWindow (windowName.."Image"),
            ["Eyes"]      = DynamicImage:CreateFrameForExistingWindow (windowName.."Eyes"),
            ["Flames"]    = Frame:CreateFrameForExistingWindow (windowName.."Flames"),
        }
        
        frame.GetLevel =    function (resourceAmount)
                                if     (resourceAmount == 0) then   return 0
                                elseif (resourceAmount <= 2) then  return 1 
                                elseif (resourceAmount <= 4) then  return 2
                                elseif (resourceAmount <= 6) then  return 3
                                elseif (resourceAmount <= 8) then  return 4
                                elseif (resourceAmount <= 10) then return 5 end
                            end

        frame.GetColor =    function (resourceAmount)
                                if     (resourceAmount == 0) then  return NewColor( 255, 255, 255, 255 )
                                elseif (resourceAmount <= 2) then  return NewColor( 251, 252, 149, 255 )
                                elseif (resourceAmount <= 4) then  return NewColor( 252, 187, 20,  255 )
                                elseif (resourceAmount <= 6) then  return NewColor( 252, 74,  61,  255 )
                                elseif (resourceAmount <= 8) then  return NewColor( 252, 30,  164, 255 )
                                elseif (resourceAmount <= 10) then return NewColor( 177, 51,  255, 255 ) end
                            end
--[[
        frame.GetColor =    function (resourceAmount)
                                if     (resourceAmount == 0) then  return NewColor( 255, 255, 255, 255 )
                                elseif (resourceAmount <= 2) then  return NewColor( 0, 255, 0, 255 )
                                elseif (resourceAmount <= 4) then  return NewColor( 0, 0, 255,  255 )
                                elseif (resourceAmount <= 6) then  return NewColor( 255, 0,  0,  255 )
                                elseif (resourceAmount <= 8) then  return NewColor( 255, 255,  0, 255 )
                                elseif (resourceAmount <= 10) then return NewColor( 177, 51,  255, 255 ) end
                            end
					--]]  		
        AnimatedImageStartAnimation( windowName.."Flames", 0, true, true, 0 )
        frame:UpdateResourceDisplay (0, 10)
        frame:Show (true)
		NissenUMBER = 2
    end
    return frame
end

function KnightResource:Initialize()
    self:Update (0, 0)
end

function KnightResource:UpdateResourceDisplay (previousResourceValue, currentResourceValue)
    -- DEBUG(L"KnightResource:UpdateResourceDisplay ("..previousResourceValue..L", "..currentResourceValue..L")")
    self.m_Windows["Eyes"]:Show( self.GetLevel(currentResourceValue) >= 1 )
    self.m_Windows["Eyes"]:SetTint(self.GetColor(currentResourceValue))	
	
    self.m_Windows["Flames"]:Show( self.GetLevel(currentResourceValue) > 0)
    self.m_Windows["Flames"]:SetTint(self.GetColor(currentResourceValue))
    self.m_Windows["Text"]:Show( self.GetLevel(currentResourceValue) > 0 )
	
    if( currentResourceValue > 0 )
    then
        self.m_Windows["Text"]:SetText( L""..currentResourceValue )
    end
    
    self.m_Data:SetPrevious (previousResourceValue)
end

function KnightResource:Update (timePassed)
--[[
   self.m_Windows["Eyes"]:SetTint(self.GetColor(NissenUMBER))
   self.m_Windows["Flames"]:SetTint(self.GetColor(NissenUMBER)) 
   self.m_Windows["Flames"]:Show( self.GetLevel(NissenUMBER) > 0)  
   self.m_Windows["Text"]:SetText( L""..NissenUMBER )   
    -- Currently not very useful, might be used for animations...
--]]	
end
