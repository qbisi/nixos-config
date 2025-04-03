{ lib, self, ... }:
{
  flake = {
    nixosModules = {
      default = {
        disabledModules = [
          "config/swap.nix"
          "services/networking/mptcpd.nix"
          "services/networking/nat.nix"
          "services/networking/nat-nftables.nix"
          "${self}/modules/default.nix"
        ];

        imports = lib.filesystem.listFilesRecursive ./.;
      };
    };
  };
}
