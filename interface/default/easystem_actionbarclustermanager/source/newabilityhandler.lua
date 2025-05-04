NewAbilityHandler = {}

function NewAbilityHandler.Initialize ()
    RegisterEventHandler (SystemData.Events.PLAYER_NEW_ABILITY_LEARNED, "NewAbilityHandler.AttemptToAddNewAbilityToSomeBar")
end

function NewAbilityHandler.Shutdown ()
    UnregisterEventHandler (SystemData.Events.PLAYER_NEW_ABILITY_LEARNED, "NewAbilityHandler.AttemptToAddNewAbilityToSomeBar")
end

function NewAbilityHandler.AttemptToAddNewAbilityToSomeBar (abilityId, abilityType)
    local newAbility = Player.GetAbilityData (abilityId, abilityType)
    assert (newAbility)
    
    --[[
        When the player receives a new ability during play, auto add it to the hot bar/morale bar / active tactics if
        there is an open slot (and the player has sufficient resources for the operation.)
        
        NOTE: At some point, this should become an interface option for whether or not players 
        want to have abilities automatically added to tactic sets, morale loadouts, and ability bars.
    --]]
    
    if (newAbility.numTacticSlots > 0)
    then
        NewAbilityHandler.AttemptToAddTactic (newAbility)
    elseif ((newAbility.moraleLevel > 0) and (newAbility.moraleLevel <= GameData.NUM_MORALE_LEVELS))
    then   
        NewAbilityHandler.AttemptToAddMorale (newAbility)
    else
        NewAbilityHandler.AttemptToAddAbility (newAbility)
    end
end

function NewAbilityHandler.AttemptToAddTactic (newAbility)
    local activeTactics     = GetActiveTactics ()
    local tacticsSlots      = GetNumTacticsSlots ()
    local availableSlots    = tacticsSlots[newAbility.tacticType] -- Begins at the maximum!

    -- Treat this the same as the user right clicking on a tactic in the Abilities window (handled in function AbilitiesWindow.ActionRButtonDown()).
    TacticsEditor.ExternalAddTactic (newAbility.id)
end

function NewAbilityHandler.AttemptToAddMorale (newAbility)
    local _, currentlySlottedMoraleAbilityId = GetMoraleBarData (newAbility.moraleLevel)

    if (currentlySlottedMoraleAbilityId == 0)
    then
        SetMoraleBarData (newAbility.moraleLevel, newAbility.id)
    end
end

function NewAbilityHandler.AttemptToAddAbility (newAbility)
    -- Passive abilities are never added to any hotbar...
    if (newAbility.isPassive)
    then
        return
    end
    
    -- Granted abilities are not added to any bar aside from the GrantedAbilitiesWindow.
    if (newAbility.isGranted)
    then
        for currentHotbarSlot = GameDefs.FIRST_GRANTED_ABILITY_SLOT, GameDefs.LAST_GRANTED_ABILITY_SLOT
        do
            local abilityType, abilityId = GetHotbarData (currentHotbarSlot)
            assert ((abilityType == 0) or (abilityType == GameData.PlayerActions.DO_ABILITY))
            
            if (abilityId == 0)
            then
                SetHotbarData (currentHotbarSlot, GameData.PlayerActions.DO_ABILITY, newAbility.id)
                return
            end            
        end
    end
    
    -- Stance abilities are added to the stance bar by their stance order
    if (newAbility.stanceOrder > 0)
    then
        StanceBar.UpdateStanceButton (newAbility.id, newAbility.abilityType)
        return
    end

    -- If the player already has this ability on their hotbars, don't re-add it, there's no
    -- reason to make it look like they have more abilities than they actually do:

    local   playerAlreadyHasAbilityOnHotbar = false
    local   firstEmptySlot                  = -1
    
    for slot = 1, GameDefs.HOTBAR_SWAPPABLE_SLOT_COUNT
    do
        local abilityType, abilityId = GetHotbarData (slot)

        if (abilityId == newAbility.id)
        then
            playerAlreadyHasAbilityOnHotbar = true
            break
        end

        if ((firstEmptySlot == -1) and (abilityId == 0))
        then
            firstEmptySlot = slot
        end
    end

    if ((false == playerAlreadyHasAbilityOnHotbar) and (firstEmptySlot > -1))
    then
        SetHotbarData (firstEmptySlot, GameData.PlayerActions.DO_ABILITY, newAbility.id)
    end
end

