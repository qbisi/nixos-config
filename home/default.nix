{ inputs, self, ... }:
let
  inherit (inputs.home-manager.lib) homeManagerConfiguration;
  profiles = self.lib.listNixName "${self}/home/profiles";
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
            inputs.vscode-server.homeModules.default
            inputs.nix-index-database.hmModules.nix-index
            self.homeManagerModules.secrets
            ./home.nix
            "${self}/home/profiles/${profile}.nix"
          ];
        }
      );
    };
}
