local sti = require "lib/sti"
local bump = require "lib/bump"
local screen = require "lib/shack/shack"

local Player = require 'player'
local Bomb = require 'bomb'
local softObject = require 'softObject'

love.graphics.setDefaultFilter("nearest", "nearest")

width, height = love.graphics.getDimensions()
screen:setDimensions(width, height)

debug = false

function love.load() ----------------------------------------------------------------------------------------
	world = bump.newWorld()
	-- load map
  map = sti("res/maps/dungeon3.lua", {"bump"})
	map:bump_init(world)

	function map:toTile(x, y)
		x = math.floor(x / 15) * 15
		y = math.floor(y / 15) * 15
		return x, y
	end

	player = Player(3, 6)
	bombs = {}
	softObjects = {}

	math.randomseed( os.time() )
	for i=1, math.random(50,100) do
		local x, y = map:toTile(math.random(0*15,17*15),math.random(0*15,11*15))
		-- if ... contraints: conrners and no overlap
		local softObject = softObject(x, y, math.random(1,5))
		table.insert(softObjects, softObject)
	end

	world:add(player, player.position.x, player.position.y, player.width, player.height)

	scale = 4.0
	canvas = love.graphics.newCanvas(map.width * map.tilewidth, map.height * map.tileheight)
end

function love.update(dt) ------------------------------------------------------------------------------------
	map:update(dt)
	player:update(dt)
	screen:update(dt)
	--screen:setShake(2)

	for _, bomb in ipairs(bombs) do
		bomb:update(dt)
	end

	for _, softObject in ipairs(softObjects) do
		softObject:update(dt)
	end
end

function love.draw() ----------------------------------------------------------------------------------------
	love.graphics.setCanvas(canvas)

	map:draw(0, 0)
	player:draw()

	for _, bomb in ipairs(bombs) do
		bomb:draw()
	end

	for _, softObject in ipairs(softObjects) do
		softObject:draw()
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
		local x, y = map:toTile(player.position:unpack())
		local bomb = Bomb(x, y)
		table.insert(bombs, bomb)
	end
end
