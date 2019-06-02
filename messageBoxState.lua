local State = require("state")
local Menu = require("menu")

local MessageBoxState = {}
MessageBoxState.__index = MessageBoxState
setmetatable(MessageBoxState, State)

function MessageBoxState.create(parent, message)
	local self = setmetatable(State.create(), MessageBoxState)

	self.inputs = parent.inputs
	self.cursors = parent.cursors
	self.message = message

	local font = ResMgr.getFont("menu")
	self.limit = 500
	self.width, self.lines = font:getWrap(message, self.limit)
	self.height = table.getn(self.lines) * font:getHeight()+48
	self.x = (WIDTH-self.width)/2
	self.y = (HEIGHT-self.height)/2

	self.menu = self:addComponent(Menu.create((WIDTH-180)/2, self.y+self.height-32, 180, 32, 24, self))
	self.menu:addButton("OKAY", "okay")

	return self
end

function MessageBoxState:draw()
	love.graphics.setFont(ResMgr.getFont("menu"))
	love.graphics.setColor(23/255, 23/255, 23/255, 1/255)
	love.graphics.rectangle("fill", self.x-25, self.y-25, self.width+50, self.height+50)
	love.graphics.setColor(241/255, 148/255, 0, 1)
	love.graphics.rectangle("line", self.x-24.5, self.y-24.5, self.width+50, self.height+50)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.printf(self.message, self.x, self.y, self.width, "center")
end

function MessageBoxState:buttonPressed(id, source)
	if id == "okay" then
		playSound("click")
		love.timer.sleep(0.15)
		popState()
	end
end

function MessageBoxState:isTransparent() return true end

return MessageBoxState
