HelpUtils = {}

-- Submits a Goldselling appeal without opening windows or requiring player interaction to fill out the appeal.
-- This is a hard coded function for goldselling.
-- Used by HelpUtils.AutoReportGoldSeller()
function HelpUtils.SubmitGoldsellingAppeal(name, message)
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
		params[1] = GameData.HelpType.CREATE_APPEAL_GOLD_SELLER
		params[2] = GameData.AppealTopic.GOLD_SELLING
		params[3] = L""
		params[4] = message
		params[5] = GameData.HelpField.NAME_REPORTING
		params[6] = name
		params[7] = 0
		params[8] = L""
		params[9] = 0
		params[10]= L""
		params[11]= 0
		params[12]= L""

	SendHelpMessage(params[1], params[2], params[3], params[4], params[5], params[6], params[7], params[8], params[9], params[10], params[11], params[12] )
end

-- Used by "Report Spam" functionality in the right-click menu on player names and mail.
function HelpUtils.AutoReportGoldSeller(name, message)
    if (name ~= L"" and message ~= L"")
    then
        HelpUtils.SubmitGoldsellingAppeal(name, message)
    end
end
