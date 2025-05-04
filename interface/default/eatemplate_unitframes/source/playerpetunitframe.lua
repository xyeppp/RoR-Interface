
--
-- The window for the entire unit frame.  Most of it is created dynamically (aside from the anchoring)
-- but the portrait remains as part of the window definition for GroupPetUnitFrame.
--

PlayerPetUnitFrame = Frame:Subclass ("PlayerPetUnitFrame")

--
-- Create a new instance of a PlayerPetUnitFrame and initialize it.
-- 
function PlayerPetUnitFrame:Create (windowName)    
    local newUnitFrame = self:CreateFromTemplate (windowName)
        
    if (newUnitFrame == nil)
    then
        return nil
    end

    StatusBarSetMaximumValue( newUnitFrame:GetName().."HealthPercentBar", 100 )
    newUnitFrame:Show (false)
    return newUnitFrame
end

--
-- Update a unit frame from its unitId information.
--
function PlayerPetUnitFrame:SetPlayersPetName (petName)
    local windowName = self:GetName ()
    
    LabelSetText (windowName.."Name", petName)
end

function PlayerPetUnitFrame:SetPetPortrait()
    CircleImageSetTexture( self:GetName().."Portrait", "render_scene_pet_portrait", 40, 54 )
end

function PlayerPetUnitFrame:Update (elapsedTime)
end

function PlayerPetUnitFrame:UpdateHealth (petHealthVal)
    StatusBarSetCurrentValue( self:GetName().."HealthPercentBar", petHealthVal )
end

function PlayerPetUnitFrame:UpdateLevel (level)
    local windowName = self:GetName ()
    
    LabelSetText        (windowName.."LevelText",        L""..level)
    LabelSetTextColor   (windowName.."LevelText",        DefaultColor.XP_COLOR_FILLED.r, DefaultColor.XP_COLOR_FILLED.g, DefaultColor.XP_COLOR_FILLED.b)
end

function PlayerPetUnitFrame.OnLButtonDown()
    BroadcastEvent( SystemData.Events.TARGET_PET )
end
