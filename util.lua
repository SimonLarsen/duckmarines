--- Converts directional vector into integer direction
function vecToDir(dx, dy)
	local pi = math.pi
	local angle = math.atan2(-dy, dx)
	if math.abs(angle) <= pi/4 then
		return 1
	elseif math.abs(angle) >= 3*pi/4 then
		return 3
	elseif angle > 0 then
		return 0
	else
		return 2
	end
end

--- Converts integer direction to unit vector
function dirToVec(dir)
	if dir == 0 then
		return 0, -1
	elseif dir == 1 then
		return 1, 0
	elseif dir == 2 then
		return 0, 1
	else
		return -1, 0
	end
end

--- Returns a random element from a table
function table.random(t)
	if #t > 1 then
		return t[love.math.random(1,#t)]
	else
		return t[1]
	end
end

--- Returns random number from a Gauss. dist. around 0
function math.randnorm()
	return love.math.random() - love.math.random()
end

--- Caps x in the interval [a,b]
function math.cap(x, a, b)
	return math.min(math.max(x, a), b)
end

--- Returns sign of x
function math.sign(x)
	return x < 0 and -1 or 1
end

--- Returns sign of x (or 0 if x == 0)
function math.signz(x)
	return x < 0 and -1 or x > 0 and 1 or 0
end

function math.round(x)
	return math.floor(x + 0.5)
end

function math.seq(first, last, increment)
	local t = {}
	local inch = increment or 1
	for i=first,last,inch do
		table.insert(t, i)
	end
	return t
end

--- Creates time string from number of seconds.
--  s = 123.4 produces "2:03"
function secsToString(s)
	local mins = math.floor(s / 60)
	local secs = math.floor(s % 60)
	return mins .. ":" .. string.format("%02d", secs)
end

--- Shuffles a table using modern Fisher-Yates algorithm.
--  @param Table to shuffle
function shuffle(a)
	for i=#a, 2, -1 do
		local j = love.math.random(1, i)
		a[i], a[j] = a[j], a[i]
	end
end

--- Converts boolean value to upper case string
function boolToStr(val)
	if val then return "ON"
	else return "OFF" end
end

--- Sorts an array using bubble sort
-- @param a Array to sort
-- @param t function taking two arguments (a,b). Returns true if a > b, false otherwise.
function bubblesort(a, t)
	while true do
		swapped = false
		for i=2,#a do
			if t(a[i-1], a[i]) == true then
				local tmp = a[i-1]
				a[i-1] = a[i]
				a[i] = tmp
				swapped = true
			end
		end

		if swapped == false then return end
	end
end

--- Iterator that traverses an entire table in order
--  but starting from a random element
function offset_iter(t)
	local i = 0
	local n = #t
	local offset
	if n > 1 then
		offset = love.math.random(1, n)
	else
		offset = 0
	end
	return function ()
		i = i + 1
		if i <= n then return t[(i+offset)%n+1] end
	end
end
