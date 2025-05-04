----------------------------------------------------------------
-- Local Data
----------------------------------------------------------------

local c_PLAY_MORALE_SOUNDS      = true
local g_playedASoundThisUpdate  = false
local g_InEditMode              = false
local g_MoraleBar               = nil

local TRANSITION_FROM_DOT_TO_FULL   = 1 -- Transition from dot to full image
local TRANSITION_FROM_FULL_TO_DOT   = 2 -- Transition from full image to dot
local TRANSITION_STATE_FULL         = 3 -- Currently showing full icon, dot is hidden, all transitioning is complete
local TRANSITION_STATE_DOT          = 4 -- Currently showing dot, full icon is hidden, all transitioning is complete

local TRANSITION_DURATION_IN_SECONDS    = .5
local TRANSITION_DELAY_IN_SECONDS       = .2
local TOTAL_TRANSITION_TIME             = TRANSITION_DELAY_IN_SECONDS + TRANSITION_DURATION_IN_SECONDS
local IS_ENABLED_POLLING_FREQUENCY      = .1 -- Enabled/TargetValid polling freqency, check every tenth of a second.

local FLASH_ANIM        = 0
local GLOW_ANIM         = 1
local BASE_ICON         = 2
local TEXT_LABEL        = 3
local COOLDOWN          = 4
local COOLDOWN_LABEL    = 5
local DOT               = 6
local RECHARGE_ANIM     = 7


local LARGE_BUTTON_OFFSET_KEY   = 1
local MINI_BUTTON_OFFSET_KEY    = 2

local MoraleButtonOffsets =
{
    { xoffs = 51,   yoffs = -10 }, 
    { xoffs = 115,  yoffs = -10 }, 
    { xoffs = 181,  yoffs = -15 }, 
    { xoffs = 249,  yoffs = -19 }, 
}

-- From the "bottom", "bottom" point of the actual Morale Button
local MoraleDotOffsets =
{
    { xoffs = 0,    yoffs = 10 }, 
    { xoffs = 2,    yoffs = 10 }, 
    { xoffs = -1,   yoffs = 10 },
    { xoffs = -1,   yoffs = 10 }, 
}


----------------------------------------------------------------
-- MoraleSlottedIndicator (the small gold dot)
----------------------------------------------------------------

MoraleSlottedIndicator = DynamicImage:Subclass ("MoraleSlottedIndicator")

function MoraleSlottedIndicator:Create (windowName, parentMoraleButton, parentMoraleBar)
    local frame = self:CreateFromTemplate (windowName, parentMoraleBar)
    
    if (frame)
    then
        frame.m_MoraleButton = parentMoraleButton
        
        local level = parentMoraleButton:GetLevel ()
        
        frame:SetAnchor ({ Point = "bottom", RelativePoint = "bottom", RelativeTo = parentMoraleButton:GetName (), XOffset = MoraleDotOffsets[level].xoffs, YOffset = MoraleDotOffsets[level].yoffs})
    end
    
    return frame
end

function MoraleSlottedIndicator:OnMouseOver (flags, x, y)
    --if (self.m_MoraleButton.m_TransitionState == TRANSITION_STATE_DOT)
    --then
    --    self.m_MoraleButton:ResetTransitionState (TRANSITION_STATE_FULL)
    --else
        self.m_MoraleButton:DoActivationTransition (TRANSITION_FROM_DOT_TO_FULL)
    --end
end

function MoraleSlottedIndicator:OnMouseOverEnd (flags, x, y)
    self.m_MoraleButton:DoActivationTransition (TRANSITION_FROM_FULL_TO_DOT)
end

----------------------------------------------------------------
-- MoraleButton
----------------------------------------------------------------

MoraleButton = Frame:Subclass ("EA_MoraleAbilityButton")

function MoraleButton:Create (windowName, parentName, moraleLevel)
    local moraleButton = self:CreateFromTemplate (windowName, parentName)
    
    local anchor = {}
    
    if (moraleButton ~= nil)
    then
        moraleButton.m_MoraleLevel      = moraleLevel
        moraleButton.m_AbilityId        = 0
        moraleButton.m_Cooldown         = 0
        moraleButton.m_TransitionState  = TRANSITION_STATE_DOT
        moraleButton.m_TransitionTimer  = 0 -- until windows can hide themselves after alpha anims...
        moraleButton.m_PollTimer        = 0
        moraleButton.m_IsTargetValid    = true
                
        moraleButton.m_Windows =
        {
            [FLASH_ANIM]        = AnimatedImage:CreateFrameForExistingWindow (windowName.."FlashAnim"),
            [GLOW_ANIM]         = AnimatedImage:CreateFrameForExistingWindow (windowName.."GlowAnim"),
            [BASE_ICON]         = DynamicImage:CreateFrameForExistingWindow (windowName.."Icon"),
            [TEXT_LABEL]        = Label:CreateFrameForExistingWindow (windowName.."Text"),
            [COOLDOWN]          = Frame:CreateFrameForExistingWindow (windowName.."Cooldown"),
            [COOLDOWN_LABEL]    = Label:CreateFrameForExistingWindow (windowName.."CooldownTimer"),
            [RECHARGE_ANIM]     = AnimatedImage:CreateFrameForExistingWindow (windowName.."RechargeAnim"),
            -- moraleButton is NOT the Dot's parent!
            [DOT]               = MoraleSlottedIndicator:Create (windowName.."Dot", moraleButton, parentName), 
        }
        
        moraleButton.m_Windows[FLASH_ANIM]:Show (false)
        moraleButton.m_Windows[RECHARGE_ANIM]:Show (false)
        moraleButton.m_Windows[GLOW_ANIM]:Show (false)
        moraleButton.m_Windows[TEXT_LABEL]:Show (true)
        moraleButton.m_Windows[TEXT_LABEL]:SetText (L"*")
        moraleButton.m_Windows[COOLDOWN]:Show (false)
        moraleButton.m_Windows[COOLDOWN]:SetTint (DefaultColor.ActionCooldown)
        moraleButton.m_Windows[COOLDOWN]:SetAlpha (DefaultColor.ActionCooldown.a)
        moraleButton.m_Windows[DOT]:Show (false)
        
        -- Bind the action buttons to the hotkey keyboard events.       
        local actionTrigger = SystemData.Settings.Keybindings.MORALE_BAR_1.id + moraleLevel - 1
        WindowSetGameActionTrigger (moraleButton:GetName (), actionTrigger)
        
        anchor =
        {
            Point           = "bottomleft",
            RelativePoint   = "bottomleft",
            RelativeTo      = parentName,
            XOffset         = MoraleButtonOffsets[moraleLevel].xoffs,
            YOffset         = MoraleButtonOffsets[moraleLevel].yoffs,
        }
        
        moraleButton:SetAnchor (anchor)
        moraleButton:Show (false)
    end
    
    return moraleButton
end

function MoraleButton:GetLevel ()
    return self.m_MoraleLevel
end

function MoraleButton:SetAbility (abilityId)
    self.m_AbilityId = abilityId
    WindowSetGameActionData (self:GetName (), GameData.PlayerActions.DO_ABILITY, abilityId, L"")
    
    if (abilityId == 0)
    then
        self.m_Windows[DOT]:Show (false)
    end
    
    self:UpdateCooldown (0, true)
end

function MoraleButton:SetIcon( iconNum, isEnabled, isBlocked )
    local texture           = L""
    local disabledTexture   = L""
    local x                 = 0
    local y                 = 0
    
    self.m_IconNum = iconNum
    
    local iconWindowName = self.m_Windows[BASE_ICON]:GetName ()
    
    if (iconNum > 0)
    then
        if( self.m_IsEnabled ~= isEnabled or self.m_IsBlocked ~= isBlocked )
        then
            texture, x, y, disabledTexture = GetIconData (iconNum)
            
            if( ( not isEnabled ) and (disabledTexture ~= "") and ( not isBlocked ) )
            then
                texture = disabledTexture
            end

            self.m_IsEnabled = isEnabled
            CircleImageSetTexture (iconWindowName, texture, 32, 32)
			
			self.m_IsBlocked = isBlocked
			
			local tint
			if( self.m_IsBlocked )
			then
				tint = DefaultColor.RED
			else
				tint = DefaultColor.ZERO_TINT
			end
			WindowSetTintColor( self:GetName(), tint.r, tint.g, tint.b )
        end
    else
        self.m_IsEnabled = nil
        CircleImageSetTexture (iconWindowName, "", 0, 0)
        CooldownDisplaySetCooldown (self.m_Windows[COOLDOWN]:GetName (), 0, 0)
        self.m_Windows[RECHARGE_ANIM]:StopAnimation (Frame.FORCE_HIDE)
        self.m_Windows[COOLDOWN]:Show (false)
		if( self.m_IsBlocked ~= isBlocked )
		then
			self.m_IsBlocked = isBlocked
			local tint = DefaultColor.ZERO_TINT
			WindowSetTintColor( self:GetName(), tint.r, tint.g, tint.b )
		end
    end
end

function MoraleButton:TransitionFromFullToDot ()
    self.m_TransitionState = TRANSITION_STATE_DOT
    self.m_TransitionTimer = 0
    
    self:StartAlphaAnimation (Window.AnimationType.SINGLE_NO_RESET, 1, 0, TRANSITION_DURATION_IN_SECONDS, TRANSITION_DELAY_IN_SECONDS, 0)
end

function MoraleButton:TransitionFromDotToFull ()
    self.m_TransitionState = TRANSITION_STATE_FULL        
    self.m_TransitionTimer = 0
    self:StartAlphaAnimation (Window.AnimationType.SINGLE_NO_RESET, 0, 1, TRANSITION_DURATION_IN_SECONDS, 0, 0)
end

function MoraleButton:UpdateTransitionTimer (timeElapsed)
    self.m_TransitionTimer = self.m_TransitionTimer + timeElapsed
    
    if (self.m_TransitionTimer >= TOTAL_TRANSITION_TIME)
    then
        self.m_Windows[DOT]:Show (self.m_AbilityId > 0)
        self:Show (self.m_TransitionState == TRANSITION_STATE_FULL)
        self:StopAlphaAnimation ()
                
        self.m_TransitionTimer = 0
    end
end

function MoraleButton:ResetTransitionState (resetStateType)
    self.m_TransitionState = resetStateType
    self.m_TransitionTimer = TOTAL_TRANSITION_TIME    
    self:UpdateTransitionTimer (0)
end

function MoraleButton:DoActivationTransition (transitionType)
    if (self.m_AbilityId == 0)
    then
        if ((g_InEditMode == true) and (self.m_TransitionState == TRANSITION_STATE_DOT))
        then
            self:TransitionFromDotToFull ()
        elseif ((g_InEditMode == false) and (self.m_TransitionState == TRANSITION_STATE_FULL))
        then
            self:TransitionFromFullToDot ()
        end
    elseif (self.m_AbilityId > 0)
    then
        if 
        (
            (transitionType == TRANSITION_FROM_DOT_TO_FULL) and 
            (self.m_TransitionState == TRANSITION_STATE_DOT)
        )
        then
            self:TransitionFromDotToFull ()
        elseif 
        (
            (transitionType == TRANSITION_FROM_FULL_TO_DOT)         and 
            (self.m_TransitionState == TRANSITION_STATE_FULL)       and 
            (g_InEditMode == false)                                 and
            (g_MoraleBar and g_MoraleBar.m_CurrentMoraleLevel < self.m_MoraleLevel)
        )
        then
            self:TransitionFromFullToDot ()
        end
    end
end

function MoraleButton:UpdateActiveState (prevMoraleLevel, currentMoraleLevel)
    local soundId = nil
    
    local selfLevel, selfAbility = self.m_MoraleLevel, self.m_AbilityId
        
    if ((prevMoraleLevel < selfLevel) and (currentMoraleLevel >= selfLevel) and (selfAbility ~= 0))
    then
        self:DoActivationTransition (TRANSITION_FROM_DOT_TO_FULL)
        
        self.m_Windows[FLASH_ANIM]:StartAnimation (0, Frame.ONESHOT_ANIM, Frame.HIDE_ON_FINISH, 0)
        self.m_Windows[GLOW_ANIM]:StartAnimation (0, Frame.LOOPING_ANIM, Frame.SHOWN_ON_FINISH, 0)
        self.m_Windows[GLOW_ANIM]:StartAlphaAnimation (Window.AnimationType.SINGLE, 0.0, 1.0, 1.0, 0, 0)

        soundId = Sound.MORALE_LEVEL_UP

    -- If we are disabling the ability, clear the animations
    elseif ((prevMoraleLevel >= selfLevel) and (currentMoraleLevel < selfLevel)) 
    then
        self:DoActivationTransition (TRANSITION_FROM_FULL_TO_DOT)
        
        self.m_Windows[FLASH_ANIM]:StopAnimation (Frame.FORCE_HIDE)
        self.m_Windows[GLOW_ANIM]:StopAnimation (Frame.FORCE_HIDE)
        
        if (selfAbility ~= 0)
        then
            soundId = Sound.MORALE_LEVEL_DOWN
        end
    end
    
    if ((c_PLAY_MORALE_SOUNDS == true) and (selfAbility ~= 0))
    then
        if ((soundId ~= nil) and (g_playedASoundThisUpdate == false))
        then
            Sound.Play (soundId)
            g_playedASoundThisUpdate = true
        end
    end
end

-- TODO: This stuff all needs to get folded into the hotbar system
-- Morale system already has a dependency on EA_ActionBars, so the use of ActionButton and ActionBars should be ok.
function MoraleButton:UpdateCooldown (timeElapsed, updateCooldown)
    local cooldownFrame     = self.m_Windows[COOLDOWN]
    local timerFrame        = self.m_Windows[COOLDOWN_LABEL]

    if (updateCooldown)
    then
        local oldCooldown = self.m_Cooldown
        
        self.m_Cooldown, self.m_MaxCooldown = GetMoraleCooldown (self.m_MoraleLevel)
        
        -- This check fixes the problem where two cooldowns broadcast in a very short time period would
        -- end up resetting the cooldown display.
        if (oldCooldown and math.abs (oldCooldown - self.m_Cooldown) > ActionButton.IGNORE_COOLDOWN_DELTA_THRESHOLD)
        then
            cooldownFrame:Show (true)
            CooldownDisplaySetCooldown (cooldownFrame:GetName (), self.m_Cooldown, self.m_MaxCooldown)
            
            -- No longer showing the cooldown text at all if the cooldown is from a global cooldown.
            -- Just show the radial animation
            if (EA_ActionBars_Settings.showCooldownText)
            then
                timerFrame:Show (self.m_MaxCooldown > ActionButton.GLOBAL_COOLDOWN)
            else
                timerFrame:Show (false)
            end
        end
    end
    
    local oldTime = 0

    if (self.m_Cooldown > 0)
    then
        oldTime         = TimeUtils.FormatRoundedSeconds (self.m_Cooldown, ActionButton.COOLDOWN_GRANULARITY, false)
        self.m_Cooldown = self.m_Cooldown - timeElapsed
    end
    
    if ((self.m_Cooldown > 0) and (self.m_MaxCooldown > 0))
    then 
        local updateLabel = false
        
        if (TimeUtils.FormatRoundedSeconds (self.m_Cooldown, ActionButton.COOLDOWN_GRANULARITY, false) < oldTime)
        then
            updateLabel = true
        end
        
        if (timerFrame:IsShowing () and (updateLabel or updateCooldown))
        then
            local labelTime
            
            -- The 3 seconds is arbitrary, this just says don't display values like 15.8
            -- only start the fractional cooldown at FRACTIONAL_COOLDOWN_BEGIN seconds or less (3.0, 2.5, etc...)
            if (self.m_Cooldown < ActionButton.FRACTIONAL_COOLDOWN_BEGIN)
            then
                labelTime = TimeUtils.FormatRoundedSeconds(self.m_Cooldown, ActionButton.COOLDOWN_GRANULARITY, true)
            else
                labelTime = TimeUtils.FormatSeconds(self.m_Cooldown, true)
            end
            
            timerFrame:SetText (labelTime)
        end
    elseif (self.m_Cooldown <= 0 and cooldownFrame:IsShowing ())
    then
        cooldownFrame:Show (false)
        
        self.m_Cooldown     = 0
        self.m_MaxCooldown  = 0
        
        self.m_Windows[RECHARGE_ANIM]:StartAnimation (0, false, true, 0)
    end
end

-- 
-- (Permanently) shows or hides the cooldown text label timer depending on the action bar's custom settings.
-- This setting is global over all morale buttons.
--
function MoraleButton:UpdateShowCooldownText ()
    self.m_Windows[COOLDOWN_LABEL]:Show (EA_ActionBars_Settings.showCooldownText)
end

function MoraleButton:Update (timeElapsed)   
    self:UpdateTransitionTimer (timeElapsed)
    
    if (self.m_AbilityId ~= 0)
    then
        self:UpdateCooldown (timeElapsed, MoraleSystem.needsCooldownUpdate)    
    end
        
    -- TODO:
    -- As much as I would love to skip enabled stuff for now...
    -- I have to put this in so the TR doesn't fail and so this CL can move on to Beta.
    -- (when the morale abilities live on the "hotbar", we get this update for free!)
    
    self.m_PollTimer = self.m_PollTimer + timeElapsed
    
    local abilityId = self.m_AbilityId
    
    if ((abilityId > 0) and (self.m_PollTimer >= IS_ENABLED_POLLING_FREQUENCY))
    then
		local isBlocked = Player.IsAbilityBlocked( abilityId, GameData.AbilityType.MORALE )
        self:SetIcon( self.m_IconNum, IsAbilityEnabled( abilityId ), isBlocked )
        
        local isTargetValid, hasRequiredUnitTypeTargeted = IsTargetValid (abilityId)
        
        local isTargetValid = (isTargetValid or (hasRequiredUnitTypeTargeted == false))
        
        if (isTargetValid ~= self.m_IsTargetValid)
        then
            self.m_IsTargetValid = isTargetValid
            
            if (isTargetValid)
            then
                self.m_Windows[TEXT_LABEL]:SetTextColor (255, 255, 255)
            else
                self.m_Windows[TEXT_LABEL]:SetTextColor (255, 0, 0)
            end
        end
    end    
end

-- TODO: Using a static anchor so that rank 4 morale abilities do not slide off the screen.
-- The real fix would resize the ability tooltip window to fit the bounds of the tooltip, and then
-- the anchoring would actually work.  But there's no time for that now.

local moraleTooltipAnchor = {}

moraleTooltipAnchor = { Point = "bottomright",  RelativeTo = "Root", RelativePoint = "bottomright",   XOffset = -420, YOffset = -250}

function MoraleButton:OnMouseOver (flags, x, y)    
    local selfLevel, selfAbility = self.m_MoraleLevel, self.m_AbilityId
    
    self:ResetTransitionState (TRANSITION_STATE_FULL)
    
    local anchor = nil
    if( DoesWindowExist( "MouseOverTargetWindow" ) and SystemData.Settings.GamePlay.staticAbilityTooltipPlacement )
    then
        anchor = Tooltips.ANCHOR_MOUSE_OVER_TARGET_WINDOW
    else
        anchor = moraleTooltipAnchor
    end
    
    if (selfAbility == 0) 
    then
        Tooltips.CreateTextOnlyTooltip (self:GetName (), GetStringFormat (StringTables.Default.TEXT_X_MORALE_SLOT, { selfLevel }))
        Tooltips.Finalize ()
        Tooltips.AnchorTooltip (anchor)
    else    
        local abilityData = Player.GetAbilityData (selfAbility, Player.AbilityType.MORALE)
		
		local text = GetString (StringTables.Default.TEXT_SHIFT_R_CLICK_TO_REMOVE)
		-- Override the interaction text if the ability is blocked
		if( abilityData and Player.IsAbilityBlocked( abilityData.id, abilityData.abilityType ))
		then
			text = GetString( StringTables.Default.TEXT_BLOCKED_ABILITY_DESC )
		end
		
        Tooltips.CreateAbilityTooltip( abilityData, self:GetName (), anchor, text )
    end
end

function MoraleButton:OnMouseOverEnd (flags, x, y)    
    self:DoActivationTransition (TRANSITION_FROM_FULL_TO_DOT)
end

function MoraleButton:OnLButtonDown (flags, x, y)
    if (Cursor.IconOnCursor ())
    then
        local slotType = nil
        
        -- Hmm, SOURCE_MORALE_LIST doesn't appear to ever be used
        if (Cursor.Data.Source ~= Cursor.SOURCE_ACTION_LIST and Cursor.Data.Source ~= Cursor.SOURCE_MORALE_LIST) 
        then
            return
        end
        
        -- Only morale abilities can be dropped on the morale bar
        local abilityData = Player.GetAbilityData (Cursor.Data.ObjectId)
                        
        if (abilityData.numTacticSlots > 0) 
        then
            AlertTextWindow.AddLine (SystemData.AlertText.Types.DEFAULT, GetString (StringTables.Default.TEXT_TACTIC_DROP_ERROR))
            return
        end     
        if (abilityData.moraleLevel == 0) 
        then
            AlertTextWindow.AddLine (SystemData.AlertText.Types.DEFAULT, GetString (StringTables.Default.TEXT_ACTION_DROP_ERROR))
            return
        end        
        
        if (abilityData.moraleLevel ~= self.m_MoraleLevel) 
        then
            AlertTextWindow.AddLine (SystemData.AlertText.Types.DEFAULT, GetStringFormat (StringTables.Default.TEXT_ABILITY_REQUIRES_MORALE, { abilityData.moraleLevel }))
            return
        end
        
        SetMoraleBarData (self.m_MoraleLevel, Cursor.Data.ObjectId)
        -- MoraleWindow.OnMoraleButtonMouseover()  -- leave this out for now...see how it works
    end
end

function MoraleButton:OnRButtonDown (flags, x, y)
    if (flags == SystemData.ButtonFlags.SHIFT) 
    then
        SetMoraleBarData (self.m_MoraleLevel, 0)
    end
end

----------------------------------------------------------------
-- MoraleBar
----------------------------------------------------------------

MoraleBar = FrameForLayoutEditor:Subclass ("EA_MoraleWindow")

local MORALE_PERCENT_MAX = 100

function MoraleBar:Create (windowName)
    local moraleBar = self:CreateFromTemplate (windowName)
    
    if (moraleBar ~= nil)
    then
        moraleBar.m_PreviousMoraleLevel = 0
        moraleBar.m_CurrentMoraleLevel  = 0
        moraleBar.m_ShowingEmptySlots   = false
        moraleBar.m_ShowGainedMorale    = true
        moraleBar.m_Buttons             = {}
        moraleBar.m_PercentagesForLevel = {}    -- Input arguments to the status bar fill function
        moraleBar.m_FillAmountsForLevel = {}    -- Ouput values for the status bar fill function
                
        for level = 1, GameData.NUM_MORALE_LEVELS
        do
            moraleBar.m_Buttons[level]              = MoraleButton:Create (windowName.."ContentsButton"..level, windowName.."Contents", level)
            moraleBar.m_PercentagesForLevel[level]  = GetMoralePercentForLevel (level)
            moraleBar.m_FillAmountsForLevel[level]  = (MORALE_PERCENT_MAX / GameData.NUM_MORALE_LEVELS) * level
        end
        
        moraleBar.m_StatusBar = Frame:CreateFrameForExistingWindow (windowName.."ContentsStatus")
        StatusBarSetMaximumValue (moraleBar.m_StatusBar:GetName (), 100)
        moraleBar:Show (true)
    end
    
    MoraleSystem.UpdateTutorial()  
    
    return moraleBar
end

function MoraleBar:Update (timePassed)
    for _, buttonFrame in ipairs (self.m_Buttons) 
    do 
        buttonFrame:Update (timePassed)
    end
end

function MoraleBar:DoActivationTransition (transitionState)
    for _, buttonFrame in ipairs (self.m_Buttons) 
    do 
        buttonFrame:DoActivationTransition (transitionState)
    end
end

function MoraleBar:UpdateButtons ()
    local hasAnyMoraleAbilitiesSlotted = false
    
    for _, buttonFrame in ipairs (self.m_Buttons)
    do
        local _, abilityId = GetMoraleBarData (buttonFrame:GetLevel ())
        local abilityWasJustSlotted = false
        
        if (abilityId and abilityId > 0)
        then
            hasAnyMoraleAbilitiesSlotted = true
        end
        
        -- If this is true, then it's a good indication that the player was swapping 
        -- or adding morale abilities...(note: this is one of the issues that's causing
        -- interface lag when updating morale abilities...waiting for server respose
        -- before dropping the icon off the cursor.)
        if (Cursor.IconOnCursor () and Cursor.Data.ObjectId == abilityId) then
            Cursor.Drop (nil)
            abilityWasJustSlotted = true
        end
        
        -- Kill this off, you can get the icon from GetHotbarIcon when the morale is living on the hotbar
        local abilityData = nil
        if( abilityId ~= 0 ) then
            abilityData = Player.GetAbilityData (abilityId, Player.AbilityType.MORALE);
        end
        
        if (abilityData ~= nil)
        then
			local isBlocked = Player.IsAbilityBlocked( abilityId, GameData.AbilityType.MORALE )
            buttonFrame:SetIcon( abilityData.iconNum, true, isBlocked )
            buttonFrame:SetAbility (abilityId)
            
            -- Force the animation to begin if this ability was just dropped in this slot..
            -- Passing in 0 for the lastMoraleValue makes it seem like the morale hasn't been
            -- updated yet, so the animation is forced to turn on.
            -- The state animations will get handled next time the morale is updated.
            if (abilityWasJustSlotted == true) 
            then
                buttonFrame:UpdateActiveState (0, GetPlayerMoraleLevel ())
            end
        else
            buttonFrame:SetIcon( 0, false, false )
            buttonFrame:SetAbility (0)
            
            -- If the slot is empty, then force the morale animation to turn off
            buttonFrame:UpdateActiveState (GameData.NUM_MORALE_LEVELS, 0)
        end
        
        buttonFrame:Show ((abilityId ~= 0) or self.m_ShowingEmptySlots)
    end
    
    self:ShowGainedMorale (hasAnyMoraleAbilitiesSlotted)
   
    MoraleSystem.UpdateTutorial() 
end

function MoraleBar:UpdateShowCooldownText ()
    for _, buttonFrame in ipairs (self.m_Buttons)
    do
        buttonFrame:UpdateShowCooldownText ()
    end    
end

function MoraleBar:ShowGainedMorale (show)
    self.m_ShowGainedMorale = show
    
    if (show == false)
    then
        StatusBarSetCurrentValue (self.m_StatusBar:GetName (), 0)
    end
end

function MoraleBar:SetMorale (moralePercent, moraleLevel)   
    self.m_CurrentMoraleLevel = moraleLevel
        
    -- Yes, this could be solved with a spline, no I'm not going to write a solver...yes, it's because I lack that knowledge.
    local fillAmount = 0
    
    -- cache tables
    local percentForLevel   = self.m_PercentagesForLevel
    local fillForLevel      = self.m_FillAmountsForLevel
    
    if (moraleLevel == 0)
    then
        fillAmount = fillForLevel[1] * (moralePercent / percentForLevel[1])
    elseif (moraleLevel == GameData.NUM_MORALE_LEVELS)
    then
        fillAmount = MORALE_PERCENT_MAX
    else
        for testLevel = 1, GameData.NUM_MORALE_LEVELS
        do
            if (percentForLevel[testLevel] <= moralePercent)
            then
                fillAmount = fillForLevel[testLevel]
            else
                local fillDistanceForCurrentLevel = fillForLevel[testLevel] - fillForLevel[moraleLevel]
                local percentThroughCurrentLevel = (moralePercent - percentForLevel[moraleLevel]) / (percentForLevel[testLevel] - percentForLevel[moraleLevel])
            
                fillAmount = fillAmount + (percentThroughCurrentLevel * fillDistanceForCurrentLevel)
                break
            end
        end
    end         
    
    if (self.m_ShowGainedMorale)
    then
        StatusBarSetCurrentValue (self.m_StatusBar:GetName (), fillAmount)
    end
    
    -- Reset so that sounds can play during this morale update...
    g_playedASoundThisUpdate = false
    
    -- Update the button animations
    for _, buttonFrame in ipairs (self.m_Buttons)
    do
        buttonFrame:UpdateActiveState (self.m_PreviousMoraleLevel, self.m_CurrentMoraleLevel)
    end
    
    self.m_PreviousMoraleLevel = moraleLevel
end

function MoraleBar:OnMouseOver (flags, x, y)
    Tooltips.CreateTextOnlyTooltip (self:GetName (), GetString (StringTables.Default.LABEL_MORALE_BAR_DESC))
    Tooltips.Finalize ()
    
    local anchor = Tooltips.ANCHOR_WINDOW_VARIABLE
    if( DoesWindowExist( "MouseOverTargetWindow" ) and SystemData.Settings.GamePlay.staticAbilityTooltipPlacement )
    then
        anchor = Tooltips.ANCHOR_MOUSE_OVER_TARGET_WINDOW
    end
    
    Tooltips.AnchorTooltip (anchor)
end

function MoraleBar:OnInitializeCustomSettings ()
    if (ActionBarClusterManager)
    then
        ActionBarClusterManager:OnInitializeCustomSettingsForFrame (self)
    end
end

----------------------------------------------------------------
-- MoraleWindow Functions
----------------------------------------------------------------

MoraleSystem = {}

function MoraleSystem.Initialize ()
    RegisterEventHandler (SystemData.Events.PLAYER_MORALE_BAR_UPDATED,      "MoraleSystem.UpdateMoraleButtons")
    RegisterEventHandler (SystemData.Events.PLAYER_MORALE_UPDATED,          "MoraleSystem.OnMoraleUpdated")
    RegisterEventHandler (SystemData.Events.PLAYER_COOLDOWN_TIMER_SET,      "MoraleSystem.SetCooldownFlag")        
    RegisterEventHandler (SystemData.Events.USER_SETTINGS_CHANGED,          "MoraleSystem.OnUserSettingsChanged")
    RegisterEventHandler (SystemData.Events.PLAYER_SINGLE_ABILITY_UPDATED,  "MoraleSystem.UpdateMoraleButtons")
end

function MoraleSystem.Shutdown ()
    UnregisterEventHandler (SystemData.Events.PLAYER_MORALE_BAR_UPDATED,     "MoraleSystem.UpdateMoraleButtons")
    UnregisterEventHandler (SystemData.Events.PLAYER_MORALE_UPDATED,         "MoraleSystem.OnMoraleUpdated")
    UnregisterEventHandler (SystemData.Events.PLAYER_COOLDOWN_TIMER_SET,     "MoraleSystem.SetCooldownFlag")
    UnregisterEventHandler (SystemData.Events.USER_SETTINGS_CHANGED,         "MoraleSystem.OnUserSettingsChanged")
    UnregisterEventHandler (SystemData.Events.PLAYER_SINGLE_ABILITY_UPDATED, "MoraleSystem.UpdateMoraleButtons")
end

function MoraleSystem.Update (timePassed)   
    if (g_MoraleBar)
    then
        g_MoraleBar:Update (timePassed)
    end
    
    MoraleSystem.needsCooldownUpdate = false
end

function MoraleSystem:CreateBar (moraleBarName)
    g_MoraleBar = MoraleBar:Create (moraleBarName)
        
    self.UpdateMoraleButtons()
    self.OnMoraleUpdated (0, 0)
    self.ShowSlotsForEditing (false)
    
end

function MoraleSystem.SetCooldownFlag ()
    MoraleSystem.needsCooldownUpdate = true
end

function MoraleSystem.OnUserSettingsChanged ()
    if (g_MoraleBar)
    then
        g_MoraleBar:UpdateShowCooldownText ()
    end
end

function MoraleSystem.UpdateMoraleButtons()
    if (g_MoraleBar)
    then
        g_MoraleBar:UpdateButtons ()
    end
end

function MoraleSystem.ShowSlotsForEditing ( show )
    g_InEditMode = show
    
    if (g_MoraleBar)
    then    
        if (g_InEditMode)
        then
            g_MoraleBar:DoActivationTransition (TRANSITION_FROM_DOT_TO_FULL)
        else
            g_MoraleBar:DoActivationTransition (TRANSITION_FROM_FULL_TO_DOT)
        end
    end
end

function MoraleSystem.OnMoraleUpdated (moralePercent, moraleLevel)
    if (g_MoraleBar)
    then
        g_MoraleBar:SetMorale (moralePercent, moraleLevel)
    end
end


function MoraleSystem.UpdateTutorial()        
    EA_AdvancedWindowManager.UpdateWindowShowing( "EA_MoraleBarContents", EA_AdvancedWindowManager.WINDOW_TYPE_MORALE )
end