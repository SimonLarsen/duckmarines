--[[
Object holding current game rules.
Set from game menu before starting game.
]]
Rules = {}

function Rules.create()
	local self = {}

	--- Number of entities pr. minute
	self.frequency = 100
	--- Percentage of entities that are enemies
	self.enemyperc = 5

	return self
end
