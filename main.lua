local bump = require "lib/bump"
local screen = require "lib/shack/shack"

local Vector = require 'vector'
local Player = require 'player'
local Bomb = require 'bomb'
local softObject = require 'softObject'
local Map = require 'map'

love.graphics.setDefaultFilter("nearest", "nearest")

width, height = love.graphics.getDimensions()
screen:setDimensions(width, height)

debug = false

function love.load() ----------------------------------------------------------------------------------------
	world = bump.newWorld()

	map = Map()

	player = Player(3, 6)
	objects = {player}

	math.randomseed( os.time() )
	map:foreach(function(x, y, value)
		local chance = math.random()
		if value == 0 and chance < 0.7 then
			local softObject = softObject((x - 1) * 15, (y - 1) * 15, math.random(1,5))
			table.insert(objects, softObject)
			world:add(softObject, softObject.position.x, softObject.position.y, softObject.width, softObject.height)
		elseif value == 1 then
			local x = x - 1
			local y = y - 1
			local wall = {
				position = Vector(x * 15, y * 15),
				width = 15,
				height = 15,
			}
			world:add(wall, wall.position.x, wall.position.y, wall.width, wall.height)
		end
	end)

	world:add(player, player.position.x, player.position.y, player.width, player.height)

	scale = 4.0
	canvas = love.graphics.newCanvas(map.width * map.tilewidth, map.height * map.tileheight)
end

function love.update(dt) ------------------------------------------------------------------------------------
	map:update(dt)
	screen:update(dt)
	--screen:setShake(2)

	for _, object in ipairs(objects) do
		object:update(dt)
	end
end

function love.draw() ----------------------------------------------------------------------------------------
	-- y-sort objects
	table.sort(objects, function(a, b)
		return a.position.y + a.height < b.position.y + b.height
	end)

	love.graphics.setCanvas(canvas)
	love.graphics.clear()

	map:draw(0, 0)

	for _, object in ipairs(objects) do
		object:draw()
	end

	if debug then
		for _, item in ipairs(world:getItems()) do
			local x, y, w, h = world:getRect(item)
			love.graphics.rectangle('line', x, y, w, h)
		end
	end

	love.graphics.setCanvas()
	love.graphics.scale(scale)

	screen:apply()
	love.graphics.draw(canvas, 0, 0, 0, 1, 1, -33, -8)
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	elseif key == 'tab' then
		debug = not debug
	elseif key == 'x' then
		local x, y = map:toTile(player.position.x + 5, player.position.y + 3)
		local bomb = Bomb(x, y)
		table.insert(objects, bomb)
	end
end
