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
	self.explosionTimer = 0
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
	-- world:add(bomb, x, y, 15, 15) -- need to check if player is present on tile and only call after that is false and remove colider once exploded
	if self.exploded then
		for _, explosionSprite in ipairs(self.explosions) do
			explosionSprite:update(dt)
			if not explosionSprite.playing and self.explosionTimer > explosionSprite.delay then
				explosionSprite.playing = true
			end
		end
		self.explosionTimer = self.explosionTimer + dt
		return
	end
	if self.timer > self.fuseDuration then
		self:check(self.position.x, self.position.y)
		self:addExplosion(self.position.x + 7, self.position.y + 7, 0)
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
						if hit == 2 then
							self:addExplosion(tile.x + 7, tile.y + 7, i / 20)
						end
					else
						self:addExplosion(tile.x + 7, tile.y + 7, i / 20)
					end
				end
			end
		end
		self.exploded = true
		if self.timer < self.explosionDuration then
			screen:setShake(10)
		end
	end

	self.sprite:update(dt)
	self.timer = self.timer + dt
end

function Bomb:draw()
	if self.exploded == false then
		self.sprite:draw(self.origin.x, self.origin.y)
	else 
		for _, explosionSprite in ipairs(self.explosions) do
			if explosionSprite.playing then
				explosionSprite:draw()
			end
		end
	end
end

function Bomb:check(x, y)
	local hit = nil
	local items, _ = world:queryRect(x, y, self.width, self.height)
	for _, item in ipairs(items) do
		if not item.is then
			hit = 1
		elseif item:is(SoftObject) then
			item.destroyed = true
			item:SpawnPowerUp()
			item:DebrisDestruction()
			world:remove(item)
			hit = 2
		end
	end
	return hit
end

function Bomb:addExplosion(x, y, delay)
	local explosionSprite = sodapop.newAnimatedSprite(
			x + math.random(-3, 3),
			y + math.random(-3, 3)
		)
	explosionSprite:addAnimation('explode1', {
		image	= love.graphics.newImage('res/sprites/explosion1.png'),
		frameWidth = 47,
		frameHeight = 39,
		frames = {
			{1, 1, 16, 1, .04},
		},
		stopAtEnd    = true
	})
	playing = math.random(0, 1)
	explosionSprite.delay = delay
	explosionSprite.playing = false
	table.insert(self.explosions, explosionSprite)
end

return Bomb
