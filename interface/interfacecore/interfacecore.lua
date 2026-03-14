
----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

InterfaceCore = {}
InterfaceCore.inGame = false
InterfaceCore.artResolution = { x=1600, y=1200 }

InterfaceCore.CoreLanguageDirectories = 
{
    [SystemData.Settings.Language.ENGLISH ] = "english",
    [SystemData.Settings.Language.FRENCH  ] = "french",
    [SystemData.Settings.Language.GERMAN  ] = "german",
    [SystemData.Settings.Language.ITALIAN ] = "italian",
    [SystemData.Settings.Language.SPANISH ] = "spanish",
    [SystemData.Settings.Language.KOREAN ] = "korean",
    [SystemData.Settings.Language.S_CHINESE ] = "s_chinese",
    [SystemData.Settings.Language.T_CHINESE ] = "t_chinese",
    [SystemData.Settings.Language.JAPANESE ] = "japanese",
    [SystemData.Settings.Language.RUSSIAN ] = "russian",
};

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

local scale = 1.0
local preGameResourcesLoaded = false
local inGameResourcesLoaded = false

local FontLanguageDirectories = 
{
    [SystemData.Settings.Language.ENGLISH ] = "english",
    [SystemData.Settings.Language.FRENCH  ] = "english",
    [SystemData.Settings.Language.GERMAN  ] = "english",
    [SystemData.Settings.Language.ITALIAN ] = "english",
    [SystemData.Settings.Language.SPANISH ] = "english",
    [SystemData.Settings.Language.KOREAN ] = "korean",
    [SystemData.Settings.Language.S_CHINESE ] = "s_chinese",
    [SystemData.Settings.Language.T_CHINESE ] = "t_chinese",
    [SystemData.Settings.Language.JAPANESE ] = "japanese",
    [SystemData.Settings.Language.RUSSIAN ] = "russian",
};

----------------------------------------------------------------
-- Interface Core Functions
----------------------------------------------------------------

function InterfaceCore.Initialize()
    
    InterfaceCore.inGame = false    
    
    -- Load the Core String Tables
    LoadStringTable("Pregame",            "data/strings/<LANG>",           "pregame.txt",             "cache/<LANG>", "StringTables.Pregame" )
    LoadStringTable("ServerLocation",     "data/strings/<LANG>/interface", "serverlocation.txt",      "cache/<LANG>", "StringTables.ServerLocation" )
    LoadStringTable("ServerLanguage",     "data/strings/<LANG>/interface", "serverlanguages.txt",      "cache/<LANG>", "StringTables.ServerLanguage" )
    LoadStringTable("AuthorizationError", "data/strings/<LANG>",           "authorizationerrors.txt", "cache/<LANG>", "" )
    LoadStringTable("Hardcoded",          "data/strings/<LANG>",           "hardcoded.txt",           "cache/<LANG>", "" )

    -- Load the language specific fonts
    local fontDirectory  = FontLanguageDirectories[SystemData.Settings.Language.active]
    LoadResources( "interface/interfacecore/fonts", fontDirectory.."/fonts.xml", IsInternalBuild() )
    LoadResources( "interface/interfacecore/fonts", fontDirectory.."/corefonts.xml", IsInternalBuild() )
   
    -- Register the Window Sets (see WarApplication.h)  Yes, these need to be the same (but it'd be dangerous to
    --   expose them and risk an end user modifying the 'constant'
    --     WINDOW_SET_TITLE,
    --     WINDOW_SET_SERVER_SELECT,
    --     WINDOW_SET_LOGIN,
    --     WINDOW_SET_QUICK_START,
    --     WINDOW_SET_CHARACTER_SELECT,
    --     WINDOW_SET_LOADING,
    --     WINDOW_SET_PLAY  

    RegisterWindowSet(0, "InterfaceCore.CreateTitleInterface", "InterfaceCore.ShutdownTitleInterface" )
    RegisterWindowSet(1, "InterfaceCore.CreateServerSelectionInterface", "InterfaceCore.ShutdownServerSelectionInterface" )   
    RegisterWindowSet(2, "InterfaceCore.CreateLoginInterface", "InterfaceCore.ShutdownLoginInterface" )
    RegisterWindowSet(3, "InterfaceCore.CreateQuickStartInterface", "InterfaceCore.ShutdownQuickStartInterface" )
    RegisterWindowSet(4, "InterfaceCore.CreateCharacterSelectionInterface", "InterfaceCore.ShutdownCharacterSelectionInterface" )    
    RegisterWindowSet(5, "InterfaceCore.CreateLoadingInterface", "InterfaceCore.ShutdownLoadingInterface" )
    RegisterWindowSet(6, "InterfaceCore.CreatePlayInterface", "InterfaceCore.ShutdownPlayInterface" ) 

    -- Callbacks
    RegisterEventHandler( SystemData.Events.RESOLUTION_CHANGED, "InterfaceCore.OnResolutionChanged")  
    RegisterEventHandler( SystemData.Events.CUSTOM_UI_SCALE_CHANGED, "InterfaceCore.OnResolutionChanged")
    RegisterEventHandler( SystemData.Events.LANGUAGE_TOGGLED, "InterfaceCore.OnLanguageChanged")
    
    -- Set the font for the names and titles
    SetNamesAndTitlesFont( "font_name_plate_names_old", "font_name_plate_titles_old" )
    
    -- Load the Core Templates & Utils
    LoadResources( "Interface/InterfaceCore", "InterfaceCorePreload.xml", IsInternalBuild() )
end


function InterfaceCore.Update( timePassed )
end

function InterfaceCore.Shutdown()
        
    UnloadStringTable( "Hardcoded" )
    UnloadStringTable( "AuthorizationError" )
    UnloadStringTable( "ServerLocation" )
    UnloadStringTable( "ServerLanguage" )
    UnloadStringTable( "Pregame" )    
    
    -- Callbacks
    UnregisterEventHandler( SystemData.Events.RESOLUTION_CHANGED, "InterfaceCore.OnResolutionChanged")  
    UnregisterEventHandler( SystemData.Events.CUSTOM_UI_SCALE_CHANGED, "InterfaceCore.OnResolutionChanged")
    UnregisterEventHandler( SystemData.Events.LANGUAGE_TOGGLED, "InterfaceCore.OnLanguageChanged")

end

----------------------------------------------------------------
-- Window Set Callbacks
----------------------------------------------------------------

local function LoadPregameMods()

    local PREGAME_MODS =
    {
        L"Interface/Default/EA_UiDebugTools/EA_UiDebugTools.mod",                                       -- Needs to be loaded first for ERROR() and DEBUG()
        L"Interface/Default/EATemplate_DefaultWindowSkin/EATemplate_DefaultWindowSkin.mod", 
        L"Interface/Default/EATemplate_ParchmentWindowSkin/EATemplate_ParchmentWindowSkin.mod", 
        L"Interface/Default/EATemplate_Icons/EATemplate_Icons.mod", 
        L"Interface/Default/EASystem_Strings/EASystem_Strings.mod", 
        L"Interface/Default/EASystem_DialogManager/EASystem_DialogManager.mod",
        L"Interface/Default/EASystem_Utils/EA_Utils.mod",
        L"Interface/Default/EASystem_WindowUtils/EA_WindowUtils.mod",
        L"Interface/Default/EASystem_TargetInfo/EASystem_TargetInfo.mod",
        L"Interface/Default/EASystem_ResourceFrames/EASystem_ResourceFrames.mod",
        L"Interface/Default/EASystem_Tooltips/TooltipSystem.mod",
        L"Interface/Default/EA_UiModWindow/EA_UiModWindow.mod",
        L"Interface/Default/EA_SettingsWindow/EA_SettingsWindow.mod",
        L"Interface/Default/EA_CustomizePerformanceWindow/EA_CustomizePerformanceWindow.mod",
        L"Interface/Default/EA_LegacyTemplates/EA_LegacyTemplates.mod",
        L"Interface/Default/EA_LCDKeyboard/EA_LCDKeyboard.mod",
        L"Interface/Default/EA_TrialAlertWindow/EA_TrialAlertWindow.mod",
        L"Interface/Default/EA_UiProfilesWindow/EA_UiProfilesWindow.mod",
    }
    
    for _, modFilePath in ipairs( PREGAME_MODS )
    do
        ModuleLoad( modFilePath, SystemData.UiModuleType.PREGAME, IsInternalBuild() ) 
    end           
        
    ModulesInitializeAllEnabled()  
    
end

local function LoadPregameData()

    if( preGameResourcesLoaded )
    then
        return
    end          
        
    -- Load the Default UI Modules that the pregame uses.
    -- For public builds, these files will only be loaded from the MYP archive.
    LoadPregameMods()
    
    -- Load the Pregame Window Definitions
    LoadResources( "Interface/InterfaceCore", "InterfaceCore.xml", IsInternalBuild() )
            
    preGameResourcesLoaded = true

end

local function LoadModData()

    -- Load the Mod Definitions.
    if( SystemData.Settings.UseCustomUI )
    then   
        ModulesLoadFromDirectory( SystemData.Directories.CustomInterface, SystemData.UiModuleType.CUSTOM_INGAME  )        

         -- Ensure atleast one .mod file was found
        local modsData = ModulesGetData()    
        if( modsData[1] == nil ) 
        then     
            return false
        end        
        
        if( IsInternalBuild() )
        then
            ModulesLoadFromDirectory( L"interface/MythicApprovedAddOns", SystemData.UiModuleType.MYTHIC_APPROVED_ADDON  )   
        end        
    else
        ModulesLoadFromListFile( SystemData.Directories.DefaultInterface..L"/EADefaultMods.txt", SystemData.UiModuleType.DEFAULT_INGAME, IsInternalBuild() )   
        ModulesLoadFromListFile( L"interface/MythicApprovedAddOns/MythicApprovedMods.txt", SystemData.UiModuleType.MYTHIC_APPROVED_ADDON, IsInternalBuild() )   
    end
    
    ModulesLoadFromDirectory( SystemData.Directories.AddOnsInterface, SystemData.UiModuleType.USER_ADDON  )

    return true
end

local function CreateCoreWindows()

    LoadPregameData()
    
end

local function InitWindowSet( doFunction )
    InterfaceCore.UpdateScale()
    
    if( not InterfaceCore.inGame )
    then
        CreateCoreWindows()
    end
    
    doFunction()
end

local function CreateWindowIfItDoesNotExist( windowName, show )
    if ( not DoesWindowExist( windowName ) )
    then
        CreateWindow( windowName, show )
    end
end

local function DestroyWindowIfItExists( windowName )
    if ( DoesWindowExist( windowName ) )
    then
        DestroyWindow( windowName )
    end
end

-- Window Set #0
function InterfaceCore.CreateTitleInterface()
   
    InterfaceCore.UpdateScale()
    
    -- Only Load the Title Window
    LoadResources( "Interface/InterfaceCore/Source", "TitleWindow.xml", IsInternalBuild() )
    CreateWindow( "TitleWindow", true )
    InterfaceCore.inGame = false
end

function InterfaceCore.ShutdownTitleInterface()
    DestroyWindow( "TitleWindow" )
end

-- Window Set #1
function InterfaceCore.CreateServerSelectionInterface()    
    InitWindowSet( InterfaceCore.DoCreateServerSelectionInterface )
    InterfaceCore.inGame = false
end
function InterfaceCore.DoCreateServerSelectionInterface()
    CreateWindow( "LoginProgressWindow", true )
    CreateWindow( "ServerSelectWindow", true )
    CreateWindow( "PreloginBackground", true )
    CreateWindowIfItDoesNotExist( "LobbyBackground", true )
end
function InterfaceCore.ShutdownServerSelectionInterface()
    DestroyWindow( "PreloginBackground" )
    DestroyWindow( "ServerSelectWindow" )
    DestroyWindow( "LoginProgressWindow" )
    DestroyWindowIfItExists( "EA_Window_RuleSet" )
end

-- Window Set #2
function InterfaceCore.CreateLoginInterface()
    InterfaceCore.inGame = false
    InitWindowSet( InterfaceCore.DoCreateLoginInterface )
end
function InterfaceCore.DoCreateLoginInterface()
    CreateWindowIfItDoesNotExist( "PNCWindow", false )
    CreateWindow( "LoginProgressWindow", true )
    CreateWindow( "LoginWindow",         false )
    CreateWindow( "PreloginBackground",  true )
    CreateWindowIfItDoesNotExist( "LobbyBackground", true )
    
    EA_Window_EULAROCPopup.Show()  -- Shows the EULA and/or ROC if they haven't yet been accepted
    
    TextLogSetEnabled( "System", true )
    
end
function InterfaceCore.ShutdownLoginInterface()
    DestroyWindow( "PreloginBackground" )
    DestroyWindow( "LoginWindow" )
    DestroyWindow( "LoginProgressWindow" )
end

-- Window Set #3
function InterfaceCore.CreateQuickStartInterface()
    InterfaceCore.inGame = false
    InitWindowSet( InterfaceCore.DoCreateQuickStartInterface )
end
function InterfaceCore.DoCreateQuickStartInterface()
    CreateWindowIfItDoesNotExist( "PNCWindow", false )
    CreateWindowIfItDoesNotExist( "LobbyBackground", true )    
    CreateWindow( "QuickStartWindow", true )
end
function InterfaceCore.ShutdownQuickStartInterface()
    DestroyWindow( "QuickStartWindow" )
end

-- Window Set #4
function InterfaceCore.CreateCharacterSelectionInterface()
    InitWindowSet( InterfaceCore.DoCreateCharacterSelectionInterface )
end
function InterfaceCore.DoCreateCharacterSelectionInterface()
    CreateWindowIfItDoesNotExist( "PNCWindow", false )
    CreateWindowIfItDoesNotExist( "LobbyBackground", true )
    CreateWindow( "CharacterSelectWindow", true )
end
function InterfaceCore.ShutdownCharacterSelectionInterface()
    DestroyWindow( "CharacterSelectWindow" )
    DestroyWindowIfItExists( "EA_Window_Rename_Container" )
end

-- Window Set #7
function InterfaceCore.CreateLoadingInterface()
    InitWindowSet( InterfaceCore.DoCreateLoadingInterface )
end
function InterfaceCore.DoCreateLoadingInterface()   
    
    CreateWindow( "PregameLoadingWindow", true )
    
end
function InterfaceCore.ShutdownLoadingInterface()
    DestroyWindow( "PregameLoadingWindow" )
end

-- Window Set #8
function InterfaceCore.CreatePlayInterface()
    InterfaceCore.inGame = true
    InitWindowSet( InterfaceCore.DoCreatePlayInterface )
end
function InterfaceCore.DoCreatePlayInterface()
    
    -- Blow away the Pregame Data.
    if( preGameResourcesLoaded ) 
    then
        -- This case should no longer be triggered
        -- The Play Window Set is now only active by setting an Active Character UI Profile, which includes a reload.
        return
    end
    
    inGameResourcesLoaded = true
    
    -- Initialize The Mods
    local inGameFilesFound = LoadModData()
        
    -- If the Debug Utils have not been loaded, load enough of the Default UI to display an error
    if( not inGameFilesFound )
    then    
        LoadPregameData()        
        UiModWindow.ShowCustomUIErrorMessage()        
    end
    
    ModulesInitializeAllEnabled()
        
    BroadcastEvent( SystemData.Events.ALL_MODULES_INITIALIZED )
    
    -- Now that we're leaving pregame, set the nameplate font to the user's choice
    SettingsWindowTabTargetting.SetNameplateFont()
    
    
    return   
end

function InterfaceCore.ShutdownPlayInterface()

end


function InterfaceCore.ReloadUI()
    BroadcastEvent( SystemData.Events.RELOAD_INTERFACE )
end

function InterfaceCore.OnResolutionChanged()
    InterfaceCore.UpdateScale()
end

function InterfaceCore.OnLanguageChanged( langId )
    InterfaceCore.ReloadUI()
end

function InterfaceCore.UpdateScale()

    -- Set the scale of the interface according to the screen resolution and user's global scale
  
    scale = InterfaceCore.GetResolutionScale()    
    
    -- Only Apply the Global UI Scale when In-game
    if( InterfaceCore.inGame )
    then
        scale = scale * SystemData.Settings.Interface.globalUiScale
    end    
   
    -- Sanity Check the End Result
    local MIN_SCALE = 0.25
    local MAX_SCALE = 1.25
   
    if( scale < MIN_SCALE )
    then
        scale = MIN_SCALE 
    elseif( scale > MAX_SCALE )
    then
        scale = MAX_SCALE
    end   

    ScaleInterface( scale )
   
end

function InterfaceCore.GetResolutionScale()
    
    -- Determine the base scale from the art resolution
    
    local minDimension = 0
    local artDimension = 0
    if (SystemData.screenResolution.y < SystemData.screenResolution.x) 
    then
        minDimension = SystemData.screenResolution.y
        artDimension = InterfaceCore.artResolution.y
    else
        minDimension = SystemData.screenResolution.x
        artDimension = InterfaceCore.artResolution.x
    end
                            
    return ( minDimension / artDimension ) 
end


function InterfaceCore.GetScale()
    return scale
end
