local Object = require 'lib.classic.classic'
local sodapop = require "lib/sodapop"
local Vector = require 'vector'

local PowerUp = Object:extend()

function PowerUp:new(x, y, variant)
  self.position = Vector(x, y)
  self.width = 15
  self.height = 15
  self.origin = Vector(0, -2)
  self.variant = variant
  self.sprite = sodapop.newAnimatedSprite(self:center():unpack())
  self.burned = false

  self.sprite:addAnimation('intact', {
		image        = love.graphics.newImage 'res/sprites/powerUps.png',
		frameWidth  = 15,
		frameHeight = 16,
		frames       = {
			{variant, 1, variant, 1, .3},
		},
	})
	self.sprite:addAnimation('burned', {
		image       = love.graphics.newImage 'res/sprites/powerUps.png',
		frameWidth  = 15,
		frameHeight = 16,
		frames      = {
			{2, variant, 5, variant, .1},
		},
	})
end

function PowerUp:center()
	return self.position + Vector(self.width / 2, self.height / 2)
end

function PowerUp:update(dt)
	if self.burned then

		return
	end
	self.sprite:update(dt)
end

function PowerUp:draw()
	if self.burned then
		return
	end
	self.sprite:draw(self.origin.x, self.origin.y)
end

return PowerUp
