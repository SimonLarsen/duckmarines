--[[
Object holding current game rules.
Set from game menu before starting game.
]]
Rules = {}

function Rules.create()
	local self = {}

	-- Round time in minutes
	self.roundtime = 3
	-- Number of entities pr. minute
	self.frequency = 100
	-- Percentage of entities that are enemies
	self.enemyperc = 6
	-- Percentage of entities that are golden ducks
	self.goldperc = 6
	-- Percentage of entities that are pink ducks
	self.pinkperc = 4
	-- Time arrows stay before they disappear
	self.arrowtime = 10
	-- Number of arrows per player
	self.maxarrows = 4
	-- Duck rush multiplier
	self.rushfrequency = 1000

	self.eventTime = {}
	self.eventTime[IngameState.EVENT_RUSH] 		= 15
	self.eventTime[IngameState.EVENT_PREDRUSH]	= 15
	self.eventTime[IngameState.EVENT_FREEZE] 	= 7
	self.eventTime[IngameState.EVENT_SWITCH] 	= 0
	self.eventTime[IngameState.EVENT_PREDATORS]	= 0
	self.eventTime[IngameState.EVENT_VACUUM] 	= 0
	self.eventTime[IngameState.EVENT_SPEEDUP] 	= 10
	self.eventTime[IngameState.EVENT_SLOWDOWN] 	= 10

	return self
end
