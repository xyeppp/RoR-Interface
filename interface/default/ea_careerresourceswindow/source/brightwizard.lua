BrightWizardResource = CareerResourceFrame:Subclass ("EA_BrightWizardResource")

CareerResource:RegisterResource (GameData.CareerLine.BRIGHT_WIZARD, BrightWizardResource)

function BrightWizardResource:Create (windowName)
    local frame = self:CreateFromTemplate (windowName)
    
    if (frame)
    then
        frame.m_Data = CareerResourceData:Create (GameData.CareerLine.BRIGHT_WIZARD)

        frame.m_Windows =
        {
            ["Text"]      = Label:CreateFrameForExistingWindow(windowName.."Text"),
            ["Skull"]     = DynamicImage:CreateFrameForExistingWindow (windowName.."Image"),
            ["Eyes"]      = DynamicImage:CreateFrameForExistingWindow (windowName.."Eyes"),
            ["Flames"]    = Frame:CreateFrameForExistingWindow (windowName.."Flames"),
        }
        
        frame.GetLevel =    function (resourceAmount)
                                if     (resourceAmount == 0) then   return 0
                                elseif (resourceAmount <= 10) then  return 1 
                                elseif (resourceAmount <= 30) then  return 2
                                elseif (resourceAmount <= 70) then  return 3
                                elseif (resourceAmount <= 90) then  return 4
                                elseif (resourceAmount <= 100) then return 5 end
                            end

        frame.GetColor =    function (resourceAmount)
                                if     (resourceAmount == 0) then   return NewColor( 255, 255, 255, 255 )
                                elseif (resourceAmount <= 10) then  return NewColor( 251, 252, 149, 255 )
                                elseif (resourceAmount <= 30) then  return NewColor( 252, 187, 20,  255 )
                                elseif (resourceAmount <= 70) then  return NewColor( 252, 74,  61,  255 )
                                elseif (resourceAmount <= 90) then  return NewColor( 252, 30,  164, 255 )
                                elseif (resourceAmount <= 100) then return NewColor( 177, 51,  255, 255 ) end
                            end
        
        AnimatedImageStartAnimation( windowName.."Flames", 0, true, true, 0 )
        frame:UpdateResourceDisplay (0, 0)
        frame:Show (true)
    end
    
    return frame
end

function BrightWizardResource:Initialize()
    self:Update (0, 0)
end

function BrightWizardResource:UpdateResourceDisplay (previousResourceValue, currentResourceValue)
    -- DEBUG(L"BrightWizardResource:UpdateResourceDisplay ("..previousResourceValue..L", "..currentResourceValue..L")")
    self.m_Windows["Eyes"]:Show( self.GetLevel(currentResourceValue) == 5 )
    self.m_Windows["Flames"]:Show( self.GetLevel(currentResourceValue) > 0)
    self.m_Windows["Flames"]:SetTint(self.GetColor(currentResourceValue))
    self.m_Windows["Text"]:Show( self.GetLevel(currentResourceValue) > 0 )
    
    if( currentResourceValue > 0 )
    then
        self.m_Windows["Text"]:SetText( L""..currentResourceValue )
    end
    
    self.m_Data:SetPrevious (previousResourceValue)
end

function BrightWizardResource:Update (timePassed)
    -- Currently not very useful, might be used for animations...
end
