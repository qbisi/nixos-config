{ lib, config, ... }:
{
  systemd.nspawn.debian = {
    execConfig = {
      Boot = true;
      PrivateUsers = 0;
    };
    filesConfig = {
      Bind = [
        "/home"
        "/nix/store"
        "/run/current-system/sw/bin/nix:/usr/bin/nix"
      ];
    };
    networkConfig = {
      Private = false;
    };
  };
}
