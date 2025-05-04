-- Variables
SalvagingWindow = {}

SalvagingWindow.windowName = "SalvagingWindow"
SalvagingWindow.numStats = 0

SalvagingWindow.radioButtons = {}
SalvagingWindow.selectedStat = 0
SalvagingWindow.selectedSlot = 0
SalvagingWindow.selectedBackpack = 0
SalvagingWindow.salvagingType = 0

-- Constants
SalvagingWindow.STAT_X_OFFSET = 20
SalvagingWindow.STAT_Y_OFFSET = 30
SalvagingWindow.TITLE_BAR_OFFSET = 40
SalvagingWindow.STAT_RADIO_BUTTON_HEIGHT_OFFSET = SalvagingWindow.TITLE_BAR_OFFSET
SalvagingWindow.WINDOW_BASE_HEIGHT = 170
SalvagingWindow.WINDOW_WIDTH = 350
SalvagingWindow.STAT_CHOICE_HEIGHT = 30

-- Local Functions 
local function UpdateStatRadioButtons()
    for index, windowName in ipairs( SalvagingWindow.radioButtons )
    do
        local buttonName = SalvagingWindow.windowName.."Stat"..index
        --DEBUG(L"Window Id: "..WindowGetId( buttonName ) )
        if ( SalvagingWindow.selectedStat == WindowGetId( buttonName ) )
        then
            --DEBUG(statStringLookUp[SalvagingWindow.selectedStat]..L" Selected")
            ButtonSetPressedFlag( buttonName.."Button", true )
        else
            --DEBUG(L""..StringToWString(SalvagingWindow.windowName.."Stat"..index.."Button"))
            ButtonSetPressedFlag( buttonName.."Button", false )
        end
    end
end

local function AddSalvageStat( stat, statString )
    SalvagingWindow.numStats = SalvagingWindow.numStats + 1

    local buttonWindowName = SalvagingWindow.windowName.."Stat"..SalvagingWindow.numStats
    --DEBUG(L"SalvagingWindow.numStats: "..SalvagingWindow.numStats)
    -- create the window
    CreateWindowFromTemplate( buttonWindowName, "EA_Window_SalvagingRadioButtonTemplate", SalvagingWindow.windowName )
    
    -- Anchor the radio button and set its text + id
    local xOffset = SalvagingWindow.STAT_X_OFFSET
    local yOffset = SalvagingWindow.STAT_Y_OFFSET * SalvagingWindow.numStats + SalvagingWindow.STAT_RADIO_BUTTON_HEIGHT_OFFSET
    WindowAddAnchor( buttonWindowName, "topleft", SalvagingWindow.windowName, "topleft", xOffset, yOffset )
    LabelSetText( buttonWindowName.."Label", statString )
    WindowSetId( buttonWindowName, stat )
    
    SalvagingWindow.radioButtons[SalvagingWindow.numStats] = buttonWindowName
end

local function DestroySalvageStats()
    for index, windowName in ipairs( SalvagingWindow.radioButtons )
    do
        WindowClearAnchors( windowName )
        DestroyWindow( windowName )
    end
    
    SalvagingWindow.radioButtons = {}
    SalvagingWindow.numStats = 0
    SalvagingWindow.selectedStat = 0
    SalvagingWindow.selectedSlot = 0
    SalvagingWindow.selectedBackpack = 0
    SalvagingWindow.salvagingType = 0
end

-- SalvigingWindow Funcitons
function SalvagingWindow.BeginSalvage()
    SetDesiredInteractAction( SystemData.InteractActions.SALVAGE )
end

function SalvagingWindow.EndSalvage()
    if( GetDesiredInteractAction() == SystemData.InteractActions.SALVAGE )
    then
        SetDesiredInteractAction( SystemData.InteractActions.NONE )
    end
end

function SalvagingWindow.Initialize()
    RegisterEventHandler( SystemData.Events.L_BUTTON_DOWN_PROCESSED, "SalvagingWindow.OnLButtonProcessed")
    RegisterEventHandler( SystemData.Events.R_BUTTON_DOWN_PROCESSED, "SalvagingWindow.OnRButtonProcessed")
    LabelSetText(SalvagingWindow.windowName.."TitleBarText", GetString( StringTables.Default.LABEL_SKILL_SALVAGING ) )
    ButtonSetText( SalvagingWindow.windowName.."Accept", GetString( StringTables.Default.LABEL_ACCEPT ) )
    ButtonSetText( SalvagingWindow.windowName.."Cancel", GetString( StringTables.Default.LABEL_CANCEL ) )
end

function SalvagingWindow.Shutdown()
    UnregisterEventHandler( SystemData.Events.L_BUTTON_DOWN_PROCESSED, "SalvagingWindow.OnLButtonProcessed")
    UnregisterEventHandler( SystemData.Events.R_BUTTON_DOWN_PROCESSED, "SalvagingWindow.OnRButtonProcessed")
    DestroySalvageStats()
end

function SalvagingWindow.Show()
    if( WindowGetShowing( SalvagingWindow.windowName ) )
    then
        return
    end
    
    WindowSetShowing( SalvagingWindow.windowName, true)
    
    WindowUtils.AddToOpenList( SalvagingWindow.windowName, SalvagingWindow.Hide, WindowUtils.Cascade.MODE_NONE )

    Sound.Play( Sound.WINDOW_OPEN )
end

function SalvagingWindow.Hide()
    if( not WindowGetShowing( SalvagingWindow.windowName ) )
    then
        return
    end

    WindowSetShowing( SalvagingWindow.windowName, false )
    
    Sound.Play( Sound.WINDOW_CLOSE )
    
    WindowUtils.RemoveFromOpenList( SalvagingWindow.windowName )
end

function SalvagingWindow.IsSalvagableItem( itemData )
	return (itemData.flags[GameData.Item.EITEMFLAG_MAGICAL_SALVAGABLE] == true) -- or (itemData.flags[GameData.Item.EITEMFLAG_MUNDANE_SALVAGABLE]
end

function SalvagingWindow.CurrentlyInSalvageMode()
	return GetDesiredInteractAction() == SystemData.InteractActions.SALVAGE
end

function SalvagingWindow.PlayerHasSufficientSkillToSalvageItem( itemData )
    local difficultyClass = GetSalvagingDifficulty( itemData.iLevel )
    return( difficultyClass ~= GameData.Salvaging.IMPOSSIBLE )
end


-- returns a string telling how easy this item is to salvage, along with the string's con color
-- NOTE: this function does not verify the item is salvagable
function SalvagingWindow.GetSalvagingDifficultyForItem( itemData )
    
    local difficultyClass, difficultyPercent = GetSalvagingDifficulty( itemData.iLevel )
    local difficultyString = CraftingUtils.SalvagingDifficulty[difficultyClass].string
    
	local text = GetStringFormatFromTable( "Default", StringTables.Default.TEXT_SALVAGING_DIFFICULTY_FORMAT_STRING, { difficultyString, L""..difficultyPercent } )
	
	return text, CraftingUtils.SalvagingDifficulty[difficultyClass].color
end



function SalvagingWindow.Salvage( slotNum )
    local backpackType = EA_BackpackUtilsMediator.GetCurrentBackpackType()
    local inventory = EA_BackpackUtilsMediator.GetItemsFromBackpack( backpackType )
    local itemData = inventory[slotNum]    
    if( slotNum == nil or itemData.uniqueID == 0 )
    then
		return
		
	elseif not SalvagingWindow.IsSalvagableItem( itemData )
    then
        TextLogAddEntry( "Chat", SystemData.ChatLogFilters.CRAFTING, GetString( StringTables.Default.TEXT_SALVAGING_ERROR ) )
		Sound.Play( Sound.ACTION_FAILED )
        return

	elseif not SalvagingWindow.PlayerHasSufficientSkillToSalvageItem( itemData )
    then
        TextLogAddEntry( "Chat", SystemData.ChatLogFilters.CRAFTING, GetString( StringTables.Default.TEXT_SALVAGING_FAIL_NOT_ENOUGH_SKILL ) )
		Sound.Play( Sound.ACTION_FAILED )
        return
    end

    -- Get rid the data from the last time we salvaged if we need too
    DestroySalvageStats()

    -- Now that we have the item, set the text and resize appropriately
	LabelSetText(SalvagingWindow.windowName.."ChoiceText", GetStringFormatFromTable( "Default", StringTables.Default.TEXT_CAN_BE_SALVAGED_INTO, { itemData.name } ) )
    local _, choiceHeight = LabelGetTextDimensions( SalvagingWindow.windowName.."ChoiceText" )
    SalvagingWindow.STAT_RADIO_BUTTON_HEIGHT_OFFSET  = SalvagingWindow.TITLE_BAR_OFFSET + choiceHeight

    for index, bonus in ipairs(itemData.bonus)
    do
        if( bonus.type == GameData.BonusTypes.SETBONUS_MAGIC and GetBonusIsSalvagable(itemData.level, bonus.reference) == 1)
        then
            local ref = bonus.reference
            if( CraftingUtils.SalvagingStatStringLookUp[ref] ~= nil )
            then
                --DEBUG(L"Ref: "..ref..L" Label: "..CraftingUtils.GetSalvagingStatString[ref] )
                AddSalvageStat( ref, CraftingUtils.GetSalvagingStatString(ref) )
            end
        end
    end

    SalvagingWindow.selectedSlot = slotNum
    SalvagingWindow.selectedBackpack = backpackType
    if( itemData.flags[GameData.Item.EITEMFLAG_MAGICAL_SALVAGABLE] )
    then
        --DEBUG(L"Magical!")
        SalvagingWindow.salvagingType = GameData.SalvagingTypes.MAGICAL
    else
        --DEBUG(L"Mundane!")
        SalvagingWindow.salvagingType = GameData.SalvagingTypes.MUNDANE
    end

    -- as long as the item is salvagable we show stats, even if there is only 1 stat to salvage
    if( SalvagingWindow.numStats > 0 and itemData.rarity ~= SystemData.ItemRarity.COMMON )
    then
        -- for the first stat added make sure to set its radio button as selected
        SalvagingWindow.selectedStat = WindowGetId( SalvagingWindow.radioButtons[1] )
        UpdateStatRadioButtons()
    
        -- resize the window
        SalvagingWindow.ResizeOnSelf()
        SalvagingWindow.EndSalvage()
        SalvagingWindow.Show()
    else
        --DEBUG(L"SalvagingWindow.selectedSlot: "..SalvagingWindow.selectedSlot..L" SalvagingWindow.salvagingType: "..SalvagingWindow.salvagingType..L" SalvagingWindow.selectedStat: "..SalvagingWindow.selectedStat)
        -- if there is a stat on the item to salvage then send the stat num
        if( SalvagingWindow.radioButtons[1] ~= nil )
        then
            SalvagingWindow.selectedStat = WindowGetId( SalvagingWindow.radioButtons[1] )
        end
        
        -- Set the action bar text if the salvaing was sent
        if( RequestSalvageItem( SalvagingWindow.selectedSlot, SalvagingWindow.selectedBackpack, SalvagingWindow.salvagingType, SalvagingWindow.selectedStat ) )
        then
            LayerTimerWindow.SetActionName( GetString( StringTables.Default.LABEL_SKILL_SALVAGING ), true )
        end
    end
end

function SalvagingWindow.ResizeOnSelf()
    local height = SalvagingWindow.WINDOW_BASE_HEIGHT + ( SalvagingWindow.STAT_CHOICE_HEIGHT * SalvagingWindow.numStats )
    WindowSetDimensions( SalvagingWindow.windowName, SalvagingWindow.WINDOW_WIDTH, height )
end

function SalvagingWindow.OnRButtonUp()
    EA_Window_ContextMenu.CreateDefaultContextMenu( SalvagingWindow.windowName )
end

function SalvagingWindow.OnStatLButtonUp()
    SalvagingWindow.selectedStat = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
    --DEBUG(L"SalvagingWindow.selectedStat: "..SalvagingWindow.selectedStat)
    UpdateStatRadioButtons()
end

function SalvagingWindow.OnRButtonProcessed()
    SalvagingWindow.EndSalvage()
end

function SalvagingWindow.OnLButtonProcessed()

    local winName = EA_BackpackUtilsMediator.GetBackpackWindowName()
    if winName ~= "" and string.sub(SystemData.MouseOverWindow.name,1,string.len(winName))==winName
    then
        return
    end
    
    SalvagingWindow.EndSalvage()
end

function SalvagingWindow.OnAcceptLButtonUp()
    if( RequestSalvageItem( SalvagingWindow.selectedSlot, SalvagingWindow.selectedBackpack, SalvagingWindow.salvagingType, SalvagingWindow.selectedStat ) )
    then
        LayerTimerWindow.SetActionName( GetString( StringTables.Default.LABEL_SKILL_SALVAGING ), true )
    end
    SalvagingWindow.Hide()
end

function SalvagingWindow.OnCancelLButtonUp()
    SalvagingWindow.EndSalvage()
	DestroySalvageStats()
	SalvagingWindow.Hide()
end
