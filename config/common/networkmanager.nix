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
        };
        ipv4.method = "auto";
        ipv6.method = "auto";
      };

      hotspot = lib.mkDefault {
        connection = {
          autoconnect = "false";
          id = "hotspot";
          interface-name = "wlan0";
          type = "wifi";
          controller = "br0";
          port-type = "bridge";
        };
        wifi = {
          band = "a";
          channel = "165";
          mode = "ap";
          ssid = "${config.networking.hostName}-5G";
        };
        wifi-security = {
          group = "ccmp";
          key-mgmt = "wpa-psk";
          pairwise = "ccmp";
          proto = "rsn";
          psk = "12345678";
        };
      };
    };
  };
}
