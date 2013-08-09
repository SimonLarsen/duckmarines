Particle = {}
Particle.LAYER_BACK  = 0
Particle.LAYER_FRONT = 1

-- SKULL PARTICLE
SkullParticle = {}
SkullParticle.__index = SkullParticle

function SkullParticle.create(x,y)
	local self = setmetatable({}, SkullParticle)

	self.x, self.y = x, y
	self.yspeed = 100
	self.alive = true
	self.layer = Particle.LAYER_FRONT

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

-- SUBMARINE BULGE PARTICLE
SubBulgeParticle = {}
SubBulgeParticle.__index = SubBulgeParticle

function SubBulgeParticle.create(x, y, player)
	local self = setmetatable({}, SubBulgeParticle)

	self.x, self.y = x, y
	self.alive = true
	self.time = 0.1
	self.layer = Particle.LAYER_BACK
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
