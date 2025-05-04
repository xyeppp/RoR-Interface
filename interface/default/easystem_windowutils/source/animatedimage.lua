AnimatedImage = Frame:Subclass ()

function AnimatedImage:StartAnimation (startFrame, looping, hideWhenComplete, delayBeforeStart)
    self:Show (true, Frame.FORCE_OVERRIDE)
    
    AnimatedImageStartAnimation (self:GetName (), startFrame, looping, hideWhenComplete, delayBeforeStart)
    self.m_AnimationPlaying = true
end

function AnimatedImage:StopAnimation (forceHide)
    --[[
        Ideally, this could be relocated to Frame,
        and AnimatedImage could call superClass:StopAnimation...
    --]]
    
    if (forceHide == Frame.FORCE_HIDE)
    then
        self:Show (false, Frame.FORCE_OVERRIDE)
    end
    
    --[[
        This is the "virtual" functionality that is desired from AnimatedImage
    --]]
    if (self.m_AnimationPlaying == true)
    then
        AnimatedImageStopAnimation (self:GetName ())    
        self.m_AnimationPlaying = false
    end
end

function AnimatedImage:SetAnimationTexture (textureName)
    AnimatedImageSetTexture (self:GetName (), textureName)
end
