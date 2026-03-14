----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EditAppealWindow = {}

EditAppealWindow.LogDisplayNumber = 1

EditAppealWindow.FieldNames = {}
EditAppealWindow.FieldNames[GameData.HelpField.DETAILS]						= StringTables.Help.HEADER_FIELD_STRING_DETAILS
EditAppealWindow.FieldNames[GameData.HelpField.CATEGORY]					= StringTables.Help.HEADER_FIELD_STRING_VIOLATION_CATEGORY
EditAppealWindow.FieldNames[GameData.HelpField.CAREER]						= StringTables.Help.HEADER_FIELD_STRING_CAREER_NAME
EditAppealWindow.FieldNames[GameData.HelpField.ITEM_NAME]					= StringTables.Help.HEADER_FIELD_STRING_ITEM_NAME
EditAppealWindow.FieldNames[GameData.HelpField.NAME_REPORTING]				= StringTables.Help.HEADER_FIELD_STRING_CHARACTER_NAME
EditAppealWindow.FieldNames[GameData.HelpField.PUBLIC_QUEST_NAME]			= StringTables.Help.HEADER_FIELD_STRING_PQ_NAME
EditAppealWindow.FieldNames[GameData.HelpField.SCENARIO_NAME]				= StringTables.Help.HEADER_FIELD_STRING_SCENARIO_NAME
EditAppealWindow.FieldNames[GameData.HelpField.BATTLEFIELD_OBJECTIVE_NAME]	= StringTables.Help.HEADER_FIELD_STRING_BO_NAME
EditAppealWindow.FieldNames[GameData.HelpField.KEEP_NAME]					= StringTables.Help.HEADER_FIELD_STRING_KEEP_NAME
EditAppealWindow.FieldNames[GameData.HelpField.MONSTER_NAME]				= StringTables.Help.HEADER_FIELD_STRING_MONSTER_NAME
EditAppealWindow.FieldNames[GameData.HelpField.QUEST_NAME]					= StringTables.Help.HEADER_FIELD_STRING_QUEST_NAME
EditAppealWindow.FieldNames[GameData.HelpField.QUEST_STEP]					= StringTables.Help.HEADER_FIELD_STRING_QUEST_STEP
EditAppealWindow.FieldNames[GameData.HelpField.TOME_ENTRY]					= StringTables.Help.HEADER_FIELD_STRING_TOME_ENTRY
EditAppealWindow.FieldNames[GameData.HelpField.PRICE]						= StringTables.Help.HEADER_FIELD_STRING_PRICE
EditAppealWindow.FieldNames[GameData.HelpField.SKILL_NAME]					= StringTables.Help.HEADER_FIELD_STRING_SKILL_NAME
EditAppealWindow.FieldNames[GameData.HelpField.PLATFORM]                    = StringTables.Help.HEADER_FIELD_STRING_PLATFORM

----------------------------------------------------------------
-- EditAppealWindow Functions
----------------------------------------------------------------

function EditAppealWindow.Initialize()
    -- Setup component text
    LabelSetText( "EditAppealWindowTitleBarText", GetHelpString( StringTables.Help.TEXT_HELP_EDIT_APPEAL_TITLE_BAR) )

    ButtonSetText( "EditAppealWindowSubmit", GetHelpString( StringTables.Help.BUTTON_SUBMIT) )
    ButtonSetText( "EditAppealWindowCancel", GetHelpString( StringTables.Help.BUTTON_CANCEL_APPEAL) )
    ButtonSetText( "EditAppealWindowBack", GetHelpString( StringTables.Help.BUTTON_BACK) )
    
    WindowRegisterEventHandler( "EditAppealWindow", SystemData.Events.HELP_LOG_UPDATED, "EditAppealWindow.UpdateHelpLog")

	EditAppealWindow.InitializeLog()
end

function EditAppealWindow.InitializeLog()
    
	TextLogCreate("AppealLog", 256)
	--TextLogClear("AppealLog")

	TextLogAddFilterType("AppealLog", 999, L"")
    TextLogAddFilterType("AppealLog", GameData.AppealAuthor.PLAYER, GetHelpString(StringTables.Help.LABEL_AUTHOR_PLAYER) )
	TextLogAddFilterType("AppealLog", GameData.AppealAuthor.CS, GetHelpString(StringTables.Help.LABEL_AUTHOR_CS) )
    LogDisplayAddLog("EditAppealWindowLogDisplay", "AppealLog", true)
    LogDisplaySetShowTimestamp("EditAppealWindowLogDisplay", false)
    LogDisplaySetShowLogName("EditAppealWindowLogDisplay", false)
    TextLogDisplayShowScrollbar("EditAppealWindowLogDisplay", true)

    LogDisplaySetFilterColor( "EditAppealWindowLogDisplay", "AppealLog", GameData.AppealAuthor.PLAYER, DefaultColor.CLEAR_WHITE.r, DefaultColor.CLEAR_WHITE.g, DefaultColor.CLEAR_WHITE.b )
    LogDisplaySetFilterColor( "EditAppealWindowLogDisplay", "AppealLog", GameData.AppealAuthor.CS, DefaultColor.YELLOW.r, DefaultColor.YELLOW.g, DefaultColor.YELLOW.b )
	LogDisplaySetFilterColor( "EditAppealWindowLogDisplay", "AppealLog", 999, DefaultColor.BLUE.r, DefaultColor.BLUE.g, DefaultColor.BLUE.b )

	LogDisplayScrollToTop("EditAppealWindowLogDisplay")
end

function EditAppealWindow.Shutdown()

end

function EditAppealWindow.Show()
    WindowSetShowing( "EditAppealWindow", true )
end

function EditAppealWindow.Hide()
    WindowSetShowing( "EditAppealWindow", false )
end

function EditAppealWindow.IsShowing()
    return WindowGetShowing( "EditAppealWindow" )
end

function EditAppealWindow.OnLButtonUpSubmitButton()
	-- SendHelpMessage expects the following params:
	--		param1 (number) = The type of help message this is, defined by GameData.HelpType.*
	--		param2 (number) = The subtype, aka topic, of this message.  Defined by GameData.AppealTopic.*
	--		param3 (WString) = The sub-subtype, aka topic category, of this message. Defined by EViolation
	--		param4 (WString) = The details field of this message.
	--		param5 (number)  = field ID for string 1
	--		param6 (WString) = Generic string1 param
	--		param7 (number)  = field ID for string 2
	--		param8 (WString) = Generic string2 param
	--		param9 (number)  = field ID for string 3
	--		param10 (WString)= Generic string3 param
	--		param11 (number) = field ID for string 4
	--		param12 (WString)= Generic string4 param
	local details = TextEditBoxGetText("EditAppealWindowEditBox")
	
	if(details == L"")
	then
	    local dialogText = GetHelpString( StringTables.Help.ERROR_NO_APPEAL_DETAILS	)
        local confirmOK = GetString( StringTables.Default.LABEL_OKAY )

        DialogManager.MakeOneButtonDialog( dialogText, confirmOK )
	else	
	    SendHelpMessage(GameData.HelpType.UPDATE_APPEAL, 0, L"", details, 0, L"", 0, L"", 0, L"", 0, L"")
	    EditAppealWindow.Hide()
	end
end

function EditAppealWindow.OnLButtonUpCancelButton()
	-- Create Confirmation Dialog
    local dialogText = GetHelpString( StringTables.Help.DIALOG_CONFIRM_CANCEL_APPEAL)
    
    local confirmYes = GetHelpString( StringTables.Help.BUTTON_CONFIRM_YES)
    local confirmNo = GetHelpString( StringTables.Help.BUTTON_CONFIRM_NO)
    DialogManager.MakeTwoButtonDialog( dialogText, confirmYes, EditAppealWindow.ConfirmedCancelAppeal, confirmNo, nil)
end

function EditAppealWindow.ConfirmedCancelAppeal()
	-- SendHelpMessage expects the following params:
	--		param1 (number) = The type of help message this is, defined by GameData.HelpType.*
	--		param2 (number) = The subtype, aka topic, of this message.  Defined by GameData.AppealTopic.*
	--		param3 (WString) = The sub-subtype, aka topic category, of this message. Defined by EViolation
	--		param4 (WString) = The details field of this message.
	--		param5 (number)  = field ID for string 1
	--		param6 (WString) = Generic string1 param
	--		param7 (number)  = field ID for string 2
	--		param8 (WString) = Generic string2 param
	--		param9 (number)  = field ID for string 3
	--		param10 (WString)= Generic string3 param
	--		param11 (number) = field ID for string 4
	--		param12 (WString)= Generic string4 param
	SendHelpMessage(GameData.HelpType.CANCEL_APPEAL, 0, L"", L"", 0, L"", 0, L"", 0, L"", 0, L"")
	EditAppealWindow.OnLButtonUpBackButton()
end

function EditAppealWindow.OnLButtonUpBackButton()
	EditAppealWindow.Hide()
	EA_Window_Help.OnShown()
end

function EditAppealWindow.Clear()
    TextEditBoxSetText( "EditAppealWindowEditBox", L"" )
end

function EditAppealWindow.OnShown()
	EditAppealWindow.Clear()
end

function EditAppealWindow.OnHidden()
	EditAppealWindow.Clear()
end

function EditAppealWindow.UpdateHelpLog(log)
	local labelText = L""
	
	--EditAppealWindow.InitializeLog()
	TextLogClear("AppealLog")

	if log.fields ~= nil then
		for stringCounter, stringData in pairs(log.fields) do
			labelText = GetHelpString(EditAppealWindow.FieldNames[stringData.fieldID])..L": "..stringData.fieldStr
			TextLogAddEntry("AppealLog", 999, labelText)
		end
	end

	if log.detailStr ~= nil then
		labelText = GetHelpString(EditAppealWindow.FieldNames[GameData.HelpField.DETAILS])..L": "..log.detailStr
		TextLogAddEntry("AppealLog", 999, labelText)
	end
		
	for textCounter, textData in pairs(log) do
		if textData.appealString ~= nil and textData.author ~= nil then
			TextLogAddEntry("AppealLog", textData.author, textData.appealString)
		end
	end
end
