----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_LootRoll = {}

EA_Window_LootRoll.TOOLTIP_ANCHOR = { Point = "topright",   RelativeTo = "EA_Window_LootRoll", RelativePoint = "topleft",   XOffset=5, YOffset=75 }

EA_Window_LootRoll.ROLL_CHOICE_GREED	= GameData.LootRoll.GREED
EA_Window_LootRoll.ROLL_CHOICE_NEED		= GameData.LootRoll.NEED
EA_Window_LootRoll.ROLL_CHOICE_PASS		= GameData.LootRoll.PASS
EA_Window_LootRoll.ROLL_CHOICE_INAVLID  = GameData.LootRoll.INVALID

EA_Window_LootRoll.MAX_ROLL_CHOICE_TIME = GameData.LootRoll.TIME_UNTIL_AUTO_ROLL -- Seconds

EA_Window_LootRoll.lootData = {}
EA_Window_LootRoll.lootDataDisplayOrder = {}

-- Locals
local LOOT_ROLL_HEIGHT = 395
local LOOT_ROLL_HEIGHT_WITH_HELP_TEXT = 465

local oldOffsetFromParent = {x=0,y=0}

----------------------------------------------------------------
-- EA_Window_LootRoll Functions
----------------------------------------------------------------

-- OnInitialize Handler
function EA_Window_LootRoll.Initialize()        
    WindowRegisterEventHandler("EA_Window_LootRoll", SystemData.Events.INTERACT_SHOW_LOOT_ROLL_DATA, "EA_Window_LootRoll.UpdateLootRollData")
    WindowRegisterEventHandler("EA_Window_LootRoll", SystemData.Events.INTERACT_LOOT_ROLL_FIRST_ITEM, "EA_Window_LootRoll.OnLootRollFirstItem")

    WindowRegisterEventHandler( "EA_Window_LootRoll", SystemData.Events.SIEGE_WEAPON_SNIPER_BEGIN, "EA_Window_LootRoll.OnBeginFireMode" )
    WindowRegisterEventHandler( "EA_Window_LootRoll", SystemData.Events.SIEGE_WEAPON_SNIPER_END, "EA_Window_LootRoll.OnEndFireMode" )  
    WindowRegisterEventHandler( "EA_Window_LootRoll", SystemData.Events.SIEGE_WEAPON_SCORCH_BEGIN, "EA_Window_LootRoll.OnBeginFireMode" )
    WindowRegisterEventHandler( "EA_Window_LootRoll", SystemData.Events.SIEGE_WEAPON_SCORCH_END, "EA_Window_LootRoll.OnEndFireMode" )  
    WindowRegisterEventHandler( "EA_Window_LootRoll", SystemData.Events.SIEGE_WEAPON_GOLF_BEGIN, "EA_Window_LootRoll.OnBeginFireMode" )
    WindowRegisterEventHandler( "EA_Window_LootRoll", SystemData.Events.SIEGE_WEAPON_GOLF_END, "EA_Window_LootRoll.OnEndFireMode" )  
    WindowRegisterEventHandler( "EA_Window_LootRoll", SystemData.Events.SIEGE_WEAPON_SWEET_SPOT_BEGIN, "EA_Window_LootRoll.OnBeginFireMode" )
    WindowRegisterEventHandler( "EA_Window_LootRoll", SystemData.Events.SIEGE_WEAPON_SWEET_SPOT_END, "EA_Window_LootRoll.OnEndFireMode" )  
    
    -- Label Text
    LabelSetText( "EA_Window_LootRollTitleBarText", GetString( StringTables.Default.LABEL_LOOTROLL_TITLE ) )   
    LabelSetText( "EA_Window_LootRollHelpText", GetString( StringTables.Default.LABEL_LOOT_ROLL_FIRE_MODE_HELP_TEXT ) )
    WindowSetShowing( "EA_Window_LootRollHelpText", false )
    
       
    EA_Window_LootRoll.UpdateLootRollData()    
    
end

-- OnInitialize Callback for each List Row
function EA_Window_LootRoll.InitializeListRow()
    
    local rowName = SystemData.ActiveWindow.name

    ButtonSetText(rowName.."NeedButton", GetString( StringTables.Default.LABEL_NEED ) )
    ButtonSetText(rowName.."GreedButton", GetString( StringTables.Default.LABEL_GREED ) )
    ButtonSetText(rowName.."PassButton", GetString( StringTables.Default.LABEL_PASS ) )

    ButtonSetStayDownFlag(rowName.."NeedButton", true )
    ButtonSetStayDownFlag(rowName.."GreedButton", true )
    ButtonSetStayDownFlag(rowName.."PassButton", true )	
    
    StatusBarSetMaximumValue(rowName.."TimerBar", EA_Window_LootRoll.MAX_ROLL_CHOICE_TIME  )
    StatusBarSetForegroundTint( rowName.."TimerBar", DefaultColor.GREEN.r, DefaultColor.GREEN.g, DefaultColor.GREEN.b )
    StatusBarSetBackgroundTint( rowName.."TimerBar", DefaultColor.BLACK.r, DefaultColor.BLACK.g, DefaultColor.BLACK.b )
end

-- OnUpdate Handler
function EA_Window_LootRoll.Update( timePassed )

    -- Update the timer bars
    local allLootsDone = true
    
    -- Loop through all of the visible items
    if( EA_Window_LootRoll.lootDataDisplayOrder ~= nil and EA_Window_LootRoll.lootData ~= nil )
    then
        for _, lootIndex in ipairs( EA_Window_LootRoll.lootDataDisplayOrder )
        do
            -- the loot data can get yanked out from under us in the middle of this loop
            -- so we need to check each pass, otherwise the script fails, and won't run again until reload
            if( EA_Window_LootRoll.lootData == nil )
            then
                return
            end
        
            local rollData = EA_Window_LootRoll.lootData[ lootIndex ]

            -- Decrement the Timer
            if( rollData.timer ~= nil and rollData.timer ~= 0 )
            then
                rollData.timer = rollData.timer - timePassed
                if( rollData.timer <= 0 )
                then
                    rollData.timer = 0
                    if( rollData.itemData.id ~= 0 and rollData.rollChoice == EA_Window_LootRoll.ROLL_CHOICE_INAVLID )
                    then
                        SelectItemRollChoice( rollData.sourceId, rollData.lootSlot, EA_Window_LootRoll.ROLL_CHOICE_PASS )
                        EA_Window_LootRoll.UpdateLootRollData()
                    end
                else
                    allLootsDone = false
                end
            end
        end    	    
    end
        
    -- Update the Timers for all visible items
    if( EA_Window_LootRollList.PopulatorIndices ~= nil and EA_Window_LootRoll.lootData ~= nil )
    then
      
        for rowIndex, lootIndex in ipairs( EA_Window_LootRollList.PopulatorIndices ) 
        do
            if( EA_Window_LootRoll.lootData == nil )
            then
                return
            end
        
            local rowName = "EA_Window_LootRollListRow"..rowIndex
            local rollData = EA_Window_LootRoll.lootData[ lootIndex ]           
    
            StatusBarSetCurrentValue( rowName.."TimerBar", rollData.timer )
        end        
        
    end        

    if( allLootsDone )
    then
       EA_Window_LootRoll.Hide()
    end
end

function EA_Window_LootRoll.OnBeginFireMode()
    -- Record the old offset from parent so we can set it again after fire mode has finished
    oldOffsetFromParent.x, oldOffsetFromParent.y = WindowGetOffsetFromParent( "EA_Window_LootRoll" )
    
    -- Put the loot roll window in the upper right as to not obstruct the players view and health while in siege weapon mode
    WindowClearAnchors( "EA_Window_LootRoll" )
    WindowAddAnchor( "EA_Window_LootRoll", "topright", "Root", "topright", 0, 0 )
    
    -- Adjust the hieght for the label we are going to show
    local x, _ = WindowGetDimensions( "EA_Window_LootRoll" )
    WindowSetDimensions( "EA_Window_LootRoll", x, LOOT_ROLL_HEIGHT_WITH_HELP_TEXT )
    
    WindowSetShowing( "EA_Window_LootRollHelpText", true )
end

function EA_Window_LootRoll.OnEndFireMode()
    -- Make sure we clear the anchors before setting the offset from parent
    WindowClearAnchors( "EA_Window_LootRoll" )
    
    WindowSetOffsetFromParent( "EA_Window_LootRoll", oldOffsetFromParent.x, oldOffsetFromParent.y )

    -- Adjust the hieght for exiting fire mode and hiding the label
    local x, _ = WindowGetDimensions( "EA_Window_LootRoll" )
    WindowSetDimensions( "EA_Window_LootRoll", x, LOOT_ROLL_HEIGHT )
    
    WindowSetShowing( "EA_Window_LootRollHelpText", false )
end


-- OnShutdown Handler
function EA_Window_LootRoll.Shutdown()
    EA_Window_LootRoll.Hide()
end

function EA_Window_LootRoll.OnHidden()
    
    -- Auto-Pass on any items for which the player hasn't selected a roll choice
    if( EA_Window_LootRoll.lootData )
    then
        for rowIndex, rollData in ipairs( EA_Window_LootRoll.lootData )
        do        
           
            if( rollData.itemData.id ~= 0 and rollData.rollChoice == EA_Window_LootRoll.ROLL_CHOICE_INAVLID ) then
                SelectItemRollChoice( rollData.sourceId, rollData.lootSlot, EA_Window_LootRoll.ROLL_CHOICE_PASS )
            end
            
        end    
    end      
    
    EA_Window_LootRoll.lootData = nil
end

function EA_Window_LootRoll.Hide()
    WindowSetShowing( "EA_Window_LootRoll", false )
end

local function AutoRoll( rollData )
    local autoRollSettings = EA_Window_OpenPartyLootRollOptions.Settings
    local item = rollData.itemData
    local rolled = false
    
    -- Don't auto roll on item set pieces
    if item.itemSet > 0
    then
        return rolled
    end

    local function CheckAndDoAutoRoll( filter, rollChoice )
        if filter and rollChoice and rollChoice ~= GameData.LootRoll.INVALID
        then
            if rollChoice ~= GameData.LootRoll.NEED
                or ( rollChoice == GameData.LootRoll.NEED and rollData.allowNeed )
            then
                SelectItemRollChoice( rollData.sourceId, rollData.lootSlot, rollChoice )
                rolled = true
            end
            return true
        end
        return false
    end
    
    local function CheckAndDoAutoRollWithRarity( filter, rollChoiceTable )
        local rollChoice = rollChoiceTable[item.rarity]
        CheckAndDoAutoRoll( filter, rollChoice )
    end
    
    -- simple type checks
    if      CheckAndDoAutoRoll( item.rarity == SystemData.ItemRarity.UTILITY, autoRollSettings.trash )
        or  CheckAndDoAutoRollWithRarity( DataUtils.IsTradeSkillItem( item, nil ), autoRollSettings.crafting )
        or  CheckAndDoAutoRollWithRarity( item.type == GameData.ItemTypes.CURRENCY, autoRollSettings.currency )
        or  CheckAndDoAutoRollWithRarity( item.type == GameData.ItemTypes.POTION, autoRollSettings.potion )
        or  CheckAndDoAutoRollWithRarity( item.type == GameData.ItemTypes.ENHANCEMENT, autoRollSettings.talisman )
        or  CheckAndDoAutoRollWithRarity( item.flags[GameData.Item.EITEMFLAG_EVENT], autoRollSettings.event )
    then
        return rolled
    end
    
    -- equipment (usable and unusable)
    local playerCanEventuallyUse = DataUtils.PlayerCanEventuallyUseItem( item )
    local isEquipment = DataUtils.ItemIsWeapon( item ) or DataUtils.ItemIsArmor( item )
    if      CheckAndDoAutoRollWithRarity( isEquipment and playerCanEventuallyUse, autoRollSettings.usableEquipment )
        or  CheckAndDoAutoRollWithRarity( isEquipment and not playerCanEventuallyUse, autoRollSettings.unusableEquipment )
    then
        return rolled
    end

    return rolled
end

function EA_Window_LootRoll.UpdateLootRollData()
    
    EA_Window_LootRoll.lootData = GetLootRollData()
    EA_Window_LootRoll.lootDataDisplayOrder = {}
    
    local showLootWindow = false

    -- Loop through all of the loot roll data and add unselected items to the display order
    for lootIndex, rollData in ipairs( EA_Window_LootRoll.lootData )
    do
        if( rollData.itemData.id ~= 0 and rollData.rollChoice == EA_Window_LootRoll.ROLL_CHOICE_INAVLID) 
        then
            --DEBUG(L" Loot Roll Item "..lootIndex..L" = "..rollData.itemData.name )
            if not AutoRoll( rollData )
            then
                table.insert( EA_Window_LootRoll.lootDataDisplayOrder, lootIndex )
            end
        end    	    
    end
        
    ListBoxSetDisplayOrder("EA_Window_LootRollList", EA_Window_LootRoll.lootDataDisplayOrder )
            
    -- Show the Window when it contains items
    WindowSetShowing( "EA_Window_LootRoll", EA_Window_LootRoll.lootDataDisplayOrder[1] ~= nil  )
end


function EA_Window_LootRoll.PopulateLootData()

    if (nil == EA_Window_LootRoll.lootData ) 
    then
        return
    end
    
    if( nil == EA_Window_LootRollList.PopulatorIndices )
    then
        return
    end    
    
    -- Setup the Custom formating for each row
    for row, lootIndex in ipairs( EA_Window_LootRollList.PopulatorIndices ) 
    do
        local rollData = EA_Window_LootRoll.lootData[lootIndex]
        
        local rowName   = "EA_Window_LootRollListRow"..row

        -- Color the Item based on rarity
        local color = DataUtils.GetItemRarityColor(rollData.itemData)
        LabelSetTextColor( rowName.."Name", color.r, color.g, color.b )
        
        -- Update the Row Background		
        local row_mod = math.mod(row, 2)
        local color = DataUtils.GetAlternatingRowColor( row_mod )
        DefaultColor.SetWindowTint( rowName.."Background", color )
        
        -- Update the Button States
        ButtonSetPressedFlag( rowName.."NeedButton",  rollData.rollChoice == EA_Window_LootRoll.ROLL_CHOICE_NEED )
        ButtonSetPressedFlag( rowName.."GreedButton", rollData.rollChoice == EA_Window_LootRoll.ROLL_CHOICE_GREED )
        ButtonSetPressedFlag( rowName.."PassButton",  rollData.rollChoice == EA_Window_LootRoll.ROLL_CHOICE_PASS )

        -- Turn off the Need button if requested.
        ButtonSetDisabledFlag( rowName.."NeedButton", not rollData.allowNeed )
        
        -- Set the stack count if we have more than one item
        local stackCount = rollData.itemData.stackCount
        local isStack = stackCount > 1
        if( isStack )
        then
            LabelSetText( rowName.."StackCount", towstring( stackCount ) )
        end
        
        WindowSetShowing( rowName.."StackCount", isStack )
        
        -- If the mouse is over this window, update the tooltip
        if( SystemData.MouseOverWindow.name == rowName )
        then
             EA_Window_LootRoll.MouseOverItemIndex( lootIndex )
        end
            
    end
    
end

function EA_Window_LootRoll.OnLootRollFirstItem( rollChoice )
    if ( EA_Window_LootRoll.lootDataDisplayOrder == nil or
         EA_Window_LootRoll.lootData == nil )
    then
        return
    end

    -- Find the first item for which we haven't yet chosen a roll choice.
    for _, lootIndex in ipairs( EA_Window_LootRoll.lootDataDisplayOrder )
    do
        local rollData = EA_Window_LootRoll.lootData[ lootIndex ]
        if ( rollData.itemData.id ~= 0 and rollData.rollChoice == EA_Window_LootRoll.ROLL_CHOICE_INAVLID )
        then
            -- We haven't yet chosen a choice for this item.
            -- So roll on it using the provided choice.
            SelectItemRollChoice( rollData.sourceId, rollData.lootSlot, rollChoice )
            EA_Window_LootRoll.UpdateLootRollData()
            break
        end
    end
end

function EA_Window_LootRoll.OnMouseOverItem()

    -- Convert the Row index to the item index
    local rowNum = WindowGetId( SystemData.ActiveWindow.name )	
    local lootIndex = EA_Window_LootRollList.PopulatorIndices[ rowNum ]
    
    EA_Window_LootRoll.MouseOverItemIndex( lootIndex )
end

function EA_Window_LootRoll.MouseOverItemIndex( lootIndex )

    if( not EA_Window_LootRoll.lootData )
    then
        return
    end

    local item = EA_Window_LootRoll.lootData[lootIndex]

    if( item ~= nil and item.itemData ~= nil and item.itemData.id ~= 0 and SystemData.ActiveWindow.name ~= nil )
    then
        Tooltips.CreateItemTooltip( item.itemData, SystemData.ActiveWindow.name, Tooltips.ANCHOR_WINDOW_LEFT )
    end
end


function EA_Window_LootRoll.SelectRollOption( lootIndex, rollChoice )
    EA_Window_LootRoll.lootData[lootIndex].rollChoice = rollChoice
    
    SelectItemRollChoice( EA_Window_LootRoll.lootData[lootIndex].sourceId, EA_Window_LootRoll.lootData[lootIndex].lootSlot, rollChoice )	

    EA_Window_LootRoll.UpdateLootRollData()
end

function EA_Window_LootRoll.SelectRollNeed()
    
    -- Convert the Row index to the item index
    local rowNum = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
    
    if ( ButtonGetDisabledFlag( "EA_Window_LootRollListRow"..rowNum.."NeedButton" ) )
    then
        return
    end

    local lootIndex = EA_Window_LootRollList.PopulatorIndices[ rowNum ]
    
    EA_Window_LootRoll.SelectRollOption( lootIndex, EA_Window_LootRoll.ROLL_CHOICE_NEED )
end

function EA_Window_LootRoll.SelectRollGreed()

    -- Convert the Row index to the loot index
    local rowNum = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )	
    local lootIndex = EA_Window_LootRollList.PopulatorIndices[ rowNum ]

    EA_Window_LootRoll.SelectRollOption( lootIndex, EA_Window_LootRoll.ROLL_CHOICE_GREED)
end

function EA_Window_LootRoll.SelectRollPass()

    -- Convert the Row index to the loot index
    local rowNum = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )	
    local lootIndex = EA_Window_LootRollList.PopulatorIndices[ rowNum ]
    
    EA_Window_LootRoll.SelectRollOption( lootIndex, EA_Window_LootRoll.ROLL_CHOICE_PASS )
end

function EA_Window_LootRoll.OnNeedMouseOver()
    local anchor = { Point="right",  RelativeTo=SystemData.ActiveWindow.name, RelativePoint="left", XOffset=20, YOffset=0 }
    
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, GetString( StringTables.Default.LABEL_NEED ))
    Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
    Tooltips.SetTooltipText( 2, 1, GetString( StringTables.Default.TEXT_NEED_DESC ))
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( anchor )
end

function EA_Window_LootRoll.OnGreedMouseOver()
    local anchor = { Point="right",  RelativeTo=SystemData.ActiveWindow.name, RelativePoint="left", XOffset=20, YOffset=0 }
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, GetString( StringTables.Default.LABEL_GREED ))
    Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
    Tooltips.SetTooltipText( 2, 1, GetString( StringTables.Default.TEXT_GREED_DESC ))
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( anchor )
end

function EA_Window_LootRoll.OnPassMouseOver()
    local anchor = { Point="right",  RelativeTo=SystemData.ActiveWindow.name, RelativePoint="left", XOffset=20, YOffset=0 }
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, GetString( StringTables.Default.LABEL_PASS ))
    Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
    Tooltips.SetTooltipText( 2, 1, GetString( StringTables.Default.TEXT_PASS_DESC ))
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( anchor )
end
