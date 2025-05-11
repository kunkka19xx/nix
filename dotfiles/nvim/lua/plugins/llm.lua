-- return {
-- 	"David-Kunz/gen.nvim",
-- 	opts = {
-- 		model = "gemma3:4b", -- The default model to use.
-- 		quit_map = "q", -- set keymap to close the response window
-- 		retry_map = "<c-r>", -- set keymap to re-send the current prompt
-- 		accept_map = "<c-cr>", -- set keymap to replace the previous selection with the last result
-- 		host = "localhost", -- The host running the Ollama service.
-- 		port = "11434", -- The port on which the Ollama service is listening.
-- 		display_mode = "float", -- The display mode. Can be "float" or "split" or "horizontal-split".
-- 		show_prompt = false, -- Shows the prompt submitted to Ollama. Can be true (3 lines) or "full".
-- 		show_model = false, -- Displays which model you are using at the beginning of your chat session.
-- 		no_auto_close = false, -- Never closes the window automatically.
-- 		file = false, -- Write the payload to a temporary file to keep the command short.
-- 		hidden = false, -- Hide the generation window (if true, will implicitly set `prompt.replace = true`), requires Neovim >= 0.10
-- 		init = function(options)
-- 			pcall(io.popen, "ollama serve > /dev/null 2>&1 &")
-- 		end,
-- 		-- Function to initialize Ollama
-- 		command = function(options)
-- 			local body = { model = options.model, stream = true }
-- 			return "curl --silent --no-buffer -X POST http://"
-- 				.. options.host
-- 				.. ":"
-- 				.. options.port
-- 				.. "/api/chat -d $body"
-- 		end,
-- 		-- The command for the Ollama service. You can use placeholders $prompt, $model and $body (shellescaped).
-- 		-- This can also be a command string.
-- 		-- The executed command must return a JSON object with { response, context }
-- 		-- (context property is optional).
-- 		-- list_models = '<omitted lua function>', -- Retrieves a list of model names
-- 		result_filetype = "markdown", -- Configure filetype of the result buffer
-- 		debug = false, -- Prints errors and the command which is run.
-- 	},
-- }
--
--[[ return {
    "huggingface/llm.nvim",
    opts = {
        backend = "ollama",
        model = "gemma3:4b",
        url = "http://localhost:11434/api/generate", -- llm-ls uses "/api/generate"
        -- cf https://github.com/ollama/ollama/blob/main/docs/api.md#parameters
        fim = {
            enabled = true,
            prefix = "<fim_prefix>",
            middle = "<fim_middle>",
            suffix = "<fim_suffix>",
        },
        debounce_ms = 50,
        accept_keymap = "<Tab>",
        dismiss_keymap = "<S-Tab>",
        -- llm-ls configuration, cf llm-ls section
        lsp = {
            bin_path = vim.api.nvim_call_function("stdpath", { "data" }) .. "/mason/bin/llm-ls",
        },
        request_body = {
            parameters = {
                max_new_tokens = 100,
                temperature = 0.2,
                top_p = 0.95,
            },
        },
        context_window = 256,          -- max number of tokens for the context window
        enable_suggestions_on_startup = true,
        enable_suggestions_on_files = "*", -- pattern matching syntax to enable suggestions on specific files, either a string or a list of strings
        disable_url_path_completion = false, -- cf Backend
    },
} ]]

return {
	"robitx/gp.nvim",
	name = "gp",
	event = "BufEnter",
	dependencies = {
		"folke/which-key.nvim",
	},
	config = function()
		require("gp").setup({
			openai_api_key = os.getenv("OPENAI_API_KEY"),
			providers = {
				copilot = {
					endpoint = "https://api.githubcopilot.com/chat/completions",
					secret = {
						"bash",
						"-c",
						"cat ~/.config/github-copilot/hosts.json | sed -e 's/.*oauth_token...//;s/\".*//'",
					},
				},
				ollama = {
					endpoint = "http://localhost:11434/v1/chat/completions",
				},
			},
			whisper = {
				-- you can disable whisper completely by whisper = {disable = true}
				disable = false,

				-- OpenAI audio/transcriptions api endpoint to transcribe audio to text
				endpoint = "https://api.openai.com/v1/audio/transcriptions",
				-- directory for storing whisper files
				store_dir = (os.getenv("TMPDIR") or os.getenv("TEMP") or "/tmp") .. "/gp_whisper",
				-- multiplier of RMS level dB for threshold used by sox to detect silence vs speech
				-- decibels are negative, the recording is normalized to -3dB =>
				-- increase this number to pick up more (weaker) sounds as possible speech
				-- decrease this number to pick up only louder sounds as possible speech
				-- you can disable silence trimming by setting this a very high number (like 1000.0)
				silence = "1.75",
				-- whisper tempo (1.0 is normal speed)
				tempo = "1.75",
				-- The language of the input audio, in ISO-639-1 format.
				language = "en",
				-- command to use for recording can be nil (unset) for automatic selection
				-- string ("sox", "arecord", "ffmpeg") or table with command and arguments:
				-- sox is the most universal, but can have start/end cropping issues caused by latency
				-- arecord is linux only, but has no cropping issues and is faster
				-- ffmpeg in the default configuration is macos only, but can be used on any platform
				-- (see https://trac.ffmpeg.org/wiki/Capture/Desktop for more info)
				-- below is the default configuration for all three commands:
				-- whisper_rec_cmd = {"sox", "-c", "1", "--buffer", "32", "-d", "rec.wav", "trim", "0", "60:00"},
				-- whisper_rec_cmd = {"arecord", "-c", "1", "-f", "S16_LE", "-r", "48000", "-d", "3600", "rec.wav"},
				-- whisper_rec_cmd = {"ffmpeg", "-y", "-f", "avfoundation", "-i", ":0", "-t", "3600", "rec.wav"},
				rec_cmd = nil,
			},
			agents = {
				{
					name = "Miku Ohashi",
					chat = true,
					command = true,
					provider = "ollama",
					model = { model = "gemma3:4b" },
					system_prompt = "I am an AI meticulously crafted to provide programming guidance and code assistance. "
						.. "To best serve you as a computer programmer, please provide detailed inquiries and code snippets when necessary, "
						.. "and expect precise, technical responses tailored to your development needs.\n",
				},
				{
					name = "Maria Ozawa",
					chat = true,
					command = true,
					provider = "ollama",
					model = { model = "qwen2.5-coder:3b" },
					system_prompt = "I am an AI meticulously crafted to provide programming guidance and code assistance. "
						.. "To best serve you as a computer programmer, please provide detailed inquiries and code snippets when necessary, "
						.. "and expect precise, technical responses tailored to your development needs.\n",
				},
			},
			hooks = {
				-- example of usig enew as a function specifying type for the new buffer
				CodeReview = function(gp, params)
					local template = "I have the following code from {{filename}}:\n\n"
						.. "```{{filetype}}\n{{selection}}\n```\n\n"
						.. "Please analyze for code smells and suggest improvements."
					local agent = gp.get_chat_agent()
					gp.Prompt(params, gp.Target.enew("markdown"), agent, template)
				end,
				-- example of making :%GpChatNew a dedicated command which
				-- opens new chat with the entire current buffer as a context
				BufferChatNew = function(gp, _)
					-- call GpChatNew command in range mode on whole buffer
					vim.api.nvim_command("%" .. gp.config.cmd_prefix .. "ChatNew")
				end,
				ReactIconSvg = function(gp, params)
					local buf = vim.api.nvim_get_current_buf()
					local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
					local content = table.concat(lines, "\n")
					local template = "The following SVG code needs to be converted into a valid React component:\n\n"
						.. "INPUT:\n"
						.. "```tsx\n"
						.. content
						.. "```\n\n"
						.. "  - Remove the `width` and `height` props from the `<svg>` element\n"
						.. "  - Add `{...props}` to the bottom of the `<svg>` element\n"
						.. "  - Replace all `fill` values with `currentColor`\n"
						.. "  - Replace all props that are dash-separated (ex: `fill-rule`) with camelCase (ex: `fillRule`)\n"
						.. "  - Don't remove any other props or attributes\n"
						.. "  - Preserve the indentation rules\n"
						.. "  - Only include the code snippet, no additional context or explanation is needed."
					local agent = gp.get_command_agent()
					gp.logger.info("Updating React SVG: " .. agent.name)
					gp.Prompt(params, gp.Target.rewrite, agent, template, nil)
				end,
				UiIconExport = function(gp, params)
					local template = "The following React modules need to be refactored and properly exported:\n\n"
						.. "```tsx\n{{selection}}\n```\n\n"
						.. "  - Take the unused import at the bottom of the file and move it up to the other imports in the alphabetical orrder\n"
						.. "  - Export the unsed import in the `icons` array in alphabetical order\n"
						.. "  - Export the unsed import in the `export {` object in alphabetical order\n"
						.. "  - Only include the code snippet, no additional context or explanation is needed."
					local agent = gp.get_command_agent()
					gp.logger.info("Updating React SVG: " .. agent.name)
					gp.Prompt(params, gp.Target.rewrite, agent, template, nil)
				end,
			},
		})
	end,

	keys = function()
		require("which-key").add({
			-- VISUAL mode mappings
			-- s, x, v modes are handled the same way by which_key
			{
				mode = { "v" },
				nowait = true,
				remap = false,
				{ "<C-g><C-t>", ":<C-u>'<,'>GpChatNew tabnew<cr>", desc = "ChatNew tabnew", icon = "󰗋" },
				{ "<C-g><C-v>", ":<C-u>'<,'>GpChatNew vsplit<cr>", desc = "ChatNew vsplit", icon = "󰗋" },
				{ "<C-g><C-x>", ":<C-u>'<,'>GpChatNew split<cr>", desc = "ChatNew split", icon = "󰗋" },
				{ "<C-g>a", ":<C-u>'<,'>GpAppend<cr>", desc = "Visual Append (after)", icon = "󰗋" },
				{ "<C-g>b", ":<C-u>'<,'>GpPrepend<cr>", desc = "Visual Prepend (before)", icon = "󰗋" },
				{ "<C-g>c", ":<C-u>'<,'>GpChatNew<cr>", desc = "Visual Chat New", icon = "󰗋" },
				{ "<C-g>g", group = "generate into new ..", icon = "󰗋" },
				{ "<C-g>ge", ":<C-u>'<,'>GpEnew<cr>", desc = "Visual GpEnew", icon = "󰗋" },
				{ "<C-g>gn", ":<C-u>'<,'>GpNew<cr>", desc = "Visual GpNew", icon = "󰗋" },
				{ "<C-g>gp", ":<C-u>'<,'>GpPopup<cr>", desc = "Visual Popup", icon = "󰗋" },
				{ "<C-g>gt", ":<C-u>'<,'>GpTabnew<cr>", desc = "Visual GpTabnew", icon = "󰗋" },
				{ "<C-g>gv", ":<C-u>'<,'>GpVnew<cr>", desc = "Visual GpVnew", icon = "󰗋" },
				{ "<C-g>i", ":<C-u>'<,'>GpImplement<cr>", desc = "Implement selection", icon = "󰗋" },
				{ "<C-g>n", "<cmd>GpNextAgent<cr>", desc = "Next Agent", icon = "󰗋" },
				{ "<C-g>p", ":<C-u>'<,'>GpChatPaste<cr>", desc = "Visual Chat Paste", icon = "󰗋" },
				{ "<C-g>r", ":<C-u>'<,'>GpRewrite<cr>", desc = "Visual Rewrite", icon = "󰗋" },
				{ "<C-g>s", "<cmd>GpStop<cr>", desc = "GpStop", icon = "󰗋" },
				{ "<C-g>t", ":<C-u>'<,'>GpChatToggle<cr>", desc = "Visual Toggle Chat", icon = "󰗋" },
				{ "<C-g>w", group = "Whisper", icon = "󰗋" },
				{ "<C-g>wa", ":<C-u>'<,'>GpWhisperAppend<cr>", desc = "Whisper Append", icon = "󰗋" },
				{ "<C-g>wb", ":<C-u>'<,'>GpWhisperPrepend<cr>", desc = "Whisper Prepend", icon = "󰗋" },
				{ "<C-g>we", ":<C-u>'<,'>GpWhisperEnew<cr>", desc = "Whisper Enew", icon = "󰗋" },
				{ "<C-g>wn", ":<C-u>'<,'>GpWhisperNew<cr>", desc = "Whisper New", icon = "󰗋" },
				{ "<C-g>wp", ":<C-u>'<,'>GpWhisperPopup<cr>", desc = "Whisper Popup", icon = "󰗋" },
				{ "<C-g>wr", ":<C-u>'<,'>GpWhisperRewrite<cr>", desc = "Whisper Rewrite", icon = "󰗋" },
				{ "<C-g>wt", ":<C-u>'<,'>GpWhisperTabnew<cr>", desc = "Whisper Tabnew", icon = "󰗋" },
				{ "<C-g>wv", ":<C-u>'<,'>GpWhisperVnew<cr>", desc = "Whisper Vnew", icon = "󰗋" },
				{ "<C-g>ww", ":<C-u>'<,'>GpWhisper<cr>", desc = "Whisper", icon = "󰗋" },
				{ "<C-g>x", ":<C-u>'<,'>GpContext<cr>", desc = "Visual GpContext", icon = "󰗋" },
			},

			-- NORMAL mode mappings
			{
				mode = { "n" },
				nowait = true,
				remap = false,
				{ "<C-g><C-t>", "<cmd>GpChatNew tabnew<cr>", desc = "New Chat tabnew" },
				{ "<C-g><C-v>", "<cmd>GpChatNew vsplit<cr>", desc = "New Chat vsplit" },
				{ "<C-g><C-x>", "<cmd>GpChatNew split<cr>", desc = "New Chat split" },
				{ "<C-g>a", "<cmd>GpAppend<cr>", desc = "Append (after)" },
				{ "<C-g>b", "<cmd>GpPrepend<cr>", desc = "Prepend (before)" },
				{ "<C-g>c", "<cmd>GpChatNew<cr>", desc = "New Chat" },
				{ "<C-g>f", "<cmd>GpChatFinder<cr>", desc = "Chat Finder" },
				{ "<C-g>g", group = "generate into new .." },
				{ "<C-g>ge", "<cmd>GpEnew<cr>", desc = "GpEnew" },
				{ "<C-g>gn", "<cmd>GpNew<cr>", desc = "GpNew" },
				{ "<C-g>gp", "<cmd>GpPopup<cr>", desc = "Popup" },
				{ "<C-g>gt", "<cmd>GpTabnew<cr>", desc = "GpTabnew" },
				{ "<C-g>gv", "<cmd>GpVnew<cr>", desc = "GpVnew" },
				{ "<C-g>n", "<cmd>GpNextAgent<cr>", desc = "Next Agent" },
				{ "<C-g>r", "<cmd>GpRewrite<cr>", desc = "Inline Rewrite" },
				{ "<C-g>s", "<cmd>GpStop<cr>", desc = "GpStop" },
				{ "<C-g>t", "<cmd>GpChatToggle<cr>", desc = "Toggle Chat" },
				{ "<C-g>w", group = "Whisper", icon = "󰗋" },
				{ "<C-g>wa", "<cmd>GpWhisperAppend<cr>", desc = "[W]hisper [A]ppend" },
				{ "<C-g>wb", "<cmd>GpWhisperPrepend<cr>", desc = "[W]hisper [P]repend" },
				{ "<C-g>we", "<cmd>GpWhisperEnew<cr>", desc = "[W]hisper Enew" },
				{ "<C-g>wn", "<cmd>GpWhisperNew<cr>", desc = "[W]hisper New" },
				{ "<C-g>wp", "<cmd>GpWhisperPopup<cr>", desc = "[W]hisper Popup" },
				{ "<C-g>wr", "<cmd>GpWhisperRewrite<cr>", desc = "[W]hisper Inline Rewrite" },
				{ "<C-g>wt", "<cmd>GpWhisperTabnew<cr>", desc = "[W]hisper Tabnew" },
				{ "<C-g>wv", "<cmd>GpWhisperVnew<cr>", desc = "[W]hisper Vnew" },
				{ "<C-g>ww", "<cmd>GpWhisper<cr>", desc = "[W]hisper" },
				{ "<C-g>x", "<cmd>GpContext<cr>", desc = "Toggle GpContext" },
			},

			-- INSERT mode mappings
			{
				mode = { "i" },
				nowait = true,
				remap = false,
				{ "<C-g><C-t>", "<cmd>GpChatNew tabnew<cr>", desc = "New Chat tabnew" },
				{ "<C-g><C-v>", "<cmd>GpChatNew vsplit<cr>", desc = "New Chat vsplit" },
				{ "<C-g><C-x>", "<cmd>GpChatNew split<cr>", desc = "New Chat split" },
				{ "<C-g>a", "<cmd>GpAppend<cr>", desc = "Append (after)" },
				{ "<C-g>b", "<cmd>GpPrepend<cr>", desc = "Prepend (before)" },
				{ "<C-g>c", "<cmd>GpChatNew<cr>", desc = "New Chat" },
				{ "<C-g>f", "<cmd>GpChatFinder<cr>", desc = "Chat Finder" },
				{ "<C-g>g", group = "generate into new .." },
				{ "<C-g>ge", "<cmd>GpEnew<cr>", desc = "GpEnew" },
				{ "<C-g>gn", "<cmd>GpNew<cr>", desc = "GpNew" },
				{ "<C-g>gp", "<cmd>GpPopup<cr>", desc = "Popup" },
				{ "<C-g>gt", "<cmd>GpTabnew<cr>", desc = "GpTabnew" },
				{ "<C-g>gv", "<cmd>GpVnew<cr>", desc = "GpVnew" },
				{ "<C-g>n", "<cmd>GpNextAgent<cr>", desc = "Next Agent" },
				{ "<C-g>r", "<cmd>GpRewrite<cr>", desc = "Inline Rewrite" },
				{ "<C-g>s", "<cmd>GpStop<cr>", desc = "GpStop" },
				{ "<C-g>t", "<cmd>GpChatToggle<cr>", desc = "Toggle Chat" },
				{ "<C-g>w", group = "Whisper" },
				{ "<C-g>wa", "<cmd>GpWhisperAppend<cr>", desc = "Whisper Append (after)" },
				{ "<C-g>wb", "<cmd>GpWhisperPrepend<cr>", desc = "Whisper Prepend (before)" },
				{ "<C-g>we", "<cmd>GpWhisperEnew<cr>", desc = "Whisper Enew" },
				{ "<C-g>wn", "<cmd>GpWhisperNew<cr>", desc = "Whisper New" },
				{ "<C-g>wp", "<cmd>GpWhisperPopup<cr>", desc = "Whisper Popup" },
				{ "<C-g>wr", "<cmd>GpWhisperRewrite<cr>", desc = "Whisper Inline Rewrite" },
				{ "<C-g>wt", "<cmd>GpWhisperTabnew<cr>", desc = "Whisper Tabnew" },
				{ "<C-g>wv", "<cmd>GpWhisperVnew<cr>", desc = "Whisper Vnew" },
				{ "<C-g>ww", "<cmd>GpWhisper<cr>", desc = "Whisper" },
				{ "<C-g>x", "<cmd>GpContext<cr>", desc = "Toggle GpContext" },
			},
		})
	end,
}
