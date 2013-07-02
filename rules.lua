--[[
Object holding current game rules.
Set from game menu before starting game.
]]
Rules = {}

function Rules.create()
	local self = {}

	-- Number of entities pr. minute
	self.frequency = 100
	-- Percentage of entities that are enemies
	self.enemyperc = 5
	-- Time arrows stay before they disappear
	self.arrowtime = 10

	return self
end
