
-- Constants
CharacterWindow.TOOLTIP_TROPHY_NEXT_LOC = GetString( StringTables.Default.TOOLTIP_TROPHY_NEXT_LOC )
CharacterWindow.TOOLTIP_TROPHY_PREV_LOC = GetString( StringTables.Default.TOOLTIP_TROPHY_PREV_LOC )
CharacterWindow.TOOLTIP_TROPHY_NO_AVAILABLE_LOC = GetString( StringTables.Default.TOOLTIP_TROPHY_NO_AVAILABLE_LOC )
CharacterWindow.TOOLTIP_TROPHY_INVALID_LOC = GetString( StringTables.Default.TOOLTIP_TROPHY_INVALID_LOC )

CharacterWindow.NUM_TROPHY_SLOTS = GameData.Player.c_NUM_TROPHIES
CharacterWindow.EQUIPMENT_EMPTY_TINT = {R=204, G=168, B=144}
CharacterWindow.TROPHY_EMPTY_TINT = {R=170, G=140, B=120}
CharacterWindow.TROPHY_INVALID_LOC_TINT = Tooltips.COLOR_WARNING 
CharacterWindow.INVALID_TROPHY_POSITION = 0

CharacterWindow.trophyData = {}
CharacterWindow.trophyLocData = {} -- locations where trophies can be attached to

CharacterWindow.currentlySelectedTrophyPosition = CharacterWindow.INVALID_TROPHY_POSITION
CharacterWindow.trophyDragStarted = false

local iconTexture, iconX, iconY = GetIconData( 37 )
CharacterWindow.TROPHY_EMPTY_ICON = {texture=iconTexture, x=iconX, y=iconY }

iconTexture, iconX, iconY = GetIconData( 38 )
CharacterWindow.TROPHY_INVALID_ATTACHMENT_POINT_ICON = {texture=iconTexture, x=iconX, y=iconY }

iconTexture, iconX, iconY = GetIconData( 39 )
CharacterWindow.TROPHY_LOCKED_ICON = {texture=iconTexture, x=iconX, y=iconY }

iconTexture, iconX, iconY = GetIconData( 40 )
CharacterWindow.TROPHY_NO_ATTACHMENT_POINT_ICON = {texture=iconTexture, x=iconX, y=iconY }


-- this gets called during intitialization and for level up events in case a new slot becomes unlocked
function CharacterWindow.UnlockTrophies()
    
    local userLevel = GameData.Player.level
    if userLevel < 1 then
        CharacterWindow.numOfTrophiesUnlocked = 0
        return
    end
    
    CharacterWindow.numOfTrophiesUnlocked = math.min( math.floor(userLevel / 10) + 1, CharacterWindow.NUM_TROPHY_SLOTS )
    
    -- unlocked
    for trophyNum = 1, CharacterWindow.numOfTrophiesUnlocked do
        ButtonSetDisabledFlag( "CharacterWindowContentsEquipmentSlot"..(trophyNum+CharacterWindow.NUM_EQUIPMENT_SLOTS), false )
        
        local text = GetStringFormat( StringTables.Default.LABEL_TROPHY, { trophyNum } )
        CharacterWindow.EquipmentSlotInfo[trophyNum+CharacterWindow.NUM_EQUIPMENT_SLOTS] =  { name=text} 
        
        local lockIconWindowName = "CharacterWindowContentsEquipmentSlot"..(trophyNum+CharacterWindow.NUM_EQUIPMENT_SLOTS).."LockIcon"
        WindowSetShowing( lockIconWindowName, false )
    end
    
    -- locked
    -- icon is now assembled from the untinted icon with a lock mini-icon on top
    for trophyNum = CharacterWindow.numOfTrophiesUnlocked+1, CharacterWindow.NUM_TROPHY_SLOTS do
    
        ButtonSetDisabledFlag( "CharacterWindowContentsEquipmentSlot"..(trophyNum+CharacterWindow.NUM_EQUIPMENT_SLOTS), true )
        local windowName = "CharacterWindowContentsEquipmentSlot"..(trophyNum+CharacterWindow.NUM_EQUIPMENT_SLOTS).."IconBase"
        local icon = CharacterWindow.TROPHY_EMPTY_ICON
        DynamicImageSetTexture( windowName, icon.texture, icon.x, icon.y)

        local requiredLevel = (trophyNum-1) * 10
        
        local text1 = GetStringFormat( StringTables.Default.LABEL_TROPHY, { trophyNum } )
        local text2 = GetStringFormat( StringTables.Default.LABEL_TROPHY_LOCKED, { requiredLevel } )
        CharacterWindow.EquipmentSlotInfo[trophyNum+CharacterWindow.NUM_EQUIPMENT_SLOTS] =  { name=text1..L"\n"..text2 } 
        
        local lockIconWindowName = "CharacterWindowContentsEquipmentSlot"..(trophyNum+CharacterWindow.NUM_EQUIPMENT_SLOTS).."LockIcon"
        lockIcon = CharacterWindow.TROPHY_LOCKED_ICON
        DynamicImageSetTexture( lockIconWindowName, lockIcon.texture, lockIcon.x, lockIcon.y)
        WindowSetShowing( lockIconWindowName, true )
        
        local miniIconWindowName = "CharacterWindowContentsEquipmentSlot"..(trophyNum+CharacterWindow.NUM_EQUIPMENT_SLOTS).."MiniIcon"
        WindowSetShowing( miniIconWindowName, false )
    end
    
    CharacterWindow.UpdateSlotIcons()
end


function CharacterWindow.GetFirstAvailableTrophySlot( trophyData )

    for slot = 1, CharacterWindow.numOfTrophiesUnlocked do
        if CharacterWindow.trophyData[slot].uniqueID == 0 then
            return slot
        end
    end
    
    return CharacterWindow.INVALID_TROPHY_POSITION
end

function CharacterWindow.ValidLocationForTrophy( trophyData, attachPoint )
    if attachPoint.inUse
    then
        return false
    end
    
    -- only need to check slot restrictions if the slotReqs table is set
    if trophyData.slots == nil or #trophyData.slots == 0
    then
        return true
    end
    
    for i, slotAllowed in ipairs(trophyData.slots) do
        if attachPoint.inventorySlotNum == slotAllowed
        then
            return true     -- found as a valid slot
        end
    end
    
    return false        -- wasn't found in the valid slot list

end

-- if trophyData is nil then return any open attachment point
-- TODO: we need to limit this to valid locations for the passed in trophyData
--
-- if startIndex is set start search from that point
-- and wrap around the last index number to check 1 to startIndex-1
--
function CharacterWindow.GetNextAvailableAttachmentPoint( trophyData, startIndex )

    if CharacterWindow.trophyLocData == nil or #CharacterWindow.trophyLocData == 0 then
        return 0, nil
    end
    
    startIndex = startIndex or 1
    local attachPoint

    for index = startIndex, #CharacterWindow.trophyLocData do
        attachPoint = CharacterWindow.trophyLocData[index]
        if CharacterWindow.ValidLocationForTrophy( trophyData, attachPoint ) then
            return index, attachPoint 
        end
    end
    
    for index = 1, (startIndex-1) do
        attachPoint = CharacterWindow.trophyLocData[index]
        if CharacterWindow.ValidLocationForTrophy( trophyData, attachPoint ) then
            return index, attachPoint 
        end
    end

    return 0, nil
end


-- Does the reverse order search of CharacterWindow.GetNextAvailableAttachmentPoint 
--
-- if trophyData is nil then return any open attachment point
-- TODO: we need to limit this to valid locations for the passed in trophyData
--
-- if startIndex is set start search from that point
-- and wrap around the last index number to check 1 to startIndex-1
--
function CharacterWindow.GetPreviousAvailableAttachmentPoint( trophyData, startIndex )
    
    if CharacterWindow.trophyLocData == nil or #CharacterWindow.trophyLocData == 0 then
        return 0, nil
    end
    
    if startIndex < 1 then
        startIndex = #CharacterWindow.trophyLocData
    end
    
    startIndex = startIndex or #CharacterWindow.trophyLocData
    
    local attachPoint

    for index = startIndex, 1, -1 do
        attachPoint = CharacterWindow.trophyLocData[index]
        if CharacterWindow.ValidLocationForTrophy( trophyData, attachPoint ) then
            return index, attachPoint 
        end
    end
    for index = #CharacterWindow.trophyLocData, (startIndex+1), -1 do
        attachPoint = CharacterWindow.trophyLocData[index]
        if CharacterWindow.ValidLocationForTrophy( trophyData, attachPoint ) then
            return index, attachPoint 
        end
    end
    
    return 0, nil
end

function CharacterWindow.HideTrophyLocArrows()

    WindowSetShowing( "CharacterWindowPreviousButton", false )
    WindowSetShowing( "CharacterWindowNextButton", false )
    
    if CharacterWindow.currentlySelectedTrophyPosition ~= CharacterWindow.INVALID_TROPHY_POSITION then
        local previousWindow = "CharacterWindowContentsEquipmentSlot"..(CharacterWindow.currentlySelectedTrophyPosition+CharacterWindow.NUM_EQUIPMENT_SLOTS)
        CharacterWindow.UnHighlightSlot( previousWindow )
        CharacterWindow.currentlySelectedTrophyPosition = CharacterWindow.INVALID_TROPHY_POSITION 
    end 

    WindowUnregisterEventHandler( "CharacterWindow", SystemData.Events.L_BUTTON_DOWN_PROCESSED )
end

function CharacterWindow.ShowTrophyLocArrows( trophyNum )

    local previousWindow = "CharacterWindowContentsEquipmentSlot"..(CharacterWindow.currentlySelectedTrophyPosition+CharacterWindow.NUM_EQUIPMENT_SLOTS)
    CharacterWindow.UnHighlightSlot( previousWindow )
    
    -- trophy windows are grouped with other equipment slots
    local windowName = "CharacterWindowContentsEquipmentSlot"..(trophyNum+CharacterWindow.NUM_EQUIPMENT_SLOTS) 
    
    WindowClearAnchors( "CharacterWindowPreviousButton" )
    WindowAddAnchor( "CharacterWindowPreviousButton", "left", windowName, "right", -5, 0 )
    WindowSetShowing( "CharacterWindowPreviousButton", true )

    WindowClearAnchors( "CharacterWindowNextButton" )
    WindowAddAnchor( "CharacterWindowNextButton", "right", windowName, "left", 5, 0 )
    WindowSetShowing( "CharacterWindowNextButton", true )
    
    CharacterWindow.HighlightSlot( windowName )
    CharacterWindow.currentlySelectedTrophyPosition = trophyNum
    
    -- there is no way to see if already registered so we go ahead and unregister first to avoid the lua error from duplicate register
    WindowUnregisterEventHandler( "CharacterWindow", SystemData.Events.L_BUTTON_DOWN_PROCESSED )
    WindowRegisterEventHandler( "CharacterWindow", SystemData.Events.L_BUTTON_DOWN_PROCESSED, "CharacterWindow.OnLButtonDownProcessed") 
end

-- EventHandler for OnLButtonDownProcessed, which is only temporarily registered in order to deactivate 
--   the TrophyLocArrows when clicking off of them
--
function CharacterWindow.OnLButtonDownProcessed( )
    
    local windowName = SystemData.MouseOverWindow.name
    local currentTrophyWindowName = "CharacterWindowContentsEquipmentSlot"..(CharacterWindow.currentlySelectedTrophyPosition+CharacterWindow.NUM_EQUIPMENT_SLOTS)

    if windowName ~= nil and windowName ~= currentTrophyWindowName and 
       windowName ~= "CharacterWindowPreviousButton" and windowName ~= "CharacterWindowNextButton" then
        CharacterWindow.HideTrophyLocArrows()
        CharacterWindow.trophyDragStarted = false
    end

end

function CharacterWindow.NextButtonPressed()

    --TEMP FIX for GetLocationsForTrophies()  failing for unknown reasons
    if CharacterWindow.trophyLocData == nil then
        CharacterWindow.RerequestTrophyLocData()
    end
    --END TEMP FIX
    
    if CharacterWindow.currentlySelectedTrophyPosition == CharacterWindow.INVALID_TROPHY_POSITION then  
        -- this should never be true
        return
    end
    
    local trophyData = CharacterWindow.trophyData[CharacterWindow.currentlySelectedTrophyPosition]
    
    local startIndex = CharacterWindow.GetIndexForTrophyLoc( trophyData.trophyLocation, trophyData.trophyLocIndex )
    local index, attachPointData = CharacterWindow.GetNextAvailableAttachmentPoint( trophyData, startIndex+1 )
    
    if index ~= 0 then
        AttachTrophyToLocation( CharacterWindow.currentlySelectedTrophyPosition, attachPointData.trophyLocation, attachPointData.trophyLocIndex)
    end
end

function CharacterWindow.NextButtonMouseOver()

    Tooltips.CreateTextOnlyTooltip( "CharacterWindowNextButton", CharacterWindow.TOOLTIP_TROPHY_NEXT_LOC )
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT)
end

function CharacterWindow.PreviousButtonPressed()

    --TEMP FIX for GetLocationsForTrophies()  failing for unknown reasons
    if CharacterWindow.trophyLocData == nil then
        CharacterWindow.RerequestTrophyLocData()
    end
    --END TEMP FIX

    if CharacterWindow.currentlySelectedTrophyPosition == CharacterWindow.INVALID_TROPHY_POSITION then  
        -- this should never be true
        return
    end
    
    local trophyData = CharacterWindow.trophyData[CharacterWindow.currentlySelectedTrophyPosition]
    
    local startIndex = CharacterWindow.GetIndexForTrophyLoc( trophyData.trophyLocation, trophyData.trophyLocIndex )
    local index, attachPointData = CharacterWindow.GetPreviousAvailableAttachmentPoint( trophyData, startIndex-1 )
    if index ~= 0 then
        AttachTrophyToLocation( CharacterWindow.currentlySelectedTrophyPosition, attachPointData.trophyLocation, attachPointData.trophyLocIndex)
    end 
end

function CharacterWindow.PreviousButtonMouseOver()

    Tooltips.CreateTextOnlyTooltip( "CharacterWindowPreviousButton", CharacterWindow.TOOLTIP_TROPHY_PREV_LOC )
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT)
end


function CharacterWindow.GetIndexForTrophyLoc( location, index )

    if CharacterWindow.trophyLocData == nil or #CharacterWindow.trophyLocData == 0 then
        return 0, nil
    end

    for apIndex, attachPoint in pairs( CharacterWindow.trophyLocData ) do
        if attachPoint.trophyLocation == location and attachPoint.trophyLocIndex == index then
            return apIndex, attachPoint
        end
    end
    
    return 0, nil
end


function CharacterWindow.UpdateTrophySlotIcons()
    CharacterWindow.trophyLocData = GetLocationsForTrophies()   -- provides list of available attachment points
    CharacterWindow.trophyData = DataUtils.GetTrophyData()      -- provides item info for all trophy slots (may be blank data)
    CharacterWindow.numOfTrophiesEquipped = 0
    
    local trophyData, miniIconWindowName, index, attachPoint, validLocation, icon, texture, x, y, iconWindowName, availableIndex

    local unattachedTrophies = {}
    for  slot = 1, CharacterWindow.numOfTrophiesUnlocked  do  
        trophyData = CharacterWindow.trophyData[slot]
        
        -- trophy windows are grouped with other equipment slots
        miniIconWindowName = "CharacterWindowContentsEquipmentSlot"..(slot+CharacterWindow.NUM_EQUIPMENT_SLOTS).."MiniIcon"    
        
        if( trophyData ~= nil and trophyData.uniqueID ~= 0) then
            texture, x, y = GetIconData( trophyData.iconNum ) 

            index, attachPoint = CharacterWindow.GetIndexForTrophyLoc( trophyData.trophyLocation, trophyData.trophyLocIndex )

            -- if trophy is not in a valid location, show mini icon and tooltip to say why invalid
            --
            validLocation = ( index ~= 0 and CharacterWindow.ValidLocationForTrophy( trophyData, attachPoint ) )
            WindowSetShowing( miniIconWindowName, not validLocation )
            if validLocation then -- trophy attached to a valid location

                attachPoint.inUse = true  -- mark it as not available for other trophies
                trophyData.tooltip = L""  -- tooltip only necessary for invalid location
            else
                -- Add to list of unattached trophies.
                -- We need to finish marking which ones are in use before we 
                --   can determine whether there are available slots for the unattached ones
                unattachedTrophies[slot] = trophyData
            end

            CharacterWindow.numOfTrophiesEquipped = CharacterWindow.numOfTrophiesEquipped + 1
        else

            -- display empty trophy slot icon
            icon = CharacterWindow.TROPHY_EMPTY_ICON
            texture, x, y = icon.texture, icon.x, icon.y

            WindowSetShowing( miniIconWindowName, false )
        end     
        
        iconWindowName = "CharacterWindowContentsEquipmentSlot"..(slot+CharacterWindow.NUM_EQUIPMENT_SLOTS).."IconBase"
        DynamicImageSetTexture( iconWindowName, texture, x, y )
    end 

    -- we can't tell if anything is valid if retrieving CharacterWindow.trophyLocData failed, so may as well leave it with previous icons/tooltips until i 
    --if CharacterWindow.trophyLocData == nil then
    --    return
    --end
    
    -- now loop through the unattached trophies and provide the appropriate mini icon and tooltip
    for slot, trophyData in pairs(unattachedTrophies) do

        miniIconWindowName = "CharacterWindowContentsEquipmentSlot"..(slot+CharacterWindow.NUM_EQUIPMENT_SLOTS).."MiniIcon"
        availableIndex = CharacterWindow.GetNextAvailableAttachmentPoint( trophyData )

        if availableIndex == 0 then
            -- there are no available locations for this trophy
            icon = CharacterWindow.TROPHY_NO_ATTACHMENT_POINT_ICON
            trophyData.tooltip = CharacterWindow.TOOLTIP_TROPHY_NO_AVAILABLE_LOC 
        else 
            -- the current set location is not available
            icon = CharacterWindow.TROPHY_INVALID_ATTACHMENT_POINT_ICON 
            trophyData.tooltip = CharacterWindow.TOOLTIP_TROPHY_INVALID_LOC 
        end
        
        DynamicImageSetTexture( miniIconWindowName, icon.texture, icon.x, icon.y )
    end

    local tint = CharacterWindow.NORMAL_TINT

    -- Set the tints for the trophies
    if( CharacterWindow.mode == CharacterWindow.MODE_ITEM_APPEARANCE )
    then
        tint = CharacterWindow.CANNOT_CUSTOMIZE_TINT
    end
    
    for i=1, CharacterWindow.NUM_TROPHY_SLOTS
    do
        WindowSetTintColor(  "CharacterWindowContentsEquipmentSlot"..(i+CharacterWindow.NUM_EQUIPMENT_SLOTS), tint.r, tint.g, tint.b )
    end
end

function CharacterWindow.RerequestTrophyLocData()

    CharacterWindow.trophyLocData = GetLocationsForTrophies()
    if CharacterWindow.trophyLocData == nil then
        DEBUG(L"CharacterWindow.RerequestTrophyLocData ERROR: still failed to receive trophy attachment point data")
        return false
    else 
        return true
    end
    
end


-- OnLButtonDown Handler
function CharacterWindow.TrophyLButtonDown()

    local slot = WindowGetId(SystemData.ActiveWindow.name)
    if Cursor.IconOnCursor() then
        
        local trophyIndex = slot + GameData.Player.c_TROPHY_START_INDEX - 1
        if (Cursor.Data.Source == Cursor.SOURCE_EQUIPMENT and Cursor.Data.SourceSlot == trophyIndex) then
            Cursor.Clear()
        end
        
    elseif CharacterWindow.trophyData[slot].uniqueID ~= 0 then  
        
        -- first click on the slot turns on trophy attachment buttons
        -- second click, needs to be done to cause pick up onto cursor
        -- click and hold should always pick up onto cursor
        if CharacterWindow.currentlySelectedTrophyPosition ~= slot then
            CharacterWindow.ShowTrophyLocArrows( slot )
        else
            local trophySlot = slot + GameData.Player.c_TROPHY_START_INDEX - 1  
            Cursor.PickUp( Cursor.SOURCE_EQUIPMENT, trophySlot, CharacterWindow.trophyData[slot].uniqueID, CharacterWindow.trophyData[slot].iconNum, true )   
            CharacterWindow.HideTrophyLocArrows()

        end

        CharacterWindow.dropPending = false  
    end
end

-- MouseDrag Handler on Trophy slots ( for drag & drop )
function CharacterWindow.TrophyDrag()

    -- have to skip the first TrophyDrag to wait and see if this is a single click (which also throws the OnDrag event)
    if not CharacterWindow.trophyDragStarted then
        CharacterWindow.trophyDragStarted = true
        return
    end

    local slot = WindowGetId(SystemData.ActiveWindow.name)
    if not Cursor.IconOnCursor() and CharacterWindow.trophyData[slot].uniqueID ~= 0 and CharacterWindow.currentlySelectedTrophyPosition == slot then

        CharacterWindow.trophyDragStarted = false
        local trophySlot = slot + GameData.Player.c_TROPHY_START_INDEX - 1  
        Cursor.PickUp( Cursor.SOURCE_EQUIPMENT, trophySlot, CharacterWindow.trophyData[slot].uniqueID, CharacterWindow.trophyData[slot].iconNum, true )   
        CharacterWindow.HideTrophyLocArrows()
    end

end

-- OnLButtonUp Handler ( Overload L Button up for drag & drop )
function CharacterWindow.TrophyLButtonUp()

    if( CharacterWindow.mode == CharacterWindow.MODE_DYE_MERCHANT )
    then
        local slot = WindowGetId(SystemData.ActiveWindow.name)
        local displayString
        if( CharacterWindow.trophyData[slot].uniqueID == 0 )
        then
            displayString = GetString( StringTables.Default.TEXT_DYE_MERCHANT_NO_ITEM_IN_SLOT )
        else
            displayString = GetString( StringTables.Default.TEXT_CANNOT_DYE_ITEM )
        end
        CharacterWindow.MakeOkayDialog( displayString )
        return
    end
    
    CharacterWindow.trophyDragStarted = false
    if Cursor.IconOnCursor() and CharacterWindow.dropPending == false then
        
        local slot = WindowGetId(SystemData.ActiveWindow.name)
        local trophyIndex = slot + GameData.Player.c_TROPHY_START_INDEX - 1
        local sourceWindow = Cursor.Data.Source
        local sourceSlot = Cursor.Data.SourceSlot
        
        -- don't need to move the item if it's dropped in same slot
        if (sourceWindow == Cursor.SOURCE_EQUIPMENT and sourceSlot == trophyIndex) then
            return
        end
        
        if ( CharacterWindow.mode == CharacterWindow.MODE_ITEM_APPEARANCE )
        then
            -- Trophy slots cannot have their appearance customized
            local text = GetStringFormat( StringTables.Default.LABEL_TROPHY, { slot } )
            CharacterWindow.PrintError( StringTables.Default.ERROR_TEXT_ITEM_APPEARANCE_NEVER_CUSTOMIZED, text )
            return
        end
        
        if CharacterWindow.IsConfirmationNeededToMoveItem( sourceWindow, sourceSlot, trophyIndex ) then
            return
        end
        
        -- TODO: should be able to automatically select attachment point when moving from other locations (e.g. bank), 
        --   but we don't have a function that can get the itemData from an unknown Cursor.Data.Source, so just auto attach
        --   if from Backpack, and can just move it otherwise.
        if sourceWindow == Cursor.SOURCE_INVENTORY then
            local itemData = DataUtils.GetItems ()[sourceSlot]
            CharacterWindow.AutoAttachTrophy( sourceWindow, sourceSlot, trophyIndex, itemData )
        else

            RequestMoveItem( sourceWindow, sourceSlot, Cursor.SOURCE_EQUIPMENT, trophyIndex, Cursor.Data.StackAmount ) 
        end
    end
end

-- OnRButtonDown Handler
function CharacterWindow.TrophyRButtonDown()
    
    CharacterWindow.trophyDragStarted = false
    local slot = WindowGetId(SystemData.ActiveWindow.name)
    
    -- verify that we're clicking on an icon before spamming the server
    if not Cursor.IconOnCursor() and CharacterWindow.trophyData[slot].uniqueID ~= 0  then
    
        local trophyIndex = slot + GameData.Player.c_TROPHY_START_INDEX - 1
        RequestMoveItem( Cursor.SOURCE_EQUIPMENT, trophyIndex, Cursor.SOURCE_INVENTORY, CharacterWindow.FIRST_AVAILABLE_INVENTORY_SLOT, CharacterWindow.equipmentData[slot].stackCount)
        CharacterWindow.HideTrophyLocArrows()
    end
end


-- if itemData does not contain a valid attachment point
--   then try to auto attach to first available attachment point
-- This function also now handles the Request move since attaching 
--   at the same time as moving is a little tricky.
--  
function CharacterWindow.AutoAttachTrophy( sourceLocation, sourceSlot, trophySlot, itemData )
    
    if itemData == nil then
        return
    end
    
    local trophyLocation = GameData.Player.c_INVALID_TROPHY_LOCATION
    local trophyLocIndex = 0
    
    -- check if there is a previous attachment position (from being previously attached) and if that is still valid
    local apIndex, apData = CharacterWindow.GetIndexForTrophyLoc( itemData.trophyLocation, itemData.trophyLocIndex )
    if ( apIndex ~= 0 and CharacterWindow.ValidLocationForTrophy( itemData, apData ) ) then

        trophyLocation = apData.trophyLocation
        trophyLocIndex = apData.trophyLocIndex    
    else
    
        local index, attachPointData = CharacterWindow.GetNextAvailableAttachmentPoint( itemData )
        if index ~= 0 then
            trophyLocation = attachPointData.trophyLocation
            trophyLocIndex = attachPointData.trophyLocIndex
        end
    end
    
    RequestEquipTrophy( sourceLocation, sourceSlot, trophySlot, trophyLocation, trophyLocIndex )
end

-- SystemData.Events.PLAYER_TROPHY_SLOT_UPDATED Handler
function CharacterWindow.UpdateTrophySlot( updatedSlots )
    
    -- We'll stick to this for now but as soon as possible we must switch to updating
    -- ONLY the slot with the concerned item.

    CharacterWindow.UpdateSlotIcons()

   for _, slot in ipairs( updatedSlots )
   do         
        local uniqueID = CharacterWindow.trophyData[slot].uniqueID
        -- If we are placing the item that is currently on the cursor, clear it
        if( Cursor.IconOnCursor() and (Cursor.Data.ObjectId == uniqueID or CharacterWindow.dropPending == true) ) then 
            Cursor.Clear()  
            CharacterWindow.dropPending = false
        end
        
        -- If we are mousing over the updated slot, show the tooltip
        if SystemData.MouseOverWindow.name == "CharacterWindowContentsEquipmentSlot"..(slot+CharacterWindow.NUM_EQUIPMENT_SLOTS) then   
            
            CharacterWindow.TrophyMouseOverSlot( slot )
        end
    end

    CharacterWindow.UpdateStatsNew()
end

-- OnMouseMove Handler
function CharacterWindow.TrophyMouseOver()
                            
    CharacterWindow.TrophyMouseOverSlot( WindowGetId(SystemData.ActiveWindow.name) )
end

function CharacterWindow.TrophyMouseOverSlot( slot )
    
    -- trophy windows are grouped with other equipment slots
    local windowName = "CharacterWindowContentsEquipmentSlot"..(slot+CharacterWindow.NUM_EQUIPMENT_SLOTS) 
    
    if( CharacterWindow.trophyData[slot].uniqueID == 0 ) then     
       
        Tooltips.CreateTextOnlyTooltip( windowName, nil )
        Tooltips.SetTooltipText( 1, 1, CharacterWindow.EquipmentSlotInfo[(slot+CharacterWindow.NUM_EQUIPMENT_SLOTS)].name )
        Tooltips.SetTooltipColor( 1, 1, 123, 172, 220 )
        Tooltips.Finalize()
        Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT )
    else

        Tooltips.CreateItemTooltip( CharacterWindow.trophyData[slot], windowName, Tooltips.ANCHOR_WINDOW_RIGHT, true )   
    end
end 

-- TrophyMiniIconMouseOver is  commmented out because the tooltip on the mini icon 
--    is not working properly. It's repeatedly
--    firing OnMouseOver events rather than only sending it once.

function CharacterWindow.TrophyMiniIconMouseOver()

    local windowName = SystemData.ActiveWindow.name
    local slot = WindowGetId( WindowGetParent( windowName ) )
    CharacterWindow.TrophyMiniIconMouseOverSlot(windowName, slot)
end
    
function CharacterWindow.TrophyMiniIconMouseOverSlot(windowName, slot)
    
    local trophyData = CharacterWindow.trophyData[slot]
     
    local invalidTint = CharacterWindow.TROPHY_INVALID_LOC_TINT
    Tooltips.CreateTextOnlyTooltip( windowName, nil )
    Tooltips.SetTooltipText( 1, 1, trophyData.tooltip )
    Tooltips.SetTooltipColor( 1, 1, invalidTint.r, invalidTint.g, invalidTint.b )
    Tooltips.Finalize()
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT )
    
end

function CharacterWindow.armorHasAttachmentPoint( trophyLocation, trophyLocIndex )
    
    local slot = CharacterWindow.GetIndexForTrophyLoc( trophyLocation, trophyLocIndex )
    
    if slot ~= 0 then
        return true 
    end
    
    return false
end
