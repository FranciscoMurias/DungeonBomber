local Object = require 'lib.classic.classic'
local sodapop = require "lib/sodapop"

local Vector = require 'vector'

local Bomb = Object:extend()

function Bomb:new(x, y)
  self.position = Vector(x, y)
  self.width = 15
  self.height = 15
  self.origin = Vector(5, 2)

	self.sprite = sodapop.newAnimatedSprite(self:center():unpack())
	self.sprite:addAnimation('idle', {
		image	= love.graphics.newImage('res/sprites/bomb.png'),
		frameWidth = 15,
		frameHeight = 15,
		frames = {
			{1, 1, 4, 1, .2},
		},
	})
end

function Bomb:center()
	return self.position + Vector(self.width / 2, self.height / 2)
end

function Bomb:update(dt)
	self.sprite:update(dt)
end

function Bomb:draw()
	self.sprite:draw()
end

return Bomb
