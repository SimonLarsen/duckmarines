ConfirmBoxState = {}
ConfirmBoxState.__index = ConfirmBoxState
setmetatable(ConfirmBoxState, State)

function ConfirmBoxState.create(parent, message, func)
	local self = setmetatable(State.create(), ConfirmBoxState)

	self.inputs = parent.inputs
	self.cursor = parent.cursor

	self.message = message
	self.func = func

	local font = ResMgr.getFont("menu")
	self.limit = 500
	self.width, self.lines = font:getWrap(message, self.limit)
	self.width = math.max(340, self.width)
	self.height = self.lines * font:getHeight()+48
	self.x = (WIDTH-self.width)/2
	self.y = (HEIGHT-self.height)/2

	self.menu = Menu.create((WIDTH-180)/2, self.y+self.height-32, 120, 32, 24, self)
	self.menu:addButton("OK", "ok", WIDTH/2-130, self.y+self.height-32)
	self.menu:addButton("CANCEL", "cancel", WIDTH/2+10, self.y+self.height-32)

	return self
end

function ConfirmBoxState:update(dt)
	for i,v in ipairs(self.inputs) do
		if v:wasClicked() then
			self.menu:click(self.cursor.x, self.cursor.y)
		end
		self.cursor:move(v:getMovement(dt, false))
	end
end

function ConfirmBoxState:draw()
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

function ConfirmBoxState:buttonPressed(id, source)
	if id == "ok" then
		self.func()
		love.timer.sleep(0.15)
		popState()
	elseif id == "cancel" then
		love.timer.sleep(0.15)
		popState()
	end
end

function ConfirmBoxState:isTransparent() return true end
