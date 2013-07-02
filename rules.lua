--[[
Object holding current game rules.
Set from game menu before starting game.
]]
Rules = {}

function Rules.create()
	local self = {}

	-- Round time in minutes
	self.roundtime = 2
	-- Number of entities pr. minute
	self.frequency = 100
	-- Percentage of entities that are enemies
	self.enemyperc = 6
	-- Percentage of entities that are golden ducks
	self.goldperc = 6
	-- Percentage of entities that are pink ducks
	self.pinkperc = 3
	-- Time arrows stay before they disappear
	self.arrowtime = 10
	-- Number of arrows per player
	self.maxarrows = 4

	return self
end
