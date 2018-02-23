local sodapop = require "lib/sodapop"
local Object = require 'lib.classic.classic'

local Vector = require 'vector'

local Player = Object:extend()

function Player:new(x, y)
  self.position = Vector(x, y)
  self.width = 11
  self.height = 11
  self.origin = Vector(5, 2)
  self.direction = Vector(0, 1)
	self.speed = 50
	self.playerSprite = sodapop.newAnimatedSprite(x, y)

	self.playerSprite:addAnimation('idleSide', {
		image        = love.graphics.newImage 'res/sprites/player_sprites.png',
		frameWidth  = 15,
		frameHeight = 19,
		frames       = {
			{1, 3, 1, 3, .3},
		},
	})
	self.playerSprite:addAnimation('idleUp', {
		image       = love.graphics.newImage 'res/sprites/player_sprites.png',
		frameWidth  = 15,
		frameHeight = 19,
		frames      = {
			{1, 1, 1, 1, .1},
		},
	})
	self.playerSprite:addAnimation('idleDown', {
		image        = love.graphics.newImage 'res/sprites/player_sprites.png',
		frameWidth  = 15,
		frameHeight = 19,
		frames      = {
			{1, 2, 1, 2, .1},
		},
	})
	self.playerSprite:addAnimation('walkSide', {
		image        = love.graphics.newImage 'res/sprites/player_sprites.png',
		frameWidth  = 15,
		frameHeight = 19,
		frames       = {
			{1, 3, 3, 3, .1},
		},
	})
	self.playerSprite:addAnimation('walkUp', {
		image       = love.graphics.newImage 'res/sprites/player_sprites.png',
		frameWidth  = 15,
		frameHeight = 19,
		frames      = {
			{1, 1, 3, 1, .1},
		},
	})
	self.playerSprite:addAnimation('walkDown', {
		image        = love.graphics.newImage 'res/sprites/player_sprites.png',
		frameWidth  = 15,
		frameHeight = 19,
		frames      = {
			{1, 2, 3, 2, .1},
		},
	})

	self.playerSprite:setAnchor(function()
		return self.position.x, self.position.y
	end)

	function updateAnimation(vector)
		if vector == Vector(-1, 0) then self.playerSprite:switch 'walkSide'
			self.playerSprite.flipX = true end
		if vector == Vector(1, 0) then self.playerSprite:switch 'walkSide'
			self.playerSprite.flipX = false end
		if vector == Vector(0, 1) then self.playerSprite:switch 'walkDown' end
		if vector == Vector(0, -1) then self.playerSprite:switch 'walkUp' end
	end

	function updateIdle(vector)
		if vector == Vector(-1, 0) then self.playerSprite:switch 'idleSide'
			self.playerSprite.flipX = true end
		if vector == Vector(1, 0) then self.playerSprite:switch 'idleSide'
			self.playerSprite.flipX = false end
		if vector == Vector(0, 1) then self.playerSprite:switch 'idleDown' end
		if vector == Vector(0, -1) then self.playerSprite:switch 'idleUp' end
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

	self.playerSprite:update(dt)
end

function Player:draw()
	self.playerSprite:draw(self.origin.x, self.origin.y)
end

return Player
