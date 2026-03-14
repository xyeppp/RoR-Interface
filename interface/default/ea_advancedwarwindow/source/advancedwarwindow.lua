----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_AdvancedWar = {}

EA_Window_AdvancedWar.fortressData  = nil
EA_Window_AdvancedWar.relicData     = nil


-- Keep IDs for Fortresses to Ensure Proper Layout in the UI
EA_Window_AdvancedWar.FORTRESS_DWARF        = 101
EA_Window_AdvancedWar.FORTRESS_GREENSKIN    = 102
EA_Window_AdvancedWar.FORTRESS_EMPIRE       = 103
EA_Window_AdvancedWar.FORTRESS_CHAOS        = 104
EA_Window_AdvancedWar.FORTRESS_HIGH_ELF     = 105
EA_Window_AdvancedWar.FORTRESS_DARK_ELF     = 106

-- Tab Information
EA_Window_AdvancedWar.numSubAreas   = 4
EA_Window_AdvancedWar.numTabs       = 3
EA_Window_AdvancedWar.TAB_GVD       = 1
EA_Window_AdvancedWar.TAB_EVC       = 2
EA_Window_AdvancedWar.TAB_ELF       = 3

EA_Window_AdvancedWar.TabData = {}
EA_Window_AdvancedWar.TabData [EA_Window_AdvancedWar.TAB_GVD]           = { tabName = "TabGvD",         windowName = "GvD",     order = "Dwarf",    destruction="Greenskin" }
EA_Window_AdvancedWar.TabData [EA_Window_AdvancedWar.TAB_EVC]           = { tabName = "TabEvC",         windowName = "EvC",     order = "Empire",   destruction="Chaos" }
EA_Window_AdvancedWar.TabData [EA_Window_AdvancedWar.TAB_ELF]           = { tabName = "TabElf",         windowName = "Elf",     order = "HighElf",  destruction="DarkElf" }

EA_Window_AdvancedWar.RelicUIDetails = {}
EA_Window_AdvancedWar.RelicUIDetails [GameData.Factions.DWARF]          = { homekeepid = EA_Window_AdvancedWar.FORTRESS_DWARF }
EA_Window_AdvancedWar.RelicUIDetails [GameData.Factions.GREENSKIN]      = { homekeepid = EA_Window_AdvancedWar.FORTRESS_GREENSKIN }
EA_Window_AdvancedWar.RelicUIDetails [GameData.Factions.HIGH_ELF]       = { homekeepid = EA_Window_AdvancedWar.FORTRESS_HIGH_ELF }
EA_Window_AdvancedWar.RelicUIDetails [GameData.Factions.DARK_ELF]       = { homekeepid = EA_Window_AdvancedWar.FORTRESS_DARK_ELF }
EA_Window_AdvancedWar.RelicUIDetails [GameData.Factions.EMPIRE]         = { homekeepid = EA_Window_AdvancedWar.FORTRESS_EMPIRE }
EA_Window_AdvancedWar.RelicUIDetails [GameData.Factions.CHAOS]          = { homekeepid = EA_Window_AdvancedWar.FORTRESS_CHAOS }

EA_Window_AdvancedWar.FortressUIDetails = {}
EA_Window_AdvancedWar.FortressUIDetails [EA_Window_AdvancedWar.FORTRESS_DWARF]      = { tab = EA_Window_AdvancedWar.TAB_GVD,    name = StringTables.RvRCity.FORTRESS_NAME_DWARF,        homerealm = GameData.Realm.ORDER,       ui = "EA_Window_AdvancedWarGvDDwarfFortress" }
EA_Window_AdvancedWar.FortressUIDetails [EA_Window_AdvancedWar.FORTRESS_GREENSKIN]  = { tab = EA_Window_AdvancedWar.TAB_GVD,    name = StringTables.RvRCity.FORTRESS_NAME_GREENSKIN,    homerealm = GameData.Realm.DESTRUCTION, ui = "EA_Window_AdvancedWarGvDGreenskinFortress" }
EA_Window_AdvancedWar.FortressUIDetails [EA_Window_AdvancedWar.FORTRESS_EMPIRE]     = { tab = EA_Window_AdvancedWar.TAB_EVC,    name = StringTables.RvRCity.FORTRESS_NAME_EMPIRE,       homerealm = GameData.Realm.ORDER,       ui = "EA_Window_AdvancedWarEvCEmpireFortress" }
EA_Window_AdvancedWar.FortressUIDetails [EA_Window_AdvancedWar.FORTRESS_CHAOS]      = { tab = EA_Window_AdvancedWar.TAB_EVC,    name = StringTables.RvRCity.FORTRESS_NAME_CHAOS,        homerealm = GameData.Realm.DESTRUCTION, ui = "EA_Window_AdvancedWarEvCChaosFortress" }
EA_Window_AdvancedWar.FortressUIDetails [EA_Window_AdvancedWar.FORTRESS_HIGH_ELF]   = { tab = EA_Window_AdvancedWar.TAB_ELF,    name = StringTables.RvRCity.FORTRESS_NAME_HIGH_ELF,     homerealm = GameData.Realm.ORDER,       ui = "EA_Window_AdvancedWarElfHighElfFortress" }
EA_Window_AdvancedWar.FortressUIDetails [EA_Window_AdvancedWar.FORTRESS_DARK_ELF]   = { tab = EA_Window_AdvancedWar.TAB_ELF,    name = StringTables.RvRCity.FORTRESS_NAME_DARK_ELF,     homerealm = GameData.Realm.DESTRUCTION, ui = "EA_Window_AdvancedWarElfDarkElfFortress" }

local PARENT_WINDOW = "EA_Window_AdvancedWar"

EA_Window_AdvancedWar.TOOLTIP_ANCHOR = { Point = "topright", RelativeTo = "EA_Window_AdvancedWar", RelativePoint = "topleft", XOffset=5, YOffset=75 }

-- Local Functions

local function GetRelicRealm(relicFaction)

    if (relicFaction == GameData.Factions.DWARF) or (relicFaction == GameData.Factions.EMPIRE) or (relicFaction == GameData.Factions.HIGH_ELF)
    then
        return GameData.Realm.ORDER
    elseif (relicFaction == GameData.Factions.GREENSKIN) or (relicFaction == GameData.Factions.CHAOS) or (relicFaction == GameData.Factions.DARK_ELF)
    then
        return GameData.Realm.DESTRUCTION
    end
    
    return GameData.Realm.NONE
    
end

local function ToggleSubareaUIElements(tabNumber, realm, show)

    local tabName = "EA_Window_AdvancedWar" .. EA_Window_AdvancedWar.TabData[tabNumber].windowName
    
    if(realm == GameData.Realm.ORDER)
    then
        tabName = tabName .. EA_Window_AdvancedWar.TabData[tabNumber].order .. "FortressSubarea"
    else
        tabName = tabName .. EA_Window_AdvancedWar.TabData[tabNumber].destruction .. "FortressSubarea"
    end
    
    for j = 1, EA_Window_AdvancedWar.numSubAreas
    do        
        local labelName         = tabName .. j
        local iconName          = tabName .. "Icon" .. j
    
        WindowSetShowing( labelName, show )
        WindowSetShowing( iconName, show )
    end
    
end

local function InitializeSubareaLabels()

    for i = 1, EA_Window_AdvancedWar.numTabs
    do
        local tabOrder          = "EA_Window_AdvancedWar" .. EA_Window_AdvancedWar.TabData[i].windowName .. EA_Window_AdvancedWar.TabData[i].order .. "FortressSubarea"
        local tabDestruction    = "EA_Window_AdvancedWar" .. EA_Window_AdvancedWar.TabData[i].windowName .. EA_Window_AdvancedWar.TabData[i].destruction .. "FortressSubarea"
            
        for j = 1, EA_Window_AdvancedWar.numSubAreas
        do
            local tabOrderLabel         = tabOrder .. j
            local tabDestructionLabel   = tabDestruction .. j
            
            LabelSetText(tabOrderLabel, GetStringFromTable("RvRCityStrings", StringTables.RvRCity.LABEL_FORTRESS_SUBAREA_UNCLAIMED))
            LabelSetText(tabDestructionLabel, GetStringFromTable("RvRCityStrings", StringTables.RvRCity.LABEL_FORTRESS_SUBAREA_UNCLAIMED))
        end
    end 
    
end

-- OnInitialize Handler
function EA_Window_AdvancedWar.Initialize()        
  
    -- Events
    WindowRegisterEventHandler( "EA_Window_AdvancedWar", SystemData.Events.INTERACT_SHOW_ADVANCED_WAR_WINDOW, "EA_Window_AdvancedWar.Show")
    WindowRegisterEventHandler( "EA_Window_AdvancedWar", SystemData.Events.ADVANCED_WAR_FORTRESS_UPDATE, "EA_Window_AdvancedWar.HandleFortressUpdate")
    WindowRegisterEventHandler( "EA_Window_AdvancedWar", SystemData.Events.ADVANCED_WAR_RELIC_UPDATE, "EA_Window_AdvancedWar.HandleRelicUpdate")
    WindowRegisterEventHandler( "EA_Window_AdvancedWar", SystemData.Events.ADVANCED_WAR_RELIC_ZONE_UPDATE, "EA_Window_AdvancedWar.HandleRelicZoneUpdate")
    
    -- Relics
    WindowSetShowing( "EA_Window_AdvancedWarGvDGreenskinFortressRelicInTransit",       false )
    WindowSetShowing( "EA_Window_AdvancedWarGvDGreenskinFortressRelicSecure",          false )
    WindowSetShowing( "EA_Window_AdvancedWarGvDGreenskinFortressRelicCaptured",        false )    
    WindowSetShowing( "EA_Window_AdvancedWarGvDDwarfFortressRelicInTransit",           false )
    WindowSetShowing( "EA_Window_AdvancedWarGvDDwarfFortressRelicSecure",              false )
    WindowSetShowing( "EA_Window_AdvancedWarGvDDwarfFortressRelicCaptured",            false )
    
    WindowSetShowing( "EA_Window_AdvancedWarEvCChaosFortressRelicInTransit",           false )
    WindowSetShowing( "EA_Window_AdvancedWarEvCChaosFortressRelicSecure",              false )
    WindowSetShowing( "EA_Window_AdvancedWarEvCChaosFortressRelicCaptured",            false )    
    WindowSetShowing( "EA_Window_AdvancedWarEvCEmpireFortressRelicInTransit",          false )
    WindowSetShowing( "EA_Window_AdvancedWarEvCEmpireFortressRelicSecure",             false )
    WindowSetShowing( "EA_Window_AdvancedWarEvCEmpireFortressRelicCaptured",           false )
    
    WindowSetShowing( "EA_Window_AdvancedWarElfDarkElfFortressRelicInTransit",         false )
    WindowSetShowing( "EA_Window_AdvancedWarElfDarkElfFortressRelicSecure",            false )
    WindowSetShowing( "EA_Window_AdvancedWarElfDarkElfFortressRelicCaptured",          false )    
    WindowSetShowing( "EA_Window_AdvancedWarElfHighElfFortressRelicInTransit",         false )
    WindowSetShowing( "EA_Window_AdvancedWarElfHighElfFortressRelicSecure",            false )
    WindowSetShowing( "EA_Window_AdvancedWarElfHighElfFortressRelicCaptured",          false )
    
    -- Tabs Setup
    EA_Window_AdvancedWar.SelectTab( EA_Window_AdvancedWar.TAB_GVD )
    LabelSetText( "EA_Window_AdvancedWarGvDGreenskinFortressRelicName", GetStringFromTable("RvRCityStrings", StringTables.RvRCity.LABEL_RELIC_STATUS ) ) 
    LabelSetText( "EA_Window_AdvancedWarGvDDwarfFortressRelicName", GetStringFromTable("RvRCityStrings", StringTables.RvRCity.LABEL_RELIC_STATUS ) ) 
    LabelSetText( "EA_Window_AdvancedWarEvCChaosFortressRelicName", GetStringFromTable("RvRCityStrings", StringTables.RvRCity.LABEL_RELIC_STATUS ) ) 
    LabelSetText( "EA_Window_AdvancedWarEvCEmpireFortressRelicName", GetStringFromTable("RvRCityStrings", StringTables.RvRCity.LABEL_RELIC_STATUS ) ) 
    LabelSetText( "EA_Window_AdvancedWarElfDarkElfFortressRelicName", GetStringFromTable("RvRCityStrings", StringTables.RvRCity.LABEL_RELIC_STATUS ) ) 
    LabelSetText( "EA_Window_AdvancedWarElfHighElfFortressRelicName", GetStringFromTable("RvRCityStrings", StringTables.RvRCity.LABEL_RELIC_STATUS ) ) 
    
    LabelSetText( "EA_Window_AdvancedWarGvDGreenskinFortressRelicStatus", GetStringFromTable("RvRCityStrings", StringTables.RvRCity.LABEL_RELIC_STATUS_SECURE ) ) 
    LabelSetText( "EA_Window_AdvancedWarGvDDwarfFortressRelicStatus", GetStringFromTable("RvRCityStrings", StringTables.RvRCity.LABEL_RELIC_STATUS_SECURE ) ) 
    LabelSetText( "EA_Window_AdvancedWarEvCChaosFortressRelicStatus", GetStringFromTable("RvRCityStrings", StringTables.RvRCity.LABEL_RELIC_STATUS_SECURE ) ) 
    LabelSetText( "EA_Window_AdvancedWarEvCEmpireFortressRelicStatus", GetStringFromTable("RvRCityStrings", StringTables.RvRCity.LABEL_RELIC_STATUS_SECURE ) ) 
    LabelSetText( "EA_Window_AdvancedWarElfDarkElfFortressRelicStatus", GetStringFromTable("RvRCityStrings", StringTables.RvRCity.LABEL_RELIC_STATUS_SECURE ) ) 
    LabelSetText( "EA_Window_AdvancedWarElfHighElfFortressRelicStatus", GetStringFromTable("RvRCityStrings", StringTables.RvRCity.LABEL_RELIC_STATUS_SECURE ) ) 
    
    for i = 1, EA_Window_AdvancedWar.numTabs
    do
        ToggleSubareaUIElements(i, GameData.Realm.ORDER, false)
        ToggleSubareaUIElements(i, GameData.Realm.DESTRUCTION, false)
    end
    
    InitializeSubareaLabels()
    
    LabelSetText( "EA_Window_AdvancedWarTitleBarText", GetString( StringTables.Default.LABEL_ADVANCED_WAR_TITLE ) ) 
    
    ButtonSetText( "EA_Window_AdvancedWarTabGvD", GetStringFromTable("RvRCityStrings", StringTables.RvRCity.LABEL_ADVANCED_WAR_GVD ) )
    ButtonSetText( "EA_Window_AdvancedWarTabEvC", GetStringFromTable("RvRCityStrings", StringTables.RvRCity.LABEL_ADVANCED_WAR_EVC ) )
    ButtonSetText( "EA_Window_AdvancedWarTabElf", GetStringFromTable("RvRCityStrings", StringTables.RvRCity.LABEL_ADVANCED_WAR_ELF ) )   
    
    EA_Window_AdvancedWar.HandleFortressUpdate()
    EA_Window_AdvancedWar.HandleRelicUpdate()
    EA_Window_AdvancedWar.HandleRelicZoneUpdate()
    
end

-- OnShutdown Handler
function EA_Window_AdvancedWar.Shutdown()
    EA_Window_AdvancedWar.Hide()
end

function EA_Window_AdvancedWar.Hide()
    WindowSetShowing( "EA_Window_AdvancedWar", false )
end

function EA_Window_AdvancedWar.Show()
    WindowSetShowing( "EA_Window_AdvancedWar", true )
end

function EA_Window_AdvancedWar.OnShown()
    WindowUtils.OnShown()
end

function EA_Window_AdvancedWar.OnHidden()   
    WindowUtils.OnHidden()  
end

function EA_Window_AdvancedWar.OnClickTab()
    local tabId = WindowGetId( SystemData.ActiveWindow.name )
    EA_Window_AdvancedWar.SelectTab( tabId )
end

function EA_Window_AdvancedWar.SelectTab( tab )
    if( EA_Window_AdvancedWar.TabData[tab] == nil )
    then
        tab = EA_Window_AdvancedWar.TAB_GVD
    end
    
    for tabId, tabData in pairs( EA_Window_AdvancedWar.TabData )
    do
        local activeTab = (tabId == tab)
        WindowSetShowing( PARENT_WINDOW..tabData.windowName, activeTab )
        ButtonSetPressedFlag( PARENT_WINDOW..tabData.tabName, activeTab )
    end
end

--
-- Update Handlers 
--
 
function EA_Window_AdvancedWar.HandleFortressUpdate()
    
    EA_Window_AdvancedWar.fortressData = GetFortressStatuses()
        
  if (EA_Window_AdvancedWar.fortressData~=nil) then 
    for index, data in ipairs( EA_Window_AdvancedWar.fortressData ) 
	do	    
        local keepId        = EA_Window_AdvancedWar.fortressData[index].id
        local labelName     = EA_Window_AdvancedWar.FortressUIDetails[keepId].ui .. "Name"
        local labelOwner    = EA_Window_AdvancedWar.FortressUIDetails[keepId].ui .. "Owner"
        
        LabelSetText(labelName, GetStringFromTable("RvRCityStrings", EA_Window_AdvancedWar.FortressUIDetails[keepId].name))  
        
        local hasOwner = false
        if (EA_Window_AdvancedWar.fortressData[index].currentOwningGuild == nil) or (wstring.len(EA_Window_AdvancedWar.fortressData[index].currentOwningGuild) < 1)
        then        
            LabelSetText(labelOwner, GetStringFromTable("RvRCityStrings", StringTables.RvRCity.LABEL_FORTRESS_UNCLAIMED))
        else
            hasOwner = true
            LabelSetText(labelOwner, EA_Window_AdvancedWar.fortressData[index].currentOwningGuild)
        end
                
        ToggleSubareaUIElements(EA_Window_AdvancedWar.FortressUIDetails[keepId].tab, EA_Window_AdvancedWar.FortressUIDetails[keepId].homerealm, hasOwner)
        
        for subareaIndex, subareaData in ipairs( EA_Window_AdvancedWar.fortressData[index] )
        do
            local subareaId         = subareaData.id
            local labelSubareaOwner = EA_Window_AdvancedWar.FortressUIDetails[keepId].ui .. "Subarea" .. subareaId
                        
            if(hasOwner == true)
            then                
                if (subareaData.currentOwningGuild == nil) or (wstring.len(subareaData.currentOwningGuild) < 1)
                then
                    LabelSetText(labelSubareaOwner, GetStringFromTable("RvRCityStrings", StringTables.RvRCity.LABEL_FORTRESS_SUBAREA_UNCLAIMED))
                else            
                    LabelSetText(labelSubareaOwner, subareaData.currentOwningGuild)
                end
            else
                LabelSetText(labelSubareaOwner, GetStringFromTable("RvRCityStrings", StringTables.RvRCity.LABEL_FORTRESS_SUBAREA_UNCLAIMED))
            end
        end
        
	end
  end
end

function EA_Window_AdvancedWar.UpdateRelicStatusInterfaceElements( relicRealm, status, relicUIName )

    WindowSetShowing( relicUIName.."Secure",          false )
    WindowSetShowing( relicUIName.."InTransit",       false )
    WindowSetShowing( relicUIName.."Captured",        false )
    
    if (relicRealm == GameData.Player.realm)
    then
        
        if (status == GameData.RelicStatuses.SECURE)
        then
            WindowSetShowing( relicUIName.."Secure", true )
            LabelSetText( relicUIName.."Status", GetStringFromTable("RvRCityStrings", StringTables.RvRCity.LABEL_RELIC_STATUS_SECURE) )
            LabelSetTextColor( relicUIName.."Status", DefaultColor.GREEN.r, DefaultColor.GREEN.g, DefaultColor.GREEN.b )
        elseif (status == GameData.RelicStatuses.INTRANSIT)
        then
            WindowSetShowing( relicUIName.."InTransit", true )
            LabelSetText( relicUIName.."Status", GetStringFromTable("RvRCityStrings", StringTables.RvRCity.LABEL_RELIC_STATUS_INTRANSIT) )
            LabelSetTextColor( relicUIName.."Status", DefaultColor.LIGHT_BLUE.r, DefaultColor.LIGHT_BLUE.g, DefaultColor.LIGHT_BLUE.b )
        elseif (status == GameData.RelicStatuses.CAPTURED)
        then
            WindowSetShowing( relicUIName.."Captured", true )
            LabelSetText( relicUIName.."Status", GetStringFromTable("RvRCityStrings", StringTables.RvRCity.LABEL_RELIC_STATUS_CAPTURED) )
            LabelSetTextColor( relicUIName.."Status", DefaultColor.RED.r, DefaultColor.RED.g, DefaultColor.RED.b )
        else
            LabelSetText( relicUIName.."Status", GetStringFromTable("RvRCityStrings", StringTables.RvRCity.LABEL_RELIC_STATUS_UNKNOWN) )
            LabelSetTextColor( relicUIName.."Status", DefaultColor.CLEAR_WHITE.r, DefaultColor.CLEAR_WHITE.g, DefaultColor.CLEAR_WHITE.b )
        end  
          
    else
        
        if (status == GameData.RelicStatuses.SECURE)
        then
            WindowSetShowing( relicUIName.."Captured", true )          
            LabelSetText( relicUIName.."Status", GetStringFromTable("RvRCityStrings", StringTables.RvRCity.LABEL_RELIC_STATUS_SECURE_ENEMY) )
            LabelSetTextColor( relicUIName.."Status", DefaultColor.RED.r, DefaultColor.RED.g, DefaultColor.RED.b )
        elseif (status == GameData.RelicStatuses.INTRANSIT)
        then
            WindowSetShowing( relicUIName.."InTransit", true )
            LabelSetText( relicUIName.."Status", GetStringFromTable("RvRCityStrings", StringTables.RvRCity.LABEL_RELIC_STATUS_INTRANSIT) )
            LabelSetTextColor( relicUIName.."Status", DefaultColor.LIGHT_BLUE.r, DefaultColor.LIGHT_BLUE.g, DefaultColor.LIGHT_BLUE.b )
        elseif (status == GameData.RelicStatuses.CAPTURED)
        then
            WindowSetShowing( relicUIName.."Secure", true )              
            LabelSetText( relicUIName.."Status", GetStringFromTable("RvRCityStrings", StringTables.RvRCity.LABEL_RELIC_STATUS_CAPTURED_FRIENDLY) )
            LabelSetTextColor( relicUIName.."Status", DefaultColor.GREEN.r, DefaultColor.GREEN.g, DefaultColor.GREEN.b )
        else
            LabelSetText( relicUIName.."Status", GetStringFromTable("RvRCityStrings", StringTables.RvRCity.LABEL_RELIC_STATUS_UNKNOWN) )
            LabelSetTextColor( relicUIName.."Status", DefaultColor.CLEAR_WHITE.r, DefaultColor.CLEAR_WHITE.g, DefaultColor.CLEAR_WHITE.b )
        end  
        
    end

end
 
function EA_Window_AdvancedWar.HandleRelicUpdate()

    EA_Window_AdvancedWar.relicData = GetRelicStatuses()
    
  if (EA_Window_AdvancedWar.relicData~=nil) then
    for index, data in ipairs( EA_Window_AdvancedWar.relicData ) 
	do	    
        local race          = EA_Window_AdvancedWar.relicData[index].race
        local status        = EA_Window_AdvancedWar.relicData[index].status
        local homekeep      = EA_Window_AdvancedWar.RelicUIDetails[race].homekeepid        
        local relicUIName   = EA_Window_AdvancedWar.FortressUIDetails[homekeep].ui .. "Relic"
        
        local relicRealm    = GetRelicRealm(race)
        
        EA_Window_AdvancedWar.UpdateRelicStatusInterfaceElements( relicRealm, status, relicUIName )
        
	end
	end
end
 
function EA_Window_AdvancedWar.HandleRelicZoneUpdate()

    EA_Window_AdvancedWar.relicData = GetRelicStatuses()

  if (EA_Window_AdvancedWar.relicData~=nil) then
    for index, data in ipairs( EA_Window_AdvancedWar.relicData ) 
	do	    
        local race          = EA_Window_AdvancedWar.relicData[index].race
        local zoneId        = EA_Window_AdvancedWar.relicData[index].zoneId
        local homekeep      = EA_Window_AdvancedWar.RelicUIDetails[race].homekeepid
        local relicUIName   = EA_Window_AdvancedWar.FortressUIDetails[homekeep].ui .. "RelicZone"
        
        local zoneString    = GetStringFromTable("RvRCityStrings", StringTables.RvRCity.LABEL_RELIC_LOCATION)
                
        if (zoneId == nil) or (zoneId == 0)
        then            
            zoneString = zoneString .. L" " .. GetStringFromTable("RvRCityStrings", StringTables.RvRCity.LABEL_RELIC_LOCATION_DISTANT)
        else
            zoneString = zoneString .. L" " .. GetZoneName(zoneId)
        end        
        
        LabelSetText( relicUIName, zoneString )
	end
	end
end