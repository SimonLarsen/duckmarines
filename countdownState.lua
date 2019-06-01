local State = require("state")

local CountdownState = {}
CountdownState.__index = CountdownState
setmetatable(CountdownState, State)

function CountdownState.create(speed,start)
	local self = setmetatable(State.create(), CountdownState)

	self.speed = speed or 2
	self.time = start or 0

	self.img = ResMgr.getImage("321go.png")
	self.quads = {}
	self.quads[0] = love.graphics.newQuad(0, 0, 100, 128, 600, 128)
	self.quads[1] = love.graphics.newQuad(100, 0, 100, 128, 600, 128)
	self.quads[2] = love.graphics.newQuad(200, 0, 100, 128, 600, 128)
	self.quads[3] = love.graphics.newQuad(300, 0, 300, 128, 600, 128)

	return self
end

function CountdownState:update(dt)
	self.time = self.time + dt*self.speed
	if self.time > 4 then
		popState()
	end
end

function CountdownState:draw()
	if self.time == 0 then return end

	if self.time < 3 then
		local quad = math.floor(self.time)
		love.graphics.setColor(0, 0, 0, 128/255)
		love.graphics.draw(self.img, self.quads[quad], (WIDTH-100)/2, 176)
		love.graphics.setColor(1,1,1,1)
		love.graphics.draw(self.img, self.quads[quad], (WIDTH-100)/2, 168)
	else
		love.graphics.setColor(0, 0, 0, 128/255)
		love.graphics.draw(self.img, self.quads[3], (WIDTH-300)/2, 176)
		love.graphics.setColor(1,1,1,1)
		love.graphics.draw(self.img, self.quads[3], (WIDTH-300)/2, 168)
	end
end

function CountdownState:isTransparent()
	return true
end

return CountdownState
