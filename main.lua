require("util")
require("resmgr")
require("map")
require("input")

require("stack")
require("state")
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
	love.graphics.setMode(582, 442, false, true)
	love.graphics.setDefaultImageFilter("nearest", "nearest")

	love.mouse.setGrab(true)
	love.mouse.setVisible(false)

	stateStack = Stack.create()
	stateStack:push(IngameState.create())
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
		for i,v in ipairs(stateStack:peek():getInputs()) do
			v:keypressed(k, uni)
		end
	end
end

function love.mousepressed(x, y, button)
	for i,v in ipairs(stateStack:peek():getInputs()) do
		v:mousepressed(x, y, button)
	end
end

function love.mousereleased(x, y, button)
	for i,v in ipairs(stateStack:peek():getInputs()) do
		v:mousereleased(x, y, button)
	end
end

function love.joystickpressed(joystick, button)
	for i,v in ipairs(stateStack:peek():getInputs()) do
	   v:joystickpressed(joystick, button)
	end
end
