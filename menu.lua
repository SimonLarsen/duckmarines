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
	love.graphics.setColor(255, 194, 49, 255)
	for i,v in ipairs(self.buttons) do
		love.graphics.rectangle("fill", v.x, v.y, self.width, self.height)
	end

	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.push()
	love.graphics.scale(2,2)
	love.graphics.setFont(ResMgr.getFont("bold"))
	for i,v in ipairs(self.buttons) do
		love.graphics.printf(v.text, v.x/2, (v.y+self.height/2-7)/2, self.width/2, "center")
	end
	love.graphics.pop()
	love.graphics.setColor(255, 255, 255, 255)
end

function Menu:click(x, y)
	print("click")
	for i,v in ipairs(self.buttons) do
		if x >= v.x and x <= v.x + self.width
		and y >= v.y and y <= v.y + self.height then
			self.listener:buttonPressed(v.id)
			return
		end
	end
end
