local Object = require 'lib.classic.classic'
local sodapop = require "lib/sodapop"

local Vector = require 'vector'

local Map = Object:extend()

floorTiles = {}

function Map:new()
  self.width = 19
  self.height = 13
	self.tilewidth = 15
	self.tileheight = 15
	self.background = love.graphics.newImage 'res/tiles/BGArena1.png'
	self.tiles = {}
	self.tileset = love.graphics.newImage('res/tiles/tileset_dungeon.png')
	self.wall = love.graphics.newQuad(15, 0, 15, 17, self.tileset:getWidth(), self.tileset:getHeight())
	self.floors = {
		love.graphics.newQuad(0, 0, 15, 15, self.tileset:getWidth(), self.tileset:getHeight()),
		love.graphics.newQuad(0, 15, 15, 15, self.tileset:getWidth(), self.tileset:getHeight()),
		love.graphics.newQuad(0, 30, 15, 15, self.tileset:getWidth(), self.tileset:getHeight()),
		love.graphics.newQuad(0, 45, 15, 15, self.tileset:getWidth(), self.tileset:getHeight()),
	}

	-- build layout, walls, spawn locations
	self:generateLayout()

	-- make random floor pattern
	self:generateFloorTiles()

	self.floor = love.graphics.newCanvas(self.width * 15, self.height * 14)
	-- prerender floor
	love.graphics.setCanvas(self.floor)
	self:foreach(function(x, y, value)
		local x = x - 1
		local y = y - 1
		love.graphics.draw(self.tileset, self.floors[self:getFloorTiles(x,y)], x * 15, y * 15)
	end)
	love.graphics.setCanvas()
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

function Map:isSpawnLocation(x, y)
	if (x == 2 or x == self.width - 1) and (y == 2 or y == self.height - 1) then
		return true
	end
	if (x == 2 or x == self.width - 1) and (y == 3 or y == self.height - 2) then
		return true
	end
	if (y == 2 or y == self.height - 1) and (x == 3 or x == self.width - 2) then
		return true
	end
	return false
end

function Map:generateLayout()
	for row = 1, self.height do
		self.tiles[row] = {}
		for col = 1, self.width do
			if col == 1 or col == self.width or row == 1 or row == self.height then
				self.tiles[row][col] = -2
			elseif (row  - 1) % 2 == 0 and (col - 1) % 2 == 0 then
				self.tiles[row][col] = 1
			else
				self.tiles[row][col] = 0
			end
			if self:isSpawnLocation(col, row) then
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

function Map:generateFloorTiles()
	-- create randomized tiles
	math.randomseed( os.time() )
	for i=1, self.width do
		for j=1, self.height do
			local chosenTile = math.random(1,4)
			table.insert(floorTiles, chosenTile)
		end
	end
end

function Map:getFloorTiles(x,y)
	local tileNumber = (y * self.width) + x + 1
	return floorTiles[tileNumber]
end

function Map:update(dt)
end

function Map:drawFloor(x, y)
	love.graphics.draw(self.floor, x, y)
end

function Map:drawWalls()
	self:foreach(function(x, y, value)
		local x = x - 1
		local y = y - 1
		if value == 1 then
			love.graphics.draw(self.tileset, self.wall, x * 15, y * 15 - 2)
		end
	end)
end

return Map
