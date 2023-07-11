local uv = vim.loop

--- call `callback` after `timeout`
---@param timeout number
---@param callback fun()
---@return uv_timer_t | nil
local set_timeout = function(timeout, callback)
	local timer = uv.new_timer()
	if not timer then
		return
	end
	timer:start(timeout, 0, function()
		timer:stop()
		timer:close()
		callback()
	end)
	return timer
end

--- call `callback` per `interval`
---@param interval number
---@param callback fun()
---@return uv_timer_t | nil
local set_interval = function(interval, callback)
	local timer = uv.new_timer()
	if not timer then
		return
	end
	timer:start(interval, interval, function()
		callback()
	end)
	return timer
end

--- clear interval task
---@param timer uv_timer_t
local clear_interval = function(timer)
	timer:stop()
	timer:close()
end

return {
	set_timeout = set_timeout,
	set_interval = set_interval,
	clear_interval = clear_interval,
}
