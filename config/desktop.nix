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

    onedrive.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    printing.enable = true;
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
      fcitx5.plasma6Support = true;
      fcitx5.waylandFrontend = true;
      fcitx5.addons = with pkgs; [
        fcitx5-chinese-addons
        fcitx5-pinyin-zhwiki
        (fcitx5-rime.override {
          rimeDataPkgs = [
            rime-data
            rime-ice
          ];
        })
      ];
    };
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
    onedrivegui
    element-desktop
    obsidian
  ];

  systemd.sleep.extraConfig = lib.mkDefault ''
    # disable hibernation
    AllowSuspend=no
    AllowHibernation=no
  '';
}
