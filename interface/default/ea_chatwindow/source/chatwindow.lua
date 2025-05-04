----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_ChatWindow = {}

----------------------------------------------------------------
-- Saved Variables
----------------------------------------------------------------
EA_ChatWindow.BaseVersion = 2.5
EA_ChatWindow.CurrentVersion = 2.5

----------------------------------------------------------------
-- Saved Settings Tables
----------------------------------------------------------------
EA_ChatWindow.Settings = {}
EA_ChatWindow.Settings.WindowGroups = {}

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------
local FADE_TIME = 0.6
local FADE_OUT_DELAY = 2.0
local WINDOW_MIN_WIDTH = 300
local WINDOW_MIN_HEIGHT = 200
local c_TELL_TARGET_COMMAND = GetChatString (StringTables.Chat.CHAT_CHANNEL_CMD_TELL_TARGET)
local c_REPLY_COMMAND       = GetChatString (StringTables.Chat.CHAT_CHANNEL_SWITCH_REPLY)
local MAX_TABS = 20
local MAX_WINDOW_GROUPS = 10

local TAB_FLASH_MAX_ALPHA = 0.8
local TAB_FLASH_MIN_ALPHA = 0.3
local TAB_FLASH_TIME = 0.5

-- game rating window
local CHAT_WINDOW_GAME_RATING_TEXT_INTERVAL_IN_SECONDS = 3600     -- game rating text will be shown every 1 hour(3600 seconds)
local CHAT_WINDOW_GAME_RATING_TEXT_SHOWTIME_IN_SECONDS = 6        -- game rating text will be shown for 6 seconds
local CHAT_WINDOW_GAME_RATING_TEXT_FADETIME_IN_SECONDS = 1        -- game rating text will be fade in/out in 1 seconds
local NAME_CHAT_WINDOW_GAME_RATING_WINDOW              = "ChatWindowGameRatingWindow"

local chatText = L""
local chatChannel = L""

local initialCreateChatWindowGroups = false

----------------------------------------------------------------
-- Local functions
----------------------------------------------------------------
local function IsSlashCommandInChannel( slashCommand, channel )
    return ( slashCommand ~= nil and
             channel ~= nil and
             channel.slashCmds ~= nil and
             channel.slashCmds[slashCommand] == 1 )
end

local function GetChatChannelFromText( text )
    
    --d(L"GetChatChannelFromText() text="..text )
        
    -- If the this text does not begin with a slash, 
    -- then it is not a slash command
    if( wstring.find(text, L"/", 1) ~= 1 )
    then
        return nil
    end
        

    for ixChannel, curChannel in pairs(ChatSettings.Channels) 
    do 
        if( IsSlashCommandInChannel(text, curChannel) ) 
        then
            return ixChannel
        end
    end
    
    return nil        
end

----------------------------------------------------------------
-- Tab Manager
----------------------------------------------------------------
EA_ChatTabManager = {}
EA_ChatTabManager.Tabs = {}
EA_ChatTabManager.activeTabId = 0
EA_ChatTabManager.dockingStarted        = false 
EA_ChatTabManager.isDocking             = false 
EA_ChatTabManager.dockingTabId          = 0 
EA_ChatTabManager.dockingStart          = false 

----------------------------------------------------------------
-- Chat Window Groups
-- A window group is a chat window that may have multiple tabs
-- Every time a chat tab is undocked, a new window group is created
-- unless it is being docked to another window group.  Likewise,
-- when all the tabs from a window group are removed or docked to
-- other window groups, a window group is destroyed.
----------------------------------------------------------------
EA_ChatWindowGroups = {}

----------------------------------------------------------------
-- Chat Window Variables
----------------------------------------------------------------
EA_ChatWindow.curChannel        = nil   -- The current channel you are typing to, nil when the input box isn't open

EA_ChatWindow.prevChannel       = nil   -- The last channel you were chatting in... (how we know which channel to switch to by default for new chats)
                                        -- the value of prevChannel is what's used when you just hit enter without typing a slash command
                                        
EA_ChatWindow.savedChannel      = nil   -- The last channel you were chatting in that is allowed to be remembered...
                                        -- savedChannel is set in the same way as prevChannel, just excluding channels that are
                                        -- marked for exclusion. when the input box is closed, prevChannel is replaced with this value

EA_ChatWindow.whisperTarget     = nil   -- The target of your tell
EA_ChatWindow.isContextMenuShowing  = false -- Used to prevent autohiding while the context menu is showing
EA_ChatWindow.isResizing            = false -- Used to prevent autohiding while resizing
EA_ChatWindow.settingsDirty         = false -- Used to update settings when they change
EA_ChatWindow.replyIndex            = 1     -- Initial reply-to should go to the first person who whispered you
EA_ChatWindow.resizeWndGroupId      = 0     -- Id of the window group that is being resized
EA_ChatWindow.createWndGroupId      = 0     -- Id of the window group that is being created
EA_ChatWindow.activeWndGroupId      = 0     -- Id of the window group that is active (for use during context menu operations)
EA_ChatWindow.showLanguageButton    = false -- The show state of the language button

-- game rating window
EA_ChatWindow.showGameRatingText    = false    -- whether the game rating text window is shown
EA_ChatWindow.timeGameRatingText    = 0        -- time of game rating text window is shown or hide according to showGameRatingText

----------------------------------------------------------------
-- Right-click context menu
----------------------------------------------------------------
function EA_ChatWindow.OnOpenChatMenu()
    EA_ChatWindow.OnSelectTab()
    EA_Window_ContextMenu.CreateContextMenu("", EA_Window_ContextMenu.CONTEXT_MENU_1)
    EA_Window_ContextMenu.AddMenuItem(GetChatString(StringTables.Chat.LABEL_CHAT_FILTERS), EA_ChatWindow.OnViewChatFilters, false, true, EA_Window_ContextMenu.CONTEXT_MENU_1)
    EA_Window_ContextMenu.AddMenuItem(GetChatString(StringTables.Chat.LABEL_CHAT_TAB_TEXTCOLORS), EA_ChatWindow.OnViewChatOptions, false, true, EA_Window_ContextMenu.CONTEXT_MENU_1)
    EA_Window_ContextMenu.AddCascadingMenuItem(GetChatString(StringTables.Chat.LABEL_CHAT_TAB_TABOPTIONS), EA_ChatWindow.SpawnTabOptionsMenu, false, EA_Window_ContextMenu.CONTEXT_MENU_1)
    EA_Window_ContextMenu.AddCascadingMenuItem(GetChatString(StringTables.Chat.LABEL_CHAT_TAB_COMMANDLISTS), EA_ChatWindow.SpawnCommandListsMenu, false, EA_Window_ContextMenu.CONTEXT_MENU_1)
    EA_Window_ContextMenu.Finalize(EA_Window_ContextMenu.CONTEXT_MENU_1)
    
    EA_ChatWindow.isContextMenuShowing = true
end

function EA_ChatWindow.SpawnTabOptionsMenu()
    local tabManagerId = EA_ChatTabManager.activeTabId
    local wndGroupId = EA_ChatTabManager.Tabs[tabManagerId].wndGroupId
    local wndGroupTabId = EA_ChatTabManager.GetWndGroupTabId( wndGroupId, tabManagerId )
    local showTimestamp = EA_ChatWindowGroups[wndGroupId].Tabs[wndGroupTabId].showTimestamp
    local flashOnActivity = EA_ChatWindowGroups[wndGroupId].Tabs[wndGroupTabId].flashOnActivity
    
    EA_Window_ContextMenu.Hide(EA_Window_ContextMenu.CONTEXT_MENU_3)
    EA_Window_ContextMenu.CreateContextMenu("", EA_Window_ContextMenu.CONTEXT_MENU_2)
    EA_Window_ContextMenu.AddCascadingMenuItem(GetChatString(StringTables.Chat.LABEL_CHAT_TAB_FONT), EA_ChatWindow.SpawnFontSelectionMenu, false, EA_Window_ContextMenu.CONTEXT_MENU_2)
    ButtonSetPressedFlag("ChatWindowContextShowTimestampCheckBox", showTimestamp)
    EA_Window_ContextMenu.AddUserDefinedMenuItem("ChatWindowContextShowTimestamp", EA_Window_ContextMenu.CONTEXT_MENU_2)
    ButtonSetPressedFlag("ChatWindowContextFlashOnActivityCheckBox", flashOnActivity)
    EA_Window_ContextMenu.AddUserDefinedMenuItem("ChatWindowContextFlashOnActivity", EA_Window_ContextMenu.CONTEXT_MENU_2)
    EA_Window_ContextMenu.AddMenuItem(GetChatString(StringTables.Chat.LABEL_CHAT_NEW_TAB), EA_ChatWindow.OnNewTab, not EA_ChatTabManager.HasFreeTab(), true, EA_Window_ContextMenu.CONTEXT_MENU_2)
    EA_Window_ContextMenu.AddMenuItem(GetChatString(StringTables.Chat.LABEL_CHAT_RENAME_TAB), EA_ChatWindow.OnRenameTab, false, true, EA_Window_ContextMenu.CONTEXT_MENU_2)
    EA_Window_ContextMenu.AddMenuItem(GetChatString(StringTables.Chat.LABEL_CHAT_REMOVE_TAB), EA_ChatWindow.OnRemoveTab, not EA_ChatTabManager.CanRemoveTab( tabManagerId ), true, EA_Window_ContextMenu.CONTEXT_MENU_2)
    EA_Window_ContextMenu.Finalize(EA_Window_ContextMenu.CONTEXT_MENU_2)
end

function EA_ChatWindow.SpawnCommandListsMenu()
    EA_Window_ContextMenu.Hide(EA_Window_ContextMenu.CONTEXT_MENU_3)
    EA_Window_ContextMenu.CreateContextMenu("", EA_Window_ContextMenu.CONTEXT_MENU_2)
    EA_Window_ContextMenu.AddMenuItem(GetChatString(StringTables.Chat.LABEL_CHAT_COMMAND_HELP), EA_ChatWindow.OnHelpCommands, false, true, EA_Window_ContextMenu.CONTEXT_MENU_2)
    EA_Window_ContextMenu.AddMenuItem(GetChatString(StringTables.Chat.LABEL_CHAT_COMMAND_EMOTE), EA_ChatWindow.OnHelpEmotes, false, true, EA_Window_ContextMenu.CONTEXT_MENU_2)
    EA_Window_ContextMenu.Finalize(EA_Window_ContextMenu.CONTEXT_MENU_2)
end

function EA_ChatWindow.OnHelpCommands()
    SendChatText( L"/help", L"" )
    EA_ChatWindow.HideMenu()
end

function EA_ChatWindow.OnHelpEmotes()
    SendChatText( L"/emotelist", L"" )
    EA_ChatWindow.HideMenu()
end

function EA_ChatWindow.SpawnFontSelectionMenu()
    local tabId = EA_ChatTabManager.activeTabId

    EA_Window_ContextMenu.CreateContextMenu("", EA_Window_ContextMenu.CONTEXT_MENU_3)
    local size = #ChatSettings.Fonts
    for idx=1, size
    do
       local _, y = LabelGetTextDimensions( "ChatWindowContextFontMenuItem"..idx.."Label" )
       EA_Window_ContextMenu.AddUserDefinedMenuItem("ChatWindowContextFontMenuItem"..idx, EA_Window_ContextMenu.CONTEXT_MENU_3)
       if (LogDisplayGetFont(EA_ChatTabManager.Tabs[tabId].name.."TextLog") == ChatSettings.Fonts[idx].fontName)
       then
            WindowSetShowing("ChatWindowContextFontMenuItem"..idx.."Check", true)
       else
            WindowSetShowing("ChatWindowContextFontMenuItem"..idx.."Check", false)
       end
    end
    EA_Window_ContextMenu.Finalize(EA_Window_ContextMenu.CONTEXT_MENU_3)
end

function EA_ChatWindow.OnSelectTab()
    EA_ChatWindow.HideMenu() 
    EA_ChatWindow.OnCancelRename()
    WindowSetShowing( "ChatFiltersWindow", false)
    WindowSetShowing( "ChatOptionsWindow", false)
    WindowSetShowing( "ChatWindowSetOpacityWindow", false )
end

function EA_ChatWindow.SetFontToSelection()
    local fontIndex = WindowGetId(SystemData.ActiveWindow.name)    
    local tabManagerId = EA_ChatTabManager.activeTabId
    local wndGroupId = EA_ChatTabManager.Tabs[tabManagerId].wndGroupId
    local wndGroupTabId = EA_ChatTabManager.GetWndGroupTabId( wndGroupId, tabManagerId )

    for idx=1, #ChatSettings.Fonts 
    do
        WindowSetShowing("ChatWindowContextFontMenuItem"..idx.."Check", false)
    end
    WindowSetShowing(SystemData.ActiveWindow.name.."Check", true)
    LogDisplaySetFont(EA_ChatTabManager.Tabs[tabManagerId].name.."TextLog", ChatSettings.Fonts[fontIndex].fontName)
    EA_ChatWindowGroups[wndGroupId].Tabs[wndGroupTabId].font = ChatSettings.Fonts[fontIndex].fontName
    
    EA_ChatWindow.isContextMenuShowing = true
    EA_ChatWindow.OnSettingsChanged()
end

function EA_ChatWindow.ToggleTimestamp()
    local tabManagerId = EA_ChatTabManager.activeTabId
    local wndGroupId = EA_ChatTabManager.Tabs[tabManagerId].wndGroupId
    local wndGroupTabId = EA_ChatTabManager.GetWndGroupTabId( wndGroupId, tabManagerId )

    -- Toggle the timestamp
    EA_ChatWindowGroups[wndGroupId].Tabs[wndGroupTabId].showTimestamp = not EA_ChatWindowGroups[wndGroupId].Tabs[wndGroupTabId].showTimestamp
    
    ButtonSetPressedFlag("ChatWindowContextShowTimestampCheckBox", EA_ChatWindowGroups[wndGroupId].Tabs[wndGroupTabId].showTimestamp)
    LogDisplaySetShowTimestamp( EA_ChatTabManager.Tabs[tabManagerId].name.."TextLog", EA_ChatWindowGroups[wndGroupId].Tabs[wndGroupTabId].showTimestamp)
    
    EA_Window_ContextMenu.HideAll()
    
    EA_ChatWindow.OnSettingsChanged()
end

function EA_ChatWindow.ToggleFlashOnActivity()
    local tabManagerId = EA_ChatTabManager.activeTabId
    local wndGroupId = EA_ChatTabManager.Tabs[tabManagerId].wndGroupId
    local wndGroupTabId = EA_ChatTabManager.GetWndGroupTabId( wndGroupId, tabManagerId )

    -- Toggle the flash on activity setting
    EA_ChatWindowGroups[wndGroupId].Tabs[wndGroupTabId].flashOnActivity = not EA_ChatWindowGroups[wndGroupId].Tabs[wndGroupTabId].flashOnActivity

    ButtonSetPressedFlag("ChatWindowContextFlashOnActivityCheckBox", EA_ChatWindowGroups[wndGroupId].Tabs[wndGroupTabId].flashOnActivity)

    EA_Window_ContextMenu.HideAll()

    EA_ChatWindow.OnSettingsChanged()
end

function EA_ChatWindow.CreateDefaultContextMenu( windowNameToActUpon, wndGroupId )
    if( windowNameToActUpon == nil or windowNameToActUpon == "" ) then
        return
    end
    
    EA_ChatWindow.activeWndGroupId = wndGroupId
    
    EA_Window_ContextMenu.CreateContextMenu( windowNameToActUpon ) 
    local movable = WindowGetMovable( EA_Window_ContextMenu.activeWindow )
    local canAutoHide = EA_ChatWindowGroups[wndGroupId].canAutoHide
    EA_Window_ContextMenu.AddMenuItem( GetString( StringTables.Default.LABEL_TO_LOCK ), EA_ChatWindow.OnLock, not movable, true )
    EA_Window_ContextMenu.AddMenuItem( GetString( StringTables.Default.LABEL_TO_UNLOCK ), EA_ChatWindow.OnUnlock, movable, true )   
    EA_Window_ContextMenu.AddMenuItem( GetString( StringTables.Default.LABEL_SET_OPACITY ), EA_ChatWindow.OnWindowOptionsSetAlpha, false, true )
    ButtonSetPressedFlag("ChatWindowContextAutoHideCheckBox", canAutoHide)
    EA_Window_ContextMenu.AddUserDefinedMenuItem("ChatWindowContextAutoHide")
    EA_Window_ContextMenu.Finalize()
end

function EA_ChatWindow.OnLock()
    WindowSetMovable( EA_Window_ContextMenu.activeWindow, false )
    WindowSetShowing( EA_Window_ContextMenu.activeWindow.."ResizeButton", false )
    
    EA_ChatWindow.HideMenu()

    EA_ChatWindow.OnSettingsChanged()
end

function EA_ChatWindow.OnUnlock()    
    WindowSetMovable( EA_Window_ContextMenu.activeWindow, true )
    WindowSetShowing( EA_Window_ContextMenu.activeWindow.."ResizeButton", true )

    EA_ChatWindow.HideMenu()
    
    EA_ChatWindow.OnSettingsChanged()
end

function EA_ChatWindow.ToggleAutoHide()
    local wndGroupId = EA_ChatWindow.activeWndGroupId
    
    -- Toggle the auto-hide
    EA_ChatWindowGroups[wndGroupId].canAutoHide = not EA_ChatWindowGroups[wndGroupId].canAutoHide
    
    if( EA_ChatWindowGroups[wndGroupId].canAutoHide == false and EA_ChatWindowGroups[wndGroupId].fadedIn == false)
    then
        EA_ChatWindow.StartAlphaAnimation( wndGroupId, true )
        EA_ChatWindowGroups[wndGroupId].fadedIn = true
        EA_ChatWindowGroups[wndGroupId].fadeOutStarted = false    
        EA_ChatWindowGroups[wndGroupId].fadeOutTimer = FADE_OUT_DELAY
    end
    
    ButtonSetPressedFlag("ChatWindowContextAutoHideCheckBox", EA_ChatWindowGroups[wndGroupId].canAutoHide)
    
    EA_Window_ContextMenu.HideAll()
    
    EA_ChatWindow.OnSettingsChanged()
end

function EA_ChatWindow.OnWindowOptionsSetAlpha()
    local wndGroupId = EA_ChatWindow.activeWndGroupId

    -- Open the Alpha Slider    
    local alpha = EA_ChatWindowGroups[wndGroupId].maxAlpha   
    SliderBarSetCurrentPosition("ChatWindowSetOpacityWindowSlider", alpha )    
    
    -- Anchor the OpacityWindow in the middle of the active window.
    WindowClearAnchors( "ChatWindowSetOpacityWindow" )
    WindowAddAnchor( "ChatWindowSetOpacityWindow", "center", EA_ChatWindowGroups[wndGroupId].name, "center", 0, 0 )

    WindowSetShowing( "ChatWindowSetOpacityWindow", true )
end

function EA_ChatWindow.OnSlideWindowOptionsAlpha( slidePos )
    local alpha = slidePos
    
    -- Requirements call for 10%-100% range, not 0% to 100%.
    if (alpha < 0.1) then
        alpha = 0.1
    end

    local wndGroupId = EA_ChatWindow.activeWndGroupId 
    EA_ChatWindowGroups[wndGroupId].maxAlpha = alpha
    
    local wndGroupName = EA_ChatWindowGroups[wndGroupId].name
    
    for k, tab in ipairs( EA_ChatWindowGroups[wndGroupId].Tabs )
    do
        local tabName = EA_ChatTabManager.GetTabName( tab.tabManagerId )
        if( tabName == nil )
        then 
            continue
        end

        WindowStopAlphaAnimation( tabName.."Background" )
        if (k == EA_ChatWindowGroups[wndGroupId].activeTab )
        then
            WindowSetAlpha ( tabName.."Background", alpha )
        else
            WindowSetAlpha ( tabName.."Background", alpha/2.0 )
        end
    end    
    WindowStopAlphaAnimation( wndGroupName.."Foreground" )
    WindowSetAlpha ( wndGroupName.."Foreground", alpha ) 
    
end

function EA_ChatWindow.CloseSetOpacityWindow()

    WindowSetShowing( "ChatWindowSetOpacityWindow", false )
    
    EA_ChatWindow.HideMenu()
end

----------------------------------------------------------------
-- Channel Menu and Switching Functions
----------------------------------------------------------------
function EA_ChatWindow.OnOpenChannelMenu()
    if (WindowGetShowing("ChatChannelSelectionWindow") == true)
    then
        WindowSetShowing("ChatChannelSelectionWindow", false)
        WindowAssignFocus( "ChatChannelSelectionWindow", false )
    else
        WindowClearAnchors( "ChatChannelSelectionWindow" )
        WindowAddAnchor( "ChatChannelSelectionWindow", "bottomright", "EA_TextEntryGroupChannelButton", "bottomleft", 0, 0 )    
        WindowSetShowing("ChatChannelSelectionWindow", true)
        WindowAssignFocus( "ChatChannelSelectionWindow", true )
        WindowSetShowing( "ChatChannelSelectionWindowSelection", false )
    end
end

function EA_ChatWindow.UpdateMenuSelection()
    local parentName = WindowGetParent( SystemData.ActiveWindow.name )
    WindowClearAnchors( parentName.."Selection" )
    WindowAddAnchor( parentName.."Selection", "topleft", SystemData.ActiveWindow.name, "topleft", -6, -4 )
    WindowAddAnchor( parentName.."Selection", "bottomright", SystemData.ActiveWindow.name, "bottomright", -8, 4 )
    WindowSetShowing( parentName.."Selection", true )
end

function EA_ChatWindow.HideChannelSelectionMenu()
    WindowAssignFocus( "ChatChannelSelectionWindow", false )
    WindowSetShowing("ChatChannelSelectionWindow", false)
end

function EA_ChatWindow.SwitchToSelectedChannel()
    local windowId = WindowGetId(SystemData.ActiveWindow.name)
    local chatChannelId = ChatSettings.Channels[windowId].id
    EA_ChatWindow.SwitchToChatChannel(chatChannelId, ChatSettings.Channels[chatChannelId].labelText)
    EA_ChatWindow.UpdateCurrentChannel(chatChannelId)
    -- Show the Text Input Window and Hide the menu
    WindowSetShowing("ChatChannelSelectionWindow", false)
    WindowAssignFocus( "ChatChannelSelectionWindow", false )
    WindowSetShowing( "EA_TextEntryGroupEntryBox", true )
    WindowAssignFocus( "EA_TextEntryGroupEntryBoxTextInput", true )
end

function EA_ChatWindow.InitializeChannelMenuSelectionWindow()
    CreateWindow( "ChatChannelSelectionWindow", false )
    
    -- Say channel
    local channelColor = ChatSettings.ChannelColors[ SystemData.ChatLogFilters.SAY ]
    WindowSetId( "ChatChannelSelectionWindowSayButton", SystemData.ChatLogFilters.SAY)
    ButtonSetText( "ChatChannelSelectionWindowSayButton", L"/"..GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_SAY) )
    ButtonSetTextColor("ChatChannelSelectionWindowSayButton", Button.ButtonState.NORMAL, channelColor.r, channelColor.g, channelColor.b)
    ButtonSetTextColor("ChatChannelSelectionWindowSayButton", Button.ButtonState.HIGHLIGHTED, channelColor.r, channelColor.g, channelColor.b)
    ButtonSetTextColor("ChatChannelSelectionWindowSayButton", Button.ButtonState.PRESSED, channelColor.r, channelColor.g, channelColor.b)
    ButtonSetTextColor("ChatChannelSelectionWindowSayButton", Button.ButtonState.PRESSED_HIGHLIGHTED, channelColor.r, channelColor.g, channelColor.b)
    
    -- Shout channel
    channelColor = ChatSettings.ChannelColors[ SystemData.ChatLogFilters.SHOUT ]
    WindowSetId( "ChatChannelSelectionWindowShoutButton", SystemData.ChatLogFilters.SHOUT)
    ButtonSetText("ChatChannelSelectionWindowShoutButton", L"/"..GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_SHOUT) )
    ButtonSetTextColor("ChatChannelSelectionWindowShoutButton", Button.ButtonState.NORMAL, channelColor.r, channelColor.g, channelColor.b)
    ButtonSetTextColor("ChatChannelSelectionWindowShoutButton", Button.ButtonState.HIGHLIGHTED, channelColor.r, channelColor.g, channelColor.b)
    ButtonSetTextColor("ChatChannelSelectionWindowShoutButton", Button.ButtonState.PRESSED, channelColor.r, channelColor.g, channelColor.b)
    ButtonSetTextColor("ChatChannelSelectionWindowShoutButton", Button.ButtonState.PRESSED_HIGHLIGHTED, channelColor.r, channelColor.g, channelColor.b)
    
    -- Guild channel
    channelColor = ChatSettings.ChannelColors[ SystemData.ChatLogFilters.GUILD ]
    WindowSetId( "ChatChannelSelectionWindowGuildButton", SystemData.ChatLogFilters.GUILD )
    ButtonSetText("ChatChannelSelectionWindowGuildButton", L"/"..GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_GUILD) )
    ButtonSetTextColor("ChatChannelSelectionWindowGuildButton", Button.ButtonState.NORMAL, channelColor.r, channelColor.g, channelColor.b)
    ButtonSetTextColor("ChatChannelSelectionWindowGuildButton", Button.ButtonState.HIGHLIGHTED, channelColor.r, channelColor.g, channelColor.b)
    ButtonSetTextColor("ChatChannelSelectionWindowGuildButton", Button.ButtonState.PRESSED, channelColor.r, channelColor.g, channelColor.b)
    ButtonSetTextColor("ChatChannelSelectionWindowGuildButton", Button.ButtonState.PRESSED_HIGHLIGHTED, channelColor.r, channelColor.g, channelColor.b)
    
    -- Party channel
    channelColor = ChatSettings.ChannelColors[ SystemData.ChatLogFilters.GROUP ]
    WindowSetId( "ChatChannelSelectionWindowPartyButton", ChatSettings.Channels[SystemData.ChatLogFilters.GROUP].id )
    ButtonSetText("ChatChannelSelectionWindowPartyButton", L"/"..GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_GROUP) )
    ButtonSetTextColor("ChatChannelSelectionWindowPartyButton", Button.ButtonState.NORMAL, channelColor.r, channelColor.g, channelColor.b)
    ButtonSetTextColor("ChatChannelSelectionWindowPartyButton", Button.ButtonState.HIGHLIGHTED, channelColor.r, channelColor.g, channelColor.b)
    ButtonSetTextColor("ChatChannelSelectionWindowPartyButton", Button.ButtonState.PRESSED, channelColor.r, channelColor.g, channelColor.b)
    ButtonSetTextColor("ChatChannelSelectionWindowPartyButton", Button.ButtonState.PRESSED_HIGHLIGHTED, channelColor.r, channelColor.g, channelColor.b)
    
    -- Warband channel
    channelColor = ChatSettings.ChannelColors[ SystemData.ChatLogFilters.BATTLEGROUP ]
    WindowSetId( "ChatChannelSelectionWindowWarbandButton", ChatSettings.Channels[SystemData.ChatLogFilters.BATTLEGROUP].id )
    ButtonSetText("ChatChannelSelectionWindowWarbandButton", L"/"..GetChatString(StringTables.Chat.CHAT_CHANNEL_NAME_BATTLEGROUP) )
    ButtonSetTextColor("ChatChannelSelectionWindowWarbandButton", Button.ButtonState.NORMAL, channelColor.r, channelColor.g, channelColor.b)
    ButtonSetTextColor("ChatChannelSelectionWindowWarbandButton", Button.ButtonState.HIGHLIGHTED, channelColor.r, channelColor.g, channelColor.b)
    ButtonSetTextColor("ChatChannelSelectionWindowWarbandButton", Button.ButtonState.PRESSED, channelColor.r, channelColor.g, channelColor.b)
    ButtonSetTextColor("ChatChannelSelectionWindowWarbandButton", Button.ButtonState.PRESSED_HIGHLIGHTED, channelColor.r, channelColor.g, channelColor.b)
        
    WindowSetAlpha( "ChatChannelSelectionWindowSelection", 0.25 )
    
end

function EA_ChatWindow.UpdateAllChannelColors()
    -- Say Channel
    local channelColor = ChatSettings.ChannelColors[ SystemData.ChatLogFilters.SAY ]
    ButtonSetTextColor("ChatChannelSelectionWindowSayButton", Button.ButtonState.NORMAL, channelColor.r, channelColor.g, channelColor.b)
    ButtonSetTextColor("ChatChannelSelectionWindowSayButton", Button.ButtonState.HIGHLIGHTED, channelColor.r, channelColor.g, channelColor.b)
    ButtonSetTextColor("ChatChannelSelectionWindowSayButton", Button.ButtonState.PRESSED, channelColor.r, channelColor.g, channelColor.b)
    ButtonSetTextColor("ChatChannelSelectionWindowSayButton", Button.ButtonState.PRESSED_HIGHLIGHTED, channelColor.r, channelColor.g, channelColor.b)
    
    -- Shout Channel
    channelColor = ChatSettings.ChannelColors[ SystemData.ChatLogFilters.SHOUT ]
    ButtonSetTextColor("ChatChannelSelectionWindowShoutButton", Button.ButtonState.NORMAL, channelColor.r, channelColor.g, channelColor.b)
    ButtonSetTextColor("ChatChannelSelectionWindowShoutButton", Button.ButtonState.HIGHLIGHTED, channelColor.r, channelColor.g, channelColor.b)
    ButtonSetTextColor("ChatChannelSelectionWindowShoutButton", Button.ButtonState.PRESSED, channelColor.r, channelColor.g, channelColor.b)
    ButtonSetTextColor("ChatChannelSelectionWindowShoutButton", Button.ButtonState.PRESSED_HIGHLIGHTED, channelColor.r, channelColor.g, channelColor.b)
    
    -- Guild Channel
    channelColor = ChatSettings.ChannelColors[ SystemData.ChatLogFilters.GUILD ]
    ButtonSetTextColor("ChatChannelSelectionWindowGuildButton", Button.ButtonState.NORMAL, channelColor.r, channelColor.g, channelColor.b)
    ButtonSetTextColor("ChatChannelSelectionWindowGuildButton", Button.ButtonState.HIGHLIGHTED, channelColor.r, channelColor.g, channelColor.b)
    ButtonSetTextColor("ChatChannelSelectionWindowGuildButton", Button.ButtonState.PRESSED, channelColor.r, channelColor.g, channelColor.b)
    ButtonSetTextColor("ChatChannelSelectionWindowGuildButton", Button.ButtonState.PRESSED_HIGHLIGHTED, channelColor.r, channelColor.g, channelColor.b)
    
    -- Party Channel
    channelColor = ChatSettings.ChannelColors[ SystemData.ChatLogFilters.GROUP ]
    ButtonSetTextColor("ChatChannelSelectionWindowPartyButton", Button.ButtonState.NORMAL, channelColor.r, channelColor.g, channelColor.b)
    ButtonSetTextColor("ChatChannelSelectionWindowPartyButton", Button.ButtonState.HIGHLIGHTED, channelColor.r, channelColor.g, channelColor.b)
    ButtonSetTextColor("ChatChannelSelectionWindowPartyButton", Button.ButtonState.PRESSED, channelColor.r, channelColor.g, channelColor.b)
    ButtonSetTextColor("ChatChannelSelectionWindowPartyButton", Button.ButtonState.PRESSED_HIGHLIGHTED, channelColor.r, channelColor.g, channelColor.b)
    
    -- Warband Channel
    channelColor = ChatSettings.ChannelColors[ SystemData.ChatLogFilters.BATTLEGROUP ]
    ButtonSetTextColor("ChatChannelSelectionWindowWarbandButton", Button.ButtonState.NORMAL, channelColor.r, channelColor.g, channelColor.b)
    ButtonSetTextColor("ChatChannelSelectionWindowWarbandButton", Button.ButtonState.HIGHLIGHTED, channelColor.r, channelColor.g, channelColor.b)
    ButtonSetTextColor("ChatChannelSelectionWindowWarbandButton", Button.ButtonState.PRESSED, channelColor.r, channelColor.g, channelColor.b)
    ButtonSetTextColor("ChatChannelSelectionWindowWarbandButton", Button.ButtonState.PRESSED_HIGHLIGHTED, channelColor.r, channelColor.g, channelColor.b)
    
end

function EA_ChatWindow.InsertText( text )

    -- Insert the text at the current cursor location
    TextEditBoxInsertText( "EA_TextEntryGroupEntryBoxTextInput", text )
    
    
    -- If the Chat Box Input Box is not currently Open, Open to the last channel used.
    if( WindowGetShowing( "EA_TextEntryGroupEntryBox" ) == false )
    then
        EA_ChatWindow.SwitchChannelWithExistingText( EA_TextEntryGroupEntryBoxTextInput.Text )
    else
    
        -- Otherwise, just assign focus to the chat box.
        WindowAssignFocus( "EA_TextEntryGroupEntryBoxTextInput", true )
    end   
    
end

-- Convenience function for switching chat channels from both the event handler
-- and arbitrary windows that need to pass existing text to a new channel.
function EA_ChatWindow.SwitchChannelWithExistingText(existingText)
    
    -- Set the Focus to the text input
    WindowSetShowing( "EA_TextEntryGroupEntryBox", true )
    WindowSetShowing( "EA_TextEntryGroupEntryBoxTextInput", true )
    WindowAssignFocus( "EA_TextEntryGroupEntryBoxTextInput", true )
    
    if (existingText == nil) 
    then
        existingText = L"";
    end
    
    -- Set the default channel to Say or the previous channel
    if (EA_ChatWindow.curChannel == nil and EA_ChatWindow.prevChannel == nil) 
    then
        EA_ChatWindow.SwitchToChatChannel(SystemData.ChatLogFilters.SAY, ChatSettings.Channels[SystemData.ChatLogFilters.SAY].labelText, existingText)
    elseif (EA_ChatWindow.prevChannel ~= nil) 
    then
        if (EA_ChatWindow.prevChannel == SystemData.ChatLogFilters.TELL_SEND and EA_ChatWindow.whisperTarget ~= nil) 
        then
            EA_ChatWindow.SwitchToChatChannel(EA_ChatWindow.prevChannel, EA_ChatWindow.FormatWhisperPrompt (EA_ChatWindow.whisperTarget), existingText)
        else
            EA_ChatWindow.SwitchToChatChannel(EA_ChatWindow.prevChannel, ChatSettings.Channels[EA_ChatWindow.prevChannel].labelText, existingText)
        end
    end
end

function EA_ChatWindow.SwitchToChatChannel (ichannelIdx, ichannelPrompt, iexistingText)

    if (ichannelIdx == SystemData.ChatLogFilters.TELL_SEND and EA_ChatWindow.whisperTarget == nil) 
    then
        return
    end
    EA_ChatWindow.UpdateCurrentChannel (ichannelIdx)
    
    local channelColor = ChatSettings.ChannelColors[ ichannelIdx ]
    
    EA_ChatWindow.UpdateTextEntryChannelColor(channelColor)

    if (iexistingText ~= nil) 
    then
        TextEditBoxSetText("EA_TextEntryGroupEntryBoxTextInput", iexistingText)
    else
        TextEditBoxSetText("EA_TextEntryGroupEntryBoxTextInput", L"")  
    end

    LabelSetText ("EA_TextEntryGroupEntryBoxChannelLabel", ichannelPrompt)
end

function EA_ChatWindow.UpdateTextEntryChannelColor(channelColor)
    TextEditBoxSetTextColor ("EA_TextEntryGroupEntryBoxTextInput", channelColor.r, channelColor.g, channelColor.b)
    WindowSetTintColor( "EA_TextEntryGroupChannelButton", channelColor.r, channelColor.g, channelColor.b)
    LabelSetTextColor ("EA_TextEntryGroupEntryBoxChannelLabel", channelColor.r, channelColor.g, channelColor.b)
end

function EA_ChatWindow.UpdateCurrentChannel (icurChannel)

    if( EA_ChatWindow.curChannel ~= nil and ChatSettings.Channels[EA_ChatWindow.curChannel].remember )
    then
        EA_ChatWindow.savedChannel = EA_ChatWindow.curChannel
    end
    EA_ChatWindow.prevChannel = EA_ChatWindow.curChannel
    EA_ChatWindow.curChannel  = icurChannel   

end

function EA_ChatWindow.GetCurrentChannel()

    if( EA_ChatWindow.curChannel ~= nil )
    then
        return EA_ChatWindow.curChannel
    else
        return EA_ChatWindow.prevChannel
    end
end

----------------------------------------------------------------
-- Text Entry Functions
----------------------------------------------------------------
function EA_ChatWindow.DoChatTextReplacement ()  

    -- If no space has been found, or the first character is a space, do not do any processing
    local spaceIdx = wstring.find (EA_TextEntryGroupEntryBoxTextInput.Text, L" ", 1)
    if (spaceIdx == nil or spaceIdx == 1) 
    then
        return
    end
                
    local firstWord  = wstring.sub (EA_TextEntryGroupEntryBoxTextInput.Text, 1, spaceIdx)        
    local restOfLine = wstring.sub (EA_TextEntryGroupEntryBoxTextInput.Text, spaceIdx + 1)

    --DEBUG (L"You typed: ["..firstWord..L"], looking in all channels for that command...");    
    local ixChannel = GetChatChannelFromText( firstWord )  
    if( ixChannel == nil )
    then
        -- Do nothing if this isn't a chat channel.
        return
    end
               

    -- This is the one special case that I can think of...it needs two params (/tell <name>)
    if (ixChannel == SystemData.ChatLogFilters.TELL_SEND) 
    then
        EA_ChatWindow.HandleTellCommand (EA_TextEntryGroupEntryBoxTextInput.Text, firstWord, spaceIdx, restOfLine)
        
    elseif( ifirstWord == c_REPLY_COMMAND..L" " and SystemData.UserInput.ReplyToPlayerName[EA_ChatWindow.replyIndex] ~= L"") 
    then
        -- Don't go into reply mode if nobody msg'd you yet...
        EA_ChatWindow.HandleTellCommand (EA_TextEntryGroupEntryBoxTextInput.Text, firstWord, spaceIdx, restOfLine)
        
    else 
        -- Otherwise it's a regular channel, no crazy arguments...just do the switch
        EA_ChatWindow.SwitchToChatChannel (ixChannel, ChatSettings.Channels[ixChannel].labelText, restOfLine)
    end
       
end

function EA_ChatWindow.HandleTellCommand (itext, ifirstWord, ispaceIdx, iexistingText)

    local cursorPos     = EA_TextEntryGroupEntryBoxTextInput.CursorPos
    local textToExamine = wstring.sub (itext, 1, cursorPos)    
    
    local space2Idx     = nil 
    local whisperPrompt = nil
    local sendTell      = false
    
    if (cursorPos > ispaceIdx + 1) then
        space2Idx = wstring.find (textToExamine, L" ", ispaceIdx + 1)
    end
    
    if ((space2Idx ~= nil) and (ifirstWord ~= c_TELL_TARGET_COMMAND)) 
    then
        
        local whisperTarget   = wstring.sub (itext, ispaceIdx + 1, space2Idx - 1)
        
        -- If the 'whisperTarget' contains any meta tag data then it cannot be a valid player name.
        if( StringUtils.HasMetaTag( whisperTarget) )
        then
            return
        end
            
        whisperPrompt   = EA_ChatWindow.FormatWhisperPrompt(whisperTarget)
        iexistingText   = wstring.sub (itext, cursorPos + 1)
        sendTell        = true

    elseif (ifirstWord == c_TELL_TARGET_COMMAND..L" ") 
    then
        -- (/tt in english): Doing the same replacement as the regular tell command
        -- using the player's current target as the name
           
        whisperPrompt   = EA_ChatWindow.FormatWhisperPrompt (TargetInfo:UnitName ("selffriendlytarget"))
        sendTell        = true

    elseif (ifirstWord == c_REPLY_COMMAND..L" " and SystemData.UserInput.ReplyToPlayerName[EA_ChatWindow.replyIndex] ~= L"") 
    then
        -- (/r in english): Switches to reply mode and currently replies to just the
        -- last person who whispered you.  FIXME: Need to add tab-cycling at some point.
        
        whisperPrompt   = EA_ChatWindow.FormatWhisperPrompt (SystemData.UserInput.ReplyToPlayerName[EA_ChatWindow.replyIndex])
        sendTell        = true
    end
    
    
    if (sendTell == true) 
    then       
        EA_ChatWindow.SwitchToChatChannel (SystemData.ChatLogFilters.TELL_SEND, whisperPrompt, iexistingText)        
    end

end


function EA_ChatWindow.FormatWhisperPrompt (iwhisperTarget)

    -- Set the global whisperTarget
    EA_ChatWindow.whisperTarget = iwhisperTarget

    -- Then format the tell prompt
    local replacement = {}
    replacement[1] = iwhisperTarget
    replacement[2] = nil
                            
    return GetFormatStringFromTable ("ChatStrings", StringTables.Chat.CHAT_CHANNEL_REPLACE_TELL, replacement)

end

-- Event Handler for pressing a chat activation key (enter or slash)
function EA_ChatWindow.OnEnterChatText()  
    EA_ChatWindow.SwitchChannelWithExistingText (L"");    
end

function EA_ChatWindow.OnReply()
    if (SystemData.UserInput.ReplyToPlayerName[1] ~= L"") then
        --d(L"EA_ChatWindow.OnReply() - "..SystemData.UserInput.ReplyToPlayerName[1])
        EA_ChatWindow.prevChannel = SystemData.ChatLogFilters.TELL_SEND
        EA_ChatWindow.whisperTarget = SystemData.UserInput.ReplyToPlayerName[1]
        EA_ChatWindow.OnEnterChatText()
    end
end

-- TextEntryGroupEntryBoxTextInput OnKeyEnter Handler
function EA_ChatWindow.OnKeyEnter()

    chatChannel = L""
    chatText = EA_TextEntryGroupEntryBoxTextInput.Text
  
    if (EA_ChatWindow.curChannel ~= nil) 
    then

        -- This is the channel that the text will go to...
        chatChannel = ChatSettings.Channels[EA_ChatWindow.curChannel].serverCmd
        
        if (EA_ChatWindow.curChannel == SystemData.ChatLogFilters.TELL_SEND) 
        then
                    
            if (EA_ChatWindow.whisperTarget ~= nil) 
            then
                -- Unless there is a whisper target...in which case that needs to be appended to the channel
                chatChannel = ChatSettings.Channels[EA_ChatWindow.curChannel].serverCmd..L" "..EA_ChatWindow.whisperTarget
            else               
                -- But if there is no whisper target, and you're in the tell channel, don't send anything.
                chatText = L""
            end
            
        end        
        
    end
    
    -- If the Chat Text is a '/tell' command to an invalid whisper target, report an error message and leave
    -- the chat window window open
    local spaceIdx = wstring.find (EA_TextEntryGroupEntryBoxTextInput.Text, L" ", 1)
    if( spaceIdx ~= nil ) 
    then
          
        local firstWord  = wstring.sub (EA_TextEntryGroupEntryBoxTextInput.Text, 1, spaceIdx)       
        local ixChannel = GetChatChannelFromText( firstWord )  
    
        if( ixChannel == SystemData.ChatLogFilters.TELL_SEND )
        then
            
            local firstSpaceIdx  = wstring.find( chatText, L" ", 1)  
            if( firstSpaceIdx ~= nil )
            then      
                local secondSpaceIdx = wstring.find(chatText, L" ", firstSpaceIdx + 1)  
                if( secondSpaceIdx ~= nil )
                then
                    local whisperTarget   = wstring.sub(chatText, firstSpaceIdx + 1, secondSpaceIdx - 1)
					-- If the 'whisperTarget' contains any meta tag data then it cannot be a valid player name.
                    if( StringUtils.HasMetaTag( whisperTarget ) )
                    then
                        local errorMsg = GetStringFromTable("ChatStrings", StringTables.Chat.TEXT_CHAT_TELL_PLAYER_NAME_ERROR )
                        EA_ChatWindow.Print(errorMsg, SystemData.ChatLogFilters.USER_ERROR)                        
                        return
                    end 
                end                 
            end         
        end
    end
    
    
    if( chatText ~= L"" ) 
    then
		for w in wstring.gmatch(chatText, L"@(%a+)") do
			local Mention_name = ChatReplace(w)
			chatText = wstring.gsub (chatText, L"@"..w,Mention_name)
		end
		
        SendChatText( chatText, chatChannel )
    end 
    
    EA_ChatWindow.ResetTextBox()

    -- Hide the Text Input Window
    WindowAssignFocus( "EA_TextEntryGroupEntryBox", false )
    WindowSetShowing( "EA_TextEntryGroupEntryBox", false )

end

function ChatReplace(_name)
	local _nameFormatted = wstring.lower(towstring(_name))
	local _begin = wstring.upper(wstring.match(_nameFormatted, L"(.)"))
	local _end = wstring.match(_nameFormatted, L".(.*)")
	_nameFormatted = _begin .. _end					
	local word  = CreateHyperLink( L"PLAYERNS:"..towstring(_nameFormatted), L"@"..towstring(_nameFormatted), {236,94,96}, {} )
	return word
end


-- EA_TextEntryGroupEntryBoxTextInput OnKeyEscape Handler
function EA_ChatWindow.OnKeyEscape()

    EA_ChatWindow.ResetTextBox ()

    -- Hide the Text Input Window
    WindowSetShowing( "EA_TextEntryGroupEntryBox", false )
    WindowAssignFocus( "EA_TextEntryGroupEntryBox", false )

end

-- EA_ChatWindow OnKeyTab Handler
-- Cycles through people who just whispered you
-- IF you're in the /whisper channel
function EA_ChatWindow.OnKeyTab()

    if (EA_ChatWindow.curChannel == SystemData.ChatLogFilters.TELL_SEND) 
    then
    
        --d(L"EA_ChatWindow.OnKeyTab called and it's checking things!");
    
        EA_ChatWindow.replyIndex = EA_ChatWindow.replyIndex + 1;
        
        if (EA_ChatWindow.replyIndex > SystemData.UserInput.ReplyListSize or SystemData.UserInput.ReplyToPlayerName[EA_ChatWindow.replyIndex] == L"") 
        then
            EA_ChatWindow.replyIndex = 1;
        end
        
        local newTarget = SystemData.UserInput.ReplyToPlayerName[EA_ChatWindow.replyIndex];
        
        if (newTarget ~= L"") 
        then
            EA_ChatWindow.prevChannel     = SystemData.ChatLogFilters.TELL_SEND;
            EA_ChatWindow.whisperTarget   = newTarget;
            EA_ChatWindow.SwitchChannelWithExistingText (EA_TextEntryGroupEntryBoxTextInput.Text);
        end
    end
end

function EA_ChatWindow.ResetTextBox ()
    -- Clear the Text
    TextEditBoxSetText("EA_TextEntryGroupEntryBoxTextInput", L"")  

    -- Reset the color to white
    TextEditBoxSetTextColor ("EA_TextEntryGroupEntryBoxTextInput", 255, 255, 255)
    
    -- Reset all the label stuff
    LabelSetTextColor ("EA_TextEntryGroupEntryBoxChannelLabel", 255, 255, 255)
                                                 
    LabelSetText ("EA_TextEntryGroupEntryBoxChannelLabel", L"")

    EA_ChatWindow.UpdateCurrentChannel( nil )
    if( EA_ChatWindow.savedChannel ~= nil )
    then
        EA_ChatWindow.prevChannel = EA_ChatWindow.savedChannel
        local channelColor = ChatSettings.ChannelColors[ EA_ChatWindow.prevChannel ]
        EA_ChatWindow.UpdateTextEntryChannelColor( channelColor )
    end
    
end


----------------------------------------------------------------
-- Social Window Functions
----------------------------------------------------------------
function EA_ChatWindow.OnMouseoverSocialBtn()
    local text = GetString( StringTables.Default.TOOLTIP_SOCIAL_MENU )
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, text)
    Tooltips.Finalize()
    Tooltips.AnchorTooltip( nil )
end

function EA_ChatWindow.OnClickSocialBtn()
    BroadcastEvent( SystemData.Events.TOGGLE_SOCIAL_WINDOW )
end

function EA_ChatWindow.UpdateSocialWindowButton()
    if (DoesWindowExist("ChatWindowSocialWindowButton") == true)
    then
       if( GameData.Player.realm == GameData.Realm.DESTRUCTION )
       then
            WindowSetDimensions("ChatWindowSocialWindowButton", 59, 77)
            ButtonSetTexture("ChatWindowSocialWindowButton", Button.ButtonState.NORMAL, "EA_HUD_01", 0, 492)
            ButtonSetTexture("ChatWindowSocialWindowButton", Button.ButtonState.HIGHLIGHTED, "EA_HUD_01", 0, 492)
            ButtonSetTexture("ChatWindowSocialWindowButton", Button.ButtonState.PRESSED, "EA_HUD_01", 0, 492)
            ButtonSetTexture("ChatWindowSocialWindowButton", Button.ButtonState.PRESSED_HIGHLIGHTED, "EA_HUD_01", 0, 492)
       end
    end
end

----------------------------------------------------------------
-- EA_ChatTabManager
----------------------------------------------------------------
function EA_ChatTabManager.Initialize()

    for i = 1, MAX_TABS 
    do
        EA_ChatTabManager.Tabs[i] = {}
        EA_ChatTabManager.Tabs[i].used = false
        EA_ChatTabManager.Tabs[i].name = "EA_ChatTab"..i
        EA_ChatTabManager.Tabs[i].wndGroupId = 0
    end
end

function EA_ChatTabManager.CreateTab( tabParent, wndGroupId )

    for i = 1, MAX_TABS 
    do
        if ( EA_ChatTabManager.Tabs[i].used == false )
        then
            -- create the tab
            EA_ChatTabManager.Tabs[i].used = true
            
            local tabWndName = EA_ChatTabManager.Tabs[i].name
            CreateWindowFromTemplate (tabWndName, "EA_ChatTab", tabParent)

            -- Each tab knows which window group it belongs to
            EA_ChatTabManager.Tabs[i].wndGroupId = wndGroupId

            -- create the text log display
            local tabLogDisplayName = tabWndName.."TextLog"
            CreateWindowFromTemplate (tabLogDisplayName, "EA_ChatLogDisplay", EA_ChatWindowGroups[wndGroupId].name)
            
            -- add the Chat and Combat Log to the display
            LogDisplayAddLog( tabLogDisplayName, "Chat", true )
            LogDisplayAddLog( tabLogDisplayName, "Combat", true )
            LogDisplayAddLog( tabLogDisplayName, "System", true )

            -- text fade time
            local visibleTime = 300
            if( SystemData.Settings.Chat.fadeText ) then
                visibleTime = SystemData.Settings.Chat.visibleTime
            end
            LogDisplaySetTextFadeTime( tabLogDisplayName, visibleTime )
            -- scroll limit
            LogDisplaySetEntryLimit( tabLogDisplayName, SystemData.Settings.Chat.scrollLimit )
            
            -- these windows are given the tabId because they needs to do unique behavior 
            -- on a per tab basis when clicked
            WindowSetId(tabWndName, i)
            WindowSetId(tabWndName.."Button", i)
            WindowSetId(tabLogDisplayName.."ToBottomButton", i)
            -- the next 2 just use wndGroupId.  It is only used for mouseover begin/end
            -- to do the fade in/out for autoHide.
            WindowSetId(tabLogDisplayName, wndGroupId)
            WindowSetId(tabLogDisplayName.."Scrollbar", wndGroupId)

            -- Hide the alert
            WindowSetShowing(tabLogDisplayName.."ToBottomButtonAlert", false)

            return i, tabWndName
        end
    end
    
    return 0, ""
end

function EA_ChatTabManager.DestroyTab( tabId )

    local tabWndName = EA_ChatTabManager.Tabs[tabId].name
    DestroyWindow (tabWndName )
    DestroyWindow (tabWndName.."TextLog")
    
    EA_ChatTabManager.Tabs[tabId].used = false

end

function EA_ChatTabManager.MoveTabToNewWndGroup( tabId, newWndGroupId, tabParent )

    -- add wndgroup tab to new window group
    local tabWndName = EA_ChatTabManager.Tabs[tabId].name
    WindowSetParent( tabWndName, tabParent)

    -- assign the newWndGroupId
    EA_ChatTabManager.Tabs[tabId].wndGroupId = newWndGroupId

    local tabLogDisplayName = tabWndName.."TextLog"
    WindowSetParent( tabLogDisplayName, EA_ChatWindowGroups[newWndGroupId].name)
    
    -- set the newWndGroupId   
    WindowSetId(tabLogDisplayName, newWndGroupId)
    WindowSetId(tabLogDisplayName.."Scrollbar", newWndGroupId)
    
end

function EA_ChatTabManager.CanRemoveTab( tabManagerId )
        
    local wndGroupId = EA_ChatTabManager.Tabs[tabManagerId].wndGroupId 
    local wndGroupTabId = EA_ChatTabManager.GetWndGroupTabId( wndGroupId, tabManagerId )
    
    if( wndGroupId == 1 and wndGroupTabId == 1)
    then
        return false
    end
    
    return true
end

function EA_ChatTabManager.HasFreeTab()
    
    for i = 1, MAX_TABS 
    do
        if ( EA_ChatTabManager.Tabs[i].used == false )
        then
            return true
        end
    end
    
    return false
end

function EA_ChatTabManager.GetTabName( tabId )

    -- validate tabID
    if (tabId < 1 or tabId > #EA_ChatTabManager.Tabs or EA_ChatTabManager.Tabs[tabId].used == false )
    then
        return nil
    end
   
    return EA_ChatTabManager.Tabs[tabId].name
end

function EA_ChatTabManager.GetWndGroupTabId( wndGroupId, tabId )

    wndGroupTabId = 0
    
    -- iterate on the window group tabs, and find the one that matches the tabId
    for k, tab in ipairs(EA_ChatWindowGroups[wndGroupId].Tabs)
    do

        if( tab.tabManagerId == tabId)
        then 
            wndGroupTabId = k
            break
        end

    end

    return wndGroupTabId
end

function EA_ChatTabManager.CreateSuggestedTabText( currTabText )
    
    -- check for the a number surrounded by ( ) in the string
    local _, _, numFound = wstring.find(currTabText, L"%((%d+)%)")

    -- take the current tabs existing text, append a number to it, or replace an already 
    -- existing number with a new.  Then see if that text is already used, 
    -- until we find an available tab text for the new tab
    for num = 1, MAX_TABS
    do
        
        local newTabText
        
        if( numFound )
        then
            if ( numFound == num )
            then
                -- if numFound is the same as num, replacing it would only 
                -- create the same string so just continue
                continue
            else
                -- replace the (numFound) with (num)
                newTabText = wstring.gsub(currTabText, L"%((%d+)%)", L"("..num..L")", 1)
            end
        else
            -- append (num) to end of text
            newTabText = currTabText..L"("..num..L")"
        end

        local newTabTextAlreadyUsed = false
        
        -- search the tabs in the tab manager to see if the name is already used
        for i = 1, MAX_TABS 
        do
            if ( EA_ChatTabManager.Tabs[i].used == true )
            then
                local tabText = ButtonGetText( EA_ChatTabManager.Tabs[i].name.."Button" )
                
                if (tabText == newTabText)
                then
                    newTabTextAlreadyUsed = true
                    break
                end

            end
        end
        
        if ( newTabTextAlreadyUsed ~= true )
        then
            return newTabText
        end
    end
    
    return L""
    
end 

----------------------------------------------------------------
-- Chat Window Tab Manipulation Functions
----------------------------------------------------------------
function EA_ChatWindow.OnRenameTab()
    
    EA_ChatWindow.HideMenu()
    
    WindowSetShowing( "ChatWindowRenameWindow", true )
    local tabButtonName = EA_ChatTabManager.Tabs[EA_ChatTabManager.activeTabId].name.."Button"
    TextEditBoxSetText( "ChatWindowRenameWindowText", ButtonGetText( tabButtonName ) )
end

function EA_ChatWindow.OnRename()

    local tabManagerId = EA_ChatTabManager.activeTabId

    local newName = TextEditBoxGetText( "ChatWindowRenameWindowText" )
    local tabName = EA_ChatTabManager.Tabs[tabManagerId].name
    local tabButtonName = tabName.."Button"
    ButtonSetText(tabName.."Button", newName)
    
    local tabButtonWidth, tabButtonHeight = WindowGetDimensions( tabName.."Button" )        
    WindowSetDimensions( tabName, tabButtonWidth, tabButtonHeight)  
    
    local wndGroupId = EA_ChatTabManager.Tabs[tabManagerId].wndGroupId
    local wndGroupTabId = EA_ChatTabManager.GetWndGroupTabId( wndGroupId, tabManagerId )

    -- update tabText
    EA_ChatWindowGroups[wndGroupId].Tabs[wndGroupTabId].tabText = newName
    
    -- update total tab width
    EA_ChatWindow.UpdateTabTotalWidth( wndGroupId )

    EA_ChatWindow.UpdateTabScrollWindow( wndGroupId )
    
    WindowSetShowing( "ChatWindowRenameWindow", false )
    EA_ChatWindow.OnSettingsChanged()
end

function EA_ChatWindow.OnCancelRename()
    WindowSetShowing( "ChatWindowRenameWindow", false )
end

function EA_ChatWindow.RemoveTabFromWndGroup(tabManagerId, wndGroupId, destroy)

    local numOfTabsInWndGroup = #EA_ChatWindowGroups[wndGroupId].Tabs

    if ( numOfTabsInWndGroup == 1 )
    then
        if( destroy )
        then
            EA_ChatTabManager.DestroyTab( tabManagerId )
        end

        EA_ChatWindow.DestroyWindowGroup( wndGroupId )
    else
        
        local wndGroupTabId = EA_ChatTabManager.GetWndGroupTabId( wndGroupId, tabManagerId )
        local activeTab = EA_ChatWindow.RemoveTabReAnchorHelper(wndGroupId, wndGroupTabId, numOfTabsInWndGroup)
        
        if( destroy )
        then
            EA_ChatTabManager.DestroyTab( tabManagerId )
        end
        
        -- remove the tab from the Tabs array of the window group
        table.remove( EA_ChatWindowGroups[wndGroupId].Tabs, wndGroupTabId )
        
        -- update total tab width
        EA_ChatWindow.UpdateTabTotalWidth( wndGroupId )

        -- update the tab appearance for the new active tab    
        EA_ChatWindow.SetToTab( activeTab )
        -- update the tab scroll window
        EA_ChatWindow.UpdateTabScrollWindow( wndGroupId )
    end
    
    EA_ChatWindow.HideMenu()
    EA_ChatWindow.OnSettingsChanged()
end

function EA_ChatWindow.OnRemoveTab()
    
    local tabManagerId = EA_ChatTabManager.activeTabId
    local wndGroupId = EA_ChatTabManager.Tabs[tabManagerId].wndGroupId

    EA_ChatWindow.RemoveTabFromWndGroup( tabManagerId, wndGroupId, true )
    
    EA_ChatWindow.HideMenu()
    EA_ChatWindow.OnSettingsChanged()
end

function EA_ChatWindow.OnNewTab( )

    local tabManagerId = EA_ChatTabManager.activeTabId
    local wndGroupId = EA_ChatTabManager.Tabs[tabManagerId].wndGroupId
    
    -- get the window group Tab Id for the currently active tab so we can
    -- access and copy information from it to the new tab we are going to create
    local wndGroupTabId = EA_ChatTabManager.GetWndGroupTabId( wndGroupId, tabManagerId )
    
    -- we are inserting a tab at the end of the window group's tab array
    -- the new tab Id is the current #of tabs plus 1
    local newTabId = #EA_ChatWindowGroups[wndGroupId].Tabs + 1
    
    -- copy info from the durrent tab to the new tab
    local currentTab = EA_ChatWindowGroups[wndGroupId].Tabs[wndGroupTabId]
    EA_ChatWindowGroups[wndGroupId].Tabs[newTabId] = {}
    EA_ChatWindowGroups[wndGroupId].Tabs[newTabId].tabText = EA_ChatTabManager.CreateSuggestedTabText( currentTab.tabText )
    EA_ChatWindowGroups[wndGroupId].Tabs[newTabId].defaultLog = currentTab.defaultLog
    EA_ChatWindowGroups[wndGroupId].Tabs[newTabId].font = currentTab.font
    EA_ChatWindowGroups[wndGroupId].Tabs[newTabId].showTimestamp = currentTab.showTimestamp
    EA_ChatWindowGroups[wndGroupId].Tabs[newTabId].flashOnActivity = currentTab.flashOnActivity

    EA_ChatWindowGroups[wndGroupId].Tabs[newTabId].Filters = {}
    -- copy the filters from the current tab to the new tab
    local tabLogDisplayName = EA_ChatTabManager.Tabs[tabManagerId].name.."TextLog"
    for channelId, channelData in pairs(ChatSettings.Channels) do
        local enabled = LogDisplayGetFilterState( tabLogDisplayName, channelData.logName, channelId )
        EA_ChatWindowGroups[wndGroupId].Tabs[newTabId].Filters[ channelId ] = enabled
    end
   
    -- add the tab to the window group 
    EA_ChatWindow.AddTabToWindowGroup( wndGroupId, newTabId )
    
    -- the scroll offset will get set in UpdateTabScrollWindow.  By setting it to tabTotalWidth
    -- UpdateTabScrollWindow will be able to push the tabs to the left if necessary, so we can see
    -- the newly created tabs on the right. 
    EA_ChatWindowGroups[wndGroupId].scrollOffset = EA_ChatWindowGroups[wndGroupId].tabTotalWidth
    -- update the tab scroll window
    EA_ChatWindow.UpdateTabScrollWindow( wndGroupId )

    local wndGroupName = EA_ChatWindowGroups[wndGroupId].name
    local tabWindowName = wndGroupName.."TabWindow"
    local tabWindowWidth, _ = WindowGetDimensions( tabWindowName ) 
    -- enable the left cycle button if necessary
    if ( EA_ChatWindowGroups[wndGroupId].tabTotalWidth > tabWindowWidth)
    then
        ButtonSetDisabledFlag( wndGroupName.."CycleLeftButton", false )
        EA_ChatWindow.ShowTabCycleButtons(wndGroupName, true)
    end
    
    EA_ChatWindow.HideMenu()
    EA_ChatWindow.OnSettingsChanged()
end

function EA_ChatWindow.UpdateTabTotalWidth( wndGroupId )
    -- iterate on tabs in window group
    local totalTabWidth = 0
    for k, tab in ipairs(EA_ChatWindowGroups[wndGroupId].Tabs)
    do
        local tabName = EA_ChatTabManager.GetTabName( tab.tabManagerId )
        if( tabName == nil )
        then 
            continue
        end

        local tabButtonWidth, _ = WindowGetDimensions( tabName.."Button" )        
        
        -- accumulate total tab width
        totalTabWidth = totalTabWidth + tabButtonWidth
    end

    EA_ChatWindowGroups[wndGroupId].tabTotalWidth = totalTabWidth
end

----------------------------------------------------------------
-- Docking/Undocking related Chat Window functions
----------------------------------------------------------------
function EA_ChatWindow.CanUndock()

    for i = 1, MAX_WINDOW_GROUPS 
    do
        if( EA_ChatWindowGroups[i].used == false )
        then
            return i
        end
    end
    
    return 0
end

function EA_ChatTabManager.DockingBegin(tabId)
    
    if( tabId >= 1 and EA_ChatTabManager.CanRemoveTab( tabId ) )
    then  
        EA_ChatTabManager.dockingTabId = tabId
        EA_ChatTabManager.dockingStart = true
    end

end

function EA_ChatTabManager.DockingEnd()
    
    local tabId = EA_ChatWindow.GetTabIdFromWindowName( SystemData.MouseOverWindow.name )
    
    -- if a tabID was found, but the mouseover window name does not match the tab name, then
    -- we are not really over a tab
    if( tabId >= 1 and SystemData.MouseOverWindow.name ~= EA_ChatTabManager.Tabs[tabId].name.."Button" )
    then
        tabId = -1
    end

    -- dock to the right of the tab we are on 
    if( tabId >= 1 )
    then

        EA_ChatWindow.Dock(EA_ChatTabManager.dockingTabId, tabId)

    else -- we are not over another tab undock and make a new window group
    
        local currWndGroupId = EA_ChatTabManager.Tabs[EA_ChatTabManager.dockingTabId].wndGroupId
        
        -- Undock if we have more than 1 tab in the current window group
        if( #EA_ChatWindowGroups[currWndGroupId].Tabs > 1 )
        then
            -- get free window group
            local newWndGroupId = EA_ChatWindow.CanUndock()

            if( newWndGroupId ~= 0 )
            then

                local width, height = WindowGetDimensions( "EA_ChatDockingWindow" )        
                local x, y = WindowGetOffsetFromParent( "EA_ChatDockingWindow" )        
                EA_ChatWindow.Undock(EA_ChatTabManager.dockingTabId, newWndGroupId, x, y, width, height)
            end        
        else 
            -- only 1 tab, so all we really did was move the current window group to a new position
            local x, y = WindowGetOffsetFromParent( "EA_ChatDockingWindow" )        
            WindowSetOffsetFromParent( EA_ChatWindowGroups[currWndGroupId].name, x, y )        

            EA_ChatWindow.OnSettingsChanged()
        end   

    end
    
    WindowSetShowing("EA_ChatDockingWindow", false)
    WindowClearAnchors("EA_ChatDockingWindow")

    EA_ChatTabManager.isDocking = false 
    
end

function EA_ChatWindow.HideTabInsert(wndGroupId)

    local tabMarkerName = EA_ChatWindowGroups[wndGroupId].name.."TabWindowScrollChildTabInsert"   
    
    WindowStopAlphaAnimation( tabMarkerName )
    WindowSetShowing(tabMarkerName, false)

end

-- this helper just handles re-anchoring the right tab to the left tab 
-- when a tab is removed from a window group.  It also determines the new
-- active tab.  The new active tab is the tab to the left if one exists
-- otherwise it is the tab to the right.
function EA_ChatWindow.RemoveTabReAnchorHelper(wndGroupId, wndGroupTabId, numOfTabsInWndGroup)

    local activeTab

    if ( wndGroupTabId < numOfTabsInWndGroup )
    then
    
        local rightTabName = EA_ChatTabManager.GetTabName( EA_ChatWindowGroups[wndGroupId].Tabs[wndGroupTabId+1].tabManagerId )

        if( wndGroupTabId == 1 )
        then
            WindowClearAnchors( rightTabName )
            
            -- tab to the right is now the first tab and it gets the scrolloffset
            WindowSetOffsetFromParent( rightTabName, -EA_ChatWindowGroups[wndGroupId].scrollOffset, 0 )

            -- set tab to right to be the active tab
            activeTab = EA_ChatWindowGroups[wndGroupId].Tabs[wndGroupTabId+1].tabManagerId
        else 
            -- anchor tab to right onto tab to left
            local leftTabName = EA_ChatTabManager.GetTabName( EA_ChatWindowGroups[wndGroupId].Tabs[wndGroupTabId-1].tabManagerId )
            WindowClearAnchors( rightTabName )
            WindowAddAnchor( rightTabName, "bottomright", leftTabName, "bottomleft", 0, 0 )
    
            -- set tab to left to be the active tab
            activeTab = EA_ChatWindowGroups[wndGroupId].Tabs[wndGroupTabId-1].tabManagerId
        end
    else
        -- we are removing right most tab, all we need to do is set tab to left to be the active tab
        activeTab = EA_ChatWindowGroups[wndGroupId].Tabs[wndGroupTabId-1].tabManagerId
    end
    
    return activeTab
end

function EA_ChatWindow.InsertTabReAnchorHelper( tabName, wndGroupId, wndGroupTabId, numOfTabsInWndGroup)

    -- anchor to previous tab
    -- Note: We are always inserting to the right of a tab, so destWndGroupTabId should never be less than 2
    -- Meaning if we docked to the 1st tab of a window gorup, destWndGroupTabId will be 2.  Thus, it is
    -- safe to subtract 1, and index into the Tabs table here
    local prevTabName = EA_ChatTabManager.GetTabName( EA_ChatWindowGroups[wndGroupId].Tabs[wndGroupTabId-1].tabManagerId )
    WindowClearAnchors( tabName )
    WindowAddAnchor( tabName, "bottomright", prevTabName, "bottomleft", 0, 0 )
                
    -- if there is a tab to the right, anchor it to the newly inserted tab
    if ( wndGroupTabId < numOfTabsInWndGroup )
    then
        local rightTabName = EA_ChatTabManager.GetTabName( EA_ChatWindowGroups[wndGroupId].Tabs[wndGroupTabId+1].tabManagerId )            
        WindowClearAnchors( rightTabName )
        WindowAddAnchor( rightTabName, "bottomright", tabName, "bottomleft", 0, 0 )
    end
        
end

function EA_ChatWindow.Dock(srcTabId, destTabId)

    local srcWndGroupId = EA_ChatTabManager.Tabs[srcTabId].wndGroupId
    local destWndGroupId = EA_ChatTabManager.Tabs[destTabId].wndGroupId
    
    EA_ChatWindow.HideTabInsert(destWndGroupId)
    
    if( srcWndGroupId == destWndGroupId )
    then
        -- we are rearranging the tab order within the windowgroup
        local wndGroupId = srcWndGroupId
        
        -- add 1 to destination because we are inserting to the right of the tab
        local destWndGroupTabId = EA_ChatTabManager.GetWndGroupTabId( wndGroupId, destTabId ) + 1
        local srcWndGroupTabId = EA_ChatTabManager.GetWndGroupTabId( wndGroupId, srcTabId )

        -- in either of these cases the tab would end up in the same spot
        if( srcWndGroupTabId == destWndGroupTabId or 
            srcWndGroupTabId+1 == destWndGroupTabId  )
        then
            return
        end
        
        
        local numOfTabsInWndGroup = #EA_ChatWindowGroups[wndGroupId].Tabs
        EA_ChatWindow.RemoveTabReAnchorHelper(wndGroupId, srcWndGroupTabId, numOfTabsInWndGroup)

        local srcTabTable = EA_ChatWindowGroups[wndGroupId].Tabs[srcWndGroupTabId]
        
        -- remove the tab from the Tabs array of the window group
        table.remove( EA_ChatWindowGroups[wndGroupId].Tabs, srcWndGroupTabId )
        
        destWndGroupTabId = EA_ChatTabManager.GetWndGroupTabId( wndGroupId, destTabId ) + 1
        -- insert the reference of the source tab to the right of the destination tab
        table.insert(EA_ChatWindowGroups[wndGroupId].Tabs, destWndGroupTabId, srcTabTable)
        
        local tabName = EA_ChatTabManager.Tabs[srcTabId].name

        EA_ChatWindow.InsertTabReAnchorHelper( tabName, wndGroupId, destWndGroupTabId, numOfTabsInWndGroup)

        EA_ChatWindow.SetToTab( srcTabId )

    else
    
        -- add 1 to destination because we are inserting to the right of the tab
        local destWndGroupTabId = EA_ChatTabManager.GetWndGroupTabId( destWndGroupId, destTabId ) + 1
        local srcWndGroupTabId = EA_ChatTabManager.GetWndGroupTabId( srcWndGroupId, srcTabId )
        
        -- insert the reference of the source tab to the right of the destination tab
        table.insert(EA_ChatWindowGroups[destWndGroupId].Tabs, destWndGroupTabId, EA_ChatWindowGroups[srcWndGroupId].Tabs[srcWndGroupTabId])
    
        
        local wndGroupName = EA_ChatWindowGroups[destWndGroupId].name
        local tabParentName = wndGroupName.."TabWindowScrollChild"   
        
        EA_ChatTabManager.MoveTabToNewWndGroup( srcTabId, destWndGroupId, tabParentName )

        local tabName = EA_ChatTabManager.Tabs[srcTabId].name
        local tabLogDisplayName = tabName.."TextLog"

        -- anchor the text log display
        WindowClearAnchors( tabLogDisplayName )
        WindowAddAnchor( tabLogDisplayName, "topleft", wndGroupName.."Foreground", "topleft", 0, 0 )
        WindowAddAnchor( tabLogDisplayName, "bottomright", wndGroupName.."Foreground", "bottomright", -5, 0 )

        local numOfTabsInWndGroup = #EA_ChatWindowGroups[destWndGroupId].Tabs
        EA_ChatWindow.InsertTabReAnchorHelper( tabName, destWndGroupId, destWndGroupTabId, numOfTabsInWndGroup)
        
        EA_ChatWindow.RemoveTabFromWndGroup( srcTabId, srcWndGroupId, false )

        -- update total tab width
        EA_ChatWindow.UpdateTabTotalWidth( destWndGroupId )
        -- update the tab scroll window
        EA_ChatWindow.UpdateTabScrollWindow( destWndGroupId )

        EA_ChatWindow.SetToTab( srcTabId )
        
    end
    
    EA_ChatWindow.OnSettingsChanged()

end

function EA_ChatWindow.Undock(tabManagerId, newWndGroupId, posX, posY, width, height)
    
    local wndGroupId = EA_ChatTabManager.Tabs[tabManagerId].wndGroupId
    local wndGroupTabId = EA_ChatTabManager.GetWndGroupTabId( wndGroupId, tabManagerId )
    
    -- copy window group attributes to new window group
    EA_ChatWindowGroups[newWndGroupId].activeTab = 1
    EA_ChatWindowGroups[newWndGroupId].scrollOffset = 0
    EA_ChatWindowGroups[newWndGroupId].canAutoHide = EA_ChatWindowGroups[wndGroupId].canAutoHide
    EA_ChatWindowGroups[newWndGroupId].maxAlpha = EA_ChatWindowGroups[wndGroupId].maxAlpha
    EA_ChatWindowGroups[newWndGroupId].movable = EA_ChatWindowGroups[wndGroupId].movable

    EA_ChatWindowGroups[newWndGroupId].Tabs = {}
    
    -- give the reference of the tab we are undocking to the first tab of the new window group
    EA_ChatWindowGroups[newWndGroupId].Tabs[1] = EA_ChatWindowGroups[wndGroupId].Tabs[wndGroupTabId]
    
    EA_ChatWindow.RemoveTabFromWndGroup( tabManagerId, wndGroupId, false )
    
    -- create the window group
    EA_ChatWindow.CreateWindowGroup( newWndGroupId )
    EA_ChatWindowGroups[newWndGroupId].fadeOutTimer = FADE_OUT_DELAY

    local tabName = EA_ChatTabManager.Tabs[tabManagerId].name
    -- first tab goes on the left
    WindowClearAnchors( tabName )
    
    local newWndGroupName = EA_ChatWindowGroups[newWndGroupId].name
    local tabParentName = newWndGroupName.."TabWindowScrollChild"   

    EA_ChatTabManager.MoveTabToNewWndGroup( tabManagerId, newWndGroupId, tabParentName )

    WindowSetOffsetFromParent( tabName, 0, 0 )
    
    -- anchor the text log display
    local tabLogDisplayName = tabName.."TextLog"
    WindowClearAnchors( tabLogDisplayName )
    WindowAddAnchor( tabLogDisplayName, "topleft", newWndGroupName.."Foreground", "topleft", 0, 0 )
    WindowAddAnchor( tabLogDisplayName, "bottomright", newWndGroupName.."Foreground", "bottomright", -5, 0 )

    local tabButtonWidth, _ = WindowGetDimensions( tabName.."Button" )        
    
    EA_ChatWindow.SetToTab( tabManagerId )

    EA_ChatWindowGroups[newWndGroupId].tabTotalWidth = tabButtonWidth

    -- position the window
    EA_ChatWindow.WindowGroupSetDims( newWndGroupId, posX, posY, width, height, 1, true )            

    EA_ChatWindow.OnSettingsChanged()
end

----------------------------------------------------------------
-- Main Chat Window functions
----------------------------------------------------------------
function EA_ChatWindow.Initialize()
    
    -- initialize the tabs
    EA_ChatTabManager.Initialize()

    -- load saved chat window settings
    EA_ChatWindow.LoadSettings()
    
    -- default channel colors
    ChatSettings.SetupChannelColorDefaults( false )

    -- Clear the channel history, if there is one. 
    EA_ChatWindow.curChannel = nil
    EA_ChatWindow.prevChannel = nil
    EA_ChatWindow.savedChannel = nil
    
    CreateWindow("ChatWindowRenameWindow", false )
    LabelSetText("ChatWindowRenameWindowLabel", GetChatString( StringTables.Chat.LABEL_CHAT_RENAME_DIALOG ) )
    ButtonSetText("ChatWindowRenameWindowRenameButton", GetChatString( StringTables.Chat.LABEL_CHAT_BUTTON_RENAME ) )
    ButtonSetText("ChatWindowRenameWindowCancelButton", GetString( StringTables.Default.LABEL_CANCEL ) )
   
    CreateWindowFromTemplate ("ChatWindowSetOpacityWindow", "ChatWindowSetOpacityWindow", "Root");
    WindowSetShowing("ChatWindowSetOpacityWindow", false)
    LabelSetText("ChatWindowSetOpacityWindowTitleBarText", GetString( StringTables.Default.LABEL_OPACITY ) )
    
    -- Initialize the ContextMenus
    CreateWindowFromTemplate ("ChatWindowContextAutoHide", "ChatContextMenuItemCheckBox", "Root")
    LabelSetText( "ChatWindowContextAutoHideCheckBoxLabel", GetChatString( StringTables.Chat.LABEL_CHAT_TAB_AUTOHIDE ) )
    WindowRegisterCoreEventHandler("ChatWindowContextAutoHide", "OnLButtonUp", "EA_ChatWindow.ToggleAutoHide")
    WindowSetShowing("ChatWindowContextAutoHide", false)

    CreateWindowFromTemplate ("ChatWindowContextShowTimestamp", "ChatContextMenuItemCheckBox", "Root")
    LabelSetText( "ChatWindowContextShowTimestampCheckBoxLabel", GetChatString( StringTables.Chat.LABEL_CHAT_TAB_TIMESTAMP ) )
    WindowRegisterCoreEventHandler("ChatWindowContextShowTimestamp", "OnLButtonUp", "EA_ChatWindow.ToggleTimestamp")
    WindowRegisterCoreEventHandler("ChatWindowContextShowTimestamp", "OnMouseOver", "EA_Window_ContextMenu.OnMouseOverDefaultMenuItem")
    WindowSetShowing("ChatWindowContextShowTimestamp", false)
    
    CreateWindowFromTemplate ("ChatWindowContextFlashOnActivity", "ChatContextMenuItemCheckBox", "Root")
    LabelSetText( "ChatWindowContextFlashOnActivityCheckBoxLabel", GetChatString( StringTables.Chat.LABEL_CHAT_TAB_FLASH_ON_ACTIVITY ) )
    WindowRegisterCoreEventHandler("ChatWindowContextFlashOnActivity", "OnLButtonUp", "EA_ChatWindow.ToggleFlashOnActivity")
    WindowRegisterCoreEventHandler("ChatWindowContextFlashOnActivity", "OnMouseOver", "EA_Window_ContextMenu.OnMouseOverDefaultMenuItem")
    WindowSetShowing("ChatWindowContextFlashOnActivity", false)

    local size = #ChatSettings.Fonts
    for idx=1, size do
        CreateWindowFromTemplate ("ChatWindowContextFontMenuItem"..idx, "ChatContextMenuItemFontSelection", "Root")
        LabelSetFont( "ChatWindowContextFontMenuItem"..idx.."Label", ChatSettings.Fonts[idx].fontName, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING )
        LabelSetText( "ChatWindowContextFontMenuItem"..idx.."Label", StringToWString(ChatSettings.Fonts[idx].shownName) )
        local _, y = LabelGetTextDimensions( "ChatWindowContextFontMenuItem"..idx.."Label" )
        local x, _ = WindowGetDimensions( "ChatWindowContextFontMenuItem"..idx )
        WindowSetDimensions( "ChatWindowContextFontMenuItem"..idx, x, y )
        WindowRegisterCoreEventHandler("ChatWindowContextFontMenuItem"..idx, "OnLButtonUp", "EA_ChatWindow.SetFontToSelection")
        WindowSetShowing("ChatWindowContextFontMenuItem"..idx, false)
        WindowSetId("ChatWindowContextFontMenuItem"..idx, idx)
    end

    -- Initializes the submenu that allows users to choose the channel of their chat entry.
    EA_ChatWindow.InitializeChannelMenuSelectionWindow()
    
    initialCreateChatWindowGroups = true

    -- initialize the window group table before writing to it
    EA_ChatWindowGroups = {}
    for i = 1, MAX_WINDOW_GROUPS 
    do
        EA_ChatWindowGroups[i] = {}
        EA_ChatWindowGroups[i].used = false
    end
    
    -- copy necessary saved settings to the WindowGroups table, and spawn
    -- all of the WindowGroups
    for wndGroupId, savedWndGroup in ipairs( EA_ChatWindow.Settings.WindowGroups ) 
    do
        if ( wndGroupId > MAX_WINDOW_GROUPS )
        then
            break
        end
        
        EA_ChatWindowGroups[wndGroupId].activeTab = savedWndGroup.activeTab
        EA_ChatWindowGroups[wndGroupId].scrollOffset = savedWndGroup.scrollOffset
        EA_ChatWindowGroups[wndGroupId].canAutoHide = savedWndGroup.canAutoHide
        EA_ChatWindowGroups[wndGroupId].maxAlpha = savedWndGroup.maxAlpha
        EA_ChatWindowGroups[wndGroupId].movable = savedWndGroup.movable
        EA_ChatWindowGroups[wndGroupId].Tabs = {}

        for tabId, savedTab in ipairs(savedWndGroup.Tabs) 
        do          
            EA_ChatWindowGroups[wndGroupId].Tabs[tabId] = {}
            EA_ChatWindowGroups[wndGroupId].Tabs[tabId].tabText = savedTab.tabText
            EA_ChatWindowGroups[wndGroupId].Tabs[tabId].defaultLog = savedTab.defaultLog
            EA_ChatWindowGroups[wndGroupId].Tabs[tabId].font = savedTab.font
            EA_ChatWindowGroups[wndGroupId].Tabs[tabId].showTimestamp = savedTab.showTimestamp
            -- Any new variables added should do an "or false" like flashOnActivity below. This way users
            -- with existing settings won't get nil for these values
            EA_ChatWindowGroups[wndGroupId].Tabs[tabId].flashOnActivity = savedTab.flashOnActivity or false

            EA_ChatWindowGroups[wndGroupId].Tabs[tabId].Filters = {}
                   
            -- We must iterate on the ChatSettings.Channels when we copy the saved tab
            -- filter info.  This will handle supplying default values for newly created 
            -- filters that did not exist when the lua variables were saved.
            for channelId, channelData in pairs( ChatSettings.Channels ) 
            do
                local enabled = false
                -- use the saved tab filter value if it exists
                if ( savedTab.Filters ~= nil and savedTab.Filters[channelId] ~= nil ) 
                then
                    enabled = savedTab.Filters[channelId]
                elseif (savedTab.defaultLog ~= nil ) -- use the default log value
                then                   
                    enabled = channelData.isOn and channelData.logName == savedTab.defaultLog
                end
                EA_ChatWindowGroups[wndGroupId].Tabs[tabId].Filters[channelId] = enabled
            end
        end    

        -- create the window group
        EA_ChatWindow.CreateWindowGroup( wndGroupId )
        -- add the tabs
        EA_ChatWindow.AddTabsToWindowGroup( wndGroupId )
        
        EA_ChatWindow.RepositionWindowGroup( wndGroupId )
        
        -- because Chat Windows don't have savesettings="true" we must manually check if the window group
        -- is hidden by the Layout Editor and if so hide it
        if ( LayoutEditor.IsWindowUserHidden( EA_ChatWindowGroups[wndGroupId].name ) )
        then
            WindowSetShowing( EA_ChatWindowGroups[wndGroupId].name, false )
        end
    end
    
    initialCreateChatWindowGroups = false
    
    -- hide language button by default
    WindowSetShowing("EA_TextEntryGroupEntryBoxLanguageButton", false)
    -- OnLanguageToggled will show the language button if necessary
    EA_ChatWindow.OnLanguageToggled()

    EA_ChatWindow.ResetTextBox()

    -- Set the history (this preserves it logging in/out)
    if( GameData.ChatData.history ) then
        TextEditBoxSetHistory("EA_TextEntryGroupEntryBoxTextInput", GameData.ChatData.history )   
    end

    CreateWindow( "EA_ChatDockingWindow", false )

    local function RegisterTextLogUpdate( textLog )
        -- Register text log update events so we can flash tabs
        local chatLogEventId = TextLogGetUpdateEventId( textLog )
        RegisterEventHandler( chatLogEventId, "EA_ChatWindow.OnTextLogUpdated" )
    end
    
    RegisterTextLogUpdate( "Chat" )
    RegisterTextLogUpdate( "Combat" )
    RegisterTextLogUpdate( "System" )

    RegisterEventHandler( SystemData.Events.RESOLUTION_CHANGED, "EA_ChatWindow.RepositionAllWindowGroups" )

    -- Mark the settings as dirty so we sync our data after we first log in
    EA_ChatWindow.OnSettingsChanged()
end

function EA_ChatWindow.RepositionAllWindowGroups()
    for wndGroupId, _ in ipairs( EA_ChatWindow.Settings.WindowGroups )
    do
        EA_ChatWindow.RepositionWindowGroup( wndGroupId )
    end
end

function EA_ChatWindow.RepositionWindowGroup( wndGroupId )
    local savedWndGroup = EA_ChatWindow.Settings.WindowGroups[ wndGroupId ]
    if not savedWndGroup
    then
        return
    end

    -- Application Window Size
    local screenX, screenY = GetScreenResolution()

    -- Window Position - Convert the x and y into general parameters for the screen
    -- based on the window's scale.
    local posX = savedWndGroup.windowDims.x * screenX * savedWndGroup.windowDims.scale
    local posY = savedWndGroup.windowDims.y * screenY * savedWndGroup.windowDims.scale
    
    savedWndGroup.windowDims.width = math.max(WINDOW_MIN_WIDTH, savedWndGroup.windowDims.width)
    savedWndGroup.windowDims.height = math.max(WINDOW_MIN_HEIGHT, savedWndGroup.windowDims.height)
    
    -- position the window
    EA_ChatWindow.WindowGroupSetDims( wndGroupId, posX, posY, savedWndGroup.windowDims.width, savedWndGroup.windowDims.height, savedWndGroup.windowDims.scale, savedWndGroup.movable )
end

function EA_ChatWindow.OnSystemTextLogUpdated( updateType, filterType )
    if( updateType ~= SystemData.TextLogUpdate.ADDED )
    then
        return
    end
    
    -- System log text cannot be filtered, and is always on window 1, tab 1
    if( EA_ChatWindowGroups[1] == nil or EA_ChatWindowGroups[1].Tabs[1] == nil )
    then
        -- Since window 1 tab 1 can never be removed, we should never get in here,
        -- but just in case, let's fail silently
        return
    end
    
    local tab = EA_ChatWindowGroups[1].Tabs[1]
    -- Since there's no way to filter system messages, let's just go ahead and flash
    -- based on active tab and user's flash setting
    if( EA_ChatWindowGroups[1].activeTab ~= 1 and tab.flashOnActivity and not tab.flashing )
    then
        local tabName = EA_ChatTabManager.GetTabName( tab.tabManagerId )
        
        tab.flashing = true
        WindowStartAlphaAnimation( tabName.."Background", Window.AnimationType.LOOP, TAB_FLASH_MAX_ALPHA, TAB_FLASH_MIN_ALPHA, TAB_FLASH_TIME, false, 0, 0 )
        WindowStartAlphaAnimation( tabName.."Button", Window.AnimationType.LOOP, TAB_FLASH_MAX_ALPHA, TAB_FLASH_MIN_ALPHA, TAB_FLASH_TIME, false, 0, 0 )
    end
end

function EA_ChatWindow.OnTextLogUpdated( updateType, filterType )

    if( updateType ~= SystemData.TextLogUpdate.ADDED )
    then
        return
    end

    -- Loop through chat windows...
    for windowIndex, windowGroup in ipairs( EA_ChatWindowGroups )
    do
        -- Verify the group is even in use, and has tabs
        if( windowGroup.used and windowGroup.Tabs ~= nil )
        then
            -- Loop through each tab in the window
            for tabIndex, tab in ipairs( windowGroup.Tabs )
            do
                -- We need to check filter status from settings, as the window group's filter list will be dirty if anything changed since load
                local hasFilter = EA_ChatWindow.Settings.WindowGroups[windowIndex].Tabs[tabIndex].Filters[filterType]
            
                -- Flash this tab only if it has the filter, isn't active, and the option is on
                if( hasFilter and windowGroup.activeTab ~= tabIndex and tab.flashOnActivity and not tab.flashing )
                then
                    -- We have a match! let's flash this tab
                    local tabName = EA_ChatTabManager.GetTabName( tab.tabManagerId )
                    if( tabName == nil )
                    then
                        -- Something went wrong if we get here, let's just move on to the next tab
                        continue
                    end

                    tab.flashing = true
                    WindowStartAlphaAnimation( tabName.."Background", Window.AnimationType.LOOP, TAB_FLASH_MAX_ALPHA, TAB_FLASH_MIN_ALPHA, TAB_FLASH_TIME, false, 0, 0 )
                    WindowStartAlphaAnimation( tabName.."Button", Window.AnimationType.LOOP, TAB_FLASH_MAX_ALPHA, TAB_FLASH_MIN_ALPHA, TAB_FLASH_TIME, false, 0, 0 )
                end
            end
        end
    end
end

local function ConvertChatSettings21to22()

    if not EA_ChatWindow.Settings
    then
        return false
    end
    -- 2.1 -> 2.2 go up to version 2.2 without losing saved chat tab settings
    if EA_ChatWindow.Settings.Version == 2.1 then
        
        local function ToggleRealmWarChatForTab( tab, enabled )
            tab.Filters[SystemData.ChatLogFilters.REALM_WAR_T1] = enabled
            tab.Filters[SystemData.ChatLogFilters.REALM_WAR_T2] = enabled
            tab.Filters[SystemData.ChatLogFilters.REALM_WAR_T3] = enabled
            tab.Filters[SystemData.ChatLogFilters.REALM_WAR_T4] = enabled
        end
        -- disable new channels in all tabs by default, then turn on only for tabs we care about
        for iTab = 1, MAX_TABS 
        do
            if not EA_ChatWindow.Settings.WindowGroups[1].Tabs[iTab] 
            then
                continue
            end
            EA_ChatWindow.Settings.WindowGroups[1].Tabs[iTab].Filters[SystemData.ChatLogFilters.ADVICE] = false
            
            ToggleRealmWarChatForTab( EA_ChatWindow.Settings.WindowGroups[1].Tabs[iTab], false )
        end
        
        -- Advice default on for Chat tab. Since tabs are customizable, consider any tab with the SAY filter on fair game for Advice
        for iTab = 1, MAX_TABS 
        do
            if not EA_ChatWindow.Settings.WindowGroups[1].Tabs[iTab]
            then
                continue
            end
            
            if EA_ChatWindow.Settings.WindowGroups[1].Tabs[iTab].Filters[SystemData.ChatLogFilters.SAY]
            then
                
                EA_ChatWindow.Settings.WindowGroups[1].Tabs[iTab].Filters[SystemData.ChatLogFilters.ADVICE] = true
            end
        end

        -- Realm War default on for Chat and RvR 
        for iTab = 1, MAX_TABS 
        do
            if not EA_ChatWindow.Settings.WindowGroups[1].Tabs[iTab]
            then
                continue
            end
            
            if EA_ChatWindow.Settings.WindowGroups[1].Tabs[iTab].Filters[SystemData.ChatLogFilters.SAY] or
                    EA_ChatWindow.Settings.WindowGroups[1].Tabs[iTab].Filters[SystemData.ChatLogFilters.SCENARIO]
            then
                ToggleRealmWarChatForTab( EA_ChatWindow.Settings.WindowGroups[1].Tabs[iTab], true )
            end
        end
        
        EA_ChatWindow.Settings.Version = 2.2
        return true
    end
end

local function ConvertChatSettings22to23()

    if EA_ChatWindow.Settings and EA_ChatWindow.Settings.Version == 2.2
    then
        if( ChatSettings.ChannelColors )
        then
            ChatSettings.ChannelColors[ SystemData.ChatLogFilters.ADVICE ] = ChatSettings.Channels[ SystemData.ChatLogFilters.ADVICE ].defaultColor
            EA_ChatWindow.Settings.Version = 2.3
            return true
        end
    end

    return false
end

local function ConvertChatSettings23to24()

    if EA_ChatWindow.Settings and EA_ChatWindow.Settings.Version == 2.3 and
       EA_ChatWindow.Settings.WindowGroups[1] and EA_ChatWindow.Settings.WindowGroups[1].Tabs[1] and
       EA_ChatWindow.Settings.WindowGroups[1].Tabs[1].Filters
    then
        EA_ChatWindow.Settings.WindowGroups[1].Tabs[1].Filters[SystemData.SystemLogFilters.GENERAL] = true
        EA_ChatWindow.Settings.WindowGroups[1].Tabs[1].Filters[SystemData.SystemLogFilters.ERROR] = true
        EA_ChatWindow.Settings.WindowGroups[1].Tabs[1].Filters[SystemData.SystemLogFilters.NOTICE] = true
        EA_ChatWindow.Settings.Version = 2.4
    end

    return true
end

local function ConvertChatSettings24to25()

    if ( EA_ChatWindow.Settings
         and EA_ChatWindow.Settings.Version == 2.4
         and EA_ChatWindow.Settings.WindowGroups[1]
         and EA_ChatWindow.Settings.WindowGroups[1].Tabs[1]
         and EA_ChatWindow.Settings.WindowGroups[1].Tabs[1].Filters )
    then
        EA_ChatWindow.Settings.WindowGroups[1].Tabs[1].Filters[SystemData.SystemLogFilters.GENERAL] = true
        EA_ChatWindow.Settings.WindowGroups[1].Tabs[1].Filters[SystemData.SystemLogFilters.NOTICE] = true
        EA_ChatWindow.Settings.WindowGroups[1].Tabs[1].Filters[SystemData.SystemLogFilters.ERROR] = true
        EA_ChatWindow.Settings.Version = 2.5
        return true
    end

    return false
end

local versionConverters = 
{
    [2.1] = ConvertChatSettings21to22,
    [2.2] = ConvertChatSettings22to23,
    [2.3] = ConvertChatSettings23to24,
    [2.4] = ConvertChatSettings24to25,
}

local function ConvertChatSettingsToCurrentVer()

    while EA_ChatWindow.Settings.Version < EA_ChatWindow.BaseVersion
    do
        if not versionConverters[EA_ChatWindow.Settings.Version]
        then
            break
        end
        
        local result, err = pcall( versionConverters[EA_ChatWindow.Settings.Version] )
        if not result
        then
            ERROR(L"Failed to convert EA_ChatWindow.Settings to latest version! Error: "..towstring(err) )
            break
        end
    end
    
end

function EA_ChatWindow.LoadSettings()      
    
    if EA_ChatWindow.Settings.Version and EA_ChatWindow.Settings.Version < EA_ChatWindow.BaseVersion
    then
        -- if this doesn't succeed, EA_ChatWindow.Settings.Version still won't be EA_ChatWindow.BaseVersion
        -- so below we'll just wipe out what was there and start fresh with default settings
        ConvertChatSettingsToCurrentVer()
    end
    
    if ( EA_ChatWindow.Settings.WindowGroups == nil
        or EA_ChatWindow.Settings.WindowGroups[1] == nil
        or EA_ChatWindow.Settings.WindowGroups[1].windowDims == nil
        or EA_ChatWindow.Settings.WindowGroups[1].Tabs == nil
        or EA_ChatWindow.Settings.WindowGroups[1].Tabs[1] == nil
        or EA_ChatWindow.Settings.WindowGroups[1].Tabs[1].defaultLog == nil
        or EA_ChatWindow.Settings.WindowGroups[1].Tabs[1].font == nil 
        or EA_ChatWindow.Settings.WindowGroups[1].Tabs[1].Filters == nil
        or EA_ChatWindow.Settings.Version == nil 
        or EA_ChatWindow.Settings.Version < EA_ChatWindow.BaseVersion )
    then
        -- Initialize the Default Settings
        EA_ChatWindow.Settings.Version = EA_ChatWindow.BaseVersion

        EA_ChatWindow.Settings.WindowGroups = ChatSettings.GetDefaultWindowGroupsTable()
    end
end

-- OnShutdown Handler
function EA_ChatWindow.Shutdown()
    
    EA_ChatWindow.SaveSettings()
    
    -- Retrieve the history (this preserves it across logging in/out)
    GameData.ChatData.history = TextEditBoxGetHistory("EA_TextEntryGroupEntryBoxTextInput")
end

function EA_ChatWindow.OnSettingsChanged()
   -- Mark the Settings as dirty for update once per frame
   EA_ChatWindow.settingsDirty = true
end

function EA_ChatWindow.SaveSettings()

    if( EA_ChatWindow.settingsDirty == false )
    then
        return -- Do nothing if the settings have not changed.
    end
    
    -- clear the dirty flag
    EA_ChatWindow.settingsDirty = false

    EA_ChatWindow.Settings.Version = EA_ChatWindow.CurrentVersion
    
    -- clear old settings
    EA_ChatWindow.Settings.WindowGroups = {}
    
    local index = 1
    for _, wndGroup in ipairs(EA_ChatWindowGroups) 
    do
        if( wndGroup.used == false )
        then
            continue
        end
        EA_ChatWindow.Settings.WindowGroups[index] = {}

        -- Window Position - Convert the Window Pos into general parameters for the screen
        -- based on the window's scale.
        local screenX, screenY = GetScreenResolution()
        local posX, posY = WindowGetScreenPosition( wndGroup.name )
        local scale = WindowGetScale( wndGroup.name )
        -- width and height
        local width, height = WindowGetDimensions( wndGroup.name )

        EA_ChatWindow.Settings.WindowGroups[index].windowDims = {}
        EA_ChatWindow.Settings.WindowGroups[index].windowDims.x = posX / screenX / scale
        EA_ChatWindow.Settings.WindowGroups[index].windowDims.y = posY / screenY / scale
        EA_ChatWindow.Settings.WindowGroups[index].windowDims.width = width
        EA_ChatWindow.Settings.WindowGroups[index].windowDims.height = height
        EA_ChatWindow.Settings.WindowGroups[index].windowDims.scale = 1.0

        EA_ChatWindow.Settings.WindowGroups[index].activeTab = wndGroup.activeTab
        EA_ChatWindow.Settings.WindowGroups[index].scrollOffset = wndGroup.scrollOffset
        EA_ChatWindow.Settings.WindowGroups[index].canAutoHide = wndGroup.canAutoHide
        EA_ChatWindow.Settings.WindowGroups[index].maxAlpha = wndGroup.maxAlpha
        EA_ChatWindow.Settings.WindowGroups[index].movable = WindowGetMovable( wndGroup.name )

        EA_ChatWindow.Settings.WindowGroups[index].Tabs = {}
        
        for tabId, tab in ipairs(wndGroup.Tabs) 
        do          
            EA_ChatWindow.Settings.WindowGroups[index].Tabs[tabId] = {}
            EA_ChatWindow.Settings.WindowGroups[index].Tabs[tabId].tabText = tab.tabText
            EA_ChatWindow.Settings.WindowGroups[index].Tabs[tabId].defaultLog = tab.defaultLog
            EA_ChatWindow.Settings.WindowGroups[index].Tabs[tabId].font = tab.font
            EA_ChatWindow.Settings.WindowGroups[index].Tabs[tabId].showTimestamp = tab.showTimestamp
            EA_ChatWindow.Settings.WindowGroups[index].Tabs[tabId].flashOnActivity = tab.flashOnActivity

            EA_ChatWindow.Settings.WindowGroups[index].Tabs[tabId].Filters = {}
            
            local tabName = EA_ChatTabManager.GetTabName( tab.tabManagerId )
            if( tabName == nil )
            then 
                continue
            end
            
            for channelId, channelData in pairs( ChatSettings.Channels ) 
            do
                local enabled = LogDisplayGetFilterState( tabName.."TextLog", channelData.logName, channelId )
                EA_ChatWindow.Settings.WindowGroups[index].Tabs[tabId].Filters[ channelId ] = enabled
            end
        end 
        
        index = index + 1      
    end
end


function EA_ChatWindow.WindowGroupSetDims( wndGroupId, x, y, width, height, scale, movable )

    if ( EA_ChatWindowGroups == nil or EA_ChatWindowGroups[wndGroupId] == nil )
    then
        return
    end
    
    local wndGroupName = EA_ChatWindowGroups[wndGroupId].name
    WindowSetDimensions( wndGroupName, width, height )
    WindowSetOffsetFromParent(wndGroupName, x, y )

    
    WindowSetMovable( wndGroupName, movable )
    WindowSetShowing( wndGroupName.."ResizeButton", movable )

    WindowForceProcessAnchors( wndGroupName)

    EA_ChatWindow.UpdateTabScrollWindow(wndGroupId)

end

function EA_ChatWindow.CreateWindowGroup( wndGroupId )
    
    EA_ChatWindowGroups[wndGroupId].used = true
    EA_ChatWindowGroups[wndGroupId].name = "EA_ChatWindowGroup"..wndGroupId
    EA_ChatWindowGroups[wndGroupId].fadedIn = false
    EA_ChatWindowGroups[wndGroupId].fadeOutStarted = true
    EA_ChatWindowGroups[wndGroupId].fadeOutTimer = 0.0
    
    EA_ChatWindow.createWndGroupId = wndGroupId
    CreateWindowFromTemplate( EA_ChatWindowGroups[wndGroupId].name, "EA_ChatWindowGroup", "Root")
    
end

function EA_ChatWindow.DestroyWindowGroup( wndGroupId )
    
    DestroyWindow( EA_ChatWindowGroups[wndGroupId].name )
    EA_ChatWindowGroups[wndGroupId] = {}
    EA_ChatWindowGroups[wndGroupId].used = false
    
end

function EA_ChatWindow.AddTabToWindowGroup( wndGroupId, tabId )
    
    local wndGroupName = EA_ChatWindowGroups[wndGroupId].name
    local tabWindowName = wndGroupName.."TabWindow"

    local tab = EA_ChatWindowGroups[wndGroupId].Tabs[tabId]
            
    local tabManagerId, tabName = EA_ChatTabManager.CreateTab( tabWindowName.."ScrollChild", wndGroupId )
    
    if ( tabManagerId < 1 ) -- no more free tabs
    then
        return
    end
    
    tab.tabManagerId = tabManagerId

    local tabLogDisplayName = tabName.."TextLog"

    -- anchor the text log display
    WindowClearAnchors( tabLogDisplayName )
    WindowAddAnchor( tabLogDisplayName, "topleft", wndGroupName.."Foreground", "topleft", 0, 0 )
    WindowAddAnchor( tabLogDisplayName, "bottomright", wndGroupName.."Foreground", "bottomright", -5, 0 )

    for channelId, channelData in pairs( ChatSettings.Channels ) 
    do
        local enabled = false
        if ( tab.Filters ~= nil and tab.Filters[ channelId ] ~= nil ) then
            enabled = tab.Filters[ channelId ]
        end
        LogDisplaySetFilterState( tabLogDisplayName, channelData.logName, channelData.id, enabled )
                
        local color = ChatSettings.ChannelColors[ channelId ]
        LogDisplaySetFilterColor( tabLogDisplayName, channelData.logName, channelData.id, color.r, color.g, color.b )
    end

    -- set the font
    LogDisplaySetFont( tabLogDisplayName, tab.font )
    
    -- set the timestamp state
    LogDisplaySetShowTimestamp( tabLogDisplayName, tab.showTimestamp )
    
    ButtonSetText( tabName.."Button", tab.tabText )
    
    local tabButtonWidth, tabButtonHeight = WindowGetDimensions( tabName.."Button" )        
    WindowSetDimensions( tabName, tabButtonWidth, tabButtonHeight)
    
    if (tabId == 1)
    then        
        -- first tab goes on the left
        WindowSetOffsetFromParent( tabName, 0, 0 )
    else 
        -- every other tab gets anchored to previous tab
        local prevTabName = EA_ChatTabManager.GetTabName( EA_ChatWindowGroups[wndGroupId].Tabs[tabId-1].tabManagerId )
        WindowClearAnchors( tabName )
        WindowAddAnchor( tabName, "bottomright", prevTabName, "bottomleft", 0, 0 )
        WindowSetShowing(tabLogDisplayName, false)
    end
                
    -- update total tab width
    EA_ChatWindowGroups[wndGroupId].tabTotalWidth = EA_ChatWindowGroups[wndGroupId].tabTotalWidth + tabButtonWidth    
    
    EA_ChatWindow.SetToTab( tabManagerId )
    
end

function EA_ChatWindow.AddTabsToWindowGroup( wndGroupId )
    
    local wndGroupName = EA_ChatWindowGroups[wndGroupId].name
    local tabWindowName = wndGroupName.."TabWindow"

    local tabWindowWidth, _ = WindowGetDimensions( tabWindowName )     
        
    local alpha = EA_ChatWindowGroups[wndGroupId].maxAlpha
    
    local totalTabWidth = 0
    -- generate the tabs
    for k, tab in ipairs(EA_ChatWindowGroups[wndGroupId].Tabs)
    do
        local tabManagerId, tabName = EA_ChatTabManager.CreateTab( tabWindowName.."ScrollChild", wndGroupId )
        
        if ( tabManagerId < 1 ) -- no more free tabs
        then
            break
        end
        
        tab.tabManagerId = tabManagerId

        local tabLogDisplayName = tabName.."TextLog"

        -- anchor the text log display
        WindowClearAnchors( tabLogDisplayName )
        WindowAddAnchor( tabLogDisplayName, "topleft", wndGroupName.."Foreground", "topleft", 0, 0 )
        WindowAddAnchor( tabLogDisplayName, "bottomright", wndGroupName.."Foreground", "bottomright", -5, 0 )

        for channelId, channelData in pairs( ChatSettings.Channels ) 
        do
            local enabled = false
            if ( tab.Filters ~= nil and tab.Filters[ channelId ] ~= nil ) then
                enabled = tab.Filters[ channelId ]
            end
            LogDisplaySetFilterState( tabLogDisplayName, channelData.logName, channelData.id, enabled )
                    
            local color = ChatSettings.ChannelColors[ channelId ]
            LogDisplaySetFilterColor( tabLogDisplayName, channelData.logName, channelData.id, color.r, color.g, color.b )
        end

        -- set the font
        LogDisplaySetFont( tabLogDisplayName, tab.font )
        
        -- set the timestamp state
        LogDisplaySetShowTimestamp( tabLogDisplayName, tab.showTimestamp )
        
        ButtonSetText( tabName.."Button", tab.tabText )
        
        local tabButtonWidth, tabButtonHeight = WindowGetDimensions( tabName.."Button" )        
        WindowSetDimensions( tabName, tabButtonWidth, tabButtonHeight)  
        
        if (k == 1)
        then        
            -- first tab goes on the left
            WindowSetOffsetFromParent( tabName, 0, 0 )
        else 
            -- every other tab gets anchored to previous tab
            local prevTabName = EA_ChatTabManager.GetTabName( EA_ChatWindowGroups[wndGroupId].Tabs[k-1].tabManagerId )
            WindowAddAnchor( tabName, "bottomright", prevTabName, "bottomleft", 0, 0 )
            WindowSetShowing(tabLogDisplayName, false)     
        end
        
        if (k == EA_ChatWindowGroups[wndGroupId].activeTab)
        then
            WindowSetFontAlpha( tabName.."Button", 1.0 )
            WindowSetAlpha( tabName.."Background", alpha )
            WindowSetShowing( tabName.."TextLog", true)
            ButtonSetPressedFlag( tabName.."Button", true)
        else
            WindowSetFontAlpha( tabName.."Button", 0.5 )
            WindowSetAlpha( tabName.."Background", alpha/2.0 )
            WindowSetShowing( tabName.."TextLog", false)
            ButtonSetPressedFlag( tabName.."Button", false)   
        end
        
        -- accumulate total tab width
        totalTabWidth = totalTabWidth + tabButtonWidth
    end
    
    EA_ChatWindowGroups[wndGroupId].tabTotalWidth = totalTabWidth

    -- enable the cycle button if necessary
    if ( totalTabWidth > tabWindowWidth)
    then
        ButtonSetDisabledFlag( wndGroupName.."CycleRightButton", false )
    end
    
end

function EA_ChatWindow.WindowGroupInitialize()

    local wndGroupId = EA_ChatWindow.createWndGroupId
    local wndGroupName = EA_ChatWindowGroups[wndGroupId].name
    WindowSetId(wndGroupName, wndGroupId)

    -- Tab cycling buttons
    ButtonSetDisabledFlag( wndGroupName.."CycleLeftButton", true )
    ButtonSetDisabledFlag( wndGroupName.."CycleRightButton", true )
    WindowSetId(wndGroupName.."CycleLeftButton", wndGroupId)
    WindowSetId(wndGroupName.."CycleRightButton", wndGroupId)
    EA_ChatWindow.ShowTabCycleButtons(wndGroupName, false)
    
    local BGAnchorName = wndGroupName
    local BGpoint = "bottomleft"    
    
    -- create the social button and the text entry group on first window group
    if( wndGroupId == 1 ) 
    then
    
        -- This container window sits outside the bounds of the window group, so it will not get input.
        -- The social button is a sibling window (ie. also a child of root) and is anchored to this container.
        -- Doing it this way allows the Social button to be scaled when the window group is scaled
        CreateWindowFromTemplate (wndGroupName.."SocialButtonAnchor", "EA_ChatWindowSocialButtonAnchor", wndGroupName)
    
        -- create the social button as a sibling to the chat window (ie. also a child of Root)
        CreateWindowFromTemplate ("ChatWindowSocialWindowButton", "EA_SocialWindowButton", "Root")
        WindowClearAnchors( "ChatWindowSocialWindowButton")
        WindowAddAnchor( "ChatWindowSocialWindowButton", "topleft", wndGroupName.."SocialButtonAnchor", "topleft", 0, 0 )    
        WindowAddAnchor( "ChatWindowSocialWindowButton", "bottomright", wndGroupName.."SocialButtonAnchor", "bottomright", 0, 0 )    
        WindowRegisterEventHandler( "ChatWindowSocialWindowButton", SystemData.Events.PLAYER_INFO_CHANGED,    "EA_ChatWindow.UpdateSocialWindowButton")
        EA_ChatWindow.UpdateSocialWindowButton()
        
        -- create the text entry group
        CreateWindowFromTemplate( "EA_TextEntryGroup", "EA_TextEntryGroup", wndGroupName )
        WindowSetAlpha( "EA_TextEntryGroup", 0.8 )
        WindowSetShowing( "EA_TextEntryGroupEntryBox", false )
        WindowClearAnchors( "EA_TextEntryGroup" )
        WindowAddAnchor( "EA_TextEntryGroup", "bottomleft", wndGroupName, "bottomleft", 0, 0 )
        WindowAddAnchor( "EA_TextEntryGroup", "bottomright", wndGroupName, "bottomright", 0, 0 )
        WindowRegisterEventHandler( "EA_TextEntryGroup", SystemData.Events.BEGIN_ENTER_CHAT, "EA_ChatWindow.OnEnterChatText")
        WindowRegisterEventHandler( "EA_TextEntryGroup", SystemData.Events.CHAT_REPLY,       "EA_ChatWindow.OnReply")
        -- Since there is only 1 text entry group, the following handlers are registered here to handle various events.
        -- If they were registered on the window group, they would get registered for each instance of the window group.
        -- They only need to be registered once.
        WindowRegisterEventHandler( "EA_TextEntryGroup", SystemData.Events.USER_SETTINGS_CHANGED,  "EA_ChatWindow.UpdateChatSettings" )
        WindowRegisterEventHandler( "EA_TextEntryGroup", SystemData.Events.L_BUTTON_DOWN_PROCESSED, "EA_ChatWindow.OnLButtonDownProcessed")
        WindowRegisterEventHandler( "EA_TextEntryGroup", SystemData.Events.R_BUTTON_DOWN_PROCESSED, "EA_ChatWindow.OnRButtonDownProcessed")
        WindowRegisterEventHandler( "EA_TextEntryGroup", SystemData.Events.L_BUTTON_UP_PROCESSED, "EA_ChatWindow.OnLButtonUpProcessed")
        WindowRegisterEventHandler( "EA_TextEntryGroup", SystemData.Events.CHANNEL_NAMES_UPDATED, "ChatSettings.UpdateChannelNames" )
        
        -- create the chat window game rating text window
        EA_ChatWindow.InitGameRatingWindow( wndGroupName )

        -- initialize our channels
        EA_ChatWindow.SwitchToChatChannel (SystemData.ChatLogFilters.SAY, ChatSettings.Channels[SystemData.ChatLogFilters.SAY].labelText, L"")
        EA_ChatWindow.UpdateCurrentChannel(SystemData.ChatLogFilters.SAY)

        BGAnchorName = "EA_TextEntryGroup"
        BGpoint = "topleft"
    end
    
    WindowAddAnchor( wndGroupName.."Foreground", "bottomright", wndGroupName.."CycleRightButton", "topright", 0, 0 )
    WindowAddAnchor( wndGroupName.."Foreground", BGpoint, BGAnchorName, "bottomleft", 0, 0 )
    
    WindowAddAnchor( wndGroupName.."Background", "bottomleft", wndGroupName.."Foreground", "bottomleft", 0, 0 )
    WindowAddAnchor( wndGroupName.."Background", "bottomright", wndGroupName.."Foreground", "bottomright", 0, 0 )

    WindowSetAlpha( wndGroupName.."Foreground", EA_ChatWindowGroups[wndGroupId].maxAlpha )
    
    WindowSetId(wndGroupName.."ResizeButton", wndGroupId)
    
    local tabInsertMarkerName = wndGroupName.."TabWindowScrollChildTabInsert"
    WindowSetShowing(tabInsertMarkerName, false)
    
    LayoutEditor.RegisterWindow( wndGroupName,
                                 GetStringFormatFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_CHAT_WINDOW_X_NAME, { towstring(wndGroupId) } ),
                                 GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_CHAT_WINDOW_X_DESC ),
                                 true,
                                 true,
                                 true,
                                 nil,
                                 nil,
                                 true,
                                 { x = WINDOW_MIN_WIDTH, y = WINDOW_MIN_HEIGHT },
                                 function() EA_ChatWindow.OnResizeEndHelper( wndGroupId ) end,
                                 EA_ChatWindow.OnSettingsChanged )
end

function EA_ChatWindow.WindowGroupInitializeCustomSettings()
    if ( not initialCreateChatWindowGroups ) -- This is only intended to be called if the Layout Editor is used
    then
        local wndGroupId = WindowGetId( SystemData.ActiveWindow.name )
        local defaultWindowGroup = ChatSettings.GetDefaultWindowGroupsTable()[wndGroupId]
        if ( defaultWindowGroup ~= nil )
        then
            local savedWndGroup = EA_ChatWindow.Settings.WindowGroups[ wndGroupId ]
            if ( savedWndGroup ~= nil )
            then
                -- Restore relevant position/size settings from defaults
                savedWndGroup.windowDims.x = defaultWindowGroup.windowDims.x
                savedWndGroup.windowDims.y = defaultWindowGroup.windowDims.y
                savedWndGroup.windowDims.width = defaultWindowGroup.windowDims.width
                savedWndGroup.windowDims.height = defaultWindowGroup.windowDims.height
                savedWndGroup.windowDims.scale = defaultWindowGroup.windowDims.scale
            end
        end
        EA_ChatWindow.RepositionWindowGroup( wndGroupId )
    end
end

function EA_ChatWindow.WindowGroupShutdown()
    LayoutEditor.UnregisterWindow( SystemData.ActiveWindow.name )
end

function EA_ChatWindow.OnWindowGroupShown()
    local wndGroupId = WindowGetId( SystemData.ActiveWindow.name )
    if ( wndGroupId == 1 )
    then
        -- The Social Button is anchored to the first group but is not a child of it, therefore
        -- the button does not get shown when the window group is shown. So we must do it manually.
        WindowSetShowing( "ChatWindowSocialWindowButton", true )
    end
end

function EA_ChatWindow.OnWindowGroupHidden()
    local wndGroupId = WindowGetId( SystemData.ActiveWindow.name )
    if ( wndGroupId == 1 )
    then
        -- The Social Button is anchored to the first group but is not a child of it, therefore
        -- the button does not get hidden when the window group is hidden. So we must do it manually.
        WindowSetShowing( "ChatWindowSocialWindowButton", false )
    end
end

-- move the tabs left
function EA_ChatWindow.CycleTabLeft()

    if  ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) == true
    then
        return
    end
    
    local wndGroupId = WindowGetId(SystemData.ActiveWindow.name)
    -- validate wndGroupId
    if (wndGroupId < 1 or wndGroupId > #EA_ChatWindowGroups )
    then
        return
    end
    
    local wndGroupName = EA_ChatWindowGroups[wndGroupId].name
    EA_ChatWindowGroups[wndGroupId].scrollOffset = EA_ChatWindowGroups[wndGroupId].scrollOffset - 20
    
    if ( EA_ChatWindowGroups[wndGroupId].scrollOffset <= 0 )
    then
        EA_ChatWindowGroups[wndGroupId].scrollOffset = 0
        local cycleLeftButton = wndGroupName.."CycleLeftButton"
        ButtonSetDisabledFlag(cycleLeftButton, true)
    end
    
    local tabName = EA_ChatTabManager.GetTabName( EA_ChatWindowGroups[wndGroupId].Tabs[1].tabManagerId )
    if( tabName ~= nil )
    then 
        WindowSetOffsetFromParent( tabName, -EA_ChatWindowGroups[wndGroupId].scrollOffset, 0 )
 
        local cycleRightButton = wndGroupName.."CycleRightButton"
        ButtonSetDisabledFlag(cycleRightButton, false)
    end    
   
end

-- move the tabs right
function EA_ChatWindow.CycleTabRight()
    
    if  ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) == true
    then
        return
    end
    
    local wndGroupId = WindowGetId(SystemData.ActiveWindow.name)
    -- validate wndGroupId
    if (wndGroupId < 1 or wndGroupId > #EA_ChatWindowGroups )
    then
        return
    end
    
    local wndGroupName = EA_ChatWindowGroups[wndGroupId].name
    EA_ChatWindowGroups[wndGroupId].scrollOffset = EA_ChatWindowGroups[wndGroupId].scrollOffset + 20
    local tabWindowWidth, _ = WindowGetDimensions( wndGroupName.."TabWindow" )        
    local totalTabWidth = EA_ChatWindowGroups[wndGroupId].tabTotalWidth

    if ( EA_ChatWindowGroups[wndGroupId].scrollOffset >= totalTabWidth - tabWindowWidth )
    then
        EA_ChatWindowGroups[wndGroupId].scrollOffset = totalTabWidth - tabWindowWidth
        local cycleRightButton = wndGroupName.."CycleRightButton"
        ButtonSetDisabledFlag(cycleRightButton, true)
    end

    local tabName = EA_ChatTabManager.GetTabName( EA_ChatWindowGroups[wndGroupId].Tabs[1].tabManagerId )
    if( tabName ~= nil )
    then 
        WindowSetOffsetFromParent( tabName, -EA_ChatWindowGroups[wndGroupId].scrollOffset, 0 )
 
        local cycleLeftButton = wndGroupName.."CycleLeftButton"
        ButtonSetDisabledFlag(cycleLeftButton, false)
    end
    
end

function EA_ChatWindow.ScrollToBottom()

    local wndName = SystemData.ActiveWindow.name
    
    local tabId = EA_ChatWindow.GetTabIdFromWindowName(wndName)

    if( tabId >= 1 )
    then  
        local logDisplayName = EA_ChatTabManager.Tabs[ tabId ].name.."TextLog"
        LogDisplayScrollToBottom( logDisplayName )
    end

end


function EA_ChatWindow.UpdateChatSettings()

    -- Set the fade settings
    local visibleTime = 300
    if( SystemData.Settings.Chat.fadeText ) 
    then
        visibleTime = SystemData.Settings.Chat.visibleTime
    end
    
    for _, tab in pairs(EA_ChatTabManager.Tabs)
    do
        if( tab.used )
        then
            local tabLogDisplayName = tab.name.."TextLog"
            LogDisplaySetTextFadeTime( tabLogDisplayName, visibleTime )
            
            LogDisplaySetEntryLimit( tabLogDisplayName, SystemData.Settings.Chat.scrollLimit )
        end
    end
end

function EA_ChatWindow.Print(text, channelId)    
    local validId = ChatSettings.Channels[SystemData.ChatLogFilters.SAY].id
    local logName = "Chat"

    if (channelId and ChatSettings.Channels[channelId] ~= nil) 
    then
        validId = ChatSettings.Channels[channelId].id
        logName = ChatSettings.Channels[channelId].logName;
    end

    TextLogAddEntry (logName, validId, text)
end


function EA_ChatWindow.OnResizeBegin( flags, x, y )                                                                          
    
    local wndGroupId = WindowGetId(SystemData.ActiveWindow.name)
    -- validate wndGroupId
    if (wndGroupId < 1 or wndGroupId > #EA_ChatWindowGroups )
    then
        return
    end
    
    EA_ChatWindow.resizeWndGroupId = wndGroupId
    
    EA_ChatWindow.isResizing = true
    
    WindowUtils.BeginResize( EA_ChatWindowGroups[wndGroupId].name, "bottomleft", WINDOW_MIN_WIDTH, WINDOW_MIN_HEIGHT, EA_ChatWindow.OnResizeEnd )
    
end

function EA_ChatWindow.OnResizeEndHelper( wndGroupId )

    -- validate groupID
    if ( wndGroupId < 1 or wndGroupId > #EA_ChatWindowGroups )
    then
        return
    end

    local wndGroupName = EA_ChatWindowGroups[wndGroupId].name
    WindowForceProcessAnchors( wndGroupName)

    EA_ChatWindow.UpdateTabScrollWindow(wndGroupId)

    EA_ChatWindow.isResizing = false

    EA_ChatWindow.resizeWndGroupId = 0
    
    EA_ChatWindow.OnSettingsChanged()
end

function EA_ChatWindow.OnResizeEnd()
    EA_ChatWindow.OnResizeEndHelper( EA_ChatWindow.resizeWndGroupId )
end

function EA_ChatWindow.ShowTabCycleButtons(wndGroupName, show)

    local wasCycleLeftButtonShowing = WindowGetShowing( wndGroupName.."CycleLeftButton")
    
    WindowSetShowing( wndGroupName.."CycleLeftButton", show )
    WindowSetShowing( wndGroupName.."CycleRightButton", show )
    
    if( show and not wasCycleLeftButtonShowing )
    then
        WindowStartAlphaAnimation ( wndGroupName.."CycleRightButton", Window.AnimationType.SINGLE_NO_RESET, 0, 1, 0.25, false, 0, 0 )
        WindowStartAlphaAnimation ( wndGroupName.."CycleLeftButton", Window.AnimationType.SINGLE_NO_RESET, 0, 1, 0.25, false, 0, 0 )
    end

end

function EA_ChatWindow.UpdateTabScrollWindow(wndGroupId)

    local wndGroupName = EA_ChatWindowGroups[wndGroupId].name

    local tabWindowName = wndGroupName.."TabWindow"   
    local tabWindowWidth, _ = WindowGetDimensions( tabWindowName )        
    local totalTabWidth = EA_ChatWindowGroups[wndGroupId].tabTotalWidth
    local currScrollOffset = EA_ChatWindowGroups[wndGroupId].scrollOffset
    local newScrollOffset = 0

    -- this is magic to keep the right most tab against the right
    if ( tabWindowWidth < totalTabWidth ) 
    then
        newScrollOffset = totalTabWidth - tabWindowWidth

        if( newScrollOffset < currScrollOffset )
        then
            if ( newScrollOffset < 0 )
            then
                newScrollOffset = 0
                ButtonSetDisabledFlag( wndGroupName.."CycleLeftButton", true )
            end
            EA_ChatWindowGroups[wndGroupId].scrollOffset = newScrollOffset
            
            local tabName = EA_ChatTabManager.GetTabName( EA_ChatWindowGroups[wndGroupId].Tabs[1].tabManagerId )
            if( tabName ~= nil )
            then 
                WindowSetOffsetFromParent( tabName, -newScrollOffset, 0 )
            end
        end
        
        EA_ChatWindow.ShowTabCycleButtons(wndGroupName, true)
        
    else
        local tabName = EA_ChatTabManager.GetTabName( EA_ChatWindowGroups[wndGroupId].Tabs[1].tabManagerId )
        if( tabName ~= nil )
        then 
            WindowSetOffsetFromParent( tabName, 0, 0 )
        end
        EA_ChatWindowGroups[wndGroupId].scrollOffset = 0
        ButtonSetDisabledFlag( wndGroupName.."CycleLeftButton", true )
        
        EA_ChatWindow.ShowTabCycleButtons(wndGroupName, false)

    end
     
    -- enable the cycle button if necessary
    if ( EA_ChatWindowGroups[wndGroupId].tabTotalWidth - EA_ChatWindowGroups[wndGroupId].scrollOffset > tabWindowWidth)
    then
        ButtonSetDisabledFlag( wndGroupName.."CycleRightButton", false )
    else
        ButtonSetDisabledFlag( wndGroupName.."CycleRightButton", true )
    end
end

function EA_ChatWindow.OnWindowGroupRButtonUp()

    local wndGroupId = WindowGetId(SystemData.ActiveWindow.name)
    -- validate wndGroupId
    if (wndGroupId < 1 or wndGroupId > #EA_ChatWindowGroups )
    then
        return
    end
    
    -- spawn the default context menu
    local wndGroupName = EA_ChatWindowGroups[wndGroupId].name
    EA_ChatWindow.CreateDefaultContextMenu( SystemData.ActiveWindow.name, wndGroupId )
end

function EA_ChatWindow.GetTabIdFromWindowName(tabButtonName)

    local tabId = WindowGetId(tabButtonName)

    -- validate tabID
    if (tabId < 1 or tabId > #EA_ChatTabManager.Tabs or EA_ChatTabManager.Tabs[tabId].used == false )
    then
        return -1
    end
    
    return tabId
end

function EA_ChatWindow.SetToTab(tabId)

    -- if tabID is invalid
    if (tabId < 1 )
    then
        return
    end

    EA_ChatWindow.HideMenu()

    -- get the window group that this tab is a member of
    local wndGroupId = EA_ChatTabManager.Tabs[tabId].wndGroupId
    
    local wndGroupTabIndex = EA_ChatWindowGroups[wndGroupId].activeTab

    -- get the alpha value for the background
    local alpha = EA_ChatWindowGroups[wndGroupId].maxAlpha
    
    for k, tab in ipairs( EA_ChatWindowGroups[wndGroupId].Tabs )
    do

        local tabName = EA_ChatTabManager.GetTabName( tab.tabManagerId )
        if( tabName == nil )
        then 
            continue
        end

        local selectedTab = false

        -- Disable flashing state for the newly selected tab, and set active state
        if( tab.tabManagerId == tabId )
        then
            tab.flashing = false
            EA_ChatWindowGroups[wndGroupId].activeTab = k
            
            selectedTab = true
        end
        
        -- Don't stop alpha anims if we're currently flashing
        if( not tab.flashing )
        then
            WindowStopAlphaAnimation( tabName.."Background" )
            WindowStopAlphaAnimation( tabName.."Button" )
        end

        if( selectedTab )
        then
            WindowSetFontAlpha( tabName.."Button", 1.0 )
            WindowSetAlpha( tabName.."Background", alpha )
            WindowSetShowing( tabName.."TextLog", true)
            ButtonSetPressedFlag( tabName.."Button", true)
        else
            WindowSetFontAlpha( tabName.."Button", 0.5 )
            WindowSetAlpha( tabName.."Background", alpha/2.0 )
            WindowSetShowing( tabName.."TextLog", false)
            ButtonSetPressedFlag( tabName.."Button", false)
        end
    end
    
    EA_ChatWindow.OnSettingsChanged()
end

function EA_ChatWindow.OnTabRButtonUp()
    
    local tabButtonName = SystemData.ActiveWindow.name
    
    local tabId = EA_ChatWindow.GetTabIdFromWindowName(tabButtonName)

    EA_ChatWindow.SetToTab(tabId)

    if( tabId >= 1 )
    then  
        -- spawn the context menu
        EA_ChatTabManager.activeTabId = tabId
        EA_ChatWindow.OnOpenChatMenu()
    else
        EA_ChatTabManager.activeTabId = -1
    end

end

function EA_ChatWindow.OnLanguageToggled()
    --DEBUG(L"Language String is "..languageStateStr)
    local showLanguageButton = false
    if ( SystemData.Settings.Language.active >= 6 ) -- Asian Languages are enum'd in Warinterface.h
    then     
        showLanguageButton = true
    end
    
    -- show or hide the language button and do some re-anchoring
    -- Note: we cannot compare against the WindowGetShowing state of the language button, because
    -- if the whole text entry group is hidden, it always returns false since it is a child
    if ( showLanguageButton ~= EA_ChatWindow.showLanguageButton )
    then
        
        WindowClearAnchors( "EA_TextEntryGroupEntryBoxTextInput" )
        WindowClearAnchors( "EA_TextEntryGroupEntryBoxBG" )
        if ( showLanguageButton == true )
        then
            WindowAddAnchor( "EA_TextEntryGroupEntryBoxTextInput", "topright", "EA_TextEntryGroupEntryBoxChannelLabel", "topleft", 2, -5 )    
            WindowAddAnchor( "EA_TextEntryGroupEntryBoxTextInput", "bottomright", "EA_TextEntryGroupEntryBox", "bottomright", -42, 2 )    
            WindowAddAnchor( "EA_TextEntryGroupEntryBoxBG", "topleft", "EA_TextEntryGroupEntryBox", "topleft", 0, 0 )    
            WindowAddAnchor( "EA_TextEntryGroupEntryBoxBG", "bottomright", "EA_TextEntryGroupEntryBox", "bottomright", -38, 0 )    
        else
            WindowAddAnchor( "EA_TextEntryGroupEntryBoxTextInput", "topright", "EA_TextEntryGroupEntryBoxChannelLabel", "topleft", 2, -5 )    
            WindowAddAnchor( "EA_TextEntryGroupEntryBoxTextInput", "bottomright", "EA_TextEntryGroupEntryBox", "bottomright", -4, 2 )    
            WindowAddAnchor( "EA_TextEntryGroupEntryBoxBG", "topleft", "EA_TextEntryGroupEntryBox", "topleft", 0, 0 )    
            WindowAddAnchor( "EA_TextEntryGroupEntryBoxBG", "bottomright", "EA_TextEntryGroupEntryBox", "bottomright", 0, 0 )    
        end
        
        -- update the show state of the window
        WindowSetShowing("EA_TextEntryGroupEntryBoxLanguageButton", showLanguageButton)
        -- cache the show state of the button
        EA_ChatWindow.showLanguageButton = showLanguageButton;
    end
    
    -- update the language button text
    if ( showLanguageButton )
    then
        local languageStateStr = GetInputLanguageString()
        
        ButtonSetText("EA_TextEntryGroupEntryBoxLanguageButton", towstring(languageStateStr))
    end

end

function EA_ChatWindow.ToggleInputLanguage()
    ToggleLanguageState()   -- Call the registered C function that "presses" and "releases" the "Shift+Alt" keys.
    EA_ChatWindow.OnLanguageToggled()
    EA_ChatWindow.SwitchChannelWithExistingText (EA_TextEntryGroupEntryBoxTextInput.Text);
end

function EA_ChatWindow.OnViewChatOptions()
    WindowSetShowing( "ChatOptionsWindow", true)
    EA_ChatWindow.HideMenu()
end

function EA_ChatWindow.OnViewChatFilters()
    WindowSetShowing( "ChatFiltersWindow", true)
    EA_ChatWindow.HideMenu()
end 

-- The main purpose of this is to close the channel select menu and set a flag to let us
-- know that the context menu is no longer showing. The channel select menu should
-- probably be converted to use EA_ContextMenu.  
function EA_ChatWindow.HideMenu()
    EA_ChatWindow.HideChannelSelectionMenu()
    
    EA_ChatWindow.isContextMenuShowing = false
end

function EA_ChatWindow.StartFadeIn(wndGroupId)

    -- validate wndGroupId
    if (wndGroupId < 1 or wndGroupId > #EA_ChatWindowGroups )
    then
        return
    end 
    
    if( EA_ChatWindowGroups[wndGroupId].fadedIn == false )
    then
        EA_ChatWindow.StartAlphaAnimation( wndGroupId, true )
        EA_ChatWindowGroups[wndGroupId].fadedIn = true
    end
    
    EA_ChatWindowGroups[wndGroupId].fadeOutStarted = false    
    EA_ChatWindowGroups[wndGroupId].fadeOutTimer = FADE_OUT_DELAY

end

function EA_ChatWindow.StartFadeOut(wndGroupId)
    
    -- validate wndGroupId
    if (wndGroupId < 1 or wndGroupId > #EA_ChatWindowGroups )
    then
        return
    end 

    EA_ChatWindowGroups[wndGroupId].fadeOutStarted = true
    EA_ChatWindowGroups[wndGroupId].fadeOutTimer = FADE_OUT_DELAY

end

function EA_ChatWindow.StartAlphaAnimation( wndGroupId, forward )

    local wndName = EA_ChatWindowGroups[wndGroupId].name
    
    local maxAlpha = EA_ChatWindowGroups[wndGroupId].maxAlpha
    local startAlpha = 0.0
    local endAlpha = 1.0
    local startAlphaHalf = 0.0
    local endAlphaHalf = 0.5
    local startAlphaMax = 0.0
    local endAlphaMax = maxAlpha
    local startAlphaHalfMax = 0.0
    local endAlphaHalfMax = maxAlpha/2.0
    local duration = FADE_TIME
    
    if( forward == false )
    then
        startAlpha = 1.0
        endAlpha = 0.0
        startAlphaHalf = 0.5
        endAlphaHalf = 0.0
        startAlphaMax = maxAlpha
        endAlphaMax = 0.0
        startAlphaHalfMax = maxAlpha/2.0
        endAlphaHalfMax = 0.0
        duration = FADE_TIME*2
    end
    
    for k, tab in ipairs( EA_ChatWindowGroups[wndGroupId].Tabs )
    do
        local tabName = EA_ChatTabManager.GetTabName( tab.tabManagerId )
        if( tabName == nil )
        then 
            continue
        end

        if( not tab.flashing ) -- don't fade tabs if a notification flash is running
        then
            if (k == EA_ChatWindowGroups[wndGroupId].activeTab )
            then
                WindowStartAlphaAnimation ( tabName.."Background", Window.AnimationType.SINGLE_NO_RESET, startAlphaMax, endAlphaMax, duration, false, 0, 0 )
                WindowStartAlphaAnimation ( tabName.."Button", Window.AnimationType.SINGLE_NO_RESET, startAlpha, endAlpha, duration, false, 0, 0 )
            else
                WindowStartAlphaAnimation ( tabName.."Background", Window.AnimationType.SINGLE_NO_RESET, startAlphaHalfMax, endAlphaHalfMax, duration, false, 0, 0 )
                WindowStartAlphaAnimation ( tabName.."Button", Window.AnimationType.SINGLE_NO_RESET, startAlphaHalf, endAlphaHalf, duration, false, 0, 0 )
            end
        end
    end
    WindowStartAlphaAnimation ( wndName.."CycleRightButton", Window.AnimationType.SINGLE_NO_RESET, startAlpha, endAlpha, duration, false, 0, 0 )
    WindowStartAlphaAnimation ( wndName.."CycleLeftButton", Window.AnimationType.SINGLE_NO_RESET, startAlpha, endAlpha, duration, false, 0, 0 )
    WindowStartAlphaAnimation ( wndName.."Foreground", Window.AnimationType.SINGLE_NO_RESET, startAlphaMax, endAlphaMax, duration, false, 0, 0 )
    WindowStartAlphaAnimation ( wndName.."ResizeButton", Window.AnimationType.SINGLE_NO_RESET, startAlpha, endAlpha, duration, false, 0, 0 )

end

function EA_ChatWindow.OnMouseOver()
    
    local wndGroupId = WindowGetId(SystemData.ActiveWindow.name)
    
    EA_ChatWindow.StartFadeIn(wndGroupId)
end

function EA_ChatWindow.OnMouseOverEnd()
    
    local wndGroupId = WindowGetId(SystemData.ActiveWindow.name)
    
    EA_ChatWindow.StartFadeOut(wndGroupId)
end



function EA_ChatWindow.OnUpdate( elapsedTime )

    -- Save the Settings if they have changed.
    EA_ChatWindow.SaveSettings() 
    
    -- update for autohiding the window
    for wndGroupId, wndGroup in ipairs(EA_ChatWindowGroups) 
    do
        if ( wndGroup.used == true and
             wndGroup.fadeOutStarted == true and
             wndGroup.canAutoHide == true and
             EA_ChatWindow.isResizing ~= true and 
             EA_ChatWindow.isContextMenuShowing ~= true and
             WindowGetShowing( "ChatWindowSetOpacityWindow" ) == false and
             WindowGetShowing( "ChatWindowRenameWindow" ) == false and
             EA_ChatTabManager.isDocking == false  )
        then
            wndGroup.fadeOutTimer = wndGroup.fadeOutTimer - elapsedTime
            if ( wndGroup.fadeOutTimer <= 0.0 )
            then
                wndGroup.fadedIn = false
                wndGroup.fadeOutStarted = false 
                
                wndGroup.fadeOutTimer = 0.0
                -- start the fade out animation
                EA_ChatWindow.StartAlphaAnimation( wndGroupId, false )
            end
        end
    end

    -- Check the chat text buffer to see if it has been updated
    -- If so, then do the check to see if you should replace the first word with 
    -- the proper string...ie, /say -> [Say]:
    if (EA_TextEntryGroupEntryBoxTextInput.TextUpdated == true) 
    then
        EA_ChatWindow.DoChatTextReplacement ()
        -- Make sure to reset the var because we handled this update
        EA_TextEntryGroupEntryBoxTextInput.TextUpdated = false
    end

    -- update the game rating window
    EA_ChatWindow.UpdateGameRatingWindow( elapsedTime )
end

function EA_ChatWindow.OnLButtonDownProcessed()

    -- do not close the chat channel menu if we clicked inside it
    -- This if statement can be removed if we convert the channel menu to an EA_ContextMenu
    winName = "ChatChannel"
    if string.sub(SystemData.MouseOverWindow.name,1,string.len(winName))==winName then
        return
    end
 
    EA_ChatWindow.HideMenu()
end

function EA_ChatWindow.OnRButtonDownProcessed()
    EA_ChatWindow.HideMenu()
end

function EA_ChatWindow.OnRButtonDown()
    EA_ChatWindow.HideMenu()
end

function EA_ChatWindow.OnScrollPosChanged()

    -- If we are not scrolled to the bottom on the active tab of a window group
    for k, wndGroup in ipairs(EA_ChatWindowGroups) 
    do
        if( wndGroup.used == false )
        then
            continue
        end
        
        local activeTabId = wndGroup.activeTab
                
        if ( wndGroup.Tabs[activeTabId] == nil or wndGroup.Tabs[activeTabId].tabManagerId == nil )
        then 
            return
        end
        
        local activeTabName = EA_ChatTabManager.GetTabName( wndGroup.Tabs[activeTabId].tabManagerId )

        local scrolledDown = LogDisplayIsScrolledToBottom( activeTabName.."TextLog" )
        local alertWindowName = activeTabName.."TextLogToBottomButtonAlert"
        -- Blink the new text alert whenever the main LogDisplay is scolled up from the bottom.
        if( scrolledDown == false ) then
            WindowSetShowing( alertWindowName, true )
            WindowStartAlphaAnimation( alertWindowName, Window.AnimationType.LOOP, 0.6, 1.0, 1.0, false, 0, 0 )
        else
            WindowSetShowing( alertWindowName, false )
            WindowStopAlphaAnimation( alertWindowName )
        end
    end
    
end

function EA_ChatWindow.OnSetMoving( bMoving )
    -- we only care if we have stopped moving
    if ( not bMoving ) then

        if (WindowGetShowing("EA_TextEntryGroupEntryBox") == true)
        then
            WindowAssignFocus( "EA_TextEntryGroupEntryBoxTextInput", true )
        end
        
        EA_ChatWindow.OnSettingsChanged()
    end
end


function EA_ChatWindow.OnTabLButtonDown()

    local tabButtonName = SystemData.ActiveWindow.name
    
    local tabId = EA_ChatWindow.GetTabIdFromWindowName(tabButtonName)
    
    EA_ChatTabManager.DockingBegin(tabId)

end

function EA_ChatWindow.OnTabLButtonUp()

    local tabButtonName = SystemData.ActiveWindow.name
    
    local tabId = EA_ChatWindow.GetTabIdFromWindowName(tabButtonName)
    EA_ChatWindow.SetToTab(tabId)

end

function EA_ChatWindow.OnTabMouseOver()
    
    local tabButtonName = SystemData.ActiveWindow.name
    
    local tabId = EA_ChatWindow.GetTabIdFromWindowName(tabButtonName)
    
    if( tabId >= 1 ) 
    then
        EA_ChatWindow.StartFadeIn(EA_ChatTabManager.Tabs[tabId].wndGroupId)
        
        if( EA_ChatTabManager.isDocking )
        then
            local wndGroupId = EA_ChatTabManager.Tabs[tabId].wndGroupId
            local tabMarkerName = EA_ChatWindowGroups[wndGroupId].name.."TabWindowScrollChildTabInsert"
            local tabName = EA_ChatTabManager.Tabs[tabId].name
            
            WindowSetShowing(tabMarkerName, true)
            
            WindowClearAnchors(tabMarkerName)
            WindowAddAnchor( tabMarkerName, "topright", tabName, "topright", 8, 0)
            WindowAddAnchor( tabMarkerName, "bottomright", tabName, "bottomright", 8, 3)

            WindowStartAlphaAnimation( tabMarkerName, Window.AnimationType.LOOP, 0.5, 1.0, 0.5, false, 0, 0 )
            WindowSetShowing("EA_ChatDockingWindow", false)
        end
    end
    
end

function EA_ChatWindow.OnTabMouseOverEnd()
   
    -- docking really starts after you move off the tab you started on
    if( EA_ChatTabManager.dockingStart )
    then
        EA_ChatTabManager.dockingStart = false
        EA_ChatTabManager.isDocking = true 
        
        local wndGroupId = EA_ChatTabManager.Tabs[EA_ChatTabManager.dockingTabId].wndGroupId
        local width, height = WindowGetDimensions( EA_ChatWindowGroups[wndGroupId].name )        
        local x, y = WindowGetOffsetFromParent( EA_ChatWindowGroups[wndGroupId].name )        
        WindowSetDimensions( "EA_ChatDockingWindow", width, height)  
        WindowSetShowing( "EA_ChatDockingWindow", true)  

        WindowClearAnchors("EA_ChatDockingWindow")
        WindowAddAnchor( "EA_ChatDockingWindow", "topleft", "CursorWindow", "topleft", 0, 0)
        EA_ChatWindow.SetToTab( EA_ChatTabManager.dockingTabId )
    end
    
    local tabButtonName = SystemData.ActiveWindow.name

    local tabId = EA_ChatWindow.GetTabIdFromWindowName(tabButtonName)
    
    if( tabId >= 1 ) 
    then
        EA_ChatWindow.StartFadeOut(EA_ChatTabManager.Tabs[tabId].wndGroupId)
        
        if( EA_ChatTabManager.isDocking )
        then            
            EA_ChatWindow.HideTabInsert(EA_ChatTabManager.Tabs[tabId].wndGroupId)
            WindowSetShowing("EA_ChatDockingWindow", true)
        end
    end
end

function EA_ChatWindow.OnLButtonUpProcessed()
    
    -- finish the docking action
    if(EA_ChatTabManager.isDocking )
    then
        EA_ChatTabManager.DockingEnd()
    end
    
    -- clear docking data
    EA_ChatTabManager.dockingStart = false
    EA_ChatTabManager.dockingTabId = 0 

end

function EA_ChatWindow.GameRatingWindowSetShowing( bShow )
    EA_ChatWindow.showGameRatingText = bShow
    EA_ChatWindow.timeGameRatingText = 0
    if( bShow ) 
    then
        WindowSetShowing( NAME_CHAT_WINDOW_GAME_RATING_WINDOW, true )
        WindowStartAlphaAnimation( NAME_CHAT_WINDOW_GAME_RATING_WINDOW, Window.AnimationType.SINGLE_NO_RESET, 0.0, 1.0, CHAT_WINDOW_GAME_RATING_TEXT_FADETIME_IN_SECONDS, false, 0, 0 )
    else
        WindowStartAlphaAnimation( NAME_CHAT_WINDOW_GAME_RATING_WINDOW, Window.AnimationType.SINGLE_NO_RESET, 1.0, 0.0, CHAT_WINDOW_GAME_RATING_TEXT_FADETIME_IN_SECONDS, false, 0, 0 )
    end
end

function EA_ChatWindow.InitGameRatingWindow( wndGroupName )
    -- the chat window game rating text is for Korea territory only
    if ( not SystemData.Territory.KOREA )
    then
        return
    end

    -- create the chat window game rating text window
    if( not DoesWindowExist( NAME_CHAT_WINDOW_GAME_RATING_WINDOW ) )
    then
        CreateWindowFromTemplate( NAME_CHAT_WINDOW_GAME_RATING_WINDOW, "EA_GameRatingGroup", wndGroupName )
    end
    LabelSetText( NAME_CHAT_WINDOW_GAME_RATING_WINDOW.."Text", GetChatString( StringTables.Chat.TEXT_CHAT_WINDOW_KOREA_ONLY_GAME_RATING_TEXT ) )
    WindowClearAnchors( NAME_CHAT_WINDOW_GAME_RATING_WINDOW )
    WindowAddAnchor( NAME_CHAT_WINDOW_GAME_RATING_WINDOW, "topleft", wndGroupName,                 "topleft",  30, 35 )
    WindowAddAnchor( NAME_CHAT_WINDOW_GAME_RATING_WINDOW, "topleft", wndGroupName.."ResizeButton", "topright", 0,  0 )
    EA_ChatWindow.GameRatingWindowSetShowing( true )
end

function EA_ChatWindow.UpdateGameRatingWindow( elapsedTime )
    -- the chat window game rating text is for Korea territory only
    if ( not SystemData.Territory.KOREA )
    then
        return
    end

    EA_ChatWindow.timeGameRatingText = EA_ChatWindow.timeGameRatingText + elapsedTime
    
    if( EA_ChatWindow.showGameRatingText == false ) 
    then
        -- check if we can hide game rating window after it finish the fade out
        if( ( EA_ChatWindow.timeGameRatingText > CHAT_WINDOW_GAME_RATING_TEXT_FADETIME_IN_SECONDS ) and WindowGetShowing( NAME_CHAT_WINDOW_GAME_RATING_WINDOW ) ) 
        then
            WindowSetShowing( NAME_CHAT_WINDOW_GAME_RATING_WINDOW, false )
        end
    
        -- the game rating text is currently not shown, check if it is the time to show the game rating text
        if( EA_ChatWindow.timeGameRatingText >= CHAT_WINDOW_GAME_RATING_TEXT_INTERVAL_IN_SECONDS ) 
        then
            -- show game rating text
            EA_ChatWindow.GameRatingWindowSetShowing( true )
        end
    else
        -- the game rating text is currently shown, check if it is the time to hide the game rating text
        if( EA_ChatWindow.timeGameRatingText >= CHAT_WINDOW_GAME_RATING_TEXT_SHOWTIME_IN_SECONDS ) 
        then
            -- hide game rating text
            EA_ChatWindow.GameRatingWindowSetShowing( false )
        end
    end
end