{ pkgs, lib, ... }:
{
  hardware = {
    graphics.enable = true;
    bluetooth.enable = true;
  };

  security.rtkit.enable = true;

  services = {
    desktopManager.plasma6.enable = true;

    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };

    printing = {
      enable = true;
      drivers = with pkgs; [
        brlaser
      ];
    };
  };

  programs.system-config-printer.enable = true;

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
      fcitx5.waylandFrontend = true;
      fcitx5.addons = with pkgs; [
        fcitx5-pinyin-zhwiki
      ];
    };
  };

  programs.chromium = {
    enable = true;
    extensions = [
      "oeopbcgkkoapgobdbedcemjljbihmemj" # mail
      "pfnededegaaopdmhkdmcofjmoldfiped" # proxy
      "cimiefiiaegbelhefglklhhakcgmhkai" # plasma
    ];
  };

  environment.systemPackages = with pkgs; [
    wl-clipboard
    chromium
    mpv
    obs-studio
    telegram-desktop
    glmark2
    vulkan-tools
    mesa-demos
    element-desktop
    onedrivegui
  ];

  systemd.sleep.extraConfig = lib.mkDefault ''
    # disable hibernation
    AllowSuspend=no
    AllowHibernation=no
  '';
}
