local Config = {}
Config.__index = Config

function Config.create()
	local self = setmetatable({}, Config)

	self.fullscreen = false
	self.vsync = true
	self.scale = 1
	self.music_volume = 4
	self.sound_volume = 4
	self.ai1level = 2
	self.ai2level = 2
	self.ai3level = 2
	self.ai4level = 2

	return self
end

function Config:save()
	local strdata = TSerial.pack(self)
	love.filesystem.write("config", strdata)
end

function Config:load()
	if love.filesystem.exists("config") then
		local strdata = love.filesystem.read("config")
		local data = TSerial.unpack(strdata)

		for i,v in pairs(data) do
			self[i] = v
		end
	end
end

return Config
