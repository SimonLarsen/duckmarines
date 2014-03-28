local Sprite = {}
Sprite.__index = Sprite

function Sprite.create(image, quad, ox, oy)
	local self = setmetatable({}, Sprite)
	self.img = image
	self.quad = quad
	self.ox, self.oy = ox, oy

	return self
end

function Sprite:draw(x, y, r)
	if self.quad then
		love.graphics.draw(self.img, self.quad, x, y, r or 0, 1, 1, self.ox or 0, self.oy or 0)
	else
		love.graphics.draw(self.img, x, y, r or 0, 1, 1, self.ox or 0, self. oy or 0)
	end
end

function Sprite:setOffset(ox, oy)
	self.ox, self.oy = ox, oy
end

return Sprite
