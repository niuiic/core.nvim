--- split string
---@param str string
---@param sep string
---@return Array<string>
local string_split = function(str, sep)
	local res = {}
	for s in string.gmatch(str, "[^" .. sep .. "]+") do
		table.insert(res, s)
	end
	return res
end

--- map list
---@param list any[]
---@param map fun(v: any): any
---@return any[]
local list_map = function(list, map)
	local new_list = {}
	for _, value in ipairs(list) do
		table.insert(new_list, map(value))
	end
	return new_list
end

--- filter list
---@param list any[]
---@param filter fun(v: any): boolean
---@return any[]
local list_filter = function(list, filter)
	local new_list = {}
	for _, value in ipairs(list) do
		if filter(value) then
			table.insert(new_list, value)
		end
	end
	return new_list
end

--- whether list includes value
---@param list any[]
---@param is_target fun(v: any): boolean
local list_includes = function(list, is_target)
	for _, value in ipairs(list) do
		if is_target(value) then
			return true
		end
	end
	return false
end

--- list reduce
---@param list any[]
---@param exec fun(prev_res: any, cur_item: any, list: any[]): any
---@param initial_res any
local list_reduce = function(list, exec, initial_res)
	local res = initial_res
	for _, value in ipairs(list) do
		res = exec(res, value, list)
	end
	return res
end

--- merge list, list2 will overwrite list1
---@param list1 any[]
---@param list2 any[]
local list_merge = function(list1, list2)
	local res = {}
	for _, value in pairs(list2) do
		table.insert(res, value)
	end
	for _, value in pairs(list1) do
		if list_includes(list2, function(v)
			return v == value
		end) ~= true then
			table.insert(res, value)
		end
	end
	return res
end

--- deep clone table
local table_clone
---@param table any
---@return any
table_clone = function(table)
	local res = {}
	if type(table) == "table" then
		for k, v in next, table, nil do
			res[table_clone(k)] = table_clone(v)
		end
		setmetatable(res, table_clone(getmetatable(table)))
	else
		res = table
	end
	return res
end

return {
	string = {
		split = string_split,
	},
	list = {
		map = list_map,
		filter = list_filter,
		includes = list_includes,
		reduce = list_reduce,
		merge = list_merge,
	},
	table = {
		clone = table_clone,
	},
}
