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
	if vim.fn.mode() == "v" then
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
---@return {s_start: {row: number, col: number}, s_end: {row: number, col: number}} | nil
local selected_area = function()
	if vim.fn.mode() == "v" then
		local start_pos = vim.fn.getpos("v")
		local finish_pos = vim.fn.getpos(".")
		local s_start = { row = start_pos[2], col = start_pos[3] }
		local s_end = { row = finish_pos[2], col = finish_pos[3] }

		if s_start.row > s_end.row then
			return {
				s_start = s_end,
				s_end = s_start,
			}
		elseif s_start.row == s_end.row and s_start.col > s_end.col then
			return {
				s_start = s_end,
				s_end = s_start,
			}
		else
			return {
				s_start = s_start,
				s_end = s_end,
			}
		end
	else
		return nil
	end
end

local cancel_selection = function()
	local esc = vim.api.nvim_replace_termcodes("<esc>", true, false, true)
	vim.api.nvim_feedkeys(esc, "x", false)
end

return {
	insert = insert,
	selection = selection,
	selected_area = selected_area,
	cancel_selection = cancel_selection,
}
