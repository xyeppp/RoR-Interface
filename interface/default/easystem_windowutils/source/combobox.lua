ComboBox = Frame:Subclass ()

function ComboBox:TextAsWideString ()
    return ComboBoxGetSelectedText (self:GetName ())
end

function ComboBox:TextAsString ()
    return tostring (self:TextAsWideString ())
end

function ComboBox:AddTable (wideStringItemTable)
    local comboName = self:GetName ()
    
    for _, v in ipairs (wideStringItemTable)
    do
        ComboBoxAddMenuItem (comboName, v)
    end
    
    -- select the first item as a convenience...
    self:SetSelectedMenuItem (1)
end

function ComboBox:SetSelectedMenuItem (itemIndex)
    ComboBoxSetSelectedMenuItem (self:GetName (), itemIndex)
end