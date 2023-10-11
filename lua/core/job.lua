local uv = vim.loop

--- async job
---@param cmd string
---@param args string[]
---@param options {env?: table<string, any>, cwd?: string, uid?: number, gid?: number, verbatim?: boolean, detached?: boolean, hide?: boolean}
---@param on_exit fun(code: integer, signal: integer) | nil
---@param on_err fun(err: string, data: string) | nil
---@param on_output fun(err: string, data: string) | nil
---@return {terminate: fun(), stdin: uv_pipe_t, running: fun(): boolean}
local spawn = function(cmd, args, options, on_exit, on_err, on_output)
	local stdin = uv.new_pipe()
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
		if handle then
			uv.process_kill(handle, 0)
		end
		clean()
	end

	handle = uv.spawn(
		cmd,
		{
			args = args,
			stdio = { stdin, stdout, stderr },
			env = options.env,
			cwd = options.cwd,
			uid = options.uid,
			gid = options.gid,
			verbatim = options.verbatim,
			detached = options.detached,
			hide = options.hide,
		},
		vim.schedule_wrap(function(code, signal)
			clean()
			if on_exit then
				on_exit(code, signal)
			end
		end)
	)

	if stdout then
		uv.read_start(
			stdout,
			vim.schedule_wrap(function(err, data)
				if data and on_output then
					on_output(err, data)
				end
			end)
		)
	end
	if stderr then
		uv.read_start(
			stderr,
			vim.schedule_wrap(function(err, data)
				if data and on_err then
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
		stdin = stdin,
	}
end

return {
	spawn = spawn,
}
