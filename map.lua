Map = {}
Map.__index = Map

function Map.create(name)
	local self = setmetatable({}, Map)

	self.backBatch  = love.graphics.newSpriteBatch(ResMgr.getImage("tiles.png"), 128)
	self.frontBatch = love.graphics.newSpriteBatch(ResMgr.getImage("tiles.png"), 128)
	if name ~= nil then
		self.data = love.filesystem.load("res/maps/"..name..".lua")()
	else
		self.data = {}
		self.data.tiles = {}
		self.data.walls = {}
		self:clearMap()
	end
	self.spawns = self:findSpawnPoints()
	self.submarines = self:findSubmarines()

	self:updateSpriteBatch()

	return self
end

function Map:updateSpriteBatch()
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
				self.backBatch:addq(groundQuad1, ix*48, iy*48)
			else
				self.backBatch:addq(groundQuad2, ix*48, iy*48)
			end

			local tile = self:getTile(ix, iy)
			if tile > 0 then
				if tile >= 5 and tile <= 7 then
					tile = 3
				end

				local cx = (tile % 10) * 48
				local cy = 0
				if tile > 0 then
					cy = math.floor(tile / 10) * 48
				end
				quad:setViewport(cx, cy, 48, 48)
				self.backBatch:addq(quad, ix*48, iy*48)
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
					self.frontBatch:addq(fenceHorzQuad, ix*48, iy*48-5)
					if self:getWall(ix+1, iy) == 0 then
						self.frontBatch:addq(postQuad, ix*48+45, iy*48-8)
					end
				end
				-- Downwards fence
				if iy < 9 and wall > 1 then
					self.frontBatch:addq(fenceVertQuad, ix*48-2, iy*48-3)
					if self:getWall(ix, iy+1) == 0 then
						self.frontBatch:addq(postQuad, ix*48-3, iy*48+40)
					end
				end
				-- Post
				self.frontBatch:addq(postQuad, ix*48-3, iy*48-8)
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
			if tile >= 10 and tile <= 14 then
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

function Map:clearMap()
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
