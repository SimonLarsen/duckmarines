ResMgr = require("resmgr")
MusicMgr = require("musicmgr")
Rules = require("rules")
IngameState = require("ingameState")
require("input")
require("util")
require("slam")

local Config = require("configuration")
local Rules = require("rules")
local Stack = require("stack")
local MainMenuState = require("mainMenuState")

VERSION = "1.0"
WIDTH = 700
HEIGHT = 442

local SCALEX = 1
local SCALEY = 1
local focus = true

local stateStack
config = nil
rules = nil

function love.load()
	-- Setup user data
	if love.filesystem.getInfo("usermaps") == nil then
		love.filesystem.createDirectory("usermaps")
	end

	-- Read configuration
	config = Config.create()
	config:load()

	-- Load rules
	rules = Rules.create()
	rules:load()

	-- Setup screen
	setScreenMode()
	love.graphics.setDefaultFilter("nearest", "nearest")
	love.graphics.setLineStyle("rough")
	math.randomseed(os.time())

	-- Preload assets
	ResMgr.loadFonts()
	MusicMgr.loadSongs()

	-- Setup mouse
	love.mouse.setVisible(false)

	-- Setup gamestate stack
	stateStack = Stack.create()
	pushState(MainMenuState.create())
end

function love.update(dt)
	if not focus then return end
	if dt > 1/30 then
		dt = 1/30
	end

	stateStack:peek():baseUpdate(dt)
end

function love.draw()
	love.graphics.scale(SCALEX, SCALEY)

	local bottom = 1
	while stateStack:peek(bottom):isTransparent() == true do
		bottom = bottom + 1
	end
	for i=bottom, 1, -1 do
		stateStack:peek(i):baseDraw()
	end
	if not focus then
		love.graphics.setColor(0,0,0,128/255)
		love.graphics.rectangle("fill", 0, 0, WIDTH, HEIGHT)
		love.graphics.setColor(1,1,1,1)
	end
end

function love.keypressed(k)
	stateStack:peek():keypressed(k)
end

function love.focus(f)
	focus = f
end

function love.textinput(text)
	stateStack:peek():textinput(text)
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

function setScreenMode()
	if config.fullscreen == true then
		local swidth, sheight = love.window.getDesktopDimensions()
		SCALEX = swidth/WIDTH
		SCALEY = sheight/HEIGHT
		love.window.setMode(0, 0, {fullscreen=true, vsync=config.vsync})
	else
		SCALEX = 1
		SCALEY = 1
		love.window.setMode(WIDTH, HEIGHT, {fullscreen=false, vsync=config.vsync})
	end
end

function setScissor(x, y, width, height)
	if x then
		love.graphics.setScissor(x*SCALEX, y*SCALEY, width*SCALEX, height*SCALEY)
	else
		love.graphics.setScissor()
	end
end
