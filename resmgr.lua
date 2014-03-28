local ResMgr = {}
ResMgr.__index = ResMgr

local images = {}
local fonts = {}

local fontString = " 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ.,:+-?!()|x%"

local currentSongSource = nil

function ResMgr.getImage(_path)
	local path = "res/images/" .. _path
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
	fonts["joystix30"] = love.graphics.newFont("res/images/fonts/joystix.ttf", 30)
	fonts["joystix40"] = love.graphics.newFont("res/images/fonts/joystix.ttf", 40)
end

function ResMgr.getFont(name)
	return fonts[name]
end

function playMusic(name)
	stopMusic()
	local source = love.audio.newSource("res/music/"..name..".ogg", "stream")
	source:setLooping(true)
	source:setVolume(config.music_volume/5)
	source:play()

	currentSongSource = source
	return source
end

function stopMusic()
	if currentSongSource then
		currentSongSource:stop()
		currentSongSource = nil
	end
end

function updateVolume()
	currentSongSource:setVolume(config.music_volume/5)
end

return ResMgr
