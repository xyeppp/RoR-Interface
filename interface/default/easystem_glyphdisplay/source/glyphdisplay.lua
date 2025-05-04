----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

GlyphDisplay = {}

-- this could go in datautils perhaps, but I'm concerned about the ordering of SystemData.Events.TOME_WAR_JOURNAL_ENTRY_UPDATED handlers
GlyphDisplay.cachedJournalEntries = {}

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

local GlyphDisplayInstances = {}
local TooltipIdToGlyphDataMap = {}
local TomeOpenJournalEntryCallback = nil -- let the Tome mod set this to TomeWindow.OpenTomeToEntry to avoid bad dependencies

local GLYPH_ICON_WIDTH = 32
local GLYPH_SPACE = 5
local MAX_GLYPH_LINES = 10
local DEFAULT_CONTAINER_WIDTH = 365
local layoutRegistered = false

----------------------------------------------------------------
-- Local/Utility Functions
----------------------------------------------------------------

-- child window setup, should be called whenever the entry this instance is tracking is changed
local function SetupGlyphDisplay (self)
    -- DEBUG (L"SetupGlyphDisplay: ");
    -- DEBUG (L"   bar:     "..StringToWString (self.windowName));
    -- DEBUG (L"   anchor:  "..StringToWString (self.parentName));
    
    -- Reanchor the main window
    -- This should update the initial anchors for all child windows:
    WindowClearAnchors (self.windowName);
    WindowAddAnchor (self.windowName, "topleft", self.parentName, "topleft", 0, 0);
    WindowAddAnchor (self.windowName, "bottomright", self.parentName, "bottomright", 0, 0); 

    for iLine=1, MAX_GLYPH_LINES
    do
        WindowSetShowing(self.windowName.."Line"..iLine, false)
    end
    
    -- make sure enough child glyph windows exist and are set to our glyphs
    if self.entryId > 0 
    then
        local entryData = GlyphDisplay.GetWarJournalEntryData( self.entryId )
        if entryData ~= nil 
        then
            local glyphIndex = 0
            local glyphAnchorWindow = self.windowName
            local glyphXOffset = 0
            local glyphYOffset = 0
            for index, glyphActivityData in ipairs( entryData.glyphActivities ) -- usually only one glyphActivity but just grab from all of em
            do
                if( glyphActivityData.name == L"" )
                then
                    continue
                end
                for index, lineData in ipairs( glyphActivityData.glyphLines  ) do 
                    local lineAnchorWindow1 = nil -- for anchoring a background around the set of glyphs in the line
                    local lineAnchorWindow2 = nil
                    local glyphWindowName = nil
                    
                    if( lineData.name == L"" )
                    then
                        continue
                    end
                    for index, glyphData in ipairs( lineData.glyphs ) do
                        if( glyphData.name == L"" )
                        then
                            continue
                        end
                        glyphIndex = glyphIndex + 1
                        
                        glyphWindowName = self.windowName.."Glyph"..glyphIndex
                        if( self.glyphWindowCount < glyphIndex ) then
                            CreateWindowFromTemplate( glyphWindowName, "WorldMapGlyph", self.windowName )                         
                            WindowAddAnchor( glyphWindowName, "topleft", glyphAnchorWindow, "topleft", glyphXOffset, glyphYOffset ) 
                            
                            -- set a unique ID, there won't be enough of these for this to be that slow
                            local tooltipId = 1
                            while (TooltipIdToGlyphDataMap[tooltipId] ~= nil) do
                                tooltipId = tooltipId + 1
                            end
                            WindowSetId( glyphWindowName, tooltipId ) 
                            -- DEBUG(L"SetupGlyphDisplay using tooltipId="..tooltipId)
                            
                            self.glyphWindowCount = self.glyphWindowCount + 1
                        end
                        
                        -- Set the Id to glyphData mapping
                        local tooltipId = WindowGetId( glyphWindowName )
                        TooltipIdToGlyphDataMap[tooltipId] = { glyphId = glyphData.id, 
                                                               lineId = lineData.id, 
                                                               glyphActivityId = glyphActivityData.id,
                                                               entryId = self.entryId }
                        
                        -- Set the image in C
                        TomeSetWarJournalGlyphImage( glyphData.id )
                        
                        -- Set the texture
                        DynamicImageSetTexture( glyphWindowName, glyphData.textureName, 64, 64 )
                        
                        local textureAlpha = 1.0
                        if( not glyphData.isUnlocked )
                        then
                            textureAlpha = 0.3
                        end
                        
                        WindowSetAlpha( glyphWindowName, textureAlpha )
                        
                        glyphXOffset = GLYPH_ICON_WIDTH + GLYPH_SPACE
                        glyphAnchorWindow = glyphWindowName
                        
                        if lineAnchorWindow1 == nil
                        then
                            lineAnchorWindow1 = glyphWindowName
                        end
                    end -- end for each glyphData
                    
                    -- anchor a background around the glyph line
                    lineAnchorWindow2 = glyphWindowName
                    local lineWindowName = self.windowName.."Line"..index
                    if lineAnchorWindow1 ~= nil and lineAnchorWindow2 ~= nil and DoesWindowExist(lineWindowName)
                    then
                        -- DEBUG(L"SetupGlyphDisplay: Anchoring line background")
                        WindowClearAnchors (lineWindowName);
                        WindowAddAnchor (lineWindowName, "topleft", lineAnchorWindow1, "topleft", -2, -2);
                        WindowAddAnchor (lineWindowName, "bottomright", lineAnchorWindow2, "bottomright", 2, 2);
                        WindowSetShowing(lineWindowName, true)
                    end
                    glyphWindowName = nil
                end -- end for each glyphLines
            end -- end for each glyphActivityData
            
        end -- if entryData ~= nil
    end -- if self.entryId > 0
    
    --may have been resized with layout editor... 
    local newWidth, newHeight = WindowGetDimensions(self.windowName)
    local scaleFactor = newWidth / DEFAULT_CONTAINER_WIDTH
    WindowSetRelativeScale( self.windowName, scaleFactor )    
end

-- updates glyph icon alpha based on which glyphs are now unlocked
-- glyph windows must have already been created in SetupGlyphDisplay
local function UpdateGlyphDisplay (self)
    -- DEBUG (L"UpdateGlyphDisplay: ");
    -- DEBUG (L"   bar:     "..StringToWString (self.windowName));
    -- DEBUG (L"   anchor:  "..StringToWString (self.parentName));
    -- DEBUG (L"   entryId:  "..self.entryId);
    
    if self.entryId > 0 and GameData.WarJournal.updatedEntry == self.entryId
    then
        local entryData = GlyphDisplay.GetWarJournalEntryData( self.entryId )
        if entryData ~= nil 
        then
            local glyphIndex = 0
            for index, glyphActivityData in ipairs( entryData.glyphActivities )
            do
                if( glyphActivityData.name == L"" )
                then
                    continue
                end
                for index, lineData in ipairs( glyphActivityData.glyphLines  ) do 
                    if( lineData.name == L"" )
                    then
                        continue
                    end
                    for index, glyphData in ipairs( lineData.glyphs ) do
                        if( glyphData.name == L"" )
                        then
                            continue
                        end
                        glyphIndex = glyphIndex + 1
                        local glyphWindowName = self.windowName.."Glyph"..glyphIndex
                        
                        local textureAlpha = 1.0
                        if( not glyphData.isUnlocked )
                        then
                            textureAlpha = 0.3
                        end
                        WindowSetAlpha( glyphWindowName, textureAlpha )
                    end -- end for each glyphData
                end -- end for each glyphLines
            end -- end for each glyphActivityData
            
            if self.entryId == GlyphDisplay.rootDisplayId
            then
                WindowSetHandleInput("EA_Window_GlyphTracker", true)
            end
            
        end -- if entryData ~= nil
    end
    
end

----------------------------------------------------------------
-- GlyphDisplay Functions
----------------------------------------------------------------

-- tries to find a cached war journal entry rather than pulling a huge table
-- from the client each time
function GlyphDisplay.GetWarJournalEntryData( entryId )
    if entryId == nil or entryId < 1
    then
        return nil
    end
    for index, entryData in pairs( GlyphDisplay.cachedJournalEntries  ) 
    do 
        if index == entryId
        then
            -- DEBUG(L"GlyphDisplay.GetWarJournalEntryData cache hit for entry="..entryId)
            return entryData
        end
    end
    
    -- cache is missing it, so insert
    local entryData = TomeGetWarJournalEntryData( entryId )
    if entryData ~= nil 
    then
        -- DEBUG(L"GlyphDisplay.GetWarJournalEntryData cache miss for entry="..entryId)
        GlyphDisplay.cachedJournalEntries[entryId] = entryData
        return entryData
    end
    
    -- DEBUG(L"GlyphDisplay.GetWarJournalEntryData could not find data for entryId="..entryId)
    return nil
end

function GlyphDisplay.RegisterTomeOpenJournalCallback( callbackFunc )
    TomeOpenJournalEntryCallback = callbackFunc
end

function GlyphDisplay.Initialize()
   RegisterEventHandler( SystemData.Events.TOME_WAR_JOURNAL_ENTRY_UPDATED, "GlyphDisplay.OnUpdateEntry" )
   RegisterEventHandler( SystemData.Events.PLAYER_ZONE_CHANGED, "GlyphDisplay.OnPlayerZoneChangedUpdateHUDTracker")
   RegisterEventHandler( SystemData.Events.TOME_INITIALIZED_FOR_PLAYER, "GlyphDisplay.OnPlayerZoneChangedUpdateHUDTracker")  
   
   GlyphDisplay.OnPlayerZoneChangedUpdateHUDTracker() -- needs to happen after a ui reload too
end

function GlyphDisplay.Shutdown()
    UnregisterEventHandler( SystemData.Events.TOME_WAR_JOURNAL_ENTRY_UPDATED, "GlyphDisplay.OnUpdateEntry" )

    -- The anchor points for the progress bars should destroy their children
    -- when they get destroyed, but just in case, I'll destroy the windows here.
    for k, v in pairs (GlyphDisplayInstances) do
        if (nil ~= v.windowName) then
            DestroyWindow (v.windowName);
        end
    end

    GlyphDisplayInstances = {}
    GlyphDisplay.cachedJournalEntries = {}
end

function GlyphDisplay.Create( windowName, parentName, displayType )

    -- DEBUG (L"GlyphDisplay.Create: ");
    
    local windowTemplateName = "GlyphDisplayTemplate" -- default glyph display template
    local updateFunc = UpdateGlyphDisplay
    local setupFunc  = SetupGlyphDisplay
    -- in the future, if there are various displaytypes they can override the above local vars
    
    CreateWindowFromTemplate(windowName, windowTemplateName, parentName);
        
    local instanceId = 0
    while (GlyphDisplayInstances[instanceId] ~= nil) do
        instanceId = instanceId + 1
    end
    
    -- record the ID so we can trigger callbacks
    WindowSetId(windowName, instanceId)

    GlyphDisplayInstances[instanceId] = 
    { 
        instanceId  = instanceId, 
        windowName  = windowName,
        parentName  = parentName,
        
        Initialize  = setupFunc,
        Update      = updateFunc,  -- varies by style of RRQ bars: Standard, Tugowar (Live Event), Tomb Kings
        
        entryId      = 0, -- War Journal Entry ID corresponding to an entry with glyphs. Use SetEntryID
        
        glyphWindowCount = 0,
    }
    
    GlyphDisplayInstances[instanceId]:Initialize()
    GlyphDisplayInstances[instanceId]:Update()
    
    return instanceId
end

function GlyphDisplay.Destroy(instanceId)
    if (GlyphDisplayInstances[instanceId] == nil) or (GlyphDisplayInstances[instanceId].windowName == nil) then
        return
    end

    DestroyWindow(GlyphDisplayInstances[instanceId].windowName)
end

function GlyphDisplay.Hide(instanceId)
    if (GlyphDisplayInstances[instanceId] == nil) or (GlyphDisplayInstances[instanceId].windowName == nil) then
        return
    end
    
    WindowSetShowing(GlyphDisplayInstances[instanceId].windowName, false)
end

function GlyphDisplay.Show(instanceId)
    if (GlyphDisplayInstances[instanceId] == nil) or (GlyphDisplayInstances[instanceId].windowName == nil) then
        return
    end

    WindowSetShowing(GlyphDisplayInstances[instanceId].windowName, true)
end

--Associate one particular War Journal Entry with one Glyph Display instance
function GlyphDisplay.SetEntryID( instanceId, entryId )
    -- DEBUG(L"GlyphDisplay.SetEntryID instanceId="..towstring(instanceId)..L" entryId="..towstring(entryId))
    if( GlyphDisplayInstances[instanceId] == nil )
    then
        ERROR( L"GlyphDisplay.SetEntryID( instanceId, entryId): No Glyph Display with that instanceId exists" )
        return
    end

    GlyphDisplayInstances[instanceId].entryId = entryId
    GlyphDisplayInstances[instanceId]:Initialize() -- setup existing glyph windows, line borders, etc for this entry
    GlyphDisplay.UpdateInstance( instanceId )
end

function GlyphDisplay.GetEntryIDfromWindowID( instanceId )
    
    if( GlyphDisplayInstances[instanceId] == nil )
    then
        ERROR( L"GlyphDisplay.GetEntryIDfromWindowID( instanceId): No Glyph Display with that instanceId exists" )
        return nil
    end
    
    return GlyphDisplayInstances[instanceId].entryId
end

function GlyphDisplay.UpdateInstance( instanceId )
    if( GlyphDisplayInstances[instanceId] == nil )
    then
        ERROR( L"GlyphDisplay.UpdateInstance( instanceId ): No Glyph Display with that instanceId exists" )
        return
    end
    
    local entryId = GlyphDisplayInstances[instanceId].entryId
    
    if entryId == 0
    then
        return -- I'm not set up with a valid war journal entry
    end

    -- Update the Display
    GlyphDisplayInstances[instanceId]:Update()
end

-- Updates any existing Glyph Display instances when a war journal entry that applies to them is updated
function GlyphDisplay.OnUpdateEntry()
    -- DEBUG(L"GlyphDisplay.OnUpdateEntry() ")
    -- 1) Update from client data if we have it cached
    for index, entryData in pairs( GlyphDisplay.cachedJournalEntries  ) 
    do 
        if index == GameData.WarJournal.updatedEntry
        then
            -- DEBUG(L"GlyphDisplay.OnUpdateEntry cache expire for entry="..index)
            GlyphDisplay.cachedJournalEntries[index] = nil
        end
    end
    
    -- 2) Loop over the Glyph Display instances that have been created so far and update
    for instanceId, windowData in pairs( GlyphDisplayInstances )
    do
        GlyphDisplay.UpdateInstance( instanceId )
    end
    
end

-- returns true if the given zone's parent map (pairing) is one of the three real racial pairings
function GlyphDisplay.DoesZoneHaveZoneControl( zoneId )
    if zoneId ~= nil and zoneId > 0 
    then
        local parentMap = MapGetParentMap( GameDefs.MapLevel.ZONE_MAP, zoneId )
        if parentMap ~= nil and parentMap.mapNumber < GameData.ExpansionMapRegion.FIRST and parentMap.mapNumber > 0
        then
            return true
        end
    end

    return false
end

--[[HUD tracker above the minimap has to be setup/updated if in a zone that has glyphs ]]
function GlyphDisplay.OnPlayerZoneChangedUpdateHUDTracker()
    -- DEBUG(L"GlyphDisplay.OnPlayerZoneChangedUpdateHUDTracker()")
    
    if not GlyphDisplay.DoesZoneHaveZoneControl( GameData.Player.zone )
    then
        local entryId = TomeGetWarJournalGlyphEntryForZone( GameData.Player.zone ) 
        if entryId ~= nil 
        then
            -- another instance, this one is attached to root and appears above the minimap
            if not DoesWindowExist("EA_Window_GlyphTrackerInstance")
            then
                GlyphDisplay.rootDisplayId = GlyphDisplay.Create( "EA_Window_GlyphTrackerInstance", 
                                                                        "EA_Window_GlyphTrackerContainer",                                                                  
                                                                        nil )
                -- Register this window for movement with the Layout Editor
                LayoutEditor.RegisterWindow( "EA_Window_GlyphTracker",  
                                             GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_GLYPH_TRACKER_NAME ),
                                             GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_GLYPH_TRACKER_DESC ),
                                             false, false,
                                             true, nil )
                layoutRegistered = true
            end

            -- some zones without zone control may use that space for something else
            -- such as Glyphs for the Necropolis of Zandri zone
            -- show locked/unlocked glyphs tracker for this zone where the zone control bar was
            WindowSetHandleInput("EA_Window_GlyphTracker", true)
            GlyphDisplay.SetEntryID( GlyphDisplay.rootDisplayId, entryId )
            GlyphDisplay.Show( GlyphDisplay.rootDisplayId )
            
            
            -- DEBUG(L"GlyphDisplay.OnPlayerZoneChangedUpdateGlyphTracker() showed tracker")
            return
        end
    end
    
    -- if we setup the tracker before but crossed into a zone without glyphs, hide it
    if DoesWindowExist("EA_Window_GlyphTrackerInstance")
    then
        GlyphDisplay.SetEntryID( GlyphDisplay.rootDisplayId, 0 )
        GlyphDisplay.Hide( GlyphDisplay.rootDisplayId )
    end
    WindowSetHandleInput("EA_Window_GlyphTracker", false)
end

function GlyphDisplay.OnMouseOverGlyph()
    -- DEBUG(L"GlyphDisplay.OnMouseOverGlyph")
    local tooltipId = WindowGetId( SystemData.MouseOverWindow.name )
    if tooltipId < 1 or TooltipIdToGlyphDataMap[tooltipId] == nil
    then
        return
    end

    local function GetTableById( tableToSearch, id )
        for index, testTable in ipairs( tableToSearch ) 
        do
            if( testTable.id == id )
            then
                return testTable
            end
        end
        
        return {}
    end
    
    local IdSet = TooltipIdToGlyphDataMap[tooltipId]
    local entryData = GlyphDisplay.GetWarJournalEntryData( IdSet.entryId )
    if entryData == nil
    then
        return
    end
    local glyphActivity = GetTableById( entryData.glyphActivities, IdSet.glyphActivityId )
    local glyphLine = GetTableById( glyphActivity.glyphLines, IdSet.lineId )
    local glyphData = GetTableById( glyphLine.glyphs, IdSet.glyphId )
    
    Tooltips.CreateGlyphTooltip( glyphData, Tooltips.ANCHOR_WINDOW_BOTTOM )
end

function GlyphDisplay.OnClickGlyph()
    -- DEBUG(L"GlyphDisplay.OnClickGlyph")
    local tooltipId = WindowGetId( SystemData.MouseOverWindow.name )
    if tooltipId < 1 or TooltipIdToGlyphDataMap[tooltipId] == nil or TomeOpenJournalEntryCallback == nil
    then
        return
    end
    
    local IdSet = TooltipIdToGlyphDataMap[tooltipId]
    TomeOpenJournalEntryCallback( GameData.Tome.SECTION_WAR_JOURNAL, IdSet.entryId )
end
