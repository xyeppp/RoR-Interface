

-- Define the ERROR and DEBUG functions if they don't exist.
-- These will be overwritte by the function definitions in the EA_UiDebugTools module.

if( DEBUG == nil ) 
then
    function DEBUG( text )
        LogLuaMessage( "Lua", SystemData.UiLogFilters.DEBUG, text )
    end
end

if( ERROR == nil ) 
then

    function ERROR( text )
        if( DebugWindow.Settings.useDevErrorHandling == true ) then
            local strTxt = WStringToString( text )
            error(strTxt, 3)
        else    
            LogLuaMessage( "Lua", SystemData.UiLogFilters.ERROR, text )
        end
    end
end

----------------------------------------------------------------
-- Global Functions
----------------------------------------------------------------

function GetPregameString( id )
	if( id == nil ) then
		ERROR(L"Invalid params to GetPregameString( id): id is nil")
		return L""
	end
	
	return GetStringFromTable( "Pregame", id )
end

function GetPregameStringFormat( id, paramTable)

	if( id == nil ) then
		ERROR(L"Invalid params to GetPregameStringFormat( id, paramTable): id is nil")
		return L""
	elseif( paramTable == nil) then
		ERROR(L"Invalid params to GetPregameStringFormat( id, paramTable): paramTable is nil")
		return L""
	end

    -- Convert all params to wstrings   
	local params = {}        
    local index = 1
    while( paramTable[index] ~= nil ) do
       	params[index] = L""..paramTable[index]
      	index = index + 1
    end
    
    text = GetStringFormatFromTable( "Pregame", id, params )
	
	return text
end

PregameDataUtils = {}

--  Alternating Row Colors
PregameDataUtils.RowColors = {}
PregameDataUtils.RowColors[0] = {r=12, g=15, b=22} -- Dark Blue
PregameDataUtils.RowColors[1] = {r=21, g=28, b=35} -- Steel Blue


function PregameDataUtils.GetAlternatingRowColor( row_mod_by_two )
    -- Pass the math.mod result of the row number divided by 2
    if( PregameDataUtils.RowColors[row_mod_by_two] ~= nil ) then
        return PregameDataUtils.RowColors[row_mod_by_two]
    end
    return PregameDataUtils.RowColors[0]
end