EscapeState = {}
EscapeState.__index = EscapeState
setmetatable(EscapeState, State)

EscapeState.STATE_GAME = 0
EscapeState.STATE_OVER = 1

EscapeState.TIME_SCALE = 2

function EscapeState.create(parent, scores, rules)
	local self = setmetatable(State.create(), EscapeState)

	self.inputs = parent.inputs
	self.scores = scores
	self.rules = rules
	self.state = EscapeState.STATE_GAME

	self.barTop = 33+56
	self.barBottom = 33+318
	self.barLength = 263

	self.greenTop = 213
	self.greenBottom = 233

	self.time = 0
	self.cursorPos = 0
	self.marker_pos = {}
	self.escaped = nil

	self.clicked = {false, false, false, false}
	self.markers = {}

	self.bg = ResMgr.getImage("escape_bg.png")
	self.mouth_closed = ResMgr.getImage("escape_mouth_closed.png")
	self.cursor = ResMgr.getImage("escape_cursor.png")
	self.markers = ResMgr.getImage("escape_markers.png")
	self.ducks = ResMgr.getImage("escape_ducks.png")
	self.ghosts = ResMgr.getImage("escape_ghosts.png")

	self.duck_quads = {}
	self.ghost_quads = {}
	self.marker_quads = {}
	for i=1,4 do
		self.duck_quads[i] = love.graphics.newQuad((i-1)*52, 0, 52, 47, 208, 47)
		self.ghost_quads[i] = love.graphics.newQuad((i-1)*50, 0, 50, 72, 200, 72)
		self.marker_quads[i] = love.graphics.newQuad((i-1)*8, 0, 8, 15, 32, 15)
	end

	return self
end

function EscapeState:update(dt)
	if self.state == EscapeState.STATE_GAME then
		self.time = self.time + dt*EscapeState.TIME_SCALE
		self.cursorPos = 1 - (math.cos(self.time) / 2 + 0.5)

		local allDead = true
		for i=1,4 do
			if self.clicked[i] == false and self.inputs[i]:wasClicked() then
				if self:isGreen() then
					self.state = EscapeState.STATE_OVER
					self.escaped = i
					self.time = 0
					break
				else
					self.clicked[i] = true
					self.marker_pos[i] = self:getCursorY()
				end
			end
			if self.clicked[i] == false then
				allDead = false
			end
		end
		if allDead == true then
			self.state = EscapeState.STATE_OVER
			self.time = 0
		end
	else
		self.time = self.time + dt
		if self.time >= 2 then
			self.time = 2
			local deltas = {0, 0, 0, 0}
			if self.escaped then
				deltas[self.escaped] = self.rules.escapeprize
				pushState(EventScoreState.create(self, self.scores, deltas))
			end
		end
	end
end

function EscapeState:draw()
	love.graphics.draw(self.bg, 42, 33)
	love.graphics.setScissor(63, 54, 573, 333)
	love.graphics.draw(self.cursor, 548, self:getCursorY()-5)

	for i=1,4 do
		if self.clicked[i] then
			love.graphics.draw(self.markers, self.marker_quads[i], 588, self.marker_pos[i]-10)
		end
	end

	if self.state == EscapeState.STATE_GAME then
		for i=1,4 do
			love.graphics.draw(self.ducks, self.duck_quads[i], 180+(i-1)*53, 298)
		end

	elseif self.state == EscapeState.STATE_OVER then
		love.graphics.draw(self.mouth_closed, 63, 54)
		if self.time > 1 then
			love.graphics.setColor(255, 255, 255, (2-self.time)*255)
		end
		for i=1,4 do
			if self.escaped == i then
				love.graphics.draw(self.ducks, self.duck_quads[i], 206+(i-1)*53, 340+self.time*100, -2*self.time, 1, 1, 26, 42)
			else
				love.graphics.draw(self.ghosts, self.ghost_quads[i], 181+(i-1)*53, 305-self.time*100)
			end
		end
		love.graphics.setColor(255,255,255,255)
	end
	love.graphics.setScissor()
end

function EscapeState:isTransparent()
	return true
end

function EscapeState:getCursorY()
	return self.barTop + self.cursorPos * self.barLength
end

function EscapeState:isGreen()
	local cursorY = self:getCursorY()
	return cursorY >= self.greenTop and cursorY <= self.greenBottom
end
