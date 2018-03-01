local Object = require 'lib.classic.classic'
local Vector = require 'vector'

local Debris = Object:extend()

-- particle stuff --
function Debris:new()
    self.particleImg = love.graphics.newImage('res/sprites/debris_particles.png')
    self.psystem = love.graphics.newParticleSystem(self.particleImg, 32)
    self.psystem:setParticleLifetime(0.5, 1.5) -- Particles live at least 2s and at most 5s.
    self.psystem:setEmissionRate(5)
    self.psystem:setSizeVariation(1)
    self.psystem:setLinearAcceleration(-20, -20, 20, 20) -- Random movement in all directions.
    self.psystem:setColors(255, 255, 255, 255, 255, 255, 255, 0) -- Fade to transparency.
end
   
function Debris:update(dt)
	self.psystem:update(dt)
end

function Debris:draw()
	-- Draw the particle system at the center of the game window.
	love.graphics.draw(self.psystem, love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.5)
end

return Debris