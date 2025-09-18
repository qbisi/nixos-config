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
      ];
    };
    networkConfig = {
      Private = false;
    };
  };
}
