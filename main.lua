require("resmgr")
require("map")
require("anim")
require("input")

require("state")
require("ingameState")

require("cursor")
require("entity")
require("duck")
require("enemy")

local stateStack = nil
local cursors = {}
local inputs = {}

function love.load()
	love.graphics.setMode(582, 442)
	love.graphics.setDefaultImageFilter("nearest", "nearest")

	love.mouse.setGrab(true)
	love.mouse.setVisible(false)

	-- Initialize cursors and inputs
	cursors[1] = Cursor.create(100, 100, 1)
	cursors[2] = Cursor.create(200, 200, 2)

	inputs[1] = KeyboardInput.create()
	inputs[2] = MouseInput.create()

	stateStack = StateStack.create()
	stateStack:push(IngameState.create())
end

function love.update(dt)
	for i=1,#cursors do
		cursors[i]:move(inputs[i]:getMovement(dt))
	end

	stateStack:peek():update(dt)
end

function love.draw()
	stateStack:peek():draw()

	for i,v in ipairs(cursors) do
		love.graphics.draw(v:getDrawable(), v.x, v.y, 0, 1, 1, 2, 2)
	end
end

function love.keypressed(k, uni)
	if k == "escape" then
		love.event.quit()
	end
end
