--[[
Generic stack implementation
]]
Stack = {}
Stack.__index = Stack

function Stack.create()
	local self = setmetatable({}, Stack)
	self.stack = {}
	return self
end

--- Pushes element to top of Stack.
--  @param e Element to push
function Stack:push(e)
	table.insert(self.stack, 1, e)
end

--- Pops top element off stack.
--  @return Top element
function Stack:pop()
	local top = self.stack[1]
	table.remove(self.stack, 1)
	return top
end

--- Peek at top of stack.
--  @return Top element without popping
function Stack:peek(no)
	return self.stack[no or 1]
end
