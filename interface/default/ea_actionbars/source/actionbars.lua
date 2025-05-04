ActionBar               = FrameForLayoutEditor:Subclass ("ActionBar")
ActionBarPageSelector   = Frame:Subclass ("ActionBarPageSelector")
ActionBarQuickLock      = Frame:Subclass ("QuickAccessLockActionBars")

-- Until item data is present on the client, caching a actionId-to-slotIcon mapping
-- so that if this action is no longer present on the client, the slot just dims out...
-- Defaults to empty...
EA_ActionBars_DataCache = {}

-- Settings variable for action bar specific settings.  Specifically not placed into the UserPrefs
-- code because that is a pita.
EA_ActionBars_Settings = 
{
    showCooldownText = true
}

local SELECTOR_TEXT = 0

function ActionBarPageSelector:Create (windowName, parentName, actionPage)
    local selector = self:CreateFromTemplate (windowName, parentName)
    
    if (selector ~= nil)
    then
        selector.m_Windows = 
        {
            [SELECTOR_TEXT] = Label:CreateFrameForExistingWindow (windowName.."CurrentPageText"),
        }

        FrameManager:ResolveWindowToFrame (windowName.."Up", selector)
        FrameManager:ResolveWindowToFrame (windowName.."Down", selector)

        selector.m_PhysicalPage     = actionPage
        selector.m_PageSequence     = nil
        
        selector:SetPageDisplay (actionPage)
        selector:Show (true)
    end
    
    return selector
end

function ActionBarPageSelector:GetPhysicalPage ()
    return self.m_PhysicalPage
end

function ActionBarPageSelector:SetPageDisplay (physicalPage, logicalPage)
    assert (physicalPage == self.m_PhysicalPage)
    
    self.m_PhysicalPage = physicalPage
    logicalPage         = logicalPage or GetHotbarPage (physicalPage)
    local displayPage   = logicalPage 
    
    -- Search through the display sequence to see if this logicalPage should
    -- display a different value in the text label
    -- If the INDEX of the given logical page matches the PHYSICAL PAGE id of
    -- this selector, then that INDEX should be displayed instead of the logical page.
    -- This is a linear search....however, it's cheap.  The sequence array is small!
    
    if (self.m_PageSequence ~= nil)
    then
        if ((physicalPage == logicalPage) and (self.m_PageSequence[physicalPage] ~= logicalPage))
        then
            SetHotbarPage (physicalPage, self.m_PageSequence[physicalPage])
            return
        end
        
        for physicalBarIndex, logicalBarIndex in ipairs (self.m_PageSequence)
        do
            if ((physicalBarIndex == self.m_PhysicalPage) and (logicalBarIndex == logicalPage))
            then
                displayPage = physicalBarIndex
                break
            end
        end
    end
    
    if (logicalPage ~= self.m_LogicalPage)
    then
        self.m_LogicalPage = logicalPage
        self.m_DisplayPage = displayPage
        self.m_Windows[SELECTOR_TEXT]:SetText (L""..self.m_DisplayPage)
    end
end

--[[
    See documentation in ActionBar:SetPageSelectorSequence
--]]
function ActionBarPageSelector:SetSequence (fullSequence)   
    self.m_PageSequence = fullSequence
end

--[[
    Utility function to convert a desired logical page index to be in-range
    and valid with the hotbar stance swapping functionality.
--]]
function ActionBarPageSelector:ValidateLogicalPage (logicalPage)
    if (logicalPage > GameData.HOTBAR_SWAPPABLE_PAGE_COUNT)
    then
        logicalPage = 1
    elseif (logicalPage <= 0)
    then
        logicalPage = GameData.HOTBAR_SWAPPABLE_PAGE_COUNT
    end
    
    if ((self.m_PageSequence ~= nil) and (self.m_PageSequence[logicalPage] ~= nil))
    then
        logicalPage = self.m_PageSequence[logicalPage]
    end
    
    return logicalPage
end

--[[
    Increment/DecrementPage just make requests to the client to change the current hotbar page.
    There is no guarantee they will succeed.  If they do, then the client will handle pushing the
    new page data into Lua via event broadcasts.
--]]
function ActionBarPageSelector:IncrementPage ()
    assert (self.m_LogicalPage ~= nil)
    SetHotbarPage (self.m_PhysicalPage, self:ValidateLogicalPage (self.m_DisplayPage + 1))
end

function ActionBarPageSelector:DecrementPage ()
    assert (self.m_LogicalPage ~= nil)
    SetHotbarPage (self.m_PhysicalPage, self:ValidateLogicalPage (self.m_DisplayPage - 1))
end

--
-- Quick Lock (globally (un)lock action bars)
--

function ActionBarQuickLock:Create (windowName)
    local lockBox = self:CreateFromTemplate (windowName, "Root")
    
    if (lockBox ~= nil)
    then
        lockBox.m_CheckBox = DynamicImage:CreateFrameForExistingWindow (windowName.."Check")
        lockBox:UpdateFromUserSettings ()
        lockBox:Show (true)
        
        WindowRegisterEventHandler (windowName, SystemData.Events.USER_SETTINGS_CHANGED, "ActionBarQuickLock.SettingsUpdated")
    end
    
    return lockBox
end

function ActionBarQuickLock:OnLButtonUp (flags, mouseX, mouseY)
    SystemData.Settings.Interface.lockActionBars = not SystemData.Settings.Interface.lockActionBars
    BroadcastEvent (SystemData.Events.USER_SETTINGS_CHANGED)
end

function ActionBarQuickLock:OnMouseOver (flags, mouseX, mouseY)
    Tooltips.CreateTextOnlyTooltip (self:GetName (), GetString (StringTables.Default.LABEL_LOCK_ACTION_BARS))
    Tooltips.AnchorTooltip (Tooltips.ANCHOR_WINDOW_VARIABLE)
end

function ActionBarQuickLock:UpdateFromUserSettings ()
    if (self.m_CheckBox ~= nil)
    then
        self.m_CheckBox:Show (SystemData.Settings.Interface.lockActionBars)
    end
end

function ActionBarQuickLock.SettingsUpdated ()
    local quickLockFrame = FrameManager:GetActiveWindow ()
    
    if (quickLockFrame)
    then
        quickLockFrame:UpdateFromUserSettings ()
    end
end



--
-- Action Bars
--

local DecorativeEndCapLookup =
{
    [GameData.Races.DWARF]      = { textureName = "EA_ActionBarCap_DW", leftSlice = "left-cap", rightSlice = "right-cap" },
    [GameData.Races.ORC]        = { textureName = "EA_ActionBarCap_OR", leftSlice = "left-cap", rightSlice = "right-cap" },
    [GameData.Races.GOBLIN]     = { textureName = "EA_ActionBarCap_OR", leftSlice = "left-cap", rightSlice = "right-cap" },
    [GameData.Races.HIGH_ELF]   = { textureName = "EA_ActionBarCap_HE", leftSlice = "left-cap", rightSlice = "right-cap" },
    [GameData.Races.DARK_ELF]   = { textureName = "EA_ActionBarCap_DE", leftSlice = "left-cap", rightSlice = "right-cap" },
    [GameData.Races.EMPIRE]     = { textureName = "EA_ActionBarCap_EM", leftSlice = "left-cap", rightSlice = "right-cap" },
    [GameData.Races.CHAOS]      = { textureName = "EA_ActionBarCap_CH", leftSlice = "left-cap", rightSlice = "right-cap" },
    ["Default"]                 = { textureName = "EA_ActionBarCap_EM", leftSlice = "left-cap", rightSlice = "right-cap" },
}

ActionBarLeftEndcap     = FrameForLayoutEditor:Subclass ("EA_ActionBarLeftCap")
ActionBarRightEndcap    = ActionBarLeftEndcap:Subclass ("EA_ActionBarRightCap")

function ActionBarLeftEndcap:Create (windowName, parentWindow, textureName, sliceName)
    local cap = self:CreateFromTemplate (windowName, parentWindow)
    
    if (cap)
    then
        DynamicImageSetTexture( cap:GetName(), textureName, 0, 0 )
        DynamicImageSetTextureSlice( cap:GetName(), sliceName )
        cap:Show (true)
    end
    
    return cap
end

function ActionBarLeftEndcap:OnInitializeCustomSettings ()
    if (ActionBarClusterManager)
    then
        ActionBarClusterManager:OnInitializeCustomSettingsForFrame (self)
    end
end

function ActionBar:CreateCaps ()
    local barName       = self:GetName ()    
    local endcapData    = DecorativeEndCapLookup[GameData.Player.race.id]

    if (endcapData == nil)
    then
        endcapData = DecorativeEndCapLookup["Default"]
    end

    if (endcapData ~= nil)
    then
        self.m_LeftEndcap   = ActionBarLeftEndcap:Create (barName.."LeftCap", "Root", endcapData.textureName, endcapData.leftSlice)
        self.m_RightEndcap  = ActionBarRightEndcap:Create (barName.."RightCap", "Root", endcapData.textureName, endcapData.rightSlice)
    end
end

--[[
    ActionBar Button Factory Lookups
    Allows the registration of string -> action button factories
    When an actionbar is created, if a specific button factory string is mapped to a Factory object
    then that factory is used to create the buttons for the action bar.
    Otherwise, the default ActionButton factory is used to create the bar's buttons.
--]]
function ActionBar:RegisterButtonFactory (factoryName, factoryObject)
    assert (factoryName ~= nil)
    assert (factoryObject ~= nil)
    assert (type (factoryName) == "string")
    assert (type (factoryObject) == "table")
    
    if (self.m_ButtonFactories == nil)
    then
        self.m_ButtonFactories = {}
    end
    
    self.m_ButtonFactories[factoryName] = factoryObject
end

function ActionBar:GetButtonFactory (factoryName)
    if ((factoryName == nil) or (self.m_ButtonFactories == nil) or (self.m_ButtonFactories[factoryName] == nil))
    then
        return ActionButton
    end
    
    return self.m_ButtonFactories[factoryName]
end

--[[
    ActionBar Constructor
    
    Creates an action bar with the given parameters and shows it.  Does not anchor the bar to any particular location on the
    screen.  (So it will most likely show at its default location of the topleft corner of the root window.
    
    NOTE: 
    
    If barParameters contains keys called "firstSlot" and "lastSlot" buttonCount and columnCount refer to 
    start_slot and end_slot respectively, otherwise, they refer to the actual button and column counts.
--]]

local DefaultButtonModificationSettings =
{
    [ActionButton.MODIFICATION_TYPE_PICKUP]     = true,
    [ActionButton.MODIFICATION_TYPE_SET_DATA]   = true,
}

function ActionBar:Create (windowName, barParameters)
    local actionPage            = barParameters["barId"]
    local showBackground        = barParameters["background"]
    local selectorMode          = barParameters["selector"]
    local showDecorativeCaps    = barParameters["caps"]  
    local showEmptySlots        = barParameters["showEmptySlots"]
    local buttonCount           = barParameters["firstSlot"] or barParameters["buttonCount"]
    local columnCount           = barParameters["lastSlot"] or barParameters["columns"]
    local buttonFactory         = self:GetButtonFactory (barParameters["buttonFactory"])
    local parentWindowName      = barParameters["parentWindow"]
    local modificationSettings  = barParameters["modificationSettings"] or DefaultButtonModificationSettings  
    
    local bar = self:CreateFromTemplate (windowName, parentWindowName)
    
    if (bar == nil or buttonCount == nil or buttonCount <= 0 or columnCount == nil or columnCount <= 0)
    then
        return (nil)
    end
    
    if (ActionBarClusterManager and ActionBarClusterManager.AddClusterSettingsTable)
    then
        ActionBarClusterManager.AddClusterSettingsTable (windowName, barParameters)
    end
    
    -- These values need to be stored, so that ActionBar:AnchorButtons can be called in OnInitializeCustomSettings()
    bar.m_ButtonXPadding        = barParameters["buttonXPadding"]
    bar.m_ButtonXSpacing        = barParameters["buttonXSpacing"]
    bar.m_ButtonYPadding        = barParameters["buttonYPadding"]
    bar.m_ButtonYSpacing        = barParameters["buttonYSpacing"]
    bar.m_BarScale              = barParameters["scale"]
    
    bar.m_Buttons           = {}
    bar.m_ActionPage        = actionPage
    bar.m_ShowBackground    = showBackground
    bar.m_Background        = FullResizeImage:CreateFrameForExistingWindow (bar:GetName ().."Background")
    bar.m_PageSelectorMode  = selectorMode
    bar.m_ShowEmptySlots    = showEmptySlots
    bar.m_ShownSlotsCount   = 0
    
    local firstSlot     = ((actionPage - 1) * GameData.HOTBAR_BUTTONS_PER_BAR) + 1
    
    if (barParameters["firstSlot"] == nil)
    then
        bar.m_ButtonCount       = buttonCount
        bar.m_ColumnCount       = columnCount
    else
        local startSlot         = buttonCount
        local endSlot           = columnCount
        
        bar.m_ButtonCount       = endSlot - startSlot
        bar.m_ColumnCount       = bar.m_ButtonCount
        firstSlot               = startSlot
    end
    
    for buttonIndex = 1, bar.m_ButtonCount
    do
        local slot = (firstSlot + buttonIndex) - 1
        bar.m_Buttons[buttonIndex] = buttonFactory:Create (windowName.."Action"..buttonIndex, windowName, slot, modificationSettings)
        ActionBars:AssociateSlotWithBar (slot, buttonIndex, bar)
    end    
    
    if (bar.m_PageSelectorMode ~= ActionBarConstants.HIDE_PAGE_SELECTOR)
    then       
        bar.m_PageSelectorWindow = ActionBarPageSelector:Create (windowName.."PageSelector", windowName, actionPage)
    end
    
    if (showDecorativeCaps == ActionBarConstants.SHOW_DECORATIVE_CAPS)
    then
        bar:CreateCaps ()
    end
    
    bar:AnchorButtons ()
    bar:Show (true)
    bar:UpdateShownSlots ()
    
    bar.m_Background:Show (bar.m_ShowBackground == ActionBarConstants.SHOW_BACKGROUND)
    if (bar.m_BarScale)
    then
        bar:SetRelativeScale (bar.m_BarScale)
    end

    -- Ok, back to sanity...    
    return bar
end

function ActionBar:AnchorButtons ()
    if (self.m_Buttons == nil)
    then
        return
    end
    
    local buttonXPadding        = self.m_ButtonXPadding
    local buttonXSpacing        = self.m_ButtonXSpacing
    local buttonYPadding        = self.m_ButtonYPadding
    local buttonYSpacing        = self.m_ButtonYSpacing
    
    local buttons           = self.m_Buttons
    local buttonCount       = #buttons
    local columnCount       = self.m_ColumnCount
    local windowName        = self:GetName ().."Action"
    
    local anchor =
    {
        Point           = "topleft",
        RelativePoint   = "topleft",
        RelativeTo      = self:GetName (),
        XOffset         = buttonXPadding,
        YOffset         = buttonYPadding,
    }
    
    local buttonXSpacingCumulative = 0
    local buttonYSpacingCumulative = 0
    
    for buttonIndex = 1, buttonCount
    do
        buttons[buttonIndex]:SetAnchor (anchor)
        
        local nextIndex = buttonIndex + 1
        local remainder = math.fmod (nextIndex, columnCount)

        if ((remainder == 1) or (columnCount == 1))
        then
            --- Start a new row...
            anchor.Point             = "bottomleft"
            anchor.RelativePoint     = "topleft"
            anchor.RelativeTo        = windowName..(nextIndex - columnCount)
            anchor.XOffset           = 0
            anchor.YOffset           = buttonYSpacing
            
            buttonYSpacingCumulative = buttonYSpacingCumulative + buttonYSpacing
        else
            -- Anchor this button to the right side of its predecessor
            anchor.Point             = "right"
            anchor.RelativePoint     = "left"
            anchor.RelativeTo        = windowName..buttonIndex
            anchor.XOffset           = buttonXSpacing
            anchor.YOffset           = 0
            
            buttonXSpacingCumulative = buttonXSpacingCumulative + buttonXSpacing
        end        
    end
    
    local rowCount = buttonCount / columnCount
    local buttonWidth, buttonHeight = buttons[1]:GetDimensions()
    local pageSelectorWidth = 0
    if( self.m_PageSelectorWindow and self.m_PageSelectorMode ~= ActionBarConstants.HIDE_PAGE_SELECTOR )
    then
        pageSelectorWidth, _ = self.m_PageSelectorWindow:GetDimensions()
    else
        pageSelectorWidth = buttonXPadding
    end
    
    local finalWidth  = (columnCount * buttonWidth)  + buttonXSpacingCumulative + buttonXPadding + pageSelectorWidth
    local finalHeight = (rowCount    * buttonHeight) + buttonYSpacingCumulative + (buttonYPadding * 2)
    
    -- Set the dimensions of the bar to the final width and height so the buttons are clickable
    self:SetDimensions( finalWidth, finalHeight, Frame.FORCE_OVERRIDE )
    
    if (self.m_PageSelectorWindow ~= nil)
    then
        if (self.m_PageSelectorMode == ActionBarConstants.SHOW_PAGE_SELECTOR_RIGHT)
        then           
            self.m_PageSelectorWindow:SetAnchor ({Point = "topright", RelativePoint = "topleft", RelativeTo = windowName..buttonCount, XOffset = -2, YOffset = -2})
        elseif (self.m_PageSelectorMode == ActionBarConstants.SHOW_PAGE_SELECTOR_LEFT)
        then
            -- Welcome to crazy town!  Showing the page selector on the left requires that the page selector be anchored directly
            -- to self:GetName, and NOT the button.  Then the anchor on button1 gets broken and reanchored to the page selector.
            --
            -- This will allow the window to be the correct size, and the page selector not be hangin off the left edge of the bar.
            -- Ahhh, Crazy Town, I love you.
            
            -- Btw, this still doesn't work quite right, but it's better than it was before...where the selector could not
            -- even be clicked on...
            
            self.m_PageSelectorWindow:SetAnchor ({Point = "left", RelativePoint = "left", RelativeTo = self:GetName (), XOffset = buttonXPadding, YOffset = buttonYPadding - 2})
            buttons[1]:SetAnchor ({Point = "right", RelativePoint = "left", RelativeTo = self.m_PageSelectorWindow:GetName (), XOffset = 0, YOffset = 0})
        end
    end    
    
    -- Force Process the anchors on the bar so everything looks right
    self:ForceProcessAnchors ()
end

function ActionBar:UpdateNumberButtons( barParameters )
    local buttons               = self.m_Buttons
    local createdButtonCount    = #buttons
    local buttonFactory         = self:GetButtonFactory(barParameters["buttonFactory"])
    local windowName            = self:GetName()
    local modificationSettings  = barParameters["modificationSettings"] or DefaultButtonModificationSettings  
    local firstSlot             = ((self.m_ActionPage - 1) * GameData.HOTBAR_BUTTONS_PER_BAR) + 1
    if( createdButtonCount < self.m_ButtonCount )
    then
        for buttonIndex = createdButtonCount + 1, self.m_ButtonCount
        do
            local slot = (firstSlot + buttonIndex) - 1
            buttons[buttonIndex] = buttonFactory:Create (windowName.."Action"..buttonIndex, windowName, slot, modificationSettings)
            ActionBars:AssociateSlotWithBar(slot, buttonIndex, self)
        end
    elseif( createdButtonCount > self.m_ButtonCount )
    then
        for buttonIndex = self.m_ButtonCount + 1, createdButtonCount
        do
            local slot = (firstSlot + buttonIndex) - 1
            FrameManager:Remove(buttons[buttonIndex]:GetName())
            DestroyWindow( buttons[buttonIndex]:GetName() )
            buttons[buttonIndex] = nil
            ActionBars:AssociateSlotWithBar(slot, nil, nil)
        end
    end
    
    if( createdButtonCount ~= self.m_ButtonCount )
    then
        self:AnchorButtons()
        self:Show(true)
        self:UpdateShownSlots()
    end
end

function ActionBar:ShowCaps (showState)
    if ((showState == true) and ((self.m_LeftEndcap == nil) or (self.m_RightEndcap == nil)))
    then
        self:CreateCaps ()
    end
    
    if (self.m_LeftEndcap ~= nil)
    then
        self.m_LeftEndcap:Show (showState)
    end
    
    if (self.m_RightEndcap ~= nil)
    then
        self.m_RightEndcap:Show (showState)
    end
end

function ActionBar:SetPageSelectorMode ( mode )
    local pageSelector = self.m_PageSelectorWindow

    self.m_PageSelectorMode = mode
    if (pageSelector ~= nil)
    then
        pageSelector:Show( mode ~= ActionBarConstants.HIDE_PAGE_SELECTOR )
    elseif( mode ~= ActionBarConstants.HIDE_PAGE_SELECTOR )
    then
        self.m_PageSelectorWindow = ActionBarPageSelector:Create(self:GetName().."PageSelector", self:GetName(), self.m_PhysicalPage or self.m_ActionPage)
        self.m_PageSelectorWindow:Show( true )
    end
end

function ActionBar:SetButtonData( buttonId, actionType, actionId )
    if (buttonId <= self.m_ButtonCount)
    then
        self.m_Buttons[buttonId]:SetActionData( actionType, actionId )
    end
end

function ActionBar:GetButtonData (buttonId)
    if (buttonId <= self.m_ButtonCount)
    then
        local _, actionType, actionId, _ = self.m_Buttons[buttonId]:GetActionData ()
        
        return actionType, actionId
    end
end

function ActionBar:UpdatePageDisplay (physicalPage, logicalPage)
    local pageSelector = self.m_PageSelectorWindow
    
    if (pageSelector ~= nil)
    then
        physicalPage = physicalPage or self.m_ActionPage
        pageSelector:SetPageDisplay (physicalPage, logicalPage)
    end
end

function ActionBar:UpdateShownSlots ()
    for _, button in ipairs (self.m_Buttons)
    do
        button:UpdateIsShowing (self)
    end
end

function ActionBar:UpdateShowBackground ()
    self.m_Background:Show (self.m_ShowBackground == ActionBarConstants.SHOW_BACKGROUND)
end

function ActionBar:UpdateShownRefCount (incrementValue)
    self.m_ShownSlotsCount = self.m_ShownSlotsCount + incrementValue
end

--[[
    Causes the Page Selector to display a different logical page number
    when the logical page it *would* display matches a value in the fullSequence
    table that maps to a different physical page index.
    
    Example:
    self.m_BarId = 1            -- The physical page of this bar.
    fullSequence = { 5, 6 }
    
    This means that when this physical bar is about to display logical bar 1
    it should actually display logical bar 5, but the current bar display text
    should read 1.  When the user advances to the next bar it will display 2, not
    6.  When the user reaches bar 5, it will actually display logical bar 5.
    
    So, the index in fullSequence is a physical bar id.  And the value at that index
    is the logical bar to set this bar to.
--]]
function ActionBar:SetPageSelectorSequence (fullSequence)
    local pageSelector = self.m_PageSelectorWindow
    
    if (pageSelector ~= nil)
    then
        pageSelector:SetSequence (fullSequence)
    end
end

function ActionBar:UpdateSlotEnabledState( buttonId, isSlotEnabled, isTargetValid, isSlotBlocked )
    if (buttonId <= self.m_ButtonCount)
    then
        self.m_Buttons[buttonId]:UpdateEnabledState( isSlotEnabled, isTargetValid, isSlotBlocked )
    end
end

function ActionBar:Update (timeElapsed, updateCooldown, updateInventory, previousResource, currentResource)
    for buttonId, button in ipairs (self.m_Buttons)
    do
        button:Update (timeElapsed, updateCooldown, updateInventory, previousResource, currentResource)
    end
end

function ActionBar:UpdateIcons (actionType, actionId)
    for buttonId, button in ipairs (self.m_Buttons)
    do
        local _, buttonActionType, buttonActionId = button:GetActionData ()
        
        if ((buttonActionType == actionType) and (buttonActionId == actionId))
        then
            button:UpdateIcon ()
        end
    end    
end

function ActionBar:UpdateKeyBindings ()
    for buttonId, button in ipairs (self.m_Buttons)
    do
        button:UpdateKeyBindingText ()
    end
end

function ActionBar:UpdateShowCooldownText ()
    for buttonId, button in ipairs (self.m_Buttons)
    do
        button:UpdateShowCooldownText ()
    end
end

function ActionBar:ShowEmptySlots ()
    return self.m_ShowEmptySlots
end

function ActionBar:OnInitializeCustomSettings ()
    if (ActionBarClusterManager)
    then
        ActionBarClusterManager:OnInitializeCustomSettingsForFrame (self)
        self:RestoreDefaultCustomization()
    end
    
end

function ActionBar:RestoreDefaultCustomization()
    self:AnchorButtons()
    
    if(self.m_BarScale)
    then
        self:SetScale(self.m_BarScale*InterfaceCore.GetScale())
    else
        self:SetScale(InterfaceCore.GetScale())
    end
end

--[[

    ActionBar Management System

--]]

ActionBars = 
{
    m_Bars                  = {},
    m_NeedsCooldownUpdate   = false,
    m_NeedsInventoryUpdate  = true,
    m_PreviousResource      = 0,
    m_CurrentResource       = 0,
    m_UpdatedMacroId        = 0,
    m_CastTimers            = {},
    m_CurrentActiveAction   = 0,
    m_ActiveActions         = {},
    m_ShowSlotsForEditing   = false,
    m_SlotToBarMapping      = {},
}

function ActionBars.Initialize ()   
    RegisterEventHandler (SystemData.Events.PLAYER_HOT_BAR_UPDATED,                 "ActionBars.UpdateActionButtons")
    RegisterEventHandler (SystemData.Events.PLAYER_CAREER_RESOURCE_UPDATED,         "ActionBars.CareerResourceUpdated")
    RegisterEventHandler (SystemData.Events.PLAYER_SINGLE_ABILITY_UPDATED,          "ActionBars.UpdateAbilityIconsProxy")
    RegisterEventHandler (SystemData.Events.MACRO_UPDATED,                          "ActionBars.UpdateMacroIconsProxy")
    RegisterEventHandler (SystemData.Events.PLAYER_PET_STATE_UPDATED,               "ActionBars.UpdatePetState")
    RegisterEventHandler (SystemData.Events.PLAYER_COOLDOWN_TIMER_SET,              "ActionBars.SetCooldownFlag")
    RegisterEventHandler (SystemData.Events.PLAYER_HOT_BAR_ENABLED_STATE_CHANGED,   "ActionBars.UpdateSlotEnabledState")
    RegisterEventHandler (SystemData.Events.PLAYER_ABILITY_TOGGLED,                 "ActionBars.AbilityToggledProxy")
    RegisterEventHandler (SystemData.Events.PLAYER_BEGIN_CAST,                      "ActionBars.CastTimerProxy")
    RegisterEventHandler (SystemData.Events.PLAYER_END_CAST,                        "ActionBars.EndCastTimerProxy")
    RegisterEventHandler (SystemData.Events.PLAYER_HOT_BAR_PAGE_UPDATED,            "ActionBars.UpdateActivePageDisplay")
    RegisterEventHandler (SystemData.Events.PLAYER_EQUIPMENT_SLOT_UPDATED,          "ActionBars.SetInventoryUpdateFlag")
    RegisterEventHandler (SystemData.Events.PLAYER_TROPHY_SLOT_UPDATED,             "ActionBars.SetInventoryUpdateFlag")
    RegisterEventHandler (SystemData.Events.PLAYER_INVENTORY_SLOT_UPDATED,          "ActionBars.SetInventoryUpdateFlag")
    RegisterEventHandler (SystemData.Events.PLAYER_QUEST_ITEM_SLOT_UPDATED,         "ActionBars.SetInventoryUpdateFlag")    
    RegisterEventHandler (SystemData.Events.USER_SETTINGS_CHANGED,                  "ActionBars.OnUserSettingsChanged")
end

function ActionBars.Shutdown ()
    UnregisterEventHandler (SystemData.Events.PLAYER_HOT_BAR_UPDATED,               "ActionBars.UpdateActionButtons")
    UnregisterEventHandler (SystemData.Events.PLAYER_CAREER_RESOURCE_UPDATED,       "ActionBars.CareerResourceUpdated")
    UnregisterEventHandler (SystemData.Events.PLAYER_SINGLE_ABILITY_UPDATED,        "ActionBars.UpdateAbilityIconsProxy")
    UnregisterEventHandler (SystemData.Events.MACRO_UPDATED,                        "ActionBars.UpdateMacroIconsProxy")
    UnregisterEventHandler (SystemData.Events.PLAYER_PET_STATE_UPDATED,             "ActionBars.UpdatePetState")
    UnregisterEventHandler (SystemData.Events.PLAYER_COOLDOWN_TIMER_SET,            "ActionBars.SetCooldownFlag")
    UnregisterEventHandler (SystemData.Events.PLAYER_HOT_BAR_ENABLED_STATE_CHANGED, "ActionBars.UpdateSlotEnabledState")
    UnregisterEventHandler (SystemData.Events.PLAYER_ABILITY_TOGGLED,               "ActionBars.AbilityToggledProxy")
    UnregisterEventHandler (SystemData.Events.PLAYER_BEGIN_CAST,                    "ActionBars.CastTimerProxy")
    UnregisterEventHandler (SystemData.Events.PLAYER_END_CAST,                      "ActionBars.EndCastTimerProxy")    
    UnregisterEventHandler (SystemData.Events.PLAYER_HOT_BAR_PAGE_UPDATED,          "ActionBars.UpdateActivePageDisplay")
    UnregisterEventHandler (SystemData.Events.PLAYER_EQUIPMENT_SLOT_UPDATED,        "ActionBars.SetInventoryUpdateFlag")
    UnregisterEventHandler (SystemData.Events.PLAYER_TROPHY_SLOT_UPDATED,           "ActionBars.SetInventoryUpdateFlag")
    UnregisterEventHandler (SystemData.Events.PLAYER_INVENTORY_SLOT_UPDATED,        "ActionBars.SetInventoryUpdateFlag")
    UnregisterEventHandler (SystemData.Events.PLAYER_QUEST_ITEM_SLOT_UPDATED,       "ActionBars.SetInventoryUpdateFlag")
    UnregisterEventHandler (SystemData.Events.USER_SETTINGS_CHANGED,                "ActionBars.OnUserSettingsChanged")
end

--[[
    Wrapper around external action bar creation
    
    Accepts a table with the same key/value pairs as the action bar settings tables in the
    ActionBarClusterSettings table and forwards that on to ActionBar:Create.  
    Stores the newly created action bar in an internal bar management table.
    
    Does not anchor the bar to any particular location on the screen.  
    (So it will most likely show at its default location of the topleft corner of the root window.)
    
    NOTE: 
    
    If barId is greater than GameData.HOTBAR_PAGE_COUNT:
        - buttonCount and columnCount refer to start_slot and end_slot respectively
        - selectorMode will be forced to ActionBarConstants.HIDE_PAGE_SELECTOR 
        - showDecorativeEndCaps will be forced to ActionBarConstants.HIDE_DECORATIVE_CAPS
        - The bar will not be indexed by its id, it will indexed by its bar name.  This is to allow multiple
          hotbars referencing the same bar id without overwriting each other, however continue to allow
          bars to be indexed by their ids for the selector page-swapping.

    If barName is a table, the rest of the parameters will be ignored and parameters from the table will be used.
    The table key/value pairs should match the format given in LayoutModes.lua.
--]]
function ActionBars:CreateBar (barWindowName, barParameters)
    assert (type (barParameters)            == "table")
    assert (barParameters["barId"]          ~= nil)
    assert (type (barParameters["barId"])   == "number")
        
    local barId                 = barParameters["barId"]
    local theNewlyCreatedBarKey = nil

    if ((barId > 0) and (barId <= GameData.HOTBAR_SWAPPABLE_PAGE_COUNT))
    then
        theNewlyCreatedBarKey = barId
    else
        theNewlyCreatedBarKey = barWindowName
    end
    
    self.m_Bars[theNewlyCreatedBarKey] = ActionBar:Create (barWindowName, barParameters)
    return self.m_Bars[theNewlyCreatedBarKey]
end

function ActionBars:CreateQuickLock (quickLockName)
    -- This currently locks ALL action buttons, not just this bar's buttons.  It should stay that way, but it probably won't...
    self.m_QuickLockButton = ActionBarQuickLock:Create (quickLockName)
end

function ActionBars:DestroyQuickLock ()
    if (self.m_QuickLockButton)
    then
        self.m_QuickLockButton:Destroy ()
        self.m_QuickLockButton = nil
    end
end

--[[
    Releases action bar resources...
--]]
function ActionBars:DestroyBars ()
    for barId, bar in pairs (self.m_Bars)
    do
        bar:Destroy ()
    end
    
    self.m_Bars = {}
end

--[[
    Obtains the single physical bar represented by the barId
--]]
function ActionBars:GetBar (physicalBarId)
    if (self.m_Bars)
    then
        return self.m_Bars[physicalBarId]
    end
    
    return nil
end

--[[
    Informs the action bar system that the user would like to pick up the desired button.
    Probably to swap it to another slot.
--]]
function ActionBars:SetPickupButton (button)
    self.m_PickupButton = button
end

--[[
    Obtains the desired pickup button, can be nil if the user hasn't tried to pick anything up
--]]
function ActionBars:GetPickupButton ()
    return self.m_PickupButton
end

--[[
    Actual event handler, time-based update for all action bars tracked by the system
--]]
function ActionBars.UpdateProxy (timeElapsed)
    ActionBars:Update (timeElapsed)
end

--[[
    Object oriented event handler, time-based update for all action bars tracked by the system
--]]
function ActionBars:Update (timeElapsed)
    local updateCooldown    = self.m_NeedsCooldownUpdate 
    local updateInventory   = self.m_NeedsInventoryUpdate
    local previousResource  = self.m_PreviousResource
    local currentResource   = self.m_CurrentResource
    local updatedMacroId    = self.m_UpdatedMacroId
    local previousShown     = self.m_ShowSlotsForEditing
        
    for barId, bar in pairs (self.m_Bars)
    do
        bar:Update (timeElapsed, updateCooldown, updateInventory, previousResource, currentResource, updatedMacroId)
    end
    
    for abilityId, timer in pairs (self.m_CastTimers)
    do
        if (timer > 0)
        then
            timer = timer - timeElapsed

            if (timer <= 0)
            then
                timer = 0
            end            

            self.m_CastTimers[abilityId] = timer
        end
    end
    
    self.m_NeedsCooldownUpdate  = false
    self.m_NeedsInventoryUpdate = false
    self.m_PreviousResource     = self.m_CurrentResource
    self.m_UpdatedMacroId       = 0
    self.m_ShowSlotsForEditing  = Cursor.IconOnCursor ()
    
    self:UpdateShownSlots (previousShown)
end

--[[
    The slot is actually the physical hotbar slot.
--]]
function ActionBars.UpdateActionButtons( slot, actionType, actionId )
    local barObject, buttonId = ActionBars:BarAndButtonIdFromSlot (slot)
        
    -- It's possible for barObject to be nil, it just means that this particular bar hasn't been created.
    if (barObject ~= nil)
    then
        barObject:SetButtonData( buttonId, actionType, actionId )
    end
end

function ActionBars.UpdateAbilityIconsProxy (abilityId, abilityType)
    ActionBars:UpdateIcons (GameData.PlayerActions.DO_ABILITY, abilityId)
end

function ActionBars.OnUserSettingsChanged ()
    ActionBars:UpdateKeyBindings ()
    ActionBars:UpdateShowCooldownText ()
end

function ActionBars.UpdateMacroIconsProxy (macroId)
    ActionBars:UpdateIcons (GameData.PlayerActions.DO_MACRO, macroId)
end

function ActionBars.UpdatePetState () -- TODO: Could use params
    ActionBars.m_PetMovementState   = GameData.Player.Pet.movement
    ActionBars.m_PetStanceState     = GameData.Player.Pet.stance
end

function ActionBars:GetPetState ()
    return self.m_PetMovementState, self.m_PetStanceState
end

function ActionBars:UpdateIcons (actionType, actionId)
    for barId, bar in pairs (self.m_Bars)
    do
        bar:UpdateIcons (actionType, actionId)
    end
end

function ActionBars.UpdateSlotEnabledState (slot, isSlotEnabled, isTargetValid, isSlotBlocked)
    local barObject, buttonId = ActionBars:BarAndButtonIdFromSlot (slot)
       
    -- It's possible for barObject to be nil, it just means that this particular bar hasn't been created.
    if (barObject ~= nil)
    then
        barObject:UpdateSlotEnabledState( buttonId, isSlotEnabled, isTargetValid, isSlotBlocked )
    end    
end

function ActionBars.AbilityToggledProxy (actionId, isActive)   
    ActionBars.m_ActiveActions[actionId] = isActive
end

function ActionBars.CastTimerProxy (actionId, isChannel, desiredCastTime, averageLatency)
    if (desiredCastTime > 0)
    then
        ActionBars.m_CastTimers[actionId]   = desiredCastTime
        ActionBars.m_CurrentActiveAction    = actionId
    elseif (ActionBars.m_CastTimers[actionId])
    then
        ActionBars.m_CastTimers[actionId]   = 0
        ActionBars.m_CurrentActiveAction    = 0
    end
end

function ActionBars.EndCastTimerProxy (isCancel)
    if (ActionBars.m_CurrentActiveAction > 0)
    then
        ActionBars.m_CastTimers[ActionBars.m_CurrentActiveAction] = 0
        ActionBars.m_CurrentActiveAction = 0
    end
end

function ActionBars:IsActionActive (actionId)
    return (self.m_ActiveActions[actionId] == true)
end

function ActionBars:GetActionCastTimer (actionId)
    local timer = self.m_CastTimers[actionId]
    
    if (timer ~= nil)
    then
        return (timer)
    end
    
    return (0)
end

function ActionBars.SetCooldownFlag ()
    ActionBars.m_NeedsCooldownUpdate = true
end

function ActionBars.SetInventoryUpdateFlag ()
    ActionBars.m_NeedsInventoryUpdate = true
end

function ActionBars:UpdateKeyBindings ()
    for barId, bar in pairs (self.m_Bars)
    do
        bar:UpdateKeyBindings ()
    end
end

function ActionBars.CareerResourceUpdated (oldValue, newValue)
    ActionBars.m_CurrentResource = newValue
end

local function CreatePageSelectorTooltip (stringTableId)
    Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name, GetString (stringTableId))
    Tooltips.AnchorTooltip (Tooltips.ANCHOR_WINDOW_LEFT)
end

function ActionBars.OnMouseoverHotbarPageUp ()
    CreatePageSelectorTooltip (StringTables.Default.TOOLTIP_NEXT_ACTION_BAR)
end

function ActionBars.OnMouseoverHotbarPageDown ()
    CreatePageSelectorTooltip (StringTables.Default.TOOLTIP_PREV_ACTION_BAR)
end

function ActionBars.HotbarPageUpProxy ()
    local pageSelector = FrameManager:GetMouseOverWindow ()
    pageSelector:IncrementPage ()
end

function ActionBars.HotbarPageDownProxy ()
    local pageSelector = FrameManager:GetMouseOverWindow ()
    pageSelector:DecrementPage ()
end

function ActionBars.UpdateActivePageDisplay (physicalPage, logicalPage)
    local barObject = ActionBars:GetBar (physicalPage)
    
    if (barObject)
    then
        barObject:UpdatePageDisplay (physicalPage, logicalPage)
    end
end

function ActionBars:UpdateShownSlots (previousShown)
    if (previousShown ~= self.m_ShowSlotsForEditing)
    then        
        for barKey, bar in pairs (self.m_Bars)
        do
            -- Do not show or hide buttons for bars like the stance/granted ability bars.
            if (type (barKey) == "number")
            then
                bar:UpdateShownSlots ()
            end
        end
    end
end

function ActionBars:ShouldShowButtonsForEditing ()
    return (self.m_ShowSlotsForEditing == true)
end

function ActionBars:AssociateSlotWithBar (slot, buttonIndex, bar)
    self.m_SlotToBarMapping[slot] = { m_Bar = bar, m_ButtonId = buttonIndex }
end

function ActionBars:BarAndButtonIdFromSlot (slot)
    local entry = self.m_SlotToBarMapping[slot]
    
    if (entry)
    then
        return entry.m_Bar, entry.m_ButtonId
    end
end

-- Sets the default state for all the cooldown text on the action buttons based on the saved setting: EA_ActionBars_Settings.showCooldownText
function ActionBars:UpdateShowCooldownText ()
    for barKey, bar in pairs (self.m_Bars)
    do
        bar:UpdateShowCooldownText ()
    end    
end