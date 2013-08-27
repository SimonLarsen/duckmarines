DuckDashState = {}
DuckDashState.__index = DuckDashState
setmetatable(DuckDashState, State)

DuckDashState.INCREMENT = 24

function DuckDashState.create(parent, scores, rules)
	local self = setmetatable(State.create(), DuckDashState)

	self.inputs = parent.inputs
	self.scores = scores
	self.rules = rules

	self.positions = {}
	self.fronts = {}
	self.dolls = {}
	for i=1,4 do
		self.positions[i] = 0
		self.dolls[i] = ResMgr.getImage("dash_doll" .. i .. ".png")
		self.fronts[i] = ResMgr.getImage("duckdash_front" .. i .. ".png")
	end

	self.bg = ResMgr.getImage("duckdash_bg.png")
	self.anim = ResMgr.getImage("buttonmash_anim.png")
	self.anim_quads = {}
	self.anim_quads[0] = love.graphics.newQuad(0, 0, 140, 103, 280, 103)
	self.anim_quads[1] = love.graphics.newQuad(140, 0, 140, 103, 280, 103)
	self.frame = 0

	return self
end

function DuckDashState:update(dt)
	self.frame = (self.frame + dt*8) % 2

	for i=1,4 do
		if self.inputs[i]:wasClicked() then
			self.positions[i] = self.positions[i] + DuckDashState.INCREMENT
		end
		if self.positions[i] >= 380 then
			self.scores[i] = self.scores[i] + self.rules.duckdashprize
			popState()
			break
		end
	end
end

function DuckDashState:draw()
	love.graphics.draw(self.bg, 56, 47)

	for i=1,4 do
		love.graphics.draw(self.dolls[i], 133-(i-1)*20+self.positions[i], 258+(i-1)*20+math.sin(self.positions[i]/10)*10)
		love.graphics.draw(self.fronts[i], 63, 312+(i-1)*20)
	end

	local frame = math.floor(self.frame)
	love.graphics.drawq(self.anim, self.anim_quads[frame], 296, 81)
end

function DuckDashState:isTransparent()
	return true
end
