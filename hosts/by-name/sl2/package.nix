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
    "${self}/config/web/alist.nix"
    "${self}/config/web/attic.nix"
    "${self}/config/web/harmonia.nix"
    "${self}/config/web/hydra.nix"
  ];

  boot = {
    initrd.availableKernelModules = [
      "virtio_scsi"
    ];
  };

  services.nginx.serverName = config.networking.domain;

  networking = {
    hostName = "sl2";
    domain = self.vars.domain;
    useDHCP = false;
    useNetworkd = true;
    interfaces.eth0.useDHCP = true;
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
    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
      dates = "weekly";
    };
  };

  system.stateVersion = "25.05";
}
