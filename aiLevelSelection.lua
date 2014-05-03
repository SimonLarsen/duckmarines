local Component = require("component")

local AILevelSelection = {}
AILevelSelection.__index = AILevelSelection
setmetatable(AILevelSelection, Component)

function AILevelSelection.create(x, y, selected)
	local self = setmetatable({}, AILevelSelection)

	self.x, self.y = x, y
	self.selected = selected or 1
	self.visible = true

	self.imgButton = ResMgr.getImage("ailevelbutton.png")
	self.imgStars = ResMgr.getImage("aistars.png")

	return self
end

function AILevelSelection:draw()
	if self.visible == false then return end

	for i=1,3 do
		if i == self.selected then
			love.graphics.draw(self.imgButton, self.x+(i-1)*42, self.y, 0, -1, -1, 41, 32)
		else
			love.graphics.draw(self.imgButton, self.x+(i-1)*42, self.y)
		end
	end
	love.graphics.draw(self.imgStars, self.x, self.y)
end

function AILevelSelection:getSelection()
	return self.selected
end

function AILevelSelection:click(x, y)
	if self.visible == false then return false end

	if y >= self.y and y <= self.y+32 then
		if x >= self.x and x < self.x+42 then
			self.selected = 1
			return true
		elseif x >= self.x+42 and x < self.x+84 then
			self.selected = 2
			return true
		elseif x >= self.x+84 and x < self.x+125 then
			self.selected = 3
			return true
		end
	end
	return false
end

return AILevelSelection
