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
    targetHost = "192.168.100.250";
    tags = [
      "desktop"
      "dev"
    ];
  };

  disko.bootImage.partLabel = "nvme";

  hardware = {
    deviceTree.dtsFile = lib.mkForce ./rk3588-hinlink-h88k.dts;
  };

  boot = {
    kernelModules = [ "ledtrig-netdev" ];
  };

  imports = [
    "${inputs.nixos-images}/devices/by-name/nixos-hinlink-h88k.nix"
    "${self}/config/desktop.nix"
    "${self}/config/nettools.nix"
  ];

  networking = {
    hostName = "h89k";
    useDHCP = false;
    useNetworkd = true;
    networkmanager.enable = true;
    firewall.allowedUDPPorts = [
      5355 # LLMNR
    ];
  };

  virtualisation.waydroid.enable = true;

  system.stateVersion = "25.05";
}
