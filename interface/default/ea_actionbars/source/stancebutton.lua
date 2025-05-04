StanceButton = ActionButton:Subclass ("StanceButton")

ActionBar:RegisterButtonFactory ("StanceButton", StanceButton)

--[[
    Not fully implemented yet.  Inherited functions were mostly for proof of concept.
    But they will be used in the final version.
--]]
function StanceButton:Create (windowName, parentName, hotbarSlot, modificationSettings)
    local newButton = self:ParentCreate (windowName, parentName, hotbarSlot, modificationSettings)
    
    return newButton
end

function StanceButton:OnMouseOver (flags, x, y)
    self:ParentOnMouseOver (flags, x, y)
end

function StanceButton:OnMouseOverEnd (flags, x, y)
    self:ParentOnMouseOverEnd (flags, x, y)
end