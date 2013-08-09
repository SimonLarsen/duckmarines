SkullParticle = {}
SkullParticle.__index = SkullParticle

function SkullParticle.create(x,y)
	local self = setmetatable({}, SkullParticle)

	self.x = x
	self.y = y
	self.yspeed = 100
	self.alive = true

	local img = ResMgr.getImage("skull.png")
	self.sprite = Sprite.create(img, nil, 12, 10)

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
	self.sprite:draw(self.x, self.y)
end
