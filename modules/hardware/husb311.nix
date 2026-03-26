{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.hardware.husb311;
in
{
  options.hardware.husb311.enable = lib.mkEnableOption "HUSB311 Type-C controller kernel module";

  config = lib.mkIf cfg.enable {
    boot.extraModulePackages = [
      (pkgs.husb311.override { linux = config.boot.kernelPackages.kernel; })
    ];

    boot.kernelModules = [ "tcpci_husb311" ];
  };
}
