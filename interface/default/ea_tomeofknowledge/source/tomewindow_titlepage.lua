----------------------------------------------------------------
-- TomeWindow - NewEntris Page Implementation
--
--  This file contains all of the initialization and callback
--  functions for the NewEntries section of the Tome of Knowledge.
-- 
----------------------------------------------------------------

local PARENT_WINDOW = "TomeWindowTitlePagePageWindowContentsChild"

TomeWindow.TitlePage = {}

TomeWindow.TitlePage.stats = {}

TomeWindow.TitlePage.stats[1] = NewTomeStat( "TomeWindowTitlePageStatMonsterKills",  
                                             StringTables.Default.LABEL_MONSTER_KILLS, 
                                             SystemData.Events.TOME_BESTIARY_TOTAL_KILL_COUNT_UPDATED,  
                                             "GameData.Bestiary.totalKills" )

TomeWindow.TitlePage.stats[2] = NewTomeStat( "TomeWindowTitlePageStatRvRKills",  
                                             StringTables.Default.LABEL_RVR_KILLS, 
                                             SystemData.Events.PLAYER_RVR_STATS_UPDATED,  
                                             "GameData.Player.RvRStats.LifetimeKills" )

TomeWindow.TitlePage.stats[3] = NewTomeStat( "TomeWindowTitlePageStatTomeUnlocks",  
                                             StringTables.Default.TEXT_TOTAL_TOME_UNLOCKS, 
                                             SystemData.Events.TOME_STAT_TOTAL_UNLOCKS_UPDATED,  
                                             "GameData.Tome.Statistics.totalUnlocks" )

TomeWindow.TitlePage.stats[4] = NewTomeStat( "TomeWindowTitlePageStatTomeXp",  
                                             StringTables.Default.TEXT_TOTAL_XP_FROM_TOME_UNLOCKS, 
                                             SystemData.Events.TOME_STAT_TOTAL_XP_UPDATED,  
                                             "GameData.Tome.Statistics.totalXp" )

 
TomeWindow.NewEntries = {}
TomeWindow.NewEntries.unreadEntryWindowCount = 0

-- Unread Entires
TomeWindow.NUM_UNREAD_ENTRY_TOC_SLOTS = 20
TomeWindow.UNREAD_ENTRY_WIDTH = 425
 


function TomeWindow.InitalizeTitlePage()

    -- Unread Entires TOC
    TomeWindow.Pages[ TomeWindow.PAGE_TITLE_PAGE ]
        = TomeWindow.NewPageData( TomeWindow.Sections.SECTION_INTRODUCTION,
                    "TomeWindowTitlePage", 
                    TomeWindow.ShowTitlePage,
                    TomeWindow.OnTitlePageUpdateNavButtons,
                    TomeWindow.OnTitlePagePreviousPage,
                    TomeWindow.OnTitlePageNextPage,
                    TomeWindow.OnTitlePageMouseOverPreviousPage,
                    TomeWindow.OnTitlePageMouseOverNextPage )
                                  
    
    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.TOME_ALERTS_UPDATED, "TomeWindow.UpdateNewEntriesList" )
    
                                  
    LabelSetText( "TomeWindowTitlePageTitleKnowledge", wstring.upper(GetString( StringTables.Default.LABEL_TOK_KNOWLEDGE ) ) )
    LabelSetText( "TomeWindowTitlePageTitleTome", wstring.upper(GetString( StringTables.Default.LABEL_TOK_TOME ) ) )
    LabelSetText( "TomeWindowTitlePageTitleOf", GetString( StringTables.Default.LABEL_TOK_OF ) )
    LabelSetText( "TomeWindowTitlePageTitleThe", GetString( StringTables.Default.LABEL_TOK_THE ) )
    
    LabelSetText( "TomeWindowTitlePagePlayerTextIntro", GetString( StringTables.Default.TEXT_WAR_INTRODUCTION ) )
    local text = GetStringFormat( StringTables.Default.TEXT_WAR_INTRODUCTION_NAME, { GameData.Player.name, GameData.Player.career.name } )
    LabelSetText( "TomeWindowTitlePagePlayerText", text )
    
    ButtonSetText( PARENT_WINDOW.."PlayerTitle", GetString( StringTables.Default.TEXT_NO_TITLE_SELECTED ) )    
    
    
    -- Stats    
    for index, statData in ipairs( TomeWindow.TitlePage.stats ) do                  
        TomeWindow.AddTrackedStat( statData )
    end 
    -- Time Played
    ButtonSetDisabledFlag( "TomeWindowTitlePageStatHoursPlayedText", true )
    WindowRegisterEventHandler( "TomeWindowTitlePageStatHoursPlayed", SystemData.Events.TOME_STAT_PLAYED_TIME_UPDATED, "TomeWindow.OnUpdateTimePlayed" )
    TomeWindow.OnUpdateTimePlayed()

	ButtonSetDisabledFlag( "TomeWindowTitlePageStatSoloMMRText", true )
	TomeWindow.OnUpdateSoloMMR()
   
   	ButtonSetDisabledFlag( "TomeWindowTitlePageStatPremadeMMRText", true )	
	TomeWindow.OnUpdatePremadeMMR()
   
    PageWindowAddPageBreak( "TomeWindowTitlePagePageWindow", PARENT_WINDOW.."NewEntriesTitleAnchor" )     
    LabelSetText( PARENT_WINDOW.."NewEntriesTitle", wstring.upper( GetString( StringTables.Default.LABEL_NEW_ENTRIES ) ) )
    
    LabelSetText( PARENT_WINDOW.."NoNewEntriesText", GetString( StringTables.Default.TEXT_NO_NEW_ENTRIES ) )
    
    TomeWindow.UpdateNewEntriesList()

end

function TomeWindow.ShowTitlePage()
    WindowSetShowing( "TomeWindowTitlePageTitleImageGroup", true )
end

function TomeWindow.ClickTitlePagePlayerTitle()
    TomeWindow.SetState( TomeWindow.PAGE_REWARDS_INFO, {} )
end

function TomeWindow.TitlePageUpdateActiveTitle( title )
    ButtonSetText( PARENT_WINDOW.."PlayerTitle", title )
end


function TomeWindow.OnUpdateTimePlayed()
    local time = GameData.Tome.Statistics.playedTime
    local days = math.floor( time / 60 / 24 )
    time = time - days * 60 * 24
    local hours = math.floor( time / 60 )
    local minutes = time % 60
    local timeString = GetStringFormat( StringTables.Default.TEXT_PLAYED_TIME, {days, hours, minutes} )
    
    local id = WindowGetId( "TomeWindowTitlePageStatHoursPlayed" )
    TomeWindow.SetTOCItemText( "TomeWindowTitlePageStatHoursPlayed", id, GetString( StringTables.Default.LABEL_HOURS_PLAYED ), timeString )
end

function TomeWindow.OnUpdateSoloMMR()
    local id = WindowGetId( "TomeWindowTitlePageStatSoloMMR" )
--    TomeWindow.SetTOCItemText( "TomeWindowTitlePageStatSoloMMR", id, L"MMR Solo", L"1500" )
TomeWindow.SetTOCItemText( "TomeWindowTitlePageStatSoloMMR", id, L"MMR Solo", L"0" )
end

function TomeWindow.OnUpdatePremadeMMR()
    local id = WindowGetId( "TomeWindowTitlePageStatPremadeMMR" )
--    TomeWindow.SetTOCItemText( "TomeWindowTitlePageStatPremadeMMR", id, L"MMR Premade", L"1500" )
    TomeWindow.SetTOCItemText( "TomeWindowTitlePageStatPremadeMMR", id, L"MMR Premade", L"0" )
end

function TomeWindow.UpdateNewEntriesList()
        
    local tomeAlerts = DataUtils.GetTomeAlerts()
    
    local anchorWindow = PARENT_WINDOW.."NewEntriesAnchor"
    local xOffset = 0
    local yOffset = 10
    
    
    local alertCount = 0
    
    local newEntryWindowName = PARENT_WINDOW.."NewEntry"
    
    -- Update the List
    for alertIndex, alertData in ipairs( tomeAlerts )
    do
    
        alertCount = alertCount + 1        
        
        -- Create the UnreadEntry Window if necessary
        local unreadEntryWindowName = newEntryWindowName..alertIndex
        if( TomeWindow.NewEntries.unreadEntryWindowCount < alertIndex )
        then
            
            CreateWindowFromTemplate( unreadEntryWindowName, "TomeUnreadEntryWindow", PARENT_WINDOW )                    
            WindowAddAnchor( unreadEntryWindowName, "bottom", anchorWindow, "top", xOffset, yOffset )   
            
            TomeWindow.NewEntries.unreadEntryWindowCount = TomeWindow.NewEntries.unreadEntryWindowCount + 1
        end
        
        anchorWindow = unreadEntryWindowName   
        
        -- Set the Id
        WindowSetId( unreadEntryWindowName, alertIndex)         
        
        -- Set the Icon
        if( alertData.section ~= 0 )
        then
            local icon = DataUtils.GetTomeSectionIcon( alertData.section )
            DynamicImageSetTextureSlice( unreadEntryWindowName.."Icon", icon )
        end
        
        
        -- Set the Name
        local name = alertData.name
        if( name == L"" )
        then
            name = L"Unlock Event #"..alertData.id
        end        
        ButtonSetText( unreadEntryWindowName.."Text", name )
        
        
        local x, y = WindowGetDimensions( unreadEntryWindowName.."Text" )
        x = TomeWindow.UNREAD_ENTRY_WIDTH
        WindowSetDimensions( unreadEntryWindowName, x, y )
    
    end
    
    
    -- Show/Hide the appropriate number of unread entry windows.
    for index = 1, TomeWindow.NewEntries.unreadEntryWindowCount
    do
        local show = index <= alertCount
        local windowName = newEntryWindowName..index
        if( WindowGetShowing( windowName ) ~= show )
        then
            WindowSetShowing( windowName, show ) 
        end
        if( show == false )
        then
            WindowSetId( windowName, 0 ) 
        end
    end
    
    
    -- Show 'no new entires' text
    WindowSetShowing( PARENT_WINDOW.."NoNewEntriesText", alertCount == 0 )
    
    PageWindowUpdatePages( "TomeWindowTitlePagePageWindow" )   
    TomeWindow.OnTitlePageUpdateNavButtons()
end

function TomeWindow.OnClickUnreadEntry()
    local tomeAlerts = DataUtils.GetTomeAlerts()
    local alert = WindowGetId(SystemData.ActiveWindow.name)
    local alertData = tomeAlerts[alert]
    local alertId = alertData.id
    
    -- Open the tome to the link    
    TomeWindow.OpenTomeToEntry( alertData.section, alertData.entry, alertData.subEntry )
    
    RemoveTomeAlert( alertId )
end

function TomeWindow.OnViewEntry( section, entry, subEntry ) 
    local tomeAlerts = DataUtils.GetTomeAlerts()
    -- Bail out if there are no unread entries
    if( tomeAlerts[1] == nil )
    then
        return
    end
    
    -- Is this entry in the alert list? If yes, then remove it.
    for index, alertData in ipairs( tomeAlerts )
    do
        if( section == alertData.section 
            and entry == alertData.entry 
            and ( ( subEntry == nil and alertData.subEntry == 0 ) or (subEntry == alertData.subEntry) ) )
        then
            RemoveTomeAlert( alertData.id )
        end
    end
    
end

function TomeWindow.OnClearListEntries()
    local tomeAlerts = DataUtils.GetTomeAlerts()
    local ids = {}
    for index, alertData in ipairs( tomeAlerts )
    do
        if( alertData.id > 0 )
        then
            ids[index] = alertData.id
        end
    end
    
    -- Clear all of the Tome Alerts 
    for index, id in ipairs( ids )
    do
        RemoveTomeAlert( id )
    end

end


-- > Title page Nav Buttons
function TomeWindow.OnTitlePageUpdateNavButtons()
    if ( TomeWindow.GetCurrentState() ~= TomeWindow.PAGE_TITLE_PAGE )
    then
        return
    end
    
    local curPage   = PageWindowGetCurrentPage("TomeWindowTitlePagePageWindow")
    local numPages  = PageWindowGetNumPages("TomeWindowTitlePagePageWindow")
    WindowSetShowing( "TomeWindowPreviousPageButton", curPage > 1 )
    WindowSetShowing( "TomeWindowNextPageButton", curPage +2 <= numPages )  
end

function TomeWindow.OnTitlePagePreviousPage()
    TomeWindow.FlipPageWindowBackward( "TomeWindowTitlePagePageWindow")

    -- Special case for the title page, as the title image extends above the pagewindow
    local curPage = PageWindowGetCurrentPage("TomeWindowTitlePagePageWindow")
    WindowSetShowing( "TomeWindowTitlePageTitleImageGroup", curPage == 1 )
end

function TomeWindow.OnTitlePageMouseOverPreviousPage()    
    local lines = {}    
    local curPage   = PageWindowGetCurrentPage("TomeWindowTitlePagePageWindow")
    local numPages  = PageWindowGetNumPages("TomeWindowTitlePagePageWindow")
    
    if( curPage > 1 )
    then
        -- Previous Pages
        lines[1] = GetString( StringTables.Default.LABEL_NEW_ENTRIES )
        lines[2] = GetString( StringTables.Default.TEXT_CONTINUED )
    end 
    
    TomeWindow.CreateBackButtonTooltip( lines )
end

function TomeWindow.OnTitlePageNextPage()
    TomeWindow.FlipPageWindowForward( "TomeWindowTitlePagePageWindow")
    
    -- Special case for the title page, as the title image extends above the pagewindow
    local curPage = PageWindowGetCurrentPage("TomeWindowTitlePagePageWindow")
    WindowSetShowing( "TomeWindowTitlePageTitleImageGroup", curPage == 1 )
end

function TomeWindow.OnTitlePageMouseOverNextPage()    
    local lines = {}    
    local curPage   = PageWindowGetCurrentPage("TomeWindowTitlePagePageWindow")
    local numPages  = PageWindowGetNumPages("TomeWindowTitlePagePageWindow")
    
    if( curPage + 2 <= numPages )
    then
        -- Next Pages
        lines[1] = GetString( StringTables.Default.LABEL_NEW_ENTRIES )
        lines[2] = GetString( StringTables.Default.TEXT_CONTINUED )
    end
     
    TomeWindow.CreateNextButtonTooltip( lines )
end
