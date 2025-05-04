ButtonFrame = Frame:Subclass ()

function ButtonFrame:SetCheckButtonFlag (flag)
    ButtonSetCheckButtonFlag (self:GetName (), flag)
end

function ButtonFrame:SetPressedFlag (flag)
    self.m_IsPressed = flag
    ButtonSetPressedFlag (self:GetName (), flag)
end

function ButtonFrame:IsPressed ()   
    return self.m_IsPressed
end

function ButtonFrame:OnLButtonUp (flags, mouseX, mouseY)
    if (self.m_RadioGroup)
    then
        self.m_RadioGroup:UpdatePressedId (self)
    end
end

function ButtonFrame:SetText (text)
    ButtonSetText (self:GetName (), WideStringFromData (text))
end