----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EquipmentUpgradeWindow = {}

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

local currentItems = {}

local mainWindowName = "EquipmentUpgradeWindow"

local MINIMUM_ITEM_LEVEL = 10   -- Only items with item level 10 or greater can be upgraded

local VALID_ITEM_SLOTS =        -- Only items that go in one of these slots can be upgraded
{
    GameData.EquipSlots.RIGHT_HAND,
    GameData.EquipSlots.LEFT_HAND,
    GameData.EquipSlots.EITHER_HAND,
    GameData.EquipSlots.RANGED,
    GameData.EquipSlots.HELM,
    GameData.EquipSlots.SHOULDERS,
    GameData.EquipSlots.BODY,
    GameData.EquipSlots.GLOVES,
    GameData.EquipSlots.BOOTS,
}

local SLOT_MAINITEM     = 1
local SLOT_REFINEMENT   = 2

local slotToWindowMapping =
{
    [SLOT_MAINITEM]     = "MainItem",
    [SLOT_REFINEMENT]   = "RefinementItem",
}

local slotToTooltipMapping =
{
    [SLOT_MAINITEM]     = StringTables.Default.TOOLTIP_EQUIPMENT_UPGRADE_MAIN_ITEM,
    [SLOT_REFINEMENT]   = StringTables.Default.TOOLTIP_EQUIPMENT_UPGRADE_REFINEMENT,
}

local currentCost = 0
local waitingOnServerResponse = false

----------------------------------------------------------------
-- Local Functions
----------------------------------------------------------------

local function SetMainItemLabelsShowing( shouldShow )
    -- Show/hide labels that are only relevant with a valid main item, and enable/disable the Upgrade button
    WindowSetShowing( mainWindowName.."LevelLabel", shouldShow )
    WindowSetShowing( mainWindowName.."SuccessLabel", shouldShow )
    WindowSetShowing( mainWindowName.."LevelText", shouldShow )
    WindowSetShowing( mainWindowName.."SuccessText", shouldShow )
    WindowSetShowing( mainWindowName.."Money", shouldShow )
    ButtonSetDisabledFlag( mainWindowName.."UpgradeButton", not shouldShow )
end

local function ClearItemSlot( slotNum )
    currentItems[slotNum] = nil
    DynamicImageSetTexture( mainWindowName..slotToWindowMapping[slotNum].."IconBase", "", 0, 0 )
            
    if ( slotNum == SLOT_MAINITEM )
    then
        SetMainItemLabelsShowing( false )
    end
end

local function ClearWindowData()
    for slotNum, _ in pairs( slotToWindowMapping )
    do
        ClearItemSlot( slotNum )
    end
    waitingOnServerResponse = false
end

local function UpgradeEquipmentWrapper( isTest )
    if ( currentItems[SLOT_MAINITEM] ~= nil )
    then
        if ( currentItems[SLOT_REFINEMENT] ~= nil )
        then
            UpgradeEquipment( isTest, currentItems[SLOT_MAINITEM].sourceBackpack, currentItems[SLOT_MAINITEM].sourceSlot, currentItems[SLOT_REFINEMENT].sourceBackpack, currentItems[SLOT_REFINEMENT].sourceSlot )
        else
            UpgradeEquipment( isTest, currentItems[SLOT_MAINITEM].sourceBackpack, currentItems[SLOT_MAINITEM].sourceSlot, 0, 0 )
        end
    end
end

local function UpgradeEquipmentCurrent()
    UpgradeEquipmentWrapper( false )
end

local function RequestUpgradeEquipmentCurrentInfo()
    UpgradeEquipmentWrapper( true )
end

local function InferItemSlot( itemData )
    if ( itemData.type == GameData.ItemTypes.REFINER_TOOL )
    then
        return SLOT_REFINEMENT
    else
        return SLOT_MAINITEM
    end
end

local function ItemIsAllowedInSlot( itemData, slotNum )
    if ( slotNum == SLOT_MAINITEM )
    then
        local isValidSlot = false
        for _, itemSlot in ipairs( VALID_ITEM_SLOTS )
        do
            if ( itemSlot == itemData.equipSlot )
            then
                isValidSlot = true
                break
            end
        end
        
        -- TODO: Also verify that maxUpgrades > 0, once server starts sending us that info
        
        return ( isValidSlot and ( itemData.iLevel >= MINIMUM_ITEM_LEVEL ) )
    elseif ( slotNum == SLOT_REFINEMENT )
    then
        return ( itemData.type == GameData.ItemTypes.REFINER_TOOL )
    else
        -- Unknown slot
        return false
    end
end

----------------------------------------------------------------
-- Exposed Functions
----------------------------------------------------------------

-- Adds an item into the appropriate upgrade slot if possible. If slotNum is nil, the upgrade window determines which slot from the item data.
function EquipmentUpgradeWindow.AddItem( backpackType, backpackSourceSlot, slotNum )
    if ( not WindowGetShowing( mainWindowName ) )
    then
        return false
    end
    
    local cursorType = EA_BackpackUtilsMediator.GetCursorForBackpack( backpackType )
    local itemData = EA_BackpackUtilsMediator.GetItemsFromBackpack( backpackType )[backpackSourceSlot]
    
    if ( not DataUtils.IsValidItem( itemData ) )
    then
        return false
    end
    
    if ( slotNum == nil )
    then
        slotNum = InferItemSlot( itemData )
    end
    
    if ( not ItemIsAllowedInSlot( itemData, slotNum ) )
    then
        return false
    end
    
    local oldItem = currentItems[slotNum]    
    currentItems[slotNum] = 
    {
        objectSource = cursorType,
        sourceSlot = backpackSourceSlot,
        sourceBackpack = backpackType,
        objectId = itemData.uniqueID,
        iconId = itemData.iconNum,
        autoOnLButtonUp = true,
        stackAmount = itemData.stackCount
    }
    
    local texture, x, y = GetIconData( itemData.iconNum )
    DynamicImageSetTexture( mainWindowName..slotToWindowMapping[slotNum].."IconBase", texture, x, y )
    
    Sound.Play( Sound.ICON_CLEAR )
    
    if ( oldItem )
    then
        -- Do this first before requesting the lock for the new item in case the old item and the new item are the same
        EA_BackpackUtilsMediator.ReleaseLockForSlot( oldItem.sourceSlot, oldItem.sourceBackpack, mainWindowName )
    end
    
    EA_BackpackUtilsMediator.RequestLockForSlot( backpackSourceSlot, backpackType, mainWindowName, {r=0,g=255,b=0} )
    
    return true
end

-- Returns true if the item can currently be inserted into the Equipment Upgrade window
function EquipmentUpgradeWindow.CanInsertItem( itemData )
    if ( not WindowGetShowing( mainWindowName ) )
    then
        return false
    end
    
    if ( not DataUtils.IsValidItem( itemData ) )
    then
        return false
    end
    
    local slotNum = InferItemSlot( itemData )
    return ItemIsAllowedInSlot( itemData, slotNum )
end

----------------------------------------------------------------
-- Core Event Handlers
----------------------------------------------------------------

function EquipmentUpgradeWindow.Initialize()

    WindowRegisterEventHandler( mainWindowName, SystemData.Events.INTERACT_EQUIPMENT_UPGRADE_OPEN, "EquipmentUpgradeWindow.Show" )
    WindowRegisterEventHandler( mainWindowName, SystemData.Events.INTERACT_DONE, "EquipmentUpgradeWindow.Hide" )
    WindowRegisterEventHandler( mainWindowName, SystemData.Events.EQUIPMENT_UPGRADE_COST, "EquipmentUpgradeWindow.ReceivedUpgradeInfo" )
    WindowRegisterEventHandler( mainWindowName, SystemData.Events.EQUIPMENT_UPGRADE_RESULT, "EquipmentUpgradeWindow.ReceivedResultInfo" )

    LabelSetText( mainWindowName.."TitleBarText", GetString( StringTables.Default.LABEL_UPGRADE_EQUIPMENT ) )
    LabelSetText( mainWindowName.."LevelLabel", GetString( StringTables.Default.LABEL_EQUIPMENT_UPGRADE_LEVEL ) )
    LabelSetText( mainWindowName.."SuccessLabel", GetString( StringTables.Default.LABEL_EQUIPMENT_UPGRADE_SUCCESS ) )
    LabelSetText( mainWindowName.."RefinementsLabel", GetString( StringTables.Default.LABEL_EQUIPMENT_UPGRADE_REFINEMENTS ) )
    ButtonSetText( mainWindowName.."UpgradeButton", GetString( StringTables.Default.TEXT_UPGRADE_BUTTON ) )
    ButtonSetText( mainWindowName.."DoneButton", GetString( StringTables.Default.LABEL_DONE ) )
    
    SetMainItemLabelsShowing( false )
end

function EquipmentUpgradeWindow.Show()
    WindowSetShowing( mainWindowName, true )
    
    EA_BackpackUtilsMediator.EnableSoftLocks( true )
    EA_BackpackUtilsMediator.ShowBackpack()
end

function EquipmentUpgradeWindow.Hide()   
    WindowSetShowing( mainWindowName, false )
    
    EA_BackpackUtilsMediator.ReleaseAllLocksForWindow( mainWindowName )
    EA_BackpackUtilsMediator.EnableSoftLocks( false )
    ClearWindowData()
end

function EquipmentUpgradeWindow.OnShown()
    WindowUtils.OnShown( EquipmentUpgradeWindow.Hide, WindowUtils.Cascade.MODE_AUTOMATIC )
end

----------------------------------------------------------------
-- Button Handlers
----------------------------------------------------------------

function EquipmentUpgradeWindow.Upgrade()
    if ( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) )
    then
        return
    end
    
    if ( Player.GetMoney() < currentCost )
    then
        DialogManager.MakeOneButtonDialog( GetString( StringTables.Default.DIALOG_EQUIPMENT_UPGRADE_NO_MONEY ), GetString( StringTables.Default.LABEL_OKAY ) )
        return
    end
    
    -- TODO: Check if the item is fully upgraded, if so, show error
    
    UpgradeEquipmentCurrent()
    
    -- Prevent the player from clicking the Upgrade button until the server responds
    ButtonSetDisabledFlag( mainWindowName.."UpgradeButton", true )
    waitingOnServerResponse = true
    -- TODO: Should we also disable the slots until we get a response?
end

----------------------------------------------------------------
-- Event Handlers
----------------------------------------------------------------

function EquipmentUpgradeWindow.ReceivedUpgradeInfo( cost, successChance )
    currentCost = cost
    MoneyFrame.FormatMoney( mainWindowName.."Money", cost, MoneyFrame.SHOW_EMPTY_WINDOWS )
    
    local successText = GetStringFormat( StringTables.Default.GENERIC_PERCENTAGE, { towstring(successChance) } )
    LabelSetText( mainWindowName.."SuccessText", successText )
    
    -- TODO: Actually calculate the level
    local levelText = L"X/Y"
    LabelSetText( mainWindowName.."LevelText", levelText )
    
    SetMainItemLabelsShowing( true )
end

function EquipmentUpgradeWindow.ReceivedResultInfo( resultCode )
    if ( waitingOnServerResponse )
    then
        waitingOnServerResponse = false
        -- Request updated info from the server. Don't unlock the buttons until we receive that info
        RequestUpgradeEquipmentCurrentInfo()
    end
    
    -- Always display the appropriate success/error messages, in case they closed the window before getting a response
    if ( resultCode == GameData.EquipmentUpgradeResult.SUCCESS )
    then
        if ( AlertTextWindow ~= nil )
        then
            AlertTextWindow.AddLine( SystemData.AlertText.Types.DEFAULT, GetString( StringTables.Default.ALERT_EQUIPMENT_UPGRADE_SUCCESSFUL ) )
        end
    elseif ( resultCode == GameData.EquipmentUpgradeResult.NO_ITEM )
    then
        DialogManager.MakeOneButtonDialog( GetString( StringTables.Default.DIALOG_EQUIPMENT_UPGRADE_INVALID_ITEM ), GetString( StringTables.Default.LABEL_OKAY ) )
    elseif ( resultCode == GameData.EquipmentUpgradeResult.MAX_UPGRADE )
    then
        -- TODO: Show same error that I add to .Upgrade()
    elseif ( resultCode == GameData.EquipmentUpgradeResult.ITEM_TOO_LOW )
    then
        DialogManager.MakeOneButtonDialog( GetString( StringTables.Default.DIALOG_EQUIPMENT_UPGRADE_ITEM_LEVEL_LOW ), GetString( StringTables.Default.LABEL_OKAY ) )
    elseif ( resultCode == GameData.EquipmentUpgradeResult.INSUFFICIENT_GOLD )
    then
        DialogManager.MakeOneButtonDialog( GetString( StringTables.Default.DIALOG_EQUIPMENT_UPGRADE_NO_MONEY ), GetString( StringTables.Default.LABEL_OKAY ) )
    elseif ( resultCode == GameData.EquipmentUpgradeResult.INVALID_REFINER )
    then
        DialogManager.MakeOneButtonDialog( GetString( StringTables.Default.DIALOG_EQUIPMENT_UPGRADE_INVALID_REFINER ), GetString( StringTables.Default.LABEL_OKAY ) )
    elseif ( resultCode == GameData.EquipmentUpgradeResult.FAILED )
    then
        if ( AlertTextWindow ~= nil )
        then
            AlertTextWindow.AddLine( SystemData.AlertText.Types.DEFAULT, GetString( StringTables.Default.ALERT_EQUIPMENT_UPGRADE_FAILURE ) )
        end
    elseif ( resultCode == GameData.EquipmentUpgradeResult.SYSTEM_FAILURE )
    then
        DialogManager.MakeOneButtonDialog( GetString( StringTables.Default.DIALOG_EQUIPMENT_UPGRADE_UNKNOWN_ERROR ), GetString( StringTables.Default.LABEL_OKAY ) )
    end
end

----------------------------------------------------------------
-- Slot Handlers
----------------------------------------------------------------

function EquipmentUpgradeWindow.SlotLButtonUp()
    if ( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) )
    then
        return
    end
    
    local slotNum = WindowGetId( SystemData.ActiveWindow.name )
    local pickupItem = currentItems[slotNum]
    
    if ( Cursor.IconOnCursor() )
    then
        local backpackType = EA_BackpackUtilsMediator.GetCurrentBackpackType()
        local cursorType = EA_BackpackUtilsMediator.GetCursorForBackpack( backpackType )
        
        if ( cursorType ~= Cursor.Data.Source )
        then
            -- Only allow items to be dropped from the active backpack
            return
        end
        
        if ( EquipmentUpgradeWindow.AddItem( backpackType, Cursor.Data.SourceSlot, slotNum ) )
        then
            Cursor.Clear( true )
        else
            -- Don't attempt to pick up the existing item if we didn't successfully drop the cursor item
            return
        end
    end
        
    if ( pickupItem )
    then
        -- Pick up the old item into the cursor
        Cursor.PickUp( pickupItem.objectSource, pickupItem.sourceSlot, pickupItem.objectId,
                       pickupItem.iconId, pickupItem.autoOnLButtonUp, pickupItem.stackAmount )
                       
        -- If we didn't just replace the slot with a new icon, then clear the icon and item data
        if ( pickupItem == currentItems[slotNum] )
        then
            EA_BackpackUtilsMediator.ReleaseLockForSlot( pickupItem.sourceSlot, pickupItem.sourceBackpack, mainWindowName )
            ClearItemSlot( slotNum )
        end
    end
    
    RequestUpgradeEquipmentCurrentInfo()
end

function EquipmentUpgradeWindow.SlotRButtonUp()
    if ( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) )
    then
        return
    end
    
    if ( Cursor.IconOnCursor() )
    then
        Cursor.Clear()
    else
        local slotNum = WindowGetId( SystemData.ActiveWindow.name )
        local item = currentItems[slotNum]
        
        if ( item )
        then
            EA_BackpackUtilsMediator.ReleaseLockForSlot( item.sourceSlot, item.sourceBackpack, mainWindowName )
            ClearItemSlot( slotNum )
            Sound.Play( Sound.ICON_CLEAR )
            
            RequestUpgradeEquipmentCurrentInfo()
        end
    end
end

function EquipmentUpgradeWindow.SlotMouseOver()
    local slotNum = WindowGetId( SystemData.ActiveWindow.name )
    local item = currentItems[slotNum]
    
    if ( item )
    then
        local itemData = EA_Window_Backpack.GetItemsFromBackpack( item.sourceBackpack )[item.sourceSlot]
        if ( DataUtils.IsValidItem( itemData ) )
        then
            Tooltips.CreateItemTooltip( itemData, SystemData.ActiveWindow.name, Tooltips.ANCHOR_WINDOW_RIGHT, true, GetString( StringTables.Default.TEXT_R_CLICK_TO_REMOVE ), Tooltips.COLOR_WARNING )
        end
    else
        local tooltipText = GetString( slotToTooltipMapping[slotNum] )
        if ( ( tooltipText ~= nil ) and ( tooltipText ~= L"" ) )
        then
            -- Create a tooltip for the empty spot
            Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, tooltipText )
            Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT )
        end
    end
end