Bot = {}
Bot.__index = Bot
setmetatable(Bot, Input)

Bot.SPEED 			= 300
Bot.DIST_THRESHOLD 	= 18
Bot.STATE_NONE 		= 0
Bot.STATE_MOVING	= 1
Bot.STATE_ACTION	= 2

function Bot.create(map, cursor, id, entities)
	local self = setmetatable(Input.create(), Bot)

	self.map = map
	self.cursor = cursor
	self.id = id
	self.entities = entities

	self.state = Bot.STATE_NONE

	self.targetx = 0
	self.targety = 0

	return self
end

function Bot:getMovement(dt, lock)
	if self.state == Bot.STATE_NONE then
		self:calculateMove()
	end

	if self.state == Bot.STATE_MOVING then
		local dx = self.targetx - self.cursor.x
		local dy = self.targety - self.cursor.y
		local sqdist = dx^2 + dy^2
		if sqdist > Bot.DIST_THRESHOLD^2 then
			local dist = math.sqrt(sqdist)
			dx = dx / dist * dt * Bot.SPEED
			dy = dy / dist * dt * Bot.SPEED
			return dx, dy, false
		else
			self.state = Bot.STATE_ACTION
			return 0, 0, false
		end
	end

	return 0, 0, false
end

function Bot:getAction()
	if self.state == Bot.STATE_ACTION then
		local ac = self.action
		self.action = nil
		self.state = Bot.STATE_NONE
		return ac
	else
		return nil
	end
end

function Bot:calculateMove()
	local sub
	for i,v in ipairs(self.map:getSubmarines()) do
		if v.player == self.id then sub = v end
	end

	self.targetx = sub.x*48+24
	self.targety = sub.y*48+24
	self.action = 1
	self.state = Bot.STATE_MOVING
end
