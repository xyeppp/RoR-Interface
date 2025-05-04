TextEditBox = Frame:Subclass ()

function TextEditBox:TextAsWideString ()
    return TextEditBoxGetText (self:GetName ())
end

function TextEditBox:TextAsString ()
    return tostring (self:TextAsWideString ())
end

function TextEditBox:TextAsNumber ()
    return tonumber (self:TextAsString ())
end

function TextEditBox:SetText (data)
    TextEditBoxSetText (self:GetName (), WideStringFromData (data))
end

function TextEditBox:Clear ()
    TextEditBoxSetText (self:GetName (), L"")
end

