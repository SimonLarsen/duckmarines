EventTextState = {}
EventTextState.__index = EventTextState
setmetatable(EventTextState, State)

local eventName = {
	"DUCK RUSH",
	"PREDATOR RUSH",
	"FREEZE TIME",
	"SWITCH",
	"PREDATORS",
	"VACUUM",
	"SPEED UP",
	"SLOW DOWN"
}

function EventTextState.create(event)
	local self = setmetatable({}, EventTextState)

	self.event = event
	self.imgBox = ResMgr.getImage("event_box.png")
	self.boxy = -106
	self.time = 0

	return self
end

function EventTextState:update(dt)
	self.time = self.time + dt
	if self.time < 0.5 then
		self.boxy = self.time*2*274 - 106
	elseif self.time < 1.5 then
		self.boxy = 168
	else
		popState()
	end
end

function EventTextState:draw()
	love.graphics.setColor(0, 0, 0, 128)
	love.graphics.rectangle("fill", 0, 0, WIDTH, HEIGHT)
	love.graphics.setColor(255, 255, 255, 255)

	love.graphics.draw(self.imgBox, 0, self.boxy)

	love.graphics.setFont(ResMgr.getFont("bold"))
	love.graphics.push()
	love.graphics.scale(4, 4)
	love.graphics.setColor(0, 0, 0, 128)
	love.graphics.print(eventName[self.event], 10, math.floor((self.boxy+40)/4)+1)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print(eventName[self.event], 10, math.floor((self.boxy+40)/4))
	love.graphics.pop()
end

function EventTextState:isTransparent()
	return true
end
