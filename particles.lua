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
	self.color = color or {255, 255, 255, 255}

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
	love.graphics.setFont(ResMgr.getFont("bold"))
	love.graphics.push()
	love.graphics.scale(3, 3)
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.printf(self.text, self.x/3-50, self.y/3+1, 100, "center")
	love.graphics.setColor(self.color)
	love.graphics.printf(self.text, self.x/3-50, self.y/3, 100, "center")
	love.graphics.pop()
	love.graphics.setColor(255, 255, 255, 255)
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
	self.time = 0.1
	self.img = ResMgr.getImage("bulge"..player..".png")

	return self
end

function SubBulgeParticle:update(dt)
	self.time = self.time - dt
	if self.time <= 0 then
		self.alive = false
	end
end

function SubBulgeParticle:draw()
	love.graphics.draw(self.img, self.x, self.y)
end

function SubBulgeParticle:getLayer()
	return Particle.LAYER_BACK
end
