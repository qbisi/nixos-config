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
    ./hk.nix
  ];

  networking.hostName = lib.mkForce "sg1";
}
