Menu = {}
Menu.__index = Menu

function Menu.create(x, y, width, height, spacing, listener)
	local self = setmetatable({}, Menu)

	self.x, self.y = x, y
	self.nexty = y
	self.width = width
	self.height = height
	self.spacing = spacing
	self.listener = listener

	self.imgButton = ResMgr.getImage("button.png")
	self.quadTopLeft = love.graphics.newQuad(0, 0, 3, 3, 7, 7)
	self.quadTopRight = love.graphics.newQuad(4, 0, 3, 3, 7, 7)
	self.quadBottomLeft = love.graphics.newQuad(0, 4, 3, 3, 7, 7)
	self.quadBottomRight = love.graphics.newQuad(4, 4, 3, 3, 7, 7)
	self.quadTopEdge = love.graphics.newQuad(3, 0, 1, 3, 7, 7)
	self.quadBottomEdge = love.graphics.newQuad(3, 4, 1, 3, 7, 7)
	self.quadLeftEdge = love.graphics.newQuad(0, 3, 3, 1, 7, 7)
	self.quadRightEdge = love.graphics.newQuad(4, 3, 3, 1, 7, 7)

	self.buttons = {}

	return self
end

function Menu:addButton(text, id)
	local e = {}
	e.text = text
	e.id = id
	e.x = self.x
	e.y = self.nexty
	table.insert(self.buttons, e)

	self.nexty = self.nexty + self.height + self.spacing
end

function Menu:draw()
	-- Draw button graphics
	for i,v in ipairs(self.buttons) do
		love.graphics.drawq(self.imgButton, self.quadTopLeft, v.x, v.y)
		love.graphics.drawq(self.imgButton, self.quadTopRight, v.x+self.width-3, v.y)
		love.graphics.drawq(self.imgButton, self.quadBottomLeft, v.x, v.y+self.height-3)
		love.graphics.drawq(self.imgButton, self.quadBottomRight, v.x+self.width-3, v.y+self.height-3)

		love.graphics.drawq(self.imgButton, self.quadTopEdge, v.x+3, v.y, 0, self.width-6, 1)
		love.graphics.drawq(self.imgButton, self.quadBottomEdge, v.x+3, v.y+self.height-3, 0, self.width-6, 1)
		love.graphics.drawq(self.imgButton, self.quadLeftEdge, v.x, v.y+3, 0, 1, self.height-6)
		love.graphics.drawq(self.imgButton, self.quadRightEdge, v.x+self.width-3, v.y+3, 0, 1, self.height-6)

		love.graphics.setColor(255, 194, 49, 255)
		love.graphics.rectangle("fill", v.x+3, v.y+3, self.width-6, self.height-6)
		love.graphics.setColor(255, 255, 255, 255)
	end

	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.push()
	love.graphics.scale(2,2)
	love.graphics.setFont(ResMgr.getFont("bold"))

	-- Draw text shadow
	love.graphics.setColor(131, 80, 0, 255)
	for i,v in ipairs(self.buttons) do
		love.graphics.printf(v.text, v.x/2, (v.y+self.height/2-7)/2, self.width/2, "center")
	end

	-- Draw text
	love.graphics.setColor(255, 255, 255, 255)
	for i,v in ipairs(self.buttons) do
		love.graphics.printf(v.text, v.x/2, (v.y+self.height/2-8)/2, self.width/2, "center")
	end

	love.graphics.pop()
end

function Menu:click(x, y)
	for i,v in ipairs(self.buttons) do
		if x >= v.x and x <= v.x + self.width
		and y >= v.y and y <= v.y + self.height then
			self.listener:buttonPressed(v.id)
			return
		end
	end
end
