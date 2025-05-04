----------------------------------------------------------------
-- TomeWindow - Stat Tracking Utils  Implementation
--
--  This file contains a utility functions for updating the a statistic
--  value from a single variable.
--
-- This uses the format the dotted line format: 
-- For Example: Total RvR Kills............ 500
-- 
----------------------------------------------------------------

TomeWindow.StatUtils = {}

function NewTomeStat( iwindowName, istrIndex, iupdateEvent, ivariableName )
    return { windowName=iwindowName, strIndex=istrIndex, updateEvent=iupdateEvent, variableName=ivariableName }
end

TomeWindow.trackedStats = {}

local function SetStatValue( statData )
    local value = L"?"
        
    -- Parse out each key 
    if( statData.variableName ) then
    
        --local varName = StringToWString(statData.variableName) 
        --DEBUG(L""..StringToWString(statData.windowName)..L" ->"..varName  )
        
        local stringText = statData.variableName 
        local tablekeys = {}
        
        local variable = _G
        while( stringText ~= L""  and variable) do
        
            local dotPos    = string.find(stringText, "[.]", 1)
            local bracketPos  = string.find(stringText, "[[]", 1)
            
            local key = nil
            if( dotPos and ( (bracketPos == nil) or (bracketPos > dotPos) ) )then
                key = string.sub(stringText, 1, dotPos-1 )
                stringText = string.sub(stringText, dotPos+1 )
            elseif( bracketPos and ( (dotPos == nil) or (dotPos > bracketPos) ) )then
                key = string.sub(stringText, 1, bracketPos-1 )
                
                local bracketEndPos  = string.find(stringText, "[]]", 1)
                stringText = string.sub(stringText, bracketEndPos+1 )
            else
                key = stringText
                stringText = L""
            end
            
            --if( key ) then
            --    DEBUG(L"    Key="..StringToWString(key) )
            --end
            
            variable = variable[ key ]               
        end
        
        if( variable ) then
            value = L""..variable
        end
    
    end         
       
   local text = GetString( statData.strIndex )
   TomeWindow.SetTOCItemText( statData.windowName, statData.id, text, value )    
end

function TomeWindow.AddTrackedStat( tomeStatData )                
   
    table.insert( TomeWindow.trackedStats, tomeStatData )
    tomeStatData.id = table.getn( TomeWindow.trackedStats )        
    

    ButtonSetDisabledFlag( tomeStatData.windowName.."Text", true )        
    WindowRegisterEventHandler( tomeStatData.windowName, tomeStatData.updateEvent, "TomeWindow.OnUpdateTrackedStat")       
    
    SetStatValue( tomeStatData )

end



function TomeWindow.OnUpdateTrackedStat()
   local id = WindowGetId( SystemData.ActiveWindow.name )
   local statData = TomeWindow.trackedStats[id]   
   SetStatValue( statData )
end