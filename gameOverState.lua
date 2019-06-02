require("input")
local State = require("state")
local CountdownState = require("countdownState")
local Menu = require("menu")
local Cursor = require("cursor")
local LevelSelectionState = require("levelSelectionState")
local CountdownState = require("countdownState")

local GameOverState = {}
GameOverState.__index = GameOverState
setmetatable(GameOverState, State)

GameOverState.LENGTH = 440

GameOverState.STATE_BARS = 0
GameOverState.STATE_GRAPH = 1

function GameOverState.create(parent, scores, stats)
	local self = setmetatable(State.create(), GameOverState)

	self.cursors[1] = Cursor.create(WIDTH/2, HEIGHT/2, 1)
	self.inputs = parent.inputs
	for i=1,4 do
		if self.inputs[i]:getType() == Input.TYPE_BOT then
			self.inputs[i] = NullInput.create()
		end
		self.cursors[1]:addInput(self.inputs[i])
	end

	self.mapname = parent.mapname
	self.scores = scores
	self.stats = stats

	self.state = GameOverState.STATE_BARS
	self.drawCrown = false
	self.crownScale = 2

	self.menu = self:addComponent(Menu.create(408-220, 26, 180, 32, 20, self))
	self.menu:addButton("REMATCH", "rematch", 125, 26)
	self.menu:addButton("EXIT", "exit", 316, 26)
	self.showButton = self.menu:addButton("SHOW GRAPH", "show", 507, 26)
	self.imgCrown = ResMgr.getImage("crown.png")

	self.counts = {}
	self.bars = {}
	self.maxscore = 0
	self.maxstat = 0
	for i=1,4 do
		self.counts[i] = 0
		self.bars[i] = ResMgr.getImage("scorebar"..i..".png")
		self.maxscore = math.max(self.maxscore, self.scores[i])
		for j=0,9 do
			self.maxstat = math.max(self.maxstat, self.stats[j][i])
		end
	end
	self.maxstat = math.max(self.maxstat, self.maxscore)

	self:startCoroutine(coroutine.create(function()
		while self.drawCrown == false do
			coroutine.yield()
		end
		while self.crownScale > 1 do
			self.crownScale = math.max(1, self.crownScale - 3*coroutine.yield())
		end
	end))

	return self
end

function GameOverState:enter()
	MusicMgr.playGameOver()
end

function GameOverState:update(dt)
	for i=1,4 do
		if self.counts[i] < self.scores[i] then
			local inc = math.max(20, (self.scores[i] - self.counts[i]))*dt
			self.counts[i] = self.counts[i] + inc
		end
		if self.counts[i] >= self.maxscore then
			self.drawCrown = true
		end
	end
end

function GameOverState:draw()
	love.graphics.setColor(0, 0, 0, 128/255)
	love.graphics.rectangle("fill", 116, 0, WIDTH-116, HEIGHT)
	love.graphics.setColor(1, 1, 1)

	if self.state == GameOverState.STATE_BARS then
		-- Draw bars
		if self.maxscore > 0 then
			for i=1,4 do
				local length = math.floor(self.counts[i]/self.maxscore*GameOverState.LENGTH)
				love.graphics.draw(self.bars[i], 116, 7+i*87, 0, length, 1)
				if self.counts[i] >= self.maxscore then
					love.graphics.draw(self.imgCrown, 174+length, 49+i*87, 0, 2*self.crownScale, 2*self.crownScale, 30, 30)
				end
			end
		end
	elseif self.state == GameOverState.STATE_GRAPH then
		love.graphics.setLineWidth(2)
		local colors = {
			{234/255,73/255,89/255}, {76/255,74/255,145/255}, {1,130/255,46/255}, {150/255,75/255,164/255}
		}
		for i=1,4 do
			for j=0,9 do
				local y = 390-self.stats[j][i]/self.maxstat*292
				local nexty
				if j < 9 then
					nexty = 390-self.stats[j+1][i]/self.maxstat*292
				else
					nexty = 390-self.scores[i]/self.maxstat*292
				end
				love.graphics.setColor(0,0,0)
				love.graphics.line(122.5+j*48, y+4.5, 122.5+(j+1)*48, nexty+4.5)
				love.graphics.rectangle("fill", 120+j*48, y+2, 6,6)
				love.graphics.setColor(colors[i])
				love.graphics.line(122.5+j*48, y+2.5, 122.5+(j+1)*48, nexty+2.5)
				love.graphics.rectangle("fill", 120+j*48, y, 6,6)
			end
			love.graphics.setColor(0,0,0)
			love.graphics.rectangle("fill", 600, 392-self.scores[i]/self.maxstat*292, 6,6)
			love.graphics.setColor(colors[i])
			love.graphics.rectangle("fill", 600, 390-self.scores[i]/self.maxstat*292, 6,6)
		end
	end
	love.graphics.setColor(1,1,1)
end

function GameOverState:buttonPressed(id, source)
	if id == "rematch" then
		playSound("quack")
		popState()
		popState()
		pushState(IngameState.create(self, self.mapname))
		pushState(CountdownState.create())
	elseif id == "exit" then
		playSound("quack")
		popState()
		popState()
		pushState(LevelSelectionState.create(self))
	elseif id == "show" then
		playSound("click")
		if self.state == GameOverState.STATE_BARS then
			self.state = GameOverState.STATE_GRAPH
			self.showButton.text = "SHOW BARS"
		else
			self.state = GameOverState.STATE_BARS
			self.showButton.text = "SHOW GRAPH"
		end
	end
end

function GameOverState:isTransparent() return true end

return GameOverState
