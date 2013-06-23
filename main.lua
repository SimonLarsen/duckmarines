require("resmgr")
require("map")

local map = nil

function love.load()
	love.graphics.setMode(582, 442)

	map = Map.create("test")
end

function love.update(dt)
	
end

function love.draw()
	love.graphics.draw(map:getDrawable(), 3, 8)
end
