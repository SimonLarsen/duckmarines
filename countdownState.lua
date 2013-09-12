CountdownState = {}
CountdownState.__index = CountdownState
setmetatable(CountdownState, State)

function CountdownState.create(event)
	local self = setmetatable(State.create(), CountdownState)

	self.time = 0

	self.img = ResMgr.getImage("321go.png")
	self.quads = {}
	self.quads[0] = love.graphics.newQuad(0, 0, 100, 128, 600, 128)
	self.quads[1] = love.graphics.newQuad(100, 0, 100, 128, 600, 128)
	self.quads[2] = love.graphics.newQuad(200, 0, 100, 128, 600, 128)
	self.quads[3] = love.graphics.newQuad(300, 0, 300, 128, 600, 128)

	return self
end

function CountdownState:update(dt)
	self.time = self.time + dt
	if self.time > 4 then
		popState()
	end
end

function CountdownState:draw()
	if self.time < 3 then
		local quad = math.floor(self.time)
		love.graphics.setColor(0, 0, 0, 128)
		love.graphics.drawq(self.img, self.quads[quad], 408-50, 176)
		love.graphics.setColor(255,255,255,255)
		love.graphics.drawq(self.img, self.quads[quad], 408-50, 168)
	else
		love.graphics.setColor(0, 0, 0, 128)
		love.graphics.drawq(self.img, self.quads[3], 408-150, 176)
		love.graphics.setColor(255,255,255,255)
		love.graphics.drawq(self.img, self.quads[3], 408-150, 168)
	end
end

function CountdownState:isTransparent()
	return true
end
