EA_Button_PlayerAssist = ButtonFrame:Subclass("EA_Button_PlayerAssist")

EA_PlayerAssist = {}

EA_PlayerAssist.CONTAINER_WINDOW = "EA_AssistWindow"

local WINDOW_NAME = "EA_AssistWindowMainAssist"

function EA_PlayerAssist.UpdateButtonEnabled( hasTarget )
    if( hasTarget ~= nil)
    then
	    ButtonSetDisabledFlag(WINDOW_NAME,  not hasTarget )
	end
end


function EA_PlayerAssist.Initialize()
      
	local button = EA_Button_PlayerAssist:Create( WINDOW_NAME, GameData.AssistType.MAIN_ASSIST )
    button:SetAnchor( { Point = "topleft", RelativePoint = "topleft", RelativeTo = EA_PlayerAssist.CONTAINER_WINDOW, XOffset = 0, YOffset = 0} )
    button:SetParent(EA_PlayerAssist.CONTAINER_WINDOW )

    -- Register this window for movement with the Layout Editor
    LayoutEditor.RegisterWindow( EA_PlayerAssist.CONTAINER_WINDOW,  
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_ASSIST_WINDOW_NAME ),
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_ASSIST_WINDOW_DESC ),
                                false, false,
                                true, nil )
                                
    -- Register events
    RegisterEventHandler( SystemData.Events.GROUP_UPDATED, "EA_Button_PlayerAssist.UpdateButtonVisibility")
    RegisterEventHandler( SystemData.Events.BATTLEGROUP_UPDATED, "EA_Button_PlayerAssist.UpdateButtonVisibility")
    
    WindowRegisterEventHandler( WINDOW_NAME, SystemData.Events.MAIN_ASSIST_TARGET_UPDATED, "EA_PlayerAssist.UpdateButtonEnabled")
	
    EA_PlayerAssist.UpdateButtonEnabled( false )
    EA_Button_PlayerAssist:UpdateButtonVisibility()
end

function EA_PlayerAssist.DisplayTooltip()
    local text = GetString( StringTables.Default.LABEL_ASSIST_MAIN_ASSIST )
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, text )
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT )
end


function EA_Button_PlayerAssist:Create( windowName, assistType )
    local newButton = self:CreateFromTemplate( windowName )
    
    WindowSetGameActionData( windowName, GameData.PlayerActions.ASSIST_PLAYER, assistType, L"" )
    
    newButton:Show( true )
    return newButton
end


function EA_Button_PlayerAssist:UpdateButtonVisibility()
	local isPlayerSolo = ( IsPlayerSolo() == 1 )
    
    WindowSetShowing( WINDOW_NAME, not isPlayerSolo )
    if( isPlayerSolo )
    then
        EA_PlayerAssist.UpdateButtonEnabled( false )
    end
end