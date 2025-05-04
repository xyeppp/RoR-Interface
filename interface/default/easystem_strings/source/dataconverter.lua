local convertToWideString =
{
    ["number"]  = function (v) return L""..v end,
    ["string"]  = function (v) return towstring (v) end,
    ["wstring"] = function (v) return v end,
}

function WideStringFromData (data)
   local fn = convertToWideString[type (data)]
    
    if (fn ~= nil)
    then
        return fn (data)
    end
    
    return (L"")
end