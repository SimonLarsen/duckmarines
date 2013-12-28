Slider = {}
Slider.__index = Slider
setmetatable(Slider, Component)

function Slider.create(x, y, width, values, selection, listener)
	local self = setmetatable({}, Slider)

	self.x, self.y = x,y
	self.width = width
	self.values = values
	self.selection = selection
	self.listener = listener

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
	love.graphics.line(self.left, self.y, self.right, self.y)
	love.graphics.line(self.left, self.y+31, self.right, self.y+31)

	love.graphics.setColor(20, 20, 20)
	local slideWidth = (self.selection-1) / (self.count-1) * self.innerWidth
	love.graphics.rectangle("fill", self.left, self.y+1, slideWidth, 30)

	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.buttons, self.leftButton, self.x, self.y)
	love.graphics.draw(self.buttons, self.rightButton, self.x+self.width-21, self.y)

	love.graphics.setFont(ResMgr.getFont("menu"))
	love.graphics.printf(self:getValue(), self.left, self.y+6, self.innerWidth, "center")
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
		--self.listener:valueChanged(self:getValue(), self)
	end
end
