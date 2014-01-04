EventScoreState = {}
EventScoreState.__index = EventScoreState
setmetatable(EventScoreState, State)

EventScoreState.TIME = 2

function EventScoreState.create(parent, scores, deltas)
	local self = setmetatable(State.create(), EventScoreState)

	for i=1,4 do
		scores[i] = scores[i] + deltas[i]
	end
	self.deltas = deltas

	self.time = 0
	self.overlay = ResMgr.getImage("scorescreen_overlay.png")

	return self
end

function EventScoreState:update(dt)
	self.time = self.time + dt
	if self.time > EventScoreState.TIME then
		popState()
		popState()
	end
end

function EventScoreState:draw()
	love.graphics.draw(self.overlay, 227, 54)
end

function EventScoreState:isTransparent()
	return true
end
