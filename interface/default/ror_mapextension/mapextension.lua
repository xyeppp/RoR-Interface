RoR_MapExtension = {}
RoR_MapExtension.Map = {}
RoR_MapExtension.PointToBo = {}
RoR_MapExtension.Lines = {}

function RoR_MapExtension.OnInitialize()
    WindowRegisterCoreEventHandler( "EA_Window_WorldMapZoneViewMapDisplay", "OnShown", "RoR_MapExtension.Map.WorldMapOnShown" )
    WindowRegisterCoreEventHandler( "EA_Window_WorldMapZoneViewMapDisplay", "OnHidden", "RoR_MapExtension.Map.WorldMapOnHidden" )	

    RegisterEventHandler(SystemData.Events.OBJECTIVE_CONTROL_POINTS_UPDATED, "RoR_MapExtension.Map.WorldMapOnShown")
    RegisterEventHandler(SystemData.Events.OBJECTIVE_MAP_TIMER_UPDATED, "RoR_MapExtension.Map.WorldMapOnShown")
    RegisterEventHandler(SystemData.Events.OBJECTIVE_OWNER_UPDATED, "RoR_MapExtension.Map.WorldMapOnShown")
		
    CreateWindow("RoR_MapExtension_Overlay",true)
	WindowSetAlpha("RoR_MapExtension_Overlay",0)
	 
    WindowSetDimensions("RoR_MapExtension_Overlay",WindowGetDimensions("EA_Window_WorldMapZoneViewMapDisplay"))
    WindowSetScale("RoR_MapExtension_Overlay",WindowGetScale("EA_Window_WorldMapZoneViewMapDisplay"))
	
	if RoR_MapExtension.LineData == nil then RoR_MapExtension.LineData = {} end
	BuildTableFromCSV("Interface/default/RoR_MapExtension/RoR_MapExtension.csv", "RoR_MapExtension.LineData")
	
	for i=1, #RoR_MapExtension.LineData do
		CreateWindowFromTemplate("RoR_MapExtension_Draw"..i, "RoR_MapExtension_Temnlate_"..RoR_MapExtension.LineData[i].Line, "RoR_MapExtension_Overlay")		
		local Scale = WindowGetScale("EA_Window_WorldMapZoneView")
		WindowSetScale("RoR_MapExtension_Draw"..i,1*Scale)
		WindowClearAnchors( "RoR_MapExtension_Draw"..i )
		WindowAddAnchor("RoR_MapExtension_Draw"..i, "topleft", "RoR_MapExtension_Overlay", "topleft",RoR_MapExtension.LineData[i].X,RoR_MapExtension.LineData[i].Y)					
	end
	WindowClearAnchors( "RoR_MapExtension_Overlay")
	WindowAddAnchor( "RoR_MapExtension_Overlay", "topleft", "EA_Window_WorldMapZoneViewMapDisplay", "topleft",0,0)					
end

function RoR_MapExtension.Map.WorldMapOnShown()
    if WindowGetShowing("EA_Window_WorldMap") == false or GameData.Player.zone ~= 191 or EA_Window_WorldMap.currentMap ~= 191 then

	   WindowSetAlpha("RoR_MapExtension_Overlay",0)
        return
	
    end

    WindowSetDimensions("RoR_MapExtension_Overlay",WindowGetDimensions("EA_Window_WorldMapZoneViewMapDisplay"))
    WindowSetScale("RoR_MapExtension_Overlay",WindowGetScale("EA_Window_WorldMapZoneViewMapDisplay"))
	WindowSetAlpha("RoR_MapExtension_Overlay",1)

    -- Calculate which ones are connected
    local ConnectedObjectives = {[1]=1,[2]=2}
    local updated = true
    while updated do
        updated = false
        for k,v in pairs(RoR_MapExtension.LineData) do

		  local o1 = v.Object1
            local o2 = v.Object2
            if ConnectedObjectives[o1] == nil and ConnectedObjectives[o2] ~= nil then
                local ObjData = GameData.GetObjectiveData(o1)
                if (ConnectedObjectives[o2] == ObjData.controllingRealm) then
                    ConnectedObjectives[o1] = ObjData.controllingRealm
                    updated = true
                end
            elseif ConnectedObjectives[o2] == nil and ConnectedObjectives[o1] ~= nil then
                local ObjData = GameData.GetObjectiveData(o2)
                if (ConnectedObjectives[o1] == ObjData.controllingRealm) then
                    ConnectedObjectives[o2] = ObjData.controllingRealm
                    updated = true
                end
           
        end
		end
    end

    -- Set tint on connected lines
    for k,v in pairs(RoR_MapExtension.LineData) do
        local objColor = GameDefs.RealmColors[0]

        if ConnectedObjectives[v.Object1] ~= nil and ConnectedObjectives[v.Object1] == ConnectedObjectives[v.Object2] then
            objColor = GameDefs.RealmColors[ConnectedObjectives[v.Object1]]
        end

        WindowSetTintColor("RoR_MapExtension_Draw"..tostring(k),objColor.r,objColor.g,objColor.b)
    end
	RoR_MapExtension.Map.MapExtensionOnShown()
end

function RoR_MapExtension.Map.WorldMapOnHidden()
WindowSetAlpha("RoR_MapExtension_Overlay",0)
end

function RoR_MapExtension.Map.MapExtensionOnShown()

	for i=1, #RoR_MapExtension.LineData do
				DynamicImageSetRotation("RoR_MapExtension_Draw"..i.."Image",(RoR_MapExtension.LineData[i].Rotation))

end
end
