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
    ./web/hydra.nix
    ./web/attic.nix
  ];

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

  services.nginx = {
    enable = true;
    group = "acme";
    defaultSSLListenPort = 443;
  };

  system.stateVersion = "25.05";
}
