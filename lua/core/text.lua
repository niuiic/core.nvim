local lua = require("core.lua")

--- insert text
---@param content string
---@param pos {row: number, col: number})
local insert = function(content, pos)
	local lines = lua.string.split(content, "\n")
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

--- get virtual selection or expr under the cursor
---@return string
local selection = function()
	local mode = vim.fn.mode()
	if mode == "v" then
		local start_pos = vim.fn.getpos("v")
		local finish_pos = vim.fn.getpos(".")
		local start_line, start_col = start_pos[2], start_pos[3]
		local finish_line, finish_col = finish_pos[2], finish_pos[3]

		if start_line > finish_line or (start_line == finish_line and start_col > finish_col) then
			start_line, start_col, finish_line, finish_col = finish_line, finish_col, start_line, start_col
		end

		local lines = vim.fn.getline(start_line, finish_line)
		if #lines == 0 then
			return ""
		end
		lines[#lines] = string.sub(lines[#lines], 1, finish_col)
		lines[1] = string.sub(lines[1], start_col)
		return table.concat(lines, "\n")
	else
		return vim.fn.expand("<cexpr>")
	end
end

--- get virtual selected area
---@param bufnr number
---@return {s_start: {row: number, col: number}, s_end: {row: number, col: number}}
local selected_area = function(bufnr)
	local s_start = vim.fn.getpos("'<")
	local s_end = vim.fn.getpos("'>")
	local fixed_col = function(row, col)
		local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1]
		local length = vim.fn.strdisplaywidth(line)
		if col > length then
			return length
		else
			return col
		end
	end
	return {
		s_start = { row = s_start[2], col = fixed_col(s_start[2], s_start[3]) },
		s_end = { row = s_end[2], col = fixed_col(s_end[2], s_end[3]) },
	}
end

return {
	insert = insert,
	selection = selection,
	selected_area = selected_area,
}
