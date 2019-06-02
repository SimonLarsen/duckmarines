local State = require("state")
local Label = require("label")
local Map = require("map")
local Menu = require("menu")
local SelectionList = require("selectionList")
local CountdownState = require("countdownState")
local AdvancedSettingsState = require("advancedSettingsState")

local LevelSelectionState = {}
LevelSelectionState.__index = LevelSelectionState
setmetatable(LevelSelectionState, State)

function LevelSelectionState.create(parent)
	local self = setmetatable(State.create(), LevelSelectionState)

	self.inputs = parent.inputs
	self.cursors = parent.cursors

	self.bg = ResMgr.getImage("bg_stars.png")
	self.imgBlueprint = ResMgr.getImage("blueprint.png")
	self.imgDogear = ResMgr.getImage("blueprint_dogear.png")
	self.imgPreview = ResMgr.getImage("preview_assets.png")
	self.imgTexture = ResMgr.getImage("blueprint_texture.png")
	self.batch = love.graphics.newSpriteBatch(self.imgPreview, 128)

	self:addComponent(Label.create("SELECT A LEVEL", 0, 25, WIDTH, "center"))

	self.list = self:addComponent(SelectionList.create(WIDTH/2-295, 62, 260, 15, 21, self))
	self:updateMapList()
	self.list:setSelection(config.level)

	self.menu = self:addComponent(Menu.create(WIDTH/2, 300, 298, 32, 10, self))
	self.menu:addButton("START GAME", "start")
	self.menu:addButton("ADVANCED SETTINGS", "advanced")
	self.menu:addButton("BACK", "back")

	return self
end

function LevelSelectionState:enter()
	MusicMgr.playMenu()
end

function LevelSelectionState:draw()
	love.graphics.draw(self.bg, 0, 0)

	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", WIDTH/2, 62, 297, 228)
	love.graphics.setColor(1, 194/255, 49/255)
	love.graphics.rectangle("line", WIDTH/2+0.5, 62.5, 297, 228)
	love.graphics.setColor(1,1,1)

	love.graphics.draw(self.imgBlueprint, WIDTH/2+8, 70)
	love.graphics.draw(self.batch, WIDTH/2+11, 73)
	love.graphics.draw(self.imgDogear, WIDTH/2+265, 70)
	love.graphics.setBlendMode("multiply","premultiplied")
	love.graphics.draw(self.imgTexture, WIDTH/2+11, 73)
	love.graphics.setBlendMode("alpha")
end

function LevelSelectionState:buttonPressed(id, source)
	if id == "advanced" then
		playSound("quack")
		pushState(AdvancedSettingsState.create(self))
	elseif id == "start" then
		playSound("quack")
		popState()
		pushState(IngameState.create(self, self:getFilename()))
		pushState(CountdownState.create())
	elseif id == "back" then
		playSound("quack")
		popState()
	end
end

function LevelSelectionState:getFilename()
	return self.list:getSelection()
end

function LevelSelectionState:updateMapList()
	local items = {}
	local labels = {}
	local files = love.filesystem.getDirectoryItems("res/maps")
	for i,v in ipairs(files) do
		table.insert(items, "res/maps/" .. v)
		table.insert(labels, v:upper())
	end
	files = love.filesystem.getDirectoryItems("usermaps")
	for i,v in ipairs(files) do
		table.insert(items, "usermaps/" .. v)
		table.insert(labels, "CUSTOM: " .. v:upper())
	end
	self.list:setItems(items, labels)
end

function LevelSelectionState:selectionChanged(source)
	playSound("click")

	self.batch:clear()
	local quadSub = love.graphics.newQuad(0, 23, 23, 22, 78, 63)
	local quadPit = love.graphics.newQuad(0, 0, 23, 23, 78, 63)
	local quadFenceHor = love.graphics.newQuad(23, 0, 28, 5, 78, 63)
	local quadFenceVer = love.graphics.newQuad(35, 7, 5, 28, 78, 63)
	local quadSpawnUp = love.graphics.newQuad(44, 23, 25, 18, 78, 63)
	local quadSpawnRight = love.graphics.newQuad(32, 48, 32, 11, 78, 63)
	local quadSpawnDown = love.graphics.newQuad(1, 45, 25, 18, 78, 63)
	local quadSpawnLeft = love.graphics.newQuad(46, 7, 32, 11, 78, 63)

	local map = Map.create(self:getFilename())
	-- Add tiles
	for iy=0,8 do
		for ix=0,11 do
			local tile = map:getTile(ix, iy)
			if tile >= 10 and tile <= 14 then
				self.batch:add(quadSub, ix*23, iy*23+1)
			elseif tile == 2 then
				self.batch:add(quadPit, ix*23, iy*23)
			elseif tile == 4 then
				self.batch:add(quadSpawnUp, ix*23-1, iy*23+2)
			elseif tile == 5 then
				self.batch:add(quadSpawnRight, ix*23-1, iy*23+9)
			elseif tile == 6 then
				self.batch:add(quadSpawnDown, ix*23-1, iy*23+9)
			elseif tile == 7 then
				self.batch:add(quadSpawnLeft, ix*23-8, iy*23+9)
			end
		end
	end
	-- Add fences
	for iy=0,8 do
		for ix=0,11 do
			local wall = map:getWall(ix, iy)
			if iy > 0 and wall % 2 == 1 then
				self.batch:add(quadFenceHor, ix*23-3, iy*23-3)
			end
			if ix > 0 and wall > 1 then
				self.batch:add(quadFenceVer, ix*23-3, iy*23-3)
			end
		end
	end
end

function LevelSelectionState:leave()
	config:update("level", self.list.selection)
end

return LevelSelectionState
