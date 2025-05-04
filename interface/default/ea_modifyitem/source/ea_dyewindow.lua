
EA_DyeWindow = {}

EA_DyeWindow.windowName = "EA_DyeWindow"
EA_DyeWindow.selectedTint = 1
EA_DyeWindow.radioButtons =
{
    [1] = EA_DyeWindow.windowName.."TintA",
    [2] = EA_DyeWindow.windowName.."TintB",
}
EA_DyeWindow.isBleach = false

-- Local Functions 
local function UpdateTintRadioButtons()
    for index, windowName in ipairs( EA_DyeWindow.radioButtons )
    do
        if ( EA_DyeWindow.selectedTint == WindowGetId( windowName ) )
        then
            ButtonSetPressedFlag( windowName.."Button", true )
        else
            ButtonSetPressedFlag( windowName.."Button", false )
        end
    end
end

function EA_DyeWindow.Initialize()
    LabelSetText(  EA_DyeWindow.windowName.."TintALabel",            GetString( StringTables.Default.TEXT_DYE_PRIMARY_TINT ) )
    LabelSetText(  EA_DyeWindow.windowName.."TintBLabel",            GetString( StringTables.Default.TEXT_DYE_SECONDARY_TINT ) )
    ButtonSetText( EA_DyeWindow.windowName.."Accept",           GetString( StringTables.Default.LABEL_ACCEPT ) )
    ButtonSetText( EA_DyeWindow.windowName.."Cancel",           GetString( StringTables.Default.LABEL_CANCEL ) )
end

function EA_DyeWindow.Shutdown()
end

function EA_DyeWindow.Show()
    if( WindowGetShowing( EA_DyeWindow.windowName ) )
    then
        return
    end
    
	WindowSetShowing( EA_DyeWindow.windowName, true)

    Sound.Play( Sound.WINDOW_OPEN )
    
    UpdateTintRadioButtons()
    
    if( EA_DyeWindow.isBleach )
    then
        LabelSetText(  EA_DyeWindow.windowName.."TitleBarText",     GetString( StringTables.Default.TEXT_BLEACH_TITLE_BAR ) )
        LabelSetText(  EA_DyeWindow.windowName.."ChoiceText",       GetString( StringTables.Default.TEXT_BLEACH_CHOOSE_TINT ) )
    else
        LabelSetText(  EA_DyeWindow.windowName.."TitleBarText",     GetString( StringTables.Default.TEXT_DYE_TITLE_BAR ) )
        LabelSetText(  EA_DyeWindow.windowName.."ChoiceText",       GetString( StringTables.Default.TEXT_DYE_CHOOSE_TINT ) )
    end

end

function EA_DyeWindow.Hide()
    if( not WindowGetShowing( EA_DyeWindow.windowName ) )
    then
        return
    end

	WindowSetShowing( EA_DyeWindow.windowName, false )
	
    Sound.Play( Sound.WINDOW_CLOSE )
end

function EA_DyeWindow.OnAcceptLButtonUp()
    UseItemTargeting.PreviewDye( EA_DyeWindow.selectedTint )
    EA_DyeWindow.Hide()
    UseItemTargeting.MakeDyeDialog()
end

function EA_DyeWindow.OnCancelLButtonUp()
    Cursor.ClearTargetingData()
    EA_DyeWindow.selectedTint = 1
    EA_DyeWindow.Hide()
end

function EA_DyeWindow.OnSelectTintLButtonUp()
    EA_DyeWindow.selectedTint = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
    DEBUG(L"Selected Tint: "..EA_DyeWindow.selectedTint)
    UpdateTintRadioButtons()
end
