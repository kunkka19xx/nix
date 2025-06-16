{ pkgs, ... }:

let
  themeDir = ./../../dotfiles/zathura;
in
{
  home.packages = with pkgs; [
    zathura
    # zathura-djvu
    # zathura-ps
  ];
  xdg.configFile."zathura/themes/catppuccin.theme".source = "${themeDir}/catppuccin.theme";
  xdg.configFile."zathura/themes/dark.theme".source = "${themeDir}/gruvbox-dark.theme";
  xdg.configFile."zathura/themes/light.theme".source = "${themeDir}/gruvbox-light.theme";
  xdg.configFile."zathura/change-theme.bash".source = "${themeDir}/change-theme.bash";
}


