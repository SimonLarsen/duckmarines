Map = {}
Map.__index = Map

function Map.create(name)
	local self = setmetatable({}, Map)

	self.batch = love.graphics.newSpriteBatch(ResMgr.getImage("tiles.png"), 256)
	self.data = love.filesystem.load("res/maps/"..name..".lua")()

	self:updateSpriteBatch()

	return self
end

function Map:updateSpriteBatch()
	-- Ground tiles
	local groundQuad = love.graphics.newQuad(144, 432, 48, 48, 512, 512)
	self.batch:addq(groundQuad, 0, 0, 0, 12, 9)
	-- Tiles
	local quad = love.graphics.newQuad(0, 0, 0, 0, 512, 512)
	for iy = 0, 8 do
		for ix = 0, 11 do
			local tile = self:getTile(ix, iy)
			if tile > 0 then
				local cx = (tile % 10) * 48
				local cy = 0
				if tile > 0 then
					cy = math.floor(tile / 10) * 48
				end
				quad:setViewport(cx, cy, 48, 48)
				self.batch:addq(quad, ix*48, iy*48)
			end
		end
	end

	-- Fences
	local postQuad = love.graphics.newQuad(0, 432, 6, 10, 512, 512)
	local fenceHorzQuad = love.graphics.newQuad(48, 432, 48, 5, 512, 512)
	local fenceVertQuad = love.graphics.newQuad(96, 432, 4, 48, 512, 512)
	for iy = 0, 9 do
		for ix = 0, 12 do
			if self:getWall(ix, iy) == 1 then
				-- Right fence
				if ix < 12 and self:getWall(ix+1, iy) == 1 then
					self.batch:addq(fenceHorzQuad, ix*48, iy*48-5)
				end
				-- Downwards fence
				if iy < 9 and self:getWall(ix, iy+1) == 1 then
					self.batch:addq(fenceVertQuad, ix*48-2, iy*48-3)
				end
				-- Post
				self.batch:addq(postQuad, ix*48-3, iy*48-8)
			end
		end
	end
end

function Map:getTile(x, y)
	return self.data.tiles[x + y*12 +1]
end

function Map:getWall(x, y)
	return self.data.walls[x + y*13 + 1]
end

function Map:northWall(x, y)
	return self:getWall(x, y) == 1 and self:getWall(x+1, y) == 1
end

function Map:southWall(x, y)
	return self:getWall(x, y+1) == 1 and self:getWall(x+1, y+1) == 1
end

function Map:westWall(x, y)
	return self:getWall(x, y) == 1 and self:getWall(x, y+1) == 1
end

function Map:eastWall(x, y)
	return self:getWall(x+1, y) == 1 and self:getWall(x+1, y+1) == 1
end

function Map:getDrawable()
	return self.batch
end
