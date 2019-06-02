local State = require("state")
local EventScoreState = require("eventScoreState")

local DuckBeatState = {}
DuckBeatState.__index = DuckBeatState
setmetatable(DuckBeatState, State)

DuckBeatState.ID_NONE     = 0
DuckBeatState.ID_RED      = 1
DuckBeatState.ID_BLUE     = 2
DuckBeatState.ID_YELLOW   = 3
DuckBeatState.ID_PURPLE   = 4
DuckBeatState.ID_PREDATOR = 5

DuckBeatState.FLASH_RED   = 1
DuckBeatState.FLASH_GREEN = 2

-- Note: Song is 150 BPM

function DuckBeatState.create(parent, scores)
	local self = setmetatable(State.create(), DuckBeatState)

	self.inputs = parent.inputs
	self.bots = parent.bots
	self.scores = scores

	self.beats = {}
	self.nextBeat = 0
	self.points = {0, 0, 0, 0}
	self.flash = {{time=0,color=1},{time=0,color=1},{time=0,color=1},{time=0,color=1}}
	self.pulse = 0.4

	self.bg = ResMgr.getImage("duckbeat_bg.png")
	self.marker = ResMgr.getImage("duckbeat_marker.png")
	self.frame = ResMgr.getImage("minigame_frame.png")

	self.imgBeat = {}
	self.imgBeat[DuckBeatState.ID_NONE] = ResMgr.getImage("beatnone.png")
	for i=1,4 do
		self.imgBeat[i] = ResMgr.getImage("beat"..i..".png")
	end
	self.imgBeat[DuckBeatState.ID_PREDATOR] = ResMgr.getImage("beatpred.png")
	self.font = ResMgr.getFont("joystix40")

	self:createBeats(16, 4)

	return self
end

function DuckBeatState:enter()
	MusicMgr.playMinigame()
	for i=1,4 do
		if self.bots[i] then
			self.bots[i]:duckBeatEnter(self.beats)
		end
	end
end

function DuckBeatState:leave() stopMusic() end

function DuckBeatState:createBeats()
	for i=1,4 do
		local seq = math.seq(1,48,1)
		for j=1,20 do
			local k = love.math.random(1, #seq)
			local y = 280 - 42*(seq[k]+8)
			local e
			if j <= 5 then
				e = { id = DuckBeatState.ID_PREDATOR, col = i, y = y }
			else
				e = { id = i, col = i, y = y }
			end
			table.remove(seq, k)
			table.insert(self.beats, e)
		end
	end
end

function DuckBeatState:update(dt)
	-- Advance beats
	for i = #self.beats,1,-1 do
		self.beats[i].y = self.beats[i].y + dt*210
		if self.beats[i].y > 340 then
			table.remove(self.beats, i)
		end
	end

	-- Update flash and pulse
	self.pulse = self.pulse + dt
	if self.pulse >= 0.4 then
		self.pulse = self.pulse % 0.4
	end
	for i=1,4 do
		self.flash[i].time = math.max(0, self.flash[i].time-6*dt)
	end

	-- Check if game is over
	if #self.beats == 0 then
		pushState(EventScoreState.create(self, self.scores, self.points))
	end

	-- Handle player input
	local found = false
	for i=1,4 do
		if self.bots[i] then
			self.bots[i]:duckBeatUpdate(dt)
			if self.bots[i]:wasClicked() then
				self.inputs[i].clicked = true
			end
			self.bots[i]:clear()
		end
		if self.inputs[i]:wasClicked() then
			found = false
			for j,v in ipairs(self.beats) do
				if v.y >= 260 and v.y <= 300 then -- 280 +- epsilon
					if v.col == i then
						if v.id == i then
							self.points[i] = self.points[i] + 5
							self.flash[i].time = 1
							self.flash[i].color = DuckBeatState.FLASH_GREEN
						else
							playSound("fail")
							self.points[i] = self.points[i] - 20
							self.flash[i].time = 1
							self.flash[i].color = DuckBeatState.FLASH_RED
						end
						v.id = DuckBeatState.ID_NONE
						found = true
					end
				end
			end
			if found == false then
				playSound("fail")
				self.points[i] = self.points[i] - 20
				self.flash[i].time = 1
				self.flash[i].color = DuckBeatState.FLASH_RED
			end
		end
	end
end

function DuckBeatState:draw()
	love.graphics.draw(self.bg, 63, 54)
	love.graphics.draw(self.frame, 42, 33)
	setScissor(63, 54, 573, 333)
	love.graphics.push()
	love.graphics.translate(63, 54)

	-- Pulse background to beat
	local alpha = 255 - 637.5*self.pulse
	love.graphics.setColor(1,1,1,alpha/255)
	love.graphics.rectangle("fill", 173, 0, 2, 333)
	love.graphics.rectangle("fill", 400, 0, 2, 333)
	love.graphics.setColor(1,1,1,1)

	-- Draw beats
	for i,v in ipairs(self.beats) do
		love.graphics.draw(self.imgBeat[v.id], 182+(v.col-1)*54, v.y)
	end

	-- Flash column on success/fail
	for i=1,4 do
		if self.flash[i].time > 0 then
			local alpha = self.flash[i].time * 128
			if self.flash[i].color == DuckBeatState.FLASH_RED then
				love.graphics.setColor(186/255, 18/255, 18/255, alpha/255)
			else
				love.graphics.setColor(84/255, 177/255, 33/255, alpha/255)
			end
			love.graphics.rectangle("fill", 181+(i-1)*54, 0, 51, 333)
			love.graphics.setColor(1,1,1,1)
		end
	end

	-- Draw marker
	love.graphics.draw(self.marker, 168, 275)

	love.graphics.scale(4, 4)
	love.graphics.setFont(ResMgr.getFont("bold"))
	love.graphics.setColor(0, 0, 0, 128/255)
	love.graphics.print(self.points[1], 12, 19)
	love.graphics.print(self.points[2], 12, 58)
	love.graphics.print(self.points[3], 113, 19)
	love.graphics.print(self.points[4], 113, 58)
	love.graphics.setColor(1,1,1,1)
	love.graphics.print(self.points[1], 12, 18)
	love.graphics.print(self.points[2], 12, 57)
	love.graphics.print(self.points[3], 113, 18)
	love.graphics.print(self.points[4], 113, 57)

	love.graphics.pop()
	setScissor()
end

function DuckBeatState:isTransparent()
	return true
end

return DuckBeatState
