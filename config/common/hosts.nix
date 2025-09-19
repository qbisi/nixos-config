{
  lib,
  self,
  ...
}:
{
  networking.hosts = lib.mapAttrs' (n: v: lib.nameValuePair v.ip [ n ]) self.vars.hosts;
}
