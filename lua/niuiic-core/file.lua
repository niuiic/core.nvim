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

local fixed_path = function(path)
	local len = string.len(path)
	if string.sub(path, len, len + 1) == "/" then
		return string.sub(path, 1, len - 1)
	end
	return path
end

--- find root path of project
---@param pattern string | nil
---@return string
local root_path = function(pattern)
	pattern = pattern or ".git"
	local path = vim.fn.getcwd(-1, -1) .. "/"
	local pathBp = path
	while path ~= "" do
		if file_or_dir_exists(path .. pattern) then
			return fixed_path(path)
		else
			path = getPrevLevelPath(path)
		end
	end
	return fixed_path(pathBp)
end

return {
	file_or_dir_exists = file_or_dir_exists,
	root_path = root_path,
}
