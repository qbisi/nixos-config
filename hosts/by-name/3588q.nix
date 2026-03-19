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
    self.nixosModules.default
    inputs.nixos-images.nixosModules.default
  ];

  disabledModules = [ "${self}/config/common.nix" ];

  hardware = {
    deviceTree = {
      dtsFile = lib.mkForce "${self}/dts/rk3588-firefly-aio-3588q.dts";
      overlays = [
        {
          name = "mipi-yx4005";
          dtsFile = "${self}/dts/overlays/rk3588-mipi-yx4005.dtso";
        }
      ];
      dtboBuildExtraIncludePaths = lib.mkBefore [ "${self}/dts" ];
    };
    graphics.enable = true;
    bluetooth.enable = false;
  };

  networking = {
    useNetworkd = true;
    nftables.enable = true;
    wireless = {
      enable = true;
      networks = {
        "jpzg" = {
          # wpa_passphrase <SSID> <passphrase>
          pskRaw = "d19fc5fba94188f5920bad77e8831993a92379bca58b0de0d62e262ce2c17e95";
        };
      };
    };
  };

  users = {
    defaultUserShell = pkgs.zsh;
    users = {
      admin = {
        name = "nixusr";
        initialPassword = "nixusr";
        uid = 1000;
        isNormalUser = true;
        linger = true;
        extraGroups = [
          "wheel"
          "root"
          "video"
          "audio"
        ];
      };
    };
  };

  time.timeZone = "Asia/Shanghai";

  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    ohMyZsh = {
      enable = true;
      theme = "gentoo";
      plugins = [
        "git"
        "history"
        "wd"
        "sudo"
      ];
    };
  };

  services = {
    desktopManager.plasma6.enable = true;

    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
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
    ethtool
    iperf3
    myrktop
    vim
    git
  ];

  system.stateVersion = "25.11";
}
