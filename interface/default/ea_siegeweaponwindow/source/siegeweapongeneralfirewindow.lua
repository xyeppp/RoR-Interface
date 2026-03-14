----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------
SiegeWeaponGeneralFireWindow = {}

local function UpdateDisplay(windowList, inFireMode)
    for index, data in ipairs(windowList) do
        WindowSetDrawWhenInterfaceHidden(data.windowName, inFireMode)

        if (data.shouldSetShowing) then
            WindowSetShowing(data.windowName, inFireMode)
        end

        -- Fade in all the windows    
        if (inFireMode and WindowGetShowing(data.windowName)) then
            local delay = 0.5
            local fadeTime = 1.0
            WindowStartAlphaAnimation(data.windowName, Window.AnimationType.SINGLE, 0, 1, fadeTime, true, delay, 0)
        end
    end

    ScreenFlashWindow.SetEnabled(inFireMode)
    SiegeWeaponControlWindow.MoveInfoToBottomOfScreen(inFireMode)
end

----------------------------------------------------------------
-- SiegeWeapon Functions
----------------------------------------------------------------

function SiegeWeaponGeneralFireWindow.Initialize()
    -- Initialize the Siege Chat Display       
    WindowSetAlpha("SiegeWeaponGeneralFireWindowChatLogDisplay", 0.0) -- Hides the scroll bar entirely
    LogDisplayAddLog("SiegeWeaponGeneralFireWindowChatLogDisplay", "Chat", true)

    for filterId, msgTypeData in pairs(ChatSettings.Channels) do
        if EA_ChatWindowGroups[1]["Tabs"][1]["Filters"][filterId] == true then
            local color = ChatSettings.ChannelColors[filterId]

            LogDisplaySetFilterState("SiegeWeaponGeneralFireWindowChatLogDisplay", msgTypeData.logName, msgTypeData.id,
                true)
            LogDisplaySetFilterColor("SiegeWeaponGeneralFireWindowChatLogDisplay", msgTypeData.logName, msgTypeData.id,
                color.r, color.g, color.b)
        end
    end
end

function SiegeWeaponGeneralFireWindow.SetInstructions(text)
    LabelSetText("SiegeWeaponGeneralFireWindowInstructions", text)
end

function SiegeWeaponGeneralFireWindow.Begin(windowList)
    UpdateDisplay(windowList, true)
    LogDisplayScrollToBottom("SiegeWeaponGeneralFireWindowChatLogDisplay")
end

function SiegeWeaponGeneralFireWindow.End(windowList)
    UpdateDisplay(windowList, false)
end

