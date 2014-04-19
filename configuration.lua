local Config = {}
Config.__index = Config

function Config.create()
	local self = setmetatable({}, Config)

	self.fullscreen = false
	self.vsync = true
	self.scale = 1
	self.music_volume = 4
	self.sound_volume = 4

	return self
end

function Config:save()
	local strdata = TSerial.pack(self)
	love.filesystem.write("config.lua", strdata)
end

function Config:load()
	if love.filesystem.exists("config.lua") then
		local strdata = love.filesystem.read("config.lua")
		local data = TSerial.unpack(strdata)

		for i,v in pairs(data) do
			self[i] = v
		end
	end
end

return Config
