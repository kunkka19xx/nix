{ config, lib, pkgs, inputs, ... }:

let
  # Wrap lookapp so it does NOT inherit the system-wide fcitx GTK module
  # setup. GTK_IM_MODULE_FILE (set by input-method.nix) points at a module
  # cache built against the system gtk3, which look's WebKit chokes on. But
  # unsetting only the cache while GTK_IM_MODULE=fcitx stays set makes GTK
  # fail the named-module load and fall back to its "simple" context: no IM
  # at all (can't type Vietnamese in Look). With BOTH unset, GTK3 on Wayland
  # defaults to its native wayland IM context (text-input-v3 -> compositor
  # -> fcitx5), which needs no module and is the recommended fcitx5 setup
  # on Wayland anyway.
  lookappWrapped = pkgs.symlinkJoin {
    name = "lookapp-fcitx-fix";
    paths = [ inputs.look.packages.${pkgs.system}.default ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/lookapp --unset GTK_IM_MODULE_FILE --unset GTK_IM_MODULE
    '';
  };
in
{
  home.packages = [ lookappWrapped ];

  xdg.configFile."fcitx5/profile" = {
    force = true;
    text = ''
      [Groups/0]
      # Group Name
      Name=Default
      # Layout
      Default Layout=us
      # Default Input Method
      DefaultIM=unikey

      [Groups/0/Items/0]
      # Name
      Name=keyboard-us
      # Layout
      Layout=

      [Groups/0/Items/1]
      # Name
      Name=unikey
      # Layout
      Layout=

      [GroupOrder]
      0=Default
    '';
  };

  xdg.configFile."fcitx5/config" = {
    force = true;
    text = ''
      [Hotkey]
      # Enumerate when holding modifier of Toggle key
      EnumerateWithTriggerKeys=True
      # Enumerate Input Method Forward
      EnumerateForwardKeys=
      # Enumerate Input Method Backward
      EnumerateBackwardKeys=
      # Skip first input method while enumerating
      EnumerateSkipFirst=False
      # Time limit in milliseconds for triggering modifier key shortcuts
      ModifierOnlyKeyTimeout=250

      [Hotkey/TriggerKeys]
      0=Alt+Shift_L
      1=Shift+Alt_L

      [Hotkey/AltTriggerKeys]
      0=Control+space

      [Hotkey/EnumerateGroupForwardKeys]
      0=Super+space

      [Hotkey/EnumerateGroupBackwardKeys]
      0=Shift+Super+space

      [Hotkey/PrevPage]
      0=Up

      [Hotkey/NextPage]
      0=Down

      [Hotkey/PrevCandidate]
      0=Shift+Tab

      [Hotkey/NextCandidate]
      0=Tab

      [Hotkey/TogglePreedit]
      0=Control+Alt+P

      [Behavior]
      # Active By Default — false means fcitx5 starts in the keyboard-us (English) state
      ActiveByDefault=False
      # Reset state on Focus In
      resetStateWhenFocusIn=No
      # Share Input State
      ShareInputState=No
      # Show preedit in application
      PreeditEnabledByDefault=True
      # Show Input Method Information when switch input method
      ShowInputMethodInformation=True
      # Show Input Method Information when changing focus
      showInputMethodInformationWhenFocusIn=False
      # Show compact input method information
      CompactInputMethodInformation=True
      # Show first input method information
      ShowFirstInputMethodInformation=True
      # Default page size
      DefaultPageSize=5
      # Override XKB Option
      OverrideXkbOption=True
      # Custom XKB Option
      CustomXkbOption=
      # Force Enabled Addons
      EnabledAddons=
      # Force Disabled Addons
      DisabledAddons=
      # Preload input method to be used by default
      PreloadInputMethod=True
      # Allow input method in the password field
      AllowInputMethodForPassword=False
      # Show preedit text when typing password
      ShowPreeditForPassword=False
      # Interval of saving user data in minutes
      AutoSavePeriod=30
    '';
  };
}
