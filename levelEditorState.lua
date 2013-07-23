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
	self.tile = 2

	self.inputs = {}
	self.inputs[1] = KeyboardInput.create()
	self.inputs[2] = MouseInput.create()
	self.inputs[3] = JoystickInput.create(1)

	self.cursor = Cursor.create(WIDTH/2, HEIGHT/2, 1)
	self.marker = ResMgr.getImage("marker1.png")

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
		if v:isDown() then
			if self.state == LevelEditorState.STATE_TILE and self:cursorInMap() then
				local cx = math.floor((self.cursor.x-121) / 48)
				local cy = math.floor((self.cursor.y-8) / 48)
				if self.map:getTile(cx,cy) ~= self.tile then
					self.map:setTile(cx,cy, self.tile)
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
				self.state = LevelEditorState.STATE_TILE
				if self.cursor.y >= 122 and self.cursor.y <= 369 then
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
				end
			end
			break
		end
	end
end

function LevelEditorState:draw()
	love.graphics.push()
	love.graphics.translate(121, 8)

	-- Draw map back layer
	love.graphics.draw(self.map:getBackBatch(), 0, 0)

	-- Draw tile marker
	if self.state == LevelEditorState.STATE_TILE and self:cursorInMap() then
		local mx = math.floor((self.cursor.x-121) / 48)*48
		local my = math.floor((self.cursor.y-8) / 48)*48
		love.graphics.draw(self.marker, mx, my)
	end

	-- Draw map front layer
	love.graphics.draw(self.map:getFrontBatch(), 0, 0)

	love.graphics.pop()

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

	-- Draw cursor
	self.cursor:getDrawable():draw(self.cursor.x, self.cursor.y)
end

function LevelEditorState:cursorInMap()
	return self.cursor.x >= 121 and self.cursor.x <= WIDTH-4 and self.cursor.y >= 8 and self.cursor.y <= HEIGHT-4
end
