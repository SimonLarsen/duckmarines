Bot = {}
Bot.__index = Bot
setmetatable(Bot, Input)

Bot.SPEED 			= 300
Bot.DIST_THRESHOLD 	= 18
Bot.STATE_NONE 		= 0
Bot.STATE_MOVING	= 1
Bot.STATE_ACTION	= 2

Bot.DANGER_THRESHOLD = (4*48)^2

function Bot.create(map, cursor, id, entities, arrows)
	local self = setmetatable(Input.create(), Bot)

	self.map = map
	self.cursor = cursor
	self.id = id
	self.entities = entities
	self.arrows = arrows

	self.state = Bot.STATE_NONE

	self.targetx = 0
	self.targety = 0

	return self
end

function Bot:getMovement(dt, lock)
	-- If no current target, try to find one
	if self.state == Bot.STATE_NONE then
		self:calculateMove()
	end

	-- Move towards target if any
	if self.state == Bot.STATE_MOVING then
		-- Check if target cell is still free
		local cx = math.floor(self.targetx / 48)
		local cy = math.floor(self.targety / 48)
		if self:canPlaceArrow(cx, cy) == false then
			self.state = Bot.STATE_NONE
		end

		-- Check if target has been reached,
		-- move towards target if not
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
	for v in offset_iter(self.entities) do
		if v:getType() == Entity.TYPE_ENEMY then
			if self:walkingTowards(v, subx, suby) then
				local dist = (subx-v.x)^2 + (suby-v.y)^2
				if dist < minDist then
					minDist = dist
					closest = v
					break
				end
			end
		end
	end
	-- Cut off predator if any danger
	if closest ~= nil then
		local dir = closest:getDir()
		local xdir, ydir = dirToVec(dir)
		local cx = math.floor(closest.x / 48)
		local cy = math.floor(closest.y / 48)

		local ix, iy = sub.x, sub.y
		while ix ~= cx or iy ~= cy do
			local free, tile, arrow = self:canPlaceArrow(ix, iy)
			if free then
				self.targetx = ix*48+24
				self.targety = iy*48+24
				self.action = (closest:getDir() + 2) % 4
				self.state = Bot.STATE_MOVING
				return
			elseif arrow and arrow.dir ~= dir then
				break
			end
			ix = ix - xdir
			iy = iy - ydir
		end
	end
	
	-- If no threats found,
	-- look for ducks that that can be guided towards sub
	-- with a single arrow
	local target = nil
	for v in offset_iter(self.entities) do
		if v:getType() ~= Entity.TYPE_ENEMY then
			if self:walkingTowardsInOneAxis(v, subx, suby) then
				target = v
				break
			end
		end
	end

	-- If a duck is found, place arrow
	if target ~= nil then
		local xdir, ydir = dirToVec(target:getDir())
		if xdir == 0 then
			self.targetx = target.x
			self.targety = suby
		else
			self.targetx = subx
			self.targety = target.y
		end

		local cx = math.floor(self.targetx / 48)
		local cy = math.floor(self.targety / 48)
		if self:canPlaceArrow(cx, cy) then
			self.action = vecToDir(subx-self.targetx, suby-self.targety)
			self.state = Bot.STATE_MOVING
		end
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

--- Checks if an arrow can be placed at (x,y)
--  @return True if placement is possible, false otherwise
function Bot:canPlaceArrow(x, y)
	-- Check if tile is empty
	local tile = self.map:getTile(x, y)
	if tile ~= 0 then
		return false, tile, nil
	end
	-- Check if another arrow is already placed there
	for i=1,4 do
		for j,v in ipairs(self.arrows[i]) do
			if v.x == x and v.y == y then
				return false, tile, v
			end
		end
	end

	return true, tile, nil
end

function Bot:getType()
	return Input.TYPE_BOT
end
