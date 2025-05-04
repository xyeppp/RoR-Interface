

function EA_Window_WorldMap.InitializeWorldView()
    
    -- Static Title
    local text = GetStringFromTable("MapSystem", StringTables.MapSystem.LABEL_THE_WARHAMMER_WORLD )    
    LabelSetText("EA_Window_WorldMapWorldViewBorderTitleText", text)
    
    
    -- Set the Text for each Pairing Button
    ButtonSetText("EA_Window_WorldMapWorldViewPairingButton1", GetStringFromTable("MapSystem", StringTables.MapSystem.LABEL_PAIRING_BUTTON_1 ) )
    ButtonSetText("EA_Window_WorldMapWorldViewPairingButton2", GetStringFromTable("MapSystem", StringTables.MapSystem.LABEL_PAIRING_BUTTON_2 ) )
    ButtonSetText("EA_Window_WorldMapWorldViewPairingButton3", GetStringFromTable("MapSystem", StringTables.MapSystem.LABEL_PAIRING_BUTTON_3 ) )
    ButtonSetText("EA_Window_WorldMapWorldViewPairingButton100", GetStringFromTable("MapSystem", StringTables.MapSystem.LABEL_EXPANSION_MAP_REGION_BUTTON_100 ) )
    
end


function EA_Window_WorldMap.ShutdownWorldView()

end

function EA_Window_WorldMap.SelectPairing()
    local mapLevel          = GameDefs.MapLevel.PAIRING_MAP
    local mapNumber         = WindowGetId( SystemData.ActiveWindow.name )
    
    EA_Window_WorldMap.SetMap(mapLevel, mapNumber)
end
