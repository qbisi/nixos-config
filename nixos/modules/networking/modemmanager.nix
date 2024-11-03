{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.networking.modemmanager;
in
{
  options = {
    networking.modemmanager = {
      enable = mkEnableOption "ModemManager";

      apn = mkOption {
        type = types.str;
        default = "";
        example = "ctnet";
        description = "Access Point Name. Required in 3GPP.";
      };

      enableIPv6 = mkOption {
        type = types.bool;
        default = true;
        description = "enable modem ipv6";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.ModemManager.enable = true;
    systemd.services.ModemManager.partOf = [ "NetworkManager.service" ];
    systemd.services.ModemManager.wantedBy = [ "multi-user.target" ];

    environment.systemPackages = [ pkgs.modemmanager ];

    networking.networkmanager.ensureProfiles.profiles = {
      wwan0 = {
        connection = {
          id = "wwan0";
          interface-name = "cdc-wdm0";
          type = "gsm";
        };
        gsm = {
          apn = cfg.apn;
        };
        ipv4 = {
          method = "auto";
        };
        ipv6 = {
          method = if cfg.enableIPv6 then "auto" else "ignore";
        };
      };
    };
  };
}
