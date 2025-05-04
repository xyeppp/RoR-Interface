
CraftingSystem = {}
CraftingSystem.versionNumber = 0.1

CraftingSystem.craftingData = {}
CraftingSystem.maxResources = 4
    
-- List of crafting skills
CraftingSystem.SKILL_UNKNOWN    = 0
CraftingSystem.SKILL_APOTHECARY = GameData.TradeSkills.APOTHECARY
CraftingSystem.SKILL_TALISMAN   = GameData.TradeSkills.TALISMAN

CraftingSystem.craftingWindows =
{
    [CraftingSystem.SKILL_UNKNOWN]      = {},
    [CraftingSystem.SKILL_APOTHECARY]   = ApothecaryWindow,
    [CraftingSystem.SKILL_TALISMAN]     = TalismanMakingWindow,
}

CraftingSystem.currentTradeSkill = CraftingSystem.SKILL_UNKNOWN
CraftingSystem.currentWindow = CraftingSystem.craftingWindows[CraftingSystem.currentTradeSkill]


-- Create the crafting type to string mapping
CraftingSystem.CraftingTypeStrings =
{
    [GameData.TradeSkills.APOTHECARY]  = GetString (StringTables.Default.LABEL_SKILL_APOTHECARY),
    [GameData.TradeSkills.SALVAGING]   = GetString (StringTables.Default.LABEL_SKILL_SALVAGING),
    [GameData.TradeSkills.TALISMAN]    = GetString (StringTables.Default.LABEL_SKILL_TALISMAN),
}


-- if craftingSkill or resourceType are passed in then it verifies that the item
--   is for that particular trade skill (e.g. GameData.TradeSkills.APOTHECARY) or resouce type (e.g. Container)
-- if they are not specified then returns true if any trade skill data is on the item
-- 
-- Note: this doesn't account for Cultivating items - use DataUtils.IsTradeSkillItem to 
--   detect if either Cultivating or Crafting exists  
--
function CraftingSystem.IsCraftingItem( itemData, craftingSkill, resourceType ) 
    if( not itemData )
    then
        ERROR(L"Invalid item data in call to IsCraftingItem")
    end

    local craftingTypes, itemResourceType = CraftingSystem.GetCraftingData( itemData )
    if #craftingTypes == 0 then
        return false
        
    elseif resourceType ~= nil and resourceType ~= itemResourceType then
        return false
        
    end
    
    if craftingSkill ~= nil then
        for i, craftingType in ipairs( craftingTypes ) do
            if craftingType == craftingSkill then
                return true
            end
        end
        
        return false
    end
    
    return true
end


-- if craftingSkill is passed in then it verifies that the player has the item's minimum skill level in that
--   particular trade skill (e.g. GameData.TradeSkills.APOTHECARY)
-- if they are not specified then it checks *all* trade skill data on the item until it finds
--   one that they player meets. 
-- if there is no crafting data on the item this will return false.
-- 
-- Note: this doesn't account for Cultivating items - use DataUtils.PlayerTradeSkillLevelIsEnoughForItem to 
--   detect if either Cultivating or Crafting exists and user meets at least one skill requirement
--
function CraftingSystem.PlayerMeetsCraftingRequirement( itemData, craftingType ) 

    if( itemData ~= nil and craftingType ~= nil and itemData.craftingSkillRequirement ~= nil ) then
        return( GameData.TradeSkillLevels[craftingType] ~= nil and
                GameData.TradeSkillLevels[craftingType] >= itemData.craftingSkillRequirement )

    elseif ( itemData )
    then
        local craftingTypes = CraftingSystem.GetCraftingData( itemData )
        for i, craftingType in ipairs( craftingTypes ) do
            if CraftingSystem.PlayerMeetsCraftingRequirement( itemData, craftingType ) then
                return true
            end
        end
        
        return false
    end
end


-- returns 3 values:
--		a list (table) of craftingTypes (as defined by GameData.TradeSkills.*)
--		its resource type (as defined by GameData.CraftingItemType.*) (Note: this is the same for all crafting skills on the item)
--		the item's crafting level requirement (Note: this is the same for all trade skills on the item basis)
--
function CraftingSystem.GetCraftingData( itemData )

    local craftingTypes = {}
    local resourceType = 0
    for i, craftingBonus in ipairs(itemData.craftingBonus) do
    
        if( craftingBonus.bonusReference == GameData.CraftingBonusRef.CRAFTING_FAMILY ) then
        
            if craftingBonus.bonusValue and craftingBonus.bonusValue > GameData.TradeSkills.NONE and craftingBonus.bonusValue <= GameData.TradeSkills.NUM_TRADE_SKILLS then
                table.insert( craftingTypes, craftingBonus.bonusValue )
            end
            
        elseif( craftingBonus.bonusReference == GameData.CraftingBonusRef.TYPE ) then
        
            resourceType = craftingBonus.bonusValue
            
        end
    end
    
    return craftingTypes, resourceType, itemData.craftingSkillRequirement
end


-- returns 3 values:
--		a wstring that concatenates all crafting names
--		a wsting for the resource type name
--		number for the item's crafting level requirement (Note: this is the same for all trade skills on the item basis)
--
function CraftingSystem.GetCraftingDataStrings( itemData )

    local typeText = L""
    local subtypeText = L""
    local typeSeparator = L""
    for i, craftingBonus in ipairs(itemData.craftingBonus) do
        if( craftingBonus.bonusReference ~= GameData.CraftingBonusRef.NONE ) then
        
            if( craftingBonus.bonusReference == GameData.CraftingBonusRef.CRAFTING_FAMILY ) then
            
                local typeStr = CraftingSystem.CraftingTypeStrings[craftingBonus.bonusValue]
                
                if( typeStr ) then
                    typeText = typeText..typeSeparator..typeStr
                    typeSeparator = GetString( StringTables.Default.SYMBOL_LIST_SEPARATOR )
                end
                
            elseif( craftingBonus.bonusReference == GameData.CraftingBonusRef.TYPE ) then
            
                local resourceType = craftingBonus.bonusValue
                subtypeText = CraftingSystem.GetResourceTypeName( resourceType )
            end
        end
    end
    
    return typeText, subtypeText, itemData.craftingSkillRequirement
end


-- NOTE: unknown resourceType bonusValues are assumed to be INGREDIENTS
--
local craftingItemTypeString = 
{
    ingredient=GetString( StringTables.Default.LABEL_CRAFTING_INGREDEINT ),
    [GameData.CraftingItemType.CONTAINER]=GetString( StringTables.Default.LABEL_CRAFTING_CONTAINER ),
    [GameData.CraftingItemType.MAIN_INGREDIENT]=GetString( StringTables.Default.LABEL_CRAFTING_MAIN_INGREDEINT ),   
    [GameData.CraftingItemType.STABILIZER]=GetString( StringTables.Default.LABEL_CRAFTING_STABILIZER ),
    [GameData.CraftingItemType.EXTENDER]=GetString( StringTables.Default.LABEL_CRAFTING_EXTENDER ),
    [GameData.CraftingItemType.MULTIPLIER]=GetString( StringTables.Default.LABEL_CRAFTING_MULTIPLIER ),
    [GameData.CraftingItemType.STIMULANT]=GetString( StringTables.Default.LABEL_CRAFTING_STIMULANT ),
    [GameData.CraftingItemType.CONTAINER_DYE]=GetString( StringTables.Default.LABEL_CRAFTING_DYE_CONTAINER ),
    [GameData.CraftingItemType.CONTAINER_ESSENCE]=GetString( StringTables.Default.LABEL_CRAFTING_GOLD_ESSENCE_CONTAIENR ),
    [GameData.CraftingItemType.FIXER]=GetString( StringTables.Default.LABEL_CRAFTING_DYE_FIXER ),
    [GameData.CraftingItemType.PIGMENT]=GetString( StringTables.Default.LABEL_CRAFTING_DYE_PIGMENT ),
    [GameData.CraftingItemType.GOLDWEED]=GetString( StringTables.Default.LABEL_CRAFTING_GOLD_WEED ),
    [GameData.CraftingItemType.GOLDDUST]=GetString( StringTables.Default.LABEL_CRAFTING_GOLD_DUST ),
    [GameData.CraftingItemType.QUICKSILVER]=GetString( StringTables.Default.LABEL_CRAFTING_QUICKSILVER ),
    [GameData.CraftingItemType.TALISMAN_CONTAINER]=GetString( StringTables.Default.LABEL_CRAFTING_CONTAINER ),
    [GameData.CraftingItemType.FRAGMENT]=GetString( StringTables.Default.LABEL_CRAFTING_FRAGMENT ),
    [GameData.CraftingItemType.GOLD_ESSENCE]=GetString( StringTables.Default.LABEL_CRAFTING_GOLD_ESSENCE ),
    [GameData.CraftingItemType.CURIOS]=GetString( StringTables.Default.LABEL_CRAFTING_CURIOS ),
    [GameData.CraftingItemType.MAGIC_ESSENCE]=GetString( StringTables.Default.LABEL_CRAFTING_MAGIC_ESSENCE ),
    [GameData.CraftingItemType.FIGURINE]=GetString( StringTables.Default.LABEL_CRAFTING_FIGURINE ),
}

function CraftingSystem.GetResourceTypeName( resourceType )

    local resourceTypeText = L""
    if resourceType
    then
        resourceTypeText = craftingItemTypeString[resourceType]
        if( not resourceTypeText )
        then
            resourceTypeText = craftingItemTypeString.ingredient
        end
    end
    
    return resourceTypeText
end


function CraftingSystem.Initialize()
    -- Register Events  
    
    RegisterEventHandler( SystemData.Events.PLAYER_CRAFTING_UPDATED, "CraftingSystem.UpdateCraftingStatus")
    RegisterEventHandler( SystemData.Events.CRAFTING_SHOW_WINDOW, "CraftingSystem.ToggleShowing" )
end

function CraftingSystem.SetCurrentTradeSkill( tradeSkill )
    if( tradeSkill ~= nil and
        tradeSkill ~= CraftingSystem.currentTradeSkill and
        CraftingSystem.craftingWindows[tradeSkill] ~= nil )
    then
        CraftingSystem.currentTradeSkill = tradeSkill
        CraftingSystem.currentWindow = CraftingSystem.craftingWindows[CraftingSystem.currentTradeSkill]
    end
end

-- local functions
local function SetCurrentWindowsTradeSkill()
    local windowID = WindowGetId( SystemData.ActiveWindow.name )
    CraftingSystem.SetCurrentTradeSkill( windowID )
end

local function SetCurrentWindowsParentsTradeSkill()
    local windowID = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
    CraftingSystem.SetCurrentTradeSkill( windowID )
end

local function HideCurrentWindow()
    if( CraftingSystem.currentWindow.windowName == nil or not WindowGetShowing( CraftingSystem.currentWindow.windowName ) )
    then
        return
    end

    Sound.Play( Sound.WINDOW_CLOSE )
    
    WindowSetShowing( CraftingSystem.currentWindow.windowName, false)
    
    WindowUtils.RemoveFromOpenList( CraftingSystem.currentWindow.windowName )
    
    if( CraftingSystem.currentWindow.Hide ~= nil )
    then
        CraftingSystem.currentWindow.Hide()
    end
end

local function ShowCurrentWindow()
    if( CraftingSystem.currentWindow.windowName == nil or WindowGetShowing( CraftingSystem.currentWindow.windowName ) )
    then
        return
    end
    local currentWindow = CraftingSystem.currentWindow
    CraftingSystem.SetStaticData()

    WindowSetShowing(currentWindow.windowName, true)
    
    currentWindow.skillNumber = CraftingSystem.currentTradeSkill
    local function CloseCallback()
        CraftingSystem.SetCurrentTradeSkill( currentWindow.skillNumber )
        HideCurrentWindow()
    end
    
    WindowUtils.AddToOpenList( currentWindow.windowName, CloseCallback, WindowUtils.Cascade.MODE_AUTOMATIC )

    Sound.Play( Sound.WINDOW_OPEN )
    
    if( currentWindow.Show ~= nil )
    then
        currentWindow.Show()
        EA_BackpackUtilsMediator.ShowBackpack()
    end
end

-- API
function CraftingSystem.UpdateCraftingStatus( updatedIngredients )
    CraftingSystem.SetCurrentTradeSkill( GameData.CraftingStatus.SkillType )
   
    if( CraftingSystem.currentWindow.UpdateCraftingStatus ~= nil )
    then
        CraftingSystem.currentWindow.UpdateCraftingStatus( updatedIngredients )
    end	
    
    CraftingSystem.SetState( GameData.CraftingStatus.State )
end

function CraftingSystem.SetStaticData()
    if( CraftingSystem.currentWindow.SetStaticData ~= nil )
    then
        CraftingSystem.currentWindow.SetStaticData()
    end									
end

function CraftingSystem.SetStateData()
    if( CraftingSystem.currentWindow.SetStateData ~= nil )
    then
        CraftingSystem.currentWindow.SetStateData()
    end			
end

function CraftingSystem.SetState( newState )
    if( CraftingSystem.currentWindow.SetState ~= nil )
    then
        CraftingSystem.currentWindow.SetState( newState )
    end			
end

function CraftingSystem.Clear()
    if( CraftingSystem.currentWindow.Clear ~= nil )
    then
        CraftingSystem.currentWindow.Clear()
    end
end

function CraftingSystem.Show()
    SetCurrentWindowsTradeSkill()
    ShowCurrentWindow()
end

function CraftingSystem.Hide()
    SetCurrentWindowsParentsTradeSkill()
    HideCurrentWindow()
end

function CraftingSystem.ToggleShowing( tradeSkill )
    --DEBUG(L"CraftingSystem.ToggleShowing")
    if( tradeSkill == nil )
    then
        --DEBUG(L"TradeSkill is nil")
        SetCurrentWindowsTradeSkill()
    elseif( tradeSkill == GameData.TradeSkills.CULTIVATION )
    then
        CultivationWindow.ToggleShowing()
        return
    else
        --DEBUG(L"Setting TradeSkill: "..tradeSkill)
        CraftingSystem.SetCurrentTradeSkill( tradeSkill ) 
    end
    
    -- DEBUG(L"Toggling Window")
    if( WindowGetShowing( CraftingSystem.currentWindow.windowName ) )
    then
        HideCurrentWindow()
    else
        ShowCurrentWindow()
    end
end

function CraftingSystem.Done()
    CraftingSystem.Hide()
end


function CraftingSystem.Shutdown()
    -- Unregister Events  
    UnregisterEventHandler( SystemData.Events.PLAYER_CRAFTING_UPDATED, "CraftingSystem.UpdateCraftingStatus")
    UnregisterEventHandler( SystemData.Events.CRAFTING_SHOW_WINDOW, "CraftingSystem.ToggleShowing" )
end
