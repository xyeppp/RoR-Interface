SettingsWindowTabServer = {}
SettingsWindowTabServer.contentsName = "SWTabServerContentsScrollChild"
local SendString
local BooltoString = {[true]=1,[false]=0}
local StringtoBool = {[0]=false,[1]=true}

function SettingsWindowTabServer.Initialize()

    -- Server Settings can only be modified In-Game.
    if( not InterfaceCore.inGame )
    then
        -- Disable the Tab
        ButtonSetDisabledFlag(SettingsWindowTabbed.Tabs[ SettingsWindowTabbed.TABS_INTERFACE ].name, true )
        return
    end
	
	if not SettingsWindowTabServer.SavedSettings then SettingsWindowTabServer.SavedSettings = {} end
	--add new settings here, wich will set the "default" value if it doesnt exist (if new options are added, etc..)   
	if not SettingsWindowTabServer.SavedSettings.ShowEnemyAppearance then SettingsWindowTabServer.SavedSettings.ShowEnemyAppearance = 1 end  
	if not SettingsWindowTabServer.SavedSettings.DisableVFX then SettingsWindowTabServer.SavedSettings.DisableVFX = 0 end  

    -- ShowEnemyAppearance
    LabelSetText( SettingsWindowTabServer.contentsName.."SettingsServerTitle", L"Visibility" )
    LabelSetText( SettingsWindowTabServer.contentsName.."SettingsServerOption1Label", L"Show Enemy Appearance" )
    LabelSetText( SettingsWindowTabServer.contentsName.."SettingsServerEnableOption1Label",L"Enable" )
    ButtonSetCheckButtonFlag( SettingsWindowTabServer.contentsName.."SettingsServerEnableOption1Button", StringtoBool[SettingsWindowTabServer.SavedSettings.ShowEnemyAppearance])
	
    -- DisableVFX
    LabelSetText( SettingsWindowTabServer.contentsName.."SettingsServerOption2Label", L"DisableVFX" )
    LabelSetText( SettingsWindowTabServer.contentsName.."SettingsServerEnableOption2Label",L"Enable" )
    ButtonSetCheckButtonFlag( SettingsWindowTabServer.contentsName.."SettingsServerEnableOption2Button", StringtoBool[SettingsWindowTabServer.SavedSettings.DisableVFX])
end

function SettingsWindowTabServer.UpdateSettings()

    -- Server Settings can only be modified In-Game.
    if( not InterfaceCore.inGame )
    then        
        return
    end
	
    ButtonSetPressedFlag( SettingsWindowTabServer.contentsName.."SettingsServerEnableOption1Button", StringtoBool[SettingsWindowTabServer.SavedSettings.ShowEnemyAppearance] )
    ButtonSetPressedFlag( SettingsWindowTabServer.contentsName.."SettingsServerEnableOption2Button", StringtoBool[SettingsWindowTabServer.SavedSettings.DisableVFX] )
	SettingsWindowTabServer.SendUpdate()
end

function SettingsWindowTabServer.ApplyCurrent()

    -- Server Settings can only be modified In-Game.
    if( not InterfaceCore.inGame )
    then        
        return
    end
	
	--Sets the new settings values
	SettingsWindowTabServer.SavedSettings.ShowEnemyAppearance = BooltoString[ButtonGetPressedFlag(SettingsWindowTabServer.contentsName.."SettingsServerEnableOption1Button")]
	SettingsWindowTabServer.SavedSettings.DisableVFX = BooltoString[ButtonGetPressedFlag(SettingsWindowTabServer.contentsName.."SettingsServerEnableOption2Button")]
	
	--Add sending script here, will run on startup/relog/reload
	SettingsWindowTabServer.SendUpdate()
end

function SettingsWindowTabServer.SendUpdate()
	SendString = L"]uiserver "
	for k,v in pairs(SettingsWindowTabServer.SavedSettings) do
		SendString = SendString..StringToWString(k)..L"#"..v..L":"
	end
	SendString = SendString:sub(1,-2) --removing the last :

	SendChatText(towstring(SendString),ChatSettings.Channels[0].serverCmd) --send to server
end
