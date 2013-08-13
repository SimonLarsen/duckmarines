--- Input base class
Input = {}
Input.__index = Input

Input.TYPE_KEYBOARD = 1
Input.TYPE_MOUSE = 2
Input.TYPE_JOYSTICK = 3

function Input.create()
	local self = setmetatable({}, Input)

	self.action = nil
	self.clicked = false

	return self
end

function Input:getAction()
	local ac = self.action
	self.action = nil
	return ac
end

function Input:wasClicked()
	local cl = self.clicked
	self.clicked = false
	return cl
end

function Input:isDown()
	return false
end

function Input:keypressed(k, uni) end
function Input:mousepressed(x, y, button) end
function Input:mousereleased(x, y, button) end
function Input:joystickpressed(joystick, button) end

--- NullInput (does nothing)
NullInput = {}
NullInput.__index = NullInput
setmetatable(NullInput, Input)

function NullInput.create()
	local self = setmetatable(Input.create(), NullInput)
	return self
end

function NullInput:getMovement(dt, lock)
	return 0, 0, false
end

function NullInput:getType() return Input.TYPE_NONE end

--- Keyboard input
KeyboardInput = { SPEED = 300 }
KeyboardInput.__index = KeyboardInput
setmetatable(KeyboardInput, Input)

function KeyboardInput.create()
	local self = setmetatable(Input.create(), KeyboardInput)

	self.type = Input.TYPE_KEYBOARD

	return self
end

function KeyboardInput:getMovement(dt, lock)
	local dx = 0
	local dy = 0

	if not love.keyboard.isDown(" ") or lock == false then
		if love.keyboard.isDown("left") then
			dx = dx - self.SPEED * dt end
		if love.keyboard.isDown("right") then
			dx = dx + self.SPEED * dt end
		if love.keyboard.isDown("up") then
			dy = dy - self.SPEED * dt end
		if love.keyboard.isDown("down") then
			dy = dy + self.SPEED * dt end
	end

	return dx, dy, false
end

function KeyboardInput:keypressed(k, uni)
	if k == " " then
		self.clicked = true
	elseif love.keyboard.isDown(" ") then
		if k == "up" then
			self.action = 0
		elseif k == "right" then
			self.action = 1
		elseif k == "down" then
			self.action = 2
		elseif k == "left" then
			self.action = 3
		end
	end
end

function KeyboardInput:isDown()
	return love.keyboard.isDown(" ")
end

function KeyboardInput:getType() return Input.TYPE_KEYBOARD end

--- Mouse input
MouseInput = {}
MouseInput.__index = MouseInput
setmetatable(MouseInput, Input)

function MouseInput.create()
	local self = setmetatable(Input.create(), MouseInput)

	love.mouse.setPosition(WIDTH/2, HEIGHT/2)

	return self
end

function MouseInput:getMovement(dt)
	if self.clicked == false then
		local mx = love.mouse.getX()
		local my = love.mouse.getY()

		love.mouse.setPosition(WIDTH/2, HEIGHT/2)
		return mx-WIDTH/2, my-HEIGHT/2, false
	else
		return 0, 0, false
	end
end

function MouseInput:mousepressed(x, y, button)
	if button == "l" then
		self.clicked = true
		self.clickx = x
		self.clicky = y
	end
end

function MouseInput:mousereleased(x, y, button)
	if self.clicked == true and button == "l" then
		local dx = x - self.clickx
		local dy = y - self.clicky
		if dx ~= 0 or dy ~= 0 then
			self.action = vecToDir(dx, dy)
		end
		self.clicked = false
		love.mouse.setPosition(WIDTH/2, HEIGHT/2)
	end
end

function MouseInput:isDown()
	return love.mouse.isDown("l")
end

function MouseInput:getType() return Input.TYPE_MOUSE end

--- Joystick Input
JoystickInput = { SPEED = 300 }
JoystickInput.__index = JoystickInput
setmetatable(JoystickInput, Input)

function JoystickInput.create(id)
	local self = setmetatable(Input.create(), JoystickInput)

	self.id = id
	self.down = false

	return self
end

function JoystickInput:getMovement(dt, lock)
	local dx = 0
	local dy = 0

	local axis1 = love.joystick.getAxis(self.id, 1)
	local axis2 = love.joystick.getAxis(self.id, 2)

	if axis1 and axis2 then
		if not love.joystick.isDown(self.id, 1) or lock == false then
			if axis1 then
				dx = axis1 * self.SPEED * dt
			end
			if axis2 then
				dy = axis2 * self.SPEED * dt
			end
		elseif self.down == true then
			if axis1 ~= 0 or axis2 ~= 0 then
				self.down = false
				self.action = vecToDir(axis1, axis2)
			end
		end
	end

	return dx, dy, false
end

function JoystickInput:joystickpressed(joystick, button)
	if joystick == self.id and button == 1 then
		self.down = true
		self.clicked = true
	end
end

function JoystickInput:isDown()
	return love.joystick.isDown(self.id, 1)
end

function JoystickInput:getType() return Input.TYPE_JOYSTICK end
