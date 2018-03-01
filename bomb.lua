local Object = require 'lib.classic.classic'
local sodapop = require "lib/sodapop"
local screen = require "lib/shack/shack"
local Vector = require 'vector'
local SoftObject = require 'softObject'

local Bomb = Object:extend()

function Bomb:new(x, y)
  self.position = Vector(x, y)
  self.width = 15
  self.height = 15
  self.origin = Vector(0, -2)

	self.fuseDuration = 2.3
	self.explosionDuration = self.fuseDuration + 0.6
	self.timer = 0
	self.exploded = false
	self.radius = 10
	
	self.numExplosions = 0
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

	self.explosionSprite = sodapop.newAnimatedSprite(self:center():unpack())
	self.explosionSprite:addAnimation('explode1', {
		image	= love.graphics.newImage('res/sprites/explosion1.png'),
		frameWidth = 47,
		frameHeight = 39,
		frames = {
			{1, 1, 16, 1, .04},
		},
		stopAtEnd    = true
	})
end

function Bomb:center()
	return self.position + Vector(self.width / 2, self.height / 2)
end

function Bomb:update(dt)
	if self.exploded then
		self.explosionSprite:update(dt)
		return
	end
	if self.timer > self.fuseDuration then
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
					local hit = self:check(tile.x, tile.y)
					if hit then
						directions[direction] = false
					else
						table.insert(self.explosions, {
								x = tile.x,
								y = tile.y,
								width = 15,
								height = 15,
							})
						self.numExplosions = self.numExplosions + 1
					end
				end
			end
		end
		self.exploded = true
		if self.timer < self.explosionDuration then
			screen:setShake(10)
		end
		--if self.timer > self.explosionDuration then
			--for i=0, self.numExplosions do
			--	table.remove(self.explosions, i) -- something's not right here
			--end
		--end
	end

	self.sprite:update(dt)
	self.timer = self.timer + dt
end

function Bomb:draw()
	if self.exploded == false then self.sprite:draw(self.origin.x, self.origin.y)
	else 
		for _, exp in ipairs(self.explosions) do
			self.explosionSprite:draw(math.random(0,3),math.random(0,3)) -- add subsequent explosions here.. later with a time delay
				-- love.graphics.rectangle('line', exp.x, exp.y, exp.width, exp.height)
		end
		self.explosionSprite:draw(math.random(0,3),math.random(0,3))
			-- love.graphics.setColor(255, 0, 0, 255)
			-- love.graphics.rectangle('line', self.position.x, self.position.y, self.width, self.height)
			-- love.graphics.setColor(255, 255, 255, 255)
	end
end

function Bomb:check(x, y)
	local hit = false
	local items, _ = world:queryRect(x, y, self.width, self.height)
	for _, item in ipairs(items) do
		if not item.is then
			hit = true
		elseif item:is(SoftObject) then
			item.destroyed = true
			item:SpawnPowerUp()
			item:DebrisDestruction()
			world:remove(item)
			hit = true
		end
	end
	return hitWall
end

return Bomb
