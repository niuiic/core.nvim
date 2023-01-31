local common = require("niuiic-core.common")

--- open float window
---@param bufnr number
---@param options {enter: boolean, relative: 'editor'|'win'|'cursor'|'mouse', win?: number, anchor?: 'NW'|'NE'|'SW'|'SE', width: number, height: number, bufpos?: Array<number>, row?: number, col?: number, style?: 'minimal', border: 'none'|'single'|'double'|'rounded'|'solid'|'shadow'|Array<string>, title?: string, title_pos?: 'left'|'center'|'right', noautocmd?: boolean}
---@return {winnr: number, win_opening: fun(), close_win: fun()}
local open_float = function(bufnr, options)
	local cur_zindex = vim.api.nvim_win_get_config(0).zindex or 0
	local winnr = vim.api.nvim_open_win(bufnr, options.enter, {
		relative = options.relative,
		win = options.win,
		anchor = options.anchor,
		width = options.width,
		height = options.height,
		bufpos = options.bufpos,
		row = options.row,
		col = options.col,
		zindex = cur_zindex + 1,
		style = options.style,
		border = options.border,
		title = options.title,
		title_pos = options.title_pos,
		noautocmd = options.noautocmd,
	})

	--- check if window is opening
	---@return boolean
	local win_opening = function()
		return vim.api.nvim_win_is_valid(winnr)
	end

	--- close window
	---@param force boolean
	local close_win = function(force)
		if win_opening() then
			pcall(vim.api.nvim_win_close, winnr, force)
		end
	end

	return {
		winnr = winnr,
		win_opening = win_opening,
		close_win = close_win,
	}
end

--- get proportional size config of window
---@param width_ratio number
---@param height_ratio number
---@return {row: number, col:number, width: number, height: number}
local proportional_size = function(width_ratio, height_ratio)
	local screen_w = vim.opt.columns:get()
	local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
	local window_w = screen_w * width_ratio
	local window_h = screen_h * height_ratio
	local window_w_int = math.floor(window_w)
	local window_h_int = math.floor(window_h)
	local center_x = (screen_w - window_w) / 2
	local center_y = ((vim.opt.lines:get() - window_h) / 2) - vim.opt.cmdheight:get()
	return {
		row = center_y,
		col = center_x,
		width = window_w_int,
		height = window_h_int,
	}
end

--- open single float window
local single_float_wrapper = function()
	local handle

	---@param bufnr number
	---@param options {enter: boolean, relative: 'editor'|'win'|'cursor'|'mouse', win?: number, anchor?: 'NW'|'NE'|'SW'|'SE', width: number, height: number, bufpos?: Array<number>, row?: number, col?: number, style?: 'minimal', border: 'none'|'single'|'double'|'rounded'|'solid'|'shadow'|Array<string>, title?: string, title_pos?: 'left'|'center'|'right', noautocmd?: boolean}
	---@return {winnr: number, win_opening: fun(), close_win: fun()}
	return function(bufnr, options)
		if handle ~= nil and handle.win_opening() == true then
			handle.close_win(true)
		end
		handle = open_float(bufnr, options)
		return handle
	end
end

--- open float window and insert text
---@param text string
---@param options {max_height?: number, max_width?: number, enter: boolean, relative: 'editor'|'win'|'cursor'|'mouse', win?: number, anchor?: 'NW'|'NE'|'SW'|'SE', bufpos?: Array<number>, row?: number, col?: number, style?: 'minimal', border: 'none'|'single'|'double'|'rounded'|'solid'|'shadow'|Array<string>, title?: string, title_pos?: 'left'|'center'|'right', noautocmd?: boolean}
---@return {bufnr: number, winnr: number, win_opening: fun(), close_win: fun()}
local open_float_with_text = function(text, options)
	local screen_w = vim.opt.columns:get()
	local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
	options.max_height = options.max_height or screen_h
	options.max_width = options.max_width or screen_w
	text = common.str_split(text, "\n")
	local height = 0
	local width = 0
	for _, line in ipairs(text) do
		local str_len = vim.fn.strdisplaywidth(line)
		if str_len <= options.max_width then
			height = height + 1
			if width < str_len then
				width = str_len
			end
		else
			width = options.max_width
			height = height + math.ceil(str_len / options.max_width)
		end
	end
	if height > options.max_height then
		height = options.max_height
	end
	local bufnr = vim.api.nvim_create_buf(false, true)
	local handle = open_float(bufnr, {
		height = height or screen_h,
		width = width or screen_w,
		enter = options.enter,
		relative = options.relative,
		win = options.win,
		anchor = options.anchor,
		bufpos = options.bufpos,
		row = options.row,
		col = options.col,
		style = options.style,
		border = options.border,
		title = options.title,
		title_pos = options.title_pos,
		noautocmd = options.noautocmd,
	})
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, text)
	return {
		bufnr = bufnr,
		winnr = handle.winnr,
		win_opening = handle.win_opening,
		close_win = handle.close_win,
	}
end

return {
	open_float = open_float,
	proportional_size = proportional_size,
	single_float_wrapper = single_float_wrapper,
	open_float_with_text = open_float_with_text,
}
