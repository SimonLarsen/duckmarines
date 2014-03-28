local Entity = require("entity")
local Animation = require("anim")

local Enemy = { MOVE_SPEED = 150 }
Enemy.__index = Enemy
setmetatable(Enemy, Entity)

function Enemy.create(x, y, dir)
	local self = Entity.create(x, y, dir)
	setmetatable(self, Enemy)

	self.anim = {}
	self.anim[0] = Animation.create(ResMgr.getImage("enemy_back.png"),  32, 44, 16, 33, 0.09, 8)
	self.anim[1] = Animation.create(ResMgr.getImage("enemy_right.png"), 32, 44, 16, 33, 0.09, 8)
	self.anim[2] = Animation.create(ResMgr.getImage("enemy_front.png"), 32, 43, 16, 32, 0.09, 6)
	self.anim[3] = Animation.create(ResMgr.getImage("enemy_left.png"),  32, 44, 16, 33, 0.09, 8)

	return self
end

function Enemy:getAnim()
	return self.anim[self.dir]
end

function Enemy:getType()
	return Entity.TYPE_ENEMY
end

return Enemy
