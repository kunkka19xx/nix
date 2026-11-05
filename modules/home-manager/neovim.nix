{
  lib,
  config,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.within.neovim;
in
{
  options.within.neovim.enable = mkEnableOption "Enables Within's Neovim config";

  config = mkIf cfg.enable {
    programs.neovim.enable = true;
    programs.neovim.viAlias = true;
    programs.neovim.vimAlias = true;
    programs.neovim.vimdiffAlias = true;
    programs.neovim.plugins = [
      pkgs.vimPlugins.nvim-treesitter.withAllGrammars
    ];
    programs.neovim.extraPackages = [
      pkgs.vscode-json-languageserver
      pkgs.lua-language-server
      pkgs.luajitPackages.jsregexp
      pkgs.nil
      pkgs.gopls
      pkgs.gofumpt
      pkgs.stylua
      pkgs.basedpyright
      pkgs.pyright
      pkgs.ruff
      pkgs.nixfmt
      pkgs.zls
      pkgs.ripgrep
      # fix bug lazy-luarocks
      # pkgs.luarocks
      pkgs.lua51Packages.lua
      pkgs.lua51Packages.luarocks
      pkgs.asm-lsp
      pkgs.websocat
    ];
    # programs.neovim generates ~/.config/nvim/init.lua (provider toggles only).
    # It cannot coexist with the directory symlink below, so drop it.
    xdg.configFile."nvim/init.lua".enable = lib.mkForce false;
    # Out-of-store symlink into the dotfiles submodule: edits are live, and
    # lazy.nvim can write lazy-lock.json. Assumes the repo is checked out at ~/nix.
    home.file.".config/nvim".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/dotfiles/nvim/.config/nvim";
  };
}
