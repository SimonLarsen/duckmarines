InputSelectState = {}
InputSelectState.__index = InputSelectState
setmetatable(InputSelectState, State)

function InputSelectState.create(parent)
	local self = setmetatable(State.create(), InputSelectState)

	self.cursors = {}

	self.menu = Menu.create((WIDTH-200)/2, 320, 200, 32, 24, self)
	self.menu:addButton("LEAVE", "leave1",  60, 250, 130, 32)
	self.menu:addButton("LEAVE", "leave2", 210, 250, 130, 32)
	self.menu:addButton("LEAVE", "leave3", 360, 250, 130, 32)
	self.menu:addButton("LEAVE", "leave4", 510, 250, 130, 32)

	self.menu:addButton("CONTINUE", "continue")
	self.menu:addButton("BACK", "back")

	self:addComponent(self.menu)

	self.bg = ResMgr.getImage("bg_stars.png")

	return self
end

function InputSelectState:update(dt)
	for i=1,4 do
		if self.inputs[i] then
			if self.cursors[i] then
				self.cursors[i]:move(self.inputs[i]:getMovement(dt, false))
			end
			if self.inputs[i]:wasClicked() then
				self.menu:click(self.cursors[i].x, self.cursors[i].y)
			end
		end
	end
end

function InputSelectState:mousepressed(x, y, button)
	for i=1,4 do
		if self.inputs[i] then
			self.inputs[i]:mousepressed(x, y, button)
		end
	end

	local found = false
	for i=1,4 do
		if self.inputs[i] and self.inputs[i]:getType() == Input.TYPE_MOUSE then
			found = true
			break
		end
	end
	if found == false then
		self:addInput(MouseInput.create())
	end
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
			self.cursors[i] = Cursor.create(-25+i*150, HEIGHT/2, i)
			return
		end
	end
end

function InputSelectState:draw()
	love.graphics.draw(self.bg, 0, 0)
	self.menu:draw()
	for i=1,4 do
		if self.cursors[i] then
			self.cursors[i]:draw()
		end
	end
end

function InputSelectState:buttonPressed(id, source)
	if id == "leave1" then
		self.inputs[1] = nil
		self.cursors[1] = nil
	elseif id == "leave2" then
		self.inputs[2] = nil
		self.cursors[2] = nil
	elseif id == "leave3" then
		self.inputs[3] = nil
		self.cursors[3] = nil
	elseif id == "leave4" then
		self.inputs[4] = nil
		self.cursors[4] = nil

	elseif id == "continue" then
		for i=1,4 do
			if self.inputs[i] == nil then
				self.inputs[i] = NullInput.create()
			end
			popState()
			pushState(IngameState.create(self, "res/maps/test", Rules.create()))
		end
	elseif id == "back" then
		popState()
	end
end
