local State = require("state")
local Label = require("label")
local Menu = require("menu")
local SelectionList = require("selectionList")
local CountdownState = require("countdownState")
local DuckBeatState = require("duckBeatState")
local DuckDashState = require("duckDashState")
local EscapeState = require("escapeState")

local LevelSelectionState = {}
LevelSelectionState.__index = LevelSelectionState
setmetatable(LevelSelectionState, State)

function LevelSelectionState.create(parent)
	local self = setmetatable(State.create(), LevelSelectionState)

	self.inputs = parent.inputs
	self.cursors = parent.cursors
	self.rules = Rules.create()

	self.score = {}
	for i=1,4 do
		self.score[i] = 0
	end

	self.bg = ResMgr.getImage("bg_stars.png")

	self:addComponent(Label.create("SELECT A LEVEL", 0, 25, WIDTH, "center"))

	self.menu = self:addComponent(Menu.create((WIDTH-200)/2, 190, 220, 32, 24, self))
	self.menu:addButton("DUCK DASH", "duckdash")
	self.menu:addButton("ESCAPE", "escape")
	self.menu:addButton("DUCK BEAT", "duckbeat")
	self.menu:addButton("BACK", "back")

	return self
end

function LevelSelectionState:enter()
	MusicMgr.playMenu()
end

function LevelSelectionState:draw()
	love.graphics.draw(self.bg, 0, 0)
end

function LevelSelectionState:buttonPressed(id, source)
	if id == "duckdash" then
		pushState(DuckDashState.create(self, self.score, self.rules))
		pushState(CountdownState.create(4, 0))
	elseif id == "escape" then
		pushState(EscapeState.create(self, self.score, self.rules))
		pushState(CountdownState.create(4, 0))
	elseif id == "duckbeat" then
		pushState(DuckBeatState.create(self, self.score, self.rules))
	elseif id == "back" then
		popState()
	end
end

return LevelSelectionState
