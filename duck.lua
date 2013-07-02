Duck = {}
Duck.__index = Duck
setmetatable(Duck, Entity)

function Duck.create(x, y, dir)
	local self = Entity.create(x, y, dir)
	setmetatable(self, Duck)

	self.anim = {}
	self.anim[0] = Animation.create(ResMgr.getImage("duck_back.png"),  32, 37, 16, 26, 0.09, 6)
	self.anim[1] = Animation.create(ResMgr.getImage("duck_right.png"), 32, 39, 16, 28, 0.09, 6)
	self.anim[2] = Animation.create(ResMgr.getImage("duck_front.png"), 34, 37, 17, 26, 0.09, 6)
	self.anim[3] = Animation.create(ResMgr.getImage("duck_left.png"),  32, 39, 16, 28, 0.09, 6)

	return self
end

function Duck:getAnim()
	return self.anim[self.dir]
end
