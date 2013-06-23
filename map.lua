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
	-- Tiles
	local quad = love.graphics.newQuad(0, 0, 0, 0, 512, 512)
	for iy = 0, 8 do
		for ix = 0, 11 do
			local tile = self.data.tiles[ix+iy*12+1]
			local cx = (tile % 10) * 48
			local cy = 0
			if tile > 0 then
				cy = math.floor(tile / 10) * 48
			end
			quad:setViewport(cx, cy, 48, 48)
			self.batch:addq(quad, ix*48, iy*48)
		end
	end

	-- Fences
	local postQuad = love.graphics.newQuad(0, 432, 6, 10, 512, 512)
	local fenceHorzQuad = love.graphics.newQuad(48, 432, 48, 5, 512, 512)
	local fenceVertQuad = love.graphics.newQuad(96, 432, 4, 48, 512, 512)
	for iy = 0, 9 do
		for ix = 0, 12 do
			if self.data.walls[ix+iy*13+1] == 1 then
				-- Right fence
				if ix < 12 and self.data.walls[ix+iy*13+2] == 1 then
					self.batch:addq(fenceHorzQuad, ix*48, iy*48-5)
				end
				-- Downwards fence
				if iy < 9 and self.data.walls[ix+(iy+1)*13+1] == 1 then
					self.batch:addq(fenceVertQuad, ix*48-2, iy*48-3)
				end
				-- Post
				self.batch:addq(postQuad, ix*48-3, iy*48-8)
			end
		end
	end
end

function Map:getDrawable()
	return self.batch
end
