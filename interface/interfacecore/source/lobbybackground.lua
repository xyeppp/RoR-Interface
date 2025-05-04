LobbyBackground = {}

function LobbyBackground.Initialize()
    LobbyBackground.HideServerName()
    LobbyBackground.UpdateVersionText()
end

function LobbyBackground.HideServerName()
    WindowSetShowing( "LobbyBackgroundServerName", false )
end

function LobbyBackground.UpdateServerName()
    local serverText = GetStringFormatFromTable( "Pregame", StringTables.Pregame.TEXT_SERVER_NAME, { GameData.Account.ServerName } )
    LabelSetText( "LobbyBackgroundServerName", serverText )
    WindowSetShowing( "LobbyBackgroundServerName", true )
end

function LobbyBackground.UpdateVersionText()
    LabelSetText( "LobbyBackgroundGameVersion", SystemData.ClientVersion )
end