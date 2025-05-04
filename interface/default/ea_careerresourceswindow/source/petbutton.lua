PetButton = ActionButton:Subclass ("ActionButton")

ActionBar:RegisterButtonFactory ("PetButton", PetButton)

function PetButton:OnRButtonDown (flags, x, y)
    local slot, actionType, actionId = self:GetActionData ()
    
    if ((actionType == GameData.PlayerActions.COMMAND_PET_DO_ABILITY) and (actionId ~= 0))
    then
        CommandPetToggleAbility (actionId)
    end 
end