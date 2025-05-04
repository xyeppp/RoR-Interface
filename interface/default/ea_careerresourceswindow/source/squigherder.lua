SquigHerderResource = PetWindow:Subclass ("PetWindow")

CareerResource:RegisterResource (GameData.CareerLine.SQUIG_HERDER, SquigHerderResource)

-- The "portrait" will set its background to one of these slices
local PetStateTextures =
{
    MAIN_TEXTURE            = "EA_Career_Sq_32b",
    BACKGROUND_FRAME_SLICE  = "PetStateFrame",
    
    [GameData.PetCommand.PASSIVE] = 
    {
        texSlice            = "PetState-Passive",
        w                   = 51, 
        h                   = 52,
        normalButtonSlice   = "PetState-Button-Passive",
        rolloverButtonSlice = "PetState-Button-Passive-ROLLOVER",
    },
    
    [GameData.PetCommand.DEFENSIVE] = 
    { 
        texSlice            = "PetState-Defensive",    
        w                   = 51, 
        h                   = 52,
        normalButtonSlice   = "PetState-Button-Defensive",
        rolloverButtonSlice = "PetState-Button-Defensive-ROLLOVER",
    },
    
    [GameData.PetCommand.AGGRESSIVE] = 
    { 
        texSlice            = "PetState-Aggressive",
        w                   = 51, 
        h                   = 52,
        normalButtonSlice   = "PetState-Button-Aggressive",
        rolloverButtonSlice = "PetState-Button-Aggressive-ROLLOVER",
    },
}

-- The pet's action bar will always have these commands available
local PetCommands =
{
    GameData.PetCommand.ATTACK,
    GameData.PetCommand.STAY,
    GameData.PetCommand.FOLLOW,
}

function SquigHerderResource:Create (windowName)
    local frame = self:ParentCreate (windowName, PetStateTextures, PetCommands)
    
    if (frame)
    then
        frame.m_Data = CareerResourceData:Create (GameData.CareerLine.SQUIG_HERDER)
        
        frame:UpdateResourceDisplay (0, 0)
    end
    
    return frame
end

function SquigHerderResource:UpdateResourceDisplay (previousResourceValue, currentResourceValue)

end
