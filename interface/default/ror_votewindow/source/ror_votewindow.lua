if not ror_votewindow then ror_votewindow = {} end

local Vote_Started = false
local Vote_Counter = 0
local Vote_Timer = 60
local PlayerName = tostring(wstring.sub( GameData.Player.name,1,-3 ))
local Vote_Choices = {}
local IsBoolChoice = nil
local BoolChoice = {[1]=L"<icon29951>",[2]=L"<icon29952>",[3]=L"<icon29950>"}

function ror_votewindow.Initialize()
CreateWindow("RoR_Window_votewindow", false)

ror_PacketHandling.Register("ReadyCheck:",ror_votewindow.TextUpdate)

ror_votewindow.Players = {}
ror_votewindow.Has_Voted = false
ror_votewindow.Total_Players = 0
ror_votewindow.Vote_Choice = {}
ror_votewindow.Player_Choices = {}
ror_votewindow.Total_Votes_Casted = 0
ror_votewindow.AnnouncementOptions = {[1]=L"GO!",[2]=L"All Ready!",[3]=L"Abort!"}

PlayerName = tostring(wstring.sub( GameData.Player.name,1,-3 ))


	if (LibSlash ~= nil) then
		LibSlash.RegisterSlashCmd("readycheck", function(input) ror_votewindow.StartReady(tonumber(input)) end)		
		LibSlash.RegisterSlashCmd("rc", function(input) ror_votewindow.StartReady(tonumber(input)) end)		
		LibSlash.RegisterSlashCmd("bio", function(input) ror_votewindow.BioReady(tonumber(input)) end)		
		LibSlash.RegisterSlashCmd("vote", function() SendChatText(L"]readycheck start What kind you like?:60:SC:PQ:RVR:PvP:PvE", ChatSettings.Channels[0].serverCmd) end)		
	end


end


function ror_votewindow.TextUpdate(text)
local text = string.gsub(text,"ReadyCheck:","")

			local SPLIT_TEXT = StringSplit(tostring(text),":")
				if SPLIT_TEXT[1] == "Start" then
					--DEBUG(L"Starting Vote")
					local Title = SPLIT_TEXT[2] or L"Ready?"
					local Timer = tonumber(SPLIT_TEXT[3]) or 60
					local Choices = {}
					if #SPLIT_TEXT > 3 then
						for i=4,#SPLIT_TEXT do
							table.insert(Choices,SPLIT_TEXT[i])
						end
					end
					ror_votewindow.StartVote(Title,Timer,Choices)
				elseif SPLIT_TEXT[1] == "Abort" then
					--DEBUG(L"Abotring Vote")
					local Command = SPLIT_TEXT[2] or nil
					local Style = tonumber(SPLIT_TEXT[3]) or 4
					ror_votewindow.AbortVote(Command,Style)
				elseif SPLIT_TEXT[1] == "Answer" then
					local PlayerID = tonumber(SPLIT_TEXT[2])
					local Choice = tonumber(SPLIT_TEXT[3])
					--DEBUG(L"Answering Vote: " .. towstring(PlayerID)..L" : ".. towstring(Choice))
					ror_votewindow.AnswerVote(PlayerID,Choice)
				end

end


function ror_votewindow.GetPlayers()
local Players = {}
local Sorter = {}

	if IsWarBandActive() then
		for j = 1, 4 do
			table.insert(Players,{})
			for i = 1, 6 do
				local member = PartyUtils.GetWarbandMember(j, i)
				table.insert(Players[j],member)
			end
		end
	else
	table.insert(Players,{})
	table.insert(Players[1],GameData.Player)
		for i = 1, 5 do
			local member = PartyUtils.GetPartyMember( i )
			table.insert(Players[1],member)
		end
	end

for num=1 , #Players do
	if Sorter[num] == nil then Sorter[num] = {} end
	for k,v in pairs(Players[num]) do		
		for i,j in pairs(RoRGroupScoreboard.playersDataRaw) do
			if WStringsRemoveGrammar(RoRGroupScoreboard.playersDataRaw[i].name) == WStringsRemoveGrammar(Players[num][k].name) then
				Sorter[num][i] = RoRGroupScoreboard.playersDataRaw[i]
			end
		end
	end
end

return Sorter
end

function ror_votewindow.StartReady(timer)
	if tonumber(timer) == nil then timer = 15 end
	SendChatText(L"]readycheck start Ready?|bool:"..towstring(timer)..L":Yes:No", ChatSettings.Channels[0].serverCmd)
end

function ror_votewindow.BioReady(timer)
	if tonumber(timer) == nil then timer = 300 end
	SendChatText(L"]readycheck start Bio Break |bool:"..towstring(timer)..L":Back", ChatSettings.Channels[0].serverCmd)
end

function ror_votewindow.StartVote(Title,Timer,Choices)
local WindowName = "RoR_Window_votewindow"
Vote_Started = true
Vote_Timer = tonumber(Timer)
Vote_Choices = Choices
ror_votewindow.Players = ror_votewindow.GetPlayers()
ror_votewindow.Vote_Choice = {}
ror_votewindow.Player_Choices = {}
ror_votewindow.Total_Players = 0
ror_votewindow.Total_Votes_Casted = 0
ror_votewindow.Has_Voted = false

IsBoolChoice = string.find(Title,"|bool")
if IsBoolChoice ~= nil then Title = string.gsub(Title,"|bool","") end

local IsLeader = (GameData.Player.isGroupLeader == true)

if IsLeader then Vote_Timer = Vote_Timer + 5 end

WindowSetShowing(WindowName .. "Close",IsLeader or ror_votewindow.Has_Voted)
WindowSetShowing(WindowName .. "Announce",IsLeader)
--Reset Windows

for k,v in pairs(Vote_Choices) do
	ror_votewindow.Player_Choices[k]= 0
end

	WindowSetDimensions( WindowName, 350, 125+(35*(#ror_votewindow.Players)))
	WindowClearAnchors(WindowName .. "TimerBar" )
	WindowAddAnchor(WindowName .. "TimerBar", "bottomleft", WindowName, "bottomleft", 50,-63)

	
for row=1,4 do	
	for col=1,6 do
		local txr, x, y, disabledTexture = GetIconData (20)	
		WindowSetShowing(WindowName .. "Party" .. row,false)
		CircleImageSetTexture(WindowName .. "Party" .. row .. col .. "PlayerIcon",txr, 32, 32)
		WindowSetTintColor(WindowName .. "Party".. row .. col,255,255,255)
		WindowSetShowing(WindowName .. "Party" .. row .. col .. "Name",false)
		ButtonSetDisabledFlag(WindowName .. "Party" .. row .. col .. "Player",true)
		LabelSetText(WindowName .. "Party".. row .. col .. "Name",L"")
		LabelSetText(WindowName .. "Party".. row .. col .. "Choice",L"")
		AnimatedImageStopAnimation (WindowName .. "Party".. row .. col.."Flash")
	end
end

--Set Labels
WindowSetShowing(WindowName,true)
LabelSetText(WindowName .. "Text",towstring(Title))
LabelSetText(WindowName .. "TimerLabel",towstring(TimeUtils.FormatClock(Vote_Timer)))

--Set Buttons, if more than 2 options, make a droplist!
	if #Choices < 3 then
		ButtonSetText(WindowName .. "_Choice_Vote_1",towstring(Choices[1] or L""))
		ButtonSetText(WindowName .. "_Choice_Vote_2",towstring(Choices[2] or L""))
		WindowSetShowing(WindowName .. "_Choice_Vote_1",not ror_votewindow.Has_Voted and Vote_Timer > 0)
		WindowSetShowing(WindowName .. "_Choice_Vote_2",not ror_votewindow.Has_Voted and #Choices > 1 and Vote_Timer > 0)
	else
		WindowSetShowing(WindowName .. "_Choice_Vote_1",not ror_votewindow.Has_Voted and Vote_Timer > 0)
		WindowSetShowing(WindowName .. "_Choice_Vote_2",false)
		ButtonSetText(WindowName .. "_Choice_Vote_1",L"Vote")
		
		--Setup Combobox droplist
		ComboBoxClearMenuItems(WindowName .. "_ChoiceCombo")
		for i=1,#Choices do
			ComboBoxAddMenuItem(WindowName .. "_ChoiceCombo", towstring(Choices[i]))
		end		
			ComboBoxSetSelectedMenuItem(WindowName .. "_ChoiceCombo", 1 )
	end

	WindowClearAnchors(WindowName .. "_Choice_Vote_1" )
	if #Choices < 2 then
		WindowAddAnchor(WindowName .. "_Choice_Vote_1", "bottomleft", WindowName, "bottomleft", 100,-12)
	else
		WindowAddAnchor(WindowName .. "_Choice_Vote_1", "bottomleft", WindowName, "bottomleft", 180,-12)
	end
WindowSetShowing(WindowName .. "_ChoiceCombo",#Choices > 2)

--Set the TimerBar
	StatusBarSetMaximumValue(WindowName .. "Bar1", Vote_Timer  )
	StatusBarSetCurrentValue(WindowName .. "Bar1", Vote_Timer  )
	StatusBarSetForegroundTint(WindowName .. "Bar1", DefaultColor.YELLOW.r, DefaultColor.YELLOW.g, DefaultColor.YELLOW.b )

--Add and Fill player icons
for row,value in pairs(ror_votewindow.Players) do
	WindowSetShowing(WindowName .. "Party" .. row,true)
	Vote_Counter = 1
	for k,v in pairs(ror_votewindow.Players[row]) do 
		WindowSetShowing(WindowName .. "Party".. row .. Vote_Counter,true)
		local txtr, x, y, disabledTexture = GetIconData (Icons.GetCareerIconIDFromCareerLine(tonumber(ror_votewindow.Players[row][k].career)))	
		CircleImageSetTexture(WindowName .. "Party" .. row .. Vote_Counter .. "PlayerIcon",txtr, 16, 16)
		WindowSetTintColor(WindowName .. "Party".. row .. Vote_Counter,75,75,75)
		LabelSetText(WindowName .. "Party".. row .. Vote_Counter .."Name",towstring(ror_votewindow.Players[row][k].name))
		if ror_votewindow.Vote_Choice[row] == nil then ror_votewindow.Vote_Choice[row] = {} end
		ror_votewindow.Vote_Choice[row][k] = Vote_Counter
		Vote_Counter = Vote_Counter+1
		ror_votewindow.Total_Players = ror_votewindow.Total_Players +1
	
	end
end
	--Play Sound
	PlaySound(501)		
end


function ror_votewindow.AnswerVote(PlayerID,Choice)
local WindowName = "RoR_Window_votewindow"

for row,value in pairs(ror_votewindow.Players) do
	for k,v in pairs(ror_votewindow.Players[row]) do 
		if PlayerID == ror_votewindow.Players[row][k].charId then
			ror_votewindow.Total_Votes_Casted = ror_votewindow.Total_Votes_Casted + 1
			WindowSetShowing(WindowName .. "Party".. row .. ror_votewindow.Vote_Choice[row][PlayerID].."Flash",true)
			AnimatedImageStartAnimation (WindowName .. "Party".. row .. ror_votewindow.Vote_Choice[row][PlayerID].."Flash", 0, false, true, 0)		
			--Choice is 0 when a player times out or closes the window before voting
			if Choice == 0 then
				WindowSetTintColor(WindowName .. "Party" .. row .. ror_votewindow.Vote_Choice[row][PlayerID],255,125,125)
				LabelSetText(WindowName .. "Party" .. row .. ror_votewindow.Vote_Choice[row][PlayerID] .. "Choice",towstring(BoolChoice[3]))
			else 
				ror_votewindow.Player_Choices[Choice] = ror_votewindow.Player_Choices[Choice] + 1
				WindowSetTintColor(WindowName .. "Party" .. row .. ror_votewindow.Vote_Choice[row][PlayerID],255,255,255)
					if IsBoolChoice ~= nil then
						LabelSetText(WindowName .. "Party" .. row .. ror_votewindow.Vote_Choice[row][PlayerID] .. "Choice",towstring(BoolChoice[Choice]))
					else
						LabelSetText(WindowName .. "Party" .. row .. ror_votewindow.Vote_Choice[row][PlayerID] .. "Choice",towstring(Vote_Choices[Choice]))
					end
			end
		end
	end
	end	
	
	if ror_votewindow.Total_Votes_Casted == ror_votewindow.Total_Players then
		--ror_votewindow.Close(true)
	end
	--Play Sound
	PlaySound(216)		
end

function ror_votewindow.AbortVote(Text,Style)
local Text = Text or nil
local Style = Style or 4

	if Text ~= nil then
						SystemData.AlertText.VecType = {Style}
						SystemData.AlertText.VecText = {towstring(Text)}
						AlertTextWindow.AddAlert()
	end

Vote_Started = false
WindowSetShowing("RoR_Window_votewindow", false)
--Play Sound
PlaySound(328)
end

function ror_votewindow.Announce()
	local function MakeCallBack( SelectedOption )
		    return function() SendChatText(L"]readycheck abort " .. ror_votewindow.AnnouncementOptions[SelectedOption], ChatSettings.Channels[0].serverCmd) end
		end

	EA_Window_ContextMenu.CreateContextMenu( SystemData.MouseOverWindow.name, EA_Window_ContextMenu.CONTEXT_MENU_1,L"")
	EA_Window_ContextMenu.AddMenuItem( L"Announce Results" ,function() ror_votewindow.Close(true) end, false, true )

	for k,v in ipairs(ror_votewindow.AnnouncementOptions) do
		EA_Window_ContextMenu.AddMenuItem( towstring(v) ,MakeCallBack(k) , false, true )
	end

	EA_Window_ContextMenu.Finalize()
end

function ror_votewindow.Close(stats)
	if GameData.Player.isGroupLeader == true then
		if stats == true then		
			local results = L"'" .. wstring.sub(towstring(LabelGetText("RoR_Window_votewindowText")),1,-2) .. L"' Results "
			for k,v in pairs(ror_votewindow.Player_Choices) do
			 if ror_votewindow.Player_Choices[k] > 0 then
				results = results .. L" ("..towstring(Vote_Choices[k]) .. L"   ".. towstring(v) .. L") "
			 end
			end
		
			SendChatText(L"]readycheck abort " .. towstring(results), ChatSettings.Channels[0].serverCmd)
		else
			SendChatText(L"]readycheck abort " .. L"Poll Aborted", ChatSettings.Channels[0].serverCmd)
		end	
		
	else
		if ror_votewindow.Has_Voted == false then
			SendChatText(L"]readycheck answer 0", ChatSettings.Channels[0].serverCmd)
		end
		WindowSetShowing("RoR_Window_votewindow", false)
	end
end


function ror_votewindow.SelectChoice()
local WindowName = "RoR_Window_votewindow"
local IsLeader = (GameData.Player.isGroupLeader == true)

  local ButtonNumber = WindowGetId (SystemData.ActiveWindow.name)
	if ror_votewindow.Has_Voted == false then
		ror_votewindow.Has_Voted = true
		if WindowGetShowing(WindowName .. "_ChoiceCombo") then
			SendChatText(L"]readycheck answer "..towstring(ComboBoxGetSelectedMenuItem(WindowName .. "_ChoiceCombo")), ChatSettings.Channels[0].serverCmd)
		else
			SendChatText(L"]readycheck answer "..towstring(ButtonNumber), ChatSettings.Channels[0].serverCmd)
		end
	end
  
WindowSetShowing(WindowName .. "_Choice_Vote_1",not ror_votewindow.Has_Voted and Vote_Timer < 0)
WindowSetShowing(WindowName .. "_Choice_Vote_2",not ror_votewindow.Has_Voted and Vote_Timer < 0)
WindowSetShowing(WindowName .. "_ChoiceCombo",not ror_votewindow.Has_Voted)
WindowSetShowing(WindowName .. "Close",IsLeader or ror_votewindow.Has_Voted)

WindowSetDimensions(WindowName, 350, 77+(35*(#ror_votewindow.Players)))
WindowClearAnchors(WindowName .. "TimerBar" )
WindowAddAnchor(WindowName .. "TimerBar", "bottomleft", WindowName, "bottomleft", 50,-16)
end

function ror_votewindow.Tooltip()
local WindowName = "RoR_Window_votewindow"
local col = tostring(((string.match(SystemData.MouseOverWindow.name,"(%d)"))))
local row = tostring(WindowGetId(WindowGetParent(SystemData.MouseOverWindow.name)))
local NameGet = towstring(LabelGetText(WindowName .. "Party".. col .. row .."Name"))

	if NameGet ~= L"" then
		local TooltipAnchor = { Point = "left", RelativeTo = "CursorWindow", RelativePoint = "left", XOffset = 18, YOffset = 0 }

		Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name)		
		Tooltips.SetTooltipText (1, 1,NameGet)
		Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)
        Tooltips.Finalize();
        Tooltips.AnchorTooltip( TooltipAnchor )	
	end
end

function ror_votewindow.Update(timeElapsed)

    if (Vote_Started == false) then return end

	if Vote_Timer > 0 then
		LabelSetText("RoR_Window_votewindowTimerLabel",towstring(TimeUtils.FormatClock(Vote_Timer)))
		StatusBarSetCurrentValue("RoR_Window_votewindowBar1", Vote_Timer  )
		Vote_Timer = Vote_Timer - timeElapsed    
	else
	   if ror_votewindow.Has_Voted == false then	   
		--ror_votewindow.Has_Voted = true
		--ror_votewindow.SelectChoice()
		ror_votewindow.Close(true)
      end
	 ror_votewindow.Close(true)
	 Vote_Started = false
	end
end