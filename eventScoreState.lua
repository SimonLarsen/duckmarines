EventScoreState = {}
EventScoreState.__index = EventScoreState
setmetatable(EventScoreState, State)

function EventScoreState.create(parent, scores, deltas)
	local self = setmetatable(State.create(), EventScoreState)

	self.scores = scores
	self.deltas = deltas

	return self
end

function EventScoreState:update(dt)
	for i=1,4 do
		self.scores[i] = self.scores[i] + self.deltas[i]
	end
	popState()
	popState()
end

function EventScoreState:isTransparent()
	return true
end
