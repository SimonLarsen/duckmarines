IngameState = {}
IngameState.__index = IngameState
setmetatable(IngameState, State)

function IngameState.create()
	local self = setmetatable({}, IngameState)

	self.map = Map.create("test")
	self.duck = Duck.create(6*48+24, 3*48+24, 2)
	self.enemy = Enemy.create(4*48+24, 3*48+24, 0)
	self.arrows = {}

	for i=1,4 do
		self.arrows[i] = {}
	end

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

	return self
end

function IngameState:update(dt)
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
	self.enemy:update(dt, self.map)
	self.duck:update(dt, self.map)
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
	self.enemy:draw()
	self.duck:draw()

	-- Draw cursors
	for i,v in ipairs(self.cursors) do
		v:getDrawable():draw(v.x, v.y)
	end
end

function IngameState:getInputs()
	return self.inputs
end

function IngameState:placeArrow(x, y, dir, player)
	if #self.arrows[player] >= 4 then
		table.remove(self.arrows[player], 1)
	end
	table.insert(self.arrows[player], Arrow.create(x, y, dir, player))
end
