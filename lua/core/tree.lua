---@class core.Tree.Node
---@field label string
---@field action core.Tree.NodeAction
---@field status core.Tree.NodeStatus
---@field option core.Tree.NodeOption
---@field level number
---@field children core.Tree.Node[] | nil
---@field extend any

---@class core.Tree.NodeAction
---@field on_click fun(node: core.Tree.Node) | nil
---@field on_expand fun(node: core.Tree.Node) | nil
---@field on_fold fun(node: core.Tree.Node) | nil

---@class core.Tree.NodeStatus
---@field expanded boolean

---@class core.Tree.NodeOption
---@field hl string | nil
---@field icon string | nil
---@field icon_hl string | nil
---@field disable boolean | nil
---@field hide boolean | nil

---@class core.Tree.Line
---@field line number
---@field node core.Tree.Node

local win = require("core.win")
local lua = require("core.lua")

local expanded_icon = ""
local unexpanded_icon = ""

vim.api.nvim_set_hl(0, "TreeViewPrimary", { fg = "#6D7E96" })

---@param node core.Tree.Node
---@return boolean
local is_leaf = function(node)
	return not node.children or table.maxn(node.children) == 0
end

---@param node core.Tree.Node
---@return string
local node_text = function(node)
	local indent = ""
	for _ = 2, node.level, 1 do
		indent = indent .. "  "
	end
	if is_leaf(node) then
		return string.format("%s%s %s %s", indent, " ", node.option.icon or " ", node.label)
	else
		if node.status.expanded then
			return string.format("%s%s %s %s", indent, expanded_icon, node.option.icon or " ", node.label)
		else
			return string.format("%s%s %s %s", indent, unexpanded_icon, node.option.icon or " ", node.label)
		end
	end
end

---@param node core.Tree.Node
---@param bufnr number
---@param cur_line number
local draw_line = function(node, bufnr, cur_line)
	vim.api.nvim_buf_set_lines(bufnr, cur_line - 1, cur_line, false, { node_text(node) })

	local indent_end_col = (node.level - 1) * 2

	-- calc expand icon pos
	local expand_icon_start_col
	local expand_icon_end_col
	if not is_leaf(node) then
		expand_icon_start_col = indent_end_col
		expand_icon_end_col = expand_icon_start_col + 1
	end

	-- calc icon pos
	local icon_start_col
	local icon_end_col
	if node.option.icon ~= nil then
		icon_start_col = indent_end_col + 2
		icon_end_col = icon_start_col + string.len(node.option.icon)
	end

	-- calc label pos
	local label_start_col
	if node.option.icon ~= nil then
		label_start_col = icon_end_col + 1
	else
		label_start_col = indent_end_col + 4
	end

	if node.option.hl then
		vim.api.nvim_buf_add_highlight(bufnr, -1, node.option.hl, cur_line - 1, label_start_col, -1)
	end
	if not is_leaf(node) then
		vim.api.nvim_buf_add_highlight(
			bufnr,
			-1,
			"TreeViewPrimary",
			cur_line - 1,
			expand_icon_start_col,
			expand_icon_end_col
		)
	end
	if node.option.icon and node.option.icon_hl then
		vim.api.nvim_buf_add_highlight(bufnr, -1, node.option.icon_hl, cur_line - 1, icon_start_col, icon_end_col)
	end
end

local draw_tree_wrapper = function()
	local draw_tree
	local cur_line = 1
	---@param nodes core.Tree.Node[]
	---@param bufnr number
	---@param tree_view {lines: core.Tree.Line[]}
	draw_tree = function(nodes, bufnr, tree_view)
		for _, node in ipairs(nodes) do
			if not node.option.hide then
				draw_line(node, bufnr, cur_line)
				table.insert(tree_view.lines, {
					line = cur_line,
					node = node,
				})
				cur_line = cur_line + 1
				if not is_leaf(node) and node.status.expanded then
					draw_tree(node.children, bufnr, tree_view)
				end
			end
		end
	end
	return draw_tree
end

---@param nodes core.Tree.Node[]
---@param bufnr number
---@param tree_view {lines: core.Tree.Line[]}
local refresh_tree_view = function(nodes, bufnr, tree_view)
	tree_view.lines = {}
	vim.api.nvim_set_option_value("modifiable", true, {
		buf = bufnr,
	})
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
	draw_tree_wrapper()(nodes, bufnr, tree_view)
	vim.api.nvim_set_option_value("modifiable", false, {
		buf = bufnr,
	})
end

---@param bufnr number
---@param tree_view {lines: core.Tree.Line[]}
---@param nodes core.Tree.Node[]
local register_actions = function(nodes, bufnr, tree_view)
	vim.keymap.set("n", "l", function()
		local pos = vim.api.nvim_win_get_cursor(0)
		local target = lua.list.find(tree_view.lines, function(v)
			if v.line == pos[1] then
				return true
			end
			return false
		end)
		if target then
			if not target.node.status.expanded then
				target.node.status.expanded = true
				refresh_tree_view(nodes, bufnr, tree_view)
			end
		end
		vim.api.nvim_win_set_cursor(0, { pos[1], 0 })
		if target.node.action.on_expand then
			target.node.action.on_expand()
		end
	end, {
		buffer = bufnr,
	})

	vim.keymap.set("n", "h", function()
		local pos = vim.api.nvim_win_get_cursor(0)
		local target = lua.list.find(tree_view.lines, function(v)
			if v.line == pos[1] then
				return true
			end
			return false
		end)
		if target then
			if target.node.status.expanded then
				target.node.status.expanded = false
				refresh_tree_view(nodes, bufnr, tree_view)
			end
		end
		vim.api.nvim_win_set_cursor(0, { pos[1], 0 })
		if target.node.action.on_fold then
			target.node.action.on_fold()
		end
	end, {
		buffer = bufnr,
	})

	vim.keymap.set("n", "<CR>", function()
		local pos = vim.api.nvim_win_get_cursor(0)
		local target = lua.list.find(tree_view.lines, function(v)
			if v.line == pos[1] then
				return true
			end
			return false
		end)
		if target and not target.node.option.disable and target.node.action.on_click then
			target.node.action.on_click()
		end
	end, {
		buffer = bufnr,
	})
end

---@param nodes core.Tree.Node[]
---@param options {direction: 'vl'|'vr'|'ht'|'hb'; size: number; enter: boolean}
---@return {winnr: number, bufnr: number, tree_view: {lines : core.Tree.Line[]}}
local create_tree_view = function(nodes, options)
	-- new window
	local handle = win.split_win(0, options)
	vim.api.nvim_set_option_value("number", false, {
		win = handle.winnr,
	})
	vim.api.nvim_set_option_value("relativenumber", false, {
		win = handle.winnr,
	})
	vim.api.nvim_set_option_value("winfixwidth", true, {
		win = handle.winnr,
	})
	vim.api.nvim_set_option_value("list", false, {
		win = handle.winnr,
	})
	vim.api.nvim_set_option_value("wrap", true, {
		win = handle.winnr,
	})
	vim.api.nvim_set_option_value("linebreak", true, {
		win = handle.winnr,
	})
	vim.api.nvim_set_option_value("breakindent", true, {
		win = handle.winnr,
	})
	vim.api.nvim_set_option_value("showbreak", "      ", {
		win = handle.winnr,
	})

	-- draw tree view
	---@type {lines: core.Tree.Line[]}
	local tree_view = {
		lines = {},
	}
	draw_tree_wrapper()(nodes, handle.bufnr, tree_view)
	vim.api.nvim_set_option_value("modifiable", false, {
		buf = handle.bufnr,
	})
	register_actions(nodes, handle.bufnr, tree_view)

	return {
		winnr = handle.winnr,
		bufnr = handle.bufnr,
		tree_view = tree_view,
	}
end

return {
	create_tree_view = create_tree_view,
	refresh_tree_view = refresh_tree_view,
}
