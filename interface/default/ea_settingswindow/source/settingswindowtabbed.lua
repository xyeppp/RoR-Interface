
----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

SettingsWindowTabbed = {}

SettingsWindowTabbed.TABS_GENERAL	    = 1
SettingsWindowTabbed.TABS_VIDEO	        = 2
SettingsWindowTabbed.TABS_SOUND		    = 3
SettingsWindowTabbed.TABS_CHAT		    = 4
SettingsWindowTabbed.TABS_TARGETTING	= 5
SettingsWindowTabbed.TABS_INTERFACE	    = 6
SettingsWindowTabbed.TABS_SERVER		= 7
SettingsWindowTabbed.TABS_MAX_NUMBER	= 7

SettingsWindowTabbed.SelectedTab		= SettingsWindowTabbed.TABS_GENERAL


SettingsWindowTabbed.Tabs = {} 
SettingsWindowTabbed.Tabs[ SettingsWindowTabbed.TABS_GENERAL  ]	= { window = "SWTabGeneral",	name="SettingsWindowTabbedTabButtonsGeneral",	label=StringTables.UserSettings.LABEL_SETTINGS_TAB_GENERAL,	tooltip=StringTables.UserSettings.TOOLTIP_SETTINGS_TAB_GENERAL, tabClass=SettingsWindowTabGeneral }
SettingsWindowTabbed.Tabs[ SettingsWindowTabbed.TABS_VIDEO ]	= { window = "SWTabVideo",	name="SettingsWindowTabbedTabButtonsVideo",	label=StringTables.UserSettings.LABEL_SETTINGS_TAB_VIDEO,	tooltip=StringTables.UserSettings.TOOLTIP_SETTINGS_TAB_VIDEO, tabClass=SettingsWindowTabVideo }
SettingsWindowTabbed.Tabs[ SettingsWindowTabbed.TABS_SOUND ]		= { window = "SWTabSound",	name="SettingsWindowTabbedTabButtonsSound",	label=StringTables.UserSettings.LABEL_SETTINGS_TAB_SOUND,	tooltip=StringTables.UserSettings.TOOLTIP_SETTINGS_TAB_SOUND, tabClass=SettingsWindowTabSound }
SettingsWindowTabbed.Tabs[ SettingsWindowTabbed.TABS_CHAT ]		= { window = "SWTabChat",	name="SettingsWindowTabbedTabButtonsChat",	label=StringTables.UserSettings.LABEL_SETTINGS_TAB_CHAT,	tooltip=StringTables.UserSettings.TOOLTIP_SETTINGS_TAB_CHAT, tabClass=SettingsWindowTabChat }
SettingsWindowTabbed.Tabs[ SettingsWindowTabbed.TABS_TARGETTING ]	= { window = "SWTabTargetting",	name="SettingsWindowTabbedTabButtonsTargetting",	label=StringTables.UserSettings.LABEL_SETTINGS_TAB_TARGETTING,	tooltip=StringTables.UserSettings.TOOLTIP_SETTINGS_TAB_TARGETTING, tabClass=SettingsWindowTabTargetting }
SettingsWindowTabbed.Tabs[ SettingsWindowTabbed.TABS_INTERFACE ]	= { window = "SWTabInterface",	name="SettingsWindowTabbedTabButtonsInterface",	label=StringTables.UserSettings.LABEL_SETTINGS_TAB_INTERFACE,	tooltip=StringTables.UserSettings.TOOLTIP_SETTINGS_TAB_INTERFACE, tabClass=SettingsWindowTabInterface }
SettingsWindowTabbed.Tabs[ SettingsWindowTabbed.TABS_SERVER ]		= { window = "SWTabServer",	name="SettingsWindowTabbedTabButtonsServer",	label=StringTables.UserSettings.LABEL_SETTINGS_TAB_SERVER,	tooltip=StringTables.UserSettings.TOOLTIP_SETTINGS_TAB_SERVER, tabClass=SettingsWindowTabServer }


function SettingsWindowTabbed.OnShow()
    WindowUtils.OnShown()
    SettingsWindowTabInterface.OnShown()
    SettingsWindowTabbed.UpdateSettings()
end

-- OnInitialize Handler()
function SettingsWindowTabbed.Initialize()

    LabelSetText( "SettingsWindowTabbedTitleBarText", GetString( StringTables.Default.LABEL_USER_SETTINGS ) )
    
    SettingsWindowTabbed.SetTabLabels()
    
    --buttons on the bottom
    ButtonSetText( "SettingsWindowTabbedOkayButton", GetString( StringTables.Default.LABEL_OKAY ) )
    ButtonSetText( "SettingsWindowTabbedApplyButton", GetString( StringTables.Default.LABEL_APPLY ) )
    ButtonSetText( "SettingsWindowTabbedResetButton", GetString( StringTables.Default.LABEL_RESET ) )
    ButtonSetText( "SettingsWindowTabbedCancelButton", GetString( StringTables.Default.LABEL_CANCEL ) )
    
    --could consider saving off and loading the tab they were looking at like GuildWindow does
    SettingsWindowTabbed.SelectTab(SettingsWindowTabbed.SelectedTab)

    SettingsWindowTabbed.UpdateSettings()
end

-- Initializes all the text on the tab buttons
function SettingsWindowTabbed.SetTabLabels()
    for index, TabData in ipairs(SettingsWindowTabbed.Tabs) 
    do
        ButtonSetText(TabData.name, GetStringFromTable( "UserSettingsStrings", TabData.label ) )
    end
end

function SettingsWindowTabbed.UpdateSettings()

    -- Reload the current settings
    for index, TabIndex in ipairs(SettingsWindowTabbed.Tabs) 
    do
        if TabIndex.tabClass ~= nil then
            TabIndex.tabClass.UpdateSettings()
        end
    end
end

function SettingsWindowTabbed.OnCancelButton()

    SettingsWindowTabbed.OnResetButton()
    
    -- Close the window     
    WindowSetShowing( "SettingsWindowTabbed", false )
end

function SettingsWindowTabbed.OnResetButton()
    SettingsWindowTabVideo.ResetSettings() --in case of previewing UI scale
    SettingsWindowTabInterface.ResetSettings()
    -- Reload the current settings
    SettingsWindowTabbed.UpdateSettings()
end

function SettingsWindowTabbed.SelectTab(tabNumber)

    if tabNumber ~= nil and tabNumber >= SettingsWindowTabbed.TABS_GENERAL and tabNumber <= SettingsWindowTabbed.TABS_MAX_NUMBER then
        if not ButtonGetDisabledFlag(SettingsWindowTabbed.Tabs[tabNumber].name) then
            SettingsWindowTabbed.SelectedTab = tabNumber
            
            for index, TabIndex in ipairs(SettingsWindowTabbed.Tabs) do
                if (index ~= tabNumber) then
                    ButtonSetPressedFlag( TabIndex.name, false )
                    WindowSetShowing( TabIndex.window, false )
                else
                    ButtonSetPressedFlag( TabIndex.name, true )
                    WindowSetShowing( TabIndex.window, true )
                end
            end
        end

    end
end

-- EventHandler for when the user mouses over an element that has an ID set to a tooltip for easy lookup
function SettingsWindowTabbed.OnMouseOverTooltipElement()
    local windowName	= SystemData.ActiveWindow.name
    local windowID	= WindowGetId (windowName)
    
    if windowID ~= 0
    then
        SettingsWindowTabbed.CreateAutoTooltip(windowID, windowName)
    end
end

-- Creates the default automatic tooltip for Settings window elements that have a 
-- tooltip string ID set
function SettingsWindowTabbed.CreateAutoTooltip(stringID, windowName)
    if stringID ~= nil and stringID ~= 0 and windowName ~= nil
    then
        Tooltips.CreateTextOnlyTooltip( windowName, GetStringFromTable( "UserSettingsStrings", stringID ) )
        Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_TOP)
    end
end

-- EventHandler for when the user moves the mouse over a Tab
function SettingsWindowTabbed.OnMouseOverTab()
    local windowName	= SystemData.ActiveWindow.name
    local windowIndex	= WindowGetId (windowName)

    Tooltips.CreateTextOnlyTooltip (windowName, nil)
    Tooltips.SetTooltipText (1, 1, GetStringFromTable( "UserSettingsStrings", SettingsWindowTabbed.Tabs[windowIndex].tooltip ) )
    Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)	
    Tooltips.Finalize ()
    
    local anchor = { Point="bottom", RelativeTo=windowName, RelativePoint="top", XOffset=0, YOffset=32 }
    Tooltips.AnchorTooltip (anchor)
    Tooltips.SetTooltipAlpha (1)
end

-- EventHandler for OnLButtonUp when a user L- clicks a tab
function SettingsWindowTabbed.OnLButtonUpTab()
    SettingsWindowTabbed.SelectTab(WindowGetId (SystemData.ActiveWindow.name))
end

function SettingsWindowTabbed.OnCancelButton()

    SettingsWindowTabbed.OnResetButton()
    
    -- Close the window     
    WindowSetShowing( "SettingsWindowTabbed", false )
end

function SettingsWindowTabbed.OnApplyButton()

    -- Set the Options
    for index, TabIndex in ipairs(SettingsWindowTabbed.Tabs) do
        if TabIndex.tabClass ~= nil then
            TabIndex.tabClass.ApplyCurrent()
        end
    end
    
    BroadcastEvent( SystemData.Events.USER_SETTINGS_CHANGED )
end

function SettingsWindowTabbed.OnOkayButton()

    SettingsWindowTabbed.OnApplyButton()

    -- Close the window     
    WindowSetShowing( "SettingsWindowTabbed", false )
end

function SettingsWindowTabbed.DoLoginPerformanceWarning()

    if ( SystemData.Settings.Performance.perfLevelOverridden and 
         SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_PERFORMANCE] )        
    then
        SystemData.Settings.Performance.perfLevelOverridden = false
        DialogManager.MakeOneButtonDialog(GetPregameString(StringTables.Pregame.LABEL_PERFORMANCE_OVERRIDDEN), GetPregameString(StringTables.Pregame.LABEL_OKAY), nil, nil, DialogManager.UNTYPED_ID)
    end

end


