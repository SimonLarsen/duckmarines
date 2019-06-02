local State = require("state")
local SelectionList = require("selectionList")
local TextInput = require("textInput")
local Menu = require("menu")
local Map = require("map")
local ConfirmBoxState = require("confirmBoxState")
local MessageBoxState = require("messageBoxState")

local LoadLevelState = {}
LoadLevelState.__index = LoadLevelState
setmetatable(LoadLevelState, State)

function LoadLevelState.create(parent, map)
	local self = setmetatable(State.create(), LoadLevelState)

	self.inputs = parent.inputs
	self.cursors = parent.cursors
	self.parent = parent

	self.list = self:addComponent(SelectionList.create(178, 133, 200, 6, 21, self))
	self.input = self:addComponent(TextInput.create(178, 307, 200, 24))
	self.input:setActive(true)

	self.menu = self:addComponent(Menu.create(390, 212, 134, 32, 11, self))
	self.menu:addButton("LOAD", "Load")
	self.menu:addButton("DELETE", "delete")
	self.menu:addButton("CANCEL", "cancel")

	self:updateFileList()

	return self
end

function LoadLevelState:draw()
	love.graphics.setColor(23/255, 23/255, 23/255, 1)
	love.graphics.rectangle("fill", 142, 96, 415, 271)
	love.graphics.setColor(241/255, 148/255, 0, 1)
	love.graphics.rectangle("line", 142.5, 96.5, 415, 271)

	love.graphics.setColor(1,1,1,1)
end

function LoadLevelState:updateFileList()
	local items = {}
	local labels = {}
	local files = love.filesystem.getDirectoryItems("usermaps")
	for i,v in ipairs(files) do
		table.insert(items, v)
		table.insert(labels, v:upper())
	end
	self.list:setItems(items, labels)
end

function LoadLevelState:selectionChanged(source)
	self.input:setText(self.list:getSelection():upper())
end

function LoadLevelState:buttonPressed(id, source)
	if id == "Load" then
		playSound("quack")
		if love.filesystem.getInfo(self:getFilename()) ~= nil then
			self.parent.map = Map.create(self:getFilename())
			self.parent.map:updateSpriteBatch(true)
			love.timer.sleep(0.25)
			popState()
		else
			pushState(MessageBoxState.create(self,
			"MAP " .. self.input:getText():upper() .. " DOES NOT EXIST"))
		end
	elseif id == "delete" then
		playSound("quack")
		if love.filesystem.getInfo(self:getFilename()) ~= nil then
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
		playSound("quack")
		love.timer.sleep(0.25)
		popState()
	end
end

function LoadLevelState:getFilename()
	return "usermaps/" .. self.input:getText():lower()
end

function LoadLevelState:isTransparent() return true end

return LoadLevelState
