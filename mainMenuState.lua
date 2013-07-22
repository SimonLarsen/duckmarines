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
	love.graphics.print("3 LEVEL EDITOR", 32, 64)
end

function MainMenuState:keypressed(k, uni)
	if k == "1" then
		pushState(IngameState.create("test", Rules.create()))
	elseif k == "2" then
		pushState(IngameState.create("test2", Rules.create()))
	elseif k == "3" then
		pushState(LevelEditorState.create())
	end
end
