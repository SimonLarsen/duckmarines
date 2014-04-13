require("Tserial")

local Map = {}
Map.__index = Map

Map.TILE_EMPTY			= 0
Map.TILE_HOLE 			= 2

Map.TILE_SPAWNER		= 3
Map.TILE_SPAWNER_UP 	= 4
Map.TILE_SPAWNER_RIGHT 	= 5
Map.TILE_SPAWNER_DOWN	= 6
Map.TILE_SPAWNER_LEFT	= 7

Map.TILE_SUBMARINE_RED    = 10
Map.TILE_SUBMARINE_BLUE   = 11
Map.TILE_SUBMARINE_ORANGE = 12
Map.TILE_SUBMARINE_PURPLE = 13

function Map.create(name)
	local self = setmetatable({}, Map)

	self.backBatch  = love.graphics.newSpriteBatch(ResMgr.getImage("tiles.png"), 256)
	self.frontBatch = love.graphics.newSpriteBatch(ResMgr.getImage("tiles.png"), 512)
	if name ~= nil then
		local strdata = love.filesystem.read(name)
		self.data = TSerial.unpack(strdata, true)
	else
		self.data = {}
		self.data.tiles = {}
		self.data.walls = {}
		self:clear()
	end
	self.spawns = self:findSpawnPoints()
	self.submarines = self:findSubmarines()

	self:updateSpriteBatch()

	return self
end

function Map:updateSpriteBatch(debug)
	debug = debug or false

	self.frontBatch:clear()
	self.backBatch:clear()
	-- Ground tiles
	local groundQuad1 = love.graphics.newQuad(144, 432, 48, 48, 512, 512)
	local groundQuad2 = love.graphics.newQuad(192, 432, 48, 48, 512, 512)
	-- Tiles
	local quad = love.graphics.newQuad(0, 0, 0, 0, 512, 512)
	for iy = 0, 8 do
		for ix = 0, 11 do
			if (ix+iy) % 2 == 1 then
				self.backBatch:add(groundQuad1, ix*48, iy*48)
			else
				self.backBatch:add(groundQuad2, ix*48, iy*48)
			end

			local tile = self:getTile(ix, iy)
			if tile > 0 then
				if tile >= Map.TILE_SPAWNER_UP
				and tile <= Map.TILE_SPAWNER_LEFT and not debug then
					tile = Map.TILE_SPAWNER
				end

				local cx = (tile % 10) * 48
				local cy = math.floor(tile / 10) * 48
				quad:setViewport(cx, cy, 48, 48)
				self.backBatch:add(quad, ix*48, iy*48)
			end
		end
	end

	-- Fences
	local postQuad = love.graphics.newQuad(0, 432, 6, 10, 512, 512)
	local fenceHorzQuad = love.graphics.newQuad(48, 432, 48, 5, 512, 512)
	local fenceVertQuad = love.graphics.newQuad(96, 432, 4, 48, 512, 512)
	for iy = 0, 9 do
		for ix = 0, 12 do
			local wall = self:getWall(ix, iy)
			if wall > 0 then
				-- Right fence
				if ix < 12 and wall % 2 == 1 then
					self.frontBatch:add(fenceHorzQuad, ix*48, iy*48-5)
					if self:getWall(ix+1, iy) == 0 then
						self.frontBatch:add(postQuad, ix*48+45, iy*48-8)
					end
				end
				-- Downwards fence
				if iy < 9 and wall > 1 then
					self.frontBatch:add(fenceVertQuad, ix*48-2, iy*48-3)
					if self:getWall(ix, iy+1) == 0 then
						self.frontBatch:add(postQuad, ix*48-3, iy*48+40)
					end
				end
				-- Post
				self.frontBatch:add(postQuad, ix*48-3, iy*48-8)
			end
		end
	end
end

function Map:getTile(x, y)
	return self.data.tiles[x + y*12 +1]
end

function Map:setTile(x, y, id)
	self.data.tiles[x + y*12 + 1] = id
end

function Map:getWall(x, y)
	return self.data.walls[x + y*13 + 1]
end

function Map:setWall(x, y, val)
	self.data.walls[x + y*13 + 1] = val
end

function Map:getSpawnPoints()
	return self.spawns
end

function Map:findSpawnPoints()
	local spawns = {}
	for iy=0,8 do
		for ix=0,11 do
			local tile = self:getTile(ix, iy)
			if tile >= 4 and tile <= 7 then
				local e = {}
				e.x = ix
				e.y = iy
				e.dir = tile - 4
				table.insert(spawns, e)
			end
		end
	end
	return spawns
end

function Map:getSubmarines()
	return self.submarines
end

function Map:findSubmarines()
	local submarines = {}
	for iy=0,8 do
		for ix=0,11 do
			local tile = self:getTile(ix, iy)
			if tile >= 10 and tile <= 13 then
				local e = {}
				e.x = ix
				e.y = iy
				e.player = tile - 9
				table.insert(submarines, e)
			end
		end
	end
	return submarines
end

function Map:shuffleSubmarines()
	local subs = self.submarines
	for i=#subs, 2, -1 do
		local j = math.random(1, i)
		-- Swap tiles
		local tilei = self:getTile(subs[i].x, subs[i].y)
		local tilej = self:getTile(subs[j].x, subs[j].y)
		self:setTile(subs[i].x, subs[i].y, tilej)
		self:setTile(subs[j].x, subs[j].y, tilei)
		-- Swap in array
		subs[i], subs[j] = subs[j], subs[i]
	end
	self:updateSpriteBatch()
	self.submarines = self:findSubmarines()
end

function Map:clear()
	for iy=0,8 do
		for ix=0,11 do
			self:setTile(ix, iy, 0)
		end
	end
	for iy=0,9 do
		for ix=0,12 do
			if ix == 0 or ix == 12 then
				self:setWall(ix, iy, 2)
			elseif iy == 0 or iy == 9 then
				self:setWall(ix, iy, 1)
			else
				self:setWall(ix, iy, 0)
			end
		end
	end
	self:setWall( 0,0, 3)
	self:setWall( 0,9, 1)
	self:setWall(12,0, 2)
	self:setWall(12,9, 0)
end

function Map:verify()
	local subsFound = {0, 0, 0, 0}
	local spawnerFound = false
	for iy = 0,8 do
		for ix=0,11 do
			local t = self:getTile(ix, iy)
			-- Check submarines
			if t >= 4 and t <= 7 then
				spawnerFound = true
			elseif t >= 10 and t <= 13 then
				subsFound[t-9] = subsFound[t-9]+1
			end
		end
	end

	-- Check if map contains at least one spawner
	if spawnerFound == false then
		return false, "MAP SHOULD CONTAIN AT LEAST ONE SPAWNER"
	end
	-- Check if all four subs are represented once
	for i=1,4 do
		if subsFound[i] ~= 1 then
			return false, "MAP SHOULD CONTAIN ONE OF EACH SUBMARINE"
		end
	end

	return true
end

function Map:pack()
	local data = {}
	data.tiles = self.data.tiles
	data.walls = self.data.walls
	return TSerial.pack(data)
end

function Map:northWall(x, y)
	return self:getWall(x, y) % 2 > 0
end

function Map:southWall(x, y)
	return self:getWall(x, y+1) % 2 > 0
end

function Map:westWall(x, y)
	return self:getWall(x, y) > 1
end

function Map:eastWall(x, y)
	return self:getWall(x+1, y) > 1
end

function Map:getFrontBatch()
	return self.frontBatch
end

function Map:getBackBatch()
	return self.backBatch
end

return Map
