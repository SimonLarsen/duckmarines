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

function Input:isDown()
	return false
end

function Input:clear()
	self.action = nil
	self.clicked = false
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

function NullInput:getMovement(dt, lock)
	return 0, 0, false
end

function NullInput:getType() return Input.TYPE_NONE end

--- Keyboard input
KeyboardInput = {}
KeyboardInput.__index = KeyboardInput
setmetatable(KeyboardInput, Input)

KeyboardInput.SPEED = 300

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

function KeyboardInput:keypressed(k)
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
	if button == "l" or button == "r" then
		self.clicked = true
		self.clickx = x
		self.clicky = y
	end
end

function MouseInput:mousereleased(x, y, button)
	if self.clicked == true and (button == "l" or button == "r") then
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
	return love.mouse.isDown("l", "r")
end

function MouseInput:getType() return Input.TYPE_MOUSE end

--- Joystick Input
JoystickInput = {}
JoystickInput.__index = JoystickInput
setmetatable(JoystickInput, Input)

JoystickInput.SPEED = 300
JoystickInput.DEADZONE = 0.5

function JoystickInput.create(joystick)
	local self = setmetatable(Input.create(), JoystickInput)

	self.joystick = joystick
	self.down = false

	return self
end

function JoystickInput:getMovement(dt, lock)
	local dx = 0
	local dy = 0

	local leftx = self.joystick:getGamepadAxis("leftx")
	local lefty = self.joystick:getGamepadAxis("lefty")

	local rightx = self.joystick:getGamepadAxis("rightx")
	local righty = self.joystick:getGamepadAxis("righty")

	if leftx and lefty then
		if not self:isDown() then
			if leftx and math.abs(leftx) > JoystickInput.DEADZONE then
				dx = leftx * self.SPEED * dt
			end
			if lefty and math.abs(lefty) > JoystickInput.DEADZONE then
				dy = lefty * self.SPEED * dt
			end
		else
			if math.abs(leftx) > JoystickInput.DEADZONE or math.abs(lefty) > JoystickInput.DEADZONE then
				self.action = vecToDir(leftx, lefty)
			end
		end
	end

	if rightx and righty then
		if math.abs(rightx) > JoystickInput.DEADZONE or math.abs(righty) > JoystickInput.DEADZONE then
			self.action = vecToDir(rightx, righty)
		end
	end

	return dx, dy, false
end

function JoystickInput:joystickpressed(joystick, button)
	if joystick:getID() == self.joystick:getID() then
		self.clicked = true
	end
end

function JoystickInput:isDown()
	return self.joystick:isGamepadDown("a", "b", "x", "y")
end

function JoystickInput:getType() return Input.TYPE_JOYSTICK end
