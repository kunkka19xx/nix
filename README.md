## Install nix

```shell
curl -L https://nixos.org/nix/install | sh
```

- Check version

```shell
nix --version
```

#### Potential issue:

Nix path is not added into .zshrc properly

-> remove

```shell
sudo rm -rf /nix
sudo rm -f /etc/zshrc.backup-before-nix
```

then reinstall with zsh as main profile

```shell
curl -L https://nixos.org/nix/install | sh -s -- --no-modify-profile
```

_note:_ we need to exit the current shell session, open again to use nix

## Nix-darwin module (Macos)

nix-darwin is an opionated set of modules for managing configuration of macOS. It provides a centralized nix file for declaring system state.
[refer](https://dev.jmgilman.com/environment/tools/nix/nix-darwin/)

### Create nix dir (your way)

```shell
mkdir ~/nix
```

```shell
cd ~/nix
mkdir ~/nix
```

_note:_ I go for the 1st criteria, after confirming that nix works in a stable state -> I will migrate it to my dotfiles

## Flake

Technically, a flake is a file system tree that contains a file named flake.nix in its root directory.
[refer](https://nix.dev/concepts/flakes.html)

- There are 2 approaches: Channels, Flake
  (I prefer Flake)

```shell
nix flake init -t nix-darwin
```

- I use experimental feature flag

```shell
nix flake init -t nix-darwin --extra-experimental-features "nix-command flakes"
```

- after this command, a file flake.nix will be added.
- open and add your setting :)

### Config

[wiki](https://wiki.nixos.org/wiki/Flakes)

- change darwinConfigurations (for macos)
  ex:

```nix
{
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."your-config" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };

    # Expose the package set, including overlays, for convenience
    darwinPackages = self.darwinConfigurations."your-config".pkgs;
};
```

- Install nix-darwin

```shell
nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake ~/nix#your-config

```

- If there are existing content in zshrc & bashrc, we can backup them first

```shell
➜  nix sudo mv /etc/bashrc /etc/bashrc.bak
➜  nix sudo mv /etc/zshrc /etc/zshrc.bak
➜  nix nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake ~/nix#your-config
```

- Confirm

```
which darwin-rebuild
/run/current-system/sw/bin/darwin-rebuild #should be like that
```

### Add packages

#### How to

- Add package to this array. Example with neovim

```nix
environment.systemPackages = #systemPackages
    [ pkgs.neovim
    ];
```

- Then run it to rebuild

```shell
darwin-rebuild switch --flake ~/nix#your-config
```

_Note:_ might need to remove apps from homebrew/ your current pkg manager to use the one from nix

```shell
brew uninstall neovim
```

- Rebuild again then check

```shell
which nvim
/run/current-system/sw/bin/nvim  #should be like this
```

### List packages:

- example with tmux

```shell
nix search nixpkgs tmux
```

- We can use this site as well:
  [nix pkgs](https://search.nixos.org/packages)

#### UI apps

- Ui app maybe cannot appeared in Spotlight search on macos (symlink)
  -> Add config in to configuration input, then add alias script for all Applications
  -> Easier way is using mac-app-util
  [link](https://github.com/hraban/mac-app-util)

## Home manager

- I think there are some levels of settings : system -> profile -> modules
- To use profile and modular settings, and keep dotfiles setting in their original setting languages, flavor
  I use home manager
- We need to install home-manager to use it!!! (declaration in nix file is not enough!)
  [home-manager](https://nix-community.github.io/home-manager/)

- apply profile:

```shell
home-manager switch --flake ~/nix#your-config
```

- Note: Home manager adds package as follow

```nix
home.packages = [
    pkgs.vim
    pkgs.git
    pkgs.wezterm
  # more
  ];
```

## Build from source.

This is Reproducible ability of nix. In my case, when go 1.24 released. It was not avaialbe in
nix packages, so I built it from source.
[refer](/users/hvn/go.nix)

- I also did it with some packages like im-select,...

## Sub-tree

Since I use home manager to keep the setting of any tools as their original flavor. I try to use git subtree to link the existing settings in my dotfiles repo to this repo. Using git submodule is easier but I don't want to get every thing. -> git subtree will be the best option.

- Refer this: /[note](./dotfiles/nvim/note.md) 

## Nixos-vm

I want to have a very minimal, identical environment for developement. And this should be re-proceducible (requires only internet)
###  VM 

- Macos: 
    - Light but slow: UTM (install via nix darwin or brew) [link](https://mac.getutm.app/) 
    - Good: VM fusion [link](https://www.vmware.com/products/desktop-hypervisor/workstation-and-fusion) 
 
- Window: Need to research

### Iso
List [list](https://nixos.org/download/) 
ARM minimal [link](https://channels.nixos.org/nixos-24.11/latest-nixos-minimal-aarch64-linux.iso.sha256) 
 
### Install
[install guideline](https://nixos.org/manual/nixos/stable/#sec-installation) 
- Follow partition, format
- -> nixos-install -> clear iso cd/dvd -> reboot (TODO: add bash)
- Add user, change password by sudo

```bash
passwd <user-name>
```

### Apply profile
- Add user sudo permission into configuration.nix file
- Rebuild -> login as user -> clone nix repo -> remember copy hardware-configuration.nix file to minimal profile
- Apply minimal-vm profile 
[minimal-vm](./nixos/minimal-vm/) 

```bash
sudo nixos-rebuild switch --flake ~/nix#vm
```
- Install home-manager [link](https://nix-community.github.io/home-manager/index.xhtml#sec-install-nixos-module) 

```bash
home-manager switch --flake ~/nix#kunkka-vm
```


## Note (out-date maybe)

- After init git for nix dir, need to add changed files to, if not, we can not rebuild using flake

- Collect garbage

```shell
nix-collect-garbage -d
```

```shell
nix-store --gc
```

- I use nix darwin, nixos, ... to manage system level pkgs (todo)
- And I use home-manager for managing user/profile/projects pkgs
  When I have new project, or new profiles, I just need to copy an existing profile (users), and
  remove, add things, customize it.

### Golang

- Don't know why but it seems like we need to `unset GOROOT` (if not, go root will be pointed to wrong path)

### Get sha256

- example script:

```shell
nix-shell -p nix-prefetch-git --run "nix-prefetch-git --url https://github.com/golang/go --rev go1.24.0"
```

### Node packages

Sometimes, I have trouble with node packages, they are not appeared in the path. Try this:

```shell
 export PATH="$HOME/.npm-global/bin:$PATH"
```

- I think I can fix it by some extra commands in the langs.nix file. But now I am quite lazy. LOL


Or need following command before installing npm pkgs, TODO: research

```shell
npm set prefix ~/.npm-global
```

