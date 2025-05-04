----------------------------------------------------------------
-- Window State Functions
--
-- Globally defined.  Initally part of InterfaceCore.lua.
--
-- This is an optimation to minimize C call overhead in places
-- where we call these methods a lot.
--
-- Helper functions that check internal window state which is a
-- native lua internal variable.
--
-- If the variable does not exist, default C call will in turn
-- be executed.
--
----------------------------------------------------------------

local function WindowGetState( windowName )
    local globalTable = _G
    local windowTable = globalTable[ windowName ]
    
    if ( windowTable ~= nil ) then
        local stateTable = windowTable[ "STATE" ]
        if ( stateTable ~= nil ) then
            return stateTable
        end
    end

    --DEBUG(L"WindowGetState( "..StringToWString(windowName)..L" ) == NIL" )
    return nil
end

function WindowGetShowing( windowName )
    local state = WindowGetState( windowName )
    
    if ( state ~= nil ) then
        return state[ "SHOWING" ]
    else
        return _WindowGetShowing( windowName )
    end
end

function WindowGetDimensions( windowName )
    local state = WindowGetState( windowName )
    
    if ( state ~= nil ) then
        return state[ "DIMENSION_X" ], state[ "DIMENSION_Y" ]
    else    
        return _WindowGetDimensions( windowName )
    end
end

function LabelGetTextColor( windowName )
    local state = WindowGetState( windowName )
    
    if ( state ~= nil ) then
        return state[ "LABEL_TEXTCOLOR_R" ], state[ "LABEL_TEXTCOLOR_G" ], state[ "LABEL_TEXTCOLOR_B" ]
    else
        return _LabelGetTextColor( windowName )
    end
end

function LabelGetLinkColor( windowName )
    return LabelGetTextColor( windowName )
end

function LabelGetTextDimensions( windowName )
    local state = WindowGetState( windowName )
    
    if ( state ~= nil ) then
        return state[ "LABEL_TEXTDIMS_X" ], state[ "LABEL_TEXTDIMS_Y" ]
    else
        return _LabelGetTextDimensions( windowName )
    end
end

function LabelGetText( windowName )
    local state = WindowGetState( windowName )
    
    if ( state ~= nil ) then
        return state[ "LABEL_TEXT" ]
    else
        return _LabelGetText( windowName )
    end
end
