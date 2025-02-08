{ pkgs, ... }:
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
    noto-fonts
    # noto-fonts-cjk-sans
    # noto-fonts-cjk-serif
    source-han-sans
    source-han-serif
    # sarasa-gothic
    source-code-pro
    hack-font
    jetbrains-mono
  ];

  fonts.fontconfig = {
    defaultFonts = {
      emoji = [ "Noto Color Emoji" ];
      monospace = [
        "Noto Sans Mono CJK SC"
        "Sarasa Mono SC"
        "DejaVu Sans Mono"
      ];
      sansSerif = [
        "Noto Sans CJK SC"
        "Source Han Sans SC"
        "DejaVu Sans"
      ];
      serif = [
        "Noto Serif CJK SC"
        "Source Han Serif SC"
        "DejaVu Serif"
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
}
