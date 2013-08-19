GameOverState = {}
GameOverState.__index = GameOverState
setmetatable(GameOverState, State)

function GameOverState.create(parent, scores)
	local self = setmetatable(State.create(), GameOverState)

	self.inputs = parent.inputs
	for i=1,4 do
		if self.inputs[i]:getType() == Input.TYPE_BOT then
			self.inputs[i] = NullInput.create()
		end
	end

	self.mapname = parent.mapname
	self.rules = parent.rules
	self.scores = scores

	self.cursor = Cursor.create(WIDTH/2, HEIGHT/2, 1)

	self.menu = Menu.create((WIDTH-200)/2, 260, 220, 32, 20, self)
	self.menu:addButton("REMATCH", "rematch")
	self.menu:addButton("MAIN MENU", "mainmenu")

	return self
end

function GameOverState:update(dt)
	for i,v in ipairs(self.inputs) do
		if v:wasClicked() then
			self.menu:click(self.cursor.x, self.cursor.y)
		end
		self.cursor:move(v:getMovement(dt, false))
	end
end

function GameOverState:draw()
	love.graphics.setColor(0, 0, 0, 128)
	love.graphics.rectangle("fill", 0, 0, WIDTH, HEIGHT)
	love.graphics.setColor(255, 255, 255)

	self.menu:draw()

	love.graphics.setFont(ResMgr.getFont("bold"))
	for i = 1,4 do
		love.graphics.print("PLAYER "..i..": "..self.scores[i], 16, i*16)
	end

	self.cursor:draw()
end

function GameOverState:buttonPressed(id, source)
	if id == "rematch" then
		popState()
		popState()
		pushState(IngameState.create(self, self.mapname, self.rules))
	elseif id == "mainmenu" then
		popState()
		popState()
	end
end

function GameOverState:isTransparent() return true end
