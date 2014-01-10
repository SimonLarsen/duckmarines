ResMgr = {}
ResMgr.__index = ResMgr

local images = {}
local fonts = {}

local fontString = " 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ.,:+-?!()|x%"

function ResMgr.getImage(_path)
	local path = "res/" .. _path
	if images[path] == nil then
		images[path] = love.graphics.newImage(path)
		images[path]:setWrap("repeat", "repeat")
		print("Loaded image: " .. _path)
	end
	return images[path]
end

function ResMgr.loadFonts()
	fonts["bold"] = love.graphics.newImageFont(ResMgr.getImage("fonts/bold.png"), fontString)
	fonts["menu"] = love.graphics.newImageFont(ResMgr.getImage("fonts/menu.png"), fontString)
	fonts["joystix30"] = love.graphics.newFont("res/fonts/joystix.ttf", 30)
	fonts["joystix40"] = love.graphics.newFont("res/fonts/joystix.ttf", 40)
end

function ResMgr.getFont(name)
	return fonts[name]
end
