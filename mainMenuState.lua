MainMenuState = {}
MainMenuState.__index = MainMenuState
setmetatable(MainMenuState, State)

function MainMenuState.create(config)
	local self = setmetatable(State.create(), MainMenuState)

	self.config = config

	table.insert(self.inputs, KeyboardInput.create())
	for i,v in ipairs(love.joystick.getJoysticks()) do
		table.insert(self.inputs, JoystickInput.create(v))
	end
	
	self.cursors[1] = Cursor.create(WIDTH/2, HEIGHT/2, 1)
	for i=1,5 do
		self.cursors[1]:addInput(self.inputs[i])
	end

	self.menu = Menu.create((WIDTH-200)/2, 190, 220, 32, 24, self)
	self.menu:addButton("START GAME", "start")
	self.menu:addButton("OPTIONS", "options")
	self.menu:addButton("LEVEL EDITOR", "editor")
	self.menu:addButton("QUIT", "quit")
	self:addComponent(self.menu)

	self.bg = ResMgr.getImage("mainmenu_bg.png")

	return self
end

function MainMenuState:draw()
	love.graphics.draw(self.bg, 0, 0)
	self.menu:draw()
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
