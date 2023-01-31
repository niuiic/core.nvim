local core = require("niuiic-core.test")

for _, value in ipairs(core) do
	vim.api.nvim_create_user_command("Core" .. value[1], function()
		value[2]()
	end, value[3] or {})
end
