--- split string
---@param str string
---@param sep string
---@return string[]
local string_split = function(str, sep)
	local chunks = {}
	local index = 1
	local len = string.len(str)
	while index <= len do
		local head, tail = string.find(str, sep, index, true)
		if not head or not tail then
			table.insert(chunks, string.sub(str, index))
			return chunks
		end
		if index == head then
			table.insert(chunks, "")
		else
			table.insert(chunks, string.sub(str, index, head - 1))
		end
		index = tail + 1
	end
	return chunks
end

--- map list
---@param list any[]
---@param map fun(v: any, i: number): any
---@return any[]
local list_map = function(list, map)
	local new_list = {}
	for index, value in ipairs(list) do
		table.insert(new_list, map(value, index))
	end
	return new_list
end

--- filter list
---@param list any[]
---@param filter fun(v: any, i: number): boolean
---@return any[]
local list_filter = function(list, filter)
	local new_list = {}
	for index, value in ipairs(list) do
		if filter(value, index) then
			table.insert(new_list, value)
		end
	end
	return new_list
end

--- sort list
---@param list any[]
---@param to_swap fun(prev: any, cur: any): boolean
---@return any[]
local list_sort = function(list, to_swap)
	local new_list = {}
	for _, value in ipairs(list) do
		for i, v in ipairs(new_list) do
			if to_swap(v, value) then
				table.insert(new_list, i, value)
				goto continue
			end
		end
		table.insert(new_list, value)
		::continue::
	end
	return new_list
end

--- whether list includes value
---@param list any[]
---@param is_target fun(v: any, i: number): boolean
---@return boolean
local list_includes = function(list, is_target)
	for index, value in ipairs(list) do
		if is_target(value, index) then
			return true
		end
	end
	return false
end

--- find item in list
---@param list any[]
---@param is_target fun(v: any, i:number): boolean
---@return any | nil
local list_find = function(list, is_target)
	for index, value in ipairs(list) do
		if is_target(value, index) then
			return value
		end
	end
	return nil
end

--- list reduce
---@param list any[]
---@param cb fun(prev_res: any, cur_item: any, list: any[]): any
---@param initial_res any
local list_reduce = function(list, cb, initial_res)
	local res = initial_res
	for _, value in ipairs(list) do
		res = cb(res, value, list)
	end
	return res
end

--- list for each
---@param list any[]
---@param cb fun(v: any, i: number): nil
local list_each = function(list, cb)
	for i, v in ipairs(list) do
		cb(v, i)
	end
end

--- merge list, list2 will overwrite list1
---@param list1 any[]
---@param list2 any[]
local list_merge = function(list1, list2)
	local res = {}
	for _, value in pairs(list1) do
		if list_includes(list2, function(v)
			return v == value
		end) ~= true then
			table.insert(res, value)
		end
	end
	for _, value in pairs(list2) do
		table.insert(res, value)
	end
	return res
end

--- deep clone table
local table_clone
---@param table object
---@return object
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

--- table for each
---@param table object
---@param cb fun(k: string, v: any): nil
local table_each = function(table, cb)
	for k, v in pairs(table) do
		cb(k, v)
	end
end

--- table map
---@param table object
---@param map fun(v: any): any
---@return object
local table_map = function(table, map)
	local res = {}
	for k, v in pairs(table) do
		res[k] = map(v)
	end
	return res
end

--- table reduce
---@param table object
---@param cb fun(prev_res: any, cur_item: {k: string, v: any}, table: any): any
---@param initial_res any
---@return any
local table_reduce = function(table, cb, initial_res)
	local res = initial_res
	for k, v in pairs(table) do
		res = cb(res, { k = k, v = v }, table)
	end
	return res
end

--- table keys
---@param t object
---@return string[]
local table_keys = function(t)
	local keys = {}
	for key, _ in pairs(t) do
		table.insert(keys, key)
	end
	return keys
end

---@class core.Lua.Node
---@field children core.Lua.Node[] | nil

--- table walk
local tree_walk
---@param nodes core.Lua.Node[]
---@param cb fun(node: core.Lua.Node, parent_node: core.Lua.Node | nil)
---@param parent_node core.Lua.Node
tree_walk = function(nodes, cb, parent_node)
	for _, node in ipairs(nodes) do
		cb(node, parent_node)
		if node.children then
			for _, child in pairs(node.children) do
				tree_walk(child, cb, node)
			end
		end
	end
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
		find = list_find,
		sort = list_sort,
		each = list_each,
	},
	table = {
		clone = table_clone,
		each = table_each,
		map = table_map,
		reduce = table_reduce,
		keys = table_keys,
	},
	tree = {
		walk = tree_walk,
	},
}
