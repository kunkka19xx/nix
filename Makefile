# Environment-aware entry points for this flake.
#
#   make            show what was detected
#   make switch     rebuild system + home-manager for this machine
#   make build      build both without activating (no sudo)
#
# Detection: macOS -> com-mac, Surface -> surface, B850 board -> desk,
# any other aarch64 Linux -> vm. Override with HOST=<name> when it guesses
# wrong, e.g. `make switch HOST=work-vm`.
#
# The dotfiles directory is a git submodule, so every flake ref carries
# ?submodules=1. Without it nix copies an empty dotfiles/ into the store.

SHELL := /usr/bin/env bash
.DEFAULT_GOAL := env

UNAME   := $(shell uname -s)
ARCH    := $(shell uname -m)
PRODUCT := $(shell cat /sys/class/dmi/id/product_name 2>/dev/null)

ifeq ($(UNAME),Darwin)
  HOST ?= com-mac
else ifneq (,$(findstring Surface,$(PRODUCT)))
  HOST ?= surface
else ifneq (,$(findstring B850,$(PRODUCT)))
  HOST ?= desk
else ifeq ($(ARCH),aarch64)
  HOST ?= vm
endif

# home-manager profile names differ from the system names in one place.
HM_PROFILE := $(if $(filter vm,$(HOST)),kunkka-vm,$(HOST))

HASH  := \#
FLAKE := .?submodules=1

ifeq ($(UNAME),Darwin)
  SYSTEM_ATTR   := darwinConfigurations.$(HOST).system
  SYSTEM_SWITCH := sudo darwin-rebuild switch --flake '$(FLAKE)$(HASH)$(HOST)'
else
  SYSTEM_ATTR   := nixosConfigurations.$(HOST).config.system.build.toplevel
  SYSTEM_SWITCH := sudo nixos-rebuild switch --flake '$(FLAKE)$(HASH)$(HOST)'
endif

# `make home BACKUP=1` moves files that are in the way to *.backup.
# Needed once on a host that still has the old ~/.config/nvim directory.
HM_FLAGS := $(if $(BACKUP),-b backup,)

.PHONY: env help require-host build build-os build-home os home switch \
        pull push dotfiles-pull dotfiles-push update

env: ## Show the detected machine and the commands that would run
	@echo "os:        $(UNAME) $(ARCH)"
	@echo "product:   $(if $(PRODUCT),$(PRODUCT),n/a)"
	@echo "host:      $(if $(HOST),$(HOST),UNKNOWN (pass HOST=desk|surface|vm|work-vm|com-mac))"
	@echo "hm:        $(HM_PROFILE)"
	@echo "system:    $(SYSTEM_SWITCH)"
	@echo "home:      home-manager switch --flake '$(FLAKE)$(HASH)$(HM_PROFILE)' $(HM_FLAGS)"

help: ## List targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

require-host:
	@test -n "$(HOST)" || { echo "cannot detect host; run with HOST=<desk|surface|vm|work-vm|com-mac>"; exit 1; }

build: build-os build-home ## Build system and home without activating

build-os: require-host ## Build the system closure only
	nix build '$(FLAKE)$(HASH)$(SYSTEM_ATTR)' --no-link --print-out-paths

build-home: require-host ## Build the home-manager generation only
	nix build '$(FLAKE)$(HASH)homeConfigurations.$(HM_PROFILE).activationPackage' --no-link --print-out-paths

os: require-host ## Switch the system (nixos-rebuild or darwin-rebuild, needs sudo)
	$(SYSTEM_SWITCH)

home: require-host ## Switch home-manager (BACKUP=1 to move files that are in the way)
	home-manager switch --flake '$(FLAKE)$(HASH)$(HM_PROFILE)' $(HM_FLAGS)

switch: os home ## Switch system then home

pull: ## Pull this repo and move the submodule to the committed pointer
	git pull --recurse-submodules

dotfiles-pull: ## Fast-forward the dotfiles submodule and commit the new pointer here
	git -C dotfiles pull --ff-only
	@if git diff --quiet -- dotfiles; then echo "dotfiles already up to date"; \
	else git add dotfiles && git commit -m "dotfiles: bump submodule"; fi

dotfiles-push: ## Push commits made inside the dotfiles submodule
	git -C dotfiles push

push: ## Push the dotfiles submodule, then nix (refuses if the pointer is not on GitHub)
	git -C dotfiles push
	git push --recurse-submodules=check

update: ## Update flake inputs
	nix flake update
