local Object = require 'lib.classic.classic'
local anim8 = require 'lib.anim8'

local Vector = require 'vector'

local Player = Object:extend()

function Player:new(x, y)
  self.position = Vector(x, y)
  self.width = 11
  self.height = 11
  self.origin = Vector(2, 6)
  self.direction = Vector(0, 1)
	self.speed = 50
	self.sprite = love.graphics.newImage('res/sprites/player_sprites.png')
	self.grid = anim8.newGrid(15, 19, self.sprite:getWidth(), self.sprite:getHeight())
	self.animations = {
		walkUp = anim8.newAnimation(self.grid('1-3', 1), 0.1),
		walkDown = anim8.newAnimation(self.grid('1-3', 2), 0.1),
		walkRight = anim8.newAnimation(self.grid('1-3', 3), 0.1),
		walkLeft = anim8.newAnimation(self.grid('1-3', 3), 0.1):flipH(),
		idleUp = anim8.newAnimation(self.grid(1, 1), 0.1),
		idleDown = anim8.newAnimation(self.grid(1, 2), 0.1),
		idleRight = anim8.newAnimation(self.grid(1, 3), 0.1),
		idleLeft = anim8.newAnimation(self.grid(1, 3), 0.1):flipH(),
	}

	function updateAnimation(vector)
		if vector == Vector(-1, 0) then self.animation = 'walkLeft' end
		if vector == Vector(1, 0) then self.animation = 'walkRight' end
		if vector == Vector(0, 1) then self.animation = 'walkDown' end
		if vector == Vector(0, -1) then self.animation = 'walkUp' end
	end

	function updateIdle(vector)
		if vector == Vector(-1, 0) then self.animation = 'idleLeft' end
		if vector == Vector(1, 0) then self.animation = 'idleRight' end
		if vector == Vector(0, 1) then self.animation = 'idleDown' end
		if vector == Vector(0, -1) then self.animation = 'idleUp' end
	end

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

		-- animation control
		local normalized = velocity:normalize()
		if normalized ~= self.direction then
			self.direction = velocity:normalize()
			updateAnimation(self.direction)
		end
	else
		updateIdle(self.direction)
	end

	self.animations[self.animation]:update(dt)
end

function Player:draw()
	self.animations[self.animation]:draw(
		self.sprite, self.position.x, self.position.y, 0, 1, 1, self.origin.x, self.origin.y
	)
end

return Player
