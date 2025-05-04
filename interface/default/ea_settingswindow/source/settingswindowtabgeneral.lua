SettingsWindowTabGeneral = {}

SettingsWindowTabGeneral.contentsName = "SWTabGeneralContentsScrollChild"

function SettingsWindowTabGeneral.Initialize()

    -- Game Play
    LabelSetText( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayTitle", GetString( StringTables.Default.LABEL_GAME_PLAY ) )
    
    LabelSetText( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayAllowAutoQueueingLabel", GetString( StringTables.Default.LABEL_ALLOW_AUTO_QUEUEING ) )
    ButtonSetCheckButtonFlag( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayAllowAutoQueueingButton", true )
    WindowSetId(SettingsWindowTabGeneral.contentsName.."SettingsGamePlayAllowAutoQueueing", StringTables.UserSettings.TOOLTIP_ALLOW_AUTO_QUEUEING)
    
    LabelSetText( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayAutoLootAllLabel", GetString( StringTables.Default.LABEL_AUTO_LOOT_ALL ) )
    ButtonSetCheckButtonFlag( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayAutoLootAllButton", true )
    WindowSetId(SettingsWindowTabGeneral.contentsName.."SettingsGamePlayAutoLootAll", StringTables.UserSettings.TOOLTIP_AUTO_LOOT_ALL)

    LabelSetText( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayShowToolTipsLabel", GetString( StringTables.Default.LABEL_SHOW_TOOLTIPS ) )
    ButtonSetCheckButtonFlag( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayShowToolTipsButton", true )
    WindowSetId(SettingsWindowTabGeneral.contentsName.."SettingsGamePlayShowToolTips", StringTables.UserSettings.TOOLTIP_SHOW_TOOLTIPS)
    
    LabelSetText( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayStaticAbilityTooltipsLabel", GetString( StringTables.Default.LABEL_STATIC_ABILITY_TOOLTIPS ) )
    ButtonSetCheckButtonFlag( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayStaticAbilityTooltipsButton", true )
    WindowSetId(SettingsWindowTabGeneral.contentsName.."SettingsGamePlayStaticAbilityTooltips", StringTables.UserSettings.TOOLTIP_STATIC_ABILITY_TOOLTIPS)
    
    LabelSetText( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayStaticTooltipsLabel", GetString( StringTables.Default.LABEL_STATIC_TOOLTIPS ) )
    ButtonSetCheckButtonFlag( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayStaticTooltipsButton", true )
    WindowSetId(SettingsWindowTabGeneral.contentsName.."SettingsGamePlayStaticTooltips", StringTables.UserSettings.TOOLTIP_STATIC_TOOLTIPS)
    
    LabelSetText( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayClickThroughSelfLabel", GetString( StringTables.Default.LABEL_CLICK_THROUGH_SELF ) )
    ButtonSetCheckButtonFlag( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayClickThroughSelfButton", true )
    WindowSetId(SettingsWindowTabGeneral.contentsName.."SettingsGamePlayClickThroughSelf", StringTables.UserSettings.TOOLTIP_CLICK_THROUGH_SELF)
    
    LabelSetText( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayShowRvRAlertsLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.SHOW_RVR_ALERTS ) )    
    ButtonSetCheckButtonFlag( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayShowRvRAlertsButton", true )
    WindowSetId(SettingsWindowTabGeneral.contentsName.."SettingsGamePlayShowRvRAlerts", StringTables.UserSettings.TOOLTIP_SHOW_RVR_ALERTS)

    LabelSetText( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayPreventPlayerStatusFadeLabel", GetString( StringTables.Default.LABEL_PREVENT_PLAYER_STATUS_FADE ) )
    ButtonSetCheckButtonFlag( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayPreventPlayerStatusFadeButton", false )
    WindowSetId(SettingsWindowTabGeneral.contentsName.."SettingsGamePlayPreventPlayerStatusFade", StringTables.UserSettings.TOOLTIP_PREVENT_PLAYER_STATUS_FADE)
    
    LabelSetText( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayClickToMoveLabel", GetString( StringTables.Default.LABEL_CLICK_TO_MOVE ) )
    ButtonSetCheckButtonFlag( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayClickToMoveButton", true )
    WindowSetId(SettingsWindowTabGeneral.contentsName.."SettingsGamePlayClickToMove", StringTables.UserSettings.TOOLTIP_CLICK_TO_MOVE)
    
    LabelSetText( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayStickyTargetingLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.LABEL_STICKY_TARGETING ) )
    ButtonSetCheckButtonFlag( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayStickyTargetingButton", true )
    WindowSetId(SettingsWindowTabGeneral.contentsName.."SettingsGamePlayStickyTargeting", StringTables.UserSettings.TOOLTIP_STICKY_TARGETING)
    
    LabelSetText( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayAutoLootInRvRLabel", GetString( StringTables.Default.LABEL_AUTO_LOOT_RVR_SETTING ) )
    ButtonSetCheckButtonFlag( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayAutoLootInRvRButton", true )
    WindowSetId(SettingsWindowTabGeneral.contentsName.."SettingsGamePlayAutoLootInRvR", StringTables.UserSettings.TOOLTIP_AUTO_LOOT_RVR )
    
    LabelSetText( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayOldMinimapBorderLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.LABEL_OLD_MINIMAP_BORDER ) )
    ButtonSetCheckButtonFlag( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayOldMinimapBorderButton", true )
    WindowSetId(SettingsWindowTabGeneral.contentsName.."SettingsGamePlayOldMinimapBorder", StringTables.UserSettings.TOOLTIP_OLD_MINIMAP_BORDER )
    
    LabelSetText( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayCombatLightingLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.LABEL_COMBAT_LIGHTING ) )
    WindowSetId( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayCombatLightingLabel", StringTables.UserSettings.TOOLTIP_COMBAT_LIGHTING )
    ComboBoxAddMenuItem( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayCombatLightingCombo", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_ABILITY_EFFECTS_NONE ) )
    ComboBoxAddMenuItem( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayCombatLightingCombo", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.LABEL_OTHERS ) )
    ComboBoxAddMenuItem( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayCombatLightingCombo", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_ABILITY_EFFECTS_ALL ) )
    WindowSetId( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayCombatLightingCombo", StringTables.UserSettings.TOOLTIP_COMBAT_LIGHTING )

    -- Tutorial & Help Tips
    LabelSetText( SettingsWindowTabGeneral.contentsName.."SettingsHelpTipsTitle", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.LABEL_TUTORIAL_AND_HELP_TIPS ) )
        
    LabelSetText(SettingsWindowTabGeneral.contentsName.."SettingsHelpTipsShowTutorialsLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.LABEL_SHOW_TUTORIALS ) )
    ButtonSetCheckButtonFlag(SettingsWindowTabGeneral.contentsName.."SettingsHelpTipsShowTutorialsButton", true )
    WindowSetId( SettingsWindowTabGeneral.contentsName.."SettingsHelpTipsShowTutorials", StringTables.UserSettings.TOOLTIP_SHOW_TUTORIALS )
    
    LabelSetText(SettingsWindowTabGeneral.contentsName.."SettingsHelpTipsHideAdvancedWindowsUntilNeededLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.LABEL_HIDE_ADVANCED_WINDOWS ) )
    ButtonSetCheckButtonFlag(SettingsWindowTabGeneral.contentsName.."SettingsHelpTipsHideAdvancedWindowsUntilNeededButton", true )
    WindowSetId( SettingsWindowTabGeneral.contentsName.."SettingsHelpTipsHideAdvancedWindowsUntilNeeded", StringTables.UserSettings.TOOLTIP_HIDE_ADVANCED_WINDOWS )
    
    LabelSetText(SettingsWindowTabGeneral.contentsName.."SettingsHelpTipsShowBeginnerTipsLabel", GetString( StringTables.Default.LABEL_SHOW_BEGINNER_TIPS ) )
    ButtonSetCheckButtonFlag(SettingsWindowTabGeneral.contentsName.."SettingsHelpTipsShowBeginnerTipsButton", true )
    WindowSetId( SettingsWindowTabGeneral.contentsName.."SettingsHelpTipsShowBeginnerTips", StringTables.UserSettings.TOOLTIP_HELP_TIPS_BEGINNER )
    
    LabelSetText(SettingsWindowTabGeneral.contentsName.."SettingsHelpTipsShowGameplayTipsLabel", GetString( StringTables.Default.LABEL_SHOW_GAMEPLAY_TIPS ) )
    ButtonSetCheckButtonFlag(SettingsWindowTabGeneral.contentsName.."SettingsHelpTipsShowGameplayTipsButton", true )
    WindowSetId( SettingsWindowTabGeneral.contentsName.."SettingsHelpTipsShowGameplayTips", StringTables.UserSettings.TOOLTIP_HELP_TIPS_GAMEPLAY )
    
    LabelSetText(SettingsWindowTabGeneral.contentsName.."SettingsHelpTipsShowUiTipsLabel", GetString( StringTables.Default.LABEL_SHOW_UI_TIPS ) )
    ButtonSetCheckButtonFlag(SettingsWindowTabGeneral.contentsName.."SettingsHelpTipsShowUiTipsButton", true )
    WindowSetId( SettingsWindowTabGeneral.contentsName.."SettingsHelpTipsShowUiTips", StringTables.UserSettings.TOOLTIP_HELP_TIPS_UI )
    
    LabelSetText(SettingsWindowTabGeneral.contentsName.."SettingsHelpTipsShowAdvancedTipsLabel", GetString( StringTables.Default.LABEL_SHOW_ADVANCED_TIPS ) )
    ButtonSetCheckButtonFlag(SettingsWindowTabGeneral.contentsName.."SettingsHelpTipsShowAdvancedTipsButton", true )
    WindowSetId( SettingsWindowTabGeneral.contentsName.."SettingsHelpTipsShowAdvancedTips", StringTables.UserSettings.TOOLTIP_HELP_TIPS_ADVANCED )
    
    -- Dialog Warnings
    LabelSetText(SettingsWindowTabGeneral.contentsName.."SettingsDialogWarningsTitle", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.DLG_WARNINGS_SECTION_LABEL ) )
    
    LabelSetText(SettingsWindowTabGeneral.contentsName.."SettingsDialogWarningsWarnBuyLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.DLG_WARNINGS_BUY ) )
    WindowSetId(SettingsWindowTabGeneral.contentsName.."SettingsDialogWarningsWarnBuy", StringTables.UserSettings.TOOLTIP_DLG_WARNINGS_BUY)
    
    LabelSetText(SettingsWindowTabGeneral.contentsName.."SettingsDialogWarningsWarnSellLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.DLG_WARNINGS_SELL ) )  
    WindowSetId(SettingsWindowTabGeneral.contentsName.."SettingsDialogWarningsWarnSell", StringTables.UserSettings.TOOLTIP_DLG_WARNINGS_SELL)
    
    LabelSetText(SettingsWindowTabGeneral.contentsName.."SettingsDialogWarningsWarnRepairLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.DLG_WARNINGS_REPAIR ) )
    WindowSetId(SettingsWindowTabGeneral.contentsName.."SettingsDialogWarningsWarnRepair", StringTables.UserSettings.TOOLTIP_DLG_WARNINGS_REPAIR)
    
    LabelSetText(SettingsWindowTabGeneral.contentsName.."SettingsDialogWarningsWarnRefineLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.DLG_WARNINGS_REFINE ) )
    WindowSetId(SettingsWindowTabGeneral.contentsName.."SettingsDialogWarningsWarnRefine", StringTables.UserSettings.TOOLTIP_DLG_WARNINGS_REFINE)
    
    LabelSetText(SettingsWindowTabGeneral.contentsName.."SettingsDialogWarningsWarnRefineCurrencyLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.DLG_WARNINGS_REFINE_CURRENCY ) )
    WindowSetId(SettingsWindowTabGeneral.contentsName.."SettingsDialogWarningsWarnRefineCurrency", StringTables.UserSettings.TOOLTIP_DLG_WARNINGS_REFINE_CURRENCY)
    
    LabelSetText(SettingsWindowTabGeneral.contentsName.."SettingsDialogWarningsWarnPerfLevelLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.DLG_WARNINGS_PERF_LEVEL ) )
    
    -- Camera
    LabelSetText( SettingsWindowTabGeneral.contentsName.."SettingsCameraTitle", GetString( StringTables.Default.LABEL_CAMERA ) )
    
    LabelSetText( SettingsWindowTabGeneral.contentsName.."SettingsCameraUseFirstPersonViewLabel", GetString( StringTables.Default.LABEL_USE_FIRST_PERSON ) )
    ButtonSetCheckButtonFlag( SettingsWindowTabGeneral.contentsName.."SettingsCameraUseFirstPersonViewButton", true )
    WindowSetId(SettingsWindowTabGeneral.contentsName.."SettingsCameraUseFirstPersonView", StringTables.UserSettings.TOOLTIP_USE_FIRST_PERSON)
    
    LabelSetText( SettingsWindowTabGeneral.contentsName.."SettingsCameraInvertMouselookLabel", GetString( StringTables.Default.LABEL_INVERT_MOUSLOOK ) )
    ButtonSetCheckButtonFlag( SettingsWindowTabGeneral.contentsName.."SettingsCameraInvertMouselookButton", true )
    WindowSetId(SettingsWindowTabGeneral.contentsName.."SettingsCameraInvertMouselook", StringTables.UserSettings.TOOLTIP_INVERT_MOUSLOOK)
    
    LabelSetText( SettingsWindowTabGeneral.contentsName.."SettingsCameraPlayerFadeLabel", GetString( StringTables.Default.LABEL_PLAYER_FADE ) )
    ButtonSetCheckButtonFlag( SettingsWindowTabGeneral.contentsName.."SettingsCameraPlayerFadeButton", true )
    WindowSetId(SettingsWindowTabGeneral.contentsName.."SettingsCameraPlayerFade", StringTables.UserSettings.TOOLTIP_PLAYER_FADE)
    
    LabelSetText( SettingsWindowTabGeneral.contentsName.."SettingsCameraSmartFollowLabel", GetString( StringTables.Default.LABEL_SMART_FOLLOW ) )
    ButtonSetCheckButtonFlag( SettingsWindowTabGeneral.contentsName.."SettingsCameraSmartFollowButton", true )
    WindowSetId(SettingsWindowTabGeneral.contentsName.."SettingsCameraSmartFollow", StringTables.UserSettings.TOOLTIP_SMART_FOLLOW)
    
end

function SettingsWindowTabGeneral.UpdateSettings()
    --Game Play
    ButtonSetPressedFlag( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayAllowAutoQueueingButton", SystemData.Settings.GamePlay.autoQueueing )
    ButtonSetPressedFlag( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayAutoLootAllButton", SystemData.Settings.GamePlay.autoLootAll )
    ButtonSetPressedFlag( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayShowToolTipsButton", SystemData.Settings.GamePlay.showToolTips )
    ButtonSetPressedFlag( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayStaticTooltipsButton", SystemData.Settings.GamePlay.staticTooltipPlacement )
    ButtonSetPressedFlag( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayStaticAbilityTooltipsButton", SystemData.Settings.GamePlay.staticAbilityTooltipPlacement )
    ButtonSetPressedFlag( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayClickThroughSelfButton", SystemData.Settings.GamePlay.clickThroughSelf )
    ButtonSetPressedFlag( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayShowRvRAlertsButton", SystemData.Settings.GamePlay.showRvrScreenMsgs )
    ButtonSetPressedFlag( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayPreventPlayerStatusFadeButton", SystemData.Settings.GamePlay.preventHealthBarFade )
    ButtonSetPressedFlag( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayClickToMoveButton", SystemData.Settings.GamePlay.clickToMove )
    ButtonSetPressedFlag( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayStickyTargetingButton", SystemData.Settings.GamePlay.stickyTargeting )
    ButtonSetPressedFlag( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayAutoLootInRvRButton", SystemData.Settings.GamePlay.autoLootInRvR )
    ButtonSetPressedFlag( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayOldMinimapBorderButton", SystemData.Settings.GamePlay.oldMinimapBorder )
    ComboBoxSetSelectedMenuItem( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayCombatLightingCombo", SystemData.Settings.GamePlay.combatLighting )
    
    -- Tutorial & Help Tips
    
    local buttonName = SettingsWindowTabGeneral.contentsName.."SettingsHelpTipsShowTutorialsButton"
    if( TutorialWindow ~= nil )
    then
        ButtonSetPressedFlag( buttonName, TutorialWindow.GetShowTutorials() )
    else        
        ButtonSetPressedFlag( buttonName, true )
        ButtonSetDisabledFlag( buttonName, true )
    end    
    
    buttonName = SettingsWindowTabGeneral.contentsName.."SettingsHelpTipsHideAdvancedWindowsUntilNeededButton"
    if( EA_AdvancedWindowManager ~= nil )
    then
        ButtonSetPressedFlag( buttonName , EA_AdvancedWindowManager.GetHideAdvancedWindowsUntilNeeded() )
    else
        ButtonSetPressedFlag( buttonName, true )
        ButtonSetDisabledFlag( buttonName, true )
    end
    
    ButtonSetPressedFlag(SettingsWindowTabGeneral.contentsName.."SettingsHelpTipsShowBeginnerTipsButton", SystemData.Settings.GamePlay.showBeginnerHelpTips )
    ButtonSetPressedFlag(SettingsWindowTabGeneral.contentsName.."SettingsHelpTipsShowGameplayTipsButton", SystemData.Settings.GamePlay.showGameplayHelpTips )
    ButtonSetPressedFlag(SettingsWindowTabGeneral.contentsName.."SettingsHelpTipsShowUiTipsButton", SystemData.Settings.GamePlay.showUiHelpTips )
    ButtonSetPressedFlag(SettingsWindowTabGeneral.contentsName.."SettingsHelpTipsShowAdvancedTipsButton", SystemData.Settings.GamePlay.showAdvancedHelpTips )
    
    -- Dialog Warnings
    ButtonSetPressedFlag(SettingsWindowTabGeneral.contentsName.."SettingsDialogWarningsWarnBuyButton", SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_BUY] )
    ButtonSetPressedFlag(SettingsWindowTabGeneral.contentsName.."SettingsDialogWarningsWarnSellButton", SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_SELL] )
    ButtonSetPressedFlag(SettingsWindowTabGeneral.contentsName.."SettingsDialogWarningsWarnRepairButton", SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_REPAIR] )
    ButtonSetPressedFlag(SettingsWindowTabGeneral.contentsName.."SettingsDialogWarningsWarnRefineButton", SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_REFINEMENT] )
    ButtonSetPressedFlag(SettingsWindowTabGeneral.contentsName.."SettingsDialogWarningsWarnRefineCurrencyButton", SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_REFINEMENT_CURRENCY] )
    ButtonSetPressedFlag(SettingsWindowTabGeneral.contentsName.."SettingsDialogWarningsWarnPerfLevelButton", SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_PERFORMANCE] )
    
    -- Camera    
    ButtonSetPressedFlag( SettingsWindowTabGeneral.contentsName.."SettingsCameraUseFirstPersonViewButton", SystemData.Settings.Camera.useFirstPersonView )
    ButtonSetPressedFlag( SettingsWindowTabGeneral.contentsName.."SettingsCameraInvertMouselookButton", SystemData.Settings.Camera.invertMouseLook )
    ButtonSetPressedFlag( SettingsWindowTabGeneral.contentsName.."SettingsCameraPlayerFadeButton", SystemData.Settings.Camera.playerFade )
    ButtonSetPressedFlag( SettingsWindowTabGeneral.contentsName.."SettingsCameraSmartFollowButton", SystemData.Settings.Camera.smartFollow )
end

function SettingsWindowTabGeneral.ApplyCurrent()
    -- Game Play
    SystemData.Settings.GamePlay.autoQueueing                   = ButtonGetPressedFlag( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayAllowAutoQueueingButton" )
    SystemData.Settings.GamePlay.autoLootAll                    = ButtonGetPressedFlag( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayAutoLootAllButton" )
    SystemData.Settings.GamePlay.showToolTips                   = ButtonGetPressedFlag( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayShowToolTipsButton" )
    SystemData.Settings.GamePlay.staticTooltipPlacement         = ButtonGetPressedFlag( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayStaticTooltipsButton" )
    SystemData.Settings.GamePlay.staticAbilityTooltipPlacement  = ButtonGetPressedFlag( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayStaticAbilityTooltipsButton" )
    SystemData.Settings.GamePlay.clickThroughSelf               = ButtonGetPressedFlag( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayClickThroughSelfButton" )
    SystemData.Settings.GamePlay.showRvrScreenMsgs              = ButtonGetPressedFlag( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayShowRvRAlertsButton" )
    SystemData.Settings.GamePlay.preventHealthBarFade           = ButtonGetPressedFlag( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayPreventPlayerStatusFadeButton" )
    SystemData.Settings.GamePlay.clickToMove                    = ButtonGetPressedFlag( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayClickToMoveButton" )
    SystemData.Settings.GamePlay.stickyTargeting                = ButtonGetPressedFlag( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayStickyTargetingButton" )
    SystemData.Settings.GamePlay.autoLootInRvR                  = ButtonGetPressedFlag( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayAutoLootInRvRButton" )
    SystemData.Settings.GamePlay.oldMinimapBorder               = ButtonGetPressedFlag( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayOldMinimapBorderButton" )
    SystemData.Settings.GamePlay.combatLighting                 = ComboBoxGetSelectedMenuItem( SettingsWindowTabGeneral.contentsName.."SettingsGamePlayCombatLightingCombo" )

    -- Tutorial & Help Tips
    if( TutorialWindow ~= nil )
    then
        TutorialWindow.SetShowTutorials( ButtonGetPressedFlag(SettingsWindowTabGeneral.contentsName.."SettingsHelpTipsShowTutorialsButton" ) )
    end
    
    if( EA_AdvancedWindowManager ~= nil )
    then
        EA_AdvancedWindowManager.SetHideAdvancedWindowsUntilNeeded( ButtonGetPressedFlag(SettingsWindowTabGeneral.contentsName.."SettingsHelpTipsHideAdvancedWindowsUntilNeededButton" ) )
    end
        
    SystemData.Settings.GamePlay.showBeginnerHelpTips           = ButtonGetPressedFlag(SettingsWindowTabGeneral.contentsName.."SettingsHelpTipsShowBeginnerTipsButton" )
    SystemData.Settings.GamePlay.showGameplayHelpTips           = ButtonGetPressedFlag(SettingsWindowTabGeneral.contentsName.."SettingsHelpTipsShowGameplayTipsButton" )
    SystemData.Settings.GamePlay.showUiHelpTips                 = ButtonGetPressedFlag(SettingsWindowTabGeneral.contentsName.."SettingsHelpTipsShowUiTipsButton" )
    SystemData.Settings.GamePlay.showAdvancedHelpTips           = ButtonGetPressedFlag(SettingsWindowTabGeneral.contentsName.."SettingsHelpTipsShowAdvancedTipsButton" )
    
    -- Dialog Warnings
    SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_BUY] = ButtonGetPressedFlag(SettingsWindowTabGeneral.contentsName.."SettingsDialogWarningsWarnBuyButton" )
    SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_SELL] = ButtonGetPressedFlag(SettingsWindowTabGeneral.contentsName.."SettingsDialogWarningsWarnSellButton" )
    SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_REPAIR] = ButtonGetPressedFlag(SettingsWindowTabGeneral.contentsName.."SettingsDialogWarningsWarnRepairButton" )
    SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_REFINEMENT] = ButtonGetPressedFlag(SettingsWindowTabGeneral.contentsName.."SettingsDialogWarningsWarnRefineButton" )
    SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_REFINEMENT_CURRENCY] = ButtonGetPressedFlag(SettingsWindowTabGeneral.contentsName.."SettingsDialogWarningsWarnRefineCurrencyButton" )
    SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_PERFORMANCE] = ButtonGetPressedFlag(SettingsWindowTabGeneral.contentsName.."SettingsDialogWarningsWarnPerfLevelButton" )
    
    -- Camera    
    SystemData.Settings.Camera.useFirstPersonView = ButtonGetPressedFlag( SettingsWindowTabGeneral.contentsName.."SettingsCameraUseFirstPersonViewButton" )
    SystemData.Settings.Camera.invertMouseLook = ButtonGetPressedFlag( SettingsWindowTabGeneral.contentsName.."SettingsCameraInvertMouselookButton" )
    SystemData.Settings.Camera.playerFade = ButtonGetPressedFlag( SettingsWindowTabGeneral.contentsName.."SettingsCameraPlayerFadeButton" )
    SystemData.Settings.Camera.smartFollow = ButtonGetPressedFlag( SettingsWindowTabGeneral.contentsName.."SettingsCameraSmartFollowButton" )
end

function SettingsWindowTabGeneral.OnWarnPerfLevelLButtonUp()

    EA_LabelCheckButton.Toggle()
    
    SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_PERFORMANCE] = ButtonGetPressedFlag(SettingsWindowTabGeneral.contentsName.."SettingsDialogWarningsWarnPerfLevelButton" )
end

function SettingsWindowTabGeneral.UpdateDialogWarnings(whichWarning)
    if (whichWarning==SystemData.Settings.DlgWarning.WARN_BUY) then
        ButtonSetPressedFlag( SettingsWindowTabGeneral.contentsName.."SettingsDialogWarningsWarnBuyButton", SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_BUY] )
    elseif (whichWarning==SystemData.Settings.DlgWarning.WARN_SELL) then
        ButtonSetPressedFlag( SettingsWindowTabGeneral.contentsName.."SettingsDialogWarningsWarnSellButton", SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_SELL] )
    elseif (whichWarning==SystemData.Settings.DlgWarning.WARN_REPAIR) then
        ButtonSetPressedFlag( SettingsWindowTabGeneral.contentsName.."SettingsDialogWarningsWarnRepairButton", SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_REPAIR] )
    elseif (whichWarning==SystemData.Settings.DlgWarning.WARN_REFINEMENT) then
        ButtonSetPressedFlag( SettingsWindowTabGeneral.contentsName.."SettingsDialogWarningsWarnRefineButton", SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_REFINEMENT] )
    elseif (whichWarning==SystemData.Settings.DlgWarning.WARN_REFINEMENT_CURRENCY) then
        ButtonSetPressedFlag( SettingsWindowTabGeneral.contentsName.."SettingsDialogWarningsWarnRefineCurrencyButton", SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_REFINEMENT_CURRENCY] )
    end
end


