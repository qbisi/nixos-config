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
    "${self.vars.hosts.x79.ip}" = [
      "cache.x79.${self.vars.domain}"
      "hydra.x79.${self.vars.domain}"
    ];
  };
}
