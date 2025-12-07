{ pkgs, ... }:

{
  imports = [
    ./../../modules/home-manager/default.nix
    ./../../modules/home-manager/alacritty.nix
    ./../../modules/home-manager/firefox.nix
    ./../../modules/home-manager/i3_vm.nix
    ./../../modules/home-manager/zathura.nix
    ./langs.nix
    ./go.nix
  ];
  home.username = "kunkka-vm";
  home.homeDirectory = "/home/kunkka-vm";
  home.stateVersion = "24.05";

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
    pkgs.cargo
  ];

  home.file = {
    ".config/rcm/bindings.conf".text = ''
      .txt = ${pkgs.neovim}/bin/nvim
    '';
  };
  # home.file.".xprofile".text = ''
  #   xrandr --output Virtual-1 --scale 0.6x0.6
  # '';

  home.file.".xprofile".text = ''
    export GDK_SCALE=1
    export GDK_DPI_SCALE=0.5
    export QT_AUTO_SCREEN_SCALE_FACTOR=1
    export QT_SCALE_FACTOR=0.5
    export XCURSOR_SIZE=24
    export CHROME_FLAGS="--force-device-scale-factor=0.5"
    # Delay to ensure X is fully initialized
    sleep 0.1
    xrandr --output Virtual-1 --scale 0.8x0.8
  '';

  home.sessionVariables = {
    EDITOR = "nvim";
  };
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
