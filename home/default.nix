{ inputs, self, ... }:
{
  perSystem =
    {
      config,
      pkgs,
      lib,
      inputs',
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
              inherit
                inputs'
                inputs
                self
                system
                ;
            };
            modules = [
              path
              inputs.vscode-server.homeModules.default
              inputs.nix-index-database.homeModules.nix-index
              inputs.secrets.homeModules.default
              ./home.nix
            ];
          });
        directory = ./profiles;
      };
    };
}
