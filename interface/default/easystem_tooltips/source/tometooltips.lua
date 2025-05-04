
local GLYPH_TOOLTIP_BASE_HEIGHT = 32
local GLYPH_TOOLTIP_NUM_ITEMS = 10
local GLYPH_TOOLTIP_BASE_WIDTH = 64

-- Glyph Tooltip
function Tooltips.CreateGlyphTooltip( glyph, anchor )

    if( glyph == nil ) then    
        -- Clear the tooltip
        Tooltips.ClearTooltip()
        return
    end
    
    local largestTextWidth = 0
    local height = GLYPH_TOOLTIP_BASE_HEIGHT
    
    local windowName = "GlyphTooltip"
    
    local function SetLabelAndUpdateDimensionVars( labelName, text, offset )
        LabelSetText( labelName, text )
        local x, y = LabelGetTextDimensions( labelName )
        if( x > largestTextWidth )
        then
            largestTextWidth = x
        end
        
        height = height + y + offset
    end
    
    SetLabelAndUpdateDimensionVars( windowName.."Name", glyph.name, 5 )
    SetLabelAndUpdateDimensionVars( windowName.."Text", glyph.tooltipText, 5 )
    
    DynamicImageSetTexture( windowName.."Icon", glyph.textureName, 64, 64 )
    
    for index = 1, GLYPH_TOOLTIP_NUM_ITEMS
    do
        local tooltipItem = glyph.tooltipItems[index]
        
        if( tooltipItem )
        then
            SetLabelAndUpdateDimensionVars( windowName.."Info"..index, tooltipItem, 15 )
        end
        
        WindowSetShowing( windowName.."Info"..index, tooltipItem ~= nil )
    end
    
    -- Update the Window Size
    local width, y = WindowGetDimensions( windowName )
    if( y ~= height or width ~= largestTextWidth + GLYPH_TOOLTIP_BASE_WIDTH) then
        WindowSetDimensions( windowName, largestTextWidth + GLYPH_TOOLTIP_BASE_WIDTH, height )
    end   

    Tooltips.CreateCustomTooltip( SystemData.MouseOverWindow.name, windowName )
    Tooltips.AnchorTooltip( anchor )
        
end