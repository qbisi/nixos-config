{
  lib,
  config,
  pkgs,
  self,
  inputs,
  ...
}:
let
  hostnames = [
    "x79"
    "ft"
    "ody"
  ];
in
{
  networking.proxy.default = lib.mkIf (builtins.elem config.networking.hostName hostnames) (
    lib.mkDefault "http://${self.vars.hostIP.h88k}:1080"
  );
}
