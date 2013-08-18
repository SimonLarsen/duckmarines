Bot = {}
Bot.__index = Bot
setmetatable(Bot, Input)

Bot.SPEED 			= 300
Bot.DIST_THRESHOLD 	= 18
Bot.STATE_NONE 		= 0
Bot.STATE_MOVING	= 1

function Bot.create(cursor, map)
	local self = setmetatable(Input.create(), Bot)

	self.cursor = cursor

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
			self.action = 1
			self.state = Bot.STATE_NONE
			return 0, 0, false
		end
	end
end

function Bot:calculateMove()
	self.targetx = 24
	self.targety = 24
	self.state = Bot.STATE_MOVING
end

function Bot:getAction()
	local ac = self.action
	self.action = nil
	self.state = Bot.STATE_NONE
	return ac
end
