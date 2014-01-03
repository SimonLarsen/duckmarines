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
	self.bottomMenu:addButton("DEFAULTS", "defaults", 60, 381, 250, 32)
	self.bottomMenu:addButton("BACK", "back", 390, 381, 250, 32)

	self:addComponent(Label.create("ROUND TIME", 60, 80, 250, "right"))
	self.roundtimeSlider = self:addComponent(Slider.create(390, 74, 250, math.seq(30, 600, 30), 180, self, Slider.timeFormatter))

	self:addComponent(Label.create("DUCKS PER MINUTE", 60, 120, 250, "right"))
	self.frequencySlider = self:addComponent(Slider.create(390, 114, 250, math.seq(50,300,5), 100, self))

	self:addComponent(Label.create("PREDATOR PCT.", 60, 160, 250, "right"))
	self.enemypercSlider = self:addComponent(Slider.create(390, 154, 250, math.seq(0,10,1), 6, self, Slider.percentFormatter))

	self:addComponent(Label.create("GOLD DUCK PCT.", 60, 200, 250, "right"))
	self.goldpercSlider = self:addComponent(Slider.create(390, 194, 250, math.seq(0,10,1), 6, self, Slider.percentFormatter))

	self:addComponent(Label.create("PINK DUCK PCT.", 60, 240, 250, "right"))
	self.pinkpercSlider = self:addComponent(Slider.create(390, 234, 250, math.seq(0,10,1), 4, self, Slider.percentFormatter))

	self:addComponent(Label.create("ARROWS PER PLAYER", 60, 280, 250, "right"))
	self.maxarrowsSlider = self:addComponent(Slider.create(390, 274, 250, math.seq(1,10,1), 4))

	self:addComponent(Label.create("ARROW LIFE TIME", 60, 320, 250, "right"))
	self.arrowtimeSlider = self:addComponent(Slider.create(390, 314, 250, math.seq(2,60,1), 10, self, Slider.timeFormatter))

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
end

function AdvancedSettingsState:updateSliders()
	self.roundtimeSlider:setValue(self.rules.roundtime)
	self.frequencySlider:setValue(self.rules.frequency)
	self.enemypercSlider:setValue(self.rules.enemyperc)
	self.goldpercSlider:setValue(self.rules.goldperc)
	self.pinkpercSlider:setValue(self.rules.pinkperc)
	self.maxarrowsSlider:setValue(self.rules.maxarrows)
	self.arrowtimeSlider:setValue(self.rules.arrowtime)
end

function AdvancedSettingsState:valueChanged(id, source)
	
end
