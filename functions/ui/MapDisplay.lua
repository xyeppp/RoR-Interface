--- Called when the user mouses over a icon map point (or points).
--- see <WindowName.MouseoverPoints> variable for all of the points currently under the mouse cursor.
--- @param mapDisplayName string The name of the MapDisplay.
function MapDisplayOnPointMouseOver(mapDisplayName) end

MapDisplay = MapDisplay or {}

MapDisplay.OnPointMouseOver = function(mapDisplayName) end
