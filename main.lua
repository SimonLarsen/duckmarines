require("resmgr")
require("map")
require("anim")

require("state")
require("ingameState")

require("entity")
require("duck")
require("enemy")

function love.load()
	love.graphics.setMode(582, 442)
	love.graphics.setDefaultImageFilter("nearest", "nearest")

	stateStack = StateStack.create()
	stateStack:push(IngameState.create())
end

function love.update(dt)
	stateStack:peek():update(dt)
end

function love.draw()
	stateStack:peek():draw()
end
