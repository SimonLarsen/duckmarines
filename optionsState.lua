OptionsState = {}
OptionsState.__index = OptionsState
setmetatable(OptionsState, State)

function OptionsState.create(parent, config)
	local self = setmetatable(State.create(), OptionsState)

	self.config = config
	self.inputs = parent.inputs
	self.cursor = parent.cursor

	self.menu = Menu.create((WIDTH-300)/2, 169, 300, 32, 20, self)
	self.fullscreenButton = self.menu:addButton("FULLSCREEN: "..boolToStr(config.fullscreen), "fullscreen")
	self.vsyncButton = self.menu:addButton("VSYNC: "..boolToStr(config.vsync), "vsync")
	self.menu:addButton("MUSIC VOLUME", "musicvolume")
	self.menu:addButton("SOUND VOLUME", "soundvolume")
	self.menu:addButton("BACK", "back")
	
	self.bg = ResMgr.getImage("mainmenu_bg.png")

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
	love.graphics.draw(self.bg, 0, 0)
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
	elseif id == "back" then
		popState()
	end
end
