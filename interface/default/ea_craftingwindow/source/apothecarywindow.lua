
ApothecaryWindow = {}
ApothecaryWindow.versionNumber = 0.1

ApothecaryWindow.craftingData = {}
ApothecaryWindow.maxResources = 4
ApothecaryWindow.PerformingLock = false

-- Static Info for each crafting skill
ApothecaryWindow.staticSkillInfo =
{
    icon = 259, -- TEMP: TODO: currently using temporary icon
    name = GetString( StringTables.Default.LABEL_SKILL_APOTHECARY ),
    commitLabel = GetString( StringTables.Default.LABEL_APOTHECARY_ACTION ),
}

ApothecaryWindow.windowName = "ApothecaryWindow"

local windowName = ApothecaryWindow.windowName

ApothecaryWindow.STATE_STABILITY_GOOD = GameData.CraftingSuccessChance.HIGH
ApothecaryWindow.STATE_STABILITY_MIDDLE = GameData.CraftingSuccessChance.MEDIUM
ApothecaryWindow.STATE_STABILITY_BAD = GameData.CraftingSuccessChance.LOW

ApothecaryWindow.stabilityAnimationDuration = 1 -- in seconds

ApothecaryWindow.stabilityCurrentState = ApothecaryWindow.STATE_STABILITY_MIDDLE


-- States that the Crafting Window can be in
ApothecaryWindow.STATE_INIT              = -1
ApothecaryWindow.STATE_NEED_CONTAINER    = GameData.CraftingStates.ADDCONTAINER
ApothecaryWindow.STATE_NEED_DETERMINENT  = GameData.CraftingStates.ADDDETERMINENT
ApothecaryWindow.STATE_NEED_RESOURCES    = GameData.CraftingStates.ADDINGREDIENT
ApothecaryWindow.STATE_VALID_RECIPE      = GameData.CraftingStates.VALID_RECIPE
ApothecaryWindow.STATE_SUCCESS           = GameData.CraftingStates.SUCCESS
ApothecaryWindow.STATE_SUCCESS_REPEAT    = GameData.CraftingStates.SUCCESS_REPEAT
ApothecaryWindow.STATE_FAIL              = GameData.CraftingStates.FAIL
ApothecaryWindow.STATE_PERFORMING        = GameData.CraftingStates.PERFORMING

-- Slots
ApothecaryWindow.SLOT_CONTAINER     = 0
ApothecaryWindow.SLOT_DETERMINENT   = 1
ApothecaryWindow.SLOT_INGREDIENT1   = 2
ApothecaryWindow.SLOT_INGREDIENT2   = 3
ApothecaryWindow.SLOT_INGREDIENT3   = 4

-- Product Type
ApothecaryWindow.PRODUCT_TYPE_GENERIC       = GameData.CraftingItemType.CONTAINER
ApothecaryWindow.PRODUCT_TYPE_GOLD_ESSENCE  = GameData.CraftingItemType.CONTAINER_ESSENCE
ApothecaryWindow.PRODUCT_TYPE_DYE           = GameData.CraftingItemType.CONTAINER_DYE

-- this is the clients list of backpack slots that are inserted into the interface
ApothecaryWindow.clientSlotList = { }

ApothecaryWindow.pendingAddItem = { backpackSlot = 0, slotNum = 0, backpack = EA_Window_Backpack.TYPE_INVENTORY }

ApothecaryWindow.DEFAULT_STATE = ApothecaryWindow.STATE_NEED_CONTAINER
ApothecaryWindow.currentState = ApothecaryWindow.DEFAULT_STATE

ApothecaryWindow.productType = ApothecaryWindow.PRODUCT_TYPE_GENERIC

ApothecaryWindow.SlotSounds  =
{
    [ApothecaryWindow.SLOT_CONTAINER]   = Sound.APOTHECARY_CONTAINER_ADDED,
    [ApothecaryWindow.SLOT_DETERMINENT] = Sound.APOTHECARY_DETERMINENT_ADDED,
    [ApothecaryWindow.SLOT_INGREDIENT1] = Sound.APOTHECARY_RESOURCE_ADDED,
    [ApothecaryWindow.SLOT_INGREDIENT2] = Sound.APOTHECARY_RESOURCE_ADDED,
    [ApothecaryWindow.SLOT_INGREDIENT3] = Sound.APOTHECARY_RESOURCE_ADDED,
}

ApothecaryWindow.StabilityToolTipText = 
{
    [ApothecaryWindow.STATE_STABILITY_GOOD]   = { text=GetString( StringTables.Default.TEXT_STABILITY_STABLE ),          color=Tooltips.COLOR_ACTION, orb="Green-Orb" },
    [ApothecaryWindow.STATE_STABILITY_MIDDLE] = { text=GetString( StringTables.Default.TEXT_STABILITY_RISKY ),           color=Tooltips.COLOR_ITEM_HIGHLIGHT, orb="Orange-Orb" },
    [ApothecaryWindow.STATE_STABILITY_BAD]    = { text=GetString( StringTables.Default.TEXT_STABILITY_HIGHLY_UNSTABLE ), color=Tooltips.COLOR_FAILS_REQUIREMENTS, orb="Red-Orb" },
}

-- The data that makes this window function like a state machine
ApothecaryWindow.stateData =
{
    [ApothecaryWindow.STATE_NEED_CONTAINER]   =
    {
        hintText = GetString( StringTables.Default.TEXT_CRAFTING_HINT_NEED_CONTAINER ),
        hintTextColor = DefaultColor.COLOR_NEED_CONTAINER,
        hintTextIconSlice = "White-Orb",
        disableCommitButton = true,
    },
    
    [ApothecaryWindow.STATE_NEED_DETERMINENT]   =
    { 
        hintText = 
        {
            [ApothecaryWindow.PRODUCT_TYPE_GENERIC] = GetString( StringTables.Default.TEXT_CRAFTING_HINT_NEED_DETERMINENT ),
            [ApothecaryWindow.PRODUCT_TYPE_GOLD_ESSENCE] = GetString( StringTables.Default.TEXT_CRAFTING_HINT_NEED_GOLD_WEED ),
            [ApothecaryWindow.PRODUCT_TYPE_DYE] = GetString( StringTables.Default.TEXT_CRAFTING_HINT_NEED_PIGMENT ),
        },
        hintTextColor = DefaultColor.COLOR_NEED_DETERMINENT,
        hintTextIconSlice = "Red-Orb",
        showIngredientSlots = true,
        disableCommitButton = true,
        showBeakerBackground = true,
        beakerBackgroundSlice = "Container-Background",
    },
    
    [ApothecaryWindow.STATE_NEED_RESOURCES]   =
    {
        hintText = 
        {
            [ApothecaryWindow.PRODUCT_TYPE_GENERIC] = GetString( StringTables.Default.TEXT_CRAFTING_HINT_NEED_RESOURCES ),
            [ApothecaryWindow.PRODUCT_TYPE_GOLD_ESSENCE] = GetString( StringTables.Default.TEXT_CRAFTING_HINT_NEED_GOLD_ESSENCE_INGREDIENTS ),
            [ApothecaryWindow.PRODUCT_TYPE_DYE] = GetString( StringTables.Default.TEXT_CRAFTING_HINT_NEED_FIXER ),
        },
        hintTextColor = DefaultColor.COLOR_NEED_INGREDIENTS,
        hintTextIconSlice = "Orange-Orb",
        showIngredientSlots = true,
        disableCommitButton = true,
        showBeakerBackground = true,
        beakerBackgroundSlice = "Filled-Container-Background",
    },
    
    [ApothecaryWindow.STATE_VALID_RECIPE]   =
    {
        hintText=
        {
            [ApothecaryWindow.STATE_STABILITY_GOOD] = GetString( StringTables.Default.TEXT_CRAFTING_HINT_WILL_SUCCEED ),
            [ApothecaryWindow.STATE_STABILITY_MIDDLE] = GetString( StringTables.Default.TEXT_CRAFTING_HINT_RISKY ),
            [ApothecaryWindow.STATE_STABILITY_BAD] = GetString( StringTables.Default.TEXT_CRAFTING_HINT_WILL_DEFINITELY_FAIL )
        },
        hintTextColor = DefaultColor.COLOR_NEED_STABILIZERS,
        hintTextIconSlice = "Green-Orb",
        showIngredientSlots = true,
        showStabilityMeter = true,
        showBeakerBackground = true,
        beakerBackgroundSlice = "Filled-Container-Background",
    },
    
    [ApothecaryWindow.STATE_SUCCESS]   =
    {
        hintText = GetString( StringTables.Default.TEXT_CRAFTING_HINT_CREATED_RECIPE ),
        hintTextColor = DefaultColor.COLOR_NEED_STABILIZERS,
        hintTextIconSlice = "Green-Orb",
        showIngredientSlots = true,
        disableCommitButton = true,
        showBeakerBackground = true,
        beakerBackgroundSlice = "Purple-Filled-Container-Background",
        sound = Sound.APOTHECARY_SUCCEEDED,
    },
    
    [ApothecaryWindow.STATE_SUCCESS_REPEAT]   =
    {
        hintText = GetString( StringTables.Default.TEXT_CRAFTING_HINT_CREATED_RECIPE ),
        hintTextColor = DefaultColor.COLOR_NEED_STABILIZERS,
        hintTextIconSlice = "Green-Orb",
        showIngredientSlots = true,
        showStabilityMeter = true,
        showBeakerBackground = true,
        beakerBackgroundSlice = "Purple-Filled-Container-Background",
        sound = Sound.APOTHECARY_SUCCEEDED,
    },
    
    [ApothecaryWindow.STATE_FAIL]   =
    {
        hintText= 
        {
            [GameData.CraftingError.NONE]           = GetString( StringTables.Default.TEXT_CRAFTING_HINT_FAILED_RECIPE ),
            [GameData.CraftingError.NOT_STABLE]     = GetString( StringTables.Default.TEXT_CRAFTING_HINT_FAILED_RECIPE ),
            [GameData.CraftingError.ITEM_DESTROYED] = GetString( StringTables.Default.TEXT_CRAFTING_HINT_FAILED_RECIPE_ITEM_DESTROYED ),
            [GameData.CraftingError.BACKPACK_FULL]  = GetString( StringTables.Default.TEXT_CRAFTING_HINT_BACKPACK_FULL ),
        },
        hintTextColor = DefaultColor.COLOR_NEED_DETERMINENT,
        hintTextIconSlice = "Red-Orb",
        showIngredientSlots = true,
        showStabilityMeter = true,
        disableCommitButton = true,
        showBeakerBackground = true,
        beakerBackgroundSlice = "Filled-Container-Background",
        sound = Sound.APOTHECARY_FAILED,
    },
    
    [ApothecaryWindow.STATE_PERFORMING]   =
    {
        hintText=
        {
            [ApothecaryWindow.STATE_STABILITY_GOOD] = GetString( StringTables.Default.TEXT_CRAFTING_HINT_WILL_SUCCEED ),
            [ApothecaryWindow.STATE_STABILITY_MIDDLE] = GetString( StringTables.Default.TEXT_CRAFTING_HINT_RISKY ),
            [ApothecaryWindow.STATE_STABILITY_BAD] = GetString( StringTables.Default.TEXT_CRAFTING_HINT_WILL_DEFINITELY_FAIL )
        },
        hintTextColor = DefaultColor.COLOR_NEED_STABILIZERS,
        hintTextIconSlice = "Green-Orb",
        showIngredientSlots = true,
        showStabilityMeter = true,
        showBeakerBackground = true,
        beakerBackgroundSlice = "Filled-Container-Background",
        sound = Sound.APOTHECARY_BREW_STARTED,
        disableCommitButton = true,
    },
}

local GenericEmptySlotToolTipText =
{
    [ApothecaryWindow.SLOT_CONTAINER]   = GetString( StringTables.Default.TOOLTIP_CONTAINER ),
    [ApothecaryWindow.SLOT_DETERMINENT] = GetString( StringTables.Default.TOOLTIP_MAIN_INGREDIENT ),
    [ApothecaryWindow.SLOT_INGREDIENT1] = GetString( StringTables.Default.TOOLTIP_INGREDIENT ),
    [ApothecaryWindow.SLOT_INGREDIENT2] = GetString( StringTables.Default.TOOLTIP_INGREDIENT ),
    [ApothecaryWindow.SLOT_INGREDIENT3] = GetString( StringTables.Default.TOOLTIP_INGREDIENT ),
}

local GoldEssenceEmptySlotToolTipText =
{
    [ApothecaryWindow.SLOT_CONTAINER]   = GetString( StringTables.Default.TOOLTIP_CONTAINER ),
    [ApothecaryWindow.SLOT_DETERMINENT] = GetString( StringTables.Default.TOOLTIP_APOTHECARY_GOLD_ESSENCE_MAIN_INGREDIENT ),
    [ApothecaryWindow.SLOT_INGREDIENT1] = GetString( StringTables.Default.TOOLTIP_APOTHECARY_GOLD_ESSENCE_INGREDIENT ),
    [ApothecaryWindow.SLOT_INGREDIENT2] = GetString( StringTables.Default.TOOLTIP_APOTHECARY_GOLD_ESSENCE_INGREDIENT ),
}

local DyeEmptySlotToolTipText =
{
    [ApothecaryWindow.SLOT_CONTAINER]   = GetString( StringTables.Default.TOOLTIP_CONTAINER ),
    [ApothecaryWindow.SLOT_DETERMINENT] = GetString( StringTables.Default.TOOLTIP_APOTHECARY_DYE_MAIN_INGREDIENT ),
    [ApothecaryWindow.SLOT_INGREDIENT1] = GetString( StringTables.Default.TOOLTIP_APOTHECARY_DYE_INGREDIENT ),
}

ApothecaryWindow.ProductData =
{
    [ApothecaryWindow.PRODUCT_TYPE_GENERIC] = 
    {
        numIngredientSlots = 3,
        emptySlotToolTip = GenericEmptySlotToolTipText,
    },
    
    [ApothecaryWindow.PRODUCT_TYPE_GOLD_ESSENCE] =
    {
        numIngredientSlots = 2,
        emptySlotToolTip = GoldEssenceEmptySlotToolTipText,
        validRecipeToolTip = GetString( StringTables.Default.HINT_TEXT_APOTHECARY_ESSENCE_CRAFTING_READY )
    },
    
    [ApothecaryWindow.PRODUCT_TYPE_DYE] =
    {
        numIngredientSlots = 1,
        emptySlotToolTip = DyeEmptySlotToolTipText,
        validRecipeToolTip = GetString( StringTables.Default.HINT_TEXT_APOTHECARY_DYE_MAKING_READY )
    },
}

-- Set the default tool tip table
ApothecaryWindow.EmptySlotToolTipText = ApothecaryWindow.ProductData[ApothecaryWindow.PRODUCT_TYPE_GENERIC].emptySlotToolTip

function ApothecaryWindow.Initialize()

    local uiScale = InterfaceCore.GetScale()

    RegisterEventHandler( SystemData.Events.PLAYER_INVENTORY_SLOT_UPDATED, "ApothecaryWindow.UpdateLock")  
    RegisterEventHandler( SystemData.Events.PLAYER_CRAFTING_SLOT_UPDATED, "ApothecaryWindow.UpdateLock")      
    ApothecaryWindow.stabilityAnimationPoints =
    {
        [ApothecaryWindow.STATE_STABILITY_GOOD] =   {startX=-9, startY=uiScale * 5,  stopX=-9, stopY=uiScale * 24},
        [ApothecaryWindow.STATE_STABILITY_MIDDLE] = {startX=-9, startY=uiScale * 45, stopX=-9, stopY=uiScale * 65},
        [ApothecaryWindow.STATE_STABILITY_BAD] =    {startX=-9, startY=uiScale * 90, stopX=-9, stopY=uiScale * 109}
    }
    ApothecaryWindow.Clear()
end

function ApothecaryWindow.OnShown()
    ApothecaryWindow.Clear()
end

function ApothecaryWindow.OnHidden()
    if( SystemData.InputProcessed.EscapeKey == false )
    then
        Sound.Play( Sound.WINDOW_CLOSE )
    
        WindowUtils.RemoveFromOpenList( windowName )
    
        ApothecaryWindow.Hide()
    end
end

function ApothecaryWindow.UpdateLock()
  ApothecaryWindow.PerformingLock = false
  ButtonSetPressedFlag( windowName.."CommitButton", false )    
end


function ApothecaryWindow.SetStaticData()
    local skillLevel = GameData.CraftingStatus.SkillLevel
    local skillText = GetString( StringTables.Default.LABEL_SKILL )..L": "..skillLevel
    LabelSetText(windowName.."Skill", skillText )
    LabelSetText(windowName.."TitleBarText", ApothecaryWindow.staticSkillInfo.name )
    ButtonSetText(windowName.."CommitButton", ApothecaryWindow.staticSkillInfo.commitLabel )
    DynamicImageSetTextureSlice( windowName.."ContainerSlotOrb",   "White-Orb" )
    DynamicImageSetTextureSlice( windowName.."DeterminentSlotOrb", "Red-Orb" )      
end

local function ShowIngredientSlots( show, numSlots )
    WindowSetShowing( windowName.."DeterminentSlot", show )
    
    for index=1, 3
    do
        local showSlot = show and numSlots >= index
        WindowSetShowing( windowName.."Bottle"..index, showSlot )
        WindowSetShowing( windowName.."Resource"..index.."Slot", showSlot )
    end
end

local function GetProductType( container )
    local returnType = ApothecaryWindow.PRODUCT_TYPE_GENERIC
    if( container and container.sourceSlot )
    then
        -- Get the product type for the container]
        local itemData = EA_Window_Backpack.GetItemsFromBackpack( container.sourceBackpack )[container.sourceSlot]
        if( itemData )
        then
            craftingTypes, returnType, requirement = CraftingSystem.GetCraftingData( itemData )
        end
    end
    
    return returnType
end

-- This is where all the magic happens
function ApothecaryWindow.SetStateData()
    local stateData = ApothecaryWindow.stateData[ApothecaryWindow.currentState]
    if( stateData == nil )
    then
        return
    end
    -- Run all the state functions based on the state data
    
    -- Set the skill level text
    local skillLevel = GameData.CraftingStatus.SkillLevel
    local skillText = GetString( StringTables.Default.LABEL_SKILL )..L": "..skillLevel
    LabelSetText(windowName.."Skill", skillText )
    
    -- Get the container slot if there is one
    local container = ApothecaryWindow.craftingData[ ApothecaryWindow.SLOT_CONTAINER ]
    if( container and container.objectId == 0 )
    then
        container = nil
    end
    
    -- Cache off the product type
    ApothecaryWindow.productType = GetProductType( container )
    local productData = ApothecaryWindow.ProductData[ApothecaryWindow.productType]
    
    -- Set the tool tips for the empty slots
    ApothecaryWindow.EmptySlotToolTipText = productData.emptySlotToolTip
    
    -- Show/Hide the ingredient slots
    ShowIngredientSlots( stateData.showIngredientSlots == true and container ~= nil, productData.numIngredientSlots )

    -- Set the beaker background
    WindowSetShowing( windowName.."ApothecaryBackgroundBeaker", stateData.showBeakerBackground == true )
    if( stateData.showBeakerBackground )
    then
        DynamicImageSetTextureSlice( windowName.."ApothecaryBackgroundBeaker",   stateData.beakerBackgroundSlice )
    end
    
    -- Show/Hide the commit button
    ButtonSetDisabledFlag( windowName.."CommitButton", stateData.disableCommitButton == true)
    
    -- Set the text of the commit button 
    ButtonSetText(windowName.."CommitButton", ApothecaryWindow.staticSkillInfo.commitLabel )

    if( ApothecaryWindow.currentState == ApothecaryWindow.STATE_SUCCESS or 
        ApothecaryWindow.currentState == ApothecaryWindow.STATE_SUCCESS_REPEAT )
    then
            -- if the last brew was successful but we don't have any main ingredient slotted,
            -- then disable the brew button
        if( ApothecaryWindow.clientSlotList[ApothecaryWindow.SLOT_DETERMINENT] == nil )
        then
            ButtonSetDisabledFlag( windowName.."CommitButton", true )
        end
    end
    
    -- Set the hint text
    -- The valid recipe state and the performing state are a little different than the others, they have their own states,
    -- based on the state of the stability meter.
    -- The need determinent and need ingredient states are also different because of the different
    -- products that the apothecary can make
    -- This probably should go into an update function that is unique or can be unique for each state... 
    local displayString = stateData.hintText
    local color = stateData.hintTextColor
    local iconSlice = stateData.hintTextIconSlice
    if ( ApothecaryWindow.currentState == ApothecaryWindow.STATE_VALID_RECIPE or
         ApothecaryWindow.currentState == ApothecaryWindow.STATE_PERFORMING )
    then
        if( ApothecaryWindow.productType == ApothecaryWindow.PRODUCT_TYPE_GENERIC or ApothecaryWindow.productType == nil)
        then
            displayString = stateData.hintText[ApothecaryWindow.stabilityCurrentState]
            color  = ApothecaryWindow.StabilityToolTipText[ApothecaryWindow.stabilityCurrentState].color
            iconSlice = ApothecaryWindow.StabilityToolTipText[ApothecaryWindow.stabilityCurrentState].orb
        else
            if( productData.validRecipeToolTip )
            then
                displayString = productData.validRecipeToolTip
            end
            color  = ApothecaryWindow.StabilityToolTipText[ApothecaryWindow.STATE_STABILITY_GOOD].color
            iconSlice = ApothecaryWindow.StabilityToolTipText[ApothecaryWindow.STATE_STABILITY_GOOD].orb
        end
    elseif( ApothecaryWindow.currentState == ApothecaryWindow.STATE_NEED_RESOURCES or
            ApothecaryWindow.currentState == ApothecaryWindow.STATE_NEED_DETERMINENT )
    then
        displayString = stateData.hintText[ApothecaryWindow.productType]
    elseif( ApothecaryWindow.currentState == ApothecaryWindow.STATE_FAIL )
    then
        displayString = stateData.hintText[GameData.CraftingStatus.ErrorCode]
        if( GameData.CraftingStatus.ErrorCode == GameData.CraftingError.ITEM_DESTROYED )
        then
            Sound.Play( stateData.sound ) -- Needs to be a crashing sound
        elseif( GameData.CraftingStatus.ErrorCode == GameData.CraftingError.BACKPACK_FULL )
        then
            ButtonSetDisabledFlag( windowName.."CommitButton", false)
        end
    end
    
    -- Finally set the hint text, color, and icon
    LabelSetTextColor( windowName.."HintText", color.r, color.g, color.b )
    LabelSetText( windowName.."HintText", displayString )
    DynamicImageSetTextureSlice( windowName.."HintTextIcon", iconSlice )
    
    -- Show/Hide the stability-ometer
    WindowSetShowing( windowName.."StabilityMeter", stateData.showStabilityMeter == true
                                                    and ApothecaryWindow.productType ~= ApothecaryWindow.PRODUCT_TYPE_DYE
                                                    and ApothecaryWindow.productType ~= ApothecaryWindow.PRODUCT_TYPE_GOLD_ESSENCE )
    
    -- Update the timer
    if( ApothecaryWindow.currentState == ApothecaryWindow.STATE_PERFORMING )
    then
        ApothecaryWindow.UpdateTimerBar()
    end
    
    -- play any sounds
    if( stateData.sound and GameData.CraftingStatus.ErrorCode ~= GameData.CraftingError.ITEM_DESTROYED)
    then
        Sound.Play( stateData.sound )
    end
end

function ApothecaryWindow.UpdateTimerBar()
    local str = GetString( StringTables.Default.LABEL_BREWING )
    LayerTimerWindow.SetActionName( GetString( StringTables.Default.LABEL_BREWING ) )
end

function ApothecaryWindow.Clear()
    ApothecaryWindow.craftingData = {}
    ApothecaryWindow.currentState = ApothecaryWindow.STATE_INIT
    ApothecaryWindow.SetState( ApothecaryWindow.DEFAULT_STATE )

    ApothecaryWindow.usedResources = 0
    ApothecaryWindow.stabilityCurrentState = ApothecaryWindow.STATE_STABILITY_MIDDLE
    ApothecaryWindow.nextFreeSlot = 0
    ApothecaryWindow.pendingAddItem = { backpackSlot = 0, slotNum = 0, backpack = EA_Window_Backpack.TYPE_INVENTORY }
    ApothecaryWindow.clientSlotList = {}
    ApothecaryWindow.productType = ApothecaryWindow.PRODUCT_TYPE_GENERIC
    
    for index=0,ApothecaryWindow.maxResources do
        ApothecaryWindow.SetCraftingSlotIcon( index )
    end
end

function ApothecaryWindow.SetState( newState )
   -- Update any changes in stability
   ApothecaryWindow.SetStabilityState( GameData.CraftingStatus.SuccessChance )
   ApothecaryWindow.UpdateStabilityAnimation()
    
   if( newState == nil or
       newState > ApothecaryWindow.STATE_PERFORMING or
       newState < ApothecaryWindow.STATE_NEED_CONTAINER )
   then
      return
   end
   
   ApothecaryWindow.currentState = newState
   ApothecaryWindow.SetStateData()
end

function ApothecaryWindow.SetStabilityState( newState )
    if( newState == nil or
        newState == ApothecaryWindow.stabilityCurrentState or
        newState > ApothecaryWindow.STATE_STABILITY_GOOD or
        newState < ApothecaryWindow.STATE_STABILITY_BAD )
    then
        return
    end

    ApothecaryWindow.stabilityCurrentState = newState
end

function ApothecaryWindow.UpdateStabilityAnimation()
    WindowStopPositionAnimation( windowName.."StabilityMeterSlider" )
    
    local currentAnimationPoints = ApothecaryWindow.stabilityAnimationPoints[ApothecaryWindow.stabilityCurrentState]
    
    WindowStartPositionAnimation( windowName.."StabilityMeterSlider",
                                  Window.AnimationType.LOOP,
                                  currentAnimationPoints.startX,
                                  currentAnimationPoints.startY,
                                  currentAnimationPoints.stopX,
                                  currentAnimationPoints.stopY,
                                  ApothecaryWindow.stabilityAnimationDuration,
                                  false, 0, 0 ) 
end

local function UpdateBackpackLocks( backpackSlotsUsed )
    EA_BackpackUtilsMediator.ReleaseAllLocksForWindow( windowName )
    
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

function ApothecaryWindow.Show()
    --The rest of this is handled in the crafting system
    SendInitCrafting( GameData.TradeSkills.APOTHECARY )
    EA_BackpackUtilsMediator.EnableSoftLocks(true)
end

function ApothecaryWindow.Hide()
    --The rest of this is handled in the crafting system
    WindowStopPositionAnimation( windowName.."StabilityMeterSlider" )
    ApothecaryWindow.Clear()
    SendCloseCrafting( GameData.TradeSkills.APOTHECARY )
    ApothecaryWindow.nextFreeSlot = 0
    UpdateBackpackLocks( {} ) -- empty table
    EA_BackpackUtilsMediator.EnableSoftLocks(false)
end

function ApothecaryWindow.UpdateCraftingStatus( updatedIngredients )

    -- The state has already changed in the crafting system
    local backpackSlotsUsed = {}
    local finalSlotList = {}
    local craftingSlot = nil

    for serverIndex, ingredient in pairs( updatedIngredients )
    do
        local itemFoundOnClient = false
        for clientIndex, clientBackpackSlot in pairs( ApothecaryWindow.clientSlotList )
        do
        
            if ( ingredient.slot == clientBackpackSlot.slot )
            then
                itemFoundOnClient = true
                craftingSlot = clientIndex
            end
        end
        
        if( itemFoundOnClient )
        then
            -- copy clientBackpackSlot into finalSlotList in the same slot as it was on the clientSlotList
            finalSlotList[craftingSlot] = ApothecaryWindow.clientSlotList[craftingSlot]            
            -- Remove the clientBackpackSlot from the clientSlotList so it won't get added twice
            ApothecaryWindow.clientSlotList[craftingSlot] = nil
        else
            -- Not found on the client, so inserting it to a proper slot
            local itemData = EA_Window_Backpack.GetItemsFromBackpack( ingredient.backpack )[ingredient.slot]            
            local _, resourceType = CraftingSystem.GetCraftingData( itemData )
            if (resourceType == GameData.CraftingItemType.CONTAINER)
            then
                finalSlotList[ApothecaryWindow.SLOT_CONTAINER]= ingredient
            elseif( resourceType == GameData.CraftingItemType.MAIN_INGREDIENT or
				resourceType == GameData.CraftingItemType.PIGMENT )
            then
                finalSlotList[ApothecaryWindow.SLOT_DETERMINENT] = ingredient
            else
                for ingredientSlot = ApothecaryWindow.SLOT_INGREDIENT1, ApothecaryWindow.SLOT_INGREDIENT3
                do
                    if( finalSlotList[ingredientSlot] == nil )
                    then
                        finalSlotList[ingredientSlot] = ingredient
                        break
                    end
                end                     
            end
        end
    end
    
    -- Clear everything
    for index = 0, ApothecaryWindow.maxResources
    do
        ApothecaryWindow.craftingData[ index ] = {}
        ApothecaryWindow.SetCraftingSlotIcon( index, nil, false )
    end
    
    -- Add in everything from the finalSlotList
    for index, backpackSlot in pairs( finalSlotList )
    do
        local itemData = EA_Window_Backpack.GetItemsFromBackpack( backpackSlot.backpack )[backpackSlot.slot]
        local validItem = DataUtils.IsValidItem( itemData )
        local isAllowed = ApothecaryWindow.ItemIsAllowedInSlot( itemData, index )

        if( validItem and isAllowed )
        then
            -- track how many of each inventory item we are using
            if( not backpackSlotsUsed[backpackSlot.backpack] or not backpackSlotsUsed[backpackSlot.backpack][ backpackSlot.slot ] )
            then
                if( not backpackSlotsUsed[backpackSlot.backpack] )
                then
                    backpackSlotsUsed[backpackSlot.backpack] = {}
                end
                backpackSlotsUsed[backpackSlot.backpack][ backpackSlot.slot ] = 1
            else
                backpackSlotsUsed[backpackSlot.backpack][ backpackSlot.slot ] = backpackSlotsUsed[backpackSlot.backpack][ backpackSlot.slot ] + 1
            end
            
            local cursorType = EA_Window_Backpack.GetCursorForBackpack( backpackSlot.backpack )
            
            ApothecaryWindow.craftingData[ index ] = 
            {
                objectSource = cursorType,
                sourceSlot = backpackSlot.slot,
                sourceBackpack = backpackSlot.backpack,
                objectId = itemData.uniqueID,
                iconId = itemData.iconNum,
                autoOnLButtonUp = true,
                stackAmount = itemData.stackCount
            }
            ApothecaryWindow.SetCraftingSlotIcon( index, itemData.iconNum, validItem )
        else
            -- This should not really happen, clear and it should be fixed next round
            finalSlotList[index] = nil
        end
    end
    
    -- Update the client list to what is actualy displayed
    ApothecaryWindow.clientSlotList = {}
    for index, backpackSlot in pairs( finalSlotList )
    do
        ApothecaryWindow.clientSlotList[index] = { slot = backpackSlot.slot, backpack = backpackSlot.backpack }
    end
 
    -- Add any pending items
    if ( ApothecaryWindow.pendingAddItem.backpackSlot ~= 0 )
    then
        ApothecaryWindow.AddItem( ApothecaryWindow.pendingAddItem.backpackSlot, ApothecaryWindow.pendingAddItem.slotNum, ApothecaryWindow.pendingAddItem.backpack )
        ApothecaryWindow.pendingAddItem = { backpackSlot = 0, slotNum = 0, backpack = EA_Window_Backpack.TYPE_INVENTORY }
    end
    
    -- We have no container... clear everything
    if( ApothecaryWindow.clientSlotList[ApothecaryWindow.SLOT_CONTAINER] == nil)
    then
        backpackSlotsUsed = {}
        ApothecaryWindow.Clear()
    end
    
    UpdateBackpackLocks( backpackSlotsUsed )
end

function ApothecaryWindow.SetCraftingSlotIcon( slotNum, icon, validItem )
    if( slotNum < 0 or slotNum > ApothecaryWindow.maxResources )
    then
        return
    end
    
    local buttonName = ""
    if( slotNum == 0 )
    then
        buttonName = "ContainerSlot"
    elseif( slotNum == 1 )
    then
        buttonName = "DeterminentSlot"
    else
        buttonName = "Resource"..(slotNum-1).."Slot"
        WindowSetShowing( windowName.."Bottle"..(slotNum-1).."Top", not validItem )
    end
    
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

    WindowSetShowing(windowName..buttonName.."Disabled", not iconValid )
    WindowSetShowing(windowName..buttonName.."Orb", not iconValid )
    DynamicImageSetTexture ( windowName..buttonName.."IconBase", texture, x, y )
end

function ApothecaryWindow.AddItem( backpackSlot, slotNum, backpackType )

    ApothecaryWindow.clientSlotList[slotNum] = { slot = backpackSlot, backpack = backpackType }
    
    if( slotNum == ApothecaryWindow.SLOT_CONTAINER)
    then
        AddCraftingContainer( GameData.TradeSkills.APOTHECARY, backpackSlot, backpackType )
    else
        AddCraftingItem( GameData.TradeSkills.APOTHECARY, slotNum, backpackSlot, backpackType )
    end
    
    -- play sound based on the cultivationType of the item
    local itemData = EA_Window_Backpack.GetItemsFromBackpack( backpackType )[backpackSlot]
    ApothecaryWindow.PlaySoundForUpdatedSlot( itemData, slotNum )
end

function ApothecaryWindow.OnRButtonUp()
    EA_Window_ContextMenu.CreateOpacityOnlyContextMenu( windowName )
    if Cursor.IconOnCursor() then
        Cursor.Clear()
    end
end

function ApothecaryWindow.OnSlotLButtonUp()
    if( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) or ApothecaryWindow.currentState == ApothecaryWindow.STATE_PERFORMING )
    then
        return
    end
    
    local backpackType = EA_Window_Backpack.currentMode
    local cursorType = EA_Window_Backpack.GetCursorForBackpack( backpackType )
    
    if Cursor.IconOnCursor() then
        if( cursorType ~= Cursor.Data.Source )
        then
            return
        end
        
        local slotNum = WindowGetId( SystemData.ActiveWindow.name )
        
        -- Pickup what is there if there is anything
        local pickupData = ApothecaryWindow.craftingData[ slotNum ]
        local backpackSourceSlot = Cursor.Data.SourceSlot
        
        if( pickupData and pickupData.sourceSlot )
        then
            -- Swap items with whatever is on the cursor
            local sourceSlot = pickupData.sourceSlot
            ApothecaryWindow.pendingAddItem.backpackSlot = backpackSourceSlot
            ApothecaryWindow.pendingAddItem.slotNum = slotNum
            ApothecaryWindow.pendingAddItem.backpack = backpackType
            
            -- We will request to remove it here and then add it again if there is any pending item data in the update
            Cursor.PickUp( pickupData.objectSource, pickupData.sourceSlot, pickupData.objectId,
                            pickupData.iconId, pickupData.autoOnLButtonUp, pickupData.stackAmount )
                
            ApothecaryWindow.clientSlotList[slotNum] = nil 
            RemoveCraftingItem( GameData.TradeSkills.APOTHECARY, sourceSlot, backpackType )
            Sound.Play( Sound.APOTHECARY_ITEM_REMOVED )
        else
            -- Add the item
			local itemData = EA_Window_Backpack.GetItemsFromBackpack( backpackType )[backpackSourceSlot]
			local validItem = DataUtils.IsValidItem( itemData )
			local isAllowed = ApothecaryWindow.ItemIsAllowedInSlot( itemData, slotNum )
			
            if( validItem and isAllowed )
			then
                ApothecaryWindow.AddItem( backpackSourceSlot, slotNum, backpackType )
            end
        
            Cursor.Clear()
        end
    end
end

function ApothecaryWindow.OnSlotRButtonUp()
    if ( Cursor.IconOnCursor() )
    then
        Cursor.Clear()
    elseif( ApothecaryWindow.currentState == ApothecaryWindow.STATE_PERFORMING )
    then
        return
    else
        local slotNum = WindowGetId( SystemData.ActiveWindow.name )
        if(ApothecaryWindow.craftingData[ slotNum ] and ApothecaryWindow.craftingData[ slotNum ].sourceSlot )
        then
            local backpackSlot = ApothecaryWindow.craftingData[ slotNum ].sourceSlot
            local backpackType = ApothecaryWindow.craftingData[ slotNum ].sourceBackpack
            if( backpackSlot == nil or
                slotNum == nil )
            then
                return
            end
                        
            -- Remove the client item information and then send to the
            -- server that we wish to remove this item
            ApothecaryWindow.clientSlotList[slotNum] = nil
            
            RemoveCraftingItem(GameData.TradeSkills.APOTHECARY, backpackSlot, backpackType )
            Sound.Play( Sound.APOTHECARY_ITEM_REMOVED )
        end
    end
end

function ApothecaryWindow.Perform()
    if (not ApothecaryWindow.PerformingLock) then 
   
      if( not ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) )
      then        
          PerformCrafting( GameData.TradeSkills.APOTHECARY, 1 )
          ApothecaryWindow.PerformingLock = true
      end
    end
end
                
function ApothecaryWindow.OnSlotMouseOver() 
    local slotNum = WindowGetId( SystemData.ActiveWindow.name )

    if( ApothecaryWindow.craftingData[ slotNum ] and ApothecaryWindow.craftingData[ slotNum ].sourceSlot )
    then
        local slot = ApothecaryWindow.craftingData[ slotNum ].sourceSlot
        local backpackType = ApothecaryWindow.craftingData[ slotNum ].sourceBackpack
        local itemData = EA_Window_Backpack.GetItemsFromBackpack( backpackType )[slot]
        if ((nil    ~= itemData)    and 
            (nil    ~= itemData.id) and
            (0      ~= itemData.id))
        then     
            Tooltips.CreateItemTooltip (itemData, SystemData.ActiveWindow.name, Tooltips.ANCHOR_WINDOW_RIGHT, true, GetString( StringTables.Default.TEXT_R_CLICK_TO_REMOVE ), Tooltips.COLOR_WARNING )
        end
    else
        local tooltipText = ApothecaryWindow.EmptySlotToolTipText[ slotNum ]
        if( tooltipText )
        then
            -- Create a tooltip for the empty spot
            Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, tooltipText )
            Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT )
        end
    end
end    

function ApothecaryWindow.ItemIsAllowedInSlot( itemData, slotNum )

    if not CraftingSystem.IsCraftingItem( itemData, GameData.TradeSkills.APOTHECARY  )
    then
        return false
    end 

    local craftingTypes, resourceType = CraftingSystem.GetCraftingData( itemData )

    if ( resourceType == GameData.CraftingItemType.CONTAINER or 
        resourceType == GameData.CraftingItemType.CONTAINER_DYE )
    then
        return slotNum == ApothecaryWindow.SLOT_CONTAINER
        
    elseif( resourceType == GameData.CraftingItemType.MAIN_INGREDIENT or 
		resourceType == GameData.CraftingItemType.PIGMENT )
	then
        return slotNum == ApothecaryWindow.SLOT_DETERMINENT
    
    -- now that we've elminated containers and main ingredients, 
    --   anything in the valid range should just be a normal ingredient
    elseif ( resourceType >= GameData.CraftingItemType.MIN_CRAFTING_ITEM_NUM and
             resourceType <= GameData.CraftingItemType.MAX_CRAFTING_ITEM_NUM ) then
       
       return( slotNum == ApothecaryWindow.SLOT_INGREDIENT1 or
               slotNum == ApothecaryWindow.SLOT_INGREDIENT2 or
               slotNum == ApothecaryWindow.SLOT_INGREDIENT3 ) 
    end
    
    return false
end


function ApothecaryWindow.PlaySoundForUpdatedSlot( itemData, slotNum )

    if( ApothecaryWindow.ItemIsAllowedInSlot( itemData, slotNum ) and
        CraftingSystem.PlayerMeetsCraftingRequirement( itemData, GameData.TradeSkills.APOTHECARY ) ) then 

        Sound.Play(ApothecaryWindow.SlotSounds[slotNum])
    else
        -- play an error sound
        Sound.Play( Sound.APOTHECARY_ADD_FAILED )	
    end
end

function ApothecaryWindow.OnMouseOverStability()
    local stabilityData = ApothecaryWindow.StabilityToolTipText[ApothecaryWindow.stabilityCurrentState]
    if( stabilityData )
    then
        Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, nil )
        Tooltips.SetTooltipText( 1, 1, GetString( StringTables.Default.LABEL_UNSTABILITY_OMETER ) )
        Tooltips.SetTooltipText( 2, 1, stabilityData.text )
        Tooltips.SetTooltipColorDef( 2, 1, stabilityData.color )
        Tooltips.SetTooltipText( 3, 1, L" " )
        Tooltips.Finalize()
        Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT )
    end
    
end

function ApothecaryWindow.Done()
    ApothecaryWindow.Hide()
end

function ApothecaryWindow.AutoAddItem( backpackSlot, itemData, backpackType )
    local tryToAdd
    local craftingSlot
    tryToAdd, craftingSlot = ApothecaryWindow.WouldBePossibleToAdd( itemData )
    if( tryToAdd == true )
    then
        ApothecaryWindow.AddItem( backpackSlot, craftingSlot, backpackType )
    end
end

function ApothecaryWindow.WouldBePossibleToAdd( itemData )
    local craftingSlot
    local craftingTypes, resourceType, requirement = CraftingSystem.GetCraftingData( itemData )
    if ( resourceType == GameData.CraftingItemType.CONTAINER or
        resourceType == GameData.CraftingItemType.CONTAINER_DYE )
    then
        craftingSlot = ApothecaryWindow.SLOT_CONTAINER
    elseif ( resourceType == GameData.CraftingItemType.MAIN_INGREDIENT or
		resourceType == GameData.CraftingItemType.PIGMENT )
    then
        craftingSlot = ApothecaryWindow.SLOT_DETERMINENT
    elseif ( resourceType >= GameData.CraftingItemType.MIN_CRAFTING_ITEM_NUM and
             resourceType <= GameData.CraftingItemType.MAX_CRAFTING_ITEM_NUM )
    then
       
        for ingredientSlot = ApothecaryWindow.SLOT_INGREDIENT1, ApothecaryWindow.SLOT_INGREDIENT3
        do
            if( ApothecaryWindow.clientSlotList[ingredientSlot] == nil )
            then
                craftingSlot = ingredientSlot
                break
            end
        end
    end
    
    if( craftingSlot )
    then
        return true, craftingSlot
    end
    
    return false
end

