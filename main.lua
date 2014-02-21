require("Tserial")
require("util")
require("resmgr")
require("map")
require("input")
require("configuration")

require("component")
require("label")
require("menu")
require("selectionList")
require("textInput")
require("slider")

require("stack")
require("state")
require("rules")

require("mainMenuState")
require("inputSelectState")
require("levelSelectionState")
require("advancedSettingsState")
require("optionsState")
require("ingameState")
require("pauseGameState")
require("countdownState")
require("eventTextState")
require("switchAnimState")
require("gameOverState")
require("duckDashState")
require("escapeState")
require("levelEditorState")
require("loadLevelState")
require("saveLevelState")
require("messageBoxState")
require("confirmBoxState")
require("eventScoreState")

require("sprite")
require("anim")

require("cursor")
require("bot")
require("arrow")
require("entity")
require("duck")
require("goldduck")
require("pinkduck")
require("enemy")
require("particles")

WIDTH = 700
HEIGHT = 442

SCALEX = 1
SCALEY = 1

local stateStack
local config

function love.load()
	-- Setup user data
	if love.filesystem.exists("usermaps") == false then
		love.filesystem.createDirectory("usermaps")
	end
	-- Read configuration
	config = Config.load()
	if config == nil then
		config = Config.create()
	end

	-- Setup screen
	setScreenMode()
	love.graphics.setDefaultFilter("nearest", "nearest")
	love.graphics.setLineStyle("rough")
	math.randomseed(os.time())

	-- Preload assets
	ResMgr.loadFonts()

	-- Setup mouse
	love.mouse.setVisible(false)

	-- Setup gamestate stack
	stateStack = Stack.create()
	pushState(MainMenuState.create(config))
end

function love.update(dt)
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
end

function love.keypressed(k)
	stateStack:peek():keypressed(k)
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
