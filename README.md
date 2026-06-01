# Nix Configuration

Multi-platform nix configuration managing macOS (nix-darwin), NixOS bare-metal machines, NixOS VMs, and home-manager profiles.

## Project Structure

```
.
├── flake.nix                  # Entry point - defines all systems and profiles
├── overlays/                  # Package overrides (e.g. pinned neovim version)
├── modules/home-manager/      # Reusable home-manager modules (neovim, zsh, tmux, etc.)
├── nixos/                     # NixOS system configurations
│   ├── desk/                  # Desktop PC (AMD GPU, i3 + GNOME, Wayland)
│   ├── surface-pro-7/         # Microsoft Surface Pro 7
│   ├── minimal-vm/            # Minimal dev VM (aarch64)
│   └── work-vm/               # Work VM (aarch64)
├── users/                     # Home-manager user profiles
│   ├── hvn/                   # macOS user profile
│   ├── desk/                  # Desktop user profile
│   ├── surface/               # Surface user profile
│   └── kunkka-vm/             # VM user profiles
├── dotfiles/                  # App configs (nvim, tmux, ghostty, alacritty, etc.)
└── shells/                    # Nix dev shells
```

## Install Nix

```sh
curl -L https://nixos.org/nix/install | sh
```

Check the installation:

```sh
nix --version
```

Enable flakes by adding to `~/.config/nix/nix.conf`:

```
experimental-features = nix-command flakes
```

**Note:** exit and re-open your terminal after installing nix.

### Potential Issue (macOS)

If the nix path is not added to `.zshrc` properly, remove the broken install:

```sh
sudo rm -rf /nix
sudo rm -f /etc/zshrc.backup-before-nix
```

Then reinstall with the no-modify-profile flag:

```sh
curl -L https://nixos.org/nix/install | sh -s -- --no-modify-profile
```

## Flake

A flake is a nix project with a `flake.nix` file at its root. It defines inputs (dependencies) and outputs (systems, packages, profiles). Flakes provide reproducibility — everyone gets the same result from the same `flake.lock`.

[Flake documentation](https://nix.dev/concepts/flakes.html) | [NixOS Wiki](https://wiki.nixos.org/wiki/Flakes)

### Initialize (if starting fresh)

```sh
mkdir ~/nix && cd ~/nix
nix flake init -t nix-darwin --extra-experimental-features "nix-command flakes"
```

This creates a `flake.nix` — open and customize it.

## macOS Setup (nix-darwin)

nix-darwin provides declarative system configuration for macOS, similar to NixOS.
[Reference](https://dev.jmgilman.com/environment/tools/nix/nix-darwin/)

### First-time Install

If `/etc/bashrc` or `/etc/zshrc` already exist, back them up first:

```sh
sudo mv /etc/bashrc /etc/bashrc.bak
sudo mv /etc/zshrc /etc/zshrc.bak
```

Then install nix-darwin:

```sh
nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake ~/nix#com-mac
```

Confirm it works:

```sh
which darwin-rebuild
# should output: /run/current-system/sw/bin/darwin-rebuild
```

### Rebuild After Changes

```sh
darwin-rebuild switch --flake ~/nix#com-mac
```

## NixOS Setup

### Rebuild

```sh
sudo nixos-rebuild switch --flake ~/nix#desk
# other configs: #surface, #vm, #work-vm
```

## Home Manager

Home manager handles user-level configuration — packages, dotfiles, shell config, and application settings. It keeps tool configs in their original format (lua for neovim, toml for ghostty, etc.) while still being managed by nix.

[Home Manager docs](https://nix-community.github.io/home-manager/)

**Important:** home-manager must be installed first before you can use it. Declaring it in the flake is not enough.

### Apply a Profile

```sh
home-manager switch --flake ~/nix#desk
# other profiles: #com-mac, #surface, #kunkka-vm, #work-vm
```

### Adding User Packages

```nix
home.packages = [
  pkgs.vim
  pkgs.git
  pkgs.ripgrep
];
```

### Modules

Reusable modules in `modules/home-manager/` can be toggled per-profile:

```nix
within.neovim.enable = true;
within.ghostty.enable = true;
within.zsh.enable = true;
```

### Dotfiles

App configs live in `dotfiles/` and are symlinked via home-manager:

```nix
home.file.".config/nvim" = {
  source = ../../dotfiles/nvim;
  recursive = true;
};
```

## Adding Packages

### System-level Packages

In NixOS `configuration.nix` or nix-darwin `system.nix`:

```nix
environment.systemPackages = [
  pkgs.neovim
  pkgs.wget
];
```

Then rebuild:

```sh
# NixOS
sudo nixos-rebuild switch --flake ~/nix#desk

# macOS
darwin-rebuild switch --flake ~/nix#com-mac
```

**Note:** if you previously installed a package via homebrew or another package manager, uninstall it first:

```sh
brew uninstall neovim
```

After rebuild, verify it comes from nix:

```sh
which nvim
# should output: /run/current-system/sw/bin/nvim
```

### Search Packages

```sh
nix search nixpkgs tmux
```

Or use the web: https://search.nixos.org/packages

### UI Apps on macOS

Nix-installed GUI apps may not appear in Spotlight. This flake uses [mac-app-util](https://github.com/hraban/mac-app-util) to fix that automatically.

## NixOS VM

A minimal, identical, reproducible dev environment. Only requires internet to set up.

### VM Software

- **macOS:**
  - Lightweight but slower: [UTM](https://mac.getutm.app/)
  - Better performance: [VMware Fusion](https://www.vmware.com/products/desktop-hypervisor/workstation-and-fusion)
- **Linux:** virt-manager with libvirtd (configured in `desk/configuration.nix`)

### ISO Downloads

- [NixOS download page](https://nixos.org/download/)
- ARM minimal ISO for VMs: check the latest minimal aarch64-linux ISO from the download page

### Installation

Follow the [official installation guide](https://nixos.org/manual/nixos/stable/#sec-installation):

1. Boot from ISO
2. Partition and format disk — see [`nixos/minimal-vm/part-form.bash`](./nixos/minimal-vm/part-form.bash) for reference (adjust partition/format based on your disk type)
3. Run `nixos-install`
4. Remove the ISO, reboot
5. Set user password:

```sh
passwd <username>
```

### Apply NixOS + Home Manager

After first boot:

1. Add user to sudoers in `configuration.nix`
2. Rebuild, login as user
3. Clone this repo
4. Copy your `hardware-configuration.nix` into the appropriate `nixos/<machine>/` directory
5. Apply:

```sh
sudo nixos-rebuild switch --flake ~/nix#vm
home-manager switch --flake ~/nix#kunkka-vm
```

### Git Setup (Headless Machines)

Since there is no browser in the VM, use SSH for git:

```sh
ssh-keygen -t ed25519 -C "your@email.com"
cat ~/.ssh/id_ed25519.pub
```

Add the public key to https://github.com/settings/keys

Verify connection:

```sh
ssh -T git@github.com
# type 'yes' to confirm
```

Then clone/push repos using SSH URLs.

### Shared Folder (VMware Fusion)

Check that vmhgfs-fuse is available:

```sh
which vmhgfs-fuse
```

Mount the shared folder:

```sh
sudo vmhgfs-fuse .host:/ /mnt/hgfs -o allow_other
```

Create a symlink for quick access:

```sh
ln -s /mnt/hgfs/<folder> ~/shared
```

## Build from Source

Nix can build packages from source when they are not yet available in nixpkgs. This is useful when a new version is released but nixpkgs hasn't updated yet.

Examples in this repo:
- [users/hvn/go.nix](./users/hvn/go.nix) — building Go from source
- [users/hvn/im-select.nix](./users/hvn/im-select.nix) — building custom tools

## Maintenance

```sh
# Update all flake inputs to latest
nix flake update

# Garbage collect old generations
nix-collect-garbage -d

# Clean the nix store
nix-store --gc
```

## Tips

- After adding new files to the repo, you must `git add` them before rebuilding with flakes (untracked files are invisible to flakes)
- Nix dev shells for project-specific tooling: see `shells/` directory
- Get a sha256 hash for a git repo:

```sh
nix-prefetch-git --url https://github.com/owner/repo --rev <tag-or-commit>
```

- Node packages not appearing in PATH:

```sh
npm set prefix ~/.npm-global
export PATH="$HOME/.npm-global/bin:$PATH"
```
