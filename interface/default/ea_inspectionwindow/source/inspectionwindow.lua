----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

-- TODO: Strip away everything that isn't needed in this window and 
-- reuse the code from the character window mod instead

EA_Window_Inspection = {}
EA_Window_Inspection.version = 2.01


-- Constant Strings
EA_Window_Inspection.TOOLTIP_TROPHY_NO_AVAILABLE_LOC = GetString( StringTables.Default.TOOLTIP_TROPHY_NO_AVAILABLE_LOC )
EA_Window_Inspection.TOOLTIP_TROPHY_INVALID_LOC = GetString( StringTables.Default.TOOLTIP_TROPHY_INVALID_LOC )

-- trophy Constants
EA_Window_Inspection.NUM_TROPHY_SLOTS = GameData.Player.c_NUM_TROPHIES
EA_Window_Inspection.NORMAL_TINT = {R=255, G=255, B=255}
EA_Window_Inspection.EQUIPMENT_EMPTY_TINT = {R=204, G=168, B=144}
EA_Window_Inspection.TROPHY_EMPTY_TINT = {R=170, G=140, B=120}
EA_Window_Inspection.TROPHY_INVALID_LOC_TINT = Tooltips.COLOR_WARNING 
EA_Window_Inspection.INVALID_TROPHY_POSITION = 0

-- prevent some invalid initialization
EA_Window_Inspection.initializationComplete = false

EA_Window_Inspection.equipmentData = {}
EA_Window_Inspection.bragData = {}

-- EquipmentSlotInfo provides default icons and strings when for when no armor is equipped for that slot
EA_Window_Inspection.NUM_EQUIPMENT_SLOTS = 20

EA_Window_Inspection.EquipmentSlotInfo = {  }     
EA_Window_Inspection.EquipmentSlotInfo[GameData.EquipSlots.RIGHT_HAND]   =  { name=GetString( StringTables.Default.LABEL_RIGHT_HAND ),   iconNum=6 }
EA_Window_Inspection.EquipmentSlotInfo[GameData.EquipSlots.LEFT_HAND]    =  { name=GetString( StringTables.Default.LABEL_LEFT_HAND ),    iconNum=7 }
EA_Window_Inspection.EquipmentSlotInfo[GameData.EquipSlots.RANGED]       =  { name=GetString( StringTables.Default.LABEL_RANGED_SLOT ),  iconNum=8 }
EA_Window_Inspection.EquipmentSlotInfo[GameData.EquipSlots.BODY]         =  { name=GetString( StringTables.Default.LABEL_BODY ),         iconNum=9 }
EA_Window_Inspection.EquipmentSlotInfo[GameData.EquipSlots.GLOVES]       =  { name=GetString( StringTables.Default.LABEL_GLOVES ),       iconNum=10 }
EA_Window_Inspection.EquipmentSlotInfo[GameData.EquipSlots.BOOTS]        =  { name=GetString( StringTables.Default.LABEL_BOOTS ),        iconNum=11 }
EA_Window_Inspection.EquipmentSlotInfo[GameData.EquipSlots.HELM]         =  { name=GetString( StringTables.Default.LABEL_HELM ),         iconNum=12 }
EA_Window_Inspection.EquipmentSlotInfo[GameData.EquipSlots.SHOULDERS]    =  { name=GetString( StringTables.Default.LABEL_SHOULDERS ),    iconNum=13 }
EA_Window_Inspection.EquipmentSlotInfo[GameData.EquipSlots.POCKET1]		 =  { name=GetString( StringTables.Default.LABEL_POCKET ),       iconNum=36 }
EA_Window_Inspection.EquipmentSlotInfo[GameData.EquipSlots.POCKET2]		 =  { name=GetString( StringTables.Default.LABEL_POCKET ),       iconNum=36 }
EA_Window_Inspection.EquipmentSlotInfo[GameData.EquipSlots.BACK]         =  { name=GetString( StringTables.Default.LABEL_BACK ),         iconNum=16 }
EA_Window_Inspection.EquipmentSlotInfo[GameData.EquipSlots.BELT]         =  { name=GetString( StringTables.Default.LABEL_BELT ),         iconNum=17 }
EA_Window_Inspection.EquipmentSlotInfo[GameData.EquipSlots.EVENT]        =  { name=GetString( StringTables.Default.LABEL_EVENT ),        iconNum=20 }
EA_Window_Inspection.EquipmentSlotInfo[GameData.EquipSlots.BANNER]       =  { name=GetString( StringTables.Default.LABEL_BANNER ),       iconNum=18 }
EA_Window_Inspection.EquipmentSlotInfo[GameData.EquipSlots.ACCESSORY1]   =  { name=GetString( StringTables.Default.LABEL_ACCESSORY1 ),   iconNum=20 } 
EA_Window_Inspection.EquipmentSlotInfo[GameData.EquipSlots.ACCESSORY2]   =  { name=GetString( StringTables.Default.LABEL_ACCESSORY2 ),   iconNum=20 } 
EA_Window_Inspection.EquipmentSlotInfo[GameData.EquipSlots.ACCESSORY3]   =  { name=GetString( StringTables.Default.LABEL_ACCESSORY3 ),   iconNum=20 } 
EA_Window_Inspection.EquipmentSlotInfo[GameData.EquipSlots.ACCESSORY4]   =  { name=GetString( StringTables.Default.LABEL_ACCESSORY4 ),   iconNum=20 }
-- EquipmentSlotInfo for trophies is set programatically in  EA_Window_Inspection.UnlockTrophies()


local iconTexture, iconX, iconY = GetIconData( 37 )
EA_Window_Inspection.TROPHY_EMPTY_ICON = {texture=iconTexture, x=iconX, y=iconY }

iconTexture, iconX, iconY = GetIconData( 38 )
EA_Window_Inspection.TROPHY_INVALID_ATTACHMENT_POINT_ICON = {texture=iconTexture, x=iconX, y=iconY }

iconTexture, iconX, iconY = GetIconData( 39 )
EA_Window_Inspection.TROPHY_LOCKED_ICON = {texture=iconTexture, x=iconX, y=iconY }

iconTexture, iconX, iconY = GetIconData( 40 )
EA_Window_Inspection.TROPHY_NO_ATTACHMENT_POINT_ICON = {texture=iconTexture, x=iconX, y=iconY }

EA_Window_Inspection.MODE_NORMAL = 1
EA_Window_Inspection.MODE_BRAGS  = 2
EA_Window_Inspection.mode = EA_Window_Inspection.MODE_NORMAL


----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

EA_Window_Inspection.dropPending = false

----------------------------------------------------------------
-- EA_Window_Inspection Functions
----------------------------------------------------------------

-- OnInitialize Handler
function EA_Window_Inspection.Initialize()
    
        
    LabelSetText( "EA_Window_InspectionContentsImageNameLabel", TargetInfo:UnitName("selffriendlytarget") )
    LabelSetText( "EA_Window_InspectionBragsHeader", GetStringFormat( StringTables.Default.LABEL_PLAYERS_BRAGS_HEADER, {TargetInfo:UnitName("selffriendlytarget")} ) )

     
    WindowRegisterEventHandler( "EA_Window_Inspection", SystemData.Events.SOCIAL_INSPECTION_UPDATED, "EA_Window_Inspection.Show")

    ButtonSetText( "EA_Window_InspectionTabsCharTab", GetString( StringTables.Default.LABEL_CHARACTER ) )
    ButtonSetText( "EA_Window_InspectionTabsBragsTab", GetString( StringTables.Default.LABEL_BRAGS ) )
    
    EA_Window_Inspection.UpdateCareerRank()
    
    EA_Window_Inspection.UpdateMode( EA_Window_Inspection.MODE_NORMAL )
end

function EA_Window_Inspection.UpdateCareerRank() 	  	 
	local career = GameData.Player.career.name 	  	 
	local rank = TargetInfo:UnitLevel("selffriendlytarget") 	  	 
	local rankText = GetStringFormat( StringTables.Default.LABEL_RANK_X, { rank } ) 	  	 
    EA_Window_Inspection.UnlockTrophies() 	  	 
end

function EA_Window_Inspection.UpdateMode( mode )
    if( mode )
    then
        local inNormalMode = true
        EA_Window_Inspection.mode = mode
        
        if( mode == EA_Window_Inspection.MODE_BRAGS )
        then
            inNormalMode = false
        end
        
        WindowSetShowing( "EA_Window_InspectionTabs", true )
        
        WindowSetShowing( "EA_Window_InspectionContents", inNormalMode )
        WindowSetShowing( "EA_Window_InspectionBrags", not inNormalMode )
        
        ButtonSetPressedFlag( "EA_Window_InspectionTabsCharTab", inNormalMode )
        ButtonSetStayDownFlag( "EA_Window_InspectionTabsCharTab", inNormalMode )
        ButtonSetPressedFlag( "EA_Window_InspectionTabsBragsTab", not inNormalMode )
        ButtonSetStayDownFlag( "EA_Window_InspectionTabsBragsTab", not inNormalMode )
    end
end

function EA_Window_Inspection.OnTabSelectChar()
    EA_Window_Inspection.UpdateMode( EA_Window_Inspection.MODE_NORMAL )
end

function EA_Window_Inspection.OnTabSelectBrags()
    EA_Window_Inspection.UpdateMode( EA_Window_Inspection.MODE_BRAGS )
end

function EA_Window_Inspection.UpdateBraggingRights()
    EA_Window_Inspection.bragData = GetInspectionBragData()
    
    for index, brag in ipairs( EA_Window_Inspection.bragData )
    do
        local windowName = "EA_Window_InspectionBragsEntry"..index
        local anchorWindow = "EA_Window_InspectionBragsEntry"..index-1
        if( index <= 1 )
        then
            anchorWindow = "EA_Window_InspectionBragsAnchor"
        end
    
        -- create a window for this brag if it doesn't exist
        if( not DoesWindowExist( windowName ) )
        then
            CreateWindowFromTemplate( windowName, "InspectionWindowBraggingRightTemplate", "EA_Window_InspectionBrags" )
            WindowAddAnchor( windowName, "bottom", anchorWindow, "top", 0, 0 )
        end
        
        WindowSetId( windowName, index )
        
        LabelSetText( windowName.."Text", brag.name )

        -- set the reward data
        if( not brag.rewards )
        then
            WindowSetShowing( windowName.."Reward1", false )
            WindowSetShowing( windowName.."Reward2", false )
        else
            EA_Window_Inspection.SetTomeReward( windowName.."Reward1", brag.rewards[1] )
            EA_Window_Inspection.SetTomeReward( windowName.."Reward2", brag.rewards[2] )
            
            -- Anchor card to left most reward
            anchorCardTo = windowName.."Reward1"
            if( brag.rewards[2] and brag.rewards[2].rewardId and brag.rewards[2].rewardId ~= 0 )
            then
                anchorCardTo = windowName.."Reward2"
            end
            WindowClearAnchors( windowName.."Card" )
            WindowAddAnchor( windowName.."Card", "topleft", anchorCardTo, "topright", 0, 0 )
        end
        
        -- Set the card if there is one
        local cardData = nil
        if( brag.cardData.cardId and brag.cardData.cardId ~= 0 )
        then
            cardData = brag.cardData
        end
        TomeWindow.SetCard( windowName.."Card", cardData )
    end
    
end

function EA_Window_Inspection.SetTomeReward( rewardWindowName, rewardData )

    if( rewardData == nil ) then
        WindowSetShowing( rewardWindowName, false )
        return
    end
    
    if( rewardData.rewardId == 0 ) then
        WindowSetShowing( rewardWindowName, false )
        return
    end
    
    WindowSetShowing( rewardWindowName, true )

    local iconNum = 0
    
    --Set up the icon for the reward
    if( GameData.Tome.REWARD_XP == rewardData.rewardType )
    then
        iconNum = GameDefs.Icons.ICON_XP_REWARD
        
    elseif( GameData.Tome.REWARD_TITLE == rewardData.rewardType )
    then
        iconNum = GameDefs.Icons.ICON_TITLE_REWARD
    
    elseif( rewardData.rewardData.iconNum )
    then
        iconNum = rewardData.rewardData.iconNum
        
    end    

    local texture, x, y = GetIconData( iconNum )        
    DynamicImageSetTexture( rewardWindowName.."IconBase", texture, x, y )  
end

function EA_Window_Inspection.OnMouseOverReward()
    local bragIndex = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
    local rewardIndex = WindowGetId(  SystemData.ActiveWindow.name )

    local rewardType = EA_Window_Inspection.bragData[bragIndex].rewards[rewardIndex].rewardType
    local rewardId = EA_Window_Inspection.bragData[bragIndex].rewards[rewardIndex].rewardId
    local rewardData = EA_Window_Inspection.bragData[bragIndex].rewards[rewardIndex].rewardData
    
    if( rewardId == 0 ) then     
       return
    end
    
    local rewardWindowName = SystemData.ActiveWindow.name
    local anchor = Tooltips.ANCHOR_RIGHT

    --Set up the icon for the reward
    if( GameData.Tome.REWARD_ITEM == rewardType )
    then
        Tooltips.CreateItemTooltip( rewardData, rewardWindowName, anchor )
        
    elseif( GameData.Tome.REWARD_ABILITY == rewardType )
    then
        Tooltips.CreateAbilityTooltip( rewardData, rewardWindowName, anchor )
        
    elseif( GameData.Tome.REWARD_XP == rewardType )
    then
        local text = GetStringFormat( StringTables.Default.LABEL_X_XP, {rewardId}  )
        Tooltips.CreateTextOnlyTooltip( rewardWindowName, text )
        Tooltips.AnchorTooltip( anchor )
        
    elseif( GameData.Tome.REWARD_TITLE == rewardType )
    then
        local name = L"???"
        if( rewardData ~= nil ) then
            name = rewardData.name
        end
        local text = GetStringFormat( StringTables.Default.LABEL_TITLE_X, { name }  )
        local actionText = GetString( StringTables.Default.TEXT_CLICK_TITLE_LINK )
        Tooltips.CreateTextOnlyTooltip( rewardWindowName, text )
        Tooltips.SetTooltipActionText( actionText )
        Tooltips.Finalize()
        
        Tooltips.AnchorTooltip( anchor )
    end  
end

function EA_Window_Inspection.OnMouseOverCard()
    local cardId = WindowGetId( SystemData.ActiveWindow.name )
    local bragIndex = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
    local cardData = EA_Window_Inspection.bragData[bragIndex].cardData
    local cardWindowName = SystemData.ActiveWindow.name
    local actionTextId = StringTables.Default.TEXT_CLICK_CARD_LINK
    local anchor = Tooltips.ANCHOR_WINDOW_RIGHT

    -- No valid card data
    if( cardData == nil ) then
        return
    end
    
    -- Build tool tip
    local cardName = GetFormatStringFromTable( "Default", StringTables.Default.TEXT_CARD_NAME, { cardData.valueName, cardData.suitName } )
    local cardColor = DataUtils.GetItemRarityColor( cardData )
    
    Tooltips.CreateTextOnlyTooltip( cardWindowName, nil )
    Tooltips.SetTooltipText( 1, 1, cardName )
    Tooltips.SetTooltipColor( 1, 1, cardColor.r, cardColor.g, cardColor.b )
    
    local unlockText = nil
    local actionText = nil
    if( cardData.unlockInfo.section ~= 0 and cardData.unlockInfo.entry ~= 0 )
    then
        local params = { DataUtils.GetTomeSectionName( cardData.unlockInfo.section ), cardData.unlockInfo.name }
        unlockText = GetStringFormat( StringTables.Default.TEXT_TOME_ENTRY_SOURCE, params )
    else
        unlockText = L""
    end
    
    Tooltips.SetTooltipText( 2, 1, unlockText )
    Tooltips.SetTooltipColorDef( 2, 1, Tooltips.COLOR_HEADING )
    
    if( actionTextId )
    then
        Tooltips.SetTooltipActionText( GetString( actionTextId ) )
    end
    Tooltips.Finalize()
    
    Tooltips.AnchorTooltip( anchor )
end

function EA_Window_Inspection.OnClickReward()
    local bragIndex = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
    local rewardIndex = WindowGetId(  SystemData.ActiveWindow.name )

    local rewardData = EA_Window_Inspection.bragData[bragIndex].rewards[rewardIndex]
    TomeWindow.OnClickTomeReward( rewardData )
end

function EA_Window_Inspection.OnClickCard()
    local bragIndex = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
    local cardData = EA_Window_Inspection.bragData[bragIndex].cardData
    
    TomeWindow.OnClickTomeCard( cardData )
end


-- this gets called during intitialization and for level up events in case a new slot becomes unlocked
function EA_Window_Inspection.UnlockTrophies()
    
    local userLevel = TargetInfo:UnitLevel("selffriendlytarget")
    if userLevel < 1 then
        return
    end
    
    EA_Window_Inspection.numOfTrophiesUnlocked = math.floor(userLevel / 10) + 1
    
    -- unlocked
    for trophyNum = 1, EA_Window_Inspection.numOfTrophiesUnlocked do
        ButtonSetDisabledFlag( "EA_Window_InspectionContentsEquipmentSlot"..(trophyNum+EA_Window_Inspection.NUM_EQUIPMENT_SLOTS), false )
        
        local text = GetStringFormat( StringTables.Default.LABEL_TROPHY, { trophyNum } )
        EA_Window_Inspection.EquipmentSlotInfo[trophyNum+EA_Window_Inspection.NUM_EQUIPMENT_SLOTS] =  { name=text} 
        
        local lockIconWindowName = "EA_Window_InspectionContentsEquipmentSlot"..(trophyNum+EA_Window_Inspection.NUM_EQUIPMENT_SLOTS).."LockIcon"
        WindowSetShowing( lockIconWindowName, false )
    end
    
    -- locked
    -- icon is now assembled from the untinted icon with a lock mini-icon on top
    for trophyNum = EA_Window_Inspection.numOfTrophiesUnlocked+1, EA_Window_Inspection.NUM_TROPHY_SLOTS do
    
        ButtonSetDisabledFlag( "EA_Window_InspectionContentsEquipmentSlot"..(trophyNum+EA_Window_Inspection.NUM_EQUIPMENT_SLOTS), true )
        local windowName = "EA_Window_InspectionContentsEquipmentSlot"..(trophyNum+EA_Window_Inspection.NUM_EQUIPMENT_SLOTS).."IconBase"
        local icon = EA_Window_Inspection.TROPHY_EMPTY_ICON
        DynamicImageSetTexture( windowName, icon.texture, icon.x, icon.y)

        local requiredLevel = (trophyNum-1) * 10
        
        local text1 = GetStringFormat( StringTables.Default.LABEL_TROPHY, { trophyNum } )
        local text2 = GetStringFormat( StringTables.Default.LABEL_TROPHY_LOCKED, { requiredLevel } )
        EA_Window_Inspection.EquipmentSlotInfo[trophyNum+EA_Window_Inspection.NUM_EQUIPMENT_SLOTS] =  { name=text1..L"\n"..text2 } 
        
        local lockIconWindowName = "EA_Window_InspectionContentsEquipmentSlot"..(trophyNum+EA_Window_Inspection.NUM_EQUIPMENT_SLOTS).."LockIcon"
        lockIcon = EA_Window_Inspection.TROPHY_LOCKED_ICON
        DynamicImageSetTexture( lockIconWindowName, lockIcon.texture, lockIcon.x, lockIcon.y)
        WindowSetShowing( lockIconWindowName, true )
        
        local miniIconWindowName = "EA_Window_InspectionContentsEquipmentSlot"..(trophyNum+EA_Window_Inspection.NUM_EQUIPMENT_SLOTS).."MiniIcon"
        WindowSetShowing( miniIconWindowName, false )
    end
    
    EA_Window_Inspection.UpdateSlotIcons()
end

-- provides the ItemInfo corresponding to the given slot
function EA_Window_Inspection.GetItem( slot )

    if slot < GameData.Player.c_TROPHY_START_INDEX then
        return EA_Window_Inspection.equipmentData[slot]

    else
        local trophySlot = slot - GameData.Player.c_TROPHY_START_INDEX + 1	
        return EA_Window_Inspection.equipmentData[slot+EA_Window_Inspection.NUM_EQUIPMENT_SLOTS]
    end
end



function EA_Window_Inspection.highlightSlot( windowName )
    
    ButtonSetStayDownFlag( windowName, true )     
    ButtonSetPressedFlag( windowName, true )
end

function EA_Window_Inspection.unhighlightSlot( windowName )
    
    ButtonSetStayDownFlag( windowName, false )     
    ButtonSetPressedFlag( windowName, false )
end


-- OnUpdate Handler
function EA_Window_Inspection.Update( timePassed )

    local showing = WindowGetShowing( "EA_Window_Inspection" )
    if( showing ) then  
        BroadcastEvent( SystemData.Events.UPDATE_TARGETPAPERDOLL )    
    end
end

-- OnShutdown Handler
function EA_Window_Inspection.Shutdown()
    WindowSetShowing("EA_Window_Inspection", false )
    WindowUnregisterEventHandler( "EA_Window_Inspection", SystemData.Events.L_BUTTON_DOWN_PROCESSED )
end

function EA_Window_Inspection.RefreshContents()
    EA_Window_Inspection.UnlockTrophies() 
    EA_Window_Inspection.UpdateBraggingRights()
end

-- OnShown Handler
function EA_Window_Inspection.OnShown()
   WindowUtils.OnShown(EA_Window_Inspection.Hide, WindowUtils.Cascade.MODE_AUTOMATIC)

   EA_Window_Inspection.RefreshContents()
end

function EA_Window_Inspection.ToggleShowing()   
    WindowUtils.ToggleShowing( "EA_Window_Inspection" )
end

function EA_Window_Inspection.Show() 
	LabelSetText( "EA_Window_InspectionContentsImageNameLabel", TargetInfo:UnitName("selffriendlytarget") )
	LabelSetText( "EA_Window_InspectionBragsHeader", GetStringFormat( StringTables.Default.LABEL_PLAYERS_BRAGS_HEADER, {TargetInfo:UnitName("selffriendlytarget")} ) )
    
    if (WindowGetShowing("EA_Window_Inspection"))
    then  
        EA_Window_Inspection.RefreshContents()
    else
        WindowSetShowing("EA_Window_Inspection", true)
    end
end

function EA_Window_Inspection.Hide() 
    WindowSetShowing("EA_Window_Inspection", false)
end

function EA_Window_Inspection.getSlotInfoForTrophyLocation( location, index )

    for slot, clothingInfo in pairs( EA_Window_Inspection.ClothingSlotInfo ) do
    
        if clothingInfo.trophyLocation == location and clothingInfo.trophyLocIndex == index then
            return slot
        end
    end
    
    return 0
end

function EA_Window_Inspection.UpdateSlotIcons()
    local texture, x, y  = 0, 0, 0
    local tint = EA_Window_Inspection.NORMAL_TINT 

    EA_Window_Inspection.equipmentData = GetInspectionData()
    for equipmentData, slot in pairs(GameData.EquipSlots) do

        local found = false
        if( EA_Window_Inspection.equipmentData[slot].iconNum ~= 0 )
        then
            texture, x, y = GetIconData( EA_Window_Inspection.equipmentData[slot].iconNum ) 
            tint = EA_Window_Inspection.NORMAL_TINT
            found = true
        elseif( EA_Window_Inspection.EquipmentSlotInfo[slot] )
        then
            texture, x, y = GetIconData( EA_Window_Inspection.EquipmentSlotInfo[slot].iconNum )  
            found = true
        end     

        if( found )
        then
            DynamicImageSetTexture( "EA_Window_InspectionContentsEquipmentSlot"..slot.."IconBase", texture, x, y )
        end
    end 
    
    EA_Window_Inspection.numOfTrophiesEquipped = 0
        
    for  slot = 1, EA_Window_Inspection.numOfTrophiesUnlocked  do  
        local trophyData = EA_Window_Inspection.equipmentData[slot+EA_Window_Inspection.NUM_EQUIPMENT_SLOTS]
        local miniIconWindowName = "EA_Window_InspectionContentsEquipmentSlot"..(slot+EA_Window_Inspection.NUM_EQUIPMENT_SLOTS).."MiniIcon"

        if( trophyData ~= nil and trophyData.uniqueID ~= 0) 
        then
            texture, x, y = GetIconData( trophyData.iconNum ) 
            tint = EA_Window_Inspection.NORMAL_TINT
            
            EA_Window_Inspection.numOfTrophiesEquipped = EA_Window_Inspection.numOfTrophiesEquipped + 1   
        else
        
            -- display empty trophy slot icon
            local icon = EA_Window_Inspection.TROPHY_EMPTY_ICON
            texture, x, y = icon.texture, icon.x, icon.y
            tint = EA_Window_Inspection.TROPHY_EMPTY_TINT

            WindowSetShowing( miniIconWindowName, false )
        end     
        
         -- trophy windows are grouped with other equipment slots
        local iconWindowName = "EA_Window_InspectionContentsEquipmentSlot"..(slot+EA_Window_Inspection.NUM_EQUIPMENT_SLOTS).."IconBase"
        DynamicImageSetTexture( iconWindowName, texture, x, y )
--        WindowSetTintColor( "EA_Window_InspectionEquipmentSlot"..(slot+EA_Window_Inspection.NUM_EQUIPMENT_SLOTS), tint.R, tint.G, tint.B )

    end 
    
end

-- OnMouseMove Handler
function EA_Window_Inspection.EquipmentMouseOver()
    EA_Window_Inspection.MouseOverSlot( WindowGetId(SystemData.ActiveWindow.name) )
end 

function EA_Window_Inspection.MouseOverSlot( slot )

    if( EA_Window_Inspection.equipmentData[slot].id == 0 ) then        
        Tooltips.CreateTextOnlyTooltip( "EA_Window_InspectionContentsEquipmentSlot"..slot, nil )
        Tooltips.SetTooltipText( 1, 1, EA_Window_Inspection.EquipmentSlotInfo[slot].name )
        Tooltips.SetTooltipColor( 1, 1, 123, 172, 220 )
        Tooltips.Finalize()
        Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT )
    else
        Tooltips.CreateItemTooltip( EA_Window_Inspection.equipmentData[slot], "EA_Window_InspectionContentsEquipmentSlot"..slot, Tooltips.ANCHOR_WINDOW_RIGHT, true )   
    end
end 


-- OnMouseMove Handler
function EA_Window_Inspection.TrophyMouseOver()
                            
    EA_Window_Inspection.TrophyMouseOverSlot( WindowGetId(SystemData.ActiveWindow.name) )
end

function EA_Window_Inspection.TrophyMouseOverSlot( slot )
    -- trophy windows are grouped with other equipment slots
    local windowName = "EA_Window_InspectionContentsEquipmentSlot"..(slot+EA_Window_Inspection.NUM_EQUIPMENT_SLOTS) 
    
    local trophyData = EA_Window_Inspection.equipmentData[slot+EA_Window_Inspection.NUM_EQUIPMENT_SLOTS]
    if( trophyData == nil or trophyData.uniqueID == 0)
    then     
        Tooltips.CreateTextOnlyTooltip( windowName, nil )
        Tooltips.SetTooltipText( 1, 1, EA_Window_Inspection.EquipmentSlotInfo[(slot+EA_Window_Inspection.NUM_EQUIPMENT_SLOTS)].name )
        Tooltips.SetTooltipColor( 1, 1, 123, 172, 220 )
        Tooltips.Finalize()
        Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT )
    else
        Tooltips.CreateItemTooltip( trophyData, windowName, Tooltips.ANCHOR_WINDOW_RIGHT, true )   
    end
end 


-- TrophyMiniIconMouseOver is  commmented out because the tooltip on the mini icon 
--    is not working properly. It's repeatedly
--    firing OnMouseOver events rather than only sending it once.

function EA_Window_Inspection.TrophyMiniIconMouseOver()

    local windowName = SystemData.ActiveWindow.name
    local slot = WindowGetId( WindowGetParent( windowName ) )
    EA_Window_Inspection.TrophyMiniIconMouseOverSlot(windowName, slot)
end
    
function EA_Window_Inspection.TrophyMiniIconMouseOverSlot(windowName, slot)
    
    local trophyData = EA_Window_Inspection.equipmentData[slot+EA_Window_Inspection.NUM_EQUIPMENT_SLOTS]
     
    local invalidTint = EA_Window_Inspection.TROPHY_INVALID_LOC_TINT
    Tooltips.CreateTextOnlyTooltip( windowName, nil )
    Tooltips.SetTooltipText( 1, 1, trophyData.tooltip )
    Tooltips.SetTooltipColor( 1, 1, invalidTint.r, invalidTint.g, invalidTint.b )
    Tooltips.Finalize()
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT )
    
end


function EA_Window_Inspection.PaperDollMouseUp()
    if Cursor.IconOnCursor() and EA_Window_Inspection.dropPending == false then
        EA_Window_Inspection.AutoEquipItem(Cursor.Data.SourceSlot)
    end
end


function EA_Window_Inspection.CreateTooltip(wndName, line1, line2)
    Tooltips.CreateTextOnlyTooltip( wndName )  
    Tooltips.SetTooltipText( 1, 1, line1 )
    Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
    if (line2 ~= nil) then
        Tooltips.SetTooltipText( 2, 1, line2 )  
    end
    Tooltips.Finalize()
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT )
end
