
----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

LayoutEditor.Settings.Options = 
{
    snapWindowsEnabled = true,
    snapDistance = 20,
}


LayoutEditor.WINDOW_SNAP_DISTANCES = { 5, 10, 15, 20, 25, 30, 35, 45 }

----------------------------------------------------------------
-- Local Functions
----------------------------------------------------------------

local function GetWindowSnapDistanceIndex( distance )
    for index, dist in ipairs( LayoutEditor.WINDOW_SNAP_DISTANCES )
    do        
        if( dist == distance )
        then
            return index
        end
    end
    
    return 0
end


-- Accessors

function LayoutEditor.GetWindowSnapDistance()
    return LayoutEditor.Settings.Options.snapDistance
end

function LayoutEditor.IsWindowSnappingEnabled()
    return LayoutEditor.Settings.Options.snapWindowsEnabled
end

----------------------------------------------------------------
-- Layout Editor Options Functions
----------------------------------------------------------------

-- OnInitialize Handler()
function LayoutEditor.InitializeOptions()

    LabelSetText( "LayoutEditorWindowOptionsTitleBarText", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_OPTIONS_TITLE ) )
   
    -- Main Buttons
    ButtonSetText( "LayoutEditorWindowOptionsOkayButton", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_OPTIONS_OKAY_BUTTON ) )
    ButtonSetText( "LayoutEditorWindowOptionsCancelButton", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_OPTIONS_CANCEL_BUTTON ) )

     
    -- Snap Windows
    LabelSetText( "LayoutEditorWindowOptionsSnapWindowSectionLabel", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_OPTIONS_SNAP_WINDOWS ) )
    
    LabelSetText( "LayoutEditorWindowOptionsSnapWindowsCheckLabel", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_OPTIONS_SNAP_WINDOWS_ENABLED ) )
    ButtonSetCheckButtonFlag( "LayoutEditorWindowOptionsSnapWindowsCheckButton", true )
    
    LabelSetText( "LayoutEditorWindowOptionsSnapWindowsDistanceLabel", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_OPTIONS_SNAP_WINDOWS_DISTANCE ) )
    for _, distance in ipairs( LayoutEditor.WINDOW_SNAP_DISTANCES )
    do        
        ComboBoxAddMenuItem( "LayoutEditorWindowOptionsSnapWindowsDistanceCombo", L""..distance )
    end
    
    LayoutEditor.RestoreOptions()    

    -- Hide the Options Screen By Default
    WindowSetShowing( "LayoutEditorWindowOptions", false )
end



function LayoutEditor.RestoreOptions()

    -- Restore the options from the settings.
    
    -- Snap Windows
    ButtonSetPressedFlag( "LayoutEditorWindowOptionsSnapWindowsCheckButton", LayoutEditor.Settings.Options.snapWindowsEnabled )
    
    -- Snap Distance
    local snapDistanceIndex = GetWindowSnapDistanceIndex( LayoutEditor.Settings.Options.snapDistance )
    ComboBoxSetSelectedMenuItem( "LayoutEditorWindowOptionsSnapWindowsDistanceCombo", snapDistanceIndex )
    
end


function LayoutEditor.OnOptionsOkayButton()
    
    -- Snap Windows
    LayoutEditor.Settings.Options.snapWindowsEnabled = ButtonGetPressedFlag( "LayoutEditorWindowOptionsSnapWindowsCheckButton" )
    LayoutEditor.Settings.Options.snapDistance = LayoutEditor.WINDOW_SNAP_DISTANCES[ ComboBoxGetSelectedMenuItem(  "LayoutEditorWindowOptionsSnapWindowsDistanceCombo" ) ]

    LayoutEditor.ToggleOptions()
end

function LayoutEditor.OnOptionsCancelButton()

    LayoutEditor.RestoreOptions()
    LayoutEditor.ToggleOptions()
end