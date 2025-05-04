Queue = {}
Queue.__index = Queue

function Queue:Create ()
    local newContainer = setmetatable( { first = 0, last = -1 }, Queue )
    newContainer.__index = self
    return newContainer
end

function Queue:IsEmpty()
    return self.first > self.last
end

function Queue:Clear()
     self.first = 0
     self.last = -1
end

function Queue:PushBack( val )
    if( val ~= nil )
    then
        self.last = self.last + 1
        self[ self.last ] = val
    end
end

function Queue:PushFront( val )
    if( val ~= nil )
    then
        self.first = self.first - 1
        self[ self.first ] = val
    end
end

-- This should be a private function :(
local function PopAt( queue, index )
    if( queue:IsEmpty() )
    then
        return nil
    end
    
    local val = queue[ index ]
    queue[ index ] = nil
    return val
end

function Queue:PopBack()
    local val = PopAt( self, self.last )
    
    if( val ~= nil )
    then
        self.last = self.last - 1
        if( self:IsEmpty() )
        then
            self:Clear()
        end
    end
    
    return val
end

function Queue:PopFront()
    local val = PopAt( self, self.first )
    
    if( val ~= nil )
    then
        self.first = self.first + 1
        if( self:IsEmpty() )
        then
            self:Clear()
        end
    end
    
    return val
end

function Queue:Back()
    return self[self.last]
end

function Queue:Front()
    return self[self.first]
end

function Queue:Begin()
    return self.first
end

function Queue:End()
    return self.last
end