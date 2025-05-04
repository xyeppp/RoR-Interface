----------------------------------------------------------------
-- TomeWindow - Sigils Implementation
--
--  This file contains all of the initialization and callack
--  functions for the Sigils section of the Old World Armory of the Tome of Knowledge.
-- 
----------------------------------------------------------------

-- Constants
local PARENT_WINDOW = "SigilPageWindowContentsChild"

-- Variables
TomeWindow.Sigils = {}
TomeWindow.Sigils.taskWindowCount = 0
TomeWindow.Sigils.currentSigil = nil


----------------------------------------------------------------
-- Local Accessor Functions

----------------------------------------------------------------
-- Old World Armory Functions
----------------------------------------------------------------


function TomeWindow.InitializeSigils()

    TomeWindow.Sigils.taskWindowCount = 0
    TomeWindow.Sigils.currentSigil = nil
    
    -- Titles Info
    TomeWindow.Pages[ TomeWindow.PAGE_SIGIL ]
        = TomeWindow.NewPageData( TomeWindow.Sections.SECTION_ARMORY, 
                    "Sigil", 
                    TomeWindow.OnShowSigil,
                    TomeWindow.OnSigilsUpdateNavButtons,
                    TomeWindow.OnSigilsPreviousPage,
                    TomeWindow.OnSigilsNextPage,
                    TomeWindow.OnSigilsMouseOverPreviousPage,
                    TomeWindow.OnSigilsMouseOverNextPage )

    TomeWindow.SetPageHeaderText( TomeWindow.PAGE_OLD_WORLD_ARMORY, 
                                  GetString( StringTables.Default.LABEL_OLD_WORLD_ARMORY ), 
                                  L"" )

    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.TOME_SIGIL_ENTRY_UPDATED, "TomeWindow.OnUpdateSigil" )

    PageWindowAddPageBreak( "SigilPageWindow", PARENT_WINDOW.."FragmentsAnchor" )
end

function TomeWindow.SelectFragment()
    local fragmentId = WindowGetId( SystemData.ActiveWindow.name )
    TomeWindow.ShowFragment( fragmentId )
end

function TomeWindow.OnUpdateSigil( sigilEntryId )
    -- don't bother updating unless we're currently looking at it
    if( not WindowGetShowing( "SigilPageWindow" )
        or not TomeWindow.Sigils.currentSigil
        or sigilEntryId ~= TomeWindow.Sigils.currentSigil.id )
    then
        return
    end
    
    TomeWindow.ShowSigil( sigilEntryId )
end

function TomeWindow.OnShowSigil( entryId )
    TomeWindow.ShowSigil( entryId )
end

function TomeWindow.ShowSigil( sigilEntryId )

    local sigilData = TomeGetSigilEntry( sigilEntryId )
    if( not sigilData or not sigilData.id )
    then
        return
    end
    
    TomeWindow.OnViewEntry( GameData.Tome.SECTION_SIGIL, sigilEntryId )
    TomeWindow.Sigils.currentSigil = sigilData

    TomeWindow.SetPageHeaderText( TomeWindow.PAGE_OLD_WORLD_ARMORY, 
                                  GetString( StringTables.Default.LABEL_SIGILS ), 
                                  L"" )
    
    
    -- Set the sigil data
    LabelSetText(PARENT_WINDOW.."SigilTitle", sigilData.fullname )
    LabelSetText(PARENT_WINDOW.."SigilDesc",  sigilData.description )
    LabelSetText(PARENT_WINDOW.."FragmentsTitle", sigilData.fragmentsTitle )
    LabelSetText(PARENT_WINDOW.."FragmentsDesc",  sigilData.fragmentsDescription )
    
    local fragmentWindowName = PARENT_WINDOW.."Fragments"
    local sigilIconName = PARENT_WINDOW.."SigilIconFragment"
    for index, fragment in ipairs( sigilData.fragments )
    do
        local fullFragmentWindowName = fragmentWindowName.."Fragment"..fragment.index
        
        WindowSetId( fullFragmentWindowName, fragment.index )
        
        LabelSetText( fullFragmentWindowName.."Name", fragment.name )
        local texture, x, y = GetIconData( fragment.iconNum )
        DynamicImageSetTexture( fullFragmentWindowName.."Icon", texture, x, y )
        
        -- Set the sigil's icon as well
        DynamicImageSetTexture( sigilIconName..fragment.index, texture, x, y )
        
        local tintColor = 125
        if( fragment.isUnlocked )
        then
            tintColor = 255
        end
        
        WindowSetTintColor( fullFragmentWindowName, tintColor, tintColor, tintColor)

    end
    
    -- Just show the first fragment
    TomeWindow.ShowFragment( 1 )
end

local DEFAULT_TASK_HEIGHT = 23

function TomeWindow.ShowFragment( fragmentId )
    if( not TomeWindow.Sigils.currentSigil )
    then
        return
    end
    
    -- find the fragment we are looking for
    local fragments = TomeWindow.Sigils.currentSigil.fragments
    local fragment = nil
    for index, frag in ipairs(fragments)
    do
        if( frag.index == fragmentId )
        then
            fragment = frag 
            break
        end
    end
    
    -- Update the second page if we found the fragment
    if( fragment )
    then
        LabelSetText(PARENT_WINDOW.."FragmentTaskTitle", GetStringFormat( StringTables.Default.LABEL_SIGIL_FRAGMENT_TASKS, {fragment.name} ) )
        LabelSetText(PARENT_WINDOW.."FragmentTaskDesc",  fragment.taskDescription )
        
        local anchorWindow = PARENT_WINDOW.."FragmentTaskDesc"
        for index, task in ipairs( fragment.tasks )
        do 
            local taskWindowName = PARENT_WINDOW.."Task"..index
            if( not DoesWindowExist( taskWindowName ) )
            then
                TomeWindow.Sigils.taskWindowCount = TomeWindow.Sigils.taskWindowCount + 1
                CreateWindowFromTemplate( taskWindowName, "TomeFragmentTask", PARENT_WINDOW )
                
                ButtonSetStayDownFlag( taskWindowName.."CompletedBtn", true )
                ButtonSetDisabledFlag( taskWindowName.."CompletedBtn", true )
            end
            
            WindowClearAnchors( taskWindowName )
            WindowAddAnchor( taskWindowName, "bottomleft", anchorWindow, "topleft", 0, 5 )
            anchorWindow = taskWindowName
            
            local taskText = task.name
            if( task.counterMax > 0 )
            then
                taskText = GetStringFormat( StringTables.Default.LABEL_SIGIL_FRAGMENT_TASKNAME_AND_COUNTER, {taskText, task.counterValue, task.counterMax} )
            end
            
            LabelSetText( taskWindowName.."Text", taskText )
            
            local x, _ = WindowGetDimensions( taskWindowName )
            local _, labelY = LabelGetTextDimensions( taskWindowName.."Text" )
            
            local y = DEFAULT_TASK_HEIGHT
            if( labelY > y )
            then
                y = labelY
            end
            
            WindowSetDimensions( taskWindowName, x, y )
            
            ButtonSetPressedFlag( taskWindowName.."CompletedBtn", task.isCompleted )
        end
        
        local taskCount = #fragment.tasks
        
        -- show the right number of tasks
        for index = 1, TomeWindow.Sigils.taskWindowCount
        do
            local show = index <= taskCount
            local windowName = PARENT_WINDOW.."Task"..index
            if( WindowGetShowing( windowName ) ~= show )
            then
                WindowSetShowing( windowName, show )
            end
        end
    end
    
    PageWindowUpdatePages( "SigilPageWindow" )
end


---------------------------------------------------------
-- > Nav Buttons

function TomeWindow.OnSigilsUpdateNavButtons()
    if ( TomeWindow.GetCurrentState() ~= TomeWindow.PAGE_SIGILS ) then
        return
    end
    
    local curPage   = PageWindowGetCurrentPage( "SigilsPageWindow" )
    local numPages  = PageWindowGetNumPages( "SigilsPageWindow" )
    WindowSetShowing( "TomeWindowPreviousPageButton", curPage > 1 )
    WindowSetShowing( "TomeWindowNextPageButton", curPage + 2 <= numPages )
end

function TomeWindow.OnSigilsPreviousPage()
    TomeWindow.FlipPageWindowBackward( "SigilsPageWindow")
end

function TomeWindow.OnSigilsNextPage()
    TomeWindow.FlipPageWindowForward( "SigilsPageWindow")
end

function TomeWindow.OnSigilsMouseOverPreviousPage()
    local lines = {}    
    local curPage   = PageWindowGetCurrentPage( "SigilsPageWindow" )
    local numPages  = PageWindowGetNumPages( "SigilsPageWindow" )
    if( curPage > 1 ) then
        -- Previous Pages
        lines[1] = GetString( StringTables.Default.LABEL_OLD_WORLD_ARMORY )
        lines[2] = GetString( StringTables.Default.TEXT_CONTINUED )
    end 
    TomeWindow.CreateBackButtonTooltip( lines )
end

function TomeWindow.OnSigilsMouseOverNextPage()
    local lines = {}    
    local curPage   = PageWindowGetCurrentPage("SigilsPageWindow")
    local numPages  = PageWindowGetNumPages("SigilsPageWindow")
    if( curPage + 2 <= numPages ) then
        -- Next Pages
        lines[1] = GetString( StringTables.Default.LABEL_OLD_WORLD_ARMORY )
        lines[2] = GetString( StringTables.Default.TEXT_CONTINUED )
    end 
    TomeWindow.CreateNextButtonTooltip( lines )
end