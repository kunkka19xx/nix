local M = {}

M.config = {
	default_url = "ws://127.0.0.1:8088/ws",
	binary = "websocat",
	split_width = 60,
}

local log_buf = nil
local log_win = nil

-- Find variable definitions ($VAR = VAL)
local function get_var_from_buffer(var_name)
	local buf = vim.api.nvim_get_current_buf()
	local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
	local lines = vim.api.nvim_buf_get_lines(buf, 0, row, false)
	local pattern = "%$" .. var_name .. "%s*=%s*([^%s]+)"
	for i = #lines, 1, -1 do
		local val = lines[i]:match(pattern)
		if val then
			return val:gsub('^"(.*)"$', "%1"):gsub("^'(.*)'$", "%1")
		end
	end
	return os.getenv(var_name)
end

-- Detect URL and inject variables
local function get_dynamic_url()
	local buf = vim.api.nvim_get_current_buf()
	local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
	local lines = vim.api.nvim_buf_get_lines(buf, 0, row, false)
	for i = #lines, 1, -1 do
		local url = lines[i]:match("wss?://[%w%./:%?%=%-_%$]+")
		if url then
			return url:gsub("%$([%w_]+)", function(var)
				local found = get_var_from_buffer(var)
				return found or ("$" .. var)
			end)
		end
	end
	return M.config.default_url
end

-- Manage Log Window on the right
local function get_log_window()
	if log_buf == nil or not vim.api.nvim_buf_is_valid(log_buf) then
		log_buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_name(log_buf, "WS-Log")
		vim.api.nvim_set_option_value("filetype", "json", { buf = log_buf })
	end

	local win_found = false
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == log_buf then
			log_win = win
			win_found = true
			break
		end
	end

	if not win_found then
		vim.cmd("botright vsplit")
		log_win = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_buf(log_win, log_buf)
		vim.api.nvim_win_set_width(log_win, M.config.split_width)
	end
	return log_buf, log_win
end

local function append_to_log(title, data)
	local buf, win = get_log_window()
	local time = os.date("%H:%M:%S")

	local lines = { string.format("=== [%s] %s ===", time, title) }

	if type(data) == "string" then
		for s in data:gmatch("[^\r\n]+") do
			table.insert(lines, s)
		end
	elseif type(data) == "table" then
		for _, line in ipairs(data) do
			if line ~= "" then
				table.insert(lines, line)
			end
		end
	end
	table.insert(lines, "")

	vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)

	local last_line = vim.api.nvim_buf_line_count(buf)
	vim.api.nvim_win_set_cursor(win, { last_line, 0 })
end

-- Extract JSON, ignoring the "GET" or "HTTP/1.1" text in your test file
local function find_json_object()
	local start_pos = vim.fn.searchpairpos("{", "", "}", "bnW")
	local end_pos = vim.fn.searchpairpos("{", "", "}", "nW")

	if start_pos[1] == 0 or end_pos[1] == 0 then
		-- Try current line if cursor isn't inside braces
		local line = vim.api.nvim_get_current_line()
		return line:match("{.*}")
	end

	local lines = vim.api.nvim_buf_get_lines(0, start_pos[1] - 1, end_pos[1], false)
	if #lines > 0 then
		lines[1] = lines[1]:sub(start_pos[2])
		if #lines == 1 then
			lines[1] = lines[1]:sub(1, end_pos[2] - start_pos[2] + 1)
		else
			lines[#lines] = lines[#lines]:sub(1, end_pos[2])
		end
	end
	return table.concat(lines, "\n")
end

local function execute_ws(payload)
	local url = get_dynamic_url()
	local cmd = { M.config.binary, url }

	local flat_payload = payload:gsub("[\n\r]", " "):gsub("%s+", " ")

	append_to_log("SENDING REQUEST", payload)

	local job_id = vim.fn.jobstart(cmd, {
		stdout_buffered = true,
		on_stdout = function(_, data)
			if data and #data > 0 and data[1] ~= "" then
				append_to_log("RESPONSE", data)
			end
		end,
		on_stderr = function(_, data)
			if data and #data > 0 and data[1] ~= "" then
				append_to_log("ERROR/INFO", { "ERR: " .. table.concat(data, " ") })
			end
		end,
		on_exit = function(_, code)
			if code ~= 0 then
				append_to_log("SYSTEM", { "PROCESS EXITED WITH CODE: " .. code })
			end
		end,
	})

	if job_id > 0 then
		vim.fn.chansend(job_id, flat_payload .. "\n")
		vim.fn.chanclose(job_id, "stdin")

		local display_url = url:sub(1, 35) .. (url:len() > 35 and "..." or "")
		vim.notify("Sent to: " .. display_url, vim.log.levels.INFO)
	else
		vim.notify("Binary not found: " .. M.config.binary, vim.log.levels.ERROR)
	end
end

function M.send_message()
	local json = find_json_object()
	if json then
		execute_ws(json)
	else
		vim.notify("No JSON found")
	end
end

function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
	vim.keymap.set("n", "<leader>ws", M.send_message, { desc = "WS Send" })
	vim.keymap.set("n", "<leader>wc", function()
		if log_buf then
			vim.api.nvim_buf_set_lines(log_buf, 0, -1, false, {})
		end
	end, { desc = "WS Clear Log" })
end

return M
