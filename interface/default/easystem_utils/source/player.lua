----------------------------------------------------------------
-- Player.lua 
--
-- Used to update all player data that changes but should not
-- be tied to a specific interface window.
----------------------------------------------------------------

----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

Player = {}

Player.previousMoney    = nil

Player.AbilityType = {}
Player.AbilityType.INVALID  = GameData.AbilityType.INVALID
Player.AbilityType.ABILITY  = GameData.AbilityType.STANDARD
Player.AbilityType.MORALE   = GameData.AbilityType.MORALE
Player.AbilityType.TACTIC   = GameData.AbilityType.TACTIC
Player.AbilityType.GRANTED  = GameData.AbilityType.GRANTED
Player.AbilityType.PASSIVE  = GameData.AbilityType.PASSIVE
Player.AbilityType.PET      = GameData.AbilityType.PET

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------
local AbilityLookups = {}
local m_blockedAbilities = {}

----------------------------------------------------------------
-- Player Functions
----------------------------------------------------------------

--[[
    Register for event handlers...
    
    Tying events to the root window for now, this should probably change.
--]]
function Player.Initialize ()
    RegisterEventHandler (SystemData.Events.PLAYER_MONEY_UPDATED,           "Player.UpdateMoney")
    RegisterEventHandler (SystemData.Events.PLAYER_ABILITIES_LIST_UPDATED,  "Player.RefreshAbilityLookups")
    RegisterEventHandler (SystemData.Events.PLAYER_SINGLE_ABILITY_UPDATED,  "Player.RefreshSingleAbility")
    RegisterEventHandler (SystemData.Events.PLAYER_ADVANCE_ALERT,           "Player.AdvanceAlert")
    RegisterEventHandler (SystemData.Events.SPELL_CAST_CANCEL,              "Player.CancelSpell")
		
    Player.RefreshAbilityLookups ()
    
    Player.UpdateMoney (GameData.Player.money)
	
	-- Needed to get the blocked abilities on first request after reload of ui.
	GameData.Player.blockedAbilitiesDirty = true
end

--[[
    Performs any tasks needed for shutdown...
--]]
function Player.Shutdown ()    
    UnregisterEventHandler (SystemData.Events.PLAYER_MONEY_UPDATED,             "Player.UpdateMoney")
    UnregisterEventHandler (SystemData.Events.PLAYER_ABILITIES_LIST_UPDATED,    "Player.RefreshAbilityLookups")
    UnregisterEventHandler (SystemData.Events.PLAYER_SINGLE_ABILITY_UPDATED,    "Player.RefreshSingleAbility")
    UnregisterEventHandler (SystemData.Events.PLAYER_ADVANCE_ALERT,             "Player.AdvanceAlert")
    UnregisterEventHandler (SystemData.Events.SPELL_CAST_CANCEL,                "Player.CancelSpell")
end

--[[
    Ability Type definitions...these should not be defined in code
    if they are, then redefine these to the proper values.
--]]


function Player.RefreshAbilityLookups()

    -- NOTE: This will obliterate cooldowns if your ability list gets refreshed
    -- while something is cooling down.  One possible workaround is to cache
    -- all the current ability cooldown values and copy them to the updated ability lists...
    -- Not going to worry about it for now.

    AbilityLookups = {}

    for i = GameData.AbilityType.FIRST, GameData.AbilityType.NUM_TYPES do
        local abilityTable = GetAbilityTable (i)
        if (nil ~= abilityTable) then
            AbilityLookups[i] = { lookup = abilityTable }
        else
            DEBUG (L"Unable to retrieve ability table: "..i);
        end
    end
end

function Player.RefreshSingleAbility (abilityID, abilityType)
    local abilityData = GetAbilityData (abilityID);
    
    if (abilityData ~= nil) then               
        if (nil ~= abilityType and
            nil ~= AbilityLookups[abilityType] and
            nil ~= AbilityLookups[abilityType].lookup) 
        then
            if (abilityData.id ~= abilityID) then
                -- Removed!
                AbilityLookups[abilityType].lookup[abilityID] = nil;
            else
                -- Added or updated
                AbilityLookups[abilityType].lookup[abilityData.id] = abilityData;
            end
        end
    end
end

--[[
    Returns an ability table for the given abilityId from the
    player's known abilities.
    
    nil is returned if the abilityId doesn't match any of the player's
    known abilities.
    
    NOTE: The way that this data is exposed to lua could probably
    move to a simple table lookup, rather than N array searches, where
    N is the number of different ability types that the player has.
    
    The preferredAbilityType is an optional parameter which suggests
    to this function that you know which table to look in.  If the 
    ability is not found in the preferred table, then the other tables
    are still examined just to make sure.
--]]

local function SearchAbilityMapForAbility (aType, aId)
    -- Now storing the abilities indexed by their ids rather than slot.
    if ((nil ~= AbilityLookups[aType].lookup)           and
        (nil ~= AbilityLookups[aType].lookup[aId])      and
        (AbilityLookups[aType].lookup[aId].id == aId)) 
    then
        return AbilityLookups[aType].lookup[aId]
    end
    
    return nil
end

function Player.GetAbilityData( abilityId, preferredAbilityType ) 

    -- Something is inserting an empty ability into the player's ability
    -- lists.  Once again, treating the symptom by just returning nil
    -- so the scripts don't think that ability 0 is valid.
    if (abilityId == 0) then
        return nil
    end
        
    local excludeType = Player.AbilityType.INVALID
    
    -- Attempt to search for the preferred ability first.
    if (preferredAbilityType ~= nil and AbilityLookups[preferredAbilityType] ~= nil) then       
        local potentialMatch = SearchAbilityMapForAbility (preferredAbilityType, abilityId)
        
        if (nil ~= potentialMatch) then
            return (potentialMatch)
        end
        
        -- Oh well, we didn't find it...exclude this table from future searches.
        excludeType = preferredAbilityType
    end
    
    -- It wasn't found in the preferred table...if there was a preferred table.
    -- So, look through the remaining non-excluded tables...
    
    for abilityType, abilityEntry in pairs (AbilityLookups) do
        if (excludeType ~= abilityType) then            
            local potentialMatch = SearchAbilityMapForAbility (abilityType, abilityId)

            if (nil ~= potentialMatch) then
                return (potentialMatch)
            end            
        end
    end
    
    -- Finally, check the client's ability tables.  This isn't here because the Lua scripts
    -- possibly missed an update, it's here to deal with the fact that some abilities -
    -- notably those on items - are not known by the player.  However, there's a good chance
    -- that when Player.GetAbilityData is called, the player is actually using the "unknown"
    -- ability (probably by using the item.)  GetAbilityData makes a concession and returns
    -- valid ability information for abilities that are currently active, but unknown by
    -- the player.  
    
    -- DEBUG
    if (abilityId == nil)
    then
        SIMPLE_STACK_TRACE ()
    end
    
    local abilityData = GetAbilityData (abilityId)
    
    if (abilityData == nil or abilityData.id == nil or abilityData.id == 0) then
        return nil
    end
    
    return abilityData
end

--[[
    Sometimes Addons will need access to an entire ability table.
    That's what this does.
    
    See beginning of Player.lua for valid ability types.    
--]]
function Player.GetAbilityTable (abilityType)
    if (nil ~= abilityType and nil ~= AbilityLookups[abilityType]) then        
        return AbilityLookups[abilityType].lookup
    end
        
    return nil
end

--[[
    Cancels the currently active ability, returns false if there was nothing
    to cancel.  Wraps exposed C function so that we can play deactivation
    sounds, etc...
--]]
function Player.CancelSpell ()
    local wasUsingAnAbility = CancelSpell ()
    
    return wasUsingAnAbility
end

--[[
    Updates the players current cash from the player's current money.
    If the amount is different than the previous value (cached on update) then
    a cha-ching sound is played, and a notification is logged to the chat window
    (in the case of the player receiving money.)
--]]
function Player.UpdateMoney (currentMoney)

    local playerInitialized = IsPlayerInitialized ()
    
    if (playerInitialized == false) then
        Player.previousMoney = nil
    end
        
    if (Player.previousMoney == nil) then
        Player.previousMoney = currentMoney
        return
    end
        
    if (currentMoney ~= Player.previousMoney and playerInitialized) then
        local diff = currentMoney - Player.previousMoney
    
        if (diff > 0) then
            local wealth = GetStringFormat (StringTables.Default.LABEL_YOU_RECEIVE, { MoneyFrame.FormatMoneyString (diff) })
                
            EA_ChatWindow.Print (wealth, SystemData.ChatLogFilters.LOOT_COIN)
        end
        
        if EA_Window_InteractionStore.InteractingWithStore() then
            Sound.Play (Sound.MONEY_TRANSACTION)
        else
            Sound.Play (Sound.MONEY_LOOT)
        end
    end
    
    -- Then set how much money the player has to how much money the player REALLY has.
    Player.previousMoney = currentMoney
end

function Player.GetMoney ()
    if (Player.previousMoney == nil)
    then
        return 0
    end
    
    return Player.previousMoney
end

--[[
    Emit chat log notification that the player has gained something as a result of levelling up...
--]]
function Player.AdvanceAlert ()
    local updateString  = L"";
    local params        = nil;
    
    if (GameData.AdvanceAlert.Type == AdvanceAlertType.STATISTIC) then
    
        if (StatInfo[GameData.AdvanceAlert.Id] ~= nil and
           (StatInfo[GameData.AdvanceAlert.Id].skip == nil or
            StatInfo[GameData.AdvanceAlert.Id].skip == false)) 
        then
            params = { StatInfo[GameData.AdvanceAlert.Id].name, GameData.AdvanceAlert.Delta };    
        end
        
    elseif (GameData.AdvanceAlert.Type == AdvanceAlertType.HIT_POINTS) then
    
        params = { GetString (StringTables.Default.LABEL_HP), GameData.AdvanceAlert.Delta };
        
    elseif (GameData.AdvanceAlert.Type == AdvanceAlertType.ACTION_POINTS) then
    
        params = { GetString (StringTables.Default.LABEL_AP), GameData.AdvanceAlert.Delta };

    end
    
    if (params ~= nil) then
        updateString = GetStringFormat (StringTables.Default.LEVEL_STAT_INCREASE, params);
        
        if (updateString ~= nil and updateString ~= L"") then
            TextLogAddEntry ("Combat", SystemData.ChatLogFilters.EXP, updateString);
        end
    end
end

local function GetBlockedAbilitiesOfType( abilityType )
	if( GameData.Player.blockedAbilitiesDirty )
	then
		GameData.Player.blockedAbilitiesDirty = false
		m_blockedAbilities = GetBlockedAbilities()
	end

	if( abilityType == GameData.AbilityType.STANDARD )
	then
		return m_blockedAbilities.standard
	elseif( abilityType == GameData.AbilityType.TACTIC )
	then
		return m_blockedAbilities.tactic
	elseif( abilityType == GameData.AbilityType.MORALE )
	then
		return m_blockedAbilities.morale
	end
	
	return m_blockedAbilities
end

function Player.IsAbilityBlocked( abilityId, abilityType )

	local abilities = GetBlockedAbilitiesOfType( abilityType )
	
	if( abilityType )
	then
		for i, ability in pairs( abilities )
		do
			if( ability == abilityId )
			then
				return true
			end
		end
	else
		ERROR(L"abilityType is nil in call to Player.IsAbilityBlocked( abilityId, abilityType )")
	end
	return false
end

function Player.TintWindowIfAbilityIsBlocked( window, abilityId, abilityType )
	if( Player.IsAbilityBlocked( abilityId, abilityType ) )
	then
		local tint = DefaultColor.RED
		WindowSetTintColor( window, tint.r, tint.g, tint.b )
		return true
	else
		local tint = DefaultColor.ZERO_TINT
		WindowSetTintColor( window, tint.r, tint.g, tint.b )
		return false
	end
end


function Player.GetTier()
    return math.ceil( GameData.Player.level / 10 )
end