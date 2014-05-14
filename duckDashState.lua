local State = require("state")
local EventScoreState = require("eventScoreState")

local DuckDashState = {}
DuckDashState.__index = DuckDashState
setmetatable(DuckDashState, State)

DuckDashState.INCREMENT = 24

function DuckDashState.create(parent, scores)
	local self = setmetatable(State.create(), DuckDashState)

	self.inputs = parent.inputs
	self.bots = parent.bots
	self.scores = scores

	self.time = 0
	self.positions = {}
	self.fronts = {}
	self.dolls = {}
	for i=1,4 do
		self.positions[i] = 0
		self.dolls[i] = ResMgr.getImage("dash_doll" .. i .. ".png")
		self.fronts[i] = ResMgr.getImage("duckdash_front" .. i .. ".png")
	end

	self.bg = ResMgr.getImage("duckdash_bg.png")
	self.frame = ResMgr.getImage("minigame_frame.png")
	self.anim = ResMgr.getImage("buttonmash_anim.png")
	self.anim_quads = {}
	self.anim_quads[0] = love.graphics.newQuad(0, 0, 140, 103, 280, 103)
	self.anim_quads[1] = love.graphics.newQuad(140, 0, 140, 103, 280, 103)

	return self
end

function DuckDashState:enter()
	MusicMgr.playMinigame()
	for i=1,4 do
		if self.bots[i] then
			self.bots[i]:duckDashEnter()
		end
	end
end

function DuckDashState:update(dt)
	self.time = self.time + dt

	for i=1,4 do
		if self.bots[i] then
			self.bots[i]:duckDashUpdate(dt)
			if self.bots[i]:wasClicked() then
				self.inputs[i].clicked = true
			end
			self.bots[i]:clear()
		end
		if self.inputs[i]:wasClicked() then
			playSound("squeek")
			self.positions[i] = self.positions[i] + DuckDashState.INCREMENT
		end
		if self.positions[i] >= 380 then
			local deltas = {0, 0, 0, 0}
			deltas[i] = rules.duckdashprize
			pushState(EventScoreState.create(self, self.scores, deltas))
			break
		end
	end
end

function DuckDashState:draw()
	love.graphics.draw(self.bg, 63, 54)
	love.graphics.draw(self.frame, 42, 33)
	setScissor(63, 54, 573, 333)

	for i=1,4 do
		love.graphics.draw(self.dolls[i], 133-(i-1)*20+self.positions[i], 258+(i-1)*20+math.sin(self.positions[i]/10)*10)
		love.graphics.draw(self.fronts[i], 63, 312+(i-1)*20)
	end

	local frame = math.floor((self.time*8) % 2)
	love.graphics.draw(self.anim, self.anim_quads[frame], 296, 81)
	setScissor()
end

function DuckDashState:isTransparent()
	return true
end

return DuckDashState
