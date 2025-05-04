----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_Appeal = {}

EA_Window_Appeal.topicList = {}
EA_Window_Appeal.topicListOrder = {}

EA_Window_Appeal.topicSelected = 1

EA_Window_Appeal.topicWindows = {}	-- This maintains a list of windows displayed in the main window adjacent the topic list.

EA_Window_Appeal.topics = {} -- This table contains all the windows that should appear for each topic.

-- Yes, yes yes.. at some point we could put these into a .csv file... but not today. or tomorrow. or this milestone.
-- NOTE: Make the first table ALWAYS contain the exact string to be used for the list button as well as the main window header name.
-- NOTE: Don't add any non-templated stuff to .sections because that table is used soley for dynamically creating windows using templates.
-- NOTE: The following embedded tags within a section are used.
--			template	 - REQUIRED. This creates a window based on the template name provided. It's anchored to the previous section window.
--			yOffset		 - REQUIRED. This window will be below the previous window by the given # of pixels. All Windows are corner anchored.
--			labelID		 - (optional) Sets the windows text based on the ID given. The stringID must be located in HelpStrings.txt
--			buttonTextID - (optional) Sets the button text based on the ID given. The stringID must be located in HelpStrings.txt
--			fieldID		 - (optional) Indicates this section is an edit or combo box with a string that gets sent as a parameter to the server.
--			comboBox	 - (optional) Indicates that this section is a combo box. the following are required:
--				.choices		- (required for Combo Box) A table of string IDs whose values must be located in HelpStrings.txt
--				.defaultChoice  - (optional for Combo Box) The default value to set the combobox to. Defaults to the first value in the table.

local violationChoices = 
{
	StringTables.Help.COMBOBOX_CHOICE_VIOLATION_CATEGORY_GENERAL,
	StringTables.Help.COMBOBOX_CHOICE_VIOLATION_CATEGORY_HARASSMENT,
	StringTables.Help.COMBOBOX_CHOICE_VIOLATION_CATEGORY_DISRUPTION,
	StringTables.Help.COMBOBOX_CHOICE_VIOLATION_CATEGORY_XP_FARMING,
	StringTables.Help.COMBOBOX_CHOICE_VIOLATION_CATEGORY_SPEED_HACKING,
	StringTables.Help.COMBOBOX_CHOICE_VIOLATION_CATEGORY_MACROING,
	StringTables.Help.COMBOBOX_CHOICE_VIOLATION_CATEGORY_KILL_STEALING,
	StringTables.Help.COMBOBOX_CHOICE_VIOLATION_CATEGORY_CROSS_REALMING
}

EA_Window_Appeal.topics[GameData.AppealTopic.GOLD_SELLING] = {}
EA_Window_Appeal.topics[GameData.AppealTopic.GOLD_SELLING].messageType = GameData.HelpType.CREATE_APPEAL_GOLD_SELLER
EA_Window_Appeal.topics[GameData.AppealTopic.GOLD_SELLING].topicID = GameData.AppealTopic.GOLD_SELLING
EA_Window_Appeal.topics[GameData.AppealTopic.GOLD_SELLING].sortOrder = 1
EA_Window_Appeal.topics[GameData.AppealTopic.GOLD_SELLING].sections = {}
EA_Window_Appeal.topics[GameData.AppealTopic.GOLD_SELLING].sections[1] = {template="AppealHeaderTemplate",				labelID = StringTables.Help.TOPIC_GOLD_SELLING, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.GOLD_SELLING].sections[2] = {template="AppealLabelMultilineTemplate100",	labelID = StringTables.Help.TOPIC_GOLD_SELLING_NOTE, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.GOLD_SELLING].sections[3] = {template="AppealLabelMultilineTemplate100",	labelID = StringTables.Help.TOPIC_GOLD_SELLING_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.GOLD_SELLING].sections[4] = {template="AppealLabelMultilineTemplate100",	labelID = StringTables.Help.TOPIC_GOLD_SELLING_NOT_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.GOLD_SELLING].sections[5] = {template="AppealLabelTemplate64",				labelID = StringTables.Help.TOPIC_GOLD_SELLING_EDITBOX_NAME_HEADER, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.GOLD_SELLING].sections[6] = {template="AppealEditBoxTemplate64",		tabOrder = 1, fieldID = GameData.HelpField.NAME_REPORTING, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.GOLD_SELLING].sections[7] = {template="AppealLabelMultilineTemplate100",	labelID = StringTables.Help.TOPIC_GOLD_SELLING_EDITBOX_DETAILS_HEADER, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.GOLD_SELLING].sections[8] = {template="AppealEditBoxTemplate1024",		tabOrder = 2, fieldID = GameData.HelpField.DETAILS, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.GOLD_SELLING].sections[9] = {template="AppealButtonTemplate",			buttonTextID = StringTables.Help.BUTTON_APPEAL_SUBMIT, yOffset = 10}

EA_Window_Appeal.topics[GameData.AppealTopic.STUCK] = {}
EA_Window_Appeal.topics[GameData.AppealTopic.STUCK].messageType = GameData.HelpType.CREATE_APPEAL_NON_VALIDATED
EA_Window_Appeal.topics[GameData.AppealTopic.STUCK].topicID = GameData.AppealTopic.STUCK
EA_Window_Appeal.topics[GameData.AppealTopic.STUCK].sortOrder = 2
EA_Window_Appeal.topics[GameData.AppealTopic.STUCK].sections = {}
EA_Window_Appeal.topics[GameData.AppealTopic.STUCK].sections[1] = {template="AppealHeaderTemplate", labelID = StringTables.Help.TOPIC_STUCK, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.STUCK].sections[2] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_STUCK_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.STUCK].sections[3] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_STUCK_NOT_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.STUCK].sections[4] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_STUCK_EDITBOX_HEADER, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.STUCK].sections[5] = {template="AppealEditBoxTemplate1024", fieldID = GameData.HelpField.DETAILS, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.STUCK].sections[6] = {template="AppealButtonTemplate", buttonTextID = StringTables.Help.BUTTON_APPEAL_SUBMIT, yOffset = 10}

EA_Window_Appeal.topics[GameData.AppealTopic.MISSING_CHARACTER] = {}
EA_Window_Appeal.topics[GameData.AppealTopic.MISSING_CHARACTER].messageType = GameData.HelpType.CREATE_APPEAL_NON_VALIDATED
EA_Window_Appeal.topics[GameData.AppealTopic.MISSING_CHARACTER].topicID = GameData.AppealTopic.MISSING_CHARACTER
EA_Window_Appeal.topics[GameData.AppealTopic.MISSING_CHARACTER].sortOrder = 3
EA_Window_Appeal.topics[GameData.AppealTopic.MISSING_CHARACTER].sections = {}
EA_Window_Appeal.topics[GameData.AppealTopic.MISSING_CHARACTER].sections[1] = {template="AppealHeaderTemplate", labelID = StringTables.Help.TOPIC_MISSING_CHARACTER, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.MISSING_CHARACTER].sections[2] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_MISSING_CHARACTER_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.MISSING_CHARACTER].sections[3] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_MISSING_CHARACTER_NOT_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.MISSING_CHARACTER].sections[4] = {template="AppealLabelTemplate64", labelID = StringTables.Help.TOPIC_MISSING_CHARACTER_EDITBOX_HEADER_NAME, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.MISSING_CHARACTER].sections[5] = {template="AppealEditBoxTemplate64", tabOrder = 1, fieldID = GameData.HelpField.NAME_REPORTING, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.MISSING_CHARACTER].sections[6] = {template="AppealLabelTemplate64", labelID = StringTables.Help.TOPIC_MISSING_CHARACTER_EDITBOX_HEADER_CAREER, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.MISSING_CHARACTER].sections[7] = {template="AppealEditBoxTemplate64", tabOrder = 2, fieldID = GameData.HelpField.CAREER, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.MISSING_CHARACTER].sections[8] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_MISSING_CHARACTER_EDITBOX_HEADER_DETAILS, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.MISSING_CHARACTER].sections[9] = {template="AppealEditBoxTemplate1024", tabOrder = 3, fieldID = GameData.HelpField.DETAILS, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.MISSING_CHARACTER].sections[10]= {template="AppealButtonTemplate", buttonTextID = StringTables.Help.BUTTON_APPEAL_SUBMIT, yOffset = 10}

EA_Window_Appeal.topics[GameData.AppealTopic.MISSING_ITEM] = {}
EA_Window_Appeal.topics[GameData.AppealTopic.MISSING_ITEM].messageType = GameData.HelpType.CREATE_APPEAL_NON_VALIDATED
EA_Window_Appeal.topics[GameData.AppealTopic.MISSING_ITEM].topicID = GameData.AppealTopic.MISSING_ITEM
EA_Window_Appeal.topics[GameData.AppealTopic.MISSING_ITEM].sortOrder = 4
EA_Window_Appeal.topics[GameData.AppealTopic.MISSING_ITEM].sections = {}
EA_Window_Appeal.topics[GameData.AppealTopic.MISSING_ITEM].sections[1] = {template="AppealHeaderTemplate", labelID = StringTables.Help.TOPIC_MISSING_ITEM, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.MISSING_ITEM].sections[2] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_MISSING_ITEM_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.MISSING_ITEM].sections[3] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_MISSING_ITEM_NOT_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.MISSING_ITEM].sections[4] = {template="AppealLabelTemplate64", labelID = StringTables.Help.TOPIC_MISSING_ITEM_EDITBOX_MISSING_ITEM_HEADER, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.MISSING_ITEM].sections[5] = {template="AppealEditBoxTemplate64", tabOrder = 1, fieldID = GameData.HelpField.ITEM_NAME, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.MISSING_ITEM].sections[6] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_MISSING_ITEM_EDITBOX_DETAILS_HEADER, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.MISSING_ITEM].sections[7] = {template="AppealEditBoxTemplate1024", tabOrder = 2, fieldID = GameData.HelpField.DETAILS, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.MISSING_ITEM].sections[8] = {template="AppealButtonTemplate", buttonTextID = StringTables.Help.BUTTON_APPEAL_SUBMIT, yOffset = 10}

EA_Window_Appeal.topics[GameData.AppealTopic.VIOLATION_REPORT] = {}
EA_Window_Appeal.topics[GameData.AppealTopic.VIOLATION_REPORT].messageType = GameData.HelpType.CREATE_APPEAL_VIOLATION_REPORT
EA_Window_Appeal.topics[GameData.AppealTopic.VIOLATION_REPORT].topicID = GameData.AppealTopic.VIOLATION_REPORT
EA_Window_Appeal.topics[GameData.AppealTopic.VIOLATION_REPORT].sortOrder = 5
EA_Window_Appeal.topics[GameData.AppealTopic.VIOLATION_REPORT].sections = {}
EA_Window_Appeal.topics[GameData.AppealTopic.VIOLATION_REPORT].sections[1] = {template="AppealHeaderTemplate", labelID = StringTables.Help.TOPIC_VIOLATION_REPORT, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.VIOLATION_REPORT].sections[2] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_VIOLATION_REPORT_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.VIOLATION_REPORT].sections[3] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_VIOLATION_REPORT_NOT_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.VIOLATION_REPORT].sections[4] = {template="AppealComboBoxTemplate", fieldID = GameData.HelpField.CATEGORY, comboBox = true, comboboxChoices = violationChoices, defaultChoice = 1, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.VIOLATION_REPORT].sections[5] = {template="AppealLabelTemplate64", labelID = StringTables.Help.TOPIC_VIOLATION_REPORT_EDITBOX1_HEADER, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.VIOLATION_REPORT].sections[6] = {template="AppealEditBoxTemplate64", tabOrder = 1, fieldID = GameData.HelpField.NAME_REPORTING, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.VIOLATION_REPORT].sections[7] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_VIOLATION_REPORT_EDITBOX2_HEADER, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.VIOLATION_REPORT].sections[8] = {template="AppealEditBoxTemplate1024", tabOrder = 2, fieldID = GameData.HelpField.DETAILS, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.VIOLATION_REPORT].sections[9] = {template="AppealButtonTemplate", buttonTextID = StringTables.Help.BUTTON_APPEAL_SUBMIT, yOffset = 10}

EA_Window_Appeal.topics[GameData.AppealTopic.NAMING_VIOLATION] = {}
EA_Window_Appeal.topics[GameData.AppealTopic.NAMING_VIOLATION].messageType = GameData.HelpType.CREATE_APPEAL_NAMING_VIOLATION
EA_Window_Appeal.topics[GameData.AppealTopic.NAMING_VIOLATION].topicID = GameData.AppealTopic.NAMING_VIOLATION
EA_Window_Appeal.topics[GameData.AppealTopic.NAMING_VIOLATION].sortOrder = 6
EA_Window_Appeal.topics[GameData.AppealTopic.NAMING_VIOLATION].sections = {}
EA_Window_Appeal.topics[GameData.AppealTopic.NAMING_VIOLATION].sections[1] = {template="AppealHeaderTemplate", labelID = StringTables.Help.TOPIC_NAMING_VIOLATION, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.NAMING_VIOLATION].sections[2] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_NAMING_VIOLATION_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.NAMING_VIOLATION].sections[3] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_NAMING_VIOLATION_NOT_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.NAMING_VIOLATION].sections[4] = {template="AppealLabelTemplate64", labelID = StringTables.Help.TOPIC_NAMING_VIOLATION_EDITBOX1_HEADER, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.NAMING_VIOLATION].sections[5] = {template="AppealEditBoxTemplate64", tabOrder = 1, fieldID = GameData.HelpField.NAME_REPORTING, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.NAMING_VIOLATION].sections[6] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_NAMING_VIOLATION_EDITBOX2_HEADER, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.NAMING_VIOLATION].sections[7] = {template="AppealEditBoxTemplate1024", tabOrder = 2, fieldID = GameData.HelpField.DETAILS, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.NAMING_VIOLATION].sections[8] = {template="AppealButtonTemplate", buttonTextID = StringTables.Help.BUTTON_APPEAL_SUBMIT, yOffset = 10}

EA_Window_Appeal.topics[GameData.AppealTopic.CHARACTER_ISSUES] = {}
EA_Window_Appeal.topics[GameData.AppealTopic.CHARACTER_ISSUES].messageType = GameData.HelpType.CREATE_APPEAL_NON_VALIDATED
EA_Window_Appeal.topics[GameData.AppealTopic.CHARACTER_ISSUES].topicID = GameData.AppealTopic.CHARACTER_ISSUES
EA_Window_Appeal.topics[GameData.AppealTopic.CHARACTER_ISSUES].sortOrder = 7
EA_Window_Appeal.topics[GameData.AppealTopic.CHARACTER_ISSUES].sections = {}
EA_Window_Appeal.topics[GameData.AppealTopic.CHARACTER_ISSUES].sections[1] = {template="AppealHeaderTemplate", labelID = StringTables.Help.TOPIC_CHARACTER_ISSUE, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.CHARACTER_ISSUES].sections[2] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_CHARACTER_ISSUE_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.CHARACTER_ISSUES].sections[3] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_CHARACTER_ISSUE_NOT_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.CHARACTER_ISSUES].sections[4] = {template="AppealLabelTemplate64", labelID = StringTables.Help.TOPIC_CHARACTER_ISSUE_EDITBOX_HEADER_CAREER, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.CHARACTER_ISSUES].sections[5] = {template="AppealEditBoxTemplate64", tabOrder = 1, fieldID = GameData.HelpField.CAREER, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.CHARACTER_ISSUES].sections[6] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_CHARACTER_ISSUE_EDITBOX_HEADER_DETAILS, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.CHARACTER_ISSUES].sections[7] = {template="AppealEditBoxTemplate1024", tabOrder = 2, fieldID = GameData.HelpField.DETAILS, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.CHARACTER_ISSUES].sections[8] = {template="AppealButtonTemplate", buttonTextID = StringTables.Help.BUTTON_APPEAL_SUBMIT, yOffset = 10}

EA_Window_Appeal.topics[GameData.AppealTopic.PAIDITEM] = {}
EA_Window_Appeal.topics[GameData.AppealTopic.PAIDITEM].messageType = GameData.HelpType.CREATE_APPEAL_NON_VALIDATED
EA_Window_Appeal.topics[GameData.AppealTopic.PAIDITEM].topicID = GameData.AppealTopic.PAIDITEM
EA_Window_Appeal.topics[GameData.AppealTopic.PAIDITEM].sortOrder = 7
EA_Window_Appeal.topics[GameData.AppealTopic.PAIDITEM].sections = {}
EA_Window_Appeal.topics[GameData.AppealTopic.PAIDITEM].sections[1] = {template="AppealHeaderTemplate", labelID = StringTables.Help.TOPIC_PAIDITEM, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.PAIDITEM].sections[2] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_PAIDITEM_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.PAIDITEM].sections[3] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_PAIDITEM_NOT_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.PAIDITEM].sections[4] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_PAIDITEM_EDITBOX_HEADER, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.PAIDITEM].sections[5] = {template="AppealEditBoxTemplate1024", fieldID = GameData.HelpField.DETAILS, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.PAIDITEM].sections[6] = {template="AppealButtonTemplate", buttonTextID = StringTables.Help.BUTTON_APPEAL_SUBMIT, yOffset = 10}

EA_Window_Appeal.topics[GameData.AppealTopic.PAIDXFER] = {}
EA_Window_Appeal.topics[GameData.AppealTopic.PAIDXFER].messageType = GameData.HelpType.CREATE_APPEAL_NON_VALIDATED
EA_Window_Appeal.topics[GameData.AppealTopic.PAIDXFER].topicID = GameData.AppealTopic.PAIDXFER
EA_Window_Appeal.topics[GameData.AppealTopic.PAIDXFER].sortOrder = 8
EA_Window_Appeal.topics[GameData.AppealTopic.PAIDXFER].sections = {}
EA_Window_Appeal.topics[GameData.AppealTopic.PAIDXFER].sections[1] = {template="AppealHeaderTemplate", labelID = StringTables.Help.TOPIC_PAIDXFER, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.PAIDXFER].sections[2] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_PAIDXFER_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.PAIDXFER].sections[3] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_PAIDXFER_NOT_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.PAIDXFER].sections[4] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_PAIDXFER_EDITBOX_HEADER, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.PAIDXFER].sections[5] = {template="AppealEditBoxTemplate1024", fieldID = GameData.HelpField.DETAILS, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.PAIDXFER].sections[6] = {template="AppealButtonTemplate", buttonTextID = StringTables.Help.BUTTON_APPEAL_SUBMIT, yOffset = 10}

EA_Window_Appeal.topics[GameData.AppealTopic.PAIDNAME] = {}
EA_Window_Appeal.topics[GameData.AppealTopic.PAIDNAME].messageType = GameData.HelpType.CREATE_APPEAL_NON_VALIDATED
EA_Window_Appeal.topics[GameData.AppealTopic.PAIDNAME].topicID = GameData.AppealTopic.PAIDNAME
EA_Window_Appeal.topics[GameData.AppealTopic.PAIDNAME].sortOrder = 9
EA_Window_Appeal.topics[GameData.AppealTopic.PAIDNAME].sections = {}
EA_Window_Appeal.topics[GameData.AppealTopic.PAIDNAME].sections[1] = {template="AppealHeaderTemplate", labelID = StringTables.Help.TOPIC_PAIDNAME, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.PAIDNAME].sections[2] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_PAIDNAME_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.PAIDNAME].sections[3] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_PAIDNAME_NOT_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.PAIDNAME].sections[4] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_PAIDNAME_EDITBOX_HEADER, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.PAIDNAME].sections[5] = {template="AppealEditBoxTemplate1024", fieldID = GameData.HelpField.DETAILS, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.PAIDNAME].sections[6] = {template="AppealButtonTemplate", buttonTextID = StringTables.Help.BUTTON_APPEAL_SUBMIT, yOffset = 10}

EA_Window_Appeal.topics[GameData.AppealTopic.PUBLIC_QUEST] = {}
EA_Window_Appeal.topics[GameData.AppealTopic.PUBLIC_QUEST].messageType = GameData.HelpType.CREATE_APPEAL_NON_VALIDATED
EA_Window_Appeal.topics[GameData.AppealTopic.PUBLIC_QUEST].topicID = GameData.AppealTopic.PUBLIC_QUEST
EA_Window_Appeal.topics[GameData.AppealTopic.PUBLIC_QUEST].sortOrder = 10
EA_Window_Appeal.topics[GameData.AppealTopic.PUBLIC_QUEST].sections = {}
EA_Window_Appeal.topics[GameData.AppealTopic.PUBLIC_QUEST].sections[1] = {template="AppealHeaderTemplate", labelID = StringTables.Help.TOPIC_PQ, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.PUBLIC_QUEST].sections[2] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_PQ_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.PUBLIC_QUEST].sections[3] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_PQ_NOT_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.PUBLIC_QUEST].sections[4] = {template="AppealLabelTemplate64", labelID = StringTables.Help.TOPIC_PQ_EDITBOX_HEADER_PQ_NAME, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.PUBLIC_QUEST].sections[5] = {template="AppealEditBoxTemplate64", tabOrder = 1, fieldID = GameData.HelpField.PUBLIC_QUEST_NAME, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.PUBLIC_QUEST].sections[6] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_PQ_EDITBOX_HEADER_DETAILS, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.PUBLIC_QUEST].sections[7] = {template="AppealEditBoxTemplate1024", tabOrder = 2, fieldID = GameData.HelpField.DETAILS, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.PUBLIC_QUEST].sections[8] = {template="AppealButtonTemplate", buttonTextID = StringTables.Help.BUTTON_APPEAL_SUBMIT, yOffset = 10}

EA_Window_Appeal.topics[GameData.AppealTopic.SCENARIO] = {}
EA_Window_Appeal.topics[GameData.AppealTopic.SCENARIO].messageType = GameData.HelpType.CREATE_APPEAL_NON_VALIDATED
EA_Window_Appeal.topics[GameData.AppealTopic.SCENARIO].topicID = GameData.AppealTopic.SCENARIO
EA_Window_Appeal.topics[GameData.AppealTopic.SCENARIO].sortOrder = 11
EA_Window_Appeal.topics[GameData.AppealTopic.SCENARIO].sections = {}
EA_Window_Appeal.topics[GameData.AppealTopic.SCENARIO].sections[1] = {template="AppealHeaderTemplate", labelID = StringTables.Help.TOPIC_SCENARIO, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.SCENARIO].sections[2] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_SCENARIO_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.SCENARIO].sections[3] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_SCENARIO_NOT_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.SCENARIO].sections[4] = {template="AppealLabelTemplate64", labelID = StringTables.Help.TOPIC_SCENARIO_EDITBOX_HEADER_SCENARIO_NAME, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.SCENARIO].sections[5] = {template="AppealEditBoxTemplate64", tabOrder = 1, fieldID = GameData.HelpField.SCENARIO_NAME, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.SCENARIO].sections[6] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_SCENARIO_EDITBOX_HEADER_DETAILS, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.SCENARIO].sections[7] = {template="AppealEditBoxTemplate1024", tabOrder = 2, fieldID = GameData.HelpField.DETAILS, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.SCENARIO].sections[8] = {template="AppealButtonTemplate", buttonTextID = StringTables.Help.BUTTON_APPEAL_SUBMIT, yOffset = 10}

EA_Window_Appeal.topics[GameData.AppealTopic.BATTLEFIELD_OBJECTIVES_AND_KEEPS] = {}
EA_Window_Appeal.topics[GameData.AppealTopic.BATTLEFIELD_OBJECTIVES_AND_KEEPS].messageType = GameData.HelpType.CREATE_APPEAL_NON_VALIDATED
EA_Window_Appeal.topics[GameData.AppealTopic.BATTLEFIELD_OBJECTIVES_AND_KEEPS].topicID = GameData.AppealTopic.BATTLEFIELD_OBJECTIVES_AND_KEEPS
EA_Window_Appeal.topics[GameData.AppealTopic.BATTLEFIELD_OBJECTIVES_AND_KEEPS].sortOrder = 12
EA_Window_Appeal.topics[GameData.AppealTopic.BATTLEFIELD_OBJECTIVES_AND_KEEPS].sections = {}
EA_Window_Appeal.topics[GameData.AppealTopic.BATTLEFIELD_OBJECTIVES_AND_KEEPS].sections[1] = {template="AppealHeaderTemplate", labelID = StringTables.Help.TOPIC_BO_KEEP, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.BATTLEFIELD_OBJECTIVES_AND_KEEPS].sections[2] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_BO_KEEP_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.BATTLEFIELD_OBJECTIVES_AND_KEEPS].sections[3] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_BO_KEEP_NOT_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.BATTLEFIELD_OBJECTIVES_AND_KEEPS].sections[4] = {template="AppealLabelTemplate64", labelID = StringTables.Help.TOPIC_BO_KEEP_EDITBOX1_HEADER, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.BATTLEFIELD_OBJECTIVES_AND_KEEPS].sections[5] = {template="AppealEditBoxTemplate64", tabOrder = 1, fieldID = GameData.HelpField.BATTLEFIELD_OBJECTIVE_NAME, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.BATTLEFIELD_OBJECTIVES_AND_KEEPS].sections[6] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_BO_KEEP_EDITBOX2_HEADER, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.BATTLEFIELD_OBJECTIVES_AND_KEEPS].sections[7] = {template="AppealEditBoxTemplate1024", tabOrder = 2, fieldID = GameData.HelpField.DETAILS, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.BATTLEFIELD_OBJECTIVES_AND_KEEPS].sections[8] = {template="AppealButtonTemplate", buttonTextID = StringTables.Help.BUTTON_APPEAL_SUBMIT, yOffset = 10}

EA_Window_Appeal.topics[GameData.AppealTopic.MONSTER_ISSUE] = {}
EA_Window_Appeal.topics[GameData.AppealTopic.MONSTER_ISSUE].messageType = GameData.HelpType.CREATE_APPEAL_NON_VALIDATED
EA_Window_Appeal.topics[GameData.AppealTopic.MONSTER_ISSUE].topicID = GameData.AppealTopic.MONSTER_ISSUE
EA_Window_Appeal.topics[GameData.AppealTopic.MONSTER_ISSUE].sortOrder = 13
EA_Window_Appeal.topics[GameData.AppealTopic.MONSTER_ISSUE].sections = {}
EA_Window_Appeal.topics[GameData.AppealTopic.MONSTER_ISSUE].sections[1] = {template="AppealHeaderTemplate", labelID = StringTables.Help.TOPIC_MONSTER, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.MONSTER_ISSUE].sections[2] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_MONSTER_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.MONSTER_ISSUE].sections[3] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_MONSTER_NOT_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.MONSTER_ISSUE].sections[4] = {template="AppealLabelTemplate64", labelID = StringTables.Help.TOPIC_MONSTER_EDITBOX1_HEADER, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.MONSTER_ISSUE].sections[5] = {template="AppealEditBoxTemplate64", tabOrder = 1, fieldID = GameData.HelpField.MONSTER_NAME, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.MONSTER_ISSUE].sections[6] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_MONSTER_EDITBOX2_HEADER, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.MONSTER_ISSUE].sections[7] = {template="AppealEditBoxTemplate1024", tabOrder = 2, fieldID = GameData.HelpField.DETAILS, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.MONSTER_ISSUE].sections[8] = {template="AppealButtonTemplate", buttonTextID = StringTables.Help.BUTTON_APPEAL_SUBMIT, yOffset = 10}

EA_Window_Appeal.topics[GameData.AppealTopic.QUEST_AND_QUEST_ITEMS] = {}
EA_Window_Appeal.topics[GameData.AppealTopic.QUEST_AND_QUEST_ITEMS].messageType = GameData.HelpType.CREATE_APPEAL_NON_VALIDATED
EA_Window_Appeal.topics[GameData.AppealTopic.QUEST_AND_QUEST_ITEMS].topicID = GameData.AppealTopic.QUEST_AND_QUEST_ITEMS
EA_Window_Appeal.topics[GameData.AppealTopic.QUEST_AND_QUEST_ITEMS].sortOrder = 14
EA_Window_Appeal.topics[GameData.AppealTopic.QUEST_AND_QUEST_ITEMS].sections = {}
EA_Window_Appeal.topics[GameData.AppealTopic.QUEST_AND_QUEST_ITEMS].sections[1] = {template="AppealHeaderTemplate", labelID = StringTables.Help.TOPIC_QUESTS, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.QUEST_AND_QUEST_ITEMS].sections[2] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_QUESTS_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.QUEST_AND_QUEST_ITEMS].sections[3] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_QUESTS_NOT_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.QUEST_AND_QUEST_ITEMS].sections[4] = {template="AppealLabelTemplate64", labelID = StringTables.Help.TOPIC_QUESTS_EDITBOX1_HEADER, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.QUEST_AND_QUEST_ITEMS].sections[5] = {template="AppealEditBoxTemplate64", tabOrder = 1, fieldID = GameData.HelpField.QUEST_NAME, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.QUEST_AND_QUEST_ITEMS].sections[6] = {template="AppealLabelTemplate64", labelID = StringTables.Help.TOPIC_QUESTS_EDITBOX2_HEADER, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.QUEST_AND_QUEST_ITEMS].sections[7] = {template="AppealEditBoxTemplateNumbers", tabOrder = 2, fieldID = GameData.HelpField.QUEST_STEP, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.QUEST_AND_QUEST_ITEMS].sections[8] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_QUESTS_EDITBOX3_HEADER, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.QUEST_AND_QUEST_ITEMS].sections[9] = {template="AppealEditBoxTemplate1024", tabOrder = 3, fieldID = GameData.HelpField.DETAILS, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.QUEST_AND_QUEST_ITEMS].sections[10]= {template="AppealButtonTemplate", buttonTextID = StringTables.Help.BUTTON_APPEAL_SUBMIT, yOffset = 10}

EA_Window_Appeal.topics[GameData.AppealTopic.COMBAT_OR_SKIRMISH] = {}
EA_Window_Appeal.topics[GameData.AppealTopic.COMBAT_OR_SKIRMISH].messageType = GameData.HelpType.CREATE_APPEAL_NON_VALIDATED
EA_Window_Appeal.topics[GameData.AppealTopic.COMBAT_OR_SKIRMISH].topicID = GameData.AppealTopic.COMBAT_OR_SKIRMISH
EA_Window_Appeal.topics[GameData.AppealTopic.COMBAT_OR_SKIRMISH].sortOrder = 15
EA_Window_Appeal.topics[GameData.AppealTopic.COMBAT_OR_SKIRMISH].sections = {}
EA_Window_Appeal.topics[GameData.AppealTopic.COMBAT_OR_SKIRMISH].sections[1] = {template="AppealHeaderTemplate", labelID = StringTables.Help.TOPIC_COMBAT, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.COMBAT_OR_SKIRMISH].sections[2] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_COMBAT_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.COMBAT_OR_SKIRMISH].sections[3] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_COMBAT_NOT_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.COMBAT_OR_SKIRMISH].sections[4] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_COMBAT_EDITBOX_HEADER, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.COMBAT_OR_SKIRMISH].sections[5] = {template="AppealEditBoxTemplate1024", tabOrder = 2, fieldID = GameData.HelpField.DETAILS, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.COMBAT_OR_SKIRMISH].sections[6] = {template="AppealButtonTemplate", buttonTextID = StringTables.Help.BUTTON_APPEAL_SUBMIT, yOffset = 10}

EA_Window_Appeal.topics[GameData.AppealTopic.TOME_OF_KNOWLEDGE] = {}
EA_Window_Appeal.topics[GameData.AppealTopic.TOME_OF_KNOWLEDGE].messageType = GameData.HelpType.CREATE_APPEAL_NON_VALIDATED
EA_Window_Appeal.topics[GameData.AppealTopic.TOME_OF_KNOWLEDGE].topicID = GameData.AppealTopic.TOME_OF_KNOWLEDGE
EA_Window_Appeal.topics[GameData.AppealTopic.TOME_OF_KNOWLEDGE].sortOrder = 16
EA_Window_Appeal.topics[GameData.AppealTopic.TOME_OF_KNOWLEDGE].sections = {}
EA_Window_Appeal.topics[GameData.AppealTopic.TOME_OF_KNOWLEDGE].sections[1] = {template="AppealHeaderTemplate", labelID = StringTables.Help.TOPIC_TOME, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.TOME_OF_KNOWLEDGE].sections[2] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_TOME_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.TOME_OF_KNOWLEDGE].sections[3] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_TOME_NOT_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.TOME_OF_KNOWLEDGE].sections[4] = {template="AppealLabelTemplate64", labelID = StringTables.Help.TOPIC_TOME_EDITBOX1_HEADER, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.TOME_OF_KNOWLEDGE].sections[5] = {template="AppealEditBoxTemplate64", tabOrder = 1, fieldID = GameData.HelpField.TOME_ENTRY, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.TOME_OF_KNOWLEDGE].sections[6] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_TOME_EDITBOX2_HEADER, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.TOME_OF_KNOWLEDGE].sections[7] = {template="AppealEditBoxTemplate1024", tabOrder = 2, fieldID = GameData.HelpField.DETAILS, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.TOME_OF_KNOWLEDGE].sections[8] = {template="AppealButtonTemplate", buttonTextID = StringTables.Help.BUTTON_APPEAL_SUBMIT, yOffset = 10}

EA_Window_Appeal.topics[GameData.AppealTopic.MAIL] = {}
EA_Window_Appeal.topics[GameData.AppealTopic.MAIL].messageType = GameData.HelpType.CREATE_APPEAL_NON_VALIDATED
EA_Window_Appeal.topics[GameData.AppealTopic.MAIL].topicID = GameData.AppealTopic.MAIL
EA_Window_Appeal.topics[GameData.AppealTopic.MAIL].sortOrder = 17
EA_Window_Appeal.topics[GameData.AppealTopic.MAIL].sections = {}
EA_Window_Appeal.topics[GameData.AppealTopic.MAIL].sections[1] = {template="AppealHeaderTemplate", labelID = StringTables.Help.TOPIC_MAIL, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.MAIL].sections[2] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_MAIL_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.MAIL].sections[3] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_MAIL_NOT_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.MAIL].sections[4] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_MAIL_EDITBOX_HEADER, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.MAIL].sections[5] = {template="AppealEditBoxTemplate1024", tabOrder = 1, fieldID = GameData.HelpField.DETAILS, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.MAIL].sections[6] = {template="AppealButtonTemplate", buttonTextID = StringTables.Help.BUTTON_APPEAL_SUBMIT, yOffset = 10}

EA_Window_Appeal.topics[GameData.AppealTopic.AUCTION_HOUSE] = {}
EA_Window_Appeal.topics[GameData.AppealTopic.AUCTION_HOUSE].messageType = GameData.HelpType.CREATE_APPEAL_NON_VALIDATED
EA_Window_Appeal.topics[GameData.AppealTopic.AUCTION_HOUSE].topicID = GameData.AppealTopic.AUCTION_HOUSE
EA_Window_Appeal.topics[GameData.AppealTopic.AUCTION_HOUSE].sortOrder = 18
EA_Window_Appeal.topics[GameData.AppealTopic.AUCTION_HOUSE].sections = {}
EA_Window_Appeal.topics[GameData.AppealTopic.AUCTION_HOUSE].sections[1] = {template="AppealHeaderTemplate", labelID = StringTables.Help.TOPIC_AUCTION_HOUSE, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.AUCTION_HOUSE].sections[2] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_AUCTION_HOUSE_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.AUCTION_HOUSE].sections[3] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_AUCTION_HOUSE_NOT_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.AUCTION_HOUSE].sections[4] = {template="AppealLabelTemplate64", labelID = StringTables.Help.TOPIC_AUCTION_HOUSE_EDITBOX1_HEADER, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.AUCTION_HOUSE].sections[5] = {template="AppealEditBoxTemplate64", tabOrder = 1, fieldID = GameData.HelpField.ITEM_NAME, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.AUCTION_HOUSE].sections[6] = {template="AppealLabelTemplate64", labelID = StringTables.Help.TOPIC_AUCTION_HOUSE_EDITBOX2_HEADER, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.AUCTION_HOUSE].sections[7] = {template="AppealEditBoxTemplate64", tabOrder = 2, fieldID = GameData.HelpField.PRICE, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.AUCTION_HOUSE].sections[8] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_AUCTION_HOUSE_EDITBOX3_HEADER, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.AUCTION_HOUSE].sections[9] = {template="AppealEditBoxTemplate1024", tabOrder = 3, fieldID = GameData.HelpField.DETAILS, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.AUCTION_HOUSE].sections[10]= {template="AppealButtonTemplate", buttonTextID = StringTables.Help.BUTTON_APPEAL_SUBMIT, yOffset = 10}

EA_Window_Appeal.topics[GameData.AppealTopic.INTERFACE] = {}
EA_Window_Appeal.topics[GameData.AppealTopic.INTERFACE].messageType = GameData.HelpType.CREATE_APPEAL_NON_VALIDATED
EA_Window_Appeal.topics[GameData.AppealTopic.INTERFACE].topicID = GameData.AppealTopic.INTERFACE
EA_Window_Appeal.topics[GameData.AppealTopic.INTERFACE].sortOrder = 19
EA_Window_Appeal.topics[GameData.AppealTopic.INTERFACE].sections = {}
EA_Window_Appeal.topics[GameData.AppealTopic.INTERFACE].sections[1] = {template="AppealHeaderTemplate", labelID = StringTables.Help.TOPIC_INTERFACE, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.INTERFACE].sections[2] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_INTERFACE_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.INTERFACE].sections[3] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_INTERFACE_NOT_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.INTERFACE].sections[4] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_INTERFACE_EDITBOX_HEADER, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.INTERFACE].sections[5] = {template="AppealEditBoxTemplate1024", tabOrder = 1, fieldID = GameData.HelpField.DETAILS, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.INTERFACE].sections[6] = {template="AppealButtonTemplate", buttonTextID = StringTables.Help.BUTTON_APPEAL_SUBMIT, yOffset = 10}

EA_Window_Appeal.topics[GameData.AppealTopic.TRADESKILL] = {}
EA_Window_Appeal.topics[GameData.AppealTopic.TRADESKILL].messageType = GameData.HelpType.CREATE_APPEAL_NON_VALIDATED
EA_Window_Appeal.topics[GameData.AppealTopic.TRADESKILL].topicID = GameData.AppealTopic.TRADESKILL
EA_Window_Appeal.topics[GameData.AppealTopic.TRADESKILL].sortOrder = 20
EA_Window_Appeal.topics[GameData.AppealTopic.TRADESKILL].sections = {}
EA_Window_Appeal.topics[GameData.AppealTopic.TRADESKILL].sections[1] = {template="AppealHeaderTemplate", labelID = StringTables.Help.TOPIC_TRADESKILLS, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.TRADESKILL].sections[2] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_TRADESKILLS_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.TRADESKILL].sections[3] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_TRADESKILLS_NOT_FOR, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.TRADESKILL].sections[4] = {template="AppealLabelTemplate64", labelID = StringTables.Help.TOPIC_TRADESKILLS_EDITBOX1_HEADER, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.TRADESKILL].sections[5] = {template="AppealEditBoxTemplate64", tabOrder = 1, fieldID = GameData.HelpField.SKILL_NAME, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.TRADESKILL].sections[6] = {template="AppealLabelMultilineTemplate100", labelID = StringTables.Help.TOPIC_TRADESKILLS_EDITBOX2_HEADER, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.TRADESKILL].sections[7] = {template="AppealEditBoxTemplate1024", tabOrder = 2, fieldID = GameData.HelpField.DETAILS, yOffset = 10}
EA_Window_Appeal.topics[GameData.AppealTopic.TRADESKILL].sections[8] = {template="AppealButtonTemplate", buttonTextID = StringTables.Help.BUTTON_APPEAL_SUBMIT, yOffset = 10}

-- This function compares 2 topics purposes of sorting them in the list.
local function CompareTopics( index1, index2 )
    if( index2 == nil ) then
        return false
    end

    local topic1 = EA_Window_Appeal.topics[index1]
    local topic2 = EA_Window_Appeal.topics[index2]
    
    if (topic1 == nil or topic1.sortOrder == nil) then
        return false
    end
    
    if (topic2 == nil or topic2.sortOrder == nil) then
        return true
    end

    -- Data driven sorting. No alphabetical or other sorting methods are desired.
    if topic1.sortOrder == topic2.sortOrder then	-- if they match, then don't sort)
        return true
    end

    return ( topic1.sortOrder < topic2.sortOrder )
end

function EA_Window_Appeal.Initialize()

	EA_Window_Appeal.InitializeTopicData()

    LabelSetText( "EA_Window_AppealTitleBarText", GetHelpString( StringTables.Help.TEXT_HELP_TITLE_BAR) )
	LabelSetText( "EA_Window_AppealHeaderText", GetHelpString( StringTables.Help.HEADER_HELP_APPEAL) )

    ButtonSetText( "EA_Window_AppealBack", GetHelpString( StringTables.Help.BUTTON_BACK))
   
    EA_Window_Appeal.SetListRowTints()

	WindowRegisterEventHandler( "EA_Window_Appeal", SystemData.Events.REPORT_GOLD_SELLER, "EA_Window_Appeal.ReportGoldSeller")
end

function EA_Window_Appeal.InitializeTopicData()

	EA_Window_Appeal.topicList = {}
	

	-- Add the Topic Names to the list of Topics.
	local entry = {}
	for topicIndex, topicData in pairs( EA_Window_Appeal.topics ) do
		entry = { name=GetHelpString(topicData.sections[1].labelID) }
		table.insert(EA_Window_Appeal.topicList, entry)
    end

	EA_Window_Appeal.FilterTopicList()
end

-- If there is already an outstanding appeal, only show the "Black Hole" appeals.
function EA_Window_Appeal.FilterTopicList()
	EA_Window_Appeal.topicListOrder = {}
	
	local appealExists = EA_Window_Help.IsThereAnActiveAppeal()
	
    for dataIndex, data in ipairs( EA_Window_Appeal.topicList ) do
		if appealExists then		-- If an appeal already exists, then only list the Black Hole appeal types.
			if (EA_Window_Appeal.DoesAppealRequireCSResponse(dataIndex) == false) then
				table.insert(EA_Window_Appeal.topicListOrder, dataIndex)
			end
		else						-- If no appeal exists, then add all appeal types.
			table.insert(EA_Window_Appeal.topicListOrder, dataIndex)
		end
    end
    
	table.sort( EA_Window_Appeal.topicListOrder, CompareTopics )

    -- Tell the listbox which ListOrder to use    
    ListBoxSetDisplayOrder( "EA_Window_AppealTopicListBox", EA_Window_Appeal.topicListOrder )
end

function EA_Window_Appeal.DoesAppealRequireCSResponse(appealType)
	-- Sadly, there's no way the client can know what appeal types copter recognizes as "Black Holes", so we'll just hard check them.
	if appealType == GameData.AppealTopic.VIOLATION_REPORT or
		appealType == GameData.AppealTopic.NAMING_VIOLATION or 
		appealType == GameData.AppealTopic.GOLD_SELLING
	then
		return false
	else
		return true
	end
end

function EA_Window_Appeal.SetupComboBox(comboBoxName, tableOfComboBoxChoices, defaultChoice)
    ComboBoxClearMenuItems(comboBoxName)
    for choiceIndex, choiceData in pairs(tableOfComboBoxChoices) do
		ComboBoxAddMenuItem( comboBoxName, GetHelpString(choiceData) )
	end
	ComboBoxSetSelectedMenuItem(comboBoxName, defaultChoice )
end

function EA_Window_Appeal.Shutdown()
end

function EA_Window_Appeal.Show()
    WindowSetShowing( "EA_Window_Appeal", true )
    EA_Window_Appeal.topicSelected = 0
	EA_Window_Appeal.SetTopicSelected(GameData.AppealTopic.GOLD_SELLING)
end

function EA_Window_Appeal.Hide()
    WindowSetShowing( "EA_Window_Appeal", false )
end

function EA_Window_Appeal.ToggleShowing()
    if ( EA_Window_Appeal.IsShowing() == true ) then
        EA_Window_Appeal.Hide()
    else
        EA_Window_Appeal.Show()
    end
end

function EA_Window_Appeal.IsShowing()
    return WindowGetShowing( "EA_Window_Appeal" )
end

function EA_Window_Appeal.Back()
	EA_Window_Appeal.Hide()
	EA_Window_Help.OnShown()
end

function EA_Window_Appeal.OnShown()
end

function EA_Window_Appeal.OnHidden()
end

----------------------------------
-- List Functions
----------------------------------

-- <Callback> from the listbox
function EA_Window_Appeal.populateTopicList()
end

function EA_Window_Appeal.SetListRowTints()
	local row_mod = 0
	local color = {}
	local targetRowWindow = ""

	for row, data in ipairs (EA_Window_AppealTopicListBox.PopulatorIndices) do
        row_mod = math.mod(row, 2)
        color = DataUtils.GetAlternatingRowColor( row_mod )
        
        targetRowWindow = "EA_Window_AppealTopicListBoxRow"..row
        WindowSetTintColor(targetRowWindow.."Background", color.r, color.g, color.b )
        WindowSetAlpha(targetRowWindow.."Background", color.a )
    end
end

function EA_Window_Appeal.SetTopicSelected(topicID)

	if EA_Window_Appeal.topicSelected == topicID then	-- Selecting the same topic already selected does nothing.
		return
	end

	EA_Window_Appeal.topicSelected = topicID
	local topicData = nil

	-- Every time we select a Topic, we will do the following:
	-- 1) Highlight the Topic Button, and unhighlight the others
	-- 2) Destroy any existing topic section windows
	-- 3) Create a window for each section the selected topic contains
	-- 3.1) Add the newly created window to the list of topic windows.
	-- 3.2) Set the window ID for each newly created window.
	-- 3.3) Anchor each newly created child window appropriately
	-- 3.4) If the window is a label, then set it.
	-- 3.5) If the window is an edit box(or any other window requiring tabbed focus), set its tab order
	-- 4) Set the Scroll region's offset and scroll rect

	-- 1) Highlight the Topic Button, and unhighlight the others
	for row, index in ipairs (EA_Window_AppealTopicListBox.PopulatorIndices) do
		ButtonSetPressedFlag("EA_Window_AppealTopicListBoxRow"..row.."Name", topicID == EA_Window_Appeal.topics[index].topicID )
	end

	-- 2) Destroy any existing topic section windows
	for windowIndex, windowName in pairs (EA_Window_Appeal.topicWindows) do
		WindowClearAnchors(windowName)
		DestroyWindow(windowName)
	end
	EA_Window_Appeal.topicWindows = {}
	
	-- 3) Create a window for each section the selected topic contains
	local newWindowName = ""
	local previousWindowName = ""
	local previousWindowID = 0

	for sectionNumber, sectionData in pairs(EA_Window_Appeal.topics[topicID].sections) do
		newWindowName = "AppealSection"..sectionNumber
		CreateWindowFromTemplate(newWindowName, sectionData.template, "EA_Window_AppealTopicWindowScrollChild")
		table.insert(EA_Window_Appeal.topicWindows, newWindowName)	-- 3.1) Add the newly created window to the list of topic windows.
		WindowSetId(newWindowName, sectionNumber)					-- 3.2) Set the window ID for each newly created window.
		
		-- FIXME: Adding this if statement exposes a bug in the scroll child code. Don't anchor the first window, otherwise the scroll bar is messed
		-- up and the botom of the last window in the scroll child region will be cut off by the same amount the 1st window's Y offset is.
		-- if sectionNumber == 1 then
		--	WindowAddAnchor(newWindowName, "topleft", "EA_Window_AppealTopicWindowScrollChild", "topleft", 0, sectionData.yOffset)
		--else
		if sectionNumber > 1 then									-- 3.3) Anchor each newly created child window appropriately
			previousWindowID = sectionNumber-1
			previousWindowName = "AppealSection"..previousWindowID
			WindowAddAnchor(newWindowName, "bottomleft", previousWindowName, "topleft", 0, sectionData.yOffset)
		end
		
		if sectionData.comboBox ~= nil then
			EA_Window_Appeal.SetupComboBox(newWindowName, sectionData.comboboxChoices, sectionData.defaultChoice)
		end
		
		if sectionData.labelID ~= nil then		-- 3.4) If the window is a label, then set it.
			LabelSetText(newWindowName, GetHelpString(sectionData.labelID))
		end
		
		if sectionData.tabOrder ~= nil then		-- 3.5) If the window is an edit box(or any other window requiring tabbed focus), set its tab order
			WindowSetTabOrder(newWindowName, sectionData.tabOrder)
		end
		
		if sectionData.buttonTextID ~= nil then
			ButtonSetText(newWindowName, GetHelpString(sectionData.buttonTextID))
		end
	end

	-- 4) Set the Scroll region's offset and scroll rect
    ScrollWindowSetOffset( "EA_Window_AppealTopicWindow", 0 )
    ScrollWindowUpdateScrollRect( "EA_Window_AppealTopicWindow" )
end

function EA_Window_Appeal.OnLButtonUpTopicRow()
 	local selectedRow = WindowGetId(SystemData.MouseOverWindow.name)
	local topicID = ListBoxGetDataIndex("EA_Window_AppealTopicListBox", selectedRow)
	
	EA_Window_Appeal.SetTopicSelected(topicID)
end

function EA_Window_Appeal.OnKeyEscapeEditBox()
end

function EA_Window_Appeal.OnSelChanged()

end

function EA_Window_Appeal.OnMouseOverComboBox()
end

function EA_Window_Appeal.SubmitAppeal()
	local topicID = EA_Window_Appeal.topics[EA_Window_Appeal.topicSelected].topicID
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
	
	local params = {}
		params[1] = EA_Window_Appeal.topics[EA_Window_Appeal.topicSelected].messageType
		params[2] = EA_Window_Appeal.topics[EA_Window_Appeal.topicSelected].topicID
		params[3] = L""
		params[4] = L""
		params[5] = 0
		params[6] = L""
		params[7] = 0
		params[8] = L""
		params[9] = 0
		params[10]= L""
		params[11]= 0
		params[12]= L""
	
	local paramNumber = 5	-- The first avail param number is 5. Params 1..4 are reserved.
	
	for sectionNumber, sectionData in pairs(EA_Window_Appeal.topics[topicID].sections) do
		if sectionData.fieldID ~= nil then
			
			if sectionData.fieldID == GameData.HelpField.CATEGORY then	-- The Category field is handled special by the server
				local choice = ComboBoxGetSelectedMenuItem("AppealSection"..sectionNumber)
				params[3] = GetHelpString( violationChoices[ choice ] )
			elseif sectionData.fieldID == GameData.HelpField.DETAILS then -- The Details field is handled special by the server 
				params[4] =  TextEditBoxGetText("AppealSection"..sectionNumber)
			else
				params[paramNumber] = sectionData.fieldID
				params[paramNumber+1] = TextEditBoxGetText("AppealSection"..sectionNumber)
				paramNumber=paramNumber+2
			end
		end
	end
	
	
	if(params[4] == L"")
	then
	    local dialogText = GetHelpString( StringTables.Help.ERROR_NO_APPEAL_DETAILS	)
        local confirmOK = GetString( StringTables.Default.LABEL_OKAY )

        DialogManager.MakeOneButtonDialog( dialogText, confirmOK )
	else	
	    SendHelpMessage(params[1], params[2], params[3], params[4], params[5], params[6], params[7], params[8], params[9], params[10], params[11], params[12] )
	    EA_Window_Appeal.Back()
	end
end

-- This function gets called whenever the player uses the gold seller reporting slash command (/rg, /rgs, or /reportgoldseller)
function EA_Window_Appeal.ReportGoldSeller()

	-- ChatManager.OnChatText() caches the lastest tellers name and text, so ensure a name exists
	if (ChatManager.LastTell.name ~= L"") then
		-- Show the Appeal Window, set the appeal topic, and auto-populate the name field
		WindowSetShowing("EA_Window_Appeal", true)	
		EA_Window_Appeal.topicSelected = 0
		EA_Window_Appeal.SetTopicSelected(GameData.AppealTopic.GOLD_SELLING)
		TextEditBoxSetText("AppealSection6", ChatManager.LastTell.name)
	end

	-- ChatManager.OnChatText() caches the lastest tellers name and text, so ensure the text exists
	if ChatManager.LastTell.name ~= L"" and ChatManager.LastTell.text ~= L"" then
		-- Auto populate the details field
		TextEditBoxSetText("AppealSection8", ChatManager.LastTell.text)
	end
end
