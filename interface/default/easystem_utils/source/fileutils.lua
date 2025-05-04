
FileUtils = {}


function FileUtils.GetFullPathString( path )

    local widePath = StringToWString( path )
    return WStringToString( FileUtils.GetFullPathWideString( widePath ) )

end


function FileUtils.GetFullPathWideString( path )

    local colonPos = wstring.find( path, L":" )
    local doubleSlashPos = wstring.find( path, L"\\\\" )

    -- If the path does not have a colon or begin with double slashes, 
    -- it is a relative path, so we need to pre-pend the working cirectory
    if( colonPos == nil or doubleSlashPos == 1)
    then

        local gamePath = SystemData.Directories.GameWorkingDirectory
        path = gamePath..L"\\"..path    

    end    

    -- Ensure the path is formated with backslashes
    path = wstring.gsub( path, L"/", L"\\" )

    return path

end