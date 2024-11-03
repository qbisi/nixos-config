{ inputs, self, ... }:
let
  inherit (inputs.home-manager.lib) homeManagerConfiguration;
  profiles = self.lib.listNixname "${self}/home/profiles";
in
{
  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];
  perSystem =
    {
      config,
      pkgs,
      lib,
      system,
      ...
    }:
    {
      legacyPackages.homeConfigurations = lib.genAttrs profiles (
        profile:
        homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit inputs self system;
          };
          modules = [
            ./home.nix
            "${self}/home/profiles/${profile}.nix"
          ];
        }
      );
    };
}
