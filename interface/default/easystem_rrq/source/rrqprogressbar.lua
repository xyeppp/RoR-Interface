----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

RRQProgressBar = {}

RRQProgressBar.BAR_HEIGHT = 23
RRQProgressBar.BAR_SPACE = 0

RRQProgressBar.TK_BAR_MAX_HEIGHT    = 61
RRQProgressBar.TK_BAR_WIDTH         = 8
RRQProgressBar.TK_BACKGROUND_WIDTH  = 61

-- if the client provides any RRQ data, it goes into this table
RRQProgressBar.RealmResourceQuestData = {}

-- a list of registered listeners from other mods that wish to process SystemData.Events.RRQ_LIST_UPDATED
-- helps ensure they do their updates AFTER the system mod has updated with the new data
RRQProgressBar.UpdateListeners = {}

RRQProgressBarTracker = { }

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

local BAR_NEUTRAL_TINT        = { r=255, g=255, b=255 }
local BAR_ORDER_TINT          = { r=0, g=0, b=255 }
local BAR_DESTRUCTION_TINT    = { r=255, g=0, b=0 }
local BAR_BACKGROUND_TINT     = { r=20, g=20, b=20 }

-- when creating the tooltip, I use this table to select the right tooltips based on the bar instance's display type
local TooltipLookupTable = { }
TooltipLookupTable[GameData.RRQDisplayType.ERRQDISPLAY_DEFAULT] =    { header=StringTables.WorldControl.TOOLTIP_RRQSTATUS_HEADER,
                                                                       desc=StringTables.WorldControl.TOOLTIP_RRQSTATUS_DESCRIPTION,
                                                                       access=StringTables.WorldControl.TOOLTIP_RRQSTATUS_REALMACCESS,
                                                                       paused=StringTables.WorldControl.TOOLTIP_RRQSTATUS_PAUSED}
TooltipLookupTable[GameData.RRQDisplayType.ERRQDISPLAY_TOMB_KINGS] = { header=StringTables.WorldControl.TOOLTIP_RRQSTATUS_TK_HEADER,
                                                                       desc=StringTables.WorldControl.TOOLTIP_RRQSTATUS_TK_DESCRIPTION,
                                                                       access=StringTables.WorldControl.TOOLTIP_RRQSTATUS_TK_REALMACCESS,
                                                                       paused=StringTables.WorldControl.TOOLTIP_RRQSTATUS_TK_PAUSED}
TooltipLookupTable[GameData.RRQDisplayType.ERRQDISPLAY_LIVE_EVENT] = { header=StringTables.WorldControl.TOOLTIP_RRQSTATUS_HEADER,
                                                                       desc=StringTables.WorldControl.TOOLTIP_RRQSTATUS_LIVEEVENT_DESCRIPTION,
                                                                       access=StringTables.WorldControl.TOOLTIP_RRQSTATUS_REALMACCESS,
                                                                       paused=StringTables.WorldControl.TOOLTIP_RRQSTATUS_PAUSED}

----------------------------------------------------------------
-- Local/Utility Functions
----------------------------------------------------------------

local function SetupBarSet (self)

    --DEBUG (L"SetupBarSet: ");
    --DEBUG (L"   bar:     "..StringToWString (self.windowName));
    --DEBUG (L"   anchor:  "..StringToWString (self.parentName));
    
    -- Reanchor the main window
    -- This should update the initial anchors for all child windows:
    -- background, order, destruction
    WindowClearAnchors (self.windowName);
    WindowAddAnchor (self.windowName, "topleft", self.parentName, "topleft", 0, 0);
    WindowAddAnchor (self.windowName, "bottomright", self.parentName, "bottomright", 0, 0);    
    
    StatusBarSetForegroundTint(self.windowName.."Bar0Bar", BAR_NEUTRAL_TINT.r, BAR_NEUTRAL_TINT.g, BAR_NEUTRAL_TINT.b)
    StatusBarSetBackgroundTint (self.windowName.."Bar0Bar", BAR_BACKGROUND_TINT.r, BAR_BACKGROUND_TINT.g, BAR_BACKGROUND_TINT.b)
    StatusBarSetForegroundTint(self.windowName.."Bar1Bar", BAR_ORDER_TINT.r, BAR_ORDER_TINT.g, BAR_ORDER_TINT.b)
    StatusBarSetBackgroundTint (self.windowName.."Bar1Bar", BAR_BACKGROUND_TINT.r, BAR_BACKGROUND_TINT.g, BAR_BACKGROUND_TINT.b)
    StatusBarSetForegroundTint(self.windowName.."Bar2Bar", BAR_DESTRUCTION_TINT.r, BAR_DESTRUCTION_TINT.g, BAR_DESTRUCTION_TINT.b)
    StatusBarSetBackgroundTint (self.windowName.."Bar2Bar", BAR_BACKGROUND_TINT.r, BAR_BACKGROUND_TINT.g, BAR_BACKGROUND_TINT.b)
end

local function SetupTKBars (self)
    -- Reanchor the main window
    -- This should update the initial anchors for all child windows:
    -- background, order, destruction
    WindowClearAnchors (self.windowName);
    WindowAddAnchor (self.windowName, "topleft", self.parentName, "topleft", 0, 0);
    WindowAddAnchor (self.windowName, "bottomright", self.parentName, "bottomright", 0, 0);
    
    -- It's possible the container was scaled using the Layout Editor
    -- since we created the content from a template dynamically, it won't be scaled
    -- to the new dimensions of its container unless done manually
    local newWidth, newHeight = WindowGetDimensions(self.windowName)
    local scaleFactor = newWidth / RRQProgressBar.TK_BACKGROUND_WIDTH
    WindowSetRelativeScale( self.windowName, scaleFactor)
end

local function UpdateTKBars (self)

    if self.rrquestID ~= 0 and RRQProgressBar.RealmResourceQuestData[self.rrquestID] ~= nil
    then
        local rrqData = RRQProgressBar.RealmResourceQuestData[self.rrquestID]
        local barHeight = 0
        
        for iRealm=GameData.Realm.ORDER, GameData.Realm.DESTRUCTION --[1, 2]
        do
            if rrqData.realmProgress[iRealm] ~= nil
            then
                barHeight = ( rrqData.realmProgress[iRealm].curVal / rrqData.realmProgress[iRealm].maxVal ) * RRQProgressBar.TK_BAR_MAX_HEIGHT
                if barHeight > RRQProgressBar.TK_BAR_MAX_HEIGHT
                then
                    barHeight = RRQProgressBar.TK_BAR_MAX_HEIGHT
                end
                --DEBUG(L"UpdateTKBars curVal="..rrqData.realmProgress[iRealm].curVal..L"maxVal="..rrqData.realmProgress[iRealm].maxVal..L"barHeight="..barHeight)
                WindowSetDimensions( self.windowName.."Bar"..iRealm, RRQProgressBar.TK_BAR_WIDTH, barHeight )
                WindowSetShowing (self.windowName.."Bar"..iRealm, true)
                
                -- show/hide the realm emblem of a realm that controls the TK dungeon, if any
                if rrqData.realmWithAccess == iRealm
                then
                    WindowSetShowing (self.windowName.."RealmSymbol"..iRealm, true)
                else
                    WindowSetShowing (self.windowName.."RealmSymbol"..iRealm, false)
                end
            else
                -- something is wrong if we are here
                ERROR(L"Tomb Kings realm resource data invalid or missing for a realm!")
                WindowSetDimensions( self.windowName.."Bar"..iRealm, RRQProgressBar.TK_BAR_WIDTH, 0 )
                WindowSetShowing (self.windowName.."Bar"..iRealm, false)
                WindowSetShowing (self.windowName.."RealmSymbol"..iRealm, false)
            end
        end
        
        -- is the dungeon locked, does one realm have exclusive access right now? Lock Icon
        if rrqData.paused 
        then
            WindowSetShowing (self.windowName.."LockIcon", true)
        else
            WindowSetShowing (self.windowName.."LockIcon", false)
        end
    end

end

-- custom update for an alternate display type for RRQ bars
-- With this, there is no real maximum, we use the sum of Order and Destro's progress. 
-- Then, like zone control bars, the fill of order from left->right and Destro right->left shows
-- who has more progress and how much more. Tooltip shows exact values if we have them, or percentages.
local function UpdateTugoWarBars (self)

    WindowSetShowing(self.windowName.."Bar"..0, false)

    if self.rrquestID ~= 0 and RRQProgressBar.RealmResourceQuestData[self.rrquestID] ~= nil 
    then
        local rrqData = RRQProgressBar.RealmResourceQuestData[self.rrquestID]
        
        local sumMax = rrqData.realmProgress[GameData.Realm.ORDER].curVal + rrqData.realmProgress[GameData.Realm.DESTRUCTION].curVal
        if sumMax == 0
        then
            sumMax = 100 -- dummy value till some realm does have progress
        end
        -- DEBUG(L"UpdateTugoWarBars sumMax="..sumMax)
        
        for iRealm=GameData.Realm.ORDER, GameData.Realm.DESTRUCTION --[1, 2]
        do
            if rrqData.realmProgress[iRealm] ~= nil 
            then
                StatusBarSetMaximumValue(self.windowName.."Bar"..iRealm.."Bar", sumMax)
                StatusBarSetCurrentValue(self.windowName.."Bar"..iRealm.."Bar", rrqData.realmProgress[iRealm].curVal)
                WindowSetShowing(self.windowName.."Bar"..iRealm, true)
            else
                WindowSetShowing(self.windowName.."Bar"..iRealm, false)
                
            end
        end
        

    end
end

-- Called after initial creation and every five minutes or so as the server updates 
-- the client on the progress of the realm resource quest. 
-- This will show/hide progress bars of the realms based on if we have data, and reanchor appropriately
function UpdateStatusBars (self)
    
    local function AnchorBar(barWindowName, prevWindowName)
        if prevWindowName ~= nil
        then
            WindowClearAnchors(barWindowName)
            WindowAddAnchor(barWindowName, "bottomleft", prevWindowName, "topleft", 0, RRQProgressBar.BAR_SPACE)
            WindowAddAnchor(barWindowName, "bottomright", prevWindowName, "topright", 0, RRQProgressBar.BAR_SPACE)
        end
    end
    
    local function ReanchorTopBar(barWindowName, numWindows)
        if barWindowName ~= nil 
        then
            local yOffset = 0
            if numWindows == 3 
            then
                yOffset = 0
            elseif numWindows == 2
            then
                yOffset = (RRQProgressBar.BAR_HEIGHT + RRQProgressBar.BAR_SPACE) / 2
            elseif numWindows == 1
            then
                yOffset = RRQProgressBar.BAR_HEIGHT + RRQProgressBar.BAR_SPACE
            end
            WindowClearAnchors(barWindowName)
            WindowAddAnchor(barWindowName, "topleft", WindowGetParent(barWindowName), "topleft", 0, yOffset)
            WindowAddAnchor(barWindowName, "topright", WindowGetParent(barWindowName), "topright", 0, yOffset)
        end

    end

    if self.rrquestID ~= 0 and RRQProgressBar.RealmResourceQuestData[self.rrquestID] ~= nil then
    
        local rrqData = RRQProgressBar.RealmResourceQuestData[self.rrquestID]
        
        local prevWindowName = nil
        local firstWindowName = nil
        local numWindows = 0
        
        for iRealm=GameData.Realm.NONE, GameData.Realm.DESTRUCTION --[0, 2]
        do
            -- Already checked display type of the RRQ. Some have no max, checking for that too. 
            if rrqData.realmProgress[iRealm] ~= nil and rrqData.realmProgress[iRealm].maxVal > 0
            then
                StatusBarSetMaximumValue(self.windowName.."Bar"..iRealm.."Bar", rrqData.realmProgress[iRealm].maxVal)
                StatusBarSetCurrentValue(self.windowName.."Bar"..iRealm.."Bar", rrqData.realmProgress[iRealm].curVal)
                --anchor to the last window we made if not the first, with an offset
                AnchorBar(self.windowName.."Bar"..iRealm, prevWindowName)
                prevWindowName = self.windowName.."Bar"..iRealm
                if firstWindowName == nil
                then
                    firstWindowName = prevWindowName
                end
                numWindows = numWindows + 1
                WindowSetShowing(self.windowName.."Bar"..iRealm, true)
            else
                WindowSetShowing(self.windowName.."Bar"..iRealm, false)
                
            end
        end
        
        --move the anchoring up based on how many bars there are to center vertically
        ReanchorTopBar(firstWindowName, numWindows)
    end

end

----------------------------------------------------------------
-- RRQProgressBar Functions
----------------------------------------------------------------

function RRQProgressBar.Initialize()
   RegisterEventHandler( SystemData.Events.RRQ_LIST_UPDATED,  "RRQProgressBar.OnRRQsUpdated")
   
   -- get initial data from client if it has any
   RRQProgressBar.OnRRQsUpdated()
end

function RRQProgressBar.Shutdown()
    UnregisterEventHandler( SystemData.Events.RRQ_LIST_UPDATED,  "RRQProgressBar.OnRRQsUpdated")

    -- The anchor points for the progress bars should destroy their children
    -- when they get destroyed, but just in case, I'll destroy the windows here.
    for k, v in pairs (RRQProgressBarTracker) do
        if (nil ~= v.windowName) then
            DestroyWindow (v.windowName);
        end
    end

    RRQProgressBar.UpdateListeners = {}
    RRQProgressBarTracker = {};

end


function RRQProgressBar.AddListener( updateFunc )
    if ( updateFunc ~= nil and RRQProgressBar.UpdateListeners[updateFunc] == nil)
    then
        -- may as well key with the function itself to easily check if it was already added
        RRQProgressBar.UpdateListeners[updateFunc] = updateFunc
    else
        ERROR(L"RRQProgressBar.AddListener failed, updateFunc is missing or already added.")
    end
    
end

function RRQProgressBar.Create( windowName, parentName, displayType )

    --DEBUG (L"RRQProgressBar.Create: ");
    --DEBUG (L"   id:      "..pointPoolID);
    --DEBUG (L"   name:    "..StringToWString (windowName));
    --DEBUG (L"   parent:  "..StringToWString (parentName));
    
    local windowTemplateName = "RRQBarsSetTemplate" -- default set of bars
    local updateFunc = UpdateStatusBars
    local setupFunc  = SetupBarSet
    if displayType ~= nil and displayType == GameData.RRQDisplayType.ERRQDISPLAY_LIVE_EVENT
    then
        -- alternate "Tug o' War" style display
        windowTemplateName = "RRQBarsTugoWarTemplate"
        updateFunc = UpdateTugoWarBars
    elseif displayType ~= nil and displayType == GameData.RRQDisplayType.ERRQDISPLAY_TOMB_KINGS
    then
        -- tomb kings stylized display with Order and Destro bars, owner icons, lock icon, etc
        windowTemplateName = "RRQBarsTombKingsTemplate"
        updateFunc = UpdateTKBars
        setupFunc  = SetupTKBars
    elseif displayType ~= nil and displayType == 4 then
        -- Create the RoR's DisplayType from templates
        windowTemplateName = "ROR_RRQBarsTemplate"
        updateFunc = UpdateRRQBars
        setupFunc = SetupRRQBars
	end
    
    CreateWindowFromTemplate(windowName, windowTemplateName, parentName);
        
    -- Map this bar's point pool id to a name so that there's an easy way to perform the updates.
    --   need to generate a unique ID

    -- Linear search - fast enough since this function isn't called often.
    --   Used since there's no generic ID generator in Lua
    local barId = 0
    while (RRQProgressBarTracker[barId] ~= nil) do
        barId = barId + 1
    end
    
    -- record the ID so we can trigger callbacks
    WindowSetId(windowName, barId)
    
    -- enable server automatic RRQ updates when this window is visible
    EnableRRQUpdates(windowName)

    RRQProgressBarTracker[barId] = 
    { 
        poolID      = barId, 
        windowName  = windowName,
        parentName  = parentName,
        
        Initialize  = setupFunc,
        Update      = updateFunc,  -- varies by style of RRQ bars: Standard, Tugowar (Live Event), Tomb Kings
        
        rrquestID      = 0, -- Realm Resource Quest that is curently displayed on this bar set. Use SetRRQuestID
    }
    
    RRQProgressBarTracker[barId]:Initialize()
    RRQProgressBarTracker[barId]:Update()
    
    return barId;
end

function RRQProgressBar.Destroy(barId)
    if (RRQProgressBarTracker[barId] == nil) or (RRQProgressBarTracker[barId].windowName == nil) then
        return
    end

    DestroyWindow(RRQProgressBarTracker[barId].windowName)
end

function RRQProgressBar.Hide(barId)
    if (RRQProgressBarTracker[barId] == nil) or (RRQProgressBarTracker[barId].windowName == nil) then
        return
    end
    
    WindowSetShowing(RRQProgressBarTracker[barId].windowName, false)
end

function RRQProgressBar.Show(barId)
    if (RRQProgressBarTracker[barId] == nil) or (RRQProgressBarTracker[barId].windowName == nil) then
        return
    end

    WindowSetShowing(RRQProgressBarTracker[barId].windowName, true)
end

--Associate one particular Realm Resource Quest with one particular RRQ status window instance
function RRQProgressBar.SetRRQuestID( barId, rrquestID )
    -- DEBUG(L"RRQProgressBar.SetRRQuestID barId="..towstring(barId)..L" rrquestID="..towstring(rrquestID))
    if( RRQProgressBarTracker[barId] == nil )
    then
        ERROR( L"RRQProgressBar.SetRRQuestID( barId, rrquestID): No RRQ window with that ID exists" )
        return
    end

    RRQProgressBarTracker[barId].rrquestID = rrquestID
    RRQProgressBar.UpdateStatusWindow( barId )
end

function RRQProgressBar.GetRRQuestIDfromWindowID( barId )
    
    if( RRQProgressBarTracker[barId] == nil )
    then
        ERROR( L"RRQProgressBar.GetRRQuestIDfromWindowID( barId): No RRQ window with that ID exists" )
        return nil
    end
    
    return RRQProgressBarTracker[barId].rrquestID
end

function RRQProgressBar.UpdateStatusWindow( windowID )
    if( RRQProgressBarTracker[windowID] == nil )
    then
        ERROR( L"RRQProgressBar.UpdateStatusWindow( windowID ): No RRQ window with that ID exists" )
        return
    end
    
    local rrqID = RRQProgressBarTracker[windowID].rrquestID
    
    if rrqID == 0
    then
        return -- I'm not set up with a valid RRQ
    end
    
    if( RRQProgressBar.RealmResourceQuestData[rrqID] == nil )
    then
        ERROR( L"RRQProgressBar.UpdateStatusWindow( windowID ): No RRQ data exists for quest ID:"..towstring(rrqID) )
        return
    end

    -- Update the Display
    RRQProgressBarTracker[windowID]:Update()
end

function RRQProgressBar.HasRRQuestData()
    return ( next(RRQProgressBar.RealmResourceQuestData) ~= nil )
end

-- convenience function for now, may go away if we want to be able to display many ongoing RRQs
function RRQProgressBar.GetFirstQuestData()
    for rrqID, rrqData in pairs( RRQProgressBar.RealmResourceQuestData )
    do
        return rrqData
    end
    return nil
end

-- returns the first RRQ we have data on that matches the specified display type
function RRQProgressBar.GetFirstQuestDataOfType(dType)
    for rrqID, rrqData in pairs( RRQProgressBar.RealmResourceQuestData )
    do
        if rrqData.displayType ~= nil and rrqData.displayType == dType
        then
            return rrqData
        end
    end
    return nil
end

--purely a testing function until server support is ready
function RRQProgressBar.SetDummyData()
    -- fake RRQ id#43
    RRQProgressBar.RealmResourceQuestData[43] = { rrquestID = 43, realmProgress = {}, 
                                                    paused = false, realmWithAccess = -1, 
                                                    displayType = GameData.RRQDisplayType.ERRQDISPLAY_LIVE_EVENT }
    -- GameData.RRQDisplayType.ERRQDISPLAY_DEFAULT, ERRQDISPLAY_LIVE_EVENT, ERRQDISPLAY_TOMB_KINGS
    -- realm 0 Neutral conditions/progress
    RRQProgressBar.RealmResourceQuestData[43].realmProgress[0] = { curVal=0, maxVal=1000000 }
    -- realm 1 Order conditions/progress
    RRQProgressBar.RealmResourceQuestData[43].realmProgress[1] = { curVal=250000, maxVal=1000000 }
    -- realm 2 Destro conditions/progress
    RRQProgressBar.RealmResourceQuestData[43].realmProgress[2] = { curVal=750000, maxVal=1000000 }

    BroadcastEvent( SystemData.Events.RRQ_LIST_UPDATED )
end

function RRQProgressBar.SetDummyDataTK()
    -- fake RRQ id#43
    RRQProgressBar.RealmResourceQuestData[43] = { rrquestID = 43, realmProgress = {}, 
                                                    paused = false, realmWithAccess = 2, 
                                                    displayType = GameData.RRQDisplayType.ERRQDISPLAY_TOMB_KINGS }
    -- GameData.RRQDisplayType.ERRQDISPLAY_DEFAULT, ERRQDISPLAY_LIVE_EVENT, ERRQDISPLAY_TOMB_KINGS

    -- realm 1 Order conditions/progress
    RRQProgressBar.RealmResourceQuestData[43].realmProgress[1] = { curVal=33, maxVal=100 }
    -- realm 2 Destro conditions/progress
    RRQProgressBar.RealmResourceQuestData[43].realmProgress[2] = { curVal=100, maxVal=100 }

    BroadcastEvent( SystemData.Events.RRQ_LIST_UPDATED )
end

function RRQProgressBar.SetDummyDataOrder()
    -- fake RRQ id#43
    RRQProgressBar.RealmResourceQuestData[43] = { rrquestID = 43, realmProgress = {}, 
                                                    paused = false, realmWithAccess = -1, 
                                                    displayType = GameData.RRQDisplayType.ERRQDISPLAY_DEFAULT }

    RRQProgressBar.RealmResourceQuestData[43].realmProgress[1] = { curVal=22, maxVal=100 }


    BroadcastEvent( SystemData.Events.RRQ_LIST_UPDATED )
end

function RRQProgressBar.SetDummyDataDestro()
    -- fake RRQ id#43
    RRQProgressBar.RealmResourceQuestData[43] = { rrquestID = 43, realmProgress = {}, 
                                                    paused = false, realmWithAccess = -1, 
                                                    displayType = GameData.RRQDisplayType.ERRQDISPLAY_DEFAULT }

    RRQProgressBar.RealmResourceQuestData[43].realmProgress[2] = { curVal=35, maxVal=100 }

    BroadcastEvent( SystemData.Events.RRQ_LIST_UPDATED )
end

--purely a testing function until server support is ready
function RRQProgressBar.UpdateDummyData()
    if RRQProgressBar.RealmResourceQuestData[43] ~= nil
    then
        if RRQProgressBar.RealmResourceQuestData[43].realmProgress[0] ~= nil
        then
            RRQProgressBar.RealmResourceQuestData[43].realmProgress[0].curVal = RRQProgressBar.RealmResourceQuestData[43].realmProgress[0].curVal + 1000
            DEBUG(L"RRQProgressBar.RealmResourceQuestData[43].realmProgress[0].curVal="..RRQProgressBar.RealmResourceQuestData[43].realmProgress[0].curVal)
        end
        if RRQProgressBar.RealmResourceQuestData[43].realmProgress[1] ~= nil
        then
            RRQProgressBar.RealmResourceQuestData[43].realmProgress[1].curVal = RRQProgressBar.RealmResourceQuestData[43].realmProgress[1].curVal + 5
            DEBUG(L"RRQProgressBar.RealmResourceQuestData[43].realmProgress[1].curVal="..RRQProgressBar.RealmResourceQuestData[43].realmProgress[1].curVal)
        end
        if RRQProgressBar.RealmResourceQuestData[43].realmProgress[2] ~= nil
        then
            RRQProgressBar.RealmResourceQuestData[43].realmProgress[2].curVal = RRQProgressBar.RealmResourceQuestData[43].realmProgress[2].curVal + 3
            DEBUG(L"RRQProgressBar.RealmResourceQuestData[43].realmProgress[2].curVal="..RRQProgressBar.RealmResourceQuestData[43].realmProgress[2].curVal)
        end
        --RRQProgressBar.OnRRQsUpdated()
        BroadcastEvent( SystemData.Events.RRQ_LIST_UPDATED )
    else
        DEBUG(L"RRQProgressBar.UpdateDummyData(): RRQ 43 is nil!")
    end

end

-- EASystem OnRRQsUpdated will happen before mods like WorldMapWindow
function RRQProgressBar.OnRRQsUpdated()
    -- 1) Update RRQProgressBar.RealmResourceQuestData from client data. 
    -- comment out the next line to use the dummy data lua functions without having their data replaced by the client's
    RRQProgressBar.RealmResourceQuestData = GetRRQData()
    
    -- 2) Loop over the RRQ Status trackers that have been created so far and update
    for windowID, windowData in pairs( RRQProgressBarTracker )
    do
        RRQProgressBar.UpdateStatusWindow( windowID )
    end
    
    for listenerID, listenerFunc in pairs( RRQProgressBar.UpdateListeners )
    do
        listenerFunc()
    end
end

function RRQProgressBar.DefaultOnMouseoverCallback()

    
    --Current Points
    local barId = WindowGetId( SystemData.ActiveWindow.name )
    local rrqID = RRQProgressBar.GetRRQuestIDfromWindowID(barId)
    if ( rrqID ~= nil and RRQProgressBar.RealmResourceQuestData[rrqID] ~= nil )
    then
        local rrqData = RRQProgressBar.RealmResourceQuestData[rrqID]
        
        local tooltipSet = TooltipLookupTable[rrqData.displayType]
        if tooltipSet == nil 
        then
            tooltipSet = TooltipLookupTable[GameData.RRQDisplayType.ERRQDISPLAY_DEFAULT]
        end
        
        Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
        Tooltips.SetTooltipText( 1, 1, GetStringFromTable("WorldControl", tooltipSet.header) )
        Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
        
        Tooltips.SetTooltipText( 2, 1, GetStringFromTable("WorldControl", tooltipSet.desc) )
        
        local iRow = 3
        
        -- Current counter numbers per-realm. May only show a percentage
        -- tooltip won't show Neutral realm right now, maybe later if we ever do use it
        for iRealm=GameData.Realm.ORDER, GameData.Realm.DESTRUCTION --[1, 2]
        do
            if rrqData.realmProgress[iRealm] ~= nil 
            then
                local params = { GetRealmName( iRealm ), towstring(rrqData.realmProgress[iRealm].curVal) }
                local stringID = StringTables.WorldControl.TOOLTIP_RRQSTATUS_PROGRESS
                if (rrqData.realmProgress[iRealm].maxVal == 100)
                then
                    stringID = StringTables.WorldControl.TOOLTIP_RRQSTATUS_PROGRESS_PERCENT
                end
                
                Tooltips.SetTooltipText( iRow, 1, GetStringFormatFromTable( "WorldControl", 
                                                    stringID,
                                                    params ) )
                Tooltips.SetTooltipColorDef( iRow, 1, Tooltips.COLOR_HEADING )
                iRow = iRow + 1
            end
        end -- end for each realm
        
        if rrqData.displayType == GameData.RRQDisplayType.ERRQDISPLAY_TOMB_KINGS
        then
            -- For TK we display access message if there's an ongoing expedition
            if rrqData.minutesUntilUnpause == 0
            then
                local params = { GetRealmName( rrqData.realmWithAccess ), GetCityNameForRealm( rrqData.realmWithAccess ) }
                Tooltips.SetTooltipText( iRow, 1, GetStringFormatFromTable( "WorldControl", 
                                                                            tooltipSet.access,
                                                                            params ) )
                Tooltips.SetTooltipColorDef( iRow, 1, Tooltips.COLOR_HEADING )
                iRow = iRow + 1
            end
        else
            -- if a realm has exclusive access, mention that
            if rrqData.realmWithAccess == GameData.Realm.ORDER or rrqData.realmWithAccess == GameData.Realm.DESTRUCTION
            then
                local params = { GetRealmName( rrqData.realmWithAccess ), GetCityNameForRealm( rrqData.realmWithAccess ) }
                Tooltips.SetTooltipText( iRow, 1, GetStringFormatFromTable( "WorldControl", 
                                                                            tooltipSet.access,
                                                                            params ) )
                Tooltips.SetTooltipColorDef( iRow, 1, Tooltips.COLOR_HEADING )
                iRow = iRow + 1
            end
        end

        -- if the rrq is currently paused ("locked"), mention that too
        if rrqData.paused
        then
            local params = {
                towstring(rrqData.minutesUntilUnpause),
                towstring(math.floor(rrqData.minutesUntilUnpause / 1440)),
                towstring(math.floor((rrqData.minutesUntilUnpause % 1440) / 60)),
                towstring(math.floor(rrqData.minutesUntilUnpause % 60)),
            }
            Tooltips.SetTooltipText( iRow, 1, GetStringFormatFromTable( "WorldControl", tooltipSet.paused, params ) )
            Tooltips.SetTooltipColorDef( iRow, 1, Tooltips.COLOR_HEADING )
            iRow = iRow + 1
        end
    end
    
    
    Tooltips.Finalize()
    
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_TOP )
end

