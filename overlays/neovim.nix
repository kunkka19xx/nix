final: prev:
let
  # nixpkgs commit with neovim 0.11.6 and matching tree-sitter/grammars
  pkgs-nvim = import
    (builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/fda6b0917a502c8198ef2de613dbad0efa411dca.tar.gz";
      sha256 = "1x6yn0fghj9d48z9w1q9743jh1v46j5v162ca57pkvj7v87w7g2h";
    })
    { system = prev.stdenv.hostPlatform.system; };
in
{
  neovim-unwrapped = pkgs-nvim.neovim-unwrapped;
  vimPlugins = prev.vimPlugins // {
    nvim-treesitter = pkgs-nvim.vimPlugins.nvim-treesitter;
  };
}
