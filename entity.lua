Entity = {}
Entity.__index = Entity

function Entity:draw()
	self:getAnim():draw(self.x, self.y)
end
