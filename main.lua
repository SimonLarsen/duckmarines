require("util")
require("resmgr")
require("map")
require("input")

require("stack")
require("state")
require("rules")

require("mainMenuState")
require("ingameState")
require("eventTextState")
require("switchAnimState")
require("levelEditorState")

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
WIDTH = 700
HEIGHT = 442

function love.load()
	love.graphics.setMode(WIDTH, HEIGHT, false, true)
	love.graphics.setDefaultImageFilter("nearest", "nearest")

	love.mouse.setGrab(true)
	love.mouse.setVisible(false)

	stateStack = Stack.create()
	pushState(MainMenuState.create())
end

function love.update(dt)
	if dt > 1/30 then
		dt = 1/30
	end
	stateStack:peek():update(dt)
end

function love.draw()
	local bottom = 1
	while stateStack:peek(bottom):isTransparent() == true do
		bottom = bottom + 1
	end
	for i=bottom, 1, -1 do
		stateStack:peek(i):draw()
	end
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
