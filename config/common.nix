{
  lib,
  config,
  pkgs,
  self,
  inputs,
  ...
}:
{
  imports = [
    self.nixosModules.default
    inputs.nixos-images.nixosModules.default
    inputs.nur-fem.nixosModules.default
    inputs.secrets.nixosModules.default
  ] ++ lib.listNixFilesRecursive ./common;

  nixpkgs.flake.source = lib.mkDefault inputs.nixpkgs;

  time.timeZone = "Asia/Shanghai";

  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    home-manager
    tree
    htop
    fastfetch
    rsync
    usbutils
    pciutils
  ];

  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld;
  };

  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      help = "run-help";
    };
    interactiveShellInit = ''
      if [ "$VSCODE_INJECTION" = "1" ]; then
        if [[ "$VSCODE_ZDOTDIR" == *"code"* ]]; then
          export EDITOR="code --wait"
        elif [[ "$VSCODE_ZDOTDIR" == *"codium"* ]]; then
          export EDITOR="codium --wait"
        fi
      fi
    '';
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

  networking = {
    useNetworkd = true;
    nftables.enable = true;
  };

  networking.tproxy.users = [ config.users.users.admin.name ];

  users.defaultUserShell = pkgs.zsh;

  users.users = {
    admin = {
      inherit (self.vars.user) name hashedPassword;
      uid = 1000;
      isNormalUser = true;
      linger = true;
      shell = pkgs.zsh;
      extraGroups = [
        "wheel"
        "root"
        "video"
        "audio"
      ];
      openssh.authorizedKeys.keys = [
        self.vars.user.authorizedKeys
      ];
    };
    root.openssh.authorizedKeys.keys = [
      self.vars.user.authorizedKeys
    ];
  };

  nix = {
    registry = {
      colmena.to = {
        owner = "zhaofengli";
        repo = "colmena";
        type = "github";
      };
    };

    settings = {
      keep-outputs = true;
      # auto-optimise-store = true;
      warn-dirty = false;
      # Whether to accept nix configuration from a flake without prompting.
      accept-flake-config = true;
      experimental-features = [
        "nix-command"
        "flakes"
        # "pipe-operators"
      ];
      trusted-users = [ config.users.users.admin.name ];
      substituters =
        [
          "https://cache.garnix.io"
          # "https://colmena.cachix.org"
          "https://nix-community.cachix.org"
          # "ssh://root@${self.vars.hosts.x79.ip}?ssh-key=/run/agenix/id_ed25519"
        ]
        ++ lib.optionals (!(builtins.elem "!cn" config.deployment.tags)) [
          "https://mirrors.ustc.edu.cn/nix-channels/store"
        ];
      # builders-use-substitutes = true;
      fallback = true;
      connect-timeout = 3;
      trusted-public-keys = [
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
        "cache.csrc.eu.org-1:x5rEGDqKTfp6brF2lvevAhDtBWZFrSWx7u8EH/kL/6k="
        "cache.qbisi.cc-1:xEChzP5k8fj+7wajY+e9IDORRTGMhViP5NaqMShGGjQ="
      ];
    };

    package = pkgs.nixVersions.latest;

    distributedBuilds = true;
  };
}
