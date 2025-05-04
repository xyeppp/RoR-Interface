
function Tooltips.OnMouseOverActionButtonGroupCareerIcon( buttonId, flags )

    local careerLineId = ActionButtonGroupGetId( SystemData.ActiveWindow.name, buttonId )
     
    local text = GetCareerLine(careerLineId)
    
    Tooltips.CreateTextOnlyTooltip(  SystemData.ActiveWindow.name.."Button"..buttonId )
    Tooltips.SetTooltipText( 1, 1, text)
    Tooltips.Finalize()
    Tooltips.AnchorTooltip( nil )

end