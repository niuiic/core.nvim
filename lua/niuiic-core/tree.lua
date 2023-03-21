---@class TreeNode
---@field label string
---@field action NodeAction
---@field status NodeStatus
---@field option NodeOption
---@field level number
---@field children TreeNode[] | nil

---@class NodeAction
---@field on_click fun(node: TreeNode) | nil
---@field on_expand fun(node: TreeNode) | nil
---@field on_fold fun(node: TreeNode) | nil
---@field on_hover fun(node: TreeNode) | nil

---@class NodeStatus
---@field expanded boolean
---@field is_leaf boolean

---@class NodeOption
---@field color string | nil
---@field icon string | nil
---@field disable boolean | nil
---@field hide boolean | nil

---@class TreeViewLine
---@field line number
---@field node TreeNode

local win = require("niuiic-core.win")
local lua = require("niuiic-core.lua")

local expanded_icon = ""
local unexpanded_icon = ""

---@param node TreeNode
---@return string
local node_text = function(node)
	local indent = ""
	for _ = 2, node.level, 1 do
		indent = indent .. "  "
	end
	if node.status.is_leaf then
		return string.format("%s%s %s", indent .. "  ", node.option.icon or "", node.label)
	else
		if node.status.expanded then
			return string.format("%s%s %s %s", indent, expanded_icon, node.option.icon or "", node.label)
		else
			return string.format("%s%s %s %s", indent, unexpanded_icon, node.option.icon or "", node.label)
		end
	end
end

---@param node TreeNode
---@param bufnr number
---@param cur_line number
local draw_line = function(node, bufnr, cur_line)
	vim.api.nvim_buf_set_lines(bufnr, cur_line - 1, cur_line, false, { node_text(node) })
end

local draw_tree
local cur_line = 1
---@param nodes TreeNode[]
---@param bufnr number
---@param tree_view TreeViewLine[]
draw_tree = function(nodes, bufnr, tree_view)
	for _, node in ipairs(nodes) do
		draw_line(node, bufnr, cur_line)
		table.insert(tree_view, {
			line = cur_line,
			node = node,
		})
		cur_line = cur_line + 1
		if node.status.expanded and not node.status.is_leaf then
			draw_tree(node.children, bufnr, tree_view)
		end
	end
end

---@param nodes TreeNode[]
---@param bufnr number
---@param tree_view TreeViewLine[]
local refresh_tree_view = function(nodes, bufnr, tree_view)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
	cur_line = 1
	draw_tree(nodes, bufnr, tree_view)
end

---@param bufnr number
---@param tree_view TreeViewLine[]
---@param nodes TreeNode[]
local register_actions = function(nodes, bufnr, tree_view)
	local ns_id = vim.api.nvim_create_namespace("tree_view")
	vim.on_key(function(key)
		if not vim.api.nvim_win_get_buf(0) == bufnr then
			return
		end
		local pos = vim.api.nvim_win_get_cursor(0)
		if key == "l" then
			local target = lua.list.find(tree_view, function(v)
				if v.line == pos[1] then
					return true
				end
				return false
			end)
			if target then
				if not target.node.status.expanded then
					target.node.status.expanded = true
					refresh_tree_view(nodes, bufnr, tree_view)
					vim.api.nvim_win_set_cursor(0, pos)
				end
			end
		elseif key == "h" then
			local target = lua.list.find(tree_view, function(v)
				if v.line == pos[1] then
					return true
				end
				return false
			end)
			if target then
				if target.node.status.expanded then
					target.node.status.expanded = false
					refresh_tree_view(nodes, bufnr, tree_view)
					vim.api.nvim_win_set_cursor(0, pos)
				end
			end
		end
	end, ns_id)
end

---@param nodes TreeNode[]
---@param options {direction: 'v' | 'h'; size: number; enter: boolean}
local create_tree_view = function(nodes, options)
	-- open window
	local handle = win.split_win(0, options)
	vim.api.nvim_buf_set_option(handle.bufnr, "filetype", "tree-view")
	vim.api.nvim_win_set_option(handle.winnr, "number", false)
	vim.api.nvim_win_set_option(handle.winnr, "relativenumber", false)

	--- @type TreeViewLine[]
	local tree_view = {}
	draw_tree(nodes, handle.bufnr, tree_view)

	register_actions(nodes, handle.bufnr, tree_view)
end

return {
	create_tree_view = create_tree_view,
    }
