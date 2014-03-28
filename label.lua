local Component = require("component")

local Label = {}
Label.__index = Label
setmetatable(Label, Component)

function Label.create(text, x, y, limit, align)
	local self = setmetatable({}, Label)

	self.text = text
	self.x, self.y = x, y
	self.limit = limit
	self.align = align

	return self
end

function Label:draw()
	love.graphics.setFont(ResMgr.getFont("menu"))
	love.graphics.printf(self.text, self.x, self.y, self.limit, self.align)
end

return Label
