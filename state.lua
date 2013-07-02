--[[
Game state object.
Contains callbacks for updating and drawing game State
and exposes Input objects to main program.
]]
State = {}
State.__index = State

function State:update(dt) end
function State:draw() end
function State:getInputs() return {} end
