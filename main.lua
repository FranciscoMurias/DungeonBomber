local sti = require "lib/sti"
local bump = require "lib/bump"
local screen = require "lib/shack/shack"

local Player = require 'player'

love.graphics.setDefaultFilter("nearest", "nearest")

width, height = love.graphics.getDimensions()
screen:setDimensions(width, height)

debug = false

function love.load() ----------------------------------------------------------------------------------------
	world = bump.newWorld(15)
	-- load map
  map = sti("res/maps/dungeon3.lua", {"bump"})
	map:bump_init(world)

	player = Player(3, 5)

	world:add(player, player.position.x, player.position.y, player.width, player.height)

	scale = 4.0
	canvas = love.graphics.newCanvas(width, height)
end

function love.update(dt) ------------------------------------------------------------------------------------
	map:update(dt)
	player:update(dt)
	screen:update(dt)
	-- screen:setShake(2) -- test screenshake - seems to be apllying differently to the player and the scenery
end

function love.draw() ----------------------------------------------------------------------------------------
	love.graphics.setCanvas(canvas)
	
	screen:apply()
	map:draw(33,8)
	player:draw()

	if debug then
		for _, item in ipairs(world:getItems()) do
			local x, y, w, h = world:getRect(item)
			love.graphics.rectangle('line', x+33, y+8, w, h)
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
