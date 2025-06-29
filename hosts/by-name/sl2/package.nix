{
  config,
  pkgs,
  lib,
  self,
  inputs,
  ...
}:
{
  deployment = {
    buildOnTarget = true;
    tags = [ "server" ];
  };

  imports = [
    "${inputs.nixos-images}/devices/by-name/nixos-aarch64-uefi.nix"
    "${inputs.nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
    "${self}/config/web/openlist.nix"
    "${self}/config/web/harmonia.nix"
    "${self}/config/web/hydra.nix"
  ] ++ lib.listNixFilesRecursive ./web;

  boot = {
    initrd.availableKernelModules = [
      "virtio_scsi"
    ];
  };

  services.nginx.serverName = config.networking.domain;

  networking = {
    hostName = "sl2";
    domain = self.vars.domain;
    useNetworkd = true;
    firewall = {
      allowedTCPPorts = [
        80
        443
      ];
      allowedUDPPorts = [
        443
      ];
    };
  };

  nix = {
    settings = {
      max-jobs = 2;
      cores = 2;
    };
  };

  system.stateVersion = "25.05";
}
