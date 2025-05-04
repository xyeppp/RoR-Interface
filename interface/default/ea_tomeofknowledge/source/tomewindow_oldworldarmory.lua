----------------------------------------------------------------
-- TomeWindow - Old World Armory Implementation
--
--  This file contains all of the initialization and callack
--  functions for the Old World Armory section of the Tome of Knowledge.
-- 
----------------------------------------------------------------


-- Constants
local PARENT_WINDOW = "OldWorldArmoryPageWindowContentsChild"

-- Variables
TomeWindow.OldWorldArmory = {}
TomeWindow.OldWorldArmory.armorSetButtonCount = 0
TomeWindow.OldWorldArmory.itemButtonCount = 0
TomeWindow.OldWorldArmory.currentArmorSet = nil

local slotWindowMap = {}
slotWindowMap[ GameData.EquipSlots.HELM ]       = PARENT_WINDOW.."StaticSlotHelm"
slotWindowMap[ GameData.EquipSlots.SHOULDERS ]  = PARENT_WINDOW.."StaticSlotShoulders"
slotWindowMap[ GameData.EquipSlots.BODY ]       = PARENT_WINDOW.."StaticSlotBody"
slotWindowMap[ GameData.EquipSlots.GLOVES ]     = PARENT_WINDOW.."StaticSlotGloves"
slotWindowMap[ GameData.EquipSlots.BOOTS ]      = PARENT_WINDOW.."StaticSlotBoots"

local tocData = nil
local bToCInitted = false

----------------------------------------------------------------
-- Local Accessor Functions




----------------------------------------------------------------
-- Old World Armory Functions
----------------------------------------------------------------

local function HideStaticSlots()

    for _, windowName in pairs( slotWindowMap )
    do
        WindowSetShowing( windowName, false )
    end
end

local function IsStaticSlot( slotNum )

    if( slotWindowMap[ slotNum ] )
    then
        return true
    end

end


function TomeWindow.InitializeOldWorldArmory()

    TomeWindow.OldWorldArmory.armorSetButtonCount = 0
    TomeWindow.OldWorldArmory.itemButtonCount = 0
    TomeWindow.OldWorldArmory.currentArmorSet = nil
    
    -- Titles Info
    TomeWindow.Pages[ TomeWindow.PAGE_OLD_WORLD_ARMORY ]
        = TomeWindow.NewPageData( TomeWindow.Sections.SECTION_ARMORY, 
                    "OldWorldArmory", 
                    TomeWindow.OnShowOldWorldArmory,
                    TomeWindow.OnOldWorldArmoryUpdateNavButtons,
                    TomeWindow.OnOldWorldArmoryPreviousPage,
                    TomeWindow.OnOldWorldArmoryNextPage,
                    TomeWindow.OnOldWorldArmoryMouseOverPreviousPage,
                    TomeWindow.OnOldWorldArmoryMouseOverNextPage )

    TomeWindow.SetPageHeaderText( TomeWindow.PAGE_OLD_WORLD_ARMORY, 
                                  GetString( StringTables.Default.LABEL_OLD_WORLD_ARMORY ), 
                                  L"" )
                                  
    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.TOME_OLD_WORLD_ARMORY_TOC_UPDATED, "TomeWindow.UpdateOldWorldArmoryTOC" )
    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.TOME_OLD_WORLD_ARMORY_ARMOR_SET_UPDATED, "TomeWindow.OnUpdateArmorSet" )
    
    -- TOC Page
    LabelSetText( PARENT_WINDOW.."Title", wstring.upper( GameData.Player.career.name..L" "..GetString( StringTables.Default.LABEL_OLD_WORLD_ARMORY ) ) )
    LabelSetText( PARENT_WINDOW.."LinkDescText", GetString( StringTables.Default.TEXT_NO_ARMOR_SETS ) )
    
    PageWindowAddPageBreak( "OldWorldArmoryPageWindow", PARENT_WINDOW.."GuyAnchor" )
    
    -- Init static slots
    for _, windowName in pairs( slotWindowMap )
    do
        ButtonSetDisabledFlag( windowName.."CompletedBtn", true )
    end
    
    HideStaticSlots()
end

function TomeWindow.OnShowOldWorldArmory( entry )
    if not bToCInitted
    then
        TomeWindow.UpdateOldWorldArmoryTOC()
    end
    if( entry == nil or entry == 0 ) then
        -- show first set if there is one
        if( tocData and tocData[1] )
        then
            TomeWindow.ShowArmorSet( tocData[1].id )
        else
            -- otherwise just bail, nothing to see here
            return
        end
    end
    
    TomeWindow.ShowArmorSet( entry ) 
    
end

function TomeWindow.UpdateOldWorldArmoryTOC()
    tocData = TomeGetOldWorldArmoryTOC()
    local setCount = 0
    
    local setEntryWindowName = PARENT_WINDOW.."SetLink"
    local anchorWindow = PARENT_WINDOW.."LinkDescText"
    
    for index, setData in ipairs( tocData )
    do
        setCount = setCount + 1
    
        -- create window if we need to
        if( not DoesWindowExist( setEntryWindowName..index ) )
        then
            TomeWindow.OldWorldArmory.armorSetButtonCount = TomeWindow.OldWorldArmory.armorSetButtonCount + 1
            CreateWindowFromTemplate( setEntryWindowName..index, "TomeOWASetButton", PARENT_WINDOW )

            ButtonSetStayDownFlag( setEntryWindowName..index.."CompletedBtn", true )
            ButtonSetDisabledFlag( setEntryWindowName..index.."CompletedBtn", true )
            
            if( setCount == 1 )
            then
                WindowAddAnchor( setEntryWindowName..index, "topleft", anchorWindow, "topleft", 0, 0 )
            else
                WindowAddAnchor( setEntryWindowName..index, "bottomleft", anchorWindow, "topleft", 0, 5 )
            end
        end
        anchorWindow = setEntryWindowName..index
        
        ButtonSetPressedFlag( setEntryWindowName..index.."CompletedBtn", setData.isComplete )
        ButtonSetText( setEntryWindowName..index.."Text", setData.name )
        WindowSetId( setEntryWindowName..index, setData.id )
    end
    
    if( setCount == 0 )
    then
        LabelSetText( PARENT_WINDOW.."LinkDescText", GetString( StringTables.Default.TEXT_NO_ARMOR_SETS ) )
    else
        LabelSetText( PARENT_WINDOW.."LinkDescText", L"" )
    end
    
    -- show the right number of buttons
    for index = 1, TomeWindow.OldWorldArmory.armorSetButtonCount
    do
        local show = index <= setCount
        local windowName = setEntryWindowName..index
        if( WindowGetShowing( windowName ) ~= show ) then
            WindowSetShowing( windowName, show )
        end
        if( show == false ) then
           WindowSetId( windowName, 0 )
        end
    end
    
    -- Anchor the items divider below the last button
    WindowClearAnchors( PARENT_WINDOW.."GuyAnchor" )
    WindowAddAnchor( PARENT_WINDOW.."GuyAnchor", "bottom", anchorWindow, "top", 0, 0 )
    
    -- Default to first unlocked if none set
    if( not TomeWindow.OldWorldArmory.currentArmorSet and setCount > 0 )
    then
        TomeWindow.ShowArmorSet( tocData[1].id )
    end
    
    PageWindowUpdatePages( "OldWorldArmoryPageWindow" )
    bToCInitted = true
end

function TomeWindow.SelectArmorSet()
    local armorSetId = WindowGetId( SystemData.ActiveWindow.name )
    TomeWindow.ShowArmorSet( armorSetId )
end

function TomeWindow.OnUpdateArmorSet( armorSetId )
    -- don't bother updating unless we're currently looking at it
    if( not TomeWindow.OldWorldArmory.currentArmorSet
        or armorSetId ~= TomeWindow.OldWorldArmory.currentArmorSet.id )
    then
        return
    end
    
    TomeWindow.ShowArmorSet( armorSetId, true )
end

function TomeWindow.ShowArmorSet( armorSetId, noAnimation )
    if( armorSetId == 0 or armorSetId == nil )
    then
        return
    end
    
    local setData = TomeGetOldWorldArmoryArmorSet( armorSetId )
    if not setData
    then
        return
    end
    
    TomeWindow.OnViewEntry( GameData.Tome.SECTION_OLD_WORLD_ARMORY, armorSetId )
    
    -- Set Pressed State
    for index = 1, TomeWindow.OldWorldArmory.armorSetButtonCount do
        local windowName = PARENT_WINDOW.."SetLink"..index
        local pressed = WindowGetId( windowName ) == armorSetId
        ButtonSetDisabledFlag( windowName.."Text", pressed )
    end
    

    TomeWindow.OldWorldArmory.currentArmorSet = setData
    local itemCount = 0 -- non static items
    
    HideStaticSlots()
    
    TomeWindow.SetPageHeaderText( TomeWindow.PAGE_OLD_WORLD_ARMORY, 
                                  GetString( StringTables.Default.LABEL_OLD_WORLD_ARMORY ), 
                                  setData.name )
    
    local itemWindowName = PARENT_WINDOW.."ArmorSetItem"
    local anchorWindow = PARENT_WINDOW.."ItemsAnchor"
    
    for index, itemInfo in ipairs( setData.pieces )
    do
        -- don't create the icon if there's no item data here
        if( not itemInfo.itemData )
        then
            continue
        end
        
        local fullItemWindowName = itemWindowName
        
        if( not IsStaticSlot( itemInfo.itemData.equipSlot ) )
        then
            itemCount = itemCount + 1
        
            -- create window if we need to
            if( not DoesWindowExist( itemWindowName..itemCount ) )
            then
                TomeWindow.OldWorldArmory.itemButtonCount = TomeWindow.OldWorldArmory.itemButtonCount + 1
                CreateWindowFromTemplate( itemWindowName..itemCount, "TomeOWAItem", PARENT_WINDOW )
                WindowAddAnchor( itemWindowName..itemCount, "bottomleft", anchorWindow, "topleft", 0, 20 )
                
                ButtonSetStayDownFlag( itemWindowName..itemCount.."CompletedBtn", true )
                ButtonSetDisabledFlag( itemWindowName..itemCount.."CompletedBtn", true )
            end
            anchorWindow = itemWindowName..itemCount
            
            fullItemWindowName = anchorWindow
        else
            fullItemWindowName = slotWindowMap[ itemInfo.itemData.equipSlot ]
            WindowSetShowing( fullItemWindowName, true )
        end
        
        WindowSetId( fullItemWindowName, index )
        
        LabelSetText( fullItemWindowName.."Name", itemInfo.itemData.name )
        ButtonSetPressedFlag( fullItemWindowName.."CompletedBtn", itemInfo.unlocked )

    end
    
    
    -- show the right number of buttons
    for index = 1, TomeWindow.OldWorldArmory.itemButtonCount
    do
        local show = index <= itemCount
        local windowName = itemWindowName..index
        if( WindowGetShowing( windowName ) ~= show ) then
            WindowSetShowing( windowName, show )
        end
        if( show == false ) then
           WindowSetId( windowName, 0 )
        end
    end
    
    if( not noAnimation )
    then
        WindowStartAlphaAnimation( "OldWorldArmoryPageWindow", Window.AnimationType.SINGLE_NO_RESET, 0, 1, 
                        TomeWindow.FADE_IN_TIME, true, 0, 0 )
    end
    
    PageWindowUpdatePages( "OldWorldArmoryPageWindow" )
end


function TomeWindow.OnMouseOverArmorSetItem()
    if( not TomeWindow.OldWorldArmory.currentArmorSet )
    then
        return
    end
    
    local itemIndex = WindowGetId( SystemData.ActiveWindow.name )
    local piece = TomeWindow.OldWorldArmory.currentArmorSet.pieces[itemIndex]
    
    if( not piece )
    then
        return
    end
    
    Tooltips.CreateItemTooltip( piece.itemData, SystemData.ActiveWindow.name, Tooltips.ANCHOR_WINDOW_LEFT )
end


---------------------------------------------------------
-- > Nav Buttons

function TomeWindow.OnOldWorldArmoryUpdateNavButtons()
    if ( TomeWindow.GetCurrentState() ~= TomeWindow.PAGE_OLD_WORLD_ARMORY ) then
        return
    end
    
    local curPage   = PageWindowGetCurrentPage( "OldWorldArmoryPageWindow" )
    local numPages  = PageWindowGetNumPages( "OldWorldArmoryPageWindow" )
    WindowSetShowing( "TomeWindowPreviousPageButton", curPage > 1 )
    WindowSetShowing( "TomeWindowNextPageButton", curPage + 2 <= numPages )
end

function TomeWindow.OnOldWorldArmoryPreviousPage()
    TomeWindow.FlipPageWindowBackward( "OldWorldArmoryPageWindow")
end

function TomeWindow.OnOldWorldArmoryNextPage()
    TomeWindow.FlipPageWindowForward( "OldWorldArmoryPageWindow")
end

function TomeWindow.OnOldWorldArmoryMouseOverPreviousPage()
    local lines = {}    
    local curPage   = PageWindowGetCurrentPage( "OldWorldArmoryPageWindow" )
    local numPages  = PageWindowGetNumPages( "OldWorldArmoryPageWindow" )
    if( curPage > 1 ) then
        -- Previous Pages
        lines[1] = GetString( StringTables.Default.LABEL_OLD_WORLD_ARMORY )
        lines[2] = GetString( StringTables.Default.TEXT_CONTINUED )
    end 
    TomeWindow.CreateBackButtonTooltip( lines )
end

function TomeWindow.OnOldWorldArmoryMouseOverNextPage()
    local lines = {}    
    local curPage   = PageWindowGetCurrentPage("OldWorldArmoryPageWindow")
    local numPages  = PageWindowGetNumPages("OldWorldArmoryPageWindow")
    if( curPage + 2 <= numPages ) then
        -- Next Pages
        lines[1] = GetString( StringTables.Default.LABEL_OLD_WORLD_ARMORY )
        lines[2] = GetString( StringTables.Default.TEXT_CONTINUED )
    end 
    TomeWindow.CreateNextButtonTooltip( lines )
end