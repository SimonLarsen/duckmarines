local State = require("state")
local Map = require("map")
local Cursor = require("cursor")
local Menu = require("menu")
local LoadLevelState = require("loadLevelState")
local SaveLevelState = require("saveLevelState")
local ConfirmBoxState = require("confirmBoxState")
local MessageBoxState = require("messageBoxState")

local LevelEditorState = {}
LevelEditorState.__index = LevelEditorState
setmetatable(LevelEditorState, State)

LevelEditorState.STATE_TILE      = 0
LevelEditorState.STATE_ADD_FENCE = 1
LevelEditorState.STATE_REM_FENCE = 2

function LevelEditorState.create(parent)
	local self = setmetatable(State.create(), LevelEditorState)

	self.map = Map.create()

	self.state = LevelEditorState.STATE_TILE
	self.selection = 0
	self.lastx, self.lasty = 0,0
	self.tile = 0

	table.insert(self.inputs, KeyboardInput.create())
	table.insert(self.inputs, MouseInput.create(false))
	for i,v in ipairs(love.joystick.getJoysticks()) do
		table.insert(self.inputs, JoystickInput.create(v))
	end
	
	self.cursors[1] = Cursor.create(WIDTH/2, HEIGHT/2, 1)
	self.cursor = self.cursors[1]
	for i,v in ipairs(self.inputs) do
		self.cursors[1]:addInput(v)
	end

	self.marker = ResMgr.getImage("marker1.png")
	self.fence_marker = ResMgr.getImage("fence_marker.png")

	local imgButtons = ResMgr.getImage("editor_buttons.png")

	self.menu = Menu.create(0, 0, 0, 0, 0, self)
	self:addComponent(self.menu)
	local nq = love.graphics.newQuad

	-- File operations
	self.menu:addImageButton(imgButtons, nq(0,0,48,48,192,192), "new", 10,11,48,48)
	self.menu:addImageButton(imgButtons, nq(48,0,48,48,192,192), "save", 60,11,48,48)
	self.menu:addImageButton(imgButtons, nq(96,0,48,48,192,192), "load", 10,61,48,48)
	self.menu:addImageButton(imgButtons, nq(144,0,48,48,192,192), "exit", 60,61,48,48)

	-- Tile buttons
	for i=0,9 do
		local x = 10 + (i%2)*50
		local y = 122 + math.floor(i/2)*50
		local quad = nq(i%4*48,48+math.floor(i/4)*48,48,48,192,192)
		self.menu:addImageButton(imgButtons, quad, i, x, y, 48, 48)
	end

	-- Fence tools
	self.menu:addImageButton(imgButtons, nq(96,144,48,48,192,192), "fence_add", 10,384,48,48)
	self.menu:addImageButton(imgButtons, nq(144,144,48,48,192,192), "fence_delete", 60,384,48,48)

	self.loadDialog = LoadLevelState.create(self)
	self.saveDialog = SaveLevelState.create(self)

	return self
end

function LevelEditorState:update(dt)
	-- Place tiles and fences if an input is held down
	for i,v in ipairs(self.inputs) do
		if v:isDown() and self:cursorInMap() then
			if self.state == LevelEditorState.STATE_TILE then
				local cx = math.floor((self.cursor.x-121) / 48)
				local cy = math.floor((self.cursor.y-8) / 48)
				if self.map:getTile(cx,cy) ~= self.tile then
					self.map:setTile(cx,cy, self.tile)
					self.map:updateSpriteBatch(true)
				end
			elseif self.state == LevelEditorState.STATE_ADD_FENCE then
				cx = math.floor((self.cursor.x - 97)/48)
				cy = math.floor((self.cursor.y + 16)/48)
				if cx ~= self.lastx or cy ~= self.lasty then
					self:addFence(self.lastx, self.lasty, cx, cy)
					self.map:updateSpriteBatch(true)
				end
			elseif self.state == LevelEditorState.STATE_REM_FENCE then
				cx = math.floor((self.cursor.x - 97)/48)
				cy = math.floor((self.cursor.y + 16)/48)
				if cx ~= self.lastx or cy ~= self.lasty then
					self:removeFence(self.lastx, self.lasty, cx, cy)
					self.map:updateSpriteBatch(true)
				end
			end
			break
		end
	end

	-- Draw fence marker if cursor in map
	if self.state == LevelEditorState.STATE_ADD_FENCE
	or self.state == LevelEditorState.STATE_REM_FENCE then
		if self:cursorInMap() then
			self.lastx = math.floor((self.cursor.x - 97)/48)
			self.lasty = math.floor((self.cursor.y + 16)/48)
		end
	end
end

function LevelEditorState:draw()
	-- Draw map back layer
	love.graphics.draw(self.map:getBackBatch(), 121, 8)

	-- Draw tile marker
	if self:cursorInMap() then
		if self.state == LevelEditorState.STATE_TILE then
			local mx = math.floor((self.cursor.x-121) / 48)*48+121
			local my = math.floor((self.cursor.y-8) / 48)*48+8
			love.graphics.draw(self.marker, mx, my)
		elseif self.state == LevelEditorState.STATE_ADD_FENCE or
		self.state == LevelEditorState.STATE_REM_FENCE then
			love.graphics.draw(self.fence_marker, 117+self.lastx*48, self.lasty*48-3)
		end
	end

	-- Draw map front layer
	love.graphics.draw(self.map:getFrontBatch(), 121, 8)
end

function LevelEditorState:drawAfter()
	-- Draw menu selection marker
	if self.state == LevelEditorState.STATE_TILE then
		if self.selection <= 1 then
			love.graphics.draw(self.marker, 10+self.selection*50, 122)
		else
			love.graphics.draw(self.marker, 10+(self.selection % 2)*50, 122+math.floor(self.selection/2)*50)
		end
	elseif self.state == LevelEditorState.STATE_ADD_FENCE then
		love.graphics.draw(self.marker, 10, 384)
	elseif self.state == LevelEditorState.STATE_REM_FENCE then
		love.graphics.draw(self.marker, 60, 384)
	end
end

function LevelEditorState:cursorInMap()
	return self.cursor.x >= 121 and self.cursor.x <= WIDTH-4
	and self.cursor.y >= 8 and self.cursor.y <= HEIGHT-4
end

function LevelEditorState:addFence(x1, y1, x2, y2)
	-- Horizontal
	if y1 == y2 then
		local x = math.min(x1, x2)
		local val = self.map:getWall(x, y1)
		if val % 2 == 0 then
			self.map:setWall(x, y1, val+1)
		end
	-- Vertical
	elseif x1 == x2 then
		local y = math.min(y1, y2)
		local val = self.map:getWall(x1, y)
		if val < 2 then
			self.map:setWall(x1, y, val+2)
		end
	end
end

function LevelEditorState:removeFence(x1, y1, x2, y2)
	-- Horizontal
	if y1 == y2 then
		if y1 == 0 or y1 == 9 then return end

		local x = math.min(x1, x2)
		local val = self.map:getWall(x, y1)
		self.map:setWall(x, y1, val - (val%2))
	-- Vertical
	elseif x1 == x2 then
		if x1 == 0 or x1 == 12 then return end

		local y = math.min(y1, y2)
		local val = self.map:getWall(x1, y)
		self.map:setWall(x1, y, val%2)
	end
end

function LevelEditorState:buttonPressed(id, source)
	if type(id) == "number" then
		if id == 0 then
			self.tile = 0
		elseif id == 1 then
			self.tile = 2
		elseif id >= 2 and id <= 5 then
			self.tile = id+2
		else
			self.tile = id+4
		end
		self.selection = id
		self.state = LevelEditorState.STATE_TILE
		playSound("click")
	else
		if id == "new" then
			playSound("quack");
			pushState(ConfirmBoxState.create(self, "CLEAR MAP?",
				function()
					self.map:clear()
					self.map:updateSpriteBatch(true)
				end)
			)
			self.loadDialog = LoadLevelState.create(self)
			self.saveDialog = SaveLevelState.create(self)
		elseif id == "save" then
			playSound("quack");
			local valid, msg = self.map:verify()
			if valid == true then
				self.saveDialog:updateFileList()
				pushState(self.saveDialog)
			else
				pushState(MessageBoxState.create(self, msg))
			end
		elseif id == "load" then
			playSound("quack");
			self.loadDialog:updateFileList()
			pushState(self.loadDialog)
		elseif id == "exit" then
			playSound("quack");
			pushState(ConfirmBoxState.create(self, "ARE YOU SURE YOU WANT TO QUIT?",
				function()
					popState()
				end)
			)
		elseif id == "fence_add" then
			self.state = LevelEditorState.STATE_ADD_FENCE
			playSound("click")
		elseif id == "fence_delete" then
			playSound("click")
			self.state = LevelEditorState.STATE_REM_FENCE
		end
	end
end

return LevelEditorState
