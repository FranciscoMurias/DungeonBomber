local Object = require 'lib.classic.classic'
local sodapop = require "lib/sodapop"

local Vector = require 'vector'

local softObject = Object:extend()

function softObject:new(x, y, variant)
  self.position = Vector(x, y)
  self.width = 15
  self.height = 17
  self.origin = Vector(0, -2)
  self.state = 1
  self.variant = variant
  self.softObjectSprite = sodapop.newAnimatedSprite(self:center():unpack())

    self.softObjectSprite:addAnimation('intact', {
		image        = love.graphics.newImage 'res/tiles/softObjects.png',
		frameWidth  = 15,
		frameHeight = 17,
		frames       = {
			{1, variant, 1, variant, .3},
		},
	})
	self.softObjectSprite:addAnimation('destroyed', {
		image       = love.graphics.newImage 'res/tiles/softObjects.png',
		frameWidth  = 15,
		frameHeight = 17,
		frames      = {
			{2, variant, 5, variant, .1},
		},
	})
end

function softObject:center()
	return self.position + Vector(self.width / 2, self.height / 2)
end

function softObject:update(dt)
	self.softObjectSprite:update(dt)
end

function softObject:draw()
	self.softObjectSprite:draw(self.origin.x, self.origin.y)
end

return softObject
