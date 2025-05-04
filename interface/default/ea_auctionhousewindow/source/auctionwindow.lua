----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

AuctionHouseWindow = {}     -- TEMP dummy due to old saved variables
AuctionWindow = {}
AuctionWindow.currentTabNumber = 0
AuctionWindow.searchResultsData = {}

local BUY_TAB = AuctionWindowListDataManager.BUYING_TAB
local SELL_TAB = AuctionWindowListDataManager.SELLING_TAB

local REQUIRED_GUILD_RANK_FOR_GUILD_ONLY_SEARCHES = 8

local WINDOW_NAME = "AuctionWindow"
local SEARCH_CONTROLS_NAME = WINDOW_NAME.."SearchControls"
local SELL_CONTROLS_NAME = WINDOW_NAME.."SellControls"
local TAB_NAME = WINDOW_NAME.."Tabs"
local RESULTS_LIST = WINDOW_NAME.."List"

function AuctionWindow.Initialize()
    ButtonSetText( TAB_NAME..BUY_TAB, GetStringFromTable( "AuctionHouseStrings",  StringTables.AuctionHouse.BUTTON_TAB_NAME_BUY ) )
    ButtonSetText( TAB_NAME..SELL_TAB, GetStringFromTable( "AuctionHouseStrings",  StringTables.AuctionHouse.BUTTON_TAB_NAME_SELL ) )
    ButtonSetText( WINDOW_NAME.."ItemListHeader", GetStringFromTable( "AuctionHouseStrings",  StringTables.AuctionHouse.BUTTON_ITEM_NAME_HEADER ) )
    ButtonSetText( WINDOW_NAME.."LvLListHeader", GetStringFromTable( "AuctionHouseStrings",  StringTables.AuctionHouse.BUTTON_ITEM_LEVEL_ABBREVIATION_HEADER ) )
    ButtonSetText( WINDOW_NAME.."PriceListHeader", GetStringFromTable( "AuctionHouseStrings",  StringTables.AuctionHouse.BUTTON_PRICE_HEADER ) )
    ButtonSetText( WINDOW_NAME.."BuyButton", GetStringFromTable( "AuctionHouseStrings",  StringTables.AuctionHouse.BUTTON_BUY ) )
    ButtonSetText( WINDOW_NAME.."CancelButton", GetStringFromTable( "AuctionHouseStrings", StringTables.AuctionHouse.SEARCH_RESULTS_CANCEL_BUTTON ) )
    ButtonSetText( WINDOW_NAME.."RefreshButton", GetStringFromTable( "AuctionHouseStrings", StringTables.AuctionHouse.SEARCH_RESULTS_REFRESH_BUTTON ) )
    LabelSetText( WINDOW_NAME.."TitleBarText", GetStringFromTable( "AuctionHouseStrings", StringTables.AuctionHouse.MAIN_TITLE ) )
    
    WindowRegisterEventHandler( WINDOW_NAME, SystemData.Events.AUCTION_INIT_RECEIVED, "AuctionWindow.Show" )
    WindowRegisterEventHandler( WINDOW_NAME, SystemData.Events.AUCTION_SEARCH_RESULT_RECEIVED, "AuctionWindow.OnSearchResultsReceived" )
    WindowRegisterEventHandler( WINDOW_NAME, SystemData.Events.AUCTION_BID_RESULT_RECEIVED, "AuctionWindow.ReceivedBidResult" )
    WindowRegisterEventHandler( WINDOW_NAME, SystemData.Events.INTERACT_DONE, "AuctionWindow.Hide" )
    
    AuctionWindowSearchControls.Initialize()
    AuctionWindowSellControls.Initialize()
    AuctionWindowListDataManager.Initialize()
    
    AuctionWindow.Clear()
    AuctionWindow.SwitchTabs( BUY_TAB )
end

local function sortButtonShowArrows( buttonName, show, shouldSortIncreasing )
    WindowSetShowing(buttonName.."DownArrow", show and shouldSortIncreasing)
    WindowSetShowing(buttonName.."UpArrow", show and not shouldSortIncreasing)
    ButtonSetPressedFlag( buttonName, show )
end

function AuctionWindow.Clear()
    AuctionWindowSearchControls.Clear()
    AuctionWindowSellControls.Clear()
    sortButtonShowArrows( WINDOW_NAME.."ItemListHeader", false )
    sortButtonShowArrows( WINDOW_NAME.."LvLListHeader", false )
    sortButtonShowArrows( WINDOW_NAME.."PriceListHeader", false )
    ListBoxSetDisplayOrder( RESULTS_LIST, {} )
    
    AuctionWindow.UpdateBuyButton( 0 )
    AuctionWindow.DisplayError( L"" )
    
    AuctionWindowListDataManager.Clear()
end

function AuctionWindow.Show()
    AuctionWindow.Clear()
	WindowSetShowing("AuctionWindow", true )
    
    if ( AuctionWindow.currentTabNumber == SELL_TAB )
    then
        -- The Sell tab should always show the current items we are selling, thus we should refresh as if we had just switched tabs to the Sell tab
        AuctionWindowListDataManager.SendPlayersAuctionSearch()
    end
end

function AuctionWindow.Hide()
	WindowSetShowing("AuctionWindow", false )
    
    -- We specifically need to clear the sell controls to release any lock we may have on the Backpack slot
    AuctionWindowSellControls.Clear()
end

function AuctionWindow.OnShown()
    WindowUtils.OnShown()
end

function AuctionWindow.DisplayError( errorString )
    if ( errorString ~= L"" )
    then
        LabelSetText( WINDOW_NAME.."ErrorText", errorString )
        WindowSetShowing( WINDOW_NAME.."ErrorText", true )
    else
        WindowSetShowing( WINDOW_NAME.."ErrorText", false )
    end
end

-- Tab Functions
function AuctionWindow.OnLButtonUpTab()
    AuctionWindow.SwitchTabs( WindowGetId( SystemData.ActiveWindow.name ) )
end

function AuctionWindow.SwitchTabs( tabNumber )
    if( tabNumber ~= AuctionWindow.currentTabNumber )
    then
        if( AuctionWindow.currentTabNumber ~= 0 )
        then
            ButtonSetPressedFlag( TAB_NAME..AuctionWindow.currentTabNumber, false )
            
            -- Hide arrows of old search row
            local oldWindowData = AuctionWindowListDataManager.GetCurrentWindowData()
            if ( oldWindowData.sortColumnName and oldWindowData.sortColumnName ~= "") 
            then
                sortButtonShowArrows( oldWindowData.sortColumnName, false )
            end
        end
        
        AuctionWindow.currentTabNumber = tabNumber
        
        AuctionWindowListDataManager.SetCurrentTabNumber( tabNumber )
    end
    
    WindowSetShowing( SELL_CONTROLS_NAME, tabNumber == SELL_TAB )
    WindowSetShowing( SEARCH_CONTROLS_NAME, tabNumber == BUY_TAB )
    WindowSetShowing( WINDOW_NAME.."BuyButton", tabNumber == BUY_TAB )
    WindowSetShowing( WINDOW_NAME.."CancelButton", tabNumber == SELL_TAB )

    local windowData = AuctionWindowListDataManager.GetCurrentWindowData()
    AuctionWindow.UpdateBuyButton( windowData.currentlySelectedRow )
    
    -- Show arrows of new search row
    if ( windowData.sortColumnName and windowData.sortColumnName ~= "") 
    then
        sortButtonShowArrows( windowData.sortColumnName, true, windowData.shouldSortIncreasing )
    end

    if( tabNumber == SELL_TAB )
    then
        -- Get our auctions
        if( not windowData.searchResultsData or not next( windowData.searchResultsData ) )
        then
            -- We have not searched for our auctions yet... so lets get them
            AuctionWindowListDataManager.SendPlayersAuctionSearch()
	    else
	        AuctionWindow.DisplayCurrentSearchResultsData()
	    end
	else
	    AuctionWindow.DisplayCurrentSearchResultsData()
    end
    
    ButtonSetPressedFlag( TAB_NAME..AuctionWindow.currentTabNumber, true )
end

function AuctionWindow.OnSearchResultsReceived( searchResultsTable )
	local windowData = AuctionWindowListDataManager.GetCurrentWindowData()
    windowData.displayOrder = {}
    windowData.reverseDisplayOrder = {}
    local numResults = #searchResultsTable
    for i = 1, numResults
    do  
        table.insert( windowData.displayOrder, i )
        table.insert( windowData.reverseDisplayOrder, numResults - i + 1 )
        
        -- remember original ordering
        searchResultsTable[i].originalIndex = i
    end
    
    windowData.searchResultsData = searchResultsTable

    AuctionWindow.SortSearchResults()
	
	AuctionWindow.DisplayCurrentSearchResultsData()
end

-- Auction List Functions
function AuctionWindow.DisplayCurrentSearchResultsData()
	local windowData = AuctionWindowListDataManager.GetCurrentWindowData()
    
    if windowData.shouldSortIncreasing
    then
        ListBoxSetDisplayOrder( RESULTS_LIST, windowData.displayOrder )
    else
        ListBoxSetDisplayOrder( RESULTS_LIST, windowData.reverseDisplayOrder )
    end 
end


function AuctionWindow.PopulateSearchResults()
    local windowData = AuctionWindowListDataManager.GetCurrentWindowData()

    for row, data in ipairs(AuctionWindowList.PopulatorIndices)
    do
        local rowName = RESULTS_LIST.."Row"..row

        local auctionData = windowData.searchResultsData[data]
        if( nil == auctionData )
        then
            continue
        end

        local itemData = auctionData.itemData
        if( nil == itemData )
        then
            continue
        end   

        AuctionWindow.PopulateSearchResultsRow( rowName, auctionData, itemData, row )

	    -- put highlight box around the selected row, if it's visible
        local dataIndex = ListBoxGetDataIndex( RESULTS_LIST, row )
        local rowIsSelected = (windowData.currentlySelectedRow == dataIndex)

        ButtonSetPressedFlag(rowName,  rowIsSelected)
        ButtonSetStayDownFlag(rowName, rowIsSelected)

        if( rowIsSelected )
        then
            windowData.currentlySelectedRowName = rowName
        end
    end
end


function AuctionWindow.PopulateSearchResultsRow( rowName, auctionData, itemData, row )
    -- Icon
    local buttonName = rowName.."Icon"
    local texture, x, y = GetIconData(itemData.iconNum)
    DynamicImageSetTexture( buttonName.."Icon", texture, x, y)
    
    -- Stack Count on Icon            
    if( itemData.stackCount > 1 )
    then
        ButtonSetText(buttonName, L""..itemData.stackCount )
    else
        ButtonSetText(buttonName, L"" )
    end
    
    -- Name
    LabelSetText(rowName.."Name", itemData.name)
    local color = DataUtils.GetItemRarityColor(itemData)
    LabelSetTextColor( rowName.."Name", color.r, color.g, color.b )

    -- Rank
    LabelSetText (rowName.."Rank", L""..itemData.level)
    
    local meetsRankRequirement  = DataUtils.LevelIsEnoughForItem( GameData.Player.level, itemData )
    if meetsRankRequirement then
        color = DefaultColor.TOOLTIP_MEETS_REQUIREMENTS
    else
        color = DefaultColor.TOOLTIP_FAILS_REQUIREMENTS
    end
    LabelSetTextColor (rowName.."Rank", color.r, color.g, color.b)

    -- BuyOutPrice
    MoneyFrame.FormatMoney (rowName.."Price", auctionData.buyOutPrice, MoneyFrame.HIDE_EMPTY_WINDOWS_ABOVE_VALUE)

    local row_mod = math.mod(row, 2)
    color = DataUtils.GetAlternatingRowColor( row_mod )
    
    WindowSetTintColor(rowName.."Background", color.r, color.g, color.b )
    WindowSetAlpha(rowName.."Background", color.a )
end

function AuctionWindow.OnSearchResultsRowSelected()
    local rowNum = WindowGetId( SystemData.ActiveWindow.name )
    local dataIndex = ListBoxGetDataIndex( RESULTS_LIST, rowNum )
    dataIndex = dataIndex or 0
    AuctionWindow.UpdateSelectedSearchResultsRow( dataIndex )
end

function AuctionWindow.UpdateSelectedSearchResultsRow( rowNum )
	local windowData = AuctionWindowListDataManager.GetCurrentWindowData()
	
	-- unselect previous row, if it's not already cleared or a no longer existing row
	if( windowData.currentlySelectedRowName ~= ""
	    and DoesWindowExist(windowData.currentlySelectedRowName) )
	then
        ButtonSetPressedFlag( windowData.currentlySelectedRowName, false )
        ButtonSetStayDownFlag( windowData.currentlySelectedRowName, false )
	    windowData.currentlySelectedRowName = ""
	    windowData.currentlySelectedRow  = 0
        windowData.currentlySelectedRowId = {high=0, low=0}
	end
	
	-- if we clicked on a new row, then we mark it as selected
    if( rowNum == 0
        or windowData.currentlySelectedRow == rowNum )
    then
        windowData.currentlySelectedRow  = 0
        windowData.currentlySelectedRowName = ""
        windowData.currentlySelectedRowId = {high=0, low=0}
    else                
        windowData.currentlySelectedRow = rowNum
	    windowData.currentlySelectedRowName = SystemData.ActiveWindow.name
        windowData.currentlySelectedRowId = {
                                                high=windowData.searchResultsData[rowNum].auctionIDHigherNum,
                                                low=windowData.searchResultsData[rowNum].auctionIDLowerNum
                                            }
        ButtonSetPressedFlag( windowData.currentlySelectedRowName,  true)
        ButtonSetStayDownFlag( windowData.currentlySelectedRowName, true)
    end
    
    AuctionWindow.UpdateBuyButton( windowData.currentlySelectedRow )
end

function AuctionWindow.UpdateBuyButton( currentlySelectedRow )
    --Enable the buy button if they have seleceted an item
    local isRowUnselected =  not currentlySelectedRow or currentlySelectedRow == 0
    ButtonSetDisabledFlag( WINDOW_NAME.."BuyButton", isRowUnselected )
    ButtonSetDisabledFlag( WINDOW_NAME.."CancelButton", isRowUnselected )
end

function AuctionWindow.ChangeSearchResultsSorting()
	local windowData = AuctionWindowListDataManager.GetCurrentWindowData()
    local activeWindowName = SystemData.ActiveWindow.name
    
    -- Hide the arrows of the last sort button that was clicked
    if( windowData.sortColumnName and windowData.sortColumnName ~= "") 
    then
        sortButtonShowArrows( windowData.sortColumnName, false )
    end

    if( windowData.sortColumnNum == WindowGetId( activeWindowName ) )
    then
        windowData.shouldSortIncreasing = (not windowData.shouldSortIncreasing)
    else
        windowData.sortColumnName = activeWindowName
        windowData.sortColumnNum = WindowGetId( activeWindowName )
        windowData.shouldSortIncreasing = true
    end

    -- Show the correct arrow
    sortButtonShowArrows( activeWindowName, true, windowData.shouldSortIncreasing )
   
    AuctionWindow.SortSearchResults()
    AuctionWindow.DisplayCurrentSearchResultsData()    
end

-- returns true if a sort column is set and false if not
function AuctionWindow.SortSearchResults()
	local windowData = AuctionWindowListDataManager.GetCurrentWindowData()
    local comparator = windowData.columnData[windowData.sortColumnNum].sortFunc
    table.sort( windowData.searchResultsData, comparator )
    
    local currentlySelectedRow = 0
    if( windowData.currentlySelectedRow ~= 0 )
    then
        for k, v in ipairs( windowData.searchResultsData )
        do
            if( v.auctionIDHigherNum == windowData.currentlySelectedRowId.high
                and v.auctionIDLowerNum == windowData.currentlySelectedRowId.low )
            then
                currentlySelectedRow = k
                break
            end
        end
    end
     
    AuctionWindow.UpdateSelectedSearchResultsRow( currentlySelectedRow )
end

function AuctionWindow.ReceivedBidResult( resultData )
	if resultData == nil
	then
		return
	end

	local result = resultData.result
    if( result == GameData.Auction.BUYOUT_SUCCESS
        or result == GameData.Auction.CANCEL_SUCCESS )
    then
		-- successful buyout, remove from auction list
		AuctionWindow.RemoveAuctionFromSearchResults( resultData.auctionIDHigherNum, resultData.auctionIDLowerNum )
		AuctionWindow.DisplayError( L"" )
	elseif( result == GameData.Auction.BID_FAIL_MISSING_ITEM
	        or result == GameData.Auction.BID_FAIL_ITEM_SOLD
		    or result == GameData.Auction.CANCEL_FAIL_ITEM_SOLD )
    then
		AuctionWindow.RemoveAuctionFromSearchResults( resultData.auctionIDHigherNum, resultData.auctionIDLowerNum )
		AuctionWindow.DisplayError( GetStringFromTable( "AuctionHouseStrings",  StringTables.AuctionHouse.LABEL_ERROR_ITEM_MISSING ) )
	elseif( result == GameData.Auction.SERVER_UNAVAILABLE
	        or result == GameData.Auction.CANCEL_FAIL_UNKNOWN_REASON
	        or result == GameData.Auction.BID_FAIL_UNKNOWN_REASON
	        or result == GameData.Auction.UNKNOWN_REASON )
	then
		AuctionWindow.DisplayError( GetStringFromTable( "AuctionHouseStrings",  StringTables.AuctionHouse.LABEL_ERROR_RESULTS_SERVER_UNAVAILABLE) )
	elseif( result == GameData.Auction.CREATE_AUCTION_FAILED )
	then
		AuctionWindow.DisplayError( GetStringFromTable( "AuctionHouseStrings",  StringTables.AuctionHouse.LABEL_ERROR_AUCTION_CREATION_FAILED ) )
    elseif( result == GameData.Auction.CANCEL_FAIL_NOT_OWNER )
    then
        AuctionWindow.DisplayError( GetStringFromTable( "AuctionHouseStrings",  StringTables.AuctionHouse.LABEL_ERROR_AUCTION_CANCEL_FAILED_NO_OWNER ) )
    elseif( result == GameData.Auction.BID_FAIL_BAD_BUY_OUT_PRICE )
    then
        -- How could this happen?
	end
end

function AuctionWindow.RemoveAuctionFromSearchResults( auctionIDHigherNum, auctionIDLowerNum )
    local searchResultsData = AuctionWindowListDataManager.GetCurrentWindowData().searchResultsData
    for i, auctionData in ipairs(searchResultsData)
    do
		if( auctionData.auctionIDLowerNum == auctionIDLowerNum
		    and auctionData.auctionIDHigherNum == auctionIDHigherNum )
		then
			table.remove( searchResultsData, i )
			break
		end
    end
    
    AuctionWindow.OnSearchResultsReceived( searchResultsData )
end

function AuctionWindow.OnMouseOverResultsIcon()
	local windowData = AuctionWindowListDataManager.GetCurrentWindowData()
    local rowNum = WindowGetId( SystemData.MouseOverWindow.name )
    local dataIndex = ListBoxGetDataIndex( WINDOW_NAME.."List", rowNum )
    if( dataIndex == 0
        or windowData.searchResultsData[dataIndex] == nil
        or windowData.searchResultsData[dataIndex].itemData == nil )
    then
        return
    end
    
	local itemData = windowData.searchResultsData[dataIndex].itemData 
	Tooltips.CreateItemTooltip (itemData, SystemData.ActiveWindow.name, Tooltips.ANCHOR_WINDOW_TOP )

end

function AuctionWindow.OnLButtonUpBuy()
    if( ButtonGetDisabledFlag( WINDOW_NAME.."BuyButton" ) )
    then
        return
    end
    
    local windowData = AuctionWindowListDataManager.GetCurrentWindowData()
	local auctionData = windowData.searchResultsData[windowData.currentlySelectedRow]
    
    if( auctionData == nil )
    then
        return
    end
    
    if( Player.GetMoney() < auctionData.buyOutPrice )
    then
        local okayText = GetString (StringTables.Default.LABEL_OKAY)
        DialogManager.MakeOneButtonDialog( GetStringFromTable( "AuctionHouseStrings",  StringTables.AuctionHouse.LABEL_ERROR_INSUFFICIENT_FUNDS ), okayText)  
        return
    end
    
    BuyAuction( auctionData.auctionIDHigherNum, auctionData.auctionIDLowerNum, auctionData.revision, auctionData.buyOutPrice )

    AuctionWindow.UpdateSelectedSearchResultsRow( 0 )
end

function AuctionWindow.OnLButtonUpCancel()
    if( ButtonGetDisabledFlag( WINDOW_NAME.."CancelButton" ) )
    then
        return
    end
    
    -- display a confirmation dialog before cancelling
    DialogManager.MakeTwoButtonDialog( GetStringFromTable( "AuctionHouseStrings",  StringTables.AuctionHouse.SEARCH_RESULTS_CANCEL_CONFIRMATION_TEXT ), 
                                       GetString( StringTables.Default.LABEL_YES ),
                                       AuctionWindow.CancelPressConfirmed, 
                                       GetString( StringTables.Default.LABEL_NO ),
                                       nil, nil, nil, false, nil, nil )
end

-- send cancel info to server
function AuctionWindow.CancelPressConfirmed()
	local windowData = AuctionWindowListDataManager.GetCurrentWindowData()
    local auctionData = windowData.searchResultsData[windowData.currentlySelectedRow]

    if( auctionData == nil )
    then
        return
    end
    	  
    CancelAuction( auctionData.auctionIDHigherNum, auctionData.auctionIDLowerNum, auctionData.revision )
end

function AuctionWindow.OnLButtonUpRefresh()
    if( AuctionWindow.currentTabNumber == BUY_TAB )
    then
        AuctionWindowSearchControls.Search()
    else
        AuctionWindowListDataManager.SendPlayersAuctionSearch()
    end
end

function AuctionWindow.PlayerCanSearchGuildAuctions()
    return GuildWindow and GuildWindow.IsPlayerInAGuild() and GameData.Guild.m_GuildRank and
           GameData.Guild.m_GuildRank >= REQUIRED_GUILD_RANK_FOR_GUILD_ONLY_SEARCHES
end

function AuctionWindow.PlayerCanSearchAllianceAuctions()
	return GuildWindow and GuildWindow.IsPlayerInAGuild() and GameData.Guild.m_GuildRank >= REQUIRED_GUILD_RANK_FOR_GUILD_ONLY_SEARCHES and GameData.Guild.Alliance.Id ~= 0
end