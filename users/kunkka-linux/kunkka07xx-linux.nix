{ pkgs, lib, config, ... }:

{
  imports = [
    ./../../modules/home-manager/default.nix
    ./../../modules/home-manager/alacritty.nix
    ./../../modules/home-manager/sway.nix
    ./langs.nix
  ];

  home.username = "kunkka07xx";
  home.homeDirectory = "/home/kunkka07xx";
  home.stateVersion = "24.05";
  nixpkgs.config.allowUnfree = true;

  within.neovim.enable = true;
  within.zsh.enable = true;
  within.alacritty.enable = true;

  home.packages = [
    pkgs.vim
    pkgs.git
    pkgs.zig
    pkgs.nerd-fonts.inconsolata
    # pkgs.nerd-fonts.maple-mono
    pkgs.rcm
    pkgs.alacritty
  ];

  home.file = {
    ".config/rcm/bindings.conf".text = ''
      .txt = ${pkgs.neovim}/bin/nvim
    '';
  };
  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "alacritty";
    GTK_IM_MODULE = "ibus";
    QT_IM_MODULE = "ibus";
    XMODIFIERS = "@im=ibus";
  };

  # ibus
  xsession.windowManager.bspwm.startupPrograms = [
    "${pkgs.ibus}/bin/ibus restart || ${pkgs.ibus}/bin/ibus-daemon -d -r -x"
  ];

  # show ui app
  programs.zsh.profileExtra = lib.mkAfter ''
    rm -rf ${config.home.homeDirectory}/.local/share/applications/home-manager
    rm -rf ${config.home.homeDirectory}/.icons/nix-icons
    ls ${config.home.homeDirectory}/.nix-profile/share/applications/*.desktop > ${config.home.homeDirectory}/.cache/current_desktop_files.txt
  '';

  home.activation = {
    linkDesktopApplications = {
      after = [ "writeBoundary" "createXdgUserDirectories" ];
      before = [ ];
      data = ''
        rm -rf ${config.home.homeDirectory}/.local/share/applications/home-manager
        rm -rf ${config.home.homeDirectory}/.icons/nix-icons
        mkdir -p ${config.home.homeDirectory}/.local/share/applications/home-manager
        mkdir -p ${config.home.homeDirectory}/.icons
        ln -sf ${config.home.homeDirectory}/.nix-profile/share/icons ${config.home.homeDirectory}/.icons/nix-icons

        # Check if the cached desktop files list exists
        if [ -f ${config.home.homeDirectory}/.cache/current_desktop_files.txt ]; then
          current_files=$(cat ${config.home.homeDirectory}/.cache/current_desktop_files.txt)
        else
          current_files=""
        fi

        # Symlink new desktop entries
        for desktop_file in ${config.home.homeDirectory}/.nix-profile/share/applications/*.desktop; do
          if ! echo "$current_files" | grep -q "$(basename $desktop_file)"; then
            ln -sf "$desktop_file" ${config.home.homeDirectory}/.local/share/applications/home-manager/$(basename $desktop_file)
          fi
        done

        # Update desktop database
        ${pkgs.desktop-file-utils}/bin/update-desktop-database ${config.home.homeDirectory}/.local/share/applications
      '';
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

}
