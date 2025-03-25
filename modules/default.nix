{
  flake = {
    nixosModules = {
      default = {
        imports = [
          ./overlays
          ./services/rsync-nixosconfig.nix
          ./networking/tproxy.nix
          ./networking/tproxy.nix
          ./services/vlmcsd.nix
          ./services/sing-box.nix
          ./services/qbittorrent.nix
        ];
      };
    };
  };
}
