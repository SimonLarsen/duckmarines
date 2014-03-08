AdvancedSettingsState = {}
AdvancedSettingsState.__index = AdvancedSettingsState
setmetatable(AdvancedSettingsState, State)

function AdvancedSettingsState.create(parent, rules)
	local self = setmetatable(State.create(), AdvancedSettingsState)

	self.inputs = parent.inputs
	self.cursors = parent.cursors
	self.rules = rules

	self:addComponent(Label.create("ADVANCED SETTINGS", 0, 25, WIDTH, "center"))

	self.bottomMenu = self:addComponent(Menu.create(0, 0, 0, 0, 0, self))
	self.bottomMenu:addButton("DEFAULTS", "defaults", 60, 390, 250, 32)
	self.bottomMenu:addButton("BACK", "back", 390, 390, 250, 32)

	self:addComponent(Label.create("ROUND TIME", 60, 72, 250, "right"))
	self.roundtimeSlider = self:addComponent(Slider.create(390, 66, 250, math.seq(30, 600, 30), 180, self, Slider.timeFormatter))

	self:addComponent(Label.create("DUCKS PER MINUTE", 60, 112, 250, "right"))
	self.frequencySlider = self:addComponent(Slider.create(390, 106, 250, math.seq(50,300,5), 100, self))

	self:addComponent(Label.create("PREDATOR PCT.", 60, 152, 250, "right"))
	self.enemypercSlider = self:addComponent(Slider.create(390, 146, 250, math.seq(0,10,1), 6, self, Slider.percentFormatter))

	self:addComponent(Label.create("GOLD DUCK PCT.", 60, 192, 250, "right"))
	self.goldpercSlider = self:addComponent(Slider.create(390, 186, 250, math.seq(0,10,1), 6, self, Slider.percentFormatter))

	self:addComponent(Label.create("PINK DUCK PCT.", 60, 232, 250, "right"))
	self.pinkpercSlider = self:addComponent(Slider.create(390, 226, 250, math.seq(0,10,1), 4, self, Slider.percentFormatter))

	self:addComponent(Label.create("ARROWS PER PLAYER", 60, 272, 250, "right"))
	self.maxarrowsSlider = self:addComponent(Slider.create(390, 266, 250, math.seq(1,10,1), 4))

	self:addComponent(Label.create("ARROW LIFE TIME", 60, 312, 250, "right"))
	self.arrowtimeSlider = self:addComponent(Slider.create(390, 306, 250, math.seq(2,60,1), 10, self, Slider.timeFormatter))

	self:addComponent(Label.create("PREDATORS EAT DUCKS", 20, 352, 290, "right"))
	self.predatorseatSlider = self:addComponent(Slider.create(390, 346, 250, {false,true}, 2, self, Slider.onOffFormatter))

	self:updateSliders()

	self.bg = ResMgr.getImage("bg_stars.png")

	return self
end

function AdvancedSettingsState:draw()
	love.graphics.draw(self.bg, 0, 0)
end

function AdvancedSettingsState:buttonPressed(id, source)
	if id == "defaults" then
		self.rules:setDefaults()
		self:updateSliders()
	elseif id == "back" then
		self:confirmSettings()
		popState()
	end
end

function AdvancedSettingsState:confirmSettings()
	self.rules.roundtime = self.roundtimeSlider:getValue()
	self.rules.frequency = self.frequencySlider:getValue()
	self.rules.enemyperc = self.enemypercSlider:getValue()
	self.rules.goldperc = self.goldpercSlider:getValue()
	self.rules.pinkperc = self.pinkpercSlider:getValue()
	self.rules.maxarrows = self.maxarrowsSlider:getValue()
	self.rules.arrowtime = self.arrowtimeSlider:getValue()
	self.rules.predatorseat = self.predatorseatSlider:getValue()
end

function AdvancedSettingsState:updateSliders()
	self.roundtimeSlider:setValue(self.rules.roundtime)
	self.frequencySlider:setValue(self.rules.frequency)
	self.enemypercSlider:setValue(self.rules.enemyperc)
	self.goldpercSlider:setValue(self.rules.goldperc)
	self.pinkpercSlider:setValue(self.rules.pinkperc)
	self.maxarrowsSlider:setValue(self.rules.maxarrows)
	self.arrowtimeSlider:setValue(self.rules.arrowtime)
	self.predatorseatSlider:setValue(self.rules.predatorseat)
end

function AdvancedSettingsState:valueChanged(id, source)
	
end
