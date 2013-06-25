--- Input base class
Input = {}
Input.__index = Input

Input.IT_KEYBOARD = 0
Input.IT_JOYSTICK = 1
Input.IT_MOUSE    = 2

--- Keyboard input
KeyboardInput = { SPEED = 300 }
KeyboardInput.__index = KeyboardInput
setmetatable(KeyboardInput, Input)

function KeyboardInput.create()
	local self = setmetatable({}, KeyboardInput)

	self.type = Input.IT_KEYBOARD

	return self
end

function KeyboardInput:getMovement(dt)
	local dx = 0
	local dy = 0
	if love.keyboard.isDown("left") then
		dx = dx - self.SPEED * dt end
	if love.keyboard.isDown("right") then
		dx = dx + self.SPEED * dt end
	if love.keyboard.isDown("up") then
		dy = dy - self.SPEED * dt end
	if love.keyboard.isDown("down") then
		dy = dy + self.SPEED * dt end

	return dx, dy, false
end

--- Mouse input
MouseInput = {}
MouseInput.__index = MouseInput
setmetatable(MouseInput, Input)

function MouseInput.create()
	local self = setmetatable({}, MouseInput)

	self.type = Input.IT_MOUSE

	return self
end

function MouseInput:getMovement(dt)
	local mx = love.mouse.getX()
	local my = love.mouse.getY()

	return love.mouse.getX(), love.mouse.getY(), true
end

--- Joystick Input
JoystickInput = { SPEED = 300 }
JoystickInput.__index = JoystickInput
setmetatable(JoystickInput, Input)

function JoystickInput.create(id)
	local self = setmetatable({}, JoystickInput)

	self.type = Input.IT_JOYSTICK
	self.id = id

	return self
end

function JoystickInput:getMovement(dt)
	local dx = 0
	local dy = 0

	local axis1 = love.joystick.getAxis(self.id, 1)
	local axis2 = love.joystick.getAxis(self.id, 2)

	if axis1 then
		dx = axis1 * self.SPEED * dt
	end
	if axis2 then
		dy = axis2 * self.SPEED * dt
	end

	return dx, dy, false
end
