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
    tags = [
      "router"
      "dev"
    ];
  };

  imports = [
    "${inputs.nixos-images}/devices/by-name/nixos-hinlink-h88k.nix"
    "${self}/config/desktop.nix"
    "${self}/config/nas.nix"
    ./networking.nix
  ];

  hardware = {
    deviceTree.dtsFile = lib.mkForce "${self}/dts/rk3588-hinlink-h88k.dts";
  };

  disko.bootImage.partLabel = "nvme";

  fileSystems = {
    "/gigatf" = {
      device = "/dev/disk/by-uuid/e64827a8-9986-42da-8364-a958dcd129d4";
      fsType = "f2fs";
      options = [
        "nofail"
        "x-systemd.wanted-by=dev-disk-by\\x2duuid-e64827a8\\x2d9986\\x2d42da\\x2d8364\\x2da958dcd129d4.device"
        "nodev"
        "noatime"
      ];
    };
    "/data" = {
      device = "/.data:/gigatf=RO";
      fsType = "mergerfs";
      options = [
        "nodev"
        "nofail"
        "cache.files=off"
        "dropcacheonclose=false"
        "category.create=mfs"
      ];
    };
  };

  services = {
    vlmcsd = {
      enable = true;
      disconnectClients = true;
      openFirewall = true;
    };
  };

  services.onedrive.enable = true;

  systemd.slices."user-1000".sliceConfig = {
    CPUQuota = "600%";
    MemoryMax = "12G";
  };

  environment.systemPackages = with pkgs; [
    minicom
    rclone
    mergerfs
    rkdeveloptool
    myrktop
    onedrivegui
  ];

  environment.variables = {
    ALSA_CONFIG_UCM2 = pkgs.symlinkJoin {
      name = "ucm2-rk3588";
      paths = [
        "${self}/ucm2"
        "${pkgs.alsa-ucm-conf}/share/alsa/ucm2"
      ];
    };
  };

  nix.buildMachines = with self.vars.buildMachines; [
    ft
    x79
    mac
  ];

  system.stateVersion = "24.11";
}
