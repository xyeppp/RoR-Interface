local NUM_CUSTOMS = 2

local LocalSettings = {}

EA_Window_CustomizePerformance = {}

EA_Window_CustomizePerformance.CurrCustom = 1
EA_Window_CustomizePerformance.textureCacheSliderEnabled = true

function EA_Window_CustomizePerformance.OnShow()
    WindowUtils.OnShown()
    EA_Window_CustomizePerformance.ClearCustomSelectRadio()
    EA_Window_CustomizePerformance.StoreSettingsLocally()
    EA_Window_CustomizePerformance.UpdateSettings()
end

function EA_Window_CustomizePerformance.Initialize()
    -- Window Title Bar
    LabelSetText( "EA_Window_CustomizePerformanceTitleBarText", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_WINDOW_TITLE ) )

    -- Which custom setting you are working on
    LabelSetText( "EA_Window_CustomizePerformanceCustomSettingLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_WHICH_CUSTOM )..L":" )
    LabelSetText( "EA_Window_CustomizePerformanceCustom1Label", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_CUSTOM1 ) )
    LabelSetText( "EA_Window_CustomizePerformanceCustom2Label", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_CUSTOM2 ) )

    -- Defaults
    LabelSetText( "EA_Window_CustomizePerformanceDefaults", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_DEFAULTS )..L":" )
    ButtonSetText( "EA_Window_CustomizePerformanceVeryHighQualButton", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.LABEL_PERFORMANCE_VERY_HIGH ))
    ButtonSetText( "EA_Window_CustomizePerformanceHighQualButton", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.LABEL_PERFORMANCE_HIGH ))
    ButtonSetText( "EA_Window_CustomizePerformanceBalancedButton", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.LABEL_PERFORMANCE_MEDIUM ))
    ButtonSetText( "EA_Window_CustomizePerformanceFastestButton", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.LABEL_PERFORMANCE_LOW ))

    -- Environment    
    LabelSetText( "EA_Window_CustomizePerformanceEnvironmentLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_ENVIRONMENT ) )

    LabelSetText( "EA_Window_CustomizePerformanceDrawDistanceLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_DRAW_DISTANCE ) )
    LabelSetText( "EA_Window_CustomizePerformanceDrawNearLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_NEAR ) )
    LabelSetText( "EA_Window_CustomizePerformanceDrawFarLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_FAR ) )

    LabelSetText( "EA_Window_CustomizePerformanceEnableGrassLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_GRASS ) )
    LabelSetText( "EA_Window_CustomizePerformanceEnableWaterReflectionLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_WATER_REF ) )
    LabelSetText( "EA_Window_CustomizePerformanceEnableWaterWakeLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_WATER_WAKE ) )

    -- Effects
    LabelSetText( "EA_Window_CustomizePerformanceEffectsLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_EFFECTS ) )
    LabelSetText( "EA_Window_CustomizePerformanceEffectsDetailLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_EFFECTS_DETAIL )..L":" )
    ComboBoxAddMenuItem( "EA_Window_CustomizePerformanceEffectsQualityCombo", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.LABEL_PERFORMANCE_HIGH ))
    ComboBoxAddMenuItem( "EA_Window_CustomizePerformanceEffectsQualityCombo", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.LABEL_PERFORMANCE_MEDIUM ))
    ComboBoxAddMenuItem( "EA_Window_CustomizePerformanceEffectsQualityCombo", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.LABEL_PERFORMANCE_LOW ))
    LabelSetText( "EA_Window_CustomizePerformanceAbilityEffectsLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_ABILITY_EFFECTS_ON )..L":" )
    ComboBoxAddMenuItem( "EA_Window_CustomizePerformanceAbilityEffectsCombo", GetStringFromTable( "UserSettingsStrings",  StringTables.UserSettings.PERFORMANCE_ABILITY_EFFECTS_NONE ))
    ComboBoxAddMenuItem( "EA_Window_CustomizePerformanceAbilityEffectsCombo", GetStringFromTable( "UserSettingsStrings",  StringTables.UserSettings.PERFORMANCE_ABILITY_EFFECTS_SELF ))
    ComboBoxAddMenuItem( "EA_Window_CustomizePerformanceAbilityEffectsCombo", GetStringFromTable( "UserSettingsStrings",  StringTables.UserSettings.PERFORMANCE_ABILITY_EFFECTS_PARTY ))
    ComboBoxAddMenuItem( "EA_Window_CustomizePerformanceAbilityEffectsCombo", GetStringFromTable( "UserSettingsStrings",  StringTables.UserSettings.PERFORMANCE_ABILITY_EFFECTS_WARBAND ))
    ComboBoxAddMenuItem( "EA_Window_CustomizePerformanceAbilityEffectsCombo", GetStringFromTable( "UserSettingsStrings",  StringTables.UserSettings.PERFORMANCE_ABILITY_EFFECTS_ALL ))

    -- Lighting
    LabelSetText( "EA_Window_CustomizePerformanceLightingLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_LIGHTING ))
    LabelSetText( "EA_Window_CustomizePerformanceEnableLightMapsLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_LIGHTMAPS ) )
    LabelSetText( "EA_Window_CustomizePerformanceEnableSpecularLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_SPECULAR ) )
    LabelSetText( "EA_Window_CustomizePerformanceEnablePostProcessLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_POST_PROCESS ) )
    
    if(Settings.HardwareSupportsPostProc() ~= true) then
        WindowSetShowing("EA_Window_CustomizePerformanceEnablePostProcess", false);
    end
    
    -- Misc
    LabelSetText( "EA_Window_CustomizePerformanceMiscLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_MISC ))
    LabelSetText( "EA_Window_CustomizePerformanceShadowsLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_SHADOWS )..L":")
    ComboBoxAddMenuItem( "EA_Window_CustomizePerformanceShadowsCombo", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.LABEL_PERFORMANCE_HIGH ))
    ComboBoxAddMenuItem( "EA_Window_CustomizePerformanceShadowsCombo", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.LABEL_PERFORMANCE_MEDIUM ))
    ComboBoxAddMenuItem( "EA_Window_CustomizePerformanceShadowsCombo", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_NONE ))
    LabelSetText( "EA_Window_CustomizePerformanceAnimationLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_ANIMATION )..L":")
    ComboBoxAddMenuItem( "EA_Window_CustomizePerformanceAnimationCombo", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.LABEL_PERFORMANCE_HIGH ))
    ComboBoxAddMenuItem( "EA_Window_CustomizePerformanceAnimationCombo", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.LABEL_PERFORMANCE_MEDIUM ))
    ComboBoxAddMenuItem( "EA_Window_CustomizePerformanceAnimationCombo", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.LABEL_PERFORMANCE_LOW ))
    
    -- GPU
    LabelSetText( "EA_Window_CustomizePerformanceGPULabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_GPU ) )
    LabelSetText( "EA_Window_CustomizePerformanceTextureMemorySliderGroupLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_TMC ) )
    LabelSetText( "EA_Window_CustomizePerformanceTextureMemorySliderGroupLeftLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_DEFAULT ) )
    LabelSetText( "EA_Window_CustomizePerformanceTextureMemorySliderGroupRightLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_LARGEST ) )
    
    -- Ok and Cancel
    ButtonSetText( "EA_Window_CustomizePerformanceOkayButton", GetString( StringTables.Default.LABEL_OKAY ) )
    ButtonSetText( "EA_Window_CustomizePerformanceCancelButton", GetString( StringTables.Default.LABEL_CANCEL ) )
    
end

function EA_Window_CustomizePerformance.StoreSettingsLocally()

    -- copy System data table to local table   
    for k1,v1 in pairs(SystemData.Settings.Performance) do
        if( type (v1) ~= "table" ) 
        then 
            continue 
        end
        
        LocalSettings[k1] = {}

        for k2,v2 in pairs(SystemData.Settings.Performance[k1]) do
            LocalSettings[k1][k2] = v2
        end
    end
    
    -- copy SystemData variable to member variable
    EA_Window_CustomizePerformance.textureCacheSliderEnabled = SystemData.Settings.Performance.canAdjustTextureMemory
    EA_Window_CustomizePerformance.EnableTextureMemorySliderGroup(EA_Window_CustomizePerformance.textureCacheSliderEnabled)
end

function EA_Window_CustomizePerformance.UpdateSettings()
    
    local i = EA_Window_CustomizePerformance.CurrCustom
    -- The names of these variables must exactly match the names defined in UserPrefs.cpp
    ButtonSetPressedFlag( "EA_Window_CustomizePerformanceCustom"..i.."Button", true )
    SliderBarSetCurrentPosition("EA_Window_CustomizePerformanceDrawDistanceSlider", LocalSettings["custom"..i].drawDistance )
    ButtonSetPressedFlag( "EA_Window_CustomizePerformanceEnableGrassButton", LocalSettings["custom"..i].grass )
    ButtonSetPressedFlag( "EA_Window_CustomizePerformanceEnableWaterReflectionButton", LocalSettings["custom"..i].waterRef )
    ButtonSetPressedFlag( "EA_Window_CustomizePerformanceEnableWaterWakeButton", LocalSettings["custom"..i].waterWakes)    
    ComboBoxSetSelectedMenuItem( "EA_Window_CustomizePerformanceEffectsQualityCombo", LocalSettings["custom"..i].effects )    
    ComboBoxSetSelectedMenuItem( "EA_Window_CustomizePerformanceAbilityEffectsCombo", LocalSettings["custom"..i].abilityEffects )    
    ComboBoxSetSelectedMenuItem( "EA_Window_CustomizePerformanceShadowsCombo", LocalSettings["custom"..i].shadows )    
    ComboBoxSetSelectedMenuItem( "EA_Window_CustomizePerformanceAnimationCombo", LocalSettings["custom"..i].animation )    
    ButtonSetPressedFlag( "EA_Window_CustomizePerformanceEnableSpecularButton", LocalSettings["custom"..i].specular )
    ButtonSetPressedFlag( "EA_Window_CustomizePerformanceEnableLightMapsButton", LocalSettings["custom"..i].lightmaps )
    ButtonSetPressedFlag( "EA_Window_CustomizePerformanceEnablePostProcessButton", LocalSettings["custom"..i].postProcess )
    
    if (EA_Window_CustomizePerformance.textureCacheSliderEnabled)
    then 
        SliderBarSetCurrentPosition("EA_Window_CustomizePerformanceTextureMemorySliderGroupSlider", LocalSettings["custom"..i].texture_Cache )
    end
end

function EA_Window_CustomizePerformance.OnOkayButton()

    EA_Window_CustomizePerformance.SaveCurrCustomSettings()

    -- copy the local settings table back to the system data table
    for k1,v1 in pairs(LocalSettings) do
        for k2,v2 in pairs(LocalSettings[k1]) do
            SystemData.Settings.Performance[k1][k2] = v2
        end
    end
    
    SettingsWindowTabVideo.SetCustomPerformance(EA_Window_CustomizePerformance.CurrCustom)
    -- Close the window     
    WindowSetShowing( "EA_Window_CustomizePerformance", false )
end

function EA_Window_CustomizePerformance.OnCancelButton()    
    -- Close the window     
    WindowSetShowing( "EA_Window_CustomizePerformance", false )
end

function EA_Window_CustomizePerformance.OnVeryHiqhQuality()
    SliderBarSetCurrentPosition("EA_Window_CustomizePerformanceDrawDistanceSlider", 1.0 )
    ButtonSetPressedFlag( "EA_Window_CustomizePerformanceEnableGrassButton", true )
    ButtonSetPressedFlag( "EA_Window_CustomizePerformanceEnableWaterReflectionButton", true )
    ButtonSetPressedFlag( "EA_Window_CustomizePerformanceEnableWaterWakeButton", true )    
    ComboBoxSetSelectedMenuItem( "EA_Window_CustomizePerformanceEffectsQualityCombo", 1 )    
    ComboBoxSetSelectedMenuItem( "EA_Window_CustomizePerformanceAbilityEffectsCombo", 5 )    
    ComboBoxSetSelectedMenuItem( "EA_Window_CustomizePerformanceShadowsCombo", 1 )    
    ComboBoxSetSelectedMenuItem( "EA_Window_CustomizePerformanceAnimationCombo", 1 )    
    ButtonSetPressedFlag( "EA_Window_CustomizePerformanceEnableSpecularButton", true )
    ButtonSetPressedFlag( "EA_Window_CustomizePerformanceEnableLightMapsButton", true )
    ButtonSetPressedFlag( "EA_Window_CustomizePerformanceEnablePostProcessButton", true )
    if (EA_Window_CustomizePerformance.textureCacheSliderEnabled)
    then 
        SliderBarSetCurrentPosition("EA_Window_CustomizePerformanceTextureMemorySliderGroupSlider", 0.0 )
    end
end

function EA_Window_CustomizePerformance.OnHiqhQuality()
    SliderBarSetCurrentPosition("EA_Window_CustomizePerformanceDrawDistanceSlider", 1.0 )
    ButtonSetPressedFlag( "EA_Window_CustomizePerformanceEnableGrassButton", true )
    ButtonSetPressedFlag( "EA_Window_CustomizePerformanceEnableWaterReflectionButton", true )
    ButtonSetPressedFlag( "EA_Window_CustomizePerformanceEnableWaterWakeButton", true )    
    ComboBoxSetSelectedMenuItem( "EA_Window_CustomizePerformanceEffectsQualityCombo", 1 )    
    ComboBoxSetSelectedMenuItem( "EA_Window_CustomizePerformanceAbilityEffectsCombo", 5 )    
    ComboBoxSetSelectedMenuItem( "EA_Window_CustomizePerformanceShadowsCombo", 1 )    
    ComboBoxSetSelectedMenuItem( "EA_Window_CustomizePerformanceAnimationCombo", 1 )    
    ButtonSetPressedFlag( "EA_Window_CustomizePerformanceEnableSpecularButton", true )
    ButtonSetPressedFlag( "EA_Window_CustomizePerformanceEnableLightMapsButton", true )
    ButtonSetPressedFlag( "EA_Window_CustomizePerformanceEnablePostProcessButton", false )
    if (EA_Window_CustomizePerformance.textureCacheSliderEnabled)
    then 
        SliderBarSetCurrentPosition("EA_Window_CustomizePerformanceTextureMemorySliderGroupSlider", 0.0 )
    end
end

function EA_Window_CustomizePerformance.OnBalanced()
    SliderBarSetCurrentPosition("EA_Window_CustomizePerformanceDrawDistanceSlider", 0.5 )
    ButtonSetPressedFlag( "EA_Window_CustomizePerformanceEnableGrassButton", true )
    ButtonSetPressedFlag( "EA_Window_CustomizePerformanceEnableWaterReflectionButton", true )
    ButtonSetPressedFlag( "EA_Window_CustomizePerformanceEnableWaterWakeButton", true )    
    ComboBoxSetSelectedMenuItem( "EA_Window_CustomizePerformanceEffectsQualityCombo", 2 )    
    ComboBoxSetSelectedMenuItem( "EA_Window_CustomizePerformanceAbilityEffectsCombo", 5 )    
    ComboBoxSetSelectedMenuItem( "EA_Window_CustomizePerformanceShadowsCombo", 2 )    
    ComboBoxSetSelectedMenuItem( "EA_Window_CustomizePerformanceAnimationCombo", 2 )    
    ButtonSetPressedFlag( "EA_Window_CustomizePerformanceEnableSpecularButton", true )
    ButtonSetPressedFlag( "EA_Window_CustomizePerformanceEnableLightMapsButton", true ) 
    ButtonSetPressedFlag( "EA_Window_CustomizePerformanceEnablePostProcessButton", false )    
    if (EA_Window_CustomizePerformance.textureCacheSliderEnabled)
    then 
        SliderBarSetCurrentPosition("EA_Window_CustomizePerformanceTextureMemorySliderGroupSlider", 0.0 )
    end
end

function EA_Window_CustomizePerformance.OnFastest()
    SliderBarSetCurrentPosition("EA_Window_CustomizePerformanceDrawDistanceSlider", 0.0 )
    ButtonSetPressedFlag( "EA_Window_CustomizePerformanceEnableGrassButton", false )
    ButtonSetPressedFlag( "EA_Window_CustomizePerformanceEnableWaterReflectionButton", false )
    ButtonSetPressedFlag( "EA_Window_CustomizePerformanceEnableWaterWakeButton", false )    
    ComboBoxSetSelectedMenuItem( "EA_Window_CustomizePerformanceEffectsQualityCombo", 3 )    
    ComboBoxSetSelectedMenuItem( "EA_Window_CustomizePerformanceAbilityEffectsCombo", 2 )    
    ComboBoxSetSelectedMenuItem( "EA_Window_CustomizePerformanceShadowsCombo", 3 )    
    ComboBoxSetSelectedMenuItem( "EA_Window_CustomizePerformanceAnimationCombo", 3 )
    ButtonSetPressedFlag( "EA_Window_CustomizePerformanceEnableSpecularButton", false )
    ButtonSetPressedFlag( "EA_Window_CustomizePerformanceEnableLightMapsButton", false )
    ButtonSetPressedFlag( "EA_Window_CustomizePerformanceEnablePostProcessButton", false )   
    if (EA_Window_CustomizePerformance.textureCacheSliderEnabled)
    then 
        SliderBarSetCurrentPosition("EA_Window_CustomizePerformanceTextureMemorySliderGroupSlider", 0.0 )
    end
end

function EA_Window_CustomizePerformance.OnCustomSelect1()
    if ( EA_Window_CustomizePerformance.CurrCustom ~= 1)
    then
        ButtonSetPressedFlag( "EA_Window_CustomizePerformanceCustom2Button", false )
        EA_Window_CustomizePerformance.OnCustomSelChanged(1)
    end
end

function EA_Window_CustomizePerformance.OnCustomSelect2()
    if ( EA_Window_CustomizePerformance.CurrCustom ~= 2)
    then
        ButtonSetPressedFlag( "EA_Window_CustomizePerformanceCustom1Button", false )
        EA_Window_CustomizePerformance.OnCustomSelChanged(2)
    end
end

function EA_Window_CustomizePerformance.OnCustomSelChanged(newCustom)
    -- save the current custom before we switch to another
    EA_Window_CustomizePerformance.SaveCurrCustomSettings()
    -- update curr custom
    EA_Window_CustomizePerformance.CurrCustom = newCustom 
    -- change all the settings to the new current custom
    EA_Window_CustomizePerformance.UpdateSettings()
end

function EA_Window_CustomizePerformance.SaveCurrCustomSettings()

    local i = EA_Window_CustomizePerformance.CurrCustom
    -- The names of these variables must exactly match the names defined in UserPrefs.cpp
    LocalSettings["custom"..i].drawDistance = SliderBarGetCurrentPosition("EA_Window_CustomizePerformanceDrawDistanceSlider")
    LocalSettings["custom"..i].grass = ButtonGetPressedFlag( "EA_Window_CustomizePerformanceEnableGrassButton" )
    LocalSettings["custom"..i].waterRef = ButtonGetPressedFlag( "EA_Window_CustomizePerformanceEnableWaterReflectionButton" )
    LocalSettings["custom"..i].waterWakes = ButtonGetPressedFlag( "EA_Window_CustomizePerformanceEnableWaterWakeButton" )    
    LocalSettings["custom"..i].effects = ComboBoxGetSelectedMenuItem( "EA_Window_CustomizePerformanceEffectsQualityCombo" )    
    LocalSettings["custom"..i].abilityEffects = ComboBoxGetSelectedMenuItem( "EA_Window_CustomizePerformanceAbilityEffectsCombo" )   
    LocalSettings["custom"..i].shadows = ComboBoxGetSelectedMenuItem( "EA_Window_CustomizePerformanceShadowsCombo")
    LocalSettings["custom"..i].animation = ComboBoxGetSelectedMenuItem( "EA_Window_CustomizePerformanceAnimationCombo" )    
    LocalSettings["custom"..i].specular = ButtonGetPressedFlag( "EA_Window_CustomizePerformanceEnableSpecularButton")
    LocalSettings["custom"..i].lightmaps = ButtonGetPressedFlag( "EA_Window_CustomizePerformanceEnableLightMapsButton")
    LocalSettings["custom"..i].postProcess = ButtonGetPressedFlag( "EA_Window_CustomizePerformanceEnablePostProcessButton")
    LocalSettings["custom"..i].texture_Cache = SliderBarGetCurrentPosition("EA_Window_CustomizePerformanceTextureMemorySliderGroupSlider")
end

function EA_Window_CustomizePerformance.ClearCustomSelectRadio()
    for i = 1,NUM_CUSTOMS do
        ButtonSetPressedFlag( "EA_Window_CustomizePerformanceCustom"..i.."Button", false )
    end
end

function EA_Window_CustomizePerformance.EnableTextureMemorySliderGroup( enable )
    
    local sliderGroupName = "EA_Window_CustomizePerformanceTextureMemorySliderGroup"

    local function SetSliderGroupColor(greyScaleColor)
        WindowSetTintColor(sliderGroupName.."Slider", greyScaleColor, greyScaleColor, greyScaleColor )
        LabelSetTextColor(sliderGroupName.."Label", greyScaleColor, greyScaleColor, greyScaleColor )
        LabelSetTextColor(sliderGroupName.."LeftLabel", greyScaleColor, greyScaleColor, greyScaleColor )
        LabelSetTextColor(sliderGroupName.."RightLabel", greyScaleColor, greyScaleColor, greyScaleColor )  
    end
   
    if (enable == true)
    then
        SetSliderGroupColor(255)
    else
        SetSliderGroupColor(128)
    end    
        
    SliderBarSetDisabledFlag(sliderGroupName.."Slider", not enable)
end

function EA_Window_CustomizePerformance.OnMouseOverTextureMemorySlider()

    local tipText
    
    if (EA_Window_CustomizePerformance.textureCacheSliderEnabled)
    then
        tipText = GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_TMC_WARNING )
    else
        tipText = GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_TMC_NO_ADJUST )
    end  
    
    if (tipText)
    then
        Tooltips.CreateTextOnlyTooltip( SystemData.MouseOverWindow.name, tipText )
        Tooltips.AnchorTooltip (nil)
    end 
end

function EA_Window_CustomizePerformance.OnMouseOverLightingCheckBox()

    local tipText = GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_LIGHTING_CHANGE )
    
    if (tipText)
    then
        Tooltips.CreateTextOnlyTooltip( SystemData.MouseOverWindow.name, tipText )
        Tooltips.AnchorTooltip (nil)
    end 
end

function EA_Window_CustomizePerformance.OnMouseOverVeryHighQuality()
    local tipText = GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_VERY_HIGH_QUALITY_TOOLTIP )
    
    if (tipText)
    then
        Tooltips.CreateTextOnlyTooltip( SystemData.MouseOverWindow.name, tipText )
        Tooltips.AnchorTooltip (nil)
    end 
end
