EventTextState = {}
EventTextState.__index = EventTextState
setmetatable(EventTextState, State)

EventTextState.EVENT_TIMEUP = 32

local eventName = {
	"DUCK RUSH",
	"PREDATOR RUSH",
	"FREEZE TIME",
	"SWITCH",
	"PREDATORS",
	"VACUUM",
	"SPEED UP",
	"SLOW DOWN",

	"DUCK DASH",
	"ESCAPE"
}

function EventTextState.create(event)
	local self = setmetatable(State.create(), EventTextState)

	if event == EventTextState.EVENT_TIMEUP then
		self.text = "TIME UP"
		self.imgBox = ResMgr.getImage("timeup_box.png")
		self.offset = 160
	else
		self.text = eventName[event]
		self.imgBox = ResMgr.getImage("event_box.png")
		self.offset = 35
	end
	self.y = -106
	self.speed = 400
	self.gravity = 500
	self.hits = 0

	self.time = 0

	return self
end

function EventTextState:update(dt)
	self.time = self.time + dt

	self.speed = self.speed + self.gravity*dt
	self.y = self.y + self.speed*dt
	if self.y > 168 then
		self.y = 168
		if self.hits < 2 then
			self.speed = self.speed * -0.20
		else
			self.speed = 0
		end
		self.hits = self.hits + 1
	end

	if self.time >= 1.5 then
		popState()
	end
end

function EventTextState:draw()
	love.graphics.setColor(0, 0, 0, 128)
	love.graphics.rectangle("fill", 0, 0, WIDTH, HEIGHT)
	love.graphics.setColor(255, 255, 255, 255)

	love.graphics.draw(self.imgBox, 0, self.y)

	love.graphics.setFont(ResMgr.getFont("joystix40"))
	love.graphics.setColor(0, 0, 0, 128)
	love.graphics.print(self.text, self.offset, self.y+30+4)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print(self.text, self.offset, self.y+30)
end

function EventTextState:isTransparent()
	return true
end
