local common = require("niuiic-core.common")

--- insert text
---@param content string
---@param pos {row: number, col: number})
local insert = function(content, pos)
	local lines = common.str_split(content, "\n")
	local cur_line = vim.api.nvim_buf_get_lines(0, pos.row - 1, pos.row, false)[1]
	if #lines == 1 then
		local new_line = cur_line:sub(0, pos.col + 1) .. lines[1] .. cur_line:sub(pos.col + 2)
		vim.api.nvim_buf_set_lines(0, pos.row - 1, pos.row, false, { new_line })
	else
		local start_line = cur_line:sub(0, pos.col + 1) .. lines[1]
		local end_line = lines[#lines] .. cur_line:sub(pos.col + 2)
		lines[1] = start_line
		lines[#lines] = end_line
		vim.api.nvim_buf_set_lines(0, pos.row - 1, pos.row, false, lines)
	end
end

--- get virtual selection
---@return Array<string>
local selection = function()
	local s_start = vim.fn.getpos("'<")
	local s_end = vim.fn.getpos("'>")
	local n_lines = math.abs(s_end[2] - s_start[2]) + 1
	local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
	lines[1] = string.sub(lines[1], s_start[3], -1)
	if n_lines == 1 then
		lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
	else
		lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
	end
	return lines
end

return {
	insert = insert,
	selection = selection,
}
