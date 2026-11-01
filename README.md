# SandHouse for Nix

A Nix flake for [SandHouse](https://sandhouse.app)'s desktop app on NixOS
or any Linux with Nix. It packages the official Linux release from
[Rotomodo/sandhouse-releases](https://github.com/Rotomodo/sandhouse-releases)
and keeps up with new releases on its own.

64-bit Intel/AMD (`x86_64-linux`) only for now.

## Try it

```sh
nix run github:Rotomodo/sandhouse-nix-flake
```

## Install it

### NixOS

Add the flake to your system's `flake.nix` and turn on the module:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    sandhouse.url = "github:Rotomodo/sandhouse-nix-flake";
    sandhouse.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, sandhouse, ... }: {
    nixosConfigurations.my-machine = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        sandhouse.nixosModules.default
        { programs.sandhouse.enable = true; }
      ];
    };
  };
}
```

### Home Manager

```nix
{
  imports = [ sandhouse.homeManagerModules.default ];
  programs.sandhouse.enable = true;
}
```

### A profile, without a configuration

```sh
nix profile install github:Rotomodo/sandhouse-nix-flake
```

### The overlay

`overlays.default` adds `pkgs.sandhouse` to your own nixpkgs. SandHouse isn't
open source, so your nixpkgs config has to allow it:

```nix
nixpkgs.config.allowUnfreePredicate = pkg: lib.getName pkg == "sandhouse";
```

The modules and `nix run` don't need this; the flake allows it for its own
package.

## Staying signed in

The app keeps your session in the Secret Service: GNOME Keyring or KWallet.
On a desktop without one (a bare window manager, say), it asks you to sign
in every time it starts. On NixOS, `services.gnome.gnome-keyring.enable =
true;` provides one anywhere.

## Updates

A daily GitHub Action (`.github/workflows/update.yml`) checks for a new
release, points `sources.json` at it, checks that it builds, and commits.
`nix flake update sandhouse` in your configuration then picks it up.

By hand: `nix develop -c ./update.sh`.

## Problems

Anything about the app itself: the contact link at the bottom of
[sandhouse.app](https://sandhouse.app). Packaging problems: open an issue
here.
