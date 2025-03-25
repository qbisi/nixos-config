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
    tags = [
      "builder"
      "dev"
    ];
    buildOnTarget = true;
  };

  imports = [
    "${inputs.nixos-images}/devices/by-name/nixos-x86_64-uefi.nix"
    self.nixosModules.secrets
    ../../nixos/config/nettools.nix
  ];

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;
    graphics = {
      enable = true;
      # Fixup for opengl not found sshing from non-nixos system
      extraPackages = [
        (pkgs.runCommand "mesa_glxindirect" { } (''
          mkdir -p $out/lib
          ln -s ${pkgs.mesa}/lib/libGLX_mesa.so.0 $out/lib/libGLX_indirect.so.0
        ''))
      ];
    };
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
      7892 # docker autobangumi
    ];
  };

  environment = {
    systemPackages = with pkgs; [
      lm_sensors
    ];
  };

  virtualisation = {
    docker.enable = true;
    podman.enable = true;
    lxd.enable = true;
  };

  users.users.admin.extraGroups = [
    "podman"
    "docker"
    "lxd"
  ];

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

  systemd.services.nix-daemon.serviceConfig = {
    MemoryHigh = "100G";
    MemoryMax = "110G";
  };

  nix = {
    settings.max-jobs = 2;
    buildMachines = with self.vars.buildMachines; [
      ft
      mac
    ];
  };

  system.stateVersion = "24.11";
}
