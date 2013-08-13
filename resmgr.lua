ResMgr = {}
ResMgr.__index = ResMgr

local images = {}
local fonts = {}

local fontString = " 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ.,:-?!()|"

function ResMgr.getImage(_path)
	local path = "res/" .. _path
	if images[path] == nil then
		images[path] = love.graphics.newImage(path)
		images[path]:setWrap("repeat", "repeat")
		print("Loaded image: " .. _path)
	end
	return images[path]
end

function ResMgr.getFont(name)
	if fonts[name] == nil then
		local image = ResMgr.getImage("fonts/".. name .. ".png")
		local font = love.graphics.newImageFont(image, fontString)
		fonts[name] = font
	end
	return fonts[name]
end
