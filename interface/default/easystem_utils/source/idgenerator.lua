--[[
    IdGenerator.lua

    One of several small utility files specifically for dealing with window infrastructures.

    The whole purpose of this file is to allow generation of a series of sequential id's for
    use in whatever application the caller sees fit.  As more modules begin to use this file
    there is no guarantee that the id's your objects used to get will remain consistent, it's
    first come, first serve.

    However, this simply provides a way to get id's that are more or less unique within the system
    and certainly should be unique to the windows that actually make use of the generator.
--]]

EA_IdGenerator = 
{
    m_CurrentId = 0,
}

function EA_IdGenerator:GetNewId ()
    self = self or EA_IdGenerator

    self.m_CurrentId = self.m_CurrentId + 1

    return self.m_CurrentId
end
