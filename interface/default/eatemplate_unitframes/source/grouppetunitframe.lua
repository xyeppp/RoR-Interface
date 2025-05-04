-----------------------------------------------------------------------------
--
-- Local utility functions and lookup tables
--
-----------------------------------------------------------------------------

local UnitIdToGroupPetMapping =
{
    ["GroupPet1"]  = { groupMemberIndex = 1, targetEvent = SystemData.Events.TARGET_GROUP_MEMBER_1_PET },
    ["GroupPet2"]  = { groupMemberIndex = 2, targetEvent = SystemData.Events.TARGET_GROUP_MEMBER_2_PET },
    ["GroupPet3"]  = { groupMemberIndex = 3, targetEvent = SystemData.Events.TARGET_GROUP_MEMBER_3_PET },
    ["GroupPet4"]  = { groupMemberIndex = 4, targetEvent = SystemData.Events.TARGET_GROUP_MEMBER_4_PET },
    ["GroupPet5"]  = { groupMemberIndex = 5, targetEvent = SystemData.Events.TARGET_GROUP_MEMBER_5_PET }
}

--
-- The window for the entire unit frame.  Most of it is created dynamically (aside from the anchoring)
-- but the portrait remains as part of the window definition for GroupPetUnitFrame.
--

GroupPetUnitFrame = Frame:Subclass ("GroupPetUnitFrame")

--
-- Create a new instance of a GroupPetUnitFrame and initialize it.
-- 
function GroupPetUnitFrame:Create (windowName, unitId)    
    local newUnitFrame = self:CreateFromTemplate (windowName)
        
    if (newUnitFrame == nil)
    then
        return nil
    end
    
    newUnitFrame.m_unitId = unitId
    CircleImageSetTexture( newUnitFrame:GetName().."Portrait", "render_scene_group_pet_portrait"..UnitIdToGroupPetMapping[newUnitFrame.m_unitId].groupMemberIndex, 45, 46 )
    StatusBarSetMaximumValue( newUnitFrame:GetName().."HealthPercentBar", 100 )
    newUnitFrame:Show(false)
    return newUnitFrame
end

function GroupPetUnitFrame:Update (elapsedTime)
end
--
-- Update a unit frame from its unitId information.
--
function GroupPetUnitFrame:UpdateHealth (petHealthVal)
    StatusBarSetCurrentValue( self:GetName().."HealthPercentBar", petHealthVal )
end
function GroupPetUnitFrame:SetPetPortrait()
    CircleImageSetTexture( self:GetName().."Portrait", "render_scene_group_pet_portrait"..UnitIdToGroupPetMapping[self.m_unitId].groupMemberIndex, 45, 46 )
end

function GroupPetUnitFrame:UpdateLevel (level)
    local windowName = self:GetName ()
    
    LabelSetText        (windowName.."LevelText",        L""..level)
    LabelSetTextColor   (windowName.."LevelText",        DefaultColor.XP_COLOR_FILLED.r, DefaultColor.XP_COLOR_FILLED.g, DefaultColor.XP_COLOR_FILLED.b)
end

function GroupPetUnitFrame.OnLButtonDown (flags, x, y)
    local unitFrame = FrameManager:GetActiveWindow ()
    if (unitFrame ~= nil)
    then
        BroadcastEvent( UnitIdToGroupPetMapping[unitFrame.m_unitId].targetEvent )
    end
end

