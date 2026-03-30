local M = {}

-- Compatibility for Lua versions (5.1/LuaJIT/5.4)
local unpack = table.unpack or unpack

M.config = {
    default_url = "ws://127.0.0.1:8088/ws",
    binary = "websocat",
    split_width = 60,
}

local log_buf = nil
local log_win = nil

-- Scan upwards from a specific line to find $VAR = VAL
local function get_var_from_buffer(var_name, search_start_row)
    local buf = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, search_start_row, false)

    local escaped_var = vim.pesc(var_name)
    -- Pattern allows for optional quotes around the value in the definition
    local pattern = "%$" .. escaped_var .. "%s*=%s*([^%s]+)"

    for i = #lines, 1, -1 do
        local val = lines[i]:match(pattern)
        if val then
            -- Strip quotes from the definition if they exist
            return val:gsub('^"(.*)"$', "%1"):gsub("^'(.*)'$", "%1")
        end
    end
    return os.getenv(var_name)
end

-- Replaces "`$VAR`" occurrences with values found above the anchor
local function inject_variables(text, search_start_row)
    if not text then
        return text
    end
    -- Pattern allows alphanumeric, underscore, and hyphen in var names
    return text:gsub("`%$([%w_%-]+)`", function(var)
        local found = get_var_from_buffer(var, search_start_row)
        -- Return found value or keep original tag if missing
        return found or ("`$" .. var .. "`")
    end)
end

-- Detect nearest URL above JSON block and inject variables
local function get_dynamic_url(search_start_row)
    local buf = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, search_start_row, false)
    for i = #lines, 1, -1 do
        local url = lines[i]:match("wss?://[%w%./:%?%=%-_%$]+")
        if url then
            -- For URLs, we support standard $VAR (no backticks needed)
            local expanded = url:gsub("%$([%w_]+)", function(var)
                return get_var_from_buffer(var, search_start_row) or ("$" .. var)
            end)
            return inject_variables(expanded, search_start_row)
        end
    end
    return M.config.default_url
end

-- Manage Log Window
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

-- Append to log and auto-scroll
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
    if win and vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_set_cursor(win, { last_line, 0 })
    end
end

-- Find the outermost JSON object and its starting line
local function find_json_info()
    local original_cursor = vim.api.nvim_win_get_cursor(0)
    local start_pos = vim.fn.searchpairpos("{", "", "}", "bnW")
    if start_pos[1] == 0 then
        return nil
    end

    local last_start = start_pos
    while true do
        vim.api.nvim_win_set_cursor(0, { last_start[1], last_start[2] - 1 })
        local parent_start = vim.fn.searchpairpos("{", "", "}", "bnW")
        if parent_start[1] > 0 then
            local parent_end = vim.fn.searchpairpos("{", "", "}", "nW")
            if parent_end[1] >= original_cursor[1] then
                last_start = parent_start
            else
                break
            end
        else
            break
        end
    end

    vim.api.nvim_win_set_cursor(0, { last_start[1], last_start[2] - 1 })
    local final_end = vim.fn.searchpairpos("{", "", "}", "nW")
    vim.api.nvim_win_set_cursor(0, original_cursor)

    local lines = vim.api.nvim_buf_get_lines(0, last_start[1] - 1, final_end[1], false)
    if #lines > 0 then
        lines[1] = lines[1]:sub(last_start[2])
        if #lines == 1 then
            lines[1] = lines[1]:sub(1, final_end[2] - last_start[2] + 1)
        else
            lines[#lines] = lines[#lines]:sub(1, final_end[2])
        end
    end

    return {
        payload = table.concat(lines, "\n"),
        start_row = last_start[1],
    }
end

-- Execute
local function execute_ws(json_info)
    local search_anchor = json_info.start_row
    local url = get_dynamic_url(search_anchor)
    local cmd = { M.config.binary, url }

    local injected_payload = inject_variables(json_info.payload, search_anchor)
    local flat_payload = injected_payload:gsub("[\n\r]", " "):gsub("%s+", " ")

    append_to_log("SENDING REQUEST", injected_payload)

    local job_id = vim.fn.jobstart(cmd, {
        stdout_buffered = true,
        on_stdout = function(_, data)
            if data and #data > 0 and data[1] ~= "" then
                append_to_log("RESPONSE", data)
            end
        end,
        on_stderr = function(_, data)
            if data and #data > 0 and data[1] ~= "" then
                append_to_log("ERROR/INFO", data)
            end
        end,
        on_exit = function(_, code)
            if code ~= 0 then
                append_to_log("SYSTEM", { "Process exited with code: " .. code })
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
    local json_info = find_json_info()
    if json_info then
        execute_ws(json_info)
    else
        vim.notify("No JSON found around cursor")
    end
end

function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})
    vim.keymap.set("n", "<leader>ws", M.send_message, { desc = "WebSocket: Send Message" })
    vim.keymap.set("n", "<leader>wc", function()
        if log_buf then
            vim.api.nvim_buf_set_lines(log_buf, 0, -1, false, {})
            vim.notify("WS Log Cleared")
        end
    end, { desc = "WebSocket: Clear Log" })
end

return M


-- sample of a ws test file


--[[ ### WebSocket test with token


# URL ws://127.0.0.1:8088/ws
$TOKEN=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIwOGEwODdkOS1iY2FlLTQ3OWYtYjEwMS00ZWZmMGJhNzU0OWIiLCJpYXQiOjE3NzM2NjY3OTEsImV4cCI6MTc3NDI3MTU5MX0.n0qbJ06aV2mLiYxT6vuIfIZQmY7ULcH13Uyecev7uKM

$CON_ID=d2f27884-e1ad-4183-a78b-e9f120af9bfc

### Search user
# URL ws://127.0.0.1:8088/ws?token=$TOKEN
### Create conversation with user (by phone)
{"type": "create_conversation", "payload": {"with_user": "+1234567890"}}

### Get all conversations
{"type": "get_conversations"}

### Get single conversation
{"type": "get_conversation", "payload": {"conversation_id": "`$CON_ID`"}}
 ]]
