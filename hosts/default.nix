{
  self,
  inputs,
  lib,
  ...
}:
let
  shareModules = [
    self.nixosModules.default
    self.nixosModules.common
    inputs.nixos-images.nixosModules.default
    { nixpkgs.overlays = [ self.overlays.default ]; }
  ];
in
{
  flake = {
    nixosConfigurations = lib.packagesFromDirectoryRecursive {
      callPackage =
        path: _:
        lib.nixosSystem {
          specialArgs = {
            inherit inputs self;
          };
          modules = shareModules ++ [
            path
            inputs.colmena.nixosModules.deploymentOptions
          ];
        };
      directory = ./by-name;
    };

    colmena = lib.packagesFromDirectoryRecursive {
      callPackage = path: _: {
        imports = shareModules ++ [
          path
          # SSH to llmnr hosts need retry to wait for hostname resolution.
          # Requires colmena version > 0.5.0.
          { deployment.sshOptions = [ "-o ConnectionAttempts=2" ]; }
        ];
      };
      directory = ./by-name;
    };
  };
}
