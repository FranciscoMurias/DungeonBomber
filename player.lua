local Object = require 'lib.classic.classic'

local Vector = require 'vector'

local Player = Object:extend()

function Player:new(x, y)
  self.position = Vector(x, y)
  self.width = 11
  self.height = 11
  self.origin = Vector(2, 5)
  self.direction = Vector(0, 1)
  self.speed = 50
  self.image = love.graphics.newImage('res/sprites/player.png')
end

function Player:update(dt)
	local velocity = Vector(0, 0)
	if love.keyboard.isDown('right') then
	  velocity.x = self.speed * dt
	elseif love.keyboard.isDown('left') then
	  velocity.x = -self.speed * dt
	end
	if love.keyboard.isDown('down') then
	  velocity.y = self.speed * dt
	elseif love.keyboard.isDown('up') then
	  velocity.y = -self.speed * dt
	end

	if velocity ~= Vector(0, 0) then
    local newPosition = self.position + velocity
	  local actualX, actualY, cols, cols_len = world:move(self, newPosition.x, newPosition.y)
    self.position = Vector(actualX, actualY)
    print(self.position.x)
	end
end

function Player:draw()
  love.graphics.draw(self.image, self.position.x, self.position.y, 0, 1, 1, self.origin.x, self.origin.y)
end

return Player
