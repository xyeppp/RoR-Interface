if not RoR_Window_ScenarioSurrender then RoR_Window_ScenarioSurrender = {} end

local Surrender_Started = false
local Vote_Counter = 0
local Vote_Timer = 140
local PlayerName = tostring(wstring.sub( GameData.Player.name,1,-3 ))

function RoR_Window_ScenarioSurrender.Initialize()
  CreateWindow("RoR_Window_ScenarioSurrender", false)

  RegisterEventHandler(TextLogGetUpdateEventId("Chat"), "RoR_Window_ScenarioSurrender.TextUpdate");
  RegisterEventHandler(SystemData.Events.SCENARIO_END, "RoR_Window_ScenarioSurrender.ClearSurrender");
  RegisterEventHandler(SystemData.Events.SCENARIO_BEGIN, "RoR_Window_ScenarioSurrender.ClearSurrender");

  LayoutEditor.RegisterWindow( "RoR_Window_ScenarioSurrender", L"Surrender Vote Window", L"Surrender Vote Window", true, true, true, nil )
  LayoutEditor.RegisterEditCallback(RoR_Window_ScenarioSurrender.OnLayoutEditorFinished)

  LabelSetText("RoR_Window_ScenarioSurrenderText",L"Surrender Scenario?")

  ButtonSetText("RoR_Window_ScenarioSurrender_Choice_Vote_Yes",GetString(StringTables.Default.LABEL_YES))
  ButtonSetText("RoR_Window_ScenarioSurrender_Choice_Vote_No",GetString(StringTables.Default.LABEL_NO))

  if not RoR_Window_ScenarioSurrender.ShowEmpty then RoR_Window_ScenarioSurrender.ShowEmpty = false end
  RoR_Window_ScenarioSurrender.Players = {}
  RoR_Window_ScenarioSurrender.Has_Voted = false
  RoR_Window_ScenarioSurrender.Total_Players = 0
  RoR_Window_ScenarioSurrender.Vote_Color = {{r=125,g=125,b=125},{r=25,g=255,b=25},{r=255,g=25,b=25}}
  RoR_Window_ScenarioSurrender.Vote_Choice = {["yes"]=1,["no"]=2}
  RoR_Window_ScenarioSurrender.Choice_Vote = {"yes","no"}
  
 Surrender_Started = false
 Vote_Counter = 0
 Vote_Timer = 140
 PlayerName = tostring(wstring.sub( GameData.Player.name,1,-3 ))
 WindowSetShowing("RoR_Window_ScenarioSurrender",false) 
end

function RoR_Window_ScenarioSurrender.OnLayoutEditorFinished( editorCode )
	if( editorCode == LayoutEditor.EDITING_END ) then
		WindowSetShowing("RoR_Window_ScenarioSurrender",Surrender_Started)
	end
end

function RoR_Window_ScenarioSurrender.UpdateWindows()

  WindowSetShowing("RoR_Window_ScenarioSurrender",Surrender_Started)
  if Surrender_Started == true then
    WindowSetShowing("RoR_Window_ScenarioSurrender_Choice",not RoR_Window_ScenarioSurrender.Has_Voted )
    if RoR_Window_ScenarioSurrender.Has_Voted == false then
      WindowSetDimensions( "RoR_Window_ScenarioSurrender", 350, 150 )
    else
      WindowSetDimensions( "RoR_Window_ScenarioSurrender", 350, 100 )
    end
  end
  return
end


function RoR_Window_ScenarioSurrender.TextUpdate(updateType, filterType)

  if not (GameData.Player.isInScenario) then return end
  if( updateType == SystemData.TextLogUpdate.ADDED ) then
    local _, filterId, text = TextLogGetEntry( "Chat", TextLogGetNumEntries("Chat") - 1 )
    if text:find(L"started surrender vote!") then
      RoR_Window_ScenarioSurrender.StartSurrender(text)--the surrender has been initiated!
    elseif text:find(L"[%a]+ voted [%a]+ for surrender.") then
      local Name,Choice = text:match(L"([%a]+) voted ([%a]+) for surrender.")
      RoR_Window_ScenarioSurrender.CastVote(Name,RoR_Window_ScenarioSurrender.Vote_Choice[tostring(Choice)])
	elseif text:find(L"Surrender vote for") then
		RoR_Window_ScenarioSurrender.ClearSurrender()
    end
  end
end


function RoR_Window_ScenarioSurrender.StartSurrender(text)

  if Surrender_Started == false then
    RoR_Window_ScenarioSurrender.ScenarioUpdate()--get player list in the scenario
    local Name = tostring(text:match(L"([%a]+) started surrender vote!"))
    if RoR_Window_ScenarioSurrender.Players[Name] == nil then return end
  end

  if Surrender_Started == true then return else Surrender_Started = true end

  Vote_Counter = 0

  local vote_wide = 310/RoR_Window_ScenarioSurrender.Total_Players
  CreateWindowFromTemplate("VoteCount1", "Vote_Count_Template", "RoR_Window_ScenarioSurrender")
  WindowSetDimensions( "VoteCount1", vote_wide, 20 )
  WindowClearAnchors("VoteCount1")
  WindowAddAnchor("VoteCount1", "topleft", "RoR_Window_ScenarioSurrender", "topleft",20,43 )
  WindowSetShowing("VoteCount1",RoR_Window_ScenarioSurrender.ShowEmpty)
  WindowSetTintColor("VoteCount1BG",125,125,125)

  for i=2,RoR_Window_ScenarioSurrender.Total_Players do
    CreateWindowFromTemplate("VoteCount"..i, "Vote_Count_Template", "RoR_Window_ScenarioSurrender")
    WindowSetDimensions( "VoteCount"..i, vote_wide, 20 )
    WindowClearAnchors("VoteCount"..i)
    WindowAddAnchor("VoteCount"..i, "right", "VoteCount"..(i-1), "left",0,0 )
    WindowSetShowing("VoteCount"..i,RoR_Window_ScenarioSurrender.ShowEmpty)
    WindowSetTintColor("VoteCount"..i.."BG",125,125,125)
  end

  Vote_Timer = 140
  StatusBarSetMaximumValue("RoR_Window_ScenarioSurrenderBar1", Vote_Timer-30  )
  StatusBarSetForegroundTint("RoR_Window_ScenarioSurrenderBar1", DefaultColor.YELLOW.r, DefaultColor.YELLOW.g, DefaultColor.YELLOW.b )
  RoR_Window_ScenarioSurrender.UpdateWindows()
end

function RoR_Window_ScenarioSurrender.ClearSurrender()
  Surrender_Started = false
  for i=1,RoR_Window_ScenarioSurrender.Total_Players do
    if DoesWindowExist("VoteCount"..i) then
      DestroyWindow("VoteCount"..i)
    end
  end
  RoR_Window_ScenarioSurrender.Total_Players = 0
  RoR_Window_ScenarioSurrender.Has_Voted = false
  RoR_Window_ScenarioSurrender.Players = {}
  RoR_Window_ScenarioSurrender.UpdateWindows()
end


function RoR_Window_ScenarioSurrender.CastVote(name,choice)
  if not (Surrender_Started) then return end
  local name = tostring(name)
  local choice = choice
  Vote_Counter = Vote_Counter+1
  RoR_Window_ScenarioSurrender.Players[tostring(name)].choice = choice
  if name == PlayerName then RoR_Window_ScenarioSurrender.Has_Voted = true end
  RoR_Window_ScenarioSurrender.UpdateWindows()
  local Color = RoR_Window_ScenarioSurrender.Vote_Color[choice+1]
  WindowSetTintColor("VoteCount"..Vote_Counter.."BG",Color.r,Color.g,Color.b)
  WindowSetShowing("VoteCount"..Vote_Counter,true)

  return
end


function RoR_Window_ScenarioSurrender.ScenarioUpdate()
  RoR_Window_ScenarioSurrender.Total_Players = 0
  if(GameData.Player.isInScenario) then
    RoR_Window_ScenarioSurrender.Players = {}
    local groupData=GameData.GetScenarioPlayerGroups()
    for index,memberData in ipairs(groupData) do
      if memberData.name ~= L"" then
        RoR_Window_ScenarioSurrender.Total_Players	= RoR_Window_ScenarioSurrender.Total_Players +1
        RoR_Window_ScenarioSurrender.Players[tostring(wstring.sub( memberData.name,1,-3 ))] = {}
      end
    end
  end
  return
end

function RoR_Window_ScenarioSurrender.SelectChoice()
  local ButtonNumber = WindowGetId (SystemData.ActiveWindow.name)
  if RoR_Window_ScenarioSurrender.Has_Voted == false then
    SendChatText(L"]"..towstring(RoR_Window_ScenarioSurrender.Choice_Vote[ButtonNumber]), ChatSettings.Channels[0].serverCmd)
  end
end


function RoR_Window_ScenarioSurrender.Update(timeElapsed)
  if(GameData.Player.isInScenario) then
    if (Surrender_Started == false) then return end

	if Vote_Timer >= 30 then
		StatusBarSetCurrentValue("RoR_Window_ScenarioSurrenderBar1", Vote_Timer-30  )
	else
	   if RoR_Window_ScenarioSurrender.Has_Voted == false then	   
        SendChatText(L"]no", ChatSettings.Channels[0].serverCmd)
		RoR_Window_ScenarioSurrender.Has_Voted = true
      end
	end

    if Vote_Timer >= 0 then
      Vote_Timer = Vote_Timer - timeElapsed      
    else
      Surrender_Started = false
      RoR_Window_ScenarioSurrender.ClearSurrender()
    end
  end
end
