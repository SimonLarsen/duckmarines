AdvancedSettingsState = {}
AdvancedSettingsState.__index = AdvancedSettingsState
setmetatable(AdvancedSettingsState, State)

function AdvancedSettingsState.create(parent, rules)
	local self = setmetatable(State.create(), AdvancedSettingsState)

	self.inputs = parent.inputs
	self.cursor = parent.cursor
	self.rules = rules

	self.leftMenu = Menu.create(25, 70, 300, 32, 20, self)
	self.rightMenu = Menu.create(375, 70, 300, 32, 20, self)

	self.buttons = {}
	self.properties = {}

	self:addProperty("roundtime", 30, 30, 600)
	self:addProperty("frequency", 50, 50, 400)
	self:addProperty("enemyperc",  3,  0,  24)
	self:addProperty("goldperc",   3,  0,  24)
	self:addProperty("pinkperc",   2,  0,  16)
	self:addProperty("arrowtime",  4,  2,  22)
	self:addProperty("maxarrows",   1,  1,   8)

	self.rightMenu:addButton("RESET TO DEFAULTS", "defaults")
	self.rightMenu:addButton("EXIT", "exit")

	self:updateButtons()

	self:addComponent(self.leftMenu)
	self:addComponent(self.rightMenu)

	self.bg = ResMgr.getImage("bg_stars.png")

	return self
end

function AdvancedSettingsState:update(dt)
	for i,v in ipairs(self:getInputs()) do
		if v:wasClicked() then
			for j,c in ipairs(self:getComponents()) do
				c:click(self.cursor.x, self.cursor.y)
			end
		end
		self.cursor:move(v:getMovement(dt, false))
	end
end

function AdvancedSettingsState:draw()
	love.graphics.draw(self.bg, 0, 0)

	love.graphics.setFont(ResMgr.getFont("menu"))
	love.graphics.printf("ADVANCED SETTINGS", 0, 25, WIDTH, "center")

	self.leftMenu:draw()
	self.rightMenu:draw()
	self.cursor:draw()
end

function AdvancedSettingsState:buttonPressed(id, source)
	for i,v in ipairs(self.properties) do
		if v.name == id then
			self.rules[v.name] = self.rules[v.name] + v.inc
			if self.rules[v.name] > v.max then self.rules[v.name] = v.min end
			self:updateButtons()
		end
	end
	
	if id == "defaults" then
		self.rules:setDefaults()
		self:updateButtons()
	elseif id == "exit" then
		popState()
	end
end

function AdvancedSettingsState:addProperty(name, inc, min, max)
	table.insert(self.properties, {name=name, inc=inc, min=min, max=max})
	self.buttons[name] = self.leftMenu:addButton("", name)
end

function AdvancedSettingsState:updateButtons()
	self.buttons.roundtime.text = "ROUND TIME: " .. secsToString(self.rules.roundtime)
	self.buttons.frequency.text = "DUCKS: " .. self.rules.frequency .. " PER MINUTE"
	self.buttons.enemyperc.text = "PREDATORS: " .. self.rules.enemyperc .. " PCT."
	self.buttons.goldperc.text = "GOLD: " .. self.rules.goldperc .. " PCT."
	self.buttons.pinkperc.text = "PINK: " .. self.rules.pinkperc .. " PCT."
	self.buttons.arrowtime.text = "ARROWS STAY " .. self.rules.arrowtime .. " S"
	self.buttons.maxarrows.text = "MAX ARROWS: " .. self.rules.maxarrows
end
