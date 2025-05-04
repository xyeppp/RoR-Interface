----------------------------------------------------------------
-- TomeWindow - WarJournal Implementation
--
--  This file contains all of the initialization and callack
--  functions for the Noteworthy Persons section of the Tome of Knowledge.
-- 
----------------------------------------------------------------


-- Constants

-- Variables

TomeWindow.NoteworthyPersons = {}
TomeWindow.NoteworthyPersons.TOCData = nil
TomeWindow.NoteworthyPersons.selectedPairing = 0
TomeWindow.NoteworthyPersons.curZoneData = nil

TomeWindow.NoteworthyPersons.pairingWindowCount   = 0
TomeWindow.NoteworthyPersons.tierWindowCount      = 0
TomeWindow.NoteworthyPersons.zoneWindowCounts     = {}
TomeWindow.NoteworthyPersons.entryWindowCount     = 0


-- Local Functions

local function GetPairingData( pairingId )

    if( TomeWindow.NoteworthyPersons.TOCData == nil ) then
        return nil
    end
    
    for index, data in ipairs( TomeWindow.NoteworthyPersons.TOCData ) do
        if( data.id == pairingId ) then
            return data
         end
    end
    
    return nil
end

----------------------------------------------------------------
-- Noteworthy Persons Functions
----------------------------------------------------------------
function TomeWindow.InitializeNoteworthyPersons()
    
    TomeWindow.NoteworthyPersons.pairingWindowCount   = 0
    TomeWindow.NoteworthyPersons.tierWindowCount      = 0
    TomeWindow.NoteworthyPersons.zoneWindowCounts     = {}
    TomeWindow.NoteworthyPersons.entryWindowCount     = 0


    -- Noteworthy Persons TOC
    TomeWindow.Pages[ TomeWindow.PAGE_NOTEWORTHY_PERSONS_TOC ]
        = TomeWindow.NewPageData( TomeWindow.Sections.SECTION_NOTEWORTHY_PERSONS,
                    "NoteworthyPersonsTOC", 
                    nil,
                    nil,
                    nil,
                    nil,
                    nil,
                    nil )
    
    TomeWindow.SetPageHeaderText( TomeWindow.PAGE_NOTEWORTHY_PERSONS_TOC, 
                                  GetString( StringTables.Default.LABEL_NOTEWORTHY_PERSONS ), 
                                  L"" )
                    
    --  Noteworthy Persons Zone Info
    TomeWindow.Pages[ TomeWindow.PAGE_NOTEWORTHY_PERSONS_ZONE_INFO ]
        = TomeWindow.NewPageData( TomeWindow.Sections.SECTION_NOTEWORTHY_PERSONS,
                    "NoteworthyPersonsZoneInfo", 
                    TomeWindow.UpdateNoteworthyPersonsZone,
                    TomeWindow.OnNoteworthyPersonsZoneInfoUpdateNavButtons,
                    TomeWindow.OnNoteworthyPersonsZoneInfoPreviousPage,
                    TomeWindow.OnNoteworthyPersonsZoneInfoNextPage, 
                    TomeWindow.OnNoteworthyPersonsZoneInfoMouseOverPreviousPage,
                    TomeWindow.OnNoteworthyPersonsZoneInfoMouseOverNextPage )
                    
    --  Noteworthy Persons Entry Info
    TomeWindow.Pages[ TomeWindow.PAGE_NOTEWORTHY_PERSONS_ENTRY_INFO ]
        = TomeWindow.NewPageData( TomeWindow.Sections.SECTION_NOTEWORTHY_PERSONS,
                    "NoteworthyPersonsEntryInfo", 
                    TomeWindow.ShowNoteworthyPersonsEntry,
                    TomeWindow.OnNoteworthyPersonsEntryInfoUpdateNavButtons,
                    TomeWindow.OnNoteworthyPersonsEntryInfoPreviousPage,
                    TomeWindow.OnNoteworthyPersonsEntryInfoNextPage, 
                    TomeWindow.OnNoteworthyPersonsEntryInfoMouseOverPreviousPage,
                    TomeWindow.OnNoteworthyPersonsEntryInfoMouseOverNextPage )
                    

    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.TOME_NOTEWORTHY_PERSONS_TOC_UPDATED, "TomeWindow.OnNoteworthyPersonsTOCUpdated")
    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.TOME_NOTEWORTHY_PERSONS_ZONE_UPDATED, "TomeWindow.OnNoteworthyPersonsZoneUpdated")
    
    -- TOC Page
    
    ButtonSetText( "NoteworthyPersonsPairing1", GetString( StringTables.Default.TEXT_PAIRING_1 ) )
    ButtonSetText( "NoteworthyPersonsPairing2", GetString( StringTables.Default.TEXT_PAIRING_2 ) )
    ButtonSetText( "NoteworthyPersonsPairing3", GetString( StringTables.Default.TEXT_PAIRING_3 ) )
    
    PageWindowAddPageBreak( "NoteworthyPersonsTOCPageWindow", "NoteworthyPersonsZonesLabel" )  
    
    LabelSetText("NoteworthyPersonsZonesLabel", GetString( StringTables.Default.LABEL_ZONES ) )
        
       
    -- Zone Info Page
    LabelSetText("NoteworthyPersonsZoneInfoEntryLabel", GetString( StringTables.Default.LABEL_NOTEWORTHY_PERSONS ) )
    
    
    TomeWindow.UpdateNoteworthyPersonsTOC()
end

function TomeWindow.OnNoteworthyPersonsTOCUpdated()    
    -- Update the TOC
    TomeWindow.UpdateNoteworthyPersonsTOC()
    
    -- Update the Zone
    if( TomeWindow.NoteworthyPersons.curZoneData ) then
        TomeWindow.UpdateNoteworthyPersonsZone( TomeWindow.NoteworthyPersons.curZoneData.id )
    end
end

function TomeWindow.UpdateNoteworthyPersonsTOC()

    TomeWindow.NoteworthyPersons.TOCData = TomeGetNoteworthyPersonsTOC()

    -- Sorth the pairing and zones lists by their names
    for pairingIndex, pairingData in ipairs( TomeWindow.NoteworthyPersons.TOCData ) do
        for tierIndex, tierData in ipairs( pairingData.tiers ) do
            table.sort( tierData.zones, DataUtils.AlphabetizeByNames )  
        end
    end

    -- Update the selected pairing
    TomeWindow.ShowNoteworthyPersonsPairing( TomeWindow.GetSelectedNoteworthyPersonsPairing() )
end


function TomeWindow.SelectActiveNoteworthyPersonsPairing()
    local pairingId = WindowGetId( SystemData.ActiveWindow.name )
    TomeWindow.ShowNoteworthyPersonsPairing( pairingId )
end

function TomeWindow.GetSelectedNoteworthyPersonsPairing()
    if( TomeWindow.NoteworthyPersons.selectedPairing ~= 0 ) then
        return TomeWindow.NoteworthyPersons.selectedPairing
    elseif( TomeWindow.NoteworthyPersons.TOCData ) then
        if( TomeWindow.NoteworthyPersons.TOCData[1] ) then
            return TomeWindow.NoteworthyPersons.TOCData[1].id
        end
    end
    
    return nil
end


function TomeWindow.ShowNoteworthyPersonsPairing( pairingId )

    local pairingData = GetPairingData( pairingId )
    if( pairingData == nil ) then
        ERROR(L"Error in TomeWindow.ShowNoteworthyPersonsPairing(): pairingId is invalid" )
        return
    end 
    
    TomeWindow.NoteworthyPersons.selectedPairing = pairingId
    
    -- set button states
    for index, _ in ipairs( TomeWindow.NoteworthyPersons.TOCData )
    do
        ButtonSetPressedFlag( "NoteworthyPersonsPairing"..index, index == pairingId )
    end

    -- Set the Zones Label
    local text = GetStringFormat( StringTables.Default.LABEL_PAIRING_NAME_ZONES, { pairingData.name } )
    LabelSetText( "NoteworthyPersonsZonesLabel", text )
    
    -- Build the Zones List     
    local parentWindow = "NoteworthyPersonsTOCPageWindowContentsChild"     
    local anchorWindow = "NoteworthyPersonsTOCPageWindowContentsChildZonesTOCAnchor"
    local xOffset = 0
    local yOffset = 5
    
    local tierCount = 0
    local zoneCounts = {}
    
    
    -- Loop through all the tiers
    for tierIndex, tierData in pairs( pairingData.tiers ) do    
    
        tierCount = tierCount + 1
        zoneCounts[ tierIndex ] = 0
        
        -- Create the Tier Label if necessary.    
        local tierWindowName = "NoteworthyPersonsTierLabel"..tierIndex
        if( TomeWindow.NoteworthyPersons.tierWindowCount < tierIndex ) then
        
            CreateWindowFromTemplate( tierWindowName, "NoteworthyPersonsTierLabel", parentWindow )
            
            WindowAddAnchor( tierWindowName, "bottom", anchorWindow, "top", xOffset, yOffset )     
            
            LabelSetText( tierWindowName, GetStringFormat( StringTables.Default.LABEL_TIER_X, { tierIndex } ) )
            
            TomeWindow.NoteworthyPersons.tierWindowCount = TomeWindow.NoteworthyPersons.tierWindowCount + 1
            
        end
        
        anchorWindow = tierWindowName
        xOffset      = 20
        yOffset      = 5
        
        
        if( TomeWindow.NoteworthyPersons.zoneWindowCounts[ tierIndex ] == nil ) then
            TomeWindow.NoteworthyPersons.zoneWindowCounts[ tierIndex ] = 0
        end
            
        -- Loop through all of the zones
        for zoneIndex, zoneData in ipairs( tierData.zones ) do
                    
            zoneCounts[ tierIndex ] = zoneCounts[ tierIndex ] + 1        
            
                  
            -- Create the type window if necessary
            local zoneWindowName = "NoteworthyPersonsZoneButtonTier"..tierIndex.."Zone"..zoneIndex
            if( TomeWindow.NoteworthyPersons.zoneWindowCounts[ tierIndex ] < zoneIndex ) then
            
                CreateWindowFromTemplate( zoneWindowName, "NoteworthyPersonsZoneButton", parentWindow )
                
                WindowAddAnchor( zoneWindowName, "bottom", anchorWindow, "top", xOffset, yOffset )     
                
                TomeWindow.NoteworthyPersons.zoneWindowCounts[ tierIndex ] = TomeWindow.NoteworthyPersons.zoneWindowCounts[ tierIndex ] + 1
            end
            anchorWindow = zoneWindowName   
            
            -- Set the Id
            WindowSetId( zoneWindowName, zoneData.id )         
            
            -- Set the Text
            ButtonSetText( zoneWindowName, zoneData.name )    
            
            xOffset      = 0
            
        end
        
         -- Show/Hide the appropriate number of zone windows.
        for index = 1, TomeWindow.NoteworthyPersons.zoneWindowCounts[ tierIndex ] do
            local show = index <= zoneCounts[ tierIndex ]
            local windowName = "NoteworthyPersonsZoneButtonTier"..tierIndex.."Zone"..index
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
    for index = 1, TomeWindow.NoteworthyPersons.tierWindowCount do
        local show = index <= tierCount
        local windowName = "NoteworthyPersonsTierLabel"..index
        if( WindowGetShowing(windowName ) ~= show ) then
            WindowSetShowing(windowName, show ) 
        end
        if( show == false ) then
            WindowSetId( windowName, 0 ) 
        end
    end
    
    PageWindowUpdatePages( "NoteworthyPersonsTOCPageWindow" )   
end

function TomeWindow.SelectNoteworthyPersonsZone()
    local zoneId = WindowGetId( SystemData.ActiveWindow.name )
    TomeWindow.ShowNoteworthyPersonsZone( zoneId )
end

function TomeWindow.ShowNoteworthyPersonsZone( zoneId )

    -- Zone Pages are always unlocked    
    local params = { zoneId }
    TomeWindow.SetState( TomeWindow.PAGE_NOTEWORTHY_PERSONS_ZONE_INFO, params )   
end

function TomeWindow.UpdateNoteworthyPersonsZone( zoneId )
    --DEBUG(L"Showing Zone "..zoneId )

    TomeWindow.NoteworthyPersons.curZoneData = TomeGetNoteworthyPersonsZoneData( zoneId )
    if( TomeWindow.NoteworthyPersons.curZoneData == nil ) then        
        ERROR(L"Error in TomeWindow.UpdateNoteworthyPersonsZone(): zoneId is invalid" )
        return
    end
    
    -- Set the Name
    LabelSetText( "NoteworthyPersonsZoneInfoName", StringUtils.ToUpperZoneName( TomeWindow.NoteworthyPersons.curZoneData.name ) )
    
    -- Set the Map
    TomeWindow.UseMap( "NoteworthyPersonsZoneInfoMapAnchor", SystemData.MapLevel.ZONE, TomeWindow.NoteworthyPersons.curZoneData.id )
    
    -- Set the Text
    local text = TomeWindow.NoteworthyPersons.curZoneData.text
    if( text == L"" ) then
        text = L" Here is some placeholder text about this zone. "
    end
    LabelSetText( "NoteworthyPersonsZoneInfoText", text )
    
        
    -- Build the Entries List     
    local parentWindow = "NoteworthyPersonsZoneInfoPageWindowContentsChild"     
    local anchorWindow = "NoteworthyPersonsZoneInfoEntryLabel"
    local xOffset = 0
    local yOffset = 5
    
    local entryCount = 0
        
    -- Loop through all of the zones
    for entryIndex, entryData in ipairs( TomeWindow.NoteworthyPersons.curZoneData.entries ) do
                
        entryCount = entryCount + 1        
                
        -- Create the type window if necessary
        local entryWindowName = "NoteworthyPersonsEntryWindow"..entryIndex
        if( TomeWindow.NoteworthyPersons.entryWindowCount < entryIndex ) then
        
            CreateWindowFromTemplate( entryWindowName, "NoteworthyPersonsEntryWindow", parentWindow )
            ButtonSetStayDownFlag( entryWindowName.."CompletedBtn", true )
            ButtonSetDisabledFlag( entryWindowName.."CompletedBtn", true )   
            
            WindowAddAnchor( entryWindowName, "bottom", anchorWindow, "top", xOffset, yOffset )     
            
            TomeWindow.NoteworthyPersons.entryWindowCount = TomeWindow.NoteworthyPersons.entryWindowCount + 1
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
    for index = 1, TomeWindow.NoteworthyPersons.entryWindowCount do
        local show = index <= entryCount
        local windowName = "NoteworthyPersonsEntryWindow"..index
        if( WindowGetShowing(windowName ) ~= show ) then
            WindowSetShowing(windowName, show ) 
        end
        if( show == false ) then
           WindowSetId( windowName, 0 ) 
        end
    end
    
          
       
    -- Update the Page Window
    PageWindowUpdatePages( "NoteworthyPersonsZoneInfoPageWindow" )   
    PageWindowSetCurrentPage( "NoteworthyPersonsZoneInfoPageWindow", 1 )
    TomeWindow.OnNoteworthyPersonsZoneInfoUpdateNavButtons()
           

    TomeWindow.SetPageHeaderText( TomeWindow.PAGE_NOTEWORTHY_PERSONS_ZONE_INFO, 
                                  GetString( StringTables.Default.LABEL_NOTEWORTHY_PERSONS ), 
                                  TomeWindow.NoteworthyPersons.curZoneData.name )  
                            
end

function TomeWindow.OnNoteworthyPersonsZoneUpdated()
    if( TomeWindow.NoteworthyPersons.curZoneData ) then
        if( TomeWindow.NoteworthyPersons.curZoneData.id == GameData.NoteworthyPersons.updatedZone ) then
            TomeWindow.ShowNoteworthyPersonsZone( TomeWindow.NoteworthyPersons.curZoneData.id )
        end
    end
end

function TomeWindow.OnMouseOverNoteworthyPersonsMapPoint()

end


function TomeWindow.SelectNoteworthyPersonsEntry()
   
    if( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) == true ) then
        return
    end
    
    local entryIndex = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
    local id = TomeWindow.NoteworthyPersons.curZoneData.entries[entryIndex].id
    TomeWindow.ShowNoteworthyPersonsEntry( id )
 
end

function TomeWindow.OnRightClickNoteworthyPersonsEntry()
    if( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) == true )
    then
        return
    end
    
    local entryIndex = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )  
    local entryData = TomeWindow.NoteworthyPersons.curZoneData.entries[entryIndex]
    
    TomeWindow.OpenBraggingRightsContextMenu( entryData.unlockEventId )
end

function TomeWindow.ShowNoteworthyPersonsEntry( entryId )

    if( TomeIsNoteworthyPersonsEntryUnlocked( entryId ) ~= true ) then
        return
    end
    
    
    TomeWindow.UpdateNoteworthyPersonsEntry( entryId )    
      
    local params = { entryId }
    TomeWindow.SetState( TomeWindow.PAGE_NOTEWORTHY_PERSONS_ENTRY_INFO, params )  
end

function TomeWindow.UpdateNoteworthyPersonsEntry( entryId ) 

    --DEBUG(L"TomeWindow.ShowNoteworthyPersonsEntry( "..entryId..L" )" )
    
    local name = L""
    local text = L"No entry selected" 

    if( entryId ~= nil ) then
        local entryData = TomeGetNoteworthyPersonsEntryData( entryId )
        if( entryData ~= nil ) then
            name = entryData.name
            text = entryData.text
            
            -- Load the zone if neccessary     
            local setZone = true
            if( TomeWindow.NoteworthyPersons.curZoneData ~= nil ) then
                if( TomeWindow.NoteworthyPersons.curZoneData.id == entryData.zoneId ) then
                    setZone = false
                end
            end
            
            if( setZone ) then    
                TomeWindow.UpdateNoteworthyPersonsZone( entryData.zoneId )
            end
        end    
    end    
    
    LabelSetText("NoteworthyPersonsEntryInfoEntryName", wstring.upper( name ) )
    LabelSetText("NoteworthyPersonsEntryInfoEntryText", text )
    
       
    PageWindowUpdatePages( "NoteworthyPersonsEntryInfoPageWindow" )   
    PageWindowSetCurrentPage( "NoteworthyPersonsZoneInfoPageWindow", 1 )
    TomeWindow.OnNoteworthyPersonsEntryInfoUpdateNavButtons()
           
           
    TomeWindow.SetPageHeaderText( TomeWindow.PAGE_NOTEWORTHY_PERSONS_ENTRY_INFO, 
                                  GetString( StringTables.Default.LABEL_NOTEWORTHY_PERSONS ), 
                                  name )                
                            
end


function TomeWindow.FlipToNoteworthyPersonsEntry()  
    local params = {GameData.Tome.NoteworthyPersons.CurrentEntry.id }
    TomeWindow.SetState( TomeWindow.PAGE_NOTEWORTHY_PERSONS_INFO, params )
    TomeWindow.OnViewEntry( GameData.Tome.SECTION_NOTEWORTHY_PERSONS, GameData.Tome.NoteworthyPersons.CurrentEntry.id )
end


-- > Noteworthy Persons  Info Nav Buttons
function TomeWindow.OnNoteworthyPersonsZoneInfoUpdateNavButtons()
    if ( TomeWindow.GetCurrentState() ~= TomeWindow.PAGE_NOTEWORTHY_PERSONS_ZONE_INFO ) then
        return
    end
    local curPage   = PageWindowGetCurrentPage("NoteworthyPersonsZoneInfoPageWindow")
    local numPages  = PageWindowGetNumPages("NoteworthyPersonsZoneInfoPageWindow")
    WindowSetShowing( "TomeWindowPreviousPageButton", curPage > 1 )
    WindowSetShowing( "TomeWindowNextPageButton", curPage + 2 <= numPages )
    
    -- Only show the map when on the first page
    TomeWindow.ShowMap( curPage == 1 ) 
end

function TomeWindow.OnNoteworthyPersonsZoneInfoPreviousPage()
    TomeWindow.FlipPageWindowBackward( "NoteworthyPersonsZoneInfoPageWindow")
end

function TomeWindow.OnNoteworthyPersonsZoneInfoMouseOverPreviousPage()    
    local lines = {}    
    local curPage   = PageWindowGetCurrentPage("NoteworthyPersonsZoneInfoPageWindow")
    local numPages  = PageWindowGetNumPages("NoteworthyPersonsZoneInfoPageWindow")
    if( curPage > 1 ) then
        -- Previous Pages
        lines[1] = TomeWindow.NoteworthyPersons.curZoneData.name
        lines[2] = GetString( StringTables.Default.TEXT_CONTINUED )
    end 
    TomeWindow.CreateBackButtonTooltip( lines )
end

function TomeWindow.OnNoteworthyPersonsZoneInfoNextPage()
    TomeWindow.FlipPageWindowForward( "NoteworthyPersonsZoneInfoPageWindow")
end

function TomeWindow.OnNoteworthyPersonsZoneInfoMouseOverNextPage()    
    local lines = {}    
    local curPage   = PageWindowGetCurrentPage("NoteworthyPersonsZoneInfoPageWindow")
    local numPages  = PageWindowGetNumPages("NoteworthyPersonsZoneInfoPageWindow")
    if( curPage + 2 <= numPages ) then
        -- Next Pages
        lines[1] = TomeWindow.NoteworthyPersons.curZoneData.name
        lines[2] = GetString( StringTables.Default.TEXT_CONTINUED )
    end 
    TomeWindow.CreateNextButtonTooltip( lines )
end


-- > Noteworthy Persons  Info Nav Buttons
function TomeWindow.OnNoteworthyPersonsEntryInfoUpdateNavButtons()
    if ( TomeWindow.GetCurrentState() ~= TomeWindow.PAGE_NOTEWORTHY_PERSONS_ENTRY_INFO ) then
        return
    end
    local curPage   = PageWindowGetCurrentPage("NoteworthyPersonsEntryInfoPageWindow")
    local numPages  = PageWindowGetNumPages("NoteworthyPersonsEntryInfoPageWindow")
    WindowSetShowing( "TomeWindowPreviousPageButton", curPage > 1 )
    WindowSetShowing( "TomeWindowNextPageButton", curPage + 2 <= numPages )

end

function TomeWindow.OnNoteworthyPersonsEntryInfoPreviousPage()
    TomeWindow.FlipPageWindowBackward( "NoteworthyPersonsEntryInfoPageWindow")
end

function TomeWindow.OnNoteworthyPersonsEntryInfoMouseOverPreviousPage()    
    local lines = {}    
    local curPage   = PageWindowGetCurrentPage("NoteworthyPersonsEntryInfoPageWindow")
    local numPages  = PageWindowGetNumPages("NoteworthyPersonsEntryInfoPageWindow")
    if( curPage > 1 ) then
        -- Previous Pages
        lines[1] = TomeWindow.NoteworthyPersons.curEntryData.name
        lines[2] = GetString( StringTables.Default.TEXT_CONTINUED )
    end 
    TomeWindow.CreateBackButtonTooltip( lines )
end

function TomeWindow.OnNoteworthyPersonsEntryInfoNextPage()
    TomeWindow.FlipPageWindowForward( "NoteworthyPersonsEntryInfoPageWindow")
end

function TomeWindow.OnNoteworthyPersonsEntryInfoMouseOverNextPage()    
    local lines = {}    
    local curPage   = PageWindowGetCurrentPage("NoteworthyPersonsEntryInfoPageWindow")
    local numPages  = PageWindowGetNumPages("NoteworthyPersonsEntryInfoPageWindow")
    if( curPage + 2 <= numPages ) then
        -- Next Pages
        lines[1] = TomeWindow.NoteworthyPersons.curEntryData.name
        lines[2] = GetString( StringTables.Default.TEXT_CONTINUED )
    end 
    TomeWindow.CreateNextButtonTooltip( lines )
end

