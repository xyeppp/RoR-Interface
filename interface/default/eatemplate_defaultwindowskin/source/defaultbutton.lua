

EA_Window_DefaultLabelToggleCircle = {}

function EA_Window_DefaultLabelToggleCircle.Initialize()
    
   local buttonName = SystemData.ActiveWindow.name.."Button"
   ButtonSetStayDownFlag( buttonName, true )

end
