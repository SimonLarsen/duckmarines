--- Input base class
Input = {}
Input.__index = Input

Input.TYPE_NONE 	= 0
Input.TYPE_KEYBOARD = 1
Input.TYPE_MOUSE 	= 2
Input.TYPE_JOYSTICK = 3
Input.TYPE_BOT		= 4

function Input.create()
	local self = setmetatable({}, Input)

	self.action = nil
	self.clicked = false

	return self
end

function Input:getAction()
	return self.action
end

function Input:wasClicked()
	return self.clicked
end

function Input:wasMenuPressed()
	return self.menuPressed
end

function Input:isDown()
	return false
end

function Input:clear()
	self.action = nil
	self.clicked = false
	self.menuPressed = false
end

function Input:keypressed(k) end
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

function NullInput:getMovement(dt)
	return 0, 0, false
end

function NullInput:getType() return Input.TYPE_NONE end

--- Keyboard input
KeyboardInput = {}
KeyboardInput.__index = KeyboardInput
setmetatable(KeyboardInput, Input)

KeyboardInput.SPEED = 300

function KeyboardInput.create(lock)
	local self = setmetatable(Input.create(), KeyboardInput)

	self.type = Input.TYPE_KEYBOARD
	self.lock = lock or false

	return self
end

function KeyboardInput:getMovement(dt)
	local dx = 0
	local dy = 0

	if not love.keyboard.isDown(" ") or self.lock == false then
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

function KeyboardInput:keypressed(k)
	if k == " " then
		self.clicked = true
	elseif k == "escape" then
		self.menuPressed = true
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
	if self.clicked == true and (button == "l") then
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
JoystickInput = {}
JoystickInput.__index = JoystickInput
setmetatable(JoystickInput, Input)

JoystickInput.SPEED = 300
JoystickInput.DEADZONE = 0.25

function JoystickInput.create(joystick, lock)
	local self = setmetatable(Input.create(), JoystickInput)

	self.joystick = joystick

	if joystick:isGamepad() then
		local _
		_, self.leftXAxis  = joystick:getGamepadMapping("leftx")
		_, self.leftYAxis  = joystick:getGamepadMapping("lefty")
		_, self.rightXAxis = joystick:getGamepadMapping("rightx")
		_, self.rightYAxis = joystick:getGamepadMapping("righty")

		_, self.buttony = joystick:getGamepadMapping("y")
		_, self.buttonb = joystick:getGamepadMapping("b")
		_, self.buttona = joystick:getGamepadMapping("a")
		_, self.buttonx = joystick:getGamepadMapping("x")
		_, self.buttonstart = joystick:getGamepadMapping("start")
	else
		self.leftXAxis = 1
		self.leftYAxis = 2
		self.rightXAxis = 3
		self.rightYAxis = 4

		self.buttony = 1
		self.buttonb = 2
		self.buttona = 3
		self.buttonx = 4
		self.buttonstart = 5
	end

	self.down = false
	self.lock = lock or false

	return self
end

function JoystickInput:getMovement(dt)
	local dx = 0
	local dy = 0

	local leftx = self.joystick:getAxis(self.leftXAxis)
	local lefty = self.joystick:getAxis(self.leftYAxis)
	local rightx = self.joystick:getAxis(self.rightXAxis)
	local righty = self.joystick:getAxis(self.rightYAxis)

	if rightx and righty and not self:inDeadZone(rightx, righty) then
		self.action = vecToDir(rightx, righty)
	end

	if leftx and lefty and not self:inDeadZone(leftx, lefty) then
		if not self:isDown() or not self.lock then
			dx = leftx * self.SPEED * dt
			dy = lefty * self.SPEED * dt
		end
	end

	return dx, dy, false
end

function JoystickInput:joystickpressed(joystick, button)
	if joystick:getID() == self.joystick:getID() then
		self.clicked = true
		if button == self.buttonstart then
			self.menuPressed = true
		end
		if button == self.buttony then
			self.action = 0
		elseif button == self.buttonb then
			self.action = 1
		elseif button == self.buttona then
			self.action = 2
		elseif button == self.buttonx then
			self.action = 3
		end
	end
end

function JoystickInput:isDown()
	return self.joystick:isDown(self.buttony, self.buttonb, self.buttona, self.buttonx)
end

function JoystickInput:inDeadZone(axis1, axis2)
	return math.abs(axis1)^2 + math.abs(axis2)^2 < JoystickInput.DEADZONE^2
end

function JoystickInput:getType() return Input.TYPE_JOYSTICK end
