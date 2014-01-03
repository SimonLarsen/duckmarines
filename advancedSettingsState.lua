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
	self.bottomMenu:addButton("DEFAULTS", "defaults", 50, 385, 250, 32)
	self.bottomMenu:addButton("BACK", "back", 400, 385, 250, 32)

	local times = math.seq(30, 180, 30)
	self.slider = self:addComponent(Slider.create(400, 70, 250, times, 2, self, Slider.timeFormatter))

	self.bg = ResMgr.getImage("bg_stars.png")

	return self
end

function AdvancedSettingsState:draw()
	love.graphics.draw(self.bg, 0, 0)
end

function AdvancedSettingsState:buttonPressed(id, source)
	if id == "defaults" then

	elseif id == "back" then
		popState()
	end
end

function AdvancedSettingsState:valueChanged(id, source)
	
end
