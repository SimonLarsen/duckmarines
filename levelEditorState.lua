LevelEditorState = {}
LevelEditorState.__index = LevelEditorState
setmetatable(LevelEditorState, State)

LevelEditorState.STATE_TILE      = 0
LevelEditorState.STATE_ADD_FENCE = 1
LevelEditorState.STATE_REM_FENCE = 2

function LevelEditorState.create()
	local self = setmetatable({}, LevelEditorState)

	self.map = Map.create()

	self.state = LevelEditorState.STATE_TILE
	self.selection = 0
	self.lastx, self.lasty = 0,0
	self.tile = 0

	self.inputs = {}
	self.inputs[1] = KeyboardInput.create()
	self.inputs[2] = MouseInput.create()
	self.inputs[3] = JoystickInput.create(1)

	self.cursor = Cursor.create(WIDTH/2, HEIGHT/2, 1)
	self.marker = ResMgr.getImage("marker1.png")
	self.fence_marker = ResMgr.getImage("fence_marker.png")

	self.buttons = ResMgr.getImage("editor_buttons.png")
	self.buttonQuad = {}
	for iy=0,3 do
		for ix=0,3 do
			self.buttonQuad[ix+iy*4] = love.graphics.newQuad(ix*48, iy*48, 48, 48, 192, 192)
		end
	end

	return self
end

function LevelEditorState:update(dt)
	for i,v in ipairs(self.inputs) do
		self.cursor:move(v:getMovement(dt))
	end

	-- Draw tiles and fences if an input is held down
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
	-- Check for clicks in the HUD
	for i,v in ipairs(self.inputs) do
		if v:wasClicked() then
			-- Check if in menu area
			if self.cursor.x >= 10 and self.cursor.x <= 107 then
				-- In tile selection area
				if self.cursor.y >= 122 and self.cursor.y <= 369 then
					self.state = LevelEditorState.STATE_TILE
					local id = math.floor((self.cursor.x-10) / 50)
						+ math.floor((self.cursor.y-122) / 50)*2
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
				-- Fence tool area
				elseif self.cursor.y >= 384 and self.cursor.y <= 431 then
					if self.cursor.x <= 58 then
						self.state = LevelEditorState.STATE_ADD_FENCE
					else
						self.state = LevelEditorState.STATE_REM_FENCE
					end
				-- File menu
				elseif self.cursor.y >= 11 and self.cursor.y <= 108 then
					if self.cursor.y <= 59 then
						-- New file
						if self.cursor.x <= 58 then
						-- Save file
						else
							local valid, msg = self.map:verify()
							if valid == true then
								local strdata = self.map:pack()
								love.filesystem.write("usermaps/custom.lua", strdata)
							else
								print("error: " .. msg)
							end
						end
					else
						-- Open file
						if self.cursor.x <= 58 then
						-- Quit editor
						else
						end
					end
				end
			end
			break
		end
	end
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

	-- Draw buttons
	-- Menu buttons
	for iy=0,1 do
		for ix=0,1 do
			love.graphics.drawq(self.buttons, self.buttonQuad[ix+iy*2], 10+ix*50, 11+iy*50)
		end
	end
	-- Tile buttons
	for iy=0,4 do
		for ix=0,1 do
			love.graphics.drawq(self.buttons, self.buttonQuad[4+ix+iy*2], 10+ix*50, 122+iy*50)
		end
	end
	love.graphics.drawq(self.buttons, self.buttonQuad[14], 10, 384)
	love.graphics.drawq(self.buttons, self.buttonQuad[15], 60, 384)

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

	-- Draw cursor
	self.cursor:getDrawable():draw(self.cursor.x, self.cursor.y)
end

function LevelEditorState:cursorInMap()
	return self.cursor.x >= 121 and self.cursor.x <= WIDTH-4 and self.cursor.y >= 8 and self.cursor.y <= HEIGHT-4
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
