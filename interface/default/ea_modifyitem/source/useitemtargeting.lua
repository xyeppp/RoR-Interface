----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

UseItemTargeting = {}
local g_teleportItemLocation


function UseItemTargeting.ItemIsDyable(itemData)
    local tintMasks = GetDyeTintMasks( itemData.id )
    return( itemData.flags[GameData.Item.EITEMFLAG_DYE_ABLE] == true and tintMasks ~= GameData.TintMasks.NONE and not itemData.broken )
end

function UseItemTargeting.ItemIsBleachable(itemData)
    return( UseItemTargeting.ItemIsDyable(itemData) and
            ( itemData.dyeTintA ~= 0 or itemData.dyeTintB ~= 0 ) )
end

function UseItemTargeting.ItemIsUnlockable(itemData)
    return( itemData.type == GameData.ItemTypes.TREASURE_CHEST )
end

--Please add your target mapping here when you right click on an item to use, if it
-- is used on something else, store the cursorIcon that it will change the cursor into
-- and what type of item template will bring up this targeting cursor
UseItemTargeting.targetMapping = {}
UseItemTargeting.targetMapping[1] = { name = "bleach", itemType = GameData.ItemTypes.DYE, defaultCursor = SystemData.InteractActions.DYE_DISABLED, testForValidTarget = UseItemTargeting.ItemIsBleachable, validTargetCursor = SystemData.InteractActions.DYE, dialogBoxText = StringTables.Default.TEXT_WANT_TO_BLEACH_ITEM }
UseItemTargeting.targetMapping[2] = { name = "dye", itemType = GameData.ItemTypes.DYE, defaultCursor = SystemData.InteractActions.DYE_DISABLED, testForValidTarget = UseItemTargeting.ItemIsDyable, validTargetCursor = SystemData.InteractActions.DYE, dialogBoxText = StringTables.Default.TEXT_WANT_TO_DYE }
UseItemTargeting.targetMapping[3] = { name = "key", itemType = GameData.ItemTypes.TREASURE_KEY, defaultCursor = SystemData.InteractActions.UNLOCK_DISABLED,   testForValidTarget = UseItemTargeting.ItemIsUnlockable, validTargetCursor = SystemData.InteractActions.UNLOCK, dialogBoxText = StringTables.Default.TEXT_WANT_TO_UNLOCK }
UseItemTargeting.TargetData = nil


----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

local function IsSpecialTargetCursor( sourceLocation, sourceSlot)
    -- Check to see if the item is a special target
    local itemData = DataUtils.GetItemData( sourceLocation, sourceSlot )
    if not DataUtils.IsValidItem( itemData ) then
        return false
    else
        local itemType = itemData.type
        
        --Check to see if the item selected to use, is any one of these special targets
        for index = 1, table.getn(UseItemTargeting.targetMapping) do
            local targetMap = UseItemTargeting.targetMapping[index]

            --If it is a special target return true
            if(targetMap.itemType == itemType) then
                if(targetMap.name == "bleach" ) then
                    if( itemData.tintA == 0 ) then
                        return true, index
                    end
                else
                    return true, index
                end
            end
        end
    end
    
    return false
end


--------------------------------------------------
-- Generic HandleUseItemTargeting
-- If this item can be used on another item, change the mouse cursor to the type of cursor you want it to be
--------------------------------------------------
function UseItemTargeting.HandleUseItemChangeTargetCursor(sourceLocation, sourceSlot)

    local itemData = UseItemTargeting.GetItemGivenLocAndSlot( sourceLocation, sourceSlot )
    if( not itemData )
    then
        return false
    end
    
    if(itemData.type == GameData.ItemTypes.TELEPORT) then
        UseItemTargeting.BeginTeleport(sourceSlot)
        return true
    elseif(itemData.type == GameData.ItemTypes.TREASURE_CHEST) then
        UseItemTargeting.UseChestItem(sourceSlot)
        return true
    end

    --Check to see if its a special target
    local specialTarget, targetIndex = IsSpecialTargetCursor( sourceLocation, sourceSlot)
    if(specialTarget) then
        local targetItem = UseItemTargeting.targetMapping[targetIndex]
        local canUseCondition = true

        local itemData = UseItemTargeting.GetItemGivenLocAndSlot(sourceLocation, sourceSlot)
        if not DataUtils.IsValidItem( itemData ) then
            return false
        end
    
        if( itemData.type == GameData.ItemTypes.DYE ) then
            canUseCondition = UseItemTargeting.CanUseDyeItem(sourceLocation, sourceSlot)
        end

        --If player pass the restriction, let the cursor change into the targeting cursor
        if( canUseCondition ) then
            -- Change mouse cursor to the icon they want to set the mouse cursor to ex: dye targeting cursor
            Cursor.StartTargetingRUp( sourceLocation, sourceSlot, targetIndex )
            SetDesiredInteractAction( targetItem.defaultCursor )
            return true
        end
    end
    
    --Return false if this handle use item doesn't do anything, so it will let the next function go through to try
    --to move the item into the selected inventory slot
    return false
end

function UseItemTargeting.GetItemGivenLocAndSlot(sourceLoc, sourceSlot)
    local itemData 
    
    if sourceLoc == Cursor.SOURCE_EQUIPMENT or sourceLoc == Cursor.SOURCE_INVENTORY then
        itemData = DataUtils.GetItemData(sourceLoc, sourceSlot)
    end 
    
    return itemData
end             

----------------------------------------------------------------
-- Functions 
-- These are used to handle any targeting interactions that needs to be done
-- with two items
----------------------------------------------------------------
function UseItemTargeting.HandleUseItemOnTarget(targetLoc, targetSlot)
    --Index of what targeting it is from
    local targetIndex = Cursor.TargetData.TargetMapId
    
    if( (targetIndex == nil) or (UseItemTargeting.targetMapping[targetIndex] == nil) ) then
        return
    end
    
    local acceptFunc = UseItemTargeting.SendingUseTargetItem
    
    --Set the targeted information
    Cursor.SetTargetedSlotData(targetLoc, targetSlot)
    UseItemTargeting.TargetData = Cursor.TargetData
    
    -- Fetch source and target item data
    local targetItemData = UseItemTargeting.GetItemGivenLocAndSlot(targetLoc, targetSlot)
    if(not DataUtils.IsValidItem(targetItemData)) then
        return
    end
    
    local sourceItemData = UseItemTargeting.GetItemGivenLocAndSlot(UseItemTargeting.TargetData.Source, UseItemTargeting.TargetData.SourceSlot)
    if(not DataUtils.IsValidItem(sourceItemData)) then
        return
    end
    
    -- Check for validity of using the given item on its target, depending on the type of items involved
    if(UseItemTargeting.targetMapping[targetIndex].itemType == GameData.ItemTypes.DYE) then
        --Make sure item is dyeable
        local tintMasks = GetDyeTintMasks( targetItemData.id )
        if( targetItemData.flags[GameData.Item.EITEMFLAG_DYE_ABLE] == false or tintMasks ==  GameData.TintMasks.NONE) then
            DialogManager.MakeOneButtonDialog(GetString( StringTables.Default.TEXT_CANNOT_DYE_ITEM) , GetString( StringTables.Default.LABEL_OKAY ), nil )
            return
        end
        
        if( tintMasks == GameData.TintMasks.BOTH )
        then
            ClearCursor()
            EA_DyeWindow.isBleach = targetIndex == 1
            EA_DyeWindow.Show()
            return
        end
        
        UseItemTargeting.PreviewDye( tintMask )    
        acceptFunc = UseItemTargeting.SendUseDye
        
    elseif(UseItemTargeting.targetMapping[targetIndex].itemType == GameData.ItemTypes.TREASURE_KEY) then
        if((targetItemData.type ~= GameData.ItemTypes.TREASURE_CHEST) or (sourceItemData.type ~= GameData.ItemTypes.TREASURE_KEY)) then
            return
        end

        if(targetItemData.tier > sourceItemData.tier) then
            DialogManager.MakeOneButtonDialog(GetStringFormat(StringTables.Default.TEXT_KEY_TIER_TOO_LOW, {sourceItemData.name, targetItemData.name}), GetString( StringTables.Default.LABEL_OKAY ), nil)
            return
        end
        
        acceptFunc = UseItemTargeting.SendUnlockTreasure
                
    end
    
    ClearCursor()
    
    local dialogText =""
    if( UseItemTargeting.targetMapping[targetIndex]~= nil) then
        dialogText = GetStringFormat(UseItemTargeting.targetMapping[targetIndex].dialogBoxText, {sourceItemData.name, targetItemData.name})
    end  

    --Send event to server telling server to use the source item on the target item if player selects yes
    DialogManager.MakeTwoButtonDialog( dialogText, 
                                       GetString( StringTables.Default.LABEL_YES ), acceptFunc, 
                                       GetString( StringTables.Default.LABEL_NO ),  UseItemTargeting.Cancel,
                                       nil, nil, nil, nil, DialogManager.TYPE_MODE_LESS )

end


function UseItemTargeting.HandleMouseOverItem( itemData )
    --DEBUG(L"HandleMouseOverItem")
    
    --Index of what interaction it is from
    local interactionIndex = Cursor.TargetData.TargetMapId
    if( not DataUtils.IsValidItem( itemData ) or 
        interactionIndex == nil or 
        UseItemTargeting.targetMapping[interactionIndex] == nil ) then
        
        return
    end
    
    local interactionType = UseItemTargeting.targetMapping[interactionIndex]
    
    local testFunction = interactionType.testForValidTarget
    if testFunction ~= nil and testFunction( itemData ) then
        SetDesiredInteractAction( interactionType.validTargetCursor )
    end
    
end

function UseItemTargeting.HandleMouseOverItemEnd()

    if Cursor.TargetData == nil then
        return
    end
    
    --Index of what interaction it is from
    local interactionIndex = Cursor.TargetData.TargetMapId
    if( (interactionIndex == nil) or (UseItemTargeting.targetMapping[interactionIndex] == nil) ) then
        return
    end
    
    local interactionType = UseItemTargeting.targetMapping[interactionIndex]
    
    if GetDesiredInteractAction() ~= interactionType.defaultCursor then
        SetDesiredInteractAction( interactionType.defaultCursor )
    end
end

function UseItemTargeting.MakeDyeDialog()
    if(UseItemTargeting.TargetData) then
        
        local targetItemData = UseItemTargeting.GetItemGivenLocAndSlot(UseItemTargeting.TargetData.TargetLoc, UseItemTargeting.TargetData.TargetSlot)
        if(not DataUtils.IsValidItem(targetItemData)) then
            return
        end
        
        local sourceItemData = UseItemTargeting.GetItemGivenLocAndSlot(UseItemTargeting.TargetData.Source, UseItemTargeting.TargetData.SourceSlot)
        if(not DataUtils.IsValidItem(sourceItemData)) then
            return
        end
    
        local dialogText =""
        if( UseItemTargeting.targetMapping[UseItemTargeting.TargetData.TargetMapId]~= nil) then
            dialogText = GetStringFormat(UseItemTargeting.targetMapping[UseItemTargeting.TargetData.TargetMapId].dialogBoxText, {sourceItemData.name, targetItemData.name})
        end  

        DialogManager.MakeTwoButtonDialog( dialogText, 
                                           GetString( StringTables.Default.LABEL_YES ), UseItemTargeting.SendUseDye, 
                                           GetString( StringTables.Default.LABEL_NO ), UseItemTargeting.Cancel,
                                           nil, nil, nil, nil, DialogManager.TYPE_MODE_LESS)
    end
end

function UseItemTargeting.CanUseDyeItem(sourceLocation, dyeSlot)
    local canUseDye = false
    -- Check to see if player is able to use the dye Item first
    canUseDye = CanUseDyeItem(sourceLocation, dyeSlot)

    --Display a one dialog box with text saying "Your rank is too low to use this dye!"
    --if they can't use the dye because of their rank
    if(canUseDye == false) then
        local rankText = GetString (StringTables.Default.TEXT_DYE_RANK_TOO_LOW)
        local okayText = GetString (StringTables.Default.LABEL_OKAY)
        DialogManager.MakeOneButtonDialog( rankText, okayText)  
        return false
    end
    
    return true
end

function UseItemTargeting.PreviewDye( tintMask )
    if( tintMask == nil )
    then
        if( UseItemTargeting.TargetData )
        then
            local itemData = UseItemTargeting.GetItemGivenLocAndSlot(UseItemTargeting.TargetData.TargetLoc, UseItemTargeting.TargetData.TargetSlot)
            tintMask = GetDyeTintMasks( itemData.id )
        end
    end
    
    local sourceSlot = UseItemTargeting.TargetData.SourceSlot
    local sourceLoc = UseItemTargeting.TargetData.Source
    local targetLoc = UseItemTargeting.TargetData.TargetLoc
    local targetSlot = UseItemTargeting.TargetData.TargetSlot
    
    DyePreview( sourceLoc, sourceSlot, tintMask, targetLoc, targetSlot )
end


function UseItemTargeting.SendUseDye( tintMask )
    if( tintMask == nil )
    then
        if( UseItemTargeting.TargetData )
        then
            local itemData = UseItemTargeting.GetItemGivenLocAndSlot(UseItemTargeting.TargetData.TargetLoc, UseItemTargeting.TargetData.TargetSlot)
            tintMask = GetDyeTintMasks( itemData.id )
            if( tintMask == GameData.TintMasks.BOTH )
            then
                tintMask = EA_DyeWindow.selectedTint
            end
        else
            tintMask = 0
        end
    end
    
    -- We are going to use the ability slot to send the tintmask to the server
    -- This should probably change to another field or something in the same message but for now...
    RevertDyePreview( UseItemTargeting.TargetData.TargetLoc, UseItemTargeting.TargetData.TargetSlot )
    UseItemTargeting.SendingUseTargetItem( tintMask )
end

function UseItemTargeting.SendUnlockTreasure()
    -- The server expects the chest item to be used, with a key as the target, so switch source and
    -- target items for the purpose of the message.
    local tempLoc = UseItemTargeting.TargetData.Source
    local tempSlot = UseItemTargeting.TargetData.SourceSlot
    UseItemTargeting.TargetData.Source = UseItemTargeting.TargetData.TargetLoc
    UseItemTargeting.TargetData.SourceSlot = UseItemTargeting.TargetData.TargetSlot
    UseItemTargeting.TargetData.TargetLoc = tempLoc
    UseItemTargeting.TargetData.TargetSlot = tempSlot
    
    UseItemTargeting.SendingUseTargetItem(0)
end

function UseItemTargeting.Cancel()

    if( UseItemTargeting.TargetData )
    then
        RevertDyePreview( UseItemTargeting.TargetData.TargetLoc, UseItemTargeting.TargetData.TargetSlot )
        local itemData = UseItemTargeting.GetItemGivenLocAndSlot(UseItemTargeting.TargetData.TargetLoc, UseItemTargeting.TargetData.TargetSlot)
        tintMask = GetDyeTintMasks( itemData.id )
        if( tintMask == GameData.TintMasks.BOTH )
        then
            EA_DyeWindow.Show()
        else
            Cursor.ClearTargetingData()
            UseItemTargeting.TargetData = nil
        end
    end
end

function UseItemTargeting.SendingUseTargetItem( ability )
    local sourceSlot = UseItemTargeting.TargetData.SourceSlot
    local sourceLoc = UseItemTargeting.TargetData.Source
    local targetLoc = UseItemTargeting.TargetData.TargetLoc
    local targetSlot = UseItemTargeting.TargetData.TargetSlot
    
    if( ability == nil )
    then
        ability = 0
    end
    
    SendUseItem(sourceLoc, sourceSlot, ability, targetLoc, targetSlot)
    Cursor.ClearTargetingData()
    UseItemTargeting.TargetData = nil
end


local function EndTeleport()
    if( GetDesiredInteractAction() == SystemData.InteractActions.TELEPORT )
    then
        SetDesiredInteractAction( SystemData.InteractActions.NONE )
    end
    g_teleportItemLocation = nil
end

function UseItemTargeting.BeginTeleport( itemSlot )
    g_teleportItemLocation = itemSlot
    SetDesiredInteractAction( SystemData.InteractActions.TELEPORT )
end

function UseItemTargeting.SendTeleport( )
    SendUseItem( GameData.ItemLocs.INVENTORY, g_teleportItemLocation, 0, 0, 0 )
    EndTeleport()
end

function UseItemTargeting.UseChestItem(itemSlot)
    local chestItemData = UseItemTargeting.GetItemGivenLocAndSlot(GameData.ItemLocs.INVENTORY, itemSlot)
    if((not DataUtils.IsValidItem(chestItemData)) or (chestItemData.type ~= GameData.ItemTypes.TREASURE_CHEST)) then
        return
    end
    
    local keyItemSlot = DataUtils.HasRequiredTreasureKey(chestItemData.tier)
    if(keyItemSlot == nil) then
        DialogManager.MakeOneButtonDialog(GetStringFormat(StringTables.Default.TEXT_KEY_NOT_FOUND, {chestItemData.name, chestItemData.tier + 1}), GetString(StringTables.Default.LABEL_OKAY), nil)
        return
    end
    
    local keyItemData = UseItemTargeting.GetItemGivenLocAndSlot(GameData.ItemLocs.INVENTORY, keyItemSlot)
    if((not DataUtils.IsValidItem(keyItemData)) or (keyItemData.type ~= GameData.ItemTypes.TREASURE_KEY)) then
        return
    end

    UseItemTargeting.TargetData = NewTargetData()
    UseItemTargeting.TargetData.Source = GameData.ItemLocs.INVENTORY
    UseItemTargeting.TargetData.SourceSlot = keyItemSlot
    UseItemTargeting.TargetData.TargetLoc = GameData.ItemLocs.INVENTORY
    UseItemTargeting.TargetData.TargetSlot = itemSlot
    
    DialogManager.MakeTwoButtonDialog( GetStringFormat(StringTables.Default.TEXT_WANT_TO_UNLOCK, {keyItemData.name, chestItemData.name}), 
                                       GetString(StringTables.Default.LABEL_YES), UseItemTargeting.SendUnlockTreasure, 
                                       GetString(StringTables.Default.LABEL_NO), UseItemTargeting.Cancel,
                                       nil, nil, nil, nil, DialogManager.TYPE_MODE_LESS)
        
end

function UseItemTargeting.OnLButtonProcessed()

    if( GetDesiredInteractAction() ~= SystemData.InteractActions.TELEPORT )
    then
        return
    end
    
    local actionType, actionId, actionText = WindowGetGameActionData( SystemData.MouseOverWindow.name )
    
    if( actionType == GameData.PlayerActions.SET_TARGET )
    then 
        return
    end
    
    EndTeleport()
end



