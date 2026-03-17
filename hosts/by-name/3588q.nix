{
  config,
  pkgs,
  lib,
  self,
  inputs,
  ...
}:
{
  deployment = {
    targetHost = "192.168.100.187";
    targetUser = "root";
    tags = [
      "test"
    ];
    buildOnTarget = false;
  };

  imports = [
    "${inputs.nixos-images}/devices/by-name/nixos-firefly-aio-3588q.nix"
    "${inputs.nixos-images}/modules/config/passless.nix"
  ];

  disabledModules = [ "${self}/config/common.nix" ];

  hardware = {
    deviceTree.dtsFile = lib.mkForce "${self}/dts/rk3588-firefly-aio-3588q.dts";
  };

  environment.variables = {
    MESA_GLSL_VERSION_OVERRIDE = 330;
    ALSA_CONFIG_UCM2 = "${pkgs.alsa-ucm-conf-rk3588}/share/alsa/ucm2";
  };

  environment.systemPackages = with pkgs; [
    usbutils
    pciutils
    minicom
    libgpiod
  ];

  system.stateVersion = "25.11";
}
