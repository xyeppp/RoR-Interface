local g_characterWindowOldX = nil
local g_characterWindowOldY = nil
local g_blockAllWarnings = false

local function ShowHelmForDyeing()

    if( not ButtonGetPressedFlag("CharacterWindowContentsEquipmentShowHelm") )
    then
        ButtonSetPressedFlag( "CharacterWindowContentsEquipmentShowHelm", true )
        CharacterWindow.ShowHelm()
        
        CharacterWindow.restoreHelmAfterDyeing = true
    end

end

local function ShowCloakForDyeing()

    if( not ButtonGetPressedFlag("CharacterWindowContentsEquipmentShowCloak") )
    then
        ButtonSetPressedFlag( "CharacterWindowContentsEquipmentShowCloak", true  )
        CharacterWindow.ShowCloak()
        
        CharacterWindow.restoreCloakAfterDyeing = true
    end
    
    if( ButtonGetPressedFlag("CharacterWindowContentsEquipmentShowCloakHeraldry") )
    then
        ButtonSetPressedFlag( "CharacterWindowContentsEquipmentShowCloakHeraldry", false  )
        CharacterWindow.ShowCloakHeraldry()

        CharacterWindow.restoreCloakHeraldryAfterDyeing = true
    end

end

function CharacterWindow.SelectSlotForDyeing(slot)
    CharacterWindow.selectedDyeSlotName = SystemData.ActiveWindow.name
    
    --Highlight the slot
    CharacterWindow.HighlightSlot( CharacterWindow.selectedDyeSlotName )
    
    -- If the Helm or Back item is selected, we need to make sure the item is showing
    -- for the sake of previewing the dye. In addition, if the heraldry cloak is being 
    -- worn it needs to be taken off so that we can see dyes on the actual back item.
    if( slot == GameData.EquipSlots.HELM )
    then
        ShowHelmForDyeing()
    elseif( slot == GameData.EquipSlots.BACK )
    then
        ShowCloakForDyeing()
    end
end

local function ShowAllItemsAndHideHeraldry()

    ShowHelmForDyeing()
    ShowCloakForDyeing()
    
end


-- DYE MERCHANT FUNCTIONS
local function GetIndexIntoDyeColors( id )
    return id + 1
end

function CharacterWindow.ClearWarningBlocker()
    g_blockAllWarnings = false
end

function CharacterWindow.MakeOkayDialog( displayString )
    if( not g_blockAllWarnings )
    then
        g_blockAllWarnings = true
        DialogManager.MakeOneButtonDialog( displayString, GetString( StringTables.Default.LABEL_OKAY ), CharacterWindow.ClearWarningBlocker )
    end
end

function CharacterWindow.IsSlotValidForDye( slotNum )   
    if( slotNum )
    then
        if( CharacterWindow.equipmentData[ slotNum ].id ~= 0 and
            CharacterWindow.equipmentData[ slotNum ].flags[GameData.Item.EITEMFLAG_DYE_ABLE] )
        then
            local tintMask = GetDyeTintMasks( CharacterWindow.equipmentData[ slotNum ].id ) 
            
            if( tintMask ~=  GameData.TintMasks.NONE )
            then
                if( tintMask == GameData.TintMasks.A )
                then
                    CharacterWindow.MakeOkayDialog( GetString( StringTables.Default.TEXT_DYE_MERCHANT_PRIMARY_TINT_ONLY ) )
                elseif( tintMask == GameData.TintMasks.B )
                then
                    CharacterWindow.MakeOkayDialog( GetString( StringTables.Default.TEXT_DYE_MERCHANT_SECONDARY_TINT_ONLY ) )
                end
            
                return true
            end
        end
    end
    
    local displayString = L""
    if( CharacterWindow.equipmentData[ slotNum ].id == 0 )
    then
        displayString = GetString( StringTables.Default.TEXT_DYE_MERCHANT_NO_ITEM_IN_SLOT )
    else
        displayString = GetString( StringTables.Default.TEXT_CANNOT_DYE_ITEM )
    end
    
    CharacterWindow.MakeOkayDialog( displayString )
    return false
end

local function GetNumDyedItems()
    local dyedA = 0
    local dyedB = 0
    
    for slot, item in ipairs( CharacterWindow.equipmentData )
    do
        if( item.id ~= 0 and item.flags[GameData.Item.EITEMFLAG_DYE_ABLE] )
        then
            if( item.dyeTintA ~= CharacterWindow.primaryColor )
            then
                dyedA = dyedA + 1
            end
            
            if( item.dyeTintB ~= CharacterWindow.secondaryColor )
            then
                dyedB = dyedB + 1
            end
        end
    end

    return dyedA, dyedB
end

function CharacterWindow.ShowDyeMerchant()
    local icon = CharacterWindow.TROPHY_EMPTY_ICON
    DynamicImageSetTexture( "DyeMerchantMarketingSlotIconBase", icon.texture, icon.x, icon.y )
    CharacterWindow.MarketingRButtonDown() -- this could be called with the window already opened to dye mode
    RevertAllDyePreview()
    
    
    WindowSetShowing("CharacterWindow", true)
    CharacterWindow.UpdateMode( CharacterWindow.MODE_DYE_MERCHANT )
end

function CharacterWindow.InitDyeMerchant()
    LabelSetText("DyeMerchantDyeAllLabel", GetString( StringTables.Default.LABEL_DYE_MERCHANT_DYE_ALL ) )
    LabelSetText("DyeMerchantCurrentColorDescLabel", GetString( StringTables.Default.LABEL_DYE_MERCHANT_MOUSE_OVER_COLOR ) )
    LabelSetText("DyeMerchantCostLabelTotal", GetString( StringTables.Default.LABEL_DYE_MERCHANT_TOTAL_COST ) )
    LabelSetText("CharacterWindowContentsInstructionText", GetString( StringTables.Default.TEXT_DYE_MERCHANT_INSTRUCTION ) )
    LabelSetText("DyeMerchantMarketingSlotDescLabel", GetString( StringTables.Default.TEXT_MARKETING_ITEM_SLOT_TIP ) )
end

function CharacterWindow.InitDyeMerchantButtons()
    LabelSetText("DyeMerchantButtonsCostLabelTotal", GetString( StringTables.Default.LABEL_DYE_MERCHANT_YOUR_MONEY ) )
    ButtonSetText("DyeMerchantButtonsAccept", GetString( StringTables.Default.LABEL_ACCEPT ) )
    ButtonSetText("DyeMerchantButtonsCancel", GetString( StringTables.Default.LABEL_CANCEL ) )
end

function CharacterWindow.HideDyeMerchant()
    if( CharacterWindow.mode == CharacterWindow.MODE_DYE_MERCHANT )
    then
        CharacterWindow.Hide()
    end
end

function CharacterWindow.UpdateMode( mode )
    if( mode )
    then
        local oldMode = CharacterWindow.mode
        CharacterWindow.mode = mode
        
        if( oldMode == CharacterWindow.MODE_ITEM_APPEARANCE )
        then
            CharacterWindow.UpdateItemAppearanceMode()
        end
        
        if( mode == CharacterWindow.MODE_NORMAL )
        then
            CharacterWindow.dyeColors = nil

            if( not g_characterWindowOldX or g_characterWindowOldX > 575 )
            then
                g_characterWindowOldX = 575
                g_characterWindowOldY = 760
            end
            WindowSetDimensions( "CharacterWindow", g_characterWindowOldX, g_characterWindowOldY )
            g_characterWindowOldX = nil
            g_characterWindowOldY = nil
            
            if( CharacterWindow.selectedDyeSlotName )
            then
                CharacterWindow.UnHighlightSlot( CharacterWindow.selectedDyeSlotName )
                CharacterWindow.selectedDyeSlotName = nil
            end
            
            WindowSetShowing( "CharacterWindowContents", true )
            WindowSetShowing( "CharacterWindowContentsAppearanceMode", true )
            WindowSetShowing( "CharacterWindowBrags", false )
            WindowSetShowing( "CharacterWindowTimeouts", false )

            WindowSetShowing( "CharacterWindowTabs", true )
            
            ButtonSetPressedFlag( "CharacterWindowTabsCharTab", true )
            ButtonSetStayDownFlag( "CharacterWindowTabsCharTab", true )
            ButtonSetPressedFlag( "CharacterWindowTabsBragsTab", false )
            ButtonSetStayDownFlag( "CharacterWindowTabsBragsTab", false )
            ButtonSetPressedFlag( "CharacterWindowTabsTimeoutTab", false )
            ButtonSetStayDownFlag( "CharacterWindowTabsTimeoutTab", false )
            
        elseif( mode == CharacterWindow.MODE_DYE_MERCHANT )
        then
            WindowSetShowing( "CharacterWindowContents", true )
            WindowSetShowing( "CharacterWindowContentsAppearanceMode", false )
            WindowSetShowing( "CharacterWindowBrags", false )
            WindowSetShowing( "CharacterWindowTimeouts", false )

            WindowSetShowing( "CharacterWindowTabs", false )
        
            CharacterWindow.primaryColor = -1
            CharacterWindow.secondaryColor = -1
            CharacterWindow.dyeColors = GetDyeMerchantData()
            CharacterWindow.dyeColorsLookUp = {}
            local bleachId = nil
            for index = 1, CharacterWindow.dyeColors.numColors
            do
                if( CharacterWindow.dyeColors[index].paletteIndex == 0 )
                then
                    bleachId = CharacterWindow.dyeColors[index].id
                end
                
                CharacterWindow.dyeColorsLookUp[ CharacterWindow.dyeColors[index].paletteIndex ] =  CharacterWindow.dyeColors[index]
            end
            
            ColorPickerCreateWithColorTable("DyeMerchantColorPicker", CharacterWindow.dyeColors, 5, 10, 10)
            if( bleachId )
            then
                local _, _, _, _, bleachX, bleachY = ColorPickerGetColorById( "DyeMerchantColorPicker", bleachId )
                local x, y = WindowGetOffsetFromParent( "DyeMerchantColorPicker" )
                WindowSetOffsetFromParent("DyeMerchantBleachSwatch", bleachX + x - 3, bleachY + y - 3)
            end
            
            WindowSetShowing( "DyeMerchantBleachSwatch", bleachId ~= nil )
            
            
            -- Set up anything else
            CharacterWindow.dyeAll = false
            ButtonSetCheckButtonFlag("DyeMerchantDyeAll", CharacterWindow.dyeAll )
            ButtonSetPressedFlag("DyeMerchantDyeAll", CharacterWindow.dyeAll )
            
            local x, y = WindowGetDimensions( "CharacterWindow" )
            local x2, _ = WindowGetDimensions( "DyeMerchant" )
            local _, y2 = WindowGetDimensions( "DyeMerchantButtons" )
            if( x > 575 )
            then
                x = 575
                y = 760
            end
            
            WindowSetDimensions( "CharacterWindow", x + x2, y + y2 )
            g_characterWindowOldX = x
            g_characterWindowOldY = y
            
            -- Show the Dye merchant window
            EA_Window_InteractionBase.Hide()
            WindowSetShowing("DyeMerchantPrimary", false)
            WindowSetShowing("DyeMerchantSecondary", false)
            WindowSetShowing("DyeMerchantPrimarySecondary", false)
            MoneyFrame.FormatMoney ("DyeMerchantTotalCost", 0, false)
            MoneyFrame.FormatMoney ("DyeMerchantSingleCost", 0, false)
            MoneyFrame.FormatMoney ("DyeMerchantButtonsPlayerMoney", GameData.Player.money, false)
            WindowSetShowing( "DyeMerchantSingleCost", false )
            
        elseif( mode == CharacterWindow.MODE_BRAGS )
        then

            WindowSetShowing( "CharacterWindowContents", false )
            WindowSetShowing( "CharacterWindowBrags", true )
            WindowSetShowing( "CharacterWindowTimeouts", false )

            WindowSetShowing( "CharacterWindowTabs", true )
            
            ButtonSetPressedFlag( "CharacterWindowTabsCharTab", false )
            ButtonSetStayDownFlag( "CharacterWindowTabsCharTab", false )
            ButtonSetPressedFlag( "CharacterWindowTabsBragsTab", true )
            ButtonSetStayDownFlag( "CharacterWindowTabsBragsTab", true )
            ButtonSetPressedFlag( "CharacterWindowTabsTimeoutTab", false )
            ButtonSetStayDownFlag( "CharacterWindowTabsTimeoutTab", false )
        elseif( mode == CharacterWindow.MODE_TIMEOUTS )
        then

            WindowSetShowing( "CharacterWindowContents", false )
            WindowSetShowing( "CharacterWindowBrags", false )
            WindowSetShowing( "CharacterWindowTimeouts", true )

            WindowSetShowing( "CharacterWindowTabs", true )

            ButtonSetPressedFlag( "CharacterWindowTabsCharTab", false )
            ButtonSetStayDownFlag( "CharacterWindowTabsCharTab", false )
            ButtonSetPressedFlag( "CharacterWindowTabsBragsTab", false )
            ButtonSetStayDownFlag( "CharacterWindowTabsBragsTab", false )
            ButtonSetPressedFlag( "CharacterWindowTabsTimeoutTab", true )
            ButtonSetStayDownFlag( "CharacterWindowTabsTimeoutTab", true )
        elseif( mode == CharacterWindow.MODE_ITEM_APPEARANCE )
        then
            CharacterWindow.UpdateItemAppearanceMode()
        end
        
        local inDyeMode = mode == CharacterWindow.MODE_DYE_MERCHANT
        
        -- Show/Hide the Dye merchant window
        if( DoesWindowExist( "DyeMerchant" ) and DoesWindowExist( "DyeMerchantButtons" ) )
        then
            WindowSetShowing( "DyeMerchant", inDyeMode )
            WindowSetShowing( "DyeMerchantButtons", inDyeMode )
        end
        WindowSetShowing( "CharacterWindowContentsInstruction", inDyeMode )
        WindowSetShowing( "CharacterWindowContentsStatCombobox", not inDyeMode )
        WindowSetShowing( "CharacterWindowContentsComboboxBG", not inDyeMode )
    end
end

function CharacterWindow.UpdateMoney()
    if( CharacterWindow.mode == CharacterWindow.MODE_DYE_MERCHANT )
    then
        MoneyFrame.FormatMoney ("DyeMerchantButtonsPlayerMoney", GameData.Player.money, false)
    end
end

function CharacterWindow.OnMouseOverColorPicker( r, g, b, id )
    if( CharacterWindow.dyeColors )
    then
        -- Make a tool tip here
        local color = CharacterWindow.dyeColors[ GetIndexIntoDyeColors( id ) ]
        if( CharacterWindow.mouseOverColor ~= color )
        then
            local dyeName
            if( color == nil )
            then
                dyeName = L""
            elseif( color.paletteIndex == 0 ) -- bleach!
            then
                dyeName = GetString( StringTables.Default.TOOL_TIP_DYE_MERCHANT_BLEACH )
            else
                dyeName = GetDyeNameString( color.paletteIndex )
            end

            LabelSetText( "DyeMerchantCurrentColorLabel", dyeName )
            
            if( color )
            then
                MoneyFrame.FormatMoney ("DyeMerchantSingleCost", color.cost, false)
            end
            
            WindowSetShowing( "DyeMerchantSingleCost", color ~= nil )
            
            CharacterWindow.mouseOverColor = color
        end
    end
end

function CharacterWindow.OnMouseOverColorPickerEnd()
    LabelSetText( "DyeMerchantCurrentColorLabel", L"" )
    WindowSetShowing( "DyeMerchantSingleCost", false )
    CharacterWindow.mouseOverColor = nil
end

function CharacterWindow.UpdateDyeTotalCost()
    local cost = 0
    local function GetDyeCost( dyeIndex )
        if( dyeIndex > -1 )
        then
            return CharacterWindow.dyeColorsLookUp[dyeIndex].cost
        end
        
        return 0
    end
    
    local aCost = GetDyeCost( CharacterWindow.primaryColor )
    local bCost = GetDyeCost( CharacterWindow.secondaryColor )
    if( CharacterWindow.dyeAll )
    then
        local numDyedA, numDyedB = GetNumDyedItems()
        cost = numDyedA * aCost + numDyedB * bCost
    else
        cost = aCost + bCost
    end
    
    MoneyFrame.FormatMoney ("DyeMerchantTotalCost", cost, false)
end

function CharacterWindow.PreviewDyes()

    if( CharacterWindow.dyeAll )
    then
        DyeMerchantPreviewAll( CharacterWindow.primaryColor, CharacterWindow.secondaryColor )
    elseif( CharacterWindow.selectedDyeSlotName )
    then
        DyeMerchantPreview( GameData.ItemLocs.EQUIPPED, WindowGetId( CharacterWindow.selectedDyeSlotName ), CharacterWindow.primaryColor, CharacterWindow.secondaryColor )
    end
    
    -- Update Money
    CharacterWindow.UpdateDyeTotalCost()
end

function CharacterWindow.OnColorPickerLButtonUp( flags, x, y )
    local color = ColorPickerGetColorAtPoint( "DyeMerchantColorPicker", x, y )
    local oldPrimary = CharacterWindow.primaryColor
    if( color )
    then
        local newColorIndex = CharacterWindow.dyeColors[ GetIndexIntoDyeColors( color.id ) ].paletteIndex
        if( newColorIndex == CharacterWindow.primaryColor )
        then
            newColorIndex = -1
        end
        
        CharacterWindow.primaryColor = newColorIndex
    else
        CharacterWindow.primaryColor = -1
    end
    
    if( CharacterWindow.primaryColor ~= -1 )
    then
        local selectedColorName = "DyeMerchantPrimary"
        local unselectedColorName = "DyeMerchantPrimarySecondary"
        if( CharacterWindow.primaryColor == CharacterWindow.secondaryColor )
        then
            selectedColorName = "DyeMerchantPrimarySecondary"
            unselectedColorName = "DyeMerchantPrimary"
            WindowSetShowing("DyeMerchantSecondary", false)
        elseif( CharacterWindow.secondaryColor ~= -1 )
        then
            WindowSetShowing("DyeMerchantSecondary", true)
        end
        
        local x, y = WindowGetOffsetFromParent( "DyeMerchantColorPicker" )
        WindowSetOffsetFromParent(selectedColorName, color.x + x - 7, color.y + y - 7)
        WindowSetOffsetFromParent(unselectedColorName, color.x + x - 7, color.y + y - 7)

        WindowSetShowing(selectedColorName, true)
        WindowSetShowing(unselectedColorName, false)
    else
        local selectedColorName = "DyeMerchantPrimary"
        if( oldPrimary ~= -1 and oldPrimary == CharacterWindow.secondaryColor )
        then
            selectedColorName = "DyeMerchantPrimarySecondary"
            WindowSetShowing("DyeMerchantSecondary", CharacterWindow.secondaryColor ~= -1)
        end
        
        WindowSetShowing(selectedColorName, false)
    end
    
    CharacterWindow.PreviewDyes()
end

function CharacterWindow.OnColorPickerRButtonUp( flags, x, y )
    local color = ColorPickerGetColorAtPoint( "DyeMerchantColorPicker", x, y )
    local oldSecondary = CharacterWindow.secondaryColor
    if( color )
    then
        local newColorIndex = CharacterWindow.dyeColors[ GetIndexIntoDyeColors( color.id ) ].paletteIndex
        if( newColorIndex == CharacterWindow.secondaryColor )
        then
            newColorIndex = -1
        end
        
        CharacterWindow.secondaryColor = newColorIndex
    else
        CharacterWindow.secondaryColor = -1
    end
    
    if( CharacterWindow.secondaryColor ~= -1 )
    then
        local selectedColorName = "DyeMerchantSecondary"
        local unselectedColorName = "DyeMerchantPrimarySecondary"
        if( CharacterWindow.primaryColor == CharacterWindow.secondaryColor )
        then
            selectedColorName = "DyeMerchantPrimarySecondary"
            unselectedColorName = "DyeMerchantSecondary"
            WindowSetShowing("DyeMerchantPrimary", false)
        elseif( CharacterWindow.primaryColor ~= -1 )
        then
            WindowSetShowing("DyeMerchantPrimary", true)
        end
        
        local x, y = WindowGetOffsetFromParent( "DyeMerchantColorPicker" )
        WindowSetOffsetFromParent(selectedColorName, color.x + x - 7, color.y + y - 7)
        WindowSetOffsetFromParent(unselectedColorName, color.x + x - 7, color.y + y - 7)

        WindowSetShowing(selectedColorName, true)
        WindowSetShowing(unselectedColorName, false)
    else
        local selectedColorName = "DyeMerchantSecondary"
        if( oldSecondary ~= -1 and oldSecondary == CharacterWindow.primaryColor )
        then
            selectedColorName = "DyeMerchantPrimarySecondary"
            WindowSetShowing("DyeMerchantPrimary", CharacterWindow.primaryColor ~= -1)
        end
        
        WindowSetShowing(selectedColorName, false)
    end
    
    CharacterWindow.PreviewDyes()
end

function CharacterWindow.OnAcceptDye()

    if( CharacterWindow.primaryColor == -1 )
    then
        GameData.DyeMerchant.tintA =  -1
    else
        GameData.DyeMerchant.tintA = CharacterWindow.dyeColorsLookUp[ CharacterWindow.primaryColor ].dataIndex
    end
    
    if( CharacterWindow.secondaryColor == -1 )
    then
        GameData.DyeMerchant.tintB =  -1
    else
        GameData.DyeMerchant.tintB = CharacterWindow.dyeColorsLookUp[ CharacterWindow.secondaryColor ].dataIndex
    end
    
    if( CharacterWindow.dyeAll )
    then
        BroadcastEvent( SystemData.Events.INTERACT_DYE_MERCHANT_DYE_ALL )
        CharacterWindow.pendingDyePreview = true
    elseif( CharacterWindow.selectedDyeSlotName )
    then
        GameData.DyeMerchant.slotNum = WindowGetId( CharacterWindow.selectedDyeSlotName )
        BroadcastEvent( SystemData.Events.INTERACT_DYE_MERCHANT_DYE_SINGLE )
    end
    
    if( CharacterWindow.marketItemData ~= nil ) 
    then
        -- 
        DialogManager.MakeTwoButtonDialog( GetString(StringTables.Default.TEXT_MARKETING_ITEM_CONFIRM), 
                                                   GetString(StringTables.Default.LABEL_YES), CharacterWindow.ApplyRewardItem, 
                                                   GetString(StringTables.Default.LABEL_NO) )
        return
    end
        
    
end

function CharacterWindow.OnCancelDye()
    CharacterWindow.HideDyeMerchant()
end

function CharacterWindow.OnDyeAll()
    if( CharacterWindow.dyeAll )
    then
        RevertAllDyePreview()
        CharacterWindow.pendingDyePreview = true
    end
    
    local toggleChecked = not CharacterWindow.dyeAll
    ButtonSetCheckButtonFlag("DyeMerchantDyeAll", toggleChecked )
    ButtonSetPressedFlag("DyeMerchantDyeAll", toggleChecked )
    CharacterWindow.dyeAll = toggleChecked
    
    if( CharacterWindow.dyeAll )
    then
        ShowAllItemsAndHideHeraldry()
        -- Un highlight any old selected slot
        local oldSelectedSlotName = CharacterWindow.selectedDyeSlotName
        if( oldSelectedSlotName )
        then
            CharacterWindow.UnHighlightSlot( oldSelectedSlotName )
            CharacterWindow.selectedDyeSlotName = nil
        end
    end    
    
    if( not CharacterWindow.pendingDyePreview )
    then
        CharacterWindow.PreviewDyes()
    end
end


