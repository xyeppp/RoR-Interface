
EA_Window_OpenPartyLootRollOptions = {}
EA_Window_OpenPartyLootRollOptions.Settings = {}

local PARENT_WINDOW = "EA_Window_OpenPartyLootRollOptions"

local ComboBoxes = {
    { windowName = "UsableEquipment", varName = "usableEquipment", tooltip = GetStringFromTable( "SocialStrings", StringTables.Social.AUTO_ROLL_OPTION_USABLE_EQUIPMENT_TOOLTIP ) },
    { windowName = "UnusableEquipment", varName = "unusableEquipment", tooltip = GetStringFromTable( "SocialStrings", StringTables.Social.AUTO_ROLL_OPTION_UNUSABLE_EQUIPMENT_TOOLTIP ) },
    { windowName = "Crafting", varName = "crafting" },
    { windowName = "Currency", varName = "currency", tooltip = GetStringFromTable( "SocialStrings", StringTables.Social.AUTO_ROLL_OPTION_CURRENCY_TOOLTIP ) },
    { windowName = "Potions", varName = "potion" },
    { windowName = "Talismans", varName = "talisman" },
    { windowName = "Event", varName = "event" },
}
local ComboBoxIndexToRollType = { GameData.LootRoll.INVALID, GameData.LootRoll.PASS, GameData.LootRoll.GREED, GameData.LootRoll.NEED }
local RollTypeToComboBoxIndex = {
    [GameData.LootRoll.INVALID] = 1,
    [GameData.LootRoll.PASS]    = 2,
    [GameData.LootRoll.GREED]   = 3,
    [GameData.LootRoll.NEED]    = 4
}
local ComboBoxIdToRarity = { SystemData.ItemRarity.COMMON, SystemData.ItemRarity.UNCOMMON, SystemData.ItemRarity.RARE, SystemData.ItemRarity.VERY_RARE, SystemData.ItemRarity.ARTIFACT }

local function PrepSavedData()
    local settings = EA_Window_OpenPartyLootRollOptions.Settings
    for _, autoRollCategory in ipairs( ComboBoxes )
    do
        if type( settings[autoRollCategory.varName] ) ~= "table"
        then
            settings[autoRollCategory.varName] = {}
        end
        for _, rarity in ipairs( ComboBoxIdToRarity )
        do
            settings[autoRollCategory.varName][rarity] = settings[autoRollCategory.varName][rarity] or GameData.LootRoll.INVALID
        end
    end
    settings.trash = settings.trash or GameData.LootRoll.INVALID
    
    -- No Need option for unusable gear!
    for key, choice in pairs( settings.unusableEquipment )
    do
        if choice == GameData.LootRoll.NEED
        then
            settings.unusableEquipment[key] = GameData.LootRoll.INVALID
        end
    end
end

function EA_Window_OpenPartyLootRollOptions.Initialize()
    PrepSavedData()
    
    LabelSetText( PARENT_WINDOW.."HelpText", GetStringFromTable( "SocialStrings", StringTables.Social.AUTO_ROLL_HELP ) )
    
    -- Rarities
    LabelSetText( PARENT_WINDOW.."RarityLabelCommon", GameDefs.ItemRarity[SystemData.ItemRarity.COMMON].desc )
    DefaultColor.LabelSetTextColor( PARENT_WINDOW.."RarityLabelCommon", GameDefs.ItemRarity[SystemData.ItemRarity.COMMON].color )
    LabelSetText( PARENT_WINDOW.."RarityLabelUncommon", GameDefs.ItemRarity[SystemData.ItemRarity.UNCOMMON].desc )
    DefaultColor.LabelSetTextColor( PARENT_WINDOW.."RarityLabelUncommon", GameDefs.ItemRarity[SystemData.ItemRarity.UNCOMMON].color )
    LabelSetText( PARENT_WINDOW.."RarityLabelRare", GameDefs.ItemRarity[SystemData.ItemRarity.RARE].desc )
    DefaultColor.LabelSetTextColor( PARENT_WINDOW.."RarityLabelRare", GameDefs.ItemRarity[SystemData.ItemRarity.RARE].color )
    LabelSetText( PARENT_WINDOW.."RarityLabelVeryRare", GameDefs.ItemRarity[SystemData.ItemRarity.VERY_RARE].desc )
    DefaultColor.LabelSetTextColor( PARENT_WINDOW.."RarityLabelVeryRare", GameDefs.ItemRarity[SystemData.ItemRarity.VERY_RARE].color )
    LabelSetText( PARENT_WINDOW.."RarityLabelArtifact", GameDefs.ItemRarity[SystemData.ItemRarity.ARTIFACT].desc )
    DefaultColor.LabelSetTextColor( PARENT_WINDOW.."RarityLabelArtifact", GameDefs.ItemRarity[SystemData.ItemRarity.ARTIFACT].color )
    
    -- Categories
    LabelSetText( PARENT_WINDOW.."UsableEquipmentTitle", GetStringFromTable( "SocialStrings", StringTables.Social.AUTO_ROLL_OPTION_USABLE_EQUIPMENT ) )
    LabelSetText( PARENT_WINDOW.."UnusableEquipmentTitle", GetStringFromTable( "SocialStrings", StringTables.Social.AUTO_ROLL_OPTION_UNUSABLE_EQUIPMENT ) )
    LabelSetText( PARENT_WINDOW.."CraftingTitle", GetStringFromTable( "SocialStrings", StringTables.Social.AUTO_ROLL_OPTION_CRAFTING ) )
    LabelSetText( PARENT_WINDOW.."CurrencyTitle", GetStringFromTable( "SocialStrings", StringTables.Social.AUTO_ROLL_OPTION_CURRENCY ) )
    LabelSetText( PARENT_WINDOW.."PotionsTitle", GetStringFromTable( "SocialStrings", StringTables.Social.AUTO_ROLL_OPTION_POTIONS ) )
    LabelSetText( PARENT_WINDOW.."TalismansTitle", GetStringFromTable( "SocialStrings", StringTables.Social.AUTO_ROLL_OPTION_TALISMANS ) )
    LabelSetText( PARENT_WINDOW.."EventTitle", GetStringFromTable( "SocialStrings", StringTables.Social.AUTO_ROLL_OPTION_EVENT ) )
    LabelSetText( PARENT_WINDOW.."TrashTitle", GetStringFromTable( "SocialStrings", StringTables.Social.AUTO_ROLL_OPTION_TRASH ) )
    DefaultColor.LabelSetTextColor( PARENT_WINDOW.."TrashTitle", GameDefs.ItemRarity[SystemData.ItemRarity.UTILITY].color )
    
    local settings = EA_Window_OpenPartyLootRollOptions.Settings
    for rowNum, autoRollCategory in ipairs( ComboBoxes )
    do
        local color = DataUtils.GetAlternatingRowColorGreyOnGrey( math.mod( rowNum, 2 ) )
        DefaultColor.SetWindowTint( PARENT_WINDOW..autoRollCategory.windowName.."Background", color )
    
        for i, rarity in ipairs( ComboBoxIdToRarity )
        do
            local fullName = PARENT_WINDOW..autoRollCategory.windowName.."Combo"..i
            ComboBoxAddMenuItem( fullName, GetStringFromTable( "SocialStrings", StringTables.Social.AUTO_ROLL_OPTION_ASK_ME ) )
            ComboBoxAddMenuItem( fullName, GetString( StringTables.Default.LABEL_PASS ) )
            ComboBoxAddMenuItem( fullName, GetString( StringTables.Default.LABEL_GREED ) )
            if autoRollCategory.varName ~= "unusableEquipment"
            then
                ComboBoxAddMenuItem( fullName, GetString( StringTables.Default.LABEL_NEED ) )
            end

            ComboBoxSetSelectedMenuItem( fullName, RollTypeToComboBoxIndex[ settings[autoRollCategory.varName][rarity] ] )
        end
    end
    
    -- trash
    local fullName = PARENT_WINDOW.."TrashCombo"
    ComboBoxAddMenuItem( fullName, GetStringFromTable( "SocialStrings", StringTables.Social.AUTO_ROLL_OPTION_ASK_ME ) )
    ComboBoxAddMenuItem( fullName, GetString( StringTables.Default.LABEL_PASS ) )
    ComboBoxAddMenuItem( fullName, GetString( StringTables.Default.LABEL_GREED ) )
    ComboBoxAddMenuItem( fullName, GetString( StringTables.Default.LABEL_NEED ) )
    ComboBoxSetSelectedMenuItem( fullName, RollTypeToComboBoxIndex[ settings.trash ] )
end

function EA_Window_OpenPartyLootRollOptions.OnMouseOverRowTitle()
    local rowWindow = WindowGetParent( SystemData.ActiveWindow.name )
    local rowId = WindowGetId( rowWindow )
    local tooltipText = ComboBoxes[rowId].tooltip
    if tooltipText
    then
    	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, tooltipText )
        Tooltips.AnchorTooltip( Tooltips.ANCHOR_CURSOR )
    end
end

function EA_Window_OpenPartyLootRollOptions.OnOptionChange( choice )
    local settings = EA_Window_OpenPartyLootRollOptions.Settings
    local comboId = WindowGetId( SystemData.ActiveWindow.name )
    
    if comboId == 0 -- trash option
    then
        settings.trash = ComboBoxIndexToRollType[choice]
        return
    end
    
    local rowId = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
    local rarityTable = settings[ComboBoxes[rowId].varName]
    
    rarityTable[ComboBoxIdToRarity[comboId]] = ComboBoxIndexToRollType[choice]
end

function EA_Window_OpenPartyLootRollOptions.OnRClickComboBox()
    local settings = EA_Window_OpenPartyLootRollOptions.Settings
    local comboId = WindowGetId( SystemData.ActiveWindow.name )
    if comboId == 0 -- trash option
    then
        return
    end
    local rowWindow = WindowGetParent( SystemData.ActiveWindow.name )
    local rowId = WindowGetId( rowWindow )
    local rarityTable = settings[ComboBoxes[rowId].varName]
    
    local function CopyLeft()
        local choice = rarityTable[ComboBoxIdToRarity[comboId]]
        for i = comboId - 1, 1, -1
        do
            rarityTable[ComboBoxIdToRarity[i]] = choice
            ComboBoxSetSelectedMenuItem( rowWindow.."Combo"..i, RollTypeToComboBoxIndex[ choice ] )
        end
    end
    local function CopyRight()
        local choice = rarityTable[ComboBoxIdToRarity[comboId]]
        local numRarities = #ComboBoxIdToRarity
        for i = comboId + 1, numRarities
        do
            rarityTable[ComboBoxIdToRarity[i]] = choice
            ComboBoxSetSelectedMenuItem( rowWindow.."Combo"..i, RollTypeToComboBoxIndex[ choice ] )
        end
    end
    
    EA_Window_ContextMenu.CreateContextMenu( SystemData.ActiveWindow.name, EA_Window_ContextMenu.CONTEXT_MENU_1 )
    EA_Window_ContextMenu.AddMenuItem(  GetStringFromTable( "SocialStrings", StringTables.Social.AUTO_ROLL_COPY_LEFT ),
                                        CopyLeft,
                                        not ComboBoxIdToRarity[comboId - 1],
                                        true, EA_Window_ContextMenu.CONTEXT_MENU_1 )
    EA_Window_ContextMenu.AddMenuItem(  GetStringFromTable( "SocialStrings", StringTables.Social.AUTO_ROLL_COPY_RIGHT ),
                                        CopyRight,
                                        not ComboBoxIdToRarity[comboId + 1],
                                        true, EA_Window_ContextMenu.CONTEXT_MENU_1 )
    EA_Window_ContextMenu.Finalize()
end