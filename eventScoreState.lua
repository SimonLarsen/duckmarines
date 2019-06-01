local State = require("state")

local EventScoreState = {}
EventScoreState.__index = EventScoreState
setmetatable(EventScoreState, State)

EventScoreState.STATE_TRANSITION = 0
EventScoreState.STATE_POPIN = 1
EventScoreState.STATE_DISPLAY = 2

function EventScoreState.create(parent, scores, deltas)
	local self = setmetatable(State.create(), EventScoreState)

	for i=1,4 do
		scores[i] = scores[i] + deltas[i]
	end
	self.deltas = deltas

	self.state = EventScoreState.STATE_TRANSITION
	self.time = 0

	self.slidex = 0
	self.slidespeed = 200
	self.slideacc = 400
	self.hits = 0

	self.sliderleft = ResMgr.getImage("score_slide_left.png")
	self.sliderright = ResMgr.getImage("score_slide_right.png")
	self.duck_dolls = ResMgr.getImage("duck_dolls.png")
	self.plusminus = ResMgr.getImage("scorescreen_plusminus.png")

	self.quad_plus = love.graphics.newQuad(0,0,34,34,34,68)
	self.quad_minus = love.graphics.newQuad(0,34,34,34,34,68)
	self.duck_quads = {}
	for i=0,3 do
		self.duck_quads[i] = love.graphics.newQuad(0,i*51, 56, 51, 56, 204)
	end

	return self
end

function EventScoreState:enter()
	playSound("slide")
end

function EventScoreState:update(dt)
	if self.state == EventScoreState.STATE_TRANSITION then
		self.slidespeed = self.slidespeed + self.slideacc*dt
		self.slidex = self.slidex + self.slidespeed*dt

		if self.slidex > 287 then
			self.slidex = 287
			self.slidespeed = self.slidespeed * -0.2
			self.hits = self.hits+1
			if self.hits == 1 then
				playSound("slam")
			elseif self.hits == 3 then
				self.state = EventScoreState.STATE_POPIN
			end
		end
	elseif self.state == EventScoreState.STATE_POPIN then
		self.time = self.time + dt
		for i=0,3 do
			if self.time > i*0.2+0.2 and self.time-dt <= i*0.2+0.2 then
				playSound("slam")
			end
		end
		if self.time > 2 then
			popState()
			popState()
		end
	end
end

function EventScoreState:draw()
	setScissor(63, 54, 573, 333)

	love.graphics.draw(self.sliderleft, 63-287+self.slidex, 54)
	love.graphics.draw(self.sliderright, 636-self.slidex, 54)

	love.graphics.setFont(ResMgr.getFont("joystix40"))
	if self.state == EventScoreState.STATE_POPIN then
		for i=0,3 do
			if self.time > i*0.2 then
				local val = math.max(0, 0.25-(self.time-i*0.2))
				love.graphics.draw(self.duck_dolls, self.duck_quads[i], 274, 97+83*i, val*2, 1+val*8, 1+val*8, 28, 25)
			end
			if self.time > i*0.2+0.25 then
				love.graphics.setColor(0, 0, 0, 128/255)
				love.graphics.print(math.abs(self.deltas[i+1]), 364, 79+83*i)
				love.graphics.setColor(1,1,1,1)
				love.graphics.print(math.abs(self.deltas[i+1]), 364, 75+83*i)
				if self.deltas[i+1] >= 0 then
					love.graphics.draw(self.plusminus, self.quad_plus, 320, 80+83*i)
				else
					love.graphics.draw(self.plusminus, self.quad_minus, 320, 80+83*i)
				end
			end
		end
	end

	setScissor()
end

function EventScoreState:isTransparent()
	return true
end

return EventScoreState
