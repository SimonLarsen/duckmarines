IngameState = {}
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

function IngameState.create(mapname, rules)
	local self = setmetatable({}, IngameState)
	self.rules = rules

	-- Load map
	self.map = Map.create(mapname)

	self.arrows = {}
	for i=1,4 do
		self.arrows[i] = {}
	end

	self.entities = {}

	-- Initialize cursors and inputs
	self.inputs = {}
	self.inputs[1] = KeyboardInput.create()
	self.inputs[2] = MouseInput.create()
	self.inputs[3] = JoystickInput.create(1)
	self.inputs[4] = JoystickInput.create(2)
	self.cursors = {}
	self.cursors[1] = Cursor.create( 72,  72, 1)
	self.cursors[2] = Cursor.create(504,  72, 2)
	self.cursors[3] = Cursor.create( 72, 360, 3)
	self.cursors[4] = Cursor.create(504, 360, 4)

	-- Set variables and counters
	self.time = self.rules.roundtime*60

	self.event = IngameState.EVENT_NONE
	self.eventTime = 0

	self.score = {}
	for i=1,4 do
		self.score[i] = 0
	end
	self.nextEntity = 2

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

function IngameState:update(dt)
	-- Advance time
	self.time = self.time - dt

	-- Advance event time
	if self.event ~= 0 then
		self.eventTime = self.eventTime - dt
		if self.eventTime < 0 then
			self.event = 0
		end
	end

	-- Cap mouse
	love.mouse.setPosition(math.cap(love.mouse.getX(), 0, 582), math.cap(love.mouse.getY(), 0, 422))

	-- Update spawn counter if not frozen
	if self.event ~= IngameState.EVENT_FREEZE then
		self.nextEntity = self.nextEntity - dt
	end
	-- Spawn new entity when counter runs out
	if self.nextEntity <= 0 then
		local freq = self.rules.frequency
		if self.event == IngameState.EVENT_RUSH then
			self.nextEntity = 0.05+math.random()/10
		else
			self.nextEntity = 1/(freq + math.randnorm()*0.8*freq)*60
		end

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
			if choice < self.rules.enemyperc then
				table.insert(self.entities, Enemy.create(e.x*48+24, e.y*48+24, e.dir))
			-- golden duck
			elseif choice < self.rules.enemyperc + self.rules.goldperc then
				table.insert(self.entities, GoldDuck.create(e.x*48+24, e.y*48+24, e.dir))
			-- pink duck
			elseif choice < self.rules.enemyperc + self.rules.goldperc + self.rules.pinkperc then
				table.insert(self.entities, PinkDuck.create(e.x*48+24, e.y*48+24, e.dir))
			-- normal duck
			else
				table.insert(self.entities, Duck.create(e.x*48+24, e.y*48+24, e.dir))
			end
		end
	end

	-- Move cursors
	for i=1,4 do
		self.cursors[i]:move(self.inputs[i]:getMovement(dt))
	end

	-- Remove expired arrows
	for i=1,4 do
		for j=#self.arrows[i], 1, -1 do
			local v = self.arrows[i][j]
			v.time = v.time + dt
			if v.time >= self.rules.arrowtime then
				table.remove(self.arrows[i], j)
			end
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
		for i=#self.entities, 1, -1 do
			-- Adjust delta time according to event
			local entityDT = dt
			if self.event == IngameState.EVENT_SPEEDUP then
				entityDT = dt*1.5
			elseif self.event == IngameState.EVENT_SLOWDOWN then
				entityDT = dt*0.5
			end
			self.entities[i]:update(entityDT, self.map, self.arrows, self.event)
			local tile = self.entities[i]:getTile()

			-- Check if entities hit submarine
			if tile >= 10 and tile <= 14 then
				local eType = self.entities[i]:getType()
				local player = tile-9
				if eType == Entity.TYPE_DUCK then
					self.score[player] = self.score[player] + 1

				elseif eType == Entity.TYPE_GOLDDUCK then
					self.score[player] = self.score[player] + 25

				elseif eType == Entity.TYPE_PINKDUCK then
					self.score[player] = self.score[player] + 10
					self:triggerEvent(player)

				elseif eType == Entity.TYPE_ENEMY then
					self.score[player] = math.floor(self.score[player]*0.6667)
				end

				table.remove(self.entities, i)
			-- Check if entity hit hole
			elseif tile == 2 then
				table.remove(self.entities, i)
			end
		end
	end

	-- Cap scores between 0 and 999
	for i=1,3 do
		self.score[i] = math.cap(self.score[i], 0, 999)
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
			if self.rules.arrowtime - v.time > 1 or v.time % 0.2 > 0.1 then
				v:getDrawable():draw(v.x*48, v.y*48)
			end
		end
	end

	-- Draw cursors
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

	-- Draw cursors
	for i,v in ipairs(self.cursors) do
		v:getDrawable():draw(v.x, v.y)
	end

	-- Draw hud
	love.graphics.pop()
	self:drawHUD()
end

function IngameState:drawHUD()
	love.graphics.draw(self.imgSidebar, 0, 0)

	love.graphics.setColor(0,0,0)
	love.graphics.setFont(ResMgr.getFont("bold"))

	love.graphics.push()
	love.graphics.scale(3, 3)

	local timeString = secsToString(self.time)
	love.graphics.print(timeString, 7, 21)

	love.graphics.setColor(0, 0, 0, 128)
	love.graphics.print(timeString, 7, 22)
	love.graphics.print(string.format("%03d", self.score[1]), 8, 47)
	love.graphics.print(string.format("%03d", self.score[2]), 8, 76)
	love.graphics.print(string.format("%03d", self.score[3]), 8, 105)
	love.graphics.print(string.format("%03d", self.score[4]), 8, 134)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print(string.format("%03d", self.score[1]), 8, 46)
	love.graphics.print(string.format("%03d", self.score[2]), 8, 75)
	love.graphics.print(string.format("%03d", self.score[3]), 8, 104)
	love.graphics.print(string.format("%03d", self.score[4]), 8, 133)

	love.graphics.pop()

	love.graphics.setColor(255,255,255)
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

	if #self.arrows[player] >= self.rules.maxarrows then
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
	self.event = math.random(1, 8)
	self.eventTime = self.rules.eventTime[self.event]
	if self.event == IngameState.EVENT_SWITCH then
		local oldsubs = self.map:getSubmarines()
		self.map:shuffleSubmarines()
		local newsubs = self.map:getSubmarines()
		pushState(SwitchAnimState.create(oldsubs, newsubs))
	elseif self.event == IngameState.EVENT_PREDATORS then
		local subs = self.map:getSubmarines()
		for i,v in ipairs(subs) do
			if v.player ~= player then
				local e = Enemy.create(v.x*48+24, v.y*48, 2)
				e.moved = 24
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
	end

	pushState(EventTextState.create(self.event))
end
