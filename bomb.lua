local Object = require 'lib.classic.classic'
local sodapop = require "lib/sodapop"

local Vector = require 'vector'
local SoftObject = require 'softObject'

local Bomb = Object:extend()

function Bomb:new(x, y)
  self.position = Vector(x, y)
  self.width = 15
  self.height = 15
  self.origin = Vector(5, 2)

	self.duration = 2
	self.timer = 0
	self.exploded = false
	self.radius = 2

	self.explosions = {}

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
	if self.exploded then
		return
	end
	if self.timer > self.duration then
		self:check(self.position.x, self.position.y)
		local directions = {
			[Vector(0, 1)] = true,
			[Vector(0, -1)] = true,
			[Vector(1, 0)] = true,
			[Vector(-1, 0)] = true
		}
		for i = 1, self.radius do
			for direction, spreading in pairs(directions) do
				if spreading then
					local tile = self.position + (direction * i * 15)
					local hitWall = self:check(tile.x, tile.y)
					if hitWall then
						directions[direction] = false
					else
						table.insert(self.explosions, {
								x = tile.x,
								y = tile.y,
								width = 15,
								height = 15,
							})
					end
				end
			end
		end
		self.exploded = true
	end

	self.sprite:update(dt)
	self.timer = self.timer + dt
end

function Bomb:draw()
	self.sprite:draw()
	for _, exp in ipairs(self.explosions) do
		love.graphics.rectangle('fill', exp.x, exp.y, exp.width, exp.height)
	end
	love.graphics.setColor(255, 0, 0, 255)
	love.graphics.rectangle('line', self.position.x, self.position.y, self.width, self.height)
	love.graphics.setColor(255, 255, 255, 255)
end

function Bomb:check(x, y)
	local hitWall = false
	local items, _ = world:queryRect(x, y, self.width, self.height)
	for _, item in ipairs(items) do
		if not item.is then
			hitWall = true
		elseif item:is(SoftObject) then
			item.destroyed = true
		end
	end
	return hitWall
end

return Bomb
