Entity = { MOVE_SPEED = 150, FLY_SPEED = 300 }
Entity.__index = Entity

Entity.TYPE_NONE = 0
Entity.TYPE_DUCK = 1
Entity.TYPE_ENEMY = 2
Entity.TYPE_GOLDDUCK = 3
Entity.TYPE_PINKDUCK = 4

Entity.STATE_WALKING = 0
Entity.STATE_FLYING  = 1

function Entity.create(x, y, dir)
	local self = setmetatable({}, Entity)

	self.x, self.y = x, y
	self.dir = dir
	self.moved = 48
	self.tile = 0
	self.state = Entity.STATE_WALKING

	return self
end

function Entity:update(dt, map, arrows)
	-- Update animation
	self:getAnim():update(dt)

	if self.state == Entity.STATE_WALKING then
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
		if self.moved >= 48 then
			-- Collide with walls
			local cx = math.floor(self.x / 48)
			local cy = math.floor(self.y / 48)
			self.x = cx*48 + 24
			self.y = cy*48 + 24

			-- Change direction if standing on an arrow
			for i=1, 4 do
				for j,v in ipairs(arrows[i]) do
					if v.x == cx and v.y == cy then
						self.dir = v.dir
						self.moved = 0
						break
					end
				end
			end

			-- Check collision with walls
			self:collideWalls(map)

			self.tile = map:getTile(cx, cy)
		end
	elseif self.state == Entity.STATE_FLYING then
		local dirx = self.destx - self.x
		local diry = self.desty - self.y
		local dist = math.sqrt(dirx^2 + diry^2)
		local toMove = self.FLY_SPEED * dt
		if dist < toMove then
			self.x = self.destx
			self.y = self.desty
			local cx = math.floor(self.x / 48)
			local cy = math.floor(self.y / 48)
			self.tile = map:getTile(cx, cy)
		else
			self.x = self.x + dirx/dist * dt * self.FLY_SPEED
			self.y = self.y + diry/dist * dt * self.FLY_SPEED
		end
	end
end

function Entity:collideWalls(map)
	local cx = math.floor(self.x / 48)
	local cy = math.floor(self.y / 48)
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

function Entity:draw()
	love.graphics.draw(ResMgr.getImage("entity_shadow.png"), self.x, self.y, 0, 1, 1, 15, -5)
	self:getAnim():draw(self.x, self.y)
end

function Entity:getTile()
	return self.tile
end

function Entity:getDir()
	return self.dir
end

function Entity:getType()
	return Entity.TYPE_NONE
end

--- Makes entity fly to destination (x,y)
function Entity:setFlying(x, y)
	self.state = Entity.STATE_FLYING
	self.destx = x
	self.desty = y
	self.tile = 0
end
