Label = Frame:Subclass ()

function Label:SetText (data)
    LabelSetText (self:GetName (), WideStringFromData (data))
end

function Label:TextAsWideString ()
    return LabelGetText (self:GetName ())
end

function Label:TextAsString ()
    return tostring (self:TextAsWideString ())
end

function Label:TextAsNumber ()
    return tonumber (self:TextAsString ())
end

function Label:Clear ()
    self:SetText (L"")
end

function Label:GetTextColor ()
    self.m_TextColorRed, self.m_TextColorGreen, self.m_TextColorBlue = LabelGetTextColor (self:GetName ())
    return self.m_TextColorRed, self.m_TextColorGreen, self.m_TextColorBlue
end

function Label:SetTextColor (r, g, b)
    if (type (r) == "table")
    then
        g = r.g
        b = r.b
        r = r.r -- Change r last so it doesn't destroy the table
    end
    
    if (r ~= self.m_TextColorRed or g ~= self.m_TextColorGreen or b ~= self.m_TextColorBlue)
    then
        self.m_TextColorRed     = r
        self.m_TextColorGreen   = g
        self.m_TextColorBlue    = b
            
        LabelSetTextColor (self:GetName (), r, g, b)
    end
end

function Label:SetFont  (fontName, lineSpacing)
    LabelSetFont (self:GetName (), fontName, lineSpacing)
end
