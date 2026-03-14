MultiSpec = {}
MultiSpec.Speccs = {}

local version = 0.5
local NameEdit = false
local Archetype = {L"Empty Slot",L"Tank",L"Melee",L"Ranged",L"Healer"} --Text for each Archetype
local Archeicons = {20,26,24,25,23}	--icons for each Archetype, not used annymore
local PlayerName = wstring.sub( GameData.Player.name,1,-3 )

function MultiSpec.OnInitialize()
RegisterEventHandler(TextLogGetUpdateEventId("Chat"), "MultiSpec.OnChatLogUpdated")

LabelSetText("MultiSpec_WindowTitleBarText",L"Mastery Switcher")

LabelSetText( "MultiSpec_WindowText", L"Chose a slot to Save/Load from" ) 

ButtonSetText("MultiSpec_WindowSaveButton", L"Save" )	
ButtonSetText("MultiSpec_WindowLoadButton", L"Load" )	
ButtonSetText("MultiSpec_WindowClearButton", L"Clear" )	

MultiSpec.SelectedListBox = nil
ButtonSetDisabledFlag( "MultiSpec_WindowClearButton", true)
ButtonSetDisabledFlag( "MultiSpec_WindowLoadButton", true)
ButtonSetDisabledFlag( "MultiSpec_WindowSaveButton", true)
PlayerName = wstring.sub( GameData.Player.name,1,-3 )
if not MultiSpec.Name then MultiSpec.Name = {} end
if not MultiSpec.Name[tostring(PlayerName)] then MultiSpec.Name[tostring(PlayerName)] = {} end --need to add playername to the savedvars in case of shared profiles

end

function MultiSpec.OnChatLogUpdated(updateType, filterType)
	if updateType ~= SystemData.TextLogUpdate.ADDED then return end
	if filterType ~= SystemData.ChatLogFilters.CHANNEL_9 then return end

	local _, filterId, text = TextLogGetEntry( "Chat", TextLogGetNumEntries("Chat") - 1 )
	if text:find(L"SPEC_LIST") then
		MultiSpec.UpdateList(text)
	end
end

function MultiSpec.UpdateList(text)
MultiSpec.CareerLine = tonumber(GameData.Player.career.line)
	for i=1, 3 do
		LabelSetText("MultiSpec_WindowPath"..i.."Label",GetSpecializationPathName((3*MultiSpec.CareerLine)-(3-i))) --fetch path names from localized strings
	end
local statsText = text:sub(11)
local SplitText = WStringSplit(statsText, L"|")
	for i=1,5 do	--Clear the list
		MultiSpec.Speccs[i] = {iconNum=Archeicons[1],id=tonumber(i),Atype=0,type=Archetype[1],Path1=0,Path2=0,Path3=0}
		DynamicImageSetTextureSlice("MultiSpec_WindowListRow"..i.."Icon","AbilityIconFrame")
	end
	if statsText ~= L"" then
		for k,v in pairs(SplitText) do	--Update the table with valid speccs
			local CharSplitText = WStringSplit(v, L",")
			MultiSpec.Speccs[tonumber(CharSplitText[1])] = {iconNum=Archeicons[(CharSplitText[2])+2],id=tonumber(CharSplitText[1]),Atype=tonumber(CharSplitText[2])+2,Path1=tonumber(CharSplitText[3]),Path2=tonumber(CharSplitText[4]),Path3=tonumber(CharSplitText[5])}		
			
			if MultiSpec.Name[tostring(PlayerName)][tonumber(CharSplitText[1])] ~= nil and MultiSpec.Name[tostring(PlayerName)][tonumber(CharSplitText[1])] ~= L"" then
				MultiSpec.Speccs[tonumber(CharSplitText[1])].type = towstring(MultiSpec.Name[tostring(PlayerName)][tonumber(CharSplitText[1])])
			else
				MultiSpec.Speccs[tonumber(CharSplitText[1])].type=Archetype[(CharSplitText[2])+2]
			end
			--set the Texture slice depending on points-per-tree from the "dirty specc compare"
			DynamicImageSetTextureSlice("MultiSpec_WindowListRow"..tonumber(CharSplitText[1]).."Icon",AbilitiesWindow.FilterTabCareerTextures[MultiSpec.CareerLine][MultiSpec.Compare(tonumber(CharSplitText[3]),tonumber(CharSplitText[4]),tonumber(CharSplitText[5]))])
			end
	end		
		--clear and populate the List with the table
	MultiSpec.lootData = nil
	MultiSpec.lootData = MultiSpec.Speccs
    MultiSpec.lootDataDisplayOrder = {}  
	
		for lootIndex, _ in pairs( MultiSpec.lootData ) do
			table.insert( MultiSpec.lootDataDisplayOrder, lootIndex )
		end   		
    ListBoxSetDisplayOrder("MultiSpec_WindowList", MultiSpec.lootDataDisplayOrder )
	WindowSetShowing("MultiSpec_Window",true)
	
	
   for row = 1, 5 do
        -- Show the background for every other button   
        local color = GameDefs.RowColorInvalid
        local row_mod = math.mod(row, 2)
        local color = DataUtils.GetAlternatingRowColor( row_mod )
        local targetRowWindow = "MultiSpec_WindowListRow"..row

            WindowSetTintColor(targetRowWindow.."Background", color.r, color.g, color.b )
            WindowSetAlpha(targetRowWindow.."Background", color.a)
     
    end
end

function MultiSpec.Select(flags, x, y)
if NameEdit == true then return end
local _index = ListBoxGetDataIndex("MultiSpec_WindowList", WindowGetId(SystemData.MouseOverWindow.name))
MultiSpec.SelectedListBox = _index

--shift click to edit name:
	local function InputSubmit(SelectText)
		MultiSpec.Name[tostring(PlayerName)][MultiSpec.SelectedListBox] = towstring(SelectText)
		SendChatText(L"]spec list",ChatSettings.Channels[0].serverCmd)
		NameEdit = false
		return
	end		
	
	local function InputAbort(SelectText)
		NameEdit = false
	end		

	if flags == SystemData.ButtonFlags.SHIFT and MultiSpec.Speccs[MultiSpec.SelectedListBox].Atype ~= 0 then	
			NameEdit = true
			DialogManager.MakeTextEntryDialog( L"Rename Mastery slot",L"Input new slotname",L"", InputSubmit, InputAbort, 100, false,1)
	end


--make the List selection sticky

for i=1,5 do
ButtonSetPressedFlag("MultiSpec_WindowListRow"..i,MultiSpec.SelectedListBox == (ListBoxGetDataIndex("MultiSpec_WindowList", i)))
end
ButtonSetDisabledFlag( "MultiSpec_WindowClearButton", MultiSpec.Speccs[MultiSpec.SelectedListBox].Atype < 1)
ButtonSetDisabledFlag( "MultiSpec_WindowLoadButton", MultiSpec.Speccs[MultiSpec.SelectedListBox].Atype < 1)
ButtonSetDisabledFlag( "MultiSpec_WindowSaveButton", false)
end

function MultiSpec.PopulateData()
for i=1,5 do
ButtonSetPressedFlag("MultiSpec_WindowListRow"..i,MultiSpec.SelectedListBox == (ListBoxGetDataIndex("MultiSpec_WindowList", i)))
        -- Show the background for every other button   
        local color = GameDefs.RowColorInvalid
        local row_mod = math.mod(i, 2)
        local color = DataUtils.GetAlternatingRowColor( row_mod )
        local targetRowWindow = "MultiSpec_WindowListRow"..i

            WindowSetTintColor(targetRowWindow.."Background", color.r, color.g, color.b )
            WindowSetAlpha(targetRowWindow.."Background", color.a)

end
ButtonSetDisabledFlag( "MultiSpec_WindowClearButton",true or MultiSpec.Speccs[MultiSpec.SelectedListBox].Atype < 1)
ButtonSetDisabledFlag( "MultiSpec_WindowLoadButton",true or  MultiSpec.Speccs[MultiSpec.SelectedListBox].Atype < 1)	

end

--dirty specc compare
function MultiSpec.Compare(Specc1,Specc2,Specc3)
if Specc3 > Specc2 and Specc3 > Specc1 then return 3
elseif Specc2 > Specc3 and Specc2 > Specc1 then return 2
else return 1
 end
end

function MultiSpec.OnShown()
WindowUtils.OnShown(MultiSpec.OnHidden, WindowUtils.Cascade.MODE_AUTOMATIC)
end

function MultiSpec.OnHidden()
WindowUtils.OnHidden()
end

function MultiSpec.Save()
if NameEdit == true then return end
SendChatText(L"]spec save "..towstring(MultiSpec.SelectedListBox),ChatSettings.Channels[0].serverCmd)
end

function MultiSpec.Load()
if NameEdit == true then return end
SendChatText(L"]spec load "..towstring(MultiSpec.SelectedListBox),ChatSettings.Channels[0].serverCmd)
end

function MultiSpec.Clear()
if NameEdit == true then return end
SendChatText(L"]spec delete "..towstring(MultiSpec.SelectedListBox),ChatSettings.Channels[0].serverCmd)
MultiSpec.Name[tostring(PlayerName)][MultiSpec.SelectedListBox] = nil
end

function MultiSpec.Close()
WindowSetShowing("MultiSpec_Window",not WindowGetShowing("MultiSpec_Window"))
end

function MultiSpec.OnShutdown()	
UnregisterEventHandler(TextLogGetUpdateEventId("Chat"), "MultiSpec.OnChatLogUpdated")
end