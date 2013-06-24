State = {}
State.__index = State

StateStack = {}
StateStack.__index = StateStack

function StateStack.create()
	local self = setmetatable({}, StateStack)

	self.stack = {}

	return self
end

function StateStack:push(state)
	table.insert(self.stack, 1, state)
end

function StateStack:pop()
	local top = self.stack[1]

	table.remove(self.stack, 1)

	return top
end

function StateStack:peek()
	return self.stack[1]
end
