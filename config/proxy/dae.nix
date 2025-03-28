{
  lib,
  pkgs,
  config,
  self,
  inputs,
  ...
}:
{
  # services.dae = {
  #   enable = true;

  #   openFirewall = {
  #     enable = true;
  #     port = 12345;
  #   };

  #   package = pkgs.dae;
  #   disableTxChecksumIpGeneric = false;
  #   configFile = "/etc/dae/config.dae";
  #   assets = with pkgs; [ v2ray-rules-dat ];
  # };

  services.daed = {
    enable = true;

    openFirewall = {
      enable = true;
      port = 12345;
    };

    package = pkgs.daed;
    configDir = "/etc/dae";
    listen = "0.0.0.0:2023";

    assetsPaths = [
      "${pkgs.v2ray-rules-dat}/share/v2ray/geoip.dat"
      "${pkgs.v2ray-rules-dat}/share/v2ray/geosite.dat"
    ];
  };

  networking.firewall.allowedTCPPorts = [
    2023
  ];
}
