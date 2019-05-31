local Animation = require("anim")
local Entity = require("entity")

Particle = {}
Particle.__index = Particle

Particle.LAYER_BACK  = 0
Particle.LAYER_FRONT = 1

function Particle.create()
	local self = setmetatable({}, Particle)
	self.alive = true
	return self
end

-- SKULL PARTICLE
SkullParticle = {}
SkullParticle.__index = SkullParticle
setmetatable(SkullParticle, Particle)

function SkullParticle.create(x,y)
	local self = setmetatable(Particle.create(), SkullParticle)

	self.x, self.y = x, y
	self.yspeed = 100

	self.img = ResMgr.getImage("skull.png")

	return self
end

function SkullParticle:update(dt)
	self.y = self.y - self.yspeed*dt
	self.yspeed = self.yspeed - 200*dt
	if self.yspeed <= 0 then
		self.alive = false
	end
end

function SkullParticle:draw()
	love.graphics.draw(self.img, self.x, self.y, 0, 1, 1, 12, 10)
end

function SkullParticle:getLayer()
	return Particle.LAYER_FRONT
end

-- BONUS/PENALTY INDICATOR PARTICLE
BonusTextParticle = {}
BonusTextParticle.__index = BonusTextParticle
setmetatable(BonusTextParticle, Particle)

function BonusTextParticle.create(x,y,text,color)
	local self = setmetatable({}, BonusTextParticle)
	
	self.x, self.y = x, y
	self.text = text
	self.yspeed = 100
	self.alive = true
	self.color = color or {1, 1, 1, 100/255}

	local number = tonumber(self.text)
	if number and number <= 0 then
		self.bar = ResMgr.getImage("bonus_bar_negative.png")
	else
		self.bar = ResMgr.getImage("bonus_bar_positive.png")
	end

	return self
end

function BonusTextParticle:update(dt)
	self.y = self.y - self.yspeed*dt
	self.yspeed = self.yspeed - 180*dt
	if self.yspeed <= 0 then
		self.alive = false
	end
end

function BonusTextParticle:draw()
	love.graphics.draw(self.bar, self.x-40, self.y+26)

	love.graphics.setFont(ResMgr.getFont("joystix30"))
	love.graphics.setColor(0, 0, 0, 100/255)
	love.graphics.printf(self.text, self.x-75, self.y+3, 150, "center")
	love.graphics.setColor(self.color)
	love.graphics.printf(self.text, self.x-75, self.y, 150, "center")
	love.graphics.setColor(1, 1, 1, 100/255)
end

function BonusTextParticle:getLayer()
	return Particle.LAYER_FRONT
end

-- SUBMARINE BULGE PARTICLE
SubBulgeParticle = {}
SubBulgeParticle.__index = SubBulgeParticle
setmetatable(SubBulgeParticle, Particle)

function SubBulgeParticle.create(x, y, player)
	local self = setmetatable(Particle.create(), SubBulgeParticle)

	self.x, self.y = x, y
	self.time = 0.5
	self.anim = Animation.create(ResMgr.getImage("bulge"..player..".png"), 54, 46, 0, 0, 1/12, 6)

	return self
end

function SubBulgeParticle:update(dt)
	self.time = self.time - dt
	self.anim:update(dt)
	if self.time <= 0 then
		self.alive = false
	end
end

function SubBulgeParticle:draw()
	self.anim:draw(self.x, self.y, 0, 1, 1)
end

function SubBulgeParticle:getLayer()
	return Particle.LAYER_BACK
end

-- DUCK FALL PARTICLE
DuckFallParticle = {}
DuckFallParticle.__index = DuckFallParticle
setmetatable(DuckFallParticle, Particle)

function DuckFallParticle.create(x, y, type)
	local self = setmetatable(Particle.create(), DuckFallParticle)

	self.x, self.y = x,y
	if type == Entity.TYPE_DUCK then
		self.anim = Animation.create(ResMgr.getImage("duckfall.png"), 48, 48, 0, 0, 0.075, 3, function() self.alive = false end)
	elseif type == Entity.TYPE_ENEMY then
		self.anim = Animation.create(ResMgr.getImage("predatorfall.png"), 48, 48, 0, 0, 0.075, 3, function() self.alive = false end)
	elseif type == Entity.TYPE_PINKDUCK then
		self.anim = Animation.create(ResMgr.getImage("pinkduckfall.png"), 48, 48, 0, 0, 0.075, 3, function() self.alive = false end)
	elseif type == Entity.TYPE_GOLDDUCK then
		self.anim = Animation.create(ResMgr.getImage("goldduckfall.png"), 48, 48, 0, 0, 0.075, 3, function() self.alive = false end)
	end
	self.anim:setMode("once")

	return self
end

function DuckFallParticle:update(dt)
	self.anim:update(dt)
end

function DuckFallParticle:draw()
	self.anim:draw(self.x, self.y)
end

function DuckFallParticle:getLayer()
	return Particle.LAYER_BACK
end

-- DUCKSPLOSIONPARTICLE
DucksplosionParticle = {}
DucksplosionParticle.__index = DucksplosionParticle
setmetatable(DucksplosionParticle, Particle)

function DucksplosionParticle.create(x, y, type)
	local self = setmetatable(Particle.create(), DucksplosionParticle)

	self.x, self.y = x, y
	if type == Entity.TYPE_DUCK then
		self.anim = Animation.create(ResMgr.getImage("ducksplosion.png"), 44, 39, 22, 18, 0.06, 13, function() self.alive = false end)
	elseif type == Entity.TYPE_PINKDUCK then
		self.anim = Animation.create(ResMgr.getImage("ducksplosion_pink.png"), 44, 39, 22, 18, 0.06, 13, function() self.alive = false end)
	elseif type == Entity.TYPE_GOLDDUCK then
		self.anim = Animation.create(ResMgr.getImage("ducksplosion_gold.png"), 44, 39, 22, 18, 0.06, 13, function() self.alive = false end)
	end
	self.anim:setMode("once")

	return self
end

function DucksplosionParticle:update(dt)
	self.anim:update(dt)
end

function DucksplosionParticle:draw()
	self.anim:draw(self.x, self.y)
end

function DucksplosionParticle:getLayer()
	return Particle.LAYER_FRONT
end
