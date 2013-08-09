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

function Menu:addButton(text, id, x, y, width, height)
	local e = {}
	e.text = text
	e.id = id
	if x and y then
		e.x = x
		e.y = y
	else
		e.x = self.x
		e.y = self.nexty
	end
	e.width = width or self.width
	e.height = height or self.height
	table.insert(self.buttons, e)

	self.nexty = self.nexty + e.height + self.spacing
end

function Menu:draw()
	-- Draw button graphics
	for i,v in ipairs(self.buttons) do
		love.graphics.drawq(self.imgButton, self.quadTopLeft, v.x, v.y)
		love.graphics.drawq(self.imgButton, self.quadTopRight, v.x+v.width-3, v.y)
		love.graphics.drawq(self.imgButton, self.quadBottomLeft, v.x, v.y+v.height-3)
		love.graphics.drawq(self.imgButton, self.quadBottomRight, v.x+v.width-3, v.y+v.height-3)

		love.graphics.drawq(self.imgButton, self.quadTopEdge, v.x+3, v.y, 0, v.width-6, 1)
		love.graphics.drawq(self.imgButton, self.quadBottomEdge, v.x+3, v.y+v.height-3, 0, v.width-6, 1)
		love.graphics.drawq(self.imgButton, self.quadLeftEdge, v.x, v.y+3, 0, 1, v.height-6)
		love.graphics.drawq(self.imgButton, self.quadRightEdge, v.x+v.width-3, v.y+3, 0, 1, v.height-6)

		love.graphics.setColor(255, 194, 49, 255)
		love.graphics.rectangle("fill", v.x+3, v.y+3, v.width-6, v.height-6)
		love.graphics.setColor(255, 255, 255, 255)
	end

	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.push()
	love.graphics.scale(2,2)
	love.graphics.setFont(ResMgr.getFont("bold"))

	-- Draw embossed text
	for i,v in ipairs(self.buttons) do
		local x = v.x/2
		local y = (v.y+v.height/2-6)/2
		local w = v.width/2
		love.graphics.setColor(44, 27, 0, 255)
		love.graphics.printf(v.text, x, y-1, w, "center")
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.printf(v.text, x, y+1, w, "center")
		love.graphics.setColor(131, 80, 0, 255)
		love.graphics.printf(v.text, x, y, w, "center")
	end

	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.pop()
end

function Menu:click(x, y)
	for i,v in ipairs(self.buttons) do
		if x >= v.x and x <= v.x + v.width
		and y >= v.y and y <= v.y + v.height then
			self.listener:buttonPressed(v.id)
			return
		end
	end
end
