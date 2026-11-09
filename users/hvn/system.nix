# system.nix
{ config, pkgs, ... }:
# Import homebrew packages from the separate file
{
  system.primaryUser = "haovanngyuen"; # new update requires
  # TODO: Add system pks and setting
  # migrate some settings from home to here
  environment.systemPackages = with pkgs; [
    pre-commit
    tldr
    git
    colima
    docker
    docker-compose
    docker-client # TODO: confirm
    google-cloud-sdk
    gh
    jq
  ];
  homebrew = {
    enable = true;
    taps = [
    ];
    casks = [
      # NOTE: Firefox comes from Homebrew, not nixpkgs. Nixpkgs has no binary
      # cache for firefox on aarch64-darwin (cache.nixos.org 404s), so the nix
      # package compiles from source -- tens of GB of scratch space and hours,
      # repeated on every version bump. home-manager still owns the profile
      # (prefs, search engines, userChrome.css) via `package = null` in
      # modules/home-manager/firefox.nix.
      "firefox"
      "slack"
      "ghostty"
      # NOTE: disabled upstream on 2026-09-01 -- the cask fails the macOS
      # Gatekeeper check, so `brew install` refuses it. Keeping it listed made
      # `brew bundle` abort mid-run, which silently blocked every cask after it
      # (firefox, slack, ghostty) from installing during activation. Re-enable
      # only once homebrew-cask ships a notarized build.
      # "qutebrowser"
    ];
    brews = [
      # "staticcheck"
      "xcp"
      "xcode-build-server"
      "xcbeautify"
    ];
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
  };
  system.stateVersion = 5;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Setting default options for mac such as: dock, theme mode,...
  system.defaults = {
    dock.autohide = true;
    dock.persistent-apps = [
      "${pkgs.alacritty}/Applications/Alacritty.app/"
      "${pkgs.wezterm}/Applications/Wezterm.app/"
      "/Applications/Slack.app/"
      "/Applications/Firefox.app/"
      "/System/Applications/System Settings.app/"
    ];
    finder.FXPreferredViewStyle = "clmv"; # column view for finder
    NSGlobalDomain.AppleInterfaceStyle = "Dark";
    NSGlobalDomain."com.apple.keyboard.fnState" = false;
    # NSGlobalDomain._HIHideMenuBar = false;
    NSGlobalDomain.NSScrollAnimationEnabled = true;
    NSGlobalDomain."com.apple.swipescrolldirection" = false;
  };
}
