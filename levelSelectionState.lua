LevelSelectionState = {}
LevelSelectionState.__index = LevelSelectionState
setmetatable(LevelSelectionState, State)

function LevelSelectionState.create(parent)
	local self = setmetatable(State.create(), LevelSelectionState)

	self.inputs = parent.inputs
	self.cursor = Cursor.create(WIDTH/2, HEIGHT/2, 1)
	self.rules = Rules.create()

	self.list = SelectionList.create((WIDTH-300)/2, 80, 300, 8, 21)
	self:updateMapList()
	self.list:setSelection(1)

	self.menu = Menu.create((WIDTH-300)/2, 300, 300, 32, 16, self)
	self.menu:addButton("ADVANCED SETTINGS", "advanced")
	self.menu:addButton("START GAME", "start")
	self.menu:addButton("BACK", "back")

	self:addComponent(self.list)
	self:addComponent(self.menu)

	self.bg = ResMgr.getImage("bg_stars.png")

	return self
end

function LevelSelectionState:update(dt)
	for i,v in ipairs(self:getInputs()) do
		if v:wasClicked() then
			for j,c in ipairs(self:getComponents()) do
				c:click(self.cursor.x, self.cursor.y)
			end
		end
		self.cursor:move(v:getMovement(dt, false))
	end
end

function LevelSelectionState:draw()
	love.graphics.draw(self.bg, 0, 0)

	love.graphics.setFont(ResMgr.getFont("menu"))
	love.graphics.printf("SELECT LEVEL", 0, 25, WIDTH, "center")

	self.list:draw()
	self.menu:draw()
	self.cursor:draw()
end

function LevelSelectionState:buttonPressed(id, source)
	if id == "advanced" then
		pushState(AdvancedSettingsState.create(self, self.rules))
	elseif id == "start" then
		popState()
		popState()
		local text = self.list:getText():lower()
		if text:sub(1,8) == "custom: " then
			pushState(IngameState.create(self, "usermaps/" .. text:sub(9), self.rules))
		else
			pushState(IngameState.create(self, "res/maps/" .. text, self.rules))
		end
	elseif id == "back" then
		popState()
	end
end

function LevelSelectionState:updateMapList()
	local items = {}
	local files = love.filesystem.enumerate("res/maps")
	for i,v in ipairs(files) do
		table.insert(items, v:upper())
	end
	files = love.filesystem.enumerate("usermaps")
	for i,v in ipairs(files) do
		table.insert(items, "CUSTOM: " .. v:upper())
	end
	self.list:setItems(items)
end
