----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_Feedback = {}

EA_Window_Feedback.feedbackTypes = {}
EA_Window_Feedback.feedbackTypes[GameData.Feedback.CITIES]						= {labelID = StringTables.Help.COMBOBOX_CHOICE_FEEDBACK_CITIES}
EA_Window_Feedback.feedbackTypes[GameData.Feedback.TOME_OF_KNOWLEDGE]			= {labelID = StringTables.Help.COMBOBOX_CHOICE_FEEDBACK_TOME_OF_KNOWLEDGE}
EA_Window_Feedback.feedbackTypes[GameData.Feedback.QUESTS_AND_PUBLIC_QUESTS]	= {labelID = StringTables.Help.COMBOBOX_CHOICE_FEEDBACK_QUESTS_AND_PUBLIC_QUESTS}
EA_Window_Feedback.feedbackTypes[GameData.Feedback.CAREER]						= {labelID = StringTables.Help.COMBOBOX_CHOICE_FEEDBACK_CAREER}
EA_Window_Feedback.feedbackTypes[GameData.Feedback.COMBAT]						= {labelID = StringTables.Help.COMBOBOX_CHOICE_FEEDBACK_COMBAT}
EA_Window_Feedback.feedbackTypes[GameData.Feedback.TRADESKILL_AND_ECONOMY]		= {labelID = StringTables.Help.COMBOBOX_CHOICE_FEEDBACK_TRADESKILL_AND_ECONOMY}
EA_Window_Feedback.feedbackTypes[GameData.Feedback.USER_INTERFACE]				= {labelID = StringTables.Help.COMBOBOX_CHOICE_FEEDBACK_USER_INTERFACE}
EA_Window_Feedback.feedbackTypes[GameData.Feedback.GENERAL_NEGATIVE]			= {labelID = StringTables.Help.COMBOBOX_CHOICE_FEEDBACK_GENERAL_NEGATIVE}
EA_Window_Feedback.feedbackTypes[GameData.Feedback.GENERAL_POSITIVE]			= {labelID = StringTables.Help.COMBOBOX_CHOICE_FEEDBACK_GENERAL_POSITIVE}

EA_Window_Feedback.selectedType = 1

----------------------------------------------------------------
-- EA_Window_Feedback Functions
----------------------------------------------------------------

function EA_Window_Feedback.Initialize()
	EA_Window_Feedback.InitializeComboBoxes()

    -- Setup component text
    LabelSetText( "EA_Window_FeedbackTitleBarText", GetHelpString( StringTables.Help.TEXT_HELP_TITLE_BAR) )
    LabelSetText( "EA_Window_FeedbackHeaderText", GetHelpString( StringTables.Help.HEADER_HELP_FEEDBACK) )
	LabelSetText( "EA_Window_FeedbackTopicHeader", GetHelpString( StringTables.Help.HEADER_HELP_FEEDBACK_TOPIC_HEADER) )
	LabelSetText( "EA_Window_FeedbackDescriptionHeader", GetHelpString( StringTables.Help.HEADER_HELP_FEEDBACK_DESCRIPTION_HEADER) )
    ButtonSetText( "EA_Window_FeedbackSubmit", GetHelpString( StringTables.Help.BUTTON_SUBMIT) )
    ButtonSetText( "EA_Window_FeedbackClear", GetHelpString( StringTables.Help.BUTTON_CLEAR) )
    ButtonSetText( "EA_Window_FeedbackBack", GetHelpString( StringTables.Help.BUTTON_BACK))
end

function EA_Window_Feedback.InitializeComboBoxes()
	ComboBoxClearMenuItems("EA_Window_FeedbackCategory")

	for categoryIndex, categoryData in pairs(EA_Window_Feedback.feedbackTypes) do
		ComboBoxAddMenuItem( "EA_Window_FeedbackCategory", GetHelpString(categoryData.labelID) )
	end
	
	ComboBoxSetSelectedMenuItem("EA_Window_FeedbackCategory", EA_Window_Feedback.selectedType)
end

function EA_Window_Feedback.Shutdown()

end

function EA_Window_Feedback.Show()
    WindowSetShowing( "EA_Window_Feedback", true )
end

function EA_Window_Feedback.Hide()
    WindowSetShowing( "EA_Window_Feedback", false )
end

function EA_Window_Feedback.ToggleShowing()
    if ( EA_Window_Feedback.IsShowing() == true ) then
        EA_Window_Feedback.Hide()
    else
        EA_Window_Feedback.Show()
    end
end

function EA_Window_Feedback.IsShowing()
    return WindowGetShowing( "EA_Window_Feedback" )
end

function EA_Window_Feedback.Submit()
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

	-- Becasue the ComboBox windows are numbered 1..n, and we need to send the ENUM values, we offset the selected menu item choice here.
	local choiceWindowNumber = ComboBoxGetSelectedMenuItem("EA_Window_FeedbackCategory")
	local FeedbackType = choiceWindowNumber + GameData.Feedback.ENUM_START - 1
	
	SendHelpMessage(GameData.HelpType.CREATE_FEEDBACK, FeedbackType, L"", 
					TextEditBoxGetText("EA_Window_FeedbackText"), 0, L"", 0, L"", 0, L"", 0, L"")

	EA_Window_Feedback.Hide()
end

function EA_Window_Feedback.Back()
	EA_Window_Feedback.Hide()
	EA_Window_Help.OnShown()
end

function EA_Window_Feedback.Clear()
    TextEditBoxSetText( "EA_Window_FeedbackText", L"" )
end

function EA_Window_Feedback.OnShown()
    EA_Window_Feedback.Clear()
end

function EA_Window_Feedback.OnHidden()
    EA_Window_Feedback.Clear()
end

function EA_Window_Feedback.OnSelChangedCategory()
end
