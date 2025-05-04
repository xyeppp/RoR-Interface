----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_Backpack = {}

EA_Window_Backpack.lockedSlot = {}
EA_Window_Backpack.animatedSlot = {}
EA_Window_Backpack.temporaryEnhancedItemsSlots = {}

EA_Window_Backpack.versionNumber = 0.33

-- Backpack types
EA_Window_Backpack.TYPE_QUEST           = 1
EA_Window_Backpack.TYPE_INVENTORY       = 2
EA_Window_Backpack.TYPE_CURRENCY        = 3
EA_Window_Backpack.TYPE_CRAFTING        = 4
EA_Window_Backpack.NUM_BACKPACK_TYPES   = 4


-- Slots
EA_Window_Backpack.numberOfSlots = 
{
	[EA_Window_Backpack.TYPE_QUEST]     = 0,
    [EA_Window_Backpack.TYPE_INVENTORY]	= 0,
	[EA_Window_Backpack.TYPE_CURRENCY]	= 0,
	[EA_Window_Backpack.TYPE_CRAFTING]	= 0,
}


EA_Window_Backpack.DEFAULT_NUM_OF_SLOTS = 
{
	[EA_Window_Backpack.TYPE_QUEST]     = 64,
    [EA_Window_Backpack.TYPE_INVENTORY]	= 32,
	[EA_Window_Backpack.TYPE_CURRENCY]	= 32,
	[EA_Window_Backpack.TYPE_CRAFTING]	= 16,
}

EA_Window_Backpack.NUM_OF_SLOTS_PER_POCKET = 
{
	[EA_Window_Backpack.TYPE_QUEST]     = 64,
    [EA_Window_Backpack.TYPE_INVENTORY]	= 16,
	[EA_Window_Backpack.TYPE_CURRENCY]	= 16,
	[EA_Window_Backpack.TYPE_CRAFTING]	= 16,
}


-- Pockets (i.e. Backpack bags )
EA_Window_Backpack.numberOfPockets = 
{
	[EA_Window_Backpack.TYPE_QUEST]     = 0,
    [EA_Window_Backpack.TYPE_INVENTORY]	= 0,
	[EA_Window_Backpack.TYPE_CURRENCY]	= 0,
	[EA_Window_Backpack.TYPE_CRAFTING]	= 0,
}

EA_Window_Backpack.MAX_NUM_OF_POCKETS = 
{
	[EA_Window_Backpack.TYPE_QUEST]     = 1,
    [EA_Window_Backpack.TYPE_INVENTORY]	= 5,
	[EA_Window_Backpack.TYPE_CURRENCY]	= 2,
	[EA_Window_Backpack.TYPE_CRAFTING]	= 5,
}

EA_Window_Backpack.HAS_PURCHASABLE_POCKETS = 
{
	[EA_Window_Backpack.TYPE_QUEST]     = false,
    [EA_Window_Backpack.TYPE_INVENTORY]	= true,
	[EA_Window_Backpack.TYPE_CURRENCY]	= false,
	[EA_Window_Backpack.TYPE_CRAFTING]	= false,
}

EA_Window_Backpack.numberOfSlotsUnpurchased = 
{
	[EA_Window_Backpack.TYPE_QUEST]     = 0,
    [EA_Window_Backpack.TYPE_INVENTORY]	= 0,
	[EA_Window_Backpack.TYPE_CURRENCY]	= 0,
	[EA_Window_Backpack.TYPE_CRAFTING]	= 0,
}

-- Table of each backpack's first index
local firstBackpackIndex = 1
local secondBackpackIndex = EA_Window_Backpack.MAX_NUM_OF_POCKETS[1] + firstBackpackIndex
local thirdBackpackIndex = EA_Window_Backpack.MAX_NUM_OF_POCKETS[2] + secondBackpackIndex
local fourthBackpackIndex = EA_Window_Backpack.MAX_NUM_OF_POCKETS[3] + thirdBackpackIndex
EA_Window_Backpack.POCKETS_START_INDEX = 
{
	[1] = firstBackpackIndex,
    [2]	= secondBackpackIndex,
	[3]	= thirdBackpackIndex,
	[4]	= fourthBackpackIndex,
}

EA_Window_Backpack.POCKET_NAME = 
{
	[EA_Window_Backpack.TYPE_QUEST]     = "EA_Window_BackpackQuestViewSection",
    [EA_Window_Backpack.TYPE_INVENTORY]	= "EA_Window_BackpackIconViewSection",
	[EA_Window_Backpack.TYPE_CURRENCY]	= "EA_Window_BackpackCurrencyViewSection",
	[EA_Window_Backpack.TYPE_CRAFTING]	= "EA_Window_BackpackCraftingViewSection",
}

-- Views (i.e. tabs in the backpack window)
EA_Window_Backpack.VIEW_MODE_QUEST      = EA_Window_Backpack.TYPE_QUEST
EA_Window_Backpack.VIEW_MODE_INVENTORY  = EA_Window_Backpack.TYPE_INVENTORY
EA_Window_Backpack.VIEW_MODE_CURRENCY	= EA_Window_Backpack.TYPE_CURRENCY
EA_Window_Backpack.VIEW_MODE_CRAFTING	= EA_Window_Backpack.TYPE_CRAFTING
EA_Window_Backpack.NUM_VIEW_MODES       = EA_Window_Backpack.NUM_BACKPACK_TYPES

EA_Window_Backpack.views =
{
    [EA_Window_Backpack.VIEW_MODE_QUEST]	 = { tabName="EA_Window_BackpackTabsQuestView",     viewWindow="EA_Window_BackpackQuestView",       mainWindowWidth=0, mainWindowHeight= 0, },
	[EA_Window_Backpack.VIEW_MODE_INVENTORY] = { tabName="EA_Window_BackpackTabsIconView",		viewWindow="EA_Window_BackpackIconView",		mainWindowWidth=0, mainWindowHeight= 0, },
    [EA_Window_Backpack.VIEW_MODE_CURRENCY]	 = { tabName="EA_Window_BackpackTabsCurrencyView",	viewWindow="EA_Window_BackpackCurrencyView",	mainWindowWidth=0, mainWindowHeight= 0, },
    [EA_Window_Backpack.VIEW_MODE_CRAFTING]	 = { tabName="EA_Window_BackpackTabsCraftingView",	viewWindow="EA_Window_BackpackCraftingView",	mainWindowWidth=0, mainWindowHeight= 0, },
}

EA_Window_Backpack.NUM_SLOTS_WIDE = 8

EA_Window_Backpack.SLOT_NAME_BASE = "EA_Window_BackpackSlot"
EA_Window_Backpack.QUEST_SLOT_NAME_BASE = "EA_Window_BackpackQuest"
EA_Window_Backpack.TIMER_MAX_ALPHA = 0.8
EA_Window_Backpack.TIMER_MIN_ALPHA = 0.2
EA_Window_Backpack.TIMER_ALPHA_RANGE = EA_Window_Backpack.TIMER_MAX_ALPHA - EA_Window_Backpack.TIMER_MIN_ALPHA

EA_Window_Backpack.BATTLE_MAP_ID                = 11919 -- Eventually this needs to be not hardcoded

EA_Window_Backpack.COLOR_MEETS_REQUIREMENTS		= {r=166, g=171, b=179, a=1 } -- light gray
EA_Window_Backpack.COLOR_FAILS_REQUIREMENTS		= {r=155, g=10, b=10, a=1 }


EA_Window_Backpack.SLOT_WIDTH = 48
EA_Window_Backpack.SLOT_HEIGHT = 48
EA_Window_Backpack.ICON_SCALE = (46 / 64)	-- using 46 instead of 48 to account for 1 pixel frame
EA_Window_Backpack.HORIZONTAL_SPACE_BETWEEN_SLOTS = 0
EA_Window_Backpack.VERTICAL_SPACE_BETWEEN_SLOTS = 0

EA_Window_Backpack.POCKET_LEFT_SPACING = 10
EA_Window_Backpack.POCKET_RIGHT_SPACING = 20
EA_Window_Backpack.POCKET_TOP_SPACING = 8
EA_Window_Backpack.POCKET_BOTTOM_SPACING = 15
EA_Window_Backpack.SPACING_BETWEEN_POCKETS = 0
EA_Window_Backpack.MINIMUM_HEIGHT_WHEN_ALL_POCKETS_CLOSED = EA_Window_Backpack.POCKET_BOTTOM_SPACING

EA_Window_Backpack.SEE_THROUGH_BOTTOM_SPACING = 30	-- FYI: "Bag1-Closed" height="50" 
EA_Window_Backpack.SEE_THROUGH_LEFT_SPACING = 27	-- FYI: "Bag1-Open" width="46"
EA_Window_Backpack.SEE_THROUGH_RIGHT_SPACING = 13	-- FYI: "LootSortButton" width="31"
EA_Window_Backpack.OVERFLOW_BOTTOM_SPACING = 70

-- this should match the y value for window="EA_Window_BackpackPocketsAnchor"
EA_Window_Backpack.mainFrameTopHeight = 125
EA_Window_Backpack.mainFrameBottomHeight = EA_Window_Backpack.SEE_THROUGH_BOTTOM_SPACING


-- the Backpack in List View should appear the same height as the Store Windows, which is currently 720
EA_Window_Backpack.LIST_VIEW_HEIGHT = 720 - EA_Window_Backpack.mainFrameTopHeight  -- - EA_Window_Backpack.SEE_THROUGH_BOTTOM_SPACING)

--EA_Window_Backpack.X_POS_FOR_FIRST_MINIMIZED_ICON = 40
EA_Window_Backpack.X_POS_FOR_FIRST_MINIMIZED_ICON = EA_Window_Backpack.SEE_THROUGH_LEFT_SPACING
EA_Window_Backpack.SPACING_BETWEEN_MINIMIZED_ICONS = 0


EA_Window_Backpack.windowName = "EA_Window_Backpack"

EA_Window_Backpack.POCKET_WINDOW_TEMPLATE = "EA_Window_BackpackPocket"
EA_Window_Backpack.POCKET_ICON_TEMPLATE = "EA_Window_BackpackPocketOpenIcon"
EA_Window_Backpack.POCKET_MINIMIZED_TEMPLATE = "EA_Window_BackpackPocketClosedIcon"
EA_Window_Backpack.POCKETS_ANCHOR = "EA_Window_BackpackPocketsAnchor"

EA_Window_Backpack.QUEST_ITEM_BUTTON_TEMPLATE = "BackpackWindowQuestButton"
EA_Window_Backpack.QUEST_BACKGROUND_TEMPLATE = "EA_Window_BackpackQuestBackgroundTemplate"
EA_Window_Backpack.QUEST_BACKGROUND_BASE_NAME = "EA_Window_BackpackBackgroundRow"

EA_Window_Backpack.NumberOfVisibleQuestBackgrounds = 0
EA_Window_Backpack.TotalNumberOfQuestBackgrounds = 0


-- used to track items we intentionally moved and therefore should not get filtered
EA_Window_Backpack.manuallyMovedItems =
{
    [EA_Window_Backpack.VIEW_MODE_QUEST]	 = {},
	[EA_Window_Backpack.VIEW_MODE_INVENTORY] = {},
    [EA_Window_Backpack.VIEW_MODE_CURRENCY]	 = {},
    [EA_Window_Backpack.VIEW_MODE_CRAFTING]	 = {},
}
 

-- Overflow Item Constants
EA_Window_Backpack.OVERFLOW_ITEM_WINDOW = "EA_Window_BackpackOverflow"
EA_Window_Backpack.OVERFLOW_ITEM_ICON = "EA_Window_BackpackOverflowIcon"
EA_Window_Backpack.OVERFLOW_ITEM_LABEL = "EA_Window_BackpackOverflowLabel"

-- Overflow Item Variables
EA_Window_Backpack.overflowItem = {}
EA_Window_Backpack.overflowCount = 0


----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

EA_Window_Backpack.dropPending = false 

----------------------------------------------------------------
-- Util Functions

function EA_Window_Backpack.UpdateBackpackSlots()
    
    EA_Window_Backpack.UpdateAllIconViewSlots()
    EA_Window_Backpack.UpdateAllQuestItemSlots()
end
    

----------------------------------------------------------------
-- EA_Window_Backpack Functions

-- OnInitialize Handler
function EA_Window_Backpack.Initialize()    

	EA_Window_Backpack.LoadSettings()
    
    WindowRegisterEventHandler( EA_Window_Backpack.windowName, SystemData.Events.PLAYER_INVENTORY_SLOT_UPDATED, "EA_Window_Backpack.OnInventorySlotUpdated")
    WindowRegisterEventHandler( EA_Window_Backpack.windowName, SystemData.Events.PLAYER_CRAFTING_SLOT_UPDATED, "EA_Window_Backpack.OnCraftingSlotUpdated")
    WindowRegisterEventHandler( EA_Window_Backpack.windowName, SystemData.Events.PLAYER_CURRENCY_SLOT_UPDATED, "EA_Window_Backpack.OnCurrencySlotUpdated")
    WindowRegisterEventHandler( EA_Window_Backpack.windowName, SystemData.Events.PLAYER_QUEST_ITEM_SLOT_UPDATED, "EA_Window_Backpack.UpdateQuestItemSlot")
    WindowRegisterEventHandler( EA_Window_Backpack.windowName, SystemData.Events.PLAY_AS_MONSTER_STATUS, "EA_Window_Backpack.HandlePlayAsMonsterStatus")
   
    WindowRegisterEventHandler( EA_Window_Backpack.windowName, SystemData.Events.PLAYER_MONEY_UPDATED, "EA_Window_Backpack.UpdateMoney" )

    
    LabelSetText( "EA_Window_BackpackTitleBarText", GetString( StringTables.Default.LABEL_BACKPACK ) )  

    LabelSetText( "EA_Window_BackpackCheckBoxLabel", GetString( StringTables.Default.LABEL_LIST_VIEW ) )  

    ButtonSetCheckButtonFlag( EA_Window_Backpack.windowName.."CheckBox", true )
    
	EA_Window_Backpack.UpdateMoney(GameData.Player.money)
	
	EA_Window_Backpack.InitializeIconView()    
    
    EA_Window_Backpack.InitializeListView()
    
    EA_Window_Backpack.InitializeBackpackFilters()
    
	EA_Window_Backpack.InitializeOverflowSlot()
	
    -- Set tabs and show/hide views 
    for viewMode in ipairs( EA_Window_Backpack.views ) 
    do
		EA_Window_Backpack.SetViewShowing( viewMode, (viewMode == EA_Window_Backpack.currentMode) )
	end
    
    EA_Window_Backpack.UpdateViewStyle( EA_Window_Backpack.currentMode )
end


function EA_Window_Backpack.HandlePlayAsMonsterStatus( isPlayAsMonster )    
    if ( isPlayAsMonster )
    then
        WindowSetShowing(EA_Window_Backpack.windowName, false)
    end 
end

function EA_Window_Backpack.InitializeOverflowSlot()

    WindowRegisterEventHandler( EA_Window_Backpack.windowName, SystemData.Events.PLAYER_INVENTORY_OVERFLOW_UPDATED, "EA_Window_Backpack.OnOverflowSlotUpdated")

	local overflowItem, overflowCount = GetOverflowData()
	EA_Window_Backpack.OnOverflowSlotUpdated( overflowItem, overflowCount )
end


function EA_Window_Backpack.OnOverflowSlotUpdated( overflowItemData, overflowCount )
	
	EA_Window_Backpack.overflowItem = overflowItemData
	EA_Window_Backpack.overflowCount = overflowCount
	
	-- update icon and text
	EA_Window_Backpack.DisplayOverflowItem()

	-- If we are mousing over the updated slot, show the tooltip
	if SystemData.MouseOverWindow.name == EA_Window_Backpack.OVERFLOW_ITEM_ICON then
		EA_Window_Backpack.MouseOverEquipmentSlot( overflowItemData, EA_Window_Backpack.OVERFLOW_ITEM_ICON )
	end
end


function EA_Window_Backpack.DisplayOverflowItem()

	local itemData = EA_Window_Backpack.overflowItem 
	local buttonName = EA_Window_Backpack.OVERFLOW_ITEM_ICON
	local overflowShowing = EA_Window_Backpack.ValidItem( itemData )
	
	WindowSetShowing( EA_Window_Backpack.OVERFLOW_ITEM_WINDOW, overflowShowing )
	
	-- resize the window to display Overflow 
	EA_Window_Backpack.mainFrameBottomHeight = EA_Window_Backpack.SEE_THROUGH_BOTTOM_SPACING	
    if overflowShowing then
        EA_Window_Backpack.mainFrameBottomHeight = EA_Window_Backpack.mainFrameBottomHeight + EA_Window_Backpack.OVERFLOW_BOTTOM_SPACING
    end

	EA_Window_Backpack.RedrawAllPockets()
    EA_Window_Backpack.DrawQuestItemsLayout()
	local currentView = EA_Window_Backpack.views[EA_Window_Backpack.currentMode]
	WindowSetDimensions( EA_Window_Backpack.windowName, currentView.mainWindowWidth, currentView.mainWindowHeight )
    
    if not overflowShowing then
        return
    end
    
    -- set main label with count of total overflow items
	local text = GetStringFormatFromTable( "BackpackStrings", StringTables.Backpack.OVERFLOW_COUNT_TEXT, { L""..EA_Window_Backpack.overflowCount } )
    LabelSetText( EA_Window_Backpack.OVERFLOW_ITEM_LABEL, text )
	
    -- set icon
	local texture, x, y = GetIconData(itemData.iconNum)
	DynamicImageSetTexture( buttonName.."Icon", texture, x, y)
             
    -- set stack count
	WindowSetShowing( buttonName.."Text", itemData.stackCount > 1 )
	if itemData.stackCount > 1 then
		LabelSetText(buttonName.."Text", L""..itemData.stackCount )
	end
    
    -- Cooldown not currently used for overflow
end


function EA_Window_Backpack.GetOverflowItem()
	return EA_Window_Backpack.overflowItem
end


-- OnShutdown Handler
function EA_Window_Backpack.Shutdown()
    EA_Window_Backpack.SaveSettings()
    EA_Window_Backpack.ShutdownBackpackFilters()
end

function EA_Window_Backpack.OnUpdate( timeElapsed )

    if( #EA_Window_Backpack.animatedSlot == 0 and #EA_Window_Backpack.temporaryEnhancedItemsSlots == 0 ) then
        return
    end
    
    for i, slot in ipairs( EA_Window_Backpack.animatedSlot ) do
        EA_Window_Backpack.UpdateItemTimer( slot, timeElapsed )
    end
    
    local timersToRemove = {}
    for index, slot in ipairs( EA_Window_Backpack.temporaryEnhancedItemsSlots ) do
        local item = DataUtils.GetItems()[slot]
        if DataUtils.UpdateEnhancementTimer( item, timeElapsed ) then
            table.insert( timersToRemove, slot )
        end
    end
    
    for index, slot in ipairs( timersToRemove ) do
        EA_Window_Backpack.ClearEnhancementTimer( slot )
    end
end

function EA_Window_Backpack.UpdateMoney(currentMoney)
    MoneyFrame.FormatMoney (EA_Window_Backpack.windowName.."Money", currentMoney, MoneyFrame.SHOW_EMPTY_WINDOWS);
end



function EA_Window_Backpack.OnRButtonUp()
    EA_Window_ContextMenu.CreateDefaultContextMenu( EA_Window_Backpack.windowName )
end


-- Hide the backpack
function EA_Window_Backpack.Hide()
    if WindowGetShowing( EA_Window_Backpack.windowName ) then
		-- this will auctomatically call EA_Window_Backpack.ToggleShowing()
		BroadcastEvent( SystemData.Events.TOGGLE_BACKPACK_WINDOW )
    end
end

function EA_Window_Backpack.OnHidden()

    WindowUtils.OnHidden()
    
    -- TODO: this stuff should really be abstracted out, e.g. by notifying the Cursor table and
    --    letting it take the appropriate action
    if EA_Window_InteractionStore.repairModeOn then
        EA_Window_InteractionStore.RepairingOff()
        
    elseif Cursor.UseItemTargeting then 
		Cursor.ClearTargetingData()
    end
end

function EA_Window_Backpack.Show()

    if( not WindowGetShowing( EA_Window_Backpack.windowName ) )
    then
		-- this will auctomatically call EA_Window_Backpack.ToggleShowing()
		BroadcastEvent( SystemData.Events.TOGGLE_BACKPACK_WINDOW )
    end
end

function EA_Window_Backpack.OnShown()

    WindowUtils.OnShown(EA_Window_Backpack.Hide, WindowUtils.Cascade.MODE_AUTOMATIC)
end


function EA_Window_Backpack.ToggleShowing()      
    
    if(GameData.Player.isPlayAsMonster == true)
    then
        -- Do not toggle this window to showing
        return
    end
    
    WindowUtils.ToggleShowing( EA_Window_Backpack.windowName )
end


---------------------------------
--- Inventory Item Handlers -----
---------------------------------
--
-- quest Items handled separately now

-- SystemData.Events.PLAYER_INVENTORY_SLOT_UPDATED Handler
function EA_Window_Backpack.OnInventorySlotUpdated( updatedSlots )
    EA_Window_Backpack.OnBackpackSlotUpdated( EA_Window_Backpack.TYPE_INVENTORY, updatedSlots )
end

-- SystemData.Events.PLAYER_CRAFTING_SLOT_UPDATED Handler
function EA_Window_Backpack.OnCraftingSlotUpdated( updatedSlots )
    EA_Window_Backpack.OnBackpackSlotUpdated( EA_Window_Backpack.TYPE_CRAFTING, updatedSlots )
end

-- SystemData.Events.PLAYER_CURRENCY_SLOT_UPDATED Handler
function EA_Window_Backpack.OnCurrencySlotUpdated( updatedSlots )
    EA_Window_Backpack.OnBackpackSlotUpdated( EA_Window_Backpack.TYPE_CURRENCY, updatedSlots )
end

function EA_Window_Backpack.OnBackpackSlotUpdated( backpackType, updatedSlots )

    for _, slot in ipairs( updatedSlots )
    do
        if( slot == 0 )
        then
            continue
        end
        
		local itemData  = EA_Window_Backpack.GetItemsFromBackpack( backpackType )[slot]
        if( itemData and DataUtils.ItemHasEnhancementTimer( itemData ) )
        then
            table.insert( EA_Window_Backpack.temporaryEnhancedItemsSlots, slot )
		end

        if( ( itemData ~= nil ) and ( not EA_Window_Backpack.WasManuallyMoved( slot ) ) and ( itemData.isNew ) )
        then 
	        local currentPocket = EA_Window_Backpack.GetPocketNumberForSlot( backpackType, slot )
	        local newSlot, newPocket = EA_Window_Backpack.FindNewPocketForIncomingItem( slot, currentPocket )
	        if newSlot ~= 0
            then
                local cursor = EA_Window_Backpack.GetCursorForBackpack( backpackType )
		        EA_Window_Backpack.ManuallyMoveItem( cursor, slot, cursor, newSlot )
		        slot = newSlot
	        end
        end
    	
        EA_Window_Backpack.PutItemInSlot( backpackType, slot )
    end
end

function EA_Window_Backpack.PutItemInSlot( backpackType, slot )
    if ( slot == 0 or slot > EA_Window_Backpack.numberOfSlots[backpackType] )
    then
        ERROR(L"PutItemInSlot - Invalid slot : "..slot)
        return  
    end 
    
    local itemData  = EA_Window_Backpack.GetItemsFromBackpack( backpackType )[slot]
      
    -- If we are placing the item that is currently on the cursor, clear it
    if( Cursor.IconOnCursor() and (Cursor.Data.ObjectId == itemData.uniqueID or EA_Window_Backpack.dropPending == true) ) then 
        Cursor.Clear()
        EA_Window_Backpack.dropPending = false
    end
    
    -- Update The Icon View
    EA_Window_Backpack.UpdateIconViewSlot( backpackType, slot, itemData )      

    -- Update The List View
	if ( WindowGetShowing( EA_Window_Backpack.windowName ) and EA_Window_Backpack.currentlyInListView )
    then
		-- OPTIMIZATION: this causes all data to be re-retrieved, sorted, filtered
		EA_Window_Backpack.UpdateCurrentList( EA_Window_Backpack.currentMode )
	end
end




-----------------------------------
-- Animated Timer Functions

-- return 0 if 
function EA_Window_Backpack.GetListRowForSlotNum( slot )
	return 0
end

function EA_Window_Backpack.ClearEnhancementTimer( slotToRemove )

    for i, slot in ipairs( EA_Window_Backpack.temporaryEnhancedItemsSlots ) do
        if slot == slotToRemove then
            table.remove( EA_Window_Backpack.temporaryEnhancedItemsSlots, i )
            return true
        end
    end
    
    return false
end

function EA_Window_Backpack.GetSlotIconWindowName( slot, mode )
	
	if mode == EA_Window_Backpack.VIEW_MODE_QUEST  then
		return EA_Window_Backpack.QUEST_SLOT_NAME_BASE..slot

	
	-- TEMP: VIEW_MODE_LIST deosn't display timers yet
	else
		return EA_Window_Backpack.SLOT_NAME_BASE..slot
	end
	-- END TEMP:
	
end
 
function EA_Window_Backpack.ItemHasTimer( itemData )

    if itemData == nil or itemData.bonus == nil then
        return false
    end

    for i, bonusData in ipairs(itemData.bonus) do
        if( bonusData.type == GameDefs.ITEMBONUS_USE and 
            bonusData.cooldownTimeLeft and
            bonusData.cooldownTimeLeft > 0 and
            bonusData.totalCooldownTime and
            bonusData.totalCooldownTime > 0 
           ) then
           
            return true, bonusData.cooldownTimeLeft, bonusData.totalCooldownTime, bonusData
        end
    end

    return false
 end
 
 
 
function EA_Window_Backpack.GetItemCooldownTimers( itemData )
    local found, cooldownTimeLeft, totalCooldownTime, bonusData = EA_Window_Backpack.ItemHasTimer( itemData )

    return cooldownTimeLeft, totalCooldownTime, bonusData
end

-- end of Animated Timer Functions
-----------------------------------



----------------------------------
--- View Handling Functions 

function EA_Window_Backpack.OnMouseOverQuestItemsTab()
    local text = GetStringFromTable( "BackpackStrings",  StringTables.Backpack.TAB_QUEST_ITEMS_MOUSEOVER )
    EA_Window_Backpack.DisplayMouseOverTabTooltip( text )
end

function EA_Window_Backpack.OnMouseOverInventoryItemsTab()
    local text = GetStringFromTable( "BackpackStrings",  StringTables.Backpack.TAB_INVENTORY_ITEMS_MOUSEOVER )
    EA_Window_Backpack.DisplayMouseOverTabTooltip( text )
end

function EA_Window_Backpack.OnMouseOverCurrencyItemsTab()
    local text = GetStringFromTable( "BackpackStrings",  StringTables.Backpack.TAB_CURRENCY_ITEMS_MOUSEOVER )
    EA_Window_Backpack.DisplayMouseOverTabTooltip( text )
end

function EA_Window_Backpack.OnMouseOverCraftingItemsTab()
    local text = GetStringFromTable( "BackpackStrings",  StringTables.Backpack.TAB_CRAFTING_ITEMS_MOUSEOVER )
    EA_Window_Backpack.DisplayMouseOverTabTooltip( text )
end

function EA_Window_Backpack.DisplayMouseOverTabTooltip( text )
	local windowName = SystemData.ActiveWindow.name    
	Tooltips.CreateTextOnlyTooltip( windowName, text )
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_TOP)
end

function EA_Window_Backpack.OnTabSelected()
    if Cursor.IconOnCursor() then
        Cursor.Clear()
    end
    
    local viewNum = WindowGetId( SystemData.ActiveWindow.name )
    
    if viewNum ~= EA_Window_Backpack.currentMode then
		EA_Window_Backpack.SetViewShowing( EA_Window_Backpack.currentMode, false )
		EA_Window_Backpack.SetViewShowing( viewNum, true )
	end
    
    EA_Window_Backpack.UpdateViewStyle( EA_Window_Backpack.currentMode )
    
end

function EA_Window_Backpack.SetViewShowing( viewMode, isShowing )
	if viewMode < 1 or viewMode > EA_Window_Backpack.NUM_VIEW_MODES then
		return
	end
	
	local tabName = EA_Window_Backpack.views[viewMode].tabName
	local viewWindowName = EA_Window_Backpack.views[viewMode].viewWindow
	
	ButtonSetPressedFlag( tabName, isShowing )
	ButtonSetStayDownFlag( tabName, isShowing )
	WindowSetShowing( viewWindowName, isShowing )
	
	if isShowing then
	
		EA_Window_Backpack.currentMode = viewMode
		
		WindowSetDimensions( EA_Window_Backpack.windowName,
							 EA_Window_Backpack.views[viewMode].mainWindowWidth, 
							 EA_Window_Backpack.views[viewMode].mainWindowHeight )
							 	
    end
	
end


--- END View Handling Functions 
----------------------------------

function EA_Window_Backpack.LoadSettings()
    EA_Window_Backpack.settings = EA_Window_Backpack.settings or {}
    local settings = EA_Window_Backpack.settings
    
    EA_Window_Backpack.currentMode = settings.currentMode or EA_Window_Backpack.VIEW_MODE_INVENTORY
        
    EA_Window_Backpack.filters = settings.filters or {}
    EA_Window_Backpack.filterPocketNames = settings.filterPocketNames or {}
    
    EA_Window_Backpack.pockets = {}
    EA_Window_Backpack.InitAllPocketData()
end

function EA_Window_Backpack.SaveSettings()
    local settings = EA_Window_Backpack.settings
    settings.currentMode = EA_Window_Backpack.currentMode
    settings.filters = EA_Window_Backpack.filters
    settings.filterPocketNames = EA_Window_Backpack.filterPocketNames
end

-- TODO: this needs to be better checking.
--  possible differences for 2 items using same template may be: stack count, soulbound, talismans, maybe timers 
--
-- NOTE: if both itemData are nil then we return true
--
function EA_Window_Backpack.ItemsAreSame( itemData1, itemData2 )
	
	if itemData1 == nil or itemData2 == nil then
		return itemData1 == itemData2
	end

	-- can't compare stackCount since the person may have just picked up or used one of the stack
	if (itemData1.uniqueID == itemData2.uniqueID) then
		return true
	end
	
	return false
end

-- NOTE: if a match is found, then we assume the move is a success and remove the item from the manuallyMovedItems list
function EA_Window_Backpack.WasManuallyMoved( slot )
	
    local inventory = EA_Window_Backpack.GetItemsFromBackpack( EA_Window_Backpack.currentMode )
    local itemData = inventory[slot]
    
	local itemExists = EA_Window_Backpack.ValidItem( itemData )
	
	local oldItemData = EA_Window_Backpack.manuallyMovedItems[EA_Window_Backpack.currentMode][slot]
	if not itemExists or EA_Window_Backpack.ItemsAreSame( itemData, oldItemData ) then
	
		EA_Window_Backpack.manuallyMovedItems[EA_Window_Backpack.currentMode][slot] = nil
		return true
	end
    
    return false
end

-- TODO: this probably belongs in Cursor or DataUtils so other windows will use this too			
function EA_Window_Backpack.ManuallyMoveItem( sourceWindow, currentSlot, destinationWindow, newSlot, stackCount )

    local inventory = EA_Window_Backpack.GetItemsFromBackpack( EA_Window_Backpack.currentMode )
    local itemData = inventory[currentSlot]

	stackCount = stackCount or itemData.stackCount 

	EA_Window_Backpack.manuallyMovedItems[EA_Window_Backpack.currentMode][newSlot] = itemData
    RequestMoveItem( sourceWindow, currentSlot, destinationWindow, newSlot, stackCount )      
end

function EA_Window_Backpack.ToggleViewStyle()
    local checkButtonWindow = EA_Window_Backpack.windowName.."CheckBox"
    local isChecked = ButtonGetPressedFlag( checkButtonWindow )
    local backpackType = EA_Window_Backpack.currentMode
    EA_Window_Backpack.UpdateViewStyle( backpackType )
end

function EA_Window_Backpack.UpdateViewStyle( backpackType )
    local checkButtonWindow = EA_Window_Backpack.windowName.."CheckBox"
    local isChecked = ButtonGetPressedFlag( checkButtonWindow )
    if( isChecked )
    then
        EA_Window_Backpack.currentlyInListView = true
        WindowSetShowing( EA_Window_Backpack.views[backpackType].viewWindow, false )
        local width = EA_Window_Backpack.views[backpackType].mainWindowWidth
        local height = EA_Window_Backpack.LIST_VIEW_HEIGHT + EA_Window_Backpack.mainFrameTopHeight + EA_Window_Backpack.mainFrameBottomHeight
        WindowSetDimensions( EA_Window_Backpack.windowName, width, height )
        
        WindowSetShowing( "EA_Window_BackpackListView", true )
        EA_Window_Backpack.UpdateCurrentList( backpackType )
    else
        EA_Window_Backpack.currentlyInListView = false
        WindowSetShowing( "EA_Window_BackpackListView", false )
        EA_Window_Backpack.SetViewShowing( backpackType, true )
    end    
end

