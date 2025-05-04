----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

MainMenuWindow = {}


----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------
local ICON_LOG_OUT			    = 254
local ICON_EXIT				    = 2524
local ICON_SETTINGS			    = 211
local ICON_KEYS				    = 213
local ICON_MACROS			    = 248
local ICON_UPGRADE_NOW		    = 23067
local ICON_ACCOUNT_ENTITLEMENTS = 206

MainMenuWindow.numButtons = 0

local trialWindowDims = {x=350, y=484}
local windowDims = {x=350, y=429}


----------------------------------------------------------------
-- MainMenuWindow Functions
----------------------------------------------------------------
local function SetMenuItemBase( windowNameBase, text )
    ButtonSetText( windowNameBase.."Text", text )

    MainMenuWindow.numButtons = MainMenuWindow.numButtons + 1
    
    -- Use the Alternating Row Colors for the BG
    DefaultColor.SetWindowTint( windowNameBase.."Background", DefaultColor.GetRowColor( MainMenuWindow.numButtons ) )
end

local function SetMenuItem( windowNameBase, iconNum, text ) 
    local texture, x, y = GetIconData( iconNum )
    DynamicImageSetTexture( windowNameBase.."Icon", texture, x, y )
    SetMenuItemBase( windowNameBase, text )
end

local function SetMenuItemWithSlice( windowNameBase, slice, textureName, textDimX, texDimY,  text ) 
    DynamicImageSetTexture( windowNameBase.."Icon", textureName, 64, 64 )
    DynamicImageSetTextureDimensions( windowNameBase.."Icon", textDimX, texDimY )
    DynamicImageSetTextureSlice( windowNameBase.."Icon", slice )
    SetMenuItemBase( windowNameBase, text )
end

-- OnInitialize Handler
function MainMenuWindow.Initialize()
    
    WindowSetAlpha( "MainMenuWindow", 0.75 )
    
    MainMenuWindow.numButtons = 0
    WindowRegisterEventHandler( "MainMenuWindow", SystemData.Events.TOGGLE_MENU, "MainMenuWindow.ToggleMenu")

    -- Label & Button Titles
    LabelSetText("MainMenuWindowTitleBarText", GetString( StringTables.Default.LABEL_MENU ))
    
    SetMenuItem( "MainMenuWindowLogOutItem", ICON_LOG_OUT, GetString( StringTables.Default.LABEL_LOG_OUT ) ) 
    SetMenuItem( "MainMenuWindowExitGameItem", ICON_EXIT, GetString( StringTables.Default.LABEL_EXIT_GAME ) ) 
    SetMenuItem( "MainMenuWindowUserSettingsItem", ICON_SETTINGS, GetString( StringTables.Default.LABEL_USER_SETTINGS ) ) 
    SetMenuItem( "MainMenuWindowKeyMappingItem", ICON_KEYS, GetString( StringTables.Default.LABEL_KEY_MAPPING ) )
    SetMenuItem( "MainMenuWindowCustomizeInterfaceItem", ICON_SETTINGS, GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_CUSTOMIZE_UI ) )  
    SetMenuItem( "MainMenuWindowMacrosItem", ICON_MACROS, GetString( StringTables.Default.LABEL_MACROS ) )   
    SetMenuItem( "MainMenuWindowAccountEntitlementsItem", ICON_ACCOUNT_ENTITLEMENTS, GetString( StringTables.Default.LABEL_ACCOUNT_ENTITLEMENTS_TITLE ) ) 

    WindowSetAlpha( "MainMenuWindow", 0.75 )
    
    local trialUser, _ = GetAccountData()
    if( trialUser )
    then
        SetMenuItemWithSlice( "MainMenuWindowUpgradeNowItem", "MainMenu-Button-Selected", "EA_Texture_Menu01", 73, 71, GetString( StringTables.Default.LABEL_MAIN_MENU_UPGRADE_NOW ) ) 
        WindowSetDimensions( "MainMenuWindow", trialWindowDims.x, trialWindowDims.y )
    else
        WindowSetDimensions( "MainMenuWindow",  windowDims.x, windowDims.y )
    end
    
    WindowSetShowing( "MainMenuWindowUpgradeNowItem", trialUser )
end

-- OnShutdown Handler
function MainMenuWindow.Shutdown()
end

function MainMenuWindow.OnLogOut()	
    -- Broadcast the event
    BroadcastEvent( SystemData.Events.LOG_OUT )
    MainMenuWindow.Hide()
end

function MainMenuWindow.OnExitGame()	
    -- Broadcast the event
    BroadcastEvent( SystemData.Events.EXIT_GAME )
    MainMenuWindow.Hide()
end

function MainMenuWindow.OnOpenUserSettings()	
    WindowUtils.ToggleShowing( "SettingsWindowTabbed" )
    MainMenuWindow.Hide()
end

function MainMenuWindow.OnOpenKeyMapping()	
    WindowUtils.ToggleShowing( "KeyMappingWindow" )
    MainMenuWindow.Hide()
end

function MainMenuWindow.OnOpenCustomizeInterfaceWindow()
    WindowUtils.ToggleShowing( "SettingsWindowTabbed" )
    SettingsWindowTabbed.SelectTab(SettingsWindowTabbed.TABS_INTERFACE)

    MainMenuWindow.Hide()
end

function MainMenuWindow.OnOpenMacros()	
    WindowUtils.ToggleShowing( "EA_Window_Macro"  )
end

function MainMenuWindow.Hide()	
    --BroadcastEvent( SystemData.Events.TOGGLE_MENU_WINDOW )
    WindowSetShowing( "MainMenuWindow", false )
end

function MainMenuWindow.ToggleShowing()
    WindowUtils.ToggleShowing( "MainMenuWindow" )
end

function MainMenuWindow.ToggleSettingsWindow()	
    WindowUtils.ToggleShowing( "SettingsWindowTabbed" )
end

function MainMenuWindow.ToggleKeyMappingWindow()	
    WindowUtils.ToggleShowing( "KeyMappingWindow"  )	
end

function MainMenuWindow.ToggleMacroWindow()	
    WindowUtils.ToggleShowing( "EA_Window_Macro" )	
end

function MainMenuWindow.OnUpgradeNow()
    EA_TrialAlertWindow.OnUpgrade()
end

function MainMenuWindow.OnAccountEntitlements()
    BroadcastEvent( SystemData.Events.CLAIM_REWARDS )
    MainMenuWindow.Hide()
end

function MainMenuWindow.OnMouseOver()

    if( (SystemData.ActiveWindow.name) == "MainMenuWindowLogOutItem" )
    then
        local text = GetString( StringTables.Default.TOOLTIP_MAIN_MENU_LOG_OUT )
        Tooltips.CreateTextOnlyTooltip( "MainMenuWindowLogOutItem", text )
    elseif( (SystemData.ActiveWindow.name) == "MainMenuWindowExitGameItem" )
    then
        local text = GetString( StringTables.Default.TOOLTIP_MAIN_MENU_EXIT )
        Tooltips.CreateTextOnlyTooltip( "MainMenuWindowExitGameItem", text )
    elseif( (SystemData.ActiveWindow.name) == "MainMenuWindowUserSettingsItem" )
    then
        local text = GetString( StringTables.Default.TOOLTIP_MAIN_USER_SETTINGS )
        Tooltips.CreateTextOnlyTooltip( "MainMenuWindowUserSettingsItem", text )
    elseif( (SystemData.ActiveWindow.name) == "MainMenuWindowKeyMappingItem" )
    then
        local text = GetString( StringTables.Default.TOOLTIP_MAIN_KEY_MAPPING )
        Tooltips.CreateTextOnlyTooltip( "MainMenuWindowKeyMappingItem", text )
    elseif( (SystemData.ActiveWindow.name) == "MainMenuWindowMacrosItem" )
    then
        local text = GetString( StringTables.Default.TOOLTIP_MAIN_MACROS )
        Tooltips.CreateTextOnlyTooltip( "MainMenuWindowMacrosItem", text )
    elseif( (SystemData.ActiveWindow.name) == "MainMenuWindowCustomizeInterfaceItem" )
    then
        local text = GetString( StringTables.Default.TOOLTIP_MAIN_MENU_CUSTOMIZE_INTERFACE )
        Tooltips.CreateTextOnlyTooltip( "MainMenuWindowCustomizeInterfaceItem", text )
    elseif( (SystemData.ActiveWindow.name) == "MainMenuWindowAccountEntitlementsItem" )
    then
        local text = GetString( StringTables.Default.TOOLTIP_MAIN_MENU_ACCOUNT_ENTITLEMENTS )
        Tooltips.CreateTextOnlyTooltip( "MainMenuWindowAccountEntitlementsItem", text )
    elseif( (SystemData.ActiveWindow.name) == "MainMenuWindowUpgradeNowItem" )
    then
        local text = GetString( StringTables.Default.TOOLTIP_MAIN_MENU_UPGRADE_NOW )
        Tooltips.CreateTextOnlyTooltip( "MainMenuWindowUpgradeNowItem", text )
    end
    
    local windowName	= SystemData.ActiveWindow.name
    local anchor = { Point="top", RelativeTo="MainMenuWindow", RelativePoint="center", XOffset=0, YOffset=-32 }
    Tooltips.AnchorTooltip (anchor)

end

function MainMenuWindow.MouseOverSlot( slot )
    --DEBUG(L"Slot name is "..SystemData.ActiveWindow.name)
end
