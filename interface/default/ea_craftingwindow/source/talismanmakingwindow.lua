
TalismanMakingWindow = {}
TalismanMakingWindow.versionNumber = 0.1

TalismanMakingWindow.PerformingLock = false

TalismanMakingWindow.craftingData = {}
TalismanMakingWindow.maxResources = 4

-- Static Info for each crafting skill
TalismanMakingWindow.staticSkillInfo =
{
    name = GetString( StringTables.Default.LABEL_SKILL_TALISMAN ),
    commitLabel = GetString( StringTables.Default.LABEL_TALISMAN_ACTION ),
}

TalismanMakingWindow.windowName = "TalismanMakingWindow"

local windowName = TalismanMakingWindow.windowName

TalismanMakingWindow.POWER_MIN = 0
TalismanMakingWindow.POWER_MAX = 49
TalismanMakingWindow.POWER_ANIMATION_JITTER_AMOUNT = 0.03 -- a percentage

-- These are the ranges of power the talisman can have
TalismanMakingWindow.QUALITY_RANGE_1 = 1
TalismanMakingWindow.QUALITY_RANGE_2 = 2
TalismanMakingWindow.QUALITY_RANGE_3 = 3
TalismanMakingWindow.QUALITY_RANGE_4 = 4
TalismanMakingWindow.QUALITY_RANGE_5 = 5
TalismanMakingWindow.QUALITY_RANGE_6 = 6
TalismanMakingWindow.NUM_RANGES = 6
TalismanMakingWindow.POWER_LEVELS_PER_QUALITY_RANGES_LEVEL = TalismanMakingWindow.POWER_MAX / TalismanMakingWindow.NUM_RANGES
TalismanMakingWindow.powerLevel = 1
TalismanMakingWindow.powerRange = TalismanMakingWindow.QUALITY_RANGE_1

-- States that the Crafting Window can be in
TalismanMakingWindow.STATE_INIT              = -1
TalismanMakingWindow.STATE_NEED_CONTAINER    = GameData.CraftingStates.ADDCONTAINER
TalismanMakingWindow.STATE_NEED_DETERMINENT  = GameData.CraftingStates.ADDDETERMINENT
TalismanMakingWindow.STATE_NEED_RESOURCES    = GameData.CraftingStates.ADDINGREDIENT
TalismanMakingWindow.STATE_VALID_RECIPE      = GameData.CraftingStates.VALID_RECIPE
TalismanMakingWindow.STATE_SUCCESS           = GameData.CraftingStates.SUCCESS
TalismanMakingWindow.STATE_SUCCESS_REPEAT    = GameData.CraftingStates.SUCCESS_REPEAT
TalismanMakingWindow.STATE_FAIL              = GameData.CraftingStates.FAIL
TalismanMakingWindow.STATE_PERFORMING        = GameData.CraftingStates.PERFORMING

-- Slots
TalismanMakingWindow.SLOT_CONTAINER         = 0
TalismanMakingWindow.SLOT_DETERMINENT       = 1
TalismanMakingWindow.SLOT_GOLD              = 2
TalismanMakingWindow.SLOT_CURIOS            = 3
TalismanMakingWindow.SLOT_MAGIC             = 4
TalismanMakingWindow.SLOT_GOLD_AND_CURIOS   = TalismanMakingWindow.SLOT_GOLD + TalismanMakingWindow.SLOT_CURIOS 
TalismanMakingWindow.SLOT_GOLD_AND_MAGIC    = TalismanMakingWindow.SLOT_GOLD + TalismanMakingWindow.SLOT_MAGIC
TalismanMakingWindow.SLOT_CURIOS_AND_MAGIC  = TalismanMakingWindow.SLOT_CURIOS + TalismanMakingWindow.SLOT_MAGIC
TalismanMakingWindow.INVALID_RECIPE         = TalismanMakingWindow.SLOT_CURIOS + TalismanMakingWindow.SLOT_MAGIC + TalismanMakingWindow.SLOT_GOLD

TalismanMakingWindow.TALISMAN_CONTAINER         = GameData.CraftingItemType.TALISMAN_CONTAINER
TalismanMakingWindow.TALISMAN_FRAGMENT          = GameData.CraftingItemType.FRAGMENT
TalismanMakingWindow.TALISMAN_GOLD_ESSENCE      = GameData.CraftingItemType.GOLD_ESSENCE
TalismanMakingWindow.TALISMAN_CURIOS            = GameData.CraftingItemType.CURIOS
TalismanMakingWindow.TALISMAN_MAGICAL_ESSENCE   = GameData.CraftingItemType.MAGIC_ESSENCE

TalismanMakingWindow.slotStrings =
{
    [TalismanMakingWindow.SLOT_CONTAINER]   = "Container",
    [TalismanMakingWindow.SLOT_DETERMINENT] = "Determinent",
    [TalismanMakingWindow.SLOT_GOLD]        = "Gold",
    [TalismanMakingWindow.SLOT_CURIOS]      = "Curios",
    [TalismanMakingWindow.SLOT_MAGIC]       = "Magic",
}

TalismanMakingWindow.pendingAddItem = { backpackSlot = 0, slotNum = 0, backpack = 0 }
TalismanMakingWindow.virtualSlots = {} -- this is the glue between the client and the server for the ingredients

TalismanMakingWindow.DEFAULT_STATE = TalismanMakingWindow.STATE_NEED_CONTAINER
TalismanMakingWindow.currentState = TalismanMakingWindow.DEFAULT_STATE

TalismanMakingWindow.SlotToolTipText =
{
    [TalismanMakingWindow.SLOT_CONTAINER]   = GetString( StringTables.Default.TOOLTIP_TALISMAN_MAKING_CONTAINER_SLOT ),
    [TalismanMakingWindow.SLOT_DETERMINENT] = GetString( StringTables.Default.TOOLTIP_TALISMAN_MAKING_MAIN_INGREDIENT_SLOT ),
    [TalismanMakingWindow.SLOT_GOLD]        = GetString( StringTables.Default.TOOLTIP_TALISMAN_MAKING_GOLD_ESSENCE_SLOT ),
    [TalismanMakingWindow.SLOT_CURIOS]      = GetString( StringTables.Default.TOOLTIP_TALISMAN_MAKING_CURIOS_SLOT ),
    [TalismanMakingWindow.SLOT_MAGIC]       = GetString( StringTables.Default.TOOLTIP_TALISMAN_MAKING_MAGICAL_ESSENCE_SLOT ),
}

TalismanMakingWindow.SlotSounds  =
{
    [TalismanMakingWindow.SLOT_CONTAINER]   = Sound.APOTHECARY_CONTAINER_ADDED,
    [TalismanMakingWindow.SLOT_DETERMINENT] = Sound.APOTHECARY_DETERMINENT_ADDED,
    [TalismanMakingWindow.SLOT_GOLD]        = Sound.APOTHECARY_RESOURCE_ADDED,
    [TalismanMakingWindow.SLOT_CURIOS]      = Sound.APOTHECARY_RESOURCE_ADDED,
    [TalismanMakingWindow.SLOT_MAGIC]       = Sound.APOTHECARY_RESOURCE_ADDED,
}

TalismanMakingWindow.AddIngredientsHintText =
{
    [TalismanMakingWindow.SLOT_GOLD]                = GetString( StringTables.Default.HINT_TEXT_GOLD_SLOT_FILLED ),
    [TalismanMakingWindow.SLOT_CURIOS]              = GetString( StringTables.Default.HINT_TEXT_CURIOS_SLOT_FILLED ),
    [TalismanMakingWindow.SLOT_MAGIC]               = GetString( StringTables.Default.HINT_TEXT_MAGIC_SLOT_FILLED ),
    [TalismanMakingWindow.SLOT_GOLD_AND_CURIOS]     = GetString( StringTables.Default.HINT_TEXT_GOLD_AND_CURIOS_SLOT_FILLED ),
    [TalismanMakingWindow.SLOT_GOLD_AND_MAGIC]      = GetString( StringTables.Default.HINT_TEXT_GOLD_AND_MAGIC_SLOT_FILLED ),
    [TalismanMakingWindow.SLOT_CURIOS_AND_MAGIC]    = GetString( StringTables.Default.HINT_TEXT_CURIOS_AND_MAGIC_SLOT_FILLED ),
    [TalismanMakingWindow.INVALID_RECIPE]           = GetString( StringTables.Default.HINT_TEXT_CURIOS_AND_MAGIC_SLOT_FILLED ),
}

-- there are 8 of these that correspond to the different power levels
TalismanMakingWindow.PowerRangeInfo = 
{
    [TalismanMakingWindow.QUALITY_RANGE_1]   =
    {
        text=GetString( StringTables.Default.HINT_TEXT_POWER_RANGE_WEAK ),
        color=DefaultColor.COLOR_TALISMAN_GENRAL_HINT,
        orb="orb-blue",
    },
    
    [TalismanMakingWindow.QUALITY_RANGE_2]   = 
    {
        text=GetString( StringTables.Default.HINT_TEXT_POWER_RANGE_INFERIOR ),
        color=DefaultColor.COLOR_TALISMAN_GENRAL_HINT,
        orb="orb-blue",
    },
    
    [TalismanMakingWindow.QUALITY_RANGE_3]   =
    {
        text=GetString( StringTables.Default.HINT_TEXT_POWER_RANGE_LESSER ),
        color=DefaultColor.COLOR_TALISMAN_GENRAL_HINT,
        orb="orb-blue",
    },
    
    [TalismanMakingWindow.QUALITY_RANGE_4]   =
    {
        text=GetString( StringTables.Default.HINT_TEXT_POWER_RANGE_GREATER ),
        color=DefaultColor.COLOR_TALISMAN_GENRAL_HINT,
        orb="orb-blue",
    },
    
    [TalismanMakingWindow.QUALITY_RANGE_5]   = 
    {
        text=GetString( StringTables.Default.HINT_TEXT_POWER_RANGE_SUPERIOR ),
        color=DefaultColor.COLOR_TALISMAN_GENRAL_HINT,
        orb="orb-blue",
    },
    
    [TalismanMakingWindow.QUALITY_RANGE_6]   = 
    {
        text=GetString( StringTables.Default.HINT_TEXT_POWER_RANGE_POTENT ),
        color=DefaultColor.COLOR_TALISMAN_GENRAL_HINT,
        orb="orb-blue",
    },
}

-- The data that makes this window function like a state machine
TalismanMakingWindow.stateData =
{
    [TalismanMakingWindow.STATE_NEED_CONTAINER]   =
    {
        hintText = GetString( StringTables.Default.TEXT_CRAFTING_HINT_NEED_CONTAINER ),
        hintTextColor = DefaultColor.COLOR_NEED_CONTAINER,
        hintTextIconSlice = "orb-grey",
        disableCommitButton = true,
        hideIngredientSlots = true,
    },
    
    [TalismanMakingWindow.STATE_NEED_DETERMINENT]   =
    {
        hintText = GetString( StringTables.Default.HINT_TEXT_TALISMAN_MAKING_NEED_DETERMINENT ),
        hintTextColor = DefaultColor.COLOR_NEED_DETERMINENT,
        hintTextIconSlice = "orb-red",
        disableCommitButton = true,
    },
    
    [TalismanMakingWindow.STATE_NEED_RESOURCES]   =
    {
        hintText = GetString( StringTables.Default.HINT_TEXT_TALISMAN_MAKING_NEED_INGREDIENTS ),
        hintTextColor = DefaultColor.COLOR_NEED_INGREDIENTS,
        hintTextIconSlice = "orb-orange",
        showPowerMeter = true,
        disableCommitButton = true,
    },
    
    [TalismanMakingWindow.STATE_VALID_RECIPE]   =
    {
        showPowerMeter = true,
    },
    
    [TalismanMakingWindow.STATE_SUCCESS]   =
    {
        hintText = GetString( StringTables.Default.HINT_TEXT_TALISMAN_MAKING_SUCCESS ),
        hintTextColor = DefaultColor.COLOR_NEED_STABILIZERS,
        hintTextIconSlice = "orb-green",
        disableCommitButton = true,
        showPowerMeter = true,
        sound = Sound.APOTHECARY_SUCCEEDED,
    },
    
    [TalismanMakingWindow.STATE_SUCCESS_REPEAT]   =
    {
        hintText = GetString( StringTables.Default.HINT_TEXT_TALISMAN_MAKING_SUCCESS ),
        hintTextColor = DefaultColor.COLOR_NEED_STABILIZERS,
        hintTextIconSlice = "orb-green",
        showPowerMeter = true,
        sound = Sound.APOTHECARY_SUCCEEDED,
    },
    
    [TalismanMakingWindow.STATE_FAIL]   =
    {
        hintText= GetString( StringTables.Default.HINT_TEXT_TALISMAN_MAKING_FAILURE ),
        hintTextColor = DefaultColor.COLOR_NEED_DETERMINENT,
        hintTextIconSlice = "orb-red",
        showPowerMeter = true,
        sound = Sound.APOTHECARY_FAILED,
    },
    
    [TalismanMakingWindow.STATE_PERFORMING]   =
    {
        showPowerMeter = true,
        sound = Sound.APOTHECARY_BREW_STARTED,
    },
}

local function GetAddIngredientsHintText()
    local hintTextIndex
    
    local function GetHintTextIndex( slot )
        local craftingData = TalismanMakingWindow.craftingData[slot]
        if( craftingData and craftingData.objectId )
        then
            return slot
        end
        
        return 0
    end
    
    hintTextIndex = GetHintTextIndex( TalismanMakingWindow.SLOT_GOLD )
    hintTextIndex = hintTextIndex + GetHintTextIndex( TalismanMakingWindow.SLOT_CURIOS )
    hintTextIndex = hintTextIndex + GetHintTextIndex( TalismanMakingWindow.SLOT_MAGIC )
    
    local hintText = TalismanMakingWindow.stateData[TalismanMakingWindow.STATE_NEED_RESOURCES].hintText
    if( hintTextIndex ~= 0 and TalismanMakingWindow.AddIngredientsHintText[hintTextIndex] )
    then
        hintText = TalismanMakingWindow.AddIngredientsHintText[hintTextIndex]
    end
    
    return hintText
end

local slotToItemTypeMapping =
{
    [TalismanMakingWindow.SLOT_CONTAINER]     = TalismanMakingWindow.TALISMAN_CONTAINER,
    [TalismanMakingWindow.SLOT_DETERMINENT]   = TalismanMakingWindow.TALISMAN_FRAGMENT,
    [TalismanMakingWindow.SLOT_GOLD]          = TalismanMakingWindow.TALISMAN_GOLD_ESSENCE,
    [TalismanMakingWindow.SLOT_CURIOS]        = TalismanMakingWindow.TALISMAN_CURIOS,
    [TalismanMakingWindow.SLOT_MAGIC ]        = TalismanMakingWindow.TALISMAN_MAGICAL_ESSENCE,
}

-- returns whether the item is valid for a particular slot and the item's type
local function IsItemValidForSlot( itemData, slotType )
    local craftingTypes, resourceType, requirement = CraftingSystem.GetCraftingData( itemData )
    local isValidForSlot = false
    if( craftingTypes )
    then
        local isTalismanItem = false
        for index, craftType in ipairs( craftingTypes )
        do
            if( craftType == GameData.TradeSkills.TALISMAN )
            then
                isTalismanItem = true
                break
            end
        end
        
        
        if( isTalismanItem and resourceType ~= nil and resourceType == slotToItemTypeMapping[slotType])
        then
            isValidForSlot = true
        end
    end
    
    return isValidForSlot, resourceType
end

local function GetQualityRangeForLevel( level )
    local range = math.floor( level / TalismanMakingWindow.POWER_LEVELS_PER_QUALITY_RANGES_LEVEL )
    --d( "Range: "..range.." PowerLevel: "..level.." Levels per quality range: "..TalismanMakingWindow.POWER_LEVELS_PER_QUALITY_RANGES_LEVEL )
    if( range + 1 > TalismanMakingWindow.NUM_RANGES )
    then
        range = TalismanMakingWindow.NUM_RANGES
    else
        range = range + 1
    end
    --d( "Final Range Returned: "..range )
    return range
end

local function ShowIngredientSlots( bShow )
    WindowSetShowing( windowName.."DeterminentSlot", bShow )
    WindowSetShowing( windowName.."GoldSlot", bShow )
    WindowSetShowing( windowName.."CuriosSlot", bShow )
    WindowSetShowing( windowName.."MagicSlot", bShow )
end

function TalismanMakingWindow.Initialize()

    RegisterEventHandler( SystemData.Events.PLAYER_INVENTORY_SLOT_UPDATED, "TalismanMakingWindow.UpdateLock")    

    -- Set up the power meter
    TalismanMakingWindow.powerDynamicImage = DynamicImage:CreateFrameForExistingWindow( windowName.."PowerMeter" )
    local width, height = TalismanMakingWindow.powerDynamicImage:GetDimensions()
    local minY = 232
    local minX = 452
    local maxX = minX + width
    local maxY = minY + height
    TalismanMakingWindow.powerDynamicImage:SetExtents( maxY, minY, maxX, minX, width, height )

    -- init everything else
    TalismanMakingWindow.Clear()
    TalismanMakingWindow.timePassed = 0
end

function TalismanMakingWindow.UpdateLock()
  TalismanMakingWindow.PerformingLock = false
  ButtonSetPressedFlag( windowName.."CommitButton", false )    
end


function TalismanMakingWindow.OnHidden()
    if( SystemData.InputProcessed.EscapeKey == false )
    then
        Sound.Play( Sound.WINDOW_CLOSE )
    
        WindowUtils.RemoveFromOpenList( windowName )
    
        TalismanMakingWindow.Hide()
    end
end

function TalismanMakingWindow.SetStaticData()
    local skillLevel = GameData.CraftingStatus.SkillLevel
    local skillText = GetString( StringTables.Default.LABEL_SKILL )..L": "..skillLevel
    LabelSetText(windowName.."Skill", skillText )
    LabelSetText(windowName.."TitleBarText", TalismanMakingWindow.staticSkillInfo.name )
    ButtonSetText(windowName.."CommitButton", TalismanMakingWindow.staticSkillInfo.commitLabel )
    ButtonSetText(windowName.."ClearButton", GetString( StringTables.Default.LABEL_CLEAR ) )
end

function TalismanMakingWindow.SetStateData()
    local stateData = TalismanMakingWindow.stateData[TalismanMakingWindow.currentState]

    if( stateData == nil )
    then
        return
    end
    
    -- Run all the state functions based on the state data
    local skillLevel = GameData.CraftingStatus.SkillLevel
    local skillText = GetString( StringTables.Default.LABEL_SKILL )..L": "..skillLevel
    LabelSetText(windowName.."Skill", skillText )
    
    ButtonSetDisabledFlag( windowName.."CommitButton", stateData.disableCommitButton == true )
    
    -- The valid recipe state and the performing state are a little different than the others,
    -- thier tooltips are based on the powerRange of the recipe
    local displayString = stateData.hintText
    local color = stateData.hintTextColor
    local iconSlice = stateData.hintTextIconSlice
    if ( TalismanMakingWindow.currentState == TalismanMakingWindow.STATE_VALID_RECIPE or
         TalismanMakingWindow.currentState == TalismanMakingWindow.STATE_PERFORMING )
    then
        displayString = TalismanMakingWindow.PowerRangeInfo[TalismanMakingWindow.powerRange].text
        color  = TalismanMakingWindow.PowerRangeInfo[TalismanMakingWindow.powerRange].color
        iconSlice = TalismanMakingWindow.PowerRangeInfo[TalismanMakingWindow.powerRange].orb
    elseif( TalismanMakingWindow.currentState == TalismanMakingWindow.STATE_NEED_RESOURCES )
    then
        displayString = GetAddIngredientsHintText()
    end

    if( TalismanMakingWindow.currentState == TalismanMakingWindow.STATE_PERFORMING )
    then
        TalismanMakingWindow.UpdateTimerBar()
    end

    ShowIngredientSlots( not stateData.hideIngredientSlots )
    
    LabelSetTextColor( windowName.."HintText", color.r, color.g, color.b )
    LabelSetText( windowName.."HintText", displayString )
    DynamicImageSetTextureSlice( windowName.."HintTextIcon", iconSlice )
    
    WindowSetShowing( windowName.."PowerMeterBackground", stateData.showPowerMeter == true )
    TalismanMakingWindow.powerDynamicImage:Show( stateData.showPowerMeter == true )
    
    
    if( stateData.sound )
    then
        Sound.Play( stateData.sound )
    end

end

function TalismanMakingWindow.UpdateTimerBar()
    local str = GetString( StringTables.Default.LABEL_PERFORMING_TALISMAN_MAKING )
    LayerTimerWindow.SetActionName( GetString( StringTables.Default.LABEL_PERFORMING_TALISMAN_MAKING ) )
end

local function UpdateBackpackLocks( backpackSlotsUsed )
    EA_BackpackUtilsMediator.ReleaseAllLocksForWindow( TalismanMakingWindow.windowName )
    for backpackType = 1, EA_Window_Backpack.NUM_BACKPACK_TYPES
    do
        if( backpackSlotsUsed[backpackType] )
        then
            for slot, count in pairs( backpackSlotsUsed[backpackType] )
            do
                local itemData = EA_Window_Backpack.GetItemsFromBackpack( backpackType )[slot]
                if( DataUtils.IsValidItem( itemData ) )
                then
                    EA_BackpackUtilsMediator.RequestLockForSlot(slot, backpackType, windowName, {r=0,g=255,b=0} )
                end
            end
        end
    end
end

function TalismanMakingWindow.Clear()
    TalismanMakingWindow.craftingData = {}
    TalismanMakingWindow.currentState = TalismanMakingWindow.STATE_INIT
    TalismanMakingWindow.SetState( TalismanMakingWindow.DEFAULT_STATE )

    TalismanMakingWindow.usedResources = 0
    TalismanMakingWindow.powerLevel = 1
    TalismanMakingWindow.powerRange = TalismanMakingWindow.QUALITY_RANGE_1
    TalismanMakingWindow.pendingAddItem ={ backpackSlot = 0, slotNum = 0, backpack = 0 }
    TalismanMakingWindow.virtualSlots = {}
    
    for index=0,TalismanMakingWindow.maxResources do
        TalismanMakingWindow.SetCraftingSlotIcon( index )
    end
end

function TalismanMakingWindow.OnClearButton()
    if( TalismanMakingWindow.craftingData[TalismanMakingWindow.SLOT_CONTAINER] and
        TalismanMakingWindow.craftingData[TalismanMakingWindow.SLOT_CONTAINER].objectId )
    then
        -- Just remove the container and everything will clear
        local invSlot = TalismanMakingWindow.craftingData[ApothecaryWindow.SLOT_CONTAINER].sourceSlot
        local backpackType = TalismanMakingWindow.craftingData[ApothecaryWindow.SLOT_CONTAINER].backpack
        TalismanMakingWindow.craftingData = {}
        RemoveCraftingItem(GameData.TradeSkills.TALISMAN, invSlot, backpackType )
        Sound.Play( Sound.APOTHECARY_ITEM_REMOVED )
    end
end

function TalismanMakingWindow.SetState( newState )

    -- Update the rest of the settings
    if( newState == nil or
        newState > TalismanMakingWindow.STATE_PERFORMING or
        newState < TalismanMakingWindow.STATE_NEED_CONTAINER )
    then
        return
    end
    
    TalismanMakingWindow.SetPowerState( GameData.CraftingStatus.OmeterValue )
    TalismanMakingWindow.currentState = newState
    TalismanMakingWindow.SetStateData()
end

function TalismanMakingWindow.SetPowerState( powerLevel )
    if( powerLevel == nil or
        powerLevel < TalismanMakingWindow.POWER_MIN )
    then
        return
    end
    
    TalismanMakingWindow.powerRange = GetQualityRangeForLevel( powerLevel )
    TalismanMakingWindow.powerLevel = powerLevel
end

function TalismanMakingWindow.UpdatePowerAnimation( timeElapsed )
    if( TalismanMakingWindow.powerDynamicImage:IsShowing() )
    then
        TalismanMakingWindow.timePassed = TalismanMakingWindow.timePassed + timeElapsed
        local jitterAmount = math.sin( TalismanMakingWindow.timePassed ) * TalismanMakingWindow.POWER_ANIMATION_JITTER_AMOUNT
        local fillPercent = TalismanMakingWindow.powerLevel / TalismanMakingWindow.POWER_MAX + jitterAmount
        if( fillPercent < 0 )
        then
            fillPercent = 0
        elseif( fillPercent > 1.0 )
        then
            fillPercent = 1.0
        end
        TalismanMakingWindow.powerDynamicImage:FillBasedOnPercent( fillPercent, "EA_Talisman01_d5" )
    end
end

function TalismanMakingWindow.Show()
    --The rest of this is handled in the crafting system
    SendInitCrafting( GameData.TradeSkills.TALISMAN )
end

function TalismanMakingWindow.Hide()
    --The rest of this is handled in the crafting system
    TalismanMakingWindow.Clear()
    SendCloseCrafting( GameData.TradeSkills.TALISMAN )
    UpdateBackpackLocks( {} ) -- empty table to clear any backpack locks
end



function TalismanMakingWindow.UpdateCraftingStatus( updatedIngredients )
    -- The state has already changed,
    -- so just set the slot to nil if there is no data there or change the icon,
    local craftingData = GetCraftingData( GameData.TradeSkills.TALISMAN )
    local backpackSlots = GetCraftingBackPackSlots( GameData.TradeSkills.TALISMAN )
    
    local backpackSlotsUsed = {}

    -- Remove everything    
    for index = 0, TalismanMakingWindow.maxResources
    do
        TalismanMakingWindow.craftingData[index] = {}
        TalismanMakingWindow.SetCraftingSlotIcon( index, nil )
    end
    TalismanMakingWindow.virtualSlots = {}
    
    -- Add everything that exist in the updated ingredients received from the server
    for index = 0, TalismanMakingWindow.maxResources
    do
        if( not backpackSlots[index] )
        then
            break
        end
        local backpackSlot = backpackSlots[index].slot
        local backpackType = backpackSlots[index].backpack
        
        local currentItem = craftingData[index]
        local validItem = currentItem.id ~= 0
        local clientCraftingSlot = index

        local itemSlottedOnServer = false
        
        for serverSlot, ingredient in pairs( updatedIngredients )
        do
            if ( ingredient.slot == backpackSlot and  ingredient.backpack == backpackType )
            then
                itemSlottedOnServer = true
                break
            end
        end
        
        if( validItem and itemSlottedOnServer )
        then
            local inventory = EA_Window_Backpack.GetItemsFromBackpack( backpackType )
            local itemData = inventory[ backpackSlot ]
            _, clientCraftingSlot = TalismanMakingWindow.WouldBePossibleToAdd( itemData )
            -- track how many of each inventory item we are using
            if( not backpackSlotsUsed[ backpackSlot ] or not backpackSlotsUsed[ backpackType ][ backpackSlot ]  )
            then
                if( not backpackSlotsUsed[backpackType] )
                then
                    backpackSlotsUsed[backpackType] = {}
                end
                backpackSlotsUsed[backpackType][ backpackSlot ] = 1
            else
                backpackSlotsUsed[backpackType][ backpackSlot ] = backpackSlotsUsed[backpackType][ backpackSlot ] + 1
            end
            
            local cursor = EA_Window_Backpack.GetCursorForBackpack( backpackType )
            TalismanMakingWindow.craftingData[ clientCraftingSlot ] = 
            {
                objectSource = cursor,
                sourceSlot = backpackSlot,
                backpack = backpackType,
                objectId = itemData.uniqueID,
                iconId = itemData.iconNum,
                autoOnLButtonUp = true,
                stackAmount = itemData.stackCount
            }
            TalismanMakingWindow.SetCraftingSlotIcon( clientCraftingSlot, itemData.iconNum )
        end
    end
    
    -- Add any pending items
    if ( TalismanMakingWindow.pendingAddItem.backpackSlot ~= 0 )
    then
        local invSlot = TalismanMakingWindow.pendingAddItem.backpackSlot
        local backpack = TalismanMakingWindow.pendingAddItem.backpack
        local slotNum = TalismanMakingWindow.pendingAddItem.slotNum
        TalismanMakingWindow.AddItem( invSlot, backpack, slotNum )
        TalismanMakingWindow.pendingAddItem ={ backpackSlot = 0, slotNum = 0, backpack = 0 }
    end
    
    if( backpackSlots[TalismanMakingWindow.SLOT_CONTAINER] == 0)
    then
        backpackSlotsUsed = {}
        TalismanMakingWindow.Clear()
    end
    
    UpdateBackpackLocks( backpackSlotsUsed )
end

function TalismanMakingWindow.SetCraftingSlotIcon( slotNum, icon )
    if( slotNum < 0 or slotNum > TalismanMakingWindow.maxResources )
    then
        return
    end
    
    local buttonName = TalismanMakingWindow.slotStrings[slotNum].."Slot"
    
    if( icon == nil )
    then
        icon = 0
    end
    
    local texture = ""
    local x = 0
    local y = 0
    local iconValid = icon ~= 0
    if( iconValid )
    then
        texture, x, y = GetIconData( icon )
    end
    
    if( slotNum ~= TalismanMakingWindow.SLOT_CONTAINER )
    then
        WindowSetShowing(windowName..buttonName.."Orb", not iconValid )
    end
    
    DynamicImageSetTexture ( windowName..buttonName.."IconBase", texture, x, y )
end

function TalismanMakingWindow.RemoveVirtualItemSlot( slotNum )
    if( slotNum < TalismanMakingWindow.SLOT_GOLD or slotNum > TalismanMakingWindow.maxResources )
    then
        return
    end
    
    -- find the slot to remove and get rid of it
    for index = TalismanMakingWindow.SLOT_GOLD-1, TalismanMakingWindow.maxResources-1
    do
        if( TalismanMakingWindow.virtualSlots[index] and TalismanMakingWindow.virtualSlots[index] == slotNum )
        then
            local oldSlot = table.remove( TalismanMakingWindow.virtualSlots, index )
            
            --Remove it
            TalismanMakingWindow.craftingData[ oldSlot ] = {}
            TalismanMakingWindow.SetCraftingSlotIcon( oldSlot, 0 )
            return
        end
    end    
end

function TalismanMakingWindow.AddItem( backpackSlot, slotNum, backpackType )
    local inventory = EA_Window_Backpack.GetItemsFromBackpack( backpackType )
    local itemData = inventory[backpackSlot]
    local isValid, resourceType = IsItemValidForSlot( itemData, slotNum )

    
    if( slotNum > TalismanMakingWindow.SLOT_DETERMINENT and isValid )
    then
        table.insert( TalismanMakingWindow.virtualSlots, slotNum )
    end
    
    if( isValid )
    then
        if( slotNum == TalismanMakingWindow.SLOT_CONTAINER)
        then 
            AddCraftingContainer( GameData.TradeSkills.TALISMAN, backpackSlot, backpackType )
        else
            AddCraftingItem( GameData.TradeSkills.TALISMAN, slotNum, backpackSlot, backpackType )
        end
        
        -- play sound based on the crafting type of the item
	    TalismanMakingWindow.PlaySoundForUpdatedSlot( itemData, slotNum )
    end
end

function TalismanMakingWindow.RemoveItem( backpackSlot, slotNum, backpackType )
    if( not backpackSlot or not slotNum or not backpackType )
    then
        ERROR(L"Invalid call to RemoveItem")
    end
    RemoveCraftingItem(GameData.TradeSkills.TALISMAN, backpackSlot, backpackType )
    Sound.Play( Sound.APOTHECARY_ITEM_REMOVED )
    TalismanMakingWindow.SetCraftingSlotIcon( slotNum, 0 )
end


function TalismanMakingWindow.OnLButtonUp()
end

function TalismanMakingWindow.OnRButtonUp()
    EA_Window_ContextMenu.CreateOpacityOnlyContextMenu( windowName )
    if Cursor.IconOnCursor() then
        Cursor.Clear()
    end
end

function TalismanMakingWindow.OnSlotLButtonUp()
    if( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) )
    then
        return
    end
    
    -- Grab the slot num
    local slotNum = WindowGetId( SystemData.ActiveWindow.name )
    
    if Cursor.IconOnCursor() then
        local backpackType = EA_Window_Backpack.GetCurrentBackpackType()
        local backpackCursor = EA_Window_Backpack.GetCursorForBackpack( backpackType )
        if( backpackCursor ~= Cursor.Data.Source )
        then
            return
        end
        
        -- pickup what is there if there is anything
        local pickupData = TalismanMakingWindow.craftingData[ slotNum ]
        local backpackSourceSlot = Cursor.Data.SourceSlot
        
        if( pickupData and pickupData.sourceSlot )
        then
            local sourceSlot = pickupData.sourceSlot
            TalismanMakingWindow.pendingAddItem.backpackSlot = backpackSourceSlot
            TalismanMakingWindow.pendingAddItem.slotNum = slotNum
            TalismanMakingWindow.pendingAddItem.backpack = backpackType
            
            Cursor.Clear()
            Cursor.PickUp( pickupData.objectSource, pickupData.sourceSlot, pickupData.objectId,
                           pickupData.iconId, pickupData.autoOnLButtonUp, pickupData.stackAmount )
            
            TalismanMakingWindow.RemoveVirtualItemSlot( slotNum )
            RemoveCraftingItem( GameData.TradeSkills.TALISMAN, sourceSlot, pickupData.backpack )
            Sound.Play( Sound.APOTHECARY_ITEM_REMOVED )
        else
			if( Cursor.Data and Cursor.Data.SourceSlot and Cursor.Data.Source == backpackCursor )
            then
				TalismanMakingWindow.AddItem( backpackSourceSlot, slotNum, backpackType )
			end
        
            Cursor.Clear()
        end
    else -- Pickup anything that is there
        local pickupData = TalismanMakingWindow.craftingData[ slotNum ]
        
        if( pickupData and pickupData.sourceSlot )
        then
            local sourceSlot = pickupData.sourceSlot
            
            Cursor.PickUp( pickupData.objectSource, pickupData.sourceSlot, pickupData.objectId,
                           pickupData.iconId, pickupData.autoOnLButtonUp, pickupData.stackAmount )
                            
            TalismanMakingWindow.RemoveVirtualItemSlot( slotNum )
            RemoveCraftingItem( GameData.TradeSkills.TALISMAN, sourceSlot, pickupData.backpack )
            Sound.Play( Sound.APOTHECARY_ITEM_REMOVED )
        end
    end
end

function TalismanMakingWindow.OnSlotRButtonUp()
    if Cursor.IconOnCursor() then
        Cursor.Clear()
    else
        local slotNum = WindowGetId( SystemData.ActiveWindow.name )
        if(TalismanMakingWindow.craftingData[ slotNum ] and TalismanMakingWindow.craftingData[ slotNum ].sourceSlot )
        then
            local backpackSlot = TalismanMakingWindow.craftingData[ slotNum ].sourceSlot
            local backpackType = TalismanMakingWindow.craftingData[ slotNum ].backpack
            if( backpackSlot == nil or
                slotNum == nil )
            then
                return
            end
            
            -- Remove the virtual item information and then send to the
            -- server that we wish to remove this item 
            TalismanMakingWindow.RemoveVirtualItemSlot( slotNum )
            TalismanMakingWindow.RemoveItem( backpackSlot, slotNum, backpackType )
            TalismanMakingWindow.craftingData[ slotNum ] = {}
        end
    end
end

function TalismanMakingWindow.Perform()
    if (not TalismanMakingWindow.PerformingLock) then
      if( not ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) )
      then
          PerformCrafting( GameData.TradeSkills.TALISMAN, 1 )
          TalismanMakingWindow.PerformingLock = true
      end
    end
end
                
function TalismanMakingWindow.OnSlotMouseOver()
    local slotNum = WindowGetId( SystemData.ActiveWindow.name )

    if( TalismanMakingWindow.craftingData[ slotNum ] and TalismanMakingWindow.craftingData[ slotNum ].sourceSlot )
    then
        local backpackSlot = TalismanMakingWindow.craftingData[ slotNum ].sourceSlot
        local backpackType = TalismanMakingWindow.craftingData[ slotNum ].backpack
        local inventory = EA_Window_Backpack.GetItemsFromBackpack( backpackType )
        local itemData = inventory[ backpackSlot ]
        if ((nil    ~= itemData)    and 
            (nil    ~= itemData.id) and
            (0      ~= itemData.id))
        then     
            Tooltips.CreateItemTooltip (itemData, SystemData.ActiveWindow.name, Tooltips.ANCHOR_WINDOW_RIGHT, true, GetString( StringTables.Default.TEXT_R_CLICK_TO_REMOVE ), Tooltips.COLOR_WARNING )
        end
    else
        -- Create a tooltip for the empty spot
        Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, TalismanMakingWindow.SlotToolTipText[ slotNum ] )
        Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT )
    end
end    

function TalismanMakingWindow.ItemIsAllowedInSlot( itemData, slotNum )
    local isValid, resourceType = IsItemValidForSlot( itemData, slotNum )
    return isValid
end


function TalismanMakingWindow.PlaySoundForUpdatedSlot( itemData, slotNum )

	if( TalismanMakingWindow.ItemIsAllowedInSlot( itemData, slotNum ) and
	    CraftingSystem.PlayerMeetsCraftingRequirement( itemData, GameData.TradeSkills.APOTHECARY ) ) then 
			
		Sound.Play(TalismanMakingWindow.SlotSounds[slotNum])

	else
		-- play an error sound
		Sound.Play( Sound.APOTHECARY_ADD_FAILED )	
	end
end

function TalismanMakingWindow.Done()
    TalismanMakingWindow.Hide()
end

function TalismanMakingWindow.OnMouseOverPowerMeter()
    local powerRangeData = TalismanMakingWindow.PowerRangeInfo[TalismanMakingWindow.powerRange]
    if( powerRangeData )
    then
        Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, nil )
        Tooltips.SetTooltipText( 1, 1, GetString( StringTables.Default.LABEL_POWER_METER ) )
        Tooltips.SetTooltipText( 2, 1, powerRangeData.text )
        Tooltips.SetTooltipColorDef( 2, 1, powerRangeData.color )
        Tooltips.SetTooltipText( 3, 1, L" " )
        Tooltips.Finalize()
        Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT )
    end
end

function TalismanMakingWindow.AutoAddItem( backpackSlot, itemData, backpackType )
    local tryToAdd
    local craftingSlot
    tryToAdd, craftingSlot = TalismanMakingWindow.WouldBePossibleToAdd( itemData )
    if( tryToAdd == true )
    then
        TalismanMakingWindow.AddItem( backpackSlot, craftingSlot, backpackType )
    end
end

function TalismanMakingWindow.WouldBePossibleToAdd( itemData )
    local craftingSlot
    local craftingTypes, resourceType, requirement = CraftingSystem.GetCraftingData( itemData )
    if ( resourceType == TalismanMakingWindow.TALISMAN_CONTAINER )
    then
        craftingSlot = TalismanMakingWindow.SLOT_CONTAINER
    elseif ( resourceType == TalismanMakingWindow.TALISMAN_FRAGMENT )
    then
        craftingSlot = TalismanMakingWindow.SLOT_DETERMINENT
    elseif ( resourceType == TalismanMakingWindow.TALISMAN_GOLD_ESSENCE )
    then
        craftingSlot = TalismanMakingWindow.SLOT_GOLD
    elseif ( resourceType == TalismanMakingWindow.TALISMAN_CURIOS )
    then
        craftingSlot = TalismanMakingWindow.SLOT_CURIOS
    elseif ( resourceType == TalismanMakingWindow.TALISMAN_MAGICAL_ESSENCE )
    then
        craftingSlot = TalismanMakingWindow.SLOT_MAGIC
    end
    
    if( craftingSlot )
    then
        return true, craftingSlot
    end
    return false
end

