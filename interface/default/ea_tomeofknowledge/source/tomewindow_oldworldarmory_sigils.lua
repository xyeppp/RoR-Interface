----------------------------------------------------------------
-- TomeWindow - Old World Armory Sigils TOC Implementation
--
--  This file contains all of the initialization and callack
--  functions for the Old World Armory Sigils TOC section of the Tome of Knowledge.
-- 
----------------------------------------------------------------


-- Constants
local PARENT_WINDOW = "OldWorldArmorySigilsPageWindowContentsChild"

-- Variables
TomeWindow.OldWorldArmorySigilTOC = {}
TomeWindow.OldWorldArmorySigilTOC.sigilButtonCount = 0

----------------------------------------------------------------
-- Local Accessor Functions

----------------------------------------------------------------
-- Old World Armory Functions
----------------------------------------------------------------

function TomeWindow.InitializeOldWorldArmorySigilsTOC()

    TomeWindow.OldWorldArmorySigilTOC.sigilButtonCount = 0
    
    -- Titles Info
    TomeWindow.Pages[ TomeWindow.PAGE_OLD_WORLD_ARMORY_SIGILS_TOC ]
        = TomeWindow.NewPageData( TomeWindow.Sections.SECTION_ARMORY, 
                    "OldWorldArmorySigils", 
                    TomeWindow.OnShowOldWorldArmorySigilsTOC,
                    TomeWindow.OnOldWorldArmorySigilsTOCUpdateNavButtons,
                    TomeWindow.OnOldWorldArmorySigilsTOCPreviousPage,
                    TomeWindow.OnOldWorldArmorySigilsTOCNextPage,
                    TomeWindow.OnOldWorldArmorySigilsTOCMouseOverPreviousPage,
                    TomeWindow.OnOldWorldArmorySigilsTOCMouseOverNextPage )

    TomeWindow.SetPageHeaderText( TomeWindow.PAGE_OLD_WORLD_ARMORY_SIGILS_TOC, 
                                  GetString( StringTables.Default.LABEL_OLD_WORLD_ARMORY ), 
                                  GetString( StringTables.Default.LABEL_SIGILS ) )
                                  
    --WindowRegisterEventHandler( "TomeWindow", SystemData.Events.TOME_OLD_WORLD_ARMORY_TOC_UPDATED, "TomeWindow.UpdateOldWorldArmorySigilsTOC" )
    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.TOME_SIGIL_TOC_UPDATED, "TomeWindow.UpdateOldWorldArmorySigilsTOC" )

    -- TOC Page
    LabelSetText( PARENT_WINDOW.."ArmoryTitle", GetString( StringTables.Default.LABEL_ARMOR_SETS ) )
    LabelSetText( PARENT_WINDOW.."ArmoryDesc", GetString( StringTables.Default.TEXT_ARMOR_SETS_DESCRIPTION ) )
    LabelSetText( PARENT_WINDOW.."SigilsTitle", GetString( StringTables.Default.LABEL_SIGILS ) )
    LabelSetText( PARENT_WINDOW.."SigilsDesc", GetString( StringTables.Default.TEXT_SIGILS_DESCRIPTION ) )
    
    PageWindowAddPageBreak( "OldWorldArmorySigilsPageWindow", PARENT_WINDOW.."SigilPageAnchor" )

    TomeWindow.UpdateOldWorldArmorySigilsTOC()
end

local NUM_SIGILS_PER_ROW = 3
local SIGIL_X_OFFSET = 140
local SIGIL_Y_OFFSET = 130

function TomeWindow.UpdateOldWorldArmorySigilsTOC()
    local tierTOCData = TomeGetOldWorldArmoryTierTOC()
    -- Set up the Armory TOC on the left 
    for tierIndex, tierSetData in ipairs( tierTOCData )
    do
        local tierWindow = PARENT_WINDOW.."Tier"..tierIndex
        LabelSetText( tierWindow.."Name", GetStringFormat( StringTables.Default.LABEL_TIER_X, { tierIndex } ) )
        StatusBarSetMaximumValue( tierWindow.."ProgressBar", tierSetData.total )
        StatusBarSetCurrentValue( tierWindow.."ProgressBar", tierSetData.numFound )
        StatusBarSetForegroundTint( tierWindow.."ProgressBar", 255, 0, 0 ) 
    end
    
    -- Set up the Sigil TOC on the right
    local sigilTOC = TomeGetSigilTOC()
    local sigilEntryWindowName = PARENT_WINDOW.."Sigil"
    local anchorWindow = PARENT_WINDOW.."SigilsAnchor"
    for index, sigilData in ipairs( sigilTOC )
    do
        -- create window if we need to
        if( not DoesWindowExist( sigilEntryWindowName..index ) )
        then
            TomeWindow.OldWorldArmorySigilTOC.sigilButtonCount = TomeWindow.OldWorldArmorySigilTOC.sigilButtonCount + 1
            CreateWindowFromTemplate( sigilEntryWindowName..index, "TomeSigilItem", PARENT_WINDOW )
        end
        
        local cellNum = sigilData.displayIndex - 1
        local col = math.fmod( cellNum, NUM_SIGILS_PER_ROW )
        local row = math.floor( cellNum / NUM_SIGILS_PER_ROW )
        WindowClearAnchors( sigilEntryWindowName..index )
        WindowAddAnchor( sigilEntryWindowName..index, "bottomleft", anchorWindow, "topleft", col * SIGIL_X_OFFSET, row * SIGIL_Y_OFFSET)

        WindowSetId( sigilEntryWindowName..index, sigilData.id )
        LabelSetText( sigilEntryWindowName..index.."Name", sigilData.name )
        
        local fragmentWindow = sigilEntryWindowName..index.."Fragment"
        for fragIndex, fragmentData in ipairs( sigilData.fragments )
        do
            local texture, x, y = GetIconData( fragmentData.iconNum )
            DynamicImageSetTexture( fragmentWindow..fragmentData.index, texture, x, y )
            
            local r = 125
            local g = 125
            local b = 125
            if( fragmentData.isUnlocked )
            then
                r = 255
                g = 255
                b = 255
            end
            
            WindowSetTintColor( fragmentWindow..fragmentData.index, r, g, b)
        end
        
    end
    
    local sigilCount = #sigilTOC
    -- show the right number of sigils
    for index = 1, TomeWindow.OldWorldArmorySigilTOC.sigilButtonCount
    do
        local show = index <= sigilCount
        local windowName = sigilEntryWindowName..index
        if( WindowGetShowing( windowName ) ~= show )
        then
            WindowSetShowing( windowName, show )
        end
        
        if( not show )
        then
           WindowSetId( windowName, 0 )
        end
    end
    
    PageWindowUpdatePages( "OldWorldArmorySigilsPageWindow" )
    
end

function TomeWindow.SelectSigilEntry()
    local sigilId = WindowGetId( SystemData.ActiveWindow.name )
    TomeWindow.SetState( TomeWindow.PAGE_SIGIL, { sigilId } )
end

function TomeWindow.SelectOldWorldArmoryTOC()
    TomeWindow.SetState( TomeWindow.PAGE_OLD_WORLD_ARMORY, {} )
end


---------------------------------------------------------
-- > Nav Buttons

function TomeWindow.OnOldWorldArmorySigilsUpdateNavButtons()
    if ( TomeWindow.GetCurrentState() ~= TomeWindow.PAGE_OLD_WORLD_ARMORY ) then
        return
    end
    
    local curPage   = PageWindowGetCurrentPage( "OldWorldArmorySigilsPageWindow" )
    local numPages  = PageWindowGetNumPages( "OldWorldArmorySigilsPageWindow" )
    WindowSetShowing( "TomeWindowPreviousPageButton", curPage > 1 )
    WindowSetShowing( "TomeWindowNextPageButton", curPage + 2 <= numPages )
end

function TomeWindow.OnOldWorldArmorySigilsPreviousPage()
    TomeWindow.FlipPageWindowBackward( "OldWorldArmorySigilsPageWindow")
end

function TomeWindow.OnOldWorldArmorySigilsNextPage()
    TomeWindow.FlipPageWindowForward( "OldWorldArmorySigilsPageWindow")
end

function TomeWindow.OnOldWorldArmorySigilsMouseOverPreviousPage()
    local lines = {}    
    local curPage   = PageWindowGetCurrentPage( "OldWorldArmorySigilsPageWindow" )
    local numPages  = PageWindowGetNumPages( "OldWorldArmorySigilsPageWindow" )
    if( curPage > 1 ) then
        -- Previous Pages
        lines[1] = GetString( StringTables.Default.LABEL_OLD_WORLD_ARMORY )
        lines[2] = GetString( StringTables.Default.TEXT_CONTINUED )
    end 
    TomeWindow.CreateBackButtonTooltip( lines )
end

function TomeWindow.OnOldWorldArmorySigilsMouseOverNextPage()
    local lines = {}    
    local curPage   = PageWindowGetCurrentPage("OldWorldArmorySigilsPageWindow")
    local numPages  = PageWindowGetNumPages("OldWorldArmorySigilsPageWindow")
    if( curPage + 2 <= numPages ) then
        -- Next Pages
        lines[1] = GetString( StringTables.Default.LABEL_OLD_WORLD_ARMORY )
        lines[2] = GetString( StringTables.Default.TEXT_CONTINUED )
    end 
    TomeWindow.CreateNextButtonTooltip( lines )
end