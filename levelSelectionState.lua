LevelSelectionState = {}
LevelSelectionState.__index = LevelSelectionState
setmetatable(LevelSelectionState, State)

function LevelSelectionState.create(parent)
	local self = setmetatable(State.create(), LevelSelectionState)

	self.inputs = parent.inputs
	self.cursor = Cursor.create(WIDTH/2, HEIGHT/2, 1)
	self.rules = Rules.create()

	self.bg = ResMgr.getImage("bg_stars.png")
	self.imgBlueprint = ResMgr.getImage("blueprint.png")
	self.imgDogear = ResMgr.getImage("blueprint_dogear.png")
	self.imgPreview = ResMgr.getImage("preview_assets.png")
	self.imgTexture = ResMgr.getImage("blueprint_texture.png")
	self.batch = love.graphics.newSpriteBatch(self.imgPreview, 128)

	self.list = SelectionList.create(WIDTH/2-295, 62, 260, 15, 21, self)
	self:updateMapList()
	self.list:setSelection(1)

	self.menu = Menu.create(WIDTH/2, 300, 298, 32, 10, self)
	self.menu:addButton("START GAME", "start")
	self.menu:addButton("ADVANCED SETTINGS", "advanced")
	self.menu:addButton("BACK", "back")

	self:addComponent(self.list)
	self:addComponent(self.menu)

	return self
end

function LevelSelectionState:update(dt)
	for i,v in ipairs(self:getInputs()) do
		if v:wasClicked() then
			for j,c in ipairs(self:getComponents()) do
				c:click(self.cursor.x, self.cursor.y)
			end
		end
		self.cursor:move(v:getMovement(dt, false))
	end
end

function LevelSelectionState:draw()
	love.graphics.draw(self.bg, 0, 0)

	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", WIDTH/2, 62, 297, 228)
	love.graphics.setColor(255, 194, 49)
	love.graphics.rectangle("line", WIDTH/2+0.5, 62.5, 297, 228)
	love.graphics.setColor(255,255,255)

	love.graphics.draw(self.imgBlueprint, WIDTH/2+8, 70)
	love.graphics.draw(self.batch, WIDTH/2+11, 73)
	love.graphics.draw(self.imgDogear, WIDTH/2+265, 70)
	love.graphics.setBlendMode("multiplicative")
	love.graphics.draw(self.imgTexture, WIDTH/2+11, 73)
	love.graphics.setBlendMode("alpha")

	love.graphics.setFont(ResMgr.getFont("menu"))
	love.graphics.printf("SELECT A LEVEL", 0, 25, WIDTH, "center")

	self.list:draw()
	self.menu:draw()
	self.cursor:draw()
end

function LevelSelectionState:buttonPressed(id, source)
	if id == "advanced" then
		pushState(AdvancedSettingsState.create(self, self.rules))
	elseif id == "start" then
		popState()
		popState()
		pushState(IngameState.create(self, self:getFilename(), self.rules))
	elseif id == "back" then
		popState()
	end
end

function LevelSelectionState:getFilename()
	local text = self.list:getText():lower()
	if text:sub(1,8) == "custom: " then
		return "usermaps/" .. text:sub(9)
	else
		return "res/maps/" .. text
	end
end

function LevelSelectionState:updateMapList()
	local items = {}
	local files = love.filesystem.enumerate("res/maps")
	for i,v in ipairs(files) do
		table.insert(items, v:upper())
	end
	files = love.filesystem.enumerate("usermaps")
	for i,v in ipairs(files) do
		table.insert(items, "CUSTOM: " .. v:upper())
	end
	self.list:setItems(items)
end

function LevelSelectionState:selectionChanged(text, source)
	self.batch:clear()
	local quadSub = love.graphics.newQuad(0, 23, 23, 22, 78, 63)
	local quadPit = love.graphics.newQuad(0, 0, 23, 23, 78, 63)
	local quadFenceHor = love.graphics.newQuad(23, 0, 28, 5, 78, 63)
	local quadFenceVer = love.graphics.newQuad(35, 7, 5, 28, 78, 63)
	local quadSpawnUp = love.graphics.newQuad(44, 23, 25, 18, 78, 63)
	local quadSpawnRight = love.graphics.newQuad(32, 48, 32, 11, 78, 63)
	local quadSpawnDown = love.graphics.newQuad(1, 45, 25, 18, 78, 63)
	local quadSpawnLeft = love.graphics.newQuad(46, 7, 32, 11, 78, 63)

	local map = Map.create(self:getFilename())
	-- Add tiles
	for iy=0,8 do
		for ix=0,11 do
			local tile = map:getTile(ix, iy)
			if tile >= 10 and tile <= 14 then
				self.batch:addq(quadSub, ix*23, iy*23+1)
			elseif tile == 2 then
				self.batch:addq(quadPit, ix*23, iy*23)
			elseif tile == 4 then
				self.batch:addq(quadSpawnUp, ix*23-1, iy*23+2)
			elseif tile == 5 then
				self.batch:addq(quadSpawnRight, ix*23-1, iy*23+9)
			elseif tile == 6 then
				self.batch:addq(quadSpawnDown, ix*23-1, iy*23+9)
			elseif tile == 7 then
				self.batch:addq(quadSpawnLeft, ix*23-8, iy*23+9)
			end
		end
	end
	-- Add fences
	for iy=0,8 do
		for ix=0,11 do
			local wall = map:getWall(ix, iy)
			if iy > 0 and wall % 2 == 1 then
				self.batch:addq(quadFenceHor, ix*23-3, iy*23-3)
			end
			if ix > 0 and wall > 1 then
				self.batch:addq(quadFenceVer, ix*23-3, iy*23-3)
			end
		end
	end
end
