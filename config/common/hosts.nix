{
  lib,
  pkgs,
  config,
  self,
  inputs,
  ...
}:
{
  networking.hosts = {
    "${self.vars.hosts.h88k.ip}" = [
      "drive.h88k.${self.vars.domain}"
    ];
    "${self.vars.hosts.x79.ip}" = lib.mkIf (config.networking.hostName != "sl2") [
      "cache.csrc.eu.org"
      "hydra.csrc.eu.org"
    ];
  };
}
