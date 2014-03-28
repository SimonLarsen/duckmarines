--[[
Small animation library HEAVILY based on Bartbes' AnAL.
See https://github.com/bartbes/love-misc-libs/tree/master/AnAL
]]

local Animation = {}
Animation.__index = Animation

--- Creates a new animation
-- @param image The image that contains the frames
-- @param fw The frame width
-- @param fh The frame height
-- @param ox Origin offset (x-axis)
-- @param oy Origin offset (y-axis)
-- @param delay The delay between two frames
-- @param frames The number of frames, 0 for autodetect
-- @param callback Callback function to call when animation completes
-- @return The created animation
function Animation.create(image, fw, fh, ox, oy, delay, frames, callback)
	local self = setmetatable({}, Animation)
	self.image = image
	self.ox = ox
	self.oy = oy
	self.delay = delay
	self.callback = callback

	self.quads = {}
	self.timer = 0
	self.frame = 1
	self.playing = true
	self.speed = 1
	self.mode = 1
	self.direction = 1

	local imgw = image:getWidth()
	local imgh = image:getHeight()
	if frames == 0 then
		frames = imgw / fw * imgh / fh
	end
	local rowsize = imgw/fw
	for i = 1, frames do
		local row = math.floor((i-1)/rowsize)
		local column = (i-1)%rowsize
		local quad = love.graphics.newQuad(column*fw, row*fh, fw, fh, imgw, imgh)
		table.insert(self.quads, quad)
	end

	return self
end

--- Update the animation
-- @param dt Time that has passed since last call
function Animation:update(dt)
	if not self.playing then return end

	self.timer = self.timer + dt * self.speed
	if self.timer > self.delay then
		self.timer = self.timer - self.delay
		self.frame = self.frame + self.direction

		-- If end of anim. reached
		if self.frame > #self.quads then
			-- Call callback if any
			if self.callback then
				self.callback()
			end
			-- Change direction depending on mode
			if self.mode == 1 then -- "loop"
				self.frame = 1
			elseif self.mode == 2 then -- "once"
				self.frame = self.frame - 1
				self:stop()
			elseif self.mode == 3 then -- "bounce"
				self.direction = -1
				self.frame = self.frame - 1
			end
		-- Progress animation
		elseif self.frame < 1 and self.mode == 3 then
			self.direction = 1
			self.frame = self.frame + 1
		end
	end
end

--- Draw the animation
-- @param x Position on x-axis.
-- @param y Position on y-axis.
-- @param Orientation (radians).
-- @param Scale factor (x-axis).
-- @param Scale factor (y-axis).
function Animation:draw(x, y, r, sx, sy)
	love.graphics.draw(self.image, self.quads[self.frame], x, y, r or 0, sx or 1, sy or 1, self.ox, self.oy)
end

--- Play the animation
-- Starts it if it was stopped.
-- Basically makes sure it uses the delays
-- to switch to the next frame.
function Animation:play()
	self.playing = true
end

--- Stop the animation
function Animation:stop()
	self.playing = false
end

--- Reset
-- Go back to the first frame.
function Animation:reset()
	self:seek(1)
end

--- Seek to a frame
-- @param frame The frame to display now
function Animation:seek(frame)
	self.frame = frame
	self.timer = 0
end

--- Set the speed
-- @param speed The speed to play at (1 is normal, 2 is double, etc)
function Animation:setSpeed(speed)
	self.speed = speed
end

--- Set the play mode
-- Could be "loop" to loop it, "once" to play it once, or "bounce" to play it, reverse it, and play it again (looping)
-- @param mode The mode: one of the above
function Animation:setMode(mode)
	if mode == "loop" then
		self.mode = 1
	elseif mode == "once" then
		self.mode = 2
	elseif mode == "bounce" then
		self.mode = 3
	end
end

return Animation
