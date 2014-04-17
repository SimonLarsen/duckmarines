local Map = require("map")

local Entity = require("entity")

local Bot = {}
Bot.__index = Bot 

Bot.INFINITY = 99999999
Bot.SPEED = 300
Bot.DIST_THRESHOLD = 24
Bot.MOVE_DELAY = 2
Bot.CHECK_DELAY = 0.05

function Bot.create(map,player,cursor)
	local self = setmetatable({}, Bot)

	self.player = player
	self.cursor = cursor
	self.movecooldown = 0
	self.checkcooldown = 0

	self.path = {}
	self.allpath = {}
	self:buildGraph(map)

	return self
end

function Bot:update(dt, map, entities, arrows)
	self.movecooldown = self.movecooldown - dt
	self.checkcooldown = self.checkcooldown - dt

	if #self.path == 0 and self.movecooldown <= 0 and self.checkcooldown <= 0 then
		self.checkcooldown = Bot.CHECK_DELAY
		local e = table.random(entities)
		if e == nil then return end

		local cx = math.floor(e.x / 48)
		local cy = math.floor(e.y / 48)
		local subs = map:getSubmarines()

		if e:getType() == Entity.TYPE_ENEMY then
			local v = table.random(subs)
			if v.player ~= self.player then
				self.path = self:findPath(cx, cy, v.x, v.y, e.dir, map, arrows)
			end
		else
			for i,v in ipairs(subs) do
				if v.player == self.player then
					self.path = self:findPath(cx, cy, v.x, v.y, e.dir, map, arrows)
				end
			end
		end

		if #self.path > 0 then
			self.movecooldown = Bot.MOVE_DELAY
		end
	end
end

function Bot:getMovement(dt, cursor)
	if self.path[1] then
		local p = self.path[1]
		local dx = p.x*48+24 - cursor.x
		local dy = p.y*48+24 - cursor.y
		local len = math.sqrt(dx^2 + dy^2)
		dx = dx/len * dt * Bot.SPEED
		dy = dy/len * dt * Bot.SPEED
		return dx, dy
	end
	return nil
end

function Bot:getAction(cursor)
	local p = self.path[1]

	if p == nil then return nil end

	local dx = p.x*48+24 - cursor.x
	local dy = p.y*48+24 - cursor.y
	local sqdist = dx^2 + dy^2
	if sqdist < Bot.DIST_THRESHOLD then
		table.remove(self.path, 1)
		return p.dir
	end
	return nil
end

function Bot:buildGraph(map)
	-- Build graph table
	self.graph = {}
	for ix=0,11 do
		self.graph[ix] = {}
		for iy=0,8 do
			self.graph[ix][iy] = {x=ix, y=iy}
		end
	end
	-- Add neighbors
	for ix=0,11 do
		for iy=0,8 do
			local node = self.graph[ix][iy]
			node.neighbors = {}
			if ix > 0 and map:westWall(ix,iy) == false then
				table.insert(node.neighbors, self.graph[ix-1][iy])
			end
			if ix < 11 and map:eastWall(ix,iy) == false then
				table.insert(node.neighbors, self.graph[ix+1][iy])
			end
			if iy > 0 and map:northWall(ix,iy) == false then
				table.insert(node.neighbors, self.graph[ix][iy-1])
			end
			if iy < 8 and map:southWall(ix,iy) == false then
				table.insert(node.neighbors, self.graph[ix][iy+1])
			end
		end
	end
end

function Bot:clearGraph(map, arrows)
	for ix=0,11 do
		for iy=0,8 do
			self.graph[ix][iy].dist = Bot.INFINITY
			self.graph[ix][iy].prev = nil
			self.graph[ix][iy].hasArrow = false
			self.graph[ix][iy].isSink = false

			local tile = map:getTile(ix, iy)
			if tile == Map.TILE_HOLE or (tile >= Map.TILE_SUBMARINE_RED and tile <= Map.TILE_SUBMARINE_PURPLE) then
				self.graph[ix][iy].isSink = true
			end
		end
	end

	for i=1,4 do
		for j,v in ipairs(arrows[i]) do
			self.graph[v.x][v.y].hasArrow = true
			self.graph[v.x][v.y].arrowdir = v.dir
		end
	end
end

function Bot:findPath(x1, y1, x2, y2, dir, map, arrows)
	self:clearGraph(map, arrows)

	local Q = {}
	for ix=0,11 do
		for iy=0,8 do
			table.insert(Q, self.graph[ix][iy])
		end
	end
	
	-- Initialize root
	self.graph[x1][y1].dist = 0
	self.graph[x1][y1].dir = dir

	while #Q > 0 do
		-- Find min dist node
		local u = Q[1]
		local minindex = 1
		for i,v in ipairs(Q) do
			if v.dist < u.dist then
				u = v
				minindex = i
			end
		end
		table.remove(Q, minindex)

		if u.dist == Bot.INFINITY then
			break
		end
		
		if u.isSink == false then
			for i,v in ipairs(u.neighbors) do
				if u.hasArrow == false then
					self:relax(u, v)
				elseif u.hasArrow == true and self:getDir(u, v) == u.arrowdir then
					self:relax(u, v)
				end
			end
		end
	end

	-- Backtrace from destination
	local path = {}
	self.allpath = {}
	local u = self.graph[x2][y2]

	if u.dist == Bot.INFINITY then
		return {}
	end

	while u do
		if u.prev then
			if u.prev.hasArrow == false and u.dir ~= u.prev.dir then
				table.insert(path, 1, {x=u.prev.x, y=u.prev.y, dir=u.dir})
			end
		end
		table.insert(self.allpath, 1, {x=u.x, y=u.y})
		u = u.prev
	end

	return path
end

function Bot:relax(u, v)
	local alt = u.dist + self:getCost(u, v, u.dir)
	if alt < v.dist then
		v.dist = alt
		v.prev = u
		v.dir = self:getDir(u, v)
	end
end

function Bot:getCost(u, v, dir)
	if dir == self:getDir(u, v) then
		return 1
	else
		return 100
	end
end

function Bot:getDir(u, v)
	if u.x == v.x then
		if v.y < u.y then
			return 0
		else
			return 2
		end
	end
	if u.y == v.y then
		if v.x < u.x then
			return 3
		else
			return 1
		end
	end
	return -1
end

function Bot:drawPath()
	local colors = {
		{191,49,63}, {56,54,136}, {255,130,46}, {119,56,130}
	}
	love.graphics.setColor(unpack(colors[self.player]))
	for i=1, #self.allpath-1 do
		local p1 = self.allpath[i]
		local p2 = self.allpath[i+1]
		love.graphics.line(p1.x*48+24, p1.y*48+24, p2.x*48+24, p2.y*48+24)
	end
	love.graphics.setColor(255,255,255,255)
end

return Bot
