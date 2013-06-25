Cursor = {}
Cursor.__index = Cursor

function Cursor.create(x,y,player)
	local self = setmetatable({}, Cursor)

	self.x, self.y = x,y
	self.player = player
	self.img = ResMgr.getImage("cursor"..player..".png")

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
end

function Cursor:getDrawable()
	return self.img
end
