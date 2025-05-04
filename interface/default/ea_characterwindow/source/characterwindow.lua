----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

CharacterWindow = {}

CharacterWindow.timeoutList = {}

-- prevent some invalid initialization
CharacterWindow.initializationComplete = false

CharacterWindow.equipmentData = {}

CharacterWindow.temporaryEnhancedItemsSlots = {}
CharacterWindow.marketItemData = nil
CharacterWindow.marketItemDataSlot = -1

CharacterWindow.timeoutsList = {}
CharacterWindow.firstTimeoutsync = true -- this is used to make sure that there has been a sync when the timeout tab is shown
CharacterWindow.timeoutElapsedTime = 0  -- this is the elapsed time, when it gets > 60 I decrement the timeouts and subtract 60

-- EquipmentSlotInfo provides default icons and strings when for when no armor is equipped for that slot
CharacterWindow.NUM_EQUIPMENT_SLOTS = 20

CharacterWindow.EquipmentSlotInfo = {  }     
CharacterWindow.EquipmentSlotInfo[GameData.EquipSlots.RIGHT_HAND]   =  { name=GetString( StringTables.Default.LABEL_RIGHT_HAND ),   iconNum=6}
CharacterWindow.EquipmentSlotInfo[GameData.EquipSlots.LEFT_HAND]    =  { name=GetString( StringTables.Default.LABEL_LEFT_HAND ),    iconNum=7 }
CharacterWindow.EquipmentSlotInfo[GameData.EquipSlots.RANGED]       =  { name=GetString( StringTables.Default.LABEL_RANGED_SLOT ),  iconNum=8 }
CharacterWindow.EquipmentSlotInfo[GameData.EquipSlots.BODY]         =  { name=GetString( StringTables.Default.LABEL_BODY ),         iconNum=9}
CharacterWindow.EquipmentSlotInfo[GameData.EquipSlots.GLOVES]       =  { name=GetString( StringTables.Default.LABEL_GLOVES ),       iconNum=10 }
CharacterWindow.EquipmentSlotInfo[GameData.EquipSlots.BOOTS]        =  { name=GetString( StringTables.Default.LABEL_BOOTS ),        iconNum=11 }
CharacterWindow.EquipmentSlotInfo[GameData.EquipSlots.HELM]         =  { name=GetString( StringTables.Default.LABEL_HELM ),         iconNum=12 }
CharacterWindow.EquipmentSlotInfo[GameData.EquipSlots.SHOULDERS]    =  { name=GetString( StringTables.Default.LABEL_SHOULDERS ),    iconNum=13 }
CharacterWindow.EquipmentSlotInfo[GameData.EquipSlots.POCKET1]        =  { name=GetString( StringTables.Default.LABEL_POCKET ),       iconNum=36 }
CharacterWindow.EquipmentSlotInfo[GameData.EquipSlots.POCKET2]        =  { name=GetString( StringTables.Default.LABEL_POCKET ),       iconNum=36 }
CharacterWindow.EquipmentSlotInfo[GameData.EquipSlots.BACK]         =  { name=GetString( StringTables.Default.LABEL_BACK ),         iconNum=16 }
CharacterWindow.EquipmentSlotInfo[GameData.EquipSlots.BELT]         =  { name=GetString( StringTables.Default.LABEL_BELT ),         iconNum=17 }
CharacterWindow.EquipmentSlotInfo[GameData.EquipSlots.EVENT]        =  { name=GetString( StringTables.Default.LABEL_EVENT ),        iconNum=20 }
CharacterWindow.EquipmentSlotInfo[GameData.EquipSlots.BANNER]       =  { name=GetString( StringTables.Default.LABEL_BANNER ),       iconNum=18 }
CharacterWindow.EquipmentSlotInfo[GameData.EquipSlots.ACCESSORY1]   =  { name=GetString( StringTables.Default.LABEL_ACCESSORY1 ),   iconNum=20 } 
CharacterWindow.EquipmentSlotInfo[GameData.EquipSlots.ACCESSORY2]   =  { name=GetString( StringTables.Default.LABEL_ACCESSORY2 ),   iconNum=20 } 
CharacterWindow.EquipmentSlotInfo[GameData.EquipSlots.ACCESSORY3]   =  { name=GetString( StringTables.Default.LABEL_ACCESSORY3 ),   iconNum=20 } 
CharacterWindow.EquipmentSlotInfo[GameData.EquipSlots.ACCESSORY4]   =  { name=GetString( StringTables.Default.LABEL_ACCESSORY4 ),   iconNum=20 }
-- EquipmentSlotInfo for trophies is set programatically in  CharacterWindow.UnlockTrophies()

CharacterWindow.FIRST_AVAILABLE_INVENTORY_SLOT = 561

CharacterWindow.MODE_NORMAL = 1
CharacterWindow.MODE_DYE_MERCHANT = 2
CharacterWindow.MODE_BRAGS = 3
CharacterWindow.MODE_TIMEOUTS = 4
CharacterWindow.MODE_ITEM_APPEARANCE = 5

CharacterWindow.dropPending = false

CharacterWindow.NORMAL_TINT = DefaultColor.ZERO_TINT
CharacterWindow.HAS_CUSTOM_ICON_TINT = DefaultColor.RED
CharacterWindow.CANNOT_CUSTOMIZE_TINT = { r=125, g=125, b=125  }

----------------------------------------------------------------
-- Local Functions
----------------------------------------------------------------


local function RestoreItemsAndHeraldry()

    if( CharacterWindow.restoreHelmAfterDyeing )
    then
        ButtonSetPressedFlag( "CharacterWindowContentsEquipmentShowHelm", false )
        CharacterWindow.ShowHelm()
    end
    
    if( CharacterWindow.restoreCloakAfterDyeing )
    then
        ButtonSetPressedFlag( "CharacterWindowContentsEquipmentShowCloak", false  )
        CharacterWindow.ShowCloak()
    end
    
    if( CharacterWindow.restoreCloakHeraldryAfterDyeing )
    then
        ButtonSetPressedFlag( "CharacterWindowContentsEquipmentShowCloakHeraldry", true  )
        CharacterWindow.ShowCloakHeraldry()
    end

    CharacterWindow.restoreHelmAfterDyeing = nil
    CharacterWindow.restoreCloakAfterDyeing = nil
    CharacterWindow.restoreCloakHeraldryAfterDyeing = nil
end

----------------------------------------------------------------
-- CharacterWindow Functions
----------------------------------------------------------------

-- OnInitialize Handler
function CharacterWindow.Initialize()

    LabelSetText( "CharacterWindowContentsImageNameLabel", GameData.Player.name )
    LabelSetText( "CharacterWindowBragsHeader", GetStringFormat( StringTables.Default.LABEL_PLAYERS_BRAGS_HEADER, {GameData.Player.name} ) )
    LabelSetText( "CharacterWindowBragsFooter", GetString( StringTables.Default.LABEL_BRAGS_HELP_TEXT ) )

    WindowRegisterEventHandler( "CharacterWindow", SystemData.Events.PLAYER_EQUIPMENT_SLOT_UPDATED, "CharacterWindow.UpdateEquipmentSlot")
    WindowRegisterEventHandler( "CharacterWindow", SystemData.Events.PLAYER_TROPHY_SLOT_UPDATED, "CharacterWindow.UpdateTrophySlot")
    WindowRegisterEventHandler( "CharacterWindow", SystemData.Events.PLAYER_STATS_UPDATED, "CharacterWindow.UpdateStatsNew")
    WindowRegisterEventHandler( "CharacterWindow", SystemData.Events.PLAYER_MAX_HIT_POINTS_UPDATED, "CharacterWindow.UpdateHitPoints")
    WindowRegisterEventHandler( "CharacterWindow", SystemData.Events.PLAYER_CAREER_RANK_UPDATED, "CharacterWindow.UpdateCareerRank") 
    WindowRegisterEventHandler( "CharacterWindow", SystemData.Events.INTERACT_DYE_MERCHANT, "CharacterWindow.ShowDyeMerchant")  
    WindowRegisterEventHandler( "CharacterWindow", SystemData.Events.INTERACT_DONE, "CharacterWindow.HideDyeMerchant")
    WindowRegisterEventHandler( "CharacterWindow", SystemData.Events.VISIBLE_EQUIPMENT_UPDATED, "CharacterWindow.OnVisibleEquipmentUpdated")
    WindowRegisterEventHandler( "CharacterWindow", SystemData.Events.PLAYER_MONEY_UPDATED, "CharacterWindow.UpdateMoney" )
    WindowRegisterEventHandler( "CharacterWindow", SystemData.Events.SOCIAL_BRAGGING_RIGHTS_UPDATED, "CharacterWindow.BraggingRightsUpdated") 
    WindowRegisterEventHandler( "CharacterWindow", SystemData.Events.PLAYER_EFFECTS_UPDATED, "CharacterWindow.PlayerEffectsUpdated") 
    WindowRegisterEventHandler( "CharacterWindow", SystemData.Events.LOCKOUTS_UPDATED, "CharacterWindow.LockoutsUpdated")
    WindowRegisterEventHandler( "CharacterWindow", SystemData.Events.PLAY_AS_MONSTER_STATUS, "CharacterWindow.HandlePlayAsMonsterStatus")

    CharacterWindow.UpdateStatsNew()
    CharacterWindow.UpdateHitPoints()
    CharacterWindow.UpdateCareerRank()
    
    CharacterWindow.HideTrophyLocArrows()

    CharacterWindow.UpdateStatCombobox()    

    CharacterWindow.UnlockTrophies() 
    
    -- Add any enhancement timers to the list
    for slot, slotData in pairs( CharacterWindow.equipmentData )
    do
        if ( DataUtils.ItemHasEnhancementTimer( slotData ) )
        then
            table.insert( CharacterWindow.temporaryEnhancedItemsSlots, slot )
        end
    end

    -- Update the visible equipment check boxes.
    ButtonSetCheckButtonFlag("CharacterWindowContentsEquipmentShowHelm", true )
    WindowSetShowing("CharacterWindowContentsEquipmentShowHelm", false)
    ButtonSetCheckButtonFlag("CharacterWindowContentsEquipmentShowCloak", true )
    WindowSetShowing("CharacterWindowContentsEquipmentShowCloak", false)
    ButtonSetCheckButtonFlag("CharacterWindowContentsEquipmentShowCloakHeraldry", true )
    WindowSetShowing("CharacterWindowContentsEquipmentShowCloakHeraldry", false)

    local showHelm = GetEquippedItemVisible( GameData.EquipSlots.HELM )
    local showCloak = GetEquippedItemVisible( GameData.EquipSlots.BACK )
    local showCloakHeraldry = IsShowingCloakHeraldry()
    CharacterWindow.OnVisibleEquipmentUpdated( showHelm, showCloak, showCloakHeraldry )

    -- Set up tabs
    ButtonSetText( "CharacterWindowTabsCharTab", GetString( StringTables.Default.LABEL_CHARACTER ) )
    ButtonSetText( "CharacterWindowTabsBragsTab", GetString( StringTables.Default.LABEL_BRAGS ) )
    ButtonSetText( "CharacterWindowTabsTimeoutTab", GetString( StringTables.Default.LABEL_TIMEOUTS ) )

    -- set the timeout tabs title label
    LabelSetText("CharacterWindowTimeoutsTitleLabel", GetString( StringTables.Default.LABEL_TIMEOUT_TITLE ))
    
    -- Set the Appearance Mode Label
    LabelSetText("CharacterWindowContentsAppearanceModeLabel", GetString( StringTables.Default.CHECK_BOX_LABEL_APPEARANCE_MODE ))

    -- Set bragging rights
    CharacterWindow.BraggingRightsUpdated()

    -- reset the background to all black
    CharacterWindow.ResetListBackground()

    CharacterWindow.UpdateMode( CharacterWindow.MODE_NORMAL )
end

function CharacterWindow.HandlePlayAsMonsterStatus( isPlayAsMonster )    
    if ( isPlayAsMonster )
    then
        CharacterWindow.Hide()
    end 
end

-- provides the ItemInfo corresponding to the given slot
function CharacterWindow.GetItem( slot )

    if slot < GameData.Player.c_TROPHY_START_INDEX then
        return CharacterWindow.equipmentData[slot]

    else
        local trophySlot = slot - GameData.Player.c_TROPHY_START_INDEX + 1  
        return CharacterWindow.trophyData[trophySlot]
    end
end

-- OnShutdown Handler
function CharacterWindow.Shutdown()
    WindowUnregisterEventHandler( "CharacterWindow", SystemData.Events.L_BUTTON_DOWN_PROCESSED )
end

-- OnShown Handler
function CharacterWindow.OnShown()
    CharacterWindow.UpdateTrophySlotIcons()
    if( CharacterWindow.mode == CharacterWindow.MODE_DYE_MERCHANT )
    then
        CharacterWindow.UpdateMode( CharacterWindow.MODE_NORMAL )
    end
    WindowUtils.OnShown(CharacterWindow.Hide, WindowUtils.Cascade.MODE_AUTOMATIC)
end

function CharacterWindow.ToggleShowing()   
    
    if(GameData.Player.isPlayAsMonster == true)
    then
        -- Do not toggle this window to showing
        return
    end
    
    WindowUtils.ToggleShowing( "CharacterWindow" )
    local showing = WindowGetShowing( "CharacterWindow" )
    WindowSetShowing( "CharacterWindowTabs", showing )
end

function CharacterWindow.Hide()   
    WindowSetShowing("CharacterWindow", false)
    WindowSetShowing("CharacterWindowTabs", false)
end

function CharacterWindow.OnHidden()
    if( CharacterWindow.mode == CharacterWindow.MODE_DYE_MERCHANT )
    then
        RevertAllDyePreview()
        RestoreItemsAndHeraldry()
        CharacterWindow.MarketingRButtonDown()
        CharacterWindow.UpdateMode( CharacterWindow.MODE_NORMAL )
    end
    
    if( CharacterWindow.mode == CharacterWindow.MODE_ITEM_APPEARANCE )
    then
        CharacterWindow.UpdateMode( CharacterWindow.MODE_NORMAL )
    end
    
    CharacterWindow.HideTrophyLocArrows()
    WindowUtils.OnHidden()
end


function CharacterWindow.UpdateSlotIcons()
    local texture, x, y  = 0, 0, 0
    
    CharacterWindow.equipmentData = DataUtils.GetEquipmentData()
    for equipmentData, slot in pairs(GameData.EquipSlots)
    do
        local equippedItem = CharacterWindow.equipmentData[slot]
        local found = false
        local hasCustomIcon = equippedItem.customizedIconNum ~= 0
        local isInItemAppearanceMode = CharacterWindow.mode == CharacterWindow.MODE_ITEM_APPEARANCE
        local tint = CharacterWindow.NORMAL_TINT
        local iconBaseTint = CharacterWindow.NORMAL_TINT
        
        -- Set the correct default tint
        if( isInItemAppearanceMode and not DataUtils.IsItemAppearanceCustomizable( slot, equippedItem ) )
        then
            tint = CharacterWindow.CANNOT_CUSTOMIZE_TINT
            iconBaseTint = CharacterWindow.CANNOT_CUSTOMIZE_TINT
        end
        
        -- Get the correct icon
        if( not isInItemAppearanceMode and equippedItem.iconNum ~= 0 )
        then
            texture, x, y = GetIconData( equippedItem.iconNum ) 
            found = true
            
            if( hasCustomIcon )
            then
                tint = CharacterWindow.HAS_CUSTOM_ICON_TINT
            end
        elseif( isInItemAppearanceMode and hasCustomIcon )
        then
            texture, x, y = GetIconData( equippedItem.customizedIconNum )
            found = true
        elseif( CharacterWindow.EquipmentSlotInfo[slot] )
        then
            texture, x, y = GetIconData( CharacterWindow.EquipmentSlotInfo[slot].iconNum )  
            found = true
        end

        if( found )
        then
            DynamicImageSetTexture( "CharacterWindowContentsEquipmentSlot"..slot.."IconBase", texture, x, y )
        end
        
        if( DoesWindowExist( "CharacterWindowContentsEquipmentSlot"..slot ) 
            and DoesWindowExist( "CharacterWindowContentsEquipmentSlot"..slot.."IconBase" ) )
        then
            WindowSetTintColor( "CharacterWindowContentsEquipmentSlot"..slot, tint.r, tint.g, tint.b )
            WindowSetTintColor( "CharacterWindowContentsEquipmentSlot"..slot.."IconBase", iconBaseTint.r, iconBaseTint.g, iconBaseTint.b )
        end
    end

    CharacterWindow.UpdateTrophySlotIcons()
end 


-- Creates a confirm dialog for BoE items,
-- which will then call the RequestMoveItem() if the player presses OK
function CharacterWindow.IsConfirmationNeededToMoveItem( Source, SourceSlot, DestSlot )

    if( Source == Cursor.SOURCE_INVENTORY )
    then
        
        local playerItems   = DataUtils.GetItems()
        local itemData      = playerItems[SourceSlot]
        if( itemData.uniqueID ~= 0 and itemData.flags[GameData.Item.EITEMFLAG_BIND_ON_EQUIP] and not itemData.boundToPlayer )
        then
            CharacterWindow.slotToEquip = DestSlot
            DialogManager.MakeTwoButtonDialog( GetString(StringTables.Default.TEXT_BIND_ON_EQUIP_CONFIRMATION), 
                                               GetString(StringTables.Default.LABEL_YES), CharacterWindow.RequestMoveItem, 
                                               GetString(StringTables.Default.LABEL_NO) )
            return true
        end
    end
    
    return false
end

-- OnLButtonDown Handler
function CharacterWindow.EquipmentLButtonDown( flags )

    local slot = WindowGetId(SystemData.ActiveWindow.name)
    if( Cursor.UseItemTargeting ) 
    then
        --Attempt to use the target item on the selected slot
        UseItemTargeting.HandleUseItemOnTarget(Cursor.SOURCE_EQUIPMENT, slot)
    
    elseif Cursor.IconOnCursor() 
    then
        -- MoveItem is handled on LButtonUp
        
    elseif( CharacterWindow.mode == CharacterWindow.MODE_DYE_MERCHANT or CharacterWindow.mode == CharacterWindow.MODE_ITEM_APPEARANCE )
    then
        -- nothing yet
        
    else
                
        if CharacterWindow.equipmentData[slot].uniqueID ~= 0 
        then
            -- Create an Item Link on Shift-Left Click
            if( flags == SystemData.ButtonFlags.SHIFT)
            then
                EA_ChatWindow.InsertItemLink( CharacterWindow.equipmentData[slot] )
            else
                Cursor.PickUp( Cursor.SOURCE_EQUIPMENT, slot, CharacterWindow.equipmentData[slot].uniqueID, CharacterWindow.equipmentData[slot].iconNum, true )                         
            end
        end
        
        CharacterWindow.dropPending = false
    end
end

function CharacterWindow.RequestMoveItem()
    if( CharacterWindow.slotToEquip and Cursor.IconOnCursor() )
    then
        -- Attempt to drop the object
        RequestMoveItem( Cursor.Data.Source, Cursor.Data.SourceSlot, Cursor.SOURCE_EQUIPMENT, CharacterWindow.slotToEquip, Cursor.Data.StackAmount )   
        CharacterWindow.dropPending = true
        CharacterWindow.slotToEquip = nil
    end
end

-- OnLButtonUp Handler ( Overload L Button up for drag & drop )
function CharacterWindow.EquipmentLButtonUp( flags )
    local slot = WindowGetId(SystemData.ActiveWindow.name)
    
    local slotOnCursor = Cursor.IconOnCursor() and CharacterWindow.dropPending == false
    
    if( slotOnCursor ) 
    then
        if( CharacterWindow.mode == CharacterWindow.MODE_ITEM_APPEARANCE )
        then
            CharacterWindow.OnLButtonUpItemAppearance( flags )
            return
        end
        
        if CharacterWindow.IsConfirmationNeededToMoveItem( Cursor.Data.Source, Cursor.Data.SourceSlot, slot ) then
            return
        end
        -- Attempt to drop the object
        RequestMoveItem( Cursor.Data.Source, Cursor.Data.SourceSlot, Cursor.SOURCE_EQUIPMENT, slot, Cursor.Data.StackAmount )    
    end
    
    if( CharacterWindow.mode == CharacterWindow.MODE_DYE_MERCHANT and  not CharacterWindow.dyeAll )
    then
        if( slotOnCursor )
        then
            -- Unhighlight the selected dye slot if the equipment in it was swapped out
            local oldSelectedSlotName = CharacterWindow.selectedDyeSlotName
            if( oldSelectedSlotName and oldSelectedSlotName == "CharacterWindowContentsEquipmentSlot"..slot )
            then
                CharacterWindow.UnHighlightSlot( oldSelectedSlotName )
            end
        else
            local oldSelectedSlotName = CharacterWindow.selectedDyeSlotName
            local isSlotValid = CharacterWindow.IsSlotValidForDye( slot )
            if( oldSelectedSlotName )
            then

                CharacterWindow.UnHighlightSlot( oldSelectedSlotName )
                
                if( oldSelectedSlotName ~= SystemData.ActiveWindow.name and isSlotValid )
                then
                    CharacterWindow.SelectSlotForDyeing(slot)
                else
                    CharacterWindow.selectedDyeSlotName = nil
                end
                
                -- revert the stuff we had selected
                RevertDyePreview( GameData.ItemLocs.EQUIPPED, WindowGetId( oldSelectedSlotName ) )
            elseif( isSlotValid ) -- nothing was selected before so select it
            then
                CharacterWindow.SelectSlotForDyeing(slot)
            else
                CharacterWindow.selectedDyeSlotName = nil
            end
            
            -- Do we need to preview anything?
            CharacterWindow.pendingDyePreview = CharacterWindow.selectedDyeSlotName ~= nil
        end
    end
end

-- OnRButtonDown Handler
function CharacterWindow.EquipmentRButtonDown( flags )
    local slot = WindowGetId(SystemData.ActiveWindow.name)
    
    -- verify that we're clicking on an icon before spamming the server
    if not Cursor.IconOnCursor() and CharacterWindow.equipmentData[slot].uniqueID ~= 0 then

        if( CharacterWindow.mode == CharacterWindow.MODE_ITEM_APPEARANCE )
        then
            CharacterWindow.OnRButtonUpItemAppearance( flags )
            return
        end
        
        -- Attempt to put this item back into the inventory
        RequestMoveItem( Cursor.SOURCE_EQUIPMENT, slot, Cursor.SOURCE_INVENTORY, CharacterWindow.FIRST_AVAILABLE_INVENTORY_SLOT, CharacterWindow.equipmentData[slot].stackCount)
    end
end


-- note that this function may be called directly from the BackpackWindow
--
function CharacterWindow.AutoEquipItem( inventorySlot )

    -- retrieve inventorySlot's item data from BackpackWindow
    local invData = DataUtils.GetItems ()
    local itemData = invData[inventorySlot]
    local isItemValid = itemData.uniqueID ~= 0
    local canUseItem = DataUtils.PlayerCanUseItem( itemData )
    
    if( CharacterWindow.mode == CharacterWindow.MODE_ITEM_APPEARANCE )
    then
        if( canUseItem and isItemValid )
        then
            CharacterWindow.ApplyItemAppearanceToSlot( GameData.ItemLocs.INVENTORY, inventorySlot, itemData.equipSlot )
            if( Cursor.IconOnCursor() )
            then
                Cursor.Clear()
            end
        end
        
        return
    end
    
    if (itemData ~= nil and itemData.type == GameData.ItemTypes.TROPHY)
    then
        local trophySlot = CharacterWindow.GetFirstAvailableTrophySlot( itemData )
        if trophySlot == CharacterWindow.INVALID_TROPHY_POSITION
        then    
            -- if all slots filled, just swap with first trophy slot
            trophySlot = 1
        end

        local trophyIndex = trophySlot + GameData.Player.c_TROPHY_START_INDEX - 1
        CharacterWindow.AutoAttachTrophy( Cursor.SOURCE_INVENTORY, inventorySlot, trophyIndex, itemData )        
        
    else
        
        if( isItemValid and itemData.flags[GameData.Item.EITEMFLAG_BIND_ON_EQUIP] and not itemData.boundToPlayer and canUseItem )
        then
            DialogManager.MakeTwoButtonDialog( GetString(StringTables.Default.TEXT_BIND_ON_EQUIP_CONFIRMATION), 
                                                GetString(StringTables.Default.LABEL_YES), CharacterWindow.DialogAutoEquip, 
                                                GetString(StringTables.Default.LABEL_NO) )
            CharacterWindow.slotToEquip = inventorySlot
            return
        end
        
        AutoEquipItem( inventorySlot )
    end
end

function CharacterWindow.DialogAutoEquip()
    if( CharacterWindow.slotToEquip )
    then
        AutoEquipItem( CharacterWindow.slotToEquip ) 
        CharacterWindow.slotToEquip = nil
    end
end

-- SystemData.Events.PLAYER_EQUIPMENT_SLOT_UPDATED Handler
function CharacterWindow.UpdateEquipmentSlot( updatedSlots )
    CharacterWindow.UpdateSlotIcons()    
    for _, slot in ipairs( updatedSlots )
    do
        local uniqueID = 0
        if (CharacterWindow.equipmentData[slot] ~= nil)
        then
            uniqueID = CharacterWindow.equipmentData[slot].uniqueID
        end

        -- If we are placing the item that is currently on the cursor, clear it
        if( Cursor.IconOnCursor() and (Cursor.Data.ObjectId == uniqueID or CharacterWindow.dropPending == true) )
        then 
            Cursor.Clear()  
            CharacterWindow.dropPending = false
        end
        
        if( DataUtils.ItemHasEnhancementTimer( CharacterWindow.equipmentData[slot] ) )
        then
            CharacterWindow.ClearEnhancementTimer( slot )   -- Prevent a slot from being added to the list duplicate times
            table.insert( CharacterWindow.temporaryEnhancedItemsSlots, slot )
        end
        
        -- If we are mousing over the updated slot, show the tooltip
        if SystemData.MouseOverWindow.name == "CharacterWindowEquipmentSlot"..slot
        then
            CharacterWindow.MouseOverSlot( slot )
        end
        
        if( CharacterWindow.mode == CharacterWindow.MODE_DYE_MERCHANT )
        then
            -- clear the dye selection higlight if the equipment in that slot has been removed, 
            -- we won't need to preview it
            local oldSelectedSlotName = CharacterWindow.selectedDyeSlotName
            if( oldSelectedSlotName and oldSelectedSlotName == "CharacterWindowContentsEquipmentSlot"..slot )
            then
                CharacterWindow.UnHighlightSlot( CharacterWindow.selectedDyeSlotName )
                CharacterWindow.selectedDyeSlotName = nil
            end
        end
        
    end
    
    CharacterWindow.UpdateStatsNew()
    if( CharacterWindow.mode == CharacterWindow.MODE_DYE_MERCHANT )
    then
        CharacterWindow.UpdateDyeTotalCost()
        if( CharacterWindow.dyeAll )
        then
            CharacterWindow.PreviewDyes()
        end    
    end
end

function CharacterWindow.ClearEnhancementTimer( slotToRemove )

    for i, slot in ipairs( CharacterWindow.temporaryEnhancedItemsSlots ) do
        if slot == slotToRemove then
            table.remove( CharacterWindow.temporaryEnhancedItemsSlots, i )
            return true
        end
    end
    
    return false
end

function CharacterWindow.OnUpdate( elapsedTime )
    if( CharacterWindow.pendingDyePreview )
    then
        CharacterWindow.PreviewDyes()
        CharacterWindow.pendingDyePreview = nil
    end
    
    CharacterWindow.UpdateTimeouts( elapsedTime )

    if( #CharacterWindow.temporaryEnhancedItemsSlots == 0 )
    then
        return
    end

    local timersToRemove = {}
    for index, slot in ipairs( CharacterWindow.temporaryEnhancedItemsSlots )
    do
        local item = CharacterWindow.equipmentData[slot]
        if( DataUtils.UpdateEnhancementTimer( item, elapsedTime ) )
        then
            table.insert( timersToRemove, slot )
        end
    end
    
    for index, slot in ipairs( timersToRemove )
    do
        CharacterWindow.ClearEnhancementTimer( slot )
    end
end

-- OnMouseOver Handler
function CharacterWindow.EquipmentMouseOver()

    CharacterWindow.MouseOverSlot( WindowGetId(SystemData.ActiveWindow.name) )
end 

function CharacterWindow.MouseOverSlot( slot )    
    
    local itemData = CharacterWindow.equipmentData[slot]
    if( itemData.uniqueID == 0 or ( CharacterWindow.mode == CharacterWindow.MODE_ITEM_APPEARANCE and itemData.customizedIconNum == 0 ) ) then        
        Tooltips.CreateTextOnlyTooltip( "CharacterWindowContentsEquipmentSlot"..slot, nil )
        Tooltips.SetTooltipText( 1, 1, CharacterWindow.EquipmentSlotInfo[slot].name )
        Tooltips.SetTooltipColor( 1, 1, 123, 172, 220 )
        Tooltips.Finalize()
        Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT )
    elseif( CharacterWindow.mode == CharacterWindow.MODE_ITEM_APPEARANCE )
    then
		local windowName = "CharacterWindowContentsEquipmentSlot"..slot
		Tooltips.CreateAppearanceItemTooltip( itemData, windowName ) 
    else
        local windowName = "CharacterWindowContentsEquipmentSlot"..slot
        Tooltips.CreateAndTintItemTooltip( itemData, windowName, Tooltips.ANCHOR_WINDOW_RIGHT, true )
        if( DataUtils.ItemHasEnhancementTimer( itemData ) ) then
            Tooltips.SetUpdateCallback( Tooltips.ItemUpdateCallback )
        end
        
        if Cursor.UseItemTargeting then 
            UseItemTargeting.HandleMouseOverItem( itemData )
        end
    end
end 

-- OnMouseOverEnd Handler
function CharacterWindow.EquipmentMouseOverEnd()

    if Cursor.UseItemTargeting then 
        UseItemTargeting.HandleMouseOverItemEnd()
    end
end

function CharacterWindow.UpdateHitPoints()
    local text = L""..GameData.Player.hitPoints.maximum
--    LabelSetText( "CharacterWindowHPValue", text )
end

function CharacterWindow.OnMouseOverStat(stat)
    CharacterWindow.CreateTooltip(SystemData.ActiveWindow.name, StatInfo[stat].name, StatInfo[stat].desc)
end

function CharacterWindow.OnMouseOverArmorValue()
    CharacterWindow.CreateTooltip(SystemData.ActiveWindow.name, GetString( StringTables.Default.LABEL_ARMOR ), GetString( StringTables.Default.TEXT_ARMOR ))
end

function CharacterWindow.UpdateCareerRank()
    
    LabelSetText( "CharacterWindowContentsImageTitleLabel", GetFormatStringFromTable("Default", StringTables.Default.LABEL_CHARACTER_WINDOW_RANK_X_CAREER, {GameData.Player.level, GameData.Player.career.name} ) )
    
    -- The player may have unlocked additional trophies.
    CharacterWindow.UnlockTrophies()
end 

function CharacterWindow.ShowCloak()
    local showCloak = ButtonGetPressedFlag("CharacterWindowContentsEquipmentShowCloak")
    SetEquippedItemVisible(GameData.EquipSlots.BACK, showCloak)

    if( showCloak )
    then
        ButtonSetDisabledFlag("CharacterWindowContentsEquipmentShowCloakHeraldry", false)
    else
        ButtonSetDisabledFlag("CharacterWindowContentsEquipmentShowCloakHeraldry", true)
    end
end

function CharacterWindow.ShowCloakHeraldry()
    SendChatText( L"/togglecloakheraldry", L"" )
end

function CharacterWindow.ShowShowCloakOnly()
    WindowSetShowing("CharacterWindowContentsEquipmentShowCloak", true)
    CharacterWindow.CreateTooltip("CharacterWindowContentsEquipmentShowCloak", GetString( StringTables.Default.TOOLTIP_SHOW_ITEM ) )
end

function CharacterWindow.ShowShowCloakHeraldryOnly()
    WindowSetShowing("CharacterWindowContentsEquipmentShowCloakHeraldry", true)
    CharacterWindow.CreateTooltip("CharacterWindowContentsEquipmentShowCloakHeraldry", GetString( StringTables.Default.TOOLTIP_SHOW_HERALDRY ) )
end

function CharacterWindow.ShowCloakOptions()
    WindowSetShowing("CharacterWindowContentsEquipmentShowCloak", true)
    WindowSetShowing("CharacterWindowContentsEquipmentShowCloakHeraldry", true)
    CharacterWindow.EquipmentMouseOver()
end

function CharacterWindow.HideCloakOptions()
    WindowSetShowing("CharacterWindowContentsEquipmentShowCloak", false)
    WindowSetShowing("CharacterWindowContentsEquipmentShowCloakHeraldry", false)
    CharacterWindow.EquipmentMouseOverEnd()
end

function CharacterWindow.ShowHelm()
    local showHelm = ButtonGetPressedFlag("CharacterWindowContentsEquipmentShowHelm")
    SetEquippedItemVisible(GameData.EquipSlots.HELM, showHelm)
end

function CharacterWindow.ShowShowHelmOnly()
    WindowSetShowing("CharacterWindowContentsEquipmentShowHelm", true)
    CharacterWindow.CreateTooltip("CharacterWindowContentsEquipmentShowHelm", GetString( StringTables.Default.TOOLTIP_SHOW_ITEM ) )
end

function CharacterWindow.ShowShowHelm()
    WindowSetShowing("CharacterWindowContentsEquipmentShowHelm", true)
    CharacterWindow.EquipmentMouseOver()
end

function CharacterWindow.HideShowHelm()
    WindowSetShowing("CharacterWindowContentsEquipmentShowHelm", false)
    CharacterWindow.EquipmentMouseOverEnd()
end

function CharacterWindow.PaperDollMouseUp()
    if Cursor.IconOnCursor() and CharacterWindow.dropPending == false then
        CharacterWindow.AutoEquipItem(Cursor.Data.SourceSlot)
    end
end

function CharacterWindow.CreateTooltip(wndName, line1, line2)
    if (line1 == nil) then
        return
    end
    Tooltips.CreateTextOnlyTooltip( wndName )
    Tooltips.SetTooltipText( 1, 1, line1 )
    Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
    if (line2 ~= nil) then
        Tooltips.SetTooltipText( 2, 1, line2 )  
    end
    Tooltips.Finalize()
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT )
end

function CharacterWindow.OnVisibleEquipmentUpdated( showHelm, showCloak, showCloakHeraldry )
    ButtonSetPressedFlag( "CharacterWindowContentsEquipmentShowHelm", showHelm )
    ButtonSetPressedFlag( "CharacterWindowContentsEquipmentShowCloak", showCloak )
    ButtonSetPressedFlag( "CharacterWindowContentsEquipmentShowCloakHeraldry", showCloakHeraldry )
    
    if( showCloak )
    then
        ButtonSetDisabledFlag("CharacterWindowContentsEquipmentShowCloakHeraldry", false)
    else
        ButtonSetDisabledFlag("CharacterWindowContentsEquipmentShowCloakHeraldry", true)
    end
end

function CharacterWindow.PlayerEffectsUpdated()
    CharacterWindow.UpdateStatsNew()
end

function CharacterWindow.MarketingLButtonDown()
    -- 
    local slot = WindowGetId(SystemData.ActiveWindow.name)  

    if( Cursor.IconOnCursor() ) then
        --    
        if( CharacterWindow.marketItemData == nil ) then
            local itemData = DataUtils.GetItems()[Cursor.Data.SourceSlot]            
            if( Cursor.Data.Source == Cursor.SOURCE_INVENTORY and itemData.type == GameData.ItemTypes.MARKETING) then                
                local slot = Cursor.Data.SourceSlot
                CharacterWindow.marketItemData = itemData
                CharacterWindow.marketItemDataSlot = slot
                local texture, x, y = GetIconData(itemData.iconNum)
                DynamicImageSetTexture( "DyeMerchantMarketingSlotIconBase", texture, x, y )
                Cursor.Clear()
                CharacterWindow.MarketingMouseOver()
                SetPlayerVariation(slot)
                LabelSetText("DyeMerchantMarketingSlotDescLabel", GetString( StringTables.Default.TEXT_MARKETING_ITEM_SLOT_REMOVE ) )           
            else
                -- Place error popup here
                DialogManager.MakeOneButtonDialog( GetString( StringTables.Default.TEXT_MARKETING_ITEM_ERROR ), GetString( StringTables.Default.LABEL_OKAY ) )
                Cursor.Clear()
                CharacterWindow.MarketingMouseOver()                
            end
        else
            CharacterWindow.marketItemData = nil
            CharacterWindow.marketItemDataSlot = -1
            RevertPlayerVariation();
            CharacterWindow.MarketingLButtonDown()
        end            
    else
        -- 
    end
end

function CharacterWindow.MarketingRButtonDown()
    -- 
    if( CharacterWindow.marketItemData == nil ) then
    -- do nothing
    else
        CharacterWindow.marketItemData = nil
        CharacterWindow.marketItemDataSlot = -1 
        local icon = CharacterWindow.TROPHY_EMPTY_ICON
        DynamicImageSetTexture( "DyeMerchantMarketingSlotIconBase", icon.texture, icon.x, icon.y )
        LabelSetText("DyeMerchantMarketingSlotDescLabel", GetString( StringTables.Default.TEXT_MARKETING_ITEM_SLOT_TIP ) )           
        CharacterWindow.MarketingMouseOver()
        RevertPlayerVariation();
    end
end

function CharacterWindow.MarketingMouseOver()
    --    
    local itemData = CharacterWindow.marketItemData    
  
    if( itemData == nil ) then
        Tooltips.CreateTextOnlyTooltip( "DyeMerchantMarketingSlot", nil )
        Tooltips.SetTooltipText( 1, 1, GetString( StringTables.Default.LABEL_MARKETING_ITEM_SLOT ) )
        Tooltips.SetTooltipColor( 1, 1, 123, 172, 220 )
        Tooltips.Finalize()
        Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT )
    else
        Tooltips.CreateItemTooltip( itemData, "DyeMerchantMarketingSlot", Tooltips.ANCHOR_WINDOW_RIGHT, true )   
    end
         
end

function CharacterWindow.ApplyRewardItem()
    -- 
    if( CharacterWindow.marketItemDataSlot ~= -1 ) then
        ApplyPlayerVariation(CharacterWindow.marketItemDataSlot)
        CharacterWindow.marketItemData = nil
        CharacterWindow.marketItemDataSlot = -1 
        local icon = CharacterWindow.TROPHY_EMPTY_ICON
        DynamicImageSetTexture( "DyeMerchantMarketingSlotIconBase", icon.texture, icon.x, icon.y )
        if( Cursor.IconOnCursor() ) then
            Cursor.Clear()
        end
        CharacterWindow.HideDyeMerchant()
        LabelSetText("DyeMerchantMarketingSlotDescLabel", GetString( StringTables.Default.TEXT_MARKETING_ITEM_SLOT_TIP ) )           
    else
        -- we shouldn't really be here
    end
end

function CharacterWindow.ResetListBackground( )
    local color = DefaultColor.BLACK    -- make the background black
    color.a = 1                         -- and opaque
    for row = 1, CharacterWindowTimeoutsList.numVisibleRows do
        local targetRowWindow = "CharacterWindowTimeoutsListRow"..row
        WindowSetTintColor(targetRowWindow.."Background", color.r, color.g, color.b )
        WindowSetAlpha(targetRowWindow.."Background", color.a )
    end
end

-- the slash command has been changed to provide a return message for use in the timeout/lockout tab
function CharacterWindow.RequestTimeoutInfo()
    SendChatText( L"/lockout", L"" )
end

-- this is the function called when the lockouts updated event is recieved
function CharacterWindow.LockoutsUpdated( lockouts )
    -- keep track of the lockout table
    CharacterWindow.timeoutsList = lockouts
    -- this boolean is used to make sure we are synced up at least once
    -- when the player opens the timeout tab for the first time
    CharacterWindow.firstTimeoutsync = false
    -- update the listbox with the table data
    CharacterWindow.UpdateLockouts()
end

function CharacterWindow.UpdateLockouts()
    -- reset the background to all black
    CharacterWindow.ResetListBackground()
    -- reset the timeout list
    CharacterWindow.timeoutList = {}
    
    local displayOrder = {}
    local objectiveTimers = {}

    local lockoutIndex = 1
    local rowCount = 1 -- this is used to keep the rows that are grouped together the same color
    
    local function AddListBoxRow(textStr, timeStr, bgColor, fgColor)
        CharacterWindow.timeoutList[rowCount] = {}
        CharacterWindow.timeoutList[rowCount].textStr = textStr
        CharacterWindow.timeoutList[rowCount].timeStr = timeStr
        CharacterWindow.timeoutList[rowCount].bgColor = bgColor
        CharacterWindow.timeoutList[rowCount].fgColor = fgColor

        -- add the row # to the display order list
        table.insert(displayOrder, rowCount)
        -- go to the next row for either a kill row or the next lockout group
        rowCount = rowCount + 1
    end
    
    for _, timeout in ipairs( CharacterWindow.timeoutsList )
    do
        if ( timeout.type == GameData.ActionTimestamp.OBJECTIVE )
        then
            -- We need to group objective timers together by zone name. Thus, do not add them to the listbox yet.
            -- We will do a second pass later on to add othe objective timers.
            if ( objectiveTimers[timeout.zoneName] == nil )
            then
                objectiveTimers[timeout.zoneName] = {}
            end
            table.insert( objectiveTimers[timeout.zoneName], timeout )
        elseif ( timeout.type == GameData.ActionTimestamp.ZONE )
        then
            -- alternate the row colors
            local row_mod = math.mod(lockoutIndex, 2)
            local color = DataUtils.GetAlternatingRowColor( row_mod )

            -- add the entry for the zone name header
            AddListBoxRow( timeout.zoneName, CharacterWindow.TimeString( timeout.timeRemaining ), color, DefaultColor.TOOLTIP_HEADING )

            for _, kill in ipairs( timeout.killList )
            do
                AddListBoxRow( GetStringFormat( StringTables.Default.LABEL_TIMEOUT_KILL, {kill} ), L"", color, DefaultColor.ZERO_TINT )
            end
           
            lockoutIndex = lockoutIndex + 1
        end
    end
    
    -- Add any objective timers we found in the first pass
    for zoneName, timeoutList in pairs( objectiveTimers )
    do
        -- alternate the row colors
        local row_mod = math.mod(lockoutIndex, 2)
        local color = DataUtils.GetAlternatingRowColor( row_mod )

        -- add the entry for the zone name header
        AddListBoxRow( zoneName, L"", color, DefaultColor.TOOLTIP_HEADING )

        for _, timeout in ipairs( timeoutList )
        do
            local stageName = L""
            if ( timeout.killList[1] ~= nil )
            then
                stageName = timeout.killList[1]
            end
            
            AddListBoxRow( stageName, CharacterWindow.TimeString( timeout.timeRemaining ), color, DefaultColor.ZERO_TINT )
        end
           
        lockoutIndex = lockoutIndex + 1
    end

    -- If there were no rows added, put a message saying there are no timers in the first row
    if ( rowCount == 1 )
    then
        AddListBoxRow( GetString( StringTables.Default.LABEL_TIMEOUTS_NO_TIMEOUTS ), L"", DataUtils.GetAlternatingRowColor( 1 ), DefaultColor.ZERO_TINT )
    end
    
    -- there is currently no sorting but the listbox needs to know how many lines to display
    ListBoxSetDisplayOrder("CharacterWindowTimeoutsList", displayOrder )

end

-- calculate the number of days, hours, and minutes from the minutes remaining field of the lockout
function CharacterWindow.TimeString( minutes )
    local days = 0
    local hours = 0
    local remainingHours = 0
    local remainingMinutes = math.fmod(minutes, 60)
    minutes = minutes - remainingMinutes
    
    if minutes > 0
    then
        hours = minutes / 60
        remainingHours = math.fmod(hours, 24)
        hours = hours - remainingHours
        if hours > 0
        then
            days = hours / 24
        end
    end

    return GetStringFormat( StringTables.Default.LABEL_TIMEOUTS_TIME_FORMAT, { days, remainingHours, remainingMinutes} )
end

-- this is called in the update loop and it keeps track of the elapsed time in order to
-- update the lockout times on the client without having to spam the server for an update
-- so that the client stays in sync with the server we will resync every 10 minutes
function CharacterWindow.UpdateTimeouts( elapsedTime )
    -- add the ela[sed time to our count
    CharacterWindow.timeoutElapsedTime = CharacterWindow.timeoutElapsedTime + elapsedTime
    -- has it been a minute?
    if CharacterWindow.timeoutElapsedTime > 60
    then
        -- if so reset our count
        CharacterWindow.timeoutElapsedTime = CharacterWindow.timeoutElapsedTime - 60
        -- update the timeout table's times
        CharacterWindow.DecrementLockouts()
        -- update the listbox with the new times
        CharacterWindow.UpdateLockouts()
    end
end

-- this is where we update the timeout times on the client
function CharacterWindow.DecrementLockouts()
    for index, timeout in pairs( CharacterWindow.timeoutsList )
    do
        timeout.timeRemaining = timeout.timeRemaining - 1
        -- if the new time remaining is zero or less we should sync up with the server 
        -- so this one can be removed from the list
        if timeout.timeRemaining <= 0
        then
            CharacterWindow.RequestTimeoutInfo()
            return -- since we are syncing we might as well not bother to finish our timer updates
        end
    end
end

-- called when the timeout tab is shown
function CharacterWindow.OnTimeoutShown()
    -- if for some reason we haven't gotten a timeout sync from the server we will request one
    if CharacterWindow.firstTimeoutsync
    then
        CharacterWindow.RequestTimeoutInfo()
        -- set to false so that this doesn't get spammed if the server isn't responding for some reason
        CharacterWindow.firstTimeoutsync = false
    end
end

-- used when the list changes what lines are shown, when the list box is scrolled for example
function CharacterWindow.PopulateTimeoutList()
    if (CharacterWindowTimeoutsList.PopulatorIndices ~= nil) then                
        for rowIndex, dataIndex in ipairs (CharacterWindowTimeoutsList.PopulatorIndices) do
            local data = CharacterWindow.timeoutList[ dataIndex ]
            local targetRowWindow = "CharacterWindowTimeoutsListRow"..rowIndex
            
            DefaultColor.SetWindowTint(targetRowWindow.."Background", data.bgColor)
            DefaultColor.LabelSetTextColor(targetRowWindow.."Text", data.fgColor)
            
            if (data.timeStr == L"")
            then
                -- Expand main text label to fill the entire line if there is no time label.
                WindowSetShowing(targetRowWindow.."TimeLeft", false)
                WindowSetDimensions(targetRowWindow.."Text", 450, 19)
            else
                -- Shink main text label to make room for time label
                WindowSetDimensions(targetRowWindow.."Text", 240, 19)
                WindowSetShowing(targetRowWindow.."TimeLeft", true)
            end
        end
    end    
end

function CharacterWindow.HighlightSlot( windowName )

    ButtonSetStayDownFlag( windowName, true )     
    ButtonSetPressedFlag( windowName, true )
end

function CharacterWindow.UnHighlightSlot( windowName )
    
    ButtonSetStayDownFlag( windowName, false )     
    ButtonSetPressedFlag( windowName, false )
end
