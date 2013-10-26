MainMenuState = {}
MainMenuState.__index = MainMenuState
setmetatable(MainMenuState, State)

function MainMenuState.create(config)
	local self = setmetatable(State.create(), MainMenuState)

	self.config = config

	self.inputs[1] = KeyboardInput.create()
	self.inputs[2] = JoystickInput.create(1)
	self.inputs[3] = JoystickInput.create(2)
	self.inputs[4] = JoystickInput.create(3)
	self.inputs[5] = JoystickInput.create(4)
	
	self.cursor = Cursor.create(WIDTH/2, HEIGHT/2, 1)

	self.menu = Menu.create((WIDTH-200)/2, 190, 220, 32, 24, self)
	self.menu:addButton("START GAME", "start")
	self.menu:addButton("OPTIONS", "options")
	self.menu:addButton("LEVEL EDITOR", "editor")
	self.menu:addButton("QUIT", "quit")

	self.bg = ResMgr.getImage("mainmenu_bg.png")

	return self
end

function MainMenuState:update(dt)
	for i,v in ipairs(self.inputs) do
		if v:wasClicked() then
			self.menu:click(self.cursor.x, self.cursor.y)
		end
		self.cursor:move(v:getMovement(dt, false))
	end
end

function MainMenuState:draw()
	love.graphics.draw(self.bg, 0, 0)
	self.menu:draw()
	self.cursor:draw()
end

function MainMenuState:buttonPressed(id, source)
	if id == "start" then
		pushState(InputSelectState.create(self))
	elseif id == "editor" then
		pushState(LevelEditorState.create(self))
	elseif id == "options" then
		pushState(OptionsState.create(self, self.config))
	elseif id == "quit" then
		love.event.quit()
	end
end
