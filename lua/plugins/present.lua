return {
    'tjdevries/present.nvim',
    config = function()
        require("present").setup {
            options = {
                syntax = {
                    comment = "%%",
                    stop = "<!%-%-%s*stop%s*%-%->",
                },
                executors = {},
            }
        }
    end
}
