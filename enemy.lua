local Object = require 'lib.classic.classic'
local anim8 = require 'lib.anim8'

local Vector = require 'vector'
local PowerUp = require 'powerUp'
local SoftObject = require 'softObject'
local Bomb = require 'bomb'

local Enemy = Object:extend()

function Enemy:new(x, y)
	self.position = Vector(x, y)
	self.width = 15
	self.height = 15
	self.origin = Vector(2, 6)
	self.direction = Vector(0, 1)
	self.speed = 50
	self.target = self.position
	self.maxBombs = 1
	self.usedBombs = 0
	self.bombRadius = 1
	self.powerUps = {}
	self.sprite = love.graphics.newImage('res/sprites/player_sprites.png')
	self.grid = anim8.newGrid(15, 19, self.sprite:getWidth(), self.sprite:getHeight())
	self.animations = {
		walkUp = anim8.newAnimation(self.grid('1-3', 1), 0.1),
		walkDown = anim8.newAnimation(self.grid('1-3', 2), 0.1),
		walkRight = anim8.newAnimation(self.grid('1-3', 3), 0.1),
		walkLeft = anim8.newAnimation(self.grid('1-3', 3), 0.1):flipH(),
		idleUp = anim8.newAnimation(self.grid(1, 1), 0.1),
		idleDown = anim8.newAnimation(self.grid(1, 2), 0.1),
		idleRight = anim8.newAnimation(self.grid(1, 3), 0.1),
		idleLeft = anim8.newAnimation(self.grid(1, 3), 0.1):flipH(),
	}

	world:add(self, self.position.x, self.position.y, self.width, self.height)
end

function Enemy:center()
	return self.position + Vector(self.width / 2, self.height / 2)
end

function Enemy:updateAnimation(vector)
	if vector == Vector(-1, 0) then self.animation = 'walkLeft' end
	if vector == Vector(1, 0) then self.animation = 'walkRight' end
	if vector == Vector(0, 1) then self.animation = 'walkDown' end
	if vector == Vector(0, -1) then self.animation = 'walkUp' end
end

function Enemy:updateIdle(vector)
	if vector == Vector(-1, 0) then self.animation = 'idleLeft' end
	if vector == Vector(1, 0) then self.animation = 'idleRight' end
	if vector == Vector(0, 1) then self.animation = 'idleDown' end
	if vector == Vector(0, -1) then self.animation = 'idleUp' end
end

function isSafe(position)
	for _, object in ipairs(objects) do
		-- fix with proper bomb removal so don't need exploded check here
		if object.is and object:is(Bomb) and not object.exploded then
			local tiles, collisions = object:checkTiles()
			for _, tile in ipairs(tiles) do
				if tile == position then
					return false
				end
			end
		end
	end
	return true
end

function Enemy:findPath(target)
	local Map = require 'map'
	local targetTile = map:toTile(target)
	local currentTile = map:toTile(self.position)

	local choice = nil
	local distance = map:distance(currentTile, targetTile)
	local neighbors = map:getNeighbors(currentTile:unpack())
	for _, tile in ipairs(neighbors) do
		local type = map.tiles[tile.y][tile.x]
		if not (type == Map.WALL or type == Map.OUTER_WALL) then
			local newDistance = map:distance(tile, targetTile)
			if newDistance <= distance then
				choice = tile
				distance = newDistance
			end
		end
	end

	if choice then
		-- convert back to world position from tile position
		choice = map:toWorld(choice)
	end

	return choice
end

function Enemy:findPathToSafety(target)
	local Map = require 'map'
	local targetTile = nil
	if target then
		targetTile = map:toTile(target)
	end
	local currentTile = map:toTile(self.position)

	local closestPath = nil
	local seen = {}
	local queue = {}
	local neighbors = map:getNeighbors(currentTile:unpack())
	for _, neighbor in ipairs(neighbors) do
		local position = map:toWorld(neighbor)
		local items, len = world:queryRect(position.x, position.y, self.width, self.height)
		if len == 0 then
			table.insert(queue, {neighbor})
		elseif target and items[1]:is(SoftObject) then
			table.insert(queue, {neighbor})
		end
	end
	while #queue > 0 do
		local path = table.remove(queue, 1)
		local node = path[#path]
		seen[tostring(node)] = true
		local position = map:toWorld(node)
		local safe = isSafe(position)
		local open = false
		local _, len = world:queryRect(position.x, position.y, self.width, self.height)
		if len == 0 then
			open = true
		end
		if targetTile then
			local distance = map:distance(path[#path], targetTile)
			if closestPath == nil then
				closestPath = path
			elseif distance < map:distance(closestPath[#closestPath], targetTile) then
				closestPath = path
			end
		end
		if targetTile and node == targetTile then
			return path
		elseif targetTile == nil and safe and open then
			return path
		else
			local neighbors = map:getNeighbors(node:unpack())
			for _, neighbor in ipairs(neighbors) do
				if not seen[tostring(neighbor)] and neighbor ~= currentTile then
					local position = map:toWorld(neighbor)
					local items, len = world:queryRect(position.x, position.y, self.width, self.height)
					if len == 0 then
						local newPath = {unpack(path)}
						table.insert(newPath, neighbor)
						table.insert(queue, newPath)
					elseif targetTile and items[1]:is(SoftObject) then
						local newPath = {unpack(path)}
						table.insert(newPath, neighbor)
						return newPath
						--table.insert(queue, newPath)
					end
				end
			end
		end
	end
	return closestPath
end

function Enemy:placeBomb()
	if self.usedBombs < self.maxBombs then
		local bomb = Bomb(self, self.position:unpack())
		table.insert(objects, bomb)
		self.usedBombs = self.usedBombs + 1
	end
end

function Enemy:update(dt)
	local velocity = Vector(0, 0)

	local safe = isSafe(self.position)
	if not safe then
		local path = self:findPathToSafety()
		if path and #path > 0 then
			self.target = map:toWorld(path[1])
			self.currentPath = nil
			self.currentIndex = nil
		end
	else
		-- currently safe, so do something
		if self.currentPath then
			if self.position == self.target then
				self.target = map:toWorld(self.currentPath[self.currentIndex])
				self.currentIndex = self.currentIndex + 1
			end
		elseif not self.target or self.target == self.position then
			local path = self:findPathToSafety(player.position)
			if #path > 0 then
				local newTarget = map:toWorld(path[1])
				if newTarget and isSafe(newTarget) then
					self.target = newTarget
					self.currentPath = path
					self.currentIndex = 2
				end
			end
		end
		if self.currentPath and self.currentIndex > #self.currentPath then
			self.currentIndex = nil
			self.currentPath = nil
		end
	end

	if self.target then
		local items, len = world:queryRect(self.target.x, self.target.y, self.width, self.height)
		for _, item in ipairs(items) do
			if item:is(SoftObject) then
				self:placeBomb()
			end
		end
	end

	-- move to target if one is set
	if self.target then
		local direction = self.target:directionTo(self.position)
		velocity = direction * self.speed * dt
		local distance = self.target:distanceTo(self.position)
		if velocity:length() > distance then
			velocity = direction * distance
		end
	end

	if velocity ~= Vector(0, 0) then
		local newPosition = self.position + velocity
		local actualX, actualY, cols, cols_len = world:move(self, newPosition.x, newPosition.y,
			function(item, other)
				if not other.is then
					return 'slide'
				elseif other:is(PowerUp) then
					return 'cross'
				elseif other:is(Bomb) and other.player == self then
					if other.underPlayer then
						return 'cross'
					else
						return 'slide'
					end
				else
					return 'slide'
				end
			end
		)
		self.position = Vector(actualX, actualY)

		-- handle collisions
		for _, col in ipairs(cols) do
			local other = col.other
			if other.is and other:is(PowerUp) then
				other.remove = true
				if not self.powerUps[other] then
					self.powerUps[other] = other
					other.addEffect(self)
				end
			end
		end

		-- animation control
		local normalized = velocity:normalize()
		if normalized ~= self.direction then
			self.direction = velocity:normalize()
			self:updateAnimation(self.direction)
		end
	else
		self:updateIdle(self.direction)
	end

	print(self.direction)

	self.animations[self.animation]:update(dt)
end

function Enemy:draw()
	-- for testing, draw enemy target
	if self.currentPath then
		for _, target in ipairs(self.currentPath) do
			target = map:toWorld(target)
			love.graphics.rectangle('line', target.x, target.y, 15, 15)
		end
	end
	love.graphics.setColor(255, 0, 0, 255)
	if self.target then
		love.graphics.rectangle('line', self.target.x, self.target.y, 15, 15)
	end
	love.graphics.setColor(255, 255, 255, 255)
	self.animations[self.animation]:draw(
		self.sprite, self.position.x, self.position.y, 0, 1, 1, self.origin.x, self.origin.y
	)
end

return Enemy
