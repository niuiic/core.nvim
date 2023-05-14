local uv = vim.loop

--- async job
---@param cmd string
---@param args string[]
---@param options {env?: table<string, any>, cwd?: string, uid?: number, gid?: number, verbatim?: boolean, detached?: boolean, hide?: boolean}
---@param on_exit fun(err: string, data: string)
---@param on_err fun(err: string, data: string)
---@return {terminate: fun(), running: fun(): boolean} handle
local spawn = function(cmd, args, options, on_exit, on_err)
	local stderr = uv.new_pipe()
	local stdout = uv.new_pipe()
	local job_running = true
	local handle
	local clean = function()
		if stdout then
			stdout:read_stop()
			stdout:close()
		end
		if stderr then
			stderr:read_stop()
			stderr:close()
		end
		if handle then
			handle:close()
		end
		job_running = false
	end
	local terminate = function()
		job_running = false
		if handle then
			uv.process_kill(handle, 0)
		end
		clean()
	end

	handle = uv.spawn(cmd, {
		args = args,
		stdio = { nil, stdout, stderr },
		env = options.env,
		cwd = options.cwd,
		uid = options.uid,
		gid = options.gid,
		verbatim = options.verbatim,
		detached = options.detached,
		hide = options.hide,
	}, clean)

	if stdout then
		uv.read_start(
			stdout,
			vim.schedule_wrap(function(err, data)
				if job_running then
					job_running = false
					on_exit(err, data)
				end
			end)
		)
	end
	if stderr then
		uv.read_start(
			stderr,
			vim.schedule_wrap(function(err, data)
				if job_running then
					job_running = false
					on_err(err, data)
				end
			end)
		)
	end

	return {
		terminate = terminate,
		running = function()
			return job_running
		end,
	}
end

return {
	spawn = spawn,
}
