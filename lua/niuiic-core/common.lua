--- split string
---@param str string
---@param sep string
---@return Array<string>
local str_split = function(str, sep)
	local res = {}
	for s in string.gmatch(str, "[^" .. sep .. "]+") do
		table.insert(res, s)
	end
	return res
end

return {
	str_split = str_split,
}
