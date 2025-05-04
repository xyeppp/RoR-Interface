----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

PetWindow           = CareerResourceFrame:Subclass ("PetWindow")
PetStanceButton     = Frame:Subclass ("EA_PetStanceButton")
ReleasePetButton    = ButtonFrame:Subclass ()

PetWindow.BACKGROUND_ALPHA      = 1.0
PetWindow.FADE_IN_TIME          = 1.0

local PetActionBarParameters =
{
    ["barId"]                   = GameDefs.PET_HOTBAR_ID,
    ["show"]                    = false,
    ["caps"]                    = ActionBarConstants.HIDE_DECORATIVE_CAPS,
    ["firstSlot"]               = GameDefs.FIRST_PET_ABILITY_SLOT,
    ["lastSlot"]                = GameDefs.LAST_PET_ABILITY_SLOT,
    ["background"]              = ActionBarConstants.HIDE_BACKGROUND,
    ["selector"]                = ActionBarConstants.HIDE_PAGE_SELECTOR,
    ["buttonXPadding"]          = 0,
    ["buttonYPadding"]          = 0,
    ["buttonXSpacing"]          = 0,
    ["buttonYSpacing"]          = 0,
    ["showEmptySlots"]          = ActionBarConstants.HIDE_EMPTY_SLOTS,
    ["buttonFactory"]           = "PetButton",
    ["scale"]                   = 0.75,
    ["modificationSettings"]    = 
    {
        [ActionButton.MODIFICATION_TYPE_PICKUP]     = false,
        [ActionButton.MODIFICATION_TYPE_SET_DATA]   = false,
    },            
}

----------------------------------------------------------------
-- PetStanceButton Functions
----------------------------------------------------------------

-- Window id's for quick window lookups:
local AGGRESSIVE                = GameData.PetCommand.AGGRESSIVE
local DEFENSIVE                 = GameData.PetCommand.DEFENSIVE
local PASSIVE                   = GameData.PetCommand.PASSIVE
local STATE                     = (AGGRESSIVE * DEFENSIVE * PASSIVE) + 1
local RING                      = STATE + 1
local RELEASE                   = RING + 1
local STANCE_BUTTON_NORMAL      = RELEASE + 1
local STANCE_BUTTON_HIGHLIGHT   = STANCE_BUTTON_NORMAL + 1

-- The amount by which to offset the activated state buttons along the x-axis
local ACTIVE_STANCE_BUTTON_X_OFFSET = 15

-- Always create the stance buttons in this order:
local StanceButtonOrdering = 
{ 
    { GameData.PetCommand.AGGRESSIVE, "Aggressive",   { Point = "topleft", RelativePoint = "topright", RelativeTo = "REPLACE_PARENT_MANUALLY", XOffset = 20, YOffset = 16 } },
    { GameData.PetCommand.DEFENSIVE,  "Defensive",    { Point = "topleft", RelativePoint = "topright", RelativeTo = "REPLACE_PARENT_MANUALLY", XOffset = 20, YOffset = 34 } },
    { GameData.PetCommand.PASSIVE,    "Passive",      { Point = "topleft", RelativePoint = "topright", RelativeTo = "REPLACE_PARENT_MANUALLY", XOffset = 20, YOffset = 52 } },
}

local StanceButtonTooltipStrings =
{
    [GameData.PetCommand.AGGRESSIVE]    = { label = GetString (StringTables.Default.LABEL_PET_STANCE_AGGRESSIVE),   desc = GetString (StringTables.Default.TEXT_PET_STANCE_AGGRESSIVE) },
    [GameData.PetCommand.DEFENSIVE]     = { label = GetString (StringTables.Default.LABEL_PET_STANCE_DEFENSIVE),    desc = GetString (StringTables.Default.TEXT_PET_STANCE_DEFENSIVE) },
    [GameData.PetCommand.PASSIVE]       = { label = GetString (StringTables.Default.LABEL_PET_STANCE_PASSIVE),      desc = GetString (StringTables.Default.TEXT_PET_STANCE_PASSIVE) },
}

function PetStanceButton:Create (windowName, parentName, textureData, petStance, anchor)
    local button = self:CreateFromTemplate (windowName, parentName)
    
    if (button)
    then
        local normalFrame   = DynamicImage:CreateFrameForExistingWindow (windowName.."Normal")
        local rolloverFrame = DynamicImage:CreateFrameForExistingWindow (windowName.."Rollover")
        
        normalFrame:SetTexture (textureData.MAIN_TEXTURE)
        normalFrame:SetTextureSlice (textureData[petStance].normalButtonSlice)
        
        rolloverFrame:SetTexture (textureData.MAIN_TEXTURE)
        rolloverFrame:SetTextureSlice (textureData[petStance].rolloverButtonSlice)
        
        button.m_Windows =
        {
            [STANCE_BUTTON_NORMAL]      = normalFrame,
            [STANCE_BUTTON_HIGHLIGHT]   = rolloverFrame,
        }
        
        button.m_TooltipLabel       = StanceButtonTooltipStrings[petStance].label
        button.m_TooltipDescription = StanceButtonTooltipStrings[petStance].desc
        button.m_StanceId           = petStance
        button.m_Anchor             = anchor -- preserved so that the button can adjust its position when active/inactive
        button.m_ActiveOffsetCount  = 0
        
        button:SetAnchor (anchor)
        button:Show (true)
        button:ShowNormalState ()
    end
    
    return button
end

function PetStanceButton:ShowNormalState ()
    self.m_ShownState = STANCE_BUTTON_NORMAL
    
    self.m_Windows[STANCE_BUTTON_NORMAL]:Show (true)
    self.m_Windows[STANCE_BUTTON_HIGHLIGHT]:Show (false)
end

function PetStanceButton:ShowHighlightState ()
    self.m_ShownState = STANCE_BUTTON_HIGHLIGHT
    
    self.m_Windows[STANCE_BUTTON_NORMAL]:Show (false)
    self.m_Windows[STANCE_BUTTON_HIGHLIGHT]:Show (true)
end

function PetStanceButton:AdjustActiveOffset (offsetChangeAmount)
    self.m_ActiveOffsetCount = self.m_ActiveOffsetCount + offsetChangeAmount
    
    -- Clamp it to 1 or 0, the clamp values are hardcoded because current the stance's state is binary
    if (self.m_ActiveOffsetCount > 1)
    then
        self.m_ActiveOffsetCount = 1
    end
    
    if (self.m_ActiveOffsetCount < 0)
    then
        self.m_ActiveOffsetCount = 0
    end
end

function PetStanceButton:ToggleState (currentPetStance)
    if (self.m_StanceId == currentPetStance)
    then
        self:ShowHighlightState ()
        self:AdjustActiveOffset (1)
    else
        self:ShowNormalState ()
        self:AdjustActiveOffset (-1)
    end
    
    local myAnchor = self.m_Anchor
    
    local currentAnchor =
    {
        Point           = myAnchor.Point, 
        RelativePoint   = myAnchor.RelativePoint, 
        RelativeTo      = myAnchor.RelativeTo, 
        XOffset         = myAnchor.XOffset + (ACTIVE_STANCE_BUTTON_X_OFFSET * self.m_ActiveOffsetCount), 
        YOffset         = myAnchor.YOffset,
    }
    
    self:SetAnchor (currentAnchor)
end

function PetStanceButton:OnMouseOver (flags, x, y)
    if (self.m_ShownState == STANCE_BUTTON_NORMAL)
    then
        self.m_ShouldRevertToNormalStateOnMouseOverEnd = true
        self:ShowHighlightState ()
    end
    
    Tooltips.CreateTextOnlyTooltip (self:GetName ())
    Tooltips.SetTooltipText (1, 1, self.m_TooltipLabel)
    Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)
    Tooltips.SetTooltipText (2, 1, self.m_TooltipDescription)
    Tooltips.Finalize()    
    
    local anchor = Tooltips.ANCHOR_WINDOW_VARIABLE
    if( DoesWindowExist( "MouseOverTargetWindow" ) and SystemData.Settings.GamePlay.staticAbilityTooltipPlacement )
    then
        anchor = Tooltips.ANCHOR_MOUSE_OVER_TARGET_WINDOW
    end
    Tooltips.AnchorTooltip (anchor)
end

function PetStanceButton:OnMouseOverEnd (flags, x, y)
    if ((self.m_ShownState == STANCE_BUTTON_HIGHLIGHT) and (self.m_ShouldRevertToNormalStateOnMouseOverEnd))
    then
        self.m_ShouldRevertToNormalStateOnMouseOverEnd = false
        self:ShowNormalState ()
    end
end

function PetStanceButton:OnLButtonUp (flags, x, y)
    local commandSent = CommandPet(self.m_StanceId)
    
    -- Pretend that a stance command will always work if it is sent
    -- short circuit the update
    local parentPetWindow = self:GetParent ()
    
    if(parentPetWindow and commandSent) then
        parentPetWindow:UpdatePetState (self.m_StanceId)
        self.m_ShouldRevertToNormalStateOnMouseOverEnd = false
    end
end

----------------------------------------------------------------
-- PetWindow Functions
----------------------------------------------------------------

function PetWindow:Create (windowName, stateTextures, petCommands)
    local petWindow = self:CreateFromTemplate (windowName)
    
    if (petWindow)
    then
        WindowRegisterEventHandler (windowName, SystemData.Events.PLAYER_PET_UPDATED,               "PetWindow.UpdatePetProxy")
        WindowRegisterEventHandler (windowName, SystemData.Events.PLAYER_PET_HEALTH_UPDATED,        "PetWindow.UpdatePetHealthProxy")
        WindowRegisterEventHandler (windowName, SystemData.Events.PLAYER_PET_STATE_UPDATED,         "PetWindow.UpdatePetStateProxy")
        WindowRegisterEventHandler (windowName, SystemData.Events.PLAYER_NEW_PET_ABILITY_LEARNED,   "PetWindow.AddNewAbilityProxy")
        WindowRegisterEventHandler (windowName, SystemData.Events.PET_AGGRESSIVE,                   "PetWindow.SwitchToAggresiveStance")
        WindowRegisterEventHandler (windowName, SystemData.Events.PET_DEFENSIVE,                    "PetWindow.SwitchToDefensive")
        WindowRegisterEventHandler (windowName, SystemData.Events.PET_PASSIVE,                      "PetWindow.SwitchToPassiveStance")
        
        
        
        petWindow.m_StateTextures                   = stateTextures
        petWindow.m_PetCommands                     = petCommands
        petWindow.m_SlotToBeginAddingPetAbilities   = GameDefs.LAST_PET_ABILITY_SLOT - #petCommands
        petWindow.m_FadeTimeRemaining               = 0
        
        petWindow.m_Windows =
        {
            [STATE]         = DynamicImage:CreateFrameForExistingWindow (windowName.."Stance"),
            [RING]          = DynamicImage:CreateFrameForExistingWindow (windowName.."Ring"),
            [RELEASE]       = ReleasePetButton:CreateFrameForExistingWindow (windowName.."ReleasePet"),
        }
        
        petWindow.m_Windows[RING]:SetTexture (stateTextures.MAIN_TEXTURE)
        petWindow.m_Windows[RING]:SetTextureSlice (stateTextures.BACKGROUND_FRAME_SLICE)
        
        for k, v in ipairs (StanceButtonOrdering)
        do
            local stanceId      = v[1]  -- Stance id also serves as the window Id for internal tracking
            local windowSuffix  = v[2]
            local buttonAnchor  = v[3]
            
            buttonAnchor.RelativeTo = petWindow.m_Windows[RING]:GetName ()
            
            petWindow.m_Windows[stanceId] = PetStanceButton:Create (windowName..windowSuffix, windowName, stateTextures, stanceId, buttonAnchor)
        end             
        
        -- Create the pet's health window under the player window
        -- This really should be creadted in Player
        petWindow.m_UnitFrame = UnitFrames:CreateNewFrame("PetHealthWindow", UnitFrames.UNITFRAME_PLAYER_PET, 1)
        petWindow.m_UnitFrame:SetAnchor( {Point = "bottomright", RelativePoint = "topleft", RelativeTo = "PlayerWindowPortrait", XOffset = -42, YOffset = -8} )        
        
        -- This makes the pet UnitFrame stop disappearing when swapping pets with the engineer
        petWindow.m_UnitFrame:SetAlpha (1.0) 
        
        PetActionBarParameters["parentWindow"] = "Root"
        
        petWindow:CreateActionBar (windowName.."ActionBar", PetActionBarParameters)
        petWindow:ClearPetBarAbilities ()
        petWindow:UpdatePetBarAbilitiesFromAbilityList ()
        petWindow:UpdatePet ()
    end
    
    return petWindow
end

function PetWindow:HasPet ()
    return GameData.Player.Pet.name ~= L""
end

function PetWindow:SetPetCommands ()
    for actionIndex, actionId in ipairs (self.m_PetCommands)
    do
        local slot = GameDefs.LAST_PET_ABILITY_SLOT - actionIndex
        
        local currentActionType, currentActionId = GetHotbarData (slot)
        
        if ((currentActionType ~= GameData.PlayerActions.COMMAND_PET) or (currentActionId ~= actionId))
        then            
            SetHotbarData (slot, GameData.PlayerActions.COMMAND_PET, actionId)
        end
    end
end

function PetWindow:CreateActionBar (barName, barParameters)
    self.m_Actionbar = ActionBars:CreateBar (barName, barParameters)
    
    if (self.m_Actionbar)
    then
        self.m_Actionbar:Show (false)
    end
    
    self:SetPetCommands ()
end

function PetWindow:UpdatePetBarAbilitiesFromAbilityList ()
    if (self:HasPet ())
    then
        local abilityTable = Player.GetAbilityTable (GameData.AbilityType.PET)
        
        for k, v in pairs (abilityTable)
        do
            self:AddNewAbility (v.id)
        end
    end
end

function PetWindow:ClearPetBarAbilities ()
    local slot = self.m_SlotToBeginAddingPetAbilities - 1
    
    while slot >= GameDefs.FIRST_PET_ABILITY_SLOT
    do
        SetHotbarData (slot, GameData.PlayerActions.NONE, 0)
        slot = slot - 1
    end
end

function PetWindow:AddNewAbility (newAbilityId) -- The second parameter (abilityType) would be unused...
    local slot = self.m_SlotToBeginAddingPetAbilities - 1
    
    while slot >= GameDefs.FIRST_PET_ABILITY_SLOT
    do
        local actionType, actionId = GetHotbarData (slot)
        
        if ((actionType == GameData.PlayerActions.NONE) and (actionId == 0))
        then
            SetHotbarData (slot, GameData.PlayerActions.COMMAND_PET_DO_ABILITY, newAbilityId)
            return
        end
        
        slot = slot - 1
    end
end

function PetWindow:OnUpdate (timePassed)

    -- TODO: Fix the tween method until then use this
    if (self.m_FadeTimeRemaining > 0 ) 
    then
        self.m_FadeTimeRemaining = self.m_FadeTimeRemaining - timePassed
        
        if (self.m_FadeTimeRemaining <= 0) 
        then
            self.m_FadeTimeRemaining = 0
            self:Show (false)
            self.m_UnitFrame:Show (false)
            self.m_Actionbar:Show (false)
        end
    else
        -- Don't show the pet window (ever!) if it really shouldn't be shown
        if ((self:HasPet () == false) and self:IsShowing ())
        then
            self:Show (false)
            self.m_UnitFrame:Show (false)
            self.m_Actionbar:Show (false)
        end
    end
end

local function FadeInComponent (frame)
    assert (frame)    
    frame:Show (true, Frame.FORCE_OVERRIDE)
	frame:SetAlpha(1.0)	
  --  frame:StartAlphaAnimation (Window.AnimationType.SINGLE_NO_RESET, 0, PetWindow.BACKGROUND_ALPHA, PetWindow.FADE_IN_TIME, 0, 0)
end

local function FadeOutComponent (frame)
    assert (frame)
    --frame:StartAlphaAnimation (Window.AnimationType.SINGLE_NO_RESET, PetWindow.BACKGROUND_ALPHA, 0, PetWindow.FADE_IN_TIME, 0, 0)
	frame:SetAlpha(0.0)
end

local function StopComponentFade (frame)
    assert (frame)
    frame:StopAlphaAnimation ()
	frame:SetAlpha(1.0)	
    frame:Show (true)
end

function PetWindow:UpdatePet()
    assert (self.m_UnitFrame)
    
    self.m_UnitFrame:SetPlayersPetName (GameData.Player.Pet.name)    
    self.m_UnitFrame:UpdateLevel (GameData.Player.Pet.level)
    
    self:UpdatePetHealth()
    self:UpdatePetState()
    
    -- Fade In/Out the Window
    local hasPet    = self:HasPet ()
    local showing   = self:IsShowing ()
    
    if ((showing == false) and (hasPet == true))
    then
        self:SetPetCommands ()
        
        self.m_UnitFrame:SetPetPortrait()
        
        FadeInComponent (self)
        FadeInComponent (self.m_UnitFrame)
        FadeInComponent (self.m_Actionbar)
    elseif ((showing == true) and (hasPet == false) and (self.m_FadeTimeRemaining == 0))
    then
        FadeOutComponent (self)
        FadeOutComponent (self.m_UnitFrame)
        FadeOutComponent (self.m_Actionbar)
        
        self:ClearPetBarAbilities ()

        self.m_FadeTimeRemaining = PetWindow.FADE_IN_TIME
    elseif ((self.m_FadeTimeRemaining > 0) and (hasPet == true))
    then
        -- If the pet was just killed/desummoned/whatever and the player has the ability
        -- to re-summon the pet instantly, make sure to stop the windows alpha animation, and clear the update timer.    
        self.m_FadeTimeRemaining = 0
        
        self.m_UnitFrame:SetPetPortrait()
        
        StopComponentFade (self)
        StopComponentFade (self.m_UnitFrame)
        StopComponentFade (self.m_Actionbar)
    end
end

function PetWindow:UpdatePetHealth()
    self.m_UnitFrame:UpdateHealth (GameData.Player.Pet.healthPercent)
end

function PetWindow:UpdatePetState(stance)
    stance = stance or GameData.Player.Pet.stance -- Update from GameData if a parameter was not supplied
    
    local textureInfo = self.m_StateTextures[stance]
        
    if (textureInfo)
    then
        local stanceFrame = self.m_Windows[STATE]
        
        -- TODO: SetTextureSlice in the client should know how to resize its window based on the slice info!
        stanceFrame:SetDimensions (textureInfo.w, textureInfo.h)
        stanceFrame:SetTexture (self.m_StateTextures.MAIN_TEXTURE)
        stanceFrame:SetTextureSlice (textureInfo.texSlice, Frame.FORCE_OVERRIDE)
    end
        
    self.m_Windows[AGGRESSIVE]:ToggleState (stance)
    self.m_Windows[DEFENSIVE]:ToggleState (stance)
    self.m_Windows[PASSIVE]:ToggleState (stance)
end

function ReleasePetButton:OnMouseOver (flags, x, y)

end

function ReleasePetButton:OnLButtonUp (flags, x, y)
    CommandPet (GameData.PetCommand.RELEASE)
end

--[[
    Proxy Event Handlers/Forwarders
--]]

function PetWindow.UpdatePetProxy ()
    local petWindow = FrameManager:GetActiveWindow ()
    assert (petWindow)
    petWindow:UpdatePet ()
end

function PetWindow.UpdatePetHealthProxy ()
    local petWindow = FrameManager:GetActiveWindow ()
    assert (petWindow)
    petWindow:UpdatePetHealth ()
end

function PetWindow.UpdatePetStateProxy ()
    local petWindow = FrameManager:GetActiveWindow ()
    assert (petWindow)
    petWindow:UpdatePetState ()
end

function PetWindow.AddNewAbilityProxy (newAbilityId) 
    local petWindow = FrameManager:GetActiveWindow ()
    assert (petWindow)
    petWindow:AddNewAbility (newAbilityId)
end

-- Keybinding event handlers

function PetWindow.SwitchToAggresiveStance ()
    CommandPet (GameData.PetCommand.AGGRESSIVE)
end

function PetWindow.SwitchToDefensive ()
    CommandPet (GameData.PetCommand.DEFENSIVE)
end

function PetWindow.SwitchToPassiveStance ()
    CommandPet (GameData.PetCommand.PASSIVE)
end