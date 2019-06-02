local Component = require("component")

local Menu = {}
Menu.__index = Menu
setmetatable(Menu, Component)

Menu.TEXT_BUTTON = 0
Menu.IMAGE_BUTTON = 1

function Menu.create(x, y, width, height, spacing, listener)
	local self = setmetatable({}, Menu)

	self.x, self.y = x, y
	self.nexty = y
	self.width = width
	self.height = height
	self.spacing = spacing
	self.listener = listener
	self.id = ""

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
	e.type = Menu.TEXT_BUTTON
	e.text = text
	e.id = id
	e.enabled = true
	e.visible = true
	e.width = width or self.width
	e.height = height or self.height
	if x and y then
		e.x = x
		e.y = y
	else
		e.x = self.x
		e.y = self.nexty
		self.nexty = self.nexty + e.height + self.spacing
	end
	table.insert(self.buttons, e)
	return e
end

function Menu:addImageButton(img, quad, id, x, y, width, height)
	local e = {}
	e.type = Menu.IMAGE_BUTTON
	e.img = img
	e.quad = quad
	e.id = id
	e.x, e.y = x,y
	e.enabled = true
	e.visible = true
	e.width, e.height = width, height
	table.insert(self.buttons, e)
	return e
end

function Menu:draw()
	love.graphics.setFont(ResMgr.getFont("menu"))
	-- Draw button graphics
	for i,v in ipairs(self.buttons) do
		if v.visible == true then
			if v.type == Menu.TEXT_BUTTON then
				love.graphics.draw(self.imgButton, self.quadTopLeft, v.x, v.y)
				love.graphics.draw(self.imgButton, self.quadTopRight, v.x+v.width-3, v.y)
				love.graphics.draw(self.imgButton, self.quadBottomLeft, v.x, v.y+v.height-3)
				love.graphics.draw(self.imgButton, self.quadBottomRight, v.x+v.width-3, v.y+v.height-3)

				love.graphics.draw(self.imgButton, self.quadTopEdge, v.x+3, v.y, 0, v.width-6, 1)
				love.graphics.draw(self.imgButton, self.quadBottomEdge, v.x+3, v.y+v.height-3, 0, v.width-6, 1)
				love.graphics.draw(self.imgButton, self.quadLeftEdge, v.x, v.y+3, 0, 1, v.height-6)
				love.graphics.draw(self.imgButton, self.quadRightEdge, v.x+v.width-3, v.y+3, 0, 1, v.height-6)

				love.graphics.setColor(1, 194/255, 49/255, 1)
				love.graphics.rectangle("fill", v.x+3, v.y+3, v.width-6, v.height-6)
				love.graphics.setColor(1, 1, 1, 1)
				if v.enabled then
					love.graphics.setColor(80/255, 49/255, 0, 1)
				else
					love.graphics.setColor(80/255, 49/255, 0, 128/255)
				end
				love.graphics.printf(v.text, v.x, (v.y+v.height/2-9), v.width, "center")
				love.graphics.setColor(1, 1, 1, 1)
			elseif v.type == Menu.IMAGE_BUTTON then
				love.graphics.draw(v.img, v.quad, v.x, v.y)
			end
		end
	end
end

function Menu:click(x, y)
	for i,v in ipairs(self.buttons) do
		if v.enabled == true and v.visible == true 
		and x >= v.x and x <= v.x + v.width
		and y >= v.y and y <= v.y + v.height then
			self.listener:buttonPressed(v.id, self)
			return true
		end
	end
	return false
end

return Menu
