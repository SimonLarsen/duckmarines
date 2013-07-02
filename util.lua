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
