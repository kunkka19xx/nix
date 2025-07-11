# system.nix
{ config, pkgs, ... }:
# Import homebrew packages from the separate file
{
  # TODO: Add system pks and setting
  # migrate some settings from home to here
  environment.systemPackages = with pkgs; [
    pre-commit
    tldr
    git
    colima
    docker
    docker-compose
    docker-client #TODO: confirm
    google-cloud-sdk
    gh
    jq
  ];
  homebrew = {
    enable = true;
    casks = [
      "firefox"
      "slack"
      "ghostty"
      "qutebrowser"
    ];
    brews = [
      # "staticcheck"
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

