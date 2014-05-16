local Component = require("component")

local ToggleButton = {}
ToggleButton.__index = ToggleButton
setmetatable(ToggleButton, Component)

function ToggleButton.create(x, y, value)
	local self = setmetatable({}, ToggleButton)

	self.x, self.y = x, y
	self.value = value
	self.img = ResMgr.getImage("togglebutton.png")
	self.quad = {}
	self.quad[1] = love.graphics.newQuad(0, 0, 32, 32, 64, 32)
	self.quad[2] = love.graphics.newQuad(32, 0, 32, 32, 64, 32)

	return self
end

function ToggleButton:draw()
	if self.value == false then
		love.graphics.draw(self.img, self.quad[1], self.x, self.y)
	else
		love.graphics.draw(self.img, self.quad[2], self.x, self.y)
	end
end

function ToggleButton:getValue()
	return self.value
end

function ToggleButton:setValue(value)
	self.value = value
end

function ToggleButton:click(x, y)
	if y >= self.y and y <= self.y+32 and x >= self.x and x <= self.x+32 then
		self.value = not self.value
		playSound("click")
		return true
	end
	return false
end

return ToggleButton
