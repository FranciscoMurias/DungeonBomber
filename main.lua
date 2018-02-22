local sti = require "lib/sti"
local bump = require "lib/bump"

local Player = require 'player'

love.graphics.setDefaultFilter("nearest", "nearest")

debug = false

function love.load() ----------------------------------------------------------------------------------------
	world = bump.newWorld(15)
	-- load map
  map = sti("res/maps/dungeon3.lua", {"bump"})
	map:bump_init(world)

	player = Player(0, 0)

	world:add(player, player.position.x, player.position.y, player.width, player.height)

	scale = 4.0
	canvas = love.graphics.newCanvas(map.width * map.tilewidth, map.height * map.tileheight)
end

function love.update(dt) ------------------------------------------------------------------------------------
	map:update(dt)
	player:update(dt)
end

function love.draw() ----------------------------------------------------------------------------------------
	love.graphics.setCanvas(canvas)

	map:draw(0, 0)
	player:draw()

	if debug then
		for _, item in ipairs(world:getItems()) do
			local x, y, w, h = world:getRect(item)
			love.graphics.rectangle('line', x, y, w, h)
		end
	end

	love.graphics.setCanvas()
	love.graphics.scale(scale)
	love.graphics.draw(canvas, 0, 0)
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	elseif key == 'tab' then
		debug = not debug
	end
end
