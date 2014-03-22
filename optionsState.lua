OptionsState = {}
OptionsState.__index = OptionsState
setmetatable(OptionsState, State)

function OptionsState.create(parent, config)
	local self = setmetatable(State.create(), OptionsState)

	self.config = config
	self.inputs = parent.inputs
	self.cursors = parent.cursors

	self.menu = self:addComponent(Menu.create((WIDTH-300)/2, 169, 300, 32, 20, self))
	self.fullscreenButton = self.menu:addButton("", "fullscreen")
	self.vsyncButton = self.menu:addButton("", "vsync")
	self.musicButton = self.menu:addButton("", "musicvolume")
	self.soundButton = self.menu:addButton("", "soundvolume")
	self.menu:addButton("BACK", "back")
	self:updateButtons()
	
	self.bg = ResMgr.getImage("mainmenu_bg.png")

	return self
end

function OptionsState:enter()
	MusicMgr.playMenu()
end

function OptionsState:draw()
	love.graphics.draw(self.bg, 0, 0)
end

function OptionsState:buttonPressed(id)
	if id == "fullscreen" then
		self.config.fullscreen = not self.config.fullscreen
		setScreenMode()
	elseif id == "vsync" then
		self.config.vsync = not self.config.vsync
		setScreenMode()
	elseif id == "musicvolume" then
		self.config.music_volume = (self.config.music_volume+1) % 6
		updateVolume()
	elseif id == "soundvolume" then
		self.config.sound_volume = (self.config.sound_volume+1) % 6
		updateVolume()
	elseif id == "back" then
		popState()
	end
	self:updateButtons()
end

function OptionsState:updateButtons()
	self.fullscreenButton.text = "FULLSCREEN: " .. boolToStr(self.config.fullscreen)
	self.vsyncButton.text = "VSYNC: " .. boolToStr(self.config.vsync)
	self.musicButton.text = "MUSIC VOLUME: " .. string.rep("I", self.config.music_volume) .. string.rep("x", 5 - self.config.music_volume)
	self.soundButton.text = "SOUND VOLUME: " .. string.rep("I", self.config.sound_volume) .. string.rep("x", 5 - self.config.sound_volume)
end
