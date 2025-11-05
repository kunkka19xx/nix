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
      pkgs.nodePackages_latest.vscode-json-languageserver
      pkgs.lua-language-server
      pkgs.luajitPackages.jsregexp
      pkgs.nil
      pkgs.gopls
      pkgs.gofumpt
      pkgs.stylua
      pkgs.basedpyright
      pkgs.pyright
      pkgs.ruff
      pkgs.nixfmt-rfc-style
      pkgs.zls
      pkgs.ripgrep
      # fix bug lazy-luarocks
      # pkgs.luarocks
      pkgs.lua51Packages.lua
      pkgs.lua51Packages.luarocks
      pkgs.asm-lsp
    ];
    home.file = {
      ".config/nvim" = {
        source = ../../dotfiles/nvim;
        recursive = true;
      };
    };
  };
}
