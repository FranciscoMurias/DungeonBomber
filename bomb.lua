local Object = require 'lib.classic.classic'
local sodapop = require "lib/sodapop"

local Vector = require 'vector'

local Bomb = Object:extend()

function Bomb:new(x, y)
  self.position = Vector(x, y)
  self.width = 15
  self.height = 15
  self.origin = Vector(5, 2)

	self.sprite = sodapop.newAnimatedSprite(x, y)
	self.sprite:addAnimation('idle', {
		image	= love.graphics.newImage('res/tiles/items.png'),
		frameWidth = 15,
		frameHeight = 17,
		frames = {
			{7, 1, 7, 1, .3},
		},
	})
end

function Bomb:update(dt)
	self.sprite:update(dt)
end

function Bomb:draw()
	self.sprite:draw()
end

return Bomb
