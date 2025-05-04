--- Sets the texture displayed on this image.
--- @param circleImageName string The name of the CircleImage.
--- @param texture string The name of the Ui Texture to display.
--- @param x number The x coordinate within the texture.
--- @param y number The y coordinate within the texture.
function CircleImageSetTexture(circleImageName, texture, x, y) end

--- Sets the fill parameters for the circle image.
--- @param circleImageName string The name of the CircleImage.
--- @param startAngle number The angle at which to begin the circle’s circumference.  (Degrees, 0-360 )
--- @param fillAngle number The angle to fill arround the circle.  (Degrees, 0-360 )
function CircleImageSetFillParams(circleImageName, startAngle, fillAngle) end

--- Sets the textureScale value.
--- @param circleImageName string The name of the CircleImage.
--- @param textureScale number The scale value to use on the image’s texture.  (1.0 = 100%)
function CircleImageSetTextureScale(circleImageName, textureScale) end

--- Sets the texture slice displayed on this image.
--- @param circleImageName string The name of the CircleImage.
--- @param sliceName string The name of the <Slice> to display in the CircleImage.
function CircleImageSetTextureSlice(circleImageName, sliceName) end

--- Rotates the image around it’s center.
--- @param circleImageName string The name of the CircleImage.
--- @param rotation number The rotation angle (Degrees, 0-360).
function CircleImageSetRotation(circleImageName, rotation) end

CircleImage = CircleImage or {}
