local State = require("state")
local Map = require("map")
local Cursor = require("cursor")
local Arrow = require("arrow")
local Entity = require("entity")
local Duck = require("duck")
local PinkDuck = require("pinkduck")
local GoldDuck = require("goldduck")
local Enemy = require("enemy")
local Bot = require("bot")
local GameOverState = require("gameOverState")
local EventTextState = require("eventTextState")
local DuckDashState = require("duckDashState")
local EscapeState = require("escapeState")
local DuckBeatState = require("duckBeatState")
local CountdownState = require("countdownState")
local SwitchAnimState = require("switchAnimState")
local PauseGameState = require("pauseGameState")
require("particles")

local IngameState = {}
IngameState.__index = IngameState
setmetatable(IngameState, State)

IngameState.EVENT_NONE 		= 0
IngameState.EVENT_RUSH 		= 1
IngameState.EVENT_PREDRUSH	= 2
IngameState.EVENT_FREEZE	= 3
IngameState.EVENT_SWITCH	= 4
IngameState.EVENT_PREDATORS	= 5
IngameState.EVENT_VACUUM	= 6
IngameState.EVENT_SPEEDUP	= 7
IngameState.EVENT_SLOWDOWN	= 8

IngameState.EVENT_DUCKDASH  = 9
IngameState.EVENT_ESCAPE    = 10
IngameState.EVENT_DUCKBEAT  = 11

IngameState.EVENT_COUNT = 8
IngameState.EVENT_COUNT_WITH_GAMES = 11

IngameState.NSTATS = 10

function IngameState.create(parent, mapname)
	local self = setmetatable(State.create(), IngameState)

	self.mapname = mapname

	-- Load map
	self.map = Map.create(mapname)

	self.arrows = {}
	for i=1,4 do
		self.arrows[i] = {}
	end

	self.entities = {}
	self.particles = {}

	-- Initialize cursors
	self.cursors = {}
	for i,v in ipairs(self.map:getSubmarines()) do
		self.cursors[v.player] = Cursor.create(v.x*48+24, v.y*48+24, v.player)
		self.cursors[v.player]:setOffset(121,8)
	end

	-- Initialize inputs
	self.inputs = parent.inputs
	for i=1,4 do
		self.inputs[i].lock = true
		self.cursors[i]:addInput(self.inputs[i])
	end

	-- Create bots
	self.bots = {}
	for i=1,4 do
		if self.inputs[i]:getType() == Input.TYPE_NONE then
			local level = config["ai"..i.."level"]
			self.bots[i] = Bot.create(self.map, i, self.cursors[i], level)
		end
	end

	-- Set variables and counters
	self.timeLeft = rules.roundtime
	self.time = 0

	self.event = IngameState.EVENT_NONE
	self.eventTime = 0
	self.nextEntity = 2

	self.score = {}
	for i=1,4 do
		self.score[i] = 0
	end
	self.stats = {}
	self.nextStat = 0

	-- Get sidebar image
	self.imgSidebar = ResMgr.getImage("sidebar.png")

	-- Get marker images
	self.marker = {}
	self.marker[1] = ResMgr.getImage("marker1.png")
	self.marker[2] = ResMgr.getImage("marker2.png")
	self.marker[3] = ResMgr.getImage("marker3.png")
	self.marker[4] = ResMgr.getImage("marker4.png")

	return self
end

function IngameState:enter()
	MusicMgr.playIngame()

	-- Stupid mouse bug hack fix
	for i=1,4 do
		if self.inputs[i] then
			self.inputs[i].down = false
		end
	end
end

function IngameState:update(dt)
	-- Check if player paused the game
	for i=1,4 do
		if self.inputs[i]:wasMenuPressed() then
			pushState(PauseGameState.create(self))
		end
	end

	-- Advance time
	self.timeLeft = self.timeLeft - dt
	self.time = self.time + dt
	if self.timeLeft < 1 then
		self.timeLeft = 0
		pushState(GameOverState.create(self, self.score, self.stats))
		pushState(EventTextState.create(EventTextState.EVENT_TIMEUP))
	end

	-- Advance event time
	if self.event ~= 0 then
		self.eventTime = self.eventTime - dt
		if self.eventTime < 0 then
			self.event = 0
		end
	end

	-- Update spawn counter if not frozen
	if self.event ~= IngameState.EVENT_FREEZE then
		self.nextEntity = self.nextEntity - dt
	end

	-- Spawn new entity when counter runs out
	if self.nextEntity <= 0 then
		local freq
		if self.event == IngameState.EVENT_RUSH then
			freq = rules.rushfrequency
		else
			freq = rules.frequency
		end
		self.nextEntity = 1/(freq + math.randnorm()*0.8*freq)*60

		local spawns = self.map:getSpawnPoints()
		local e = table.random(spawns)

		if self.event == IngameState.EVENT_RUSH then
			table.insert(self.entities, Duck.create(e.x*48+24, e.y*48+24, e.dir))
		elseif self.event == IngameState.EVENT_PREDRUSH then
			table.insert(self.entities, Enemy.create(e.x*48+24, e.y*48+24, e.dir))
		else
			-- Spawn random entity according to rules' percentages
			local choice = math.random(0, 99)
			-- enemy
			if choice < rules.enemyperc then
				table.insert(self.entities, Enemy.create(e.x*48+24, e.y*48+24, e.dir))
			-- golden duck
			elseif choice < rules.enemyperc + rules.goldperc then
				table.insert(self.entities, GoldDuck.create(e.x*48+24, e.y*48+24, e.dir))
			-- pink duck
			elseif choice < rules.enemyperc + rules.goldperc + rules.pinkperc then
				table.insert(self.entities, PinkDuck.create(e.x*48+24, e.y*48+24, e.dir))
			-- normal duck
			else
				table.insert(self.entities, Duck.create(e.x*48+24, e.y*48+24, e.dir))
			end
		end
	end

	-- Cap cursor positions
	for i=1,4 do
		self.cursors[i].x = math.cap(self.cursors[i].x, 0, 570)
		self.cursors[i].y = math.cap(self.cursors[i].y, 0, 428)
	end

	-- Remove expired arrows
	if self.event ~= IngameState.EVENT_FREEZE then
		for i=1,4 do
			for j=#self.arrows[i], 1, -1 do
				local v = self.arrows[i][j]
				v.time = v.time + dt
				if v.time >= rules.arrowtime then
					table.remove(self.arrows[i], j)
				end
			end
		end
	end

	-- Update bots
	for i=1,4 do
		if self.bots[i] then
			self.bots[i]:update(dt, self.map, self.entities, self.arrows)
			local mx, my = self.bots[i]:getMovement(dt, self.cursors[i])
			if mx then
				self.cursors[i]:move(mx, my)
			end
			local ac = self.bots[i]:getAction(self.cursors[i])
			if ac then
				local cx = math.floor(self.cursors[i].x / 48)
				local cy = math.floor(self.cursors[i].y / 48)
				self:placeArrow(cx, cy, ac, i)
			end
			self.bots[i]:clear()
		end
	end

	-- Check player actions
	for i=1,4 do
		local ac = self.inputs[i]:getAction()
		if ac then
			local cx = math.floor(self.cursors[i].x / 48)
			local cy = math.floor(self.cursors[i].y / 48)
			self:placeArrow(cx, cy, ac, i)
		end
	end

	-- Update entities
	if self.event ~= IngameState.EVENT_FREEZE then
		-- Adjust delta time according to event
		local entityDT = dt
		if self.event == IngameState.EVENT_SPEEDUP then
			entityDT = dt*1.5
		elseif self.event == IngameState.EVENT_SLOWDOWN then
			entityDT = dt*0.5
		end

		for i=#self.entities, 1, -1 do
			self.entities[i]:update(entityDT, self.map, self.arrows, self.event)
			local tile = self.entities[i]:getTile()

			-- Check if entities hit submarine
			if tile >= 10 and tile <= 13 then
				local eType = self.entities[i]:getType()
				local player = tile-9
				if eType == Entity.TYPE_DUCK then
					self.score[player] = self.score[player] + 1

				elseif eType == Entity.TYPE_GOLDDUCK then
					playSound("goldduck")
					self.score[player] = self.score[player] + rules.goldbonus
					table.insert(self.particles, BonusTextParticle.create(
						self.entities[i].x, self.entities[i].y-12, "+"..rules.goldbonus))

				elseif eType == Entity.TYPE_PINKDUCK then
					playSound("goldduck")
					self.score[player] = self.score[player] + rules.pinkbonus
					self:triggerEvent(player)

				elseif eType == Entity.TYPE_ENEMY then
					playSound("fail")
					self.score[player] = math.floor(self.score[player]*0.6667)
					table.insert(self.particles, BonusTextParticle.create(
						self.entities[i].x, self.entities[i].y-12,
						"-"..math.ceil(self.score[player]*0.3333)))
				end

				local x = math.floor(self.entities[i].x / 48)*48-3
				local y = math.floor(self.entities[i].y / 48)*48+1
				table.insert(self.particles, SubBulgeParticle.create(x, y, player))
				table.remove(self.entities, i)

			-- Check if entity hit hole
			elseif tile == Map.TILE_HOLE then
				local x = math.floor(self.entities[i].x / 48)*48
				local y = math.floor(self.entities[i].y / 48)*48
				table.insert(self.particles, DuckFallParticle.create(x, y, self.entities[i]:getType()))
				table.remove(self.entities, i)

			-- Check collision with ducks if predator
			elseif rules.predatorseat and self.entities[i]:getType() == Entity.TYPE_ENEMY then
				for j=#self.entities, 1, -1 do
					local jType = self.entities[j]:getType()
					if jType == Entity.TYPE_DUCK or jType == Entity.TYPE_GOLDDUCK or jType == Entity.TYPE_PINKDUCK then
						local dist = (self.entities[i].x-self.entities[j].x)^2 + (self.entities[i].y-self.entities[j].y)^2
						if dist < 128 then
							table.insert(self.particles, DucksplosionParticle.create(self.entities[j].x, self.entities[j].y, self.entities[j]:getType()))
							table.remove(self.entities, j)
							break
						end
					end
				end
			end
		end
	end

	-- Sort entities by y-coordinate for drawing order
	bubblesort(self.entities, function(a,b) return a.y > b.y end)

	-- Update particles
	for i=#self.particles, 1, -1 do
		if self.particles[i].alive == true then
			self.particles[i]:update(dt)
		else
			table.remove(self.particles, i)
		end
	end

	-- Cap scores between 0 and 999
	for i=1,3 do
		self.score[i] = math.cap(self.score[i], 0, 999)
	end

	-- Update stats
	if self.time >= self.nextStat*(rules.roundtime/IngameState.NSTATS) then
		self.stats[self.nextStat] = {}
		for i = 1,4 do
			self.stats[self.nextStat][i] = self.score[i]
		end
		self.nextStat = self.nextStat + 1
	end
end

function IngameState:draw()
	love.graphics.push()
	love.graphics.translate(121, 8)

	-- Draw map back layer
	love.graphics.draw(self.map:getBackBatch(), 0, 0)

	-- Draw arrows
	for i=1,4 do
		for j,v in ipairs(self.arrows[i]) do
			-- Make arrows blink the last seconds
			if rules.arrowtime - v.time > 1 or v.time % 0.2 > 0.1 then
				v:draw()
			end
		end
	end

	-- Draw back particles
	for i,v in ipairs(self.particles) do
		if v:getLayer() == Particle.LAYER_BACK then
			v:draw()
		end
	end

	-- Draw cursor markers
	for i,v in ipairs(self.cursors) do
		local mx = math.floor(v.x / 48)*48
		local my = math.floor(v.y / 48)*48
		love.graphics.draw(self.marker[i], mx, my)
	end

	-- Draw map front layer
	love.graphics.draw(self.map:getFrontBatch(), 0, 0)

	-- Draw entities
	for i,v in ipairs(self.entities) do
	   v:draw()
	end

	-- Draw front particles
	for i,v in ipairs(self.particles) do
		if v:getLayer() == Particle.LAYER_FRONT then
			v:draw()
		end
	end

	-- Draw hud
	love.graphics.pop()
	self:drawHUD()
end

function IngameState:drawHUD()
	love.graphics.draw(self.imgSidebar, 0, 0)

	love.graphics.setFont(ResMgr.getFont("bold"))

	love.graphics.push()
	love.graphics.scale(3, 3)

	local timeString = secsToString(self.timeLeft)
	love.graphics.setColor(0, 0, 0, 128/255)
	love.graphics.printf(timeString, 0, 21, 40, "center")
	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.printf(timeString, 0, 20, 40, "center")

	love.graphics.setColor(0, 0, 0, 128/255)
	for i=1,4 do
		love.graphics.print(string.format("%03d", self.score[i]), 8, 18+i*29)
	end
	love.graphics.setColor(1,1,1,1)
	for i=1,4 do
		love.graphics.print(string.format("%03d", self.score[i]), 8, 17+i*29)
	end

	love.graphics.pop()

	love.graphics.setColor(1,1,1)
end

function IngameState:getInputs()
	return self.inputs
end

--- Places an arrow in tile if possible.
--  @param x x-coordinate (in cell coordinates)
--  @param y y-coordinate (in cell coordinates)
--  @param dir Integer direction of arrow (0,1,2 or 3)
--  @param player Id of player that placed arrow (1-4)
function IngameState:placeArrow(x, y, dir, player)
	if self:canPlaceArrow(x, y) == false then
		return
	end

	if #self.arrows[player] >= rules.maxarrows then
		table.remove(self.arrows[player], 1)
	end
	table.insert(self.arrows[player], Arrow.create(x, y, dir, player))
end

--- Checks if an arrow can be placed at (x,y)
--  @return True if placement is possible, false otherwise
function IngameState:canPlaceArrow(x, y)
	-- Check if tile is empty
	if self.map:getTile(x, y) ~= 0 then
		return false
	end
	-- Check if another arrow is already placed there
	for i=1,4 do
		for j,v in ipairs(self.arrows[i]) do
			if v.x == x and v.y == y then
				return false
			end
		end
	end

	return true
end

function IngameState:triggerEvent(player)
	if rules.minigames == true then
		self.event = math.random(1, IngameState.EVENT_COUNT_WITH_GAMES)
	else
		self.event = math.random(1, IngameState.EVENT_COUNT)
	end
	self.eventTime = rules.eventTime[self.event] or 0

	if self.event == IngameState.EVENT_SWITCH then
		local oldsubs = self.map:getSubmarines()
		self.map:shuffleSubmarines()
		local newsubs = self.map:getSubmarines()
		pushState(SwitchAnimState.create(oldsubs, newsubs))

	elseif self.event == IngameState.EVENT_PREDATORS then
		local subs = self.map:getSubmarines()
		for i,v in ipairs(subs) do
			if v.player ~= player then
				local e = Enemy.create(6*48, 4*48+24, 2)
				e:setFlying(v.x*48+24, v.y*48+24)
				table.insert(self.entities, e)
			end
		end

	elseif self.event == IngameState.EVENT_VACUUM then
		local subs = self.map:getSubmarines()
		local sub = nil
		for i,v in ipairs(subs) do
			if v.player == player then
				sub = v
				break
			end
		end
		for i,v in ipairs(self.entities) do
			local t = v:getType()
			if t == Entity.TYPE_DUCK or t == Entity.TYPE_GOLDDUCK then
				v:setFlying(sub.x*48+24, sub.y*48+24)
			end
		end
	
	elseif self.event == IngameState.EVENT_DUCKDASH then
		pushState(DuckDashState.create(self, self.score, rules))
		pushState(CountdownState.create(4, 0))
	
	elseif self.event == IngameState.EVENT_ESCAPE then
		pushState(EscapeState.create(self, self.score, rules))
		pushState(CountdownState.create(4, 0))
	
	elseif self.event == IngameState.EVENT_DUCKBEAT then
		pushState(DuckBeatState.create(self, self.score, rules))
	end

	pushState(EventTextState.create(self.event))
end

function IngameState:keypressed(k)
	if k == "f1" then
		local spawns = self.map:getSpawnPoints()
		local e = spawns[1]
		table.insert(self.entities, PinkDuck.create(e.x*48+24, e.y*48+24, e.dir))
	elseif k == "f2" then
		local spawns = self.map:getSpawnPoints()
		local e = spawns[1]
		table.insert(self.entities, GoldDuck.create(e.x*48+24, e.y*48+24, e.dir))
	elseif k == "f3" then
		local spawns = self.map:getSpawnPoints()
		local e = spawns[1]
		table.insert(self.entities, Enemy.create(e.x*48+24, e.y*48+24, e.dir))
	elseif k == "escape" then
		pushState(PauseGameState.create(self))
	else
		State.keypressed(self, k)
	end
end

return IngameState
