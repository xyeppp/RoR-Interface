local NO_STANCE             = 0
local GIFT_OF_SAVAGERY      = 8394
local GIFT_OF_BRUTALITY     = 8398
local GIFT_OF_MONSTROSITY   = 8403
local SCOUT_STANCE          = 9080
local ASSAULT_STANCE        = 9090
local SKIRMISH_STANCE       = 9094
local WITCH_HUNTER_STEALTH  = 8090
local WITCH_HUNTER_STEALTH2 = 6012
local WITCH_ELF_STEALTH     = 9393
local WITCH_ELF_STEALTH2    = 6013
local SQUIG_ARMOR           = 1830
local PLAY_AS_MONSTER       = 27950

ActionBarStanceSwaps = 
{
    -- This maps ability/buff/stance ids (they're all just ability ids) to a set of action bars.
    --
    -- When the character gains a stance, if the stance is in this set, the hotbars are remapped 
    -- to that sequence (using ipairs over the set, so it's ok if the whole sequence isn't specified)
    --
    -- When the character loses a stance, the hotbars are remapped to their default configuration.
    --
    -- Because the stances are given as ability ids, it will be most useful to provide some constant
    -- symbols to make editing this file easier (until abilities can be referred to by name?)
    
    m_Swaps =
    {
        [NO_STANCE]             = { 1 },
        [GIFT_OF_SAVAGERY]      = { 1 },
        [GIFT_OF_BRUTALITY]     = { 7 },
        [GIFT_OF_MONSTROSITY]   = { 8 },
        [SCOUT_STANCE]          = { 1 },
        [ASSAULT_STANCE]        = { 7 },
        [SKIRMISH_STANCE]       = { 8 },
        [WITCH_HUNTER_STEALTH]  = { 6 },
        [WITCH_HUNTER_STEALTH2] = { 6 },
        [WITCH_ELF_STEALTH]     = { 6 },
        [WITCH_ELF_STEALTH2]    = { 6 },
        [SQUIG_ARMOR]           = { 6 },
        [PLAY_AS_MONSTER]       = { 11 }, -- DO NOT REUSE FOR ANY OTHER STANCE!!!
                                         -- PaM is available to all careers and must
                                         -- not overwrite career-specific stance hotbars!
                                         -- If this value ever changes, also change
                                         -- Player.h/c_SSDB_PLAY_AS_MONSTER_STANCE_BAR!
    },
    
    m_CurrentStance = 0
}

function ActionBarStanceSwaps.Initialize ()
    RegisterEventHandler (SystemData.Events.PLAYER_STANCE_UPDATED, "ActionBarStanceSwaps.OnUpdated")
    RegisterEventHandler (SystemData.Events.PLAY_AS_MONSTER_STATUS, "ActionBarStanceSwaps.HandlePlayAsMonsterStatus")
end

function ActionBarStanceSwaps.Shutdown ()
    UnregisterEventHandler (SystemData.Events.PLAYER_STANCE_UPDATED, "ActionBarStanceSwaps.OnUpdated")
    UnregisterEventHandler (SystemData.Events.PLAY_AS_MONSTER_STATUS, "ActionBarStanceSwaps.HandlePlayAsMonsterStatus")
end

function ActionBarStanceSwaps.OnUpdated (stance, updateType)
    local currentStance = ActionBarStanceSwaps:GetCurrentStance ()
    
    if ((updateType == GameData.STANCE_ADDED) and (currentStance ~= stance))
    then
        ActionBarStanceSwaps:RemapBars (stance)
        ActionBarStanceSwaps:SetCurrentStance (stance)
    elseif ((updateType == GameData.STANCE_REMOVED) and (currentStance == stance))
    then
        ActionBarStanceSwaps:RemapBars (NO_STANCE)
        ActionBarStanceSwaps:SetCurrentStance (NO_STANCE)
    end
end

function ActionBarStanceSwaps.HandlePlayAsMonsterStatus( isPlayAsMonster )

    if ( not isPlayAsMonster )
    then
        -- Play-As-Monster has been toggled off, though it may have been toggled
        -- after the stance was removed, so we need to now manually remap the bar
        -- back to NO_STANCE to ensure the player returns to the intended, default
        -- hotbar configuration
        ActionBarStanceSwaps:RemapBars (NO_STANCE)
        ActionBarStanceSwaps:SetCurrentStance (NO_STANCE)
    end
    
end

function ActionBarStanceSwaps:RemapBars (stance)
    local swaps = self.m_Swaps[stance]
    
    if ((swaps ~= nil) and (type (swaps) == "table"))
    then        
        for physicalBar, logicalBar in ipairs (swaps)
        do
            local bar = ActionBars:GetBar (physicalBar)
            
            if (bar)
            then
                bar:SetPageSelectorSequence (swaps)
            end
            
            SetHotbarPage (physicalBar, logicalBar)
        end
    end    
end

function ActionBarStanceSwaps:GetCurrentStance ()
    return self.m_CurrentStance
end

function ActionBarStanceSwaps:SetCurrentStance (stance)
    self.m_CurrentStance = stance
end
