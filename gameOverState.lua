GameOverState = {}
GameOverState.__index = GameOverState
setmetatable(GameOverState, State)

GameOverState.LENGTH = 440

function GameOverState.create(parent, scores)
	local self = setmetatable(State.create(), GameOverState)

	self.inputs = parent.inputs
	for i=1,4 do
		if self.inputs[i]:getType() == Input.TYPE_BOT then
			self.inputs[i] = NullInput.create()
		end
	end

	self.mapname = parent.mapname
	self.rules = parent.rules
	self.scores = scores

	self.cursor = Cursor.create(WIDTH/2, HEIGHT/2, 1)

	self.menu = Menu.create(408-220, 26, 200, 32, 20, self)
	self.menu:addButton("REMATCH", "rematch", 408-220, 26)
	self.menu:addButton("MAIN MENU", "mainmenu", 408+20, 26)

	self.counts = {}
	self.bars = {}
	self.maxscore = 0
	for i=1,4 do
		self.counts[i] = 0
		self.bars[i] = ResMgr.getImage("scorebar"..i..".png")
		if self.scores[i] > self.maxscore then
			self.maxscore = self.scores[i]
		end
	end
	self.imgCrown = ResMgr.getImage("crown.png")

	return self
end

function GameOverState:update(dt)
	for i,v in ipairs(self.inputs) do
		if v:wasClicked() then
			self.menu:click(self.cursor.x, self.cursor.y)
		end
		self.cursor:move(v:getMovement(dt, false))
	end

	for i=1,4 do
		if self.counts[i] < self.scores[i] then
			local inc = math.max(8, (self.scores[i] - self.counts[i]))*dt
			self.counts[i] = self.counts[i] + inc
		end
	end
end

function GameOverState:draw()
	love.graphics.setColor(0, 0, 0, 128)
	love.graphics.rectangle("fill", 116, 0, WIDTH-116, HEIGHT)
	love.graphics.setColor(255, 255, 255)

	-- Draw buttons
	self.menu:draw()

	-- Draw bars
	if self.maxscore > 0 then
		for i=1,4 do
			local length = math.floor(self.counts[i]/self.maxscore*GameOverState.LENGTH)
			love.graphics.draw(self.bars[i], 116, 7+i*87, 0, length, 1)
			if self.counts[i] >= self.maxscore then
				love.graphics.draw(self.imgCrown, 128+length, 29+i*87)
			end
		end
	end

	self.cursor:draw()
end

function GameOverState:buttonPressed(id, source)
	if id == "rematch" then
		popState()
		popState()
		pushState(IngameState.create(self, self.mapname, self.rules))
	elseif id == "mainmenu" then
		popState()
		popState()
	end
end

function GameOverState:isTransparent() return true end
