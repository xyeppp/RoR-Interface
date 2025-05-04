----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

local function InitCheckBox( buttonName )
   ButtonSetStayDownFlag( buttonName, true )
end

local function ToggleCheckBox( buttonName )
    if( ButtonGetDisabledFlag( buttonName ) )
    then
        return
    end
    
    local pressed = ButtonGetPressedFlag( buttonName )
    ButtonSetPressedFlag( buttonName, not pressed )
end

local function IsCheckBoxChecked( buttonName )    
    return ButtonGetPressedFlag( buttonName )
end

local function SetCheckBoxChecked( buttonName, pressed )
    ButtonSetPressedFlag( buttonName, pressed )
end

EA_LabelCheckButton = {}

function EA_LabelCheckButton.Initialize( initialState )
    InitCheckBox( SystemData.ActiveWindow.name.."Button" )
    
    -- Set the initial state if specified
    if( initialState ~= nil )
    then
        SetCheckBoxChecked( SystemData.ActiveWindow.name.."Button", initialState)
    end
end

function EA_LabelCheckButton.Toggle()
    ToggleCheckBox( SystemData.ActiveWindow.name.."Button" )
end

function EA_LabelCheckButton.IsChecked()
    return IsCheckBoxChecked( SystemData.ActiveWindow.name.."Button" )
end

EA_GenericCheckButton = {}

function EA_GenericCheckButton.Initialize( initialState )
    InitCheckBox( SystemData.ActiveWindow.name )

    -- Set the initial state if specified
    if( initialState ~= nil )
    then
        SetCheckBoxChecked( SystemData.ActiveWindow.name, initialState)
    end
end

function EA_GenericCheckButton.Toggle()
    ToggleCheckBox( SystemData.ActiveWindow.name )
end


