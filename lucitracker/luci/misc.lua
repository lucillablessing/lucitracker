function hex(n) return tonumber(n, 16) end


function hexr(...)
	local s = 0
	for i = 1, select("#", ...) do s = 16 * s + select(i, ...) end
	return s
end


function hext(t, x, y)
	y = y or x
	local s = 0
	for i = x, y do s = 16 * s + t[i] end
	return s
end


function dump(o)
	if type(o) == "table" then
		local s = "{ "
		for k, v in pairs(o) do
			if type(k) ~= "number" then k = '"' .. k .. '"' end
			s = s .. "[" .. k .. "] = " .. dump(v) .. ",\n"
		end
		return s .. "} "
	else
		return tostring(o)
	end
end