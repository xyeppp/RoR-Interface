----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

HeraldryEditor = {}

HeraldryEditor.NUM_ROWS = 3
HeraldryEditor.NUM_COLS = 4
HeraldryEditor.isColorPickerShown = false
HeraldryEditor.ComboBoxBestOptions = {}		-- These filter IDs should match the ones in war_interface::LuaGetHeraldryBestOptions
--HeraldryEditor.ComboBoxBestOptions[1] = {label = GetGuildString(StringTables.Guild.COMBOBOX_HERALD_BEST_CHOICES_ALL),			filterID = 100}

HeraldryEditor.OFFSET_DESTRUCTION = 20
HeraldryEditor.OFFSET_ORDER = 30

HeraldryEditor.ComboBoxBestOptions[HeraldryEditor.OFFSET_DESTRUCTION]	= {label = GetGuildString(StringTables.Guild.COMBOBOX_HERALD_BEST_CHOICES_ALL),			filterID = 20}
HeraldryEditor.ComboBoxBestOptions[HeraldryEditor.OFFSET_DESTRUCTION+1] = {label = GetGuildString(StringTables.Guild.COMBOBOX_HERALD_BEST_CHOICES_CHAOS),		filterID = 21}
HeraldryEditor.ComboBoxBestOptions[HeraldryEditor.OFFSET_DESTRUCTION+2] = {label = GetGuildString(StringTables.Guild.COMBOBOX_HERALD_BEST_CHOICES_DARK_ELF),	filterID = 22}
HeraldryEditor.ComboBoxBestOptions[HeraldryEditor.OFFSET_DESTRUCTION+3] = {label = GetGuildString(StringTables.Guild.COMBOBOX_HERALD_BEST_CHOICES_GREENSKIN),	filterID = 23}

HeraldryEditor.ComboBoxBestOptions[HeraldryEditor.OFFSET_ORDER]   = {label = GetGuildString(StringTables.Guild.COMBOBOX_HERALD_BEST_CHOICES_ALL),		filterID = 30}
HeraldryEditor.ComboBoxBestOptions[HeraldryEditor.OFFSET_ORDER+1] = {label = GetGuildString(StringTables.Guild.COMBOBOX_HERALD_BEST_CHOICES_DWARF),		filterID = 31}
HeraldryEditor.ComboBoxBestOptions[HeraldryEditor.OFFSET_ORDER+2] = {label = GetGuildString(StringTables.Guild.COMBOBOX_HERALD_BEST_CHOICES_EMPIRE),	filterID = 32}
HeraldryEditor.ComboBoxBestOptions[HeraldryEditor.OFFSET_ORDER+3] = {label = GetGuildString(StringTables.Guild.COMBOBOX_HERALD_BEST_CHOICES_HIGH_ELF),	filterID = 33}

HeraldryEditor.BestOptionsFiltered = {}		-- This is the stored table from war_interface::LuaGetHeraldryBestOptions

HeraldryEditor.CurrentFactionChoice		= 1
HeraldryEditor.CurrentShapeChoice		= 2

HeraldryEditor.CurrentEmblemIndex		= 1	-- This is the index into our table of heraldryBestOptions.emblemList
HeraldryEditor.CurrentPatternIndex		= 1	-- This is the index into our table of heraldryBestOptions.patternList

HeraldryEditor.CurrentEmblemID			= 0	-- This is the ID as specified in the CSV file
HeraldryEditor.CurrentPatternID			= 0	-- This is the ID as specified in the CSV file

HeraldryEditor.MaxShapeChoices = 5
HeraldryEditor.MaxPatternChoices = 0
HeraldryEditor.MaxEmblemChoices = 0

-- These are all the circles we can click on to select. Once selected, we can use the color picker to change its color
HeraldryEditor.COLOR_CHOICE_BASE	 = 1
HeraldryEditor.COLOR_CHOICE_PATTERN  = 2

-- This keeps track of which circle we've selected (Base Color, Pattern Color) so we can color it when we select a color on the color swatch
HeraldryEditor.SelectedCustomization = 0	

HeraldryEditor.CustomColors = {}
HeraldryEditor.CustomColors[HeraldryEditor.COLOR_CHOICE_BASE] = 1	-- Defaulting colorID to white
HeraldryEditor.CustomColors[HeraldryEditor.COLOR_CHOICE_PATTERN] = 1	-- Defaulting colorID to white

-- OnInitialize Handler
function HeraldryEditor.Initialize()
	HeraldryEditor.InitializeChoices() -- NOTE This must be called before InitializeComboBoxes
	HeraldryEditor.InitializeComboBoxes()

   	if (GameData.Realm.ORDER == GameData.Player.realm) then 
		HeraldryEditor.CustomColors[HeraldryEditor.COLOR_CHOICE_BASE] = 1		-- Order defaults to White
		HeraldryEditor.CustomColors[HeraldryEditor.COLOR_CHOICE_PATTERN] = 1	-- Order defaults to White
   	else
		HeraldryEditor.CustomColors[HeraldryEditor.COLOR_CHOICE_BASE] = 2		-- Destruction defaults to Black
		HeraldryEditor.CustomColors[HeraldryEditor.COLOR_CHOICE_PATTERN] = 2	-- Destruction defaults to Black
   	end

	LabelSetText( "HeraldryEditorTitleBarText",				GetGuildString(StringTables.Guild.LABEL_HERALD_EDITOR) )
	LabelSetText( "HeraldryEditorShowBestOptionsHeader",	GetGuildString(StringTables.Guild.HEADER_HERALDRY_SHOW_BEST_OPTIONS) )
	LabelSetText( "HeraldryEditorShapeHeader",				GetGuildString(StringTables.Guild.HEADER_HERALDRY_SHAPE) )
	LabelSetText( "HeraldryEditorShapeColorHeader",			GetGuildString(StringTables.Guild.HEADER_HERALDRY_PRIMARY_COLOR) )
	LabelSetText( "HeraldryEditorPatternHeader",			GetGuildString(StringTables.Guild.HEADER_HERALDRY_PATTERN) )
	LabelSetText( "HeraldryEditorPatternColorHeader",		GetGuildString(StringTables.Guild.HEADER_HERALDRY_PATTERN_COLOR) )
	LabelSetText( "HeraldryEditorEmblemHeader",				GetGuildString(StringTables.Guild.HEADER_HERALDRY_EMBLEM) )

	LabelSetText( "HeraldryEditorDescriptionHeader",		GetGuildString(StringTables.Guild.HEADER_HERALDRY_DESCRIPTION) )

	ButtonSetText( "HeraldryEditorSaveButton", GetGuildString(StringTables.Guild.BUTTON_HERALDRY_SAVE) )
	ButtonSetText( "HeraldryEditorCancelButton", GetGuildString(StringTables.Guild.BUTTON_HERALDRY_CANCEL) )
	
	HeraldryEditor.UpdateAllChoiceLabels()

	-- Had to delay initializes the rendering of the post until after all the heraldry stuff is setup.
	GuildWindowTabBanner.SetRenderPostAndComboBox(GuildWindowTabBanner.Banners[GuildWindowTabBanner.CurrentBannerNumber].postID)
end

function HeraldryEditor.InitializeChoices()
	if (GameData.Realm.ORDER == GameData.Player.realm) then 
		HeraldryEditor.BestOptionsFiltered = GetHeraldryBestOptions(HeraldryEditor.ComboBoxBestOptions[HeraldryEditor.OFFSET_DESTRUCTION].filterID, HeraldryEditor.CurrentShapeChoice)
	else
		HeraldryEditor.BestOptionsFiltered = GetHeraldryBestOptions(HeraldryEditor.ComboBoxBestOptions[HeraldryEditor.OFFSET_ORDER].filterID, HeraldryEditor.CurrentShapeChoice)
	end
end

function HeraldryEditor.InitializeComboBoxes()
    -- Clear all previous entries to avoid duplicating entries.
    ComboBoxClearMenuItems("HeraldryEditorBestOptionsComboBox")
    
	if (GameData.Realm.ORDER == GameData.Player.realm) then 
		for index = HeraldryEditor.OFFSET_ORDER, 33 do --data in ipairs(HeraldryEditor.ComboBoxBestOptions) do
			ComboBoxAddMenuItem( "HeraldryEditorBestOptionsComboBox", HeraldryEditor.ComboBoxBestOptions[index].label )
		end
	else
		for index = HeraldryEditor.OFFSET_DESTRUCTION, 23 do --, data in ipairs(HeraldryEditor.ComboBoxBestOptions) do
			ComboBoxAddMenuItem( "HeraldryEditorBestOptionsComboBox", HeraldryEditor.ComboBoxBestOptions[index].label )
		end
	end

	ComboBoxSetSelectedMenuItem("HeraldryEditorBestOptionsComboBox", 1)
	HeraldryEditor.OnSelChangedBestOptionsComboBox()
end

function HeraldryEditor.Shutdown()
end

function HeraldryEditor.OnShown()
	WindowSetShowing("HeraldryEditor", true)
	WindowSetShowing("ColorPicker", true)
	WindowSetAlpha("ColorPicker", 0.0)
	
	HeraldryEditor.UpdateButtonPermissions(GameData.Guild.m_GuildRank)
end

function HeraldryEditor.OnHidden()
	WindowSetShowing("HeraldryEditor", false)
	WindowSetShowing("ColorPicker", false)
end

function HeraldryEditor.OnMouseOver()
end

function HeraldryEditor.VerifyValidEmblemID()
	-- The Index is the index into the LUA table. The ID is the pattern's ID according to the CSV file.
	local emblemID = 0

	-- Save the currently selected emblemID
	if (HeraldryEditor.CurrentEmblemIndex ~= nil and HeraldryEditor.CurrentEmblemIndex > 0) then
        emblemID = HeraldryEditor.GetActualEmblemID(HeraldryEditor.CurrentEmblemIndex)
    end

	-- If the currently selected EmblemID still exists in our new filter, reselect it (by choosing its new index)
    if emblemID ~= nil and emblemID > 0 then
		HeraldryEditor.CurrentEmblemIndex = HeraldryEditor.GetEmblemIndexFromActualEmblemID(emblemID)
    else
		HeraldryEditor.CurrentEmblemIndex = 1	-- If the currently selected EmblemID doesn't exist in our new filter, use the first valid index.
    end
end

function HeraldryEditor.VerifyValidPatternID()
	-- The Index is the index into the LUA table. The ID is the pattern's ID according to the CSV file.
	local patternID = 0

	-- Save the currently selected patternID
	if (HeraldryEditor.CurrentPatternIndex ~= nil and HeraldryEditor.CurrentPatternIndex > 0) then
        patternID = HeraldryEditor.GetActualPatternID(HeraldryEditor.CurrentPatternIndex)
    end

	-- If the currently selected PatternID still exists in our new filter, reselect it (by choosing its new index)
    if patternID ~= nil and patternID > 0 then
        HeraldryEditor.CurrentPatternIndex = HeraldryEditor.GetPatternIndexFromActualPatternID(patternID)
	else
		HeraldryEditor.CurrentPatternIndex = 1	-- If the currently selected PatternID doesn't exist in our new filter, use the first valid index.
    end
end

function HeraldryEditor.OnSelChangedBestOptionsComboBox()

	HeraldryEditor.CurrentFactionChoice = ComboBoxGetSelectedMenuItem("HeraldryEditorBestOptionsComboBox")
	
	-- The combo box returns 1..4. We need to add 29 to this to index the Order Filters, or 19 for the Destruction filters (see top of file)
	if (GameData.Realm.ORDER == GameData.Player.realm) then			-- Setup Order Defaults
		HeraldryEditor.CurrentFactionChoice = HeraldryEditor.CurrentFactionChoice + 29
	else															-- Setup Destruction Defaults
		HeraldryEditor.CurrentFactionChoice = HeraldryEditor.CurrentFactionChoice + 19
	end

    if (HeraldryEditor.ComboBoxBestOptions[HeraldryEditor.CurrentFactionChoice] == nil) then
        return		-- We cannot perform any functionality if this table is NIL
    end

	local filterID = HeraldryEditor.ComboBoxBestOptions[HeraldryEditor.CurrentFactionChoice].filterID

	-- Save our old choices so we can re-select them if they exist in the new filters.

	local oldPatternID = HeraldryEditor.BestOptionsFiltered.patternList[HeraldryEditor.CurrentPatternIndex]
	local oldEmblemID = HeraldryEditor.BestOptionsFiltered.emblemList[HeraldryEditor.CurrentEmblemIndex]

	-- Get the table from C that contains all the filtered choices
	HeraldryEditor.BestOptionsFiltered = GetHeraldryBestOptions(filterID, HeraldryEditor.CurrentShapeChoice)

	-- reset the maximum number of choices based on the new filtered choices
	HeraldryEditor.MaxPatternChoices = #HeraldryEditor.BestOptionsFiltered.patternList
	HeraldryEditor.MaxEmblemChoices = #HeraldryEditor.BestOptionsFiltered.emblemList
	
	-- Ensure that the currently selected choices fall within the new filtered choices
	ColorPicker.FilterColorChoices()

	HeraldryEditor.CurrentPatternIndex = 1
	for index, data in ipairs(HeraldryEditor.BestOptionsFiltered.patternList) do
		if data == oldPatternID then
			HeraldryEditor.CurrentPatternIndex = index
			break
		end
	end

	HeraldryEditor.CurrentEmblemIndex = 1
	for index, data in ipairs(HeraldryEditor.BestOptionsFiltered.emblemList) do
		if data == oldEmblemID then
			HeraldryEditor.CurrentEmblemIndex = index
			break
		end
	end

	-- Update the labels with the new filtered choices
	HeraldryEditor.UpdateAllChoiceLabels()

	-- Update the other choices and the render scene
	HeraldryEditor.UpdateAllChoices() 
end

function HeraldryEditor.GetCurrencyText( brassAmount )      
    local currencyText = StringTables.Default.LABEL_CURRENCY_BRASS
      
    local brassPerGold = GetNumBrassPerGold()
    local brassPerSilver = GetNumBrassPerSilver()
    
    if( brassAmount >= brassPerGold ) then
        currencyText = GetString(StringTables.Default.LABEL_CURRENCY_GOLD)
    elseif( brassAmount >= brassPerSilver and brassAmount < brassPerGold ) then
        currencyText = GetString(StringTables.Default.LABEL_CURRENCY_SILVER)
    end
    
    return currencyText
    
end

function HeraldryEditor.ConvertMoney( brassAmount )
    -- Convert the brass amount into what it should be for the type of
    -- currency it represents
    
    local money = brassAmount
      
    local brassPerGold = GetNumBrassPerGold()
    local brassPerSilver = GetNumBrassPerSilver()
    
    if( brassAmount >= brassPerGold ) then
        money = money / brassPerGold
    elseif( brassAmount >= brassPerSilver and brassAmount < brassPerGold ) then
        money = money / brassPerSilver
    end
    
    return money    
end

function HeraldryEditor.OnMouseoverHeraldrySaveButton()

    -- Determine heraldry costs
    local heraldryCost = GetHeraldryCost()
    local currencyText = HeraldryEditor.GetCurrencyText(heraldryCost)
    heraldryCost = HeraldryEditor.ConvertMoney(heraldryCost)
            
    Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name, nil)
    Tooltips.SetTooltipText (1, 1, GetFormatStringFromTable( "guildstrings", StringTables.Guild.TOOLTIP_SAVE_HERALDRY_BUTTON, { heraldryCost, currencyText } ) )
    Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)  
    Tooltips.Finalize ()
    
    local anchor = { Point="top", RelativeTo=SystemData.MouseOverWindow.name, RelativePoint="bottomleft", XOffset=0, YOffset=-20 }
    Tooltips.AnchorTooltip (anchor)
    -- Tooltips.SetTooltipAlpha (1)
end

function HeraldryEditor.OnLButtonUpSaveButton()
    -- Create Confirmation Dialog
    local dialogText
    local heraldryData = GetHeraldryConfigurationData()
    if( heraldryData.reserved == SystemData.GuildHeraldryReservation.RESET_AVAILABLE )
    then
        dialogText = GetStringFromTable( "guildstrings", StringTables.Guild.DIALOG_CONFIRM_SAVING_HERALDRY_WITH_RESET )
    else
        -- Determine heraldry costs
        local heraldryCost = GetHeraldryCost()
        local currencyText = HeraldryEditor.GetCurrencyText(heraldryCost)
        heraldryCost = HeraldryEditor.ConvertMoney(heraldryCost)
        dialogText = GetFormatStringFromTable( "guildstrings", StringTables.Guild.DIALOG_CONFIRM_SAVING_HERALDRY, { heraldryCost, currencyText } )
    end

     HeraldryEditor.OnLButtonUpSaveButtonConfirmed()
    --DialogManager.MakeTwoButtonDialog( dialogText, 
	--								   GetGuildString(StringTables.Guild.BUTTON_CONFIRM_YES),
	--								   HeraldryEditor.OnLButtonUpSaveButtonConfirmed, 
	--								   GetGuildString(StringTables.Guild.BUTTON_CONFIRM_NO),
	--								   nil)
end

function HeraldryEditor.OnLButtonUpSaveButtonConfirmed()
-- Params must match those expected in war_interface::LuaSendHeraldryConfigurationData.
--       LUA_NUMBER, // Emblem Icon
--        LUA_NUMBER, // Background Pattern
--        LUA_NUMBER, // Background Primary Color
--        LUA_NUMBER, // Background Secondary Color
--        LUA_NUMBER, // Shape
--
	SendHeraldryConfigurationData(HeraldryEditor.CurrentEmblemID, 
								HeraldryEditor.CurrentPatternID, 
								HeraldryEditor.CustomColors[HeraldryEditor.COLOR_CHOICE_BASE], 
								HeraldryEditor.CustomColors[HeraldryEditor.COLOR_CHOICE_PATTERN], 
								HeraldryEditor.CurrentShapeChoice)
	WindowSetShowing("HeraldryEditor", false)
end

function HeraldryEditor.OnLButtonUpCancelButton()
	WindowSetShowing("HeraldryEditor", false)
end

function HeraldryEditor.OnMouseOverBestOptionsComboBox()
    Tooltips.CreateTextOnlyTooltip(SystemData.MouseOverWindow.name, GetGuildString(StringTables.Guild.TOOLTIP_HERALD_RACEFILTER))
    anchor = { Point="top", RelativeTo=SystemData.MouseOverWindow.name, RelativePoint="bottom", XOffset=0, YOffset=-10 }
    Tooltips.AnchorTooltip (anchor)
    Tooltips.Finalize()
end

function HeraldryEditor.OnMouseOverEmblem()
    Tooltips.CreateTextOnlyTooltip(SystemData.MouseOverWindow.name, GetGuildString(StringTables.Guild.TOOLTIP_HERALD_EMBLEM_DESCRIPTION))
    anchor = { Point="top", RelativeTo=SystemData.MouseOverWindow.name, RelativePoint="bottom", XOffset=0, YOffset=-10 }
    Tooltips.AnchorTooltip (anchor)
    Tooltips.Finalize()
end

function HeraldryEditor.OnMouseoverColorBox()

	local colorBoxID = WindowGetId( SystemData.ActiveWindow.name ) 
	if (colorBoxID == HeraldryEditor.COLOR_CHOICE_BASE)
	then
        Tooltips.CreateTextOnlyTooltip(SystemData.ActiveWindow.name, GetGuildString(StringTables.Guild.TOOLTIP_HERALD_COLORPATTERN))
    else
        Tooltips.CreateTextOnlyTooltip(SystemData.ActiveWindow.name, GetGuildString(StringTables.Guild.TOOLTIP_HERALD_COLORBACKGROUND))
    end
	local anchor = { Point="top", RelativeTo=SystemData.MouseOverWindow.name, RelativePoint="bottom", XOffset=0, YOffset=-10 }
    Tooltips.AnchorTooltip (anchor)
    Tooltips.Finalize()
end

function HeraldryEditor.OnMouseoverEndColorBox()

end

function HeraldryEditor.OnMouseoverPrimaryColorHeader()
    Tooltips.CreateTextOnlyTooltip(SystemData.ActiveWindow.name, GetGuildString(StringTables.Guild.TOOLTIP_HERALD_COLORBACKGROUND))
    local anchor = { Point="top", RelativeTo=SystemData.MouseOverWindow.name, RelativePoint="bottom", XOffset=0, YOffset=-10 }
    Tooltips.AnchorTooltip (anchor)
    Tooltips.Finalize()
end

function HeraldryEditor.OnMouseoverSecondaryColorLabel()
    Tooltips.CreateTextOnlyTooltip(SystemData.ActiveWindow.name, GetGuildString(StringTables.Guild.TOOLTIP_HERALD_COLORPATTERN))
    local anchor = { Point="top", RelativeTo=SystemData.MouseOverWindow.name, RelativePoint="bottom", XOffset=0, YOffset=-10 }
    Tooltips.AnchorTooltip (anchor)
    Tooltips.Finalize()
end

function HeraldryEditor.OnMouseOverPatternHeader()
    Tooltips.CreateTextOnlyTooltip(SystemData.MouseOverWindow.name, GetGuildString(StringTables.Guild.TOOLTIP_HERALD_FOREGROUND_DESCRIPTION))
    anchor = { Point="top", RelativeTo=SystemData.MouseOverWindow.name, RelativePoint="bottom", XOffset=0, YOffset=-10 }
    Tooltips.AnchorTooltip (anchor)
    Tooltips.Finalize()
end

function HeraldryEditor.OnLButtonUpColorBox()
	local colorBoxID = WindowGetId( SystemData.ActiveWindow.name )

	ButtonSetPressedFlag("HeraldryEditorCustomColor1", false)
	ButtonSetPressedFlag("HeraldryEditorCustomColor2", false)
    WindowSetTintColor("HeraldryEditorCustomColorFrame1", 255, 255, 255)
    WindowSetTintColor("HeraldryEditorCustomColorFrame2", 255, 255, 255)
	
	if colorBoxID == nil or HeraldryEditor.SelectedCustomization == colorBoxID then	-- Deselect if already selected or invalid data
		HeraldryEditor.SelectedCustomization = 0
		if (HeraldryEditor.isColorPickerShown == true)
		then
		    HeraldryEditor.isColorPickerShown = false
		    WindowStartAlphaAnimation( "ColorPicker", Window.AnimationType.SINGLE_NO_RESET, 1.0, 0.0, 0.5, false, 0, 0 )
		end
	else
		HeraldryEditor.SelectedCustomization = colorBoxID							-- Otherwise select it
		ButtonSetPressedFlag("HeraldryEditorCustomColor"..colorBoxID, true)
		WindowSetTintColor("HeraldryEditorCustomColorFrame"..colorBoxID, 255, 85, 0 )
		if (HeraldryEditor.isColorPickerShown == false)
		then
		    HeraldryEditor.isColorPickerShown = true
		    WindowStartAlphaAnimation( "ColorPicker", Window.AnimationType.SINGLE_NO_RESET, 0.0, 1.0, 0.5, false, 0, 0 )
		end
		
	end
end

-- Callback from the Colorpicker
function HeraldryEditor.HandleColorPickerChoice(r,g,b, colorID)
	if r == nil or g == nil or b == nil or colorID ==nil then
		return
	end
    if HeraldryEditor.SelectedCustomization == 0 then
        return
    end
    WindowSetTintColor("HeraldryEditorCustomColor"..HeraldryEditor.SelectedCustomization, r, g, b)
	if colorID ~= nil then
		HeraldryEditor.CustomColors[HeraldryEditor.SelectedCustomization] = colorID
		HeraldryEditor.UpdateColorChoices(false)
	end
end

function HeraldryEditor.UpdateColorChoices(_bUpdateStandard)
	local r,g,b

	if ColorPicker.SelectedColorPickerWindowID <= 0 then
		-- Neither the base color nor the pattern color is selected, so use the defaults
		r,g,b = ColorPicker.GetRGBValuesFromColorID(GameData.Player.realm) --HeraldryEditor.BestOptionsFiltered.colorList[GameData.Player.realm])
		WindowSetTintColor("HeraldryEditorCustomColor1", r, g, b)
		WindowSetTintColor("HeraldryEditorCustomColor2", r, g, b)
	else
		if ColorPicker.SelectedColorPickerWindowID > 45 then -- (These are the 3 special boxes on the edge)
			if ColorPicker.SelectedColorPickerWindowID == 1 then 
				r, g, b = WindowGetTintColor("ColorPickerColorBoxEdge203")
			elseif ColorPicker.SelectedColorPickerWindowID == 46 then
				r, g, b = WindowGetTintColor("ColorPickerColorBoxEdge201")
			else
				r, g, b = WindowGetTintColor("ColorPickerColorBoxEdge202")
			end
		else
        -- TODO: This needs to be fixed also
			if ColorPicker.SelectedColorPickerWindowID > 41 then
				ColorPicker.SelectedColorPickerWindowID = ColorPicker.SelectedColorPickerWindowID -1
				r, g, b = WindowGetTintColor("ColorPickerColorBox"..ColorPicker.SelectedColorPickerWindowID)
				else
				r, g, b = WindowGetTintColor("ColorPickerColorBox"..ColorPicker.SelectedColorPickerWindowID)
			end
		end
	end
	HeraldryEditor.UpdateAllChoices(_bUpdateStandard)
end

function HeraldryEditor.UpdateButtonPermissions(rank)
end

function HeraldryEditor.UpdateAllChoices(bUpdateStandard)
	if bUpdateStandard == nil then
		bUpdateStandard = false
	end
	HeraldryEditor.UpdateButtonPermissions(GameData.Guild.m_GuildRank)

	HeraldryEditor.CurrentEmblemID = HeraldryEditor.BestOptionsFiltered.emblemList[HeraldryEditor.CurrentEmblemIndex]
	HeraldryEditor.CurrentPatternID = HeraldryEditor.BestOptionsFiltered.patternList[HeraldryEditor.CurrentPatternIndex]
	
	if     HeraldryEditor.CurrentPatternID == nil
        or HeraldryEditor.CurrentEmblemID == nil
        or GuildWindowTabBanner.CurrentPostNumber == nil
        or HeraldryEditor.CustomColors[HeraldryEditor.COLOR_CHOICE_BASE] == nil
        or HeraldryEditor.CustomColors[HeraldryEditor.COLOR_CHOICE_PATTERN] == nil
    then
        return
    end

	-- Pattern, Primary Color, Secondary Color, Emblem, bUpdateStandard
	SetGuildHeraldryScene(
						  HeraldryEditor.CurrentPatternID,
						  HeraldryEditor.CustomColors[HeraldryEditor.COLOR_CHOICE_BASE],
						  HeraldryEditor.CustomColors[HeraldryEditor.COLOR_CHOICE_PATTERN],
						  HeraldryEditor.CurrentEmblemID,
						  GuildWindowTabBanner.CurrentPostNumber,
						  bUpdateStandard)
end

function HeraldryEditor.UpdateAllChoiceLabels()
	LabelSetText( "HeraldryEditorShapeChoice",		L""..HeraldryEditor.CurrentShapeChoice..L"/"..HeraldryEditor.MaxShapeChoices )
	LabelSetText( "HeraldryEditorPatternChoice",	L""..HeraldryEditor.CurrentPatternIndex..L"/"..HeraldryEditor.MaxPatternChoices )
	LabelSetText( "HeraldryEditorEmblemChoice",		L""..HeraldryEditor.CurrentEmblemIndex..L"/"..HeraldryEditor.MaxEmblemChoices )
end

function HeraldryEditor.OnLButtonUpShapeLeftArrow()

	if HeraldryEditor.CurrentShapeChoice <= 1 then
		HeraldryEditor.CurrentShapeChoice = HeraldryEditor.MaxShapeChoices
	else
		HeraldryEditor.CurrentShapeChoice = HeraldryEditor.CurrentShapeChoice - 1
	end

	LabelSetText( "HeraldryEditorShapeChoice",		L""..HeraldryEditor.CurrentShapeChoice..L"/"..HeraldryEditor.MaxShapeChoices )
	local filterID = HeraldryEditor.ComboBoxBestOptions[HeraldryEditor.CurrentFactionChoice].filterID

	HeraldryEditor.BestOptionsFiltered = GetHeraldryBestOptions(filterID, HeraldryEditor.CurrentShapeChoice)
	HeraldryEditor.UpdateAllChoices()
end

function HeraldryEditor.OnLButtonUpShapeRightArrow()

	if HeraldryEditor.CurrentShapeChoice >= HeraldryEditor.MaxShapeChoices then
		HeraldryEditor.CurrentShapeChoice = 1
	else
		HeraldryEditor.CurrentShapeChoice = HeraldryEditor.CurrentShapeChoice + 1
	end

	LabelSetText( "HeraldryEditorShapeChoice",		L""..HeraldryEditor.CurrentShapeChoice..L"/"..HeraldryEditor.MaxShapeChoices )
	local filterID = HeraldryEditor.ComboBoxBestOptions[HeraldryEditor.CurrentFactionChoice].filterID

	HeraldryEditor.BestOptionsFiltered = GetHeraldryBestOptions(filterID, HeraldryEditor.CurrentShapeChoice)
	HeraldryEditor.UpdateAllChoices()
end

function HeraldryEditor.OnLButtonUpPatternLeftArrow()
	if HeraldryEditor.CurrentPatternIndex <= 1 then
		HeraldryEditor.CurrentPatternIndex = HeraldryEditor.MaxPatternChoices
	else
		HeraldryEditor.CurrentPatternIndex = HeraldryEditor.CurrentPatternIndex - 1
	end
	
	LabelSetText( "HeraldryEditorPatternChoice",	L""..HeraldryEditor.CurrentPatternIndex..L"/"..HeraldryEditor.MaxPatternChoices )
	HeraldryEditor.UpdateAllChoices()
end

function HeraldryEditor.OnLButtonUpPatternRightArrow()
	if HeraldryEditor.CurrentPatternIndex >= HeraldryEditor.MaxPatternChoices then
		HeraldryEditor.CurrentPatternIndex = 1
	else
		HeraldryEditor.CurrentPatternIndex = HeraldryEditor.CurrentPatternIndex + 1
	end

	LabelSetText( "HeraldryEditorPatternChoice",	L""..HeraldryEditor.CurrentPatternIndex..L"/"..HeraldryEditor.MaxPatternChoices )
	HeraldryEditor.UpdateAllChoices()
end

function HeraldryEditor.OnLButtonUpEmblemLeftArrow()
	if HeraldryEditor.CurrentEmblemIndex <= 1 then
		HeraldryEditor.CurrentEmblemIndex = HeraldryEditor.MaxEmblemChoices
	else
		HeraldryEditor.CurrentEmblemIndex = HeraldryEditor.CurrentEmblemIndex - 1
	end

	LabelSetText( "HeraldryEditorEmblemChoice",		L""..HeraldryEditor.CurrentEmblemIndex..L"/"..HeraldryEditor.MaxEmblemChoices )
	HeraldryEditor.UpdateAllChoices()
end

function HeraldryEditor.OnLButtonUpEmblemRightArrow()
	if HeraldryEditor.CurrentEmblemIndex >= HeraldryEditor.MaxEmblemChoices then
		HeraldryEditor.CurrentEmblemIndex = 1
	else
		HeraldryEditor.CurrentEmblemIndex = HeraldryEditor.CurrentEmblemIndex + 1
	end

	LabelSetText( "HeraldryEditorEmblemChoice",		L""..HeraldryEditor.CurrentEmblemIndex..L"/"..HeraldryEditor.MaxEmblemChoices )
	HeraldryEditor.UpdateAllChoices()
end

function HeraldryEditor.OnMouseOverShapeHeader()
	Tooltips.CreateTextOnlyTooltip(SystemData.ActiveWindow.name, GetGuildString(StringTables.Guild.TOOLTIP_HERALD_PATTERN_DESCRIPTION))
    anchor = { Point="top", RelativeTo=SystemData.MouseOverWindow.name, RelativePoint="bottom", XOffset=0, YOffset=-10 }
    Tooltips.AnchorTooltip (anchor)
    Tooltips.Finalize()
end

function HeraldryEditor.OnMouseOverEmblemHeader()
end

function HeraldryEditor.GetPatternIndexFromPatternID(patternID)
	for index, data in ipairs(HeraldryEditor.BestOptionsFiltered.patternList) do
		if data == patternID then
			return index
		end
	end
	return 1
end

function HeraldryEditor.GetEmblemIndexFromEmblemID(emblemID)
	for index, data in ipairs(HeraldryEditor.BestOptionsFiltered.emblemList) do
		if data == emblemID then
			return index
		end
	end
	return 1
end

function HeraldryEditor.SyncHeraldryOptions()
	local heraldryData = GetHeraldryConfigurationData()
    local filterID = HeraldryEditor.ComboBoxBestOptions[HeraldryEditor.CurrentFactionChoice].filterID

	HeraldryEditor.CurrentShapeChoice								= heraldryData.shape
	HeraldryEditor.BestOptionsFiltered                              = GetHeraldryBestOptions(filterID, HeraldryEditor.CurrentShapeChoice)
	HeraldryEditor.CurrentPatternIndex								= HeraldryEditor.GetPatternIndexFromPatternID(heraldryData.backgroundPattern)
	HeraldryEditor.CurrentEmblemIndex								= HeraldryEditor.GetEmblemIndexFromEmblemID(heraldryData.emblemIcon)
	HeraldryEditor.CustomColors[HeraldryEditor.COLOR_CHOICE_BASE]	= heraldryData.primaryColorID
	HeraldryEditor.CustomColors[HeraldryEditor.COLOR_CHOICE_PATTERN]= heraldryData.secondaryColorID
	HeraldryEditor.CurrentPost										= heraldryData.post
end
