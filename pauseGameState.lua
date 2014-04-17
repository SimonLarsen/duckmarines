local State = require("state")
local LevelSelectionState = require("levelSelectionState")
local Cursor = require("cursor")
local Menu = require("menu")
local CountdownState = require("countdownState")
local Label = require("label")

local PauseGameState = {}
PauseGameState.__index = PauseGameState
setmetatable(PauseGameState, State)

function PauseGameState.create(parent)
	local self = setmetatable(State.create(), PauseGameState)

	self:addComponent(Label.create("PAUSE", 0, 94, WIDTH, "center"))

	self.menu = self:addComponent(Menu.create((WIDTH-200)/2, 143, 200, 32, 24, self))
	self.menu:addButton("CONTINUE", "continue")
	self.menu:addButton("RESTART", "restart")
	self.menu:addButton("SELECT LEVEL", "selectlevel")
	self.menu:addButton("QUIT", "quit")

	self.cursors[1] = Cursor.create(WIDTH/2, HEIGHT/2, 1)
	for i=1,4 do
		if parent.inputs[i]:getType() == Input.TYPE_BOT then
			self.inputs[i] = NullInput.create()
		else
			self.inputs[i] = parent.inputs[i]
		end
		self.cursors[1]:addInput(self.inputs[i])
	end

	self.mapname = parent.mapname
	self.rules = parent.rules

	return self
end

function PauseGameState:draw()
	love.graphics.setColor(0, 0, 0, 128)
	love.graphics.rectangle("fill", 0, 0, WIDTH, HEIGHT)
	love.graphics.setColor(255,255,255,255)
end

function PauseGameState:buttonPressed(id, source)
	if id == "continue" then
		popState()
	elseif id == "restart" then
		popState()
		popState()
		pushState(IngameState.create(self, self.mapname, self.rules))
		pushState(CountdownState.create())
	elseif id == "selectlevel" then
		popState()
		popState()
		pushState(LevelSelectionState.create(self))
	elseif id == "quit" then
		popState()
		popState()
	end
end

function PauseGameState:isTransparent()
	return true
end

function PauseGameState:keypressed(k)
	if k == "escape" then
		popState()
	else
		State.keypressed(self, k)
	end
end

return PauseGameState
