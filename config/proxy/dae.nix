{
  lib,
  pkgs,
  config,
  self,
  inputs,
  ...
}:
{
  services.dae = {
    enable = true;

    openFirewall = {
      enable = true;
      port = 12345;
    };

    package = pkgs.dae;
    disableTxChecksumIpGeneric = false;
    configFile = "/etc/dae/config.dae";
    assets = with pkgs; [ v2ray-rules-dat ];
  };

  services.daed = {
    # enable = true;

    openFirewall = {
      enable = true;
      port = 12345;
    };

    /*
      default options

      package = inputs.daeuniverse.packages.x86_64-linux.daed;
      configDir = "/etc/daed";
      listen = "127.0.0.1:2023";
    */
  };
}
