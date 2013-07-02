require("util")
require("resmgr")
require("map")
require("input")

require("stack")
require("state")
require("rules")
require("ingameState")

require("sprite")
require("anim")

require("cursor")
require("arrow")
require("entity")
require("duck")
require("enemy")

local stateStack = nil

function love.load()
	love.graphics.setMode(700, 542, false, true)
	love.graphics.setDefaultImageFilter("nearest", "nearest")

	love.mouse.setGrab(true)
	love.mouse.setVisible(false)

	stateStack = Stack.create()
	stateStack:push(IngameState.create(Rules.create()))
end

function love.update(dt)
	stateStack:peek():update(dt)
end

function love.draw()
	stateStack:peek():draw()
end

function love.keypressed(k, uni)
	if k == "escape" then
		love.event.quit()
	else
		stateStack:peek():keypressed(k, uni)
	end
end

function love.mousepressed(x, y, button)
	stateStack:peek():mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
	stateStack:peek():mousereleased(x, y, button)
end

function love.joystickpressed(joystick, button)
	stateStack:peek():joystickpressed(joystick, button)
end
