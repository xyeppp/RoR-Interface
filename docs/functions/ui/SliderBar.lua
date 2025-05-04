--- Sets if slider is disabled.
--- @param sliderName string The name of the slider.
--- @param isDisabled boolean Should the slider be disabled?
function SliderBarSetDisabledFlag(sliderName, isDisabled) end

--- Returns if the slider is currently set to disabled.
--- @param sliderName string The name of the slider.
--- @return isDisabled boolean Is the slider currently disabled?
function SliderBarGetDisabledFlag(sliderName) end

--- Sets the current position for the slider bar,
--- @param sliderBarName string The name of the SliderBar.
--- @param position number The desired position, a value between 0.0 (all the way to the left) and 1.0 (all the way to the right).
function SliderBarSetCurrentPosition(sliderBarName, position) end

--- Returns the current position for the slider bar,
--- @param sliderBarName string The name of the SliderBar.
--- @return position number The current position, a value between 0.0 (all the way to the left) and 1.0 (all the way to the right).
function SliderBarGetCurrentPosition(sliderBarName) end

SliderBar = SliderBar or {}

--- Called when the bar’s position changes.
--- @param curPos number The current slide position.
SliderBar.OnSlide = function(sliderBarName, curPos) end
