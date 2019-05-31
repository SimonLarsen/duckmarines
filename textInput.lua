local Component = require("component")

local TextInput = {}
TextInput.__index = TextInput
setmetatable(TextInput, Component)

function TextInput.create(x, y, width, height)
	local self = setmetatable({}, TextInput)

	self.x, self.y = x, y
	self.width = width
	self.height = height or 21
	self.text = ""
	self.backgroundColor = {0, 0, 0}
	self.active = false

	return self
end

function TextInput:draw()
	love.graphics.setColor(self.backgroundColor)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	love.graphics.setColor(1, 194/255, 49/255)
	love.graphics.rectangle("line", self.x+0.5, self.y+0.5, self.width-1, self.height-1)
	love.graphics.setColor(1, 1, 1)

	if self.active == true then
		love.graphics.print(self.text.."|", self.x+4, self.y+((self.height-8)/2))
	else
		love.graphics.print(self.text, self.x+4, self.y+((self.height-8)/2))
	end
end

function TextInput:click(x, y)
	if x >= self.x and x <= self.x+self.width
	and y >= self.y and y <= self.y+self.height then
		self.active = true
	else
		self.active = false
	end
end

function TextInput:getText()
	return self.text
end

function TextInput:setText(text)
	self.text = text
end

function TextInput:setActive(active)
	self.active = active
end

function TextInput:keypressed(k)
	if self.active == false then return end

	if k == "backspace" and self.text:len() > 0 then
		self.text = self.text:sub(1, self.text:len()-1)
		return true
	end
end

function TextInput:textinput(text)
	if self.active == false then return end

	local uni = text:byte(1)
	if (uni >= string.byte("A") and uni <= string.byte("Z"))
	or (uni >= string.byte("a") and uni <= string.byte("z"))
	or (uni >= string.byte("0") and uni <= string.byte("9")) then
		self.text = self.text .. text:upper()
		return true
	end
end

return TextInput
