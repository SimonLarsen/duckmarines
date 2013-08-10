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

--- Returns a random element from a table
function table.random(t)
	return t[math.random(1,#t)]
end

--- Returns random number from a Gauss. dist. around 0
function math.randnorm()
	return math.random() - math.random()
end

--- Caps x in the interval [a,b]
function math.cap(x, a, b)
	return math.min(math.max(x, a), b)
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
		local j = math.random(1, i)
		a[i], a[j] = a[j], a[i]
	end
end

--- Converts boolean value to upper case string
function boolToStr(val)
	if val then return "TRUE"
	else return "FALSE" end
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
