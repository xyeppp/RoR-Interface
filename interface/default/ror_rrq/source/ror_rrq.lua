ror_rrq = {}
RoR_Window_RRQTracker = {}
ror_rrq.UpdateRRQWindowID = nil

ror_rrq.BAR_HEIGHT = 23
ror_rrq.BAR_SPACE = 0

ror_rrq.CITY_BAR_MAX_HEIGHT = 82
ror_rrq.CITY_BAR_MAX_WIDTH = 10
ror_rrq.CITY_BACKGROUND_WIDTH = 49

-- when creating the tooltip, I use this table to select the right tooltips based on the bar instance's display type
local TooltipLookupTable = {}
TooltipLookupTable[GameData.RRQDisplayType.ERRQDISPLAY_DEFAULT] = {
    header = StringTables.WorldControl.TOOLTIP_RRQSTATUS_HEADER,
    desc = StringTables.WorldControl.TOOLTIP_RRQSTATUS_DESCRIPTION,
    access = StringTables.WorldControl.TOOLTIP_RRQSTATUS_REALMACCESS,
    paused = StringTables.WorldControl.TOOLTIP_RRQSTATUS_PAUSED
}
TooltipLookupTable[GameData.RRQDisplayType.ERRQDISPLAY_TOMB_KINGS] = {
    header = StringTables.WorldControl.TOOLTIP_RRQSTATUS_TK_HEADER,
    desc = StringTables.WorldControl.TOOLTIP_RRQSTATUS_TK_DESCRIPTION,
    access = StringTables.WorldControl.TOOLTIP_RRQSTATUS_TK_REALMACCESS,
    paused = StringTables.WorldControl.TOOLTIP_RRQSTATUS_TK_PAUSED
}
TooltipLookupTable[GameData.RRQDisplayType.ERRQDISPLAY_LIVE_EVENT] = {
    header = StringTables.WorldControl.TOOLTIP_RRQSTATUS_HEADER,
    desc = StringTables.WorldControl.TOOLTIP_RRQSTATUS_LIVEEVENT_DESCRIPTION,
    access = StringTables.WorldControl.TOOLTIP_RRQSTATUS_REALMACCESS,
    paused = StringTables.WorldControl.TOOLTIP_RRQSTATUS_PAUSED
}
TooltipLookupTable[4] = {
    header = StringTables.WorldControl.TOOLTIP_RRQSTATUS_CITY_HEADER,
    desc = StringTables.WorldControl.TOOLTIP_RRQSTATUS_CITY_DESCRIPTION,
    access = StringTables.WorldControl.TOOLTIP_RRQSTATUS_CITY_REALMACCESS,
    paused = StringTables.WorldControl.TOOLTIP_RRQSTATUS_CITY_PAUSED
}

-- this will run on start
function ror_rrq.OnInitialize()
    -- Create the Togglebutton and MAP Tracker window
    CreateWindow("EA_Window_WorldMapRRQ_RORTrackerToggle", true)
    WindowSetParent("EA_Window_WorldMapRRQ_RORTrackerToggle", "EA_Window_WorldMap")
    RRQProgressBar.AddListener(ror_rrq.UpdateRRQ) -- map tracker
end

-- Setup the Bars
function SetupRRQBars(self)
    -- Reanchor the main window
    -- This should update the initial anchors for all child windows:
    -- background, order, destruction
    WindowClearAnchors(self.windowName);
    WindowAddAnchor(self.windowName, "topleft", self.parentName, "topleft", 0, 0);
    WindowAddAnchor(self.windowName, "bottomright", self.parentName, "bottomright", 0, 0);

    -- It's possible the container was scaled using the Layout Editor
    -- since we created the content from a template dynamically, it won't be scaled
    -- to the new dimensions of its container unless done manually
    local newWidth, newHeight = WindowGetDimensions(self.windowName)
    local scaleFactor = newWidth / ror_rrq.CITY_BACKGROUND_WIDTH
    --  WindowSetRelativeScale( self.windowName, scaleFactor)
end

-- Bar Calculation for the trackers
function UpdateRRQBars(self)

    if self.rrquestID ~= 0 and RRQProgressBar.RealmResourceQuestData[self.rrquestID] ~= nil then
        local rrqData = RRQProgressBar.RealmResourceQuestData[self.rrquestID]
        local barHeight = 0
        WindowSetShowing(self.windowName .. "RealmSymbol0", true)

        for iRealm = GameData.Realm.ORDER, GameData.Realm.DESTRUCTION -- [1, 2]
        do
            if rrqData.realmProgress[iRealm] ~= nil then
                barHeight = (rrqData.realmProgress[iRealm].curVal / rrqData.realmProgress[iRealm].maxVal) *
                                ror_rrq.CITY_BAR_MAX_HEIGHT
                if barHeight > ror_rrq.CITY_BAR_MAX_HEIGHT then
                    barHeight = ror_rrq.CITY_BAR_MAX_HEIGHT
                end

                WindowSetDimensions(self.windowName .. "Bar" .. iRealm, ror_rrq.CITY_BAR_MAX_WIDTH, barHeight)
                WindowSetShowing(self.windowName .. "Bar" .. iRealm, true)

                if rrqData.realmWithAccess == iRealm then
                    WindowSetShowing(self.windowName .. "RealmSymbol" .. iRealm, true)
                    WindowSetShowing(self.windowName .. "RealmSymbol0", false)
                else
                    WindowSetShowing(self.windowName .. "RealmSymbol" .. iRealm, false)
                end
            else
                -- something is wrong if we are here
                ERROR(L "Tomb Kings realm resource data invalid or missing for a realm!")
                WindowSetDimensions(self.windowName .. "Bar" .. iRealm, ror_rrq.CITY_BAR_MAX_HEIGHT, 0)
                WindowSetShowing(self.windowName .. "Bar" .. iRealm, false)
                WindowSetShowing(self.windowName .. "RealmSymbol" .. iRealm, false)
            end
        end

        WindowSetTintColor(self.windowName .. "Circle", DefaultColor.RealmColors[rrqData.realmWithAccess].r,
            DefaultColor.RealmColors[rrqData.realmWithAccess].g, DefaultColor.RealmColors[rrqData.realmWithAccess].b)

        if rrqData.minutesUntilUnpause > 1 then
            LabelSetText(self.windowName .. "TimerLabel",
                TimeUtils.FormatTimeCondensed(rrqData.minutesUntilUnpause * 60))
            WindowSetShowing(self.windowName .. "TimerLabel", true)
        elseif rrqData.minutesUntilUnpause == 1 then
            LabelSetText(self.windowName .. "TimerLabel", towstring("1m"))
            WindowSetShowing(self.windowName .. "TimerLabel", true)
        else
            WindowSetShowing(self.windowName .. "TimerLabel", false)
        end

        -- Lock icon hidden for now
        WindowSetShowing(self.windowName .. "LockIcon", false)

        --  if rrqData.paused then
        --    WindowSetShowing(self.windowName .. "LockIcon", true)
        -- else
        --    WindowSetShowing(self.windowName .. "LockIcon", false)
        -- end
    end

end

-- ========================
-- MAP Tracker
-- ========================

-- Creates the MAP tracker
function ror_rrq.UpdateRRQ()
    local bShow = false
    local rrqData = RRQProgressBar.GetFirstQuestDataOfType(4) -- 4 should be our new Type
    if rrqData ~= nil then
        if not DoesWindowExist("EA_Window_WorldMapRRQ_RORContainerStatus") then
            -- setup Realm Resource Quest Status Window
            ror_rrq.UpdateRRQWindowID = RRQProgressBar.Create("EA_Window_WorldMapRRQ_RORContainerStatus",
                "EA_Window_WorldMapRRQ_RORContainer", rrqData.displayType)

            WindowSetParent("EA_Window_WorldMapRRQ_RORContainer", "EA_Window_WorldMap")
            LabelSetText("EA_Window_WorldMapRRQ_RORTrackerToggleName",
                GetStringFromTable("WorldControl", StringTables.WorldControl.LABEL_TOGGLE_RRQ))
        end
        if not (RRQProgressBar.GetRRQuestIDfromWindowID(ror_rrq.UpdateRRQWindowID) == rrqData.rrquestID) then
            RRQProgressBar.SetRRQuestID(ror_rrq.UpdateRRQWindowID, rrqData.rrquestID)
        end
        bShow = true

    end
    WindowSetShowing("EA_Window_WorldMapRRQ_RORContainer", bShow)
end

-- ========================
-- HUD Tracker
-- ========================

-- Initilize the HUD tracker
function RoR_Window_RRQTracker.Initialize()

    -- HUD Window should be registerd to layouteditor
    LayoutEditor.RegisterWindow("EA_Window_ROR_RRQTracker",
        GetStringFromTable("WorldControl", StringTables.WorldControl.LABEL_TOGGLE_RRQ),
        GetStringFromTable("HUDStrings", StringTables.HUD.LABEL_HUD_RRQ_STATUS_WINDOW_DESC), false, false, true, nil)

    if (EA_Window_WorldMap.Settings.initializedRoR_Window_RRQTrackerShowing == nil) then
        LayoutEditor.UserShow("EA_Window_ROR_RRQTracker")
        EA_Window_WorldMap.Settings.initializedRoR_Window_RRQTrackerShowing = true
    end

    RRQProgressBar.AddListener(RoR_Window_RRQTracker.UpdateRRQ) -- Set the HUD tracker auto update

    if EA_Window_WorldMap.Settings.initializedRoR_Window_RRQTrackerShowing == true then
        LayoutEditor.UserShow("EA_Window_ROR_RRQTracker")
    else
        LayoutEditor.UserHide("EA_Window_ROR_RRQTracker")
    end

    -- Set the status of the Togglebutton
    ButtonSetPressedFlag("EA_Window_WorldMapRRQ_RORTrackerToggleCheckBox",
        EA_Window_WorldMap.Settings.initializedRoR_Window_RRQTrackerShowing)

    RoR_Window_RRQTracker.UpdateRRQ()
end

-- Creates the HUD tracker
function RoR_Window_RRQTracker.UpdateRRQ()
    local rrqData = RRQProgressBar.GetFirstQuestDataOfType(4) -- 4 should be our new Type
    if rrqData ~= nil then
        if not DoesWindowExist("EA_Window_ROR_RRQTrackerBarContainerStatus") then
            -- setup Realm Resource Quest Status Window
            RoR_Window_RRQTracker.UpdateRRQWindowID = RRQProgressBar.Create(
                "EA_Window_ROR_RRQTrackerBarContainerStatus", "EA_Window_ROR_RRQTrackerBarContainer",
                rrqData.displayType)

        end
        if not (RRQProgressBar.GetRRQuestIDfromWindowID(RoR_Window_RRQTracker.UpdateRRQWindowID) == rrqData.rrquestID) then
            RRQProgressBar.SetRRQuestID(RoR_Window_RRQTracker.UpdateRRQWindowID, rrqData.rrquestID)
        end

    end
end

-- Toggle button functions
function RoR_Window_RRQTracker.ToggleHUDTracker()
    local shouldShow = LayoutEditor.IsWindowUserHidden("EA_Window_ROR_RRQTracker")
    if (shouldShow) then
        LayoutEditor.UserShow("EA_Window_ROR_RRQTracker")
    else
        LayoutEditor.UserHide("EA_Window_ROR_RRQTracker")
    end
    RoR_Window_RRQTracker.UpdateTrackerButton()
end

function RoR_Window_RRQTracker.UpdateTrackerButton()
    local showing = not LayoutEditor.IsWindowUserHidden("EA_Window_ROR_RRQTracker")
    EA_Window_WorldMap.Settings.initializedRoR_Window_RRQTrackerShowing =
        not EA_Window_WorldMap.Settings.initializedRoR_Window_RRQTrackerShowing
    ButtonSetPressedFlag("EA_Window_WorldMapRRQ_RORTrackerToggleCheckBox", showing)
end

-- Tooltip

function ror_rrq.DefaultOnMouseoverCallback()

    -- Current Points
    local barId = WindowGetId(SystemData.ActiveWindow.name)
    local rrqID = RRQProgressBar.GetRRQuestIDfromWindowID(barId)
    if (rrqID ~= nil and RRQProgressBar.RealmResourceQuestData[rrqID] ~= nil) then
        local rrqData = RRQProgressBar.RealmResourceQuestData[rrqID]

        local tooltipSet = TooltipLookupTable[rrqData.displayType]
        if tooltipSet == nil then
            tooltipSet = TooltipLookupTable[GameData.RRQDisplayType.ERRQDISPLAY_DEFAULT]
        end

        Tooltips.CreateTextOnlyTooltip(SystemData.ActiveWindow.name)
        Tooltips.SetTooltipText(1, 1, GetStringFromTable("WorldControl", tooltipSet.header))
        Tooltips.SetTooltipColorDef(1, 1, Tooltips.COLOR_HEADING)

        Tooltips.SetTooltipText(2, 1, GetStringFromTable("WorldControl", tooltipSet.desc))

        local iRow = 3

        -- Current counter numbers per-realm. May only show a percentage
        -- tooltip won't show Neutral realm right now, maybe later if we ever do use it
        for iRealm = GameData.Realm.ORDER, GameData.Realm.DESTRUCTION -- [1, 2]
        do
            if rrqData.realmProgress[iRealm] ~= nil then
                local params = {GetRealmName(iRealm), towstring(rrqData.realmProgress[iRealm].curVal)}
                local stringID = StringTables.WorldControl.TOOLTIP_RRQSTATUS_PROGRESS
                if (rrqData.realmProgress[iRealm].maxVal == 100) then
                    stringID = StringTables.WorldControl.TOOLTIP_RRQSTATUS_PROGRESS_PERCENT
                end

                Tooltips.SetTooltipText(iRow, 1, GetStringFormatFromTable("WorldControl", stringID, params))
                Tooltips.SetTooltipColorDef(iRow, 1, Tooltips.COLOR_HEADING)
                iRow = iRow + 1
            end
        end -- end for each realm

        if rrqData.displayType == GameData.RRQDisplayType.ERRQDISPLAY_TOMB_KINGS then
            -- For TK we display access message if there's an ongoing expedition
            if rrqData.minutesUntilUnpause == 0 then
                local params = {GetRealmName(rrqData.realmWithAccess), GetCityNameForRealm(rrqData.realmWithAccess)}
                Tooltips.SetTooltipText(iRow, 1, GetStringFormatFromTable("WorldControl", tooltipSet.access, params))
                Tooltips.SetTooltipColorDef(iRow, 1, Tooltips.COLOR_HEADING)
                iRow = iRow + 1
            end
        else
            -- if a realm has exclusive access, mention that
            if rrqData.realmWithAccess == GameData.Realm.ORDER or rrqData.realmWithAccess == GameData.Realm.DESTRUCTION then
                local params = {GetRealmName(rrqData.realmWithAccess), GetCityNameForRealm(rrqData.realmWithAccess)}
                Tooltips.SetTooltipText(iRow, 1, GetStringFormatFromTable("WorldControl", tooltipSet.access, params))
                Tooltips.SetTooltipColorDef(iRow, 1, Tooltips.COLOR_HEADING)
                iRow = iRow + 1
            end
        end

        -- if the rrq is currently paused ("locked"), mention that too
        if rrqData.paused then
            local params = {towstring(rrqData.minutesUntilUnpause),
                            towstring(math.floor(rrqData.minutesUntilUnpause / 1440)),
                            towstring(math.floor((rrqData.minutesUntilUnpause % 1440) / 60)),
                            towstring(math.floor(rrqData.minutesUntilUnpause % 60))}
            Tooltips.SetTooltipText(iRow, 1, GetStringFormatFromTable("WorldControl", tooltipSet.paused, params))
            Tooltips.SetTooltipColorDef(iRow, 1, Tooltips.COLOR_HEADING)
            iRow = iRow + 1
        end
    end

    Tooltips.Finalize()

    Tooltips.AnchorTooltip(Tooltips.ANCHOR_WINDOW_TOP)
end

-- Just for testing bar groth stuff
function ror_rrq.UpdateDummyData()
    if RRQProgressBar.RealmResourceQuestData[2] ~= nil then
        if RRQProgressBar.RealmResourceQuestData[2].realmProgress[1] ~= nil then
            RRQProgressBar.RealmResourceQuestData[2].realmProgress[1].curVal = math.ceil(
                RRQProgressBar.RealmResourceQuestData[2].realmProgress[1].curVal + math.random(5))
        end
        if RRQProgressBar.RealmResourceQuestData[2].realmProgress[2] ~= nil then
            RRQProgressBar.RealmResourceQuestData[2].realmProgress[2].curVal = math.ceil(
                RRQProgressBar.RealmResourceQuestData[2].realmProgress[2].curVal + math.random(5))
        end
        BroadcastEvent(SystemData.Events.RRQ_LIST_UPDATED)
    else
    end

end

-- this will run on exit
function ror_rrq.OnShutdown()

end
