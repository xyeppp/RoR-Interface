SettingsWindowTabSound = {}

SettingsWindowTabSound.contentsName = "SWTabSoundContentsScrollChild"

function SettingsWindowTabSound.Initialize()
    -- Sound    
    LabelSetText( SettingsWindowTabSound.contentsName.."SettingsSoundTitle", GetString( StringTables.Default.LABEL_SOUND ) )
    LabelSetText( SettingsWindowTabSound.contentsName.."SettingsSoundMasterSoundLabel", GetString( StringTables.Default.LABEL_MASTER_VOL ) )
    LabelSetText( SettingsWindowTabSound.contentsName.."SettingsSoundEnableMasterSoundLabel", GetString( StringTables.Default.LABEL_ENABLED ) )
    ButtonSetCheckButtonFlag( SettingsWindowTabSound.contentsName.."SettingsSoundEnableMasterSoundButton", true )
    LabelSetText( SettingsWindowTabSound.contentsName.."SettingsSoundEffectsSoundLabel", GetString( StringTables.Default.LABEL_EFFECTS_VOL ) )
    LabelSetText( SettingsWindowTabSound.contentsName.."SettingsSoundEnableEffectsSoundLabel", GetString( StringTables.Default.LABEL_ENABLED ) )
    ButtonSetCheckButtonFlag( SettingsWindowTabSound.contentsName.."SettingsSoundEnableEffectsSoundButton", true )
    LabelSetText( SettingsWindowTabSound.contentsName.."SettingsSoundMusicSoundLabel", GetString( StringTables.Default.LABEL_MUSIC_VOL ) )
    LabelSetText( SettingsWindowTabSound.contentsName.."SettingsSoundEnableMusicSoundLabel", GetString( StringTables.Default.LABEL_ENABLED ) )
    ButtonSetCheckButtonFlag( SettingsWindowTabSound.contentsName.."SettingsSoundEnableMusicSoundButton", true )
    LabelSetText( SettingsWindowTabSound.contentsName.."SettingsSoundEAXLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.SOUND_EAX ) )
    LabelSetText( SettingsWindowTabSound.contentsName.."SettingsSoundEnableEAXLabel", GetString( StringTables.Default.LABEL_ENABLED ) )
    
    LabelSetText( SettingsWindowTabSound.contentsName.."SettingsSoundNotificationLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.SOUND_SOUND_NOTIFICATIONS ) )
    LabelSetText( SettingsWindowTabSound.contentsName.."SettingsSoundDisableCommunicationSoundsLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.SOUND_DISABLE_COMMUNICATION_SOUNDS ) )
    
    WindowSetId( SettingsWindowTabSound.contentsName.."SettingsSoundDisableCommunicationSounds", StringTables.UserSettings.TOOLTIP_SOUND_DISABLE_COMMUNICATION_SOUNDS )
end

function SettingsWindowTabSound.UpdateSettings()

    -- Sound    
    ButtonSetPressedFlag( SettingsWindowTabSound.contentsName.."SettingsSoundEnableMasterSoundButton", SystemData.Settings.Sound.master.enabled )
    SliderBarSetCurrentPosition( SettingsWindowTabSound.contentsName.."SettingsSoundMasterVolSilder", SystemData.Settings.Sound.master.volume )
    
    ButtonSetPressedFlag( SettingsWindowTabSound.contentsName.."SettingsSoundEnableEffectsSoundButton", SystemData.Settings.Sound.effects.enabled )
    SliderBarSetCurrentPosition( SettingsWindowTabSound.contentsName.."SettingsSoundEffectsVolSilder", SystemData.Settings.Sound.effects.volume )
    
    ButtonSetPressedFlag( SettingsWindowTabSound.contentsName.."SettingsSoundEnableMusicSoundButton", SystemData.Settings.Sound.music.enabled )
    SliderBarSetCurrentPosition( SettingsWindowTabSound.contentsName.."SettingsSoundMusicVolSilder", SystemData.Settings.Sound.music.volume )
    
    if( SystemData.Settings.Sound.EAXCapable )
    then
        ButtonSetPressedFlag( SettingsWindowTabSound.contentsName.."SettingsSoundEnableEAXButton", SystemData.Settings.Sound.EAXEnabled )
    else
        ButtonSetDisabledFlag( SettingsWindowTabSound.contentsName.."SettingsSoundEnableEAXButton", true )        
    end
    
    ButtonSetPressedFlag( SettingsWindowTabSound.contentsName.."SettingsSoundDisableCommunicationSoundsButton", SystemData.Settings.Sound.disableCommunicationSounds )
end

function SettingsWindowTabSound.ApplyCurrent()
    -- Sound    
    SystemData.Settings.Sound.master.enabled = ButtonGetPressedFlag( SettingsWindowTabSound.contentsName.."SettingsSoundEnableMasterSoundButton")
    SystemData.Settings.Sound.master.volume = SliderBarGetCurrentPosition( SettingsWindowTabSound.contentsName.."SettingsSoundMasterVolSilder" )
    
    SystemData.Settings.Sound.effects.enabled = ButtonGetPressedFlag( SettingsWindowTabSound.contentsName.."SettingsSoundEnableEffectsSoundButton" )
    SystemData.Settings.Sound.effects.volume = SliderBarGetCurrentPosition( SettingsWindowTabSound.contentsName.."SettingsSoundEffectsVolSilder" )
    
    SystemData.Settings.Sound.music.enabled = ButtonGetPressedFlag( SettingsWindowTabSound.contentsName.."SettingsSoundEnableMusicSoundButton" )
    SystemData.Settings.Sound.music.volume = SliderBarGetCurrentPosition( SettingsWindowTabSound.contentsName.."SettingsSoundMusicVolSilder" )
    
    if( SystemData.Settings.Sound.EAXCapable )
    then
        SystemData.Settings.Sound.EAXEnabled = ButtonGetPressedFlag( SettingsWindowTabSound.contentsName.."SettingsSoundEnableEAXButton" )
    end
    
    SystemData.Settings.Sound.disableCommunicationSounds = ButtonGetPressedFlag( SettingsWindowTabSound.contentsName.."SettingsSoundDisableCommunicationSoundsButton" )
end

