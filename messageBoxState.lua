MessageBoxState = {}
MessageBoxState.__index = MessageBoxState
setmetatable(MessageBoxState, State)

function MessageBoxState.create(parent, message)
	local self = setmetatable({}, MessageBoxState)

	self.inputs = parent.inputs
	self.cursor = parent.cursor
	self.message = message

	local font = ResMgr.getFont("menu")
	self.limit = 500
	self.width, self.lines = font:getWrap(message, self.limit)
	self.height = self.lines * font:getHeight()+48
	self.x = (WIDTH-self.width)/2
	self.y = (HEIGHT-self.height)/2

	self.menu = Menu.create((WIDTH-180)/2, self.y+self.height-32, 180, 32, 24, self)
	self.menu:addButton("OKAY", "okay")

	return self
end

function MessageBoxState:update(dt)
	for i,v in ipairs(self.inputs) do
		if v:wasClicked() then
			self.menu:click(self.cursor.x, self.cursor.y)
		end
		self.cursor:move(v:getMovement(dt, false))
	end
end

function MessageBoxState:draw()
	love.graphics.setFont(ResMgr.getFont("menu"))
	love.graphics.setColor(23, 23, 23, 255)
	love.graphics.rectangle("fill", self.x-25, self.y-25, self.width+50, self.height+50)
	love.graphics.setColor(241, 148, 0, 255)
	love.graphics.rectangle("line", self.x-24.5, self.y-24.5, self.width+50, self.height+50)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.printf(self.message, self.x, self.y, self.width, "center")

	self.menu:draw()
	self.cursor:draw()
end

function MessageBoxState:buttonPressed(id, source)
	if id == "okay" then
		popState()
	end
end

function MessageBoxState:isTransparent() return true end
