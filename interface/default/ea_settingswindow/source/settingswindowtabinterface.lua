SettingsWindowTabInterface = {}

SettingsWindowTabInterface.contentsName = "SWTabInterfaceContentsScrollChild"

-----------------------------------------------------------------
-- Center screen messaging

SettingsWindowTabInterface.SavedMessageSettings = nil
SettingsWindowTabInterface.LONG_COOLDOWN = 8000
SettingsWindowTabInterface.SHORT_COOLDOWN = 3000
SettingsWindowTabInterface.NO_COOLDOWN = 0
SettingsWindowTabInterface.NUM_COOLDOWN_VALUES = 3

local MessageBodyWindowName = SettingsWindowTabInterface.contentsName.."CustomizeUiMessageSettings"

local ACTION_BAR_VISIBILITY_SHOW_ALL            = 1
local ACTION_BAR_VISIBILITY_HIDE_BACKGROUND     = 2
local ACTION_BAR_VISIBILITY_HIDE_EMPTY_SLOTS    = 3
local ACTION_BAR_VISIBILITY_HIDE_ALL            = 4

local ACTION_BAR_VISIBILITY_LOOKUP = {}

function SettingsWindowTabInterface.Initialize()

    -- Interface/Server Settings can only be modified In-Game.
    if( not InterfaceCore.inGame )
    then
        -- Disable the Tab
        ButtonSetDisabledFlag(SettingsWindowTabbed.Tabs[ SettingsWindowTabbed.TABS_INTERFACE ].name, true )
        ButtonSetDisabledFlag(SettingsWindowTabbed.Tabs[ SettingsWindowTabbed.TABS_SERVER ].name, true )
        return
    end
    
    ACTION_BAR_VISIBILITY_LOOKUP = 
    {
        [ACTION_BAR_VISIBILITY_SHOW_ALL]            = { backgroundMode=ActionBarConstants.SHOW_BACKGROUND, slotsMode=ActionBarConstants.SHOW_EMPTY_SLOTS },
        [ACTION_BAR_VISIBILITY_HIDE_BACKGROUND]     = { backgroundMode=ActionBarConstants.HIDE_BACKGROUND, slotsMode=ActionBarConstants.SHOW_EMPTY_SLOTS },
        [ACTION_BAR_VISIBILITY_HIDE_EMPTY_SLOTS]    = { backgroundMode=ActionBarConstants.SHOW_BACKGROUND, slotsMode=ActionBarConstants.HIDE_EMPTY_SLOTS },
        [ACTION_BAR_VISIBILITY_HIDE_ALL]            = { backgroundMode=ActionBarConstants.HIDE_BACKGROUND, slotsMode=ActionBarConstants.HIDE_EMPTY_SLOTS },
    }

    ---------------------------------------------------------------------------------
    -- SubSystems
    local bodyWindowName = SettingsWindowTabInterface.contentsName.."SettingsSubSystems"        
    LabelSetText( bodyWindowName.."Title", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_UI_SYSTEMS ) )    
    
    -- Character Profiles
    ButtonSetText( bodyWindowName.."CharacterProfilesButton", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_CHARACTER_PROFILES_BUTTON ) )     
    WindowSetId( bodyWindowName.."CharacterProfilesButton", StringTables.UserSettings.TOOLTIP_MANAGE_PROFILES)
    
    -- Ui Mods
    ButtonSetText( bodyWindowName.."UiModsButton", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_UI_MODS_BUTTON ) ) 
    WindowSetId( bodyWindowName.."UiModsButton", StringTables.UserSettings.TOOLTIP_MANAGE_MODS)

    -- Layout Editor    
    ButtonSetText( bodyWindowName.."LayoutEditorButton", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_LAYOUT_EDITOR_BUTTON ) ) 
    WindowSetId( bodyWindowName.."LayoutEditorButton", StringTables.UserSettings.TOOLTIP_LAYOUT_EDITOR)

    ---------------------------------------------------------------------------------
    -- Action Bars
    bodyWindowName = SettingsWindowTabInterface.contentsName.."SettingsActionBars"
    
    LabelSetText( bodyWindowName.."Title", GetString( StringTables.Default.LABEL_ACTIONBAR_SETTINGS ) )    
    
    LabelSetText( bodyWindowName.."LockActionBarsLabel", GetString( StringTables.Default.LABEL_LOCK_ACTION_BARS ) )
    LabelSetText( bodyWindowName.."ShowCooldownTextLabel", GetString( StringTables.Default.LABEL_DISPLAY_COOLDOWN_TIMER_TEXT ) )
    ButtonSetCheckButtonFlag( bodyWindowName.."LockActionBarsButton", false )
    ButtonSetCheckButtonFlag( bodyWindowName.."ShowCooldownTextButton", false )
    WindowSetId( bodyWindowName.."LockActionBars", StringTables.UserSettings.TOOLTIP_LOCK_ACTION_BARS)
    WindowSetId( bodyWindowName.."ShowCooldownText", StringTables.UserSettings.TOOLTIP_DISPLAY_COOLDOWN_TIMER_TEXT)
    WindowRegisterEventHandler (bodyWindowName.."LockActionBarsButton", SystemData.Events.USER_SETTINGS_CHANGED, "SettingsWindowTabInterface.UpdateLockActionBarsButton")
    WindowRegisterEventHandler (bodyWindowName.."ShowCooldownTextButton", SystemData.Events.USER_SETTINGS_CHANGED, "SettingsWindowTabInterface.UpdateShowCooldownTextButton")
    
    local layoutWindow = bodyWindowName.."LayoutMode"
    
    LabelSetText( layoutWindow.."Title", GetString( StringTables.Default.LABEL_ACTION_BAR_LAYOUT_MODE_TITLE ) )
    WindowSetId( layoutWindow.."Title", StringTables.UserSettings.TOOLTIP_ACTION_BAR_LAYOUT_MODE)
    LabelSetText( layoutWindow.."1BarLabel", GetString( StringTables.Default.LABEL_ACTION_BAR_LAYOUT_1_BAR ) )
    LabelSetText( layoutWindow.."2BarsLabel", GetString( StringTables.Default.LABEL_ACTION_BAR_LAYOUT_2_BARS ) )
    LabelSetText( layoutWindow.."2BarsStackedLabel", GetString( StringTables.Default.LABEL_ACTION_BAR_LAYOUT_2_BARS_STACKED ) )
    LabelSetText( layoutWindow.."3BarsLabel", GetString( StringTables.Default.LABEL_ACTION_BAR_LAYOUT_3_BARS ) )
    LabelSetText( layoutWindow.."4BarsLabel", GetString( StringTables.Default.LABEL_ACTION_BAR_LAYOUT_4_BARS ) )
    LabelSetText( layoutWindow.."5BarsLabel", GetString( StringTables.Default.LABEL_ACTION_BAR_LAYOUT_5_BARS ) )
    
    local customizeWindow = bodyWindowName.."Customize"
    
    LabelSetText( customizeWindow.."Title", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.LABEL_ACTION_BAR_CUSTOMIZATION ) )
    LabelSetText( customizeWindow.."MakeVertical", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.LABEL_ACTION_BAR_MAKE_VERTICAL ) )
    LabelSetText( customizeWindow.."Rows", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.LABEL_ACTION_BAR_ROWS ) )
    LabelSetText( customizeWindow.."NumberButtons", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.LABEL_ACTION_BAR_NUMBER_OF_BUTTONS ) )
    LabelSetText( customizeWindow.."Visibility", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.LABEL_ACTION_BAR_VISIBILITY ) )
    
    -- Set up each bar for the action bar cusomization options
    for i = 1, CREATED_HOTBAR_COUNT
    do
        local barName = customizeWindow.."Bar"..i
        LabelSetText( barName.."Name", GetStringFormatFromTable( "UserSettingsStrings", StringTables.UserSettings.LABEL_ACTION_BAR_NUMBER_NAME, {L""..i} ) )
        ButtonSetStayDownFlag( barName.."MakeVertical", true )
        
        local visibilityComboBox = barName.."Visibility"
        -- Add the visibility options
        ComboBoxAddMenuItem( visibilityComboBox, GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.LABEL_ACTION_BAR_SHOW_ALL ) )
        ComboBoxAddMenuItem( visibilityComboBox, GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.LABEL_ACTION_BAR_HIDE_BAR_BACKGROUND ) )
        ComboBoxAddMenuItem( visibilityComboBox, GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.LABEL_ACTION_BAR_HIDE_EMPTY_BUTTONS ) )
        ComboBoxAddMenuItem( visibilityComboBox, GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.LABEL_ACTION_BAR_HIDE_ALL ) )
        
        local numButtonsComboBox = barName.."NumberButtons"
        -- Add the numbers to the combo boxes for the amount of buttons
        for j = 1, ActionBarConstants.BUTTONS
        do 
            ComboBoxAddMenuItem( numButtonsComboBox, towstring( j ) )
        end
    end

    ---------------------------------------------------------------------------------
    -- Center screen messaging
    SettingsWindowTabInterface.InitMessageSettings()
end

-- Used to mark when we are updating the combo boxes via the update function
local updatingInterfaceSettings = false

local function SetActionbarSettingsWindowDisabled( actionbarSettingWindowName, disabled )
    ComboBoxSetDisabledFlag( actionbarSettingWindowName.."Visibility", disabled )
    ComboBoxSetDisabledFlag( actionbarSettingWindowName.."Rows", disabled )
    ComboBoxSetDisabledFlag( actionbarSettingWindowName.."NumberButtons", disabled )
    ButtonSetDisabledFlag( actionbarSettingWindowName.."MakeVertical", disabled )
end

function SettingsWindowTabInterface.UpdateSettings()

    -- Interface Settings can only be modified In-Game.
    if( not InterfaceCore.inGame )
    then        
        return
    end
    
    updatingInterfaceSettings = true

    local bodyWindowName = SettingsWindowTabInterface.contentsName.."SettingsActionBars"
    
    -- Lock Action Bars
    ButtonSetPressedFlag( bodyWindowName.."LockActionBarsButton", SystemData.Settings.Interface.lockActionBars )
    ButtonSetPressedFlag( bodyWindowName.."ShowCooldownTextButton", EA_ActionBars_Settings.showCooldownText )
    SettingsWindowTabInterface.initialLockActionBars = SystemData.Settings.Interface.lockActionBars
    SettingsWindowTabInterface.initialShowCooldownText = EA_ActionBars_Settings.showCooldownText
     
    local layoutWindow = bodyWindowName.."LayoutMode"
    
    if (ActionBarClusterManager)
    then
        
        local currentLayout = ActionBarClusterManager:GetLayoutMode ()
        
        local function CheckAndSetButton (buttonName)
            local layoutModeMatchesWindowId = (currentLayout == WindowGetId (buttonName))
            ButtonSetPressedFlag (buttonName.."Button", layoutModeMatchesWindowId)
        end

        CheckAndSetButton (layoutWindow.."1Bar")
        CheckAndSetButton (layoutWindow.."2Bars")
        CheckAndSetButton (layoutWindow.."2BarsStacked")
        CheckAndSetButton (layoutWindow.."3Bars")
        CheckAndSetButton (layoutWindow.."4Bars")
        CheckAndSetButton (layoutWindow.."5Bars")
        
        local numBarsShowing = LAYOUT_MODE_TO_NUM_BARS_SHOWING[currentLayout]
        
        -- Set up each bar for the action bar cusomization options
        for i = 1, CREATED_HOTBAR_COUNT
        do
            
            local barSettings = ActionBarClusterSettings[ACTION_BAR_NAME..i]
            
            if( barSettings )
            then
                local settingsBarName = SettingsWindowTabInterface.contentsName.."SettingsActionBarsCustomizeBar"..i

                SetActionbarSettingsWindowDisabled( settingsBarName, i > numBarsShowing )
                
                ButtonSetPressedFlag( settingsBarName.."MakeVertical", barSettings.columns == 1 and barSettings.buttonCount == 12 )

                local numButtons = barSettings.buttonCount
                
                if( numButtons < 1 )
                then
                    numButtons = 1
                elseif( numButtons > ActionBarConstants.BUTTONS )
                then
                    numButtons = ActionBarConstants.BUTTONS
                end
                
                -- Set the combo boxes
                ComboBoxSetSelectedMenuItem( settingsBarName.."NumberButtons", barSettings.buttonCount )
                
                local rows = barSettings.buttonCount / barSettings.columns 

                -- Clear out the menu items for the rows
                -- Then add menu items that look good depending upon the
                -- number of buttons for this bar
                ComboBoxClearMenuItems( settingsBarName.."Rows" )
                
                local numMenuItems = 1
                local halfButtons = math.floor( numButtons / 2 )
                for j = 1, halfButtons
                do
                    if( math.fmod( numButtons, j ) == 0 )
                    then
                        ComboBoxAddMenuItem(  settingsBarName.."Rows", towstring( j ) )
                        
                        if( rows == j )
                        then
                            ComboBoxSetSelectedMenuItem( settingsBarName.."Rows", numMenuItems )
                        end
                        
                        numMenuItems = numMenuItems + 1
                    end
                end
                
                ComboBoxAddMenuItem(  settingsBarName.."Rows", towstring( numButtons ) )
                
                if( rows == numButtons )
                then
                    ComboBoxSetSelectedMenuItem( settingsBarName.."Rows", numMenuItems )
                end
                
                local visibilityOption = ACTION_BAR_VISIBILITY_SHOW_ALL
                if( barSettings.background ~= ActionBarConstants.SHOW_BACKGROUND
                    and barSettings.showEmptySlots ~= ActionBarConstants.SHOW_EMPTY_SLOTS )
                then
                    visibilityOption = ACTION_BAR_VISIBILITY_HIDE_ALL
                elseif( barSettings.background ~= ActionBarConstants.SHOW_BACKGROUND )
                then
                    visibilityOption = ACTION_BAR_VISIBILITY_HIDE_BACKGROUND
                elseif( barSettings.showEmptySlots ~= ActionBarConstants.SHOW_EMPTY_SLOTS )
                then
                    visibilityOption = ACTION_BAR_VISIBILITY_HIDE_EMPTY_SLOTS
                end
                
                ComboBoxSetSelectedMenuItem( settingsBarName.."Visibility", visibilityOption )
            end
        end
    end

    updatingInterfaceSettings = false
end

-- These are the settings for the action bar when the tab interface was shown
-- and before the user started editing them
local oldActionBarSettings = {}
local oldActionBarLayout = LAYOUT_MODE_1_ACTION_BAR
function SettingsWindowTabInterface.ResetActionbarSettings()
    if( not InterfaceCore.inGame )
    then        
        return
    end
    
    for i = 1, CREATED_HOTBAR_COUNT
    do
        local oldSettingsForBar = oldActionBarSettings[i]
        if(oldSettingsForBar ~= nil)
        then
            SettingsWindowTabInterface.SetActionBarVisibility( i, oldSettingsForBar.background, oldSettingsForBar.showEmptySlots )
            SettingsWindowTabInterface.SetActionBarsButtons( i, oldSettingsForBar.buttonCount )
            SettingsWindowTabInterface.SetActionBarsCols( i, oldSettingsForBar.columns )
        end
    end
    
    ActionBarClusterManager:SpawnClusterDelayed (oldActionBarLayout)
    SettingsWindowTabInterface.UpdateSettings()
end

function SettingsWindowTabInterface.SetOldActionBarSettings()

    if( not InterfaceCore.inGame )
    then        
        return
    end
    
    for i = 1, CREATED_HOTBAR_COUNT
    do
        local barSettings = ActionBarClusterSettings[ACTION_BAR_NAME..i]
        oldActionBarSettings[i] = {}
        oldActionBarSettings[i].buttonCount = barSettings.buttonCount
        oldActionBarSettings[i].columns = barSettings.columns
        oldActionBarSettings[i].background = barSettings.background
        oldActionBarSettings[i].showEmptySlots = barSettings.showEmptySlots
    end
    
    oldActionBarLayout = ActionBarClusterManager:GetLayoutMode ()
end

function SettingsWindowTabInterface.OnShown()
    SettingsWindowTabInterface.SetOldActionBarSettings()
end

function SettingsWindowTabInterface.ApplyCurrent()
    
    -- Interface Settings can only be modified In-Game.
    if( not InterfaceCore.inGame )
    then        
        return
    end
    
    local bodyWindowName = SettingsWindowTabInterface.contentsName.."SettingsActionBars"


    SystemData.Settings.Interface.lockActionBars = ButtonGetPressedFlag( bodyWindowName.."LockActionBarsButton" )
    EA_ActionBars_Settings.showCooldownText = ButtonGetPressedFlag( bodyWindowName.."ShowCooldownTextButton" )
    
    -- Center Screen Messages
    SettingsWindowTabInterface.SaveMessageSettings()
    
    -- No need to do anything with the action bar cause their new settings have already been applied
    -- Except we have to overwrite the old settings (the settings we revert to if they hit cancel or reset or the x button)
    -- With the new settings that we have right now
    SettingsWindowTabInterface.SetOldActionBarSettings()
end

-- We want to process all the other anchoring next frame so the size and everything else
-- gets updated correctly before we start anchoring
function SettingsWindowTabInterface.StartReanchorBarsDelayed()
    ActionBarClusterManager:UnregisterClusterWithLayoutEditor()
    WindowRegisterCoreEventHandler ("SWTabInterface", "OnUpdate", "SettingsWindowTabInterface.ReanchorBarsDelayed")
end

function SettingsWindowTabInterface.ReanchorBarsDelayed()
    ActionBarClusterManager:ReanchorCluster()--WithDefaults()
    ActionBarClusterManager:RegisterClusterWithLayoutEditor()
    WindowUnregisterCoreEventHandler ( "SWTabInterface", "OnUpdate" )
end

-- Set the cols for the action bar
function SettingsWindowTabInterface.SetActionBarsCols( barNum, cols )
    SettingsWindowTabInterface.StartReanchorBarsDelayed()
    
    ActionBarClusterManager.m_Settings:SetActionBarSetting( barNum, "columns", cols )
    ActionBars.m_Bars[barNum].m_ColumnCount = cols
    
    local rows = ActionBarClusterManager.m_Settings:GetActionBarSetting( barNum, "buttonCount" ) / cols
    
    local oldMode = ActionBarClusterManager.m_Settings:GetActionBarSetting( barNum, "selector" )
    local newMode = ActionBarConstants.SHOW_PAGE_SELECTOR_RIGHT
    
    if( cols <= rows )
    then
        newMode = ActionBarConstants.HIDE_PAGE_SELECTOR
    end
    
    if( oldMode ~= newMode ) 
    then
        ActionBarClusterManager.m_Settings:SetActionBarSetting( barNum, "selector", newMode )
        ActionBars.m_Bars[barNum]:SetPageSelectorMode( newMode )
    end
    
    ActionBars.m_Bars[barNum]:AnchorButtons()
end

-- Set the cols and or rows for the action bar, this does not do any anchoring
function SettingsWindowTabInterface.SetActionBarsButtons( barNum, buttons )
    ActionBarClusterManager.m_Settings:SetActionBarSetting( barNum, "buttonCount", buttons )
    ActionBars.m_Bars[barNum].m_ButtonCount = buttons
    
    ActionBars.m_Bars[barNum]:UpdateNumberButtons( ActionBarClusterManager.m_Settings:GetActionBarSetting( barNum ) )
end

function SettingsWindowTabInterface.SetActionBarVisibility( barNum, backgroundMode, slotsMode )
    local bar = ActionBars.m_Bars[barNum]
    ActionBarClusterManager.m_Settings:SetActionBarSetting( barNum, "background", backgroundMode )
    bar.m_ShowBackground = backgroundMode
    
    ActionBarClusterManager.m_Settings:SetActionBarSetting( barNum, "showEmptySlots", slotsMode )
    bar.m_ShowEmptySlots = slotsMode
    
    bar:UpdateShownSlots()
    bar:UpdateShowBackground()
end


-- Toggling the make veritcal check box will just make the bar have 12 buttons and 12 rows or 1 column
function SettingsWindowTabInterface.ToggleMakeVertical()
    if( not ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) )
    then
        local barNum = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
        local isCurrentlyVertical = ActionBarClusterSettings[ACTION_BAR_NAME..barNum].columns == 1
                                    and ActionBarClusterSettings[ACTION_BAR_NAME..barNum].buttonCount == 12

        local cols = 12
        local buttons = ActionBarConstants.BUTTONS
        if( not isCurrentlyVertical )
        then
            cols = 1
        end
        
        SettingsWindowTabInterface.SetActionBarsButtons( barNum, buttons )
        SettingsWindowTabInterface.SetActionBarsCols( barNum, cols )
        SettingsWindowTabInterface.UpdateSettings()
    end
end

-- OnSelChanged for the rows callback
function SettingsWindowTabInterface.SelectRows()
    -- make sure we do not keep calling this function which is called indirectly by
    -- the OnSelChanged callback for the combo box by setting the selected one in the
    -- UpdateSettings function
    if( not updatingInterfaceSettings )
    then
        local barNum = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
        local comboBoxName = SettingsWindowTabInterface.contentsName.."SettingsActionBarsCustomizeBar"..barNum.."Rows"
        local rows = tonumber( ComboBoxGetSelectedText( comboBoxName ) )
        local cols = ActionBarClusterManager.m_Settings:GetActionBarSetting( barNum, "buttonCount" ) / rows

        SettingsWindowTabInterface.SetActionBarsCols( barNum, cols )
        SettingsWindowTabInterface.UpdateSettings()
    end
end

-- OnSelChanged for the buttons callback
function SettingsWindowTabInterface.SelectNumButtons()
    -- make sure we do not keep calling this function which is called indirectly by
    -- the OnSelChanged callback for the combo box by setting the selected one in the
    -- UpdateSettings function
    if( not updatingInterfaceSettings )
    then
        -- We have to ensure that the number of rows that they have selected will work with this number of buttons
        -- if it will not then find the closest match
        local barNum = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
        local comboBoxName = SettingsWindowTabInterface.contentsName.."SettingsActionBarsCustomizeBar"..barNum.."NumberButtons"
        local buttons = tonumber( ComboBoxGetSelectedText( comboBoxName ) )
        local oldRows = ActionBarClusterManager.m_Settings:GetActionBarSetting( barNum, "buttonCount" ) / ActionBarClusterManager.m_Settings:GetActionBarSetting( barNum, "columns" )
        local cols, colsFrac = math.modf( buttons / oldRows )
        local newCols = cols
        
        -- if we have a fraction then we need to specify a different amount of rows/cols
        -- so it will look better
        if( colsFrac ~= 0 )
        then
            -- Find the closest match
            local halfButtons = math.floor( buttons / 2 )
            local newRows = buttons
            
            if( oldRows < buttons )
            then
                -- Start at the highest valid row and check to see if this is the closest
                for j = halfButtons, 1, -1
                do
                    if( math.fmod( buttons, j ) == 0 and j <= oldRows )
                    then
                        newRows = j
                        break
                    end
                end
            end
            
            newCols = buttons / newRows
        end
        
        SettingsWindowTabInterface.SetActionBarsButtons( barNum, buttons )
        SettingsWindowTabInterface.SetActionBarsCols( barNum, newCols )
        SettingsWindowTabInterface.UpdateSettings()
    end
end

-- OnSelChanged for the visibility callback
function SettingsWindowTabInterface.SelectVisibility()
    local barNum = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
    local comboBoxName = SettingsWindowTabInterface.contentsName.."SettingsActionBarsCustomizeBar"..barNum.."Visibility"
    local showSettings = ACTION_BAR_VISIBILITY_LOOKUP[ComboBoxGetSelectedMenuItem( comboBoxName )]
    SettingsWindowTabInterface.SetActionBarVisibility(barNum, showSettings.backgroundMode, showSettings.slotsMode )
end

function SettingsWindowTabInterface.OnManageUIProfiles()
    WindowUtils.ToggleShowing( "EA_Window_ManageUiProfiles" )
end

function SettingsWindowTabInterface.OnActionBarLayoutSelect ()
    -- It should be impossible for this to be called when the window containing these settings is hidden.
    assert (ActionBarClusterManager ~= nil)
    
    ActionBarClusterManager:SpawnClusterDelayed (WindowGetId (SystemData.ActiveWindow.name))
    SettingsWindowTabInterface.UpdateSettings ()
end

function SettingsWindowTabInterface.OnManageUIMods()
    WindowUtils.ToggleShowing( "UiModWindow" )
end

function SettingsWindowTabInterface.UpdateLockActionBarsButton()

    ButtonSetPressedFlag( SystemData.ActiveWindow.name, SystemData.Settings.Interface.lockActionBars )

end

function SettingsWindowTabInterface.UpdateShowCooldownTextButton()

    ButtonSetPressedFlag( SystemData.ActiveWindow.name, EA_ActionBars_Settings.showCooldownText )
    
end

function SettingsWindowTabInterface.OnBeginLayoutEditor()
    LayoutEditor.Begin()
end

local function ProcessSliderCooldown( sliderName )
    -- This code needs to change when NUM_COOLDOWN_VALUES changes
    local cooldown = SliderBarGetCurrentPosition( sliderName )
    local cooldownInMs
    if( cooldown <= 0.3 )
    then
        cooldown = 0
        cooldownInMs = SettingsWindowTabInterface.NO_COOLDOWN
    elseif( cooldown >= 0.7 )
    then
        cooldown = 1
        cooldownInMs = SettingsWindowTabInterface.LONG_COOLDOWN
    else
        cooldown = 0.5
        cooldownInMs = SettingsWindowTabInterface.SHORT_COOLDOWN
    end
    
    SliderBarSetCurrentPosition( sliderName, cooldown )
    return cooldownInMs, cooldown 
end

function SettingsWindowTabInterface.InitMessageSettings()

    -- Header
    LabelSetText( MessageBodyWindowName.."Title", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_CSM ) )

    LabelSetText( MessageBodyWindowName.."EnableLabel", GetStringFromTable( "CustomizeUiStrings",  StringTables.CustomizeUi.LABEL_CSM_ENABLE ) )
    WindowSetId( MessageBodyWindowName.."EnableLabel", StringTables.UserSettings.TOOLTIP_CENTER_MESSAGES)
    LabelSetText( MessageBodyWindowName.."CooldownLabel", GetStringFromTable( "CustomizeUiStrings",  StringTables.CustomizeUi.LABEL_CSM_COOLDOWN ) )
    WindowSetId( MessageBodyWindowName.."CooldownLabel", StringTables.UserSettings.TOOLTIP_CENTER_MESSAGES)
 
    LabelSetText( MessageBodyWindowName.."AlertCombatLabel", GetStringFromTable( "CustomizeUiStrings",  StringTables.CustomizeUi.LABEL_CSM_COMBAT ) )
    LabelSetText( MessageBodyWindowName.."AlertRvRLabel", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_CSM_RVR ) )
    LabelSetText( MessageBodyWindowName.."AlertGeoLabel", GetStringFromTable( "CustomizeUiStrings",  StringTables.CustomizeUi.LABEL_CSM_GEO ) )
    LabelSetText( MessageBodyWindowName.."AlertAchievLabel", GetStringFromTable( "CustomizeUiStrings",  StringTables.CustomizeUi.LABEL_CSM_ACHIEV ) )
    LabelSetText( MessageBodyWindowName.."AlertQuestLabel", GetStringFromTable( "CustomizeUiStrings",  StringTables.CustomizeUi.LABEL_CSM_QUEST ) )
    LabelSetText( MessageBodyWindowName.."AlertSocialLabel", GetStringFromTable( "CustomizeUiStrings",  StringTables.CustomizeUi.LABEL_CSM_SOCIAL ) )
    LabelSetText( MessageBodyWindowName.."AlertDefaultLabel", GetStringFromTable( "CustomizeUiStrings",  StringTables.CustomizeUi.LABEL_CSM_DEFAULT ) )
    WindowSetId( MessageBodyWindowName.."AlertCombat", StringTables.UserSettings.TOOLTIP_CENTER_MESSAGES)
    WindowSetId( MessageBodyWindowName.."AlertRvR", StringTables.UserSettings.TOOLTIP_CENTER_MESSAGES)
    WindowSetId( MessageBodyWindowName.."AlertGeo", StringTables.UserSettings.TOOLTIP_CENTER_MESSAGES)
    WindowSetId( MessageBodyWindowName.."AlertAchiev", StringTables.UserSettings.TOOLTIP_CENTER_MESSAGES)
    WindowSetId( MessageBodyWindowName.."AlertQuest", StringTables.UserSettings.TOOLTIP_CENTER_MESSAGES)
    WindowSetId( MessageBodyWindowName.."AlertSocial", StringTables.UserSettings.TOOLTIP_CENTER_MESSAGES)
    WindowSetId( MessageBodyWindowName.."AlertDefault", StringTables.UserSettings.TOOLTIP_CENTER_MESSAGES)
    
    SettingsWindowTabInterface.ResetMessageSettings()
    SettingsWindowTabInterface.SaveMessageSettings()
end

function SettingsWindowTabInterface.UpdateMessageSettings()
   
end

function SettingsWindowTabInterface.SaveMessageSettings()

    if( not SettingsWindowTabInterface.SavedMessageSettings )
    then
        SettingsWindowTabInterface.SavedMessageSettings = {}
    end 

    SettingsWindowTabInterface.SavedMessageSettings.combat = ButtonGetPressedFlag( MessageBodyWindowName.."AlertCombatButton" )
    SettingsWindowTabInterface.SavedMessageSettings.rvr = ButtonGetPressedFlag( MessageBodyWindowName.."AlertRvRButton" )
    SettingsWindowTabInterface.SavedMessageSettings.geo = ButtonGetPressedFlag( MessageBodyWindowName.."AlertGeoButton" )
    SettingsWindowTabInterface.SavedMessageSettings.achiev = ButtonGetPressedFlag( MessageBodyWindowName.."AlertAchievButton" )
    SettingsWindowTabInterface.SavedMessageSettings.quest = ButtonGetPressedFlag( MessageBodyWindowName.."AlertQuestButton" )
    SettingsWindowTabInterface.SavedMessageSettings.social = ButtonGetPressedFlag( MessageBodyWindowName.."AlertSocialButton" )
    SettingsWindowTabInterface.SavedMessageSettings.default = ButtonGetPressedFlag( MessageBodyWindowName.."AlertDefaultButton" )    

    local cooldownInMs, cooldownSlider = ProcessSliderCooldown( MessageBodyWindowName.."CombatSlider" )
    SettingsWindowTabInterface.SavedMessageSettings.combatSlider = cooldownSlider    
    EnableAlert( SystemData.AlertContainer.COMBAT, SettingsWindowTabInterface.SavedMessageSettings.combat, cooldownInMs )
    
    cooldownInMs, cooldownSlider = ProcessSliderCooldown( MessageBodyWindowName.."RvRSlider" )
    SettingsWindowTabInterface.SavedMessageSettings.rvrSlider = cooldownSlider    
    EnableAlert( SystemData.AlertContainer.RVR, SettingsWindowTabInterface.SavedMessageSettings.rvr, cooldownInMs )

    cooldownInMs, cooldownSlider = ProcessSliderCooldown( MessageBodyWindowName.."GeoSlider" )
    SettingsWindowTabInterface.SavedMessageSettings.geoSlider = cooldownSlider    
    EnableAlert( SystemData.AlertContainer.GEOGRAPHICAL, SettingsWindowTabInterface.SavedMessageSettings.geo, cooldownInMs )
    
    cooldownInMs, cooldownSlider = ProcessSliderCooldown( MessageBodyWindowName.."AchievSlider" )
    SettingsWindowTabInterface.SavedMessageSettings.achievSlider = cooldownSlider    
    EnableAlert( SystemData.AlertContainer.ACHIEVEMENT, SettingsWindowTabInterface.SavedMessageSettings.achiev, cooldownInMs )
    
    cooldownInMs, cooldownSlider = ProcessSliderCooldown( MessageBodyWindowName.."QuestSlider" )
    SettingsWindowTabInterface.SavedMessageSettings.questSlider = cooldownSlider    
    EnableAlert( SystemData.AlertContainer.QUESTS, SettingsWindowTabInterface.SavedMessageSettings.quest, cooldownInMs )        
    
    cooldownInMs, cooldownSlider = ProcessSliderCooldown( MessageBodyWindowName.."SocialSlider" )
    SettingsWindowTabInterface.SavedMessageSettings.socialSlider = cooldownSlider    
    EnableAlert( SystemData.AlertContainer.SOCIAL, SettingsWindowTabInterface.SavedMessageSettings.social, cooldownInMs )

    cooldownInMs, cooldownSlider = ProcessSliderCooldown( MessageBodyWindowName.."DefaultSlider" )
    SettingsWindowTabInterface.SavedMessageSettings.defaultSlider = cooldownSlider    
    EnableAlert( SystemData.AlertContainer.DEFAULT, SettingsWindowTabInterface.SavedMessageSettings.default, cooldownInMs )
   
end

function SettingsWindowTabInterface.ResetSettings()
    SettingsWindowTabInterface.ResetMessageSettings()
    SettingsWindowTabInterface.ResetActionbarSettings()
end
   
function SettingsWindowTabInterface.ResetMessageSettings()
    -- This tab used to be the CustomizeUI window
    -- We disable it during Pregame as it depends on things like ActionBar 
    if ButtonGetDisabledFlag(SettingsWindowTabbed.Tabs[ SettingsWindowTabbed.TABS_INTERFACE ].name) then
        return
    end
    
    if( SettingsWindowTabInterface.SavedMessageSettings )
    then
        ButtonSetPressedFlag( MessageBodyWindowName.."AlertCombatButton", SettingsWindowTabInterface.SavedMessageSettings.combat )
        ButtonSetPressedFlag( MessageBodyWindowName.."AlertRvRButton", SettingsWindowTabInterface.SavedMessageSettings.rvr )
        ButtonSetPressedFlag( MessageBodyWindowName.."AlertGeoButton", SettingsWindowTabInterface.SavedMessageSettings.geo )
        ButtonSetPressedFlag( MessageBodyWindowName.."AlertAchievButton", SettingsWindowTabInterface.SavedMessageSettings.achiev )
        ButtonSetPressedFlag( MessageBodyWindowName.."AlertQuestButton", SettingsWindowTabInterface.SavedMessageSettings.quest )
        ButtonSetPressedFlag( MessageBodyWindowName.."AlertSocialButton", SettingsWindowTabInterface.SavedMessageSettings.social )
        ButtonSetPressedFlag( MessageBodyWindowName.."AlertDefaultButton", SettingsWindowTabInterface.SavedMessageSettings.default )
        
        SliderBarSetCurrentPosition( MessageBodyWindowName.."CombatSlider", SettingsWindowTabInterface.SavedMessageSettings.combatSlider )
        SliderBarSetCurrentPosition( MessageBodyWindowName.."RvRSlider", SettingsWindowTabInterface.SavedMessageSettings.rvrSlider )
        SliderBarSetCurrentPosition( MessageBodyWindowName.."GeoSlider", SettingsWindowTabInterface.SavedMessageSettings.geoSlider )
        SliderBarSetCurrentPosition( MessageBodyWindowName.."AchievSlider", SettingsWindowTabInterface.SavedMessageSettings.achievSlider )
        SliderBarSetCurrentPosition( MessageBodyWindowName.."QuestSlider", SettingsWindowTabInterface.SavedMessageSettings.questSlider )
        SliderBarSetCurrentPosition( MessageBodyWindowName.."SocialSlider", SettingsWindowTabInterface.SavedMessageSettings.socialSlider )
        SliderBarSetCurrentPosition( MessageBodyWindowName.."DefaultSlider", SettingsWindowTabInterface.SavedMessageSettings.defaultSlider )
        
    else
        ButtonSetPressedFlag( MessageBodyWindowName.."AlertCombatButton", true )
        ButtonSetPressedFlag( MessageBodyWindowName.."AlertRvRButton", true )
        ButtonSetPressedFlag( MessageBodyWindowName.."AlertGeoButton", true )
        ButtonSetPressedFlag( MessageBodyWindowName.."AlertAchievButton", true )
        ButtonSetPressedFlag( MessageBodyWindowName.."AlertQuestButton", true )
        ButtonSetPressedFlag( MessageBodyWindowName.."AlertSocialButton", true )
        ButtonSetPressedFlag( MessageBodyWindowName.."AlertDefaultButton", true )
        
        local defaultSlider = 0
        local geographySlider = 1
        if( SystemData.Territory.KOREA )
        then
            defaultSlider = 0.5
            geographySlider = 0.5
        end

        SliderBarSetCurrentPosition( MessageBodyWindowName.."CombatSlider", defaultSlider )
        SliderBarSetCurrentPosition( MessageBodyWindowName.."RvRSlider", defaultSlider )
        SliderBarSetCurrentPosition( MessageBodyWindowName.."GeoSlider", geographySlider ) -- Defaulting a cooldown on geographical messages
        SliderBarSetCurrentPosition( MessageBodyWindowName.."AchievSlider", defaultSlider )
        SliderBarSetCurrentPosition( MessageBodyWindowName.."QuestSlider", defaultSlider )
        SliderBarSetCurrentPosition( MessageBodyWindowName.."SocialSlider", defaultSlider )
        SliderBarSetCurrentPosition( MessageBodyWindowName.."DefaultSlider", defaultSlider )
        
    end
end

function SettingsWindowTabInterface.OnMouseOverLayoutMode()
    local windowName	= SystemData.ActiveWindow.name
    
    SettingsWindowTabbed.CreateAutoTooltip(StringTables.UserSettings.TOOLTIP_ACTION_BAR_LAYOUT_MODE, windowName)
end
