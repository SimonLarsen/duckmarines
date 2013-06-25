ResMgr = {}
ResMgr.__index = ResMgr

local images = {}

function ResMgr.getImage(_path)
	local path = "res/" .. _path
	if images[path] == nil then
		images[path] = love.graphics.newImage(path)
		images[path]:setWrap("repeat", "repeat")
		print("Loaded image: " .. _path)
	end
	return images[path]
end
