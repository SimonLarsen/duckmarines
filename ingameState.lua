IngameState = {}
IngameState.__index = IngameState
setmetatable(IngameState, State)

function IngameState.create()
	local self = setmetatable({}, IngameState)

	self.map = Map.create("test")
	self.duck = Duck.create(6*48+24, 3*48+24, 2)
	self.enemy = Enemy.create(4*48+24, 3*48+24, 0)

	return self
end

function IngameState:update(dt)
	self.enemy:update(dt, self.map)
	self.duck:update(dt, self.map)
end

function IngameState:draw()
	-- Draw map
	love.graphics.translate(3, 8)
	love.graphics.draw(self.map:getDrawable(), 0, 0)

	-- Draw entities
	self.enemy:draw()
	self.duck:draw()
end
