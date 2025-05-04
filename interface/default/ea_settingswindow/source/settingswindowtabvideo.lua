SettingsWindowTabVideo = {}

SettingsWindowTabVideo.contentsName = "SWTabVideoContentsScrollChild"

SettingsWindowTabVideo.FullscreenResolutions = {}
SettingsWindowTabVideo.WindowedResolutions = {}
SettingsWindowTabVideo.NUM_RESOLUTIONS = 0
SettingsWindowTabVideo.NUM_WINDOWED_RESOLUTIONS = 0

SettingsWindowTabVideo.DEFAULT_GLOBAL_UI_SCALE = 1.0
SettingsWindowTabVideo.MIN_GLOBAL_UI_SCALE = 0.50
SettingsWindowTabVideo.MAX_GLOBAL_UI_SCALE = 1.50

SettingsWindowTabVideo.GLOBAL_UI_SCALE_RANGE = SettingsWindowTabVideo.MAX_GLOBAL_UI_SCALE - SettingsWindowTabVideo.MIN_GLOBAL_UI_SCALE
SettingsWindowTabVideo.DEFAULT_GLOBAL_UI_SCALE_SLIDER_POS = ( SettingsWindowTabVideo.DEFAULT_GLOBAL_UI_SCALE - SettingsWindowTabVideo.MIN_GLOBAL_UI_SCALE ) / SettingsWindowTabVideo.GLOBAL_UI_SCALE_RANGE
  
SettingsWindowTabVideo.initalGlobalUiScaleValue = nil

SettingsWindowTabVideo.currentGlobalUiScaleSliderPos = nil
SettingsWindowTabVideo.newGlobalUiScaleSliderPos = nil

function SettingsWindowTabVideo.Initialize()
    -- Resolution
    LabelSetText( SettingsWindowTabVideo.contentsName.."SettingsResolutionTitle", GetString( StringTables.Default.LABEL_DISPLAY ) )
    
    LabelSetText( SettingsWindowTabVideo.contentsName.."SettingsResolutionWindowedResLabel", GetString( StringTables.Default.LABEL_WINDOWED )..L":" )
    WindowSetId( SettingsWindowTabVideo.contentsName.."SettingsResolutionWindowedResLabel", StringTables.UserSettings.TOOLTIP_WINDOWED)
    
    LabelSetText( SettingsWindowTabVideo.contentsName.."SettingsResolutionFullScreenResLabel", GetString( StringTables.Default.LABEL_FULLSCREEN )..L":" )
    WindowSetId( SettingsWindowTabVideo.contentsName.."SettingsResolutionFullScreenResLabel", StringTables.UserSettings.TOOLTIP_FULLSCREEN)
    
    
    LabelSetText( SettingsWindowTabVideo.contentsName.."SettingsResolutionShowFrameLabel", GetString( StringTables.Default.LABEL_SHOW_FRAME ))
    ButtonSetCheckButtonFlag( SettingsWindowTabVideo.contentsName.."SettingsResolutionShowFrameButton", true )
    WindowSetId( SettingsWindowTabVideo.contentsName.."SettingsResolutionShowFrame", StringTables.UserSettings.TOOLTIP_SHOW_FRAME)
    
    LabelSetText( SettingsWindowTabVideo.contentsName.."SettingsResolutionUseFullscreenLabel", GetString( StringTables.Default.LABEL_USE_FULLSCREEN ) )
    ButtonSetCheckButtonFlag( SettingsWindowTabVideo.contentsName.."SettingsResolutionUseFullscreenButton", true )
    WindowSetId( SettingsWindowTabVideo.contentsName.."SettingsResolutionUseFullscreen", StringTables.UserSettings.TOOLTIP_USE_FULLSCREEN)
    
    SettingsWindowTabVideo.NUM_RESOLUTIONS = SystemData.Settings.Resolution.numAdapterModes

    for res = 1, SettingsWindowTabVideo.NUM_RESOLUTIONS do
        local curRes = { w = SystemData.Settings.Resolution.adapterModes.widths[res], h = SystemData.Settings.Resolution.adapterModes.heights[res] }
        local resString = L""..curRes.w..L" x "..curRes.h

        ComboBoxAddMenuItem( SettingsWindowTabVideo.contentsName.."SettingsResolutionFullScreenResCombo",    resString)
        
        SettingsWindowTabVideo.FullscreenResolutions[res] = { x = curRes.w, y = curRes.h }
    end

    SettingsWindowTabVideo.NUM_WINDOWED_RESOLUTIONS = SystemData.Settings.Resolution.numWindowedModes

    for res = 1, SettingsWindowTabVideo.NUM_WINDOWED_RESOLUTIONS do
        local curRes = { w = SystemData.Settings.Resolution.windowedModes.widths[res], h = SystemData.Settings.Resolution.windowedModes.heights[res] }
        local resString = L""..curRes.w..L" x "..curRes.h

        ComboBoxAddMenuItem( SettingsWindowTabVideo.contentsName.."SettingsResolutionWindowedResCombo",      resString)
        
        SettingsWindowTabVideo.WindowedResolutions[res] = { x = curRes.w, y = curRes.h }
    end
    
    WindowSetId( SettingsWindowTabVideo.contentsName.."SettingsResolutionFullScreenResCombo", StringTables.UserSettings.TOOLTIP_FULLSCREEN)
    WindowSetId( SettingsWindowTabVideo.contentsName.."SettingsResolutionWindowedResCombo", StringTables.UserSettings.TOOLTIP_WINDOWED)
    
    -- Global UI Scale
    local bodyWindowName = SettingsWindowTabVideo.contentsName.."SettingsGlobalUIScale"
    
    -- Interface Settings can only be modified In-Game.
    if( InterfaceCore.inGame == false )
    then
        --Hide the global UI scale options
        WindowSetShowing( bodyWindowName, false )
        WindowClearAnchors( SettingsWindowTabVideo.contentsName.."SettingsPerformance" )
        WindowAddAnchor( SettingsWindowTabVideo.contentsName.."SettingsPerformance", "bottomleft", SettingsWindowTabVideo.contentsName.."SettingsResolution", "topleft", 0, 0 )
        WindowAddAnchor( SettingsWindowTabVideo.contentsName.."SettingsPerformance", "bottomright", SettingsWindowTabVideo.contentsName.."SettingsResolution", "topright", 0, 0 )  
    else
        LabelSetText( bodyWindowName.."Title", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_GLOBAL_UI_SCALE ) )    
        
        LabelSetText(  bodyWindowName.."UiScaleSliderMinLabel", L""..SettingsWindowTabVideo.MIN_GLOBAL_UI_SCALE )
        LabelSetText(  bodyWindowName.."UiScaleSliderMaxLabel", L""..SettingsWindowTabVideo.MAX_GLOBAL_UI_SCALE )
        
        local midValue = (SettingsWindowTabVideo.MIN_GLOBAL_UI_SCALE + SettingsWindowTabVideo.MAX_GLOBAL_UI_SCALE )/ 2
        LabelSetText(  bodyWindowName.."UiScaleSliderMidLabel", L""..midValue )   
           
        ButtonSetText( bodyWindowName.."PreviewUiScaleButton", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_PREVIEW ) )   
        ButtonSetText( bodyWindowName.."RestoreDefaultUiScaleButton", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_DEFAULT ) )    
    end
    
    WindowSetId( bodyWindowName.."UiScaleSlider", StringTables.UserSettings.TOOLTIP_GLOBAL_UI_SCALE)

    -- Performance
    LabelSetText(SettingsWindowTabVideo.contentsName.."SettingsPerformanceTitle", GetString( StringTables.Default.LABEL_PERFORMANCE ) )
    LabelSetText(SettingsWindowTabVideo.contentsName.."SettingsPerformancePerformanceLabel", GetString( StringTables.Default.LABEL_LEVEL )..L":" )
    WindowSetId( SettingsWindowTabVideo.contentsName.."SettingsPerformancePerformanceLabel", StringTables.UserSettings.TOOLTIP_PERF_LEVEL)
    
    ButtonSetText(SettingsWindowTabVideo.contentsName.."SettingsPerformanceCustomizeButton", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_CUSTOMIZE ))
    
    ComboBoxAddMenuItem(SettingsWindowTabVideo.contentsName.."SettingsPerformancePerformanceCombo", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.LABEL_PERFORMANCE_LOW ))
    ComboBoxAddMenuItem(SettingsWindowTabVideo.contentsName.."SettingsPerformancePerformanceCombo", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.LABEL_PERFORMANCE_MEDIUM ))
    ComboBoxAddMenuItem(SettingsWindowTabVideo.contentsName.."SettingsPerformancePerformanceCombo", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.LABEL_PERFORMANCE_HIGH ))
    ComboBoxAddMenuItem(SettingsWindowTabVideo.contentsName.."SettingsPerformancePerformanceCombo", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.LABEL_PERFORMANCE_VERY_HIGH ))
    ComboBoxAddMenuItem(SettingsWindowTabVideo.contentsName.."SettingsPerformancePerformanceCombo", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_CUSTOM1 ))
    ComboBoxAddMenuItem(SettingsWindowTabVideo.contentsName.."SettingsPerformancePerformanceCombo", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_CUSTOM2 ))
    WindowSetId( SettingsWindowTabVideo.contentsName.."SettingsPerformancePerformanceCombo", StringTables.UserSettings.TOOLTIP_PERF_LEVEL)
    
    LabelSetText(SettingsWindowTabVideo.contentsName.."SettingsPerformanceShaderCachingLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_SHADER_CACHING_LABEL ))
    ButtonSetCheckButtonFlag(SettingsWindowTabVideo.contentsName.."SettingsPerformanceShaderCachingButton", true )
    
    -- Brightness and Gamma
    LabelSetText( SettingsWindowTabVideo.contentsName.."SettingsColorTitle", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.COLOR_LABEL ) )
    LabelSetText( SettingsWindowTabVideo.contentsName.."SettingsColorBrightnessLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.COLOR_BRIGHTNESS_LABEL ) )
    LabelSetText( SettingsWindowTabVideo.contentsName.."SettingsColorGammaLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.COLOR_GAMMA_LABEL ) )
    LabelSetText( SettingsWindowTabVideo.contentsName.."SettingsColorInstructionsLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.COLOR_INSTRUCTIONS ) )
    LabelSetText( SettingsWindowTabVideo.contentsName.."SettingsColorDisabledLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.COLOR_DISABLED ) )
end

function SettingsWindowTabVideo.UpdateSettings()
    -- Resolution
       
    for res = 1, SettingsWindowTabVideo.NUM_WINDOWED_RESOLUTIONS do           
        if( SystemData.Settings.Resolution.windowed.width == SettingsWindowTabVideo.WindowedResolutions[res].x and 
            SystemData.Settings.Resolution.windowed.height == SettingsWindowTabVideo.WindowedResolutions[res].y) then
            ComboBoxSetSelectedMenuItem( SettingsWindowTabVideo.contentsName.."SettingsResolutionWindowedResCombo", res )   
            break
        end       
    end
    
    for res = 1, SettingsWindowTabVideo.NUM_RESOLUTIONS do    
        if( SystemData.Settings.Resolution.fullScreen.width == SettingsWindowTabVideo.FullscreenResolutions[res].x and 
            SystemData.Settings.Resolution.fullScreen.height == SettingsWindowTabVideo.FullscreenResolutions[res].y) then            
            ComboBoxSetSelectedMenuItem( SettingsWindowTabVideo.contentsName.."SettingsResolutionFullScreenResCombo", res )    
            break
        end       
    end
    
    ButtonSetPressedFlag( SettingsWindowTabVideo.contentsName.."SettingsResolutionShowFrameButton", SystemData.Settings.Resolution.showWindowFrame )
    ButtonSetPressedFlag( SettingsWindowTabVideo.contentsName.."SettingsResolutionUseFullscreenButton", SystemData.Settings.Resolution.useFullScreen )

    -- Global UI Scale
    local bodyWindowName = SettingsWindowTabVideo.contentsName.."SettingsGlobalUIScale"
    local scaleSliderPos = ( SystemData.Settings.Interface.globalUiScale - SettingsWindowTabVideo.MIN_GLOBAL_UI_SCALE) 
                        / SettingsWindowTabVideo.GLOBAL_UI_SCALE_RANGE   

    SliderBarSetCurrentPosition( bodyWindowName.."UiScaleSlider", scaleSliderPos )
    
    SettingsWindowTabVideo.currentGlobalUiScaleSliderPos = sliderPos
    SettingsWindowTabVideo.newGlobalUiScaleSliderPos = sliderPos

    SettingsWindowTabVideo.initalGlobalUiScaleValue = SystemData.Settings.Interface.globalUiScale 
    
    SettingsWindowTabVideo.UpdateUiScaleButtons()
    
    -- Performance
    ComboBoxSetSelectedMenuItem(SettingsWindowTabVideo.contentsName.."SettingsPerformancePerformanceCombo", SystemData.Settings.Performance.perfLevel )   
    ButtonSetPressedFlag(SettingsWindowTabVideo.contentsName.."SettingsPerformanceShaderCachingButton", SystemData.Settings.Performance.shaderCaching )
    
    -- Color
    SliderBarSetCurrentPosition( SettingsWindowTabVideo.contentsName.."SettingsColorBrightnessSlider", SystemData.Settings.Color.brightness_boost * 4.0 )
    SliderBarSetCurrentPosition( SettingsWindowTabVideo.contentsName.."SettingsColorGammaSlider", (SystemData.Settings.Color.monitor_gamma - 1.0) / 3.0 )
    SettingsWindowTabVideo.EnableDisableGamma()
end

function SettingsWindowTabVideo.ApplyCurrent()

    -- Resolution
    local windowedRes = ComboBoxGetSelectedMenuItem( SettingsWindowTabVideo.contentsName.."SettingsResolutionWindowedResCombo" )    
    SystemData.Settings.Resolution.windowed.width  = SettingsWindowTabVideo.WindowedResolutions[windowedRes].x
    SystemData.Settings.Resolution.windowed.height = SettingsWindowTabVideo.WindowedResolutions[windowedRes].y
    
    local fullScreenRes = ComboBoxGetSelectedMenuItem( SettingsWindowTabVideo.contentsName.."SettingsResolutionFullScreenResCombo" ) 
    SystemData.Settings.Resolution.fullScreen.width = SettingsWindowTabVideo.FullscreenResolutions[fullScreenRes].x
    SystemData.Settings.Resolution.fullScreen.height = SettingsWindowTabVideo.FullscreenResolutions[fullScreenRes].y
    
    SystemData.Settings.Resolution.showWindowFrame = ButtonGetPressedFlag( SettingsWindowTabVideo.contentsName.."SettingsResolutionShowFrameButton" )
    SystemData.Settings.Resolution.useFullScreen = ButtonGetPressedFlag( SettingsWindowTabVideo.contentsName.."SettingsResolutionUseFullscreenButton" )

    -- Global UI Scale
    SettingsWindowTabVideo.SaveUiScaleSettings()
    
    -- Performance
    SystemData.Settings.Performance.perfLevel = ComboBoxGetSelectedMenuItem(SettingsWindowTabVideo.contentsName.."SettingsPerformancePerformanceCombo" )
    SystemData.Settings.Performance.shaderCaching = ButtonGetPressedFlag(SettingsWindowTabVideo.contentsName.."SettingsPerformanceShaderCachingButton" )

    -- Color
    SystemData.Settings.Color.brightness_boost = SliderBarGetCurrentPosition( SettingsWindowTabVideo.contentsName.."SettingsColorBrightnessSlider" ) / 4.0
    SystemData.Settings.Color.monitor_gamma = (SliderBarGetCurrentPosition( SettingsWindowTabVideo.contentsName.."SettingsColorGammaSlider" ) * 3.0) + 1.0
    
    SettingsWindowTabVideo.EnableDisableGamma()
    
    SettingsWindowTabVideo.UpdateSettings()
end

function SettingsWindowTabVideo.ResetSettings()

    if not (SystemData.Settings.Interface.globalUiScale == SettingsWindowTabVideo.initalGlobalUiScaleValue)
    then
        SystemData.Settings.Interface.globalUiScale = SettingsWindowTabVideo.initalGlobalUiScaleValue
        BroadcastEvent( SystemData.Events.USER_SETTINGS_CHANGED )
    end

end


function SettingsWindowTabVideo.EnableDisableGamma()
    if (SystemData.Settings.Resolution.useFullScreen) then
        WindowSetShowing(SettingsWindowTabVideo.contentsName.."SettingsColorInstructionsLabel", true )
        WindowSetShowing(SettingsWindowTabVideo.contentsName.."SettingsColorDisabledLabel", false )
        SliderBarSetDisabledFlag(SettingsWindowTabVideo.contentsName.."SettingsColorBrightnessSlider", false )
        SliderBarSetDisabledFlag(SettingsWindowTabVideo.contentsName.."SettingsColorGammaSlider", false )
        LabelSetTextColor(SettingsWindowTabVideo.contentsName.."SettingsColorBrightnessLabel", 255, 255, 255 )
        LabelSetTextColor(SettingsWindowTabVideo.contentsName.."SettingsColorGammaLabel", 255, 255, 255 )
        WindowSetTintColor(SettingsWindowTabVideo.contentsName.."SettingsColorBrightnessSlider", 255, 255, 255 )
        WindowSetTintColor(SettingsWindowTabVideo.contentsName.."SettingsColorGammaSlider", 255, 255, 255 )
        SettingsWindowTabVideo.OnGammaChanged( 0 )
    else
        WindowSetShowing(SettingsWindowTabVideo.contentsName.."SettingsColorInstructionsLabel", false )
        WindowSetShowing(SettingsWindowTabVideo.contentsName.."SettingsColorDisabledLabel", true )
        SliderBarSetDisabledFlag(SettingsWindowTabVideo.contentsName.."SettingsColorBrightnessSlider", true )
        SliderBarSetDisabledFlag(SettingsWindowTabVideo.contentsName.."SettingsColorGammaSlider", true )
        LabelSetTextColor(SettingsWindowTabVideo.contentsName.."SettingsColorBrightnessLabel", 128, 128, 128 )
        LabelSetTextColor(SettingsWindowTabVideo.contentsName.."SettingsColorGammaLabel", 128, 128, 128 )
        WindowSetTintColor(SettingsWindowTabVideo.contentsName.."SettingsColorBrightnessSlider", 128, 128, 128 )
        WindowSetTintColor(SettingsWindowTabVideo.contentsName.."SettingsColorGammaSlider", 128, 128, 128 )
    end
end

function SettingsWindowTabVideo.OnGammaChanged( ignored )
    local brightness_boost = SliderBarGetCurrentPosition(SettingsWindowTabVideo.contentsName.."SettingsColorBrightnessSlider" ) / 4.0
    local monitor_gamma = (SliderBarGetCurrentPosition(SettingsWindowTabVideo.contentsName.."SettingsColorGammaSlider" ) * 3.0) + 1.0
    Settings.SetBrightnessAndGamma( brightness_boost, monitor_gamma )
end

function SettingsWindowTabVideo.OnPerfLevelChanged()

    local shouldWarn = SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_PERFORMANCE]
    local suggestedLevel = SystemData.Settings.Performance.suggestedLevel
    local setLevel = ComboBoxGetSelectedMenuItem( SettingsWindowTabVideo.contentsName.."SettingsPerformancePerformanceCombo" )

    -- if suggested level is medium or low, and the level we are trying to set to  
    -- a higher level or custom level and should warn
    if ( (suggestedLevel == SystemData.Settings.Performance.PERF_LEVEL_LOW or 
          suggestedLevel == SystemData.Settings.Performance.PERF_LEVEL_MEDIUM) and
         (setLevel > suggestedLevel) and
         shouldWarn)
    then
    
        -- warn about changing to a non-recommended level
        DialogManager.MakeTwoButtonDialog (GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_LEVEL_CHANGE_WARNING ), 
                        GetString (StringTables.Default.LABEL_YES), nil, 
                        GetString (StringTables.Default.LABEL_NO), SettingsWindowTabVideo.ResetPerfLevel,
                        nil, nil, false,
                        SettingsWindowTabVideo.NeverWarnAboutPerfLevel)
    
    end
end

function SettingsWindowTabVideo.ResetPerfLevel()

    ComboBoxSetSelectedMenuItem( SettingsWindowTabVideo.contentsName.."SettingsPerformancePerformanceCombo", SystemData.Settings.Performance.perfLevel )
    
end

function SettingsWindowTabVideo.NeverWarnAboutPerfLevel()

    local showWarning = not SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_PERFORMANCE]    
    SystemData.Settings.ShowWarning[SystemData.Settings.DlgWarning.WARN_PERFORMANCE] = showWarning
    
    ButtonSetPressedFlag( SettingsWindowTabGeneral.contentsName.."SettingsDialogWarningsWarnPerfLevelButton", showWarning )

end

function SettingsWindowTabVideo.OnMouseOverShaderPerformanceCheckBox()

    local tipText = GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_SHADER_CACHING_TOOLTIP )
    
    if (tipText)
    then
        Tooltips.CreateTextOnlyTooltip( SystemData.MouseOverWindow.name, tipText )
        Tooltips.AnchorTooltip (nil)
    end 
end

function SettingsWindowTabVideo.OnCustomizeButton()

    local currCustom = ComboBoxGetSelectedMenuItem( SettingsWindowTabVideo.contentsName.."SettingsPerformancePerformanceCombo")
    if (currCustom == SystemData.Settings.Performance.PERF_LEVEL_CUSTOM1) then
        EA_Window_CustomizePerformance.CurrCustom = 1
    elseif (currCustom == SystemData.Settings.Performance.PERF_LEVEL_CUSTOM2) then
        EA_Window_CustomizePerformance.CurrCustom = 2
    end

    WindowSetShowing( "EA_Window_CustomizePerformance", true )
end

function SettingsWindowTabVideo.SaveUiScaleSettings()
    local bodyWindowName = SettingsWindowTabVideo.contentsName.."SettingsGlobalUIScale"

    -- Global Scale
    local scaleSliderPos = SliderBarGetCurrentPosition( bodyWindowName.."UiScaleSlider" )        
    SystemData.Settings.Interface.globalUiScale = SettingsWindowTabVideo.MIN_GLOBAL_UI_SCALE 
                                                       + scaleSliderPos*SettingsWindowTabVideo.GLOBAL_UI_SCALE_RANGE
end



function SettingsWindowTabVideo.OnCustomUiScaleSliderChanged( sliderPos )

    SettingsWindowTabVideo.newGlobalUiScaleSliderPos = sliderPos
    SettingsWindowTabVideo.UpdateUiScaleButtons()
end

function SettingsWindowTabVideo.OnPreviewUiScaleButton()

    if( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) == true )
    then
        return
    end
    

    SettingsWindowTabVideo.SaveUiScaleSettings()
    BroadcastEvent( SystemData.Events.USER_SETTINGS_CHANGED )
    
    SettingsWindowTabVideo.currentGlobalUiScaleSliderPos = SettingsWindowTabVideo.newGlobalUiScaleSliderPos
    SettingsWindowTabVideo.UpdateUiScaleButtons()
end

function SettingsWindowTabVideo.OnRestoreDefaultUiScaleButton()

    if( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) == true )
    then
        return
    end    
    
    local bodyWindowName = SettingsWindowTabVideo.contentsName.."SettingsGlobalUIScale"
    
    SliderBarSetCurrentPosition( bodyWindowName.."UiScaleSlider", SettingsWindowTabVideo.DEFAULT_GLOBAL_UI_SCALE_SLIDER_POS  )  
    
    SettingsWindowTabVideo.newGlobalUiScaleSliderPos = SettingsWindowTabVideo.DEFAULT_GLOBAL_UI_SCALE_SLIDER_POS
    
    SettingsWindowTabVideo.UpdateUiScaleButtons()
end

function SettingsWindowTabVideo.UpdateUiScaleButtons()

    local bodyWindowName = SettingsWindowTabVideo.contentsName.."SettingsGlobalUIScale"

    -- Enable the button only when something has changed.
    
    local previewDisabled = SettingsWindowTabVideo.currentGlobalUiScaleSliderPos == SettingsWindowTabVideo.newGlobalUiScaleSliderPos        
    ButtonSetDisabledFlag( bodyWindowName.."PreviewUiScaleButton",previewDisabled )
    
    local restoreDisabled = SettingsWindowTabVideo.newGlobalUiScaleSliderPos == SettingsWindowTabVideo.DEFAULT_GLOBAL_UI_SCALE_SLIDER_POS 
    ButtonSetDisabledFlag( bodyWindowName.."RestoreDefaultUiScaleButton", restoreDisabled )

end

function SettingsWindowTabVideo.SetCustomPerformance(customPerfLevel)
    
    if (customPerfLevel==1)
    then
        ComboBoxSetSelectedMenuItem( SettingsWindowTabVideo.contentsName.."SettingsPerformancePerformanceCombo", SystemData.Settings.Performance.PERF_LEVEL_CUSTOM1 )
    else
        ComboBoxSetSelectedMenuItem( SettingsWindowTabVideo.contentsName.."SettingsPerformancePerformanceCombo", SystemData.Settings.Performance.PERF_LEVEL_CUSTOM2 )
    end
    
    SettingsWindowTabVideo.OnPerfLevelChanged()
end


