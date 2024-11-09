{
  flake = {
    nixosModules = {
      default = {
        imports = [
          ./modules/overlays
          ./modules/services/rsync-nixosconfig.nix
          ./modules/networking/tproxy.nix
          ./modules/networking/modemmanager.nix
          ./modules/services/sing-box.nix
        ];
      };
      common = ./config/common.nix;
      router = ./config/router.nix;
      vps = ./config/vps.nix;
      desktop = ./config/desktop.nix;
    };
  };
}
