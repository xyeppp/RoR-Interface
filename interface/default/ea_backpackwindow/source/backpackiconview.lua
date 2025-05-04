-------------------------------------------------------------------------------------
-- Backpack Icon View Utils
--
-- This file contains the implementation for the Backpack Icon View Tab. 
-- 
-------------------------------------------------------------------------------------

function EA_Window_Backpack.InitializeIconView()

    EA_Window_Backpack.InitializeSlots()
    EA_Window_Backpack.UpdateBackpackSlots()

    -- The number of icon slots is determined by the player's rank    
    WindowRegisterEventHandler( EA_Window_Backpack.windowName, SystemData.Events.PLAYER_NEW_NUMBER_OF_BACKPACK_SLOTS, "EA_Window_Backpack.OnNumBackpackSlotsUpdated") 
    WindowRegisterEventHandler( EA_Window_Backpack.windowName, SystemData.Events.PLAYER_CRAFTING_INVENTORY_UPDATED, "EA_Window_Backpack.OnCraftingInventoryUpdated") 
    
    EA_Window_Backpack.OnNumBackpackSlotsUpdated()
    EA_Window_Backpack.OnCraftingInventoryUpdated()
end


function EA_Window_Backpack.SetActionButton( buttonGroupName, buttonIndex, itemData, isLocked, highLightColor )
	
	if DoesWindowExist( buttonGroupName ) == false then
		ERROR(L"SetActionButton failed to find window="..StringToWString(buttonGroupName) )
		return
	end
	
    -- Clear the Slot if no item is set.
    if not EA_Window_Backpack.ValidItem( itemData ) then               		
        
        ActionButtonGroupSetIcon( buttonGroupName, buttonIndex, 0 )
        ActionButtonGroupSetText( buttonGroupName, buttonIndex, L"" )
        ActionButtonGroupSetTimer( buttonGroupName, buttonIndex, 0, 0 )        
        ActionButtonGroupSetTintColor( buttonGroupName, buttonIndex,  255, 255, 255 )
        
        return
    end

    -- Set the Data

    -- Icon
    ActionButtonGroupSetIcon( buttonGroupName, buttonIndex, itemData.iconNum )
    
    -- Tint & Lock
    if isLocked 
    then
        if highLightColor 
        then
            ActionButtonGroupSetTintColor(  buttonGroupName, buttonIndex,  highLightColor.r, highLightColor.g, highLightColor.b )
        else
            ActionButtonGroupSetTintColor( buttonGroupName, buttonIndex, 75, 75, 75)
        end
    else
        ActionButtonGroupSetTintColor( buttonGroupName, buttonIndex,  255, 255, 255 )
    end      
	
    
    -- Count            
    local text = L""
    if itemData.stackCount > 1 then
        text = L""..itemData.stackCount
    end
    ActionButtonGroupSetText( buttonGroupName, buttonIndex, text )
    
    
    -- Cooldown Timer
    local cooldownTimeLeft, totalCooldownTime = EA_Window_Backpack.GetItemCooldownTimers( itemData )
    if( cooldownTimeLeft ~= nil )
    then
        ActionButtonGroupSetTimer( buttonGroupName, buttonIndex, totalCooldownTime, cooldownTimeLeft )
    else    
        ActionButtonGroupSetTimer( buttonGroupName, buttonIndex, 0, 0 ) 
    end
    
    -- NOTE: I've removing the call to WindowSetGameActionData( buttonName, GameData.PlayerActions.USE_ITEM
    --   We now handle the UseItem call directly in EA_Window_Backpack.EquipmentRButtonUp.
    
end




function EA_Window_Backpack.UpdateAllIconViewSlots()
    
    for backpackType = 1, EA_Window_Backpack.NUM_BACKPACK_TYPES
    do
        -- Quest icons are updated separatly
        if backpackType == EA_Window_Backpack.TYPE_QUEST
        then
            continue
        end
        local inventory = EA_Window_Backpack.GetItemsFromBackpack( backpackType )
        if inventory ~= nil
        then
            for inventorySlot = 1, EA_Window_Backpack.numberOfSlots[backpackType]
            do		
                local itemData = inventory[inventorySlot]
                EA_Window_Backpack.UpdateIconViewSlot( backpackType, inventorySlot, itemData )        	        
            end
        end
    end
end

function EA_Window_Backpack.UpdateIconViewSlot( backpackType, slot, itemData )
    
    -- Get the Pocket
    local pocketNumber = EA_Window_Backpack.GetPocketNumberForSlot( backpackType, slot )
    
    local pocketWindowName = EA_Window_Backpack.GetPocketName( pocketNumber )
    
    -- Update the ActionButton
    local buttonGroupWindowName = pocketWindowName.."Buttons"
    local buttonIndex = slot - EA_Window_Backpack.pockets[pocketNumber].firstSlotID + 1
    
    -- Tint
    local highLightColor = DefaultColor.CLEAR
    local isLocked, lockedWindow = EA_Window_Backpack.IsSlotLocked(slot, backpackType)
	if isLocked 
	then
		highLightColor = lockedWindow.highLightColor
	end
    
    EA_Window_Backpack.SetActionButton( buttonGroupWindowName, buttonIndex, itemData, isLocked, highLightColor )    
    
    -- If we are mousing over the updated slot, show the tooltip
    if( SystemData.MouseOverWindow.name == buttonGroupWindowName.."Button"..buttonIndex )
    then
        EA_Window_Backpack.MouseOverEquipmentSlot( slot, SystemData.MouseOverWindow.name )
    end
end

-------------------------------------------------------------------------
-- Accessor Functions
-------------------------------------------------------------------------

function EA_Window_Backpack.GetInternalPocketAndType( pocketNumber )
    local remainder = 0
    for backpackType = 1, EA_Window_Backpack.NUM_BACKPACK_TYPES
    do
        remainder = pocketNumber - EA_Window_Backpack.MAX_NUM_OF_POCKETS[backpackType]
   
        if( remainder <= 0 )
        then
            return pocketNumber, backpackType
        end
        
        pocketNumber = remainder
    end  
    return pocketNumber, EA_Window_Backpack.NUM_BACKPACK_TYPES
end

function EA_Window_Backpack.GetGlobalPocketNumber( backpackType, pocket )
    return EA_Window_Backpack.POCKETS_START_INDEX[ backpackType ] + ( pocket - 1 )
end

function EA_Window_Backpack.GetPocketNumberForSlot( backpackType, slotToFind )
    local pocketNumber = math.ceil( tonumber(slotToFind) / EA_Window_Backpack.NUM_OF_SLOTS_PER_POCKET[backpackType] )
    local globalPocketNumber = EA_Window_Backpack.GetGlobalPocketNumber( backpackType, pocketNumber )
    return globalPocketNumber
end

function EA_Window_Backpack.GetPocketName( pocketNumber )

	if (pocketNumber == nil)
	then
        ERROR(L"Trying to get the name of a pocket that doesn't exist")
	    return ""
	end

    local pocketName = ""
    local pocket, backpackType = EA_Window_Backpack.GetInternalPocketAndType( pocketNumber )
    pocketName = EA_Window_Backpack.POCKET_NAME[backpackType]..pocket
    return pocketName
end

function EA_Window_Backpack.GetPocketDefaultTitle( pocketNumber )
   
    local pocket, backpackType = EA_Window_Backpack.GetInternalPocketAndType( pocketNumber )
    if( backpackType == EA_Window_Backpack.TYPE_QUEST )
    then
        return GetStringFromTable( "BackpackStrings", StringTables.Backpack.ICON_VIEW_SECTION_NAME_QUEST_ITEMS )
    else
        return GetFormatStringFromTable( "BackpackStrings",  StringTables.Backpack.ICON_VIEW_DEFAULT_SECTION_NAME, { pocket } )
    end
end

function EA_Window_Backpack.GetPocketNonMinimizedIconName( pocketNumber )

	return EA_Window_Backpack.GetPocketName( pocketNumber ).."Icon"
end

function EA_Window_Backpack.GetPocketMinimizedName( pocketNumber )

	return EA_Window_Backpack.GetPocketName( pocketNumber ).."MinIcon"
end

function EA_Window_Backpack.GetPocketIsClosed( pocketNumber )
    return EA_Window_Backpack.pockets[pocketNumber].isClosed
end

function EA_Window_Backpack.SetPocketIsClosed( pocketNumber, isClosed )
	EA_Window_Backpack.pockets[pocketNumber].isClosed = isClosed
end

function EA_Window_Backpack.GetPocketIsUnpurchased( pocketNumber )
    return EA_Window_Backpack.pockets[pocketNumber].isUnpurchased
end

function EA_Window_Backpack.SetPocketIsUnpurchased( pocketNumber, isUnpurchased )
	EA_Window_Backpack.pockets[pocketNumber].isUnpurchased = isUnpurchased
end

function EA_Window_Backpack.GetPocketTitleString( pocketNumber )
	return EA_Window_Backpack.pockets[pocketNumber].titleBarString
end

function EA_Window_Backpack.SetPocketTitleString( pocketNumber, string )
	EA_Window_Backpack.pockets[pocketNumber].titleBarString = string
end

function EA_Window_Backpack.GetSlotFromActionButtonGroup( buttonGroupWindow, buttonIndex )
    local pocketNumber = WindowGetId( WindowGetParent( buttonGroupWindow ) )
    
    return EA_Window_Backpack.pockets[pocketNumber].firstSlotID + buttonIndex - 1
end

function EA_Window_Backpack.OnPocketOpened()

	pocketNumber = WindowGetId( SystemData.ActiveWindow.name )
	 EA_Window_Backpack.SetPocketShowing( pocketNumber, true )
end

function EA_Window_Backpack.OnPocketClosed()
	
	local pocketNumber = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name  ) )
	 EA_Window_Backpack.SetPocketShowing( pocketNumber, false )
end

function  EA_Window_Backpack.SetPocketShowing( pocketNumber, isShowing )
	
	local pocketWindowName = EA_Window_Backpack.GetPocketName( pocketNumber )
	local pocketMinimizedIcon = EA_Window_Backpack.GetPocketMinimizedName( pocketNumber )
    
	WindowSetShowing( pocketWindowName, isShowing )
	WindowSetShowing( pocketMinimizedIcon, not isShowing )
	EA_Window_Backpack.SetPocketIsClosed( pocketNumber, not isShowing )
	
	-- OPTIMIZATION: only really need to adjust the windows surrounding the relevant pocket
	EA_Window_Backpack.ReAnchorPockets()	
end

function EA_Window_Backpack.OnMouseOverOpenPocketIcon()

	local windowName = SystemData.ActiveWindow.name	
	local pocketNumber = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name  ) )
	EA_Window_Backpack.ShowPocketTitleTooltip( windowName, pocketNumber )
end

function EA_Window_Backpack.OnMouseOverMinimizedIcon()

	local windowName = SystemData.ActiveWindow.name
	local pocketNumber = WindowGetId( SystemData.ActiveWindow.name )
	EA_Window_Backpack.ShowPocketTitleTooltip( windowName, pocketNumber )
end

function EA_Window_Backpack.ShowPocketTitleTooltip( anchorWindow, pocketNumber )
	
	local pocketTitle = EA_Window_Backpack.GetPocketTitleString( pocketNumber )
	if pocketTitle == nil or pocketTitle == L"" then
		return
	end
	
	Tooltips.CreateTextOnlyTooltip( anchorWindow, pocketTitle )
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_TOP)
end


-- Resizes the Main Window and all item views
function EA_Window_Backpack.ReAnchorPockets()
	local pocketName
	local maxHeight = 0
    
    -- Skip the quest window, it never needs reanchoring
    for backpackType = 2, EA_Window_Backpack.NUM_BACKPACK_TYPES
    do
        local anchorWindow = EA_Window_Backpack.POCKETS_ANCHOR
        local windowHeight, totalHeight = 0, 0
        for pocket = 1, EA_Window_Backpack.numberOfPockets[backpackType]
        do
            local globalPocketNumber = EA_Window_Backpack.GetGlobalPocketNumber( backpackType, pocket )
            if ( EA_Window_Backpack.GetPocketIsClosed( globalPocketNumber ) )
            then
                continue
            end
            
            pocketName = EA_Window_Backpack.GetPocketName( globalPocketNumber )
		
            WindowClearAnchors( pocketName )
            WindowAddAnchor( pocketName, "bottomleft", anchorWindow, "topleft", 0, EA_Window_Backpack.SPACING_BETWEEN_POCKETS )
            anchorWindow = pocketName
            
            -- add to total height
            __, windowHeight = WindowGetDimensions( pocketName )
            totalHeight = totalHeight + windowHeight + EA_Window_Backpack.SPACING_BETWEEN_POCKETS
		end
        
        if totalHeight < EA_Window_Backpack.MINIMUM_HEIGHT_WHEN_ALL_POCKETS_CLOSED
        then
            totalHeight = EA_Window_Backpack.MINIMUM_HEIGHT_WHEN_ALL_POCKETS_CLOSED
        end    

        totalHeight = totalHeight + EA_Window_Backpack.mainFrameTopHeight + EA_Window_Backpack.mainFrameBottomHeight
        EA_Window_Backpack.views[backpackType].mainWindowHeight = totalHeight
    
        if( maxHeight < totalHeight )
        then 
            maxHeight = totalHeight
        end   
    end
    
    local currentView = EA_Window_Backpack.views[EA_Window_Backpack.currentMode]
	WindowSetDimensions( EA_Window_Backpack.windowName, currentView.mainWindowWidth, currentView.mainWindowHeight )
end

function EA_Window_Backpack.DrawPocketLayout( pocketNumber )
	local pocketData = EA_Window_Backpack.pockets[pocketNumber]
	local pocketWindowName = EA_Window_Backpack.GetPocketName( pocketNumber )
		
	-- Set the # of Rows & Cols on the ButtonGroup
	local totalSlots = pocketData.lastSlotID - pocketData.firstSlotID
	local numRows = math.ceil( totalSlots/EA_Window_Backpack.NUM_SLOTS_WIDE )
	local numCols = EA_Window_Backpack.NUM_SLOTS_WIDE
	
	ActionButtonGroupSetNumButtons( pocketWindowName.."Buttons", numRows, numCols )
	
	return numRows
end

function EA_Window_Backpack.ResizePocket( pocketNumber, numberOfRows, width  )

	local pocketWindowName = EA_Window_Backpack.GetPocketName( pocketNumber )

	if numberOfRows == 0 then
		numberOfRows = 1
	end
	
		 
	local height = EA_Window_Backpack.POCKET_TOP_SPACING +
				  EA_Window_Backpack.POCKET_BOTTOM_SPACING +
				  numberOfRows * EA_Window_Backpack.SLOT_HEIGHT  +
				  (numberOfRows - 1) * EA_Window_Backpack.VERTICAL_SPACE_BETWEEN_SLOTS
                  
	WindowSetDimensions( pocketWindowName, width, height )

	-- if pocket is minimized then just return frame height
	if EA_Window_Backpack.GetPocketIsClosed( pocketNumber ) then
		return 0
	else 
		return height + EA_Window_Backpack.VERTICAL_SPACE_BETWEEN_SLOTS
	end
end


function EA_Window_Backpack.RedrawAllPockets()

	-- OPTIMIZATION: TODO: offer a bool to say we don't need to redraw the slots.
	--		just need to recheck anhoring and the end window size
	-- numRows = EA_Window_Backpack.NumberOfRowsNeeded( numSlots )
	--redrawSlots = redrawSlots or true
	
	local width = EA_Window_Backpack.POCKET_LEFT_SPACING +
				  EA_Window_Backpack.POCKET_RIGHT_SPACING +
				  EA_Window_Backpack.SEE_THROUGH_LEFT_SPACING + 
				  EA_Window_Backpack.SEE_THROUGH_RIGHT_SPACING +
				  EA_Window_Backpack.NUM_SLOTS_WIDE * EA_Window_Backpack.SLOT_WIDTH  +
			     (EA_Window_Backpack.NUM_SLOTS_WIDE - 1) * EA_Window_Backpack.HORIZONTAL_SPACE_BETWEEN_SLOTS
 
	local numRows, height
	
	-- set size for Quest Items View pockets	
	EA_Window_Backpack.DrawQuestItemsLayout( width )
	
	-- set size for all the other backpack views
    for backpackType = 2, EA_Window_Backpack.NUM_BACKPACK_TYPES
    do
        local totalHeight = 0
        for pocket = 1, EA_Window_Backpack.numberOfPockets[backpackType]
        do
    		-- Resize the pocket window
            local globalPocketNumber = EA_Window_Backpack.GetGlobalPocketNumber( backpackType, pocket )
            numRows = EA_Window_Backpack.DrawPocketLayout( globalPocketNumber )
            height = EA_Window_Backpack.ResizePocket( globalPocketNumber, numRows, width )
            totalHeight = totalHeight + height + EA_Window_Backpack.SPACING_BETWEEN_POCKETS
        end
        
        if totalHeight < EA_Window_Backpack.MINIMUM_HEIGHT_WHEN_ALL_POCKETS_CLOSED then
            totalHeight = EA_Window_Backpack.MINIMUM_HEIGHT_WHEN_ALL_POCKETS_CLOSED
        end
	
        totalHeight = totalHeight + EA_Window_Backpack.mainFrameTopHeight + EA_Window_Backpack.mainFrameBottomHeight    
        
        EA_Window_Backpack.views[backpackType].mainWindowWidth = width
        EA_Window_Backpack.views[backpackType].mainWindowHeight = totalHeight
    end
end

-- returns whole number
function EA_Window_Backpack.NumberOfRowsNeeded( numSlots )
	return math.ceil( numSlots / EA_Window_Backpack.NUM_SLOTS_WIDE )
end

function EA_Window_Backpack.OnNumBackpackSlotsUpdated()
    local newNumberOfSlots = GameData.Player.numBackpackSlots
    EA_Window_Backpack.GrowBackpack( EA_Window_Backpack.TYPE_INVENTORY, newNumberOfSlots )

end

function EA_Window_Backpack.OnCraftingInventoryUpdated()
    local newNumberOfSlots = GameData.Player.numCraftingSlots
    EA_Window_Backpack.GrowBackpack( EA_Window_Backpack.TYPE_CRAFTING, newNumberOfSlots )
end

function EA_Window_Backpack.GrowBackpack( backpackType, newNumberOfSlots )
	
    local numberOfSlotsIncreased = newNumberOfSlots - EA_Window_Backpack.numberOfSlots[backpackType]

    -- If we have puchasable pockets then we have to take into account the number of slots that have not been purchased
    if( EA_Window_Backpack.HAS_PURCHASABLE_POCKETS[backpackType] )
    then
        numberOfSlotsIncreased = newNumberOfSlots - (EA_Window_Backpack.numberOfSlots[backpackType] - EA_Window_Backpack.numberOfSlotsUnpurchased[backpackType])
    end

    if( numberOfSlotsIncreased > 0 )
    then
        EA_Window_Backpack.CreateMultipleNewPocketsData( backpackType, newNumberOfSlots )

        -- Destroy the previous ActionButtonGroup pockets
        -- and remake them.
        EA_Window_Backpack.DestroyIconViewPocketWindows()
        
        EA_Window_Backpack.CreatePocketWindows()
        EA_Window_Backpack.CreateMinimizedPocketWindows()
        EA_Window_Backpack.CreateAllQuestSlotWindows()
        
        EA_Window_Backpack.RedrawAllPockets()
        EA_Window_Backpack.ReAnchorPockets()
        
        -- TODO: This shouldn't have to refresh all slots
        EA_Window_Backpack.UpdateBackpackSlots()
        
        WindowSetDimensions( EA_Window_Backpack.windowName,
                            EA_Window_Backpack.views[EA_Window_Backpack.currentMode].mainWindowWidth, 
                            EA_Window_Backpack.views[EA_Window_Backpack.currentMode].mainWindowHeight )
    end
end

function EA_Window_Backpack.InitAllPocketData()
	
	EA_Window_Backpack.pockets.displayOrder = {}
	EA_Window_Backpack.pockets.filterOrder = {}
   
    for backpackType = 1, EA_Window_Backpack.NUM_BACKPACK_TYPES
    do
        EA_Window_Backpack.CreateMultipleNewPocketsData( backpackType, EA_Window_Backpack.DEFAULT_NUM_OF_SLOTS[backpackType] )        
    end
end

function EA_Window_Backpack.PurchasePockets( pocketsToPurchase, pocketNumberToStart, pocketsEnd )
    while pocketsToPurchase > 0 and pocketNumberToStart <= pocketsEnd
    do
        if( EA_Window_Backpack.pockets[pocketNumberToStart].isUnpurchased )
        then
    	    EA_Window_Backpack.pockets[pocketNumberToStart].isUnpurchased = false
            pocketsToPurchase = pocketsToPurchase - 1
        end
        
        pocketNumberToStart = pocketNumberToStart + 1
    end
end

function EA_Window_Backpack.CreateMultipleNewPocketsData( backpackType, newTotalSlots )

    -- Slots already allocated for this backpack type
    local pocketStart = EA_Window_Backpack.POCKETS_START_INDEX[backpackType]
    local slotsAllocated = EA_Window_Backpack.numberOfSlots[backpackType]
    local numberOfPockets = EA_Window_Backpack.numberOfPockets[backpackType]
	local pocketNumber = pocketStart + numberOfPockets
	local slotsForThisPocket = EA_Window_Backpack.NUM_OF_SLOTS_PER_POCKET[backpackType]

    local totalSlotsNeeded = newTotalSlots
    local hasPurchasablePockets = EA_Window_Backpack.HAS_PURCHASABLE_POCKETS[backpackType]
    if( hasPurchasablePockets )
    then
        -- We want to allocate all of them so that the user can buy them
        totalSlotsNeeded = EA_Window_Backpack.NUM_OF_SLOTS_PER_POCKET[backpackType] * EA_Window_Backpack.MAX_NUM_OF_POCKETS[backpackType]
        
        -- Purchase any pockets we have already allocated
        local slotsUnpurchased = EA_Window_Backpack.numberOfSlotsUnpurchased[backpackType]
        EA_Window_Backpack.numberOfSlotsUnpurchased[backpackType] = totalSlotsNeeded - newTotalSlots
        local slotsToPurchase = slotsUnpurchased - EA_Window_Backpack.numberOfSlotsUnpurchased[backpackType]
        local pocketsToPurchase = slotsToPurchase / slotsForThisPocket
        EA_Window_Backpack.PurchasePockets( pocketsToPurchase, pocketStart, numberOfPockets +  pocketStart)
    end
    
	while slotsAllocated < totalSlotsNeeded
    do
		local isUnpurchased = hasPurchasablePockets and newTotalSlots <= slotsAllocated
		EA_Window_Backpack.CreateNewPocketData( pocketNumber, ( slotsAllocated + 1 ), slotsForThisPocket, isUnpurchased )
		slotsAllocated = slotsAllocated + slotsForThisPocket
		pocketNumber = pocketNumber + 1
	end
    
    -- Save our current number of slots and pockets
    EA_Window_Backpack.numberOfSlots[backpackType] = totalSlotsNeeded
    EA_Window_Backpack.numberOfPockets[backpackType] = totalSlotsNeeded / slotsForThisPocket
end

function EA_Window_Backpack.CreateNewPocketData( pocketNumber, firstSlotID, slotsForThisPocket, isUnpurchased )
    local filters
    local titleBarString
    if( EA_Window_Backpack.filters[pocketNumber] and EA_Window_Backpack.filterPocketNames[pocketNumber] )
    then 
        filters = EA_Window_Backpack.filters[pocketNumber]
        titleBarString = EA_Window_Backpack.filterPocketNames[pocketNumber]
    else
        filters = {}
        titleBarString = EA_Window_Backpack.GetPocketDefaultTitle( pocketNumber )
    end

	EA_Window_Backpack.pockets[pocketNumber] =
	{
		filters = filters,
		-- ASSUMPTION: new design assumes we'll always keep the slot IDs contiguous within each pocket
		firstSlotID = firstSlotID,
		lastSlotID = ( firstSlotID + slotsForThisPocket - 1 ),
		isClosed = false,
		titleBarString = titleBarString,
        isUnpurchased=isUnpurchased
	}
	
	-- we skip adding the quest pocket
	if pocketNumber ~= EA_Window_Backpack.POCKETS_START_INDEX[EA_Window_Backpack.TYPE_QUEST]
    then
		table.insert( EA_Window_Backpack.pockets.displayOrder, pocketNumber )
		table.insert( EA_Window_Backpack.pockets.filterOrder, pocketNumber )
	end
	
end		

function EA_Window_Backpack.CreateMinimizedPocketWindows()
	for __, pocketNumber in ipairs(EA_Window_Backpack.pockets.displayOrder) do
	
    	local pocketMinimizedIcon
        local pocket, backpackType = EA_Window_Backpack.GetInternalPocketAndType( pocketNumber )
        local parentWindow = EA_Window_Backpack.views[backpackType].viewWindow
    
		pocketMinimizedIcon = EA_Window_Backpack.GetPocketMinimizedName( pocketNumber )
		if not DoesWindowExist( pocketMinimizedIcon ) then
			CreateWindowFromTemplate( pocketMinimizedIcon, EA_Window_Backpack.POCKET_MINIMIZED_TEMPLATE, parentWindow )
		end
		DynamicImageSetTextureSlice( pocketMinimizedIcon, "Bag"..(pocket).."-Closed" )
		
		WindowSetShowing( pocketMinimizedIcon, true )
		WindowClearAnchors( pocketMinimizedIcon )

		if pocket == 1
        then
			WindowAddAnchor( pocketMinimizedIcon, "bottomleft", parentWindow, "bottomleft", EA_Window_Backpack.X_POS_FOR_FIRST_MINIMIZED_ICON, 0 )
		else
            local anchorPocket = EA_Window_Backpack.GetGlobalPocketNumber( backpackType, pocket - 1 )
            local anchorWindow = EA_Window_Backpack.GetPocketMinimizedName( anchorPocket )
			WindowAddAnchor( pocketMinimizedIcon, "bottomright", anchorWindow, "bottomleft", EA_Window_Backpack.SPACING_BETWEEN_MINIMIZED_ICONS, 0 )
		end
		WindowSetId( pocketMinimizedIcon, pocketNumber)
		
		WindowSetShowing( pocketMinimizedIcon, EA_Window_Backpack.GetPocketIsClosed( pocketNumber ) )
	end	
end

function EA_Window_Backpack.DestroyIconViewPocketWindows()

	for __, pocketNumber in ipairs(EA_Window_Backpack.pockets.displayOrder) do
	
		pocketName = EA_Window_Backpack.GetPocketName( pocketNumber )
		if DoesWindowExist( pocketName ) then
			DestroyWindow( pocketName )
		end
	end
end 

function EA_Window_Backpack.CreatePocketWindows()
	local parentWindow = EA_Window_Backpack.GetPocketName( EA_Window_Backpack.TYPE_QUEST )
	local backgroundName
	    
	-- Quest Pocket already exists, but need to dynamic set a background for each row
	EA_Window_Backpack.TotalNumberOfQuestBackgrounds = EA_Window_Backpack.NumberOfRowsNeeded( EA_Window_Backpack.numberOfSlots[EA_Window_Backpack.TYPE_QUEST] )
	for i = 1, EA_Window_Backpack.TotalNumberOfQuestBackgrounds do

		backgroundName = EA_Window_Backpack.QUEST_BACKGROUND_BASE_NAME..i
		if not DoesWindowExist( backgroundName ) then
			CreateWindowFromTemplate( backgroundName, EA_Window_Backpack.QUEST_BACKGROUND_TEMPLATE, parentWindow )
		else 
			WindowClearAnchors( backgroundName )
		end
		
		if i == 1
        then
			WindowAddAnchor( backgroundName, "topleft", parentWindow, "topleft", 0, EA_Window_Backpack.POCKET_TOP_SPACING )
		else
			WindowAddAnchor( backgroundName, "bottomleft", 
							EA_Window_Backpack.QUEST_BACKGROUND_BASE_NAME..(i-1), "topleft", 
							0, EA_Window_Backpack.SPACING_BETWEEN_POCKETS )
		end		  
	end
    
	-- create all inventory pockets
	for __, pocketNumber in ipairs(EA_Window_Backpack.pockets.displayOrder) do
	
        local anchorWindow = EA_Window_Backpack.POCKETS_ANCHOR
        local pocketName, pocketIcon
        
		pocketName = EA_Window_Backpack.GetPocketName( pocketNumber )
        
        local pocket, backpackType = EA_Window_Backpack.GetInternalPocketAndType( pocketNumber )
    	local parentWindow = EA_Window_Backpack.views[backpackType].viewWindow        
        
		if not DoesWindowExist( pocketName ) then
			CreateWindowFromTemplate( pocketName, EA_Window_Backpack.POCKET_WINDOW_TEMPLATE, parentWindow )
			
			-- Set up the timers
			ActionButtonGroupSetTimeFormat( pocketName.."Buttons", Window.TimeFormat.LARGEST_UNIT_TRUNCATE )
			ActionButtonGroupSetTimeAbbreviations( pocketName.."Buttons",
			                                      GetString(StringTables.Default.LABEL_TIMER_DAYS_ABBREVIATION),
			                                      GetString(StringTables.Default.LABEL_TIMER_HOURS_ABBREVIATION),
			                                      GetString(StringTables.Default.LABEL_TIMER_MINUTES_ABBREVIATION),
			                                      GetString(StringTables.Default.LABEL_TIMER_SECONDS_ABBREVIATION) )

            ButtonSetText( pocketName.."LockButtonBuyButton", GetString( StringTables.Default.LABEL_BUY ) )

		end
        
        -- Hiding filterbuttons on all backpacks except for purchased pockets in the the main inventory
        if( backpackType ~= EA_Window_Backpack.TYPE_INVENTORY or EA_Window_Backpack.GetPocketIsUnpurchased(pocketNumber) )
        then
            WindowSetShowing( pocketName.."FiltersButton", false )
        end

        if( not EA_Window_Backpack.GetPocketIsUnpurchased(pocketNumber) )
        then
            WindowSetShowing( pocketName.."LockButton", false )
        end
        
		WindowSetId( pocketName, pocketNumber)      
		EA_Window_Backpack.SetPocketTitleFromFilter( pocketNumber )
		
		pocketIcon = EA_Window_Backpack.GetPocketNonMinimizedIconName( pocketNumber )
		DynamicImageSetTextureSlice( pocketIcon, "Bag"..(pocket).."-Open" )
		
		if EA_Window_Backpack.GetPocketIsClosed( pocketNumber ) then
			WindowSetShowing( pocketName, false )
		else
			WindowSetShowing( pocketName, true )
			WindowClearAnchors( pocketName )
			WindowAddAnchor( pocketName, "bottomleft", anchorWindow, "topleft", 0, EA_Window_Backpack.SPACING_BETWEEN_POCKETS )
			anchorWindow = pocketName
		end
		
	end

end

function EA_Window_Backpack.InitializeSlots()
	
	EA_Window_Backpack.CreatePocketWindows()
	EA_Window_Backpack.CreateMinimizedPocketWindows()
	EA_Window_Backpack.CreateAllQuestSlotWindows()
	
	EA_Window_Backpack.RedrawAllPockets()
	EA_Window_Backpack.ReAnchorPockets()
end

---
-- Button Handlers
---
function EA_Window_Backpack.InventoryLButtonDown( buttonId, flags )
    local slot = EA_Window_Backpack.GetSlotFromActionButtonGroup( SystemData.ActiveWindow.name, buttonId )
    
	EA_Window_Backpack.EquipmentLButtonDown( slot, flags )
end

function EA_Window_Backpack.InventoryLButtonUp( buttonId, flags )
    local slot = EA_Window_Backpack.GetSlotFromActionButtonGroup( SystemData.ActiveWindow.name, buttonId )
    
	EA_Window_Backpack.EquipmentLButtonUp( slot )
end

function EA_Window_Backpack.InventoryRButtonUp( buttonId, flags )
    local slot = EA_Window_Backpack.GetSlotFromActionButtonGroup( SystemData.ActiveWindow.name, buttonId )
    
	EA_Window_Backpack.EquipmentRButtonUp( slot, flags )
end


-- OnMouseOver Handler
function EA_Window_Backpack.InventoryMouseOver( buttonId, flags )
    local slot = EA_Window_Backpack.GetSlotFromActionButtonGroup( SystemData.ActiveWindow.name, buttonId )
    EA_Window_Backpack.MouseOverEquipmentSlot( slot, SystemData.ActiveWindow.name.."Button"..buttonId )
end

local purchasingBackPackSlots = false

function EA_Window_Backpack.OnBuyPocket()
    local pocketCost = GameData.Player.backpackExpansionSlotsCost
    
    if( purchasingBackPackSlots or (pocketCost <= 0 and GameData.Player.backpackExpansionSlots <= 0) )
    then
        return
    end

    -- Create Confirmation Dialog
    local dialogText = GetStringFormat( StringTables.Default.DIALOG_BUY_BACKPACK_POCKET, {MoneyFrame.FormatMoneyString (pocketCost, false, true) } )
    
    local function doneBuyingBackPackSlots()
        purchasingBackPackSlots = false
    end
    
    local function buyPocket()
        doneBuyingBackPackSlots()
        
        if( GameData.Player.money < pocketCost )
        then
            DialogManager.MakeOneButtonDialog( GetString( StringTables.Default.DIALOG_CANNOT_BUY_BACKPACK_SLOTS), GetString( StringTables.Default.LABEL_OKAY ) )
            return
        end
        BuyBackpackSlots()
    end

    DialogManager.MakeTwoButtonDialog( dialogText, 
								       GetString(StringTables.Default.LABEL_YES),
								       buyPocket,
								       GetString(StringTables.Default.LABEL_NO),
								       doneBuyingBackPackSlots )
									       
    purchasingBackPackSlots = true
end

function EA_Window_Backpack.OnMouseOverBuyPocket()
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, GetString( StringTables.Default.TOOLTIP_BUY_BACKPACK_SLOTS ) )
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_BOTTOM )
end
