{
  config,
  pkgs,
  lib,
  self,
  inputs,
  ...
}:
{

  imports = [
    inputs.nixos-wsl.nixosModules.default
  ];

  networking.hostName = "nixos-wsl";

  wsl.enable = true;
  wsl.defaultUser = self.vars.user.name;

  system.stateVersion = "24.05";
}