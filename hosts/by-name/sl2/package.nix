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
  ] ++ self.lib.listNixFilesRecursive ./web;

  boot = {
    initrd.availableKernelModules = [
      "virtio_scsi"
    ];
  };

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
