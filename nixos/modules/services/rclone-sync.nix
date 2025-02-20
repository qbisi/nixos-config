{
  lib,
  pkgs,
  self,
  ...
}:
let
  cfg = config.services.rsyncd;
  settingsFormat = pkgs.formats.keyValue { };
  configFile = settingsFormat.generate "rclone-syncd.conf" cfg.settings;
in
{
  options = {
    services.rclone-sync = {

      enable = lib.mkEnableOption "the rclone-sync timer/service";
    };
  };

  config = {

    environment.systemPackages = [ pkgs.rclone ];

    systemd.services.rsync-nixosconfigurations = {
      description = "Rsync this flake source to /etc/nixos";

      enable = lib.mkDefault true;
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      path = with pkgs; [ rsync ];
      script = ''
        rsync -a --delete --chmod=D770,F660 "${self}/" /etc/nixos
      '';
    };
  };
}
