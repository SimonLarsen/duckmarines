require("resmgr")
require("map")
require("anim")

require("entity")
require("duck")

function love.load()
	love.graphics.setMode(582, 442)
	love.graphics.setDefaultImageFilter("nearest", "nearest")

	map = Map.create("test")
	duck = Duck.create(216, 168, 3)
end

function love.update(dt)
	duck:update(dt, map)
end

function love.draw()
	love.graphics.translate(3, 8)

	love.graphics.draw(map:getDrawable(), 0, 0)
	duck:draw()
end
