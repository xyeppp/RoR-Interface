EA_Window_InteractionAltar =
{
}

-- Copied from ActionButton so the InteractionWindow module doesn't need to depend on the ActionBar module
EA_Window_InteractionAltar.COOLDOWN_GRANULARITY            = 0.1
EA_Window_InteractionAltar.FRACTIONAL_COOLDOWN_BEGIN       = 2.5
EA_Window_InteractionAltar.IGNORE_COOLDOWN_DELTA_THRESHOLD = 0.7

EA_Window_InteractionAltar.donationType = 0
EA_Window_InteractionAltar.itemName = L""
EA_Window_InteractionAltar.donationsPerCharge = 0
EA_Window_InteractionAltar.cooldownTime = 0
EA_Window_InteractionAltar.cooldownMax = 0
EA_Window_InteractionAltar.numCharges = 0
EA_Window_InteractionAltar.maxCharges = 0
EA_Window_InteractionAltar.numItemsInBackpack = 0
EA_Window_InteractionAltar.isReadOnly = false


----------------------------------------------------------------
-- EA_Window_InteractionAltar Functions
----------------------------------------------------------------

-- OnInitialize: Set localized strings and register event handlers
function EA_Window_InteractionAltar.OnInitialize()
   WindowRegisterEventHandler( "EA_Window_InteractionAltar", SystemData.Events.INTERACT_DONE,                    "EA_Window_InteractionAltar.Hide" )
   WindowRegisterEventHandler( "EA_Window_InteractionAltar", SystemData.Events.INTERACT_DIVINEFAVORALTAR_OPEN,   "EA_Window_InteractionAltar.Show" )
   WindowRegisterEventHandler( "EA_Window_InteractionAltar", SystemData.Events.INTERACT_DIVINEFAVORALTAR_UPDATE, "EA_Window_InteractionAltar.UpdatedInfo" )
   WindowRegisterEventHandler( "EA_Window_InteractionAltar", SystemData.Events.PLAYER_INVENTORY_SLOT_UPDATED,    "EA_Window_InteractionAltar.UpdatedInventory" )
   
   LabelSetText( "EA_Window_InteractionAltarTitleBarText", GetString( StringTables.Default.LABEL_DIVINE_FAVOR_ALTAR_TITLEBAR ) )
   
   ButtonSetText( "EA_Window_InteractionAltarActivateButton", GetString( StringTables.Default.LABEL_DIVINE_FAVOR_ALTAR_ACTIVATE_BUTTON ) )
   ButtonSetText( "EA_Window_InteractionAltarDonateButton", GetString( StringTables.Default.LABEL_DIVINE_FAVOR_ALTAR_DONATE_BUTTON ) )
   ButtonSetText( "EA_Window_InteractionAltarCloseButton", GetString( StringTables.Default.LABEL_CLOSE ) )
   
   DefaultColor.SetWindowTint( "EA_Window_InteractionAltarAbilityCooldown", DefaultColor.ActionCooldown )
end

-- CanActivate: Based on the cooldown, current number of charges, and read only state, determine if we can currently activate the altar
function EA_Window_InteractionAltar.CanActivate()
    return ( EA_Window_InteractionAltar.numCharges >= 1 ) and ( EA_Window_InteractionAltar.cooldownTime == 0 ) and not EA_Window_InteractionAltar.isReadOnly
end

-- CanDonate: Based on the number of items in inventory and how many charges are in the altar, determine if we can donate any more items
function EA_Window_InteractionAltar.CanDonate()
    return ( EA_Window_InteractionAltar.numCharges < EA_Window_InteractionAltar.maxCharges ) and ( EA_Window_InteractionAltar.numItemsInBackpack > 0 )
end

-- SetCooldownText: Sets an appropriate cooldown string based on the current number of seconds
function EA_Window_InteractionAltar.SetCooldownText()
    local labelTime = L""
    if ( EA_Window_InteractionAltar.cooldownTime < EA_Window_InteractionAltar.FRACTIONAL_COOLDOWN_BEGIN ) then
        labelTime = TimeUtils.FormatRoundedSeconds( EA_Window_InteractionAltar.cooldownTime, EA_Window_InteractionAltar.COOLDOWN_GRANULARITY, true )
    else
        labelTime = TimeUtils.FormatSeconds( EA_Window_InteractionAltar.cooldownTime, true )
    end
            
    LabelSetText( "EA_Window_InteractionAltarAbilityCooldownTimer", labelTime )
end

-- SetBackpackText: Sets an appropriate text for number of items in backpack
function EA_Window_InteractionAltar.SetBackpackText()
    local labelBackpack = L""
    if ( EA_Window_InteractionAltar.numCharges < EA_Window_InteractionAltar.maxCharges ) then
        labelBackpack = GetStringFormat( StringTables.Default.LABEL_DIVINE_FAVOR_ALTAR_AMOUNT_IN_BACKPACK, { EA_Window_InteractionAltar.numItemsInBackpack } )
    else
        labelBackpack = GetString( StringTables.Default.LABEL_DIVINE_FAVOR_ALTAR_FULL )
    end
    
    LabelSetText( "EA_Window_InteractionAltarAmountInBackpack", labelBackpack )
end

-- Show: Causes the window to be shown
function EA_Window_InteractionAltar.Show(altarData)
    -- Parse input data
    EA_Window_InteractionAltar.donationType = altarData.donationType
    EA_Window_InteractionAltar.itemName = altarData.itemName
    EA_Window_InteractionAltar.donationsPerCharge = altarData.donationsPerCharge
    EA_Window_InteractionAltar.cooldownTime = altarData.secondsUntilNextFire
    EA_Window_InteractionAltar.cooldownMax = altarData.actionFireInterval
    EA_Window_InteractionAltar.numCharges = math.floor( altarData.donationsCurrent / altarData.donationsPerCharge )
    EA_Window_InteractionAltar.maxCharges = altarData.maxCharges
    EA_Window_InteractionAltar.numItemsInBackpack = GetItemStackCount( altarData.donationType )
    EA_Window_InteractionAltar.isReadOnly = not GuildWindowTabAdmin.GetGuildCommandPermissionForPlayer( SystemData.GuildPermissons.DIVINEFAVORALTAR_INTERACT )
    
    -- Instruction text
    LabelSetText( "EA_Window_InteractionAltarInstructions", GetStringFormat( StringTables.Default.LABEL_DIVINE_FAVOR_ALTAR_INSTRUCTIONS, { EA_Window_InteractionAltar.donationsPerCharge, EA_Window_InteractionAltar.itemName } ) )
    
    -- Item icon and count
    local itemIconTexture, itemIconX, itemIconY = GetIconData( altarData.itemIcon ) 
    DynamicImageSetTexture( "EA_Window_InteractionAltarItemIcon", itemIconTexture, itemIconX, itemIconY )
    DynamicImageSetTexture( "EA_Window_InteractionAltarItemIconSmall", itemIconTexture, itemIconX, itemIconY )
    LabelSetText( "EA_Window_InteractionAltarItemCount", L""..altarData.donationsCurrent )
    
    -- Ability icon, charge count, arrow images
    local abilityIconTexture, abilityIconX, abilityIconY = GetIconData( altarData.abilityIcon ) 
    DynamicImageSetTexture( "EA_Window_InteractionAltarAbilityIcon", abilityIconTexture, abilityIconX, abilityIconY )
    LabelSetText( "EA_Window_InteractionAltarAbilityCount", L""..EA_Window_InteractionAltar.numCharges )
    LabelSetText( "EA_Window_InteractionAltarChargeText", GetStringFormat( StringTables.Default.LABEL_DIVINE_FAVOR_ALTAR_CHARGE_TEXT, { EA_Window_InteractionAltar.numCharges, EA_Window_InteractionAltar.maxCharges } ) )

    -- Cooldown timer
    if (EA_Window_InteractionAltar.cooldownTime > 0) then
        CooldownDisplaySetCooldown( "EA_Window_InteractionAltarAbilityCooldown", EA_Window_InteractionAltar.cooldownTime, EA_Window_InteractionAltar.cooldownMax )
        EA_Window_InteractionAltar.SetCooldownText()
        WindowSetShowing( "EA_Window_InteractionAltarAbilityCooldown", true )
        WindowSetShowing( "EA_Window_InteractionAltarAbilityCooldownTimer", true )
    else
        WindowSetShowing( "EA_Window_InteractionAltarAbilityCooldown", false )
        WindowSetShowing( "EA_Window_InteractionAltarAbilityCooldownTimer", false )
    end
    
    -- Backpack count and Donate button disabled state
    EA_Window_InteractionAltar.SetBackpackText()
    -- If we're able to donate, then initialize the text box value to the max amount we can donate
    if ( EA_Window_InteractionAltar.CanDonate() ) then
        TextEditBoxSetText( "EA_Window_InteractionAltarDonationEditBox", L""..EA_Window_InteractionAltar.numItemsInBackpack )
    end
    
    -- Activate and Donate buttons
    ButtonSetDisabledFlag( "EA_Window_InteractionAltarActivateButton", not EA_Window_InteractionAltar.CanActivate() )
    ButtonSetDisabledFlag( "EA_Window_InteractionAltarDonateButton", not EA_Window_InteractionAltar.CanDonate() )
    
    WindowSetShowing( "EA_Window_InteractionAltar", true )
end

-- Hide: Causes the window to be hidden
function EA_Window_InteractionAltar.Hide()
    WindowSetShowing( "EA_Window_InteractionAltar", false )
end

-- OnShown: Called when the window has just been shown
function EA_Window_InteractionAltar.OnShown()
    WindowUtils.OnShown( EA_Window_InteractionAltar.Hide, WindowUtils.Cascade.MODE_AUTOMATIC )
end

-- OnHidden: Called when the window has just been hidden
function EA_Window_InteractionAltar.OnHidden()
    WindowUtils.OnHidden()
end

-- UpdatedInfo: Called when the server sends updated altar information
function EA_Window_InteractionAltar.UpdatedInfo(altarData)
    EA_Window_InteractionAltar.cooldownTime = altarData.secondsUntilNextFire
    EA_Window_InteractionAltar.numCharges = math.floor( altarData.donationsCurrent / EA_Window_InteractionAltar.donationsPerCharge )
    
    LabelSetText( "EA_Window_InteractionAltarItemCount", L""..altarData.donationsCurrent )
    LabelSetText( "EA_Window_InteractionAltarAbilityCount", L""..EA_Window_InteractionAltar.numCharges )
    LabelSetText( "EA_Window_InteractionAltarChargeText", GetStringFormat( StringTables.Default.LABEL_DIVINE_FAVOR_ALTAR_CHARGE_TEXT, { EA_Window_InteractionAltar.numCharges, EA_Window_InteractionAltar.maxCharges } ) )
    
    if (EA_Window_InteractionAltar.cooldownTime > 0) then
        CooldownDisplaySetCooldown( "EA_Window_InteractionAltarAbilityCooldown", EA_Window_InteractionAltar.cooldownTime, EA_Window_InteractionAltar.cooldownMax )
        EA_Window_InteractionAltar.SetCooldownText()
        WindowSetShowing( "EA_Window_InteractionAltarAbilityCooldown", true )
        WindowSetShowing( "EA_Window_InteractionAltarAbilityCooldownTimer", true )
    else
        WindowSetShowing( "EA_Window_InteractionAltarAbilityCooldown", false )
        WindowSetShowing( "EA_Window_InteractionAltarAbilityCooldownTimer", false )
    end
    
    EA_Window_InteractionAltar.SetBackpackText()
    
    ButtonSetDisabledFlag( "EA_Window_InteractionAltarActivateButton", not EA_Window_InteractionAltar.CanActivate() )
    ButtonSetDisabledFlag( "EA_Window_InteractionAltarDonateButton", not EA_Window_InteractionAltar.CanDonate() )
end

-- UpdatedInventory: Called when any inventory slot is changed -- could affect our item
function EA_Window_InteractionAltar.UpdatedInventory(altarData)
    if ( WindowGetShowing( "EA_Window_InteractionAltar" ) ) then
        local numItemsInBackpack = GetItemStackCount( EA_Window_InteractionAltar.donationType )
        if ( numItemsInBackpack ~= EA_Window_InteractionAltar.numItemsInBackpack ) then
            EA_Window_InteractionAltar.numItemsInBackpack = numItemsInBackpack
            EA_Window_InteractionAltar.SetBackpackText()
            ButtonSetDisabledFlag( "EA_Window_InteractionAltarDonateButton", not EA_Window_InteractionAltar.CanDonate() )
        end
    end
end

-- OnUpdate: Called every frame
function EA_Window_InteractionAltar.OnUpdate( timePassed )
    if ( EA_Window_InteractionAltar.cooldownTime > 0 ) then
        local oldTime = TimeUtils.FormatRoundedSeconds( EA_Window_InteractionAltar.cooldownTime, EA_Window_InteractionAltar.COOLDOWN_GRANULARITY, false )
        EA_Window_InteractionAltar.cooldownTime = EA_Window_InteractionAltar.cooldownTime - timePassed
        
        if ( EA_Window_InteractionAltar.cooldownTime > 0 ) then
            if ( TimeUtils.FormatRoundedSeconds( EA_Window_InteractionAltar.cooldownTime, EA_Window_InteractionAltar.COOLDOWN_GRANULARITY, false ) < oldTime ) then
                EA_Window_InteractionAltar.SetCooldownText()
            end
        else
            EA_Window_InteractionAltar.cooldownTime = 0
            WindowSetShowing( "EA_Window_InteractionAltarAbilityCooldownTimer", false )
            ButtonSetDisabledFlag( "EA_Window_InteractionAltarActivateButton", not EA_Window_InteractionAltar.CanActivate() )
        end
    end
end

-- DonateAll: Attempt to donate all skulls in your backpack
function EA_Window_InteractionAltar.DonateAll()
    DonateToAltar( EA_Window_InteractionAltar.donationType, EA_Window_InteractionAltar.numItemsInBackpack )
end

-- OnDonate: Called when the donate button is pressed
function EA_Window_InteractionAltar.OnDonate()
    if ( EA_Window_InteractionAltar.CanDonate() ) then
        local amount = tonumber( TextEditBoxGetText( "EA_Window_InteractionAltarDonationEditBox" ) )
        if ( amount > 0 ) then
            if ( amount <= EA_Window_InteractionAltar.numItemsInBackpack ) then
                DonateToAltar( EA_Window_InteractionAltar.donationType, amount )
            else
                local dialogString = GetStringFormat( StringTables.Default.LABEL_DIVINE_FAVOR_ALTAR_NOT_ENOUGH_IN_BACKPACK, { amount, EA_Window_InteractionAltar.numItemsInBackpack, EA_Window_InteractionAltar.itemName } )
                DialogManager.MakeTwoButtonDialog( dialogString,
                                                   GetString( StringTables.Default.LABEL_YES ), EA_Window_InteractionAltar.DonateAll, 
                                                   GetString( StringTables.Default.LABEL_NO ), nil )
            end
        end
    end
end

-- OnActivate: Called when the activate button is pressed
function EA_Window_InteractionAltar.OnActivate()
    if ( EA_Window_InteractionAltar.CanActivate() ) then
        FireAltarAbility()
    end
end

-- OnActivateMouseOver: Called when the mouse is moved over the activate button
function EA_Window_InteractionAltar.OnActivateMouseOver()
    if ( EA_Window_InteractionAltar.isReadOnly ) then
        Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, GetString( StringTables.Default.LABEL_DIVINE_FAVOR_ALTAR_NO_PERMISSION ) )
        Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_BOTTOM )
    end
end
