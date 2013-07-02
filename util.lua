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
