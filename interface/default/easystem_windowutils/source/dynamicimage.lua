DynamicImage = Frame:Subclass ()

function DynamicImage:SetTextureSlice (sliceName, forceOverride)
    if ((sliceName ~= self.m_SliceName) or (forceOverride == Frame.FORCE_OVERRIDE))
    then
        DynamicImageSetTextureSlice (self:GetName (), sliceName)
        self.m_SliceName = sliceName
    end
end

function DynamicImage:SetTextureDimensions (textureWidth, textureHeight)
    DynamicImageSetTextureDimensions (self:GetName (), textureWidth, textureHeight)
end

function DynamicImage:SetTexture ( textureName, textureX, textureY )
    textureX = textureX or 0
    textureY = textureY or 0
    
    DynamicImageSetTexture ( self:GetName(), textureName, textureX, textureY )
end

function DynamicImage:SetExtents( maxY, minY, maxX, minX, width, height )
    self.extents =
    {
        maxY = maxY,
        minY = minY,
        maxX = maxX,
        minX = minX,
        width = width,
        height = height
    }
end

-- SetExtents needs be called before this function can be used.
-- Show the appropriate amount of the texture based on some fill percent from 0 to 1.0.
function DynamicImage:FillBasedOnPercent( fillPercent, textureName )
    if( fillPercent and textureName and self.extents )
    then
        local height        = math.floor ( (fillPercent * self.extents.height) + 0.5 )
        local texY          = self.extents.maxY - height
        
        self:SetDimensions( self.extents.width, height )
        self:SetTextureDimensions( self.extents.width, height )
        self:SetTexture( textureName, self.extents.minX, texY )
    end
end