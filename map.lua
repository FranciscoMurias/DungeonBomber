local Object = require 'lib.classic.classic'
local sodapop = require "lib/sodapop"

local Vector = require 'vector'

local Map = Object:extend()

function Map:new()
  self.width = 17
  self.height = 11
	self.tilewidth = 15
	self.tileheight = 15
	self.tiles = {}
	self.tileset = love.graphics.newImage('res/tiles/tileset_dungeon.png')
	self.wall = love.graphics.newQuad(0, 0, 15, 15, self.tileset:getWidth(), self.tileset:getHeight())
	self.floor = love.graphics.newQuad(0, 15, 15, 15, self.tileset:getWidth(), self.tileset:getHeight())

	-- build map
	self:generateLayout()
end

function Map:numNeighbors(x, y)
	local num = 4
	if x == 1 or x == self.width then
		num = num - 1
	end
	if y == 1 or y == self.height then
		num = num - 1
	end
	return num
end

function Map:getNeighbors(x, y)
	local neighbors = {}
	if x ~= 1 then
		table.insert(neighbors, Vector(x - 1, y))
	end
	if y ~= 1 then
		table.insert(neighbors, Vector(x, y - 1))
	end
	if x ~= self.width then
		table.insert(neighbors, Vector(x + 1, y))
	end
	if y ~= self.height then
		table.insert(neighbors, Vector(x, y + 1))
	end
	return neighbors
end

function Map:adjacentToCorner(x, y)
	if (x == 1 or x == self.width) and (y == 2 or y == self.height - 1) then
		return true
	end
	if (y == 1 or y == self.height) and (x == 2 or x == self.width - 1) then
		return true
	end
	return false
end

function Map:generateLayout()
	for row = 1, self.height do
		self.tiles[row] = {}
		for col = 1, self.width do
			if row % 2 == 0 and col % 2 == 0 then
				self.tiles[row][col] = 1
			else
				self.tiles[row][col] = 0
			end
			if self:adjacentToCorner(col, row) or self:numNeighbors(col, row) == 2 then
				self.tiles[row][col] = -1
			end
		end
	end
end

function Map:toTile(x, y)
	x = math.floor(x / 15) * 15
	y = math.floor(y / 15) * 15
	return x, y
end

function Map:foreach(fn)
	for row = 1, self.height do
		for col = 1, self.width do
			fn(col, row, self.tiles[row][col])
		end
	end
end

function Map:update(dt)
end

function Map:draw()
	self:foreach(function(x, y, value)
		local x = x - 1
		local y = y - 1
		if value == 1 then
			love.graphics.draw(self.tileset, self.floor, x * 15, y * 15)
			love.graphics.draw(self.tileset, self.wall, x * 15, y * 15)
		else
			love.graphics.draw(self.tileset, self.floor, x * 15, y * 15)
		end
	end)
end

return Map
