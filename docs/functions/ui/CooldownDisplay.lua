--- Alters the state of the cooldown animation.  This either begins a new cooldown, adjusts a cooldown in progress, or stops a cooldown.
--- @param cooldownDisplayName string The window name of the CooldownDisplay.
--- @param currentCooldownValue number What the timer is currently set to.
--- @param maximumCooldownValue number What the maximum timer of the cooldown is.
function CooldownDisplaySetCooldown(cooldownDisplayName, currentCooldownValue, maximumCooldownValue) end

CooldownDisplay = CooldownDisplay or {}
