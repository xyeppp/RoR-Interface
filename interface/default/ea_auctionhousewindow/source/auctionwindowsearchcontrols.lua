----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

AuctionWindowSearchControls = {}

local NO_CONTEXT_MENU_ITEM_SELECTED = 0
local CHECKBOX_CHECKED_ICON = 57
local CHECKBOX_UNCHECKED_ICON = 58

AuctionWindowSearchControls.isProcessedEventRegistered = false

AuctionWindowSearchControls.itemTypesSelected = {}
AuctionWindowSearchControls.itemSlotsSelected = {}

AuctionWindowSearchControls.selectedCareer = NO_CONTEXT_MENU_ITEM_SELECTED
AuctionWindowSearchControls.clickedCareerFunctionTable = {}

AuctionWindowSearchControls.selectedRestriction = GameData.Auction.RESTRICTION_NONE
AuctionWindowSearchControls.clickedRestrictionFunctionTable = {}

AuctionWindowSearchControls.selectedStatistic = GameData.BonusTypes.EBONUS_NONE
AuctionWindowSearchControls.clickedStatisticFunctionTable = {}


local MIN_RANK = 1
local MAX_RANK = 40

local MIN_TRADESKILL_RANK = 1
local MAX_TRADESKILL_RANK = 999         -- currently max is 200, but leaving room for expnasion

local WINDOW_NAME = "AuctionWindow"
local SEARCH_CONTROLS_NAME = WINDOW_NAME.."SearchControls"

local RARITY_DATA =
{
    { rarity = SystemData.ItemRarity.UTILITY,   stringId = StringTables.AuctionHouse.RARITY_ALL },
    { rarity = SystemData.ItemRarity.COMMON,    stringId = StringTables.AuctionHouse.RARITY_COMMON },
    { rarity = SystemData.ItemRarity.UNCOMMON,  stringId = StringTables.AuctionHouse.RARITY_UNCOMMON },
    { rarity = SystemData.ItemRarity.RARE,      stringId = StringTables.AuctionHouse.RARITY_RARE },
    { rarity = SystemData.ItemRarity.VERY_RARE, stringId = StringTables.AuctionHouse.RARITY_VERYRARE },
    { rarity = SystemData.ItemRarity.ARTIFACT,  stringId = StringTables.AuctionHouse.RARITY_MYTHIC },
}

local CATEGORY_DATA =
{
    { stringId = StringTables.AuctionHouse.CREATE_SEARCH_CATEGORY_NOT_SET,
      allItemTypesStringId = StringTables.AuctionHouse.CREATE_SEARCH_ITEM_TYPE_NOT_SET,
      allSlotsStringId = StringTables.AuctionHouse.CREATE_SEARCH_SLOT_NOT_SET,
      tradeSkills = false,
      itemTypes =
      {
        GameData.ItemTypes.AXE,
		GameData.ItemTypes.BOW,
		GameData.ItemTypes.DAGGER,
		GameData.ItemTypes.GUN,
		GameData.ItemTypes.HAMMER,
		GameData.ItemTypes.PISTOL,
		GameData.ItemTypes.SPEAR,
		GameData.ItemTypes.STAFF,
		GameData.ItemTypes.SWORD,

		GameData.ItemTypes.LIGHTARMOR,
		GameData.ItemTypes.MEDIUMARMOR,
		GameData.ItemTypes.HEAVYARMOR,
		GameData.ItemTypes.ROBE,
		GameData.ItemTypes.MEDIUMROBE,
		GameData.ItemTypes.SHIELD,
		GameData.ItemTypes.CHARM,
		-- TODO: Add Accessories here

		GameData.ItemTypes.CRAFTING,
		GameData.ItemTypes.DYE,
		GameData.ItemTypes.ENHANCEMENT,
		GameData.ItemTypes.POTION,
        GameData.ItemTypes.TROPHY,
      },
      slots =
      {
        GameData.EquipSlots.RIGHT_HAND,
		GameData.EquipSlots.LEFT_HAND,
		GameData.EquipSlots.EITHER_HAND,
		-- We want to add a fake value for BOTH_HANDS
		GameData.EquipSlots.RANGED,

		GameData.EquipSlots.BODY,
		GameData.EquipSlots.BOOTS,
		GameData.EquipSlots.GLOVES,
		GameData.EquipSlots.HELM,
		GameData.EquipSlots.SHOULDERS,
		
		GameData.EquipSlots.ACCESSORY1,
		GameData.EquipSlots.BACK,
		GameData.EquipSlots.BELT,
      },
    },
    { stringId = StringTables.AuctionHouse.CREATE_SEARCH_CATEGORY_WEAPONS,
      allItemTypesStringId = StringTables.AuctionHouse.CREATE_SEARCH_ITEM_TYPE_ALL_WEAPONS,
      allSlotsStringId = StringTables.AuctionHouse.CREATE_SEARCH_SLOT_ALL_WEAPONS,
      tradeSkills = false,
      itemTypes =
      {
        GameData.ItemTypes.AXE,
		GameData.ItemTypes.BOW,
		GameData.ItemTypes.DAGGER,
		GameData.ItemTypes.GUN,
		GameData.ItemTypes.HAMMER,
		GameData.ItemTypes.PISTOL,
		GameData.ItemTypes.SPEAR,
		GameData.ItemTypes.STAFF,
		GameData.ItemTypes.SWORD,
      },
      slots =
      {
        GameData.EquipSlots.RIGHT_HAND,
		GameData.EquipSlots.LEFT_HAND,
		GameData.EquipSlots.EITHER_HAND,
		-- We want to add a fake value for BOTH_HANDS
		GameData.EquipSlots.RANGED,
      },
    },
    { stringId = StringTables.AuctionHouse.CREATE_SEARCH_CATEGORY_ARMOR,
      allItemTypesStringId = StringTables.AuctionHouse.CREATE_SEARCH_ITEM_TYPE_ALL_ARMOR,
      allSlotsStringId = StringTables.AuctionHouse.CREATE_SEARCH_SLOT_ALL_ARMOR,
      tradeSkills = false,
      itemTypes =
      {
        GameData.ItemTypes.LIGHTARMOR,
		GameData.ItemTypes.MEDIUMARMOR,
		GameData.ItemTypes.HEAVYARMOR,
		GameData.ItemTypes.ROBE,
		GameData.ItemTypes.MEDIUMROBE,
		GameData.ItemTypes.SHIELD,
		GameData.ItemTypes.CHARM,
      },
      slots =
      {
        GameData.EquipSlots.BODY,
		GameData.EquipSlots.GLOVES,
		GameData.EquipSlots.BOOTS,
		GameData.EquipSlots.HELM,
		GameData.EquipSlots.SHOULDERS,
      },
    },
    { stringId = StringTables.AuctionHouse.CREATE_SEARCH_CATEGORY_ACCESSORIES, 
      allItemTypesStringId = StringTables.AuctionHouse.CREATE_SEARCH_ITEM_TYPE_ALL_ACCESSORIES,
      allSlotsStringId = StringTables.AuctionHouse.CREATE_SEARCH_SLOT_ALL_ACCESSORIES,
      tradeSkills = false,
      itemTypes =
      {
      },
      slots =
      {
        GameData.EquipSlots.BACK,
		GameData.EquipSlots.BELT,
		GameData.EquipSlots.ACCESSORY1,
      },
    },
    { stringId = StringTables.AuctionHouse.CREATE_SEARCH_CATEGORY_CRAFTING,
      allItemTypesStringId = StringTables.AuctionHouse.CREATE_SEARCH_ITEM_TYPE_ALL_CRAFTING,
      allSlotsStringId = StringTables.AuctionHouse.CREATE_SEARCH_SLOT_ALL_CRAFTING,
      tradeSkills = true,
      itemTypes =
      {
      },
      slots =
      {
      },
    },
    { stringId = StringTables.AuctionHouse.CREATE_SEARCH_CATEGORY_MISC,
      allItemTypesStringId = StringTables.AuctionHouse.CREATE_SEARCH_ITEM_TYPE_ALL_MISC,
      allSlotsStringId = StringTables.AuctionHouse.CREATE_SEARCH_SLOT_ALL_MISC,
      tradeSkills = false,
      itemTypes =
      {
        GameData.ItemTypes.POTION,
		GameData.ItemTypes.ENHANCEMENT,
		GameData.ItemTypes.DYE,
        GameData.ItemTypes.SIEGE,
        GameData.ItemTypes.TROPHY,
      },
      slots =
      {
        GameData.EquipSlots.POCKET1
      },
    },
}

local DEFAULT_SELECTION = 1

function AuctionWindowSearchControls.Initialize()
    ButtonSetText( SEARCH_CONTROLS_NAME.."SearchButton", GetStringFromTable( "AuctionHouseStrings",  StringTables.AuctionHouse.CREATE_SEARCH_SEARCH_BUTTON ) )
    ButtonSetText( SEARCH_CONTROLS_NAME.."ClearButton", GetStringFromTable( "AuctionHouseStrings",  StringTables.AuctionHouse.CREATE_AUCTION_CLEAR_BUTTON ) )
    LabelSetText( SEARCH_CONTROLS_NAME.."RankHeader", GetStringFromTable( "AuctionHouseStrings",  StringTables.AuctionHouse.LABEL_ITEM_LEVEL_EDIT_BOXES ) )
    LabelSetText( SEARCH_CONTROLS_NAME.."RankSeparator", GetStringFromTable( "AuctionHouseStrings",  StringTables.AuctionHouse.LABEL_ITEM_LEVEL_EDIT_BOX_SEPARATOR ) )
    LabelSetText( SEARCH_CONTROLS_NAME.."AdditionalFiltersLabel", GetStringFromTable( "AuctionHouseStrings",  StringTables.AuctionHouse.LABEL_ADDITIONAL_FILTERS ) )
    
    for _, rarityData in pairs(RARITY_DATA)
    do
        ComboBoxAddMenuItem( SEARCH_CONTROLS_NAME.."Rarities", GetStringFromTable( "AuctionHouseStrings", rarityData.stringId ) )
    end
    
    for _, categoryData in ipairs(CATEGORY_DATA)
    do
        ComboBoxAddMenuItem( SEARCH_CONTROLS_NAME.."Categories", GetStringFromTable( "AuctionHouseStrings", categoryData.stringId ) )
    end
    
    for rankNum = MIN_RANK, MAX_RANK
    do
        ComboBoxAddMenuItem( SEARCH_CONTROLS_NAME.."MinRank", towstring(rankNum) )
        ComboBoxAddMenuItem( SEARCH_CONTROLS_NAME.."MaxRank", towstring(rankNum) )
    end
    
    AuctionWindowSearchControls.UpdateAdditonalFiltersButton( true )
end

function AuctionWindowSearchControls.Clear()
    ComboBoxSetSelectedMenuItem( SEARCH_CONTROLS_NAME.."Rarities", DEFAULT_SELECTION )
    ComboBoxSetSelectedMenuItem( SEARCH_CONTROLS_NAME.."MinRank", 1 )
    ComboBoxSetSelectedMenuItem( SEARCH_CONTROLS_NAME.."MaxRank", MAX_RANK - MIN_RANK + 1 )
    
    TextEditBoxSetText( SEARCH_CONTROLS_NAME.."SearchBox", L"" )
    
    ComboBoxSetSelectedMenuItem( SEARCH_CONTROLS_NAME.."Categories", DEFAULT_SELECTION )
    AuctionWindowSearchControls.OnChangeCategory()
    
    AuctionWindowSearchControls.selectedCareer = NO_CONTEXT_MENU_ITEM_SELECTED
    AuctionWindowSearchControls.selectedRestriction = GameData.Auction.RESTRICTION_NONE
    AuctionWindowSearchControls.selectedStatistic = GameData.BonusTypes.EBONUS_NONE
end

function AuctionWindowSearchControls.OnLButtonUpProcessed()
    AuctionWindowSearchControls.UpdateAdditonalFiltersButton( not WindowGetShowing( "EA_Window_ContextMenu1" ) )
end

function AuctionWindowSearchControls.Search()
    local searchQuery = AuctionWindowListDataManager.CreateEmptyQuery()
    
    searchQuery.minItemLevel = ComboBoxGetSelectedMenuItem( SEARCH_CONTROLS_NAME.."MinRank" ) - MIN_RANK + 1
    searchQuery.maxItemLevel = ComboBoxGetSelectedMenuItem( SEARCH_CONTROLS_NAME.."MaxRank" ) - MIN_RANK + 1
    
    searchQuery.itemName = TextEditBoxGetText(SEARCH_CONTROLS_NAME.."SearchBox") or L""
	searchQuery.restrictionType = AuctionWindowSearchControls.selectedRestriction
    searchQuery.career = AuctionWindowSearchControls.selectedCareer
    
    local rarityIndex = ComboBoxGetSelectedMenuItem( SEARCH_CONTROLS_NAME.."Rarities" )
    searchQuery.rarity = RARITY_DATA[rarityIndex].rarity
	
    if ( AuctionWindowSearchControls.selectedStatistic ~= GameData.BonusTypes.EBONUS_NONE )
	then
	    searchQuery.itemBonuses = { AuctionWindowSearchControls.selectedStatistic }
	end
    
    local categoryIndex = ComboBoxGetSelectedMenuItem(SEARCH_CONTROLS_NAME.."Categories")
    local categoryData = CATEGORY_DATA[categoryIndex]
    if ( categoryData.tradeSkills )
    then
        searchQuery.minTradeSkillLevel = MIN_TRADESKILL_RANK
        searchQuery.maxTradeSkillLevel = MAX_TRADESKILL_RANK
    end
    
    searchQuery.itemTypes = AuctionWindowSearchControls.itemTypesSelected
	searchQuery.itemEquipSlots = AuctionWindowSearchControls.itemSlotsSelected
    
    local hasItemTypes = ( next( searchQuery.itemTypes ) ~= nil )
    local hasItemEquipSlots = ( next( searchQuery.itemEquipSlots ) ~= nil )
    
    if ( ( categoryIndex ~= DEFAULT_SELECTION ) and not hasItemTypes and not hasItemEquipSlots )
    then
        -- If both Default Item Types and Default Equip Slots are chosen, apply one of the category's restrictions
        -- Prefer applying the Item Types restriction, unless there is none, in which case apply the Equip Slots restriction
        if ( next( categoryData.itemTypes ) ~= nil )
        then
            searchQuery.itemTypes = categoryData.itemTypes
        else
            searchQuery.itemEquipSlots = categoryData.slots
        end
	end
    
    AuctionWindowListDataManager.SendAuctionSearch(searchQuery)
end

-- Search Functions
function AuctionWindowSearchControls.OnLButtonUpSearch()
    AuctionWindowSearchControls.Search()
end

function AuctionWindowSearchControls.OnLButtonUpClear()
    AuctionWindowSearchControls.Clear()
end

function AuctionWindowSearchControls.OnChangeMinRank( newIndex )
    -- If the new min rank is greater than the current max rank, force the max rank upward to match
    if ( newIndex > ComboBoxGetSelectedMenuItem( SEARCH_CONTROLS_NAME.."MaxRank" ) )
    then
        ComboBoxSetSelectedMenuItem( SEARCH_CONTROLS_NAME.."MaxRank", newIndex )
    end
end

function AuctionWindowSearchControls.OnChangeMaxRank( newIndex )
    -- If the new max rank is lesser than the current min rank, force the min rank downward to match
    if ( newIndex < ComboBoxGetSelectedMenuItem( SEARCH_CONTROLS_NAME.."MinRank" ) )
    then
        ComboBoxSetSelectedMenuItem( SEARCH_CONTROLS_NAME.."MinRank", newIndex )
    end
end

function AuctionWindowSearchControls.BuildComboBox( comboBoxName, defaultStringId, options, checkedOptions, namesArray )
    local checkedPrefix = L"<icon"..CHECKBOX_CHECKED_ICON..L">  "
    local uncheckedPrefix = L"<icon"..CHECKBOX_UNCHECKED_ICON..L">  "
    local defaultString = GetStringFromTable( "AuctionHouseStrings", defaultStringId )
    local selectedText = L""
    
    ComboBoxClearMenuItems( comboBoxName )
    ComboBoxAddMenuItem( comboBoxName, defaultString )
    for _, itemType in ipairs(options)
    do
        local isChecked = false
        for _, checkedItemType in ipairs(checkedOptions)
        do
            if ( itemType == checkedItemType )
            then
                isChecked = true
                break
            end
        end
        
        if ( isChecked )
        then
            if ( selectedText ~= L"" )
            then
                selectedText = selectedText..L", "
            end
            selectedText = selectedText..namesArray[itemType].name
            
            ComboBoxAddMenuItem( comboBoxName, checkedPrefix..namesArray[itemType].name )
        else
            ComboBoxAddMenuItem( comboBoxName, uncheckedPrefix..namesArray[itemType].name )
        end
    end
	
	if ( selectedText == L"" )
    then
		selectedText = defaultString
	end
	
	ButtonSetText( comboBoxName.."SelectedButton", selectedText )
end

function AuctionWindowSearchControls.RebuildItemTypes()
    local categoryIndex = ComboBoxGetSelectedMenuItem( SEARCH_CONTROLS_NAME.."Categories" )
    local categoryData = CATEGORY_DATA[categoryIndex]
    
    AuctionWindowSearchControls.BuildComboBox( SEARCH_CONTROLS_NAME.."ItemTypes", categoryData.allItemTypesStringId, categoryData.itemTypes, AuctionWindowSearchControls.itemTypesSelected, ItemTypes )
end

function AuctionWindowSearchControls.RebuildItemSlots()
    local categoryIndex = ComboBoxGetSelectedMenuItem( SEARCH_CONTROLS_NAME.."Categories" )
    local categoryData = CATEGORY_DATA[categoryIndex]
    
    AuctionWindowSearchControls.BuildComboBox( SEARCH_CONTROLS_NAME.."Slots", categoryData.allSlotsStringId, categoryData.slots, AuctionWindowSearchControls.itemSlotsSelected, ItemSlots )
end

function AuctionWindowSearchControls.OnChangeCategory()
    AuctionWindowSearchControls.itemTypesSelected = {}
    AuctionWindowSearchControls.itemSlotsSelected = {}
    
    AuctionWindowSearchControls.RebuildItemTypes( DEFAULT_SELECTION )
    AuctionWindowSearchControls.RebuildItemSlots( DEFAULT_SELECTION )
end

function AuctionWindowSearchControls.ToggleInArray( arrayVar, arrayItem )
    for index, itemVal in ipairs(arrayVar)
    do
        if ( itemVal == arrayItem )
        then
            table.remove( arrayVar, index )
            return
        end
    end
    -- If we're here, we didn't find anything to remove, so add it
    table.insert( arrayVar, arrayItem )
end

function AuctionWindowSearchControls.OnCheckItemType( index )
    if ( index == DEFAULT_SELECTION )
    then
        AuctionWindowSearchControls.itemTypesSelected = {}
    else
        local categoryIndex = ComboBoxGetSelectedMenuItem( SEARCH_CONTROLS_NAME.."Categories" )
        local categoryData = CATEGORY_DATA[categoryIndex]
        local itemType = categoryData.itemTypes[index - 1]  -- Subtract 1 due to the extra "All" option at the top
        
        AuctionWindowSearchControls.ToggleInArray( AuctionWindowSearchControls.itemTypesSelected, itemType )
        
        WindowRegisterEventHandler( SEARCH_CONTROLS_NAME.."ItemTypes", SystemData.Events.L_BUTTON_UP_PROCESSED, "AuctionWindowSearchControls.ReopenItemTypes" )
    end
    
    AuctionWindowSearchControls.RebuildItemTypes()
end

function AuctionWindowSearchControls.OnCheckItemSlot( index )
    if ( index == DEFAULT_SELECTION )
    then
        AuctionWindowSearchControls.itemSlotsSelected = {}
    else
        local categoryIndex = ComboBoxGetSelectedMenuItem( SEARCH_CONTROLS_NAME.."Categories" )
        local categoryData = CATEGORY_DATA[categoryIndex]
        local itemSlot = categoryData.slots[index - 1]  -- Subtract 1 due to the extra "All" option at the top
        
        AuctionWindowSearchControls.ToggleInArray( AuctionWindowSearchControls.itemSlotsSelected, itemSlot )
        
        WindowRegisterEventHandler( SEARCH_CONTROLS_NAME.."Slots", SystemData.Events.L_BUTTON_UP_PROCESSED, "AuctionWindowSearchControls.ReopenItemSlots" )
    end
    
    AuctionWindowSearchControls.RebuildItemSlots()
end

function AuctionWindowSearchControls.ReopenItemTypes()
    ComboBoxExternalOpenMenu( SEARCH_CONTROLS_NAME.."ItemTypes" )
	WindowUnregisterEventHandler( SEARCH_CONTROLS_NAME.."ItemTypes", SystemData.Events.L_BUTTON_UP_PROCESSED )
end

function AuctionWindowSearchControls.ReopenItemSlots()
    ComboBoxExternalOpenMenu( SEARCH_CONTROLS_NAME.."Slots" )
	WindowUnregisterEventHandler( SEARCH_CONTROLS_NAME.."Slots", SystemData.Events.L_BUTTON_UP_PROCESSED )
end

-- Addtional Filters Functions
function AuctionWindowSearchControls.UpdateAdditonalFiltersButton( showPlusButton )
    WindowSetShowing( SEARCH_CONTROLS_NAME.."AdditionalFiltersButtonPlusButton", showPlusButton )
    WindowSetShowing( SEARCH_CONTROLS_NAME.."AdditionalFiltersButtonMinusButton", not showPlusButton )
    
    if ( showPlusButton )
    then
        if ( AuctionWindowSearchControls.isProcessedEventRegistered )
        then
            WindowUnregisterEventHandler( WINDOW_NAME, SystemData.Events.L_BUTTON_UP_PROCESSED )
            AuctionWindowSearchControls.isProcessedEventRegistered = false
        end
    else
        if ( not AuctionWindowSearchControls.isProcessedEventRegistered )
        then
            WindowRegisterEventHandler( WINDOW_NAME, SystemData.Events.L_BUTTON_UP_PROCESSED, "AuctionWindowSearchControls.OnLButtonUpProcessed")
            AuctionWindowSearchControls.isProcessedEventRegistered = true
        end
    end
end

local function CreateWindowIfItDoesNotExist( windowName, templateName )
    if( not DoesWindowExist( windowName ) )
    then
        CreateWindowFromTemplate( windowName, templateName, "Root" )
    end
end

local function CreateAndAddSelectionMenuItem( buttonText, id, selectionName )
    local windowName = WINDOW_NAME..selectionName.."ContextMenuItem"..id
    CreateWindowIfItDoesNotExist( windowName, "AuctionWindowContextMenuItem"..selectionName )
    
    ButtonSetText( windowName, buttonText )
    WindowSetShowing( windowName.."Check", AuctionWindowSearchControls["selected"..selectionName ] == id )
    
    EA_Window_ContextMenu.AddUserDefinedMenuItem( windowName, EA_Window_ContextMenu.CONTEXT_MENU_2 )
    
    local func = function() AuctionWindowSearchControls["selected"..selectionName ] = id ButtonSetPressedFlag(windowName, false) end
    AuctionWindowSearchControls["clicked"..selectionName.."FunctionTable"][ WindowGetId( windowName ) ] = func
end

local function SpawnStatisticMenu()
    EA_Window_ContextMenu.CreateContextMenu(nil, EA_Window_ContextMenu.CONTEXT_MENU_2)
    local noneText = GetStringFromTable( "AuctionHouseStrings",  StringTables.AuctionHouse.CONTEXT_MENU_ADDITIONAL_FILTERS_NONE )
    CreateAndAddSelectionMenuItem( noneText, GameData.BonusTypes.EBONUS_NONE, "Statistic" )
    CreateAndAddSelectionMenuItem( BonusTypes[GameData.BonusTypes.EBONUS_STRENGTH].name, GameData.BonusTypes.EBONUS_STRENGTH, "Statistic" )
    CreateAndAddSelectionMenuItem( BonusTypes[GameData.BonusTypes.EBONUS_WILLPOWER].name, GameData.BonusTypes.EBONUS_WILLPOWER, "Statistic" )
    CreateAndAddSelectionMenuItem( BonusTypes[GameData.BonusTypes.EBONUS_TOUGHNESS].name, GameData.BonusTypes.EBONUS_TOUGHNESS, "Statistic" )
    CreateAndAddSelectionMenuItem( BonusTypes[GameData.BonusTypes.EBONUS_WOUNDS].name, GameData.BonusTypes.EBONUS_WOUNDS, "Statistic" )
    CreateAndAddSelectionMenuItem( BonusTypes[GameData.BonusTypes.EBONUS_INITIATIVE].name, GameData.BonusTypes.EBONUS_INITIATIVE, "Statistic" )
    CreateAndAddSelectionMenuItem( BonusTypes[GameData.BonusTypes.EBONUS_WEAPONSKILL].name, GameData.BonusTypes.EBONUS_WEAPONSKILL, "Statistic" )
    CreateAndAddSelectionMenuItem( BonusTypes[GameData.BonusTypes.EBONUS_BALLISTICSKILL].name, GameData.BonusTypes.EBONUS_BALLISTICSKILL, "Statistic" )
    CreateAndAddSelectionMenuItem( BonusTypes[GameData.BonusTypes.EBONUS_INTELLIGENCE].name, GameData.BonusTypes.EBONUS_INTELLIGENCE, "Statistic" )
    CreateAndAddSelectionMenuItem( BonusTypes[GameData.BonusTypes.EBONUS_SPIRIT_RESIST].name, GameData.BonusTypes.EBONUS_SPIRIT_RESIST, "Statistic" )
    CreateAndAddSelectionMenuItem( BonusTypes[GameData.BonusTypes.EBONUS_ELEMENTAL_RESIST].name, GameData.BonusTypes.EBONUS_ELEMENTAL_RESIST, "Statistic" )
    CreateAndAddSelectionMenuItem( BonusTypes[GameData.BonusTypes.EBONUS_CORPOREAL_RESIST].name, GameData.BonusTypes.EBONUS_CORPOREAL_RESIST, "Statistic" )
    
    EA_Window_ContextMenu.Finalize( EA_Window_ContextMenu.CONTEXT_MENU_2 )
end

local function SpawnCareerMenu()
    EA_Window_ContextMenu.CreateContextMenu(nil, EA_Window_ContextMenu.CONTEXT_MENU_2)
    local noneText = GetStringFromTable( "AuctionHouseStrings",  StringTables.AuctionHouse.CONTEXT_MENU_ADDITIONAL_FILTERS_NONE )
    CreateAndAddSelectionMenuItem( noneText, NO_CONTEXT_MENU_ITEM_SELECTED, "Career"  ) -- Add the none choice
    for careerId, careerData in ipairs(CareerNames)
    do
        CreateAndAddSelectionMenuItem( careerData.name, careerId, "Career" )
    end
    EA_Window_ContextMenu.Finalize( EA_Window_ContextMenu.CONTEXT_MENU_2 )
end

local function SpawnRestriction()
    EA_Window_ContextMenu.CreateContextMenu(nil, EA_Window_ContextMenu.CONTEXT_MENU_2)
    CreateAndAddSelectionMenuItem( GetStringFromTable( "AuctionHouseStrings",  StringTables.AuctionHouse.CONTEXT_MENU_ADDITIONAL_FILTERS_UNRESTRICTED ), GameData.Auction.RESTRICTION_NONE, "Restriction" ) -- Add the none choice
	if AuctionWindow.PlayerCanSearchGuildAuctions()
	then
		CreateAndAddSelectionMenuItem( GetStringFromTable( "AuctionHouseStrings", StringTables.AuctionHouse.CONTEXT_MENU_ADDITIONAL_FILTERS_GUILD ), GameData.Auction.RESTRICTION_GUILD_ONLY, "Restriction" )
	end
	
	if AuctionWindow.PlayerCanSearchAllianceAuctions()
	then
		CreateAndAddSelectionMenuItem( GetStringFromTable( "AuctionHouseStrings", StringTables.AuctionHouse.CONTEXT_MENU_ADDITIONAL_FILTERS_ALLIANCE ), GameData.Auction.RESTRICTION_GUILD_ALLIANCE_ONLY, "Restriction" )
	end

    EA_Window_ContextMenu.Finalize( EA_Window_ContextMenu.CONTEXT_MENU_2 )
end

local function OnLButtonDownContextMenuItem( funcTable )
    local clickedFunc = funcTable[ WindowGetId( SystemData.ActiveWindow.name ) ]
    clickedFunc()
    EA_Window_ContextMenu.HideAll()
end

function AuctionWindowSearchControls.OnLButtonDownRestrictionSelection()
    OnLButtonDownContextMenuItem( AuctionWindowSearchControls.clickedRestrictionFunctionTable )
end

function AuctionWindowSearchControls.OnLButtonDownStatisticSelection()
    OnLButtonDownContextMenuItem( AuctionWindowSearchControls.clickedStatisticFunctionTable )
end

function AuctionWindowSearchControls.OnLButtonDownCareerSelection()
    OnLButtonDownContextMenuItem( AuctionWindowSearchControls.clickedCareerFunctionTable )
end

local function GetSelectedName( selectedId, selectedString, noneString, noneId )
    if( selectedId  == noneId )
    then
        return noneString
    end
    
    return selectedString
end

function AuctionWindowSearchControls.OnLButtonUpAdditonalFilters()
    local isPlusButtonShowing = WindowGetShowing( SEARCH_CONTROLS_NAME.."AdditionalFiltersButtonPlusButton" )
    AuctionWindowSearchControls.UpdateAdditonalFiltersButton( not isPlusButtonShowing )
    
    if( isPlusButtonShowing )
    then
        local anchor = { Point="bottomleft",
                         RelativePoint="topleft",
                         RelativeTo=SEARCH_CONTROLS_NAME.."AdditionalFiltersButton",
                         XOffset=0,
                         YOffset=0 }
        
        local noneString = GetStringFromTable( "AuctionHouseStrings",  StringTables.AuctionHouse.CONTEXT_MENU_ADDITIONAL_FILTERS_NONE )
        
        local statName = L""
        if ( BonusTypes[AuctionWindowSearchControls.selectedStatistic] )
        then
            statName = BonusTypes[AuctionWindowSearchControls.selectedStatistic].name or L""
        end
        local statisticSelectionName = GetSelectedName( AuctionWindowSearchControls.selectedStatistic,
                                                        statName,
                                                        noneString,
                                                        GameData.BonusTypes.EBONUS_NONE )
        
        local careerName = L""
        if( CareerNames[AuctionWindowSearchControls.selectedCareer] )
        then
            careerName = CareerNames[AuctionWindowSearchControls.selectedCareer].name or L""
        end
        
        local careerSelectionName = GetSelectedName( AuctionWindowSearchControls.selectedCareer,
                                                     careerName,
                                                     noneString,
                                                     NO_CONTEXT_MENU_ITEM_SELECTED )
                                                     
        local restrictionName = L""
        if( AuctionWindowSearchControls.selectedRestriction == GameData.Auction.RESTRICTION_GUILD_ONLY )
        then
            restrictionName = GetStringFromTable( "AuctionHouseStrings",  StringTables.AuctionHouse.CONTEXT_MENU_ADDITIONAL_FILTERS_GUILD )
        elseif( AuctionWindowSearchControls.selectedRestriction == GameData.Auction.RESTRICTION_GUILD_ALLIANCE_ONLY )
        then
            restrictionName = GetStringFromTable( "AuctionHouseStrings",  StringTables.AuctionHouse.CONTEXT_MENU_ADDITIONAL_FILTERS_ALLIANCE )
        end
        
        local restrictionSelectionName = GetSelectedName( AuctionWindowSearchControls.selectedRestriction,
                                                          restrictionName,
                                                          GetStringFromTable( "AuctionHouseStrings",  StringTables.AuctionHouse.CONTEXT_MENU_ADDITIONAL_FILTERS_UNRESTRICTED ),
                                                          GameData.Auction.RESTRICTION_NONE )

        -- Spawn the additional filters window as the context window
        EA_Window_ContextMenu.CreateContextMenu()
        EA_Window_ContextMenu.AddCascadingMenuItem( GetStringFormatFromTable( "AuctionHouseStrings",  StringTables.AuctionHouse.CONTEXT_MENU_ADDITIONAL_FILTERS_STATISTIC_X, {statisticSelectionName} ), SpawnStatisticMenu )
        EA_Window_ContextMenu.AddCascadingMenuItem( GetStringFormatFromTable( "AuctionHouseStrings",  StringTables.AuctionHouse.CONTEXT_MENU_ADDITIONAL_FILTERS_CAREER_X, {careerSelectionName} ), SpawnCareerMenu )
        EA_Window_ContextMenu.AddCascadingMenuItem( GetStringFormatFromTable( "AuctionHouseStrings",  StringTables.AuctionHouse.CONTEXT_MENU_ADDITIONAL_FILTERS_RESTRICTION_X, {restrictionSelectionName} ), SpawnRestriction )
        EA_Window_ContextMenu.Finalize(EA_Window_ContextMenu.CONTEXT_MENU_1, anchor)
    end
end
