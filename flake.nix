{
  description = "Kunkka nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.url = "github:hraban/mac-app-util"; # show UI app in spotlight search
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware"; # Add nixos-hardware
    # home brew
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    # Optional: Declarative tap management
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
  };

  outputs =
    { self
    , nix-darwin
    , nixpkgs
    , mac-app-util
    , home-manager
    , nixos-hardware
    , nix-homebrew
    , homebrew-cask
    , homebrew-core
    , homebrew-bundle
    , ...
    }@inputs:
    let
      mkNixosConfig =
        system: extraModules:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs system; };
          modules = extraModules;
        };
      mkHmConfig =
        pkgs: extraModules:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit inputs; };
          modules = extraModules;
        };
    in
    {
      darwinConfigurations = {
        com-mac = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit inputs; };
          modules = [
            mac-app-util.darwinModules.default
            ./users/hvn/system.nix
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                enable = true;
                enableRosetta = true;
                # User owning the Homebrew prefix
                user = "haovanngyuen";
                taps = {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                  "homebrew/homebrew-bundle" = homebrew-bundle;
                };
                mutableTaps = false;
              };
            }
          ];
        };
      };
      nixosConfigurations = {
        surface = mkNixosConfig "x86_64-linux" [
          ./nixos/surface-pro-7/configuration.nix
          # if there is alternative to it to use touchscreen, replace 
          # because installing kernel takes time
          nixos-hardware.nixosModules.microsoft-surface-pro-intel
          # nixos-hardware.nixosModules.microsoft-surface-common
          {
            microsoft-surface.ipts.enable = true;
            microsoft-surface.surface-control.enable = false;
          }
        ];
        vm = mkNixosConfig "aarch64-linux" [
          ./nixos/minimal-vm/configuration.nix
        ];
      };
      homeConfigurations = {
        "com-mac" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
          extraSpecialArgs = { inherit inputs; };
          modules = [
            mac-app-util.homeManagerModules.default
            ./users/hvn/haovanngyuen.nix
          ];
        };
        "kunkka07xx-linux" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs; };
          modules = [
            ./users/kunkka-linux/kunkka07xx-linux.nix
          ];
        };
        "kunkka-vm" = home-manager.lib.homeManagerConfiguration
          {
            pkgs = nixpkgs.legacyPackages.aarch64-linux;
            extraSpecialArgs = { inherit inputs; };
            modules = [
              ./users/kunkka-vm/kunkka-vm.nix
            ];
          };
      };
    };
}
