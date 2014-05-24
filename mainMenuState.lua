local State = require("state")
local Menu = require("menu")
local Cursor = require("cursor")
local InputSelectState = require("inputSelectState")
local OptionsState = require("optionsState")
local LevelEditorState = require("levelEditorState")

local MainMenuState = {}
MainMenuState.__index = MainMenuState
setmetatable(MainMenuState, State)

function MainMenuState.create()
	local self = setmetatable(State.create(), MainMenuState)

	table.insert(self.inputs, KeyboardInput.create())
	table.insert(self.inputs, MouseInput.create())
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

function MainMenuState:enter()
	MusicMgr.playMenu()
end

function MainMenuState:draw()
	love.graphics.draw(self.bg, 0, 0)
	love.graphics.setFont(ResMgr.getFont("bold"))
	love.graphics.printf(VERSION, 14, HEIGHT-18, 300, "left")
	love.graphics.printf("MUSIC BY LINDE", WIDTH-314, HEIGHT-18, 300, "right")
end

function MainMenuState:buttonPressed(id, source)
	if id == "start" then
		playSound("quack")
		pushState(InputSelectState.create(self))
	elseif id == "editor" then
		playSound("quack")
		pushState(LevelEditorState.create(self))
	elseif id == "options" then
		playSound("quack")
		pushState(OptionsState.create(self))
	elseif id == "quit" then
		love.event.quit()
	end
end

return MainMenuState
