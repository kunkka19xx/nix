return {
    {
        "olimorris/codecompanion.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },

        config = function()
            require("codecompanion").setup({
                strategies = {
                    chat = { adapter = "ollama" },
                    inline = { adapter = "ollama" },
                    cmd = { adapter = "ollama" },
                },
                display = {
                    diff = {
                        enabled = true,
                        layout = "vertical",
                    },
                },

                adapters = {
                    -- Google Gemini
                    gemini = function()
                        return require("codecompanion.adapters").extend("gemini", {
                            name = "gemini",
                            env = {
                                api_key = os.getenv("GEMINI_API_KEY") or "DUMMY_KEY",
                            },
                            schema = {
                                model = { default = "using-model" },
                            },
                        })
                    end,
                    -- Anthropic (Claude Opus)
                    anthropic = function()
                        return require("codecompanion.adapters").extend("anthropic", {
                            name = "anthropic",
                            env = {
                                api_key = os.getenv("ANTHROPIC_API_KEY") or "DUMMY_KEY",
                            },
                            schema = {
                                model = { default = "using-model" },
                            },
                        })
                    end,

                    -- Ollama (Local)
                    ollama = function()
                        return require("codecompanion.adapters").extend("ollama", {
                            name = "ollama",
                            schema = {
                                model = { default = "qwen2.5-coder:7b" },
                            },
                        })
                    end,
                },
            })
        end,
    },

    {
        "supermaven-inc/supermaven-nvim",
        config = function()
            require("supermaven-nvim").setup({
                keymaps = {
                    accept_suggestion = "<Tab>",
                    clear_suggestion = "<C-]>",
                    accept_word = "<C-j>",
                },
                color = {
                    suggestion_color = "#808080",
                    cterm = 244,
                },
                disable_inline_completion = false,
            })
        end,
    },
}
