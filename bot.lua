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
	local subx = sub.x*48+24
	local suby = sub.y*48+24

	-- Check if a predator is steering towards submarine
	local minDist = 1000000
	local closest = nil
	for i,v in ipairs(self.entities) do
		if v:getType() == Entity.TYPE_ENEMY then
			if self:walkingTowards(v, subx, suby) then
				local dist = (subx-v.x)^2 + (suby-v.y)^2
				if dist < minDist then
					minDist = dist
					closest = v
				end
			end
		end
	end
	-- Cut off predator if any danger
	if closest ~= nil then
		local xdir, ydir = dirToVec(closest:getDir())
		local cx = math.floor(closest.x / 48)
		local cy = math.floor(closest.y / 48)

		if xdir ~= 0 then
			for ix=sub.x, cx, -xdir do
				if self.map:getTile(ix, sub.y) == 0 then
					self.targetx = ix*48+24
					self.targety = suby
					self.action = (closest:getDir() + 2) % 4
					self.state = Bot.STATE_MOVING
					return
				end
			end
		end
	end
	
	-- If no threats found,
	-- look for ducks that that can be guided towards sub
	-- with a single arrow
	local target = nil
	for i,v in ipairs(self.entities) do
		if v:getType() ~= Entity.TYPE_ENEMY then
			if self:walkingTowardsInOneAxis(v, subx, suby) then
				target = v
				break
			end
		end
	end

	-- If a dick is found, place arrow
	if target ~= nil then
		local xdir, ydir = dirToVec(target:getDir())
		if xdir == 0 then
			self.targetx = target.x
			self.targety = suby
		else
			self.targetx = subx
			self.targety = target.y
		end
		self.action = vecToDir(subx-self.targetx, suby-self.targety)
		self.state = Bot.STATE_MOVING
		return
	end
end

function Bot:walkingTowards(entity, x, y)
	local xdir, ydir = dirToVec(entity:getDir())
	return (entity.y == y and math.sign(x - entity.x) == xdir)
	or     (entity.x == x and math.sign(y - entity.y) == ydir)
end

function Bot:walkingTowardsInOneAxis(entity, x, y)
	local xdir1, ydir1 = dirToVec(entity:getDir())
	local xdir2 = math.signz(x - entity.x)
	local ydir2 = math.signz(y - entity.y)

	return (xdir1 == xdir2 or xdir1*xdir2 == 0)
	and    (ydir1 == ydir2 or ydir1*ydir2 == 0)
end

function Bot:getType()
	return Input.TYPE_BOT
end
