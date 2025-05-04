EA_Window_InternalBuffs = {}

function EA_Window_InternalBuffs.Initialize()
    WindowRegisterEventHandler ("EA_Window_InternalBuffs", SystemData.Events.PLAYER_INTERNAL_BUFF_UPDATED, "EA_Window_InternalBuffs.Update" )
    EA_Window_InternalBuffs.Update()
end

function EA_Window_InternalBuffs.Update()

    local texture, x, y
    local iconWindowName = "EA_Window_InternalBuffsIcon1"
    local numIconsShowing = 0
    if (GameData.DormantFlags.non) then
        texture, x, y = GetIconData (-100)
        DynamicImageSetTexture (iconWindowName.."IconBase", texture, x, y)
        WindowSetShowing( iconWindowName, true)   
        numIconsShowing = 1
        iconWindowName = "EA_Window_InternalBuffsIcon"..(numIconsShowing+1)   
    end
    
    if (GameData.DormantFlags.nok) then
        texture, x, y = GetIconData (-101)
        DynamicImageSetTexture (iconWindowName.."IconBase", texture, x, y)
        WindowSetShowing( iconWindowName, true)      
        numIconsShowing = numIconsShowing + 1
        iconWindowName = "EA_Window_InternalBuffsIcon"..(numIconsShowing+1)
    end
    
    if (GameData.DormantFlags.inv) then
        texture, x, y = GetIconData (-102)
        DynamicImageSetTexture (iconWindowName.."IconBase", texture, x, y)
        WindowSetShowing( iconWindowName, true)      
        numIconsShowing = numIconsShowing + 1
    end
    
    for index = numIconsShowing + 1, 3 do
        WindowSetShowing( "EA_Window_InternalBuffsIcon"..index, false )
    end
end