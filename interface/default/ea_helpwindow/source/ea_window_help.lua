EA_Window_Help = {}

EA_Window_Help.AppealStatus = GameData.AppealStatus.CLOSED

function EA_Window_Help.Initialize()
    LabelSetText( "EA_Window_HelpTitleBarText", GetHelpString(StringTables.Help.TEXT_HELP_TITLE_BAR))
    
    LabelSetText( "EA_Window_HelpFAQHeader", GetHelpString(StringTables.Help.HEADER_HELP_FAQ))
    LabelSetText( "EA_Window_HelpAppealHeader",	GetHelpString(StringTables.Help.HEADER_HELP_APPEAL))
    LabelSetText( "EA_Window_HelpManualHeader",	GetHelpString(StringTables.Help.BUTTON_HELP_MANUAL))
    LabelSetText( "EA_Window_HelpReportBugHeader", GetHelpString(StringTables.Help.HEADER_HELP_BUG))
    LabelSetText( "EA_Window_HelpFeedbackHeader", GetHelpString(StringTables.Help.HEADER_HELP_FEEDBACK))
    LabelSetText( "EA_Window_HelpTipsHeader", GetHelpString(StringTables.Help.HEADER_HELP_TIPS))
    
    LabelSetText( "EA_Window_HelpFAQDescriptionText", GetHelpString(StringTables.Help.LABEL_HELP_DESCRIPTION_FAQ))
	LabelSetText( "EA_Window_HelpAppealDescriptionText", GetHelpString(StringTables.Help.LABEL_HELP_DESCRIPTION_APPEAL))
	LabelSetText( "EA_Window_HelpManualDescriptionText", GetHelpString(StringTables.Help.LABEL_HELP_DESCRIPTION_MANUAL))
	LabelSetText( "EA_Window_HelpReportBugDescriptionText", GetHelpString(StringTables.Help.LABEL_HELP_DESCRIPTION_BUG))
	LabelSetText( "EA_Window_HelpFeedbackDescriptionText", GetHelpString(StringTables.Help.LABEL_HELP_DESCRIPTION_FEEDBACK))
    LabelSetText( "EA_Window_HelpTipsDescriptionText", GetHelpString(StringTables.Help.LABEL_HELP_DESCRIPTION_TIPS))

	ButtonSetText("EA_Window_HelpFaqButton", GetHelpString(StringTables.Help.BUTTON_HELP_FAQ))
	ButtonSetText("EA_Window_HelpAppealButton", GetHelpString(StringTables.Help.BUTTON_HELP_APPEAL))
	ButtonSetText("EA_Window_HelpEditAppealButton", GetHelpString(StringTables.Help.BUTTON_HELP_EDIT_APPEAL))
	ButtonSetText("EA_Window_HelpManualButton", GetHelpString(StringTables.Help.BUTTON_HELP_MANUAL))
	ButtonSetText("EA_Window_HelpReportBugButton", GetHelpString(StringTables.Help.BUTTON_HELP_BUG))
	ButtonSetText("EA_Window_HelpFeedbackButton", GetHelpString(StringTables.Help.BUTTON_HELP_FEEDBACK))
    ButtonSetText("EA_Window_HelpTipsButton", GetHelpString(StringTables.Help.BUTTON_HELP_TIPS))
	
	WindowRegisterEventHandler( "EA_Window_Help", SystemData.Events.HELP_STATUS_UPDATED, "EA_Window_Help.UpdateHelpStatus")
	
	EA_Window_Help.UpdateButtons()
end

function EA_Window_Help.OnShown()
	WindowSetShowing("EA_Window_Help", true)	-- This is needed since many other help related window call this function to open the Help Window.
	EA_Window_Help.UpdateButtons()

	-- When the Help Window is shown, we want to ensure none of the other help related windows are open.
    if WindowGetShowing("FAQWindow")			== true then FAQWindow.Hide() end
	if WindowGetShowing("BugReportWindow")		== true then BugReportWindow.Hide() end
	if WindowGetShowing("ManualWindow")			== true then ManualWindow.Hide() end
	if WindowGetShowing("EA_Window_Feedback")	== true then EA_Window_Feedback.Hide() end
	if WindowGetShowing("EA_Window_Appeal")		== true then EA_Window_Appeal.Hide() end
	if WindowGetShowing("EditAppealWindow")		== true then EditAppealWindow.Hide() end
    if WindowGetShowing("TipsWindow")           == true then TipsWindow.Hide() end
end

function EA_Window_Help.ToggleShowing()
    WindowUtils.ToggleShowing("EA_Window_Help")
end

function EA_Window_Help.Hide()
    WindowSetShowing("EA_Window_Help", false)
end

function EA_Window_Help.Shutdown()
end

function EA_Window_Help.OnLButtonUpFaqButton()
	EA_Window_Help.Hide()
	FAQWindow.OnShown()
end

function EA_Window_Help.OnLButtonUpAppealButton()
	EA_Window_Help.Hide()
	EA_Window_Appeal.Show()
end

function EA_Window_Help.OnLButtonUpEditAppealButton()
	EA_Window_Help.Hide()
	EditAppealWindow.Show()
end

function EA_Window_Help.OnLButtonUpManualButton()
	EA_Window_Help.Hide()
	ManualWindow.Show()
end

function EA_Window_Help.OnLButtonUpReportBugButton()
	EA_Window_Help.Hide()
	BugReportWindow.Show()
end

function EA_Window_Help.OnLButtonUpFeedbackButton()
	EA_Window_Help.Hide()
	EA_Window_Feedback.Show()
end

function EA_Window_Help.OnLButtonUpTipsButton()
	EA_Window_Help.Hide()
	TipsWindow.Show()
end

function EA_Window_Help.UpdateHelpStatus(status)
	EA_Window_Help.AppealStatus = status
	EA_Window_Help.UpdateButtons()
	EA_Window_Appeal.FilterTopicList()
end

function EA_Window_Help.IsThereAnActiveAppeal()
	if EA_Window_Help.AppealStatus == GameData.AppealStatus.AWAITING_PLAYER or 
		EA_Window_Help.AppealStatus == GameData.AppealStatus.AWAITING_CS
	then
		return true
	else
		return false
	end
end

function EA_Window_Help.UpdateButtons()
	WindowSetShowing("EA_Window_HelpEditAppealButton", EA_Window_Help.IsThereAnActiveAppeal())
end
