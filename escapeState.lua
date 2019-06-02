local State = require("state")
local EventScoreState = require("eventScoreState")
local Animation = require("anim")

local EscapeState = {}
EscapeState.__index = EscapeState
setmetatable(EscapeState, State)

EscapeState.STATE_GAME  = 0
EscapeState.STATE_SHAKE = 1
EscapeState.STATE_OVER  = 2

EscapeState.TIME_SCALE = 3
EscapeState.DURATION = 6
EscapeState.WARNING_TIME = 2

function EscapeState.create(parent, scores)
	local self = setmetatable(State.create(), EscapeState)

	self.inputs = parent.inputs
	self.bots = parent.bots
	self.scores = scores
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
	self.offsetx = 0

	self.clicked = {false, false, false, false}
	self.markers = {}

	self.bg = ResMgr.getImage("escape_bg.png")
	self.frame = ResMgr.getImage("minigame_frame.png")
	self.mouth_top = ResMgr.getImage("escape_mouth_top.png")
	self.mouth_closed = ResMgr.getImage("escape_mouth_closed.png")
	self.mouth_closed_lines = ResMgr.getImage("escape_mouth_closed_lines.png")
	self.cursor = ResMgr.getImage("escape_cursor.png")
	self.markers = ResMgr.getImage("escape_markers.png")
	self.ducks = ResMgr.getImage("escape_ducks.png")
	self.ghosts = ResMgr.getImage("escape_ghosts.png")

	self.buttonAnim = Animation.create(ResMgr.getImage("small_button_anim.png"), 44, 38, 0, 0, 0.2, 2)
	self.tearAnim = Animation.create(ResMgr.getImage("teardrop.png"), 9, 16, 0, 0, 0.3, 2)

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

function EscapeState:enter()
	MusicMgr.playMinigame()
	for i=1,4 do
		if self.bots[i] then
			self.bots[i]:escapeEnter()
		end
	end
end

function EscapeState:update(dt)
	self.time = self.time + dt
	self.buttonAnim:update(dt)
	self.tearAnim:update(dt)

	if self.state == EscapeState.STATE_GAME then
		self.cursorPos = 1 - (math.cos(self.time*EscapeState.TIME_SCALE) / 2 + 0.5)

		local allDead = true
		for i=1,4 do
			if self.bots[i] then
				self.bots[i]:escapeUpdate(dt)
				if self.bots[i]:wasClicked() then
					self.inputs[i].clicked = true
				end
				self.bots[i]:clear()
			end
			if self.clicked[i] == false and self.inputs[i]:wasClicked() then
				if self:isGreen() then
					playSound("squeek")
					self.escaped = i
					self.state = EscapeState.STATE_SHAKE
					self.time = 0
					break
				else
					playSound("fail")
					self.clicked[i] = true
					self.marker_pos[i] = self:getCursorY()
				end
			end
			if self.clicked[i] == false then
				allDead = false
			end
		end

		if self.time > EscapeState.DURATION then
			self.state = EscapeState.STATE_OVER
			playSound("slam")
			self.time = 0
		elseif self.time > EscapeState.DURATION-EscapeState.WARNING_TIME then
			self.offsetx = math.sign(math.cos(self.time*30))*6
		end
		if allDead == true then
			self.state = EscapeState.STATE_SHAKE
			self.time = 0
		end

	elseif self.state == EscapeState.STATE_SHAKE then
		self.offsetx = math.sign(math.cos(self.time*30))*6
		if self.time > 1 then
			self.time = 0
			self.state = EscapeState.STATE_OVER
			playSound("slam")
			if self.escaped then
				playSound("escape")
			end
		end

	elseif self.state == EscapeState.STATE_OVER then
		if self.time >= 2 then
			self.time = 2
			local deltas = {0, 0, 0, 0}
			if self.escaped then
				deltas[self.escaped] = rules.escapeprize
			end
			pushState(EventScoreState.create(self, self.scores, deltas))
		end
	end
end

function EscapeState:draw()
	love.graphics.draw(self.bg, 63, 54)
	love.graphics.draw(self.frame, 42, 33)
	setScissor(63, 54, 573, 333)
	love.graphics.draw(self.cursor, 548, self:getCursorY()-5)

	for i=1,4 do
		if self.clicked[i] then
			love.graphics.draw(self.markers, self.marker_quads[i], 588, self.marker_pos[i]-10)
		end
	end

	if self.state == EscapeState.STATE_GAME then
		for i=1,4 do
			love.graphics.draw(self.ducks, self.duck_quads[i], 180+(i-1)*53, 298)
			if self.clicked[i] and self.escaped ~= i then
				self.tearAnim:draw(213+(i-1)*53, 329)
			end
		end
		self.buttonAnim:draw(501, 202)
		love.graphics.draw(self.mouth_top, 64+self.offsetx, 66)
	
	elseif self.state == EscapeState.STATE_SHAKE then
		for i=1,4 do
			love.graphics.draw(self.ducks, self.duck_quads[i], 180+(i-1)*53, 298)
			if self.clicked[i] and self.escaped ~= i then
				self.tearAnim:draw(213+(i-1)*53, 329)
			end
		end
		love.graphics.draw(self.mouth_top, 64+self.offsetx, 66)
	
	elseif self.state == EscapeState.STATE_OVER then
		if self.time < 0.2 then
			love.graphics.draw(self.mouth_closed_lines, 63, 54)
		else
			love.graphics.draw(self.mouth_closed, 63, 54)
		end

		for i=1,4 do
			if self.escaped == i then
				love.graphics.draw(self.ducks, self.duck_quads[i], 206+(i-1)*53-self.time*250, 340-self.time*250, -6*self.time, 1+self.time, 1+self.time, 26, 42)
			else
				if self.time > 1 then
					love.graphics.setColor(1, 1, 1, (2-self.time))
				end
				love.graphics.draw(self.ghosts, self.ghost_quads[i], 181+(i-1)*53, 305-self.time*140)
				love.graphics.setColor(1,1,1,1)
			end
		end
	end
	setScissor()
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

return EscapeState
