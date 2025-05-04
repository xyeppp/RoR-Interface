StanceBar = {}

function StanceBar.Initialize ()
    RegisterEventHandler (SystemData.Events.INTERFACE_RELOADED,     "StanceBar.UpdateBar")
    RegisterEventHandler (SystemData.Events.LOADING_END,            "StanceBar.UpdateBar")
end

function StanceBar.Shutdown ()
    UnregisterEventHandler (SystemData.Events.INTERFACE_RELOADED,   "StanceBar.UpdateBar")
    UnregisterEventHandler (SystemData.Events.LOADING_END,          "StanceBar.UpdateBar")
end

function StanceBar.CreateBar (barName, barParameters)
    ActionBars:CreateBar (barName, barParameters)
end

function StanceBar.UpdateBar ()
    local standardAbilities = Player.GetAbilityTable (GameData.AbilityType.STANDARD)
    
    for abilityId, abilityData in pairs (standardAbilities)
    do
        -- Not the most efficient thing, but doesn't happen often enough that this will ever matter.
        StanceBar.UpdateStanceButton (abilityData.id, GameData.AbilityType.STANDARD) 
    end
end

function StanceBar.UpdateStanceButton (abilityId, abilityType)
    local abilityData = Player.GetAbilityData (abilityId, abilityType)
    
    if ((abilityData ~= nil) and (abilityData.stanceOrder ~= nil) and (abilityData.stanceOrder > 0))
    then       
        SetHotbarData (GameDefs.FIRST_STANCE_ABILITY_SLOT + abilityData.stanceOrder - 1, GameData.PlayerActions.DO_ABILITY, abilityData.id)
    end
end