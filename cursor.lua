local Sprite = require("sprite")

local Cursor = {}
Cursor.__index = Cursor

function Cursor.create(x,y,player)
	local self = setmetatable({}, Cursor)

	self.x, self.y = x,y
	self.offsetx, self.offsety = 0,0
	self.player = player
	local img = ResMgr.getImage("cursor"..player..".png")
	self.sprite = Sprite.create(img)
	self.sprite:setOffset(2, 2)

	self.inputs = {}

	return self
end

--- Moves cursor 
-- @param dx Movement on x-axis
-- @param dy Movement on y-axis
-- @param absolute True if coordinates are absolute, not relative
function Cursor:move(dx, dy, absolute)
	if absolute == true then
		self.x = dx
		self.y = dy
	else
		self.x = self.x + dx
		self.y = self.y + dy
	end

	self.x = math.cap(self.x, 0, WIDTH)
	self.y = math.cap(self.y, 0, HEIGHT)
end

function Cursor:draw()
	self.sprite:draw(math.floor(self.x+self.offsetx), math.floor(self.y+self.offsety))
end

function Cursor:addInput(i)
	table.insert(self.inputs, i)
end

function Cursor:getInputs()
	return self.inputs
end

function Cursor:setOffset(x,y)
	self.offsetx = x
	self.offsety = y
end

return Cursor
