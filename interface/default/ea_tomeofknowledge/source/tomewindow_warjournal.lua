----------------------------------------------------------------
-- TomeWindow - WarJournal Implementation
--
--  This file contains all of the initialization and callack
--  functions for the WarJournal section of the Tome of Knowledge.
-- 
----------------------------------------------------------------


-- Constants
TomeWindow.MAX_TASKS_PER_ENTRY = 4

TomeWindow.NUM_REWARD_LEVELS = 3
TomeWindow.MAX_REWARDS_PER_LEVEL = 4

-- Variables
TomeWindow.WarJournal = {}
TomeWindow.WarJournal.storylinesWindowCount = 0
TomeWindow.WarJournal.entriesTOCWindowCount = 0
TomeWindow.WarJournal.activitiesWindowCount = 0
TomeWindow.WarJournal.tasksWindowCount      = 0
TomeWindow.WarJournal.glyphActivityWindowCount   = 0
TomeWindow.WarJournal.glyphLineWindowCount   = 0
TomeWindow.WarJournal.glyphWindowCount   = 0

TomeWindow.WarJournal.AvailStorylinesTOC = nil
TomeWindow.WarJournal.StorylinesData     = {}
TomeWindow.WarJournal.CurStorylineData   = nil
TomeWindow.WarJournal.CurEntryData     = nil

local TOME_WAR_JOURNAL_STORYLINE = 1
local TOME_WAR_JOURNAL_ACTIVITY = 2
local TOME_WAR_JOURNAL_GLYPH_ACTIVITY = 3

TomeWindow.WarJournal.CurEntryPageType = TOME_WAR_JOURNAL_STORYLINE
TomeWindow.WarJournal.CurEntryPageId = 0


----------------------------------------------------------------
-- Local Accessor Functions


local function CacheStorylineData( storyId )
    TomeWindow.WarJournal.StorylinesData[storyId] = TomeGetWarJournalStorylineData( storyId )

    if ( TomeWindow.WarJournal.CurStorylineData ~= nil and TomeWindow.WarJournal.CurStorylineData.id == storyId ) then
        TomeWindow.WarJournal.CurStorylineData = TomeWindow.WarJournal.StorylinesData[storyId]
    end

end

local function GetStorylineData( storyId )
    if ( TomeWindow.WarJournal.StorylinesData[storyId] == nil ) then
        CacheStorylineData( storyId )
    end

    return TomeWindow.WarJournal.StorylinesData[storyId]
end

local function GetEntryData( storyId, entryId )    
    local storyData =  GetStorylineData( storyId )    
    return storyData.entries[entryId]    
end

local function GetStorylineForRace( raceId )

    --DEBUG(L" race = "..raceId )

    if( raceId == GameData.Races.ORC or raceId == GameData.Races.GOBLIN ) then
        return 1 -- Greenskin Storyline
    end
    
    if( raceId == GameData.Races.CHAOS  ) then
        return 2 -- Chaos Storyline
    end
    
    if( raceId == GameData.Races.DARK_ELF  ) then
        return 3 -- Chaos Storyline
    end
    
    if( raceId == GameData.Races.DWARF  ) then
        return 4 -- Dwarf Storyline
    end
    
    if( raceId == GameData.Races.EMPIRE  ) then
        return 5 -- Empire Storyline
    end
    
    if( raceId == GameData.Races.HIGH_ELF  ) then
        return 6 -- High Elf Storyline
    end
        
    return nil
end

local function UpdateTomeInfluenceDisplay( displayName, influenceId )

    local influenceData = DataUtils.GetInfluenceData( influenceId )
    if( influenceData == nil ) then
        return
    end    

    -- Set the Id
    WindowSetId( displayName, influenceId )

    -- Set the Status
    DataUtils.UpdateInfluenceBar( displayName.."Status", influenceId )
    
    -- Set the rewards available Check    amountNeeded
    for level = 1, TomeWindow.NUM_REWARD_LEVELS do
        local checked = influenceData.curValue >= influenceData.rewardLevel[level].amountNeeded

        ButtonSetPressedFlag( displayName.."Check"..level, checked )
        ButtonSetStayDownFlag( displayName.."Check"..level, true )
        ButtonSetDisabledFlag( displayName.."Check"..level, true )
    end 
end

----------------------------------------------------------------
-- WarJournal Functions
----------------------------------------------------------------


function TomeWindow.InitializeWarJournal()

    TomeWindow.WarJournal.storylinesWindowCount = 0
    TomeWindow.WarJournal.entriesTOCWindowCount = 0
    TomeWindow.WarJournal.activitiesWindowCount = 0
    TomeWindow.WarJournal.tasksWindowCount      = 0
    TomeWindow.WarJournal.glyphActivityWindowCount   = 0
    TomeWindow.WarJournal.glyphLineWindowCount   = 0
    TomeWindow.WarJournal.glyphWindowCount   = 0
    TomeWindow.WarJournal.CurEntryPageType = TOME_WAR_JOURNAL_STORYLINE
    TomeWindow.WarJournal.CurEntryPageId = 0

    -- > Initialize the PageData

    
    -- WarJournal TOC
    TomeWindow.Pages[ TomeWindow.PAGE_WAR_JOURNAL_TOC ]
        = TomeWindow.NewPageData( TomeWindow.Sections.SECTION_CHAPTERS, 
                    "WarJournalTOCSection", 
                    TomeWindow.ShowWarJournalTOC,
                    TomeWindow.OnWarJournalTOCUpdateNavButtons,
                    TomeWindow.OnWarJournalTOCPreviousPage,
                    TomeWindow.OnWarJournalTOCNextPage,
                    TomeWindow.OnWarJournalTOCMouseOverPreviousPage,
                    TomeWindow.OnWarJournalTOCMouseOverNextPage )

    TomeWindow.SetPageHeaderText( TomeWindow.PAGE_WAR_JOURNAL_TOC, 
                                  GetString( StringTables.Default.LABEL_WAR_JOURNAL ), 
                                  L"" ) 
    -- WarJournal Entry Info
    TomeWindow.Pages[ TomeWindow.PAGE_WAR_JOURNAL_ENTRY_INFO ]
        = TomeWindow.NewPageData( TomeWindow.Sections.SECTION_CHAPTERS,
                    "WarJournalEntryInfo", 
                    TomeWindow.OnShowWarJournalEntry,
                    TomeWindow.OnWarJournalEntryUpdateNavButtons,
                    TomeWindow.OnWarJournalEntryPreviousPage,
                    TomeWindow.OnWarJournalEntryNextPage , 
                    TomeWindow.OnWarJournalEntryMouseOverPreviousPage,
                    TomeWindow.OnWarJournalEntryMouseOverNextPage )


    -- > Register the Event Handlers
    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.TOME_WAR_JOURNAL_TOC_UPDATED, "TomeWindow.UpdateWarJournalTOC")
    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.PLAYER_INFLUENCE_UPDATED, "TomeWindow.OnPlayerInfluenceUpdated" )
    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.PLAYER_INFLUENCE_REWARDS_UPDATED, "TomeWindow.OnPlayerInfluenceRewardsUpdated" )
    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.TOME_WAR_JOURNAL_ENTRY_UPDATED, "TomeWindow.OnUpdateEntry" )
    
    
    LabelSetText( "WarJournalTOCSectionTitle", wstring.upper( GetString( StringTables.Default.LABEL_WAR_JOURNAL ) ) )
    
    local parentWindow = "WarJournalStorylineTOCPageWindowContentsChild"
    PageWindowAddPageBreak( "WarJournalStorylineTOCPageWindow", parentWindow.."VertScrollAnchor" )

    -- Entry Page
    LabelSetText( "WarJournalEntryLevel1RewardsLabel", GetString( StringTables.Default.LABEL_BASIC_REWARDS ) )
    LabelSetText( "WarJournalEntryLevel2RewardsLabel", GetString( StringTables.Default.LABEL_ADVANCED_REWARDS ) )
    LabelSetText( "WarJournalEntryLevel3RewardsLabel", GetString( StringTables.Default.LABEL_ELITE_REWARDS ) )
    
    PageWindowAddPageBreak( "WarJournalEntryInfoPageWindow", "WarJournalEntryTextButton" )
    
    
    TomeWindow.UpdateWarJournalTOC()
    
    -- allow Glyph icon clicks to open the tome to the appropriate war journal entry
    GlyphDisplay.RegisterTomeOpenJournalCallback( TomeWindow.OpenTomeToEntry )
end


--------------------------------------
-- TOC Functions

function TomeWindow.ShowWarJournalTOC( storyId )
    if ( storyId ~= nil ) then
        TomeWindow.ShowWarJournalStoryline( storyId )
    else
        TomeWindow.ShowWarJournalStoryline( TomeWindow.GetSelectedWarJournalStoryline() )
    end
    
end

function TomeWindow.UpdateWarJournalTOC()

    TomeWindow.WarJournal.AvailStorylinesTOC = TomeGetWarJournalAvailiableStorylines()
    if( TomeWindow.WarJournal.AvailStorylinesTOC == nil ) then
        --DEBUG(L" No Storylines unlocked")
        return
    end
    
    -- Sort the Storylines List alphabetically
    table.sort( TomeWindow.WarJournal.AvailStorylinesTOC, DataUtils.AlphabetizeByNames )        
    
    local parentWindow = "WarJournalStorylineTOCPageWindowContentsChild"     
    local anchorWindow = "WarJournalStorylineTOCPageWindowContentsChildStorylinesTOCAnchor"
    local xOffset = 0
    local yOffset = 0
    
    local storylineCount = 0
    
    local currentStory = TomeWindow.GetSelectedWarJournalStoryline()
        
    -- Loop through all of the storylines
    for storylineIndex, storylineData in ipairs( TomeWindow.WarJournal.AvailStorylinesTOC ) do

        storylineCount = storylineCount + 1        
                
        -- Create the type window if necessary
        local storylineWindowName = "WarJournalStorylineButton"..storylineCount
        if( TomeWindow.WarJournal.storylinesWindowCount < storylineCount ) then
        
            CreateWindowFromTemplate( storylineWindowName, "WarJournalStorylineButton", parentWindow )
            --ButtonSetStayDownFlag( storylineWindowName, true )
                    
            WindowAddAnchor( storylineWindowName, "bottom", anchorWindow, "top", xOffset, yOffset )       
  
            
            TomeWindow.WarJournal.storylinesWindowCount = TomeWindow.WarJournal.storylinesWindowCount + 1
        end
        anchorWindow = storylineWindowName   
        
        ButtonSetDisabledFlag( storylineWindowName.."Text", currentStory == storylineData.id )
        
        -- Set the Id
        WindowSetId( storylineWindowName, storylineData.id )         
        
        -- Set the Text
        ButtonSetText( storylineWindowName.."Text", storylineData.name )    
    
    end
    
    -- Show/Hide the appropriate number of storyline windows.
    for index = 1, TomeWindow.WarJournal.storylinesWindowCount do
        local show = index <= storylineCount
        local windowName = "WarJournalStorylineButton"..index
        if( WindowGetShowing(windowName ) ~= show ) then
            WindowSetShowing(windowName, show ) 
        end
        if( show == false ) then
           WindowSetId( windowName, 0 ) 
        end
    end
    
    WindowClearAnchors( parentWindow.."Divider" )
    WindowAddAnchor( parentWindow.."Divider", "bottom", anchorWindow, "top", 0, 20 )
    
    PageWindowUpdatePages( "WarJournalStorylineTOCPageWindow" )
    
    WindowClearAnchors( parentWindow.."VertScroll" )
    local anchorX, anchorY = WindowGetOffsetFromParent( parentWindow.."VertScrollAnchor" )
    WindowAddAnchor( parentWindow.."VertScroll", "topleft", parentWindow, "topleft", anchorX, anchorY )
    WindowAddAnchor( parentWindow.."VertScroll", "bottomleft", parentWindow, "bottomleft", anchorX, -10 )
    
    -- Update the selected storyline
    TomeWindow.ShowWarJournalStoryline( TomeWindow.GetSelectedWarJournalStoryline() ) 

end

function TomeWindow.SelectActiveWarJournalStoryline()
    
    local storylineId     = WindowGetId( SystemData.ActiveWindow.name )    
        
    --DEBUG(L" TomeWindow.SelectActiveWarJournalStoryline:  storylineId="..storylineId )
    TomeWindow.WarJournal.CurStorylineData = GetStorylineData( storylineId )    
    TomeWindow.UpdateWarJournalTOC()
end


function TomeWindow.GetSelectedWarJournalStoryline()
    -- If we have a selected storyline, return that
    if( TomeWindow.WarJournal.CurStorylineData ) then
        if( TomeWindow.WarJournal.CurStorylineData.id ~= 0 ) then
        
            -- Make sure the selected storyline is valid
            for _, storyline in ipairs( TomeWindow.WarJournal.AvailStorylinesTOC )
            do
                if( storyline.id == TomeWindow.WarJournal.CurStorylineData.id )
                then
                    return storyline.id
                end
            end

        end
    end
    
    -- Otherwise default to the storyline for the player's race.
    local id = GetStorylineForRace( GameData.Player.race.id  )    
    if( id ) then
        if( TomeIsWarJournalStorylineUnlocked( id ) ) then
            return id
        end
    end
    
    -- If that fails, just show the first unlocked section
    if( TomeWindow.WarJournal.AvailStorylinesTOC ~= nil and
            TomeWindow.WarJournal.AvailStorylinesTOC[1] ~= nil ) then
        
        return TomeWindow.WarJournal.AvailStorylinesTOC[1].id
    end
    
    return nil
end

function TomeWindow.ShowWarJournalStoryline( id ) 

    if( id == nil ) then
        return
    end
    
    --DEBUG(L" TomeWindow.ShowWarJournalStoryline( "..id..L" ) " )

    -- Is the storyline unlocked?
    if( TomeIsWarJournalStorylineUnlocked(id) ~= true ) then
        return
    end
    
    -- Recache the storyline data in case something has changed since we last looked at it,
    -- such as a chapter being unlocked or such.
    CacheStorylineData( id )
    TomeWindow.WarJournal.CurStorylineData = GetStorylineData( id )
    if( TomeWindow.WarJournal.CurStorylineData == nil ) then
        return
    end
    
    local storylineData = TomeWindow.WarJournal.CurStorylineData
    
    -- Set Pressed State for the storyline button
    for index = 1, TomeWindow.WarJournal.storylinesWindowCount do
        local windowName = "WarJournalStorylineButton"..index
        local pressed = WindowGetId( windowName ) == storylineData.id 
        --ButtonSetPressedFlag( windowName, pressed ) 
    end
    
    LabelSetText( "WarJournalTOCActiveEntryTitle", wstring.upper( storylineData.name ) )
        
    -- Create the TOC entry for each Entry
    local parentWindow = "WarJournalStorylineTOCPageWindowContentsChild"     
    local anchorWindow = "WarJournalTOCEntryAnchor"
    local xOffset = 0
    local yOffset = 10
    
    local entryCount = 0       
    for index, entryData in ipairs( storylineData.entries ) do
    
        --DEBUG( L"["..index..L"] = "..entryData.id..L": "..entryData.name )
        
        entryCount = entryCount + 1    
        
        -- Create the entry window if necessary
        local entryWindowName = "WarJournalEntry"..entryCount
        if( TomeWindow.WarJournal.entriesTOCWindowCount < entryCount ) then
        
            CreateWindowFromTemplate( entryWindowName, "WarJournalEntry", parentWindow )
            ButtonSetStayDownFlag( entryWindowName.."CompletedBtn", true )
            ButtonSetDisabledFlag( entryWindowName.."CompletedBtn", true )
            
            WindowAddAnchor( entryWindowName, "bottomleft", anchorWindow, "topleft", xOffset, yOffset )        
            
            TomeWindow.WarJournal.entriesTOCWindowCount = TomeWindow.WarJournal.entriesTOCWindowCount + 1
        end
        anchorWindow = entryWindowName     
        
        -- Set the Id
        WindowSetId( entryWindowName, entryData.id )         
        
        -- Set the completed check
        ButtonSetPressedFlag( entryWindowName.."CompletedBtn", entryData.unlocked )
                             
        -- Set the Title                    
        LabelSetText( entryWindowName.."Title",  entryData.title )    
        
        -- Set the Name  
        ButtonSetText( entryWindowName.."Name", entryData.name )      
        ButtonSetDisabledFlag( entryWindowName.."Name", not entryData.unlocked )  
        
        -- Update the Influence value & Hide the bar when no influnece field is set.
        UpdateTomeInfluenceDisplay( entryWindowName.."InfluenceDisplay", entryData.influenceId )
        WindowSetShowing( entryWindowName.."InfluenceDisplay", entryData.influenceId ~= 0 )
        
        local x, y = WindowGetDimensions( entryWindowName.."Name" )
        if( y < 25 ) then
            y = 25
        end
        
        local width, height = WindowGetDimensions( entryWindowName) 
        height = y + 40
        
        if( entryData.influenceId ~= 0 ) then
            height = height + 25
        end
        
        WindowSetDimensions(entryWindowName, width, height )
               
                
    end
    
    -- Show/Hide the appropriate number of entry windows.
    for index = 1, TomeWindow.WarJournal.entriesTOCWindowCount do
        local show = index <= entryCount
        local windowName = "WarJournalEntry"..index
        if( WindowGetShowing(windowName ) ~= show ) then
            WindowSetShowing(windowName, show ) 
        end
    end
    
    local storyText = L""
    if( storylineData and storylineData.summary )
    then
        storyText = storylineData.summary
    end
    LabelSetText( parentWindow.."StoryText", storyText )
    
    
    PageWindowUpdatePages("WarJournalStorylineTOCPageWindow")
    PageWindowSetCurrentPage( "WarJournalStorylineTOCPageWindow", 1 )
    TomeWindow.OnWarJournalTOCUpdateNavButtons()
    
    WindowStartAlphaAnimation( "WarJournalStorylineTOCPageWindow", Window.AnimationType.SINGLE_NO_RESET, 0, 1, 
                            TomeWindow.FADE_IN_TIME, true, 0, 0 )
    
end

----------------------------------------------------
-- Entry Functions

function TomeWindow.SelectWarJournalEntry()
    
    local entryId     = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )    
        
    --DEBUG(L" TomeWindow.SelectWarJournalEntry:  entryId="..entryId )    
    TomeWindow.ShowWarJournalEntry( entryId )
end

function TomeWindow.OnShowWarJournalEntry( entryId )
    -- Is the Entry unlocked?
    if( TomeIsWarJournalEntryUnlocked(entryId) ~= true ) then
        return
    end
    
    local glyphActivityId = nil
    
    local entryData  = TomeGetWarJournalEntryData( entryId )    
    -- If we are showing an entry that has a glyph activity have that be selected first
    -- Instead of the story
    if( entryData and
        entryData.glyphActivities and
        entryData.glyphActivities[1] )
    then
        glyphActivityId = entryData.glyphActivities[1].id
    end
    
    TomeWindow.UpdateWarJournalEntry( entryId, glyphActivityId, entryData )
    
    TomeWindow.OnViewEntry( GameData.Tome.SECTION_WAR_JOURNAL, entryId )
end

function TomeWindow.ShowWarJournalEntry( entryId )

    --DEBUG(L"TomeWindow.ShowWarJournalEntry:  storyId="..storyId..L" entryId="..id )
    
    -- Is the Entry unlocked?
    if( TomeIsWarJournalEntryUnlocked(entryId) ~= true ) then
        return
    end
    
    local entryData = TomeGetWarJournalEntryData( entryId )

    local params = { entryId }
    local flipModeParams = { entryData.displayIndex }
    TomeWindow.SetState( TomeWindow.PAGE_WAR_JOURNAL_ENTRY_INFO, params, flipModeParams )
end

function TomeWindow.UpdateWarJournalEntry( entryId, glyphActivityId, inEntryData  )    
    --DEBUG(L">> TomeWindow.UpdateWarJournalEntry():"..entryId )  
    
    if( inEntryData )
    then
        TomeWindow.WarJournal.CurEntryData = inEntryData
    else
        -- Get the Entry Data
        TomeWindow.WarJournal.CurEntryData = TomeGetWarJournalEntryData( entryId )
    end
        
    --DEBUG(L"TomeWindow.ShowWarJournalEntry(): story="..storyId..L" entry = "..entry )
    if( TomeWindow.WarJournal.CurEntryData  == nil ) then
        DEBUG(L" Entry is nil")
        return
    end
        
    local entryData  = TomeWindow.WarJournal.CurEntryData
    --DUMP_TABLE( TomeWindow.WarJournal.CurEntryData )


    TomeSetWarJournalEntryImage( entryData.id )
    
    -- Set the Title
    LabelSetText( "WarJournalEntryTitle", wstring.upper( entryData.title ) )
    LabelSetText( "WarJournalEntryChapterName", entryData.name )
    
    local influenceData = DataUtils.GetInfluenceData( entryData.influenceId )
    
    -- Set the Map
    if( influenceData ~= nil and influenceData.isRvRInfluence )
    then
        TomeWindow.ClearMap()
        WindowSetShowing( "WarJournalEntryRvRImage", true )
    else
        local mapId = entryData.zoneId * 1000 + entryData.zoneAreaId
        TomeWindow.UseMap( "WarJournalEntryMapAnchor", SystemData.MapLevel.AREA, mapId )
        WindowSetShowing( "WarJournalEntryRvRImage", false )
    end
    
    LabelSetText( "WarJournalEntryLocationText",  entryData.locationText )
    
     -- Only show the influnece section when an Influence Id is set.
    local showInf = entryData.influenceId ~= 0 and influenceData ~= nil
        
    WindowSetShowing( "WarJournalEntryInfluenceInfo", showInf )    
    
    if( showInf ) then
        LabelSetText( "WarJournalEntryRallyMasterText", entryData.npcName )
        
        local helpText = L""
        if( influenceData ~= nil and influenceData.isRvRInfluence )
        then
            helpText = GetString( StringTables.Default.TEXT_INF_REWARD_RVR_HELP )
        elseif( influenceData ~= nil )
        then
            helpText = GetString( StringTables.Default.TEXT_INF_REWARD_HELP )
        end
        LabelSetText( "WarJournalEntryInfluenceHelpText", helpText )
    else
        LabelSetText( "WarJournalEntryRallyMasterText", L"" )
    end
    
    
    -- Set the text for the story link
    ButtonSetText( "WarJournalEntryTextButtonText", wstring.upper( GetString( StringTables.Default.LABEL_CHAPTER_STORY ) ) )
    
    -- Build the Activities List
    
    -- Sort the Activities List alphabetically
    table.sort( entryData.activities, DataUtils.AlphabetizeByNames )        
    
    local parentWindow = "WarJournalEntryInfoPageWindowContentsChild"     
    local anchorWindow = "WarJournalEntryTextButton"
    local xOffset = 0
    local yOffset = 0
    
    local activityCount = 0
        
    -- Loop through all of the activities
    for activityIndex, activityData in ipairs( entryData.activities ) do
                
        --DEBUG(L"activity["..activityIndex..L"] = "..activityData.name )      

        if( activityData.name == L"" )
        then
            continue
        end

        activityCount = activityCount + 1        
                
        -- Create the type window if necessary
        local activityWindowName = "WarJournalEntryActivityButton"..activityCount
        if( TomeWindow.WarJournal.activitiesWindowCount < activityCount ) then
        
            CreateWindowFromTemplate( activityWindowName, "WarJournalActivityButton", parentWindow )
                    
            WindowAddAnchor( activityWindowName, "bottom", anchorWindow, "top", xOffset, yOffset )       
  
            
            TomeWindow.WarJournal.activitiesWindowCount = TomeWindow.WarJournal.activitiesWindowCount + 1
        end
        anchorWindow = activityWindowName   
        
        -- Set the Id
        WindowSetId( activityWindowName, activityData.id )         
        
        -- Set the Text
        ButtonSetText( activityWindowName.."Text", wstring.upper( activityData.name ) )    
    
    end
    
    -- Show/Hide the appropriate number of storyline windows.
    for index = 1, TomeWindow.WarJournal.activitiesWindowCount do
        local show = index <= activityCount
        local windowName = "WarJournalEntryActivityButton"..index
        if( WindowGetShowing(windowName ) ~= show ) then
            WindowSetShowing(windowName, show ) 
        end
        if( show == false ) then
           WindowSetId( windowName, 0 ) 
        end
    end
    
    local glyphActivityCount = 0
        
    -- Loop through all of the glyph activities
    for glyphActivityIndex, glyphActivityData in ipairs( entryData.glyphActivities ) do
                
        --DEBUG(L"glyphActivity["..glyphActivityIndex..L"] = "..glyphActivityData.name )      

        if( glyphActivityData.name == L"" )
        then
            continue
        end

        glyphActivityCount = glyphActivityCount + 1        
                
        -- Create the type window if necessary
        local glyphActivityWindowName = "WarJournalEntryGlyphActivityButton"..glyphActivityCount
        if( TomeWindow.WarJournal.glyphActivityWindowCount < glyphActivityCount ) then
        
            CreateWindowFromTemplate( glyphActivityWindowName, "WarJournalGlyphActivityButton", parentWindow )
                    
            WindowAddAnchor( glyphActivityWindowName, "bottom", anchorWindow, "top", xOffset, yOffset )       
  
            
            TomeWindow.WarJournal.glyphActivityWindowCount = TomeWindow.WarJournal.glyphActivityWindowCount + 1
        end
        anchorWindow = glyphActivityWindowName   
        
        -- Set the Id
        WindowSetId( glyphActivityWindowName, glyphActivityData.id )         
        
        -- Set the Text
        ButtonSetText( glyphActivityWindowName.."Text", wstring.upper( glyphActivityData.name ) )    
    
    end
    
    -- Show/Hide the appropriate number of glyph activity windows.
    for index = 1, TomeWindow.WarJournal.glyphActivityWindowCount do
        local show = index <= glyphActivityCount
        local windowName = "WarJournalEntryGlyphActivityButton"..index
        if( WindowGetShowing(windowName ) ~= show ) then
            WindowSetShowing(windowName, show ) 
        end
        if( show == false ) then
           WindowSetId( windowName, 0 ) 
        end
    end
        
      
    -- Anchor the Entry name below the last activity.       
    WindowClearAnchors( parentWindow.."VertScrollAnchor" )
    WindowAddAnchor( parentWindow.."VertScrollAnchor", "bottomleft", anchorWindow, "topleft", 0, 0 )
    

    TomeWindow.UpdateActiveWarstoryEntryRewards()
    if( glyphActivityId )
    then
        TomeWindow.UpdateActiveWarJournalEntryGlyphActivity( glyphActivityId )
    else
        TomeWindow.UpdateActiveWarJournalEntryActivity( 0 )
    end
    
    PageWindowUpdatePages( "WarJournalEntryInfoPageWindow" )
    
    WindowClearAnchors( parentWindow.."VertScroll" )
    local anchorX, anchorY = WindowGetOffsetFromParent( parentWindow.."VertScrollAnchor" )
    WindowAddAnchor( parentWindow.."VertScroll", "topleft", parentWindow, "topleft", anchorX, anchorY )
    WindowAddAnchor( parentWindow.."VertScroll", "bottomleft", parentWindow, "bottomleft", anchorX, -10 )
    
    PageWindowUpdatePages( "WarJournalEntryInfoPageWindow" )
    
    TomeWindow.OnWarJournalEntryUpdateNavButtons()
    PageWindowSetCurrentPage("WarJournalEntryInfoPageWindow", 1 )       
    
    local storylineName = GetString( StringTables.Default.LABEL_WAR_JOURNAL )
    local storylineData = TomeWindow.WarJournal.CurStorylineData
    if( storylineData and storylineData.name )
    then
        storylineName = storylineData.name
    end
    TomeWindow.SetPageHeaderText( TomeWindow.PAGE_WAR_JOURNAL_ENTRY_INFO, 
                                  storylineName, 
                                  entryData.title )
end

function TomeWindow.OnUpdateEntry()
    -- If we are not looking at the entry that is updated do not update it
    if( not TomeWindow.WarJournal.CurEntryData or TomeWindow.WarJournal.CurEntryData.id ~= GameData.WarJournal.updatedEntry )
    then
        return
    end

    -- Get the New Entry Data
    TomeWindow.WarJournal.CurEntryData = TomeGetWarJournalEntryData( GameData.WarJournal.updatedEntry )
     
    if( TomeWindow.WarJournal.CurEntryData  == nil ) then
        return
    end
        
    local entryData  = TomeWindow.WarJournal.CurEntryData

    -- Sort the Activities List alphabetically
    table.sort( entryData.activities, DataUtils.AlphabetizeByNames )        
    
    local pageId = TomeWindow.WarJournal.CurEntryPageId
    if( TomeWindow.WarJournal.CurEntryPageType == TOME_WAR_JOURNAL_ACTIVITY )
    then
        local tasks = {}
    
        -- Find the activity we are looking at
        for index, activityData in ipairs( TomeWindow.WarJournal.CurEntryData.activities ) do
            if( activityData.id == pageId ) then
                tasks = activityData.tasks            
            end        
        end
        
        -- Tasks....
        local parentWindow = "WarJournalEntryInfoPageWindowContentsChild"
        
        -- Set the pressed stat of the completed button
        local taskIndex = 0
        for index, taskData in ipairs( tasks)
        do
            if( taskData.name == L"" )
            then
                continue
            end
            
            taskIndex = taskIndex + 1
            
            -- Set the Completed Button
            ButtonSetPressedFlag( "WarJournalActivityTask"..taskIndex.."CompletedBtn", taskData.isComplete )           
        end
        
    elseif( TomeWindow.WarJournal.CurEntryPageType == TOME_WAR_JOURNAL_GLYPH_ACTIVITY )
    then
        local lines = {}
        
        -- Find the glyph activity we are looking at
        for index, glyphActivityData in ipairs( TomeWindow.WarJournal.CurEntryData.glyphActivities )
        do
            if( glyphActivityData.id == pageId )
            then
                lines = glyphActivityData.glyphLines            
            end        
        end
        
        -- Set the the status of each glyph
        local glyphIndex = 0
        for index, lineData in ipairs( lines ) do                               

            if( lineData.name == L"" )
            then
                continue
            end
            
            -- Loop through all the glyphs and set the alpha of the image
            for index, glyphData in ipairs( lineData.glyphs ) do                               
                
                if( glyphData.name == L"" )
                then
                    continue
                end
                
                glyphIndex = glyphIndex + 1
                        
                local textureAlpha = 1.0
                if( not glyphData.isUnlocked )
                then
                    textureAlpha = 0.3
                end
                
                WindowSetAlpha( "WarJournalGlyph"..glyphIndex, textureAlpha )
            end
        end
        
    end
    
end

function TomeWindow.SelectActiveWarJournalEntryActivity( ) 
    local activityId = WindowGetId( SystemData.ActiveWindow.name )
    TomeWindow.UpdateActiveWarJournalEntryActivity( activityId ) 
    
    PageWindowUpdatePages( "WarJournalEntryInfoPageWindow" )
    TomeWindow.OnWarJournalEntryUpdateNavButtons()
end

function TomeWindow.SelectActiveGlyphActivityEntry( ) 
    local glyphActivityId = WindowGetId( SystemData.ActiveWindow.name )
    TomeWindow.UpdateActiveWarJournalEntryGlyphActivity( glyphActivityId ) 
    
    PageWindowUpdatePages( "WarJournalEntryInfoPageWindow" )
    TomeWindow.OnWarJournalEntryUpdateNavButtons()
end

local function UpdateActiveWarJournalEntryActivityAndGlyphActivity( activityId, glyphActivityId, anchorWindow, anchorWindowXOffset, anchorWindowYOffset, NumTasks, NumGlyphLines, NumGlyphs )
    
    local function HideShowWindow( windowName, show )
        if( WindowGetShowing(windowName ) ~= show ) then
            WindowSetShowing(windowName, show ) 
        end
    end

    -- Show/Hide the appropriate number of reward windows.
    for index = 1, TomeWindow.WarJournal.tasksWindowCount
    do
        HideShowWindow( "WarJournalActivityTask"..index, index <= NumTasks )
    end
     
    -- Show/Hide the appropriate number of glyph line windows.
    for index = 1, TomeWindow.WarJournal.glyphLineWindowCount
    do
        HideShowWindow( "WarJournalGlyphLine"..index, index <= NumGlyphLines )
    end
    
    -- Show/Hide the appropriate number of glyph windows.
    for index = 1, TomeWindow.WarJournal.glyphWindowCount
    do
        HideShowWindow( "WarJournalGlyph"..index, index <= NumGlyphs )
    end

    WindowClearAnchors( "WarJournalEntryText" )
    WindowAddAnchor( "WarJournalEntryText", "bottom", anchorWindow, "top", anchorWindowXOffset, anchorWindowYOffset )

    local parentWindow = "WarJournalEntryInfoPageWindowContentsChild"
    -- If there are no activities, hide the 'entry text button
    if( TomeWindow.WarJournal.CurEntryData.glyphActivities[1] == nil and  TomeWindow.WarJournal.CurEntryData.activities[1] == nil ) then
        WindowSetShowing( "WarJournalEntryTextButton", false )
        PageWindowAddPageBreak( "WarJournalEntryInfoPageWindow", parentWindow.."VertScrollAnchor" )
        return
    else
        WindowSetShowing("WarJournalEntryTextButton", true)
        PageWindowRemovePageBreak( "WarJournalEntryInfoPageWindow", parentWindow.."VertScrollAnchor" )
    end

    
    -- Update the Buttons    
    ButtonSetDisabledFlag( "WarJournalEntryTextButtonText" , activityId == 0 and glyphActivityId == 0)
    local buttonIndex = 0
    for glyphActivityIndex, glyphActivityData in ipairs( TomeWindow.WarJournal.CurEntryData.glyphActivities )
    do
        if( glyphActivityData.name == L"" )
        then
            continue
        end
        buttonIndex = buttonIndex + 1
    
        local glyphActivityWindowName = "WarJournalEntryGlyphActivityButton"..buttonIndex.."Text"
        ButtonSetDisabledFlag( glyphActivityWindowName, glyphActivityData.id == glyphActivityId )
    end
    
    buttonIndex = 0
    for activityIndex, activityData in ipairs( TomeWindow.WarJournal.CurEntryData.activities )
    do
        if( activityData.name == L"" )
        then
            continue
        end
        buttonIndex = buttonIndex + 1
    
        local activityWindowName = "WarJournalEntryActivityButton"..buttonIndex.."Text"
        ButtonSetDisabledFlag( activityWindowName, activityData.id == activityId )
    end
    
    local parentId = 0
    if( activityId ~= 0 )
    then
        parentId = activityId
    elseif( glyphActivityId ~= 0 )
    then
        parentId = glyphActivityId
    end
    
    WindowSetId( parentWindow, parentId )
end

function TomeWindow.UpdateActiveWarJournalEntryActivity( activityId ) 

    local name = L""
    local text = L""
    local tasks = {}
    
    -- If the activityId is 0, that means show the story text
    if( activityId == 0 ) then
        name = TomeWindow.WarJournal.CurEntryData.name
        text = TomeWindow.WarJournal.CurEntryData.storyText
        TomeWindow.WarJournal.CurEntryPageType = TOME_WAR_JOURNAL_STORYLINE   
    else
    
        -- Otherwise, find the activity.
        for index, activityData in ipairs( TomeWindow.WarJournal.CurEntryData.activities ) do
            if( activityData.id == activityId ) then
                name = activityData.name
                text = activityData.text 
                tasks = activityData.tasks
                TomeWindow.WarJournal.CurEntryPageType = TOME_WAR_JOURNAL_ACTIVITY        
            end        
        end
    end
    
    -- Set the id of the current page
    TomeWindow.WarJournal.CurEntryPageId = activityId
    
    -- Set the Name & Text
    LabelSetText( "WarJournalEntryName",  wstring.upper( name ) )   
    LabelSetText( "WarJournalEntryText",  text )     
    
    
    -- Tasks....
    local parentWindow = "WarJournalEntryInfoPageWindowContentsChild"
    local anchorWindow = "WarJournalEntryTasksAnchor"
    local xOffset = 0
    local yOffset = 10
    
    -- Set the Species, creating window as necessary
    local taskIndex = 0
    for index, taskData in ipairs( tasks) do                               
        
        if( taskData.name == L"" )
        then
            continue
        end
        
        taskIndex = taskIndex + 1
                
        -- Create the sub type window if necessary
        local taskWindowName = "WarJournalActivityTask"..taskIndex
        if( TomeWindow.WarJournal.tasksWindowCount < taskIndex ) then
        
            CreateWindowFromTemplate( taskWindowName, "WarJournalActivityTask", parentWindow )                         
            
            WindowAddAnchor( taskWindowName, "bottom", anchorWindow, "top", xOffset, yOffset )             
           
            ButtonSetStayDownFlag( taskWindowName.."CompletedBtn", true )
            ButtonSetDisabledFlag( taskWindowName.."CompletedBtn", true )
           
            TomeWindow.WarJournal.tasksWindowCount = TomeWindow.WarJournal.tasksWindowCount + 1
        end
        
        -- Set the Id
        WindowSetId( taskWindowName, taskIndex )   
        
        -- Set the Completed Button
        ButtonSetPressedFlag( taskWindowName.."CompletedBtn", taskData.isComplete )
                    
        -- Set Task
        LabelSetText( taskWindowName.."Task", taskData.name )
        local taskWidth, taskHeight = WindowGetDimensions( taskWindowName.."Task" )
        
        -- Set The Desc
        LabelSetText( taskWindowName.."Desc", taskData.text )
        local descWidth, descHeight = WindowGetDimensions( taskWindowName.."Desc" )
        
        -- Resize....        
        local width, height = WindowGetDimensions( taskWindowName )
        local height = taskHeight + descHeight

        WindowSetDimensions( taskWindowName, width, height )    
        
               
        anchorWindow = taskWindowName             
    end
   
    UpdateActiveWarJournalEntryActivityAndGlyphActivity( activityId, 0, anchorWindow, 0, 15, taskIndex, 0, 0 )
end

function TomeWindow.UpdateActiveWarJournalEntryGlyphActivity( glyphActivityId ) 

    local text = L""
    local name = L""
    local lines = {}
    
    -- If the glyphActivityId is 0, that means show the story text
    if( glyphActivityId == 0 ) then
        text = TomeWindow.WarJournal.CurEntryData.storyText
        name = TomeWindow.WarJournal.CurEntryData.name
        TomeWindow.WarJournal.CurEntryPageType = TOME_WAR_JOURNAL_STORYLINE
    else
        
        -- Otherwise, find the activity.
        for index, glyphActivityData in ipairs( TomeWindow.WarJournal.CurEntryData.glyphActivities )
        do
            if( glyphActivityData.id == glyphActivityId )
            then
                text = glyphActivityData.text 
                lines = glyphActivityData.glyphLines
                TomeWindow.WarJournal.CurEntryPageType = TOME_WAR_JOURNAL_GLYPH_ACTIVITY
            end        
        end
    end
    
    -- Set the id of the current page
    TomeWindow.WarJournal.CurEntryPageId = glyphActivityId
    
    -- Set the Text
    LabelSetText( "WarJournalEntryText",  text ) 
    LabelSetText( "WarJournalEntryName",  name )   
    
    
    -- Glyph Lines....
    local parentWindow = "WarJournalEntryInfoPageWindowContentsChild"
    local anchorWindow = "WarJournalEntryText"
    local xOffset = 0
    local yOffset = 25
    
    local glyphParentWindow = "WarJournalGlyphLine1"
    local glyphAnchorWindow = "WarJournalGlyphLine1"
    
    -- Set the Line, creating window as necessary
    local lineIndex = 0
    local glyphIndex = 0
    for index, lineData in ipairs( lines ) do                               

        if( lineData.name == L"" )
        then
            continue
        end

        lineIndex = lineIndex + 1
                
        -- Create the sub type window if necessary
        local lineWindowName = "WarJournalGlyphLine"..lineIndex
        if( TomeWindow.WarJournal.glyphLineWindowCount < lineIndex ) then
        
            CreateWindowFromTemplate( lineWindowName, "WarJournalGlyphLine", parentWindow )                         
            
            WindowAddAnchor( lineWindowName, "bottom", anchorWindow, "top", xOffset, yOffset )             
           
            TomeWindow.WarJournal.glyphLineWindowCount = TomeWindow.WarJournal.glyphLineWindowCount + 1
        end
        
        yOffset = 5
        
        -- Set the Id
        WindowSetId( lineWindowName, lineData.id )   
                    
        -- Set Task
        LabelSetText( lineWindowName.."Name", wstring.upper( lineData.name ) )   

        anchorWindow = lineWindowName
        glyphParentWindow = lineWindowName
        glyphAnchorWindow = lineWindowName
        
        local glyphXOffset = 15
        local glyphYOffset = 32
    
        for index, glyphData in ipairs( lineData.glyphs ) do                               
            
            if( glyphData.name == L"" )
            then
                continue
            end
            
            glyphIndex = glyphIndex + 1
                    
            -- Create the sub type window if necessary
            local glyphWindowName = "WarJournalGlyph"..glyphIndex
            if( TomeWindow.WarJournal.glyphWindowCount < glyphIndex ) then
            
                CreateWindowFromTemplate( glyphWindowName, "WarJournalGlyph", glyphParentWindow )                         
                
                WindowAddAnchor( glyphWindowName, "topleft", glyphAnchorWindow, "topleft", glyphXOffset, glyphYOffset )             
               
                TomeWindow.WarJournal.glyphWindowCount = TomeWindow.WarJournal.glyphWindowCount + 1
            end
            
            glyphXOffset = 74
            glyphYOffset = 0
            
            -- Set the Id
            WindowSetId( glyphWindowName, glyphData.id )   
            
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

            glyphAnchorWindow = glyphWindowName 
        end
        
    end
   
    UpdateActiveWarJournalEntryActivityAndGlyphActivity( 0, glyphActivityId, "WarJournalEntryInfoPageWindowContentsChildVertScrollAnchor", 10, 30, 0, lineIndex, glyphIndex )
end

function TomeWindow.UpdateActiveWarstoryEntryRewards()

    -- Influence
    local influenceId = TomeWindow.WarJournal.CurEntryData.influenceId
    --DEBUG(L" Chapter Influence Id="..influenceId)

    local influenceRewards = GameData.GetInfluenceRewards( influenceId )
    if(  influenceRewards == nil ) then
        --DEBUG( L" No Influence Data - Id="..influenceId )
        return
    end
    
    UpdateTomeInfluenceDisplay( "WarJournalEntryInfluenceDisplay", influenceId )

    -- Update the Rewards
    for level = 1, TomeWindow.NUM_REWARD_LEVELS do
        
        local levelRewards = influenceRewards[level]
        local numRewards = 0
        
        for reward = 1, TomeWindow.MAX_REWARDS_PER_LEVEL do
        
            local itemData = nil
            if levelRewards then
                itemData = levelRewards[reward]
            end

            local playerCareer = GameData.Player.career.line
            
            -- Filter the choices, don't display any that are nonexistant
            local isRewardValid = (itemData ~= nil) and (itemData.id ~= 0)
            
            --   ...or unusable by the character's career
            local isRewardRelevent = DataUtils.CareerIsAllowedForItem(playerCareer, itemData) and
                                        DataUtils.SkillIsEnoughForItem(GameData.Player.Skills, itemData)
        
            -- Do something if the filter removes all rewards?        
            
            local isChoiceVisible = (isRewardValid and isRewardRelevent)
    
            --DEBUG( L"Influence Reward #"..level..L"-"..reward..L" = "..itemData.name..L", icon = "..itemData.iconNum )
            WindowSetShowing("WarJournalEntryLevel"..level.."Reward"..reward, isChoiceVisible )
            if( isChoiceVisible ) then
                numRewards = numRewards + 1
                local texture, x, y = GetIconData( itemData.iconNum )
                DynamicImageSetTexture( "WarJournalEntryLevel"..level.."Reward"..reward.."IconBase", texture, x, y )
            end
        end
        
        local xOffset = 0
        local yOffset = 0
        if( numRewards > 2 )
        then
            xOffset = -32
        end
        WindowClearAnchors( "WarJournalEntryLevel"..level.."Reward1" )
        WindowAddAnchor( "WarJournalEntryLevel"..level.."Reward1", "bottom", "WarJournalEntryLevel"..level.."RewardsLabel", "top", xOffset, yOffset )
    end                       
end


function TomeWindow.OnPlayerInfluenceUpdated( updatedId )
    --DEBUG(L" Player Influence Updated #".. updatedId )
    --DEBUG(L" Player Influence #".. updatedId..L" updated, currentlyView Infl #"..TomeWindow.WarJournal.CurEntryData.influenceId )  
    if( updatedId == 0 ) then
        return
    end
    
    -- Current Entry Bar
    if( TomeWindow.WarJournal.CurEntryData ~= nil ) then
        if( TomeWindow.WarJournal.CurEntryData.influenceId == updatedId ) then
            UpdateTomeInfluenceDisplay( "WarJournalEntryInfluenceDisplay", updatedId )
        end
    end
    
    -- TOC Bars
    if( TomeWindow.WarJournal.CurStorylineData ~= nil ) then
        for index, entryData in ipairs( TomeWindow.WarJournal.CurStorylineData.entries ) do
            --DEBUG(L" ("..index..L","..entry..L") = "..influenceId )
            if( entryData.influenceId == updatedId ) then
                local barName = "WarJournalEntry"..index.."InfluenceDisplay"
                
                --DEBUG(L" Influence Bar - "..StringToWString(barName) )
                UpdateTomeInfluenceDisplay( barName, updatedId )
            end
        end 
    end
end

function TomeWindow.OnPlayerInfluenceRewardsUpdated( updatedId )
    --DEBUG(L" Player Influence Rewards Updated #".. updatedId..L" updated, currentlyView Infl #"..TomeWindow.WarJournal.CurEntryData.influenceId )
     if( TomeWindow.WarJournal.CurEntryData ~= nil ) then
        if( updatedId ~= 0 and 
            TomeWindow.WarJournal.CurEntryData.influenceId == updatedId ) then
            TomeWindow.UpdateActiveWarstoryEntryRewards()     
        end
     end
end

function TomeWindow.OnMouseOverInfluenceDisplay()

    local influenceId = WindowGetId( SystemData.ActiveWindow.name )
    --DEBUG(L" Entry InfluenceId"..influenceId )
    
    if influenceId == 0 then
        return
    end
        
    local influenceData = DataUtils.GetInfluenceData( influenceId )
    if( influenceData == nil ) then
        return
    end    

    local zoneName  = GetZoneName( influenceData.zoneNum )
    local areaName = GetZoneAreaName(  influenceData.zoneNum, influenceData.zoneAreaNum )
    
    local stringIndex = StringTables.Default.TEXT_INFLUENCE_DESC
    if( influenceData.isRvRInfluence )
    then
        stringIndex = StringTables.Default.TEXT_INFLUENCE_RVR_DESC
    end

    local text = GetStringFormat( stringIndex,
                                 { areaName, zoneName,
                                    influenceData.rewardLevel[1].amountNeeded,
                                    influenceData.npcName,
                                    influenceData.rewardLevel[2].amountNeeded,
                                    influenceData.rewardLevel[3].amountNeeded } )
                                    
                                    
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, nil ) 
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT )
    
    
    -- Name
    local row = 1
    local column = 1
    Tooltips.SetTooltipText( row, column, GetString( StringTables.Default.LABEL_AREA_INFLUENCE ) )
    row = row + 1
    
    -- Desc
    Tooltips.SetTooltipText( row, column, text )
    Tooltips.SetTooltipColor( row, column, 255, 204, 51 )
    row = row + 1
    
    
    -- Current Points
    local curPointsText = GetStringFormat( StringTables.Default.TEXT_CURRENT_INFLUENCE, { influenceData.curValue } )
    Tooltips.SetTooltipText( row, column, curPointsText )
    Tooltips.SetTooltipColor( row, column, 255, 204, 102 )
    row = row + 1                           
                                 
    -- Rewards Avail / Recieved
    if( influenceData.rewardLevel[1].rewardsRecieved == true ) then
        Tooltips.SetTooltipText( row, column, GetString( StringTables.Default.TEXT_BASIC_REWARD_RECEIVED) )
        Tooltips.SetTooltipColor( row, column, 150, 150, 150 )
        row = row + 1
    elseif( influenceData.curValue >= influenceData.rewardLevel[1].amountNeeded ) then
        Tooltips.SetTooltipText( row, column, GetString( StringTables.Default.TEXT_BASIC_REWARD_AVAILIABLE ) )
        Tooltips.SetTooltipColor( row, column, 255, 255, 0 )
        row = row + 1
    end
    
    if( influenceData.rewardLevel[2].rewardsRecieved == true ) then
        Tooltips.SetTooltipText( row, column, GetString( StringTables.Default.TEXT_ADVANCED_REWARD_RECEIVED) )
        Tooltips.SetTooltipColor( row, column, 150, 150, 150 )
        row = row + 1
    elseif( influenceData.curValue >= influenceData.rewardLevel[2].amountNeeded ) then
        Tooltips.SetTooltipText( row, column, GetString( StringTables.Default.TEXT_ADVANCED_REWARD_AVAILIABLE ) )
        Tooltips.SetTooltipColor( row, column, 255, 255, 0 )
        row = row + 1
    end
    
    
    if( influenceData.rewardLevel[3].rewardsRecieved == true ) then
        Tooltips.SetTooltipText( row, column, GetString( StringTables.Default.TEXT_ELITE_REWARD_RECEIVED) )
        Tooltips.SetTooltipColor( row, column, 150, 150, 150 )
        row = row + 1
    elseif( influenceData.curValue >= influenceData.rewardLevel[3].amountNeeded ) then
        Tooltips.SetTooltipText( row, column, GetString( StringTables.Default.TEXT_ELITE_REWARD_AVAILIABLE ) )
        Tooltips.SetTooltipColor( row, column, 255, 255, 0 )
        row = row + 1
    end
    
    
    Tooltips.Finalize()

end

function TomeWindow.MouseoverInfluenceReward( level, reward )
    
    local influenceRewards = GameData.GetInfluenceRewards( TomeWindow.WarJournal.CurEntryData.influenceId )
    if( influenceRewards == nil ) 
    then
        return
    end
        
    local itemData = influenceRewards[level][reward]
    if( itemData == nil or itemData.id == 0 )
    then
        return
    end
   
    Tooltips.CreateItemTooltip( itemData, SystemData.ActiveWindow.name, Tooltips.ANCHOR_WINDOW_RIGHT )
   
end

function TomeWindow.OnMouseOverInfluenceRewardLevel1()
    local level = 1
    local reward = WindowGetId(SystemData.ActiveWindow.name)  
    TomeWindow.MouseoverInfluenceReward( level, reward )
end
function TomeWindow.OnMouseOverInfluenceRewardLevel2()
    local level = 2
    local reward = WindowGetId(SystemData.ActiveWindow.name)  
    TomeWindow.MouseoverInfluenceReward( level, reward )
end
function TomeWindow.OnMouseOverInfluenceRewardLevel3()
    local level = 3
    local reward = WindowGetId(SystemData.ActiveWindow.name)  
    TomeWindow.MouseoverInfluenceReward( level, reward )
end


function TomeWindow.OnLButtonDownInfluenceReward( level, reward, flags, x, y )
 
    local influenceRewards = GameData.GetInfluenceRewards( TomeWindow.WarJournal.CurEntryData.influenceId )
    if( influenceRewards == nil ) 
    then
        return
    end    
    
    local itemData = influenceRewards[level][reward]
    if( itemData == nil or itemData.id == 0 )
    then
        return
    end
        
    -- Create an Item Link on Shift-Left Click
    if( flags == SystemData.ButtonFlags.SHIFT )
    then
        EA_ChatWindow.InsertItemLink( itemData )
    end              
end
            
function TomeWindow.OnLButtonDownInfluenceRewardLevel1( flags, x, y )
    local level = 1
    local reward = WindowGetId(SystemData.ActiveWindow.name)  
    TomeWindow.OnLButtonDownInfluenceReward( level, reward, flags, x, y )
end
function TomeWindow.OnLButtonDownInfluenceRewardLevel2( flags, x, y )
    local level = 2
    local reward = WindowGetId(SystemData.ActiveWindow.name)  
    TomeWindow.OnLButtonDownInfluenceReward( level, reward, flags, x, y )
end
function TomeWindow.OnLButtonDownInfluenceRewardLevel3( flags, x, y )
    local level = 3
    local reward = WindowGetId(SystemData.ActiveWindow.name)  
    TomeWindow.OnLButtonDownInfluenceReward( level, reward, flags, x, y )
end


---------------------------------------------------------
-- > War Journal TOC Nav Buttons

function TomeWindow.OnWarJournalTOCUpdateNavButtons()
    if ( TomeWindow.GetCurrentState() ~= TomeWindow.PAGE_WAR_JOURNAL_TOC ) then
        return
    end
    
    local curPage   = PageWindowGetCurrentPage("WarJournalStorylineTOCPageWindow")
    local numPages  = PageWindowGetNumPages("WarJournalStorylineTOCPageWindow")
    WindowSetShowing( "TomeWindowPreviousPageButton", curPage > 1 )
    WindowSetShowing( "TomeWindowNextPageButton", curPage +2 <= numPages )  
end

function TomeWindow.OnWarJournalTOCPreviousPage()
    TomeWindow.FlipPageWindowBackward( "WarJournalStorylineTOCPageWindow")
end

function TomeWindow.OnWarJournalTOCMouseOverPreviousPage()  
    local lines = {}    
    local curPage   = PageWindowGetCurrentPage("WarJournalStorylineTOCPageWindow")
    local numPages  = PageWindowGetNumPages("WarJournalStorylineTOCPageWindow")
    if( curPage > 1 ) then
        -- Previous Pages
        lines[1] = GetString( StringTables.Default.TEXT_WAR_JOURNAL_TOC )
        lines[2] = GetString( StringTables.Default.TEXT_CONTINUED )
    end 
    TomeWindow.CreateBackButtonTooltip( lines )
end

function TomeWindow.OnWarJournalTOCNextPage()
    TomeWindow.FlipPageWindowForward( "WarJournalStorylineTOCPageWindow")
end

function TomeWindow.OnWarJournalTOCMouseOverNextPage()  
    local lines = {}    
    local curPage   = PageWindowGetCurrentPage("WarJournalStorylineTOCPageWindow")
    local numPages  = PageWindowGetNumPages("WarJournalStorylineTOCPageWindow")
    if( curPage + 2 <= numPages ) then
        -- Next Pages
        lines[1] = GetString( StringTables.Default.TEXT_WAR_JOURNAL_TOC )
        lines[2] = GetString( StringTables.Default.TEXT_CONTINUED )
    end 
    TomeWindow.CreateNextButtonTooltip( lines )
end


---------------------------------------------------------
-- > War Journal Entry Nav Buttons

function TomeWindow.OnWarJournalEntryUpdateNavButtons()
    --DEBUG(L"TomeWindow.OnWarJournalEntryUpdateNavButtons() " )
    
    if ( TomeWindow.GetCurrentState() ~= TomeWindow.PAGE_WAR_JOURNAL_ENTRY_INFO ) then
        return
    end
    
    local curStoryline  = TomeWindow.WarJournal.CurEntryData.storylineId
    local curDisplayIndex = TomeWindow.WarJournal.CurEntryData.displayIndex
    
    local storyData = GetStorylineData( curStoryline )
    
    
    -- Disable the buttons is the next/previous entry is not unlocked    
    local curPage   = PageWindowGetCurrentPage("WarJournalEntryInfoPageWindow")
    local numPages  = PageWindowGetNumPages("WarJournalEntryInfoPageWindow")
    
    
    -- Back Button
    local disabled  = false
    if( curPage == 1 ) then    
        if( storyData.entries[curDisplayIndex-1] == nil ) then
            disabled = true
        elseif( storyData.entries[curDisplayIndex-1].unlocked == false ) then
            disabled = true
        end
    
    end
    ButtonSetDisabledFlag( "TomeWindowPreviousPageButton", disabled )
    WindowSetShowing( "TomeWindowPreviousPageButton", disabled == false )
    
    -- Next Button    
    local disabled = false
    if( curPage + 2 > numPages ) then
    
        if( storyData.entries[curDisplayIndex+1] == nil ) then
            disabled = true
        elseif( storyData.entries[curDisplayIndex+1].unlocked == false ) then
            disabled = true
        end
    end
    ButtonSetDisabledFlag( "TomeWindowNextPageButton", disabled )
    WindowSetShowing( "TomeWindowNextPageButton", disabled == false )
    
    -- Only show the map when on the first page and not open rvr tier chapter
    local chapterHasMap = false
    local influenceData = DataUtils.GetInfluenceData( storyData.entries[curDisplayIndex].influenceId )
    if( (influenceData and influenceData.isRvRInfluence == false)
        or storyData.entries[curDisplayIndex].influenceId == 0 )
    then
        chapterHasMap = true
    end
    TomeWindow.ShowMap( curPage == 1 and chapterHasMap )
end

function TomeWindow.OnWarJournalEntryPreviousPage()
    if( ButtonGetDisabledFlag("TomeWindowPreviousPageButton" ) == true ) then
        return
    end
    
    if( TomeWindow.FlipPageWindowBackward( "WarJournalEntryInfoPageWindow") == false ) then
        
        -- Flip to the previous entry
        local curStoryline  = TomeWindow.WarJournal.CurEntryData.storylineId
        local curDisplayIndex = TomeWindow.WarJournal.CurEntryData.displayIndex
    
        local storyData = GetStorylineData( curStoryline )    
        
        if( storyData.entries[curDisplayIndex-1] ) then
            -- There is a next entry
            TomeWindow.ShowWarJournalEntry( storyData.entries[curDisplayIndex-1].id )
        end      
    end
end

function TomeWindow.OnWarJournalEntryMouseOverPreviousPage()  
    local lines = {}    
    local curPage   = PageWindowGetCurrentPage("WarJournalEntryInfoPageWindow")
    local numPages  = PageWindowGetNumPages("WarJournalEntryInfoPageWindow")
    if( curPage > 1 ) then
        -- Previous Pages
        local storyName     = TomeWindow.WarJournal.CurEntryData.storylineName       
        local entryData     = TomeWindow.WarJournal.CurEntryData 
        lines[1] = storyName
        lines[2] = entryData.title..L": "..entryData.name
        lines[3] = GetString( StringTables.Default.TEXT_CONTINUED )
    else     
        -- Previous Entry
        local curStoryline  = TomeWindow.WarJournal.CurEntryData.storylineId
        local curDisplayIndex = TomeWindow.WarJournal.CurEntryData.displayIndex
               
        local storyData      = GetStorylineData( curStoryline )   
        local entryData      = storyData.entries[curDisplayIndex-1]
        
        if( entryData == nil ) then
            return
        end
          
        lines[1] = storyData.name
        lines[2] = entryData.title..L": "..entryData.name      
    end 
    TomeWindow.CreateBackButtonTooltip( lines )
end

function TomeWindow.OnWarJournalEntryNextPage()
    if( ButtonGetDisabledFlag("TomeWindowNextPageButton" ) == true ) then
        return
    end

    if( TomeWindow.FlipPageWindowForward( "WarJournalEntryInfoPageWindow") == false ) then
        -- Flip to the next entry
        local curStoryline  = TomeWindow.WarJournal.CurEntryData.storylineId
        local curDisplayIndex = TomeWindow.WarJournal.CurEntryData.displayIndex
    
        local storyData = GetStorylineData( curStoryline )    
        
        if( storyData.entries[curDisplayIndex+1] ) then
            -- There is a next entry
            TomeWindow.ShowWarJournalEntry( storyData.entries[curDisplayIndex+1].id )
        end   
    end
end

function TomeWindow.OnWarJournalEntryMouseOverNextPage()  
    local lines = {}    
    local curPage   = PageWindowGetCurrentPage("WarJournalEntryInfoPageWindow")
    local numPages  = PageWindowGetNumPages("WarJournalEntryInfoPageWindow")
    if( curPage + 2 <= numPages ) then
        -- Next Pages
        local entryData       = TomeWindow.WarJournal.CurEntryData
        local storyName     = TomeWindow.WarJournal.CurEntryData.storylineName   
         
        lines[1] = storyName
        lines[2] = entryData.title..L": "..entryData.name
        lines[3] = GetString( StringTables.Default.TEXT_CONTINUED )
    else     
        -- Next Entry
        local curStoryline  = TomeWindow.WarJournal.CurEntryData.storylineId
        local curDisplayIndex = TomeWindow.WarJournal.CurEntryData.displayIndex
        
        local storyData      = GetStorylineData( curStoryline )   
        local entryData      = storyData.entries[curDisplayIndex+1]
          
        if( entryData == nil ) then
            return
        end
          
        lines[1] = storyData.name
        lines[2] = entryData.title..L": "..entryData.name     
    end 
    TomeWindow.CreateNextButtonTooltip( lines )
end

function TomeWindow.OnMouseOverGlyph()
    
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
    
    local glyphId = WindowGetId( SystemData.MouseOverWindow.name )
    local lineWindow = WindowGetParent( SystemData.MouseOverWindow.name )
    local lineId = WindowGetId( lineWindow )
    local glyphActivityId = WindowGetId( WindowGetParent( lineWindow ) )
    
    local glyphActivity = GetTableById( TomeWindow.WarJournal.CurEntryData.glyphActivities, glyphActivityId )
    local glyphLine = GetTableById( glyphActivity.glyphLines, lineId )
    local glyphData = GetTableById( glyphLine.glyphs, glyphId )
    
    Tooltips.CreateGlyphTooltip( glyphData, Tooltips.ANCHOR_WINDOW_RIGHT )
end
