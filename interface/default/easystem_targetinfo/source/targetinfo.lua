
-- NOTE: This file is doccumented with NaturalDocs style comments. All comments begining with "--#' will
-- be included in the output.

------------------------------------------------------------------------------------------------------------------------------------------------
--# Title: TargetInfo
--#     This file contains util functions for accessing target information.
------------------------------------------------------------------------------------------------------------------------------------------------

--
-- In order to avoid dependency issues, the temporary target tracking table (alliteration ftw!)
-- Is located here.
--

-- The UnitFrame stuff is decoupled from the actual information representing the target.
-- The purpose of the TargetWindow is to collect that information from client updates
-- and publish it to the visible interface via the UnitFrame objects.
--
-- This "TargetInfo" exists so that updates can be collected from the client
-- and pushed into the UnitFrame.  It's going away.  A new architecture is being designed
-- that will allow the client to simply call registered Lua-scripts with unit updates...
-- instead of saying "new event!!!" and then forcing Lua to call BACK into the client to
-- request relevant information...instead the client will bundle that whole "event"
-- up into the form of "here's a new event, and the relevant information that goes along with it."

TargetInfo = 
{
    m_Units = {},
    
    
    -- Unit Types
    HOSTILE_TARGET          = "selfhostiletarget",
    FRIENDLY_TARGET         = "selffriendlytarget",
}

function TargetInfo:SetUnitInfo (unitId, targetData)
    self.m_Units[unitId] = targetData
end

function TargetInfo:ClearUnits ()
    self.m_Units = {}
end

function TargetInfo:UnitEntityId (unitId)
    if (unitId == nil or self.m_Units[unitId] == nil or self.m_Units[unitId].entityid == nil) then
        return 0
    end

    return self.m_Units[unitId].entityid;
end

function TargetInfo:UnitName (unitId)
    if (unitId == nil or self.m_Units[unitId] == nil or self.m_Units[unitId].name == nil) then
        return L"";
    end
    
    return self.m_Units[unitId].name;
end

function TargetInfo:UnitHealth (unitId)
    if (unitId == nil or self.m_Units[unitId] == nil or self.m_Units[unitId].healthPercent == nil) then
        return 0;
    end
    
    return self.m_Units[unitId].healthPercent;
end

function TargetInfo:UnitType (unitId)
    if (unitId == nil or self.m_Units[unitId] == nil or self.m_Units[unitId].type == nil) then
        return SystemData.TargetObjectType.NONE;
    end
    
    return self.m_Units[unitId].type;
end

function TargetInfo:UnitLevel (unitId)
    if (unitId == nil or self.m_Units[unitId] == nil or self.m_Units[unitId].level == nil) then
        return 0;
    end
    
    return self.m_Units[unitId].level;
end

function TargetInfo:UnitBattleLevel( unitId )
    if( unitId == nil or self.m_Units[unitId] == nil )
    then
        return 0
    elseif( self.m_Units[unitId].battleLevel == nil )
    then
        return self.m_Units[unitId].level
    end
    
    return self.m_Units[unitId].battleLevel
end

function TargetInfo:UnitTier (unitId)
    if (unitId == nil or self.m_Units[unitId] == nil or self.m_Units[unitId].tier == nil) then
        return 0;
    end
    
    return self.m_Units[unitId].tier;
end

function TargetInfo:UnitConType (unitId)
    if (unitId == nil or self.m_Units[unitId] == nil or self.m_Units[unitId].conType == nil) then
        return 0;
    end
    
    return self.m_Units[unitId].conType;
end

function TargetInfo:UnitIsPvPFlagged (unitId)
    if (unitId == nil or self.m_Units[unitId] == nil or self.m_Units[unitId].isPvP == nil) then
        return false;
    end
    
    return self.m_Units[unitId].isPvP;
end

function TargetInfo:UnitIsNPC (unitId)
    if (unitId == nil or self.m_Units[unitId] == nil or self.m_Units[unitId].isNPC == nil) then
        return false;
    end
    
    return self.m_Units[unitId].isNPC;
end

function TargetInfo:UnitIsFriendly (unitId)
    if (unitId == nil or self.m_Units[unitId] == nil or self.m_Units[unitId].type == nil) then
        return false;
    end
    
    if( self.m_Units[unitId].type == SystemData.TargetObjectType.SELF )
    then
        return true
    end
    
    if( self.m_Units[unitId].type == SystemData.TargetObjectType.ALLY_PLAYER )
    then
        return true
    end
    
    if( self.m_Units[unitId].type == SystemData.TargetObjectType.ALLY_NON_PLAYER )
    then
        return true
    end
        
    return false
end

function TargetInfo:UnitMapPinType (unitId)
    if (unitId == nil or self.m_Units[unitId] == nil or self.m_Units[unitId].mapPinType == nil) then
        return -1;
    end
    
    return self.m_Units[unitId].mapPinType;
end

function TargetInfo:UnitRelationshipColor (unitId)
    if (unitId == nil or self.m_Units[unitId] == nil or self.m_Units[unitId].relationshipColor == nil) then
        return { r = 255, g = 255, b = 255 };
    end
    
    return self.m_Units[unitId].relationshipColor;
end

function TargetInfo:UnitDifficultyMask (unitId)
    if (unitId == nil or self.m_Units[unitId] == nil or self.m_Units[unitId].difficultyMask == nil) then
        return 0
    end
    
    return self.m_Units[unitId].difficultyMask;
end

function TargetInfo:UnitCareer (unitId)
    if (unitId == nil or self.m_Units[unitId] == nil or self.m_Units[unitId].career == nil) then
        return 0
    end

    return self.m_Units[unitId].career;
end

function TargetInfo:UnitCareerName (unitId)
    if (unitId == nil or self.m_Units[unitId] == nil or self.m_Units[unitId].careerName == nil) then
        return 0
    end

    return self.m_Units[unitId].careerName;
end

function TargetInfo:UnitNPCTitle (unitId)
    if (unitId == nil or self.m_Units[unitId] == nil or self.m_Units[unitId].npcTitle == nil) then
        return 0
    end

    return self.m_Units[unitId].npcTitle;
end

function TargetInfo:UnitSigilEntryId (unitId)
    if (unitId == nil or self.m_Units[unitId] == nil or self.m_Units[unitId].sigilEntryId == nil ) then
        return 0
    end
    
    return self.m_Units[unitId].sigilEntryId
end

--
--  This is going away eventually...
--
function TargetInfo:UpdateFromClient ()
    local targets = GetUpdatedTargets ()
    
    -- Calling GetUpdatedTargets will no longer return any table data until the next
    -- PLAYER_TARGET_UPDATED event!!
    
    -- Health events will come from somewhere else...maybe some crazy event like PLAYER_TARGET_HEALTH_UPDATED
    -- but currently still results in some trigger that will allow GetUpdatedTargets to be called.
    
    if (targets ~= nil) then
        for unitId, targetData in pairs (targets) do
            self:SetUnitInfo (unitId, targetData)
        end
    else
        self:ClearUnits ()
    end
end

function TargetInfo:ShowHealthBar (unitId)
    -- show the health bar as the default
    if (unitId == nil or self.m_Units[unitId] == nil or self.m_Units[unitId].showHealthBar == nil) then
        return true
    end

    return self.m_Units[unitId].showHealthBar;
end