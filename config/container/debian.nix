{ lib, config, ... }:
{
  systemd.nspawn.debian = {
    execConfig = {
      Boot = true;
      PrivateUsers = 0;
      Capability = "CAP_MKNOD";
    };
    filesConfig = {
      BindReadOnly = [
        "/nix/store"
        "/nix/var/nix/db"
        "/nix/var/nix/daemon-socket"
      ];
      Bind = [
        "/home"
        "/run/current-system/sw/bin/nix:/usr/bin/nix"
        "/etc/nix/registry.json"
        "/etc/nix/nix.conf"
      ];
    };
    networkConfig = {
      Private = false;
    };
  };

  systemd.services."systemd-nspawn@debian" = {
    serviceConfig = {
      DeviceAllow = [
        "block-loop rwm"
      ];
    };
    overrideStrategy = "asDropin";
  };
}
