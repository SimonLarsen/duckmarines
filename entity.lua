local Entity = { MOVE_SPEED = 125, FLY_SPEED = 300 }
Entity.__index = Entity

Entity.TYPE_NONE = 0
Entity.TYPE_DUCK = 1
Entity.TYPE_ENEMY = 2
Entity.TYPE_GOLDDUCK = 3
Entity.TYPE_PINKDUCK = 4

Entity.STATE_WALKING = 0
Entity.STATE_FLYING  = 1

Entity.DIR_UP    = 0
Entity.DIR_RIGHT = 1
Entity.DIR_DOWN  = 2
Entity.DIR_LEFT  = 3

function Entity.create(x, y, dir)
	local self = setmetatable({}, Entity)

	self.x, self.y = x, y
	self.dir = dir
	self.moved = 48
	self.tile = 0
	self.state = Entity.STATE_WALKING
	self.alive = true

	return self
end

function Entity:update(dt, map, arrows)
	-- Update animation
	self:getAnim():update(dt)

	if self.state == Entity.STATE_WALKING then
		-- Move
		local toMove = self.MOVE_SPEED*dt
		if self.dir == Entity.DIR_UP then
			self.y = self.y - toMove
		elseif self.dir == Entity.DIR_RIGHT then
			self.x = self.x + toMove
		elseif self.dir == Entity.DIR_DOWN then
			self.y = self.y + toMove
		elseif self.dir == Entity.DIR_LEFT then
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
	if self.dir == Entity.DIR_UP and map:northWall(cx, cy) then
		if not map:eastWall(cx, cy) then
			self.dir = Entity.DIR_RIGHT
			self.moved = 0
		else
			self.dir = Entity.DIR_LEFT
		end
	elseif self.dir == Entity.DIR_RIGHT and map:eastWall(cx, cy) then
		if not map:southWall(cx, cy) then
			self.dir = Entity.DIR_DOWN
			self.moved = 0
		else
			self.dir = Entity.DIR_UP
		end
	elseif self.dir == Entity.DIR_DOWN and map:southWall(cx, cy) then
		if not map:westWall(cx, cy) then
			self.dir = Entity.DIR_LEFT
			self.moved = 0
		else
			self.dir = Entity.DIR_RIGHT
		end
	elseif self.dir == Entity.DIR_LEFT and map:westWall(cx, cy) then
		if not map:northWall(cx, cy) then
			self.dir = Entity.DIR_UP
			self.moved = 0
		else
			self.dir = Entity.DIR_DOWN
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

return Entity
