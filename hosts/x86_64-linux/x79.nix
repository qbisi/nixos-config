{
  config,
  pkgs,
  lib,
  modulesPath,
  self,
  inputs,
  ...
}:
{
  deployment = {
    tags = [
      "builder"
      "dev"
    ];
    buildOnTarget = true;
  };

  imports = [
    "${inputs.nixos-images}/devices/x86_64-linux/nixos-x86_64-uefi.nix"
    self.nixosModules.secrets
    ../../nixos/config/nettools.nix
  ];

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;
  };

  boot = {
    kernelParams = [
      "console=tty1"
    ];
    kernelModules = [ "kvm-intel" ];
    initrd.availableKernelModules = [
      "ehci_pci"
      "ahci"
      "mpt3sas"
      "xhci_pci"
      "usbhid"
      "sd_mod"
      "sr_mod"
    ];
  };

  networking = {
    hostName = "x79";
    proxy.default = "http://${self.vars.hostIP.h88k}:1080";
    firewall.allowedTCPPorts = [
      7892
    ];
  };

  environment = {
    systemPackages = with pkgs; [
      lm_sensors
    ];
  };

  virtualisation = {
    docker.enable = true;
    podman = {
      enable = true;
      # dockerCompat = true;
    };
  };

  users.users.admin.extraGroups = [ "podman" "docker" ];

  # virtualisation.oci-containers.containers = {
  #   autoBangumi = {
  #     image = "ghcr.io/estrellaxd/auto_bangumi:latest";
  #     ports = [ "7892:7892" ];
  #     volumes = [
  #       "/var/lib/autobangumi/config:/app/config"
  #       "/var/lib/autobangumi/data:/app/data"
  #     ];
  #     environment = {
  #       UMASK = "022";
  #       PGID = toString config.users.groups.${config.users.users.qbittorrent.group}.gid;
  #       PUID = toString config.users.users.qbittorrent.uid;
  #     };
  #   };
  # };

  nix.buildMachines = with self.vars.buildMachines; [
    ft
    mac
  ];

  system.stateVersion = "24.11";
}
