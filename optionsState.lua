OptionsState = {}
OptionsState.__index = OptionsState
setmetatable(OptionsState, State)

function OptionsState.create(parent, config)
	local self = setmetatable(State.create(), OptionsState)

	self.config = config
	self.inputs = parent.inputs
	self.cursor = parent.cursor

	self.menu = Menu.create((WIDTH-300)/2, 100, 300, 32, 20, self)
	self.fullscreenButton = self.menu:addButton("FULLSCREEN: "..boolToStr(config.fullscreen), "fullscreen")
	self.vsyncButton = self.menu:addButton("VSYNC: "..boolToStr(config.vsync), "vsync")
	self.menu:addButton("EXIT", "exit")

	return self
end

function OptionsState:update(dt)
	for i,v in ipairs(self.inputs) do
		if v:wasClicked() then
			self.menu:click(self.cursor.x, self.cursor.y)
		end
		self.cursor:move(v:getMovement(dt, false))
	end
end

function OptionsState:draw()
	love.graphics.setColor(70, 97, 138)
	love.graphics.rectangle("fill", 0, 0, WIDTH, HEIGHT)
	love.graphics.setColor(255, 255, 255)

	self.menu:draw()
	self.cursor:draw()
end

function OptionsState:buttonPressed(id)
	if id == "fullscreen" then
		self.config.fullscreen = not self.config.fullscreen
		self.fullscreenButton.text = "FULLSCREEN: " .. boolToStr(self.config.fullscreen)
		setScreenMode()
	elseif id == "vsync" then
		self.config.vsync = not self.config.vsync
		self.vsyncButton.text = "VSYNC: " .. boolToStr(self.config.vsync)
		setScreenMode()
	elseif id == "exit" then
		popState()
	end
end
