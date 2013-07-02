IngameState = {}
IngameState.__index = IngameState
setmetatable(IngameState, State)

function IngameState.create(rules)
	local self = setmetatable({}, IngameState)
	self.rules = rules

	-- Load map
	self.map = Map.create("test")

	self.arrows = {}
	for i=1,4 do
		self.arrows[i] = {}
	end

	self.ducks = {}
	self.enemies = {}

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

	-- Set counters
	self.nextEntity = 2

	return self
end

function IngameState:update(dt)
	-- Update counters and events
	self.nextEntity = self.nextEntity - dt
	if self.nextEntity <= 0 then
		local freq = self.rules.frequency
		self.nextEntity = 1/(freq + math.randnorm()*freq)*60

		local spawns = self.map:getSpawnPoints()
		local e = table.random(spawns)

		local choice = math.random(0, 99)
		if choice < self.rules.enemyperc then
			table.insert(self.enemies, Enemy.create(e.x*48+24, e.y*48+24, e.dir))
		else
			table.insert(self.ducks, Duck.create(e.x*48+24, e.y*48+24, e.dir))
		end
	end

	-- Move cursors
	for i=1,4 do
		self.cursors[i]:move(self.inputs[i]:getMovement(dt))
	end

	-- Check player actions
	for i=1,4 do
		local ac = self.inputs[i]:getAction()
		if ac then
			local cx, cy = 0, 0
			if self.inputs[i]:getType() == Input.TYPE_MOUSE then
				cx = math.floor(self.inputs[i].clickx / 48)
				cy = math.floor(self.inputs[i].clicky / 48)
			else
				cx = math.floor(self.cursors[i].x / 48)
				cy = math.floor(self.cursors[i].y / 48)
			end
			self:placeArrow(cx, cy, ac, i)
		end
	end

	-- Update entities
	for i=#self.ducks, 1, -1 do
		self.ducks[i]:update(dt, self.map, self.arrows)
		local tile = self.ducks[i]:getTile()
		if tile >= 10 and tile <= 14 then
			table.remove(self.ducks, i)
		end
	end
	for i=#self.enemies, 1, -1 do
		self.enemies[i]:update(dt, self.map, self.arrows)
		local tile = self.enemies[i]:getTile()
		if tile >= 10 and tile <= 14 then
			table.remove(self.enemies, i)
		end
	end
end

function IngameState:draw()
	-- Draw map
	love.graphics.translate(3, 8)
	love.graphics.draw(self.map:getDrawable(), 0, 0)

	-- Draw arrows
	for i=1,4 do
		for j,v in ipairs(self.arrows[i]) do
			v:getDrawable():draw(v.x*48, v.y*48)
		end
	end

	-- Draw entities
	for i,v in ipairs(self.ducks) do
	   v:draw()
	end
	for i,v in ipairs(self.enemies) do
	   v:draw()
	end

	-- Draw cursors
	for i,v in ipairs(self.cursors) do
		v:getDrawable():draw(v.x, v.y)
	end
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

	if #self.arrows[player] >= 4 then
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
