SelectionList = {}
SelectionList.__index = SelectionList
setmetatable(SelectionList, Component)

function SelectionList.create(x, y, width, length, spacing, listener)
	local self = setmetatable({}, SelectionList)

	self.x, self.y = x, y
	self.width = width
	self.length = length
	self.height = 28
	self.spacing = spacing or 14
	self.listener = listener
	self.scroll = 1
	self.selection = 0
	self.id = ""

	self.items = {}
	self.backgroundColor = {0, 0, 0, 255}
	self.selectionColor = {20, 20, 20, 255}

	self.imgButton = ResMgr.getImage("selectionlist_buttons.png")
	self.quadButtonLeft = love.graphics.newQuad(0, 0, 2, 14, 49, 14)
	self.quadButtonRight = love.graphics.newQuad(3, 0, 2, 14, 49, 14)
	self.quadButtonMiddle = love.graphics.newQuad(2, 0, 1, 14, 49, 14)
	self.quadButtonUp = love.graphics.newQuad(5, 0, 22, 14, 49, 14)
	self.quadButtonDown = love.graphics.newQuad(27, 0, 22, 14, 49, 14)

	return self
end

function SelectionList:draw()
	love.graphics.setColor(self.backgroundColor)
	love.graphics.rectangle("fill", self.x, self.y+14, self.width, self.height-28)
	love.graphics.setColor(255,255,255,255)

	-- Draw buttons
	love.graphics.drawq(self.imgButton, self.quadButtonLeft, self.x, self.y)
	love.graphics.drawq(self.imgButton, self.quadButtonLeft, self.x, self.y+self.height-14)
	love.graphics.drawq(self.imgButton, self.quadButtonRight, self.x+self.width-2, self.y)
	love.graphics.drawq(self.imgButton, self.quadButtonRight, self.x+self.width-2, self.y+self.height-14)
	love.graphics.drawq(self.imgButton, self.quadButtonMiddle, self.x+2, self.y, 0, self.width-4, 1)
	love.graphics.drawq(self.imgButton, self.quadButtonMiddle, self.x+2, self.y+self.height-14, 0, self.width-4, 1)
	love.graphics.drawq(self.imgButton, self.quadButtonUp, self.x+self.width/2-11, self.y)
	love.graphics.drawq(self.imgButton, self.quadButtonDown, self.x+self.width/2-11, self.y+self.height-14)

	-- Draw sides
	love.graphics.setColor(255, 194, 49)
	love.graphics.line(self.x+0.5, self.y+14.5, self.x+0.5, self.y+self.height-14.5)
	love.graphics.line(self.x+self.width-0.5, self.y+14.5, self.x+self.width-0.5, self.y+self.height-14.5)
	love.graphics.setColor(255, 255, 255)

	love.graphics.setFont(ResMgr.getFont("bold"))
	for i=1, self.length do
		local index = i+self.scroll-1
		if index > #self.items then break end
		if i > #self.items then break end
		if index == self.selection then
			love.graphics.setColor(self.selectionColor)
			love.graphics.rectangle("fill", self.x+1, self.y+(i-1)*self.spacing+14, self.width-2, self.spacing)
			love.graphics.setColor(255, 255, 255, 255)
		end
		love.graphics.print(self.items[index], self.x+5, self.y+(i-1)*self.spacing+(self.spacing-8)/2+14)
	end
end

function SelectionList:click(x, y)
	if x >= self.x and x <= self.x+self.width
	and y >= self.y and y <= self.y+self.height then
		if y <= self.y+14 then
			self.scroll = math.max(1, self.scroll-1)
		elseif y <= self.y+self.height-14 then
			local old = self.selection
			self.selection = math.floor((y-self.y-14)/self.spacing)+self.scroll
			if self.selection > #self.items then
				self.selection = old
			else
				if self.listener then
					self.listener:selectionChanged(self:getText(), self)
				end
			end
		else
			self.scroll = math.min(self.scroll+1, #self.items-self.length+1)
			self.scroll = math.max(1, self.scroll)
		end
	end
end

function SelectionList:setItems(items)
	self.items = items
	self.height = self.length*self.spacing + 28
	self.selection = 0
end

function SelectionList:setId(id)
	self.id = id
end

function SelectionList:getText()
	if self.selection > 0 then
		return self.items[self.selection]
	else
		return ""
	end
end

function SelectionList:setBackgroundColor(r,g,b,a)
	self.backgroundColor = {r,g,b,a}
end

function SelectionList:setSelectionColor(r, g, b, a)
	self.selectionColor = {r,g,b,a}
end

function SelectionList:setSelection(index)
	self.selection = index
end

function SelectionList:getSelection()
	return self.items[self.selection]
end
