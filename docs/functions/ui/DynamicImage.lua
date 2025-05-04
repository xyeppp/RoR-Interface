--- Sets the texture displayed on this image.
--- @param dynamicImageName string The name of the DynamicImage.
--- @param texture string The name of the Ui Texture to display.
--- @param x number The x offset of the texture coordinate.
--- @param y number The y offset of the texture coordinate.
function DynamicImageSetTexture(dynamicImageName, texture, x, y) end

--- Sets the textureScale value.
--- @param dynamicImageName string The name of the DynamicImage.
--- @param textureScale number The scale value to use on the image’s texture.  (1.0 = 100%)
function DynamicImageSetTextureScale(dynamicImageName, textureScale) end

--- Sets the explicit texture coordinates to be used for this image.
--- @param dynamicImageName string The name of the DynamicImage.
--- @param x number The x texture size.
--- @param y number The y texture size.
function DynamicImageSetTextureDimensions(dynamicImageName, x, y) end

--- Sets the texture’s mirrored orientation for this dynamic image.
--- @param dynamicImageName string The name of the DynamicImage.
--- @param mirrored boolean True/False if the texture should be mirrored.
function DynamicImageSetTextureOrientation(dynamicImageName, mirrored) end

--- Sets the slice to be displayed in this DynamicImage.
--- @param dynamicImageName string The name of the DynamicImage.
--- @param sliceName string Name (or id) of the slice to use.
function DynamicImageSetTextureSlice(dynamicImageName, sliceName) end

--- Rotates the image arround it’s center.
--- @param dynamicImageName string The name of the DynamicImage.
--- @param rotation number The rotation angle (Degees, 0-360).
function DynamicImageSetRotation(dynamicImageName, rotation) end

--- Returns if the image is currently displaying a valid texture.
--- @param dynamicImageName string The name of the DynamicImage.
--- @return hasTexture boolean Is the image currently displaying a texture?
function DynamicImageHasTexture(dynamicImageName) end

DynamicImage = DynamicImage or {}
