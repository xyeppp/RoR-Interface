----------------------------------------------------------------
-- TomeWindow - WarJournal Implementation
--
--  This file contains all of the initialization and callack
--  functions for the WarJournal section of the Tome of Knowledge.
-- 
----------------------------------------------------------------


-- Constants

-- Variables
TomeWindow.Achievements = {} 
TomeWindow.Achievements.TOCData = nil
TomeWindow.Achievements.CurTypeData = nil
TomeWindow.Achievements.typeTOCWindowCount = 0
TomeWindow.Achievements.subTypeTOCWindowCount = 0
TomeWindow.Achievements.entryTOCWindowCount = 0

TomeWindow.Achievements.MIN_FRAME_HEIGHT = 75

local function GetAchievementTypeData( typeId )

    for index, typeData in ipairs( TomeWindow.Achievements.TOCData ) do
        if( typeData.id  == typeId ) then
            return typeData
        end
    end
    
    return nil
end

----------------------------------------------------------------
-- Achievements Functions
----------------------------------------------------------------

function TomeWindow.InitializeAchievements()

    -- Init the variables
    TomeWindow.Achievements.typeTOCWindowCount = 0
    TomeWindow.Achievements.subTypeTOCWindowCount = 0
    TomeWindow.Achievements.entryTOCWindowCount = 0

  -- > Initialize the PageData
    -- Achievements TOC
    TomeWindow.Pages[ TomeWindow.PAGE_ACHIEVEMENTS_TOC ]
        = TomeWindow.NewPageData( TomeWindow.Sections.SECTION_ACHIEVEMENTS,
                    "AchievementsTOC", 
                    TomeWindow.UpdateAchievementsTOC,
                    TomeWindow.OnAchievementsTOCUpdateNavButtons,
                    TomeWindow.OnAchievementsTOCPreviousPage,
                    TomeWindow.OnAchievementsTOCNextPage,
                    TomeWindow.OnAchievementsTOCMouseOverPreviousPage,
                    TomeWindow.OnAchievementsTOCMouseOverNextPage )
                    
   TomeWindow.Pages[ TomeWindow.PAGE_ACHIEVEMENTS_SUBTYPE_INFO ]
        = TomeWindow.NewPageData( TomeWindow.Sections.SECTION_ACHIEVEMENTS,
                    "AchievementsSubTypeInfo", 
                    TomeWindow.UpdateAchievementsSubType,
                    TomeWindow.OnAchievementsSubTypeInfoUpdateNavButtons,
                    TomeWindow.OnAchievementsSubTypeInfoPreviousPage,
                    TomeWindow.OnAchievementsSubTypeInfoNextPage,
                    TomeWindow.OnAchievementsSubTypeInfoMouseOverPreviousPage,
                    TomeWindow.OnAchievementsSubTypeInfoMouseOverNextPage )
    
    TomeWindow.SetPageHeaderText( TomeWindow.PAGE_ACHIEVEMENTS_TOC,
                                  GetString( StringTables.Default.LABEL_ACHIEVEMENTS ), 
                                  L"" )
                
    -- Achievements
    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.TOME_ACHIEVEMENTS_TOC_UPDATED, "TomeWindow.UpdateAchievementsTOC")
    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.TOME_ACHIEVEMENTS_SUBTYPE_UPDATED, "TomeWindow.OnAchievementsSubTypeUpdated")   

    -- TOC
    LabelSetText("AchievementsSectionTitle", wstring.upper( GetString( StringTables.Default.LABEL_ACHIEVEMENTS ) ) )

    -- SubType    
    LabelSetText( "AchievementsSubTypeInfoTaskLabel", GetString( StringTables.Default.LABEL_TASK ))
    LabelSetText( "AchievementsSubTypeInfoRewardsLabel", GetString( StringTables.Default.LABEL_REWARDS ))
 
    -- Inits
    TomeWindow.UpdateAchievementsTOC() 
end

-- Achievements Functions
function TomeWindow.UpdateAchievementsTOC()

    TomeWindow.Achievements.TOCData = TomeGetAchievementsTOC()    
    if( TomeWindow.Achievements.TOCData == nil ) then
        ERROR(L"AchievementsTOC is nil")
        return
    end
    
    -- Sort the Types alphabetically    
    table.sort( TomeWindow.Achievements.TOCData, DataUtils.AlphabetizeByNames )    
    for typeIndex, typeData in ipairs( TomeWindow.Achievements.TOCData ) do
        table.sort( typeData.subtypes, DataUtils.AlphabetizeByNames )   
    end
    
    local parentWindow = "AchievementsTOCPageWindowContentsChild"     
    local anchorWindow = "AchievementsTOCPageWindowContentsChildTypesTOCAnchor"
    local xOffset = 0
    local yOffset = 0
    
    local pageBreakPad = 30
    
    local subTypeCount = 0    
        
    -- Loop through all of the Achievement Types
    for typeIndex, typeData in ipairs( TomeWindow.Achievements.TOCData ) do
                
        -- Create the type window if necessary
        local typeWindowName = "AchievementsTypeTOCItem"..typeIndex
        if( TomeWindow.Achievements.typeTOCWindowCount < typeIndex ) then
            CreateWindowFromTemplate( typeWindowName, "AchievementsTypeHeading", parentWindow )
        
            WindowAddAnchor( typeWindowName, "bottom", anchorWindow, "top", xOffset, yOffset )        
            anchorWindow = typeWindowName     
            
            if( typeIndex == 1 ) then                
                LabelSetText( typeWindowName.."Unlocks",  GetString( StringTables.Default.LABEL_UNLOCKS ) )
            end               
            
            TomeWindow.Achievements.typeTOCWindowCount = TomeWindow.Achievements.typeTOCWindowCount + 1
        
        end
        
        -- Set the Id
        WindowSetId( typeWindowName, typeData.id )         
        
        -- Set the Text
        LabelSetText( typeWindowName.."Text", typeData.name ) 
        local textWidth, textHeight = WindowGetDimensions( typeWindowName.."Text" )
        local width, height = WindowGetDimensions( typeWindowName )
        WindowSetDimensions( typeWindowName, width, textHeight + pageBreakPad )
 
        xOffset = 10
        yOffset = 0
        
          
        for subTypeIndex, subTypeData in ipairs( typeData.subtypes ) do                               
                        
            subTypeCount = subTypeCount + 1
                        
            -- Create the sub type window if necessary
            local subTypeWindowName = "AchievementsSubTypeTOCItem"..subTypeCount
            if( TomeWindow.Achievements.subTypeTOCWindowCount < subTypeCount ) then
            
                CreateWindowFromTemplate( subTypeWindowName, "AchievementsSubTypeTOCItem", parentWindow )                         
                
                local adjustedOffset = yOffset
                if( subTypeIndex == 1 )
                then
                    adjustedOffset = adjustedOffset - pageBreakPad
                end
                WindowAddAnchor( subTypeWindowName, "bottom", anchorWindow, "top", xOffset, adjustedOffset )             
                anchorWindow = subTypeWindowName 
                
                TomeWindow.Achievements.subTypeTOCWindowCount = TomeWindow.Achievements.subTypeTOCWindowCount + 1
            end
            
            -- Set the name and unlock text
            local killText = L""..subTypeData.numUnlocks
            TomeWindow.SetTOCItemText( subTypeWindowName, subTypeData.id, subTypeData.name, killText )
            
            -- Disable The Highlight if the subtype is locked
            ButtonSetDisabledFlag( subTypeWindowName.."Text", subTypeData.isUnlocked == false )    
            
                        
            xOffset = 0
            yOffset = 0
            
        end    
        
        if( typeData.subtypes[1] ) then        
            xOffset = -10 
        else
            xOffset = 0
        end           
        yOffset = 15           
        
    end

    
   -- Show/Hide the appropriate number of subtype windows.
    for index = 1, TomeWindow.Achievements.subTypeTOCWindowCount do
        local show = index <= subTypeCount
        local windowName = "AchievementsSubTypeTOCItem"..index
        if( WindowGetShowing(windowName ) ~= show ) then
            WindowSetShowing(windowName, show ) 
        end
    end
    
    PageWindowUpdatePages( "AchievementsTOCPageWindow" )
    PageWindowSetCurrentPage( "AchievementsTOCPageWindow", 1 )
    TomeWindow.OnAchievementsTOCUpdateNavButtons()
    

end


function  TomeWindow.ShowAchievementsEntry( entryId )
     if( entryId ) then
        local entryData = TomeGetAchievementsEntryData( entryId ) 
        if( entryData ) then
            TomeWindow.ShowAchievementsSubType( entryData.subTypeId )
        end
    end
end


function TomeWindow.OnSelectAchievementsSubType()
    -- Check to see if the button is disabled
    if( ButtonGetDisabledFlag( SystemData.ActiveWindow.name.."Text" ) ) then
        return
    end
    
    local id = WindowGetId( SystemData.ActiveWindow.name )
    TomeWindow.ShowAchievementsSubType( id )
end

function TomeWindow.ShowAchievementsSubType( id ) 
    local params = { id }
    TomeWindow.SetState( TomeWindow.PAGE_ACHIEVEMENTS_SUBTYPE_INFO, params ) 
end
    
function TomeWindow.UpdateAchievementsSubType( subTypeId )

    --DEBUG(L"TomeWindow.UpdateAchievementsSubType( subTypeId ): "..subTypeId )
    
    -- find the selected type and save it as the CurTypeData
    TomeWindow.Achievements.CurSubTypeData = TomeGetAchievementsSubTypeData( subTypeId )
    
    if( TomeWindow.Achievements.CurSubTypeData == nil ) then
        DEBUG( L"ERROR: Could Not Find the Sub Type Data matching that Sub Type Id" )
        return
    end

    local subTypeData = TomeWindow.Achievements.CurSubTypeData

    -- Set the Name
    LabelSetText("AchievementsSubTypeInfoName", wstring.upper( subTypeData.name ) )
    
    -- Set the Image
    TomeSetAchievementsSubTypeImage( subTypeData.id )    
    
    -- Set the Desc
    LabelSetText("AchievementsSubTypeInfoText1", subTypeData.desc )    
          
    -- Entries....
    local parentWindow = "AchievementsSubTypeInfoPageWindowContentsChild"
    local anchorWindow = "AchievementsSubTypeInfoTaskAnchor"
    local yOffset = 30
    
    -- Set the Tasks, creating window as necessary
    local entryIndex = 0
    for index, entryData in ipairs( subTypeData.entries ) do                               
    
        entryIndex = entryIndex + 1
                
        -- Create the sub type window if necessary
        local entryWindowName = "AchievementsEntryItem"..entryIndex
        if( TomeWindow.Achievements.entryTOCWindowCount < entryIndex ) then
        
            CreateWindowFromTemplate( entryWindowName, "AchievementsEntryItem", parentWindow )                         
            CreateWindowFromTemplate( entryWindowName.."Desc", "AchievementsEntryItemDesc", parentWindow )
            
                
            WindowAddAnchor( entryWindowName, "bottom", anchorWindow, "top", 0, yOffset )             
            WindowAddAnchor( entryWindowName.."Desc", "bottom", entryWindowName, "top", 0, 0 )
           
            ButtonSetStayDownFlag( entryWindowName.."CompletedBtn", true )
            ButtonSetDisabledFlag( entryWindowName.."CompletedBtn", true )
           
            TomeWindow.Achievements.entryTOCWindowCount = TomeWindow.Achievements.entryTOCWindowCount + 1
        end
        
        -- Set the Id
        WindowSetId( entryWindowName, entryIndex )   
        
        -- Set the Completed Button
        ButtonSetPressedFlag( entryWindowName.."CompletedBtn", entryData.isUnlocked )
                    
        -- Set the Task
        LabelSetText( entryWindowName.."Name", entryData.name )
        local nameWidth, nameHeight = WindowGetDimensions( entryWindowName.."Name" )
        
        -- Set the Desc
        LabelSetText( entryWindowName.."Desc", entryData.desc )
        local descWidth, descHeight = WindowGetDimensions( entryWindowName.."Desc" )
        
        -- Set The Rewards        
        TomeWindow.SetTomeReward( entryWindowName.."Reward1", entryData.rewards[1] )
        TomeWindow.SetTomeReward( entryWindowName.."Reward2", entryData.rewards[2] )
        
        -- Anchor card to left most reward
        anchorCardTo = entryWindowName.."Reward1"
        if( entryData.rewards[2] and entryData.rewards[2].rewardId ~= 0 )
        then
            anchorCardTo = entryWindowName.."Reward2"
        end
        WindowClearAnchors( entryWindowName.."Card" )
        WindowAddAnchor( entryWindowName.."Card", "topleft", anchorCardTo, "topright", 0, 0 )
        
        -- Set the card if there is one
        local cardData = nil
        if( entryData.cardId and entryData.cardId ~= 0 )
        then
            cardData = TomeGetCardData( entryData.cardId )
        end
        TomeWindow.SetCard( entryWindowName.."Card", cardData )
               
        anchorWindow = entryWindowName.."Desc"
        yOffset = 10
    end
   
    -- Show/Hide the appropriate number of reward windows.
    for index = 1, TomeWindow.Achievements.entryTOCWindowCount do
        local show = index <= entryIndex       
        
        local windowName = "AchievementsEntryItem"..index
        if( WindowGetShowing( windowName ) ~= show ) then
            WindowSetShowing( windowName, show ) 
            WindowSetShowing( windowName.."Desc", show )
        end
    end
    

    PageWindowUpdatePages( "AchievementsSubTypeInfoPageWindow" )
    PageWindowSetCurrentPage( "AchievementsSubTypeInfoPageWindow", 1 )
    TomeWindow.OnAchievementsSubTypeInfoUpdateNavButtons()

 
    TomeWindow.SetPageHeaderText( TomeWindow.PAGE_ACHIEVEMENTS_SUBTYPE_INFO, 
                                GetString( StringTables.Default.LABEL_ACHIEVEMENTS ), 
                                subTypeData.name)

    
    PageWindowUpdatePages( "AchievementsTOCPageWindow" )
    TomeWindow.OnAchievementsSubTypeInfoUpdateNavButtons()
end

function TomeWindow.OnAchievementsSubTypeUpdated()
    
    -- Update the TOC data to get any new subtypes.
     TomeWindow.UpdateAchievementsTOC()
    
    -- If we're currently viewing this subtype, update the page.
    if( TomeWindow.Achievements.CurSubTypeData ) then
        if( GameData.Achievements.updatedSubType == TomeWindow.Achievements.CurSubTypeData.id ) then
            TomeWindow.UpdateAchievementsSubType( TomeWindow.Achievements.CurSubTypeData.id  )
        end   
    end
end


function TomeWindow.OnClickAchievementsEntryReward()

    local entryIndex = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
    local rewardIndex = WindowGetId(  SystemData.ActiveWindow.name )

    local rewardData = TomeWindow.Achievements.CurSubTypeData.entries[entryIndex].rewards[rewardIndex]
    TomeWindow.OnClickTomeReward( rewardData )
end

function TomeWindow.OnMouseOverAchievementsEntryReward()
    
    local entryIndex = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
    local rewardIndex = WindowGetId(  SystemData.ActiveWindow.name )

    local rewardData = TomeWindow.Achievements.CurSubTypeData.entries[entryIndex].rewards[rewardIndex]
    local isComplete = TomeWindow.Achievements.CurSubTypeData.entries[entryIndex].isUnlocked
    TomeWindow.OnMouseOverTomeReward( SystemData.ActiveWindow.name, rewardData, isComplete )

end

function TomeWindow.OnClickAchievementsEntryCard()

    local cardId = WindowGetId( SystemData.ActiveWindow.name )
    local cardData = TomeGetCardData( cardId )
    TomeWindow.OnClickTomeCard( cardData )
end

function TomeWindow.OnMouseOverAchievementsEntryCard()
    
    local cardId = WindowGetId( SystemData.ActiveWindow.name )
    local cardData = TomeGetCardData( cardId )
    TomeWindow.OnMouseOverTomeCard( SystemData.ActiveWindow.name, cardData, StringTables.Default.TEXT_CLICK_CARD_LINK, Tooltips.ANCHOR_WINDOW_RIGHT )

end

function TomeWindow.OnRightClickAchievementsTaskEntry()
    local entryIndex = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
    local entryData = TomeWindow.Achievements.CurSubTypeData.entries[entryIndex]
    
    TomeWindow.OpenBraggingRightsContextMenu( entryData.unlockEventId )
end

-- Achievements TOC Nav functions
function TomeWindow.OnAchievementsTOCUpdateNavButtons()
    if ( TomeWindow.GetCurrentState() ~= TomeWindow.PAGE_ACHIEVEMENTS_TOC ) then
        return
    end
    local curPage   = PageWindowGetCurrentPage("AchievementsTOCPageWindow")
    local numPages  = PageWindowGetNumPages("AchievementsTOCPageWindow")
    WindowSetShowing( "TomeWindowPreviousPageButton", curPage > 1 )
    WindowSetShowing( "TomeWindowNextPageButton", curPage + 2 <= numPages )
end

function TomeWindow.OnAchievementsTOCPreviousPage()
    TomeWindow.FlipPageWindowBackward( "AchievementsTOCPageWindow")
end

function TomeWindow.OnAchievementsTOCMouseOverPreviousPage()    
    local lines = {}    
    local curPage   = PageWindowGetCurrentPage("AchievementsTOCPageWindow")
    local numPages  = PageWindowGetNumPages("AchievementsTOCPageWindow")
    if( curPage > 1 ) then
        -- Previous Pages
        lines[1] = GetString( StringTables.Default.TEXT_ACHIEVEMENTS_TOC )
        lines[2] = GetString( StringTables.Default.TEXT_CONTINUED )
    end 
    TomeWindow.CreateBackButtonTooltip( lines )
end

function TomeWindow.OnAchievementsTOCNextPage()
    TomeWindow.FlipPageWindowForward( "AchievementsTOCPageWindow")
end

function TomeWindow.OnAchievementsTOCMouseOverNextPage()    
    local lines = {}    
    local curPage   = PageWindowGetCurrentPage("AchievementsTOCPageWindow")
    local numPages  = PageWindowGetNumPages("AchievementsTOCPageWindow")
    if( curPage + 2 <= numPages ) then
        -- Next Pages
        lines[1] = GetString( StringTables.Default.TEXT_ACHIEVEMENTS_TOC )
        lines[2] = GetString( StringTables.Default.TEXT_CONTINUED )
    end 
    TomeWindow.CreateNextButtonTooltip( lines )
end


-- Achievements Info Nav functions
function TomeWindow.OnAchievementsSubTypeInfoUpdateNavButtons()
    if ( TomeWindow.GetCurrentState() ~= TomeWindow.PAGE_ACHIEVEMENTS_SUBTYPE_INFO ) then
        return
    end
    local curPage   = PageWindowGetCurrentPage("AchievementsSubTypeInfoPageWindow")
    local numPages  = PageWindowGetNumPages("AchievementsSubTypeInfoPageWindow")
    WindowSetShowing( "TomeWindowPreviousPageButton", curPage > 1 )
    WindowSetShowing( "TomeWindowNextPageButton", curPage + 2 <= numPages )
end

function TomeWindow.OnAchievementsSubTypeInfoPreviousPage()
    TomeWindow.FlipPageWindowBackward( "AchievementsSubTypeInfoPageWindow")
end

function TomeWindow.OnAchievementsSubTypeInfoMouseOverPreviousPage()    
    local lines = {}    
    local curPage   = PageWindowGetCurrentPage("AchievementsSubTypeInfoPageWindow")
    local numPages  = PageWindowGetNumPages("AchievementsSubTypeInfoPageWindow")
    if( curPage > 1 ) then
        -- Previous Pages
        lines[1] = TomeWindow.Achievements.CurSubTypeData.name
        lines[2] = GetString( StringTables.Default.TEXT_CONTINUED )
    end 
    TomeWindow.CreateBackButtonTooltip( lines )
end

function TomeWindow.OnAchievementsSubTypeInfoNextPage()
    TomeWindow.FlipPageWindowForward( "AchievementsSubTypeInfoPageWindow")
end

function TomeWindow.OnAchievementsSubTypeInfoMouseOverNextPage()    
    local lines = {}    
    local curPage   = PageWindowGetCurrentPage("AchievementsSubTypeInfoPageWindow")
    local numPages  = PageWindowGetNumPages("AchievementsSubTypeInfoPageWindow")
    if( curPage + 2 <= numPages ) then
        -- Next Pages
        lines[1] = TomeWindow.Achievements.CurSubTypeData.name
        lines[2] = GetString( StringTables.Default.TEXT_CONTINUED )
    end 
    TomeWindow.CreateNextButtonTooltip( lines )
end