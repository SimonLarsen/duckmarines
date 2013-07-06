require("util")
require("resmgr")
require("map")
require("input")

require("stack")
require("state")
require("rules")

require("ingameState")
require("eventTextState")

require("sprite")
require("anim")

require("cursor")
require("arrow")
require("entity")
require("duck")
require("goldduck")
require("pinkduck")
require("enemy")

local stateStack = nil

function love.load()
	love.graphics.setMode(700, 442, false, true)
	love.graphics.setDefaultImageFilter("nearest", "nearest")

	love.mouse.setGrab(true)
	love.mouse.setVisible(false)

	stateStack = Stack.create()
	pushState(IngameState.create("test2", Rules.create()))
end

function love.update(dt)
	if dt > 1/30 then
		dt = 1/30
	end
	stateStack:peek():update(dt)
end

function love.draw()
	if stateStack:peek(1):isTransparent() == true then
		stateStack:peek(2):draw()
	end
	stateStack:peek(1):draw()
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

function pushState(state)
	stateStack:push(state)
end

function popState()
	stateStack:pop()
end
