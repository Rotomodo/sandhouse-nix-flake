{
  description = "SandHouse, the desktop app, for Nix and NixOS";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      # The releases only have an x86_64 Linux build so far.
      systems = [ "x86_64-linux" ];
      # SandHouse isn't open source (meta.license is unfree), so allow it,
      # and only it, here; the overlay's users allow it in their own config.
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          f (
            import nixpkgs {
              inherit system;
              config.allowUnfreePredicate = pkg: nixpkgs.lib.getName pkg == "sandhouse";
            }
          )
        );
    in
    {
      packages = forAllSystems (pkgs: {
        sandhouse = pkgs.callPackage ./package.nix { };
        default = self.packages.${pkgs.stdenv.hostPlatform.system}.sandhouse;
      });

      apps = forAllSystems (pkgs: {
        default = {
          type = "app";
          program = "${self.packages.${pkgs.stdenv.hostPlatform.system}.sandhouse}/bin/sandhouse";
          meta.description = "Run SandHouse";
        };
      });

      overlays.default = final: _prev: {
        sandhouse = final.callPackage ./package.nix { };
      };

      nixosModules.default = import ./modules/nixos.nix self;
      homeManagerModules.default = import ./modules/home-manager.nix self;

      # For update.sh.
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = [
            pkgs.curl
            pkgs.jq
          ];
        };
      });

      formatter = forAllSystems (pkgs: pkgs.nixfmt);
    };
}
