----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

TomeWindow = {}
TomeWindow.version = 2.0

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

-- Player Titles
TomeWindow.NUM_PLAYER_TITLE_SLOTS = 100

----
TomeWindow.FLIP_TIME = 6/12
TomeWindow.FADE_IN_TIME = 0.5

TomeWindow.Sections = {}
TomeWindow.Sections.SECTION_INTRODUCTION        = 1
TomeWindow.Sections.SECTION_QUESTS              = 2
TomeWindow.Sections.SECTION_CHAPTERS            = 3
TomeWindow.Sections.SECTION_ACHIEVEMENTS        = 4
TomeWindow.Sections.SECTION_REWARDS             = 5
TomeWindow.Sections.SECTION_LORE                = 6
TomeWindow.Sections.SECTION_NOTEWORTHY_PERSONS  = 7
TomeWindow.Sections.SECTION_BESTIARY            = 8
TomeWindow.Sections.SECTION_ARMORY              = 9
TomeWindow.Sections.SECTION_LIVE_EVENT          = 10

TomeWindow.Sections.NUM_SECTIONS = 10


TomeWindow.INACTIVE_BOOKMARK_ANCHOR_X = 112

TomeWindow.Sections[ TomeWindow.Sections.SECTION_INTRODUCTION ]
= {
    bookmarkWindow = "TomeWindowIntroductionBookmark",
    bookmarkAnchor = { x=136, y=80 },
    sectionIcon = nil
  }

TomeWindow.Sections[ TomeWindow.Sections.SECTION_QUESTS ]
= {
    bookmarkWindow = "TomeWindowQuestsBookmark",
    bookmarkAnchor = { x=137, y=180 },
    sectionIcon = "MiniSection-Quests"
  }

TomeWindow.Sections[ TomeWindow.Sections.SECTION_CHAPTERS ]
= {
    bookmarkWindow = "TomeWindowChaptersBookmark",
    bookmarkAnchor = { x=139, y=250 },
    sectionIcon = "MiniSection-Chapters"
  }

TomeWindow.Sections[ TomeWindow.Sections.SECTION_ACHIEVEMENTS ]
= {
    bookmarkWindow = "TomeWindowAchievementsBookmark",
    bookmarkAnchor = { x=140, y=320 },
    sectionIcon = "MiniSection-Achievements"
  }
  
TomeWindow.Sections[ TomeWindow.Sections.SECTION_REWARDS ]
= {
    bookmarkWindow = "TomeWindowRewardsBookmark",
    bookmarkAnchor = { x=139, y=390 },
    sectionIcon = "MiniSection-Rewards"
  }
  
TomeWindow.Sections[ TomeWindow.Sections.SECTION_LORE ]
= {
    bookmarkWindow = "TomeWindowLoreBookmark",
    bookmarkAnchor = { x=142, y=460 },
    sectionIcon = "MiniSection-Lore"
  }
  
TomeWindow.Sections[ TomeWindow.Sections.SECTION_NOTEWORTHY_PERSONS ]
= {
    bookmarkWindow = "TomeWindowNoteworthyPersonsBookmark",
    bookmarkAnchor = { x=141, y=530 },
    sectionIcon = "MiniSection-Lore"
  }
  
TomeWindow.Sections[ TomeWindow.Sections.SECTION_BESTIARY ]
= {
    bookmarkWindow = "TomeWindowBestiaryBookmark",
    bookmarkAnchor = { x=142, y=600 },
    sectionIcon = "MiniSection-Bestiary"
  }
  
TomeWindow.Sections[ TomeWindow.Sections.SECTION_ARMORY ]
= {
    bookmarkWindow = "TomeWindowArmoryBookmark",
    bookmarkAnchor = { x=147, y=670 },
    sectionIcon = "MiniSection-Armory"
  }
  
TomeWindow.Sections[ TomeWindow.Sections.SECTION_LIVE_EVENT ]
= {
    bookmarkWindow = "TomeWindowLiveEventBookmark",
    bookmarkAnchor = { x=148, y=740 },
    sectionIcon = nil
  }

  
  
-- Page Flipping modes & animations
TomeWindow.FlipModes = {}
TomeWindow.FLIP_NONE                = 0
TomeWindow.FLIP_FORWARD_SINGLE  = 1
TomeWindow.FLIP_BACKWARD_SINGLE = 2
TomeWindow.FLIP_FORWARD_MULTI       = 3
TomeWindow.FLIP_BACKWARD_MULTI  = 4
TomeWindow.FlipModes[ TomeWindow.FLIP_FORWARD_SINGLE ] = { window="TomeWindowPageFlipAnim", fps=18, time=0.3333 }
TomeWindow.FlipModes[ TomeWindow.FLIP_BACKWARD_SINGLE ] = { window="TomeWindowPageFlipBackAnim", fps=18, time=0.3333 }
TomeWindow.FlipModes[ TomeWindow.FLIP_FORWARD_MULTI ] = { window="TomeWindowPageFlipAnim", fps=12, time=0.5 }
TomeWindow.FlipModes[ TomeWindow.FLIP_BACKWARD_MULTI ] = { window="TomeWindowPageFlipBackAnim", fps=12, time=0.5 }


TomeWindow.Pages = {}
TomeWindow.PAGE_TITLE_PAGE                      = 1
TomeWindow.PAGE_QUEST_TOC                       = 2
TomeWindow.PAGE_QUEST_INFO                      = 3
TomeWindow.PAGE_WAR_JOURNAL_TOC                 = 4
TomeWindow.PAGE_WAR_JOURNAL_ENTRY_INFO          = 5
TomeWindow.PAGE_ACHIEVEMENTS_TOC                = 6
TomeWindow.PAGE_ACHIEVEMENTS_SUBTYPE_INFO       = 7
TomeWindow.PAGE_REWARDS_INFO                    = 8
TomeWindow.PAGE_HISTORY_AND_LORE_TOC            = 9
TomeWindow.PAGE_HISTORY_AND_LORE_ZONE_INFO      = 10
TomeWindow.PAGE_HISTORY_AND_LORE_ENTRY_INFO     = 11
TomeWindow.PAGE_NOTEWORTHY_PERSONS_TOC          = 12
TomeWindow.PAGE_NOTEWORTHY_PERSONS_ZONE_INFO    = 13
TomeWindow.PAGE_NOTEWORTHY_PERSONS_ENTRY_INFO   = 14
TomeWindow.PAGE_BESTIARY_TOC                    = 15
TomeWindow.PAGE_BESTIARY_SUBTYPE_INFO           = 16
TomeWindow.PAGE_BESTIARY_SPECIES_INFO           = 17
TomeWindow.PAGE_OLD_WORLD_ARMORY                = 18
TomeWindow.PAGE_OLD_WORLD_ARMORY_SIGILS_TOC     = 19
TomeWindow.PAGE_SIGIL                           = 20
TomeWindow.PAGE_LIVE_EVENT                      = 21
TomeWindow.PAGE_LIVE_EVENT_TASK_DETAILS         = 22
TomeWindow.PAGE_LIVE_EVENT_LIST                 = 23

TomeWindow.Pages.NUM_PAGES = 23


-- Constructor function for a single tome 'page'
function TomeWindow.NewPageData( isectionId, 
                            iwindowName, 
                            iOnSetState,
                            iUpdateNavButtons,
                            iPrevPageCallback, 
                            iNextPageCallback, 
                            iPrevPageMouseOver, 
                            iNextPageMouseOver,
                            iOnOpenCallback)
    
    WindowSetShowing( iwindowName, false )
    
    return { sectionId=isectionId, 
             windowName=iwindowName, 
             OnSetState=iOnSetState,
             UpdateNavButtons=iUpdateNavButtons,
             PrevPageCallback=iPrevPageCallback, 
             NextPageCallback=iNextPageCallback,
             PrevPageMouseOver=iPrevPageMouseOver, 
             NextPageMouseOver=iNextPageMouseOver,
             leftHeaderText=L"",
             rightHeaderText=L"",
             OnOpenCallback=iOnOpenCallback}
end



function NewStateData( ipageType, iparams, iflipModeParams )
    return { pageType = ipageType, params = iparams, flipModeParams = iflipModeParams }
end
TomeWindow.currentState = nil
TomeWindow.stateHistoryQueue = Queue:Create()
TomeWindow.stateHistoryCount = 0
TomeWindow.MAX_HISTORY = 10

TomeWindow.braggingRights = nil
TomeWindow.braggingRightsCards = nil

----------------------------------------------------------------
--  Util Functions

function TomeWindow.CreateBackButtonTooltip( textLines )     
    
    Tooltips.CreateTextOnlyTooltip( SystemData.MouseOverWindow.name )       
    
    Tooltips.SetTooltipText( 1, 1, GetString( StringTables.Default.LABEL_PREVIOUS_PAGE ))
    Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )     
    
    for line, text in ipairs( textLines ) do
        Tooltips.SetTooltipText( line+1, 1, text)
    end
    
    Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )     
    
    Tooltips.Finalize()
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT )   
end

function TomeWindow.CreateNextButtonTooltip( textLines ) 
    
    Tooltips.CreateTextOnlyTooltip( SystemData.MouseOverWindow.name )       
    
    Tooltips.SetTooltipText( 1, 1, GetString( StringTables.Default.LABEL_NEXT_PAGE ))
    Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )     
    
    for line, text in ipairs( textLines ) do
        Tooltips.SetTooltipText( line+1, 1, text)
    end     
    
    Tooltips.Finalize()
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT )  
end


local function DetermineFlipMode( pageType, params )
    if( TomeWindow.currentState.pageType < pageType ) then
        return TomeWindow.FLIP_FORWARD_MULTI
    elseif( TomeWindow.currentState.pageType > pageType ) then
        return TomeWindow.FLIP_BACKWARD_MULTI
    end
    
    if( TomeWindow.currentState.flipModeParams[1] ~= nil and params[1] ~= nil ) then
        if( TomeWindow.currentState.flipModeParams[1] < params[1] ) then
            return TomeWindow.FLIP_FORWARD_MULTI
        elseif( TomeWindow.currentState.flipModeParams[1] > params[1] ) then
            return TomeWindow.FLIP_BACKWARD_MULTI
        end 
    end
    
    if( TomeWindow.currentState.flipModeParams[2] ~= nil and params[2] ~= nil ) then
        if( TomeWindow.currentState.flipModeParams[2] < params[2] ) then
            return TomeWindow.FLIP_FORWARD_SINGLE
        elseif( TomeWindow.currentState.flipModeParams[2] > params[2] ) then
            return TomeWindow.FLIP_BACKWARD_SINGLE
        end
    end     
    return TomeWindow.FLIP_NONE
end

-- Returns true when the flip successs,
-- False when the PageWindow is already on the first page
function TomeWindow.FlipPageWindowBackward( pageWindow )

    local curPage   = PageWindowGetCurrentPage( pageWindow )    
    if( curPage == 1 ) then
        return false
    end
    
    local flipPages = PageWindowGetNumPagesDisplayed( pageWindow )
    
    -- Flip the page window back & play the animation
    PageWindowSetCurrentPage( pageWindow, curPage - flipPages )
    TomeWindow.PlayFlipAnim( TomeWindow.FLIP_BACKWARD_SINGLE )
    
    return true
end

-- Returns true when the flip successs,
-- False when the PageWindow is already on the last page
function TomeWindow.FlipPageWindowForward( pageWindow )

    local curPage   = PageWindowGetCurrentPage( pageWindow )
    local numPages  = PageWindowGetNumPages( pageWindow )
    local flipPages = PageWindowGetNumPagesDisplayed( pageWindow )  
  
    --DEBUG(L" curPage = "..curPage..L" numPages = "..numPages..L" flipPages = "..flipPages )
    if( curPage + flipPages > numPages ) then
        return false
    end
    
    -- Flip the page window forward & play the animation
    PageWindowSetCurrentPage( pageWindow, curPage + flipPages )
    TomeWindow.PlayFlipAnim( TomeWindow.FLIP_FORWARD_SINGLE )

    return true
end

----------------------------------------------------------------
-- TomeWindow Core Functions
----------------------------------------------------------------

-- OnInitialize Handler
function TomeWindow.Initialize()        
        
    TomeWindow.currentState = NewStateData( 0, 0, 0, 0 )    
    
    CreateMapInstance( "TomeWindowMapDisplay", SystemData.MapTypes.NORMAL )

    -- Introduction Sections
    TomeWindow.InitalizeTitlePage()
    
     -- Personal Journal Sections
    TomeWindow.InitializeQuestJournal() 
    TomeWindow.InitializeWarJournal()
    TomeWindow.InitializeRewards()
    TomeWindow.InitializeAchievements()
    
    -- Compendium Sections
    TomeWindow.InitializeBestiary()
    TomeWindow.InitializeNoteworthyPersons()
    TomeWindow.InitializeHistoryAndLore()
    TomeWindow.InitializeOldWorldArmorySigilsTOC()
    TomeWindow.InitializeOldWorldArmory()
    TomeWindow.InitializeSigils()

    -- Live Event
    TomeWindow.InitializeLiveEvent()
    
    TomeWindow.SetBookmark( TomeWindow.Sections.SECTION_INTRODUCTION )
   
    TomeWindow.ClearHistory()
    
    -- handle bragging rights updates
    TomeWindow.braggingRights, TomeWindow.braggingRightsCards = GetBraggingRights()
    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.SOCIAL_BRAGGING_RIGHTS_UPDATED, "TomeWindow.OnBraggingRightsUpdated") 
    
    local params = { 1 }
    TomeWindow.SetState( TomeWindow.PAGE_TITLE_PAGE, params )
       
    
    MapUtils.RegisterOpenTomeToQuestCallback( TomeWindow.OpenToQuest )
    MapUtils.RegisterOpenTomeToEventTaskCallback( TomeWindow.OpenToEventTask )
    MapUtils.RegisterToggleTomeCallback( TomeWindow.ToggleShowing )
    
    -- Prepare custom tooltip window
    local windowName = "TacticCounterTooltip"
    CreateWindow( windowName, false )
    WindowSetTintColor( windowName.."BackgroundInner", 0, 0, 0 )
    WindowSetAlpha( windowName.."BackgroundInner", .9 )
end

-- OnShutdown Handler
function TomeWindow.Shutdown()    
    RemoveMapInstance( "TomeWindowMapDisplay" )
end


-- OnUpdate Handler
function TomeWindow.Update( timePassed )
               
    if( TomeWindow.currentQuestData and TomeWindow.maxTimer ~= 0 ) then             
        
        local timeLeft = TomeWindow.currentQuestData.timeLeft
        --DEBUG(L"Time Left = "..timeLeft )
                
        local mins = math.floor( timeLeft/60 )
        local secs =  math.floor( timeLeft - mins*60 )
        
        local text = wstring.format(L"%d:%02d", mins, secs+1)
        LabelSetText( "TomeWindowQuestInfoTimerValue", text )   
   end

end


function TomeWindow.ToggleShowing()  
    local showing = WindowGetShowing( "TomeWindow" )
    if( showing == true ) then  
        WindowSetShowing( "TomeWindow", false )
        if InterfaceCore.inGame
        then
            Sound.Play( Sound.TOME_CLOSE )
        end
    else
        WindowSetShowing( "TomeWindow", true )
        Sound.Play( Sound.TOME_OPEN )
		RoR_MatchMakingRaiting.Enable()
    end
end

function TomeWindow.OnOpen()
   WindowUtils.OnShown()
   TomeWindow.PlayFlipAnim( TomeWindow.FLIP_FORWARD_MULTI )   
    local pageData = TomeWindow.Pages[ TomeWindow.currentState.pageType ]
    if pageData ~= nil
    then
        if pageData.OnOpenCallback ~= nil
        then 
            pageData.OnOpenCallback()
        end
    end
   
   
end

function TomeWindow.OnClose()
    WindowUtils.OnHidden()
end

function TomeWindow.Hide() 
   --BroadcastEvent( SystemData.Events.TOGGLE_TOME_WINDOW )
   WindowSetShowing( "TomeWindow", false )
end

function TomeWindow.ClearHistory()
    while( not TomeWindow.stateHistoryQueue:IsEmpty() )
    do
        TomeWindow.stateHistoryQueue:PopBack()
    end
    TomeWindow.stateHistoryCount = 0
end

function TomeWindow.IsCurrentPage( pageType, params )

    if( pageType ~= TomeWindow.currentState.pageType ) then
        return false
    end
    
    for key, value in pairs( params ) do       
        if( value ~= TomeWindow.currentState.params[key] ) then
            return false
        end
    end

    return true
end


function TomeWindow.SetBookmark( pageType )
    -- Reset all bookmarks
    for section = 1, TomeWindow.Sections.NUM_SECTIONS do
        WindowClearAnchors( TomeWindow.Sections[ section ].bookmarkWindow )
        local x = TomeWindow.INACTIVE_BOOKMARK_ANCHOR_X
        local y = TomeWindow.Sections[ section ].bookmarkAnchor.y
        WindowAddAnchor( TomeWindow.Sections[ section ].bookmarkWindow,
            "topleft", "TomeWindow", "topright", x, y )
    end
    
    -- Set the active bookmark
    local pageData = TomeWindow.Pages[ pageType ]
    local section = pageData.sectionId
    WindowClearAnchors( TomeWindow.Sections[ section ].bookmarkWindow )
    local x = TomeWindow.Sections[ section ].bookmarkAnchor.x
    local y = TomeWindow.Sections[ section ].bookmarkAnchor.y
    WindowAddAnchor( TomeWindow.Sections[ section ].bookmarkWindow,
        "topleft", "TomeWindow", "topright", x, y )
end


function TomeWindow.SetState( pageType, params, flipModeParams )

    if( pageType == nil ) then    
        ERROR_TRACE( L"TomeWindow.SetState(): pageType == nil " ) 
        return 
    end
    

     -- Return if we're already showing this state
    if( TomeWindow.IsCurrentPage( pageType, params ) ) then
        return
    end
    

    -- Add the Current State to the History
    if( TomeWindow.currentState ~= nil and TomeWindow.currentState.pageType ~= 0 )
    then
        TomeWindow.stateHistoryQueue:PushBack( TomeWindow.currentState )
        TomeWindow.stateHistoryCount = TomeWindow.stateHistoryCount + 1
        --DEBUG( L"History Count: "..TomeWindow.stateHistoryCount )
    end
    
    if( TomeWindow.stateHistoryCount > TomeWindow.MAX_HISTORY )
    then
        TomeWindow.stateHistoryQueue:PopFront()
        TomeWindow.stateHistoryCount = TomeWindow.stateHistoryCount - 1
        --DEBUG( L"Trimmed History - Count: "..TomeWindow.stateHistoryCount )
    end
    
    -- Set the State
    TomeWindow.ShowPage( pageType, params, flipModeParams )
end

function TomeWindow.ShowPage( pageType, params, flipModeParams )

    if( pageType == nil ) then    
        ERROR_TRACE( L"TomeWindow.ShowPage(): pageType == nil " ) 
        return 
    end
    

    if( TomeWindow.currentState ~= nil and TomeWindow.currentState.pageType ~= 0 ) then        
        local oldPageData = TomeWindow.Pages[ TomeWindow.currentState.pageType ]
        WindowSetShowing( oldPageData.windowName, false )
    end

    if( flipModeParams == nil )
    then
        flipModeParams = params
    end
    local flipMode = DetermineFlipMode( pageType, flipModeParams )

    local lastState = TomeWindow.currentState   
    TomeWindow.currentState = NewStateData( pageType, params, flipModeParams )
    if( pageType == 0 ) then
        return
    end
    --DEBUG(L" -> TomeWindow.ShowPage(): pageType="..pageType )
    
    -- Clear the Map
    TomeWindow.ClearMap()
    
    -- Adjust bookmarks
    TomeWindow.SetBookmark( pageType )
    
    -- Show the current page
    local pageData = TomeWindow.Pages[ pageType ]
    WindowSetShowing( pageData.windowName, true )
    
    if( pageData.OnSetState ) then 
        pageData.OnSetState( params[1], params[2], params[3] )
    end
    
    -- Hide the previous/next page buttons if callbacks arn't set for this page type
    -- And update the mouseover if we're currently mousing over of these buttons
    if( pageData.UpdateNavButtons ) then
        pageData.UpdateNavButtons()
        if( SystemData.MouseOverWindow.name == "TomeWindowPreviousPageButton" and pageData.PrevPageMouseOver ) then
            pageData.PrevPageMouseOver()
        elseif( SystemData.MouseOverWindow.name == "TomeWindowNextPageButton" and pageData.NextPageMouseOver ) then
            pageData.NextPageMouseOver()
        end
    else    
        WindowSetShowing( "TomeWindowPreviousPageButton", false)
        WindowSetShowing( "TomeWindowNextPageButton", false)
    end
    
    
    -- Update the Header
    TomeWindow.SetHeaderInfo( TomeWindow.Pages[ pageType ].leftHeaderText, 
                              TomeWindow.Pages[ pageType ].rightHeaderText )
    
    -- Update the Footer
    local section = TomeWindow.Pages[ pageType ].sectionId
    local iconData = TomeWindow.Sections[ section ].sectionIcon
    local iconExists = iconData ~= nil
    WindowSetShowing( "TomeWindowLeftPageNumber", iconExists )
    WindowSetShowing( "TomeWindowRightPageNumber", iconExists )
    if( iconExists )
    then
        DynamicImageSetTextureSlice( "TomeWindowLeftPageNumber", iconData )
        DynamicImageSetTextureSlice( "TomeWindowRightPageNumber", iconData )
    end
    

    TomeWindow.PlayFlipAnim( flipMode )
    
end

function TomeWindow.GetCurrentState()
    return TomeWindow.currentState.pageType
end


function TomeWindow.PlayFlipAnim( flipMode )   
   
    if( flipMode == TomeWindow.FLIP_NONE ) then
        return
    end
   
    local animWindow = TomeWindow.FlipModes[flipMode].window
    local fps = TomeWindow.FlipModes[flipMode].fps
    local delay = TomeWindow.FlipModes[flipMode].time
    
    -- Start the Anim
    WindowSetShowing( animWindow, true )
    AnimatedImageSetPlaySpeed( animWindow, fps )
    AnimatedImageStartAnimation( animWindow, 0, false, true, 0 )

    -- Fade in the current page & center section bookmark
    local pageData = TomeWindow.Pages[ TomeWindow.currentState.pageType ]
    if( pageData == nil ) then
        DEBUG(L"pageData is nil for PageType = "..TomeWindow.currentState.pageType )
        return
    end

    --WindowSetAlpha( pageData.windowName, 0 )
    --WindowSetFontAlpha( pageData.windowName, 0 )
    WindowStartAlphaAnimation( pageData.windowName, Window.AnimationType.SINGLE_NO_RESET, 0, 1, 
            TomeWindow.FADE_IN_TIME, true, delay, 0 )
                        
    -- Fade in the nav buttons if they are showing
    if( WindowGetShowing( "TomeWindowPreviousPageButton" ) == true ) then
        --WindowSetAlpha( "TomeWindowPreviousPageButton", 0 )
        WindowStartAlphaAnimation( "TomeWindowPreviousPageButton", Window.AnimationType.SINGLE_NO_RESET, 0, 1, 
            TomeWindow.FADE_IN_TIME, true, delay, 0 )  
    end
    
    if( WindowGetShowing( "TomeWindowNextPageButton" ) == true ) then
        --WindowSetAlpha( "TomeWindowNextPageButton", 0 )
        WindowStartAlphaAnimation( "TomeWindowNextPageButton", Window.AnimationType.SINGLE_NO_RESET, 0, 1, 
            TomeWindow.FADE_IN_TIME, true, delay, 0 )  
    end
    
    -- Fade in map if it is showing
    if( WindowGetShowing( "TomeWindowMap" ) == true ) then
        WindowStartAlphaAnimation( "TomeWindowMap", Window.AnimationType.SINGLE_NO_RESET, 0, 1,
            TomeWindow.FADE_IN_TIME, true, delay, 0 )
    end
    
    -- Play the flip sound
    if( WindowGetShowing( "TomeWindow" ) ) then
        Sound.Play( Sound.TOME_TURN_PAGE )
    end
end

function TomeWindow.GoBack()
    
    if( TomeWindow.stateHistoryQueue:IsEmpty() ) then
        return
    end
    
    local lastState = TomeWindow.stateHistoryQueue:PopBack()
    TomeWindow.stateHistoryCount = TomeWindow.stateHistoryCount - 1
   
    TomeWindow.ShowPage( lastState.pageType, lastState.params, {TomeWindow.FLIP_BACKWARD_MULTI} )
end

function TomeWindow.OnMouseoverBackBtn()
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, GetString( StringTables.Default.LABEL_GO_BACK ) )
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT )
end

function TomeWindow.OnMouseoverCloseBtn()
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, GetString( StringTables.Default.LABEL_CLOSE_TOME ) )
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT )
end


function TomeWindow.OnPreviousPage()

    local pageType = TomeWindow.currentState.pageType
    local pageData = TomeWindow.Pages[ pageType ]
    if( pageData ) then
        if( pageData.PrevPageCallback ) then pageData.PrevPageCallback() end        
        
        -- Update the Nav Buttons if the are still in the same section
        if( pageType == TomeWindow.currentState.pageType and pageData.UpdateNavButtons ) then
            pageData.UpdateNavButtons() 
        end
    end
    
    -- Update the tooltip
    TomeWindow.OnMouseOverPreviousPage()
end

function TomeWindow.OnMouseOverPreviousPage()
    local pageData = TomeWindow.Pages[ TomeWindow.currentState.pageType ]
    if( pageData ~= nil and pageData.PrevPageMouseOver ~= nil) then
        pageData.PrevPageMouseOver()
    end
end

function TomeWindow.OnNextPage()
    
    local pageType = TomeWindow.currentState.pageType
    local pageData = TomeWindow.Pages[ pageType ]
    if( pageData ) then
        if( pageData.NextPageCallback ) then pageData.NextPageCallback() end    
        
        -- Update the Nav Buttons if the are still in the same section
        if( pageType == TomeWindow.currentState.pageType and pageData.UpdateNavButtons ) then
            pageData.UpdateNavButtons() 
        end
    end
    
    -- Update the tooltip
    TomeWindow.OnMouseOverNextPage()
end


function TomeWindow.OnMouseOverNextPage()
    local pageData = TomeWindow.Pages[ TomeWindow.currentState.pageType ]
    if( pageData ~= nil and pageData.NextPageMouseOver ~= nil) then
        pageData.NextPageMouseOver()
    end
end

----------------------------------------------------------------
-- Tome Map Utils
----------------------------------------------------------------
function TomeWindow.UseMap( anchorWindow, mapMode, mapId )

    WindowClearAnchors( "TomeWindowMap" )
    WindowAddAnchor( "TomeWindowMap", "topleft", anchorWindow, "topleft", 0, 0 )
    WindowAddAnchor( "TomeWindowMap", "bottomright", anchorWindow, "bottomright", 0, 0 )
    
    WindowSetShowing( "TomeWindowMap", true )
    
    MapSetMapView( "TomeWindowMapDisplay", mapMode, mapId )
end

function TomeWindow.ClearMap()
    if( WindowGetShowing( "TomeWindowMap" ) ==  true  ) then
        WindowSetShowing( "TomeWindowMap", false )
    end
end


function TomeWindow.ShowMap( show )
    if( WindowGetShowing( "TomeWindowMap" ) ~=  show  ) then
        WindowSetShowing( "TomeWindowMap", show )
    end
end


function TomeWindow.OnMouseOverMapPoint()
    Tooltips.CreateMapPointTooltip( "TomeWindowMapDisplay", TomeWindowMapDisplay.MouseoverPoints, Tooltips.ANCHOR_CURSOR, Tooltips.MAP_TYPE_OTHER )   
end

function TomeWindow.OnClickMap()
    MapUtils.ClickMap( "TomeWindowMapDisplay", TomeWindowMapDisplay.MouseoverPoints )   
end


----------------------------------------------------------------
-- Bookmark Functions
----------------------------------------------------------------

function TomeWindow.OnIntroductionBookmark()
   local params = {}
   TomeWindow.SetState( TomeWindow.PAGE_TITLE_PAGE, params )
end

function TomeWindow.OnMouseoverIntroductionBookmark()
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, GetString( StringTables.Default.LABEL_INTRODUCTION ) )
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT )
end

function TomeWindow.OnQuestsBookmark()
   local params = {}
   TomeWindow.SetState( TomeWindow.PAGE_QUEST_TOC, params )
end

function TomeWindow.OnMouseoverQuestsBookmark()
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, GetString( StringTables.Default.LABEL_QUESTS ) )
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT )
end

function TomeWindow.OnChaptersBookmark()
   local params = {}
   TomeWindow.SetState( TomeWindow.PAGE_WAR_JOURNAL_TOC, params )
end

function TomeWindow.OnMouseoverChaptersBookmark()
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, GetString( StringTables.Default.LABEL_WAR_JOURNAL ) )
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT )
end

function TomeWindow.OnAchievementsBookmark()
   local params = {}
   TomeWindow.SetState( TomeWindow.PAGE_ACHIEVEMENTS_TOC, params )
end

function TomeWindow.OnMouseoverAchievementsBookmark()
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, GetString( StringTables.Default.TEXT_ACHIEVEMENTS_TOC ) )
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT )
end

function TomeWindow.OnRewardsBookmark()
   local params = {}
   TomeWindow.SetState( TomeWindow.PAGE_REWARDS_INFO, params )
end

function TomeWindow.OnMouseoverRewardsBookmark()
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, GetString( StringTables.Default.LABEL_REWARDS ) )
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT )
end

function TomeWindow.OnLoreBookmark()
   local params = {}
   TomeWindow.SetState( TomeWindow.PAGE_HISTORY_AND_LORE_TOC, params )
end

function TomeWindow.OnMouseoverLoreBookmark()
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, GetString( StringTables.Default.LABEL_HISTORY_AND_LORE ) )
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT )
end

function TomeWindow.OnNoteworthyPersonsBookmark()
   local params = {}
   TomeWindow.SetState( TomeWindow.PAGE_NOTEWORTHY_PERSONS_TOC, params )
end

function TomeWindow.OnMouseoverNoteworthyPersonsBookmark()
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, GetString( StringTables.Default.LABEL_NOTEWORTHY_PERSONS ) )
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT )
end

function TomeWindow.OnBestiaryBookmark()
   local params = {}
   TomeWindow.SetState( TomeWindow.PAGE_BESTIARY_TOC, params )
end

function TomeWindow.OnMouseoverBestiaryBookmark()
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, GetString( StringTables.Default.LABEL_BESTIARY ) )
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT )
end

function TomeWindow.OnArmoryBookmark()
   local params = {}
   TomeWindow.SetState( TomeWindow.PAGE_OLD_WORLD_ARMORY_SIGILS_TOC, params )
end

function TomeWindow.OnMouseoverArmoryBookmark()
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, GetString( StringTables.Default.LABEL_OLD_WORLD_ARMORY ) )
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT )
end

function TomeWindow.OnLiveEventBookmark()
    local liveEventList = GetLiveEventList()
    if ( ( liveEventList[1] ~= nil ) and ( liveEventList[2] == nil ) )
    then
        -- Exactly one live event loaded, go straight to the page to display it
        local eventId = liveEventList[1].id
        TomeWindow.SetState( TomeWindow.PAGE_LIVE_EVENT, { eventId } )
        
        local eventData = GetLiveEventData( eventId )
        if ( eventData.soundId ~= 0 )
        then
            Sound.Play( eventData.soundId )
        end
    else
        -- Show a menu so player can pick which live event to view
        local params = {}
        TomeWindow.SetState( TomeWindow.PAGE_LIVE_EVENT_LIST, params )
    end
end

function TomeWindow.OnMouseoverLiveEventBookmark()
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, GetStringFromTable( "LiveEventStrings", StringTables.LiveEventStrings.LABEL_LIVE_EVENT ) )
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT )
end

-- *****************************************************************************
-- TOME Hyper Link Handling

function TomeWindow.OnHyperLinkClicked( linkParam )

    -- Tome Links should be in this format: L"TOME1:200"
    -- This means section 1, entry 200
     -- or
    -- Tome Links should be in this format: L"TOME20:2:10"
    -- This means section 20, entry 2, subEntry 10
    
    if( wstring.sub(linkParam, 1, 4) ~= L"TOME" ) then
       return
    end
    
    DEBUG(L" Link = "..linkParam )
    
    local colonPos1  = wstring.find(linkParam, L":", 1)
       
    local section   = tonumber( wstring.sub(linkParam, 5, colonPos1-1) )
   
    local subString = wstring.sub(linkParam, colonPos1+1 )
    local colonPos2  = wstring.find(subString, L":")
    
    local entry, subEntry
    if( colonPos2 ~= nil ) then     
        entry       = tonumber( wstring.sub(subString, 0, colonPos2-1 ) )
        subEntry    = tonumber( wstring.sub(subString, colonPos2+1 ) )
    else
        entry       = tonumber( subString )
        subEntry    = 0
    end
    
    --DEBUG(L" section = "..section..L", entry #"..entry )    
    TomeWindow.OpenTomeToEntry( section, entry, subEntry )
    
end

function TomeWindow.OpenTomeToEntry( section, entry, subEntry )   
    
    --DEBUG(L" Opening Tome: section = "..section..L", entry #"..entry )    

    -- Map Links

    if( section == GameData.Tome.SECTION_ZONE_MAPS ) then

        EA_Window_WorldMap.SetMap( GameDefs.MapLevel.ZONE_MAP, entry )
        

        -- Open the Map if it is closed
        if( WindowGetShowing( "EA_Window_WorldMap" ) == false  )
        then           
            EA_Window_OverheadMap.ToggleWorldMapWindow()
        end
        
        return
    end
    
    -- Open the Tome if it is closed.
    -- We do this before flipping to the chapter so we avoid the intro page opening when we have new entries.
    if( WindowGetShowing( "TomeWindow" ) == false ) then            
        MenuBarWindow.ToggleTomeWindow() 
    end

    -- Tome Links        
    if( section == GameData.Tome.SECTION_BESTIARY ) then
        TomeWindow.SetState( TomeWindow.PAGE_BESTIARY_SPECIES_INFO, { entry } )
    elseif( section == GameData.Tome.SECTION_NOTEWORTHY_PERSONS ) then
        TomeWindow.ShowNoteworthyPersonsEntry( entry )
    elseif( section == GameData.Tome.SECTION_HISTORY_AND_LORE ) then
        TomeWindow.ShowHistoryAndLoreEntry( entry )
    elseif( section == GameData.Tome.SECTION_WAR_JOURNAL ) then
        TomeWindow.ShowWarJournalEntry( entry )
    elseif( section == GameData.Tome.SECTION_PLAYER_TITLES ) then
        TomeWindow.SetState( TomeWindow.PAGE_REWARDS_INFO, { entry } )
    elseif( section == GameData.Tome.SECTION_ACHIEVEMENTS ) then
        TomeWindow.ShowAchievementsEntry( entry )
    elseif( section == GameData.Tome.SECTION_OLD_WORLD_ARMORY ) then
        TomeWindow.SetState( TomeWindow.PAGE_OLD_WORLD_ARMORY, { entry } )
    elseif( section == GameData.Tome.SECTION_ARMORY_SIGILS ) then
        TomeWindow.SetState( TomeWindow.PAGE_SIGIL, { entry } )
    elseif( section == GameData.Tome.SECTION_TACTICS ) then
        TomeWindow.SetState( TomeWindow.PAGE_TACTIC_REWARDS_SECTION, {} )
    elseif( section == GameData.Tome.SECTION_LIVE_EVENT ) then
        if ( ( entry ~= nil ) and ( entry > 0 ) )
        then
            if ( ( subEntry ~= nil ) and ( subEntry > 0 ) )
            then
                TomeWindow.SetState( TomeWindow.PAGE_LIVE_EVENT_TASK_DETAILS, { entry, subEntry } )
            else
                TomeWindow.SetState( TomeWindow.PAGE_LIVE_EVENT, { entry } )
            end
        else
            TomeWindow.SetState( TomeWindow.PAGE_LIVE_EVENT_LIST, {} )
        end
    else
        -- Error fallback.
        TomeWindow.SetState( TomeWindow.PAGE_TITLE_PAGE, {} )
    end    
    
end


-- Sets Up a Table of Contents line
function TomeWindow.SetTOCItemText( windowName, windowId, itemText, pageNumberText )
    
    -- Set the Window Id
    WindowSetId( windowName, windowId )
    
    -- Set the Text Fields
    ButtonSetText( windowName.."Text", itemText )
    LabelSetText( windowName.."Number", pageNumberText )
    
    -- Resize the the height of the TOC item if necessary.   
    local width, height = WindowGetDimensions( windowName )
    local x, y = WindowGetDimensions( windowName.."Text" )     
    
    WindowSetDimensions( windowName, width, math.max( height, y ) )        

    -- Set the Dotted Line Text Last, after it has been sized.
    WindowForceProcessAnchors( windowName )
    LabelSetText( windowName.."DottedLine", L"..............................................................................." )
    
end

-- Sets the Header Information
function TomeWindow.SetHeaderInfo( leftText, rightText )
    
    -- Set the Text
    LabelSetText("TomeWindowHeaderLeftText", leftText )
    LabelSetText("TomeWindowHeaderRightText", rightText )

end

function TomeWindow.SetPageHeaderText( page, left, right )
    if( TomeWindow.Pages[ page ] == nil ) then
        return
    end
    
    TomeWindow.Pages[ page ].leftHeaderText = left
    TomeWindow.Pages[ page ].rightHeaderText = right
    
    -- If this is our current page, update the text    
    if( TomeWindow.GetCurrentState() == page ) then
        TomeWindow.SetHeaderInfo( left, right )
    end
end


function TomeWindow.SetTomeReward( rewardWindowName, rewardData )
    
    
    if( rewardData == nil ) then
        WindowSetShowing( rewardWindowName, false )
        return
    end
    
    if( rewardData.rewardId == 0 ) then
        WindowSetShowing( rewardWindowName, false )
        return
    end
    
    --DEBUG(L"TomeWindow.OnMouseOverTomeReward(): window="..StringToWString(rewardWindowName)..L" type="..rewardData.rewardType..L" id="..rewardData.rewardId )
    
    WindowSetShowing( rewardWindowName, true )

    local iconNum = 0
    
    if( rewardData.rewardId ~= 0 ) then

        --Set up the icon for the reward
        if( GameData.Tome.REWARD_ITEM == rewardData.rewardType or
            GameData.Tome.REWARD_ITEM_NO_AUTOCREATE == rewardData.rewardType )
        then
         
            local itemData = TomeGetItemRewardData( rewardData.rewardId )
            iconNum = itemData.iconNum
            
        elseif( GameData.Tome.REWARD_ABILITY == rewardData.rewardType ) then
        
            local tacticData = TomeGetTacticRewardData( rewardData.rewardId )
            iconNum = tacticData.iconNum
            
        elseif( GameData.Tome.REWARD_ABILITY_COUNTER == rewardData.rewardType ) then
        
            iconNum = GameDefs.Icons.ICON_TACTIC_REWARD
            
        elseif( GameData.Tome.REWARD_XP == rewardData.rewardType ) then
        
            iconNum = GameDefs.Icons.ICON_XP_REWARD
            
        elseif( GameData.Tome.REWARD_TITLE == rewardData.rewardType ) then
           
            iconNum = GameDefs.Icons.ICON_TITLE_REWARD
            
        end    
    end                
    
    --DEBUG(L"Icon num = "..iconNum )    
    
    if( iconNum == 0 )
    then
        WindowSetShowing( rewardWindowName, false )
        return
    end

    if( iconNum )
    then
        local texture, x, y = GetIconData( iconNum )        
        DynamicImageSetTexture( rewardWindowName.."IconBase", texture, x, y )
    end

end

local function BuildTacticCounterTooltip( lineName, progress, rewards )
    local windowName = "TacticCounterTooltip"
    local totalHeight = 0
    local height = 0
    local TOOLTIP_PAD = 15

    local title = GetFormatStringFromTable( "Default", StringTables.Default.TOOLTIP_TOME_TACTIC_COUNTER_X_FRAGMENT, { lineName } )
    LabelSetText( windowName.."Title", title )
    _, height = WindowGetDimensions( windowName.."Title" )
    totalHeight = totalHeight + height
    
    local descText = GetFormatStringFromTable( "Default", StringTables.Default.TOOLTIP_TOME_TACTIC_COUNTER_HELP, { lineName } )
    LabelSetText( windowName.."Text", descText )
    _, height = WindowGetDimensions( windowName.."Text" )
    totalHeight = totalHeight + height + TOOLTIP_PAD
    
    local maxThreshold = 0
    for index, reward in ipairs( rewards )
    do
        local tactic = TomeGetTacticCounterRewardData( reward.rewardId )
        local tacticText = GetFormatStringFromTable( "Default", StringTables.Default.TOOLTIP_X_REQUIRES_Y_FRAGMENTS, { tactic.name, reward.threshold } )
        local texture, x, y = GetIconData( tactic.iconNum )
        DynamicImageSetTexture( windowName.."TacticIcon"..index, texture, x, y )
        LabelSetText( windowName.."TacticText"..index, tacticText )
        
        local alpha = 1.0
        if( progress < reward.threshold )
        then
            alpha = 0.4
        end
        WindowSetAlpha( windowName.."TacticIcon"..index, alpha )
        WindowSetFontAlpha( windowName.."TacticText"..index, alpha )
        
        _, height = WindowGetDimensions( windowName.."TacticIcon"..index )
        totalHeight = totalHeight + height + TOOLTIP_PAD
        
        maxThreshold = math.max( maxThreshold, reward.threshold )
    end
    
    local progressText = GetFormatStringFromTable( "Default", StringTables.Default.TOOLTIP_TOME_TACTIC_COUNTER_PROGRESS, { lineName, progress, maxThreshold } )
    LabelSetText( windowName.."Progress", progressText )
    _, height = WindowGetDimensions( windowName.."Progress" )
    totalHeight = totalHeight + height + TOOLTIP_PAD

    local texture, x, y = GetIconData( GameDefs.Icons.ICON_TACTIC_REWARD )
    DynamicImageSetTexture( windowName.."FragmentIcon", texture, x, y )
    
    
    local width, _ = WindowGetDimensions( windowName )
    WindowSetDimensions( windowName, width, totalHeight + TOOLTIP_PAD * 2 )

    Tooltips.CreateCustomTooltip( SystemData.ActiveWindow.name, windowName )
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT )

end

function TomeWindow.OnMouseOverTomeReward( rewardWindowName, rewardData, isComplete )
    
    --DEBUG(L"TomeWindow.OnMouseOverTomeReward(): type="..rewardData.rewardType..L" id="..rewardData.rewardId )
    
    if( rewardData.rewardId == 0 ) then     
       return
    end
    
    local anchor = Tooltips.ANCHOR_WINDOW_RIGHT

    --Set up the icon for the reward
    if( GameData.Tome.REWARD_ITEM == rewardData.rewardType or
        GameData.Tome.REWARD_ITEM_NO_AUTOCREATE == rewardData.rewardType )
    then
        
        -- Create an Item Tooltip
        local itemData = TomeGetItemRewardData( rewardData.rewardId )
        if( itemData.name ~= nil )
        then
            local actionText = nil
            if( GameData.Tome.REWARD_ITEM_NO_AUTOCREATE == rewardData.rewardType )
            then
                actionText = GetString( StringTables.Default.TOOLTIP_TOME_ITEM )
            end
            Tooltips.CreateItemTooltip( itemData, rewardWindowName, anchor, false, actionText )
        else
            Tooltips.CreateTextOnlyTooltip( rewardWindowName, L"???" )
            Tooltips.Finalize()
            Tooltips.AnchorTooltip( anchor )
        end

    elseif( GameData.Tome.REWARD_ABILITY == rewardData.rewardType ) then
        
        -- Create an Ability Tooltip
        local tacticData = TomeGetTacticRewardData( rewardData.rewardId )
        if( tacticData.name ~= nil )
        then
            Tooltips.CreateAbilityTooltip( tacticData, rewardWindowName, anchor )
        else
            Tooltips.CreateTextOnlyTooltip( rewardWindowName, L"???" )
            Tooltips.Finalize()
            Tooltips.AnchorTooltip( anchor )
        end
        
    elseif( GameData.Tome.REWARD_ABILITY_COUNTER == rewardData.rewardType ) then
        if( isComplete )
        then
            BuildTacticCounterTooltip( TomeGetTacticCounter( rewardData.rewardId ) )
        else
            local toolTipText = L"???"
            Tooltips.CreateTextOnlyTooltip( rewardWindowName, toolTipText )
            Tooltips.Finalize()
            Tooltips.AnchorTooltip( anchor )
        end
        
    elseif( GameData.Tome.REWARD_XP == rewardData.rewardType ) then
           
        local text = GetStringFormat( StringTables.Default.LABEL_X_XP, {rewardData.rewardId }  )
        Tooltips.CreateTextOnlyTooltip( rewardWindowName, text )
        Tooltips.AnchorTooltip( anchor )
        
    elseif( GameData.Tome.REWARD_TITLE == rewardData.rewardType ) then
        
        local titleData = TomeGetPlayerTitleData( rewardData.rewardId )
        local name = L"???"
        if( titleData.name ~= nil ) then
            name = titleData.name
        end
        local text = GetStringFormat( StringTables.Default.LABEL_TITLE_X, { name }  )
        local actionText = GetString( StringTables.Default.TEXT_CLICK_TITLE_LINK )
        Tooltips.CreateTextOnlyTooltip( rewardWindowName, text )
        Tooltips.SetTooltipActionText( actionText )
        Tooltips.Finalize()
        
        Tooltips.AnchorTooltip( anchor )

    end    

end

function TomeWindow.OnClickTomeReward( rewardData )
    
    --DEBUG(L"TomeWindow.OnClickTomeReward(): type="..rewardData.rewardType..L" id="..rewardData.rewardId )
    
    -- No valid reward data or just xp reward
    if( rewardData == nil or
        rewardData.rewardType == GameData.Tome.REWARD_XP )
    then
        return
    end
    
    if( not WindowGetShowing( "TomeWindow" ) )
    then
        WindowUtils.ToggleShowing( "TomeWindow" )
    end
    
    -- For a tile reward, flip to the titles page.
    if( rewardData.rewardType == GameData.Tome.REWARD_TITLE ) then
        local params = {}
        TomeWindow.SetState( TomeWindow.PAGE_REWARDS_INFO, params)
        return
    end
    
    -- For an ability reward, flip to the abilities page.
    if( rewardData.rewardType == GameData.Tome.REWARD_ITEM or
        rewardData.rewardType == GameData.Tome.REWARD_ITEM_NO_AUTOCREATE )
    then
        local params = {}
        TomeWindow.SetState( TomeWindow.PAGE_REWARDS_INFO, params)
        return
    end
    
    -- For an item reward, flip to the items page.
    if( rewardData.rewardType == GameData.Tome.REWARD_ABILITY or rewardData.rewardType == GameData.Tome.REWARD_ABILITY_COUNTER )
    then
        local params = {}
        TomeWindow.SetState( TomeWindow.PAGE_REWARDS_INFO, params)
        return
    end
    
    -- For a quest reward, flip to the quests page.
    if( rewardData.rewardType == GameData.Tome.REWARD_QUEST ) then
    
        if( DataUtils.DoesPlayerHaveQuest( rewardData.id ) )then
            local params = { rewardData.id }
            TomeWindow.SetState( TomeWindow.PAGE_QUEST_INFO, params)
        end
        return
    end

end


function TomeWindow.SetCard( cardWindowName, cardData )
    
    if( cardData == nil ) then
        WindowSetShowing( cardWindowName, false )
        return
    end
    
    if( cardData.cardId == 0 ) then
        WindowSetShowing( cardWindowName, false )
        return
    end
    
    WindowSetId( cardWindowName, cardData.cardId )
    WindowSetShowing( cardWindowName, true )

    local texture, x, y = GetIconData( cardData.iconNum )        
    DynamicImageSetTexture( cardWindowName.."IconBase", texture, x, y )                     

end

function TomeWindow.OnClickTomeCard( cardData )
    
    -- No valid card data
    if( cardData == nil ) then
        return
    end
    
    if( not WindowGetShowing( "TomeWindow" ) )
    then
        WindowUtils.ToggleShowing( "TomeWindow" )
    end
    
    -- Simply flip to card reward page
    local params = {}
    TomeWindow.SetState( TomeWindow.PAGE_CARD_REWARDS_SECTION, params)
        
end

function TomeWindow.OnMouseOverTomeCard( cardWindowName, cardData, actionTextId, anchor )
    
    -- No valid card data
    if( cardData == nil ) then
        return
    end
    
    -- Build tool tip
    local cardName = GetFormatStringFromTable( "Default", StringTables.Default.TEXT_CARD_NAME, { cardData.valueName, cardData.suitName } )
    local cardColor = DataUtils.GetItemRarityColor( cardData )
    
    Tooltips.CreateTextOnlyTooltip( cardWindowName, nil )
    Tooltips.SetTooltipText( 1, 1, cardName )
    Tooltips.SetTooltipColor( 1, 1, cardColor.r, cardColor.g, cardColor.b )
    
    local unlockText = nil
    local actionText = nil
    if( cardData.unlockInfo.section ~= 0 and cardData.unlockInfo.entry ~= 0 )
    then
        local params = { DataUtils.GetTomeSectionName( cardData.unlockInfo.section ), cardData.unlockInfo.name }
        unlockText = GetStringFormat( StringTables.Default.TEXT_TOME_ENTRY_SOURCE, params )
    else
        unlockText = L""
    end
    
    Tooltips.SetTooltipText( 2, 1, unlockText )
    Tooltips.SetTooltipColorDef( 2, 1, Tooltips.COLOR_HEADING )
    
    if( actionTextId )
    then
        Tooltips.SetTooltipActionText( GetString( actionTextId ) )
    end
    Tooltips.Finalize()
    
    Tooltips.AnchorTooltip( anchor )

end

function TomeWindow.OnBraggingRightsUpdated()
    TomeWindow.braggingRights, TomeWindow.braggingRightsCards = GetBraggingRights()
end

function TomeWindow.OpenBraggingRightsContextMenu( entryId )

    if( not entryId )
    then
        return
    end

    EA_Window_ContextMenu.CreateContextMenu( "TomeWindow" )
    
    local entryName = L""
    for index, entryData in ipairs( TomeWindow.braggingRights )
    do
        entryName = index..L": "
    
        if( entryData.name )
        then
            entryName = entryName..entryData.name
        end
        
        local function OnPickBraggingRight()
            if( entryId )
            then
                SetBraggingRight( index, entryId )
            end
        end
        
        EA_Window_ContextMenu.AddMenuItem( entryName, OnPickBraggingRight, false, true )
    end
    
    EA_Window_ContextMenu.Finalize()
end