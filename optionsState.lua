local State = require("state")
local Menu = require("menu")

local OptionsState = {}
OptionsState.__index = OptionsState
setmetatable(OptionsState, State)

function OptionsState.create(parent, config)
	local self = setmetatable(State.create(), OptionsState)

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
		playSound("click")
		config.fullscreen = not config.fullscreen
		setScreenMode()
	elseif id == "vsync" then
		playSound("click")
		config.vsync = not config.vsync
		setScreenMode()
	elseif id == "musicvolume" then
		playSound("click")
		config.music_volume = (config.music_volume+1) % 6
		updateVolume()
	elseif id == "soundvolume" then
		config.sound_volume = (config.sound_volume+1) % 6
		updateVolume()
		playSound("click")
	elseif id == "back" then
		playSound("quack")
		popState()
	end
	self:updateButtons()
end

function OptionsState:updateButtons()
	self.fullscreenButton.text = "FULLSCREEN: " .. boolToStr(config.fullscreen)
	self.vsyncButton.text = "VSYNC: " .. boolToStr(config.vsync)
	self.musicButton.text = "MUSIC VOLUME: " .. string.rep("I", config.music_volume) .. string.rep("x", 5 - config.music_volume)
	self.soundButton.text = "SOUND VOLUME: " .. string.rep("I", config.sound_volume) .. string.rep("x", 5 - config.sound_volume)
end

function OptionsState:leave()
	config:save()
end

return OptionsState
