local sti = require "lib/sti"
local bump = require "lib/bump"

love.graphics.setDefaultFilter("nearest", "nearest")

local world

local cols_len = 0 -- how many collisions are happening

local world = bump.newWorld(15)

local player = { x=0, y=0, w=11, h=11, speed=50 , ox= 2, oy= 5, image = love.graphics.newImage("res/sprites/player.png") }

local function updatePlayer(dt)
	local speed = player.speed
  
	local dx, dy = 0, 0
	if love.keyboard.isDown('right') then
	  dx = speed * dt
	elseif love.keyboard.isDown('left') then
	  dx = -speed * dt
	end
	if love.keyboard.isDown('down') then
	  dy = speed * dt
	elseif love.keyboard.isDown('up') then
	  dy = -speed * dt
	end
  
	if dx ~= 0 or dy ~= 0 then
	  local cols
	  player.x, player.y, cols, cols_len = world:move(player, player.x + dx, player.y + dy)
	  for i=1, cols_len do
		local col = cols[i]
	  end
	end
  end

  -- helper functions
local function drawEntity(entity)
	local x = math.floor(entity.x*4+31*4)
	local y = math.floor(entity.y*4+8*4)
	love.graphics.draw(entity.image, x, y, 0, 4,4, entity.ox,entity.oy)
	love.graphics.rectangle("line", entity.x*4+31*4, entity.y*4+8*4, entity.w*4, entity.h*4)
  end

function love.load() ----------------------------------------------------------------------------------------
	-- load map
    map = sti("res/maps/dungeon3.lua", { "bump" })
	map:bump_init(world)
	
	world:add(player, player.x, player.y, player.w, player.h)

    --map:addCustomLayer("Entities Layer", 3)
	--local entitiesLayer = map.layers["Entities Layer"]
	--entitiesLayer.entities = {
	--	player = {
	--		image = love.graphics.newImage("res/sprites/player.png"),
	--		x = -5,
	--		y = -8,
	--		speed = 10
	--	}
    --}

    -- Update callback for Custom Layer
	--function entitiesLayer:update(dt)
		

    --end
    
    -- Draw callback for Custom Layer
	--function entitiesLayer:draw()
	--	for _, sprite in pairs(self.entities) do
	--		local x = math.floor(sprite.x)
	--		local y = math.floor(sprite.y)
	--		love.graphics.draw(sprite.image, x, y)
	--	end
	--end

end

function love.keypressed(key)
	-- Exit
	if key == "escape" then
		love.event.quit()
	end
end

function love.update(dt) ------------------------------------------------------------------------------------
	cols_len = 0
  	updatePlayer(dt)
	map:update(dt)
end

 
function love.draw() ----------------------------------------------------------------------------------------

	map:draw(31, 8, 4, 4)
    -- map:bump_draw(world,31, 8, 4, 4)
	drawEntity(player)

end