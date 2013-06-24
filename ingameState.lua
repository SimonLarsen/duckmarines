IngameState = {}
IngameState.__index = IngameState
setmetatable(IngameState, State)

function IngameState.create()
	local self = setmetatable({}, IngameState)

	self.map = Map.create("test")

	return self
end

function IngameState:update(dt)
	
end

function IngameState:draw()
	love.graphics.translate(3, 8)
	love.graphics.draw(self.map:getDrawable(), 0, 0)
end
