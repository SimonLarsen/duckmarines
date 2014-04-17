local Component = require("component")

local Slider = {}
Slider.__index = Slider
setmetatable(Slider, Component)

Slider.timeFormatter = function(v)
	return secsToString(v)
end

Slider.onOffFormatter = function(v)
	return v and "ON" or "OFF"
end

Slider.percentFormatter = function(v)
	return v .. " %"
end

function Slider.create(x, y, width, values, value, listener, formatter)
	local self = setmetatable({}, Slider)

	self.x, self.y = x,y
	self.width = width
	self.values = values
	self.selection = 1
	self:setValue(value)
	self.listener = listener
	self.formatter = formatter

	self.left = self.x+21
	self.right = self.x+self.width-21
	self.innerWidth = self.right - self.left
	self.count = #values

	self.buttons = ResMgr.getImage("slider_buttons.png")
	self.leftButton = love.graphics.newQuad(0, 0, 21, 32, 42, 32)
	self.rightButton = love.graphics.newQuad(21, 0, 21, 32, 42, 32)

	return self
end

function Slider:draw()
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", self.left, self.y, self.innerWidth, 32)

	love.graphics.setColor(255, 194, 49)
	love.graphics.setLineWidth(1)
	love.graphics.line(self.left, self.y+1, self.right, self.y+1)
	love.graphics.line(self.left, self.y+32, self.right, self.y+32)

	love.graphics.setColor(20, 20, 20)
	local slideWidth = (self.selection-1) / (self.count-1) * self.innerWidth
	love.graphics.rectangle("fill", self.left, self.y+1, slideWidth, 30)

	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.buttons, self.leftButton, self.x, self.y)
	love.graphics.draw(self.buttons, self.rightButton, self.x+self.width-21, self.y)

	love.graphics.setFont(ResMgr.getFont("menu"))
	local str
	if self.formatter then
		str = self.formatter(self:getValue())
	else
		str = tostring(self:getValue())
	end
	love.graphics.printf(str, self.left, self.y+6, self.innerWidth, "center")
end

function Slider:click(x, y)
	if y >= self.y and y < self.y+32 and x >= self.x and x < self.x+self.width then
		if x < self.left then
			self:setSelection(self.selection-1)
		elseif x >= self.right then
			self:setSelection(self.selection+1)
		else
			val = (x - self.left)/self.innerWidth
			self.selection = math.round(val * (self.count-1) + 1)
		end
	end
end

function Slider:getValue()
	return self.values[self.selection]
end

function Slider:setSelection(index)
	self.selection = index
	if self.selection < 1 then self.selection = self.count end
	if self.selection > self.count then self.selection = 1 end

	if self.listener then
		self.listener:valueChanged(self:getValue(), self)
	end
end

function Slider:setValue(value)
	self.selection = 1
	for i,v in pairs(self.values) do
		if v == value then
			self.selection = i
			break
		end
	end
end

return Slider
