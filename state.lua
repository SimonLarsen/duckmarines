--[[
Game state object.
Contains callbacks for updating and drawing game State
and exposes Input objects to main program.
]]
require("input")
local Cursor = require("cursor")

local State = {}
State.__index = State

function State.create()
	local self = setmetatable({}, State)

	self.inputs = {}
	self.cursors = {}
	self.components = {}
	self.coroutines = {}

	return self
end

function State:enter() end
function State:leave() end 
function State:update(dt) end
function State:draw() end
function State:drawAfter() end
function State:getInputs() return self.inputs end
function State:getComponents() return self.components end 
function State:addComponent(c) table.insert(self.components, c) return c end
function State:buttonPressed(id, source) end

function State:isTransparent() return false end

function State:baseUpdate(dt)
	-- Update components and cursors
	for i,v in pairs(self.cursors) do
		for j,w in pairs(v:getInputs()) do
			if w:wasClicked() then
				for k,c in pairs(self:getComponents()) do
					if c:click(v.x, v.y) then
						break
					end
				end
			end
			v:move(w:getMovement(dt, false))
		end
	end

	-- Update coroutines
	for i=#self.coroutines, 1, -1 do
		if coroutine.resume(self.coroutines[i], dt) == false then
			table.remove(self.coroutines, i)
		end
	end

	-- Update state
	self:update(dt)

	-- Consume input actions and clicks
	for i=1,4 do
		if self.inputs[i] then
			self.inputs[i]:clear()
		end
	end
end

function State:baseDraw()
	self:draw()
	for i,v in pairs(self:getComponents()) do
		v:draw()
	end
	for i,v in pairs(self.cursors) do
		v:draw()
	end
	self:drawAfter()
end

function State:startCoroutine(co)
	table.insert(self.coroutines, co)
end

function State:keypressed(...)
	for i,v in pairs(self:getComponents()) do
		v:keypressed(...)
	end
	for i,v in pairs(self:getInputs()) do
		v:keypressed(...)
	end
end

function State:textinput(...)
	for i,v in ipairs(self:getComponents()) do
		v:textinput(...)
	end
end

function State:mousepressed(...)
	for i,v in pairs(self:getInputs()) do
		v:mousepressed(...)
	end
end

function State:mousereleased(...)
	for i,v in pairs(self:getInputs()) do
		v:mousereleased(...)
	end
end

function State:joystickpressed(...)
	for i,v in pairs(self:getInputs()) do
		v:joystickpressed(...)
	end
end

return State
