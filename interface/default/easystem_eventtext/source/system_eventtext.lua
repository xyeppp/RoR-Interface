----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------
local CombatEventText =
{
    [ GameData.CombatEvent.HIT ]             = L"",
    [ GameData.CombatEvent.ABILITY_HIT ]     = L"",
    [ GameData.CombatEvent.CRITICAL ]        = L"",
    [ GameData.CombatEvent.ABILITY_CRITICAL] = L"",
    [ GameData.CombatEvent.BLOCK ]           = GetStringFromTable("CombatEvents", StringTables.CombatEvents.LABEL_BLOCK ),
    [ GameData.CombatEvent.PARRY ]           = GetStringFromTable("CombatEvents", StringTables.CombatEvents.LABEL_PARRY ),
    [ GameData.CombatEvent.EVADE]            = GetStringFromTable("CombatEvents", StringTables.CombatEvents.LABEL_EVADE ),
    [ GameData.CombatEvent.DISRUPT ]         = GetStringFromTable("CombatEvents", StringTables.CombatEvents.LABEL_DISRUPT ),
    [ GameData.CombatEvent.ABSORB ]          = GetStringFromTable("CombatEvents", StringTables.CombatEvents.LABEL_ABSORB ),
    [ GameData.CombatEvent.IMMUNE ]          = GetStringFromTable("CombatEvents", StringTables.CombatEvents.LABEL_IMMUNE ),
}

local DEFAULT_FRIENDLY_EVENT_ANIMATION_PARAMETERS = 
{
    start               = {x=-280, y=100},
    target              = {x=-280, y=20},
    current             = {x=-280, y=100},
    maximumDisplayTime  = 4,
    fadeDelay           = 2,
    fadeDuration        = 0.75,
}

local DEFAULT_HOSTILE_EVENT_ANIMATION_PARAMETERS = 
{
    start               = {x=-120, y=0},
    target              = {x=-120, y=-80},
    current             = {x=-120, y=0},
    maximumDisplayTime  = 4,
    fadeDelay           = 2,
    fadeDuration        = 0.75,
}

local DEFAULT_POINT_GAIN_EVENT_ANIMATION_PARAMETERS = 
{
    start               = {x=-200, y=-90},
    target              = {x=-200, y=-170},
    current             = {x=-200, y=-90},
    maximumDisplayTime  = 4,
    fadeDelay           = 2,
    fadeDuration        = 0.75,
}

local MINIMUM_EVENT_SPACING     = 36

local OWN_EVENT_SCALE_FACTOR    = 0.6
local OTHER_EVENT_SCALE_FACTOR  = 0.48
local CRITICAL_SCALE_FACTOR     = 1.0

local COMBAT_EVENT              = 1
local POINT_GAIN                = 2

local XP_GAIN                   = 1
local RENOWN_GAIN               = 2
local INFLUENCE_GAIN            = 3

----------------------------------------------------------------
-- Individual event displays.
----------------------------------------------------------------

EA_System_EventEntry = Frame:Subclass("EA_Window_EventTextLabel")

function EA_System_EventEntry:Create(windowName, parentWindow, animationData)
    local eventFrame = self:CreateFromTemplate(windowName, parentWindow)

    if (eventFrame ~= nil)
    then
        eventFrame.m_LifeSpan        = 0 -- Newly born        
        eventFrame.m_AnimationData   = {
                                            start               = {x=animationData.start.x,  y=animationData.start.y},
                                            target              = {x=animationData.target.x, y=animationData.target.y},
                                            current             = {x=animationData.start.x,  y=animationData.start.y},
                                            maximumDisplayTime  = animationData.maximumDisplayTime,
                                       }
    end

    WindowSetOffsetFromParent(windowName, animationData.start.x, animationData.start.y)

    return eventFrame
end

function EA_System_EventEntry:Update(elapsedTime, simulationSpeed)
    -- Update position and/or flag for destroying self
    local simulationTime = (elapsedTime * simulationSpeed)
    local animationStep  = simulationTime / self.m_AnimationData.maximumDisplayTime

    local stepX = (self.m_AnimationData.target.x - self.m_AnimationData.start.x) * animationStep
    local stepY = (self.m_AnimationData.target.y - self.m_AnimationData.start.y) * animationStep
    
    self.m_AnimationData.current.x = self.m_AnimationData.current.x + stepX
    self.m_AnimationData.current.y = self.m_AnimationData.current.y + stepY
    
    -- This system doesn't use the standard window animation system due to the speed-variable animations.
    WindowSetOffsetFromParent(self:GetName(), self.m_AnimationData.current.x, self.m_AnimationData.current.y)

    -- Return how long it has lived, including faster or slower than normal time.
    self.m_LifeSpan = self.m_LifeSpan + simulationTime
    
    return self.m_LifeSpan
end

function EA_System_EventEntry:SetupText(hitTargetObjectNumber, hitAmount, textType)
    local text = L""

    -- Sign-adjust healing vs. damage
    if ( ( textType == GameData.CombatEvent.HIT ) or 
         ( textType == GameData.CombatEvent.ABILITY_HIT ) or
         ( textType == GameData.CombatEvent.CRITICAL ) or
         ( textType == GameData.CombatEvent.ABILITY_CRITICAL ) )
    then
        if (hitAmount > 0)
        then
            text = L"+"..hitAmount
        else
            text = L""..hitAmount
        end
    else
        text = L""..CombatEventText[ textType ]
    end
    
    local scaling = OWN_EVENT_SCALE_FACTOR

    -- Denote critical hits
    if ( ( textType == GameData.CombatEvent.CRITICAL ) or
         ( textType == GameData.CombatEvent.ABILITY_CRITICAL ) )
    then
        scaling = CRITICAL_SCALE_FACTOR
        LabelSetFont( self:GetName(), "font_default_text_huge", WindowUtils.FONT_DEFAULT_TEXT_LINESPACING )  
    end
    
    local color = DefaultColor.GetCombatEventColor( hitTargetObjectNumber, hitAmount, textType )
    
    -- DEBUG(L" Frame "..StringToWString(self:GetName())..L" scaled to "..scaling)
    --     self:SetRelativeScale( scaling )
    LabelSetText( self:GetName(), text )
    LabelSetTextColor( self:GetName(), color.r, color.g, color.b )
    WindowSetFontAlpha( self:GetName(), 1.0 )
end

function EA_System_EventEntry:IsOutOfStartingBox()
    local isClear = (self.m_AnimationData.start.y - self.m_AnimationData.current.y) > MINIMUM_EVENT_SPACING
    return isClear
end

----------------------------------------------------------------
-- Individual event displays for advancement point gains.
----------------------------------------------------------------

EA_System_PointGainEntry = Frame:Subclass("EA_Window_EventTextLabel")

function EA_System_PointGainEntry:Create(windowName, parentWindow, animationData)
    local eventFrame = self:CreateFromTemplate(windowName, parentWindow)
    
    if (eventFrame ~= nil)
    then
        eventFrame.m_LifeSpan        = 0 -- Newly born        
        eventFrame.m_AnimationData   = {
                                            start               = {x=animationData.start.x,  y=animationData.start.y},
                                            target              = {x=animationData.target.x, y=animationData.target.y},
                                            current             = {x=animationData.start.x,  y=animationData.start.y},
                                            maximumDisplayTime  = animationData.maximumDisplayTime,
                                       }
    end

    WindowSetOffsetFromParent(windowName, animationData.start.x, animationData.start.y)
    
    return eventFrame
end

function EA_System_PointGainEntry:Update(elapsedTime, simulationSpeed)
    -- Update position and/or flag for destroying self
    local simulationTime = (elapsedTime * simulationSpeed)
    local animationStep  = simulationTime / self.m_AnimationData.maximumDisplayTime

    local stepX = (self.m_AnimationData.target.x - self.m_AnimationData.start.x) * animationStep
    local stepY = (self.m_AnimationData.target.y - self.m_AnimationData.start.y) * animationStep
    
    self.m_AnimationData.current.x = self.m_AnimationData.current.x + stepX
    self.m_AnimationData.current.y = self.m_AnimationData.current.y + stepY
    
    -- This system doesn't use the standard window animation system due to the speed-variable animations.
    WindowSetOffsetFromParent(self:GetName(), self.m_AnimationData.current.x, self.m_AnimationData.current.y)

    -- Return how long it has lived, including faster or slower than normal time.
    self.m_LifeSpan = self.m_LifeSpan + simulationTime
    
    return self.m_LifeSpan
end

function EA_System_PointGainEntry:SetupText(hitTargetObjectNumber, pointAmount, pointType)
    local text  = L""
    local color = { r=0, g=0, b=0, a=0 }

    text = L"+"..pointAmount
    
    if (pointType == XP_GAIN)
    then
        text    = GetFormatStringFromTable( "CombatEvents", StringTables.CombatEvents.LABEL_XP_POINT_GAIN, {pointAmount})
        color   = DefaultColor.COLOR_EXPERIENCE_GAIN
    elseif (pointType == RENOWN_GAIN)
    then
        text    = GetFormatStringFromTable( "CombatEvents", StringTables.CombatEvents.LABEL_RENOWN_POINT_GAIN, {pointAmount})
        color   = DefaultColor.COLOR_RENOWN_GAIN
    elseif (pointType == INFLUENCE_GAIN)
    then
        text    = GetFormatStringFromTable( "CombatEvents", StringTables.CombatEvents.LABEL_INFLUENCE_POINT_GAIN, {pointAmount})
        color   = DefaultColor.COLOR_INFLUENCE_GAIN
    end
    
    LabelSetText( self:GetName(), text )
    LabelSetTextColor( self:GetName(), color.r, color.g, color.b )
    WindowSetFontAlpha( self:GetName(), 1.0 )
end

function EA_System_PointGainEntry:IsOutOfStartingBox()
    local isClear = (self.m_AnimationData.start.y - self.m_AnimationData.current.y) > MINIMUM_EVENT_SPACING
    return isClear
end


----------------------------------------------------------------
-- A single event stream tracker
----------------------------------------------------------------
EA_System_EventTracker = {}
EA_System_EventTracker.__index = EA_System_EventTracker

function EA_System_EventTracker:Create(anchorWindowName, targetObjectNumber)

    local isPlayerTracker = (targetObjectNumber == GameData.Player.worldObjNum)
    local trackerAttachmentHeight = 1.0
    if (isPlayerTracker)
    then
        trackerAttachmentHeight = 0.3
    else
        trackerAttachmentHeight = 0.8
    end

    local newTracker =         
    {
        m_DisplayedEvents       = Queue:Create(),       -- Contains the tracked object's shown event data.
        m_PendingEvents         = Queue:Create(),       -- Contains the tracked object's pending event data.
        m_TargetObject          = targetObjectNumber,   -- World object this tracker relocates to.
        m_Anchor                = anchorWindowName,     -- Anchor window that will be the parent of all tracked events.
        m_MinimumScrollSpeed    = 1,                    -- The slowest speed at which displays are animated.
        m_MaximumScrollSpeed    = 20,                   -- The maximum speed at which displays are animated.
        m_CurrentScrollSpeed    = 1,                    -- The current animation speed applied to displayed events.
        m_ScrollAcceleration    = 0.1,                  -- The rate at which animation speed increases or decreases.

        -- if attached to the player, anchor relative to the feet.  if attached to something else, anchor near the shoulders
        m_AttachHeight          = trackerAttachmentHeight
    }

    newTracker = setmetatable(newTracker, self)
    newTracker.__index = self

    -- Have to use MoveWindowToWorldObject() like
    --   MoveWindowToWorldObject(self.m_Anchor, self.m_TargetObject, self.m_AttachHeight)
    --   if we want to have scaled attachment?  Or modify AttachWindowToWorldObject() at some point.
    AttachWindowToWorldObject(anchorWindowName, targetObjectNumber)

    return newTracker
end

function EA_System_EventTracker:Update( elapsedTime )

    local clearForPendingDispatch = true

    for index = self.m_DisplayedEvents:Begin(), self.m_DisplayedEvents:End()
    do
        -- Animate and/or decay each frame.
        local lifeElapsed = self.m_DisplayedEvents[index]:Update(elapsedTime, self.m_CurrentScrollSpeed)
        
        -- DEBUG(L" index = "..index..L". life = "..lifeElapsed)
        if ( (lifeElapsed > DEFAULT_FRIENDLY_EVENT_ANIMATION_PARAMETERS.maximumDisplayTime) and
             (index == self.m_DisplayedEvents:Begin()) )
        then
            local condemnedFrame = self.m_DisplayedEvents:PopFront()
            condemnedFrame:Destroy()

            -- don't allow creation to occur on the same frame as a destruction due to the queued window destruction
            clearForPendingDispatch = false
        -- Test if dispatch area is clear.
        elseif (not self.m_DisplayedEvents[index]:IsOutOfStartingBox())
        then
            clearForPendingDispatch = false
        end
    end


    -- If the pending events queue has events in it, check to see if there is room to display it
    if (not self.m_PendingEvents:IsEmpty())
    then
        -- If there is room, 
        if (clearForPendingDispatch)
        then
            -- If it is a combat event or just one xp/renown/influence event, move it from pending to displayed and spawn the frame
            local eventType = self.m_PendingEvents:Front().event
            if (eventType == COMBAT_EVENT)
            then
                local newEventWindowName = ""..self.m_Anchor.."Event"..self.m_DisplayedEvents:End()

                -- Huh, this window is still around?            
                if ( not DoesWindowExist(newEventWindowName) )
                then
                    local eventData          = self.m_PendingEvents:PopFront()
                    local animationData      = self:InitializeAnimationData(eventType)
                    
                    animationData.target.y   = animationData.target.y - ((self.m_PendingEvents:End() - self.m_PendingEvents:Begin() + 1) * MINIMUM_EVENT_SPACING )
                    
                    local newEventFrame      = EA_System_EventEntry:Create(newEventWindowName, self.m_Anchor, animationData)
                    newEventFrame:SetupText(self.m_TargetObject, eventData.amount, eventData.type)
                    WindowSetShowing( newEventFrame:GetName(), true )
                    WindowStartAlphaAnimation( newEventFrame:GetName(), Window.AnimationType.EASE_OUT,
                                               1, 0,
                                               animationData.fadeDuration, false, animationData.fadeDelay, 0 )

                    self.m_DisplayedEvents:PushBack(newEventFrame)
                end
            -- If there are a lot of xp/renown/influence events in a row, move them all from pending to displayed and trigger the spray feature
            else
                local newPointGainWindowName  = ""..self.m_Anchor.."PointGain"..self.m_DisplayedEvents:End()

                -- Huh, this window is still around?            
                if ( not DoesWindowExist(newPointGainWindowName) )
                then
                    local eventData          = self.m_PendingEvents:PopFront()
                    local animationData      = self:InitializeAnimationData(eventType)

                    -- Set up the spray effect.
                    local pendingQueueSize  = (self.m_PendingEvents:End() - self.m_PendingEvents:Begin() + 1)
                    animationData.target.x  = animationData.target.x +
                                              ( (math.pow(-1, pendingQueueSize)) *
                                                (pendingQueueSize * (MINIMUM_EVENT_SPACING / 2)) )
                                                
                    animationData.target.y  = animationData.target.y - ( pendingQueueSize * MINIMUM_EVENT_SPACING )


                    local newPointGainFrame = EA_System_PointGainEntry:Create(newPointGainWindowName, self.m_Anchor, animationData)
                    newPointGainFrame:SetupText(self.m_TargetObject, eventData.amount, eventData.type)
                    WindowSetShowing( newPointGainFrame:GetName(), true )
                    WindowStartAlphaAnimation( newPointGainFrame:GetName(), Window.AnimationType.EASE_OUT,
                                               1, 0,
                                               animationData.fadeDuration, false, animationData.fadeDelay, 0 )

                    self.m_DisplayedEvents:PushBack(newPointGainFrame)
                end
            end
        end
    end


    -- If the pending events queue is clear, decay the speed by the acceleration.
    if (self.m_PendingEvents:IsEmpty())
    then
        self.m_CurrentScrollSpeed = self.m_CurrentScrollSpeed - self.m_ScrollAcceleration
        
        if (self.m_CurrentScrollSpeed < self.m_MinimumScrollSpeed)
        then
            self.m_CurrentScrollSpeed = self.m_MinimumScrollSpeed
        end
    -- If there are still events in the pending queue, increase the speed by the acceleration.
    else
        self.m_CurrentScrollSpeed = self.m_CurrentScrollSpeed + self.m_ScrollAcceleration
        
        if (self.m_CurrentScrollSpeed > self.m_MaximumScrollSpeed)
        then
            self.m_CurrentScrollSpeed = self.m_MaximumScrollSpeed
        end
    end
end

function EA_System_EventTracker:InitializeAnimationData( displayType )
    local baseAnimation = DEFAULT_FRIENDLY_EVENT_ANIMATION_PARAMETERS
    
    if (displayType == COMBAT_EVENT)
    then
        if (self.m_TargetObject == GameData.Player.worldObjNum)
        then
            baseAnimation = DEFAULT_FRIENDLY_EVENT_ANIMATION_PARAMETERS
        else
            baseAnimation = DEFAULT_HOSTILE_EVENT_ANIMATION_PARAMETERS
        end
    else
        baseAnimation = DEFAULT_POINT_GAIN_EVENT_ANIMATION_PARAMETERS
    end
    
    local animationData = {
                            start               = {x=baseAnimation.start.x,  y=baseAnimation.start.y},
                            target              = {x=baseAnimation.target.x, y=baseAnimation.target.y},
                            current             = {x=baseAnimation.start.x,  y=baseAnimation.start.y},
                            maximumDisplayTime  = baseAnimation.maximumDisplayTime,
                            fadeDelay           = baseAnimation.fadeDelay,
                            fadeDuration        = baseAnimation.fadeDuration,
                          }
    
    return animationData
end        

function EA_System_EventTracker:AddEvent(eventData)
    self.m_PendingEvents:PushBack(eventData)
end

function EA_System_EventTracker:Destroy()

    -- Destroy all displayed frames
    while (self.m_DisplayedEvents:Front() ~= nil)
    do
        self.m_DisplayedEvents:PopFront():Destroy()
    end

    -- Destroy anchor window.
    DetachWindowFromWorldObject( self.m_Anchor, self.m_TargetObject )
    DestroyWindow( self.m_Anchor )

end

----------------------------------------------------------------
-- The event display dispatcher factory
----------------------------------------------------------------
EA_System_EventText =
{
    EventTrackers = {}
}

function EA_System_EventText.Initialize()
    RegisterEventHandler( SystemData.Events.WORLD_OBJ_COMBAT_EVENT,     "EA_System_EventText.AddCombatEventText")
    RegisterEventHandler( SystemData.Events.WORLD_OBJ_XP_GAINED,        "EA_System_EventText.AddXpText"         )
    RegisterEventHandler( SystemData.Events.WORLD_OBJ_RENOWN_GAINED,    "EA_System_EventText.AddRenownText"     )
    RegisterEventHandler( SystemData.Events.WORLD_OBJ_INFLUENCE_GAINED, "EA_System_EventText.AddInfluenceText"  )
    RegisterEventHandler( SystemData.Events.LOADING_BEGIN,              "EA_System_EventText.BeginLoading"      )
    RegisterEventHandler( SystemData.Events.LOADING_END,                "EA_System_EventText.EndLoading"        )

    local uiScale = InterfaceCore.GetScale()
end

function EA_System_EventText.Shutdown()
    UnregisterEventHandler( SystemData.Events.LOADING_END,                  "EA_System_EventText.EndLoading"        )
    UnregisterEventHandler( SystemData.Events.LOADING_BEGIN,                "EA_System_EventText.BeginLoading"      )
    UnregisterEventHandler( SystemData.Events.WORLD_OBJ_INFLUENCE_GAINED,   "EA_System_EventText.AddInfluenceText"  )
    UnregisterEventHandler( SystemData.Events.WORLD_OBJ_RENOWN_GAINED,      "EA_System_EventText.AddRenownText"     )
    UnregisterEventHandler( SystemData.Events.WORLD_OBJ_XP_GAINED,          "EA_System_EventText.AddXpText"         )
    UnregisterEventHandler( SystemData.Events.WORLD_OBJ_COMBAT_EVENT,       "EA_System_EventText.AddCombatEventText")
    
    -- Kill any windows that are still around
    for _, eventTracker in pairs(EA_System_EventText.EventTrackers)
    do
        eventTracker:Destroy()
    end
    EA_System_EventText.EventTrackers = {}
end

function EA_System_EventText.Update( timePassed )
    if( EA_System_EventText.loading or ( DoesWindowExist( "LoadingWindow" ) and WindowGetShowing( "LoadingWindow" ) ) )
    then
        return
    end
    
    for index, eventTracker in pairs(EA_System_EventText.EventTrackers)
    do
        eventTracker:Update( timePassed )
        if ( eventTracker.m_DisplayedEvents:Front() == nil and
             eventTracker.m_PendingEvents:Front() == nil and
             not GameData.Player.inCombat )
        then
            eventTracker:Destroy( )
            EA_System_EventText.EventTrackers[ index ] = nil
        end
    end
end

function EA_System_EventText.BeginLoading()
    EA_System_EventText.loading = true
end

function EA_System_EventText.EndLoading()
    EA_System_EventText.loading = false
end

function EA_System_EventText.AddCombatEventText( hitTargetObjectNumber, hitAmount, textType )
    local eventData = { event=COMBAT_EVENT, amount = hitAmount, type = textType }

    if (EA_System_EventText.EventTrackers[hitTargetObjectNumber] == nil)
    then
        local newTrackerAnchorWindowName = "EA_System_EventTextAnchor"..hitTargetObjectNumber
        CreateWindowFromTemplate(newTrackerAnchorWindowName, "EA_Window_EventTextAnchor", "EA_Window_EventTextContainer")
        EA_System_EventText.EventTrackers[hitTargetObjectNumber] = EA_System_EventTracker:Create(newTrackerAnchorWindowName, hitTargetObjectNumber)
    end

    EA_System_EventText.EventTrackers[hitTargetObjectNumber]:AddEvent(eventData)
end

function EA_System_EventText.AddXpText( hitTargetObjectNumber, pointsGained )
    local pointGainData = { event = POINT_GAIN, amount = pointsGained, type = XP_GAIN }
    EA_System_EventText.AddPointGain( hitTargetObjectNumber, pointGainData )
end

function EA_System_EventText.AddRenownText( hitTargetObjectNumber, pointsGained )
    local pointGainData = { event = POINT_GAIN, amount = pointsGained, type = RENOWN_GAIN }
    EA_System_EventText.AddPointGain( hitTargetObjectNumber, pointGainData )
end

function EA_System_EventText.AddInfluenceText( hitTargetObjectNumber, pointsGained )
    local pointGainData = { event = POINT_GAIN, amount = pointsGained, type = INFLUENCE_GAIN }
    EA_System_EventText.AddPointGain( hitTargetObjectNumber, pointGainData )
end

function EA_System_EventText.AddPointGain( hitTargetObjectNumber, pointGainData )
    if (EA_System_EventText.EventTrackers[hitTargetObjectNumber] == nil)
    then
        local newTrackerAnchorWindowName = "EA_System_EventTextAnchor"..hitTargetObjectNumber
        CreateWindowFromTemplate(newTrackerAnchorWindowName, "EA_Window_EventTextAnchor", "EA_Window_EventTextContainer")
        EA_System_EventText.EventTrackers[hitTargetObjectNumber] = EA_System_EventTracker:Create(newTrackerAnchorWindowName, hitTargetObjectNumber)
    end

    EA_System_EventText.EventTrackers[hitTargetObjectNumber]:AddEvent(pointGainData)
end
