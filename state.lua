--[[
Game state object.
Contains callbacks for updating and drawing game State
and exposes Input objects to main program.
]]
State = { inputs = {} }
State.__index = State

function State:update(dt) end
function State:draw() end
function State:getInputs() return self.inputs end
function State:isTransparent() return false end

function State:keypressed(...)
	for i,v in ipairs(self:getInputs()) do
		v:keypressed(...)
	end
end

function State:mousepressed(...)
	for i,v in ipairs(self:getInputs()) do
		v:mousepressed(...)
	end
end

function State:mousereleased(...)
	for i,v in ipairs(self:getInputs()) do
		v:mousereleased(...)
	end
end

function State:joystickpressed(...)
	for i,v in ipairs(self:getInputs()) do
		v:joystickpressed(...)
	end
end
