[1mdiff --git a/modules/home-manager/i3.nix b/modules/home-manager/i3.nix[m
[1mindex 86b5ef5..24b37ee 100644[m
[1m--- a/modules/home-manager/i3.nix[m
[1m+++ b/modules/home-manager/i3.nix[m
[36m@@ -63,6 +63,7 @@[m [min[m
       font pango:JetBrainsMono Nerd Font 19[m
       exec --no-startup-id sh -c "sleep 0.5 && ${pkgs.feh}/bin/feh --bg-scale ~/nix/modules/bg/nix-waifu.png"[m
       exec --no-startup-id ghostty[m
[32m+[m[32m      exec --no-startup-id lookapp[m
       exec i3-msg workspace 1[m
       exec --no-startup-id xclip[m
       exec --no-startup-id fcitx5[m
