require("Tserial")
require("util")
require("resmgr")
require("map")
require("input")
require("configuration")

require("component")
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
require("duckDashState")
require("gameOverState")

require("levelEditorState")

require("loadLevelState")
require("saveLevelState")
require("messageBoxState")
require("confirmBoxState")

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
SCALE = 1

local stateStack
local config
local focused

function love.load()
	-- Setup screen
	love.window.setMode(WIDTH*SCALE, HEIGHT*SCALE, {fullscreen=false, vsync=true})
	love.graphics.setDefaultFilter("nearest", "nearest")
	love.graphics.setLineStyle("rough")

	-- Setup user data
	if love.filesystem.exists("usermaps") == false then
		love.filesystem.mkdir("usermaps")
	end
	-- Read configuration
	config = Config.load()
	if config == nil then
		config = Config.create()
	end

	-- Setup mouse
	--love.mouse.setGrab(true)
	love.mouse.setVisible(false)
	focused = true

	-- Setup gamestate stack
	stateStack = Stack.create()
	pushState(MainMenuState.create(config))
end

function love.update(dt)
	if focused == false then return end

	if dt > 1/30 then
		dt = 1/30
	end
	stateStack:peek():baseUpdate(dt)
end

function love.draw()
	love.graphics.scale(SCALE, SCALE)
	local bottom = 1
	while stateStack:peek(bottom):isTransparent() == true do
		bottom = bottom + 1
	end
	for i=bottom, 1, -1 do
		stateStack:peek(i):baseDraw()
	end
end

function love.keypressed(k, uni)
	if k == "f3" then
		love.mouse.setGrab(not love.mouse.isGrabbed())
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

function love.focus(f)
	focused = f
end

function setScreenMode()
	love.window.setMode(WIDTH, HEIGHT, {fullscreen=config.fullscreen, vsync=config.vsync})
end
