--- check whether file or directory exist
---@param path string
local file_or_dir_exists = function(path)
	local file = io.open(path, "r")
	if file ~= nil then
		io.close(file)
		return true
	else
		return false
	end
end

local getPrevLevelPath = function(currentPath)
	local tmp = string.reverse(currentPath)
	local _, i = string.find(tmp, "/")
	return string.sub(currentPath, 1, string.len(currentPath) - i)
end

--- find root path of project
---@param pattern string
---@return string
local find_root_path = function(pattern)
	pattern = pattern or ".git"
	local path = vim.fn.getcwd(-1, -1) .. "/"
	local pathBp = path
	while path ~= "" do
		local file, _ = io.open(path .. pattern)
		if file ~= nil then
			return path
		else
			path = getPrevLevelPath(path)
		end
	end
	return pathBp
end

return {
	file_or_dir_exists = file_or_dir_exists,
	find_root_path = find_root_path,
}
