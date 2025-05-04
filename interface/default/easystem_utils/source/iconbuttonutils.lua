----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

IconButtonUtils = {}

function IconButtonUtils.SetIconTextures( iconButtonName, iconId ) 

    local texture, x, y, disabledTexture = GetIconData( iconId )    
    
    -- Set the Normal Texture
    DynamicImageSetTexture( iconButtonName.."Icon", texture, x, y ) 
    
    -- Set the Disabled Texture 
    if( disabledTexture ~= L"" ) then
        DynamicImageSetTexture( iconButtonName.."DisabledIcon", disabledTexture, x, y ) 
    else    
        --(Fallback to a darktinted version of the colored image if no disabled Texture is specified.
        DynamicImageSetTexture( iconButtonName.."DisabledIcon", texture, x, y ) 
        WindowSetTintColor( iconButtonName.."DisabledIcon", 100, 100, 100 )
    end
    
end