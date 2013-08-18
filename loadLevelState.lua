LoadLevelState = {}
LoadLevelState.__index = LoadLevelState
setmetatable(LoadLevelState, State)

function LoadLevelState.create(parent, map)
	local self = setmetatable(State.create(), LoadLevelState)

	self.inputs = parent.inputs
	self.cursor = parent.cursor
	self.parent = parent

	self.list = SelectionList.create(178, 133, 200, 6, 21, self)
	self.input = TextInput.create(178, 307, 200, 24)
	self.input:setActive(true)

	self.menu = Menu.create(390, 212, 134, 32, 11, self)
	self.menu:addButton("LOAD", "Load")
	self.menu:addButton("DELETE", "delete")
	self.menu:addButton("CANCEL", "cancel")

	self:addComponent(self.list)
	self:addComponent(self.input)
	self:addComponent(self.menu)

	self:updateFileList()

	return self
end

function LoadLevelState:update(dt)
	for i,v in ipairs(self.inputs) do
		if v:wasClicked() then
			for j,c in ipairs(self:getComponents()) do
				c:click(self.cursor.x, self.cursor.y)
			end
		end
		self.cursor:move(v:getMovement(dt, false))
	end
end

function LoadLevelState:draw()
	love.graphics.setColor(23, 23, 23, 255)
	love.graphics.rectangle("fill", 142, 96, 415, 271)
	love.graphics.setColor(241, 148, 0, 255)
	love.graphics.rectangle("line", 142.5, 96.5, 415, 271)

	love.graphics.setColor(255, 255, 255, 255)
	self.list:draw()
	self.input:draw()
	self.menu:draw()
	self.cursor:draw()
end

function LoadLevelState:updateFileList()
	local items = {}
	local files = love.filesystem.enumerate("usermaps")
	for i,v in ipairs(files) do
		table.insert(items, v:upper())
	end
	self.list:setItems(items)
end

function LoadLevelState:selectionChanged(text, source)
	self.input:setText(text)
end

function LoadLevelState:buttonPressed(id, source)
	if id == "Load" then
		if love.filesystem.exists(self:getFilename()) then
			self.parent.map = Map.create(self:getFilename())
			self.parent.map:updateSpriteBatch(true)
			love.timer.sleep(0.25)
			popState()
		else
			pushState(MessageBoxState.create(self,
			"MAP " .. self.input:getText():upper() .. " DOES NOT EXIST"))
		end
	elseif id == "delete" then
		if love.filesystem.exists(self:getFilename()) then
			pushState(
				ConfirmBoxState.create(self,
				"ARE YOU SURE YOU WANT TO DELETE " .. self.input:getText():upper() .. "?",
				function()
					love.filesystem.remove(self:getFilename())
					self:updateFileList()
				end
			))
		end
	elseif id == "cancel" then
		love.timer.sleep(0.25)
		popState()
	end
end

function LoadLevelState:getFilename()
	return "usermaps/" .. self.input:getText():lower()
end

function LoadLevelState:isTransparent() return true end
