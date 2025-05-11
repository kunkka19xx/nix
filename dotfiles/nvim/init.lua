-- pull lazy vim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- install plugins and options
require("vim-options")
require("vim-helpers")
require("help-floating")
require("floating-term")
-- require("lazy").setup("plugins")
local uname = vim.loop.os_uname()
local hostname = vim.loop.os_gethostname()
lazy_opts = {}
if not (uname.sysname == "Darwin" and hostname == "kunkka07xx") then
    lazy_opts.lockfile = "~/nix/dotfiles/nvim/lazy-lock.json"
end
require("lazy").setup("plugins", lazy_opts)
require("snipets")
