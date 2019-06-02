local IngameState = require("ingameState")

local Rules = {}
Rules.__index = Rules

function Rules.create()
	local self = setmetatable({}, Rules)

	self.eventTime = {}
	self:setDefaults()

	return self
end

function Rules:setDefaults()
	-- Round time in minutes
	self.roundtime = 180
	-- Number of entities pr. minute
	self.frequency = 100
	-- Percentage of entities that are enemies
	self.enemyperc = 6
	-- Percentage of entities that are golden ducks
	self.goldperc = 6
	-- Percentage of entities that are pink ducks
	self.pinkperc = 4
	-- Number of arrows per player
	self.maxarrows = 4
	-- Time arrows stay before they disappear
	self.arrowtime = 10
	-- Predators eat ducks
	self.predatorseat = true
	-- Mini games enabled
	self.minigames = true

	-- Duck rush multiplier
	self.rushfrequency = 1000

	self.eventTime[IngameState.EVENT_RUSH] 		= 15
	self.eventTime[IngameState.EVENT_PREDRUSH]	= 15
	self.eventTime[IngameState.EVENT_FREEZE] 	= 5
	self.eventTime[IngameState.EVENT_SWITCH] 	= 0
	self.eventTime[IngameState.EVENT_PREDATORS]	= 0
	self.eventTime[IngameState.EVENT_VACUUM] 	= 0
	self.eventTime[IngameState.EVENT_SPEEDUP] 	= 10
	self.eventTime[IngameState.EVENT_SLOWDOWN] 	= 10

	-- Gold duck bonus
	self.goldbonus = 25
	-- Pink duck bonus
	self.pinkbonus = 10

	-- Event prizes
	self.duckdashprize = 50
	self.escapeprize = 50
end

function Rules:save()
	local strdata = TSerial.pack(self)
	love.filesystem.write("rules", strdata)
end

function Rules:load()
	if love.filesystem.getInfo("rules") ~= nil then
		local strdata = love.filesystem.read("rules")
		local data = TSerial.unpack(strdata)

		for i,v in pairs(data) do
			self[i] = v
		end
	end
end

return Rules
