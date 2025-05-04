----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

----------------------------------------------------------------
-- AuctionWindowListDataManager Functions
--
-- Allows for multiple AuctionList data to exist at the same time
--
----------------------------------------------------------------

AuctionWindowListDataManager = 
{
}

AuctionWindowData = {}

AuctionWindowListDataManager.BUYING_TAB = 1
AuctionWindowListDataManager.SELLING_TAB = 2

local MIN_RANK = 1
local MAX_RANK = 40

--------------------------------------------
-- local Comparator functions for columns --

local function defaultComparator( a, b ) return a.originalIndex < b.originalIndex end
local function nameComparator( a, b ) return a.itemData.name < b.itemData.name end
local function rankComparator( a, b ) return a.itemData.level < b.itemData.level end

-- a money value of 0 should be sorted to the end.
local function moneyComparator( moneyA, moneyB ) 
	if moneyA == 0 then
		return false
	elseif moneyB == 0 then
		return true
	else
		return moneyA < moneyB
	end
end

local function pricePerCount( money, itemData ) 

    if( itemData.stackCount > 1 ) then
        return money / itemData.stackCount
    else
        return money
    end
end

local function buyOutComparator( a, b )
    return moneyComparator( pricePerCount( a.buyOutPrice, a.itemData ), pricePerCount( b.buyOutPrice, b.itemData ) )
end

-----------------------
-- Column Data Table --

AuctionWindowListDataManager.DefaultColumnData =
{
    [0] = { column = "",        sortFunc=defaultComparator,  },
    { column = "Name",          sortFunc=nameComparator,     },
    { column = "Rank",          sortFunc=rankComparator,     },
    { column = "BuyOutPrice",   sortFunc=buyOutComparator,   },
}

AuctionWindowListDataManager.MyAuctionsColumnData =
{
    [0] = { column = "",        sortFunc=defaultComparator,  },
    { column = "Name",          sortFunc=nameComparator,     },
    { column = "Rank",          sortFunc=rankComparator,     },
    { column = "BuyOutPrice",   sortFunc=buyOutComparator,   },
}

----------------------------------------------------------------
-- AuctionData Functions
----------------------------------------------------------------

function AuctionWindowData.CreateData( tabNumber )

	local newData = 
		{
		    tabNumber=tabNumber,
			sortColumnNum = 0,               -- column number to sort by
			sortColumnName = "",              -- column name currently sorting by
			shouldSortIncreasing = true,       -- DEFAULT_SORTING
		    
			searchResultsData = {},
			displayOrder = {},          -- used for switching between up and
			reverseDisplayOrder = {},   --   down sort directions
		    
			currentlySelectedRowName = "",      -- remember windowName when selecting a row
			currentlySelectedRow = 0,
		} 
		
	-- headers are hardcoded to all use the same columns,
	--		but this could be more variable in the future
	if tabNumber == AuctionWindowListDataManager.BUYING_TAB then 
		newData.columnData = AuctionWindowListDataManager.DefaultColumnData 
	else
		newData.columnData = AuctionWindowListDataManager.MyAuctionsColumnData
	end
	return newData
end


----------------------------------------------------------------
-- AuctionListDataManager Functions
----------------------------------------------------------------


function AuctionWindowListDataManager.Initialize()
	-- Initialize the hardcoded tabs
    AuctionWindowListDataManager.tabs = 
    {
		[AuctionWindowListDataManager.BUYING_TAB]=AuctionWindowData.CreateData(AuctionWindowListDataManager.BUYING_TAB),
		[AuctionWindowListDataManager.SELLING_TAB]=AuctionWindowData.CreateData(AuctionWindowListDataManager.SELLING_TAB),
    }
    
    AuctionWindowListDataManager.currentTab = AuctionWindowListDataManager.BUYING_TAB
end

function AuctionWindowListDataManager.Clear()
    for i = 1, #AuctionWindowListDataManager.tabs
	do
		AuctionWindowListDataManager.tabs[i] = AuctionWindowData.CreateData(i)
    end
end

function AuctionWindowListDataManager.SetCurrentTabNumber( tabNumber )
	if( tabNumber > 0 and tabNumber <= #AuctionWindowListDataManager.tabs )
	then
        AuctionWindowListDataManager.currentTab = tabNumber
	end
end

function AuctionWindowListDataManager.GetCurrentTabNumber()
	return AuctionWindowListDataManager.currentTab
end

function AuctionWindowListDataManager.GetWindowData( tabNumber )
    return AuctionWindowListDataManager.tabs[ tabNumber ]
end

function AuctionWindowListDataManager.GetCurrentWindowData()
    return AuctionWindowListDataManager.GetWindowData( AuctionWindowListDataManager.currentTab )
end

function AuctionWindowListDataManager.CreateEmptyQuery()

	return( {
			minItemLevel = MIN_RANK,
			maxItemLevel = MAX_RANK,  
			career = 0,
			restrictionType = GameData.Auction.RESTRICTION_NONE,
            minTradeSkillLevel = 0,
			maxTradeSkillLevel = 0,
            rarity = SystemData.ItemRarity.UTILITY,
            
			itemTypes = {},
			itemEquipSlots = {},
			itemBonuses = {},

			itemName = L"",
			sellerName = L"",
			} )
end

function AuctionWindowListDataManager.SendAuctionSearch( queryData )
    SendAuctionSearch( queryData.minItemLevel,
                       queryData.maxItemLevel,
                       queryData.career,
                       queryData.restrictionType,
                       queryData.minTradeSkillLevel,
                       queryData.maxTradeSkillLevel,
                       queryData.rarity,
                       
                       queryData.itemTypes,
                       queryData.itemEquipSlots,
                       queryData.itemBonuses,
                       
                       queryData.itemName,
                       queryData.sellerName
                     )
end

function AuctionWindowListDataManager.SendPlayersAuctionSearch()
    local queryData = AuctionWindowListDataManager.CreateEmptyQuery()
    queryData.sellerName = GameData.Player.name
    AuctionWindowListDataManager.SendAuctionSearch( queryData )
end
