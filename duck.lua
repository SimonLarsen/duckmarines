Duck = { MOVE_SPEED = 100 }
Duck.__index = Duck
setmetatable(Duck, Entity)

function Duck.create(x, y, dir)
	local self = setmetatable({}, Duck)

	self.x, self.y = x, y
	self.dir = dir
	self.moved = 0
	self.anim = Animation.create(ResMgr.getImage("duck.png"), 48, 48, 24, 24, 0.2, 1)

	return self
end

function Duck:update(dt, map)
	-- Update animation
	self.anim:update(dt)

	-- Move
	local toMove = self.MOVE_SPEED*dt
	if self.dir == 0 then -- up
		self.y = self.y - toMove
	elseif self.dir == 1 then -- right
		self.x = self.x + toMove
	elseif self.dir == 2 then -- down
		self.y = self.y + toMove
	elseif self.dir == 3 then -- left
		self.x = self.x - toMove
	end

	-- Check if whole step has been moved
	self.moved = self.moved + toMove
	if self.moved > 48 then
		local cx = math.floor(self.x / 48)
		local cy = math.floor(self.y / 48)
		self.x = cx*48 + 24
		self.y = cy*48 + 24

		if self.dir == 0 and map:northWall(cx, cy) then
			if not map:eastWall(cx, cy) then
				self.dir = 1
				self.moved = 0
			else
				self.dir = 3
			end
		elseif self.dir == 1 and map:eastWall(cx, cy) then
			if not map:southWall(cx, cy) then
				self.dir = 2
				self.moved = 0
			else
				self.dir = 0
			end
		elseif self.dir == 2 and map:southWall(cx, cy) then
			if not map:westWall(cx, cy) then
				self.dir = 3
				self.moved = 0
			else
				self.dir = 1
			end
		elseif self.dir == 3 and map:westWall(cx, cy) then
			if not map:northWall(cx, cy) then
				self.dir = 0
				self.moved = 0
			else
				self.dir = 2
			end
		else
			self.moved = 0
		end
	end
end

function Duck:getAnim()
	return self.anim
end
