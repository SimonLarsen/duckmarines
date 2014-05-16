local State = require("state")
local Label = require("label")
local Menu = require("menu")
local Slider = require("slider")
local ToggleButton = require("toggleButton")

local AdvancedSettingsState = {}
AdvancedSettingsState.__index = AdvancedSettingsState
setmetatable(AdvancedSettingsState, State)

function AdvancedSettingsState.create(parent)
	local self = setmetatable(State.create(), AdvancedSettingsState)

	self.inputs = parent.inputs
	self.cursors = parent.cursors

	self:addComponent(Label.create("ADVANCED SETTINGS", 0, 25, WIDTH, "center"))

	self.bottomMenu = self:addComponent(Menu.create(0, 0, 0, 0, 0, self))
	self.bottomMenu:addButton("DEFAULTS", "defaults", 80, 390, 250, 32)
	self.bottomMenu:addButton("BACK", "back", 370, 390, 250, 32)

	self:addComponent(Label.create("ROUND TIME", 80, 72, 250, "right"))
	self.roundtimeSlider = self:addComponent(Slider.create(370, 66, 250, math.seq(30, 600, 30), 180, self, Slider.timeFormatter))

	self:addComponent(Label.create("DUCKS PER MINUTE", 80, 112, 250, "right"))
	self.frequencySlider = self:addComponent(Slider.create(370, 106, 250, math.seq(50,300,5), 100, self))

	self:addComponent(Label.create("PREDATOR PCT.", 80, 152, 250, "right"))
	self.enemypercSlider = self:addComponent(Slider.create(370, 146, 250, math.seq(0,10,1), 6, self, Slider.percentFormatter))

	self:addComponent(Label.create("GOLD DUCK PCT.", 80, 192, 250, "right"))
	self.goldpercSlider = self:addComponent(Slider.create(370, 186, 250, math.seq(0,10,1), 6, self, Slider.percentFormatter))

	self:addComponent(Label.create("PINK DUCK PCT.", 80, 232, 250, "right"))
	self.pinkpercSlider = self:addComponent(Slider.create(370, 226, 250, math.seq(0,10,1), 4, self, Slider.percentFormatter))

	self:addComponent(Label.create("ARROWS PER PLAYER", 80, 272, 250, "right"))
	self.maxarrowsSlider = self:addComponent(Slider.create(370, 266, 250, math.seq(1,10,1), 4))

	self:addComponent(Label.create("PREDATORS EAT DUCKS", 40, 312, 290, "right"))
	self.predatorseatToggle = self:addComponent(ToggleButton.create(370, 306, true))

	self:addComponent(Label.create("MINI GAMES ENABLED", 80, 352, 250, "right"))
	self.minigamesToggle = self:addComponent(ToggleButton.create(370, 346, true))

	self:updateSliders()

	self.bg = ResMgr.getImage("bg_stars.png")

	return self
end

function AdvancedSettingsState:draw()
	love.graphics.draw(self.bg, 0, 0)
end

function AdvancedSettingsState:buttonPressed(id, source)
	if id == "defaults" then
		playSound("click")
		rules:setDefaults()
		self:updateSliders()
	elseif id == "back" then
		playSound("quack")
		self:confirmSettings()
		popState()
	end
end

function AdvancedSettingsState:confirmSettings()
	rules.roundtime = self.roundtimeSlider:getValue()
	rules.frequency = self.frequencySlider:getValue()
	rules.enemyperc = self.enemypercSlider:getValue()
	rules.goldperc = self.goldpercSlider:getValue()
	rules.pinkperc = self.pinkpercSlider:getValue()
	rules.maxarrows = self.maxarrowsSlider:getValue()
	rules.predatorseat = self.predatorseatToggle:getValue()
	rules.minigames = self.minigamesToggle:getValue()
end

function AdvancedSettingsState:updateSliders()
	self.roundtimeSlider:setValue(rules.roundtime)
	self.frequencySlider:setValue(rules.frequency)
	self.enemypercSlider:setValue(rules.enemyperc)
	self.goldpercSlider:setValue(rules.goldperc)
	self.pinkpercSlider:setValue(rules.pinkperc)
	self.maxarrowsSlider:setValue(rules.maxarrows)
	self.predatorseatToggle:setValue(rules.predatorseat)
	self.minigamesToggle:setValue(rules.minigames)
end

function AdvancedSettingsState:valueChanged(id, source)
	
end

function AdvancedSettingsState:leave()
	rules:save()
end

return AdvancedSettingsState
