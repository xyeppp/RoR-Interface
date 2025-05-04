ActionBarConstants = 
{
    BUTTONS                     = 12,
    COLUMNS                     = 12,
    SHOW_BACKGROUND             = true,
    HIDE_BACKGROUND             = false,
    SHOW_PAGE_SELECTOR_LEFT     = 42,
    SHOW_PAGE_SELECTOR_RIGHT    = 43,
    HIDE_PAGE_SELECTOR          = 44,
    HIDE_EMPTY_SLOTS            = 45,
    SHOW_EMPTY_SLOTS            = 46,
    SHOW_DECORATIVE_CAPS        = true,
    HIDE_DECORATIVE_CAPS        = false,
}

function ActionBarConstants:BarAndButtonFromSlot (slot)
    assert (slot)
    
    local page      = math.modf (slot / self.BUTTONS)
    local button    = math.fmod (slot, self.BUTTONS)
    
    if (button == 0)
    then
        button = self.BUTTONS
    else
        -- Because bars are tracked internally starting at 1, not 0.
        -- and there is no remainder, this needs to stay at the result
        -- returned from math.modf
        page = page + 1
    end
    
    return page, button
end