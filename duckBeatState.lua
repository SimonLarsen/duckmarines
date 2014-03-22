DuckBeatState = {}
DuckBeatState.__index = DuckBeatState
setmetatable(DuckBeatState, State)

DuckBeatState.ID_NONE   = 0
DuckBeatState.ID_RED    = 1
DuckBeatState.ID_BLUE   = 2
DuckBeatState.ID_YELLOW = 3
DuckBeatState.ID_PURPLE = 4
DuckBeatState.ID_ALL    = 5

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
	self.indicator = ResMgr.getImage("duckbeat_indicator.png")

	self.imgBeat = {}
	self.imgBeat[0] = ResMgr.getImage("beatnone.png")
	for i=1,4 do
		self.imgBeat[i] = ResMgr.getImage("beat"..i..".png")
	end
	self.imgBeatAll = Animation.create(ResMgr.getImage("beatall.png"), 64, 37, 0, 0, 0.1, 4)
	self.font = ResMgr.getFont("joystix40")

	self:createBeats(16, 4)

	return self
end

function DuckBeatState:enter()
	MusicMgr.playMinigame()
end

function DuckBeatState:leave() stopMusic() end

function DuckBeatState:createBeats()
	for i=1,6 do
		for id=1,4 do
			local b = { id = id }
			table.insert(self.beats, b)
		end
	end
	for i=1,4 do
		local b = { id = DuckBeatState.ID_ALL, hasClicked = {false,false,false,false} }
		table.insert(self.beats, b)
	end

	shuffle(self.beats)

	for i,v in ipairs(self.beats) do
		v.y = -42*i
	end
end

function DuckBeatState:update(dt)
	-- Advance beats
	for i,v in ipairs(self.beats) do
		v.y = v.y + dt*150
	end
	self.imgBeatAll:update(dt)

	-- Check if game is over
	if self.beats[#self.beats].y > 340 then
		pushState(EventScoreState.create(self, self.scores, self.points))
	end

	-- Handle player input
	local found = false
	for i=1,4 do
		if self.inputs[i]:wasClicked() then
			found = false
			for j,v in ipairs(self.beats) do
				if v.y >= 235 and v.y <= 259 then
					if v.id == DuckBeatState.ID_ALL then
						if v.hasClicked[i] == false then
							v.hasClicked[i] = true
							self.points[i] = self.points[i] + 5
						else
							self.points[i] = self.points[i] - 20
						end
					else
						if v.id == i then
							self.points[i] = self.points[i] + 5
							v.id = DuckBeatState.ID_NONE
						else
							self.points[i] = self.points[i] - 20
						end
					end
					found = true
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
		if v.id == 5 then
			self.imgBeatAll:draw(255, v.y)
		else
			love.graphics.draw(self.imgBeat[v.id], 255, v.y)
		end
	end
	love.graphics.draw(self.indicator, 207, 241)

	love.graphics.scale(4, 4)
	love.graphics.setFont(ResMgr.getFont("bold"))
	love.graphics.print(self.points[1], 18, 19)
	love.graphics.print(self.points[2], 18, 56)
	love.graphics.print(self.points[3], 110, 19)
	love.graphics.print(self.points[4], 110, 56)

	love.graphics.pop()
	setScissor()
end

function DuckBeatState:isTransparent()
	return true
end
