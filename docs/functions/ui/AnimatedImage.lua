--- Sets the texture displayed on this image.
--- @param animatedImageName string The name of the AnimatedImage.
--- @param texture string The name of the ui Texture to display.
function AnimatedImageSetTexture(animatedImageName, texture) end

--- Starts playing this animation according to the parameters.
--- @param animatedImageName string The name of the AnimatedImage.
--- @param startFrame number The id number of the frame to begin with.
--- @param loop boolean Should the animation loop?
--- @param hideWhenDone boolean Should the animation automatically hide when it finishes (Not to be used when looping)?
--- @param delay number How long to wait before starting the animation.
function AnimatedImageStartAnimation(animatedImageName, startFrame, loop, hideWhenDone, delay) end

--- Stops an active animation.
--- @param animatedImageName string The name of the AnimatedImage.
function AnimatedImageStopAnimation(animatedImageName) end

--- Sets the speed (fps) at which to play the animation.
--- @param animatedImageName string The name of the AnimatedImage.
--- @param fpsSpeed string The play speed in frames per second.
function AnimatedImageSetPlaySpeed(animatedImageName, fpsSpeed) end

AnimatedImage = AnimatedImage or {}
