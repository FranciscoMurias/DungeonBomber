local Object = require 'lib.classic.classic'

local Vector = Object:extend()

function Vector:new(x, y)
  self.x = x or 0
  self.y = y or 0
end

-- t must be a value between 0 and 1
function Vector:lerp(v, t)
  return self + (v - self) * t
end

-- find the length of a vector
function Vector:length()
  return math.sqrt(math.pow(self.x, 2) + math.pow(self.y, 2))
end

function Vector:unpack()
  return self.x, self.y
end

-- add two vectors: Vector(1, 2) + Vector(3, 4)
function Vector:__add(v)
  return Vector(self.x + v.x, self.y + v.y)
end

-- subtract one vector from another: Vector(3, 4) - Vector(1, 2)
function Vector:__sub(v)
  return Vector(self.x - v.x, self.y - v.y)
end

-- multiply a vector by a scalar value
function Vector:__mult(s)
  return Vector(self.x * s, self.y * s)
end

-- check if two vectors are equal
function Vector:__eq(v)
  return self.x == v.x and self.y == v.y
end

return Vector
