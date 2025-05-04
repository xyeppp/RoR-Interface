----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

ChatFiltersWindow = {}

ChatFiltersWindow.channelListData = {}
ChatFiltersWindow.channelListOrder = {}
ChatFiltersWindow.channelFiltersState = {}

local function InitChatOptionListData()
    ChatFiltersWindow.channelListData = {}
    local channelIndex = 0
    for channel, channelData in pairs(ChatSettings.Channels) do
        if (channelData ~= nil and channelData.name ~= nil) then
            channelIndex = channelIndex + 1
            ChatFiltersWindow.channelListData[channelIndex] = {}
            ChatFiltersWindow.channelListData[channelIndex].channelName = channelData.name
            ChatFiltersWindow.channelListData[channelIndex].color = ChatSettings.ChannelColors[channel]
            ChatFiltersWindow.channelListData[channelIndex].logName = channelData.logName
            ChatFiltersWindow.channelListData[channelIndex].channelID = channelData.id
        end
    end
end

local function FilterChannelList()

    -- Reset the tables
    ChatFiltersWindow.channelListOrder = {}
    ChatFiltersWindow.channelFiltersState = {}
    
    local tabId = EA_ChatTabManager.activeTabId
    local logDisplayName = EA_ChatTabManager.Tabs[tabId].name.."TextLog"
    -- Set the name of the tab we are working on
    LabelSetText( "ChatFiltersWindowTabName", ButtonGetText( EA_ChatTabManager.Tabs[tabId].name.."Button" ) )
    
    local active
    for idx, channelId in ipairs (ChatSettings.Ordering) do
        
        for dataIndex, data in ipairs( ChatFiltersWindow.channelListData ) do
            if (channelId == data.channelID)
            then
                table.insert(ChatFiltersWindow.channelListOrder, dataIndex)

                active = LogDisplayGetFilterState( logDisplayName, data.logName, data.channelID)
                -- Cache off all of the values, for comparison later
                ChatFiltersWindow.channelFiltersState[idx] = active
                if (idx < ChatFiltersWindowList.numVisibleRows)
                then
                    -- Only fill the table with the number of Checkboxes actually visible
                    ButtonSetPressedFlag("ChatFiltersWindowListRow"..idx.."CheckBox", active)
                end
                break
            end
        end
    end
end

local function ResetChannelList()
    -- Filter, Sort, and Update
    InitChatOptionListData()
    FilterChannelList()
    ListBoxSetDisplayOrder( "ChatFiltersWindowList", ChatFiltersWindow.channelListOrder )
end

-- OnInitialize Handler
function ChatFiltersWindow.Initialize()

    LabelSetText( "ChatFiltersWindowTitleBarText", GetChatString(StringTables.Chat.LABEL_CHAT_FILTERS) )
    ButtonSetText( "ChatFiltersWindowAcceptButton", GetChatString(StringTables.Chat.LABEL_CHAT_SETTINGS_ACCEPT) ) 
end

function ChatFiltersWindow.Hide()
    WindowSetShowing( "ChatFiltersWindow", false )
end

function ChatFiltersWindow.OnShown()
    WindowUtils.OnShown()
    ResetChannelList()
    ChatFiltersWindow.UpdateChatOptionRow()
end

function ChatFiltersWindow.OnHidden()
    WindowUtils.OnHidden()
end

function ChatFiltersWindow.Shutdown()

end

function ChatFiltersWindow.UpdateTitleBar()
    LabelSetText( "ChatFiltersWindowTitleBarText", GetChatString(StringTables.Chat.LABEL_CHAT_OPTIONS_WINDOW_TITLE) )
end

-- Callback from the <List> that updates a single row.
function ChatFiltersWindow.UpdateChatOptionRow()
    if (ChatFiltersWindowList.PopulatorIndices ~= nil) then
        local active = false
        local labelName
        for rowIndex, dataIndex in ipairs(ChatFiltersWindowList.PopulatorIndices) do
            labelName = "ChatFiltersWindowListRow"..rowIndex.."ChannelName"
            LabelSetTextColor(labelName, 
                              ChatFiltersWindow.channelListData[dataIndex].color.r, 
                              ChatFiltersWindow.channelListData[dataIndex].color.g,
                              ChatFiltersWindow.channelListData[dataIndex].color.b)
            local actualIndex = 0
    
            for idx=1, #ChatSettings.Ordering do
                if (ChatFiltersWindow.channelListData[dataIndex].channelID == ChatSettings.Ordering[idx])
                then
                    actualIndex = idx
                end
            end
            if (actualIndex ~= 0)
            then
                active = ChatFiltersWindow.channelFiltersState[actualIndex]
            end
            ButtonSetPressedFlag("ChatFiltersWindowListRow"..rowIndex.."CheckBox", active)
        end
    end
end
function ChatFiltersWindow.SetAllFiltersChanges()
    local active = false
    
    local tabId = EA_ChatTabManager.activeTabId
    local logDisplayName = EA_ChatTabManager.Tabs[tabId].name.."TextLog"

    for idx=1, #ChatSettings.Ordering do
        
        active = LogDisplayGetFilterState( logDisplayName, 
                        ChatSettings.Channels[ChatSettings.Ordering[idx]].logName, ChatSettings.Ordering[idx])
        if (active ~= ChatFiltersWindow.channelFiltersState[idx])
        then
            -- This item has changed, update the filter now
            LogDisplaySetFilterState( logDisplayName, ChatSettings.Channels[ChatSettings.Ordering[idx]].logName,  
                        ChatSettings.Ordering[idx], ChatFiltersWindow.channelFiltersState[idx])
        end
    end
    ChatFiltersWindow.Hide()
    EA_ChatWindow.OnSettingsChanged()
end
function ChatFiltersWindow.OnToggleChannel()
    local windowIndex = WindowGetId (SystemData.ActiveWindow.name)
    local windowParent = WindowGetParent (SystemData.ActiveWindow.name)
    local dataIndex = ListBoxGetDataIndex (windowParent, windowIndex)
    local actualIndex = 0
    
    -- Search for the index of the Channel we're altering
    for idx=1, #ChatSettings.Ordering do
        if (ChatFiltersWindow.channelListData[dataIndex].channelID == ChatSettings.Ordering[idx])
        then
            actualIndex = idx
        end
    end

    ChatFiltersWindow.channelFiltersState[actualIndex] = not ChatFiltersWindow.channelFiltersState[actualIndex]
    
    -- Update the button
    local channelCheckBox = "ChatFiltersWindowListRow"..windowIndex.."CheckBox"
    ButtonSetPressedFlag(channelCheckBox, ChatFiltersWindow.channelFiltersState[actualIndex])
end

