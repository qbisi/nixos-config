{ pkgs, config, ... }:
{
  environment.systemPackages = with pkgs; [
    obs-studio
    # not supported on aarch64
    # obs-studio-plugins.looking-glass-obs
    # obs-studio-plugins.obs-nvfbc
    # obs-studio-plugins.wlrobs
    obs-studio-plugins.obs-gstreamer
  ];

  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];

  users.users.admin.extraGroups = [ "video" ];
}