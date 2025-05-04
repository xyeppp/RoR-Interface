SettingsWindowTabChat = {}

SettingsWindowTabChat.contentsName = "SWTabChatContentsScrollChild"

SettingsWindowTabChat.ChatFadeTime = {}
SettingsWindowTabChat.ChatFadeTime[1] = 1
SettingsWindowTabChat.ChatFadeTime[2] = 2
SettingsWindowTabChat.ChatFadeTime[3] = 3
SettingsWindowTabChat.ChatFadeTime[4] = 4
SettingsWindowTabChat.ChatFadeTime[5] = 5
SettingsWindowTabChat.NUM_FADE_TIMES = 5

SettingsWindowTabChat.ChatScrollLimit = nil

function SettingsWindowTabChat.Initialize()
    -- Chat
               
    -- May need to pull the Chat settings down from C
    -- If the settings window was initialize before the Chat window.
    if( SystemData.Settings.Chat == nil ) then
        Settings.LoadChatSettings()
    end
    
    LabelSetText( SettingsWindowTabChat.contentsName.."SettingsChatTitle", GetString( StringTables.Default.LABEL_CHAT ) )
    LabelSetText( SettingsWindowTabChat.contentsName.."SettingsChatFadeTextLabel", GetString( StringTables.Default.LABEL_FADE_TEXT ) )
    ButtonSetCheckButtonFlag( SettingsWindowTabChat.contentsName.."SettingsChatFadeTextButton", true )
    WindowSetId( SettingsWindowTabChat.contentsName.."SettingsChatFadeText", StringTables.UserSettings.TOOLTIP_FADE_TEXT)
    
    LabelSetText( SettingsWindowTabChat.contentsName.."SettingsChatProfanityFilterLabel",  GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.CHAT_PROFANITY_FILTER ) )
    ButtonSetCheckButtonFlag( SettingsWindowTabChat.contentsName.."SettingsChatProfanityFilterButton", true )
    WindowSetId( SettingsWindowTabChat.contentsName.."SettingsChatProfanityFilter", StringTables.UserSettings.TOOLTIP_CHAT_PROFANITY_FILTER)

    LabelSetText( SettingsWindowTabChat.contentsName.."SettingsChatVisTimeLabel", GetString( StringTables.Default.LABEL_VISIBLE_TIME ) )
    WindowSetId( SettingsWindowTabChat.contentsName.."SettingsChatVisTimeLabel", StringTables.UserSettings.TOOLTIP_VISIBLE_TIME)
    for time = 1, SettingsWindowTabChat.NUM_FADE_TIMES do
        ComboBoxAddMenuItem( SettingsWindowTabChat.contentsName.."SettingsChatVisTimeCombo", GetStringFormat( StringTables.Default.LABEL_X_MIN, {SettingsWindowTabChat.ChatFadeTime[time]} ) )
    end
    WindowSetId( SettingsWindowTabChat.contentsName.."SettingsChatVisTimeCombo", StringTables.UserSettings.TOOLTIP_VISIBLE_TIME )

    LabelSetText( SettingsWindowTabChat.contentsName.."SettingsChatLimitLabel", GetString( StringTables.Default.LABEL_SCROLLBACK_LIMIT ) )
    WindowSetId( SettingsWindowTabChat.contentsName.."SettingsChatLimitLabel", StringTables.UserSettings.TOOLTIP_SCROLLBACK_LIMIT )
    LabelSetText( SettingsWindowTabChat.contentsName.."SettingsChatLimitLowLabel",      towstring( WindowGetId(SettingsWindowTabChat.contentsName.."SettingsChatLimitLow") ) )
    LabelSetText( SettingsWindowTabChat.contentsName.."SettingsChatLimitMediumLabel",   towstring( WindowGetId(SettingsWindowTabChat.contentsName.."SettingsChatLimitMedium") ) )
    LabelSetText( SettingsWindowTabChat.contentsName.."SettingsChatLimitHighLabel",     towstring( WindowGetId(SettingsWindowTabChat.contentsName.."SettingsChatLimitHigh") ) )
    LabelSetText( SettingsWindowTabChat.contentsName.."SettingsChatLimitVeryHighLabel",  towstring( WindowGetId(SettingsWindowTabChat.contentsName.."SettingsChatLimitVeryHigh") ) )
    ButtonSetCheckButtonFlag( SettingsWindowTabChat.contentsName.."SettingsChatLimitLowButton",      true )
    ButtonSetCheckButtonFlag( SettingsWindowTabChat.contentsName.."SettingsChatLimitMediumButton",   true )
    ButtonSetCheckButtonFlag( SettingsWindowTabChat.contentsName.."SettingsChatLimitHighButton",     true )
    ButtonSetCheckButtonFlag( SettingsWindowTabChat.contentsName.."SettingsChatLimitVeryHighButton",  true )
    SettingsWindowTabChat.ChatScrollLimit = SystemData.Settings.Chat.scrollLimit
    
    -- Chat Bubbles 
    LabelSetText(SettingsWindowTabChat.contentsName.."SettingsChatBubblesShowPlayerChatBubblesLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.SHOW_PLAYER_BUBBLES ) )
    ButtonSetCheckButtonFlag(SettingsWindowTabChat.contentsName.."SettingsChatBubblesShowPlayerChatBubblesButton", true )
    WindowSetId( SettingsWindowTabChat.contentsName.."SettingsChatBubblesShowPlayerChatBubbles", StringTables.UserSettings.TOOLTIP_SHOW_PLAYER_BUBBLES )

    LabelSetText(SettingsWindowTabChat.contentsName.."SettingsChatBubblesShowNPCChatBubblesLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.SHOW_NPC_BUBBLES ) )
    ButtonSetCheckButtonFlag(SettingsWindowTabChat.contentsName.."SettingsChatBubblesShowNPCChatBubblesButton", true )
    WindowSetId( SettingsWindowTabChat.contentsName.."SettingsChatBubblesShowNPCChatBubbles", StringTables.UserSettings.TOOLTIP_SHOW_NPC_BUBBLES )
    
    LabelSetText(SettingsWindowTabChat.contentsName.."SettingsChatBubblesShowPartyChatBubblesLabel", GetStringFromTable( "UserSettingsStrings", StringTables.UserSettings.SHOW_PARTY_BUBBLES ) )
    ButtonSetCheckButtonFlag(SettingsWindowTabChat.contentsName.."SettingsChatBubblesShowPartyChatBubblesButton", true )
    WindowSetId( SettingsWindowTabChat.contentsName.."SettingsChatBubblesShowPartyChatBubbles", StringTables.UserSettings.TOOLTIP_SHOW_PARTY_BUBBLES )
end

function SettingsWindowTabChat.UpdateSettings()
    -- Chat
    ButtonSetPressedFlag( SettingsWindowTabChat.contentsName.."SettingsChatFadeTextButton", SystemData.Settings.Chat.fadeText )   
    ButtonSetPressedFlag( SettingsWindowTabChat.contentsName.."SettingsChatProfanityFilterButton", SystemData.Settings.Chat.profanityFilter )   

    local foundTime = false
    for time = 1, SettingsWindowTabChat.NUM_FADE_TIMES do      
        if( SystemData.Settings.Chat.visibleTime == SettingsWindowTabChat.ChatFadeTime[time] * 60 ) then
            foundTime = true
            ComboBoxSetSelectedMenuItem( SettingsWindowTabChat.contentsName.."SettingsChatVisTimeCombo", time )
            break
        end  
    end
    
    if( not foundTime ) then
        SystemData.Settings.Chat.visibleTime = SettingsWindowTabChat.ChatFadeTime[1] * 60
        ComboBoxSetSelectedMenuItem( SettingsWindowTabChat.contentsName.."SettingsChatVisTimeCombo", 1 )
    end
    
    SettingsWindowTabChat.ChatScrollLimit = SystemData.Settings.Chat.scrollLimit
    SettingsWindowTabChat.UpdateScrollLimitButtons()
    
    -- Chat Bubbles
    ButtonSetPressedFlag(SettingsWindowTabChat.contentsName.."SettingsChatBubblesShowPlayerChatBubblesButton", SystemData.Settings.GamePlay.showPlayerChatBubbles )
    ButtonSetPressedFlag(SettingsWindowTabChat.contentsName.."SettingsChatBubblesShowNPCChatBubblesButton", SystemData.Settings.GamePlay.showNPCChatBubbles )
    ButtonSetPressedFlag(SettingsWindowTabChat.contentsName.."SettingsChatBubblesShowPartyChatBubblesButton", SystemData.Settings.GamePlay.showPartyChatBubbles )
end

function SettingsWindowTabChat.ApplyCurrent()
    -- Chat
    SystemData.Settings.Chat.fadeText = ButtonGetPressedFlag( SettingsWindowTabChat.contentsName.."SettingsChatFadeTextButton")
    SystemData.Settings.Chat.profanityFilter = ButtonGetPressedFlag( SettingsWindowTabChat.contentsName.."SettingsChatProfanityFilterButton")
    
    local timeVal = ComboBoxGetSelectedMenuItem( SettingsWindowTabChat.contentsName.."SettingsChatVisTimeCombo" ) 
    SystemData.Settings.Chat.visibleTime = SettingsWindowTabChat.ChatFadeTime[timeVal] * 60       

    SystemData.Settings.Chat.scrollLimit = SettingsWindowTabChat.ChatScrollLimit
    
    -- Chat Bubbles
    SystemData.Settings.GamePlay.showPlayerChatBubbles          = ButtonGetPressedFlag(SettingsWindowTabChat.contentsName.."SettingsChatBubblesShowPlayerChatBubblesButton" )
    SystemData.Settings.GamePlay.showNPCChatBubbles             = ButtonGetPressedFlag(SettingsWindowTabChat.contentsName.."SettingsChatBubblesShowNPCChatBubblesButton" )
    SystemData.Settings.GamePlay.showPartyChatBubbles           = ButtonGetPressedFlag(SettingsWindowTabChat.contentsName.."SettingsChatBubblesShowPartyChatBubblesButton" )
end

function SettingsWindowTabChat.OnScrollLimitSelect()
    -- DEBUG(L"SettingsWindowTabChat.OnScrollLimitSelect() from "..StringToWString(SystemData.ActiveWindow.name))
    SettingsWindowTabChat.ChatScrollLimit = WindowGetId(SystemData.ActiveWindow.name)
    SettingsWindowTabChat.UpdateScrollLimitButtons()
end

function SettingsWindowTabChat.UpdateScrollLimitButtons()

    local function CheckAndSetButton( ButtonName )
        -- DEBUG(L" "..SettingsWindowTabChat.ChatScrollLimit..L" == "..WindowGetId( ButtonName ) )
        if ( SettingsWindowTabChat.ChatScrollLimit == WindowGetId( ButtonName ) )
        then
            ButtonSetPressedFlag( ButtonName.."Button", true )
        else
            ButtonSetPressedFlag( ButtonName.."Button", false )
        end
    end
    
    CheckAndSetButton( SettingsWindowTabChat.contentsName.."SettingsChatLimitLow"     )
    CheckAndSetButton( SettingsWindowTabChat.contentsName.."SettingsChatLimitMedium"  )
    CheckAndSetButton( SettingsWindowTabChat.contentsName.."SettingsChatLimitHigh"    )
    CheckAndSetButton( SettingsWindowTabChat.contentsName.."SettingsChatLimitVeryHigh" )
    
end

function SettingsWindowTabChat.OnMouseOverScrollLimit()
    local windowName	= SystemData.ActiveWindow.name
    
    SettingsWindowTabbed.CreateAutoTooltip(StringTables.UserSettings.TOOLTIP_SCROLLBACK_LIMIT, windowName)
end
