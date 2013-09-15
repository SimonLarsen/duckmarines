PauseGameState = {}
PauseGameState.__index = PauseGameState
setmetatable(PauseGameState, State)

function PauseGameState.create(parent)
	local self = setmetatable(State.create(), PauseGameState)

	self.menu = Menu.create((WIDTH-200)/2, 168, 200, 32, 24, self)
	self.menu:addButton("CONTINUE", "continue")
	self.menu:addButton("RESTART", "restart")
	self.menu:addButton("QUIT", "quit")
	self:addComponent(self.menu)

	self.inputs = {}
	for i=1,4 do
		if parent.inputs[i]:getType() == Input.TYPE_BOT then
			self.inputs[i] = NullInput.create()
		else
			self.inputs[i] = parent.inputs[i]
		end
	end
	self.cursor = Cursor.create(WIDTH/2, HEIGHT/2, 1)

	self.mapname = parent.mapname
	self.rules = parent.rules

	return self
end

function PauseGameState:update(dt)
	for i,v in ipairs(self:getInputs()) do
		if v:wasClicked() then
			for j,c in ipairs(self:getComponents()) do
				c:click(self.cursor.x, self.cursor.y)
			end
		end
		self.cursor:move(v:getMovement(dt, false))
	end
end

function PauseGameState:draw()
	love.graphics.setColor(0, 0, 0, 128)
	love.graphics.rectangle("fill", 0, 0, WIDTH, HEIGHT)
	love.graphics.setColor(255,255,255,255)
	love.graphics.setFont(ResMgr.getFont("menu"))
	love.graphics.printf("PAUSED", 0, 104, WIDTH, "center")

	self.menu:draw()
	self.cursor:draw()
end

function PauseGameState:buttonPressed(id, source)
	if id == "continue" then
		popState()
	elseif id == "restart" then
		popState()
		popState()
		pushState(IngameState.create(self, self.mapname, self.rules))
	elseif id == "quit" then
		popState()
		popState()
		pushState(LevelSelectionState.create(self))
	end
end

function PauseGameState:isTransparent()
	return true
end
