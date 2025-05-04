SettingsWindowTabTargetting = {}

local fontOptions = {
    { fontNameSuffix = "_old", stringTableId = StringTables.Default.LABEL_NAMES_SETTING_FONT_STYLIZED },
    { fontNameSuffix = "",    stringTableId = StringTables.Default.LABEL_NAMES_SETTING_FONT_SIMPLE }
}

SettingsWindowTabTargetting.contentsName = "SWTabTargettingContentsScrollChild"

function SettingsWindowTabTargetting.Initialize()
    -- Health Bars
    LabelSetText( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsTitle", GetString( StringTables.Default.LABEL_SETTINGS_HEALTHBARS ) )
    
    LabelSetText( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsYourHealthbar", GetString( StringTables.Default.LABEL_HEALTHBARS_SETTING_YOURS ) )
    WindowSetId( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsYourHealthbar", StringTables.UserSettings.TOOLTIP_HEALTHBARS_SETTING_YOURS )
    ComboBoxAddMenuItem( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsYourHealthbarCombo", GetString( StringTables.Default.LABEL_HEALTHBARS_SETTING_OFF  ))
    ComboBoxAddMenuItem( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsYourHealthbarCombo", GetString( StringTables.Default.LABEL_HEALTHBARS_SETTING_HURT ))
    ComboBoxAddMenuItem( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsYourHealthbarCombo", GetString( StringTables.Default.LABEL_HEALTHBARS_SETTING_ON   ))
    WindowSetId( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsYourHealthbarCombo", StringTables.UserSettings.TOOLTIP_HEALTHBARS_SETTING_YOURS )

    LabelSetText( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsGroupHealthbar", GetString( StringTables.Default.LABEL_HEALTHBARS_SETTING_GROUP ) )
    WindowSetId( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsGroupHealthbar", StringTables.UserSettings.TOOLTIP_HEALTHBARS_SETTING_GROUP )
    ComboBoxAddMenuItem( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsGroupHealthbarCombo", GetString( StringTables.Default.LABEL_HEALTHBARS_SETTING_OFF  ))
    ComboBoxAddMenuItem( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsGroupHealthbarCombo", GetString( StringTables.Default.LABEL_HEALTHBARS_SETTING_HURT ))
    ComboBoxAddMenuItem( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsGroupHealthbarCombo", GetString( StringTables.Default.LABEL_HEALTHBARS_SETTING_ON   ))
    WindowSetId( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsGroupHealthbarCombo", StringTables.UserSettings.TOOLTIP_HEALTHBARS_SETTING_GROUP )
    
    LabelSetText( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsFriendlyPlayerHealthbar", GetString( StringTables.Default.LABEL_HEALTHBARS_SETTING_FRIENDLY_PLAYER ) )
    WindowSetId( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsFriendlyPlayerHealthbar", StringTables.UserSettings.TOOLTIP_HEALTHBARS_SETTING_FRIENDLY_PLAYER )
    ComboBoxAddMenuItem( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsFriendlyPlayerHealthbarCombo", GetString( StringTables.Default.LABEL_HEALTHBARS_SETTING_OFF  ))
    ComboBoxAddMenuItem( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsFriendlyPlayerHealthbarCombo", GetString( StringTables.Default.LABEL_HEALTHBARS_SETTING_HURT ))
    ComboBoxAddMenuItem( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsFriendlyPlayerHealthbarCombo", GetString( StringTables.Default.LABEL_HEALTHBARS_SETTING_ON   ))
    WindowSetId( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsFriendlyPlayerHealthbarCombo", StringTables.UserSettings.TOOLTIP_HEALTHBARS_SETTING_FRIENDLY_PLAYER )

    LabelSetText( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsEnemyPlayerHealthbar", GetString( StringTables.Default.LABEL_HEALTHBARS_SETTING_ENEMY_PLAYER ) )
    WindowSetId( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsEnemyPlayerHealthbar", StringTables.UserSettings.TOOLTIP_HEALTHBARS_SETTING_ENEMY_PLAYER )
    ComboBoxAddMenuItem( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsEnemyPlayerHealthbarCombo", GetString( StringTables.Default.LABEL_HEALTHBARS_SETTING_OFF  ))
    ComboBoxAddMenuItem( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsEnemyPlayerHealthbarCombo", GetString( StringTables.Default.LABEL_HEALTHBARS_SETTING_HURT ))
    ComboBoxAddMenuItem( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsEnemyPlayerHealthbarCombo", GetString( StringTables.Default.LABEL_HEALTHBARS_SETTING_ON   ))
    WindowSetId( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsEnemyPlayerHealthbarCombo", StringTables.UserSettings.TOOLTIP_HEALTHBARS_SETTING_ENEMY_PLAYER )

    LabelSetText( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsMonsterHealthbar", GetString( StringTables.Default.LABEL_HEALTHBARS_SETTING_MONSTER ) )
    WindowSetId( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsMonsterHealthbar", StringTables.UserSettings.TOOLTIP_HEALTHBARS_SETTING_MONSTER )
    ComboBoxAddMenuItem( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsMonsterHealthbarCombo", GetString( StringTables.Default.LABEL_HEALTHBARS_SETTING_OFF  ))
    ComboBoxAddMenuItem( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsMonsterHealthbarCombo", GetString( StringTables.Default.LABEL_HEALTHBARS_SETTING_HURT ))
    ComboBoxAddMenuItem( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsMonsterHealthbarCombo", GetString( StringTables.Default.LABEL_HEALTHBARS_SETTING_ON   ))
    WindowSetId( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsMonsterHealthbarCombo", StringTables.UserSettings.TOOLTIP_HEALTHBARS_SETTING_MONSTER )

    LabelSetText( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsTargetHealthbar", GetString( StringTables.Default.LABEL_HEALTHBARS_SETTING_TARGET ) )
    WindowSetId( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsTargetHealthbar", StringTables.UserSettings.TOOLTIP_HEALTHBARS_SETTING_TARGET )
    ComboBoxAddMenuItem( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsTargetHealthbarCombo", GetString( StringTables.Default.LABEL_HEALTHBARS_SETTING_OFF  ))
    ComboBoxAddMenuItem( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsTargetHealthbarCombo", GetString( StringTables.Default.LABEL_HEALTHBARS_SETTING_HURT ))
    ComboBoxAddMenuItem( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsTargetHealthbarCombo", GetString( StringTables.Default.LABEL_HEALTHBARS_SETTING_ON   ))
    WindowSetId( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsTargetHealthbarCombo", StringTables.UserSettings.TOOLTIP_HEALTHBARS_SETTING_TARGET )
    
    -- Names
    LabelSetText( SettingsWindowTabTargetting.contentsName.."SettingsNamesTitle", GetString( StringTables.Default.LABEL_NAMES ) )
    WindowSetId( SettingsWindowTabTargetting.contentsName.."SettingsNames", StringTables.UserSettings.TOOLTIP_NAMES )
    LabelSetText( SettingsWindowTabTargetting.contentsName.."SettingsNamesFont", GetString( StringTables.Default.LABEL_NAMES_SETTING_FONT ) )
    for _, fontOption in ipairs( fontOptions )
    do
        ComboBoxAddMenuItem( SettingsWindowTabTargetting.contentsName.."SettingsNamesFontCombo", GetString( fontOption.stringTableId ) )
    end
    LabelSetText( SettingsWindowTabTargetting.contentsName.."SettingsNamesFriendlyPlayerNameLabel",   GetString( StringTables.Default.LABEL_NAMES_SETTING_FRIENDLY_PLAYER_NAME ) )
    LabelSetText( SettingsWindowTabTargetting.contentsName.."SettingsNamesEnemyPlayerNameLabel",      GetString( StringTables.Default.LABEL_NAMES_SETTING_ENEMY_PLAYER_NAME ) )
    LabelSetText( SettingsWindowTabTargetting.contentsName.."SettingsNamesFriendlyNPCNameLabel",      GetString( StringTables.Default.LABEL_NAMES_SETTING_FRIENDLY_NPC_NAME ) )
    LabelSetText( SettingsWindowTabTargetting.contentsName.."SettingsNamesEnemyNPCNameLabel",         GetString( StringTables.Default.LABEL_NAMES_SETTING_ENEMY_NPC_NAME ) )
    LabelSetText( SettingsWindowTabTargetting.contentsName.."SettingsNamesYourNameLabel",             GetString( StringTables.Default.LABEL_NAMES_SETTING_YOUR_NAME ) )
    LabelSetText( SettingsWindowTabTargetting.contentsName.."SettingsNamesYourPetNameLabel",          GetString( StringTables.Default.LABEL_NAMES_SETTING_PET_NAME ) )
    LabelSetText( SettingsWindowTabTargetting.contentsName.."SettingsNamesTargetNameLabel",           GetString( StringTables.Default.LABEL_NAMES_SETTING_TARGET_NAME ) )
    ButtonSetCheckButtonFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesFriendlyPlayerNameButton",  true )
    ButtonSetCheckButtonFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesEnemyPlayerNameButton",     true )
    ButtonSetCheckButtonFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesFriendlyNPCNameButton",     true )
    ButtonSetCheckButtonFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesEnemyNPCNameButton",        true )
    ButtonSetCheckButtonFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesYourNameButton",            true )
    ButtonSetCheckButtonFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesYourPetNameButton",         true )
    ButtonSetCheckButtonFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesTargetNameButton",          true )
    WindowSetId( SettingsWindowTabTargetting.contentsName.."SettingsNamesFont", StringTables.UserSettings.TOOLTIP_NAMES_FONT )
    WindowSetId( SettingsWindowTabTargetting.contentsName.."SettingsNamesFriendlyPlayerName", StringTables.UserSettings.TOOLTIP_NAMES )
    WindowSetId( SettingsWindowTabTargetting.contentsName.."SettingsNamesEnemyPlayerName", StringTables.UserSettings.TOOLTIP_NAMES )
    WindowSetId( SettingsWindowTabTargetting.contentsName.."SettingsNamesFriendlyNPCName", StringTables.UserSettings.TOOLTIP_NAMES )
    WindowSetId( SettingsWindowTabTargetting.contentsName.."SettingsNamesEnemyNPCName", StringTables.UserSettings.TOOLTIP_NAMES )
    WindowSetId( SettingsWindowTabTargetting.contentsName.."SettingsNamesYourName", StringTables.UserSettings.TOOLTIP_NAMES )
    WindowSetId( SettingsWindowTabTargetting.contentsName.."SettingsNamesYourPetName", StringTables.UserSettings.TOOLTIP_NAMES )
    WindowSetId( SettingsWindowTabTargetting.contentsName.."SettingsNamesTargetName", StringTables.UserSettings.TOOLTIP_NAMES )

    LabelSetText( SettingsWindowTabTargetting.contentsName.."SettingsNamesYourTitleLabel",            GetString( StringTables.Default.LABEL_NAMES_SETTING_YOUR_TITLE ) )
    LabelSetText( SettingsWindowTabTargetting.contentsName.."SettingsNamesFriendlyPlayerTitleLabel",  GetString( StringTables.Default.LABEL_NAMES_SETTING_FRIENDLY_PLAYER_TITLE ) )
    LabelSetText( SettingsWindowTabTargetting.contentsName.."SettingsNamesEnemyPlayerTitleLabel",     GetString( StringTables.Default.LABEL_NAMES_SETTING_ENEMY_PLAYER_TITLE ) )
    LabelSetText( SettingsWindowTabTargetting.contentsName.."SettingsNamesNPCTitleLabel",             GetString( StringTables.Default.LABEL_NAMES_SETTING_NPC_TITLE ) )
    LabelSetText( SettingsWindowTabTargetting.contentsName.."SettingsNamesTargetTitleLabel",          GetString( StringTables.Default.LABEL_NAMES_SETTING_TARGET_TITLE ) )
    ButtonSetCheckButtonFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesYourTitleButton",           true )
    ButtonSetCheckButtonFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesFriendlyPlayerTitleButton", true )
    ButtonSetCheckButtonFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesEnemyPlayerTitleButton",    true )
    ButtonSetCheckButtonFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesNPCTitleButton",            true )
    ButtonSetCheckButtonFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesTargetTitleButton",         true )
    WindowSetId( SettingsWindowTabTargetting.contentsName.."SettingsNamesYourTitle", StringTables.UserSettings.TOOLTIP_NAMES )
    WindowSetId( SettingsWindowTabTargetting.contentsName.."SettingsNamesFriendlyPlayerTitle", StringTables.UserSettings.TOOLTIP_NAMES )
    WindowSetId( SettingsWindowTabTargetting.contentsName.."SettingsNamesEnemyPlayerTitle", StringTables.UserSettings.TOOLTIP_NAMES )
    WindowSetId( SettingsWindowTabTargetting.contentsName.."SettingsNamesNPCTitle", StringTables.UserSettings.TOOLTIP_NAMES )
    WindowSetId( SettingsWindowTabTargetting.contentsName.."SettingsNamesTargetTitle", StringTables.UserSettings.TOOLTIP_NAMES )

    LabelSetText( SettingsWindowTabTargetting.contentsName.."SettingsNamesYourGuildLabel",            GetString( StringTables.Default.LABEL_NAMES_SETTING_YOUR_GUILD ) )
    LabelSetText( SettingsWindowTabTargetting.contentsName.."SettingsNamesFriendlyPlayerGuildLabel",  GetString( StringTables.Default.LABEL_NAMES_SETTING_FRIENDLY_PLAYER_GUILD ) )
    LabelSetText( SettingsWindowTabTargetting.contentsName.."SettingsNamesEnemyPlayerGuildLabel",     GetString( StringTables.Default.LABEL_NAMES_SETTING_ENEMY_PLAYER_GUILD ) )
    LabelSetText( SettingsWindowTabTargetting.contentsName.."SettingsNamesTargetGuildLabel",          GetString( StringTables.Default.LABEL_NAMES_SETTING_TARGET_GUILD ) )
    ButtonSetCheckButtonFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesYourGuildButton",           true )
    ButtonSetCheckButtonFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesFriendlyPlayerGuildButton", true )
    ButtonSetCheckButtonFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesEnemyPlayerGuildButton",    true )
    ButtonSetCheckButtonFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesTargetGuildButton",         true )
    WindowSetId( SettingsWindowTabTargetting.contentsName.."SettingsNamesYourGuild", StringTables.UserSettings.TOOLTIP_NAMES )
    WindowSetId( SettingsWindowTabTargetting.contentsName.."SettingsNamesFriendlyPlayerGuild", StringTables.UserSettings.TOOLTIP_NAMES )
    WindowSetId( SettingsWindowTabTargetting.contentsName.."SettingsNamesEnemyPlayerGuild", StringTables.UserSettings.TOOLTIP_NAMES )
    WindowSetId( SettingsWindowTabTargetting.contentsName.."SettingsNamesTargetGuild", StringTables.UserSettings.TOOLTIP_NAMES )
    
    -- Reticles
    LabelSetText( SettingsWindowTabTargetting.contentsName.."SettingsReticlesTitle", GetString( StringTables.Default.LABEL_RETICLES ) )
    
    LabelSetText( SettingsWindowTabTargetting.contentsName.."SettingsReticlesTargetLabel", GetString( StringTables.Default.LABEL_TARGET ) )
    ButtonSetCheckButtonFlag( SettingsWindowTabTargetting.contentsName.."SettingsReticlesTargetButton", true )
    WindowSetId( SettingsWindowTabTargetting.contentsName.."SettingsReticlesTarget", StringTables.UserSettings.TOOLTIP_TARGET )
    
    LabelSetText( SettingsWindowTabTargetting.contentsName.."SettingsReticlesMouseOverLabel", GetString( StringTables.Default.LABEL_MOUSEOVER ) )
    ButtonSetCheckButtonFlag( SettingsWindowTabTargetting.contentsName.."SettingsReticlesMouseOverButton", true )
    WindowSetId( SettingsWindowTabTargetting.contentsName.."SettingsReticlesMouseOver", StringTables.UserSettings.TOOLTIP_MOUSEOVER )
    
    LabelSetText( SettingsWindowTabTargetting.contentsName.."SettingsReticlesOverheadArrowLabel", GetString( StringTables.Default.LABEL_TARGET_HIGHLIGHTING ) )
    ButtonSetCheckButtonFlag( SettingsWindowTabTargetting.contentsName.."SettingsReticlesOverheadArrowButton", true )
    WindowSetId( SettingsWindowTabTargetting.contentsName.."SettingsReticlesOverheadArrow", StringTables.UserSettings.TOOLTIP_TARGET_HIGHLIGHTING )
    
    LabelSetText( SettingsWindowTabTargetting.contentsName.."SettingsReticlesTargetPointerLabel", GetString( StringTables.Default.LABEL_TARGET_POINTER ) )
    ButtonSetCheckButtonFlag( SettingsWindowTabTargetting.contentsName.."SettingsReticlesTargetPointerButton", true )
    WindowSetId( SettingsWindowTabTargetting.contentsName.."SettingsReticlesTargetPointer", StringTables.UserSettings.TOOLTIP_TARGET_POINTER )
    
    LabelSetText( SettingsWindowTabTargetting.contentsName.."SettingsReticlesGroupPointerLabel", GetString( StringTables.Default.LABEL_TARGET_PARTY_POINTER ) )
    ButtonSetCheckButtonFlag( SettingsWindowTabTargetting.contentsName.."SettingsReticlesGroupPointerButton", true )
    WindowSetId( SettingsWindowTabTargetting.contentsName.."SettingsReticlesGroupPointer", StringTables.UserSettings.TOOLTIP_TARGET_PARTY_POINTER )
    
    LabelSetText( SettingsWindowTabTargetting.contentsName.."SettingsReticlesDamagePointerLabel", GetString( StringTables.Default.LABEL_TARGET_DAMAGE_POINTER ) )
    ButtonSetCheckButtonFlag( SettingsWindowTabTargetting.contentsName.."SettingsReticlesDamagePointerButton", true )
    WindowSetId( SettingsWindowTabTargetting.contentsName.."SettingsReticlesDamagePointer", StringTables.UserSettings.TOOLTIP_TARGET_DAMAGE_POINTER )
end

function SettingsWindowTabTargetting.UpdateSettings()
    -- Health Bars
    ComboBoxSetSelectedMenuItem( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsYourHealthbarCombo",            SystemData.Settings.Names.yourhealth )
    ComboBoxSetSelectedMenuItem( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsGroupHealthbarCombo",           SystemData.Settings.Names.grouphealth )
    ComboBoxSetSelectedMenuItem( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsFriendlyPlayerHealthbarCombo",  SystemData.Settings.Names.friendlyhealth )
    ComboBoxSetSelectedMenuItem( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsEnemyPlayerHealthbarCombo",     SystemData.Settings.Names.enemyhealth )
    ComboBoxSetSelectedMenuItem( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsMonsterHealthbarCombo",         SystemData.Settings.Names.npchealth )
    ComboBoxSetSelectedMenuItem( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsTargetHealthbarCombo",          SystemData.Settings.Names.targethealth )

    -- Names
    if not fontOptions[ SystemData.Settings.Names.font ]
    then
        SystemData.Settings.Names.font = 1
    end
    ComboBoxSetSelectedMenuItem( SettingsWindowTabTargetting.contentsName.."SettingsNamesFontCombo", SystemData.Settings.Names.font )
    
    ButtonSetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesFriendlyPlayerNameButton",  SystemData.Settings.Names.friendlyplayers )
    ButtonSetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesEnemyPlayerNameButton",     SystemData.Settings.Names.enemyplayers )
    ButtonSetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesFriendlyNPCNameButton",     SystemData.Settings.Names.friendlynpcs )
    ButtonSetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesEnemyNPCNameButton",        SystemData.Settings.Names.enemynpcs )
    ButtonSetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesYourNameButton",            SystemData.Settings.Names.your )
    ButtonSetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesTargetNameButton",          SystemData.Settings.Names.target )
    ButtonSetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesYourPetNameButton",         SystemData.Settings.Names.yourpet )
    ButtonSetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesYourTitleButton",           SystemData.Settings.Names.yourtitle )
    ButtonSetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesFriendlyPlayerTitleButton", SystemData.Settings.Names.friendlytitles )
    ButtonSetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesEnemyPlayerTitleButton",    SystemData.Settings.Names.enemytitles )
    ButtonSetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesNPCTitleButton",            SystemData.Settings.Names.npctitles )
    ButtonSetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesTargetTitleButton",         SystemData.Settings.Names.targettitle )
    ButtonSetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesYourGuildButton",           SystemData.Settings.Names.yourguild )
    ButtonSetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesFriendlyPlayerGuildButton", SystemData.Settings.Names.friendlyguilds )
    ButtonSetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesEnemyPlayerGuildButton",    SystemData.Settings.Names.enemyguilds )
    ButtonSetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesTargetGuildButton",         SystemData.Settings.Names.targetguild )

    -- Reticles
    ButtonSetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsReticlesTargetButton", SystemData.Settings.Reticles.target )
    ButtonSetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsReticlesMouseOverButton", SystemData.Settings.Reticles.mouseover )
    ButtonSetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsReticlesOverheadArrowButton", SystemData.Settings.Reticles.arrowOverTarget )
    ButtonSetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsReticlesTargetPointerButton", SystemData.Settings.Reticles.targetPointer )
    ButtonSetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsReticlesGroupPointerButton", SystemData.Settings.Reticles.friend )
    ButtonSetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsReticlesDamagePointerButton", SystemData.Settings.Reticles.enemy )
end

function SettingsWindowTabTargetting.ApplyCurrent()
    -- Health Bars
    SystemData.Settings.Names.yourhealth        = ComboBoxGetSelectedMenuItem( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsYourHealthbarCombo"            )
    SystemData.Settings.Names.grouphealth       = ComboBoxGetSelectedMenuItem( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsGroupHealthbarCombo"           )
    SystemData.Settings.Names.friendlyhealth    = ComboBoxGetSelectedMenuItem( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsFriendlyPlayerHealthbarCombo"  )
    SystemData.Settings.Names.enemyhealth       = ComboBoxGetSelectedMenuItem( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsEnemyPlayerHealthbarCombo"     )
    SystemData.Settings.Names.npchealth         = ComboBoxGetSelectedMenuItem( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsMonsterHealthbarCombo"         )
    SystemData.Settings.Names.targethealth      = ComboBoxGetSelectedMenuItem( SettingsWindowTabTargetting.contentsName.."SettingsHealthbarsTargetHealthbarCombo"          )
    
    -- Names
    local newFontChoice = ComboBoxGetSelectedMenuItem( SettingsWindowTabTargetting.contentsName.."SettingsNamesFontCombo" )
    if not fontOptions[ newFontChoice ]
    then
        newFontChoice = 1
        ComboBoxSetSelectedMenuItem( SettingsWindowTabTargetting.contentsName.."SettingsNamesFontCombo", newFontChoice )
    end
    if newFontChoice ~= SystemData.Settings.Names.font
    then
        SystemData.Settings.Names.font = newFontChoice
        SettingsWindowTabTargetting.SetNameplateFont()
    end
    
    SystemData.Settings.Names.friendlyplayers   = ButtonGetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesFriendlyPlayerNameButton" )
    SystemData.Settings.Names.enemyplayers      = ButtonGetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesEnemyPlayerNameButton"    )
    SystemData.Settings.Names.friendlynpcs      = ButtonGetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesFriendlyNPCNameButton"    )
    SystemData.Settings.Names.enemynpcs         = ButtonGetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesEnemyNPCNameButton"       )
    SystemData.Settings.Names.your              = ButtonGetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesYourNameButton"           ) 
    SystemData.Settings.Names.target            = ButtonGetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesTargetNameButton"         )
    SystemData.Settings.Names.yourpet           = ButtonGetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesYourPetNameButton"        )
    SystemData.Settings.Names.yourtitle         = ButtonGetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesYourTitleButton"          )
    SystemData.Settings.Names.friendlytitles    = ButtonGetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesFriendlyPlayerTitleButton")
    SystemData.Settings.Names.enemytitles       = ButtonGetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesEnemyPlayerTitleButton"   )
    SystemData.Settings.Names.npctitles         = ButtonGetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesNPCTitleButton"           ) 
    SystemData.Settings.Names.targettitle       = ButtonGetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesTargetTitleButton"        ) 
    SystemData.Settings.Names.yourguild         = ButtonGetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesYourGuildButton"          )
    SystemData.Settings.Names.friendlyguilds    = ButtonGetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesFriendlyPlayerGuildButton")
    SystemData.Settings.Names.enemyguilds       = ButtonGetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesEnemyPlayerGuildButton"   )
    SystemData.Settings.Names.targetguild       = ButtonGetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsNamesTargetGuildButton"        )

    -- Reticles
    SystemData.Settings.Reticles.target             = ButtonGetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsReticlesTargetButton")
    SystemData.Settings.Reticles.mouseover          = ButtonGetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsReticlesMouseOverButton")
    SystemData.Settings.Reticles.arrowOverTarget    = ButtonGetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsReticlesOverheadArrowButton")
    SystemData.Settings.Reticles.targetPointer      = ButtonGetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsReticlesTargetPointerButton")
    SystemData.Settings.Reticles.friend             = ButtonGetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsReticlesGroupPointerButton")
    SystemData.Settings.Reticles.enemy              = ButtonGetPressedFlag( SettingsWindowTabTargetting.contentsName.."SettingsReticlesDamagePointerButton")
end

function SettingsWindowTabTargetting.SetNameplateFont()
    if not InterfaceCore.inGame or not fontOptions[ SystemData.Settings.Names.font ]
    then
        return
    end
    local suffix = fontOptions[ SystemData.Settings.Names.font ].fontNameSuffix
    SetNamesAndTitlesFont( "font_name_plate_names"..suffix, "font_name_plate_titles"..suffix )
end

