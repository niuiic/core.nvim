---@param content string
---@param cursor_pos {row: number, col: number})
local insert = function(content, cursor_pos)
	if string.find(content, "\n") ~= nil then
		vim.notify([[content shouldn't contain \n]], vim.log.levels.ERROR, {
			title = "Text Insert",
		})
		return
	end
	local line = vim.api.nvim_buf_get_lines(0, cursor_pos.row - 1, cursor_pos.row, false)[1]
	local new_line = line:sub(0, cursor_pos.col + 1) .. content .. line:sub(cursor_pos.col + 2)
	vim.api.nvim_buf_set_lines(0, cursor_pos.row - 1, cursor_pos.row, false, { new_line })
end

return {
	insert = insert,
}
