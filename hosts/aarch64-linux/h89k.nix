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
    targetHost = "192.168.100.69";
    # buildOnTarget = true;
    tags = [
      "desktop"
      "dev"
    ];
  };

  imports = [
    "${inputs.nixos-images}/devices/aarch64-linux/nixos-hinlink-h88k.nix"
    self.nixosModules.desktop
  ];

  networking = {
    hostName = "h89k";
  };

}
