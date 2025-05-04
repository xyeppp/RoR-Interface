----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_Macro = {}

EA_Window_Macro.NUM_MACROS = 48
EA_Window_Macro.NUM_MACRO_ICONS = 18
EA_Window_Macro.MACRO_ICONS_ID_BASE = 200

EA_Window_Macro.activeId = 1
EA_Window_Macro.iconNum = 0


----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

----------------------------------------------------------------
-- EA_Window_Macro Functions
----------------------------------------------------------------

-- OnInitialize Handler
function EA_Window_Macro.Initialize()       
            
    -- Label Text
    LabelSetText( "EA_Window_MacroTitleBarText",GetString( StringTables.Default.LABEL_MACROS) )
    ButtonSetText( "EA_Window_MacroDetailsSave", GetString( StringTables.Default.LABEL_SAVE) )
    LabelSetText( "EA_Window_MacroDetailsNameTitle", GetString( StringTables.Default.LABEL_MACROS_NAME) )
    LabelSetText( "EA_Window_MacroDetailsTextTitle", GetString( StringTables.Default.LABEL_MACROS_TEXT) )
    
    LabelSetText( "MacroIconSelectionWindowTitleBarText", GetString( StringTables.Default.LABEL_SELECT_ICON) )

    for  slot = 1, EA_Window_Macro.NUM_MACRO_ICONS do   
        local texture, x, y = GetIconData( EA_Window_Macro.MACRO_ICONS_ID_BASE + slot )
        DynamicImageSetTexture( "MacroIconSelectionWindowIconSlot"..slot.."IconBase", texture, x, y )    
    end
    
    for  slot = 1, EA_Window_Macro.NUM_MACROS do    
        ButtonSetCheckButtonFlag( "EA_Window_MacroIconSlot"..slot, true )
    end
    
    WindowRegisterEventHandler( "EA_Window_Macro", SystemData.Events.MACRO_UPDATED, "EA_Window_Macro.OnMacroUpdated")   
    WindowRegisterEventHandler( "EA_Window_Macro", SystemData.Events.MACROS_LOADED, "EA_Window_Macro.UpdateMacros")   
    
    EA_Window_Macro.UpdateMacros()
    EA_Window_Macro.UpdateDetails( 1 )  
end

-- OnShutdown Handler
function EA_Window_Macro.Shutdown()

end

function EA_Window_Macro.OnHidden()
    WindowUtils.OnHidden()
    EA_Window_Macro.HideMacroIconSelectionWindow()
end

function EA_Window_Macro.OnShown()
    WindowUtils.OnShown(EA_Window_Macro.Hide, WindowUtils.Cascade.MODE_AUTOMATIC)
end

function EA_Window_Macro.Hide()
    WindowSetShowing( "EA_Window_Macro", false )
    EA_Window_Macro.HideMacroIconSelectionWindow()
end

function EA_Window_Macro.OnMacroUpdated(macroId)
    if( macroId == EA_Window_Macro.activeId ) then    
        EA_Window_Macro.UpdateDetails( EA_Window_Macro.activeId )
    end
    
    local macros = DataUtils.GetMacros()
    
    local texture, x, y = GetIconData( macros[macroId].iconNum )
    DynamicImageSetTexture( "EA_Window_MacroIconSlot"..macroId.."IconBase", texture, x, y )
end

function EA_Window_Macro.UpdateMacros()    
    local macros = DataUtils.GetMacros()
        
    for  slot = 1, EA_Window_Macro.NUM_MACROS do    
        local texture, x, y = GetIconData( macros[slot].iconNum )
        DynamicImageSetTexture( "EA_Window_MacroIconSlot"..slot.."IconBase", texture, x, y )
    end
end

function EA_Window_Macro.DetailIconLButtonDown()
    local showing = WindowGetShowing( "MacroIconSelectionWindow" )
    
    if( showing ~= true ) then
        for  slot = 1, EA_Window_Macro.NUM_MACRO_ICONS do   
            ButtonSetPressedFlag( "MacroIconSelectionWindowIconSlot"..slot, false )  
        end
    end
    
    WindowSetShowing( "MacroIconSelectionWindow", showing == false )

end

function EA_Window_Macro.DetailIconLButtonUp()
end

function EA_Window_Macro.DetailIconRButtonDown()
end

function EA_Window_Macro.DetailIconMouseOver()
    local text = GetString( StringTables.Default.TEXT_SELECT_ICON_BUTTON )
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, text )
    Tooltips.AnchorTooltip(Tooltips.ANCHOR_WINDOW_LEFT)
end

function EA_Window_Macro.IconLButtonUp()
    local slot = WindowGetId(SystemData.ActiveWindow.name)
    
    if( EA_Window_Macro.activeId == slot ) then    
        local macros = DataUtils.GetMacros()
        Cursor.PickUp( Cursor.SOURCE_MACRO, slot, slot, macros[slot].iconNum, false )    
    else
        EA_Window_Macro.UpdateDetails( slot )
    end    
end


function EA_Window_Macro.IconMouseDrag()
    if not Cursor.IconOnCursor() then
        local slot = WindowGetId(SystemData.ActiveWindow.name)
        local macros = DataUtils.GetMacros()
        Cursor.PickUp( Cursor.SOURCE_MACRO, slot, slot, macros[slot].iconNum, false )
        EA_Window_Macro.UpdateDetails( slot )
    end
end

function EA_Window_Macro.IconRButtonDown()
end

function EA_Window_Macro.IconMouseOver()
    -- this is all debugged
    --local slot = WindowGetId(SystemData.ActiveWindow.name)
    --local macros = DataUtils.GetMacros()
    --DEBUG( L"Slot "..slot..L"name "..macros[slot].name )
end

function EA_Window_Macro.OnSave()

    SetMacroData( TextEditBoxGetText( "EA_Window_MacroDetailsName" ), TextEditBoxGetText( "EA_Window_MacroDetailsText" ), EA_Window_Macro.iconNum, EA_Window_Macro.activeId )

    local texture, x, y = GetIconData( EA_Window_Macro.iconNum )
    DynamicImageSetTexture( "EA_Window_MacroIconSlot"..EA_Window_Macro.activeId.."IconBase", texture, x, y )
    
    Sound.Play( Sound.BUTTON_CLICK )
end


function EA_Window_Macro.UpdateDetails( slot )
    
    local macros = DataUtils.GetMacros()
    
    EA_Window_Macro.activeId = slot
    EA_Window_Macro.iconNum = macros[slot].iconNum
    
    TextEditBoxSetText( "EA_Window_MacroDetailsName", macros[slot].name )
    TextEditBoxSetText( "EA_Window_MacroDetailsText", macros[slot].text )
    local texture, x, y = GetIconData( macros[slot].iconNum )
    DynamicImageSetTexture( "EA_Window_MacroDetailsIconIconBase", texture, x, y )   
    
    -- Update the Buttons
    for index = 1, EA_Window_Macro.NUM_MACROS do    
        ButtonSetPressedFlag( "EA_Window_MacroIconSlot"..index, EA_Window_Macro.activeId == index )      
    end

end

function EA_Window_Macro.SelectionIconLButtonDown()
    local slot = WindowGetId(SystemData.ActiveWindow.name)

    EA_Window_Macro.iconNum = EA_Window_Macro.MACRO_ICONS_ID_BASE + slot

    local texture, x, y = GetIconData( EA_Window_Macro.iconNum )
    DynamicImageSetTexture( "EA_Window_MacroDetailsIconIconBase", texture, x, y )

    WindowSetShowing( "MacroIconSelectionWindow", false )
end

function EA_Window_Macro.SelectionIconLButtonUp()
end

function EA_Window_Macro.SelectionIconRButtonDown()
end

function EA_Window_Macro.SelectionIconMouseOver()
end

function EA_Window_Macro.HideMacroIconSelectionWindow()
    local showing = WindowGetShowing( "MacroIconSelectionWindow" )
    if(showing == true) then
        WindowSetShowing( "MacroIconSelectionWindow", false )
    end
end
