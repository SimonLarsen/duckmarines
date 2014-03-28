local State = require("state")
local Animation = require("anim")

local SwitchAnimState = {}
SwitchAnimState.__index = SwitchAnimState
setmetatable(SwitchAnimState, State)

SwitchAnimState.SINK_TIME = 1
SwitchAnimState.RAISE_TIME = 1
SwitchAnimState.TOTAL_TIME = SwitchAnimState.SINK_TIME + SwitchAnimState.RAISE_TIME

function SwitchAnimState.create(oldsubs, newsubs)
	local self = setmetatable(State.create(), SwitchAnimState)

	self.oldsubs = oldsubs
	self.newsubs = newsubs

	self.oldanims = {}
	self.newanims = {}
	for i=1,4 do
		self.oldanims[i] = Animation.create(ResMgr.getImage("sub_sink".. oldsubs[i].player ..".png"),
			48, 48, 0, 0, self.SINK_TIME/12, 12)
		self.newanims[i] = Animation.create(ResMgr.getImage("sub_raise".. newsubs[i].player ..".png"),
			48, 48, 0, 0, self.RAISE_TIME/8, 8)
		self.oldanims[i].mode = 2
		self.newanims[i].mode = 2
	end

	self.time = 0

	return self
end

function SwitchAnimState:update(dt)
	self.time = self.time + dt

	if self.time < SwitchAnimState.SINK_TIME then
		for i=1,4 do
			self.oldanims[i]:update(dt)
		end
	elseif self.time < SwitchAnimState.TOTAL_TIME then
		for i=1,4 do
			self.newanims[i]:update(dt)
		end
	else
		popState()
	end
end

function SwitchAnimState:draw()
	love.graphics.push()
	love.graphics.translate(121, 8)
	if self.time < SwitchAnimState.SINK_TIME then
		for i=1,4 do
			self.oldanims[i]:draw(self.oldsubs[i].x*48, self.oldsubs[i].y*48)
		end
	else
		for i=1,4 do
			self.newanims[i]:draw(self.newsubs[i].x*48, self.newsubs[i].y*48)
		end
	end
	love.graphics.pop()
end

function SwitchAnimState:isTransparent()
	return true
end

return SwitchAnimState
