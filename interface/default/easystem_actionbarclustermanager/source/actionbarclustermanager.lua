--[[
    ActionBarClusterSettings 
--]]

-- Don't put functions in this table, let the settings manager table have the functions.
-- LuaPlus does not enjoy saving tables with functions...instead it generates invalid Lua script.
-- This will have to be addressed eventually.
ActionBarClusterSettings    = {}
ActionBarClusterPositions   = {}

do
    for bar = 1, CREATED_HOTBAR_COUNT
    do
        ActionBarClusterSettings[ACTION_BAR_NAME..bar] =
        {
            ["barId"]                   = bar,
            ["show"]                    = (bar == 1),
            ["caps"]                    = (bar == 1),
            ["buttonCount"]             = ActionBarConstants.BUTTONS,
            ["columns"]                 = ActionBarConstants.COLUMNS,
            ["background"]              = ActionBarConstants.SHOW_BACKGROUND,
            ["selector"]                = ActionBarConstants.SHOW_PAGE_SELECTOR_RIGHT,
            ["buttonXPadding"]          = 6,
            ["buttonYPadding"]          = 5,
            ["buttonXSpacing"]          = 0,
            ["buttonYSpacing"]          = 0,
            ["showEmptySlots"]          = ActionBarConstants.SHOW_EMPTY_SLOTS,
            ["buttonFactory"]           = "ActionButton",
            
            -- The scale fix in the interface didn't work so well for widescreen resolutions.
            -- So, now there's a fix in hotbars to scale each one to 93% of its full size.
            -- That should fix the overlap issue for multiple hotbar displays...for now.
            -- Scale is applied to the action bar, its page selector, and its end caps in ActionBarClusterManager:UpdateFrameSettings.
            -- Note that the scale provided here is multiplied by the interface core scale.
            ["scale"]                   = 0.93, 
            ["modificationSettings"]    = 
            {
                [ActionButton.MODIFICATION_TYPE_PICKUP]     = true,
                [ActionButton.MODIFICATION_TYPE_SET_DATA]   = true,
            },
        }
    end
    
    ActionBarClusterSettings[GRANTED_ABILITY_BAR_NAME] =
    {
        ["barId"]                   = GameDefs.GRANTED_ABILITY_HOTBAR_ID,
        ["show"]                    = false,
        ["caps"]                    = ActionBarConstants.HIDE_DECORATIVE_CAPS,
        ["firstSlot"]               = GameDefs.FIRST_GRANTED_ABILITY_SLOT,
        ["lastSlot"]                = GameDefs.LAST_GRANTED_ABILITY_SLOT,
        ["background"]              = ActionBarConstants.HIDE_BACKGROUND,
        ["selector"]                = ActionBarConstants.HIDE_PAGE_SELECTOR,
        ["buttonXPadding"]          = 0,
        ["buttonYPadding"]          = 0,
        ["buttonXSpacing"]          = 4,
        ["buttonYSpacing"]          = 4,
        ["showEmptySlots"]          = ActionBarConstants.HIDE_EMPTY_SLOTS,
        ["buttonFactory"]           = "ActionButton",
        ["scale"]                   = 0.75,
        ["modificationSettings"]    = 
        {
            [ActionButton.MODIFICATION_TYPE_PICKUP]     = true,
            [ActionButton.MODIFICATION_TYPE_SET_DATA]   = false,
        },        
    }
    
    ActionBarClusterSettings[STANCE_ABILITY_BAR_NAME] =
    {
        ["barId"]                   = GameDefs.STANCE_ABILITY_HOTBAR_ID,
        ["show"]                    = false,
        ["caps"]                    = ActionBarConstants.HIDE_DECORATIVE_CAPS,
        ["firstSlot"]               = GameDefs.FIRST_STANCE_ABILITY_SLOT,
        ["lastSlot"]                = GameDefs.LAST_STANCE_ABILITY_SLOT,
        ["background"]              = ActionBarConstants.HIDE_BACKGROUND,
        ["selector"]                = ActionBarConstants.HIDE_PAGE_SELECTOR,
        ["buttonXPadding"]          = 0,
        ["buttonYPadding"]          = 0,
        ["buttonXSpacing"]          = 4,
        ["buttonYSpacing"]          = 4,
        ["showEmptySlots"]          = ActionBarConstants.HIDE_EMPTY_SLOTS,
        ["buttonFactory"]           = "StanceButton",
        ["scale"]                   = 0.75,
        ["modificationSettings"]    = 
        {
            [ActionButton.MODIFICATION_TYPE_PICKUP]     = false,
            [ActionButton.MODIFICATION_TYPE_SET_DATA]   = false,
        },
    }
    
    ActionBarClusterSettings["layoutMode"] = LAYOUT_MODE_1_ACTION_BAR
    
    ActionBarClusterPositions = DataUtils.CopyTable (ClusterAnchorPoints)
end

-- Convenience functions to acquire anchor points for the cluster
function GetClusterAnchorPoint (self, layoutMode, anchorId)
    return self[layoutMode][anchorId]
end        

local function SettingsKeyFromBarKey (barKey)
    local barKeyType = type (barKey)
    
    if (barKeyType == "number")
    then
        return (ACTION_BAR_NAME..barKey)
    end
    
    assert (barKeyType == "string")
    return barKey
end

ActionBarClusterSettingsManager = {} 

function ActionBarClusterSettingsManager:Get (settingKey)
    return ActionBarClusterSettings[settingKey]
end

-- Function used to change existing values in the ActionBarClusterSettings table,
-- e.g. ActionBarClusterSettings["layoutMode"].
function ActionBarClusterSettingsManager:Set (settingKey, settingValue)
    ActionBarClusterSettings[settingKey] = settingValue
end

function ActionBarClusterSettingsManager:GetActionBarSetting (barKey, settingKey)
    local settingsTable = ActionBarClusterSettings[SettingsKeyFromBarKey (barKey)]
    
    if (settingKey and settingsTable)
    then
        return settingsTable[settingKey]
        
    end
    
    return settingsTable
end

function ActionBarClusterSettingsManager:SetActionBarSetting (barKey, settingKey, settingValue)
    ActionBarClusterSettings[SettingsKeyFromBarKey (barKey)][settingKey] = settingValue
end

--[[
    ActionBarClusterManager
--]]

ActionBarClusterManager = 
{
    m_Settings      = ActionBarClusterSettingsManager,
    m_PendingSpawn  = false,
}

function ActionBarClusterManager.Initialize ()
    RegisterEventHandler (SystemData.Events.PLAYER_CAREER_LINE_UPDATED, "ActionBarClusterManager.SpawnCluster")
    RegisterEventHandler (SystemData.Events.LOADING_END,                "ActionBarClusterManager.SpawnCluster")
    RegisterEventHandler (SystemData.Events.INTERFACE_RELOADED,         "ActionBarClusterManager.SpawnCluster")
    
     -- Copy in the default values for any missing keys in the saved ActionBarClusterPositions table 
    for layoutModeId, layoutTable in pairs( ClusterAnchorPoints )  
    do
        if( ActionBarClusterPositions[layoutModeId] == nil ) 
        then 
            ActionBarClusterPositions[layoutModeId] = DataUtils.CopyTable( layoutTable ) 
            continue 
        end  
 
        for key, data in pairs(layoutTable) 
        do 
            if( ActionBarClusterPositions[layoutModeId][key] == nil ) 
            then 
                ActionBarClusterPositions[layoutModeId][key] = DataUtils.CopyTable( data ) 
            end  
        end 
    end
    
    LayoutEditor.RegisterEditCallback (ActionBarClusterManager.LayoutEditorEventHandler)
end

function ActionBarClusterManager.Shutdown ()
    UnregisterEventHandler (SystemData.Events.PLAYER_CAREER_LINE_UPDATED, "ActionBarClusterManager.SpawnCluster")
    UnregisterEventHandler (SystemData.Events.LOADING_END,                "ActionBarClusterManager.SpawnCluster")
    UnregisterEventHandler (SystemData.Events.INTERFACE_RELOADED,         "ActionBarClusterManager.SpawnCluster")
    
    ActionBarClusterManager.DestroyCluster ()
end

local RESPAWN_DELAY = 0.1 -- Wait this many seconds before attempting to respawn the cluster after its destruction.
local respawnTimer = 0

function ActionBarClusterManager.Update (timeElapsed)
    if (ActionBarClusterManager.m_PendingSpawn)
    then
        respawnTimer = respawnTimer + timeElapsed
                
        if (respawnTimer >= RESPAWN_DELAY)
        then
            ActionBarClusterManager.m_PendingSpawn  = false
            respawnTimer                            = 0
            
            ActionBarClusterManager.SpawnCluster ()
        end
    end
end

function ActionBarClusterManager.DestroyCluster ()
    ActionBars:DestroyQuickLock ()
    ActionBars:DestroyBars ()
    CareerResource:DespawnCurrentDisplay ()
end

local FORCE_LAYOUT = 42

function ActionBarClusterManager.SpawnCluster ()
    -- Determine whether or not the cluster actually needs to be created depending on whether or not
    -- the first action bar exists...
    if (GetFrame (ACTION_BAR_NAME.."1") == nil)
    then
        ActionBarClusterManager:SpawnActionBars ()
        ActionBarClusterManager:SpawnMoraleBar ()
        ActionBarClusterManager:SpawnTacticsWindow ()
        ActionBarClusterManager:SpawnCareerResourceBar ()
    end
        
    ActionBarClusterManager:SetLayoutMode (ActionBarClusterManager:GetLayoutMode (), FORCE_LAYOUT)
end

function ActionBarClusterManager:SpawnClusterDelayed (newLayoutMode)
    self.m_PendingSpawn = true
    self.m_Settings:Set ("layoutMode", newLayoutMode)
end

function ActionBarClusterManager.ReanchorCluster ()
    local currentLayout = ActionBarClusterManager.m_Settings:Get ("layoutMode")
    
    for anchorKey, anchorData in pairs (ActionBarClusterPositions[currentLayout])
    do
        ActionBarClusterManager:AnchorClusterFragment (anchorKey)
    end
end

-- Function to add a settings table to the ActionBarClusterSettings table,
-- used for externally created action bars (like the Pet Stance Bar)
function ActionBarClusterManager.AddClusterSettingsTable (windowName, settings)
    if (not ActionBarClusterSettings[windowName])
    then
        ActionBarClusterSettings[windowName] = settings
    end
end

--[[
    Convenience function to obtain the current layout mode, so that external script doesn't
    have to rely on encapsulated data.
--]]
function ActionBarClusterManager:GetLayoutMode ()
    return self.m_Settings:Get ("layoutMode")
end

--[[
    Switch the current layout mode.
--]]
-- look back here
function ActionBarClusterManager:SetLayoutMode (newLayoutMode, override)
    if ((newLayoutMode ~= nil) and ((newLayoutMode >= LAYOUT_MODE_FIRST_LAYOUT) and (newLayoutMode <= LAYOUT_MODE_LAST_LAYOUT)))
    then        
        ActionBarClusterManager:UnregisterClusterWithLayoutEditor ()
    
        if ((self:GetLayoutMode () ~= newLayoutMode) or (override == FORCE_LAYOUT))
        then
            self.m_Settings:Set ("layoutMode", newLayoutMode)

            self.m_Settings:SetActionBarSetting (1, "show", (newLayoutMode >= LAYOUT_MODE_1_ACTION_BAR))
            self.m_Settings:SetActionBarSetting (1, "caps", ActionBarConstants.SHOW_DECORATIVE_CAPS)
            self.m_Settings:SetActionBarSetting (2, "show", (newLayoutMode >= LAYOUT_MODE_2_ACTION_BARS))
            self.m_Settings:SetActionBarSetting (3, "show", (newLayoutMode >= LAYOUT_MODE_3_ACTION_BARS))
            self.m_Settings:SetActionBarSetting (4, "show", (newLayoutMode >= LAYOUT_MODE_4_ACTION_BARS))
            self.m_Settings:SetActionBarSetting (5, "show", (newLayoutMode == LAYOUT_MODE_5_ACTION_BARS))
            
            for barIndex = 1, CREATED_HOTBAR_COUNT
            do
                GetFrame (ACTION_BAR_NAME..barIndex):Show (self.m_Settings:GetActionBarSetting (barIndex, "show"))
                GetFrame (ACTION_BAR_NAME..barIndex):ShowCaps (self.m_Settings:GetActionBarSetting (barIndex, "caps"))
            end
            
            
            ActionBarClusterManager:RegisterClusterWithLayoutEditor ()    
            self:ReanchorCluster ()
        end
    end
end

--[[
    Convenience function to return the given anchor taking into account the current layout mode.
--]]
function ActionBarClusterManager:GetAnchor (anchorId, tableToGetAnchorFrom)
    tableToGetAnchorFrom = tableToGetAnchorFrom or ClusterAnchorPoints
    
    return GetClusterAnchorPoint (tableToGetAnchorFrom, self:GetLayoutMode (), anchorId)
end

--[[
    Convenience function to anchor, show/hide, and scale the given window from a known settings table
    The settings table is also a valid anchor (as well as containing other relevant window data)
--]]
function ActionBarClusterManager:UpdateFrameSettings (frame, settingsTable, useDefault)
    if (frame and settingsTable)
    then
    
        frame:SetScale (1)
        
        -- scaling default:  if there is no specified scale in settingsTable or ActionBarClusterSettings, use this.
        local newScale = InterfaceCore.GetScale()
        
        -- first choice:  if there is a scale specified in the settingsTable, it becomes the new scale.
        if (settingsTable.scale ~= nil and not useDefault)
        then
            newScale = newScale * settingsTable.scale
        -- second choice:  if there is a scale specified for an action bar, it becomes the new scale.
        elseif (frame.m_BarScale)
        then
            newScale = newScale * frame.m_BarScale
        end
        
        -- The trick doesn't work for booleans...
        -- (false is a valid option, but it will trip the A or B and always assign B to newShow)
        local newShow = settingsTable.showing
        
        if (newShow == nil)
        then
            newShow = true
        end
        
        frame:SetAnchor (settingsTable)
        
        -- If this frame has a page selector, scale it as well.  For now we are not scaling end caps, as they look terrible when scaled that much.
        if (frame.m_ActionPage and self.m_Settings)
        then
            selectorSetting = self.m_Settings:GetActionBarSetting (frame:GetName(), "selector")
            
            if (selectorSetting and (selectorSetting ~= ActionBarConstants.HIDE_PAGE_SELECTOR) and frame.m_PageSelectorWindow)
            then
                frame.m_PageSelectorWindow:SetScale (newScale)
            end
        end
        
        
        frame:SetScale (newScale)
        frame:Show (newShow)
        
    end
end

--[[
    Convenience function to anchor the given window where it needs to go
--]]
function ActionBarClusterManager:AnchorClusterFragment (frameId)
    -- All window anchors except the CareerResourceWindow anchors are indexed by strings.
    -- The CareerResourceWindow anchors are indexed by number.  So, if frameId is a number
    -- the anchor for the career resource window is probably desired.
    local anchorKey     = frameId
    local frameIdType   = type (frameId)
    
    if (frameIdType == "number")
    then
        if (anchorKey ~= GameData.Player.career.line)
        then
            -- Bail out and don't anchor this window if the anchor key doesn't match the player's career
            return
        end
        
        frameId = CAREER_WINDOW_NAME
    end    
    
    -- When anchoring the fragment, use the saved data....
    self:UpdateFrameSettings (FrameManager:EnsureWindowHasFrame (frameId), self:GetAnchor (anchorKey, ActionBarClusterPositions), false)
end

function ActionBarClusterManager:SpawnActionBars ()
    -- Convenient settings lookup...
    local settings = self.m_Settings

    -- Make some bars...    
    for barIndex = 1, CREATED_HOTBAR_COUNT
    do
        -- Force initialize all hotbar pages to their default values
        SetHotbarPage (barIndex, barIndex)
                
        local newBar = ActionBars:CreateBar (ACTION_BAR_NAME..barIndex, settings:GetActionBarSetting (barIndex))
        
        local showBar = settings:GetActionBarSetting (barIndex, "show")
        
        local scale = settings:GetActionBarSetting (barIndex, "scale")

        if (newBar)
        then
            newBar:Show (showBar)
        end

        if (barIndex == 1)
        then
            ActionBars:CreateQuickLock (QUICK_LOCK_NAME)
            GetFrame (QUICK_LOCK_NAME):Show (showBar)
        end
    end
    
    -- Move these to to their own functions?
    GrantedAbilityWindow.CreateBar (GRANTED_ABILITY_BAR_NAME, settings:GetActionBarSetting (GRANTED_ABILITY_BAR_NAME))
    StanceBar.CreateBar (STANCE_ABILITY_BAR_NAME, settings:GetActionBarSetting (STANCE_ABILITY_BAR_NAME))
end

function ActionBarClusterManager:SpawnTacticsWindow ()
    TacticsEditor.CreateBar (TACTICS_WINDOW_NAME)
end

function ActionBarClusterManager:SpawnMoraleBar ()
    MoraleSystem:CreateBar (MORALE_BAR_NAME)
end

function ActionBarClusterManager:SpawnCareerResourceBar ()
    CareerResource:SpawnCareerWindow (CAREER_WINDOW_NAME)
end

-- LayoutEditor stuff...adding some constants here to give meaning to the boolean parameters.

local ALLOW_SIZE_WIDTH = true
local PREVENT_SIZE_WIDTH = false

local ALLOW_SIZE_HEIGHT = true
local PREVENT_SIZE_HEIGHT = false

local ALLOW_HIDING = true
local PREVENT_HIDING = false

function ActionBarClusterManager:RegisterClusterWithLayoutEditor ()
    for windowName, customizationData in pairs (ClusterUICustomizationData)
    do        
        -- Only register the windows that are currently in use. 
        if ( customizationData.minMode <= self:GetLayoutMode() )
        then
            local frame = GetFrame( windowName )
            if ( frame )
            then
                local displayName   = L""
                local displayDesc   = L""
                if( customizationData.params )
                then
                    displayName   = GetStringFormatFromTable ("HUDStrings", customizationData.nameKey, customizationData.params)
                    displayDesc   = GetStringFormatFromTable ("HUDStrings", customizationData.descKey, customizationData.params)
                else
                    displayName   = GetStringFromTable ("HUDStrings", customizationData.nameKey )
                    displayDesc   = GetStringFromTable ("HUDStrings", customizationData.descKey ) 
                end
                
                frame:RegisterLayout( displayName, displayDesc, PREVENT_SIZE_WIDTH, PREVENT_SIZE_HEIGHT, customizationData.hideable )
            end
       end
    end
end

function ActionBarClusterManager:UnregisterClusterWithLayoutEditor ()
    for windowName, customizationData in pairs (ClusterUICustomizationData)
    do 
        local frame = GetFrame( windowName )
        if ( frame )
        then
            frame:UnregisterLayout()
        end
    end
end

function ActionBarClusterManager:OnInitializeCustomSettingsForFrame (frame)
    if (frame)
    then

        local anchorKey = frame:GetName ()
        
        if (anchorKey == CAREER_WINDOW_NAME)
        then
            anchorKey = GameData.Player.career.line
        end

        -- Copied from AnchorClusterFragment, there's no need to ensure the window has a frame, or perform
        -- reverse translation of the anchorKey...just find the anchor, and set it on the frame.

        -- When restoring defaults, use the static data...
        self:UpdateFrameSettings (frame, self:GetAnchor (anchorKey, ClusterAnchorPoints), false)
        
    end
end

function ActionBarClusterManager.LayoutEditorEventHandler (layoutEditorEventCode)
    if (layoutEditorEventCode == LayoutEditor.EDITING_END)
    then
        local layoutMode = ActionBarClusterManager:GetLayoutMode ()
        local globalUIScale = InterfaceCore.GetScale()
        for windowName, customizationData in pairs (ClusterUICustomizationData)
        do
            -- For careers without pets, "EA_CareerResourceWindowActionBar" will not exist.
            if (DoesWindowExist (windowName))
            then
                
                local anchorCount = WindowGetAnchorCount (windowName)
                
                if (anchorCount and anchorCount > 0)
                then
                    -- Only using the first anchor...relatively safe to assume that these windows will only have one anchor...
                    local point, relativePoint, relativeTo, xoffs, yoffs = WindowGetAnchor (windowName, 1)
                    
                    -- Obtain the rest of the settings for the window
                    local windowScale   = WindowGetScale (windowName)
                    local isShowing     = WindowGetShowing (windowName)
                    
                    if (windowName == CAREER_WINDOW_NAME)
                    then
                        windowName = GameData.Player.career.line
                    end
                    
                    local settingsTable = ActionBarClusterPositions[layoutMode][windowName]
                    
                    if (settingsTable)
                    then
                        settingsTable.Point         = point
                        settingsTable.RelativePoint = relativePoint
                        settingsTable.RelativeTo    = relativeTo
                        settingsTable.XOffset       = xoffs
                        settingsTable.YOffset       = yoffs
                        
                        -- We just want to save off the scale of the window in comparision to a UI scale of 1
                        -- We will take into account the global scale when we set the scale of the window in
                        -- Update frame settings. This fixes all bugs with the action bars resetting their scale
                        -- when the global scale is different then when we saved the scale.
                        settingsTable.scale         = windowScale / globalUIScale
                        settingsTable.showing       = isShowing
                    end
                end
                
            end
        end    
    end
end