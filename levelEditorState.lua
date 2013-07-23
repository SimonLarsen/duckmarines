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

	return self
end

function LevelEditorState:update(dt)
	for i,v in ipairs(self.inputs) do
		self.cursor:move(v:getMovement(dt))
	end

	for i,v in ipairs(self.inputs) do
		if v:isDown() then
			if self.state == LevelEditorState.STATE_TILE then
				local cx = math.floor(self.cursor.x / 48)
				local cy = math.floor(self.cursor.y / 48)
				if self.map:getTile(cx,cy) ~= self.tile then
					self.map:setTile(cx,cy, self.tile)
					self.map:updateSpriteBatch()
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
	if self.state == LevelEditorState.STATE_TILE then
		local mx = math.floor(self.cursor.x / 48)*48
		local my = math.floor(self.cursor.y / 48)*48
		love.graphics.draw(self.marker, mx, my)
	end

	-- Draw map front layer
	love.graphics.draw(self.map:getFrontBatch(), 0, 0)

	-- Draw cursor
	self.cursor:getDrawable():draw(self.cursor.x, self.cursor.y)

	love.graphics.pop()
end
