# programs.sandhouse for NixOS: installs SandHouse for every user.
self:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.sandhouse;
in
{
  options.programs.sandhouse = {
    enable = lib.mkEnableOption "SandHouse, the desktop app";
    package = lib.mkOption {
      type = lib.types.package;
      default = self.packages.${pkgs.stdenv.hostPlatform.system}.sandhouse;
      defaultText = lib.literalExpression "sandhouse-nix-flake.packages.\${system}.sandhouse";
      description = "The SandHouse package to install.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
  };
}
