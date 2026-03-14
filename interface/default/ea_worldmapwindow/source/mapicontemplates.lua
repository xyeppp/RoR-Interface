
----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

-- This is the lookup table used to get the zone numbers for a specific pairing
-- The table is set up like this PairingMapTierZones[pairing][tier][1..n]
-- The zones are ordered from destruction to order for tier 4
EA_Window_WorldMap.PairingMapTierZones =
{
    [GameData.Pairing.GREENSKIN_DWARVES]     = { [1] = {6, 11},    [2] = {7, 1},     [3] = {8, 2},     [4] = {3, 5, 27, 26, 9} },
    [GameData.Pairing.EMPIRE_CHAOS]          = { [1] = {100, 106}, [2] = {101, 107}, [3] = {102, 108}, [4] = {103, 105, 120, 109} },
    [GameData.Pairing.ELVES_DARKELVES]       = { [1] = {200, 206}, [2] = {201, 207}, [3] = {202, 208}, [4] = {203, 205, 220, 209} }
}

EA_Window_WorldMap.ORDER_FORT_INDEX = 5
EA_Window_WorldMap.DESTRUCTION_FORT_INDEX = 1

-- The second value in this table is the zone which the wings are attached to
EA_Window_WorldMap.PairingMapWingZones =
{
    [26]  = 5,
    [27]  = 5,
    [120] = 105,
    [220] = 205
}

EA_Window_WorldMap.PairingMapFortZones =
{
    [4]     = 1,
    [10]    = 1,
    [104]   = 2,
    [110]   = 2,
    [204]   = 3,
    [210]   = 3,
}

EA_Window_WorldMap.PairingMapCityZones =
{
    [61]    = 1,
    [62]    = 1,
    [161]   = 2,
    [162]   = 2,
}
