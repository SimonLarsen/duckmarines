Coroutines = {}
Coroutines.__index = Coroutines

local routines = {}

function Coroutines.start(f)
	local co = coroutine.create(f)
	table.insert(routines, co)
end

function Coroutines.update(dt)
	for i=#routines, 1, -1 do
		if coroutine.update(routines[i], dt) == false then
			table.remove(routines, i)
		end
	end
end

function Coroutines.clear()
	routines = {}
end
