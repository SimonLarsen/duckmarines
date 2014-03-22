DuckBeatState = {}
DuckBeatState.__index = DuckBeatState
setmetatable(DuckBeatState, State)

DuckBeatState.ID_NONE   = 0
DuckBeatState.ID_RED    = 1
DuckBeatState.ID_BLUE   = 2
DuckBeatState.ID_YELLOW = 3
DuckBeatState.ID_PURPLE = 4

-- Note: Song i 150 BPM

function DuckBeatState.create(parent, scores, rules)
	local self = setmetatable(State.create(), DuckBeatState)

	self.inputs = parent.inputs
	self.scores = scores
	self.rules = rules

	self.beats = {}
	self.nextBeat = 0
	self.points = {0, 0, 0, 0}

	self.bg = ResMgr.getImage("duckbeat_bg.png")
	self.frame = ResMgr.getImage("minigame_frame.png")

	self.imgBeat = {}
	self.imgBeat[0] = ResMgr.getImage("beatnone.png")
	for i=1,4 do
		self.imgBeat[i] = ResMgr.getImage("beat"..i..".png")
	end
	self.font = ResMgr.getFont("joystix40")

	self:createBeats(16, 4)

	return self
end

function DuckBeatState:enter()
	MusicMgr.playMinigame()
end

function DuckBeatState:leave() stopMusic() end

function DuckBeatState:createBeats()
	for i=1,4 do
		local seq = math.seq(1,16,1)
		for j=1,8 do
			local k = math.random(1, #seq)
			local e = { id = i, x = 182+(i-1)*54, y = -42*seq[k] }
			table.remove(seq, k)
			table.insert(self.beats, e)
		end
	end
end

function DuckBeatState:update(dt)
	-- Advance beats
	for i = #self.beats,1,-1 do
		self.beats[i].y = self.beats[i].y + dt*105
		if self.beats[i].y > 340 then
			table.remove(self.beats, i)
		end
	end

	-- Check if game is over
	if #self.beats == 0 then
		pushState(EventScoreState.create(self, self.scores, self.points))
	end

	-- Handle player input
	local found = false
	for i=1,4 do
		if self.inputs[i]:wasClicked() then
			found = false
			for j,v in ipairs(self.beats) do
				if v.y >= 270 and v.y <= 290 then -- 280 +- epsilon
					if v.id == i then
						self.points[i] = self.points[i] + 5
						v.id = DuckBeatState.ID_NONE
						found = true
					end
				end
			end
			if found == false then
				self.points[i] = self.points[i] - 20
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

	for i,v in ipairs(self.beats) do
		love.graphics.draw(self.imgBeat[v.id], v.x, v.y)
	end

	love.graphics.scale(4, 4)
	love.graphics.setFont(ResMgr.getFont("bold"))
	love.graphics.setColor(0, 0, 0, 128)
	love.graphics.print(self.points[1], 14, 19)
	love.graphics.print(self.points[2], 14, 58)
	love.graphics.print(self.points[3], 115, 19)
	love.graphics.print(self.points[4], 115, 58)
	love.graphics.setColor(255,255,255,255)
	love.graphics.print(self.points[1], 14, 18)
	love.graphics.print(self.points[2], 14, 57)
	love.graphics.print(self.points[3], 115, 18)
	love.graphics.print(self.points[4], 115, 57)

	love.graphics.pop()
	setScissor()
end

function DuckBeatState:isTransparent()
	return true
end
