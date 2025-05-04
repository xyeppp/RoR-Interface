
-- NOTE: This file is doccumented with NaturalDocs style comments. All comments begining with "--#' will
-- be included in the output.

------------------------------------------------------------------------------------------------------------------------------------------------
--# Title: Data Utils
--#     This file contains data manipulation and access utilities similar to <StringUtils> and <WindowUtils>.
------------------------------------------------------------------------------------------------------------------------------------------------

-- WARNING: Changing these may have widespread and unpredictable impact on
-- various interfaces.


DataUtils = 
{
    SORT_ORDER_UP   = 1,
    SORT_ORDER_DOWN = 2,
}

--****************************************************************************************
-- LOCAL

local DataUtilsData = 
{
    tomeAlerts      = {},
    macros          = {},
    quests          = {},
    items           = {},
    currencyItems   = {},
    craftingItems   = {};
    questItems      = {},
    influenceData   = {},
    equippedItems   = {},
    trophyItems     = {},
    bankItems     = {},
}

--****************************************************************************************
-- Global Tables to be shared among various windows should go here.
-- These tables are going to be used for things such as timer updates.

DataUtils.activeObjectivesData = nil;


--****************************************************************************************
-- GENERAL UTILS
--****************************************************************************************

----------------------------------------------------------------------------------------------------
--# Function: DataUtils.OrderingFunction()
--#         This is a helper function for table.sort's comparators to call.  It returns the ordering
--#         of the first two input parameters given the desired ordering (up or down.)
--#
--#     Parameters:
--#         table1      - (table) An entry in the table being sorted
--#         table2      - (table) Another entry in the table being sorted
--#         sortKey     - (anything) A key in the table arguments (tableX[sortKey]) to be used for sorting.
--#         sortKeys    - (table) A table whose keys are all keys in tableX and whose values are all tables (optionally containing fallback and isNumeric)
--#         sortOrder   - (number) Must be DataUtils.SORT_ORDER_UP or DataUtils.SORT_ORDER_DOWN
--#
--#     Returns:
--#         (boolean) - When sortOrder is DataUtils.SORT_ORDER_UP: table1[sortKey] < table2[sortKey]
--#                     otherwise this returns table1[sortKey] > table2[sortKey]
--#
--#     Example:
--#
----------------------------------------------------------------------------------------------------
local ValidOrderingValueTypes =
{
    ["number"]  = true, 
    ["string"]  = true, 
    ["wstring"] = true, 
    ["boolean"] = true
}

function DataUtils.OrderingFunction (table1, table2, sortKey, sortKeys, sortOrder)
    local value1        = table1[sortKey]
    local value2        = table2[sortKey]
    local value1Type    = type (value1)
    
    if (value1Type ~= type (value2) or not ValidOrderingValueTypes[value1Type])
    then
        return false
    end
    
    if (value1Type == "boolean")
    then
        local function NumberFromBoolean (b) 
            if (b) 
            then 
                return 1 
            end 
            return 0 
        end
        
        value1 = NumberFromBoolean (value1)
        value2 = NumberFromBoolean (value2)
    end
    
    assert (type (sortKeys[sortKey]) == "table")
    
    if (sortKeys[sortKey].isNumeric)
    then
        value1 = tonumber (value1)
        value2 = tonumber (value2)
    end
    
    if (value1 == value2)
    then
        local fallback = sortKeys[sortKey].fallback
        
        if (fallback)
        then
            -- When sorting by a fallback key, always sort in ascending order.
            -- eg, The primary key is "level", the fallback is "name", when:
            --
            -- table1["level"] == table2["level"]
            --
            -- then use the fallback of name so that 
            
            return DataUtils.OrderingFunction (table1, table2, fallback, sortKeys, DataUtils.SORT_ORDER_UP)
        end
    else
        if (sortOrder == DataUtils.SORT_ORDER_UP)
        then
            return value1 < value2
        end

        return value1 > value2    
    end
    
    return false
end


----------------------------------------------------------------------------------------------------
--# Function: DataUtils.AlphabetizeByNames()
--#         This is a function for table.sort() to be called on an array of data tables that contain
--#         The "name" field. This will re-arrange the entries in the array so that they are ordered
--#         in increasing alphabetical order.  The name field must be a wide string
--#
--#     Parameters:
--#         table1         - (table) A table data structure in the array.
--#         table2         - (table) A table data structure in the array.
--#
--#     Returns:
--#         true    - If table1.name > table2.name
--#         false   - If table2.name <= table1.name
--#
--#     Example:
--#         
--#         >     -- Sort the BeatiaryTypes List alphabetically
--#         >    table.sort( TomeWindow.Bestiary.TOCData, DataUtils.AlphabetizeByNames )
--#
----------------------------------------------------------------------------------------------------
function DataUtils.AlphabetizeByNames( table1, table2 )

    if( table2 == nil ) then
        return false
    end
    
    if( table1 == nil ) then
        return false
    end
    
    if( table1.name == nil or table2.name == nil ) then
        ERROR(L"DataUtils.AlphabetizeByNames may only be used on tables containing 'name' variables." )
        return false
    end
        
    -- Sort unknown names (name == L"???" ) to
    -- the end of the list.
    if( table1.name == L"???" ) then
        return false
    end
    
    if( table2.name == L"???" ) then
        return true
    end

    return (table1.name < table2.name)
end

----------------------------------------------------------------------------------------------------
--# Function: DataUtils.CopyTable()
--#         Creates a new table, performing a deep-copy of the source table to the new table.  
--#         Returns the new table.
--#
--#     Parameters:
--#         source  - (table) The table that should be copied
--#
--#     Returns:
--#         copiedTable - A new table which looks exactly like sourceTable, but is distinct from it.
--#
--#     Notes:
--#         Does not copy metatable data.
--#
--#     Example:
--#         
--#         >    local myCopy = DataUtils.CopyTable (sourceTable)
--#
----------------------------------------------------------------------------------------------------
function DataUtils.CopyTable (source)
    -- Don't ERROR out on this, it stops your script execution...not so desirable for debugging.

    if (source == nil) 
    then
        d (L"DataUtils.CopyTable (source): Source table was nil.")
        return nil
    end
    
    if (type (source) ~= "table") 
    then        
        d (L"DataUtils.CopyTable (source): Source is not a table, it was a ="..towstring(type(source)))
        return nil
    end

    local newTable = {}

    for k, v in pairs (source) 
    do
        if (type (v) == "table")
        then
            newTable[k] = DataUtils.CopyTable (v)
        else
            newTable[k] = v
        end
    end
    
    return newTable
end

--****************************************************************************************
-- INTERNAL TIMERS
--****************************************************************************************

--****************************************************************************************************
-- Locally scoped timer update functions
--****************************************************************************************************

--[[
    These should only be called once per frame, do not call externally.
    Some of these updates merely decrement a timer value, others have
    callbacks...all of these can be unified to use a timer object/table
    in the Lua data which can be set and updated by a generalized function.
--]]

--[[
    Quest
--]]
local function UpdateQuestTimers( timePassed )

    local tempQuests = DataUtils.GetQuests()
    for index, questData in ipairs( tempQuests ) do
        if( questData.timeLeft ~= 0  ) then
            questData.timeLeft = questData.timeLeft - timePassed 
            if( questData.timeLeft < 0 ) then
                questData.timeLeft = 0
            end
        end             
    end
end

--[[
    Scenario timers
--]]
local function UpdateScenarioTimers( timePassed )

    -- Update the scenario timer
    if( GameData.ScenarioData.mode ~= GameData.ScenarioMode.ENDED and GameData.ScenarioData.timeLeft > 0 ) then
    
        GameData.ScenarioData.timeLeft = GameData.ScenarioData.timeLeft - timePassed
        if( GameData.ScenarioData.timeLeft < 0 ) then
            GameData.ScenarioData.timeLeft = 0
        end
    end 
end

--****************************************************************************************
-- Initialization/Update Cycle
--****************************************************************************************

function DataUtils.Initialize ()
    RegisterEventHandler (SystemData.Events.ITEM_SET_DATA_ARRIVED, "DataUtils.UpdateItemSets")
    RegisterEventHandler (SystemData.Events.MACROS_LOADED, "DataUtils.ReloadMacros" )
    RegisterEventHandler (SystemData.Events.PLAYER_INVENTORY_SLOT_UPDATED, "DataUtils.ReloadItems")
    RegisterEventHandler (SystemData.Events.PLAYER_CRAFTING_SLOT_UPDATED, "DataUtils.ReloadCraftingItems")
    RegisterEventHandler (SystemData.Events.PLAYER_CURRENCY_SLOT_UPDATED, "DataUtils.ReloadCurrencyItems")
    RegisterEventHandler (SystemData.Events.PLAYER_QUEST_ITEM_SLOT_UPDATED, "DataUtils.ReloadQuestItems")
    RegisterEventHandler (SystemData.Events.LOADING_BEGIN, "DataUtils.BeginLoading")
    RegisterEventHandler (SystemData.Events.LOADING_END, "DataUtils.EndLoading")
    RegisterEventHandler (SystemData.Events.INTERFACE_RELOADED, "DataUtils.EndLoading")
    
    -- Why this isn't in the DataUtilsData table is beyond me...
    DataUtils.activeObjectivesData  = GetActiveObjectivesData()
    
    GameData.Player.tomeAlertsDirty     = true
    GameData.Macros.macrosDirty         = true
    GameData.Player.questsDirty         = true
    GameData.Player.itemsDirty          = true 
    GameData.Player.questItemsDirty     = true
    GameData.Player.craftingItemsDirty  = true 
    GameData.Player.currencyItemsDirty  = true 
    GameData.Player.influenceDataDirty  = true
    GameData.Player.equippedItemsDirty  = true
    GameData.Player.trophyItemsDirty    = true
    GameData.Player.bankItemsDirty    = true
    
    DataUtils.GetTomeAlerts()    
    DataUtils.GetMacros()    
    DataUtils.GetQuests()
    DataUtils.GetItems()
    DataUtils.GetCraftingItems()
    DataUtils.GetCurrencyItems()
    DataUtils.GetQuestItems()
    DataUtils.GetAllInfluenceData()
end

function DataUtils.Shutdown ()
    WindowUnregisterEventHandler ("Root", SystemData.Events.ITEM_SET_DATA_ARRIVED)
    
    UnregisterEventHandler (SystemData.Events.LOADING_BEGIN, "DataUtils.BeginLoading")
    UnregisterEventHandler (SystemData.Events.LOADING_END, "DataUtils.EndLoading")
    UnregisterEventHandler (SystemData.Events.INTERFACE_RELOADED, "DataUtils.EndLoading")
end

function DataUtils.Update( timePassed )
    UpdateQuestTimers(timePassed)
    UpdateScenarioTimers( timePassed )
end

local worldIsLoading = false

function DataUtils.BeginLoading ()
    worldIsLoading = true
end

function DataUtils.EndLoading ()
    worldIsLoading = false
end

function DataUtils.IsWorldLoading ()
    return worldIsLoading
end

function DataUtils.ReloadMacros ()
    DataUtils.GetMacros ()
end

function DataUtils.ReloadItems()
    DataUtils.GetItems()
end

function DataUtils.ReloadCraftingItems()
    DataUtils.GetCraftingItems()
end

function DataUtils.ReloadCurrencyItems()
    DataUtils.GetCurrencyItems()
end

function DataUtils.ReloadQuestItems()
    DataUtils.GetQuestItems()
end


--****************************************************************************************
-- ITEM DATA

local function Requirements (hasCareer, hasSkills, isRace, hasRenown, isLevel)
    return { career = hasCareer, skills = hasSkills, race = isRace, renown = hasRenown, level = isLevel }
end


----------------------------------------------------------------------------------------------------
--# Function: DataUtils.PlayerMeetsReqs()
--#     Tests to see if the player meets the requirements for using this item.
--#
--#     Parameters:
--#         itemdata       - (<ItemData>) The item to query
--#
--#     Returns:
--#         reqs - (table) The requires check results
--#
--#         Format as follows...
--#
--#             reqs.career - (boolean) Can the player's career use this item?
--#             reqs.skills - (boolean) Does the player have high enough skill?
--#             reqs.race   - (boolean) Can the player's race use this item?
--#             reqs.renown - (boolean) Does the player have high enough renown?
--#             reqs.level  - (boolean) Is the player of high enough level?
--#             reqs.tradeSkillLevel  - (boolean) Does the player have high enough level for ?
--#
--#     Notes:
--#         none
--#
----------------------------------------------------------------------------------------------------
function DataUtils.PlayerMeetsReqs (inItemData)

    -- DEBUG (L"Player Data:\n   CareerLine: "..GameData.Player.career.line..L", Race: "..GameData.Player.race.id)

    local reqs = Requirements (true, true, true, true, true)

    if (inItemData == nil) then
        return reqs
    end

    reqs.career = DataUtils.CareerIsAllowedForItem( GameData.Player.career.line, inItemData )
    reqs.skills = DataUtils.SkillIsEnoughForItem( GameData.Player.Skills, inItemData )
    reqs.race   = DataUtils.RaceIsAllowedForItem( GameData.Player.race.id, inItemData )
    reqs.renown = DataUtils.RenownIsEnoughForItem( GameData.Player.Renown.curRank, inItemData )
    reqs.level  = DataUtils.LevelIsEnoughForItem( GameData.Player.level, inItemData )
    reqs.tradeSkillLevel = DataUtils.PlayerTradeSkillLevelIsEnoughForItem( inItemData )

    return reqs

end


----------------------------------------------------------------------------------------------------
--# Function: DataUtils.ItemIsWeapon()
--#         Convenience function to see if an item is a weapon
--#
--#     Parameters:
--#         itemdata        - (<ItemData>) The item to query
--#
--#     Returns:
--#         isWeapon        - (boolean) Whether or not the queried item is a weapon.
--#
--#
--#     Notes:
--#         Right now I just check and see if it's equipped in the readied slots, this is going to give
--#         false positives when off-hand/ability enhancing items come into play.
--#         Shields are held in the offhand, BUT if they have a block value or armor, they will not be
--#         counted as weapons...
--#
----------------------------------------------------------------------------------------------------
function DataUtils.ItemIsWeapon (itemData)
    if (itemData.equipSlot >= GameData.EquipSlots.RIGHT_HAND and itemData.equipSlot < GameData.EquipSlots.BODY) then
    
        -- Do one further check to make sure it's not a shield...STILL not using type...
        if (itemData.blockRating > 0) then 
            return false;
        end
        
        return true;
    end
    
    return false;
end

----------------------------------------------------------------------------------------------------
--# Function: DataUtils.ItemIsArmor()
--#         Convenience function to see if an item is a piece of armor.
--#
--#     Parameters:
--#         itemdata        - (<ItemData>) The item to query
--#
--#     Returns:
--#         isArmor         - (boolean) Whether or not the queried item is a piece of armor.
--#
--#
--#     Notes:
--#         Right now I just check and see if it's equipped in the worn slots.
--#
----------------------------------------------------------------------------------------------------
function DataUtils.ItemIsArmor (itemData)
    return (itemData.equipSlot >= GameData.EquipSlots.BODY) or (itemData.blockRating > 0);
end

----------------------------------------------------------------------------------------------------
--# Function: DataUtils.ItemHasUseEffect()
--#         Convenience function to see if an item has a use effect.
--#
--#     Parameters:
--#         itemdata        - (<ItemData>) The item to query
--#
--#     Returns:
--#         hasUse          - (boolean) Whether or not the queried item has a use effect
--#
--#
--#     Notes:
--#         Simply checks bonuses for any known item use bonuses. It should be noted that quest 
--#     items may have inexplicit uses, so they should send item use messages to the server regardless.
--#
----------------------------------------------------------------------------------------------------
function DataUtils.ItemHasUseEffect(itemData)
    for i, bonus in ipairs(itemData.bonus) do
        if(bonus.type == GameDefs.ITEMBONUS_USE) then
            return true
        end
    end
    
    return false
end

----------------------------------------------------------------------------------------------------
--# Function: DataUtils.PlayerCanUseItem()
--#         Convenience function to test whether or not a player can use an item
--#
--#     Parameters:
--#         itemdata        - (<ItemData>) The item to query
--#
--#     Returns:
--#         usable          - (boolean) Whether or not the queried item can be used by the player.
--#
--#
--#     Notes:
--#         none
--#
----------------------------------------------------------------------------------------------------
function DataUtils.PlayerCanUseItem (inItemData)
    local reqs = DataUtils.PlayerMeetsReqs (inItemData);
    return (reqs.career and reqs.skills and reqs.race and reqs.renown and reqs.level and reqs.tradeSkillLevel);
end

----------------------------------------------------------------------------------------------------
--# Function: DataUtils.PlayerCanEventuallyUseItem()
--#         Convenience function to test whether or not a player can use an item (doesn't check rank or renown rank)
--#
--#     Parameters:
--#         itemdata        - (<ItemData>) The item to query
--#
--#     Returns:
--#         usable          - (boolean) Whether or not the queried item can be used by the player.
--#
--#
--#     Notes:
--#         none
--#
----------------------------------------------------------------------------------------------------
function DataUtils.PlayerCanEventuallyUseItem (inItemData)
    local reqs = DataUtils.PlayerMeetsReqs (inItemData);
    return (reqs.career and reqs.skills and reqs.race);
end

--[[
    Internal table checking function, used by DataUtils.CareerIsAllowedForItem
    and DataUtils.RaceIsAllowedForItem
--]]
local function TableContainsValueOrIsEmpty (testTable, value, onlyPassIfTableContainsValue)

    -- if either input is itself invalid, it's not allowed
    if ((value == nil) or (testTable == nil)) then
        return false
    end
    -- if the table is empty, the second condition of the function is satisfied unless
    -- the table MUST contain the value
    -- I would like to use the length operator (#) defined in Lua 5.1, but it does not 
    -- appear to be supported by our Lua interpreter...so, back to table.getn.
    
    if (onlyPassIfTableContainsValue ~= true) and (table.getn (testTable) == 0) then
        return true
    end
    
    for k, v in ipairs (testTable) do    
        if ((v ~= 0) and (value == v)) then
            return true
        end
    end
    
    return false
end

----------------------------------------------------------------------------------------------------
--# Function: DataUtils.CareerIsAllowedForItem()
--#         Checks whether or not the given career can use the given item.  
--#
--#     Parameters:
--#         career                  - (number)      Which career line you want to check for.
--#                                                 See GameDefs.lua for more details.
--#         item                    - (<ItemData>)  Which item you want to check against.  
--#         onlyPassIfItemHasCareer - (boolean)     (Optional) Forces a failure if the item 
--#                                                 does not have the career as a requirement.
--#
--#     Returns:
--#         isAllowed               - (boolean) Whether or not the queried item is usable by the given career.
--#
--#     Notes:
--#         The optional parameter, onlyPassIfItemHasCareer, can be used as a filtering aid.
--#
----------------------------------------------------------------------------------------------------
function DataUtils.CareerIsAllowedForItem( career, item, onlyPassIfItemHasCareer )
    if (item == nil) then
        return false
    end
    
    return TableContainsValueOrIsEmpty (item.careers, career, onlyPassIfItemHasCareer)
end

----------------------------------------------------------------------------------------------------
--# Function: DataUtils.RaceIsAllowedForItem()
--#         Checks whether or not the given race can use the given item.  
--#
--#     Parameters:
--#         race                    - (number)      Which race you want to check for.
--#                                                 See GameDefs.lua for more details.
--#         item                    - (<ItemData>)  Which item you want to check against.  
--#
--#     Returns:
--#         isAllowed               - (boolean) Whether or not the queried item is usable by the given race.
--#
--#     Notes:
--#         At some point this function should take a onlyPassIfItemHasRace parameter.  This will
--#         aid in item filtering operations.
--#
----------------------------------------------------------------------------------------------------
function DataUtils.RaceIsAllowedForItem( race, item )
    if (item == nil) then
        return false
    end
    
    return TableContainsValueOrIsEmpty (item.races, race)
end

----------------------------------------------------------------------------------------------------
--# Function: DataUtils.SlotIsAllowedForItem()
--#         Checks whether or not the given the item can fit into the provided slot.  
--#
--#     Parameters:
--#         slot                    - (number)      Which slot you want to check for.
--#                                                 See GameDefs.lua for more details.
--#         item                    - (<ItemData>)  Which item you want to check against.  
--#
--#     Returns:
--#         isAllowed               - (boolean) Whether or not the queried item is usable by the given race.
--#
--#     Notes:
--#         At some point this function should take a onlyPassIfItemHasRace parameter.  This will
--#         aid in item filtering operations.
--#
----------------------------------------------------------------------------------------------------
function DataUtils.SlotIsAllowedForItem( slot, item )
    if (item == nil) then
        return false
    end
    
--DEBUG (L"DataUtils.SlotIsAllowedForItem slot = " ..slot);

    return TableContainsValueOrIsEmpty (item.slots, slot, false) -- false at end says an empty table is allows any slot 
end

----------------------------------------------------------------------------------------------------
--# Function: DataUtils.SkillIsEnoughForItem()
--#         Checks whether or not the given skills table contains all the skills necessary for
--#         using the item.
--#
--#     Parameters:
--#         skillTable              - (table)       Table whose keys are skill types, and whose elements
--#                                                 are booleans.  No element should be nil, only false or true.
--#                                                 See GameDefs.lua for more details.
--#         item                    - (<ItemData>)  Which item you want to check against.  
--#
--#     Returns:
--#         isAllowed               - (boolean) Whether or not the given skills are sufficient for using the item
--#
--#     Notes:
--#         This is a bit different than the Race/Career checks, because even a single missing skill will disallow use.
--#
----------------------------------------------------------------------------------------------------
function DataUtils.SkillIsEnoughForItem( skillTable, item )
    if ( (skillTable == nil) or (item == nil) or (item.skills == nil) ) then
        return false
    end
        
    for ix, reqId in ipairs (item.skills) do    
        if ((reqId ~= 0) and (skillTable[reqId] == false)) then
            return false
        end
    end
    
    return true
end

----------------------------------------------------------------------------------------------------
--# Function: DataUtils.RenownIsEnoughForItem()
--#         Checks whether or not the given renown rank is sufficient for using the item.
--#
--#     Parameters:
--#         renownRank              - (number)      Any renown rank.
--#         item                    - (<ItemData>)  Which item you want to check against.  
--#
--#     Returns:
--#         isAllowed               - (boolean) Whether or not the given renown is sufficient for using the item
--#
--#     Notes:
--#         This is a bit different than the Race/Career checks, because even a single missing skill will disallow use.
--#
----------------------------------------------------------------------------------------------------
function DataUtils.RenownIsEnoughForItem( renownRank, item )
    if ( (renownRank == nil) or (item == nil) ) then
        return false
    end
    
    if ((item.renown) > 0 and (renownRank < item.renown)) then
        return false
    else
        return true
    end
end

----------------------------------------------------------------------------------------------------
--# Function: DataUtils.LevelIsEnoughForItem()
--#         Checks whether or not the given level is sufficient for using the item.
--#
--#     Parameters:
--#         level                   - (number)      Any player level 
--#         item                    - (<ItemData>)  Which item you want to check against.  
--#
--#     Returns:
--#         isAllowed               - (boolean) Whether or not the given skills are sufficient for using the item
--#
--#     Notes:
--#         This is a bit different than the Race/Career checks, because even a single missing skill will disallow use.
--#
----------------------------------------------------------------------------------------------------
function DataUtils.LevelIsEnoughForItem( level, item )
    -- if either input is invalid, it's not allowed
    if ( (level == nil) or (item == nil) ) then
        return false
    end
    
    if ((item.level > 0) and (level < item.level)) then
        return false
    else
        return true
    end
end


----------------------------------------------------------------------------------------------------
--# Function: DataUtils.GetItemRarityColor()
--#         Convenience method to get the color table for a given rarity
--#
--#     Parameters:
--#         rarity                  - (number)  One of the elements of the SystemData.ItemRarity table:
--#                                             UTILITY, COMMON, UNCOMMON, RARE, VERY_RARE, ARTIFACT
--#
--#     Returns:
--#         color                   - (table)   { r = X, g = Y, b = Z }
--#
--#     Notes:
--#         none
--#
----------------------------------------------------------------------------------------------------
function DataUtils.GetItemRarityColor( itemData )

    if (itemData == nil or itemData.itemSet == nil or itemData.rarity == nil) then
        return GameDefs.ItemRarity[1].color

    elseif itemData.itemSet > 0 then
        return DefaultColor.RARITY_ITEM_SET

    elseif( itemData.rarity ~= 0 and GameDefs.ItemRarity[itemData.rarity] ~= nil ) then
        return GameDefs.ItemRarity[itemData.rarity].color
    end

    return GameDefs.ItemRarity[1].color
end

----------------------------------------------------------------------------------------------------
--# Function: DataUtils.GetItemTierColor()
--#         Convenience method to get the color table for a given tier
--#
--#     Parameters:
--#         itemData                - (table)  item data for the query
--#
--#     Returns:
--#         color                   - (table)   { r = X, g = Y, b = Z }
--#
--#     Notes:
--#         none
--#
----------------------------------------------------------------------------------------------------
function DataUtils.GetItemTierColor( itemData )

    if(itemData == nil or itemData.tier == nil) then
        return GameDefs.ItemRarity[2].color
    end

    -- Return rarity color for tier+2 because tier is 0-based while rarity is 1-based,
    -- and we want to align tier 0 with COMMON rarity for color purposes
    
    return GameDefs.ItemRarity[itemData.tier + 2].color
end

----------------------------------------------------------------------------------------------------
--# Function: DataUtils.GetItemTypeName()
--#         Convenience method to get the description from an item type id.
--#
--#     Parameters:
--#         typeId                  - (number)  The item type id
--#         isGreatWeapon           - (boolean) Is this item a great weapon
--#
--#     Returns:
--#         name                    - (wstring)   The item type description.
--#
--#     Notes:
--#         none
--#
----------------------------------------------------------------------------------------------------
function DataUtils.GetItemTypeName( typeId, isGreatWeapon )
    if( typeId ~= 0 and ItemTypes[typeId] ~= nil )
    then
        local name = ItemTypes[typeId].name
        if( isGreatWeapon and typeId ~= GameData.ItemTypes.STAFF )
        then
            return GetStringFormat( StringTables.Default.LABEL_ITEM_GREAT_WEAPON, { name } )
        end
        return name
    end
    return L""
end


----------------------------------------------------------------------------------------------------
--# Function: DataUtils.getItemTypeText()
--#         Works like DataUtils.GetItemTypeName, but also supplies the item's subtype
--#         if it has one, e.g. "Apothecary - Main Ingredient"
--#
--#     Parameters:
--#         itemData               - (table)  The item data
--#
--#     Returns:
--#         name                    - (wstring)   The item type text.
--#
--#     Notes:
--#         none
--#
----------------------------------------------------------------------------------------------------
function DataUtils.getItemTypeText( itemData )
        local typeText 
        if DataUtils.IsTradeSkillItem( itemData ) then
            typeText = DataUtils.GetStringForAllTradeSkills( itemData )
        else
            typeText = DataUtils.GetItemTypeName( itemData.type, itemData.isTwoHanded )
            local subtypeText = DataUtils.GetItemEquipSlotName( itemData )
            if subtypeText ~= nil and subtypeText ~= L"" then
                typeText = typeText..L" - "..subtypeText
            end
        end
    return typeText
end

----------------------------------------------------------------------------------------------------
--# Function: DataUtils.GetItemEquipSlotName()
--#         Convenience method to get the nameription from an item equipment slot id.
--#
--#     Parameters:
--#         itemData                - (table)  The item data
--#
--#     Returns:
--#         name                    - (wstring)   The item item equip nameription.
--#
--#     Notes:
--#         none
--#
----------------------------------------------------------------------------------------------------
function DataUtils.GetItemEquipSlotName( itemData )
    local equipSlotId = itemData.equipSlot
    if( itemData.isTwoHanded )
    then
        return GetString( StringTables.Default.LABEL_BOTH_HANDS )
    end
    if( ItemSlots[equipSlotId] ~= nil )
    then
        return ItemSlots[equipSlotId].name
    end
    return L""
end

----------------------------------------------------------------------------------------------------
--# Function: DataUtils.FindItem()
--#         Attempts to find an itemData table matching the given uniqueId in the character's
--#         worn, backpack, and quest inventory.
--#
--#     Parameters:
--#         uniqueId                - (number)      The uniqueId of the desired item.
--#
--#     Returns:
--#         itemData                - (table)       A table representing the item you wanted, or nil if not found
--#         itemLoc                 - (number)      Location of item (see GameData.ItemLocs)
--#         itemSlot                - (number)      Slot of item in the given location
--#
--#     Notes:
--#         None
--#
----------------------------------------------------------------------------------------------------

function DataUtils.FindItem (uniqueId)
    local function findItem (itemTable, id)
        if (itemTable == nil)
        then
            return nil
        end
        
        for itemSlot, itemData in pairs (itemTable)
        do   
            if(itemData.uniqueID == id)
            then
                return itemData, itemSlot
            end
        end        
        
        return nil, 0
    end
    
    -- If more inventory tables become available, simply add to these tables to search them.
    -- Searched linearly...
    local searchTable =
    {
        DataUtils.GetEquipmentData(),
        DataUtils.GetItems(),
        DataUtils.GetCraftingItems(),
        DataUtils.GetCurrencyItems(),
        DataUtils.GetQuestItems (),
    }
    
    local itemLocs =
    {
        GameData.ItemLocs.EQUIPPED,
        GameData.ItemLocs.INVENTORY,
        GameData.ItemLocs.CRAFTING_ITEM,
        GameData.ItemLocs.CURRENCY_ITEM,
        GameData.ItemLocs.QUEST_ITEM,
    }
    
    for tableId, itemTable in ipairs (searchTable)
    do
        local itemData, itemSlot = findItem (itemTable, uniqueId)
        
        if (itemData)
        then
            return itemData, itemLocs[tableId], itemSlot
        end
    end
    
    return nil
end

--****************************
-- ITEM DATA FOR ENHANCEMENTS

-- Check if an item has an enhancement timer
function DataUtils.ItemHasEnhancementTimer( itemData )

    if( itemData == nil )
    then
        return false
    end

    for i = 1, itemData.numEnhancementSlots
    do
        local enhSlot = itemData.enhSlot[i]
        if( enhSlot ~= nil )
        then
            for ixEnhSlotBonus, bonus in ipairs(enhSlot.bonus)
            do
                if( bonus.duration and bonus.duration > 0 )
                then
                    return true, bonus.duration
                end
            end
        end
    end

    return false
end

-- Update an item's enhancments durations
function DataUtils.UpdateEnhancementTimer( itemData, timeElapsed )
    local removeTimer = true
    itemData.durationUpdated = false
    for i = 1, itemData.numEnhancementSlots
    do
        local enhSlot = itemData.enhSlot[i]
        if( enhSlot ~= nil )
        then
            for ixEnhSlotBonus, bonus in ipairs(enhSlot.bonus)
            do
                if( bonus.duration and bonus.duration > 0 )
                then
                    local oldDuration = bonus.duration
                    bonus.duration = bonus.duration - timeElapsed
                    if( bonus.duration < 0 )
                    then
                        bonus.duration = 0
                        itemData.enhSlot[i] = nil
                    else
                        removeTimer = false
                    end
                    if( math.floor(oldDuration) > math.floor(bonus.duration) )
                    then
                        itemData.durationUpdated = true
                    end
                end
            end
        end
    end
    
    if( removeTimer )
    then
        itemData.durationUpdated = true
    end
    
    return removeTimer 
end

--****************************
-- ITEM DATA FOR TRADE SKILLS

-- NOTE: if the tradeSkill arg is nil then it will see if the item matches any tradeskill
-- 
function DataUtils.IsTradeSkillItem( itemData, tradeSkill  )

    if tradeSkill == nil then
        return( CultivationWindow.IsCultivatingItem( itemData ) or
                CraftingSystem.IsCraftingItem( itemData ) or
                itemData.type == GameData.ItemTypes.SALVAGING )

    elseif tradeSkill == GameData.TradeSkills.CULTIVATION then
        return( CultivationWindow.IsCultivatingItem( itemData ) )

    elseif tradeSkill == GameData.TradeSkills.APOTHECARY then
        return( CraftingSystem.IsCraftingItem( itemData, GameData.TradeSkills.APOTHECARY ) )

    elseif tradeSkill == GameData.TradeSkills.TALISMAN then
        return( CraftingSystem.IsCraftingItem( itemData, GameData.TradeSkills.TALISMAN ) )

    elseif tradeSkill == GameData.TradeSkills.SALVAGING then
        return( itemData.type == GameData.ItemTypes.SALVAGING )

    else
        return false

    end
end


-- If the item has more than one applicable trade skill, the player
--   just has to meet the level requirement for any one of them.
--
function DataUtils.PlayerTradeSkillLevelIsEnoughForItem( itemData )

    -- If this item isn't a tradeskill item, the player meets the requirements for using it.
    -- Similarly Salvaging (refinement) items can be used by anyone right now.
    if ( itemData.type == GameData.ItemTypes.SALVAGING or
         DataUtils.IsTradeSkillItem (itemData) == false)
    then
        return (true)
    end

    return( CultivationWindow.PlayerMeetsCultivatingRequirement( itemData ) or 
            CraftingSystem.PlayerMeetsCraftingRequirement( itemData ) )
end

-- Return all crafting and cultivation type/subtype info on the item 
-- or L"" if no crafting or dultivation data found
--
function DataUtils.GetStringForAllTradeSkills( itemData )

    local text = L""
    local tradeSkillString, resourceTypeString
    
	if CultivationWindow.IsCultivatingItem( itemData )
	then
		-- special case for cultivation items
        tradeSkillString = GetString( StringTables.Default.LABEL_SKILL_CULTIVATION )
        resourceTypeString = CultivationWindow.GetCultivationTypeName( itemData )    
        text = GetStringFormat( StringTables.Default.SYMBOL_TYPE_TO_SUBTYPE, {tradeSkillString, resourceTypeString } )
    
    elseif CraftingSystem.IsCraftingItem( itemData )
	then
		-- all other trade skill items are handled here, including salvaging
        tradeSkillString, resourceTypeString = CraftingSystem.GetCraftingDataStrings( itemData )
        text = GetStringFormat( StringTables.Default.SYMBOL_TYPE_TO_SUBTYPE, {tradeSkillString, resourceTypeString } )
    end
    
    return text
end


-- Return all crafting and cultivation types with requirement level for the item 
-- or L"" if no crafting or dultivation data found
--
function DataUtils.GetStringForTradeSkillsLevel( itemData )

    local text = L""
    
    if CraftingSystem.IsCraftingItem( itemData ) then
        local craftingTypesString = CraftingSystem.GetCraftingDataStrings( itemData )
        text = text..craftingTypesString
    end
    
    if CultivationWindow.IsCultivatingItem( itemData ) then
        
        if text ~= L"" then
            text = text..GetString( StringTables.Default.SYMBOL_LIST_SEPARATOR )
        end
        
        text = text..GetString( StringTables.Default.LABEL_SKILL_CULTIVATION )
    end
    
    -- ASSUMPTION: Currently the level is specific to the item, not specific to any particular skill
    if itemData.craftingSkillRequirement and itemData.craftingSkillRequirement > 0 then
        text = text..L" "..itemData.craftingSkillRequirement
    end
    
    return text
end


------------------------------------------------------------------------------------------
-- BONUS STRINGS
------------------------------------------------------------------------------------------

-- Looks up the appropriate mastery path name for the careers
-- If your character's career is in the list, your career's mastery path name is returned
-- If only one career is in the list, that career's mastery path name is returned
-- Otherwise a generic "Bonus to Mastery 1 Abilities" is returned
function DataUtils.GetStatSpecBonusName( bonusType, careers )
    if ( TableContainsValueOrIsEmpty( careers, GameData.Player.career.line ) )
    then
        return BonusTypes[bonusType].name
    end
    
    local specLine = bonusType - GameData.BonusTypes.EBONUS_SPEC_1
    
    if ( #careers == 1 )
    then
        local NUM_SPECIALIZATION_PATHS = 3
        local specPath = NUM_SPECIALIZATION_PATHS * ( careers[1] - 1 ) + specLine + 1
        return GetStringFormat( StringTables.Default.LABEL_BONUS_SPEC_X, { GetSpecializationPathName( specPath ) } )
    end
    
    return GetString( StringTables.Default.LABEL_BONUS_SPEC_1 + specLine )
end

--[[
    The following are utility strings for correctly formatting strings for bonuses.
--]]
function DataUtils.GetStatBonusString( bonusType, value, isPercentageValue, careers )		

    if bonusType == nil or BonusTypes[bonusType] == nil
	then
		return L""
	end
    
    local bonusName
    -- The mastery path bonus lines are always given for the player's class. If this item is not for the player's class, we may need to manually look up the current spec line.
    if ( ( bonusType == GameData.BonusTypes.EBONUS_SPEC_1 ) or ( bonusType == GameData.BonusTypes.EBONUS_SPEC_2 ) or ( bonusType == GameData.BonusTypes.EBONUS_SPEC_3 ) )
    then
        bonusName = DataUtils.GetStatSpecBonusName( bonusType, careers )
    else
        bonusName = BonusTypes[bonusType].name
    end
	
	local formatStringIndex
	
	-- Handle special cases where the bonus has to be modified in some way.
	-- (e.g. health regen, auto attack haste, range)
	if( BonusTypes[bonusType].multiplier )
	then
		value = value * BonusTypes[bonusType].multiplier
	end
		
    if BonusTypes[bonusType].format ~= nil then
		-- NOTE: we don't have any special formatted bonuses that are negative for now,
		--   but may need to handle that in future
		formatStringIndex = BonusTypes[bonusType].format

	elseif value > 0
    then
        if( not isPercentageValue )
        then
            formatStringIndex = StringTables.Default.LABEL_BONUS_PREFIX_POSITIVE
        else
            formatStringIndex = StringTables.Default.LABEL_BONUS_PREFIX_POSITIVE_PERCENT
        end

	elseif value < 0
    then
		-- The string already shows that it's a negative value so remove the minus sign from the value
		value = -value        
        if( not isPercentageValue )
        then
            formatStringIndex = StringTables.Default.LABEL_BONUS_PREFIX_NEGATIVE
        else
            formatStringIndex = StringTables.Default.LABEL_BONUS_PREFIX_NEGATIVE_PERCENT
        end	
	else
		-- Special case only takes one parameter so do lookup and return here
		return GetStringFormat( StringTables.Default.LABEL_ITEM_ENHANCES, { bonusName } )
    end

    return GetStringFormat( formatStringIndex, { value, bonusName } )
end											

function DataUtils.GetBonusContributionString( value )	
	
	if value > 0  then
		return GetStringFormat( StringTables.Default.LABEL_BONUS_CONTRIBUTION_POSITIVE, { value } )
    
    elseif value < 0 then
		-- The string already shows that it's a negative value so remove the minus sign from the value
		return GetStringFormat( StringTables.Default.LABEL_BONUS_CONTRIBUTION_NEGATIVE, { -value } )
    
    else
		return L""
    end

end


------------------------------------------------------------------------------------------
-- ITEM SET DATA 
------------------------------------------------------------------------------------------

--[[
    Here's what an item set table looks like in Lua (not in C...Lua massages each C update
    of the item sets for better performance.)
    
    The name->index and index->name associative arrays should probably change...unless there
    is no good way around the data duplication...
    
    ItemSetData = 
    {
        id          = 1 to 64K for valid sets
        name        = Wide String Item Set Name
        castingLevel  = If nonzero, use this item level when casting abilities instead of the actual item levels
        numPieces   = 1 to GameDefs.MAX_ITEMS_IN_SET for valid sets
        
        ntoi[Wide String Name] =
        {
            Index of the item within the set
        }
        
        iton[Piece Index] =
        {
            Wide String Name
        }
        
        bonuses[Index: Number of pieces to get this bonus] = <- Can be nil if there is no bonus for X numPieces.
        {
            rankType        = Type of the bonus (NOT in lua yet...)
            statType        = If (rankType == MAGIC) this can be looked up in *Tooltips.BonusTypes
            statValue       = If (rankType == MAGIC) this is the value of the bonus from *Tooltips.BonusTypes
                              If (rankType == CONTINUOUS) this can be looked up as an ability id 
        }
    }
        
--]]

--[[
    Cached item set data...this data is PER-SESSION
    it will not persist across runs of the game until we 
    come up with a way for cacheing Lua data, it will also be lost on
    a reload of the ui. But it's not so bad, since the client will hold
    the values and only request new values from the server when new item
    sets are encountered.
    
    Some CRC stuff would be nice for validating this data against
    the server's idea of what each item set really looks like...
--]]
local ItemSetData = {}

--[[
    Gets a cached item set if it exists, otherwise returns
    nil and requests item set data from the client.
    
    For functions using GetItemSetData...it's OK to get
    nil back, just register your mod for the 
    SystemData.
--]]
function DataUtils.GetItemSetData (itemSetId)
    if (itemSetId ~= nil) then
        
        -- DEBUG (L"Attempting to get item set: "..itemSetId);
        
        if (ItemSetData[itemSetId] ~= nil) then
            -- TODO: Here's where the check would go to see
            -- if the hash of this item set matches the server's...
            
            return ItemSetData[itemSetId];
        end
        
        -- Otherwise, we need to request this from the client...
        RequestItemSet (itemSetId);
    end
    
    return nil;
end

--[[ 
    Handles new item sets arriving from the server or updates from the client
    when the value is lost in lua.
    Called in response to: SystemData.Events.ITEM_SET_DATA_ARRIVED
--]]
function DataUtils.UpdateItemSets ()
    if (GameData.UpdatedItemSet.id ~= 0) then
        ItemSetData[GameData.UpdatedItemSet.id] = {};
        
        local newSet = ItemSetData[GameData.UpdatedItemSet.id];
        
        newSet.id           = GameData.UpdatedItemSet.id;
        newSet.name         = GameData.UpdatedItemSet.name;
        newSet.castingLevel = GameData.UpdatedItemSet.castingLevel;
        newSet.numPieces    = 0;
        
        newSet.ntoi = {};
        newSet.iton = {};
        
        -- This means that only item names will be checked to determine which
        -- pieces of the set the player has.  That's probably ok for now...
        -- Setting the table key as the item name so it's easier to quickly determine
        -- which item indices the player has.
        for ixName = 1, GameDefs.MAX_ITEMS_IN_SET do
            local pieceName = GameData.UpdatedItemSet.itemNames[ixName];
            if (pieceName and pieceName ~= L"") then
                newSet.iton[ixName]     = pieceName;
                newSet.ntoi[pieceName]  = ixName;
                
                newSet.numPieces = newSet.numPieces + 1;
            end
        end
        
        newSet.bonuses = {};
                
        for ixRank = 1, GameDefs.MAX_ITEM_SET_RANKS do
            local numPieces = GameData.UpdatedItemSet.bonuses[ixRank].piecesRequired;
        
            if (numPieces > 0) then
            
                newSet.bonuses[numPieces] = 
                {
                    rankType    = GameData.UpdatedItemSet.bonuses[ixRank].rankType,
                    statType    = GameData.UpdatedItemSet.bonuses[ixRank].statType,
                    statValue   = GameData.UpdatedItemSet.bonuses[ixRank].statValue,
					isPercentage   = GameData.UpdatedItemSet.bonuses[ixRank].isPercentage
                };                
            end
        end
        
        BroadcastEvent (SystemData.Events.ITEM_SET_DATA_UPDATED);
    end
end

--[[
    For a given item set (as previously looked up/retrieved from the server):

    Return 1: a list of booleans with the indices of the list corresponding
    to item names in the set, the entry at each index is true if the player
    owns that piece of the set.
    
    Return 2: the number of pieces in the set that the player owns, this is only
    a convenience, since this number can be determined from looking at 
    the list of pieces the player has.
       
    This function currently only examines the PLAYER'S equipped items...so it will
    not work for seeing other player's set bonuses...but we don't have player
    inspection yet, so that's ok for now.    
--]]
function DataUtils.GetPlayerOwnedSetPieces (itemSet)
    local playerOwnedItems  = {};
    local numPiecesOwned    = 0;
    
    local equipment = DataUtils.GetEquipmentData()
    for equipSlot, itemData in pairs( equipment )
    do
        local pieceIndex = itemSet.ntoi[itemData.name];
        if (pieceIndex and pieceIndex > 0) 
        then
            playerOwnedItems[pieceIndex] = true;
            numPiecesOwned = numPiecesOwned + 1;
        end
    end
    
    return playerOwnedItems, numPiecesOwned;
end

--[[
    Convenience method that returns the descriptions of all the set
    bonuses.  If the numPiecesOwned argument is non-nil then whether
    or not the particular bonus is unlocked is also returned.
    
    There can be up to DataUtils.MAX_ITEM_SET_RANKS so make sure to iterate
    over the entire returned array...maybe someday I'll return a max ranks...
    One fact is that the bonuses will be packed into the array sequentially,
    so, on reaching the first nil entry, you can stop iterating.
    
    Return table format: 
        bonuses[bonusIndex] =
        {
            desc        = "(<Pieces>): Player can eat monsters for breakfast"
            unlocked    = true/false
        }
    
    
--]]

local c_LABEL_PIECE_BONUS = GetString (StringTables.Default.LABEL_SET_PIECE_BONUS_SUFFIX);
local c_UNITS_PER_FEET = 12

function DataUtils.GetSetBonuses (itemSet, numPiecesOwned, itemLevel, careers)
    local bonusTable    = {};
    local curDesc       = L"";
    local curUnlocked   = false;
    local curBonus      = 1;
    
    -- Override item level with item set casting level if set
    if ( itemSet.castingLevel > 0 )
    then
        itemLevel = itemSet.castingLevel
    end
    
    for ixPiece = 1, GameDefs.MAX_ITEMS_IN_SET 
    do
        if (itemSet.bonuses[ixPiece] ~= nil) 
        then
            curUnlocked = false;
            if (numPiecesOwned and numPiecesOwned >= ixPiece) 
            then
                curUnlocked = true;
            end
            
            curDesc = L"("..ixPiece..L" "..c_LABEL_PIECE_BONUS..L"): ";
            
            if (GameDefs.ITEMBONUS_MAGIC == itemSet.bonuses[ixPiece].rankType) 
            then
                local bonusType = itemSet.bonuses[ixPiece].statType;
            
                if (BonusTypes[bonusType] ~= nil) 
                then
					local isPercentage = itemSet.bonuses[ixPiece].isPercentage
					local statValue = itemSet.bonuses[ixPiece].statValue

                    curDesc = curDesc..DataUtils.GetStatBonusString( bonusType, statValue, isPercentage, careers );
                end
            elseif (GameDefs.ITEMBONUS_CONTINUOUS == itemSet.bonuses[ixPiece].rankType) 
            then
                curDesc = curDesc..GetAbilityDesc (itemSet.bonuses[ixPiece].statValue, itemLevel);				
            end
            
            bonusTable[curBonus] = { desc = curDesc, unlocked = curUnlocked };
            curBonus = curBonus + 1;
        end
    end
    
    return bonusTable;
end

------------------------------------------------------------------------------------------
-- INFLUENCE DATA 
------------------------------------------------------------------------------------------
function DataUtils.GetInfluenceData( influenceId )
    local influenceDataTable = DataUtils.GetAllInfluenceData()
    
    if ( influenceDataTable == nil ) or ( influenceId == nil )
    then
        return nil
    end
    
    return influenceDataTable[influenceId]
end

function DataUtils.GetAllInfluenceData()
    if( GameData.Player.influenceDataDirty )
    then
        DataUtilsData.influenceData = GetInfluenceData()
        GameData.Player.influenceDataDirty = false
    end
    return DataUtilsData.influenceData
end

function DataUtils.UpdateInfluenceBar( barName, influenceId )

    local influenceData = DataUtils.GetInfluenceData( influenceId )
    if( influenceData == nil )
    then
        return false
    end

    -- We want to show each 1/3 of the status bar as the status for each reward level.. but each
    -- level has a different reward amount. So, compute the percents and add them.
    local statusBarPercent = 0  
    local lastLevelInf = 0 

    -- TODO: Fix this so that is does not have a dependency on the tome window here
    for level = 1, TomeWindow.NUM_REWARD_LEVELS
    do
        local levelPercent = ( influenceData.curValue - lastLevelInf ) / ( influenceData.rewardLevel[level].amountNeeded - lastLevelInf )
        if( levelPercent > 1.0 )
        then
            statusBarPercent = statusBarPercent + ( 1.0 / TomeWindow.NUM_REWARD_LEVELS )
        elseif( levelPercent > 0 )
        then
            statusBarPercent = statusBarPercent + ( 1.0 / TomeWindow.NUM_REWARD_LEVELS )*levelPercent
        end
                
        lastLevelInf = influenceData.rewardLevel[level].amountNeeded
        
        local rewardWindow = barName.."Reward"..level
        
        if (DoesWindowExist(rewardWindow))
        then
            if (levelPercent >= 1.0)
            then
                if (not influenceData.rewardLevel[level].rewardsRecieved)
                then
                    DynamicImageSetTextureSlice(rewardWindow, "Influence-Reward-Achieved")
                else
                    DynamicImageSetTextureSlice(rewardWindow, "Influence-Reward")
                end
            else
                DynamicImageSetTextureSlice(rewardWindow, "Influence-Reward")
            end
        end
    end     

    StatusBarSetMaximumValue( barName, 1.0 )
    StatusBarSetCurrentValue( barName, statusBarPercent )
    --DEBUG(L" Influance Bar ["..StringToWString(barName)..L"] = "..statusBarPercent..L" curValue = "..influenceData.curValue )
    return true
end

------------------------------------------------------------------------------------------
-- QUEST DATA 
------------------------------------------------------------------------------------------

function DataUtils.GetQuestData( questId )

    local tempQuests = DataUtils.GetQuests()
    for index, questData in ipairs( tempQuests ) do 
        if( questData.id == questId  ) then
            return questData
        end             
    end
    
    return nil
end


function DataUtils.GetQuestDataFromName( questName )
    
    local tempQuests = DataUtils.GetQuests()
    for index, questData in ipairs( tempQuests ) do 
        if( questData.name == questName  ) then
            return tempQuests[index]  
        end             
    end
    
    return nil
end

function DataUtils.IsQuestComplete( questName ) 

    local tempQuests = DataUtils.GetQuests()
    for index, questData in ipairs( tempQuests ) do
        if( questData.name == questName  ) then
            return questData.complete       
        end               
    end
    
    return false
end


function DataUtils.DoesPlayerHaveQuest( questId )

    local tempQuests = DataUtils.GetQuests()
    for index, questData in ipairs( tempQuests ) do 
        if( questData.id == questId  ) then
            return true
        end             
    end
    
    return false
end

--***
--
--***

function DataUtils.GetRealmColor( realm )
    --DEBUG(L"DataUtils.GetRealmColor("..realm..L")")
    if( GameDefs.RealmColors[realm] ~= nil ) then
        return GameDefs.RealmColors[realm]
    end
    return GameDefs.RealmColors[0]
end

function DataUtils.GetAlternatingRowColor( row_mod_by_two )
    -- Pass the math.mod result of the row number divided by 2
    if( GameDefs.RowColors[row_mod_by_two] ~= nil ) then
        return GameDefs.RowColors[row_mod_by_two]
    end
    return GameDefs.RowColors[0]
end

function DataUtils.GetAlternatingRowColorGreyOnGrey( row_mod_by_two )
    -- Pass the math.mod result of the row number divided by 2
    if( GameDefs.RowColorsGreyOnGrey[row_mod_by_two] ~= nil ) then
        return GameDefs.RowColorsGreyOnGrey[row_mod_by_two]
    end
    return GameDefs.RowColorsGreyOnGrey[0]
end

--
-- to use this, the Row definition for the ListBox must have a background window named "$parentBackground"
--
function DataUtils.SetListRowAlternatingTints( listBoxName, numVisibleRows )

    for row = 1, numVisibleRows do
            
        local row_mod = math.mod(row, 2)
        local color = DataUtils.GetAlternatingRowColor( row_mod )
        local rowBackground = listBoxName.."Row"..row.."Background"
        
        WindowSetTintColor( rowBackground, color.r, color.g, color.b )
        WindowSetAlpha( rowBackground, color.a )
    end
    
end



------------------------------------------------------------------------------------------
-- TARGET DATA 
------------------------------------------------------------------------------------------
function DataUtils.GetTargetConColor( conType )
    if( conType ~= nil and GameDefs.CON_COLORS[conType] ~= nil ) then
         return GameDefs.CON_COLORS[conType]
    end    
    return GameDefs.CON_COLORS[GameData.ConType.NO_LEVEL]
end

function DataUtils.GetTargetConDesc( conType )
    if( conType ~= nil and GameDefs.CON_DESCS[conType] ~= nil ) then
         return GameDefs.CON_DESCS[conType]
    end    
    return GameDefs.CON_DESCS[GameData.ConType.NO_LEVEL]
end

function DataUtils.GetTargetTierDesc( tier )
    if( tier ~= nil and GameDefs.TIER_NAMES[tier] ~= nil ) then
         return GameDefs.TIER_NAMES[tier]
    end    
    return GameDefs.TIER_NAMES[0]
end

------------------------------------------------------------------------------------------
-- TOME DATA
------------------------------------------------------------------------------------------
function DataUtils.GetTomeSectionIcon( section, useLarge )
    
    if( GameDefs.TomeSectionIcons[section] ~= nil ) then
        if( useLarge )
        then
            return GameDefs.TomeSectionIcons[section].large
        else
            return GameDefs.TomeSectionIcons[section].small
        end
    end
    
    ERROR( L"Invalid Param to DataUtils.GetTomeSectionIcon( section ), "..section..L" is an invalid section" )
    return ""
end

function DataUtils.GetTomeSectionName( section )
    
    if( GameDefs.TomeSectionNames[ section] ~= nil ) then
        return GameDefs.TomeSectionNames[section]
    end
    
    ERROR( L"Invalid Param to DataUtils.GetTomeSectionName( section ), "..section..L" is an invalid section" )
    return L""
end

------------------------------------------------------------------------------------------
-- Getting wrapper functions that 
------------------------------------------------------------------------------------------
function DataUtils.GetTomeAlerts()
    if( GameData.Player.tomeAlertsDirty ) then
        DataUtilsData.tomeAlerts = GetTomeAlertsData()
        GameData.Player.tomeAlertsDirty = false
    end
    return DataUtilsData.tomeAlerts
end

function DataUtils.GetMacros()
    if( GameData.Macros.macrosDirty ) then
        GameData.Macros.macrosDirty = false
        DataUtilsData.macros = GetMacrosData()
    end
    return DataUtilsData.macros
end

function DataUtils.GetQuests()
    if( GameData.Player.questsDirty ) then
        GameData.Player.questsDirty = false
        DataUtilsData.quests = GetQuestData()
    end
    return DataUtilsData.quests
end

function DataUtils.GetItems()
    if (GameData.Player.itemsDirty)
    then
        GameData.Player.itemsDirty = false
        DataUtilsData.items = GetInventoryItemData()
    end
    
    return DataUtilsData.items
end

function DataUtils.GetCraftingItems()
    if (GameData.Player.craftingItemsDirty)
    then
        GameData.Player.itemsDirty = false
        DataUtilsData.craftingItems = GetCraftingItemData()
    end
    
    return DataUtilsData.craftingItems
end

function DataUtils.GetCurrencyItems()
    if (GameData.Player.currencyItemsDirty)
    then
        GameData.Player.currencyItemsDirty = false
        DataUtilsData.currencyItems = GetCurrencyItemData()
    end
    
    return DataUtilsData.currencyItems
end

function DataUtils.GetQuestItems()
    if (GameData.Player.questItemsDirty)
    then
        GameData.Player.questItemsDirty = false
        DataUtilsData.questItems = GetQuestItemData()
    end
    
    return DataUtilsData.questItems
end

function DataUtils.GetEquipmentData ()
    if (GameData.Player.equippedItemsDirty)
    then
        GameData.Player.equippedItemsDirty = false
        DataUtilsData.equippedItems = GetEquipmentData()
    end
    
    return DataUtilsData.equippedItems
end

function DataUtils.GetTrophyData ()
    if (GameData.Player.trophyItemsDirty)
    then
        GameData.Player.trophyItemsDirty = false
        DataUtilsData.trophyItems = GetTrophyData()
    end
    
    return DataUtilsData.trophyItems
end

function DataUtils.GetBankData ()
    if (GameData.Player.bankItemsDirty)
    then
        GameData.Player.bankItemsDirty = false
        DataUtilsData.bankItems= GetBankData()
    end
    
    return DataUtilsData.bankItems
end


function DataUtils.GetItemData( source, slot )

    if source == GameData.ItemLocs.EQUIPPED then

        if slot < GameData.Player.c_TROPHY_START_INDEX then
            return DataUtils.GetEquipmentData()[slot]
        else
            local trophySlot = slot - GameData.Player.c_TROPHY_START_INDEX + 1  
            return DataUtils.GetTrophyData()[trophySlot]
        end
        
    elseif source == GameData.ItemLocs.INVENTORY then
        return DataUtils.GetItems()[slot]
        
    elseif source == GameData.ItemLocs.CRAFTING_ITEM then
        return DataUtils.GetCraftingItems()[slot]
    
    elseif source == GameData.ItemLocs.CURRENCY_ITEM then
        return DataUtils.GetCurrencyItems()[slot]        
    
    elseif source == GameData.ItemLocs.INVENTORY_OVERFLOW then
        return GetOverflowData()   -- only returns the topmost overflow itemData
        
    elseif source == GameData.ItemLocs.QUEST_ITEM then
        return DataUtils.GetQuestItems()[slot]
        
    elseif source == GameData.ItemLocs.BANK  then
        return DataUtils.GetBankData()[slot]
    
    end

    return nil
end

-- This table represents the valid slots for icon customization
local validSlots = {
                    [GameData.EquipSlots.RIGHT_HAND] = true,
                    [GameData.EquipSlots.LEFT_HAND] = true,
                    [GameData.EquipSlots.RANGED] = true,
                    [GameData.EquipSlots.EITHER_HAND] = true,
                    [GameData.EquipSlots.BODY] = true,
                    [GameData.EquipSlots.GLOVES] = true,
                    [GameData.EquipSlots.BOOTS] = true,
                    [GameData.EquipSlots.HELM] = true,
                    [GameData.EquipSlots.SHOULDERS] = true,
                    [GameData.EquipSlots.BACK] = true,
                    [GameData.EquipSlots.BELT] = true
                   }

function DataUtils.IsItemAppearanceCustomizable( slot, itemData )
    return itemData
           and itemData.uniqueID ~= 0
           and (itemData.boundToPlayer
           or itemData.flags[GameData.Item.EITEMFLAG_BIND_ON_PICKUP]
           or itemData.flags[GameData.Item.EITEMFLAG_BIND_ON_EQUIP])
           and validSlots[slot]
end

function DataUtils.IsItemSlotCustomizable( slot )
    return validSlots[slot]
end

-- TODO: we may want to make this validation stronger in the future
--
function DataUtils.IsValidItem( itemData )
    return ( itemData ~= nil and itemData.uniqueID ~= 0 )
end


--****************************************************************************************
-- ABILITY DATA 
--****************************************************************************************

-- The order in this table matters.  The first matching type is returned in cases
-- where abilities are offensive + defensive + buffs + debuff + heals...because
-- for whatever reason, we will have crazy abilities that embody all of those types!
local AbilityTypeStringCache =
{
    ["isHealing"]       = GetString (StringTables.Default.LABEL_FILTER_HEALING),
    ["isDebuff"]        = GetString (StringTables.Default.LABEL_ABILITY_TYPE_DEBUFF),    
    ["isBuff"]          = GetString (StringTables.Default.LABEL_ABILITY_TYPE_BUFF),
    ["isDefensive"]     = GetString (StringTables.Default.LABEL_FILTER_DEFENSE),
    ["isOffensive"]     = GetString (StringTables.Default.LABEL_FILTER_OFFENSE),
    ["isDamaging"]      = GetString (StringTables.Default.LABEL_FILTER_DAMAGE),
    ["isStatsBuff"]     = GetString (StringTables.Default.LABEL_FILTER_STATS_BUFF),
    ["isHex"]           = GetString (StringTables.Default.LABEL_ABILITY_TYPE_HEX),
    ["isCurse"]         = GetString (StringTables.Default.LABEL_ABILITY_TYPE_CURSE),
    ["isCripple"]       = GetString (StringTables.Default.LABEL_ABILITY_TYPE_CRIPPLE),        
    ["isAilment"]       = GetString (StringTables.Default.LABEL_ABILITY_TYPE_AILMENT),
    ["isBolster"]       = GetString (StringTables.Default.LABEL_ABILITY_TYPE_BOLSTER),
    ["isAugmentation"]  = GetString (StringTables.Default.LABEL_ABILITY_TYPE_AUGMENTATION),
    ["isBlessing"]      = GetString (StringTables.Default.LABEL_ABILITY_TYPE_BLESSING),
    ["isEnchantment"]   = GetString (StringTables.Default.LABEL_ABILITY_TYPE_ENCHANTMENT),
}

function DataUtils.GetAbilityTypeText (abilityData)
-- This uses a priority system, even though an ability might be both damaging and healing,
-- this will only return the highest priority type.  This is intended for the type on the 
-- ability tooltip, buff tracker, and abilities window.
-- Damaging is the highest priority of all...
-- Defensive/Offensive: This is apparently the fallback string which is intended for tactics.
-- It should almost never be used, but it's set on every ability...    

    if      (abilityData.isCripple)         then return AbilityTypeStringCache["isCripple"]
    elseif  (abilityData.isHex)             then return AbilityTypeStringCache["isHex"]	
    elseif  (abilityData.isCurse)           then return AbilityTypeStringCache["isCurse"]
    elseif  (abilityData.isAilment)         then return AbilityTypeStringCache["isAilment"]
    elseif  (abilityData.isBolster)         then return AbilityTypeStringCache["isBolster"]
    elseif  (abilityData.isAugmentation)    then return AbilityTypeStringCache["isAugmentation"]
    elseif  (abilityData.isBlessing)        then return AbilityTypeStringCache["isBlessing"]
    elseif  (abilityData.isEnchantment)     then return AbilityTypeStringCache["isEnchantment"]    
    elseif  (abilityData.isDamaging)        then return AbilityTypeStringCache["isDamaging"]
    elseif  (abilityData.isHealing)         then return AbilityTypeStringCache["isHealing"]
    elseif  (abilityData.isDebuff)          then return AbilityTypeStringCache["isDebuff"]
    elseif  (abilityData.isBuff)            then return AbilityTypeStringCache["isBuff"]
    elseif  (abilityData.isStatsBuff)       then return AbilityTypeStringCache["isStatsBuff"]
    elseif  (abilityData.isOffensive)       then return AbilityTypeStringCache["isOffensive"]
    elseif  (abilityData.isDefensive)       then return AbilityTypeStringCache["isDefensive"]
    end
    
    return L""
end

function DataUtils.GetAbilitySpecLine (abilityData)
    if (abilityData and (abilityData.specialization > 0) and (abilityData.specialization <= 3))
    then
        -- TODO: Consider adding GetSpecializationPathName which takes 1, 2, or 3 as a parameter
        -- and indexes into a table to avoid this lookup that will need to be repeated...
        local specLookupTable =
        {
            [1] = GameData.Player.SPECIALIZATION_PATH_1,
            [2] = GameData.Player.SPECIALIZATION_PATH_2,
            [3] = GameData.Player.SPECIALIZATION_PATH_3,
        }
        
        -- The GameData.Player.X is always the short name...this method of translating a short name to
        -- a "Path of X" should also be considered for moving into StringUtils.lua.
        local specFormatTable = 
        { 
            GetSpecializationPathName (specLookupTable[abilityData.specialization]) 
        }
        
        return GetStringFormat (StringTables.Default.LABEL_SPECIALIZATION_PATH, specFormatTable)
    end

    return (GetString (StringTables.Default.LABEL_ABILITY_TOOLTIP_NO_SPECIALIZATION_PATH))
end

-- If the texture names are changed, the strings returned here will also need to be changed.
local BuffFrameTexData =
{
    ["Debuff-Frame"]    = { w = 64, h = 88 },
    ["Buff-Frame"]      = { w = 64, h = 88 },
    ["Neutral-Frame"]   = { w = 64, h = 64 },
}

function DataUtils.GetAbilityTypeTextureAndColor(abilityData)
    local t = BuffFrameTexData
    
    if      (abilityData.isHex)            then local k = "Debuff-Frame";   return k, t[k].w, t[k].h, abilityData.typeColorRed, abilityData.typeColorGreen, abilityData.typeColorBlue
    elseif  (abilityData.isCurse)          then local k = "Debuff-Frame";   return k, t[k].w, t[k].h, abilityData.typeColorRed, abilityData.typeColorGreen, abilityData.typeColorBlue
    elseif  (abilityData.isCripple)        then local k = "Debuff-Frame";   return k, t[k].w, t[k].h, abilityData.typeColorRed, abilityData.typeColorGreen, abilityData.typeColorBlue
    elseif  (abilityData.isAilment)        then local k = "Debuff-Frame";   return k, t[k].w, t[k].h, abilityData.typeColorRed, abilityData.typeColorGreen, abilityData.typeColorBlue
    elseif  (abilityData.isBolster)        then local k = "Buff-Frame";     return k, t[k].w, t[k].h, abilityData.typeColorRed, abilityData.typeColorGreen, abilityData.typeColorBlue
    elseif  (abilityData.isAugmentation)   then local k = "Buff-Frame";     return k, t[k].w, t[k].h, abilityData.typeColorRed, abilityData.typeColorGreen, abilityData.typeColorBlue
    elseif  (abilityData.isBlessing)       then local k = "Buff-Frame";     return k, t[k].w, t[k].h, abilityData.typeColorRed, abilityData.typeColorGreen, abilityData.typeColorBlue
    elseif  (abilityData.isEnchantment)    then local k = "Buff-Frame";     return k, t[k].w, t[k].h, abilityData.typeColorRed, abilityData.typeColorGreen, abilityData.typeColorBlue
    elseif  (abilityData.isDamaging)       then local k = "Debuff-Frame";   return k, t[k].w, t[k].h, DefaultColor.AbilityType.DAMAGING.r,  DefaultColor.AbilityType.DAMAGING.g,  DefaultColor.AbilityType.DAMAGING.b 
    elseif  (abilityData.isHealing)        then local k = "Buff-Frame";     return k, t[k].w, t[k].h, DefaultColor.AbilityType.HEALING.r,   DefaultColor.AbilityType.HEALING.g,   DefaultColor.AbilityType.HEALING.b
    elseif  (abilityData.isDebuff)         then local k = "Debuff-Frame";   return k, t[k].w, t[k].h, DefaultColor.AbilityType.DEBUFF.r,    DefaultColor.AbilityType.DEBUFF.g,    DefaultColor.AbilityType.DEBUFF.b
    elseif  (abilityData.isBuff)           then local k = "Buff-Frame";     return k, t[k].w, t[k].h, DefaultColor.AbilityType.BUFF.r,      DefaultColor.AbilityType.BUFF.g,      DefaultColor.AbilityType.BUFF.b
    elseif  (abilityData.isStatsBuff)      then local k = "Buff-Frame";     return k, t[k].w, t[k].h, DefaultColor.AbilityType.BUFF.r,      DefaultColor.AbilityType.BUFF.g,      DefaultColor.AbilityType.BUFF.b
    elseif  (abilityData.isOffensive)      then local k = "Buff-Frame";     return k, t[k].w, t[k].h, DefaultColor.AbilityType.OFFENSIVE.r, DefaultColor.AbilityType.OFFENSIVE.g, DefaultColor.AbilityType.OFFENSIVE.b
    elseif  (abilityData.isDefensive)      then local k = "Buff-Frame";     return k, t[k].w, t[k].h, DefaultColor.AbilityType.OFFENSIVE.r, DefaultColor.AbilityType.OFFENSIVE.g, DefaultColor.AbilityType.OFFENSIVE.b
    end
    
    local k = "Neutral-Frame"
    return k, t[k].w, t[k].h, DefaultColor.WHITE.r, DefaultColor.WHITE.g, DefaultColor.WHITE.b
end

-- Finds all summoning stones in the inventory that will work for the specified playerLevel
-- and returns the inventory slot of the summoning stone with the lowest item level
function DataUtils.HasRequiredSummoningStone( playerLevel )
	if( not playerLevel )
	then
		ERROR(L"Invalid call to DataUtils.HasRequiredSummoningStone( playerLevel ), playerLevel is nil")
		return nil
	end
	
    local singleSummonSlot = nil
	local lowestItemLevel = 255
    local inventory = DataUtils.GetItems()
    for i, itemData in pairs( inventory )
    do
        if( itemData.type == GameData.ItemTypes.TELEPORT )
        then
			if( itemData.iLevel >= playerLevel and itemData.iLevel < lowestItemLevel )
			then
				singleSummonSlot = i
				lowestItemLevel = itemData.iLevel
			end
        end
    end   
    
    return singleSummonSlot
end

-- Finds all treasure keys in the inventory that will work for the specified tier
-- and returns the inventory slot of the treasure key with the lowest tier
function DataUtils.HasRequiredTreasureKey( requiredTier )
	if( not requiredTier )
	then
		ERROR(L"Invalid call to DataUtils.HasRequiredTreasureKey( requiredTier ), requiredTier is nil")
		return nil
	end
	
    local keySlot = nil
	local lowestKeyTier = 255
    local inventory = DataUtils.GetItems()
    for i, itemData in pairs( inventory )
    do
        if( itemData.type == GameData.ItemTypes.TREASURE_KEY )
        then
			if( itemData.tier >= requiredTier and itemData.tier < lowestKeyTier )
			then
				keySlot = i
				lowestKeyTier = itemData.tier
			end
        end
    end   
    
    return keySlot
end

function DataUtils.GetPQTimerRemaining( timerState, timerValue )
    if ( timerState == GameData.PQTimerState.RUNNING )
    then
        -- In this case, timerValue is the game time at which the timer expires
        local timeLeft = timerValue - GetGameTime()
        if ( timeLeft >= 0 )
        then
            return timeLeft
        else
            return 0
        end
    elseif ( timerState == GameData.PQTimerState.FROZEN )
    then
        -- In this case, timerValue is the actual time remaining in seconds
        return timerValue
    else
        return nil
    end
end

function DataUtils.bxor(a,b)
    local p,c=1,0
    while a>0 and b>0 do
        local ra,rb=a%2,b%2
        if ra~=rb then c=c+p end
        a,b,p=(a-ra)/2,(b-rb)/2,p*2
    end
    if a<b then a=b end
    while a>0 do
        local ra=a%2
        if ra>0 then c=c+p end
        a,p=(a-ra)/2,p*2
    end
    return c
end

function DataUtils.band(a,b)
    local p,c=1,0
    while a>0 and b>0 do
        local ra,rb=a%2,b%2
        if ra+rb>1 then c=c+p end
        a,b,p=(a-ra)/2,(b-rb)/2,p*2
    end
    return c
end

function DataUtils.shl(x, by)
  return x * 2 ^ by
end

function DataUtils.shr(x, by)
  return math.floor(x / 2 ^ by)
end