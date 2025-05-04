----------------------------------------------------------------
-- TomeWindow - WarJournal Implementation
--
--  This file contains all of the initialization and callack
--  functions for the History & Lore section of the Tome of Knowledge.
-- 
----------------------------------------------------------------


-- Constants

-- Variables

TomeWindow.HistoryAndLore = {}
TomeWindow.HistoryAndLore.TOCData = nil
TomeWindow.HistoryAndLore.selectedPairing = 0
TomeWindow.HistoryAndLore.curZoneData = nil

TomeWindow.HistoryAndLore.pairingWindowCount   = 0
TomeWindow.HistoryAndLore.tierWindowCount      = 0
TomeWindow.HistoryAndLore.zoneWindowCounts     = {}
TomeWindow.HistoryAndLore.entryWindowCount     = 0


-- Local Functions

local function GetPairingData( pairingId )

    if( TomeWindow.HistoryAndLore.TOCData == nil ) then
        return nil
    end
    
    for index, data in ipairs( TomeWindow.HistoryAndLore.TOCData ) do
        if( data.id == pairingId ) then
            return data
         end
    end
    
    return nil
end

----------------------------------------------------------------
-- History & Lore Functions
----------------------------------------------------------------
function TomeWindow.InitializeHistoryAndLore()
    
    TomeWindow.HistoryAndLore.pairingWindowCount   = 0
    TomeWindow.HistoryAndLore.tierWindowCount      = 0
    TomeWindow.HistoryAndLore.zoneWindowCounts     = {}
    TomeWindow.HistoryAndLore.entryWindowCount     = 0


    -- History & Lore TOC
    TomeWindow.Pages[ TomeWindow.PAGE_HISTORY_AND_LORE_TOC ]
        = TomeWindow.NewPageData( TomeWindow.Sections.SECTION_LORE,
                    "HistoryAndLoreTOC", 
                    nil,
                    nil,
                    nil,
                    nil,
                    nil,
                    nil )
                    
   TomeWindow.SetPageHeaderText( TomeWindow.PAGE_HISTORY_AND_LORE_TOC,
                                 GetString( StringTables.Default.LABEL_HISTORY_AND_LORE ), 
                                 L"" )
                    
    --  History & Lore Zone Info
    TomeWindow.Pages[ TomeWindow.PAGE_HISTORY_AND_LORE_ZONE_INFO ]
        = TomeWindow.NewPageData( TomeWindow.Sections.SECTION_LORE,
                    "HistoryAndLoreZoneInfo", 
                    TomeWindow.UpdateHistoryAndLoreZone,
                    TomeWindow.OnHistoryAndLoreZoneInfoUpdateNavButtons,
                    TomeWindow.OnHistoryAndLoreZoneInfoPreviousPage,
                    TomeWindow.OnHistoryAndLoreZoneInfoNextPage, 
                    TomeWindow.OnHistoryAndLoreZoneInfoMouseOverPreviousPage,
                    TomeWindow.OnHistoryAndLoreZoneInfoMouseOverNextPage )
                    
    --  History & Lore Entry Info
    TomeWindow.Pages[ TomeWindow.PAGE_HISTORY_AND_LORE_ENTRY_INFO ]
        = TomeWindow.NewPageData( TomeWindow.Sections.SECTION_LORE,
                    "HistoryAndLoreEntryInfo", 
                    TomeWindow.ShowHistoryAndLoreEntry,
                    TomeWindow.OnHistoryAndLoreEntryInfoUpdateNavButtons,
                    TomeWindow.OnHistoryAndLoreEntryInfoPreviousPage,
                    TomeWindow.OnHistoryAndLoreEntryInfoNextPage, 
                    TomeWindow.OnHistoryAndLoreEntryInfoMouseOverPreviousPage,
                    TomeWindow.OnHistoryAndLoreEntryInfoMouseOverNextPage )
                    

    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.TOME_HISTORY_AND_LORE_TOC_UPDATED, "TomeWindow.OnHistoryAndLoreTOCUpdated")
    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.TOME_HISTORY_AND_LORE_ZONE_UPDATED, "TomeWindow.OnHistoryAndLoreZoneUpdated")

    -- TOC Page
    ButtonSetText( "HistoryAndLorePairing1", GetString( StringTables.Default.TEXT_PAIRING_1 ) )
    ButtonSetText( "HistoryAndLorePairing2", GetString( StringTables.Default.TEXT_PAIRING_2 ) )
    ButtonSetText( "HistoryAndLorePairing3", GetString( StringTables.Default.TEXT_PAIRING_3 ) )

    PageWindowAddPageBreak( "HistoryAndLoreTOCPageWindow", "HistoryAndLoreZonesLabel" )  
    
    LabelSetText("HistoryAndLoreZonesLabel", GetString( StringTables.Default.LABEL_ZONES ) )

    -- Zone Info Page
    LabelSetText( "HistoryAndLoreZoneInfoEntryLabel", GetString( StringTables.Default.LABEL_ENTRIES ) )

    TomeWindow.UpdateHistoryAndLoreTOC()
end


function TomeWindow.OnHistoryAndLoreTOCUpdated()    
    -- Update the TOC
    TomeWindow.UpdateHistoryAndLoreTOC()
    
    -- Update the Zone
    if( TomeWindow.HistoryAndLore.curZoneData ) then
        TomeWindow.UpdateHistoryAndLoreZone( TomeWindow.HistoryAndLore.curZoneData.id )
    end
end


function TomeWindow.UpdateHistoryAndLoreTOC()

    TomeWindow.HistoryAndLore.TOCData = TomeGetHistoryAndLoreTOC()
    
    -- Sorth the pairing and zones lists by their names
    for pairingIndex, pairingData in ipairs( TomeWindow.HistoryAndLore.TOCData ) do
        for tierIndex, tierData in ipairs( pairingData.tiers ) do
            table.sort( tierData.zones, DataUtils.AlphabetizeByNames )  
        end
    end
    
    -- Update the selected pairing
    TomeWindow.ShowHistoryAndLorePairing( TomeWindow.GetSelectedHistoryAndLorePairing() )
   
   
end


function TomeWindow.SelectActiveHistoryAndLorePairing()
    local pairingId = WindowGetId( SystemData.ActiveWindow.name )
    TomeWindow.ShowHistoryAndLorePairing( pairingId )
end

function TomeWindow.GetSelectedHistoryAndLorePairing()
    if( TomeWindow.HistoryAndLore.selectedPairing ~= 0 ) then
        return TomeWindow.HistoryAndLore.selectedPairing
    elseif( TomeWindow.HistoryAndLore.TOCData ) then
        if( TomeWindow.HistoryAndLore.TOCData[1] ) then
            return TomeWindow.HistoryAndLore.TOCData[1].id
        end
    end
    
    return nil
end


function TomeWindow.ShowHistoryAndLorePairing( pairingId )

    local pairingData = GetPairingData( pairingId )
    if( pairingData == nil ) then
        ERROR(L"Error in TomeWindow.ShowHistoryAndLorePairing(): pairingId is invalid" )
        return
    end 
    
    TomeWindow.HistoryAndLore.selectedPairing = pairingId
    
    -- set button states
    for index, _ in ipairs( TomeWindow.HistoryAndLore.TOCData )
    do
        ButtonSetPressedFlag( "HistoryAndLorePairing"..index, index == pairingId )
    end

    -- Set the Zones Label
    local text = GetStringFormat( StringTables.Default.LABEL_PAIRING_NAME_ZONES, { pairingData.name } )
    LabelSetText( "HistoryAndLoreZonesLabel", text )
    
    -- Build the Zones List     
    local parentWindow = "HistoryAndLoreTOCPageWindowContentsChild"     
    local anchorWindow = "HistoryAndLoreTOCPageWindowContentsChildZonesTOCAnchor"
    local xOffset = 0
    local yOffset = 5
    
    local tierCount = 0
    local zoneCounts = {}
    
    
    -- Loop through all the tiers
    for tierIndex, tierData in pairs( pairingData.tiers ) do    
    
        tierCount = tierCount + 1
        zoneCounts[ tierIndex ] = 0
        
        -- Create the Tier Label if necessary.    
        local tierWindowName = "HistoryAndLoreTierLabel"..tierIndex
        if( TomeWindow.HistoryAndLore.tierWindowCount < tierIndex ) then
        
            CreateWindowFromTemplate( tierWindowName, "HistoryAndLoreTierLabel", parentWindow )
            
            WindowAddAnchor( tierWindowName, "bottom", anchorWindow, "top", xOffset, yOffset )     
            
            LabelSetText( tierWindowName, GetStringFormat( StringTables.Default.LABEL_TIER_X, { tierIndex } ) )
            
            TomeWindow.HistoryAndLore.tierWindowCount = TomeWindow.HistoryAndLore.tierWindowCount + 1
            
        end
        
        anchorWindow = tierWindowName
        xOffset      = 20
        yOffset      = 5
        
        
        if( TomeWindow.HistoryAndLore.zoneWindowCounts[ tierIndex ] == nil ) then
            TomeWindow.HistoryAndLore.zoneWindowCounts[ tierIndex ] = 0
        end
            
        -- Loop through all of the zones
        for zoneIndex, zoneData in ipairs( tierData.zones ) do
                    
            zoneCounts[ tierIndex ] = zoneCounts[ tierIndex ] + 1        
            
                  
            -- Create the type window if necessary
            local zoneWindowName = "HistoryAndLoreZoneButtonTier"..tierIndex.."Zone"..zoneIndex
            if( TomeWindow.HistoryAndLore.zoneWindowCounts[ tierIndex ] < zoneIndex ) then
            
                CreateWindowFromTemplate( zoneWindowName, "HistoryAndLoreZoneButton", parentWindow )
                
                WindowAddAnchor( zoneWindowName, "bottom", anchorWindow, "top", xOffset, yOffset )     
                
                TomeWindow.HistoryAndLore.zoneWindowCounts[ tierIndex ] = TomeWindow.HistoryAndLore.zoneWindowCounts[ tierIndex ] + 1
            end
            anchorWindow = zoneWindowName   
            
            -- Set the Id
            WindowSetId( zoneWindowName, zoneData.id )         
            
            -- Set the Text
            ButtonSetText( zoneWindowName, zoneData.name )    
            
            xOffset      = 0
            
        end
        
         -- Show/Hide the appropriate number of zone windows.
        for index = 1, TomeWindow.HistoryAndLore.zoneWindowCounts[ tierIndex ] do
            local show = index <= zoneCounts[ tierIndex ]
            local windowName = "HistoryAndLoreZoneButtonTier"..tierIndex.."Zone"..index
            if( WindowGetShowing(windowName ) ~= show ) then
                WindowSetShowing(windowName, show ) 
            end
            if( show == false ) then
                WindowSetId( windowName, 0 ) 
            end
        end
        
        yOffset = 30
        xOffset = -20
    end
    
    -- Show/Hide the appropriate number of tier windows.
    for index = 1, TomeWindow.HistoryAndLore.tierWindowCount do
        local show = index <= tierCount
        local windowName = "HistoryAndLoreTierLabel"..index
        if( WindowGetShowing(windowName ) ~= show ) then
            WindowSetShowing(windowName, show ) 
        end
        if( show == false ) then
            WindowSetId( windowName, 0 ) 
        end
    end
    

    PageWindowUpdatePages( "HistoryAndLoreTOCPageWindow" )   
end

function TomeWindow.SelectHistoryAndLoreZone()
    local zoneId = WindowGetId( SystemData.ActiveWindow.name )
    TomeWindow.ShowHistoryAndLoreZone( zoneId )
end

function TomeWindow.ShowHistoryAndLoreZone( zoneId )

    -- Zone Pages are always unlocked    
    local params = { zoneId }
    TomeWindow.SetState( TomeWindow.PAGE_HISTORY_AND_LORE_ZONE_INFO, params )   
end

function TomeWindow.UpdateHistoryAndLoreZone( zoneId )
    --DEBUG(L"Showing Zone "..zoneId )

    TomeWindow.HistoryAndLore.curZoneData = TomeGetHistoryAndLoreZoneData( zoneId )
    if( TomeWindow.HistoryAndLore.curZoneData == nil ) then        
        ERROR(L"Error in TomeWindow.UpdateHistoryAndLoreZone(): zoneId is invalid" )
        return
    end
    
    -- Set the Name
    LabelSetText( "HistoryAndLoreZoneInfoName", StringUtils.ToUpperZoneName( TomeWindow.HistoryAndLore.curZoneData.name ) )
    
    -- Set the Map
    TomeWindow.UseMap( "HistoryAndLoreZoneInfoMapAnchor", SystemData.MapLevel.ZONE, TomeWindow.HistoryAndLore.curZoneData.id )
    
    -- Set the Text
    local text = TomeWindow.HistoryAndLore.curZoneData.text
    if( text == L"" ) then
        text = L" Here is some placeholder text about this zone. "
    end
    LabelSetText( "HistoryAndLoreZoneInfoText", text )
    
        
    -- Build the Entries List     
    local parentWindow = "HistoryAndLoreZoneInfoPageWindowContentsChild"     
    local anchorWindow = "HistoryAndLoreZoneInfoEntryLabel"
    local xOffset = 0
    local yOffset = 5
    
    local entryCount = 0
        
    -- Loop through all of the zones
    for entryIndex, entryData in ipairs( TomeWindow.HistoryAndLore.curZoneData.entries ) do
                
        entryCount = entryCount + 1        
                
        -- Create the type window if necessary
        local entryWindowName = "HistoryAndLoreEntryWindow"..entryIndex
        if( TomeWindow.HistoryAndLore.entryWindowCount < entryIndex ) then
        
            CreateWindowFromTemplate( entryWindowName, "HistoryAndLoreEntryWindow", parentWindow )
            ButtonSetStayDownFlag( entryWindowName.."CompletedBtn", true )
            ButtonSetDisabledFlag( entryWindowName.."CompletedBtn", true )      
            
            WindowAddAnchor( entryWindowName, "bottom", anchorWindow, "top", xOffset, yOffset )     
            
            TomeWindow.HistoryAndLore.entryWindowCount = TomeWindow.HistoryAndLore.entryWindowCount + 1
        end
        anchorWindow = entryWindowName   
        
        -- Set the Id
        WindowSetId( entryWindowName, entryIndex )         
        
        -- Set the Check Button
        ButtonSetPressedFlag( entryWindowName.."CompletedBtn", entryData.isUnlocked )
        
        -- Set the Text
        ButtonSetText( entryWindowName.."Text", entryData.name )
        local textWidth, textHeight = WindowGetDimensions( entryWindowName.."Text" )    
        
        -- Disabled locked entries
        ButtonSetDisabledFlag( entryWindowName.."Text", entryData.isUnlocked == false )
        
         -- Resize....        
        local MIN_HEIGHT = 30
        local OFFSET = 10
        local width, height = WindowGetDimensions( entryWindowName )
        if( textHeight + OFFSET > height ) then height = textHeight + OFFSET end
        if( MIN_HEIGHT > height ) then height = MIN_HEIGHT end
        WindowSetDimensions( entryWindowName, width, height )  
    end
    
    -- Show/Hide the appropriate number of entry windows.
    for index = 1, TomeWindow.HistoryAndLore.entryWindowCount do
        local show = index <= entryCount
        local windowName = "HistoryAndLoreEntryWindow"..index
        if( WindowGetShowing(windowName ) ~= show ) then
            WindowSetShowing(windowName, show ) 
        end
        if( show == false ) then
           WindowSetId( windowName, 0 ) 
        end
    end
    
    -- Update the Page Window   
    PageWindowUpdatePages( "HistoryAndLoreZoneInfoPageWindow" ) 
    PageWindowSetCurrentPage( "HistoryAndLoreZoneInfoPageWindow", 1 )
    TomeWindow.OnHistoryAndLoreZoneInfoUpdateNavButtons()
           

    TomeWindow.SetPageHeaderText( TomeWindow.PAGE_HISTORY_AND_LORE_ZONE_INFO, 
                                  GetString( StringTables.Default.LABEL_HISTORY_AND_LORE ), 
                                  TomeWindow.HistoryAndLore.curZoneData.name )
                            
end

function TomeWindow.OnHistoryAndLoreZoneUpdated()
    if( TomeWindow.HistoryAndLore.curZoneData ) then
        if( TomeWindow.HistoryAndLore.curZoneData.id == GameData.HistoryAndLore.updatedZone ) then
            TomeWindow.ShowHistoryAndLoreZone( TomeWindow.HistoryAndLore.curZoneData.id )
        end
    end
end

function TomeWindow.OnMouseOverHistoryAndLoreMapPoint()

end


function TomeWindow.SelectHistoryAndLoreEntry()
   
    if( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) == true ) then
        return
    end
    
    local entryIndex = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
    local id = TomeWindow.HistoryAndLore.curZoneData.entries[entryIndex].id
    TomeWindow.ShowHistoryAndLoreEntry( id )
 
end

function TomeWindow.OnRightClickHistoryAndLoreEntry()
    if( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) == true )
    then
        return
    end
    
    local entryIndex = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )  
    local entryData = TomeWindow.HistoryAndLore.curZoneData.entries[entryIndex]
    
    TomeWindow.OpenBraggingRightsContextMenu( entryData.unlockEventId )
end


function TomeWindow.ShowHistoryAndLoreEntry( entryId )

    if( TomeIsHistoryAndLoreEntryUnlocked( entryId ) ~= true ) then
        return
    end
    
    
    TomeWindow.UpdateHistoryAndLoreEntry( entryId )    
      
    local params = { entryId }
    TomeWindow.SetState( TomeWindow.PAGE_HISTORY_AND_LORE_ENTRY_INFO, params )  
end

function TomeWindow.UpdateHistoryAndLoreEntry( entryId ) 

    --DEBUG(L"TomeWindow.ShowHistoryAndLoreEntry( "..entryId..L" )" )      
    
    local name = L""
    local text = L"No entry selected" 

    if( entryId ~= nil ) then
        local entryData = TomeGetHistoryAndLoreEntryData( entryId )
        if( entryData ~= nil ) then
            name = entryData.name
            text = entryData.text
            
            -- Load the zone if neccessary     
            local setZone = true
            if( TomeWindow.HistoryAndLore.curZoneData ~= nil ) then
                if( TomeWindow.HistoryAndLore.curZoneData.id == entryData.zoneId ) then
                    setZone = false
                end
            end
            
            if( setZone ) then    
                TomeWindow.UpdateHistoryAndLoreZone( entryData.zoneId )
            end
        end    
    end
   
    
    
    LabelSetText("HistoryAndLoreEntryInfoEntryName", wstring.upper( name ) )
    LabelSetText("HistoryAndLoreEntryInfoEntryText", text )
    
       
    PageWindowUpdatePages( "HistoryAndLoreEntryInfoPageWindow" )   
    PageWindowSetCurrentPage( "HistoryAndLoreZoneInfoPageWindow", 1 )
    TomeWindow.OnHistoryAndLoreEntryInfoUpdateNavButtons()
           
           
                           
    TomeWindow.SetPageHeaderText( TomeWindow.PAGE_HISTORY_AND_LORE_ENTRY_INFO,
                                  GetString( StringTables.Default.LABEL_HISTORY_AND_LORE ), 
                                  name )
                            
end


function TomeWindow.FlipToHistoryAndLoreEntry()  
    local params = {GameData.Tome.HistoryAndLore.CurrentEntry.id }
    TomeWindow.SetState( TomeWindow.PAGE_HISTORY_AND_LORE_INFO, params )
    TomeWindow.OnViewEntry( GameData.Tome.SECTION_HISTORY_AND_LORE, GameData.Tome.HistoryAndLore.CurrentEntry.id )
end






-- > History & Lore  Info Nav Buttons
function TomeWindow.OnHistoryAndLoreZoneInfoUpdateNavButtons()
    if ( TomeWindow.GetCurrentState() ~= TomeWindow.PAGE_HISTORY_AND_LORE_ZONE_INFO ) then
        return
    end
    local curPage   = PageWindowGetCurrentPage("HistoryAndLoreZoneInfoPageWindow")
    local numPages  = PageWindowGetNumPages("HistoryAndLoreZoneInfoPageWindow")
    WindowSetShowing( "TomeWindowPreviousPageButton", curPage > 1 )
    WindowSetShowing( "TomeWindowNextPageButton", curPage + 2 <= numPages )
    
    -- Only show the map when on the first page
    TomeWindow.ShowMap( curPage == 1 ) 
end

function TomeWindow.OnHistoryAndLoreZoneInfoPreviousPage()
    TomeWindow.FlipPageWindowBackward( "HistoryAndLoreZoneInfoPageWindow")
end

function TomeWindow.OnHistoryAndLoreZoneInfoMouseOverPreviousPage()    
    local lines = {}    
    local curPage   = PageWindowGetCurrentPage("HistoryAndLoreZoneInfoPageWindow")
    local numPages  = PageWindowGetNumPages("HistoryAndLoreZoneInfoPageWindow")
    if( curPage > 1 ) then
        -- Previous Pages
        lines[1] = TomeWindow.HistoryAndLore.curZoneData.name
        lines[2] = GetString( StringTables.Default.TEXT_CONTINUED )
    end 
    TomeWindow.CreateBackButtonTooltip( lines )
end

function TomeWindow.OnHistoryAndLoreZoneInfoNextPage()
    TomeWindow.FlipPageWindowForward( "HistoryAndLoreZoneInfoPageWindow")
end

function TomeWindow.OnHistoryAndLoreZoneInfoMouseOverNextPage()    
    local lines = {}    
    local curPage   = PageWindowGetCurrentPage("HistoryAndLoreZoneInfoPageWindow")
    local numPages  = PageWindowGetNumPages("HistoryAndLoreZoneInfoPageWindow")
    if( curPage + 2 <= numPages ) then
        -- Next Pages
        lines[1] = TomeWindow.HistoryAndLore.curZoneData.name
        lines[2] = GetString( StringTables.Default.TEXT_CONTINUED )
    end 
    TomeWindow.CreateNextButtonTooltip( lines )
end


-- > History & Lore  Info Nav Buttons
function TomeWindow.OnHistoryAndLoreEntryInfoUpdateNavButtons()
    if ( TomeWindow.GetCurrentState() ~= TomeWindow.PAGE_HISTORY_AND_LORE_ENTRY_INFO ) then
        return
    end
    local curPage   = PageWindowGetCurrentPage("HistoryAndLoreEntryInfoPageWindow")
    local numPages  = PageWindowGetNumPages("HistoryAndLoreEntryInfoPageWindow")
    WindowSetShowing( "TomeWindowPreviousPageButton", curPage > 1 )
    WindowSetShowing( "TomeWindowNextPageButton", curPage + 2 <= numPages )

end

function TomeWindow.OnHistoryAndLoreEntryInfoPreviousPage()
    TomeWindow.FlipPageWindowBackward( "HistoryAndLoreEntryInfoPageWindow")
end

function TomeWindow.OnHistoryAndLoreEntryInfoMouseOverPreviousPage()    
    local lines = {}    
    local curPage   = PageWindowGetCurrentPage("HistoryAndLoreEntryInfoPageWindow")
    local numPages  = PageWindowGetNumPages("HistoryAndLoreEntryInfoPageWindow")
    if( curPage > 1 ) then
        -- Previous Pages
        lines[1] = TomeWindow.HistoryAndLore.curEntryData.name
        lines[2] = GetString( StringTables.Default.TEXT_CONTINUED )
    end 
    TomeWindow.CreateBackButtonTooltip( lines )
end

function TomeWindow.OnHistoryAndLoreEntryInfoNextPage()
    TomeWindow.FlipPageWindowForward( "HistoryAndLoreEntryInfoPageWindow")
end

function TomeWindow.OnHistoryAndLoreEntryInfoMouseOverNextPage()    
    local lines = {}    
    local curPage   = PageWindowGetCurrentPage("HistoryAndLoreEntryInfoPageWindow")
    local numPages  = PageWindowGetNumPages("HistoryAndLoreEntryInfoPageWindow")
    if( curPage + 2 <= numPages ) then
        -- Next Pages
        lines[1] = TomeWindow.HistoryAndLore.curEntryData.name
        lines[2] = GetString( StringTables.Default.TEXT_CONTINUED )
    end 
    TomeWindow.CreateNextButtonTooltip( lines )
end

