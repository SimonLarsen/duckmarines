local Entity = require("entity")
local Animation = require("anim")

local Duck = {}
Duck.__index = Duck
setmetatable(Duck, Entity)

function Duck.create(x, y, dir)
	local self = Entity.create(x, y, dir)
	setmetatable(self, Duck)

	self.anim = {}
	self.anim[0] = Animation.create(ResMgr.getImage("duck_back.png"),  32, 37, 16, 26, 0.05, 6)
	self.anim[1] = Animation.create(ResMgr.getImage("duck_right.png"), 32, 38, 16, 28, 0.08, 8)
	self.anim[2] = Animation.create(ResMgr.getImage("duck_front.png"), 34, 37, 17, 26, 0.08, 6)
	self.anim[3] = Animation.create(ResMgr.getImage("duck_left.png"),  32, 38, 16, 28, 0.05, 8)

	return self
end

function Duck:getAnim()
	return self.anim[self.dir]
end

function Duck:getType()
	return Entity.TYPE_DUCK
end

return Duck
