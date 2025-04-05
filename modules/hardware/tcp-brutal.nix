{
  lib,
  pkgs,
  config,
  ...
}:
{
  boot.extraModulePackages = lib.mkIf (builtins.elem "brutal" config.boot.kernelModules) [
    (pkgs.tcp-brutal.override { linux = config.boot.kernelPackages.kernel; })
  ];
}
