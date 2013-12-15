InputSelectState = {}
InputSelectState.__index = InputSelectState
setmetatable(InputSelectState, State)

function InputSelectState.create(parent)
	local self = setmetatable(State.create(), InputSelectState)

	self.menu = Menu.create((WIDTH-200)/2, 320, 200, 32, 24, self)
	self.leaveButtons = {}
	for i=1,4 do
		self.leaveButtons[i] = self.menu:addButton("LEAVE", "leave"..i, -90+i*150, 258, 130, 32)
		self.leaveButtons[i].enabled = false
	end

	self.menu:addButton("CONTINUE", "continue")
	self.menu:addButton("BACK", "back")

	self:addComponent(self.menu)

	self.bg = ResMgr.getImage("bg_stars.png")
	self.imgColors = ResMgr.getImage("icon_colors.png")
	self.iconKeyboard = ResMgr.getImage("icon_keyboard.png")
	self.iconMouse = ResMgr.getImage("icon_mouse.png")
	self.iconController = ResMgr.getImage("icon_controller.png")
	self.iconAI = ResMgr.getImage("icon_ai.png")

	return self
end

function InputSelectState:keypressed(k, uni)
	for i=1,4 do
		if self.inputs[i] then
			self.inputs[i]:keypressed(k, uni)
		end
	end

	local found = false
	for i=1,4 do
		if self.inputs[i] and self.inputs[i]:getType() == Input.TYPE_KEYBOARD then
			found = true
			break
		end
	end
	if found == false then
		self:addInput(KeyboardInput.create())
	end
end

function InputSelectState:joystickpressed(joy, button)
	for i=1,4 do
		if self.inputs[i] then
			self.inputs[i]:joystickpressed(joy, button)
		end
	end

	local found = false
	for i=1,4 do
		if self.inputs[i] and self.inputs[i]:getType() == Input.TYPE_JOYSTICK then
			if self.inputs[i].id == joy then
				found = true
				break
			end
		end
	end
	if found == false then
		self:addInput(JoystickInput.create(joy))
	end
end

function InputSelectState:addInput(input)
	for i=1,4 do
		if self.inputs[i] == nil then
			self.inputs[i] = input
			self.cursors[i] = Cursor.create(-25+i*150, 165, i)
			self.cursors[i]:addInput(input)
			self.leaveButtons[i].enabled = true
			return
		end
	end
end

function InputSelectState:draw()
	love.graphics.draw(self.bg, 0, 0)
	love.graphics.draw(self.imgColors, 62, 116)
	love.graphics.setFont(ResMgr.getFont("menu"))
	love.graphics.printf("PRESS ACTION BUTTON TO JOIN", 0, 25, WIDTH, "center")
	self.menu:draw()

	-- Draw titles
	local player = 1
	local ai = 1
	for i=1,4 do
		love.graphics.setColor(23, 23, 23, 255)
		love.graphics.rectangle("fill", -88+i*150, 66, 126, 32)
		love.graphics.setColor(241, 148, 0, 255)
		love.graphics.rectangle("line", -87.5+i*150, 66.5, 126, 32)

		love.graphics.setColor(255, 255, 255, 255)

		if self.inputs[i] then
			love.graphics.printf("PLAYER "..player, -100+i*150, 73, 150, "center")
			player = player+1
			local t = self.inputs[i]:getType()
			if t == Input.TYPE_KEYBOARD then
				love.graphics.draw(self.iconKeyboard, -85+i*150, 119)
			elseif t == Input.TYPE_MOUSE then
				love.graphics.draw(self.iconMouse, -85+i*150, 119)
			elseif t == Input.TYPE_JOYSTICK then
				love.graphics.draw(self.iconController, -85+i*150, 119)
			end
		else
			love.graphics.printf("AI "..ai, -100+i*150, 73, 150, "center")
			ai = ai+1
			love.graphics.draw(self.iconAI, -85+i*150, 119)
		end
	end
end

function InputSelectState:buttonPressed(id, source)
	if id == "leave1" then
		self.inputs[1] = nil
		self.cursors[1] = nil
		self.leaveButtons[1].enabled = false
	elseif id == "leave2" then
		self.inputs[2] = nil
		self.cursors[2] = nil
		self.leaveButtons[2].enabled = false
	elseif id == "leave3" then
		self.inputs[3] = nil
		self.cursors[3] = nil
		self.leaveButtons[3].enabled = false
	elseif id == "leave4" then
		self.inputs[4] = nil
		self.cursors[4] = nil
		self.leaveButtons[4].enabled = false

	elseif id == "continue" then
		for i=1,4 do
			if self.inputs[i] == nil then
				self.inputs[i] = NullInput.create()
			end
		end
		popState()
		pushState(LevelSelectionState.create(self))
	elseif id == "back" then
		popState()
	end
end
