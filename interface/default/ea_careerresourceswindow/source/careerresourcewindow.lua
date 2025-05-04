----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

CareerResource = 
{
    m_CurrentDisplay    = {},
    m_ResourceFactory   = {},
    m_ActiveCareerLine  = 0,
}

----------------------------------------------------------------
-- Event Handlers
----------------------------------------------------------------

function CareerResource.Initialize ()
    RegisterEventHandler (SystemData.Events.PLAYER_CAREER_RESOURCE_UPDATED, "CareerResource.UpdateResourceDisplay")
end

function CareerResource.Shutdown ()
    UnregisterEventHandler (SystemData.Events.PLAYER_CAREER_RESOURCE_UPDATED, "CareerResource.UpdateResourceDisplay")
end

function CareerResource.UpdateResourceDisplay (previousResourceValue, currentResourceValue)
    local display = CareerResource.m_CurrentDisplay
    if ((display ~= nil) and (display.Update ~= nil))
    then
        display:UpdateResourceDisplay (previousResourceValue, currentResourceValue)
    end
end

function CareerResource.Update (timePassed)
    local display = CareerResource.m_CurrentDisplay
    if ((display ~= nil) and (display.Update ~= nil))
    then
        display:Update (timePassed)
    end
end

--[[
    All career resource displays will register themselves through this
    function so that they may be created on demand.
    resourceId is a careerline.
    resourceCreator is a table that knows how to create instances of itself
    through a function named Create.
--]]
function CareerResource:RegisterResource (resourceId, resourceCreator)
    self.m_ResourceFactory[resourceId] = resourceCreator    
end

function CareerResource:SpawnCareerWindow (careerWindowName)
    -- Only Update the UI if the active career has changed
    if (self.m_ActiveCareerLine ~= GameData.Player.career.line) 
    then
        self.m_ActiveCareerLine = GameData.Player.career.line    
        
        -- Destroy the old UI
        if (self.m_CurrentDisplay ~= nil) 
        then
            self:DespawnCurrentDisplay ()
        end

        -- Extract target window from settings table
        local factory = self.m_ResourceFactory[self.m_ActiveCareerLine]
        
        if ((factory ~= nil) and (factory.Create ~= nil))
        then            
            self.m_CurrentDisplay = factory:Create (careerWindowName)
        end
    end
end

function CareerResource:GetActiveCareerLine ()
    return self.m_ActiveCareerLine
end

function CareerResource:DespawnCurrentDisplay ()
    local display = self.m_CurrentDisplay

    if ((nil ~= display) and (nil ~= display.Destroy))
    then
        display:Destroy ()
        
        self.m_CurrentDisplay     = nil
        self.m_ActiveCareerLine   = 0
    end
end

function CareerResource:SetAnchor (anchor)    
    if (nil ~= self.m_CurrentDisplay) 
    then
        self.m_CurrentDisplay:SetAnchor (anchor)
    end
end

function CareerResource:GetCurrent ()    
    if ((nil ~= self.m_CurrentDisplay) and (nil ~= self.m_CurrentDisplay.GetCurrent))
    then
        return self.m_CurrentDisplay:GetCurrent ()
    end
        
    return 0
end

function CareerResource:GetMaximum ()
    if ((nil ~= self.m_CurrentDisplay) and (nil ~= self.m_CurrentDisplay.GetMaximum))
    then
        return self.m_CurrentDisplay:GetMaximum ()
    end
        
    return 0    
end

