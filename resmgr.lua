local ResMgr = {}
ResMgr.__index = ResMgr

local images = {}
local fonts = {}
local sounds = {}

local fontString = " 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ.,:+-?!()|x%"

local currentSongSource = nil

function ResMgr.getImage(name)
	local path = "res/images/" .. name
	if images[path] == nil then
		images[path] = love.graphics.newImage(path)
		images[path]:setWrap("repeat", "repeat")
		print("Loaded image: " .. name)
	end
	return images[path]
end

function ResMgr.loadFonts()
	fonts["bold"] = love.graphics.newImageFont("res/images/fonts/bold.png", fontString, 2)
	fonts["menu"] = love.graphics.newImageFont("res/images/fonts/menu.png", fontString)
	fonts["joystix30"] = love.graphics.newFont("res/fonts/joystix.ttf", 30)
	fonts["joystix40"] = love.graphics.newFont("res/fonts/joystix.ttf", 40)
end

function ResMgr.getFont(name)
	return fonts[name]
end

function ResMgr.getSound(name)
	local path = "res/sounds/" .. name .. ".wav"
	if sounds[path] == nil then
		sounds[path] = love.audio.newSource(path, "static")
		sounds[path]:addTags("sfx")
		print("Loaded sound: " .. name)
	end
	return sounds[path]
end

function playSound(name)
	local sound = ResMgr.getSound(name)
	love.audio.play(sound)
end

function playMusic(name)
	stopMusic()

	local path = "res/music/" .. name
	if love.filesystem.getInfo(path) == nil then return end

	local source = love.audio.newSource("res/music/" .. name, "stream")
	source:setLooping(true)
	source:setVolume(config.music_volume/5)
	source:play()

	currentSongSource = source
end

function stopMusic()
	if currentSongSource then
		currentSongSource:stop()
		currentSongSource = nil
	end
end

function updateVolume()
	currentSongSource:setVolume(config.music_volume/5)
	love.audio.tags.sfx.setVolume(config.sound_volume/5)
end

return ResMgr