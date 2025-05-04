----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

ContestedInstanceSelectionWindow = {}

ContestedInstanceSelectionWindow.AUTO_CANCEL_TIME = 60 -- Seconds. Should match value on server.

ContestedInstanceSelectionWindow.zone = 0
ContestedInstanceSelectionWindow.canInvade = false
ContestedInstanceSelectionWindow.autoCancelTime = 0

----------------------------------------------------------------------------------------
-- ContestedInstanceSelectionWindow Functions
----------------------------------------------------------------------------------------

function ContestedInstanceSelectionWindow.Initialize()

    WindowRegisterEventHandler( "ContestedInstanceSelectionWindow", SystemData.Events.CONTESTED_SCENARIO_SELECT_INSTANCE, "ContestedInstanceSelectionWindow.OnSelectInstance")
    
    LabelSetText( "ContestedInstanceSelectionWindowTitleBarText", GetString( StringTables.Default.LABEL_CONTESTED_INSTANCE_LOBBY ) )
    LabelSetText( "ContestedInstanceSelectionWindowInstructions", GetString( StringTables.Default.LABEL_CONTESTED_INSTANCE_INSTRUCTIONS ) )
    
    ButtonSetText("ContestedInstanceSelectionWindowInvadeButton", GetString( StringTables.Default.LABEL_CONTESTED_INSTANCE_INVADE ) )
    ButtonSetText("ContestedInstanceSelectionWindowNewButton", GetString( StringTables.Default.LABEL_CONTESTED_INSTANCE_NEW ) )
    ButtonSetText("ContestedInstanceSelectionWindowCancelButton", GetString( StringTables.Default.LABEL_CANCEL ) )
    
end

function ContestedInstanceSelectionWindow.Hide()
    ContestedInstanceSelectionWindow.autoCancelTime = 0
    WindowSetShowing( "ContestedInstanceSelectionWindow", false )
end

function ContestedInstanceSelectionWindow.OnShown()
    WindowUtils.OnShown()    
end

function ContestedInstanceSelectionWindow.OnHidden()
    WindowUtils.OnHidden()
end

function ContestedInstanceSelectionWindow.UpdateAutoCancelLabel()
    local time = TimeUtils.FormatClock(ContestedInstanceSelectionWindow.autoCancelTime)
    local text = GetStringFormat( StringTables.Default.TEXT_JOIN_SCENARIO_RESPOND_TIME, { time } )
    LabelSetText("ContestedInstanceSelectionWindowRespondTime", text )
end

function ContestedInstanceSelectionWindow.OnUpdate(timePassed)
    if (ContestedInstanceSelectionWindow.autoCancelTime > 0) then
        local oldAutoCancelTime = ContestedInstanceSelectionWindow.autoCancelTime
        ContestedInstanceSelectionWindow.autoCancelTime = ContestedInstanceSelectionWindow.autoCancelTime - timePassed
        
        if (ContestedInstanceSelectionWindow.autoCancelTime <= 0) then
            ContestedInstanceSelectionWindow.OnCancel()
        elseif (math.floor(oldAutoCancelTime + 0.5) ~= math.floor(ContestedInstanceSelectionWindow.autoCancelTime + 0.5)) then
            ContestedInstanceSelectionWindow.UpdateAutoCancelLabel()
        end
    end
end

function ContestedInstanceSelectionWindow.OnSelectInstance(zone, canInvade, canJoinAsWarband)
    if( WindowGetShowing("ContestedInstanceSelectionWindow") == false ) then
        WindowSetShowing("ContestedInstanceSelectionWindow", true)
    end
    
    ButtonSetDisabledFlag( "ContestedInstanceSelectionWindowInvadeButton", not canInvade )
    
    ContestedInstanceSelectionWindow.zone = zone
    ContestedInstanceSelectionWindow.canInvade = canInvade
    
    ContestedInstanceSelectionWindow.autoCancelTime = ContestedInstanceSelectionWindow.AUTO_CANCEL_TIME
    ContestedInstanceSelectionWindow.UpdateAutoCancelLabel()
end

function ContestedInstanceSelectionWindow.OnInvade()
    if (ContestedInstanceSelectionWindow.canInvade) then
        GameData.ContestedInstance.zone = ContestedInstanceSelectionWindow.zone
        GameData.ContestedInstance.invade = true
        BroadcastEvent( SystemData.Events.CONTESTED_INSTANCE_ENTER )
    
        ContestedInstanceSelectionWindow.Hide()
    end
end

function ContestedInstanceSelectionWindow.OnNew()
    GameData.ContestedInstance.zone = ContestedInstanceSelectionWindow.zone
    GameData.ContestedInstance.invade = false
    BroadcastEvent( SystemData.Events.CONTESTED_INSTANCE_ENTER )
    
    ContestedInstanceSelectionWindow.Hide()
end

function ContestedInstanceSelectionWindow.OnCancel()
    BroadcastEvent( SystemData.Events.CONTESTED_INSTANCE_CANCEL )
    
    ContestedInstanceSelectionWindow.Hide()
end
