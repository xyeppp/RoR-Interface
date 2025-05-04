----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

SiegeWeaponControlWindow = {}

SiegeWeaponControlWindow.controlData = nil

SiegeWeaponControlWindow.HEALTH_BAR_COLOR = {r=0, g=255, b=0 }
SiegeWeaponControlWindow.REUSE_TIMER_BAR_COLOR = {r=255, g=255, b=0 }
SiegeWeaponControlWindow.TIMER_BAR_BG_COLOR = {r=20, g=20, b=20 }

SiegeWeaponControlWindow.REPAIR_ICON = 50
SiegeWeaponControlWindow.AIM_ICON = 51
SiegeWeaponControlWindow.RELEASE_ICON = 4419

SiegeWeaponControlWindow.lastHealthPercent = 0

SiegeWeaponControlWindow.TOOLTIP_ANCHOR = { Point = "right",  RelativeTo = "SiegeWeaponControlWindow", RelativePoint = "left",   XOffset = 5, YOffset = 0 }

SiegeWeaponControlWindow.MAX_USERS_DISPLAYED = 4

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

----------------------------------------------------------------
-- SiegeWeapon Functions
----------------------------------------------------------------


function SiegeWeaponControlWindow.Initialize()       
    
    -- Set the Repair Button Icons
    IconButtonUtils.SetIconTextures( "SiegeWeaponControlWindowRepairButton", SiegeWeaponControlWindow.REPAIR_ICON )    
    IconButtonUtils.SetIconTextures( "SiegeWeaponControlWindowAimButton", SiegeWeaponControlWindow.AIM_ICON )  
    IconButtonUtils.SetIconTextures( "SiegeWeaponControlWindowReleaseButton", SiegeWeaponControlWindow.RELEASE_ICON ) 
    WindowSetShowing("SiegeWeaponControlWindowReleaseButtonDisabledIcon", false )

     
    -- Setup the Status Bars
    local color = SiegeWeaponControlWindow.HEALTH_BAR_COLOR
    StatusBarSetForegroundTint ("SiegeWeaponInfoWindowHealthPercentBar", color.r, color.g, color.b)
    
    color = SiegeWeaponControlWindow.TIMER_BAR_BG_COLOR
    StatusBarSetBackgroundTint ("SiegeWeaponInfoWindowHealthPercentBar", color.r, color.g, color.b)    
    
    color = SiegeWeaponControlWindow.REUSE_TIMER_BAR_COLOR
    StatusBarSetForegroundTint ("SiegeWeaponStatusWindowTimerBar", color.r, color.g, color.b)
    
    color = SiegeWeaponControlWindow.TIMER_BAR_BG_COLOR
    StatusBarSetBackgroundTint ("SiegeWeaponStatusWindowTimerBar", color.r, color.g, color.b)
    
    LabelSetTextColor("SiegeWeaponStatusWindowText",  SiegeWeaponControlWindow.REUSE_TIMER_BAR_COLOR.r, SiegeWeaponControlWindow.REUSE_TIMER_BAR_COLOR.g, SiegeWeaponControlWindow.REUSE_TIMER_BAR_COLOR.b  )
       
    StatusBarSetMaximumValue( "SiegeWeaponInfoWindowHealthPercentBar", 100 )    
    
    WindowRegisterEventHandler( "SiegeWeaponControlWindow", SystemData.Events.SIEGE_WEAPON_UPDATED, "SiegeWeaponControlWindow.UpdateData" )
    WindowRegisterEventHandler( "SiegeWeaponControlWindow", SystemData.Events.SIEGE_WEAPON_HEALTH_UPDATED, "SiegeWeaponControlWindow.OnUpdateHealth" )
    WindowRegisterEventHandler( "SiegeWeaponControlWindow", SystemData.Events.SIEGE_WEAPON_STATE_UPDATED, "SiegeWeaponControlWindow.OnUpdateState" )
    WindowRegisterEventHandler( "SiegeWeaponControlWindow", SystemData.Events.SIEGE_WEAPON_REUSE_TIMER_UPDATED, "SiegeWeaponControlWindow.OnUpdateReuseTimer" )    
    WindowRegisterEventHandler( "SiegeWeaponControlWindow", SystemData.Events.SIEGE_WEAPON_USERS_UPDATED, "SiegeWeaponControlWindow.UpdateUsers" )
    WindowRegisterEventHandler( "SiegeWeaponControlWindow", SystemData.Events.SIEGE_WEAPON_FIRE_RESULTS, "SiegeWeaponControlWindow.OnSiegeWeaponFireResults" )
    
    WindowSetGameActionData( "SiegeWeaponControlWindowAimButton", GameData.PlayerActions.FIRE_SIEGE_WEAPON, 0, L"");
    
    -- Initialize the User Buttons
    for index = 1, SiegeWeaponControlWindow.MAX_USERS_DISPLAYED
    do
        ButtonSetStayDownFlag( "SiegeWeaponUsersWindowUser"..index, true )    
    end
       
    SiegeWeaponControlWindow.ShowUsersNames( false )
    
    SiegeWeaponControlWindow.UpdateData()
    
end


function SiegeWeaponControlWindow.UpdateData()

    SiegeWeaponControlWindow.controlData = GetSiegeWeaponControlData()
    
    local weaponName = SiegeWeaponControlWindow.controlData.weaponDef.name 
    if( weaponName == L"" ) then
        weaponName = L"NONE"
    end
    
    -- Set the Weapon Name                
    local text = GetStringFormatFromTable("SiegeStrings", StringTables.Siege.LABEL_WEAPON_NAME, { weaponName } )
    LabelSetText( "SiegeWeaponInfoWindowName", text )

    local showWindow = SiegeWeaponControlWindow.controlData.weaponDef.name ~= L""    
    WindowSetShowing( "SiegeWeaponInfoWindow", showWindow )    
    WindowSetShowing( "SiegeWeaponControlWindow",  showWindow )
    WindowSetShowing( "SiegeWeaponUsersWindow", showWindow )
    
       
    -- Update Everything....
    SiegeWeaponControlWindow.UpdateState() 
    SiegeWeaponControlWindow.UpdateStateText()    
    SiegeWeaponControlWindow.UpdateHealth()
    SiegeWeaponControlWindow.UpdateReuseTimer()  
    SiegeWeaponControlWindow.UpdateAimButton()        
    SiegeWeaponControlWindow.UpdateRepairButton()
    SiegeWeaponControlWindow.UpdateUsers()
end

function SiegeWeaponControlWindow.OnUpdateHealth()

    local lastHealthPercent = SiegeWeaponControlWindow.lastHealthPercent
    SiegeWeaponControlWindow.UpdateHealth()
    
    -- If we are going from <100% health to 100% health, then update the repair button
    if( ( lastHealthPercent ~= GameData.SiegeWeapon.healthPercent )
        and ( lastHealthPercent == 100 or  GameData.SiegeWeapon.healthPercent == 100 ) ) then
            SiegeWeaponControlWindow.UpdateRepairButton()
    end

end

function SiegeWeaponControlWindow.UpdateHealth()

    StatusBarSetCurrentValue( "SiegeWeaponInfoWindowHealthPercentBar", GameData.SiegeWeapon.healthPercent )       
    
    SiegeWeaponControlWindow.lastHealthPercent = GameData.SiegeWeapon.healthPercent
end

function SiegeWeaponControlWindow.OnUpdateState()
    SiegeWeaponControlWindow.UpdateState()
    SiegeWeaponControlWindow.UpdateStateText()
    SiegeWeaponControlWindow.UpdateAimButton()        
    SiegeWeaponControlWindow.UpdateRepairButton()
    SiegeWeaponControlWindow.UpdateUsers()
end

function SiegeWeaponControlWindow.UpdateState()

    -- Enable/Disable Buttons Based on State.
    ButtonSetStayDownFlag("SiegeWeaponControlWindowRepairButton", GameData.SiegeWeapon.currentState == GameData.SiegeObjectState.REPAIRING )
    ButtonSetPressedFlag("SiegeWeaponControlWindowRepairButton", GameData.SiegeWeapon.currentState == GameData.SiegeObjectState.REPAIRING )
    
    -- Only Show the Control Timer when the weapon is avaliable for use    
    local show = ( GameData.SiegeWeapon.currentState == GameData.SiegeObjectState.READY or GameData.SiegeWeapon.currentState == GameData.SiegeObjectState.IN_USE )           
                        and GameData.SiegeWeapon.isPlayerController                                        
    WindowSetShowing( "SiegeWeaponInfoWindowControlTimer", show )
    
end


function SiegeWeaponControlWindow.UpdateUsers()

    SiegeWeaponControlWindow.currentUsers = GetSiegeWeaponUsersData()

    -- Set the num players text    
    local numUsers = # SiegeWeaponControlWindow.currentUsers
    local maxUsers = 0
    
    local playersText = L""
    if( GameData.SiegeWeapon.currentState == GameData.SiegeObjectState.BUILDING or
        GameData.SiegeWeapon.currentState == GameData.SiegeObjectState.REPAIRING  )
    then
        maxUsers = SiegeWeaponControlWindow.controlData.weaponDef.maxBuilders
         
    elseif( GameData.SiegeWeapon.currentState == GameData.SiegeObjectState.IN_USE or
            GameData.SiegeWeapon.currentState == GameData.SiegeObjectState.READY ) 
    then 
        maxUsers = SiegeWeaponControlWindow.controlData.weaponDef.maxUsers 
    end
    
    
    for index = 1, SiegeWeaponControlWindow.MAX_USERS_DISPLAYED
    do
        local show = index <= maxUsers
        local active = index <= numUsers
        
        -- Update the Icons
        ButtonSetPressedFlag( "SiegeWeaponUsersWindowUser"..index, active )
        ButtonSetDisabledFlag( "SiegeWeaponUsersWindowUser"..index, not active )    
        WindowSetShowing( "SiegeWeaponUsersWindowUser"..index, show )
        
        
        -- Update the Names   
        local nameWindowName = "SiegeWeaponUsersWindowNamesUser"..index    
        WindowSetShowing( nameWindowName, active ) 
        WindowSetShowing( nameWindowName.."HorizConnector", active )   
        WindowSetShowing( nameWindowName.."VertConnector", active )   
        
        if( active )
        then
            local userData = SiegeWeaponControlWindow.currentUsers[index]
    
            local text  = GetFormatStringFromTable( "SiegeStrings", StringTables.Siege.LABEL_SIEGE_USER_AND_RANK, { userData.name, L""..userData.level } )
            LabelSetText( nameWindowName.."Text" , text )
        end
    end
    
    WindowSetShowing("SiegeWeaponUsersWindow", maxUsers > 1 )
    
    
    local params = { L""..numUsers, L""..maxUsers }
    playersText = GetStringFormatFromTable( "SiegeStrings", StringTables.Siege.LABEL_X_OF_Y_PLAYERS, params )
    --LabelSetText( "SiegeWeaponControlWindowNumPlayersText", playersText )    
   
end

function SiegeWeaponControlWindow.OnMouseOverSiegeWeaponUser()
    
    local index = WindowGetId( SystemData.ActiveWindow.name )
    local userData = SiegeWeaponControlWindow.currentUsers[index]

    if( userData == nil ) 
    then
        return
    end
    
    local heading   = GetFormatStringFromTable( "SiegeStrings", StringTables.Siege.LABEL_SIEGE_USER_NAME, { userData.name } )
    local desc      = GetFormatStringFromTable( "SiegeStrings", StringTables.Siege.LABEL_SIEGE_USER_RANK, { userData.level } )

    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, heading )
    Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
    Tooltips.SetTooltipText( 2, 1, desc )
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_BOTTOM  )
end

function SiegeWeaponControlWindow.ShowUsersNames( show )
    WindowSetShowing("SiegeWeaponUsersWindowNames", show )
end

function SiegeWeaponControlWindow.UpdateStateText()

    -- Set the State Text
    local stateText = L""
    
    -- If the reuse timer is set, we're reloading.. 
    if( GameData.SiegeWeapon.currentReuseTimer > 0 ) then
        stateText = GetStringFromTable( "SiegeStrings", StringTables.Siege.LABEL_RELOADING )
    else    
        -- Otherwise get the regualar state text
        if( GameDefs.SiegeObjectStateNames[GameData.SiegeWeapon.currentState]) then
            stateText = GameDefs.SiegeObjectStateNames[GameData.SiegeWeapon.currentState]
        end
    end
    
    LabelSetText( "SiegeWeaponStatusWindowText", stateText )
    
    
    -- When Building and Repairing, Show the large center screen text.
    if( GameData.SiegeWeapon.currentState == GameData.SiegeObjectState.BUILDING or
        GameData.SiegeWeapon.currentState == GameData.SiegeObjectState.REPAIRING
       )
    then
       LabelSetText( "SiegeWeaponInfoWindowStateText", stateText )
    else
        LabelSetText( "SiegeWeaponInfoWindowStateText", L"" )
    end  
   
end

function SiegeWeaponControlWindow.OnUpdateReuseTimer()

    SiegeWeaponControlWindow.UpdateReuseTimer()
    SiegeWeaponControlWindow.UpdateAimButton()
    SiegeWeaponControlWindow.UpdateStateText()
end

function SiegeWeaponControlWindow.UpdateReuseTimer()
    --DEBUG(L"SiegeWeaponControlWindow.UpdateReuseTimer() cur="..GameData.SiegeWeapon.currentReuseTimer..L" max="..GameData.SiegeWeapon.maximumReuseTimer )

    -- If the MaxTimer is 0, set it to 1 to show a filled bar
    local maxTimer = GameData.SiegeWeapon.maximumReuseTimer
    if( maxTimer == 0 ) then
        maxTimer = 1
    end       

    StatusBarSetMaximumValue( "SiegeWeaponStatusWindowTimerBar", maxTimer )   
       
    -- The bar will fill from left to right.
    StatusBarSetCurrentValue( "SiegeWeaponStatusWindowTimerBar",  GameData.SiegeWeapon.maximumReuseTimer - GameData.SiegeWeapon.currentReuseTimer )      
    
    local showWindow = GameData.SiegeWeapon.currentReuseTimer > 0
    WindowSetShowing( "SiegeWeaponStatusWindow", showWindow )        
    
    if( showWindow == false ) 
    then
        SiegeWeaponControlWindow.ResetResults()
    end
end

function SiegeWeaponControlWindow.UpdateStatusWindow( timePassed )

    if( GameData.SiegeWeapon.currentReuseTimer > 0 ) then
        GameData.SiegeWeapon.currentReuseTimer = GameData.SiegeWeapon.currentReuseTimer - timePassed
        if( GameData.SiegeWeapon.currentReuseTimer < 0 ) then
            -- Update the full timer state
            GameData.SiegeWeapon.currentReuseTimer = 0
            SiegeWeaponControlWindow.UpdateReuseTimer()        
        else        
            -- Just set the Bar
            StatusBarSetCurrentValue( "SiegeWeaponStatusWindowTimerBar", GameData.SiegeWeapon.maximumReuseTimer - GameData.SiegeWeapon.currentReuseTimer )      
        end        
    end
end



function SiegeWeaponControlWindow.UpdateInfoWindow( timePassed )

    if( GameData.SiegeWeapon.controlTimeRemaining > 0 ) then
        GameData.SiegeWeapon.controlTimeRemaining = GameData.SiegeWeapon.controlTimeRemaining - timePassed
        
        if( GameData.SiegeWeapon.controlTimeRemaining < 0 ) then
            GameData.SiegeWeapon.controlTimeRemaining = 0    
        end
                                
        local time = TimeUtils.FormatClock( GameData.SiegeWeapon.controlTimeRemaining )    
        LabelSetText( "SiegeWeaponInfoWindowControlTimerText", time )                     
    end
end


function SiegeWeaponControlWindow.UpdateAimButton()

    local enabled = GameData.SiegeWeapon.currentReuseTimer == 0 
                 and ( GameData.SiegeWeapon.currentState == GameData.SiegeObjectState.READY or GameData.SiegeWeapon.currentState == GameData.SiegeObjectState.IN_USE )           
                 and GameData.SiegeWeapon.isPlayerController                  
    
    -- Update the Button State    
    ButtonSetDisabledFlag( "SiegeWeaponControlWindowAimButton", not enabled )
    
    WindowSetShowing( "SiegeWeaponControlWindowAimButtonIcon", enabled  )
    WindowSetShowing( "SiegeWeaponControlWindowAimButtonDisabledIcon", not enabled )     
end

function SiegeWeaponControlWindow.UpdateRepairButton()

    local enabled = ( GameData.SiegeWeapon.healthPercent < 100 )
                and ( GameData.SiegeWeapon.currentState == GameData.SiegeObjectState.READY 
                    or GameData.SiegeWeapon.currentState == GameData.SiegeObjectState.IN_USE
                    or GameData.SiegeWeapon.currentState == GameData.SiegeObjectState.REPAIRING )
                and GameData.SiegeWeapon.isPlayerController    
    
 
    -- Update the Button State    
    ButtonSetDisabledFlag( "SiegeWeaponControlWindowRepairButton", not enabled )
    
    WindowSetShowing( "SiegeWeaponControlWindowRepairButtonIcon", enabled  )
    WindowSetShowing( "SiegeWeaponControlWindowRepairButtonDisabledIcon", not enabled )     
end

function SiegeWeaponControlWindow.OnSiegeWeaponFireResults( overallEffectivness, randomResult, minClientEffectivness, playerEffectivnessValues )
    
    --DEBUG(L"  SiegeWeaponControlWindow.OnSiegeWeaponFireResults: overall="..overallEffectivness..L" random="..randomResult )

    if( SiegeWeaponControlWindow.currentUsers == nil ) 
    then
        return
    end

    local numUsers = # SiegeWeaponControlWindow.currentUsers
    local maxUsers = SiegeWeaponControlWindow.controlData.weaponDef.maxUsers 
  
    -- If we have more than one user, color the User Icons according to their effectivness results.
    if( maxUsers > 1 ) 
    then
    
        for index = 1, SiegeWeaponControlWindow.MAX_USERS_DISPLAYED
        do
            if( index <= numUsers )
            then
            
                -- Color the Icons Red when they've not not exceeded the minimum effectivness.
                local color = DefaultColor.RED
                if( playerEffectivnessValues[index] ~= nil )
                then
                    if( playerEffectivnessValues[index] > minClientEffectivness )
                    then
                        color = DefaultColor.YELLOW
                    end
                end         
                
                --DEBUG(L" Player["..index..L"] = "..playerEffectivnessValues[index] )     
                
                DefaultColor.SetWindowTint( "SiegeWeaponUsersWindowUser"..index, color )    
                
                -- Set the Result Text
                local text = GetStringFormatFromTable("SiegeStrings", StringTables.Siege.TEXT_SIEGE_RESULT_USER_PERCENT, { L""..playerEffectivnessValues[index] } ) 
                LabelSetText( "SiegeWeaponUsersWindowUser"..index.."ResultText", text )
                DefaultColor.SetLabelColor( "SiegeWeaponUsersWindowUser"..index.."ResultText", color )   
                WindowSetShowing( "SiegeWeaponUsersWindowUser"..index.."ResultText", true )
            end
           
        end
    
    end 
end

function SiegeWeaponControlWindow.ResetResults()

    if( SiegeWeaponControlWindow.currentUsers == nil ) 
    then
        return
    end

    local numUsers = # SiegeWeaponControlWindow.currentUsers
    for index = 1, SiegeWeaponControlWindow.MAX_USERS_DISPLAYED
    do
        if( index <= numUsers )
        then
        
            DefaultColor.SetWindowTint( "SiegeWeaponUsersWindowUser"..index, DefaultColor.ZERO_TINT )    
            WindowSetShowing( "SiegeWeaponUsersWindowUser"..index.."ResultText", false )
        end
    end
        
end


-- Tooltips 
function SiegeWeaponControlWindow.OnMouseOverHealthPercent()

    local heading   = GetStringFromTable( "SiegeStrings", StringTables.Siege.LABEL_SIEGE_HEALTH_BAR )
    local desc      = GetStringFromTable( "SiegeStrings", StringTables.Siege.TEXT_SIEGE_HEALTH_BAR )

    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, heading )
    Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
    Tooltips.SetTooltipText( 2, 1, desc )
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( SiegeWeaponControlWindow.TOOLTIP_ANCHOR )
        
end


function SiegeWeaponControlWindow.OnMouseOverReuseTimer()

    local heading   = GetStringFromTable( "SiegeStrings", StringTables.Siege.LABEL_SIEGE_RELOAD_BAR )
    local desc      = GetStringFromTable( "SiegeStrings", StringTables.Siege.TEXT_SIEGE_RELOAD_BAR )

    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, heading )
    Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
    Tooltips.SetTooltipText( 2, 1, desc )
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( SiegeWeaponControlWindow.TOOLTIP_ANCHOR )
        
end

function SiegeWeaponControlWindow.OnMouseOverName()
    local abilityData = SiegeWeaponControlWindow.controlData.weaponDef.fireAbility
    Tooltips.CreateAbilityTooltip( abilityData, SystemData.ActiveWindow.name, SiegeWeaponControlWindow.TOOLTIP_ANCHOR )
end

-- Button Callbacks
function SiegeWeaponControlWindow.OnMouseOverAimButton()

    local fireMode = GameData.SiegeWeapon.fireMode

    local text = L""
    if( fireMode == GameData.SiegeFireMode.PLAYER_TARGET ) 
    then    
        text = GetStringFromTable( "SiegeStrings", StringTables.Siege.LABEL_FIREMODE_PLAYERTARGET )
        
    elseif( fireMode == GameData.SiegeFireMode.SNIPER ) 
    then
        text = GetStringFromTable( "SiegeStrings", StringTables.Siege.LABEL_FIREMODE_SNIPER )
        
    elseif( fireMode == GameData.SiegeFireMode.SCORCH ) 
    then
         text = GetStringFromTable( "SiegeStrings", StringTables.Siege.LABEL_FIREMODE_SCORCH )
    
    elseif( fireMode == GameData.SiegeFireMode.DROP )    
    then
        local abilityName = SiegeWeaponControlWindow.controlData.weaponDef.fireAbility.name 
        text = GetStringFormatFromTable( "SiegeStrings", StringTables.Siege.LABEL_FIREMODE_DROP, { abilityName }  )    
    
    elseif( fireMode == GameData.SiegeFireMode.GOLF )    
    then
        text = GetStringFromTable( "SiegeStrings", StringTables.Siege.LABEL_FIREMODE_GOLF  )    
    end   
   

    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, text )
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_BOTTOM )
end

function SiegeWeaponControlWindow.OnMouseOverRepairButton()
    local text = GetStringFromTable( "SiegeStrings", StringTables.Siege.LABEL_REPAIR_WEAPON )
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, text )    
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_BOTTOM )
end

function SiegeWeaponControlWindow.RepairWeapon()
    if( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) ) then
        return
    end
    
    RepairSiegeWeapon()
end


function SiegeWeaponControlWindow.OnMouseOverReleaseButton()

    local text = GetStringFromTable( "SiegeStrings", StringTables.Siege.LABEL_RELEASE_WEAPON )
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, text )
    
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_BOTTOM )
end


function SiegeWeaponControlWindow.ReleaseWeapon()
    -- The release message is broadast on the OnHidden() callback so it gets triggered with the Escape key as well.
    WindowSetShowing( "SiegeWeaponControlWindow", false )
end

function SiegeWeaponControlWindow.OnMouseOverControlTimer()

    local heading   = GetStringFromTable( "SiegeStrings", StringTables.Siege.TOOLTIP_FIRE_TIMER_TITLE )
    local desc      = GetStringFromTable( "SiegeStrings", StringTables.Siege.TOOLTIP_FIRE_TIMER_DESC )

    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, heading )
    Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
    Tooltips.SetTooltipText( 2, 1, desc )
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_RIGHT )
    
end

function SiegeWeaponControlWindow.IsShowing()
    return WindowGetShowing( "SiegeWeaponControlWindow" )
end


function SiegeWeaponControlWindow.OnShown()
    WindowUtils.OnShown()
end

function SiegeWeaponControlWindow.OnHidden()
    WindowUtils.OnHidden()
    BroadcastEvent( SystemData.Events.SIEGE_WEAPON_RELEASE ) 
end

function SiegeWeaponControlWindow.MoveInfoToBottomOfScreen( bottom )

    WindowClearAnchors( "SiegeWeaponInfoWindow")
    WindowClearAnchors( "SiegeWeaponUsersWindow")
    
    if( bottom ) then   
        WindowAddAnchor("SiegeWeaponInfoWindow", "bottom", "Root", "bottom", 0, -15 )
        WindowAddAnchor("SiegeWeaponUsersWindow", "center", "Root", "top", 0, 275 )
    else     
        WindowAddAnchor("SiegeWeaponInfoWindow", "center", "Root", "top", 0, 150 )
        WindowAddAnchor("SiegeWeaponUsersWindow", "bottom", "SiegeWeaponControlWindow", "top", 0, 0 )
    end
end

