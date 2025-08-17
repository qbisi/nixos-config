{
  lib,
  config,
  pkgs,
  self,
  inputs,
  ...
}:
{
  systemd.services.ModemManager.wantedBy = lib.mkIf config.networking.modemmanager.enable [ "multi-user.target" ];

  networking.networkmanager = lib.mkIf config.networking.networkmanager.enable {
    settings.main.no-auto-default = lib.mkDefault "*";

    ensureProfiles.profiles = {
      wwan0 = {
        connection = {
          id = "wwan0";
          interface-name = "cdc-wdm0";
          type = "gsm";
          mptcp-flags = 1;
        };
        ipv4.method = "auto";
        ipv6.method = "auto";
      };
    };
  };
}
