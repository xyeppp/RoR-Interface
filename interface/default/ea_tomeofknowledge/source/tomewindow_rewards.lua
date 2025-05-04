----------------------------------------------------------------
-- TomeWindow - TomeRewards Implementation
--
--  This file contains all of the initialization and callack
--  functions for the Rewards section of the Tome of Knowledge.
-- 
----------------------------------------------------------------


-- Constants
local ENTRY_WINDOW = "TomeRewardsPageEntry"

local STATE_TITLES  = 1
local STATE_TACTICS = 2
local STATE_ITEMS   = 3
local STATE_CARDS   = 4
local STATES = {}

-- Variables
TomeWindow.Rewards = {}
TomeWindow.Rewards.currentState = 0

TomeWindow.Rewards.titlesTypesWindowCount = 0
TomeWindow.Rewards.currentTitleType = 0

TomeWindow.Rewards.entryWindowCount = 0

TomeWindow.Rewards.currentTacticData = {}

----------------------------------------------------------------
-- TomeRewards Functions
----------------------------------------------------------------

function TomeWindow.RewardsPageTitleStatUpdated()
    if( TomeWindow.Rewards.currentState ~= STATE_TITLES )
    then
        return
    end
    LabelSetText( "TomeRewardsInfoSelectedTypeStat",
        GetFormatStringFromTable( "Default", StringTables.Default.LABEL_NUM_REWARDS_UNLOCKED, {GameData.Tome.Statistics.totalTitleRewards} ) )
end

function TomeWindow.RewardsPageItemStatUpdated()
    if( TomeWindow.Rewards.currentState ~= STATE_ITEMS )
    then
        return
    end
    LabelSetText( "TomeRewardsInfoSelectedTypeStat",
        GetFormatStringFromTable( "Default", StringTables.Default.LABEL_NUM_REWARDS_UNLOCKED, {GameData.Tome.Statistics.totalItemRewards} ) )
end

function TomeWindow.RewardsPageTacticStatUpdated()
    if( TomeWindow.Rewards.currentState ~= STATE_TACTICS )
    then
        return
    end
    LabelSetText( "TomeRewardsInfoSelectedTypeStat",
        GetFormatStringFromTable( "Default", StringTables.Default.LABEL_NUM_REWARDS_UNLOCKED, {GameData.Tome.Statistics.totalTacticRewards} ) )
end

function TomeWindow.RewardsPageCardStatUpdated()
    if( TomeWindow.Rewards.currentState ~= STATE_CARDS )
    then
        return
    end
    LabelSetText( "TomeRewardsInfoSelectedTypeStat",
        GetFormatStringFromTable( "Default", StringTables.Default.LABEL_NUM_REWARDS_UNLOCKED, {GameData.Tome.Statistics.totalCards} ) )
end

function TomeWindow.InitializeRewards()

    -- TomeRewards Info Info
    TomeWindow.Pages[ TomeWindow.PAGE_REWARDS_INFO ]
        = TomeWindow.NewPageData( TomeWindow.Sections.SECTION_REWARDS, 
                    "TomeRewardsInfo", 
                    TomeWindow.OnViewRewardsPage,
                    TomeWindow.OnTomeRewardsUpdateNavButtons,
                    TomeWindow.OnTomeRewardsPreviousPage,
                    TomeWindow.OnTomeRewardsNextPage , 
                    TomeWindow.OnTomeRewardsMouseOverPreviousPage,
                    TomeWindow.OnTomeRewardsMouseOverNextPage )

    TomeWindow.SetPageHeaderText( TomeWindow.PAGE_REWARDS_INFO, 
                                  GetString( StringTables.Default.LABEL_REWARDS ), 
                                  L"" ) 
    -- Stat Event Handlers
    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.TOME_STAT_TOTAL_TITLE_REWARDS_UPDATED, "TomeWindow.RewardsPageTitleStatUpdated" )
    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.TOME_STAT_TOTAL_ITEM_REWARDS_UPDATED, "TomeWindow.RewardsPageItemStatUpdated" )
    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.TOME_STAT_TOTAL_TACTIC_REWARDS_UPDATED, "TomeWindow.RewardsPageTacticStatUpdated" )
    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.TOME_STAT_TOTAL_CARDS_UPDATED, "TomeWindow.RewardsPageCardStatUpdated" )
             
    -- Event Handlers
    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.TOME_PLAYER_TITLES_TOC_UPDATED, "TomeWindow.UpdateTitleRewards")
    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.PLAYER_ACTIVE_TITLE_UPDATED, "TomeWindow.UpdateActiveTitle")
    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.TOME_TACTIC_REWARDS_LIST_UPDATED, "TomeWindow.UpdateTacticRewards")
    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.TOME_ITEM_REWARDS_LIST_UPDATED, "TomeWindow.UpdateItemRewards")
    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.TOME_CARD_LIST_UPDATED, "TomeWindow.UpdateCardRewards")
    
    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.TOME_PLAYER_TITLES_TYPE_UPDATED, "TomeWindow.OnPlayerTitlesTypeUpdated" )
    
    STATES[ STATE_TITLES ]  = wstring.upper( GetString( StringTables.Default.LABEL_TITLES ) )
    STATES[ STATE_TACTICS ] = wstring.upper( GetString( StringTables.Default.LABEL_TACTICS ) )
    STATES[ STATE_ITEMS ]   = wstring.upper( GetString( StringTables.Default.LABEL_ITEMS ) )
    STATES[ STATE_CARDS ]   = wstring.upper( GetString( StringTables.Default.LABEL_CARDS ) )
    
    for index, stateText in ipairs( STATES )
    do
        ButtonSetText( "TomeRewardsInfoRewardTypeButton"..index.."Text", stateText )
    end
    
    LabelSetText( "TomeRewardsInfoCurrentTitleName", GetString( StringTables.Default.TEXT_NO_TITLE_SELECTED ) )
    LabelSetText( "TomeRewardsInfoCurrentTitleDesc", GetString( StringTables.Default.LABEL_USE_TITLE_DESC ) )
    ButtonSetText( "TomeRewardsInfoCurrentTitleClearButton", GetString( StringTables.Default.TEXT_CLEAR_TITLE ) )
    
    TomeWindow.OnViewTitleRewards()
   
end

function TomeWindow.OnViewRewardsPage()
    PageWindowUpdatePages( "TomeRewardsInfoPageWindow" )
    PageWindowSetCurrentPage( "TomeRewardsInfoPageWindow", 1 )
end


----------------------------------------------------
-- Reward Types Functiosn

local function UpdateRewardTypeButtons( state )
    TomeWindow.Rewards.currentState = state
    for index, stateText in ipairs( STATES )
    do
        ButtonSetDisabledFlag( "TomeRewardsInfoRewardTypeButton"..index.."Text", TomeWindow.Rewards.currentState == index )
    end
end

function TomeWindow.OnViewTitleRewards()
    UpdateRewardTypeButtons( STATE_TITLES )
    TomeWindow.UpdateTitleRewards()
end

function TomeWindow.OnViewTacticRewards()
    UpdateRewardTypeButtons( STATE_TACTICS )
    TomeWindow.UpdateTacticRewards()
end

function TomeWindow.OnViewItemRewards()
    UpdateRewardTypeButtons( STATE_ITEMS )
    TomeWindow.UpdateItemRewards()
end

function TomeWindow.OnViewCardRewards()
    UpdateRewardTypeButtons( STATE_CARDS )
    TomeWindow.UpdateCardRewards()
end


function TomeWindow.SelectRewardEntry()
    local windowId = WindowGetId( SystemData.ActiveWindow.name )

    if( TomeWindow.Rewards.currentState == STATE_TITLES )
    then
        TomeSetActivePlayerTitle( windowId )
    end
end

function TomeWindow.MouseOverRewardEntry()
    local windowId = WindowGetId( SystemData.ActiveWindow.name )
    
    if( TomeWindow.Rewards.currentState == STATE_TITLES )
    then
        TomeWindow.MouseOverPlayerTitle( windowId )
    elseif( TomeWindow.Rewards.currentState == STATE_TACTICS )
    then
        TomeWindow.MouseOverTacticReward( windowId )
    elseif( TomeWindow.Rewards.currentState == STATE_ITEMS )
    then
        TomeWindow.MouseOverItemReward( windowId )
    elseif( TomeWindow.Rewards.currentState == STATE_CARDS )
    then
        TomeWindow.MouseOverCardReward( windowId )
    end
end

function TomeWindow.GotToUnlockingTomeEntry()
    local windowId = WindowGetId( SystemData.ActiveWindow.name )
    
    if( TomeWindow.Rewards.currentState == STATE_TITLES )
    then
        TomeWindow.GotToTitleUnlockingTomeEntry( windowId )
    elseif( TomeWindow.Rewards.currentState == STATE_TACTICS )
    then
        TomeWindow.GoToTacticUnlockingTomeEntry( windowId )
    elseif( TomeWindow.Rewards.currentState == STATE_ITEMS )
    then
        TomeWindow.GoToItemUnlockingTomeEntry( windowId )
    elseif( TomeWindow.Rewards.currentState == STATE_CARDS )
    then
        TomeWindow.GoToCardUnlockingTomeEntry( windowId )
    end
end



--------------------------------------------------
-- Titles Functions
local function SetTitleWindowsShowing( show )
    WindowSetShowing( "TomeRewardsInfoCurrentTitle", show )
    PageWindowRemovePageBreak( "TomeRewardsInfoPageWindow", "TomeRewardsInfoEntryAnchor" )

    if( not show )
    then
        for index = 1, TomeWindow.Rewards.titlesTypesWindowCount do
            local windowName = "PlayerTitlesTypeButton"..index
            WindowSetShowing(windowName, false )
            WindowSetId( windowName, 0 ) 
        end
    else
        PageWindowAddPageBreak( "TomeRewardsInfoPageWindow", "TomeRewardsInfoEntryAnchor" )
    end
end

function TomeWindow.UpdateActiveTitle()
    --DEBUG(L" Updating Title = "..GameData.Player.activeTitle )
    
    local titleText = L""--GetString( StringTables.Default.LABEL_CUR_TITLE )..L": "
    local titleId = GameData.Player.activeTitle
    if( titleId ~= 0 ) then
        local titleData = TomeGetPlayerTitleData( titleId )
        if( titleData ) then
            --titleText = titleText..titleData.name
            titleText = titleData.name
        end   
    else
        titleText = GetString( StringTables.Default.TEXT_NO_TITLE_SELECTED ) 
    end    
    
    -- Disable the 'clear title' button when no title is selected
    ButtonSetDisabledFlag( "TomeRewardsInfoCurrentTitleClearButton", titleId == 0 ) 
    
    LabelSetText( "TomeRewardsInfoCurrentTitleName", titleText )
    TomeWindow.TitlePageUpdateActiveTitle( titleText )
end

function TomeWindow.ClearActivePlayerTitle()
    if( GameData.Player.activeTitle ~= 0 )
    then
        TomeSetActivePlayerTitle( 0 )
    end
end

function TomeWindow.UpdateTitleRewards()

    if( TomeWindow.Rewards.currentState ~= STATE_TITLES )
    then
        return
    end

    LabelSetText( "TomeRewardsInfoSelectedTypeName", wstring.upper( GetString( StringTables.Default.LABEL_TITLES ) ) )
    LabelSetText( "TomeRewardsInfoSelectedTypeStat",
        GetFormatStringFromTable( "Default", StringTables.Default.LABEL_NUM_REWARDS_UNLOCKED, {GameData.Tome.Statistics.totalTitleRewards} ) )
    
    SetTitleWindowsShowing( true )
    
    local types = TomeGetPlayerTitlesAvailiableTypes()
    if( types == nil )
    then
        return
    end
    
    -- Sort the Types List alphabetically
    table.sort( types, DataUtils.AlphabetizeByNames )        
    
    local parentWindow = "TomeRewardsInfoPageWindowContentsChild"     
    local anchorWindow = "TomeRewardsInfoCurrentTitle"
    local xOffset = 0
    local yOffset = 5
    
    local typeCount = 0
    
    -- Loop through all of the title types
    for typeIndex, typeData in ipairs( types ) do
    
        typeCount = typeCount + 1
    
        -- Create the type window if necessary
        local typeWindowName = "PlayerTitlesTypeButton"..typeIndex
        if( TomeWindow.Rewards.titlesTypesWindowCount < typeIndex ) then
    
            CreateWindowFromTemplate( typeWindowName, "PlayerTitlesTypeButton", parentWindow )
            ButtonSetStayDownFlag( typeWindowName, true )
    
            WindowAddAnchor( typeWindowName, "bottom", anchorWindow, "top", xOffset, yOffset )       
  
    
            TomeWindow.Rewards.titlesTypesWindowCount = TomeWindow.Rewards.titlesTypesWindowCount + 1
        end
        anchorWindow = typeWindowName   
    
        WindowSetId( typeWindowName, typeData.id )
        -- Set the Text
        ButtonSetText( typeWindowName, typeData.name )    
        
        if( TomeWindow.Rewards.currentTitleType == 0 )
        then
            TomeWindow.Rewards.currentTitleType = typeData.id
        end
    
    end
    
    WindowClearAnchors( "TomeRewardsInfoEntryAnchor" )
    WindowAddAnchor( "TomeRewardsInfoEntryAnchor", "bottom", anchorWindow, "top", 0, 0 )
    
    -- Show/Hide the appropriate number of type windows.
    for index = 1, TomeWindow.Rewards.titlesTypesWindowCount do
        local show = index <= typeCount
        local windowName = "PlayerTitlesTypeButton"..index
        if( WindowGetShowing(windowName ) ~= show ) then
            WindowSetShowing(windowName, show ) 
        end
        if( show == false ) then
            WindowSetId( windowName, 0 ) 
        end
    end
    
    TomeWindow.ShowTitleRewards( TomeWindow.Rewards.currentTitleType )

end

function TomeWindow.OnPlayerTitlesTypeUpdated()
    if ( GameData.Tome.Titles.updatedType == TomeWindow.Rewards.currentTitleType )
    then
        TomeWindow.ShowTitleRewards( TomeWindow.Rewards.currentTitleType, true )
    end
end

function TomeWindow.SelectActivePlayerTitlesType()
    TomeWindow.Rewards.currentTitleType = WindowGetId( SystemData.ActiveWindow.name )
    TomeWindow.ShowTitleRewards( TomeWindow.Rewards.currentTitleType )
end

function TomeWindow.ShowTitleRewards( typeId, dontDoFade )

    if( not typeId or typeId == 0 )
    then
        return
    end

    local titleEntries = TomeGetPlayerTitlesTypeData( typeId )
    
    if( not titleEntries )
    then
        return
    end
    
    -- Set Pressed State for the type button
    for index = 1, TomeWindow.Rewards.titlesTypesWindowCount do
        local windowName = "PlayerTitlesTypeButton"..index
        local pressed = WindowGetId( windowName ) == titleEntries.id 
        ButtonSetPressedFlag( windowName, pressed ) 
    end

    -- Create the TOC entry for each Entry
    local parentWindow = "TomeRewardsInfoPageWindowContentsChild"     
    local anchorWindow = "TomeRewardsInfoEntryAnchor"
    local xOffset = 0
    local yOffset = 4
    
    local entryCount = 0       
    for index, entryData in ipairs( titleEntries.entries ) do

        entryCount = entryCount + 1    
    
        -- Create the entry window if necessary
        local entryWindowName = ENTRY_WINDOW..entryCount
        if( TomeWindow.Rewards.entryWindowCount < entryCount ) then
    
            CreateWindowFromTemplate( entryWindowName, "RewardEntryWindowDef", parentWindow )
    
            WindowAddAnchor( entryWindowName, "bottom", anchorWindow, "top", xOffset, yOffset )
    
            LabelSetText( entryWindowName.."Number", L""..entryCount..L":")
    
            TomeWindow.Rewards.entryWindowCount = TomeWindow.Rewards.entryWindowCount + 1
    
        end
        anchorWindow = entryWindowName     
    
        -- Set the Id
        WindowSetId( entryWindowName, entryData.id )         
    
        ButtonSetText( entryWindowName.."Text", entryData.name )
        
        WindowSetShowing( entryWindowName.."Icon", false )
        WindowClearAnchors( entryWindowName.."Text" )
        WindowAddAnchor( entryWindowName.."Text", "topright", entryWindowName.."Number", "topleft", 10, 0 )
        local width = WindowGetDimensions( entryWindowName )
        local _, height = ButtonGetTextDimensions( entryWindowName.."Text" )
        WindowSetDimensions( entryWindowName, width, height )
    
    end
    
    -- Show/Hide the appropriate number of entry windows.
    for index = 1, TomeWindow.Rewards.entryWindowCount do
        local show = index <= entryCount
        local windowName = ENTRY_WINDOW..index
        if( WindowGetShowing(windowName ) ~= show ) then
            WindowSetShowing(windowName, show ) 
        end
    end
    
    PageWindowUpdatePages( "TomeRewardsInfoPageWindow" )
    PageWindowSetCurrentPage( "TomeRewardsInfoPageWindow", 1 )
    TomeWindow.OnTomeRewardsUpdateNavButtons()
    
    if ( not dontDoFade )
    then
        WindowStartAlphaAnimation( "TomeRewardsInfoPageWindow", Window.AnimationType.SINGLE_NO_RESET, 0, 1, 
            TomeWindow.FADE_IN_TIME, true, 0, 0 )
    end
end

function TomeWindow.GotToTitleUnlockingTomeEntry( titleId )

    local titleData = TomeGetPlayerTitleData( titleId )
    if( titleData == nil ) then
        return
    end    
    
    if( titleData.unlockInfo.section == 0 and titleData.unlockInfo.entry == 0 ) then        
        return
    end
    
    TomeWindow.OpenTomeToEntry( titleData.unlockInfo.section, titleData.unlockInfo.entry )
end

function TomeWindow.MouseOverPlayerTitle( titleId )

    local titleData = TomeGetPlayerTitleData( titleId )
    if( titleData == nil ) then
        return
    end
    
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, nil ) 
    
    -- Set the Name
    Tooltips.SetTooltipText( 1, 1, titleData.name )
    Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING ) 
    
    -- Set the Desc
    Tooltips.SetTooltipText( 2, 1, titleData.text )
    
    -- Set the unlock and action text according to if a link is avail
    local unlockText = nil
    local actionText = nil
    if( titleData.unlockInfo.section ~= 0 and titleData.unlockInfo.entry ~= 0 ) then        
        
        local params = { DataUtils.GetTomeSectionName( titleData.unlockInfo.section ), titleData.unlockInfo.name }
        unlockText = GetStringFormat( StringTables.Default.TEXT_TOME_ENTRY_SOURCE, params )
        
        actionText = GetString( StringTables.Default.TEXT_TITLE_L_AND_R_CLICK_DESC )
        
    else
    
        unlockText = L""
        
        actionText = GetString( StringTables.Default.TEXT_TITLE_R_CLICK_DESC )
        
    end                 
    
    Tooltips.SetTooltipText( 3, 1, unlockText )
    Tooltips.SetTooltipColorDef( 3, 1, Tooltips.COLOR_HEADING )   
    
    Tooltips.SetTooltipActionText( actionText )
    
    
    Tooltips.Finalize()
    
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT )
end


--------------------------------------------------
-- Tactics Functions
function TomeWindow.UpdateTacticRewards()

    if( TomeWindow.Rewards.currentState ~= STATE_TACTICS )
    then
        return
    end

    LabelSetText( "TomeRewardsInfoSelectedTypeName", wstring.upper( GetString( StringTables.Default.LABEL_TACTICS ) ) )
    LabelSetText( "TomeRewardsInfoSelectedTypeStat",
        GetFormatStringFromTable( "Default", StringTables.Default.LABEL_NUM_REWARDS_UNLOCKED, {GameData.Tome.Statistics.totalTacticRewards} ) )
    
    SetTitleWindowsShowing( false )
    WindowClearAnchors( "TomeRewardsInfoEntryAnchor" )
    WindowAddAnchor( "TomeRewardsInfoEntryAnchor", "bottom", "TomeRewardsInfoDivider", "top", 0, 0 )

    local tacticsList = TomeGetTacticRewardsList()
    TomeWindow.Rewards.currentTacticData = tacticsList
    
    local parentWindow = "TomeRewardsInfoPageWindowContentsChild"     
    local anchorWindow = "TomeRewardsInfoEntryAnchor"
    local xOffset = 0
    local yOffset = 10
    
    local entryCount = 0       
    for index, entryData in ipairs( tacticsList ) do

        entryCount = entryCount + 1    
        
        -- Create the entry window if necessary
        local entryWindowName = ENTRY_WINDOW..entryCount
        if( TomeWindow.Rewards.entryWindowCount < entryCount ) then
        
            CreateWindowFromTemplate( entryWindowName, "RewardEntryWindowDef", parentWindow )
            
            WindowAddAnchor( entryWindowName, "bottom", anchorWindow, "top", xOffset, yOffset )        
            
            LabelSetText( entryWindowName.."Number", L""..entryCount..L":")
            
            TomeWindow.Rewards.entryWindowCount = TomeWindow.Rewards.entryWindowCount + 1
            
        end
        anchorWindow = entryWindowName     
        
        -- Set the Id
        WindowSetId( entryWindowName, index  )         
        
        ButtonSetText( entryWindowName.."Text", entryData.name )
        
        local texture, x, y = GetIconData( entryData.iconNum )
        DynamicImageSetTexture( entryWindowName.."IconIconBase", texture, x, y )
        
        WindowSetShowing( entryWindowName.."Icon", true )
        WindowClearAnchors( entryWindowName.."Text" )
        WindowAddAnchor( entryWindowName.."Text", "topright", entryWindowName.."Icon", "topleft", 5, 5 )
        local width = WindowGetDimensions( entryWindowName )
        local _, height = WindowGetDimensions( entryWindowName.."Icon" )
        WindowSetDimensions( entryWindowName, width, height )
        
    end
    
    -- Show/Hide the appropriate number of entry windows.
    for index = 1, TomeWindow.Rewards.entryWindowCount do
        local show = index <= entryCount
        local windowName = ENTRY_WINDOW..index
        if( WindowGetShowing(windowName ) ~= show ) then
            WindowSetShowing(windowName, show ) 
        end
    end

    
    PageWindowUpdatePages( "TomeRewardsInfoPageWindow" )
    PageWindowSetCurrentPage( "TomeRewardsInfoPageWindow", 1 )
    TomeWindow.OnTomeRewardsUpdateNavButtons()
    
    WindowStartAlphaAnimation( "TomeRewardsInfoPageWindow", Window.AnimationType.SINGLE_NO_RESET, 0, 1, 
        TomeWindow.FADE_IN_TIME, true, 0, 0 )
end

function TomeWindow.MouseOverTacticReward( index )

    local rewardId = TomeWindow.Rewards.currentTacticData[index].rewardId
    local rewardType = TomeWindow.Rewards.currentTacticData[index].rewardType
    
    local tacticData = nil
    if( rewardType == GameData.Tome.REWARD_ABILITY_COUNTER )
    then
        tacticData = TomeGetTacticCounterRewardData( rewardId )
    else
        tacticData = TomeGetTacticRewardData( rewardId )
    end
    
    if( tacticData == nil ) then
        return
    end
    
    local anchor = { Point = "bottomleft", RelativeTo = SystemData.ActiveWindow.name, RelativePoint = "bottomleft", XOffset = -320, YOffset = -20 }
    Tooltips.CreateAbilityTooltip( tacticData, SystemData.ActiveWindow.name, anchor )

end

function TomeWindow.GoToTacticUnlockingTomeEntry( index )

    local rewardId = TomeWindow.Rewards.currentTacticData[index].rewardId
    local rewardType = TomeWindow.Rewards.currentTacticData[index].rewardType
    
    if( rewardType == GameData.Tome.REWARD_ABILITY_COUNTER )
    then
        return
    end
    
    local tacticData = TomeGetTacticRewardData( rewardId )
    if( tacticData == nil ) then
        return
    end    
    
    if( tacticData.unlockInfo.section == 0 and tacticData.unlockInfo.entry == 0 ) then        
        return
    end
    
    TomeWindow.OpenTomeToEntry( tacticData.unlockInfo.section, tacticData.unlockInfo.entry )
end



--------------------------------------------------
-- Item Functions
function TomeWindow.UpdateItemRewards()

    if( TomeWindow.Rewards.currentState ~= STATE_ITEMS )
    then
        return
    end
    
    LabelSetText( "TomeRewardsInfoSelectedTypeName", wstring.upper( GetString( StringTables.Default.LABEL_ITEMS ) ) )
    LabelSetText( "TomeRewardsInfoSelectedTypeStat",
        GetFormatStringFromTable( "Default", StringTables.Default.LABEL_NUM_REWARDS_UNLOCKED, {GameData.Tome.Statistics.totalItemRewards} ) )
    
    SetTitleWindowsShowing( false )
    WindowClearAnchors( "TomeRewardsInfoEntryAnchor" )
    WindowAddAnchor( "TomeRewardsInfoEntryAnchor", "bottom", "TomeRewardsInfoDivider", "top", 0, 0 )

    local itemList = TomeGetItemRewardsList()
    
    local parentWindow = "TomeRewardsInfoPageWindowContentsChild"     
    local anchorWindow = "TomeRewardsInfoEntryAnchor"
    local xOffset = 0
    local yOffset = 10
    
    local entryCount = 0       
    for index, entryData in ipairs( itemList ) do

        entryCount = entryCount + 1    
        
        -- Create the entry window if necessary
        local entryWindowName = ENTRY_WINDOW..entryCount
        if( TomeWindow.Rewards.entryWindowCount < entryCount ) then
        
            CreateWindowFromTemplate( entryWindowName, "RewardEntryWindowDef", parentWindow )
            
            WindowAddAnchor( entryWindowName, "bottom", anchorWindow, "top", xOffset, yOffset )        
            
            LabelSetText( entryWindowName.."Number", L""..entryCount..L":")
            
            TomeWindow.Rewards.entryWindowCount = TomeWindow.Rewards.entryWindowCount + 1
            
        end
        anchorWindow = entryWindowName     
        
        -- Set the Id
        WindowSetId( entryWindowName, entryData.rewardId )         
        
        if( entryData.itemId ~= 0 )
        then
            ButtonSetText( entryWindowName.."Text", entryData.name )
            
            local texture, x, y = GetIconData( entryData.iconNum )
            DynamicImageSetTexture( entryWindowName.."IconIconBase", texture, x, y )
        else
            ButtonSetText( entryWindowName.."Text", L"" )
            DynamicImageSetTexture( entryWindowName.."IconIconBase", L"", 0, 0 )
        end
        
        WindowSetShowing( entryWindowName.."Icon", true )
        WindowClearAnchors( entryWindowName.."Text" )
        WindowAddAnchor( entryWindowName.."Text", "topright", entryWindowName.."Icon", "topleft", 5, 5 )
        local width = WindowGetDimensions( entryWindowName )
        local _, height = WindowGetDimensions( entryWindowName.."Icon" )
        WindowSetDimensions( entryWindowName, width, height )
        
    end
    
    -- Show/Hide the appropriate number of entry windows.
    for index = 1, TomeWindow.Rewards.entryWindowCount do
        local show = index <= entryCount
        local windowName = ENTRY_WINDOW..index
        if( WindowGetShowing(windowName ) ~= show ) then
            WindowSetShowing(windowName, show ) 
        end
    end

    
    PageWindowUpdatePages( "TomeRewardsInfoPageWindow" )
    PageWindowSetCurrentPage( "TomeRewardsInfoPageWindow", 1 )
    TomeWindow.OnTomeRewardsUpdateNavButtons()
    
    WindowStartAlphaAnimation( "TomeRewardsInfoPageWindow", Window.AnimationType.SINGLE_NO_RESET, 0, 1, 
        TomeWindow.FADE_IN_TIME, true, 0, 0 )
end

function TomeWindow.GoToItemUnlockingTomeEntry( itemId )
    
    local itemData = TomeGetItemRewardData( itemId )
    if( itemData == nil ) then
        return
    end    
    
    if( itemData.unlockInfo.section == 0 and itemData.unlockInfo.entry == 0 ) then        
        return
    end
    
    TomeWindow.OpenTomeToEntry( itemData.unlockInfo.section, itemData.unlockInfo.entry )
end

function TomeWindow.MouseOverItemReward( itemId )

    local itemData = TomeGetItemRewardData( itemId )
    if( itemData.name == nil ) then
        return
    end
    
    -- Set the unlock and action text according to if a link is avail
    local unlockText = nil
    local actionText = nil
    if( itemData.unlockInfo.section ~= 0 and itemData.unlockInfo.entry ~= 0 )
    then
        local params = { DataUtils.GetTomeSectionName( itemData.unlockInfo.section ), itemData.unlockInfo.name }
        unlockText = GetStringFormat( StringTables.Default.TEXT_TOME_ENTRY_SOURCE, params )
    else
        unlockText = L""
    end
    
    actionText = unlockText..L"<BR>"..GetString( StringTables.Default.TEXT_CLICK_CARD_DESC )
    
    Tooltips.CreateItemTooltip( itemData, SystemData.ActiveWindow.name, Tooltips.ANCHOR_WINDOW_LEFT, false, actionText )
end



--------------------------------------------------
-- Card Functions
function TomeWindow.UpdateCardRewards()

    if( TomeWindow.Rewards.currentState ~= STATE_CARDS )
    then
        return
    end

    LabelSetText( "TomeRewardsInfoSelectedTypeName", wstring.upper( GetString( StringTables.Default.LABEL_CARDS ) ) )
    LabelSetText( "TomeRewardsInfoSelectedTypeStat",
        GetFormatStringFromTable( "Default", StringTables.Default.LABEL_NUM_REWARDS_UNLOCKED, {GameData.Tome.Statistics.totalCards} ) )
    
    SetTitleWindowsShowing( false )
    WindowClearAnchors( "TomeRewardsInfoEntryAnchor" )
    WindowAddAnchor( "TomeRewardsInfoEntryAnchor", "bottom", "TomeRewardsInfoDivider", "top", 0, 0 )

    local cardList = TomeGetCardList()
    
    local parentWindow = "TomeRewardsInfoPageWindowContentsChild"     
    local anchorWindow = "TomeRewardsInfoEntryAnchor"
    local xOffset = 0
    local yOffset = 10
    
    local entryCount = 0       
    for index, entryData in ipairs( cardList ) do

        entryCount = entryCount + 1    
        
        -- Create the entry window if necessary
        local entryWindowName = ENTRY_WINDOW..entryCount
        if( TomeWindow.Rewards.entryWindowCount < entryCount ) then
            
            CreateWindowFromTemplate( entryWindowName, "RewardEntryWindowDef", parentWindow )
            
            WindowAddAnchor( entryWindowName, "bottom", anchorWindow, "top", xOffset, yOffset )        
            
            LabelSetText( entryWindowName.."Number", L""..entryCount..L":")
            
            TomeWindow.Rewards.entryWindowCount = TomeWindow.Rewards.entryWindowCount + 1
            
        end
        anchorWindow = entryWindowName     
        
        -- Set the Id
        WindowSetId( entryWindowName, entryData.cardId  )         
        
        local cardName = GetFormatStringFromTable( "Default", StringTables.Default.TEXT_CARD_NAME, { entryData.valueName, entryData.suitName } )
        ButtonSetText( entryWindowName.."Text", cardName )
        
        local texture, x, y = GetIconData( entryData.iconNum )
        DynamicImageSetTexture( entryWindowName.."IconIconBase", texture, x, y )
        
        WindowSetShowing( entryWindowName.."Icon", true )
        WindowClearAnchors( entryWindowName.."Text" )
        WindowAddAnchor( entryWindowName.."Text", "topright", entryWindowName.."Icon", "topleft", 5, 5 )
        local width = WindowGetDimensions( entryWindowName )
        local _, height = WindowGetDimensions( entryWindowName.."Icon" )
        WindowSetDimensions( entryWindowName, width, height )
    
    end
    
    -- Show/Hide the appropriate number of entry windows.
    for index = 1, TomeWindow.Rewards.entryWindowCount do
        local show = index <= entryCount
        local windowName = ENTRY_WINDOW..index
        if( WindowGetShowing(windowName ) ~= show ) then
            WindowSetShowing(windowName, show ) 
        end
    end

    
    PageWindowUpdatePages( "TomeRewardsInfoPageWindow" )
    PageWindowSetCurrentPage( "TomeRewardsInfoPageWindow", 1 )
    TomeWindow.OnTomeRewardsUpdateNavButtons()
    
    WindowStartAlphaAnimation( "TomeRewardsInfoPageWindow", Window.AnimationType.SINGLE_NO_RESET, 0, 1, 
        TomeWindow.FADE_IN_TIME, true, 0, 0 )
end

function TomeWindow.GoToCardUnlockingTomeEntry( cardId )

    local cardData = TomeGetCardData( cardId )
    if( cardData == nil ) then
        return
    end    

    if( cardData.unlockInfo.section == 0 and cardData.unlockInfo.entry == 0 ) then        
        return
    end
    
    TomeWindow.OpenTomeToEntry( cardData.unlockInfo.section, cardData.unlockInfo.entry )
end

function TomeWindow.MouseOverCardReward( cardId )

    local cardData = TomeGetCardData( cardId )
    if( cardData == nil ) then
        return
    end
    
    TomeWindow.OnMouseOverTomeCard( SystemData.ActiveWindow.name, cardData, StringTables.Default.TEXT_CLICK_CARD_DESC, Tooltips.ANCHOR_WINDOW_LEFT )

end


---------------------------------------------------------
-- > Rewards Nav Buttons

function TomeWindow.OnTomeRewardsUpdateNavButtons()
    --DEBUG(L"TomeWindow.OnTomeRewardsUpdateNavButtons() " )
    
    if ( TomeWindow.GetCurrentState() ~= TomeWindow.PAGE_REWARDS_INFO ) then
        return
    end
    local curPage   = PageWindowGetCurrentPage("TomeRewardsInfoPageWindow")
    local numPages  = PageWindowGetNumPages("TomeRewardsInfoPageWindow")
    WindowSetShowing( "TomeWindowPreviousPageButton", curPage > 1 )
    WindowSetShowing( "TomeWindowNextPageButton", curPage + 2 <= numPages )
end

function TomeWindow.OnTomeRewardsPreviousPage()
    TomeWindow.FlipPageWindowBackward( "TomeRewardsInfoPageWindow")
end

function TomeWindow.OnTomeRewardsMouseOverPreviousPage()  
    local lines = {}    
    local curPage   = PageWindowGetCurrentPage("TomeRewardsInfoPageWindow")
    local numPages  = PageWindowGetNumPages("TomeRewardsInfoPageWindow")
    if( curPage > 1 ) then
        -- Previous Pages
        lines[1] = GetString( StringTables.Default.LABEL_REWARDS )
        lines[2] = GetString( StringTables.Default.TEXT_CONTINUED )
    end 
    TomeWindow.CreateBackButtonTooltip( lines )
end

function TomeWindow.OnTomeRewardsNextPage()
    TomeWindow.FlipPageWindowForward( "TomeRewardsInfoPageWindow")
end

function TomeWindow.OnTomeRewardsMouseOverNextPage()  
    local lines = {}    
    local curPage   = PageWindowGetCurrentPage("TomeRewardsInfoPageWindow")
    local numPages  = PageWindowGetNumPages("TomeRewardsInfoPageWindow")
    if( curPage + 2 <= numPages ) then
        -- Next Pages
        lines[1] = GetString( StringTables.Default.LABEL_REWARDS )
        lines[2] = GetString( StringTables.Default.TEXT_CONTINUED )
    end 
    TomeWindow.CreateNextButtonTooltip( lines )
end
