{ pkgs, lib, ... }:
{
  hardware = {
    graphics = {
      enable = true;
      # Fixup for opengl not found sshing from non-nixos system 
      extraPackages = [
        (pkgs.runCommand "mesa_glxindirect" { } (''
          mkdir -p $out/lib
          ln -s ${pkgs.mesa}/lib/libGLX_mesa.so.0 $out/lib/libGLX_indirect.so.0
        ''))
      ];
    };
    bluetooth.enable = true;
  };

  security.rtkit.enable = true;

  services = {
    desktopManager.plasma6.enable = true;

    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };

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
      fcitx5.addons = [
        pkgs.qt6Packages.fcitx5-chinese-addons
        pkgs.fcitx5-pinyin-zhwiki
      ];
    };
  };

  environment.systemPackages = [ pkgs.wl-clipboard ];

  systemd.sleep.extraConfig = lib.mkDefault ''
    # disable hibernation
    AllowSuspend=no
    AllowHibernation=no
  '';
}
