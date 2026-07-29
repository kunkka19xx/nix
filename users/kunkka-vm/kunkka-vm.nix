{ pkgs, ... }:

{
  imports = [
    ./../../modules/home-manager/default.nix
    ./../../modules/home-manager/alacritty.nix
    ./../../modules/home-manager/firefox.nix
    ./../../modules/home-manager/i3_vm.nix
    ./../../modules/home-manager/zathura.nix
    ./../../modules/home-manager/opencode.nix
    ./langs.nix
    ./go.nix
  ];
  home.username = "kunkka-vm";
  home.homeDirectory = "/home/kunkka-vm";
  home.stateVersion = "26.05";

  within.neovim.enable = true;
  within.ghostty.enable = true;
  within.zsh.enable = true;
  nixpkgs.config.allowUnfree = true;

  home.packages = [
    pkgs.dmenu
    pkgs.feh
    pkgs.vim
    pkgs.git
    pkgs.nerd-fonts.inconsolata
    pkgs.alacritty
    pkgs.ghostty
    pkgs.rcm
    pkgs.rustup
    pkgs.claude-code
    pkgs.postman
  ];

  home.file = {
    ".config/rcm/bindings.conf".text = ''
      .txt = ${pkgs.neovim}/bin/nvim
    '';
  };

  home.file.".xprofile".text = ''
    export XCURSOR_SIZE=24
    ${pkgs.bash}/bin/bash $HOME/.local/bin/pick-resolution.sh
  '';

  # Single source of truth for VM resolution.
  # If the host display is HiDPI (max mode > 2560 wide), force 1920x1200 so
  # text isn't microscopic. Otherwise let VMware/auto-fit pick the native
  # size of the external monitor.
  home.file.".local/bin/pick-resolution.sh" = {
    executable = true;
    text = ''
      #!${pkgs.bash}/bin/bash
      OUTPUT=Virtual-1
      MAX_W=$(${pkgs.xorg.xrandr}/bin/xrandr | \
        awk -v out="$OUTPUT" '
          $1 == out && $2 == "connected" { f=1; next }
          f && /^[[:space:]]+[0-9]+x[0-9]+/ { print $1; exit }
        ' | cut -dx -f1)
      if [ "''${MAX_W:-0}" -gt 2560 ]; then
        ${pkgs.xorg.xrandr}/bin/xrandr --output "$OUTPUT" --mode 1920x1200
      else
        ${pkgs.xorg.xrandr}/bin/xrandr --output "$OUTPUT" --auto
      fi
    '';
  };

  # for chrome, firefox ,...
  # adjust layout.css.devPixelsPerPx -> as needed (1.5, 2.0 ....)

  home.sessionVariables = {
    EDITOR = "nvim";
  };
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
