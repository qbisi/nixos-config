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
        "/etc/nix/nix.conf"
        "/proc/sys/fs/binfmt_misc"
        "/run/binfmt"
      ];
    };
    networkConfig = {
      Private = false;
    };
  };
}
