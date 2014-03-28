local Entity = require("entity")
local Animation = require("anim")

local GoldDuck = {}
GoldDuck.__index = GoldDuck
setmetatable(GoldDuck, Entity)

function GoldDuck.create(x, y, dir)
	local self = Entity.create(x, y, dir)
	setmetatable(self, GoldDuck)

	self.anim = {}
	self.anim[0] = Animation.create(ResMgr.getImage("gold_back.png"),  32, 37, 16, 26, 0.05, 6)
	self.anim[1] = Animation.create(ResMgr.getImage("gold_right.png"), 32, 38, 16, 28, 0.08, 8)
	self.anim[2] = Animation.create(ResMgr.getImage("gold_front.png"), 34, 37, 17, 26, 0.08, 6)
	self.anim[3] = Animation.create(ResMgr.getImage("gold_left.png"),  32, 38, 16, 28, 0.05, 8)

	return self
end

function GoldDuck:getAnim()
	return self.anim[self.dir]
end

function GoldDuck:getType()
	return Entity.TYPE_GOLDDUCK
end

return GoldDuck
