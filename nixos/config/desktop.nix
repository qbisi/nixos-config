{ pkgs, lib, ... }:
{
  hardware = {
    graphics.enable = true;
    bluetooth.enable = true;
  };

  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    nerd-fonts.hack
  ];

  fonts.fontconfig = {
    defaultFonts = {
      emoji = [ "Noto Color Emoji" ];
      monospace = [
        "Hack Nerd Font"
      ];
      sansSerif = [
        "Noto Sans CJK SC"
      ];
      serif = [
        "Noto Serif CJK SC"
      ];
    };
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.plasma6Support = true;
      fcitx5.waylandFrontend = true;
      fcitx5.addons = [
        pkgs.qt6Packages.fcitx5-chinese-addons
        pkgs.fcitx5-pinyin-zhwiki
      ];
    };
  };

  systemd.sleep.extraConfig = lib.mkDefault ''
    # disable hibernation
    AllowSuspend=no
    AllowHibernation=no
  '';
}
