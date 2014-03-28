local Sprite = require("sprite")
local Arrow = {}
Arrow.__index = Arrow

function Arrow.create(x,y,dir,player)
	local self = setmetatable({}, Arrow)

	self.x, self.y = x, y
	self.dir = dir
	self.time = 0

	local img = ResMgr.getImage("arrows"..player..".png")
	local quad = love.graphics.newQuad(dir*48, 0, 48, 48, 192, 48)
	self.sprite = Sprite.create(img, quad)

	return self
end

function Arrow:draw()
	self.sprite:draw(self.x*48, self.y*48)
end

return Arrow
