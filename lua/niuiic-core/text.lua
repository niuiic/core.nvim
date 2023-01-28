local common = require("niuiic-core.common")

---@param content string
---@param cursor_pos {row: number, col: number})
local insert = function(content, cursor_pos)
	local lines = common.str_split(content, "\n")
	local cur_line = vim.api.nvim_buf_get_lines(0, cursor_pos.row - 1, cursor_pos.row, false)[1]
	if #lines == 1 then
		local new_line = cur_line:sub(0, cursor_pos.col + 1) .. lines[1] .. cur_line:sub(cursor_pos.col + 2)
		vim.api.nvim_buf_set_lines(0, cursor_pos.row - 1, cursor_pos.row, false, { new_line })
	else
		local start_line = cur_line:sub(0, cursor_pos.col + 1) .. lines[1]
		local end_line = lines[#lines] .. cur_line:sub(cursor_pos.col + 2)
		lines[1] = start_line
		lines[#lines] = end_line
		vim.api.nvim_buf_set_lines(0, cursor_pos.row - 1, cursor_pos.row, false, lines)
	end
end

return {
	insert = insert,
}
