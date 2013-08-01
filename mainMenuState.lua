MainMenuState = {}
MainMenuState.__index = MainMenuState
setmetatable(MainMenuState, State)

function MainMenuState.create()
	local self = setmetatable({}, MainMenuState)
	return self
end

function MainMenuState:draw()
	love.graphics.print("1 START TEST", 32, 32)
	love.graphics.print("2 START TEST2", 32, 48)
	love.graphics.print("3 START CUSTOM MAP", 32, 64)
	love.graphics.print("4 LEVEL EDITOR", 32, 80)
end

function MainMenuState:keypressed(k, uni)
	if k == "1" then
		pushState(IngameState.create("res/maps/test.lua", Rules.create()))
	elseif k == "2" then
		pushState(IngameState.create("res/maps/test2.lua", Rules.create()))
	elseif k == "3" then
		pushState(IngameState.create("usermaps/custom.lua", Rules.create()))
	elseif k == "4" then
		pushState(LevelEditorState.create())
	end
end
