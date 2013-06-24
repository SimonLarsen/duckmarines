ResMgr = {}
ResMgr.__index = ResMgr

local prefix = "res/"
local images = {}

function ResMgr.getImage(_path)
	local path = prefix .. _path
	if images[path] == nil then
		images[path] = love.graphics.newImage(path)
		images[path]:setWrap("repeat", "repeat")
	end
	return images[path]
end
