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
    "${self}/config/nettools.nix"
    self.nixosModules.secrets
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
