TutorialWindow = {}

local LEVEL_AUTOHIDE = 20
TutorialWindow.Settings = 
{ 
    showTutorials = GameData.Player.level < LEVEL_AUTOHIDE, -- Default the Tutorials to 'Off' if the player is above level 20.
} 

local WINDOWNAME = "TutorialWindow"

-- Tutorial Modes. 
-- These each have a set of tabs to show for their topic, such as: RvR, Scenarios, or new to MMOs "How to play" info
TutorialWindow.TUTORIAL_MODE_BASIC_CONTROLS  = 1
TutorialWindow.TUTORIAL_MODE_QUESTS         = 2
TutorialWindow.TUTORIAL_MODE_COMBAT         = 3
TutorialWindow.TUTORIAL_MODE_INVENTORY      = 4
TutorialWindow.TUTORIAL_MODE_TRAINING       = 5
TutorialWindow.TUTORIAL_MODE_GROUPING       = 6 
TutorialWindow.TUTORIAL_MODE_TOK            = 7
TutorialWindow.TUTORIAL_MODE_SCENARIOS      = 8
TutorialWindow.TUTORIAL_MODE_WARCAMP        = 9 
TutorialWindow.TUTORIAL_MODE_PQ             = 10
TutorialWindow.TUTORIAL_MODE_RENOWN         = 11

TutorialWindow.TutorialTabs =
{
    [TutorialWindow.TUTORIAL_MODE_BASIC_CONTROLS]    = { "TutorialWindowTabBasicControls1", "TutorialWindowTabBasicControls2" },                                                     
    [TutorialWindow.TUTORIAL_MODE_QUESTS]            = { "TutorialWindowTabQuests1" },
    [TutorialWindow.TUTORIAL_MODE_COMBAT]            = { "TutorialWindowTabCombat1" },
    [TutorialWindow.TUTORIAL_MODE_INVENTORY]         = { "TutorialWindowTabInventory1" },
    [TutorialWindow.TUTORIAL_MODE_TRAINING]          = { "TutorialWindowTabTraining1" },
    [TutorialWindow.TUTORIAL_MODE_GROUPING]          = { "TutorialWindowTabGrouping1", "TutorialWindowTabGrouping2" },
    [TutorialWindow.TUTORIAL_MODE_TOK]               = { "TutorialWindowTabTOK1" },
    [TutorialWindow.TUTORIAL_MODE_SCENARIOS]         = { "TutorialWindowTabScenario1" },
    [TutorialWindow.TUTORIAL_MODE_WARCAMP]           = { "TutorialWindowTabWarCamp1" },
    [TutorialWindow.TUTORIAL_MODE_PQ]                = { "TutorialWindowTabPQ1" },
    [TutorialWindow.TUTORIAL_MODE_RENOWN]            = { "TutorialWindowTabRenown1" },
}

TutorialWindow.TutorialSounds =
{
    [TutorialWindow.TUTORIAL_MODE_BASIC_CONTROLS]    = GameData.Sound.HELP_TUTORIAL_VO_MAIN,
    [TutorialWindow.TUTORIAL_MODE_QUESTS]            = GameData.Sound.HELP_TUTORIAL_VO_QUESTS,
    [TutorialWindow.TUTORIAL_MODE_COMBAT]            = GameData.Sound.HELP_TUTORIAL_VO_COMBAT,
    [TutorialWindow.TUTORIAL_MODE_INVENTORY]         = GameData.Sound.HELP_TUTORIAL_VO_INVENTORY,
    [TutorialWindow.TUTORIAL_MODE_TRAINING]          = GameData.Sound.HELP_TUTORIAL_VO_BASIC_TRAINING,
    [TutorialWindow.TUTORIAL_MODE_GROUPING]          = GameData.Sound.HELP_TUTORIAL_VO_SOCIALIZING,
    [TutorialWindow.TUTORIAL_MODE_TOK]               = GameData.Sound.HELP_TUTORIAL_VO_TOK,
    [TutorialWindow.TUTORIAL_MODE_SCENARIOS]         = GameData.Sound.HELP_TUTORIAL_VO_SCENARIOS,
    [TutorialWindow.TUTORIAL_MODE_WARCAMP]           = GameData.Sound.HELP_TUTORIAL_VO_WARCAMPS,
    [TutorialWindow.TUTORIAL_MODE_PQ]                = GameData.Sound.HELP_TUTORIAL_VO_PUBLIC_QUESTS,
    [TutorialWindow.TUTORIAL_MODE_RENOWN]            = GameData.Sound.HELP_TUTORIAL_VO_RENOWN,


}

-- Certain Tome Unlocks can trigger opening a tutorial if tutorials are enabled
TutorialWindow.TomeIdUnlockMap = 
{   
    [11989] = { tutorialMode=TutorialWindow.TUTORIAL_MODE_RENOWN, initialTab=1, }, -- the initial tab to select can optionally be specified like so
    [11990] = { tutorialMode=TutorialWindow.TUTORIAL_MODE_WARCAMP, }, 
    [11991] = { tutorialMode=TutorialWindow.TUTORIAL_MODE_GROUPING, }, 
    [11992] = { tutorialMode=TutorialWindow.TUTORIAL_MODE_SCENARIOS,  },  
    [11993] = { tutorialMode=TutorialWindow.TUTORIAL_MODE_TOK, }, 
    [11994] = { tutorialMode=TutorialWindow.TUTORIAL_MODE_PQ, },
    [11995] = { tutorialMode=TutorialWindow.TUTORIAL_MODE_TRAINING, }, 
    [11996] = { tutorialMode=TutorialWindow.TUTORIAL_MODE_INVENTORY, }, 
    [11997] = { tutorialMode=TutorialWindow.TUTORIAL_MODE_COMBAT, }, 
    [11998] = { tutorialMode=TutorialWindow.TUTORIAL_MODE_QUESTS, }, 
}



local m_curMode       = nil
local m_curTab        = nil
local m_curUnlockId   = nil
local m_delayedMode   = nil

local m_basicControlsTimer = 0 
local m_initialShowSetting = true

---------------------------------------------------------------------------
-- Main Tutorial Window Functions
---------------------------------------------------------------------------

function TutorialWindow.Initialize()

    WindowRegisterEventHandler( WINDOWNAME, SystemData.Events.TOME_ID_UNLOCKED_FOR_PLAYER, "TutorialWindow.OnTomeIdUnlocked" )   
    WindowRegisterEventHandler( WINDOWNAME, SystemData.Events.CINEMA_INTRO_ENDED, "TutorialWindow.BeginBasicControlsTimer" )
       
    -- Show Tutorials Button
    LabelSetText( WINDOWNAME.."ShowTutorialsLabel", GetStringFromTable( "TutorialStrings", StringTables.Tutorial.CHECKBUTTON_SHOW_TUTORIALS) )
    ButtonSetStayDownFlag( WINDOWNAME.."ShowTutorialsButton", true )
    
    -- Close Button
    ButtonSetText( WINDOWNAME.."CloseButton", GetStringFromTable( "TutorialStrings", StringTables.Tutorial.CLOSE_BUTTON_TEXT) )
     
    TutorialWindow.SetShowTutorials( TutorialWindow.Settings.showTutorials )    
end

function TutorialWindow.OnShown()
    
    if( m_delayedMode )
    then    
        TutorialWindow.SetMode(m_delayedMode, 1)
        m_delayedMode = nil
    end


    -- Fade in the Window
    local FADE_IN_TIME  = 0.75
    local MIN_ALPHA     = 0.0
    local MAX_ALPHA     = 0.8
    
    WindowStartAlphaAnimation( WINDOWNAME, Window.AnimationType.SINGLE_NO_RESET, MIN_ALPHA, MAX_ALPHA, 
                               FADE_IN_TIME, true, 0, 0 )
    
    -- Cache off the Setting when the window is opened.                           
    m_initialShowSetting = TutorialWindow.GetShowTutorials()
end

function TutorialWindow.OnHidden()

    -- If the user disabled tutorials, show the popup
    if( (m_initialShowSetting == true) and ( TutorialWindow.GetShowTutorials() == false ) )
    then
        TutorialWindow.ShowTutorialsDisabledDialog()        
    end

end

function TutorialWindow.Show()
    WindowSetShowing( WINDOWNAME, true)
    
end

function TutorialWindow.Hide()
    WindowSetShowing( WINDOWNAME, false)
end

function TutorialWindow.OnCloseButton()
    
    if( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) )
    then
        return
    end
    
    TutorialWindow.Hide()
end

function TutorialWindow.Shutdown()
    
end

function TutorialWindow.ShouldShowBeginnerTutorial()
    return TutorialWindow.GetShowTutorials()  and ( GameData.Player.level < 2 )
end

-- Basic Controls Tutorial
function TutorialWindow.BeginBasicControlsTimer()

    if( not TutorialWindow.ShouldShowBeginnerTutorial() )
    then
        return
    end
   
    -- Register the Update Callback to decrement the timer. 
    WindowRegisterEventHandler( WINDOWNAME, SystemData.Events.UPDATE_PROCESSED, "TutorialWindow.UpdateBasicControlsTimer" )
    
    -- Delay Showing the Control Window
    m_basicControlsTimer = 5.0 -- Seconds
end

function TutorialWindow.UpdateBasicControlsTimer()

    m_basicControlsTimer = m_basicControlsTimer - SystemData.UpdateProcessed.Time
    if( m_basicControlsTimer > 0 )
    then
        return -- Continue the timer.
    end

    -- Show the Basic Controls Tutorial
    TutorialWindow.SetMode( TutorialWindow.TUTORIAL_MODE_BASIC_CONTROLS, 1 )
    TutorialWindow.Show()  
    
    -- Unregister the Update Callback
    WindowUnregisterEventHandler( WINDOWNAME, SystemData.Events.UPDATE_PROCESSED )
end

function TutorialWindow.OnTomeIdUnlocked( unlockId, tipType )
    --DEBUG(L"TutorialWindow.OnTomeIdUnlocked unlockId="..towstring(unlockId))
    if( not TutorialWindow.GetShowTutorials() )
    then
        return 
    end
    
    m_curUnlockId = unlockId
    
    local tutorialEntry = TutorialWindow.TomeIdUnlockMap[unlockId]
    if tutorialEntry
    then
        TutorialWindow.SetMode( tutorialEntry.tutorialMode, tutorialEntry.initialTab )
        TutorialWindow.Show()
    end
    
end



-- TutorialWindow.SetModeDelayed -- To load the dds files, this module needs to be 'active'.
-- By calling this function, we delay the 'set' until the OnShown callback
function TutorialWindow.SetModeDelayed( tutorialMode )
    m_delayedMode = tutorialMode
    TutorialWindow.Hide()
    TutorialWindow.Show()
end

-- TutorialWindow.SetMode -- sets which particular tutorial we are showing. Each tutorial can have many tabs, a title, etc
-- initial tab to show within the tutorial is optional and defaults to the first tab
function TutorialWindow.SetMode(tutorialMode, initialTab)
    if ( tutorialMode and ( tutorialMode ~= m_curMode ) and TutorialWindow.TutorialTabs[tutorialMode] )
    then
        if m_curMode and m_curTab
        then
            WindowSetShowing( TutorialWindow.TutorialTabs[m_curMode][m_curTab], false )
        end
        
        -- set up new tabs
        m_curTab = nil
        m_curMode = tutorialMode
                
        TutorialWindow.SelectTab( initialTab or 1 )
        
        Sound.Play( TutorialWindow.TutorialSounds[m_curMode] )
    end
end

function TutorialWindow.OnLButtonUpTab()
    local tabId = WindowGetId (SystemData.ActiveWindow.name)
    TutorialWindow.SelectTab(tabId)
end

-- TutorialWindow.SelectTab -- flips to a tab within the currently displayed tutorial mode
function TutorialWindow.SelectTab(tabNumber)
    if not m_curMode
    then
        return
    end
    
    if ( ( tabNumber ~= nil ) and ( TutorialWindow.TutorialTabs[m_curMode][tabNumber] ) and ( m_curTab ~= tabNumber ) )
    then
        if m_curTab
        then
            -- hide current tab first, unpress its button
            WindowSetShowing( TutorialWindow.TutorialTabs[m_curMode][m_curTab], false )
        end

        m_curTab = tabNumber
        
        local tabWindowName = TutorialWindow.TutorialTabs[m_curMode][m_curTab]
        if not DoesWindowExist(tabWindowName)
        then
            -- lazy tab window create since these windows will rarely be used
            CreateWindowFromTemplate( tabWindowName, tabWindowName.."Template", WINDOWNAME )
        end
        WindowSetShowing( tabWindowName, true )
                
        TutorialWindow.UpdateNavButtons()
    end
end

function TutorialWindow.TabBack()
    if ( m_curTab <= 1 )
    then
        return
    end
    
    TutorialWindow.SelectTab(m_curTab - 1)
end

function TutorialWindow.TabForward()
    if ( m_curTab >= #TutorialWindow.TutorialTabs[m_curMode])
    then
        return
    end
    
    TutorialWindow.SelectTab(m_curTab + 1)
end

function TutorialWindow.UpdateNavButtons()

    WindowSetShowing( WINDOWNAME.."Back", ( m_curTab > 1 ) )
    WindowSetShowing( WINDOWNAME.."Forward", ( m_curTab < #TutorialWindow.TutorialTabs[m_curMode] ) )

end


function TutorialWindow.SetShowTutorials( value )
    TutorialWindow.Settings.showTutorials = value    
    ButtonSetPressedFlag( WINDOWNAME.."ShowTutorialsButton", value )
end

function TutorialWindow.GetShowTutorials()
    return TutorialWindow.Settings.showTutorials
end

function TutorialWindow.ToggleDisableTutorials()
    TutorialWindow.SetShowTutorials( not TutorialWindow.GetShowTutorials() )
end

function TutorialWindow.ShowTutorialsDisabledDialog()

        -- Display an Info dialog telling the player how they may access tutorials
        -- now that they have been disabled.
        DialogManager.MakeOneButtonDialog ( GetStringFromTable( "TutorialStrings",  StringTables.Tutorial.TEXT_TUTORIAL_DISABLED ), 
                                        GetString (StringTables.Default.LABEL_OKAY), nil, 
                                        nil, nil,
                                        nil, nil, false, nil, nil, 
                                        nil,  nil)
end

---------------------------------------------------------------------------
-- Util Functions: These functions are called by the Tabs to 
--                 populate the tutorial data.
---------------------------------------------------------------------------

function TutorialWindow.SetTitleString( stringName )

    local titleText = L"?"
    local stringId = StringTables.Tutorial[ stringName ] 
    if( stringId )
    then
        titleText =  GetStringFromTable( "TutorialStrings", stringId  )
    end

    LabelSetText( WINDOWNAME.."TitleText", titleText )
    
end

function TutorialWindow.SetBackgroundImage( textureFileName )
    
    -- Util function for building the localized Texture Path
    local function GetTextureFilePath( lang )
        local langDir = InterfaceCore.CoreLanguageDirectories[ lang ]
        return "Textures/"..langDir.."/"..textureFileName 
    end
    
    
    -- First try to load the localized image
    local success = SetTextureImage( "EA_Help_Tutorial_Background1", GetTextureFilePath( SystemData.Settings.Language.active ) )    
    if( success == false )
    then
        -- Otherwise fallback on the English image
        SetTextureImage( "EA_Help_Tutorial_Background1", GetTextureFilePath( SystemData.Settings.Language.ENGLISH ) )
    end
end


function TutorialWindow.SetLabelsForWindow( labelBase, numLabels, stringIdBase )

    for index = 1, numLabels
    do
    
        local labelName = labelBase..index
        if( DoesWindowExist( labelName ) )
        then
            
            local text = L""
       
            local stringId = StringTables.Tutorial[ stringIdBase..index ]              
            if( stringId )
            then
                text = GetStringFromTable( "TutorialStrings", stringId )
            end
            
            LabelSetText( labelName, text )
        
        end    
    
    end  

end
