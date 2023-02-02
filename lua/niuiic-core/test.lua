local M = {}
local job = require("niuiic-core.job")
local text = require("niuiic-core.text")
local win = require("niuiic-core.win")

table.insert(M, {
	"Job",
	function()
		local on_exit = function(err, data)
			print("exit", err, data)
		end
		local on_err = function(err, data)
			print("err", err, data)
		end

		local handle = job.spawn("rg", { "test" }, {}, on_exit, on_err)
		print("running", handle.running())
		handle.terminate()
		print("running", handle.running())
		job.spawn("rg", { "test" }, {}, on_exit, on_err)
	end,
})

table.insert(M, {
	"TextInsert",
	function()
		local cursor_pos = vim.api.nvim_win_get_cursor(0)
		text.insert("test", {
			row = cursor_pos[1],
			col = cursor_pos[2],
		})
		text.insert("test\ntest\n", {
			row = cursor_pos[1],
			col = cursor_pos[2],
		})
	end,
})

table.insert(M, {
	"TextSelection",
	function()
		print(vim.inspect(text.selection()))
	end,
	{ range = 0 },
})

table.insert(M, {
	"TextSelectArea",
	function()
		print(vim.inspect(text.selected_area(0)))
	end,
	{ range = 0 },
})

table.insert(M, {
	"WinOpenFloat",
	function()
		win.open_float(0, {
			enter = true,
			relative = "cursor",
			width = 20,
			height = 20,
			row = 10,
			col = 10,
			style = "minimal",
			border = "single",
			title = "title",
			title_pos = "left",
		})
	end,
})

table.insert(M, {
	"WinSingleFloat",
	function()
		local single_float = win.single_float_wrapper()
		for _ = 1, 3 do
			single_float(0, {
				enter = true,
				relative = "cursor",
				width = 20,
				height = 20,
				row = 10,
				col = 10,
				style = "minimal",
				border = "single",
				title = "title",
				title_pos = "left",
			})
		end
	end,
})

table.insert(M, {
	"WinOpenFloatWithText",
	function()
		win.open_float_with_text("hello\nhello2\nhello3", {
			enter = false,
			relative = "cursor",
			row = 10,
			col = 10,
			max_height = 20,
			max_width = 2,
			style = "minimal",
			border = "single",
			title = "title",
			title_pos = "left",
		})
	end,
})

return M
