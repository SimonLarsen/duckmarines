MainMenuState = {}
MainMenuState.__index = MainMenuState
setmetatable(MainMenuState, State)

function MainMenuState.create(config)
	local self = setmetatable({}, MainMenuState)

	self.config = config

	self.inputs = {}
	self.inputs[1] = KeyboardInput.create()
	self.inputs[2] = MouseInput.create()
	self.inputs[3] = JoystickInput.create(1)
	self.inputs[4] = JoystickInput.create(2)
	
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
	for i,v in ipairs(self.inputs) do
		if v:wasClicked() then
			self.menu:click(self.cursor.x, self.cursor.y)
		end
	end
end

function MainMenuState:draw()
	love.graphics.draw(self.bg, 0, 0)
	self.menu:draw()
	self.cursor:draw()
end

function MainMenuState:keypressed(k, uni)
	for i,v in ipairs(self:getInputs()) do
		v:keypressed(k, uni)
	end

	if k == "1" then
		pushState(IngameState.create(self, "res/maps/test.lua", Rules.create()))
	elseif k == "2" then
		pushState(IngameState.create(self, "res/maps/test2.lua", Rules.create()))
	elseif k == "3" then
		pushState(IngameState.create(self, "usermaps/custom.lua", Rules.create()))
	end
end

function MainMenuState:buttonPressed(id)
	if id == "editor" then
		pushState(LevelEditorState.create(self))
	elseif id == "options" then
		print(self.config)
		pushState(OptionsState.create(self, self.config))
	elseif id == "quit" then
		love.event.quit()
	end
end
