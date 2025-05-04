-- Subclass the Frame object to use as the button base...
ActionButton = Frame:Subclass ("ActionButton")

ActionButton.PRINT_MODIFICATION_ATTEMPT_ERROR       = true
ActionButton.SUPPRESS_MODIFICATION_ATTEMPT_ERROR    = false
ActionButton.MODIFICATION_TYPE_PICKUP               = 1
ActionButton.MODIFICATION_TYPE_SET_DATA             = 2
ActionButton.COOLDOWN_GRANULARITY                   = 0.1
ActionButton.FRACTIONAL_COOLDOWN_BEGIN              = 2.5
ActionButton.IGNORE_COOLDOWN_DELTA_THRESHOLD        = 0.7
ActionButton.GLOBAL_COOLDOWN                        = 1.51 -- max cooldown ends up being 1.500000001 or something crazy....

-- Window id's used to look up window names in a button's 
local BASE_ICON         = 0
local BUTTON_TEXT       = 1
local COOLDOWN          = 2
local COOLDOWN_TIMER    = 3
local FLASH_ANIM        = 4
local ACTIVE_ANIM       = 5
local GLOW_ANIM         = 6
local STACK_COUNT_TEXT  = 7

local INITIAL_COOLDOWN_ALPHA    = .9
local BASE_COOLDOWN_ALPHA       = .1

function ActionButton:Create (windowName, parentName, hotbarSlot, allowableModifications)
    local actionButton = self:CreateFromTemplate (windowName, parentName)
    
    if (actionButton == nil)
    then
        return (nil)
    end
    
    actionButton.m_HotBarSlot               = hotbarSlot
    actionButton.m_ActionType               = 0
    actionButton.m_ActionId                 = 0    
    actionButton.m_IconNum                  = 0
    actionButton.m_Cooldown                 = 0
    actionButton.m_MaxCooldown              = 0
    actionButton.m_GlowAtXPoints            = 0
    actionButton.m_GlowCap                  = 0
    actionButton.m_GlowLevel                = 0
	actionButton.m_IsBlocked				= false
    actionButton.m_RequiresFullUpdate       = false
    actionButton.m_AllowableModifications   = allowableModifications -- This table does not need to be copied.
    
    local overlayName   = windowName.."Overlay"
    local actionName    = windowName.."Action"
    
    actionButton.m_Windows = 
    {
        [BASE_ICON]         = DynamicImage:CreateFrameForExistingWindow (actionName.."Icon"),
        [BUTTON_TEXT]       = Label:CreateFrameForExistingWindow (actionName.."Text"),
        [COOLDOWN]          = Frame:CreateFrameForExistingWindow (actionName.."Cooldown"),
        [COOLDOWN_TIMER]    = Label:CreateFrameForExistingWindow (actionName.."CooldownTimer"),
        [STACK_COUNT_TEXT]  = Label:CreateFrameForExistingWindow (actionName.."Count"),
        [FLASH_ANIM]        = AnimatedImage:CreateFrameForExistingWindow (overlayName.."Flash"),
        [ACTIVE_ANIM]       = AnimatedImage:CreateFrameForExistingWindow (overlayName.."Active"),
        [GLOW_ANIM]         = AnimatedImage:CreateFrameForExistingWindow (overlayName.."Glow"),
    }
    
    WindowSetGameActionTrigger (windowName, GetActionIdFromName (actionButton:GetActionName ()))
        
    -- Because both the windows (named windowName and windowName.."Action") handle input
    -- the child window must resolve up the the Frame table created for this button when
    -- interacting with the button.  This should be cheaper than creating an additional subclass
    -- of Frame, but still incurs the cost of storing the "resolver-object" in the FrameManager.
    FrameManager:ResolveWindowToFrame (actionName, actionButton)    
    
    actionButton.m_Windows[COOLDOWN]:Show (false)
    actionButton.m_Windows[COOLDOWN]:SetTint (DefaultColor.ActionCooldown)
    actionButton.m_Windows[COOLDOWN]:SetAlpha (DefaultColor.ActionCooldown.a)    
    actionButton.m_Windows[STACK_COUNT_TEXT]:Show (false)
    actionButton.m_Windows[FLASH_ANIM]:Show (false)
    actionButton.m_Windows[GLOW_ANIM]:Show (false)
    
    -- Start the animation on this button so that it will be in synch with the rest of the buttons, the 
    -- animation will never be stopped, only hidden/shown at the appropriate times.
    -- NOTE: This doesn't work because Update is not called for hidden windows.
    -- Still this will not break anything and is a good "worst case" test for all animations being active at once.
    actionButton.m_Windows[ACTIVE_ANIM]:StartAnimation (0, true, false, 0.0)
    actionButton.m_Windows[ACTIVE_ANIM]:Show (false)

    actionButton:UpdateGlowTexture ()
    actionButton:UpdateKeyBindingText ()

    actionButton:SetActionData ()            
    return (actionButton)    
end

-- 
-- (Permanently) shows or hides the cooldown text label timer depending on the action bar's custom settings.
-- This setting is global over all action bars.
--
function ActionButton:UpdateShowCooldownText ()
    self.m_Windows[COOLDOWN_TIMER]:Show (EA_ActionBars_Settings.showCooldownText)
end

--
-- Updates/enables/disables the state of the cooldown animation on the window.
--
function ActionButton:UpdateCooldownAnimation (timeElapsed, updateCooldown)
    local cooldownFrame     = self.m_Windows[COOLDOWN]
    local timerFrame        = self.m_Windows[COOLDOWN_TIMER]
    local updateCooldown    = updateCooldown or self.m_RequiresFullUpdate
    local cooldownExpired   = false -- Should the flash animation play?
    
    if (updateCooldown)
    then
        local oldCooldown = self.m_Cooldown
        
        self.m_Cooldown, self.m_MaxCooldown = GetHotbarCooldown (self:GetSlot ())
        
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
        
        if (self.m_Cooldown <= 0)
        then
            cooldownExpired = true
        end
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
        
        -- Checking whether or not the cooldown actually expired here eliminates the false flash-animations
        if (cooldownExpired)
        then
            self.m_Windows[FLASH_ANIM]:StartAnimation (0, false, true, 0)
        end
    end 
end

--
-- For abilities that can be toggled on/off this controls whatever animation has been
-- created for the button containing the ability icon.
--
function ActionButton:UpdateActiveAbilityAnimation ()
    local slot, actionType, actionId = self:GetActionData ()
    local shouldBeActive = false
    
    if ((actionType == GameData.PlayerActions.DO_ABILITY) or (actionType == GameData.PlayerActions.COMMAND_PET_DO_ABILITY))
    then
        shouldBeActive = (ActionBars:IsActionActive (actionId) or (ActionBars:GetActionCastTimer (actionId) > 0))
    end
    
    if (actionType == GameData.PlayerActions.COMMAND_PET)
    then
        local movementState, stanceState = ActionBars:GetPetState ()
        
        shouldBeActive = (movementState == actionId)
    end
        
    if (shouldBeActive and (not self.m_Windows[ACTIVE_ANIM]:IsShowing ()))
    then
        self.m_Windows[ACTIVE_ANIM]:Show (true)
    elseif ((not shouldBeActive) and self.m_Windows[ACTIVE_ANIM]:IsShowing ())
    then
        self.m_Windows[ACTIVE_ANIM]:Show (false)
        -- self.m_Windows[ACTIVE_ANIM]:StopAnimation (Frame.FORCE_HIDE)
    end
end

--
-- Burn, baby, burn
--

function ActionButton:GetGlowLevels ()
    return self.m_GlowAtXPoints, self.m_GlowCap
end

function ActionButton:UpdateBurning (previousResource, currentResource)
    if ((previousResource == currentResource) and (not self.m_RequiresFullUpdate))
    then
        return
    end
    
    local glowLevel = 0
    local glowInfo  = EA_CareerResourceData[GameData.Player.career.line]

    if (nil ~= glowInfo) then 
        local glowBeginThreshold, glowCap = self:GetGlowLevels ()
        
        glowLevel = glowInfo:GetGlowLevel (currentResource, CareerResource:GetMaximum (), glowBeginThreshold, glowCap)
    end
    
    local glowFrame = self.m_Windows[GLOW_ANIM]
    
    if ((glowLevel == 0) and (glowFrame:IsShowing ()))
    then
        glowFrame:StopAnimation (true)
        glowFrame:Show (false)
    elseif ((glowLevel > 0) and ((not glowFrame:IsShowing ()) or (self.m_GlowLevel ~= glowLevel)))
    then
        glowFrame:StopAnimation (true)
        glowFrame:SetAnimationTexture (self.m_GlowBase..glowLevel)
        glowFrame:StartAnimation (0, true, false, 0)
        self.m_GlowLevel = glowLevel
    end             
end

--[[
    Updates the stack count for action buttons that contain items.
--]]

function ActionButton:UpdateInventory ()
    local _, actionType, actionId = self:GetActionData ()
    local showCountWindow = false
    
    if (actionType == GameData.PlayerActions.USE_ITEM)
    then
        local totalCount = GetItemStackCount (actionId)
        
        if (totalCount > 1)
        then
            showCountWindow = true
            self.m_Windows[STACK_COUNT_TEXT]:SetText (totalCount)
        end
    end
    
    self.m_Windows[STACK_COUNT_TEXT]:Show (showCountWindow)
end

--
-- Per-frame button update function
-- TODO: A key place for optimization
--
function ActionButton:Update (timeElapsed, updateCooldown, updateInventory, previousResource, currentResource)
    if (self.m_ActionId ~= 0)
    then
        self:UpdateCooldownAnimation (timeElapsed, updateCooldown)
        self:UpdateActiveAbilityAnimation ()
        self:UpdateBurning (previousResource, currentResource)
        
        if (updateInventory) 
        then
            self:UpdateInventory ()
        end
    end
    
    self.m_RequiresFullUpdate = false
end

local USE_ENABLED_ICON  = 42
local USE_DISABLED_ICON = 84
local USE_EMPTY_ICON    = 168

function ActionButton:SetIcon (iconNum, iconType)
    local texture           = L""
    local disabledTexture   = L""
    local x                 = 0
    local y                 = 0
    
    self.m_IconNum = iconNum
    
    local iconWindow    = self.m_Windows[BASE_ICON]
    
    if (iconNum > 0) 
    then
        texture, x, y, disabledTexture = GetIconData (iconNum)
                
        if (iconType == USE_DISABLED_ICON) 
        then
            if (disabledTexture ~= "")
            then
                texture = disabledTexture
            else
                iconType    = USE_ENABLED_ICON
            end
        end
        
        iconWindow:SetTexture (texture, x, y)
    else
        -- NOTE: To avoid two function calls, potentially allow DynamicImageSetTextureSlice to take a texture name as well...
        iconWindow:SetTexture ("EA_HUD_01", 0, 0)
        iconWindow:SetTextureSlice ("Blank-Action-Bar-Icon-Slot", Frame.FORCE_OVERRIDE)
        
        iconType = USE_EMPTY_ICON
    end
    
    -- To allow callers to determine which icon type was actually displayed...
    return iconType
end

function CacheData (actionType, actionId, key, data)
    if (data and key)
    then
        if (EA_ActionBars_DataCache[actionType] == nil)
        then
            EA_ActionBars_DataCache[actionType] = {}
        end
        
        if (EA_ActionBars_DataCache[actionType][actionId] == nil)
        then
            EA_ActionBars_DataCache[actionType][actionId] = {}
        end
                
        EA_ActionBars_DataCache[actionType][actionId][key] = data
    end
end

function GetCachedData (actionType, actionId, key)
    if (actionType and actionId and key)
    then
        local typeCache = EA_ActionBars_DataCache[actionType]
        
        if (typeCache)
        then
            local cacheTable = typeCache[actionId]
        
            if (cacheTable and cacheTable[key])
            then
                return cacheTable[key]
            end
        end
    end
end

function ActionButton:GetIcon (slot, actionType, actionId)
    local icon = GetHotbarIcon (slot)
    
    -- Until item data is present on the client, caching a actionId-to-slotIcon mapping
    -- so that if this action is no longer present on the client, the slot just dims out...
    if (icon > 0)
    then
        CacheData (actionType, actionId, "icon", icon)
    elseif (icon == 0)
    then
        icon = GetCachedData (actionType, actionId, "icon") or 0
    end
    
    return icon
end

--
-- Called when the game updates the hotbar on a per-button basis.
-- Typically called from the event handler, however this is also called
-- when the button initializes itself
--
function ActionButton:SetActionData( actionType, actionId )
    local actionName    = self:GetName ().."Action"
    local slot          = self:GetSlot ()
    
    -- If either actionType/actionId are nil, the button should pull its data
    -- directly from the game
    
    if( actionType == nil or actionId == nil )
    then
        actionType, actionId, self.m_IsEnabled, self.m_IsTargetValid, self.m_IsBlocked = GetHotbarData( slot )
    end
    	
    self.m_ActionType                       = actionType
    self.m_ActionId                         = actionId
    self.m_GlowLevel                        = 0
    self.m_Cooldown                         = 0 
    self.m_RequiresFullUpdate               = true
    self.m_GlowAtXPoints, self.m_GlowCap    = GetHotbarGlowLevels (slot)
    self.m_IconNum                          = self:GetIcon (slot, actionType, actionId)
    
    self:UpdateInventory ()
    self:UpdateEnabledState( self.m_IsEnabled, self.m_IsTargetValid, self.m_IsBlocked )
    self:UpdateIsShowing (self:GetParent ())
    
    WindowSetGameActionData (actionName, actionType, actionId, L"")
    
    if (actionType == 0 and actionId == 0) 
    then
        WindowSetGameActionData (actionName, 0, 0, L"")
        
        self:SetIcon (0)
        
        -- Clearing the rest of the window states can be performed with the normally called functions...
        self:UpdateCooldownAnimation (0)
        self:UpdateActiveAbilityAnimation ()
        self:UpdateBurning (0, 0)
        
        -- Required because this never hides itself in the regular update cycle...
        self.m_Windows[FLASH_ANIM]:StopAnimation (Frame.FORCE_HIDE)        
    end
    
    -- For items, temporarily caching their data so they can appear dimmed out on the hotbar
    -- but still have a tooltip.  Doing this is not accurate, but it's not dangerous.
    
    if (actionType == GameData.PlayerActions.USE_ITEM)
    then
        local itemData = DataUtils.FindItem (actionId)
        
        if (itemData ~= nil)
        then
            CacheData (actionType, actionId, "itemData", DataUtils.CopyTable (itemData))
        end
    end
end

function ActionButton:SetEnabled( enable )
	if( enable )
	then
		self.m_Windows[BASE_ICON]:SetTintColor (255, 255, 255)
	else
		self.m_Windows[BASE_ICON]:SetTintColor (255, 0, 0)
	end
end


--
-- Convenience function to update whether or not this button should show based on whether
-- or not it has an action id
--
function ActionButton:UpdateIsShowing (parentBar)
    local isEmpty = (self.m_ActionId == 0)
    
    local wasShowing = self:IsShowing ()
    
    if (isEmpty)
    then
        local parentShowsEmptySlots = (parentBar:ShowEmptySlots () == ActionBarConstants.SHOW_EMPTY_SLOTS)
        local showingSlotsForEditing = ActionBars:ShouldShowButtonsForEditing ()
        
        self:Show (parentShowsEmptySlots or showingSlotsForEditing)
    else
        -- Always show buttons that have something in them...        
        self:Show (true)
    end
    
    local isShowing = self:IsShowing ()
    
    if (isShowing ~= wasShowing)
    then
        if (isShowing)
        then
            parentBar:UpdateShownRefCount (1)
        else
            parentBar:UpdateShownRefCount (-1)
        end
    end
end

--
-- Default behavior for updating icons for abilities enabled/disabled states.
-- When an ability is not enabled, we show the disabled icon and tint the base 
-- icon gray (incase the disabled icon is missing)
--
-- Update the binding text label on the button to reflect whether or not the target is valid/in-range.
--

local COLOR_IT_VALID    = true
local COLOR_IT_INVALID  = false

function ActionButton:UpdateEnabledState( isSlotEnabled, isTargetValid, isBlocked )
	
	local iconType = USE_ENABLED_ICON
    
    self.m_IsEnabled        = isSlotEnabled
    self.m_IsTargetValid    = isTargetValid
	self.m_IsBlocked		= isBlocked
	
	if( isBlocked )
	then
		self:SetIcon( self.m_IconNum, USE_ENABLED_ICON )
		local tint = DefaultColor.RED
		self.m_Windows[BASE_ICON]:SetTintColor( tint.r, tint.g, tint.b )
		tint = DefaultColor.ZERO_TINT
		self.m_Windows[BUTTON_TEXT]:SetTextColor( tint.r, tint.g, tint.b )
		return
	end    

	if (not isSlotEnabled)
    then
        iconType = USE_DISABLED_ICON
    end

    
    iconType = self:SetIcon (self.m_IconNum, iconType)

    if (isSlotEnabled == true)
    then                  
        self.m_Windows[BASE_ICON]:SetTintColor (255, 255, 255)
    elseif ((isSlotEnabled == false) and (iconType == USE_ENABLED_ICON)) -- for missing disabled icons
    then
        self.m_Windows[BASE_ICON]:SetTintColor (125, 125, 125)
    end
    
    local r = 255
    local g = 0
    local b = 0
    
    -- The number should be white if the target is valid 
    -- or 
    -- if the target is invalid, but it's only because the player doesn't have the required unit type targeted.
    if (isTargetValid == COLOR_IT_VALID)
    then
        r = 255 g = 255 b = 255
    end
    
    self.m_Windows[BUTTON_TEXT]:SetTextColor (r, g, b)  
end

function ActionButton:GetSlot ()
    return self.m_HotBarSlot
end

function ActionButton:GetActionName ()
    -- FIXME: Makes assumptions about the internal implementation of the action/command system...But is easily generalized.
    -- Also, this limits Buttons to only looking at hotbar actions.  Don't forget about Granted Abilities, Morales, pets....
    --
    -- Easily fixed by parameterizing "HOTBAR_" ...or creating a simple table of lookup functions indexed by the button's type...
    
    if (self.m_ActionName == nil)
    then
        self.m_ActionName = "ACTION_BAR_"..self:GetSlot ()
    end
    
    return self.m_ActionName
end

--[[
    Returns:
        physical hot bar slot
        action type
        action id
        icon number
--]]
function ActionButton:GetActionData ()
    return self.m_HotBarSlot, self.m_ActionType, self.m_ActionId, self.m_IconNum
end

--[[
    Updates the fire animation overlay on a given action button's overlay Window
    to use class specific textures.  
--]]
function ActionButton:UpdateGlowTexture ()
    self.m_GlowBase = "anim_waaagh_" -- For destruction characters...

    if (GameData.Realm.ORDER == GameData.Player.realm) then 
        self.m_GlowBase  = "anim_fury_" -- For Order characters...
    end
    
    -- Default it to animation level 1...
    self.m_Windows[GLOW_ANIM]:SetAnimationTexture (self.m_GlowBase.."1")
end

--[[
    Determines which hot bar slot this button represents and sets the keybinding text appropriately.
--]]
function ActionButton:UpdateKeyBindingText ()    
    -- Ignore the second key
    local action = self:GetActionName ()
    local bindings = {}
    
    KeyUtils.GetBindingsForAction (action, bindings)
    
    if (#bindings == 0)
    then
        LabelSetText (self:GetName ().."ActionText", L"");
        return
    end
        
    -- Display the first valid keybinding found in the bindings table:
    for bindingId, bindingData in ipairs (bindings)
    do
        -- FIXME: Need to implement "short" keynames.  Ctrl = C, Shift = S, Alt = A ... Ctrl + 1 = C1
        -- And of course that has to be localized...
        if (bindingData.name ~= L"")
        then
            local shortBindingName = KeyUtils.ShortenBindingName (bindingData.name)
            LabelSetText (self:GetName ().."ActionText", shortBindingName)
            break
        end
    end    
end

--[[
    If the ability changes out from under the button this updates the icon to match
    the ability's new graphic.  It's typically for auto-attack.  
--]]
function ActionButton:UpdateIcon ()
    self:SetIcon (GetHotbarIcon (self:GetSlot ()))
	self:UpdateEnabledState( self.m_IsEnabled, self.m_IsTargetValid, self.m_IsBlocked )
end

--[[
    Picks up the cursor without checking the mouse movement rules or whether or not there is 
    something already on the cursor.
    Don't call directly, wrap in a check for distance or mouseOverEnd
--]]
function ActionButton:DoDragPickup ()
    if ((self.m_ActionType > 0) and (self.m_ActionId > 0))
    then    
        if (self:VerifySlotIsUserModifiable (ActionButton.SUPPRESS_MODIFICATION_ATTEMPT_ERROR, ActionButton.MODIFICATION_TYPE_PICKUP))
        then
            Cursor.PickUp (self.m_ActionType, 0, self.m_ActionId, self.m_IconNum, Cursor.AUTO_PICKUP_ON_LBUTTON_UP)
        end
        
        if (self:VerifySlotIsUserModifiable (ActionButton.SUPPRESS_MODIFICATION_ATTEMPT_ERROR, ActionButton.MODIFICATION_TYPE_SET_DATA))
        then
            SetHotbarData (self:GetSlot (), 0, 0)
        end
    end
end

--[[
    Should probably be called OnLButtonUp, because that's what it is...
--]]

-- This little table aids in translating cursor source-types to action types
-- It exists so that the cursor source can actually be set to an action source and swapped
-- onto different slots in the CursorSwap function
local CursorSourceTranslation =
{
    [Cursor.SOURCE_ACTION_LIST] = GameData.PlayerActions.DO_ABILITY,
    [Cursor.SOURCE_EQUIPMENT]   = GameData.PlayerActions.USE_ITEM,
    [Cursor.SOURCE_INVENTORY]   = GameData.PlayerActions.USE_ITEM,
    [Cursor.SOURCE_QUEST_ITEM]  = GameData.PlayerActions.USE_ITEM,    
    [Cursor.SOURCE_MACRO]       = GameData.PlayerActions.DO_MACRO,
    [Cursor.SOURCE_CRAFTING]    = GameData.PlayerActions.DO_CRAFTING,
    
    -- The action-type keys are also in this table in case the cursor was created with one of them as the 
    -- source type!
    
    [GameData.PlayerActions.DO_ABILITY]     = GameData.PlayerActions.DO_ABILITY,
    [GameData.PlayerActions.USE_ITEM]       = GameData.PlayerActions.USE_ITEM,
    [GameData.PlayerActions.DO_MACRO]       = GameData.PlayerActions.DO_MACRO,
    [GameData.PlayerActions.DO_CRAFTING]    = GameData.PlayerActions.DO_CRAFTING,
}

local function ActionButtonAlert (alertId)
    AlertTextWindow.AddLine (SystemData.AlertText.Types.DEFAULT, GetString (alertId))
    return false
end

function ActionButton:VerifySlotIsUserModifiable (printErrorMessage, modificationType)
    local modificationAllowed = false
    
    if (modificationType and self.m_AllowableModifications[modificationType])
    then
        modificationAllowed = true
    end

    local slot = self:GetSlot ()
    local errorMessageId
    
    if ((slot >= GameDefs.FIRST_GRANTED_ABILITY_SLOT) and (slot <= GameDefs.LAST_GRANTED_ABILITY_SLOT))
    then
        errorMessageId = StringTables.Default.TEXT_GRANTED_DROP_ERROR
    end

    if ((slot >= GameDefs.FIRST_STANCE_ABILITY_SLOT) and (slot <= GameDefs.LAST_STANCE_ABILITY_SLOT))
    then
        errorMessageId = StringTables.Default.TEXT_STANCE_DROP_ERROR
    end
    
    if ((slot >= GameDefs.FIRST_PET_ABILITY_SLOT) and (slot <= GameDefs.LAST_PET_ABILITY_SLOT))
    then
        errorMessageId = StringTables.Default.TEXT_PET_DROP_ERROR
    end 
    
    if (printErrorMessage == ActionButton.PRINT_MODIFICATION_ATTEMPT_ERROR and (errorMessageId ~= nil))
    then
        ActionButtonAlert (errorMessageId)
    end
    
    return (modificationAllowed)
end

function ActionButton:CursorSwap (flags, x, y)

    local mySlot, slotType, slotId, slotIcon = self:GetActionData ()
		
	-- SetHotbarData will modify the values in actionData, so it can't be used later in this function
	local oldActionId   = slotId
	local oldActionType = slotType
	local oldIconNum    = slotIcon
	
    slotType = CursorSourceTranslation[Cursor.Data.Source]
        
    if (slotType == GameData.PlayerActions.DO_ABILITY) 
    then
         -- Only Standard Abilities can be dropped on the hotbar, not morale or tactic
        local abilityData = Player.GetAbilityData (Cursor.Data.ObjectId)
            
        if (abilityData == nil) 
        then
            return
        end
            
        if (abilityData.abilityType == GameData.AbilityType.MORALE) 
        then
            return ActionButtonAlert (StringTables.Default.TEXT_MORALE_DROP_ERROR)
        end  
            
        if (abilityData.abilityType == GameData.AbilityType.TACTIC) 
        then
            return ActionButtonAlert (StringTables.Default.TEXT_TACTIC_DROP_ERROR)
        end
    elseif (slotType == nil)
    then
        -- AlertText about the error?  
        -- (That the cursor source was something completely unsupported by the hotbar?)
        return
    end
        
    if (self:VerifySlotIsUserModifiable (ActionButton.PRINT_MODIFICATION_ATTEMPT_ERROR, ActionButton.MODIFICATION_TYPE_SET_DATA) == false)
    then
        return
    end       
        
    SetHotbarData (mySlot, slotType, Cursor.Data.ObjectId)
    Cursor.Clear ()

    -- Pick up the old slot data if there was something there before
    if (oldActionId ~= 0) 
    then        
        Cursor.PickUp (oldActionType, 0, oldActionId, oldIconNum, Cursor.AUTO_PICKUP_ON_LBUTTON_UP)
    end
        
    -- So that the button tooltip will update properly
    self:OnMouseOver (flags, x, y)
end

--
-- Event Handlers 
--

local ActionButtonTooltipCreators =
{   
    [GameData.PlayerActions.DO_ABILITY] = function (actionId, clickText, anchor)
        local abilityData = Player.GetAbilityData (actionId)
                
        if (abilityData ~= nil) 
        then
			-- Override the interaction text if the ability is blocked
			if( Player.IsAbilityBlocked( abilityData.id, abilityData.abilityType ))
			then
				clickText = GetString( StringTables.Default.TEXT_BLOCKED_ABILITY_DESC )
			end
			
            Tooltips.CreateAbilityTooltip (abilityData, SystemData.MouseOverWindow.name, anchor, clickText)
        end    
    end,
    
    [GameData.PlayerActions.USE_ITEM] = function (actionId, clickText, anchor, slot)
        local itemData = DataUtils.FindItem (actionId)
        local cacheThisItem = true
        
        if (itemData == nil) 
        then
            itemData = GetCachedData (GameData.PlayerActions.USE_ITEM, actionId, "itemData")
            cacheThisItem = false
        end
        
        if (itemData ~= nil)
        then
            Tooltips.CreateItemTooltip (itemData, SystemData.MouseOverWindow.name, anchor, true, clickText)
            
            if (cacheThisItem == true)
            then
                CacheData (GameData.PlayerActions.USE_ITEM, actionId, "itemData", DataUtils.CopyTable (itemData))
            end
        end
    end,
    
    [GameData.PlayerActions.DO_MACRO] = function (actionId, clickText, anchor)
        local macroTable    = DataUtils.GetMacros ()
        local macroData     = macroTable[actionId]
        
        if (macroData ~= nil) 
        then            
            Tooltips.CreateMacroTooltip (macroData, SystemData.MouseOverWindow.name, anchor, clickText)
        end    
    end,
    
    [GameData.PlayerActions.DO_CRAFTING] = function (actionId, clickText, anchor)
        Tooltips.CreateTradeskillTooltip (actionId, anchor)
    end,
    
    [GameData.PlayerActions.COMMAND_PET] = function (actionId, clickText, anchor)
        -- This function is the devil
        local line1 = L""
        local line2 = L""
        local line3 = L""
        if (actionId == GameData.PetCommand.STAY) 
        then
            line1 = GetString( StringTables.Default.LABEL_PET_STAY )
            line2 = GetString( StringTables.Default.TEXT_PET_STAY ) 
            line3 = L"("..KeyUtils.GetFirstBindingNameForAction( "PET_STAY" )..L")"
        elseif (actionId == GameData.PetCommand.FOLLOW) 
        then
            line1 = GetString( StringTables.Default.LABEL_PET_FOLLOW )
            line2 = GetString( StringTables.Default.TEXT_PET_FOLLOW )   
            line3 = L"("..KeyUtils.GetFirstBindingNameForAction( "PET_FOLLOW" )..L")"
        elseif (actionId == GameData.PetCommand.ATTACK)
        then
            line1 = GetString( StringTables.Default.LABEL_PET_ATTACK )
            line2 = GetString( StringTables.Default.TEXT_PET_ATTACK )
            line3 = L"("..KeyUtils.GetFirstBindingNameForAction( "PET_ATTACK" )..L")"
        end

        Tooltips.CreateTextOnlyTooltip( SystemData.MouseOverWindow.name )
        Tooltips.SetTooltipText( 1, 1, line1)
        Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
        Tooltips.SetTooltipText( 2, 1, line2)
        Tooltips.SetTooltipText( 3, 1, line3)
        Tooltips.SetTooltipColor( 3, 1, 140, 100, 0 ) 
        Tooltips.Finalize()    
        Tooltips.AnchorTooltip (anchor)
    end,
    
    [GameData.PlayerActions.COMMAND_PET_DO_ABILITY] = function (actionId, clickText, anchor)
        local abilityData = Player.GetAbilityData (actionId)
        
        if (abilityData ~= nil)
        then
            local text = GetString( StringTables.Default.TEXT_PET_ABILITY_FLASH )
            Tooltips.CreateAbilityTooltip (abilityData, SystemData.MouseOverWindow.name, anchor, text)
        end
    end,
}

function ActionButton:OnMouseOver (flags, x, y)
    local anchor = nil
    if  DoesWindowExist( "MouseOverTargetWindow" )
        and ( SystemData.Settings.GamePlay.staticAbilityTooltipPlacement or SystemData.Settings.GamePlay.staticTooltipPlacement )
    then
        anchor = Tooltips.ANCHOR_MOUSE_OVER_TARGET_WINDOW
    else
        anchor = { Point = "top",  RelativeTo = self:GetName (), RelativePoint = "bottom", XOffset = 0, YOffset = -50 }
    end
    
    local clickText = L""
 
    if (self:VerifySlotIsUserModifiable (ActionButton.SUPPRESS_MODIFICATION_ATTEMPT_ERROR, ActionButton.MODIFICATION_TYPE_SET_DATA))
    then
        clickText = GetString (StringTables.Default.TEXT_ACTION_BUTTON_ACTION_TEXT)
       
        if (SystemData.Settings.Interface.lockActionBars)
        then
            clickText = GetString (StringTables.Default.TEXT_ACTION_BUTTON_ACTION_TEXT_LOCKED)
        end
    end

    local slot, slotType, slotId = self:GetActionData ()
    
    local tooltipFunction = ActionButtonTooltipCreators[slotType]
    
    if (tooltipFunction)
    then
        tooltipFunction (slotId, clickText, anchor, slot)
    end
end

function ActionButton:OnLButtonDown( flags, x, y )
    if ( flags ~= SystemData.ButtonFlags.GAME_ACTION )
    then
        local button = FrameManager:GetMouseOverWindow ()
    
        if ( button )
        then
            local hotbarSlot = button:GetSlot()
            local modificationAllowed = button:VerifySlotIsUserModifiable( ActionButton.SUPPRESS_MODIFICATION_ATTEMPT_ERROR, ActionButton.MODIFICATION_TYPE_PICKUP )
        
            if ( ( not SystemData.Settings.Interface.lockActionBars ) and modificationAllowed )
            then
                ActionBars:SetPickupButton( button )
            end
        end
    end
end

function ActionButton:OnLButtonUp( flags, x, y )
    --Handle item activation in lua (allows conditioning behavior on UI input)
    
    --Item activation from hotbar can:
    -- 1. Equip item (if not bound, and is bind-on-equip)
    -- 2. Use item (if usable; need to assume quest items may be usable)
    -- 3. Equip item (if can be equipped)
    
    local button = FrameManager:GetActiveWindow()
    
    if ( button )
    then
        if ( flags ~= SystemData.ButtonFlags.GAME_ACTION )
        then
            ActionBars:SetPickupButton( nil )
            if ( Cursor.IconOnCursor() )
            then
                button:CursorSwap( flags, x, y )
                return
            end
        end
        
        local action, actionType, actionId = button:GetActionData()
        if(actionType == GameData.PlayerActions.USE_ITEM) then
            local itemData, itemLoc, itemSlot = DataUtils.FindItem(actionId)
            if((itemData ~= nil) and  (itemData.uniqueID ~= 0)) then

                if((itemLoc == GameData.ItemLocs.INVENTORY) and (itemData.flags[GameData.Item.EITEMFLAG_BIND_ON_EQUIP]) and not (itemData.boundToPlayer)) then
                    CharacterWindow.AutoEquipItem(itemSlot)
                
                elseif(UseItemTargeting.HandleUseItemChangeTargetCursor(itemLoc, itemSlot)) then
                    -- handled in conditional, so nothing else to do
                
                elseif((itemLoc == GameData.ItemLocs.QUEST_ITEM) or (DataUtils.ItemHasUseEffect(itemData) == true)) then
                    if not ItemUtils.ShowUseOptions(itemData, itemLoc, itemSlot)
                    then
                        SendUseItem(itemLoc, itemSlot, 0, 0, 0)
                    end

                elseif( (itemLoc == GameData.ItemLocs.INVENTORY) and ((itemData.equipSlot > 0) or (itemData.type == GameData.ItemTypes.TROPHY)) ) then
                    CharacterWindow.AutoEquipItem(itemSlot)

                end
                
            end            
        else
            WindowGameAction( SystemData.ActiveWindow.name )
        end
   end
end

function ActionButton:OnRButtonDown (flags, x, y)
    if ((SystemData.Settings.Interface.lockActionBars == false) and (flags == SystemData.ButtonFlags.SHIFT))
    then
        if (self:VerifySlotIsUserModifiable (ActionButton.PRINT_MODIFICATION_ATTEMPT_ERROR, ActionButton.MODIFICATION_TYPE_SET_DATA) == true)
        then
            SetHotbarData (self:GetSlot (), 0, 0)
        end
    end
end

function ActionButton:OnMouseOverEnd (flags, x, y)
    if ((not Cursor.IconOnCursor ()) and (ActionBars:GetPickupButton () == self))
    then
        self:DoDragPickup ()
    end
    
    ActionBars:SetPickupButton (nil)
end

