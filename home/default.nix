{ inputs, self, ... }:
{
  systems = [
    "x86_64-linux"
    "x86_64-darwin"
    "aarch64-linux"
    "aarch64-darwin"
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
      legacyPackages.homeConfigurations = lib.packagesFromDirectoryRecursive {
        callPackage =
          path: _:
          (inputs.home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = {
              inherit inputs self system;
            };
            modules = [
              path
              inputs.vscode-server.homeModules.default
              inputs.nix-index-database.hmModules.nix-index
              inputs.secrets.homeModules.default
              ./home.nix
            ];
          });
        directory = ./profiles;
      };
    };
}
