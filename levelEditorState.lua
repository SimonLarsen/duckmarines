LevelEditorState = {}
LevelEditorState.__index = LevelEditorState
setmetatable(LevelEditorState, State)

function LevelEditorState.create()
	local self = setmetatable({}, LevelEditorState)

	self.map = Map.create()

	self.inputs = {}
	self.inputs[1] = KeyboardInput.create()
	self.inputs[2] = MouseInput.create()
	self.inputs[3] = JoystickInput.create(1)

	self.cursor = Cursor.create(WIDTH/2, HEIGHT/2, 1)
	self.marker = ResMgr.getImage("marker1.png")

	return self
end

function LevelEditorState:update(dt)
	for i,v in ipairs(self.inputs) do
		self.cursor:move(v:getMovement(dt))
	end
end

function LevelEditorState:draw()
	love.graphics.push()
	love.graphics.translate(121, 8)

	-- Draw map back layer
	love.graphics.draw(self.map:getBackBatch(), 0, 0)

	-- Draw tile marker
	local mx = math.floor(self.cursor.x / 48)*48
	local my = math.floor(self.cursor.y / 48)*48
	love.graphics.draw(self.marker, mx, my)

	-- Draw map front layer
	love.graphics.draw(self.map:getFrontBatch(), 0, 0)

	self.cursor:getDrawable():draw(self.cursor.x, self.cursor.y)

	love.graphics.pop()
end
